import pandas as pd
import re
import langid
import pymongo
from collections import Counter
import math
import numpy as np

"""
    Download files to moviedb_setup folder from the address below：
    https://datasets.imdbws.com/title.basics.tsv.gz
    https://datasets.imdbws.com/title.ratings.tsv.gz
    https://datasets.imdbws.com/title.principals.tsv.gz
    https://datasets.imdbws.com/name.basics.tsv.gz
    then rename those files as data-5.tsv, data-6.tsv, data-10.tsv, data-9.tsv
    
    Then run this program to set up database
    
    OR
    
    import movie_feedback_user1.json, movie_feedback_user1.json, movie_feedback_user3.json, rs_state.json, user_profiles.json to the database
    for initializing collections:  movie_feedback_user1, movie_feedback_user1, movie_feedback_user3, rs_state, user_profiles

"""


# 'nm0342278,nm0342303,nm0566338' --> ['nm0342278', 'nm0342303', 'nm0566338']
def format_string(namestring):
    return [name for name in namestring.split(",")]


def check_language(moviename):
    if not re.match(r'^[ A-Za-z0-9-!,.?*&<>:\'\"()]+$', moviename):
        return False
    words = moviename.split(" ")
    if len(words) < 3:
        return True
    if langid.classify(moviename)[0] == 'en':
        return True
    count = 0
    for word in words:
        if langid.classify(word)[0] == 'en':
            count += 1
    if count / len(words) > 0.5:
        return True
    return False

def get_year_interval(year):
    intervals = [(0,1990),(1991,1995),(1996,2000),(2001,2005),(2006,2010),(2011,2015),(2016,2017),(2018,8102)]
    for i in intervals:
        if year >= i[0] and year <= i[1]:
            return i

# 'nm0342278,nm0342303,nm0566338' --> ['nm0342278', 'nm0342303', 'nm0566338']
def format_string(namestring):
    return [name for name in namestring.split(",")]


# filter the movies and information from omdb
def insert_doc_to_db(info_collection):

    # https://datasets.imdbws.com/title.basics.tsv.gz
    name_file = pd.read_csv('data-5.tsv', sep='\t')
    # https://datasets.imdbws.com/title.ratings.tsv.gz
    rank_file = pd.read_csv('data-6.tsv', sep='\t')
    # https://datasets.imdbws.com/title.principals.tsv.gz
    crew_file = pd.read_csv('data-10.tsv', sep='\t')
    # https://datasets.imdbws.com/name.basics.tsv.gz
    crew_detail_file = pd.read_csv('data-9.tsv', sep='\t')

    name_df = pd.DataFrame(name_file)
    rank_df = pd.DataFrame(rank_file)
    crew_df = pd.DataFrame(crew_file)
    crew_detail_df = pd.DataFrame(crew_detail_file)

    name_df = name_df.set_index('tconst')
    rank_df = rank_df.set_index('tconst')
    crew_df = crew_df.set_index(['tconst', 'ordering'])
    crew_detail_df = crew_detail_df.set_index('nconst')

    num_votes_limit = 2000

    for rank_index, rank_row in rank_df.iterrows():
        if re.match(r'^[0-9.]*$', str(rank_row['numVotes'])) and int(rank_row['numVotes']) > num_votes_limit:
            try:
                if name_df.loc[rank_index, 'titleType'] == 'movie' and check_language(
                        name_df.loc[rank_index, 'primaryTitle']) and check_language(
                    name_df.loc[rank_index, 'originalTitle']):
                    tid = rank_index
                    tconst = rank_index
                    title = name_df.loc[tconst, 'primaryTitle']
                    num_votes = int(rank_row['numVotes'])
                    released_year = int(name_df.loc[tconst, 'startYear'])
                    genre = format_string(name_df.loc[tconst, 'genres'])

                    director = []
                    star = []
                    writer = []

                    for i, row in crew_df.loc[tconst].iterrows():
                        category = row['category']
                        nconst = row['nconst']
                        if nconst in crew_detail_df.index:
                            crew_name = crew_detail_df.loc[nconst, 'primaryName']
                            crew_know_title = format_string(crew_detail_df.loc[nconst, 'knownForTitles'])
                            crew_know_title = [t for t in crew_know_title if t != tconst and t in rank_df.index and int(rank_df.loc[t, 'numVotes']) > num_votes_limit]
                            if len(crew_know_title) != 0:
                                if category == 'director':
                                    director.append({'nconst':nconst, 'crew_name': crew_name})
                                elif category == 'actor' or category == 'actress':
                                    star.append({'nconst': nconst, 'crew_name': crew_name})
                                elif category == 'writer':
                                    writer.append({'nconst': nconst, 'crew_name': crew_name})

                    movie_dict = {'tid': tid, 'title': title, 'num_votes': num_votes, 'released_year': released_year,
                                  'genre': genre,
                                  'director': director, 'star': star, 'writer': writer}
                    info_collection.insert_one(movie_dict)

            except ValueError:
                print(rank_index)

# represent each movie in a structured representaion
def calculate_vector(info_collection):
    info_collection.update_many({}, {'$unset': {'vector': 1}})

    genre_collection = Counter()
    star_collection = Counter()
    director_collection = Counter()
    writer_collection = Counter()
    year_dict = Counter()
    count = 0
    for post in info_collection.find():
        genre_collection += Counter(post['genre'])

        for i in range(len(post['star'])):
            if i < 3:
                star_collection[post['star'][i]['nconst']] += 1

        for e in post['writer']:
            writer_collection[e['nconst']] += 1

        for e in post['director']:
            director_collection[e['nconst']] += 1
        if get_year_interval(post['released_year']) == (2018, 8102):
            year_dict[(2018, 8102)] += 1
        count += 1

    genre_dict = Counter(genre_collection)

    star_common = dict(star_collection.most_common(2000))
    director_common = dict(director_collection.most_common(800))
    writer_common = dict(writer_collection.most_common(100))

    star_dict = Counter(star_common)
    director_dict = Counter(director_common)
    writer_dict = Counter(writer_common)

    one_hot_dict = year_dict + genre_dict + star_dict + director_dict + writer_dict
    weight_dict = year_dict + genre_dict + star_dict + director_dict + writer_dict

    for e in weight_dict:
        if type(e) == str and e[:2] == 'nm':
            if weight_dict[e] >= 10:
                weight_dict[e] = 1 + weight_dict[e] / 100
            else:
                weight_dict[e] = 1
        else:
            weight_dict[e] = math.log10(count/(weight_dict[e]*1.0)) / 10

    index = 0
    for e in one_hot_dict:
        one_hot_dict[e] = index
        index += 1

    for post in info_collection.find():
        vector = [0] * len(one_hot_dict)
        tid = post['tid']
        year_interval = get_year_interval(post['released_year'])
        vector[one_hot_dict[year_interval]] = weight_dict[year_interval]

        genres = post['genre']
        stars = [star['nconst'] for star in post['star']]
        directors = [director['nconst'] for director in post['director']]
        writers = [writer['nconst'] for writer in post['writer']]

        for e in genres + stars + directors + writers:
            if e in one_hot_dict.keys():
                vector[one_hot_dict[e]] = weight_dict[e]

        info_collection.update_one({'tid': tid}, {'$set': {'vector': vector}})


def get_user_collection(username='username'):
    client = pymongo.MongoClient('localhost', 27017)
    db = client['comp9900moviedb']
    collection_name = 'movie_feedback_'+ username
    return db[collection_name]

# preference: neutral/positive
# set all preference to neutral
def init_feedback(title, year=None, user='username'):
    client = pymongo.MongoClient('localhost', 27017)
    db = client['comp9900moviedb']
    info_collection = db['movie_info']
    feedback_collection = get_user_collection(user)
    if year != None:
        for post in info_collection.find({'title': title, 'released_year': year}):
            vector = post['vector']
            feedback = {'user': user, 'preference': 'neutral', 'released_year': year, 'title': title, 'tid': post['tid'],'vector': vector, 'rec_para': 0}
            feedback_collection.insert_one(feedback)
    else:
        for post in info_collection.find({'title': title}):
            vector = post['vector']
            feedback = {'user': user, 'preference': 'neutral', 'released_year': year, 'title': title, 'tid': post['tid'], 'vector': vector, 'rec_para': 0}
            feedback_collection.insert_one(feedback)

# like --> set perference to positive
def modify_postive_feedback(title, year=None, user='username'):
    feedback_collection = get_user_collection(user)
    if year != None:
        feedback_collection.update_one({'released_year': year, 'title': title}, {'$set': {'preference': 'positive'}})
    else:
        feedback_collection.update_one({'title': title}, {'$set': {'preference': 'positive'}})

# switch --> decided recommend movie based on hotness or personal interest
def store_user_rs_state(state, user='username'):
    client = pymongo.MongoClient('localhost', 27017)
    db = client['comp9900moviedb']
    rs_state_collection = db['rs_state']
    rs_state_collection.update_one({'user': user}, {"$set": {'state': state}}, upsert=True)

# based on the preference data in movie_feedback_user collection, calculate the user profile
def store_user_profile(user='username'):
    client = pymongo.MongoClient('localhost', 27017)
    db = client['comp9900moviedb']
    profiles_collection = db['user_profiles']
    feedback_collection = get_user_collection(user)

    length_vector = len(feedback_collection.find_one({})['vector'])
    if profiles_collection.count_documents({'user': user}) != 0:
        init_vector = np.array(profiles_collection.find_one({'user': user})['profile'])
    else:
        init_vector = np.array([0] * length_vector)

    a = 1
    b = 0.75
    c = 0.15

    posts = feedback_collection.find({'rec_para': 0}).sort("_id", pymongo.DESCENDING)
    time_interval = 0
    d_r = np.array([]).reshape(0, length_vector)
    d_nr = np.array([]).reshape(0, length_vector)

    for post in posts:
        if post['preference'] == 'positive':
            cooling_rate = 0.1
            vector = (np.array(post['vector']) * np.exp(-cooling_rate*time_interval)).reshape(1, length_vector)
            d_r = np.vstack((d_r, vector))

        else:
            cooling_rate = 0.1
            vector = (np.array(post['vector']) * np.exp(-cooling_rate*time_interval)).reshape(1, length_vector)
            d_nr = np.vstack((d_nr, vector))

        time_interval += 1

    feedback_collection.update_many({'rec_para': 0}, {'$set': {'rec_para': 1}})

    count_r = d_r.shape[0]
    count_nr = d_nr.shape[0]

    sum_r = np.sum(d_r, axis=0)
    sum_nr = np.sum(d_nr, axis=0)

    if count_r != 0 and count_nr != 0:
        user_profile = a * init_vector + b * (1/count_r) * sum_r - c * (1/count_nr) * sum_nr

    elif count_r == 0 and count_nr != 0:
        user_profile = a * init_vector - c * (1/count_nr) * sum_nr

    elif count_r != 0 and count_nr == 0:
        user_profile = a * init_vector + b * (1/count_r) * sum_r

    else:
        user_profile = a * init_vector
    user_profile[user_profile < 0.001] = 0.0  # limit the interest and ignore the negative number

    if profiles_collection.count_documents({'user': user}) != 0:
        profiles_collection.update_one({'user': user}, {'$set': {'profile': list(user_profile)}})
    else:
        profiles_collection.insert_one({'user': user, 'profile': list(user_profile)})



def init_moviedb():
    client = pymongo.MongoClient('localhost', 27017)
    db = client['comp9900moviedb']
    info_collection = db['movie_info']
    # insert data into db
    insert_doc_to_db(info_collection)
    # create an index according to released year
    info_collection.create_index([('released_year', pymongo.DESCENDING)], name='year_index')
    info_collection.create_index([('tid', pymongo.ASCENDING)], name='tid_index')
    info_collection.create_index([('num_votes', pymongo.DESCENDING)], name='votes_index')
    calculate_vector(info_collection)
    store_user_rs_state(1, 'username')
    client.close()


def init_other_users():

    init_feedback('The Godfather', 1972, 'user3')
    init_feedback('The Avengers', 2012, 'user3')
    init_feedback('Avengers: Age of Ultron', 2015, 'user3')
    init_feedback('Avengers: Infinity War', 2018, 'user3')
    init_feedback('Iron Man', 2008, 'user3')
    init_feedback('Iron Man 2', 2010, 'user3')
    init_feedback('Iron Man 3', 2013, 'user3')
    init_feedback('The Silence of the Lambs', 1991, 'user3')
    init_feedback('No Country for Old Men', 2007, 'user3')
    init_feedback('Green Book', 2018, 'user3')
    init_feedback(' Let The Bullets Fly', 2010, 'user3')
    init_feedback('The Flowers Of War', 2001, 'user3')
    init_feedback('Spider-Man: Into the Spider-Verse', 2018, 'user3')
    init_feedback('Taxi Driver', 1976, 'user3')
    init_feedback('Memories of Murder', 2003, 'user3')
    init_feedback('The Shawshank Redemption', 1994, 'user3')
    init_feedback('Inception', 2010, 'user3')
    init_feedback('Interstellar', 2014, 'user3')
    modify_postive_feedback('The Godfather',  user='user3')
    modify_postive_feedback('The Avengers',  user='user3')
    modify_postive_feedback('Avengers: Age of Ultron',  user='user3')
    modify_postive_feedback('Avengers: Infinity War',  user='user3')
    modify_postive_feedback('Iron Man',  user='user3')
    modify_postive_feedback('Iron Man 2',  user='user3')
    modify_postive_feedback('The Silence of the Lambs',  user='user3')
    modify_postive_feedback('No Country for Old Men',  user='user3')
    modify_postive_feedback('Green Book',  user='user3')
    modify_postive_feedback('Spider-Man: Into the Spider-Verse',  user='user3')
    modify_postive_feedback('Memories of Murder',  user='user3')
    modify_postive_feedback('The Shawshank Redemption',  user='user3')
    modify_postive_feedback('Inception',  user='user3')


    init_feedback('La La Land', 2016, user='user2')
    init_feedback('Roman Holiday', 1953, user='user2')
    init_feedback('Avengers‎: ‎Infinity War', 2018, user='user2')
    init_feedback('Up', 2009, user='user2')
    init_feedback('Aquaman', 2018, user='user2')
    init_feedback('Secret', 2007, user='user2')
    init_feedback('The Wandering Earth', 2019, user='user2')
    init_feedback('The Revenant', 2015, user='user2')
    init_feedback('The Fault in Our Stars', 2014, user='user2')
    init_feedback('Call Me by Your Name', 2017, user='user2')
    init_feedback('Begin again', 2013, user='user2')
    init_feedback('me before you', 2016, user='user2')
    init_feedback('Logan', 2017, user='user2')
    init_feedback('Dangal',2016, user='user2')
    init_feedback('Hacksaw Ridge', 2016, user='user2')
    init_feedback('kimi no na wa', 2016, user='user2')
    init_feedback('Rush', 2013, user='user2')
    modify_postive_feedback('La La Land', user='user2')
    modify_postive_feedback('Roman Holiday', user='user2')
    modify_postive_feedback('Avengers‎: ‎Infinity War', user='user2')
    modify_postive_feedback('Up', user='user2')
    modify_postive_feedback('Aquaman', user='user2')
    modify_postive_feedback('Secret', user='user2')
    modify_postive_feedback('The Wandering Earth', user='user2')
    modify_postive_feedback('The Revenant', user='user2')
    modify_postive_feedback('The Fault in Our Stars', user='user2')
    modify_postive_feedback('Call Me by Your Name', user='user2')
    modify_postive_feedback('Begin again', user='user2')
    modify_postive_feedback('me before you', user='user2')

    init_feedback('Spider-man', 2002, 'user1')
    init_feedback('Spider-man 3', 2007, 'user1')
    init_feedback('avengers:infinity war', 2018, 'user1')
    init_feedback('Batman', user='user1')
    init_feedback('Guardians of the Galaxy', user='user1')
    init_feedback('Dawn of the Planet of the Apes', 2014, user='user1')
    init_feedback('Inception', 2010, user='user1')
    init_feedback('Avatar', 2009, user='user1')
    init_feedback('Interstellar', 2014, user='user1')
    init_feedback('Transformers', user='user1')
    init_feedback('Harry Potter and the Deathly Hallows', 2009, user='user1')
    init_feedback('Fast & Furious', user='user1')
    init_feedback('2 Fast 2 Furious', 2003, 'user1')
    init_feedback('Harry Potter and the Sorcerer Stone', 2001, user='user1')
    init_feedback('The Godfather', 1972, user='user1')
    init_feedback('The Dark Knight', 2008, user='user1')
    init_feedback('Green Book', 2018, user='user1')
    init_feedback('Coco', 2017, user='user1')
    init_feedback('Room', 2015, user='user1')
    modify_postive_feedback('Spider-man', user='user1')
    modify_postive_feedback('avengers:infinity war', user='user1')
    modify_postive_feedback('Batman', user='user1')
    modify_postive_feedback('Guardians of the Galaxy', user='user1')
    modify_postive_feedback('Dawn of the Planet of the Apes', user='user1')
    modify_postive_feedback('Inception', user='user1')
    modify_postive_feedback('Avatar', user='user1')
    modify_postive_feedback('Interstellar', user='user1')
    modify_postive_feedback('Transformers', user='user1')
    modify_postive_feedback('Harry Potter and the Deathly Hallows', user='user1')
    modify_postive_feedback('Fast & Furious', user='user1')
    modify_postive_feedback('Harry Potter and the Sorcerer Stone', user='user1')
    modify_postive_feedback('The Dark Knight', user='user1')


    init_feedback('Coco', 2017, user='user2')
    modify_postive_feedback('Coco', 2017, user='user2')
    init_feedback('Coco', 2017, user='user3')
    modify_postive_feedback('Coco', 2017, user='user3')

    init_feedback('La La Land', 2016, user='user1')
    modify_postive_feedback('La La Land', 2016, user='user1')
    init_feedback('La La Land', 2016, user='user3')
    modify_postive_feedback('La La Land', 2016, user='user3')

    init_feedback('Avengers: Infinity War',  user='user1')
    modify_postive_feedback('Avengers: Infinity War',  user='user1')
    init_feedback('Captain Marvel',  user='user1')
    modify_postive_feedback('Captain Marvel',  user='user1')
    init_feedback('Captain Marvel',  user='user2')
    modify_postive_feedback('Captain Marvel',  user='user2')


    store_user_profile('user1')
    store_user_profile('user2')
    store_user_profile('user3')

    store_user_rs_state(1, 'user1')
    store_user_rs_state(1, 'user2')
    store_user_rs_state(1, 'user3')


def delete_moviedb():
    client = pymongo.MongoClient('localhost', 27017)
    db = client['comp9900moviedb']
    collection = db['movie_info']
    db.drop_collection(collection)
    client.close()

if __name__ == "__main__":
    init_moviedb()
    init_other_users()