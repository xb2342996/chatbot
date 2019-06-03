import random

music_instruction = {
    1:'play',
    2:'pause',
    3:'next',
    4:'previous',
    5:'shuffle',
    6:'repeat'
}

def movie_selection_response():
    randon_response=[
    "the movie information is comming up",
    "the movie you select will be presented to you",
    "here you are ^-^",
    "Here is the movie you expected."
    ]
    return random.choice(randon_response)

def music_playlist_response():
    randon_response=[
    "Here is all your own playlists, you can select one of them to play.",
    "here is what i found in your playlist, check it out",
    "select one of the playlists here to play"
    ]
    return random.choice(randon_response)

def wrong_movie_response():
    randon_response=[
        "Tell me if the movie is incorrect! RalexBot can search the movies for you.",
        "Not what you expected? just tell me no to find more movies",
        "Tell me if it's not your expeced, I can search more related movie for you"
    ]
    return random.choice(randon_response)

def music_topten_response(artist):
    randon_response=[
    f"{artist} top ten tracks are comming up. Choose one or loop these songs",
    f"the {artist}'s most heart tracks will be presented to you. Choose one or loop these songs",
    f"here is {artist} ten most popular songs. Choose one or loop these songs",
    f"Here is {artist} most heat tracks. Choose one or loop these songs"
    ]
    return random.choice(randon_response)

def music_album_response(artist):
    randon_response=[
    f"Good taste! {artist}'s albums are comming up. Choose one to play",
    f"Oh!,i like {artist} too! albums comming right up ~ Choose one to play",
    f"here is what i found ",
    f"Here is {artist}'s albums. Pick one that interests you"
    ]
    return random.choice(randon_response)

def music_instrction_response(action):
    action_type = music_instruction[action]
    response=''
    if action_type=='play':
        response='music is playing'
    elif action_type=='pause':
        response='Ok, music stoped now'
    elif action_type=='next':
        response = 'Playing next song now'
    elif action_type=='previous':
        response='Playing the previous song'
    elif action_type=='shuffle':
        response ='shuffle play activate'
    elif action_type=='repeat':
        response ='Ok,cycle mode is on'
    return response




