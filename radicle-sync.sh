#!/bin/sh
# Mirror the current branch into the radicle docker workspace, then announce it.
# Best-effort by design: every failure path exits 0 so a git pre-push to GitHub
# still proceeds even when the node is down or the workspace is missing.
set -e

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
if ! git -C "$REPO_ROOT" push --quiet "$WORKSPACE" "+refs/heads/$BRANCH:refs/heads/$BRANCH"; then
    log "could not update workspace (dirty worktree?), skipping announce"
    exit 0
fi

# 2. announce from inside the container: git-remote-rad needs the node + RAD_HOME,
#    which only exist there. -T = no TTY (hooks are non-interactive).
if ! docker compose --project-directory "$COMPOSE_DIR" exec -T \
        --workdir "/root/.radicle/repos/$REPONAME" "$SVC" git push rad "$BRANCH"; then
    log "rad push failed (node down?); GitHub push unaffected"
    exit 0
fi

log "mirrored '$BRANCH' to radicle"
