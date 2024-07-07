
# Pushing to two origins
Create two remotes
```bash
git remote add gitlab https://gitlab.com/your-username/your-repo.git
git remote add github https://github.com/your-username/your-repo.git
git remote -v
```

Loop through remotes when pushing
```bash
for remote in gitlab github; do git push $remote master; done
```

