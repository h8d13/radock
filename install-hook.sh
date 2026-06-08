#!/bin/sh
# Install a pre-push hook that mirrors pushes into the radicle docker workspace.
# Run from inside the git repo you want to publish to radicle.
set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
REPONAME=$(basename "$REPO_ROOT")
WORKSPACE="$REPO_ROOT/rad-home/repos/$REPONAME"
SYNC="$REPO_ROOT/radicle-sync.sh"

if [ ! -f "$SYNC" ]; then
    echo "error: $SYNC not found" >&2
    exit 1
fi
chmod +x "$SYNC"

# the workspace is a non-bare clone with the same branch checked out; allow
# pushing into it and let the push update its worktree too.
if [ -d "$WORKSPACE/.git" ]; then
    git -C "$WORKSPACE" config receive.denyCurrentBranch updateInstead
    echo "configured workspace: $WORKSPACE"
else
    echo "warning: $WORKSPACE not found; create it before pushing" >&2
fi

HOOK="$REPO_ROOT/.git/hooks/pre-push"
cat > "$HOOK" <<EOF
#!/bin/sh
# pre-push: also mirror to the radicle docker workspace (best-effort)
exec "$SYNC"
EOF
chmod +x "$HOOK"
echo "installed pre-push hook -> $HOOK"
