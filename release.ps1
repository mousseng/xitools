git stash --include-untracked
git checkout master
rm xitools.7z
7z a xitools.7z addons
git checkout -
git stash pop
