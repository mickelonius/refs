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