#!/bin/bash
# Let's start fresh!
clear

# Help?
if [[ $1 == '-h' ]]; then
	echo "Usage: wordpressinstall INSTALL_DIRECTORY [-c|-chown USERNAME]"
	exit
fi

# Installation directory
INSTALL_DIR=$1
if [[ $INSTALL_DIR == "" ]]; then
	echo "Please restart the script with a path"
	exit
elif [[ $INSTALL_DIR == "/" ]]; then
	echo "You can't install Wordpress to /!"
	exit
fi

if [[ $(whoami) != "root" ]]; then
	echo "This script requires root access. Try 'sudo wordpressinstall INSTALL_DIRECTORY [-c|-chown USERNAME]'"
	exit
fi

# Retrieving all variables
echo "Please enter the database name:"
read DBNAME
clear
echo "Please enter the database user:"
read DBUSER
clear
echo "Please enter the database password:"
read DBPASS
clear
SECURE_KEYS=$(curl "https://api.wordpress.org/secret-key/1.1/salt/" | sed "s/)\;/)\;\\r\\n/g")

# Administrator login
echo "Enter admin username:"
read GEBRUIKER
clear
echo "Enter admin email:"
read JEEMAILADRES
clear

# Site data
echo "Enter site URL (with http(s)://:"
read URLVANDESITE
clear
echo "Enter site title:"
read TIETEL
clear
echo "Enter site description:"
read OMSCHRIJVING
clear

# Asking for deletion
clear
if [ ! -d "$INSTALL_DIR" ]; then
  mkdir -p $INSTALL_DIR
else
	echo "Do you want to remove all files from $INSTALL_DIR? y/n"
	read answer

	if [[ $answer == 'y' ]]; then
		rm -rf $INSTALL_DIR/*
		clear
		echo "Directory $INSTALL_DIR emptied."
	else
		clear
	fi
fi

echo "Do you want to empty the database $DBNAME? y/n"
read answer2

if [[ $answer2 == 'y' ]]; then
	mysql -u$DBUSER -p$DBPASS -e "DROP DATABASE $DBNAME"
	mysql -u$DBUSER -p$DBPASS -e "CREATE DATABASE $DBNAME"
	clear
	echo "Database $DBNAME emptied."
else
	clear
fi

echo "Downloading required files..."

# Where to download from
FILELOCATION="https://wordpress.org/latest.tar.gz"

# Get the file
cd /tmp
wget $FILELOCATION
clear

# Extract the file
echo "Extracting the archive"
tar -xzf latest.tar.gz

# And removing it
echo "Removing the archive"
rm -rf latest.tar.gz

# Move contents to install dir
echo "Moving the wordpress core files to $INSTALL_DIR"
mv wordpress/* $INSTALL_DIR

# Remove traces
echo "Removing archive"
rm -rf /tmp/wordpress

# Making the config file
echo "Preparing wp-config.php"

# Changing to install directory
cd $INSTALL_DIR
echo "<?php" >> wp-config.php
echo "/**" >> wp-config.php
echo "* The base configuration for WordPress" >> wp-config.php
echo "*" >> wp-config.php
echo "* The wp-config.php creation script uses this file during the" >> wp-config.php
echo "* installation. You don't have to use the web site, you can" >> wp-config.php
echo "* copy this file to "wp-config.php" and fill in the values." >> wp-config.php
echo "*" >> wp-config.php
echo "* This file contains the following configurations:" >> wp-config.php
echo "*" >> wp-config.php
echo "* * MySQL settings" >> wp-config.php
echo "* * Secret keys" >> wp-config.php
echo "* * Database table prefix" >> wp-config.php
echo "* * ABSPATH" >> wp-config.php
echo "*" >> wp-config.php
echo "* @link https://codex.wordpress.org/Editing_wp-config.php" >> wp-config.php
echo "*" >> wp-config.php
echo "* @package WordPress" >> wp-config.php
echo "*/" >> wp-config.php
echo "" >> wp-config.php
echo "/** MySQL settings - You can get this info from your web host **/" >> wp-config.php
echo "/** The name of the database for WordPress */" >> wp-config.php
echo "define('DB_NAME', '$DBNAME');" >> wp-config.php
echo "" >> wp-config.php
echo "/** MySQL database username */" >> wp-config.php
echo "define('DB_USER', '$DBUSER');" >> wp-config.php
echo "" >> wp-config.php
echo "/** MySQL database password */" >> wp-config.php
echo "define('DB_PASSWORD', '$DBPASS');" >> wp-config.php
echo "" >> wp-config.php
echo "/** MySQL hostname */" >> wp-config.php
echo "define('DB_HOST', 'localhost');" >> wp-config.php
echo "" >> wp-config.php
echo "/** Database Charset to use in creating database tables. */" >> wp-config.php
echo "define('DB_CHARSET', 'utf8');" >> wp-config.php
echo "" >> wp-config.php
echo "/** The Database Collate type. Don't change this if in doubt. */" >> wp-config.php
echo "define('DB_COLLATE', '');" >> wp-config.php
echo "" >> wp-config.php
echo "/**#@+" >> wp-config.php
echo "* Authentication Unique Keys and Salts." >> wp-config.php
echo "*" >> wp-config.php
echo "* Change these to different unique phrases!" >> wp-config.php
echo "* You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}" >> wp-config.php
echo "* You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again." >> wp-config.php
echo "*" >> wp-config.php
echo "* @since 2.6.0" >> wp-config.php
echo "*/" >> wp-config.php
echo "$SECURE_KEYS" >> wp-config.php
echo "" >> wp-config.php
echo "/**" >> wp-config.php
echo "* WordPress Database Table prefix." >> wp-config.php
echo "*" >> wp-config.php
echo "* You can have multiple installations in one database if you give each" >> wp-config.php
echo "* a unique prefix. Only numbers, letters, and underscores please!" >> wp-config.php
echo "*/" >> wp-config.php
echo "\$table_prefix  = 'wp_';" >> wp-config.php
echo "" >> wp-config.php
echo "/**" >> wp-config.php
echo "* For developers: WordPress debugging mode." >> wp-config.php
echo "*" >> wp-config.php
echo "* Change this to true to enable the display of notices during development." >> wp-config.php
echo "* It is strongly recommended that plugin and theme developers use WP_DEBUG" >> wp-config.php
echo "* in their development environments." >> wp-config.php
echo "*" >> wp-config.php
echo "* For information on other constants that can be used for debugging," >> wp-config.php
echo "* visit the Codex." >> wp-config.php
echo "*" >> wp-config.php
echo "* @link https://codex.wordpress.org/Debugging_in_WordPress" >> wp-config.php
echo "*/" >> wp-config.php
echo "define('WP_DEBUG', false);" >> wp-config.php
echo "" >> wp-config.php
echo "/* That's all, stop editing! Happy blogging. */" >> wp-config.php
echo "" >> wp-config.php
echo "/** Absolute path to the WordPress directory. */" >> wp-config.php
echo "if ( !defined('ABSPATH') )" >> wp-config.php
echo "        define('ABSPATH', dirname(FILE) . '/');" >> wp-config.php
echo "" >> wp-config.php
echo "/** Sets up WordPress vars and included files. */" >> wp-config.php
echo "require_once(ABSPATH . 'wp-settings.php');" >> wp-config.php

# Setting up the database
clear
echo "Setting up the database, this might take a while"
echo ""

# Changing back to temp directory
cd /tmp

# Fetching the template
SQLURL="http://dl.laurensho.nl/wptemplate.sql"
wget $SQLURL

# Changing some values in the SQL
sed -i "s/TIETEL/$TIETEL/g" wptemplate.sql
sed -i "s/OMSCHRIJVING/$OMSCHRIJVING/g" wptemplate.sql

# Actual importing of the database
mysql -u$DBUSER -p$DBPASS $DBNAME < wptemplate.sql
mysql -u$DBUSER -p$DBPASS $DBNAME -e "update wp_options SET option_value=\"$URLVANDESITE\" where option_name=\"siteurl\" OR option_name=\"home\";"

rm wptemplate.sql
clear

# Installing WP CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Chowning
if [[ $2 == '-chown' ]]; then
	echo "Changing owner of all files."
	chown -R $3: $INSTALL_DIR
elif [[ $2 == '-c' ]]; then
	echo "Changing owner of all files."
	chown -R $3: $INSTALL_DIR
fi

clear
echo "Installation done. Administrator password below:"

cd $INSTALL_DIR
wp --allow-root user create $GEBRUIKER $JEEMAILADRES --role=administrator
