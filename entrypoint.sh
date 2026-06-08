#!/bin/sh
set -e

# first run: no keypair yet -> create identity non-interactively.
# rad auth reads passphrase from RAD_PASSPHRASE (empty = unencrypted key).
if [ ! -f "$RAD_HOME/keys/radicle" ]; then
    echo "no identity found, running rad auth (alias=${RAD_ALIAS:-radock})"
    rad auth --alias "${RAD_ALIAS:-radock}"
    rad self --did
fi

# radicle-node needs the secret key; with an encrypted key it relies on
# RAD_PASSPHRASE since there is no ssh-agent in the container.
exec radicle-node --listen "${RAD_LISTEN:-0.0.0.0:8776}" "$@"

# rad-home/ will look something like this 
# cobs/  config.json  keys/  node/  storage/

# we want to add a repos/ folder for org
