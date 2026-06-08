# radock

```
echo 'RAD_ALIAS=john' > .env
echo 'RAD_PASSPHRASE=pw123' >> .env

docker compose build && docker compose up -d
```

=========================================================

$CWD mirrored into Docker volume `./rad-home/repos/$REPO`

`git config core.hooksPath .githooks` set to push to both

provider repo + rad repo

=========================================================

multi-repo test:

```
mkdir -p rad-home/repos/testrepo && echo test > rad-home/repos/testrepo/README.md
./radctl -r testrepo git init -q -b master
./radctl -r testrepo git add README.md
./radctl -r testrepo git commit -m 'init'
./radctl -r testrepo init --name testrepo --default-branch master
```

Or try `radctl --help` and `radctl git --help`
