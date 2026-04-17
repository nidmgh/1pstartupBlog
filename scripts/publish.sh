#!/bin/bash
# 1pstartupBlog — Deploy script
#
# Builds the static blog locally and rsyncs ONLY to /var/www/1pstartup-blog/
# on the Lightsail server. Never touches /var/www/1pstartup/ (the main site).
#
# Usage:
#   bash scripts/publish.sh                    # dry run (shows what would change)
#   bash scripts/publish.sh deploy             # real deploy (requires clean + pushed)
#   bash scripts/publish.sh deploy --allow-dirty  # override preflight
#
# First-time server setup (run once):
#   bash scripts/publish.sh setup
set -e

HOST="ubuntu@54.202.58.132"
PEM="$HOME/work/pem/LightsailDefaultKey-us-west-2.pem"
REMOTE_DIR="/var/www/1pstartup-blog"   # ← blog only, never touches /var/www/1pstartup
LOCAL_DIR="$(cd "$(dirname "$0")/.." && pwd)/public/blog/"

ACTION=${1:-dryrun}

echo "=== 1pstartupBlog publish (action: $ACTION) ==="
echo "    local  → $LOCAL_DIR"
echo "    remote → $HOST:$REMOTE_DIR"
echo ""

# ── 1. Build ──────────────────────────────────────────────────────────────────
echo "→ Building blog..."
node "$(dirname "$0")/build.js"
echo "  Build complete."
echo ""

# ── 2. Dry run (default) ──────────────────────────────────────────────────────
if [ "$ACTION" = "dryrun" ]; then
  echo "→ Dry run — showing changes (no files written to server):"
  rsync -az --delete --dry-run \
    -e "ssh -i $PEM" \
    "$LOCAL_DIR" "$HOST:$REMOTE_DIR/"
  echo ""
  echo "Run 'bash scripts/publish.sh deploy' to apply."
  exit 0
fi

# ── 3. First-time setup ───────────────────────────────────────────────────────
if [ "$ACTION" = "setup" ]; then
  echo "→ Creating $REMOTE_DIR on server..."
  ssh -i "$PEM" "$HOST" "sudo mkdir -p $REMOTE_DIR && sudo chown ubuntu:ubuntu $REMOTE_DIR"
  echo "  Directory ready."
  echo ""
  echo "→ Deploying nginx config from 1pstartup project..."
  NGINX_CONF="$(cd "$(dirname "$0")/../.." && pwd)/1pstartup/nginx/1pstartup.conf"
  if [ -f "$NGINX_CONF" ]; then
    scp -i "$PEM" "$NGINX_CONF" "$HOST:/tmp/1pstartup.conf"
    ssh -i "$PEM" "$HOST" "sudo cp /tmp/1pstartup.conf /etc/nginx/sites-available/1pstartup && sudo nginx -t && sudo systemctl reload nginx"
    echo "  Nginx updated and reloaded."
  else
    echo "  WARNING: nginx config not found at $NGINX_CONF — update manually."
  fi
  echo ""
  echo "→ Running initial file sync..."
  rsync -az --delete \
    -e "ssh -i $PEM" \
    "$LOCAL_DIR" "$HOST:$REMOTE_DIR/"
  echo ""
  echo "=== Setup complete. Blog live at https://1pstartup.com/blog ==="
  exit 0
fi

# ── 4. Deploy ─────────────────────────────────────────────────────────────────
if [ "$ACTION" = "deploy" ]; then
  # Preflight: refuse to deploy from dirty or unpushed working tree.
  # Why: rsync --delete overwrites the server. Deploying uncommitted work
  # means live has content that only exists on this laptop — if anything
  # overwrites it later, the only version is gone. (We hit this on 2026-04-17.)
  # Escape hatch: bash scripts/publish.sh deploy --allow-dirty
  if [ "$2" != "--allow-dirty" ]; then
    echo "→ Preflight: checking git state..."
    if [ -n "$(git status --porcelain)" ]; then
      echo ""
      echo "  ✗ Working tree has uncommitted changes:"
      git status --short | sed 's/^/    /'
      echo ""
      echo "  Commit them first, or re-run with --allow-dirty to override."
      exit 1
    fi
    git fetch origin main --quiet
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse origin/main)
    if [ "$LOCAL" != "$REMOTE" ]; then
      BASE=$(git merge-base HEAD origin/main)
      echo ""
      if [ "$LOCAL" = "$BASE" ]; then
        echo "  ✗ Local branch is behind origin/main. Pull first."
      else
        echo "  ✗ Local has commits not pushed to GitHub:"
        git log --oneline origin/main..HEAD | sed 's/^/    /'
        echo ""
        echo "  Push with: git push origin main"
      fi
      echo "  (or re-run with --allow-dirty to override)"
      exit 1
    fi
    echo "  ✓ Clean working tree, in sync with origin/main."
    echo ""
  fi

  echo "→ Syncing to server (only /var/www/1pstartup-blog — main site untouched)..."
  rsync -az --delete \
    -e "ssh -i $PEM" \
    "$LOCAL_DIR" "$HOST:$REMOTE_DIR/"
  ssh -i "$PEM" "$HOST" "find $REMOTE_DIR -type f | xargs chmod 644 && find $REMOTE_DIR -type d | xargs chmod 755"
  echo "  Sync complete."
  echo ""
  echo "=== Deploy complete. Blog live at https://1pstartup.com/blog ==="
  exit 0
fi

echo "Usage: bash scripts/publish.sh [dryrun|deploy|setup]"
exit 1
