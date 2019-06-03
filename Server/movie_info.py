import json

from urllib.request import urlopen

from math import log
from model import Movie
import re

import pymongo
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from collections import Counter


LIMIT = 50

movie_info_type = {
    'overview': 0,
    'star': 1,
    'director': 2,
    'genre': 3,
    'plot': 4,
    'year': 5,
    'writer': 6,
    'rating': 7,
    'trailer': 8
}


# find movie information in movie_info db collection
def find_results(name, type_of_info):  # year:1999 or [1999,2013]
    client = pymongo.MongoClient('localhost', 27017)
    db = client['comp9900moviedb']
    collection = db['movie_info']
    more_stopwords = set([word[:1].upper() + word[1:].lower() for word in stopwords.words('english')])
    stop_words = more_stopwords.union(set(stopwords.words('english')))
    name_tokens = word_tokenize(name)
    for index in range(len(name_tokens)):
        if name_tokens[index] == '.' or name_tokens[index] == ',' or name_tokens[index] == ':':
            name_tokens[index] = name_tokens[index - 1] + name_tokens[index]

    if len(name_tokens) != 1:
        formatted_name_tokens = [word for word in name_tokens if not word in stop_words]
    else:
        formatted_name_tokens = name_tokens

    # filter the movies in db
    # sort them base on tf-idf weighting schema
    counter = Counter()
    for token in formatted_name_tokens:
        title_frequency = 0
        post_counter = Counter()
        for post in collection.find(
                {'title': {'$regex': '(.*(' + token + ' ):.*[^\n]|' + token + '$|' + token + ': |' + token + ' )'}},
                {'num_votes': 1, 'title': 1, 'released_year': 1},
                sort=[('num_votes', pymongo.DESCENDING)]):
            token_frequency = 1 / len(post['title'].split(" "))
            post_counter[(post['title'], post['released_year'], post['num_votes'])] = token_frequency
            title_frequency += 1
        for movie in post_counter:
            counter[movie] = counter[movie] + post_counter[movie] * (log(1 + 1 / title_frequency))
    selected_movie = counter.most_common(25)
    store_search_results = []
    for mov in selected_movie:
        movie = Movie(mov[0][0], mov[0][1], type_of_info)
        store_search_results.append(movie.to_dict())

    client.close()
    return store_search_results

# get movie information from omdb
def get_movie_info(movie_name, year=None):
    apikey = 'a8a1b915'
    if year == None:
        omdb_url = 'http://www.omdbapi.com/?apikey=' + apikey + '&t=' + re.sub(' ', '+', movie_name)
    else:
        omdb_url = 'http://www.omdbapi.com/?apikey=' + apikey + '&t=' + re.sub(' ', '+',
                                                                               movie_name.lower()) + '&y=' + str(year)
    result = urlopen(omdb_url).read()
    movie_data = json.loads(result)
    return movie_data

# get movie's released year
def get_movie_year(title):
    data = get_movie_info(title)
    return data['Year']