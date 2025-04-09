git blame bin/server.dart | while read hash others; do echo $hash $others "|" $(git log -1 --pretty=%s $hash); done
