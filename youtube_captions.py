# importing required modules
from urllib.parse import parse_qs, urlparse

from flask import Flask, jsonify, request
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from youtube_transcript_api import YouTubeTranscriptApi

# initialize Flask app
app = Flask(__name__)

# define route for searching videos
@app.route('/searchVideos', methods=['GET'])
def search_videos():
    # get search query from query parameter
    query = request.args.get('query')
    try:
        # build YouTube API client
        youtube = build('youtube', 'v3', developerKey='AIzaSyAggcRjkjtwQ8RcKAPCgl9IeYHDyqhhMwI')
        # search for videos containing query term
        search_response = youtube.search().list(
            q=query,
            type='video',
            part='id',
            maxResults=10
        ).execute()
        # extract video IDs from search response
        video_ids = [item['id']['videoId'] for item in search_response['items']]
        # return video IDs as JSON response
        return jsonify({'videoIds': video_ids})
    except HttpError as e:
        # return error message if search request fails
        return jsonify({'error': 'Failed to search videos'})

# define route for getting video transcript
@app.route('/getTranscript', methods=['GET'])
def get_transcript():
    # get video ID from query parameter
    video_id = request.args.get('videoId')
    try:
        # get transcript for the video
        transcript = YouTubeTranscriptApi.get_transcript(video_id)
        # return transcript as JSON response
        return jsonify({'transcript': transcript})
    except:
        # return error message if transcript not found
        return jsonify({'error': 'Transcript not found for video ID'})

# define route for getting specific time in video
@app.route('/getVideoTime', methods=['GET'])
def get_video_time():
    # get video ID and search query from query parameters
    video_id = request.args.get('videoId')
    query = request.args.get('query')
    try:
        # get transcript for the video
        transcript = YouTubeTranscriptApi.get_transcript(video_id)
        # iterate over each word in the transcript
        for word in transcript:
            # check if the search query is in the word
            if query in word['text']:
                # get the start time for the word and return as JSON response
                return jsonify({'time': word['start']})
        # return error message if search query not found in transcript
        return jsonify({'error': 'Search query not found in transcript'})
    except:
        # return error message if transcript not found
        return jsonify({'error': 'Transcript not found for video ID'})

# run Flask app
if __name__ == '__main__':
    app.run(port=8000)
