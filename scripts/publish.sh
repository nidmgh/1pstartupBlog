#!/bin/bash
# 1pstartupBlog — Deploy script
#
# Builds the static blog locally and rsyncs ONLY to /var/www/1pstartup-blog/
# on the Lightsail server. Never touches /var/www/1pstartup/ (the main site).
#
# Usage:
#   bash scripts/publish.sh                              # dry run (shows what would change)
#   bash scripts/publish.sh deploy                       # FULL sync — pushes every published post
#                                                          and removes anything on server not in build (--delete).
#                                                          Use only for site-wide changes (CSS, template, etc.).
#   bash scripts/publish.sh deploy <slug> [<slug>...]    # SCOPED sync — pushes ONLY the named posts
#                                                          (EN+ZH) plus index pages and assets. No --delete.
#                                                          Default mode for publishing or updating individual posts.
#   bash scripts/publish.sh deploy <args> --allow-dirty  # override preflight (also works with no slugs)
#
# Posts only build if frontmatter has `published: true`. Drafts are invisible.
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
  # Parse remaining args: slugs (positional) vs --allow-dirty flag.
  ALLOW_DIRTY=0
  SLUGS=()
  shift  # drop "deploy"
  for arg in "$@"; do
    if [ "$arg" = "--allow-dirty" ]; then
      ALLOW_DIRTY=1
    else
      SLUGS+=("$arg")
    fi
  done

  # Preflight: refuse to deploy from dirty or unpushed working tree.
  # Why: rsync overwrites the server. Deploying uncommitted work means
  # live has content that only exists on this laptop — if anything
  # overwrites it later, the only version is gone. (We hit this on 2026-04-17.)
  # Escape hatch: --allow-dirty
  if [ "$ALLOW_DIRTY" = "0" ]; then
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

  if [ "${#SLUGS[@]}" -eq 0 ]; then
    # ── Full sync (no slugs given) ──────────────────────────────────────────
    echo "→ FULL sync to server (rsync --delete — anything on server not in build will be removed):"
    rsync -az --delete \
      -e "ssh -i $PEM" \
      "$LOCAL_DIR" "$HOST:$REMOTE_DIR/"
  else
    # ── Scoped sync (only named slugs + indexes + assets) ──────────────────
    echo "→ SCOPED sync to server (no --delete) — pushing slugs:"
    for s in "${SLUGS[@]}"; do echo "    • $s"; done
    echo ""

    # Verify each slug actually built (catches typos and missing `published: true`).
    for s in "${SLUGS[@]}"; do
      if [ ! -d "${LOCAL_DIR}en/$s" ] && [ ! -d "${LOCAL_DIR}zh/$s" ]; then
        echo "  ✗ Slug '$s' did not build in either /en or /zh."
        echo "    Check the slug spelling and that frontmatter has 'published: true'."
        exit 1
      fi
    done

    # Push each slug's EN + ZH directory (whichever exists).
    for s in "${SLUGS[@]}"; do
      for lang in en zh; do
        if [ -d "${LOCAL_DIR}${lang}/$s" ]; then
          rsync -az -e "ssh -i $PEM" \
            "${LOCAL_DIR}${lang}/$s/" \
            "$HOST:$REMOTE_DIR/${lang}/$s/"
        fi
      done
    done

    # Always refresh index pages (they list posts) and assets (for new images).
    rsync -az -e "ssh -i $PEM" "${LOCAL_DIR}en/index.html" "$HOST:$REMOTE_DIR/en/index.html"
    rsync -az -e "ssh -i $PEM" "${LOCAL_DIR}zh/index.html" "$HOST:$REMOTE_DIR/zh/index.html"
    rsync -az -e "ssh -i $PEM" "${LOCAL_DIR}index.html"    "$HOST:$REMOTE_DIR/index.html"
    rsync -az -e "ssh -i $PEM" "${LOCAL_DIR}assets/"       "$HOST:$REMOTE_DIR/assets/"
  fi

  ssh -i "$PEM" "$HOST" "find $REMOTE_DIR -type f | xargs chmod 644 && find $REMOTE_DIR -type d | xargs chmod 755"
  echo "  Sync complete."
  echo ""
  echo "=== Deploy complete. Blog live at https://1pstartup.com/blog ==="
  exit 0
fi

echo "Usage: bash scripts/publish.sh [dryrun|deploy [slug...] [--allow-dirty]|setup]"
exit 1
