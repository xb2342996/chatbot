from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

from model import Video

DEVELOPER_KEY = 'AIzaSyADLl7xKwGjFLma3_5bEx6j0ylSLFbAbFc'
YOUTUBE_API_SERVICE_NAME = 'youtube'
YOUTUBE_API_VERSION = 'v3'

def youtube_search(q, year='' ,limit=1):
  youtube = build(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION,
    developerKey=DEVELOPER_KEY)

  search_response = youtube.search().list(
    q=q + str(year) + ' trailer',
    part='id, snippet',
    maxResults=limit
  ).execute()
  videos = []
  for search_result in search_response.get('items', []):
    if search_result['id']['kind'] == 'youtube#video':
      video = Video(video_id = search_result['id']['videoId'],thumbnail=search_result['snippet']['thumbnails']['medium']['url']).to_dict()
      videos.append(video)
  return videos
