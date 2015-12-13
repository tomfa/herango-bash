#!/bin/bash

# Requires python, pip, virtualenv
# 	which can be installed with brew install python
#   (See brew.sh for brew installation)


## INPUT HELP FUNCTIONS
bold=$(tput bold)
normal=$(tput sgr0)

function trueFalseInputDefTrue {
    while true; do
        printf "$2 (${bold}y${normal}/n): "
        read INPUT

        if [ "$INPUT" = "n" ] ; then
            printf -v $1 false
            break
        else
            if [ "$INPUT" = "y" ] || [ "$INPUT" = "" ] ; then
                printf -v $1 true
                break
            else 
                echo "Invalid input."
            fi
        fi
    done
}

function trueFalseInputDefFalse {
    while true; do
        printf "$2 (y/${bold}n${normal}): "
        read INPUT

        if [ "$INPUT" = "y" ] ; then
            printf -v $1 true
            break
        else
            if [ "$INPUT" = "n" ] || [ "$INPUT" = "" ] ; then
                printf -v $1 false
                break
            else 
                echo "Invalid input."
            fi
        fi
    done
}

function nonEmptyTextInput {
    while true; do
        printf "$2 (e.g. $3): "
        read INPUT

        if [ "$INPUT" = "" ] ; then
            echo "Invalid input"
        else
            printf -v $1 $INPUT
            break
        fi
    done
}

function textInput {
    printf "$2 (e.g. $3): "
    read INPUT

    printf -v $1 "$INPUT"
}


## ENSURING WE HAVE REQUIREMENTS
MISSING_REQUIREMENT=false;

type git >/dev/null 2>&1 || [ "$USE_GIT" = false ] || { echo >&2 "I require git but it's not installed.  Please install with 'brew install git' or see https://git-scm.com/book/en/v2/Getting-Started-Installing-Git"; MISSING_REQUIREMENT=true; }
type python >/dev/null 2>&1 || { echo >&2 "I require python but it's not installed.  Please install with 'brew install python' or see https://www.python.org/downloads/"; MISSING_REQUIREMENT=true; }
type pip >/dev/null 2>&1 || { echo >&2 "I require pip but it's not installed. Please install with 'curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | sudo python'"; MISSING_REQUIREMENT=true; }
type virtualenv >/dev/null 2>&1 || { echo >&2 "I require virtualenv but it's not installed.  Please install with 'pip install virtualenv'"; MISSING_REQUIREMENT=true; }
type heroku >/dev/null 2>&1 || [ "$USE_HEROKU" = false ] || { echo >&2 "I require heroku but it's not installed.  Please install with 'brew install heroku' or see toolbelt.heroku.com."; MISSING_REQUIREMENT=true; }
type pg_config >/dev/null 2>&1 || [ "$USE_HEROKU" = false ] || { echo >&2 "I require postgres but it's not installed.  Please install with 'brew install postgres' or see www.postgresql.org/download/"; MISSING_REQUIREMENT=true; }
type npm >/dev/null 2>&1 || [ "$USE_NPM" = false ] || { echo >&2 "I require npm but it's not installed.  Please install with 'brew install node' or see nodejs.org/download/"; MISSING_REQUIREMENT=true; }

if [ "$MISSING_REQUIREMENT" = true ] ; then
    type brew >/dev/null 2>&1 || { echo >&2 "Brew is recommended, but not found. It can be installed with 'ruby -e \$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)' or see http://brew.sh"; }
    trueFalseInputDefFalse "CONTINUE" "Requirements are not met. You should install these first. \nDo you wish to continue anyway (not recommended)?"
    if [ "$CONTINUE" = false ] ; then
        exit 1;
    fi
fi

## GETTING INPUTS
trueFalseInputDefTrue "USE_GIT" "Should I initialize a git repository (necessary to push to heroku)?"
if [ "$USE_GIT" = true ] ; then
    textInput "GIT_REPO" "URL to existing git repository (leave empty if none)" "git@github.com:gituser/reponame.git"
    trueFalseInputDefTrue "DEV_BRANCH" "Would you like me to make a branch 'dev' (and make it the default branch)?"
fi
nonEmptyTextInput "DJANGO_PROJECT_NAME" "Django project name" "myproject"
trueFalseInputDefTrue "USE_HEROKU" "Should I set up the project to be Heroku-compatible?"
if [ "$USE_HEROKU" = true ] && [ "$USE_GIT" = true ] ; then
    trueFalseInputDefFalse "NEW_HEROKU" "Should I also spin up a heroku instance with this app for you?"
    if [ "$NEW_HEROKU" = true ] ; then
        textInput "HEROKU_DOMAINS" "(optional) Domain to be forwarded to heroku" "example.com"
    fi
fi

trueFalseInputDefTrue "PACKAGES" "Would you like to browse our selection of packages (Bootstrap, jQuery etc)?"
if [ "$PACKAGES" = true ] ; then

    trueFalseInputDefTrue "JQUERY" "Do you want jQuery?"
    trueFalseInputDefFalse "BOOTSTRAP" "Do you want Bootstrap?"
    if [ "$BOOTSTRAP" = false ] ; then
        trueFalseInputDefTrue "FOUNDATION" "How about Foundation?"
    fi
    trueFalseInputDefTrue "GULP" "Do you want Gulp?"
    if [ "$GULP" = false ] ; then
        trueFalseInputDefTrue "GRUNT" "Do you want Grunt, instead then?"
    fi
    trueFalseInputDefTrue "FONTAWESOME" "Do you want FontAwesome-icons?"
fi

trueFalseInputDefTrue "DEMO_APP" "Want me to create an app with a default base template?"
if [ "$DEMO_APP" = true ] ; then
    nonEmptyTextInput "DEMO_NAME" "What's the name of the demo app?" "main"
    trueFalseInputDefFalse "USE_GOOGLE_ANALYTICS" "Do you want Google Analytics included on the dummypage?"
    if [ "$USE_GOOGLE_ANALYTICS" = true ] ; then
        nonEmptyTextInput "GOOGLE_ANALYTICS_ID" "What's your Google Analytics ID?" "UA-12345-6"
    fi
fi
# trueFalseInputDefTrue "DEMO_MODEL" "(TODO) Want me to create an dummy model app?"

## ACTION!
mkdir $DJANGO_PROJECT_NAME
cd $DJANGO_PROJECT_NAME

if [ "$USE_GIT" = true ] ; then
    echo "\nscript: -> Initializing repository for $GIT_REPO"
	git init
        if [ ! "$GIT_REPO" = "" ] ; then
	    git remote add origin $GIT_REPO
        fi
fi

# Installing project requirements in virtual environment
echo "\nscript: -> Installing python requirements"
virtualenv env
source env/bin/activate 
pip install Django==1.8.6
pip install dj-database-url==0.3.0
pip install dj-static==0.0.6

if [ "$USE_HEROKU" = true ] ; then
	pip install django-toolbelt==0.0.1
    if [ "$PACKAGES" = true ] ; then
        npm install bower --save
        cat <<EOF >> .buildpacks
https://github.com/heroku/heroku-buildpack-nodejs.git
https://github.com/heroku/heroku-buildpack-python.git
EOF
    fi
fi

# Creating django project
django-admin startproject $DJANGO_PROJECT_NAME .

# Add django config
echo "\nscript: -> Creating django settings"

cat <<EOF >> $DJANGO_PROJECT_NAME/settings.py 
# AUTO-GENERATED CONFIG
# Parse database configuration from $DATABASE_URL
import dj_database_url
DATABASES['default'] =  dj_database_url.config()

# Honor the 'X-Forwarded-Proto' header for request.is_secure()
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

# Allow all host headers
ALLOWED_HOSTS = ['*']

# Static asset configuration
import os
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
STATIC_ROOT = 'staticfiles'
STATIC_URL = '/static/'

DEBUG = False

STATICFILES_DIRS = (
    os.path.join(BASE_DIR, '../../static'),
)

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': ('%(asctime)s [%(process)d] [%(levelname)s] ' +
                       'pathname=%(pathname)s lineno=%(lineno)s ' +
                       'funcname=%(funcName)s %(message)s'),
            'datefmt': '%Y-%m-%d %H:%M:%S'
        },
        'simple': {
            'format': '%(levelname)s %(message)s'
        }
    },
    'handlers': {
        'null': {
            'level': 'DEBUG',
            'class': 'logging.NullHandler',
        },
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose'
        }
    },
    'loggers': {
        'testlogger': {
            'handlers': ['console'],
            'level': 'INFO',
        }
    }
}

TEMPLATES = [{
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': ['templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
                'django.core.context_processors.static'
            ],
        },
    }]
EOF

if [ "$PACKAGES" = true ] ; then
    echo "\nscript: -> Setting up node and bower components"
    cat <<EOF >> package.json
{
  "name": "$DJANGO_PROJECT_NAME",
  "version": "1.0.0",
  "description": "$DJANGO_PROJECT_NAME",
  "main": "index.js",
  "repository": "$GIT_REPO",
  "readme": "See $GIT_REPO",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1;",
    "postinstall": "echo \"Installing bower packages\"; bower install;"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
  },
  "cacheDirectories": ["node_modules", "components"]
}
EOF
    npm install bower --save
    if [ "$GULP" = true ] ; then
        type gulp >/dev/null 2>&1 && "Gulp already installed globally" || { npm install -g gulp; }
        npm install gulp --save
        cat <<EOF >> gulpfile.js
var gulp = require('gulp');

gulp.task('default', function() {
  // place code for your default task here
});
EOF
    fi
    if [ "$GRUNT" = true ] ; then
        type grunt >/dev/null 2>&1 && "Grunt already installed globally" || { npm install -g grunt-cli; }
        npm install grunt-cli --save
    fi
    
    cat <<EOF >> .bowerrc
{
  "directory": "components"
}
EOF
    cat <<EOF >> bower.json
{
  "name": "$DJANGO_PROJECT_NAME",
  "description": "$DJANGO_PROJECT_NAME",
  "main": "",
  "license": "",
  "moduleType": [],
  "homepage": ""
}
EOF
    if [ "$JQUERY" = true ] ; then
        ./node_modules/bower/bin/bower install jquery --save
    fi
    if [ "$BOOTSTRAP" = true ] ; then
        ./node_modules/bower/bin/bower install bootstrap --save
    fi
    if [ "$FOUNDATION" = true ] ; then
        ./node_modules/bower/bin/bower install foundation --save
    fi
    if [ "$FONTAWESOME" = true ] ; then
        ./node_modules/bower/bin/bower install font-awesome --save
    fi
fi

mkdir $DJANGO_PROJECT_NAME/settings
mv $DJANGO_PROJECT_NAME/settings.py $DJANGO_PROJECT_NAME/settings/base.py

cat <<EOF >> $DJANGO_PROJECT_NAME/settings/example_local.py 
"""
    Local settings. Copy this file to local.py to enable local settings.
"""

import os
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

DEBUG = True

ALLOWED_HOSTS = ['*']

# Database
# https://docs.djangoproject.com/en/1.8/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, '../../db.sqlite3'),
    }
}
EOF

cp $DJANGO_PROJECT_NAME/settings/example_local.py $DJANGO_PROJECT_NAME/settings/local.py 

cat <<EOF >> $DJANGO_PROJECT_NAME/settings/__init__.py 
from $DJANGO_PROJECT_NAME.settings.base import *
import os

dir = os.path.dirname(__file__)
filename = os.path.join(dir, 'local.py')

if os.path.exists(filename):
    from $DJANGO_PROJECT_NAME.settings.local import *
else:
    print("Not using localsettings, $DJANGO_PROJECT_NAME.settings.local could not be found. Continuing with default settings")
EOF


if [ "$USE_HEROKU" = true ] ; then
	echo "\nscript: -> Setting up files for heroku"
cat > Procfile << EOF
web: gunicorn $DJANGO_PROJECT_NAME.wsgi --log-file -
EOF

cat > $DJANGO_PROJECT_NAME/wsgi.py << EOF
import os
from django.core.wsgi import get_wsgi_application
from dj_static import Cling

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "$DJANGO_PROJECT_NAME.settings")

application = Cling(get_wsgi_application())
EOF
fi

echo "\nscript: -> Exporting requirements to requirements.txt"
pip freeze > requirements.txt  # Export pip requirements to file

if [ "$DEMO_APP" = true ] ; then
    echo "\nscript: -> Creating demo app"
    python manage.py startapp $DEMO_NAME
    
    cat <<EOF >> $DJANGO_PROJECT_NAME/settings/base.py 
INSTALLED_APPS = INSTALLED_APPS + ('$DEMO_NAME',)
EOF
    cat <<EOF >> $DJANGO_PROJECT_NAME/urls.py
urlpatterns.append(url(r'^$', '$DEMO_NAME.views.home', name='home'));
EOF
    mkdir -p $DEMO_NAME/templates/$DEMO_NAME
    
    cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/base.html
{% load staticfiles %}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" type="image/png" href="{{ STATIC_URL }}img/logo-favicon.png">
    <meta name="description" content="{{ page_description|default:"TODO: Default desciption" }}">
    <meta name="author" content="TODO: tomfa@github">

    <!-- Open Graph data -->
    <meta property="og:title" content="{{ page_title|default:"TODO: Default title" }}" />
    <meta property="og:type" content="website" />
    <meta property="og:url" content="{{ request.scheme }}://{{ request.META.HTTP_HOST }}" />
    <meta property="og:image" content="{{ request.scheme }}://{{ request.META.HTTP_HOST }}{{ STATIC_URL }}img/social-fb.jpg" />
    <meta property="og:description" content="{{ page_description|default:"TODO: Default desciption" }}" />

    <title>{{ page_title|default:"TODO: Default title" }}</title>
EOF
    if [ "$FOUNDATION" = true ] ; then
        cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/base.html
    <!-- Package: Foundation -->
    <link href="{{ STATIC_URL }}components/foundation/css/foundation.min.css" rel="stylesheet">

EOF
    fi
    if [ "$BOOTSTRAP" = true ] ; then
        cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/base.html
    <!-- Package: Bootstrap -->
    <link href="{{ STATIC_URL }}components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet">

EOF
    fi
    if [ "$FONTAWESOME" = true ] ; then
        cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/base.html
    <!-- Package: Font Awesome -->
    <link href="{{ STATIC_URL }}components/font-awesome/css/font-awesome.min.css" rel="stylesheet">

EOF
    fi

    cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/base.html
    <!-- Custom style for base-template -->
    <link href="{{ STATIC_URL }}css/style.css" rel="stylesheet">

    <!-- Custom style for specific template -->
    {% block style %}
    {% endblock %}

</head>
<body>

{% block content %}
{% endblock %}
EOF
    if [ "$USE_GOOGLE_ANALYTICS" = true ] ; then
        mkdir static/js
        cat <<EOF >> static/js/ga.js
var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '$GOOGLE_ANALYTICS_ID']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
EOF

    cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/base.html
    <!-- Google Analytics -->
    <script src="{% static "js/ga.js" %}"></script>

EOF
    fi
    if [ "$JQUERY" = true ] ; then
        cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/base.html
    <!-- jQuery -->
    <script src="{% static "components/jquery/dist/jquery.min.js" %}"></script>

EOF
    fi
    if [ "$BOOTSTRAP" = true ] ; then
        cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/base.html
    <!-- Bootstrap Core JavaScript -->
    <script src="{% static "components/bootstrap/dist/js/bootstrap.min.js" %}"></script>

EOF
    fi
    cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/base.html
{% block script %}
{% endblock %}

</body>
</html>
EOF
    cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/home.html
    {% extends "$DEMO_NAME/base.html" %}

{% block style %}
    <link href='https://fonts.googleapis.com/css?family=Roboto+Mono:400,300,500' rel='stylesheet' type='text/css'>
    <style>
        section {
            font-weight: 400;
            font-size: 1.4rem;
            box-sizing: border-box;
            margin: 0;
            color: white;
            text-align: left;
            padding: 1rem;
            float: left;
        }
        p, ul { font-size: 1.4rem; max-width: 550px;}
        code {
            padding: 0.5rem; 
            margin-top: 2rem; 
            display: block;
            overflow: scroll;
            background-color: #000000;
            color: #5CFF09;
        }
        h1 { 
            font-size: 4rem; 
            font-family: 'Roboto Mono', ; 
            font-weight: 300;
            padding: 1rem;
        }
        ul {
            list-style: none;
        }

        .bash h1{
            color: #FDFDFD;
        }

        .herango h1{
            color: #555555;
        }

        .herango {
            width: 100%;
            background-color: #FFFFFF;
            color: #555555;
        }
        .bash {
            width: 100%;
            background-color: #555555;
            color: #E7E7E7;
        }
        .btn {
            margin: 3px;
        }

        .desktop-only { display: none }

        @media screen and (min-width: 767px) {
            .herango, .bash {
                min-height: 100vh;
            }
            h1 {
                font-size: 4rem;
                padding: 1rem 0;
            }
            .bash {
                width: 70%; 
            }
            .herango {
                width: 30%;
                text-align: right;
            }
            .mobile-only {
                display: none;
            }
            .desktop-only {
                display: block;
            }
        }
        .sign {
            margin-top: 2rem;
            font-weight: 500;
        }
    </style>
{% endblock %}

{% block content %}
    <a class="desktop-only" href="https://github.com/tomfa/herango-bash">
        <img style="position: absolute; top: 0; right: 0; border: 0;" src="https://camo.githubusercontent.com/a6677b08c955af8400f44c6298f40e7d19cc5b2d/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f677261795f3664366436642e706e67" alt="Fork me on GitHub" data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_right_gray_6d6d6d.png">
    </a>

    <h1 class="mobile-only">Herango Bash</h1>
    <section class="herango">
        <h1 class="desktop-only">Herango</h1>
        <p>I am your Django-app with:</p>
        <ul>
EOF
if [[ "$GULP" = true ]]; then
    cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/home.html 
            <li>Gulp</li>
EOF
fi
if [[ "$GRUNT" = true ]]; then
    cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/home.html
            <li>Grunt</li>
EOF
fi
if [[ "$BOOTSTRAP" = true ]]; then
    cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/home.html
            <li>Bootstrap</li>
EOF
fi
if [[ "$FOUNDATION" = true ]]; then
    cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/home.html
            <li>Foundation</li>
EOF
fi
if [[ "$JQUERY" = true ]]; then
    cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/home.html
            <li>jQuery</li>
EOF
fi
if [[ "$FONTAWESOME" = true ]]; then
    cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/home.html
            <li>Font-Awesome</li>
EOF
fi
if [[ "$USE_GOOGLE_ANALYTICS" = true ]]; then
    cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/home.html
            <li>Google Analytics</li>
EOF
fi
    cat <<EOF >> $DEMO_NAME/templates/$DEMO_NAME/home.html
        </ul>
    </section>
    <section class="bash">
        <h1 class="desktop-only">Bash</h1>
        <p>
            Herango-Bash is just a bash-script. It helps you quickly setup Django and push it to Heroku. Real fast. SuperASAP.
        </p>
        <p>
            As long as you're connected to the internet, you can always run this script with the following command via the terminal:
            <code>curl -O https://raw.githubusercontent.com/tomfa/herango-bash/master/install.sh ; sh install.sh </code>
        </p>
        <p class="sign">
            <a class="button btn btn-primary" href="https://github.com/tomfa/herango-bash/issues">Request other packages</a>
            <a class="button btn btn-danger" href="https://github.com/tomfa/herango-bash/issues">Found a bug?</a>
            <a class="button btn btn-success mobile-only" href="http://github.com/tomfa/herango-bash">Fork the script on github</a>
        </p>
    </section>
{% endblock %}

{% block script %}
    {# Includes parent script block #}
    {{ block.super }}  

    {# Your custom javascript goes here #}
    <script>true</script>
{% endblock %}
EOF
    cat <<EOF >> $DEMO_NAME/views.py
def home(request):
    return render(request, '$DEMO_NAME/home.html')
EOF
    mkdir static/css
    cat <<EOF >> static/css/style.css
* {padding: 0; margin: 0; box-sizing: border-box; }
html { font-size: 12px; margin: 0; padding: 0; }
EOF

fi

echo "\nscript: -> Collecting static files and migrating"
python manage.py collectstatic --noinput
python manage.py migrate --noinput

if [ "$USE_GIT" = true ] ; then
    echo "\nscript: -> Configuring git"
# Ignore certain files from being added to git
cat > .gitignore << EOF
env
*.py[cod]
.DS_Store
staticfiles
.idea
local.py
node_modules/*
static/components
EOF

	git add .
	git commit -m "Autogenerated app $DJANGO_PROJECT_NAME"
    if [ "$DEV_BRANCH" = true ] ; then
        git checkout -b dev
        git symbolic-ref HEAD refs/heads/dev
    fi
fi

if [ "$USE_HEROKU" = true ] ; then
    if [ "$NEW_HEROKU" = true ] ; then
        echo "\nscript: -> Spinning up a new heroku"
        heroku create
	heroku buildpacks:set https://github.com/heroku/heroku-buildpack-multi.git
        git push heroku master
        heroku ps:scale web=1
        if ! [ "$HEROKU_DOMAINS" = "" ] ; then
            heroku domains:add $HEROKU_DOMAINS
        fi
    else
        echo "-----------------------------------------------"
        echo "  This app can now be published to heroku with:"
        echo "  > cd $DJANGO_PROJECT_NAME"
        echo "  > heroku create"
        echo "  > heroku buildpacks:set https://github.com/heroku/heroku-buildpack-multi.git"
        echo "  > git push heroku master"
        echo "  > heroku ps:scale web=1	"
    fi
fi

if [ "$USE_GIT" = true ] ; then
    echo "-----------------------------------------------"
    echo "  Create your empty repository if you haven't, "
    echo "  e.g. at https://github.com/new"
    echo "  and push with"
    echo "  > cd $DJANGO_PROJECT_NAME"
    echo "  > git push -u"

    if [ "$USE_HEROKU" = true ]; then
        echo "-----------------------------------------------"
        echo "  Automatic deploy from github to heroku can be" 
        echo "  configured from https://dashboard.heroku.com/" 
        echo "      -> app -> deploy -> github"
    fi
fi
echo "-----------------------------------------------"
echo "  In order to run your app, do: "
echo "  > cd $DJANGO_PROJECT_NAME"
echo "  > source env/bin/activate"
echo "  > python manage.py runserver"
