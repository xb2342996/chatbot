from flask import Flask, request, jsonify, make_response
import dialogflow
import json
import requests
import os

from db_data import authentication, History, User, user_register, user_response_dict, UserManager, set_up_db, \
    check_require


import light_control
import music_player
import health_record
import more_human
from model import Response
from model import FulfillmentText
from model import Selection
from model import Music_Instruction

import video_service
import recommend_movie
import movie_info
import pymongo


app = Flask(__name__)

'''
Const Value
'''
response_type = {
    'text': 1,
    'light': 2,
    'health': 3,
    'movie_info': 4,
    'movielist': 5,
    'track': 6,
    'album' : 7,
    'playlist': 8,
    'list_selection' : 9,
    'music_control':10,
    'video':11
}

movie_info_type = {
    'overview': 0,
    'star': 1,
    'director': 2,
    'genre': 3,
    'plot': 4,
    'year': 5,
    'writer': 6,
    'rating': 7,
    'trailer':8
}
health_info_type = {
    'steps' : 1,
    'walking distance' : 2,
    'sleep analysis' : 3,
    'calorie' : 4,
    'heart rate' : 5,
}
music_instruction = {
    'play': 1,
    'pause': 2,
    'next': 3,
    'previous': 4,
    'shuffle': 5,
    'repeat':6
}
action_to_type = {
    "loop_list":"repeat",
    "pause":"pause",
    "play":"play",
    "resume":"play",
    "shuffle":"shuffle",
    "skip_backward":"previous",
    "skip_forward":"next",
    "stop":"pause"
    }


"""
connect to dialogflow function, post message to dialogflow and obtain response
request:  method: post  
response: type: json     
"""


@app.route('/message', methods=['POST', 'GET'])
def send_message():
    message = request.form['content']
    project_id = os.getenv("DIALOGFLOW_PROJECT_ID")
    fulfillment_text, action = detect_intent_texts(project_id, "unique", message, 'en')
    type, contents, msg = '', None, ''

    # return recommend movie list
    if action == 'recommendation':
        state = recommend_movie.get_user_rs_state()

        # personalized recommendation
        if state == '1':
            recommend_movie.store_user_profile()
            search_results = recommend_movie.recommand_movies()
            contents = {'playlists': search_results}
            msg = 'You can tell me the number or touch the option to choose the recommended movie'
            type = 'movielist'

        # recommend according to the movie's hotness
        else:
            search_results = recommend_movie.recommond_hotest_movie()
            contents = {'playlists': search_results}
            msg = 'You can tell me the number or touch the option to choose the recommended movie'
            type = 'movielist'

    # reply fulfillment_text set in dialogflow
    elif action =='input.unknown':
        msg = fulfillment_text
        type = 'text'
        contents = {}

    elif action[:5] == "movie":
        # ERROR: multiple movies
        if fulfillment_text == "0":
            msg = 'only one movie permitted'
            type = 'text'

        # give information for the movie
        else:
            if action == "movie.trailer":
                movie_name, type_of_info = fulfillment_text.split("#")
                video_info = video_service.youtube_search(movie_name)[0]
                type='video'
                msg=more_human.wrong_movie_response()
                contents=video_info
            else:
                movie_name, type_of_info = fulfillment_text.split("#")
                moive_data = movie_info.get_movie_info(movie_name)
                contents = {'type': movie_info_type[type_of_info], 'movie': moive_data}
                msg=more_human.wrong_movie_response()
                type = 'movie_info'
            year = movie_info.get_movie_year(movie_name)
            recommend_movie.init_feedback(movie_name,int(year))


    # based on the movie name user given in last step, generate search result list
    elif action == "notasexpected":
        movie_name, type_of_info = fulfillment_text.split('#')
        search_results = movie_info.find_results(movie_name,type_of_info)
        msg = 'You can tell me the number or touch the option to choose the movie you expected'
        contents = {'playlists': search_results}
        type = 'movielist'

    # select movie from search result list
    elif action == "select.movie":
        # ERROR: input multiple number
        if len(fulfillment_text) > 10:
            msg = fulfillment_text
            type = "text"

        # base on the number user choose, return the corresponding movie info
        else:
            number, type_of_info = fulfillment_text.split('#')
            number = int(number)
            contents = Selection(response_type["movie_info"], number, type_of_info).to_dict()
            msg = more_human.movie_selection_response()
            type='list_selection'

    # select movie from  result recommendation list
    elif action == "select.rs":
        # ERROR: input multiple number
        if len(fulfillment_text) > 10:
            msg = fulfillment_text
            type = "text"

        # base on the number user choose, return the corresponding movie info
        else:
            number, type_of_info = fulfillment_text,'overview'
            number = int(number)
            contents = Selection(response_type["movie_info"], number, type_of_info).to_dict()
            msg = more_human.movie_selection_response()
            type='list_selection'

    # small talk
    elif "smalltalk" in action:
        type="text"
        msg=fulfillment_text+" you can ask me information about movies(details,actors,rating etc) and play music for you by asking the artists or their albums. i can also obtain the health data from your Apple Watch if you have one. Oh!dont't forget to connect your LIFX buble so you can control it from here"
        contents = fulfillment_text

    # defalut welcome
    elif action == "input.welcome":
        type="text"
        msg=fulfillment_text+" you can ask me information about movies(details,actors,rating etc) and play music for you by asking the artists or their albums. i can also obtain the health data from your Apple Watch if you have one. Oh!dont't forget to connect your LIFX buble so you can control it from here"
        contents = fulfillment_text

    # health
    elif action == "health":
        health_type, start_date, end_date = fulfillment_text.split('#')
        if health_type =='None':
            msg='could you say that again?'
            type='text'
            contents={}
        else:        
            
            msg = health_record.generate_res(health_type, start_date, end_date)
            type = 'health'
            health_type = health_type.split(',')
            contents = {'start':start_date,'end':end_date,'type':health_info_type[health_type[0]]}

    # player function
    elif action[:6] == "player":
        contents = Music_Instruction(music_instruction[action_to_type[fulfillment_text]]).to_dict()
        type = "music_control"
        msg=more_human.music_instrction_response(music_instruction[action_to_type[fulfillment_text]])

    # user's own playlists list
    elif action == 'music.playlist':
        contents = music_player.show_playlist()
        msg = more_human.music_playlist_response()
        type = "playlist"

    # top Ten
    elif action == "music.topten":
        # ERROR: multiple singers
        if fulfillment_text == '0':
            msg = 'one singer only.'
            type = "text"

        # return a certain singer's top-ten songs list
        else:
            contents = music_player.show_top_tracks(fulfillment_text)
            msg = more_human.music_topten_response(fulfillment_text)
            type = "track"

    # albums
    elif action == "music.album":
        # ERROR: multiple singers
        if fulfillment_text == '0':
            msg = 'one singer only.'
            type = "text"

        # return one singer's albums list
        else:
            contents = music_player.show_artist_albums(fulfillment_text)
            msg = more_human.music_album_response(fulfillment_text)
            type = "album"

    # selection in music part
    elif action == "select.music":
        # ERROR: multiple numbers
        if len(fulfillment_text) > 5:
            msg = fulfillment_text
            type = "text"

        # return the number user selected
        else:
            contents = Selection(response_type["playlist"],fulfillment_text).to_dict()
            type = 'list_selection'
    else :
        msg = fulfillment_text
        type = 'text'

    response_text = Response(type=response_type[type], message=msg, status=1, contents=contents).to_dict()  # state == 1 ?

    return jsonify(response_text)


"""
search movie information according to movie title and released year from omdb 

"""
@app.route('/movie', methods=['POST','GET'])
def get_info_from_omdb():
    mn = request.form['movie']
    type = request.form['type']
    year = request.form['year']
    data = movie_info.get_movie_info(mn, year)
    contents = {'type': type, 'movie': data}
    recommend_movie.init_feedback(mn, int(year))
    resp = Response(type=response_type['movie_info'], status=1, message=mn, contents=contents).to_dict()
    return jsonify(resp)


"""
get movie trailer resource according to movie title and released year from youtube

"""
@app.route('/video', methods=['POST'])
def movie_trailer():
    movie_name = request.form['movie']
    year = request.form['year']
    video_info = video_service.youtube_search(movie_name, year)[0]
    resp = Response(type=response_type['video'], status=1, message='Here is the trailer of '+movie_name, contents=video_info).to_dict()
    return jsonify(resp)


"""
like button interface:  once - give a like,  twice - cancel the like ...
status: 1 sucessful
        0 failed

"""
@app.route('/like', methods=['POST'])
def like():
    title = request.form['movie']
    user = 'username'
    feedback_collection = recommend_movie.get_user_collection(user)

    preference = feedback_collection.find_one({'title': title}, sort=[('_id', pymongo.DESCENDING)])['preference']
    if preference == 'neutral':
        feedback_collection.find_one_and_update({'title': title}, {'$set': {'preference': 'positive'}}, sort=[('_id', pymongo.DESCENDING)])
    else:
        feedback_collection.find_one_and_update({'title': title}, {'$set': {'preference': 'neutral'}}, sort=[('_id', pymongo.DESCENDING)])
    return jsonify({'status': 1})

"""
recommendation system interface
param : 
        status : app switch  0 off
                             1 on
                             
return type : 
        set status :  0 failed
                      1 sucessful
                  
        switch : 0 off
                 1 on
"""
@app.route('/recommendation', methods=['POST'])
def rs():
    status = request.form['switch']
    recommend_movie.store_user_rs_state(status)

    resp = {
        'status': 1,
        'switch': int(status)
    }
    return jsonify(resp)


"""
personalized recommendation switch interface

state: 1 sucessful
       0 failed
switch: 1 on - based on personalized
        0 off - based on hotness
"""
@app.route('/switch', methods=['POST'])
def get_switch_state():
    client = pymongo.MongoClient('localhost', 27017)
    db = client['comp9900moviedb']
    rs_state_collection = db['rs_state']
    post = rs_state_collection.find_one({'user': 'username'})
    if post == None:
        status = 0
    else:
        status = post['state']
    resp = {
        'status': 1,
        'switch': int(status)
    }
    return jsonify(resp)




"""
register function
request:  method: post  param: username, email, password, second_password
success:  {"status": 1, "content": {"username": user.username, "email": user.email}}
fail:  {"status": 0, "content": {"error": error}}

"""


@app.route("/register", methods=['POST'])
def register():
    data = request.form
    requires = ['username', 'email', 'password', 'second_password']
    missing_part = check_require(requires, data)
    if missing_part:
        return jsonify(user_response_dict(None, f"{missing_part} is missing"))
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')
    second_password = data.get('second_password')
    return jsonify(user_response_dict(*user_register(username, email, password, second_password)))


"""
Login function
request:  method: post  param: username, password
success:  {"status": 1, "content": {"username": user.username, "email": user.email}}
fail:  {"status": 0, "content": {"error": error}}
"""

@app.route('/login', methods=['POST'])
def login():
    data = request.form
    requires = ['username', 'password']
    missing_part = check_require(requires, data)
    if missing_part:
        return jsonify(user_response_dict(None, f"{missing_part} is missing"))

    username = data.get('username')
    password = data.get('password')
    return jsonify(user_response_dict(*authentication(username, password)))




"""
change_email function
request:  method: post  param: username, new_email
success:  {"status": 1, "content": {"username": user.username, "email": user.email}}
fail:  {"status": 0, "content": {"error": error}}
"""


@app.route('/modify_email', methods=['POST','GET'])
def change_email():
    data = request.form
    username = data.get('username')
    new_email = data.get('new_email')

    requires = ['username', 'new_email']
    missing_part = check_require(requires, data)
    if missing_part:
        return jsonify(user_response_dict(None, f"{missing_part} is missing"))
    return jsonify(user_response_dict(*UserManager(username, None, False).change_email(new_email)))

"""
change_password function
request:  method: post  param: username, new_password, password
success:  {"status": 1, "content": {"username": user.username, "email": user.email}}
fail:  {"status": 0, "content": {"error": error}}
"""


@app.route('/change_password', methods=['POST'])
def change_password():
    data = request.form
    requires = ['username', 'new_password', 'password']
    missing_part = check_require(requires, data)
    if missing_part:
        return jsonify(user_response_dict(None, f"required field {missing_part} is missing"))
    username = data.get('username')
    new_password = data.get('new_password')
    password = data.get('password')
    return jsonify(user_response_dict(*UserManager(username, password).change_password(new_password)))


# --------------------------------------------Spotify Music Function----------------------------------------------



'''
authorization function: swap spotify token
'''


@app.route('/swap', methods=['POST', 'GET'])
def swap():
    code = request.form['code']
    data, headers = music_player.swap_token(code)
    response = requests.post('https://accounts.spotify.com/api/token', data=data, headers=headers)
    return jsonify(response.json())


'''
authorization funtion: refresh spofity token 
'''


@app.route('/refresh', methods=['POST', 'GET'])
def refresh():
    token = request.form['refresh_token']
    data, headers = music_player.refresh_token(token)
    respone = requests.post('https://accounts.spotify.com/api/token', data=data, headers=headers)
    return jsonify(respone.json())


'''
Get playlists of current user
'''


@app.route('/playlists', methods=['POST', 'GET'])
def playlist():
    playlists = music_player.show_playlist()
    resp = Response(type=response_type['playlist'], status=1, message='Here is all your own playlists, you can select one of them to play.', contents=playlists).to_dict()
    return jsonify(resp)


'''
Get details of one playlist, contains track uri, cover image, and track name
'''


@app.route('/playlist_detail', methods=['POST', 'GET'])
def playlist_detail():
    playlist_id = request.form['playlist_id']
    playlist_type = int(request.form['playlist_type']);
    if playlist_type == response_type['album']:
        tracks = music_player.album_content(playlist_id)
    elif playlist_type == response_type['playlist']:
        tracks = music_player.playlist_track(playlist_id)
    resp = Response(type=response_type['track'], status=1, message='', contents=tracks).to_dict()
    return jsonify(resp)


'''
Get all albums of an artist
'''


@app.route('/albums', methods=['POST', 'GET'])
def artist_album():
    artist_name = request.form['artist']
    album = music_player.show_artist_albums(artist_name)
    resp = Response(type=response_type['playlist'], status=1, message= 'Here is ' + artist_name + "'s albums. Pick one that interests you", contents=album).to_dict()
    return jsonify(resp)


'''
Get the tracks in a album
'''


@app.route('/album_detail', methods=['POST'])
def album_song():
    album = request.form['album']
    tracks = music_player.album_content(album)
    resp = Response(type=response_type['track'], status=1, message='',contents=tracks).to_dict()
    return jsonify(resp)


'''
Get top 10 songs of an artist
'''


@app.route('/artist_top_song', methods=['POST'])
def artist_top_tracks():
    artist_name = request.form['artist']
    top_tracks = music_player.artist_top_tracks(artist_name)
    resp = Response(type=response_type['track'], status=1, message='Here is ' + artist_name + ' most heat tracks. Choose one or loop the these songs', contents=top_tracks).to_dict()
    return jsonify(resp)



"""
get fulfillment text msg and get the intent corresponding action from dialogflow 

"""

def detect_intent_texts(project_id, session_id, text, language_code):
    session_client = dialogflow.SessionsClient()
    session = session_client.session_path(project_id, session_id)

    if text:
        text_input = dialogflow.types.TextInput(
            text=text, language_code=language_code)
        query_input = dialogflow.types.QueryInput(text=text_input)
        response = session_client.detect_intent(
            session=session, query_input=query_input)
        return response.query_result.fulfillment_text, response.query_result.action



"""
process request according to the intent corresponding different action

"""
@app.route('/webhook', methods=['POST'])
def webhook():
    req = request.get_json(silent=True, force=True)
    res = process_request(req)
    res = json.dumps(res, indent=4)
    r = make_response(res)
    r.headers['Content-Type'] = 'application/json'
    return r


def process_request(req):

    action = req.get("queryResult").get("action")

    if action == 'select.music':
        result = req.get("queryResult")
        number = result.get('parameters').get('number')
        if len(number) != 1:
            speech = 'Sorry, we allow choose only one music. Please choose again. '
            return FulfillmentText(speech).to_dict()
        return FulfillmentText(int(number[0])).to_dict()

    if action == 'select.rs':
        result = req.get("queryResult")
        number = result.get('parameters').get('number')
        if len(number) != 1:
            speech = 'Sorry, we allow choose only one movie. Please choose again. '
            return FulfillmentText(speech).to_dict()
        return FulfillmentText(str(int(number[0]))).to_dict()

    if action == "select.movie":
        result = req.get("queryResult")
        number = result.get('parameters').get('number')
        type_of_info = result.get("outputContexts")[1]['parameters']['Info']
        if len(number) != 1:
            speech = 'Sorry, we allow choose only one movie. Please choose again. '
            return FulfillmentText(speech).to_dict()
        res = str(int(number[0]))+'#' + type_of_info
        return FulfillmentText(res).to_dict()


    if action == "music.topten" or action == "music.album":
        result = req.get("queryResult")
        artist = result.get('parameters').get('MusicArtist')
        if len(artist) != 1:
            return FulfillmentText('0').to_dict()
        return FulfillmentText(artist[0]).to_dict()

    if action == "movie.change.movie":
        result = req.get("queryResult")
        movie_name = result.get('parameters').get('MovieName')
        type_of_info = result.get("outputContexts")[0].get('parameters').get('Info')
        if len(movie_name) > 1:
            return FulfillmentText('0').to_dict()
        title = movie_name[0]
        res = title + "#" + type_of_info
        return FulfillmentText(res).to_dict()


    if action[:5] == "movie":
        result = req.get("queryResult")
        movie_name = result.get('parameters').get('MovieName')
        type_of_info = action[6:]
        if len(movie_name) == 1:
            title = movie_name[0]
        else:
            return FulfillmentText('0').to_dict()
        res = title + "#" + type_of_info
        return FulfillmentText(res).to_dict()

    if action == "notasexpected":
        para = req.get("queryResult").get("outputContexts")[1].get('parameters')
        title, type_of_info = para['MovieName'][0], para['Info']
        res = title + "#" + type_of_info
        return FulfillmentText(res).to_dict()



    if action[:6] == "player":
        return FulfillmentText(action[7:]).to_dict()

    if action == "light":
        result = req.get("queryResult")
        lightcontext = result.get('parameters')
        return light_control.LightController(lightcontext).to_response()

    if action == "health":
        result = req.get("queryResult")
        res= health_record.health(result)
        return FulfillmentText(res).to_dict()

'''
-------------------------------------------DONE END-------------------------------------------------
'''

if __name__ == '__main__':
    set_up_db()
    app.run()
