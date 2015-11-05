# herango-bash
Create and deploy your django-app on Heroku in 60 seconds. 

Prompts you for a set of questions, and creates magic!


## Packages
- Google Analytics
- Grunt or Gulp
- Bower
- Bootstrap or Foundation
- jQuery
- FontAwesome

## Other options
- Optionally spins up a new Heroku instance for this app.
- Optionally creates a new git repo with dev branch as default branch
- Optionally sets up an app for you, demoing the usage + fixes the settings for templates etc.

# Download and use script
To download and use this script, go to your terminal and write
```
curl -O https://raw.githubusercontent.com/tomfa/herango-bash/master/install.sh ; sh install.sh
```

The prompt will respond:
```
Are you using git (*y*/n):
URL to git repository (e.g. git@github.com:gituser/reponame.git): git@github.com/tomfa/herango-bash.git
Would you like me to make a dev-branch (And make it default branch)? (*y*/n):
Django project name (e.g. myproject): lightning
Are you using heroku (*y*/n):
Should I spin up a heroku instance with this app for you? (y/*n*): y
(optional) Domain to be forwarded to heroku (e.g. example.com):
Would you like to browse our selection of packages (Bootstrap, jQuery etc)? (*y*/n):
Do you want jQuery? (*y*/n):
Do you want Bootstrap? (y/*n*): y
Do you want Gulp? (*y*/n):
Do you want FontAwesome-icons? (*y*/n):
Want me to create an app with a default base template? (*y*/n):
What's the name of the demo app? (e.g. main): thunder
Do you want Google Analytics included on the dummypage? (y/*n*): y
What's your Google Analytics ID? (e.g. UA-12345-6): UA-12345-6
[... makes the magic]
```
