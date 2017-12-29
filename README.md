# herango-bash
Create and deploy your django-app on Heroku in 60 seconds. 
Supports both python 2 and 3 and newer django versions (e.g. 1.11 and 2.0)

## Options
- Optionally spins up a new Heroku instance for this app.
- Optionally creates a new git repo
- Optionally sets up an app for you, demoing the usage + fixes the settings for templates etc.

# Download and use script
To download and use this script, go to your terminal and write
```
curl -O https://raw.githubusercontent.com/tomfa/herango-bash/master/install.sh ; sh install.sh
```

The prompt will respond:
```
Do you want to use python3 instead of python? (*y*/n):
Are you using git (*y*/n):
URL to git repository (e.g. git@github.com:gituser/reponame.git): git@github.com/tomfa/herango-bash.git
Would you like me to make a dev-branch (And make it default branch)? (y/*n*):
Django project name (e.g. myproject): lightning
Are you using heroku (*y*/n):
Should I spin up a heroku instance with this app for you? (y/*n*): y
(optional) Domain to be forwarded to heroku (e.g. example.com):
Want me to create an app with a default base template? (*y*/n):
What's the name of the demo app? (e.g. main): thunder
What Django version would you like to use (default 2.0)? (e.g. 1.11):
[... makes the magic]
```
