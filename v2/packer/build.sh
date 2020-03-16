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

# Update postgres engine
# Requires RDS connection string
sudo sed -i "s/create_engine('sqlite:\/\/\/catalog.db')/create_engine('postgresql:\/\/postgres:password@{{RDS_CONNECTION_STRING}}\/mtgtradingpostdb')/g" `find . -maxdepth 1 -type f`

# Install Python
sudo apt-get -qqy install python-pip
sudo apt-get -qqy install python-psycopg2
sudo pip install sqlalchemy flask-sqlalchemy psycopg2 requests flask oauth2client

# Set up database on RDS
sudo python database_setup.py
sudo python populate_db.py

# Set up Flask app
sudo sed -i "s/{{SERVER_IP}}/mtgtradingpost.com/g" FlaskApp.conf
sudo cp FlaskApp.conf /etc/apache2/sites-available/FlaskApp.conf
sudo cp flaskapp.wsgi /var/www/FlaskApp/flaskapp.wsgi
sudo rm /etc/apache2/sites-enabled/000-default.conf

# Update init.py
sudo sed -i "s/app.run(host='0.0.0.0.xip.io', port=5000)/app.run(threaded=True)/g" __init__.py
sudo sed -i "s/http:\/\/0.0.0.0.xip.io:5000\//http:\/\/http:\/\/mtgtradingpost.com/g" __init__.py

# Commands to start the service
# Note: For reference only since this should be done at launch.
# sudo a2ensite FlaskApp
# sudo service apache2 restart