git stash --include-untracked
git checkout master
7z a xitools.7z addons
git checkout -
git stash pop
