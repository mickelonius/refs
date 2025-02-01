
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

---
```bash
git remote add origin git@github.com:mickelonius/refs.git
git remote add secondary git@gitlab.com:mickelonius/references.git
git remote set-url --add --push origin git@gitlab.com:mickelonius/references.git
git remote -v
```

```
origin  git@github.com:mickelonius/refs.git (fetch)
origin  git@github.com:mickelonius/refs.git (push)
origin  git@gitlab.com:mickelonius/references.git (push)
```