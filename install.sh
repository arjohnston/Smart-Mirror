#!/bin/bash

# ensure the user is root for setting this up
function must_be_root {
	if [ $USER != root ]; then
		echo "ERROR: Script must be executed as the root user"
		exit 1
	fi
}

# install the required dependencies
function install_dependencies {
	echo "Installing the dependencies ..."
	sudo pip install requests
	sudo pip install feedparser
	sudo pip install Pillow
	sudo apt-get -y install python-imaging-tk
}

# Allow the necessary files to be executable
function modify_read_write {
	echo "Making the program executable ..."
	chmod +x smartmirror.py
	chmod +x monitor-on-off.sh
	chmod +x timer.sh
}

# setup a timer to turn on and off the monitor
function setup_timer {
	echo ""
	echo "Would you like to set up a timer to automatically turn on|off the screen? (Y/n)"
	
	read setupTimer

	if [ $setupTimer == "y" ] || [ $setupTimer == "Y" ]; then
		echo "What time do you want the monitor to turn off? (Integer in hour format 0-23, e.g. 23 for 11PM)"
		read turnOffTime

		echo "How long do you want it off for (in hours)? "
		read sleepTime

		( crontab -l ; echo "0 $turnOffTime * * * $PWD/timer.sh" ) | crontab -

		#crontab -l > mychron
		#echo "0 $turnOffTime * * * $PWD/timer.sh" >> mycron
		#crontab mycron
		#rm mycron
	elif [ $setupTimer == "n" ] || [ $setupTimer == "N" ]; then
		#{}
	else
		setup_timer
	fi
}

# Set up the smartmirror.py program
# get the user preferences & save them to setup.txt
function setup_smartmirror {
	echo "Would you like to enable the clock? (Y/n)"
	read enableClock

	if [ $enableClock == "Y" ] || [ $enableClock == "y" ]; then
		echo "12 hour or 24 hour format? (12|24)"
		read clockTimeFormat
	fi

	echo "Would you like to enable News? (Y/n)"
	read enableNews

	#if [ $enableNews == "Y" ] || [ $enableNews == "y" ]; then
		#
	#fi

	echo "Would you like to enable Weather? (Y/n)"
	read enableWeather

	if [ $enableWeather == "y" ] || [ $enableWeather == "Y" ]; then

		echo "An API token is required to obtain your location. Alternatively you can enter a static latitude and longitude. Do you want to use an API token? (Y/n)"
       		read enableDynamicWeather
	
	# get dynamic info for weather
		if [ $enableDynamicWeather == "Y" ] || [ $enableDynamicWeather == "y" ]; then
			echo "Create an account at https://ipstack.com/signup/free and enter the location API key:"
			read locationAPI

			echo "Create an account at https://darksky.net/dev/ and enter the weather API key: "
			read weatherAPI

		# use static Lat and Long
		else
			echo "Enter the latitude: "
			read latitude

			echo "Enter the longitude: "
			read longitude
		fi
	fi

	# Store info in file
	echo $enableClock >> config.txt
	echo $clockTimeFormat >> config.txt
	echo $enableNews >> config.txt
	echo $enableWeather >> config.txt
	echo $enableDynamicWeather >> config.txt
	echo $locationAPI >> config.txt
	echo $weatherAPI >> config.txt
	echo $latitude >> config.txt
	echo $longitude >> config.txt
}

function main {
	must_be_root
	sudo rm config.txt

	install_dependencies
	modify_read_write
	setup_timer
	setup_smartmirror
}

main
