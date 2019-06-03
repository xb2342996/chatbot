# ChatBot
UNSW COMP9900
=============
Configuration
-------------

  1. Make sure you have a Python 3.6+ environment

  2. Install mongodb and import all json files in Server/moviedb_setup

    mongoimport --db comp9900moviedb --collection “file_name” --type csv --file “file_name”
  
  3. install all packages: 
  
    pip3 install requirements.txt

  4. create virtualenv : 
  
    virtualenv venv 

  5.activate virtualenv : 
  
    source venv/bin/activate

  6. run setup_nltk.py to download nltk packages: 
  
    python3 setup_nltk

  7. back to Server dir and start server: 
  
    flask run

  8. Modify the spotify username in music_player.py and lifx bulb token in light_control.py to control your own light and music app.
  
  9. Restore the agent in dialogflow use the zip file in dialogflow folder
  
  10. Download Xcode 10.2, update your iOS version to `12.2`,  Plug your phone on the MacBook, make sure you have a Spotify app in your phone.
  Open the iOS/RelaxBot dictionary then click `RelaxBot.xcworkspace`
 
  11. Modify the Server Address named `kServerUrl` to your own local address in `iOS/Utilities/Config.h` and keep the port is same as server.

  12. Select your device and click run to run the app on your phone.

  we also deployed our server on AWS server, the Ip address is `13.210.181.96`

