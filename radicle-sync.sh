#!/bin/sh
# Mirror the current branch into the radicle docker workspace, then announce it.
# Best-effort by design: every failure path exits 0 so a git pre-push to the
# provider still proceeds even when the node is down or the workspace is missing.
set -e

# guard against recursion: pushing to the workspace below re-fires pre-push,
# which would re-run this script -> fork bomb. bail if already inside a run.
[ -n "$RADICLE_SYNC_RUNNING" ] && exit 0
export RADICLE_SYNC_RUNNING=1

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=${REPO_ROOT:-$HERE}
COMPOSE_DIR=${COMPOSE_DIR:-$REPO_ROOT}
SVC=${SVC:-radicle}
# repo name = dir basename; workspace lives at rad-home/repos/<name>, same name in-container.
REPONAME=${REPONAME:-$(basename "$REPO_ROOT")}
WORKSPACE=${WORKSPACE:-$REPO_ROOT/rad-home/repos/$REPONAME}
BRANCH=${BRANCH:-$(git -C "$REPO_ROOT" symbolic-ref --short HEAD)}

log() { printf 'radicle-sync: %s\n' "$1" >&2; }

if [ ! -d "$WORKSPACE/.git" ]; then
    log "workspace $WORKSPACE not found, skipping"
    exit 0
fi

# 1. copy local commits into the workspace clone (host-side, shared filesystem).
#    needs receive.denyCurrentBranch=updateInstead on the workspace (installer sets it).
if ! git -C "$REPO_ROOT" push --no-verify --quiet "$WORKSPACE" "+refs/heads/$BRANCH:refs/heads/$BRANCH"; then
    log "could not update workspace (dirty worktree?), skipping announce"
    exit 0
fi

# 2. announce from inside the container: git-remote-rad needs the node + RAD_HOME,
#    which only exist there. -T = no TTY (hooks are non-interactive).
#    --force: host root is the source of truth; radicle is a downstream mirror,
#    so overwrite any drift on the rad side instead of jamming on non-fast-forward.
if ! docker compose --project-directory "$COMPOSE_DIR" exec -T \
        --workdir "/root/.radicle/repos/$REPONAME" "$SVC" git push --force rad "$BRANCH"; then
    log "rad push failed (node down?); provider push unaffected"
    exit 0
fi

log "mirrored '$BRANCH' to radicle"
