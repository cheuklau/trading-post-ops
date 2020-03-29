#!/bin/bash

# Install dependencies
sudo apt-get -qqy update
sudo apt-get -qqy upgrade
sudo apt-get -qqy install apache2
sudo apt-get -qqy install libapache2-mod-wsgi
sudo apt-get -qqy install postgresql

# Download the trading-post app
sudo apt-get -qqy install git
sudo mkdir /var/www/FlaskApp/
cd /var/www/FlaskApp/
sudo git clone https://github.com/cheuklau/trading-post.git FlaskApp
cd FlaskApp
sudo mv project.py __init__.py

# Install Python
sudo apt-get -qqy install python-pip
sudo apt-get -qqy install python-psycopg2
sudo pip install sqlalchemy flask-sqlalchemy psycopg2 requests flask oauth2client

# Set up Flask app
sudo sed -i "s/{{SERVER_IP}}/mtgtradingpost.com/g" FlaskApp.conf
sudo cp FlaskApp.conf /etc/apache2/sites-available/FlaskApp.conf
sudo cp flaskapp.wsgi /var/www/FlaskApp/flaskapp.wsgi
sudo rm /etc/apache2/sites-enabled/000-default.conf

# Update init.py
sudo sed -i "s/APP.run(host='0.0.0.0.xip.io', port=5000)/APP.run(threaded=True)/g" __init__.py
sudo sed -i "s/http:\/\/0.0.0.0.xip.io:5000\//http:\/\/mtgtradingpost.com/g" __init__.py