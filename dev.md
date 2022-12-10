# Some notes about build and deploy

## Docker Node
```sh
docker run --rm -ti -p4000:4000 -v $(pwd):/data -w /data node:14 /bin/bash

npm i -g hexo-cli

# update npm modules
npm i -g npm-check-updates
ncu -u
```

## Hexo commands
```sh
hexo g
hexo s
hexo clean
hexo d
```