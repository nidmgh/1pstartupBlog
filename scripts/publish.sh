#!/bin/bash
# 1pstartupBlog — Deploy script
#
# Builds the static blog locally and rsyncs ONLY to /var/www/1pstartup-blog/
# on the Lightsail server. Never touches /var/www/1pstartup/ (the main site).
#
# Usage:
#   bash scripts/publish.sh           # dry run (shows what would change)
#   bash scripts/publish.sh deploy    # real deploy
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
