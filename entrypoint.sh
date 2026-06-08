#!/bin/sh
set -e

# first run: no keypair yet -> create identity non-interactively.
# rad auth reads passphrase from RAD_PASSPHRASE (empty = unencrypted key).
if [ ! -f "$RAD_HOME/keys/radicle" ]; then
    echo "no identity found, running rad auth (alias=${RAD_ALIAS:-radock})"
    rad auth --alias "${RAD_ALIAS:-radock}"
    rad self --did
fi

# working copies live here (sibling of storage/, not inside it).
# storage/ is radicle's internal object store; repos/ is for git checkouts.
mkdir -p "$RAD_HOME/repos"

# radicle-node needs the secret key; with an encrypted key it relies on
# RAD_PASSPHRASE since there is no ssh-agent in the container.
exec radicle-node --listen "${RAD_LISTEN:-0.0.0.0:8776}" "$@"
