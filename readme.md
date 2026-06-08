# radock

```
echo 'RAD_ALIAS=john' > .env
echo 'RAD_PASSPHRASE=pw123' > .env

docker compose build && docker compose up -d
```

=========================================================

$CWD mirrored into Docker volume `./rad-home/repos/$REPO`
`git config core.hooksPath .githooks` set to push to both

provider repo + rad repo

=========================================================
