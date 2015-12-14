#!/bin/sh

# Build drupal
drush make https://raw.githubusercontent.com/aakb/odaa_dk/development/odaa.make htdocs

# Clone odaa
FOLDER='htdocs/sites/odaa.dk'
git clone git@github.com:aakb/odaa_dk.git $FOLDER

# Configure
mkdir -p ${FOLDER}/files
mkdir -p ${FOLDER}/private/files
mkdir -p ${FOLDER}/private/temp
cp htdocs/sites/default/default.settings.php ${FOLDER}/settings.php
chmod 664 ${FOLDER}/settings.php

cp htdocs/sites/example.sites.php htdocs/sites/sites.php
echo "\$sites['odaa.vm'] = 'odaa.dk';" >> htdocs/sites/sites.php

