## How to prune git commit tree
```commandline
git reset --hard <CommitId>
git push -f origin master
```

## Rename local `master` branch to `main`
```commandline
git branch -m master main
```

## Starting a GitLab project with existing local repo
```commandline
git init
git remote add origin git@gitlab.com:mickelonius/fastapi-application.git
git add .
git commit -m "Initial commit"
git branch -m master main
git push -u origin main
```

## Pull all branches from origin
```commandline
git branch -r | grep -v '\->' | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
git fetch --all
git pull --all
```

## Push to two (or more) remote repos
Note that you will need to add both remotes, even if one is already defined for push:
```commandline
git remote set-url --add --push origin git@gitlab.com:mickelonius/references.git
git remote set-url --add --push origin git@github.com:mickelonius/refs.git

git remote -v
origin  git@github.com:mickelonius/refs.git (fetch)
origin  git@gitlab.com:mickelonius/references.git (push)
origin  git@github.com:mickelonius/refs.git (push)
```