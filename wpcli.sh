# TODO:

# english - spanish traductions
# prompt options
# theme choice

#!/bin/bash

# bash wpcli.sh sitename "My WP Blog"

# $1 = folder name & database name
# $2 = Site title


# VARS
# admin email
email="carlos@vernalis.fr"

# local url login
url="http://"$1".carlos.quai13.com"

# admin login
admin="vernalis"

# path to install your WPs
pathtoinstall="/var/www/html/"

# path to plugins.txt
pluginfilepath="/var/www/plugins.txt"

# end VARS ---


# Stop on error
set -e

# colorize and formatting command line
# You need iTerm and activate 256 color mode in order to work : http://kevin.colyar.net/wp-content/uploads/2011/01/Preferences.jpg
green='\x1B[0;32m'
cyan='\x1B[1;36m'
blue='\x1B[0;34m'
grey='\x1B[1;30m'
red='\x1B[0;31m'
bold='\033[1m'
normal='\033[0m'

# Jump a line
function line {
  echo " "
}

function bot {
  line
  echo -e "${blue}${bold}😄${normal}  $1"
}


#  ==============================
#  = The show is about to begin =
#  ==============================

# Welcome !
bot "${blue}${bold}Bonjour les PDs${normal}"
echo -e "Je vais installer WordPress pour votre site : ${cyan}$2${normal}"


# check if provided folder name already exists
if [ -d $1 ]; then
  bot "${red}Le dossier ${cyan}$1${red}existe déjà${normal}."
  echo "         Par sécurité, je ne vais pas plus loin pour ne rien écraser."
  line

  # quit script
  exit 1
fi

# create directory
bot "Je crée le dossier : ${cyan}$1${normal}"
mkdir $1
cd $1

# Download WP
bot "Je télécharge WordPress..."
wp core download --locale=fr_FR --force

# check version
bot "J'ai récupéré cette version :"
wp core version

# create base configuration
bot "Je lance la configuration :"
wp core config --dbname=$1 --dbuser=root --dbpass=vernalis --skip-check --extra-php <<PHP
define( 'WP_DEBUG', true );
PHP

# Create database
bot "Je crée la base de données :"
wp db create

# Generate Vernalis password
password="tequila"

# launch install
bot "et j'installe !"
wp core install --url=$url --title="$2" --admin_user=$admin --admin_email=$email --admin_password=$password

# Plugins install
bot "J'installe les plugins à partir de la liste des plugins :"
while read line || [ -n "$line" ]
do
    wp plugin install $line --activate
done < pluginfilepath

# Vernalis theme
# bot "Je copie le thème Vernalis :"
# cd wp-content/themes/
#
# cp -R /var/www/html/vernalis_starter_theme /var/www/html/$1/wp-content/themes/
#
# wp theme activate vernalis_starter_theme

# Create standard pages
bot "Je crée les pages habituelles"
wp post create --post_type=page --post_title='Contact' --post_status=publish
wp post create --post_type=page --post_title='Accesibilite' --post_status=publish
wp post create --post_type=page --post_title='Mentions Légales' --post_status=publish

# Create fake posts
# bot "Je crée quelques faux articles d'actualites"
# curl http://loripsum.net/api/5 | wp post generate --post_type=actualites --post_content --count=5

# bot "Je crée quelques faux articles d'agenda"
# curl http://loripsum.net/api/5 | wp post generate --post_type=agenda --post_content --count=5


# Menu stuff
# bot "Je crée le menu principal, assigne les pages, et je lie l'emplacement du thème : "
# wp menu create "Menu Principal"
# wp menu item add-post menu-principal 3
# wp menu item add-post menu-principal 4
# wp menu item add-post menu-principal 5
# wp menu location assign menu-principal menu-1

# Misc cleanup
bot "Je supprime Hello Dolly, les thèmes de base et les articles exemples"
wp post delete 1 --force # Article exemple - no trash. Comment is also deleted
wp post delete 2 --force # page exemple
wp plugin delete hello
# wp theme delete twentytwelve
# wp theme delete twentythirteen
# wp theme delete twentyfourteen
# wp option update blogdescription ''

# Permalinks to /%postname%/
bot "J'active la structure des permaliens"
wp rewrite structure "/%postname%/" --hard
wp rewrite flush --hard

# cat and tag base update
wp option update category_base theme
wp option update tag_base sujet

# Git project
# REQUIRED : download Git at http://git-scm.com/downloads

# Create gitignore
bot "je crée un fichier gitignore"
cd ../..
cat <<EOF >.gitignore
.svn
wp-content/object-cache.php
.cvs
*.bak
*.swp
Thumbs.db
wp-content/cache/supercache/*
*.log
.htaccess
.DS_Store
sitemap.xml
sitemap.xml.gz
wp-config.php
wp-content/advanced-cache.php
wp-content/backup-db/
wp-content/backups/
wp-content/blogs.dir/
wp-content/cache/
wp-content/upgrade/
wp-content/uploads/
wp-content/wp-cache-config.php
wp-content/plugins/hello.php
.sass-cache/
node_modules/
*.css.map
sitesync/
config.codekit
/readme.html
/license.txt
wp-content/wflogs/config.php
html-files-to-import/
sitesync
wp-content/plugins/wordfence/
wp-content/wflogs/
EOF
bot "Je Git le .gitignore :"

# That's all ! Install summary
bot "${green}L'installation est terminée !${normal}"
line
echo "URL du site:   $url"
echo "Login admin :  vernalis"
echo -e "Password :  ${cyan}${bold} $password ${normal}${normal}"
line
echo -e "${grey}(N'oubliez pas le mot de passe ! Je l'ai copié dans le presse-papier)${normal}"

line
bot "à Bientôt !"
line
line
