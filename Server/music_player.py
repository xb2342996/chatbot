import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
from model import Playlist, Track
import base64

SPOTIFY_CLIENT_ID = '1861ba8bada044718fd946a732425af3'
SPOTIFY_CLIENT_SECRET = '649dc1c99de64330a009fb68c43abf2c'
SPOTIFY_CLIENT_CALLBACK_URL = 'relax-bot-demo://spotify-login-callback'

client_credentials_manager = SpotifyClientCredentials(client_id=SPOTIFY_CLIENT_ID, client_secret=SPOTIFY_CLIENT_SECRET)
spotify = spotipy.Spotify(client_credentials_manager=client_credentials_manager)



def spotify_username():
    spotify_username = 'uzgf6rntskvg3r9gh8g4wcw39'
    return spotify_username


def show_playlist():
    username = spotify_username()
    playlists = spotify.user_playlists(username)
    playlists_list = []

    for playlist in playlists['items']:
        # print(playlist)
        if playlist['images'] == []:
            play_list = Playlist(name=playlist['name'], uri=playlist['uri'], total=playlist['tracks']['total'])
        else:
            play_list = Playlist(name=playlist['name'], uri=playlist['uri'], total=playlist['tracks']['total'], image=playlist['images'][2]['url'])
        playlists_list.append(play_list.to_dict())
    return {
        'playlists' : playlists_list
    }


def playlist_track(playlist_uri):
    username = spotify_username()
    tracks_in_playlist = []
    results = spotify.user_playlist(username, playlist_uri, fields="tracks,next")
    for tracks in results['tracks']['items']:
        single_track = tracks['track']
        track = Track(single_track['name'], single_track['uri'], single_track['album']['images'][1]['url'])
        tracks_in_playlist.append(track.to_dict())
    return {
        'playlists': tracks_in_playlist
    }


def get_artist(name):
    results = spotify.search(q='artist:' + name, type='artist')
    items = results['artists']['items']
    if len(items) > 0:
        return items[0]
    else:
        return None


def show_artist_albums(artist_name):
    albums_list = []
    albums = []
    artist = get_artist(artist_name)
    results = spotify.artist_albums(artist['id'], album_type='album')
    albums.extend(results['items'])
    while results['next']:
        results = spotify.next(results)
        albums.extend(results['items'])
    seen = set()  # to avoid dups
    albums.sort(key=lambda album: album['name'].lower())
    for album in albums:
        name = album['name']
        if name not in seen:
            playlist = Playlist(name=name, uri=album['uri'], image=album['images'][2]['url'], total=album['total_tracks'])
            albums_list.append(playlist.to_dict())
            seen.add(name)
    return {
        'playlists': albums_list
    }



def album_content(album_uri):
    results = spotify.album(album_uri)
    songs = []
    for song in results['tracks']['items']:
        track = Track(name=song['name'], uri=song['uri'])
        songs.append(track.to_dict())
    return {
        'playlists': songs
    }


def show_top_tracks(artist_name):  # default: top10
    tracks_list =[]
    artist = get_artist(artist_name)
    results = spotify.artist_top_tracks(artist['uri'])

    for track in results['tracks']:
        playlist = Playlist(name=track['name'], uri=track['uri'], image=track['album']['images'][1]['url'])
        tracks_list.append(playlist.to_dict())
    return {
        'playlists': tracks_list
    }


def refresh_token(token):
    data = {
        'grant_type': 'refresh_token',
        'refresh_token': token
    }
    auth_string = SPOTIFY_CLIENT_ID + ':' + SPOTIFY_CLIENT_SECRET
    auth_header = str(base64.b64encode(bytes(auth_string, encoding='utf8')), encoding='utf-8')
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': "Basic " + auth_header
    }
    return data, headers


def swap_token(code):
    data = {
        'grant_type': "authorization_code",
        'redirect_uri': SPOTIFY_CLIENT_CALLBACK_URL,
        'code': code
    }
    auth_string = SPOTIFY_CLIENT_ID + ':' + SPOTIFY_CLIENT_SECRET
    auth_header = str(base64.b64encode(bytes(auth_string, encoding='utf8')), encoding='utf-8')
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': "Basic " + auth_header
    }
    return data, headers
