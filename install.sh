#!/usr/bin/env bash
# Next Move Theory — canon + skills installer (macOS / Linux / Bash).
# Windows users: run install.ps1 instead.
#
# Installs INTO the root of your existing project (the folder you run your agent from):
#   <target>/Next-Move-Theory-Canon/        the canon (keep this exact name)
#   <target>/.claude/skills/<skill>/        skills for Claude Code   (invoke with /nmt-…)
#   <target>/.agents/skills/<skill>/        skills for Codex         (invoke with $nmt-…)
#   <target>/CLAUDE.md, AGENTS.md           rules injected between markers (your file kept)
#   <target>/NextMoveTheory-README.md       this repo's README, renamed
#
# The skill sources live in this repo under Skills/claude/ and
# Skills/codex/ — the Claude copy is installed verbatim; the Codex copy is
# a separately-maintained, Codex-compatible variant (no AskUserQuestion /
# subagent_type / run_in_background; $skill invocation; ≤1024-char descriptions).
#
# It NEVER leaves a top-level Skills/ folder in your project and NEVER
# nests `.claude`/`.agents`/canon inside one another. Re-running is idempotent: it
# replaces the canon, the skills, the marked rules block, and the README in place.
# It does NOT delete unrelated skills already in .claude/skills or .agents/skills.
# The one exception is our own renamed skill: an old `nmt-upgrade/` folder is
# removed and replaced by `nmt-update/`.
#
# Usage:
#   # A) one-liner — fresh install into the CURRENT directory (your project root):
#   curl -fsSL https://raw.githubusercontent.com/zamesin/Next-Move-Theory-Canon-and-Skills/main/install.sh | bash
#
#   # B) from a clone of this repo — installs into the PARENT dir by default
#   #    (so the skills land in your project, not inside the clone). After a
#   #    successful install it REMOVES the clone folder, so
#   #    `git clone … && bash …/install.sh --target .` leaves nothing behind.
#   bash install.sh                 # target = parent of the clone
#   bash install.sh --target DIR    # or an explicit target project root
#   bash install.sh --target .      # or install in place (current dir)
#   bash install.sh --keep-clone    # keep the clone folder after installing
set -euo pipefail

REPO_URL="https://github.com/zamesin/Next-Move-Theory-Canon-and-Skills.git"

TARGET=""
KEEP_CLONE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --target) TARGET="${2:?--target needs a directory}"; shift 2 ;;
    --keep-clone) KEEP_CLONE=1; shift ;;
    -h|--help) sed -n '2,33p' "$0" 2>/dev/null || true; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

# Resolve SRC (where the repo content is) and whether we must clone it.
SELF="${BASH_SOURCE[0]:-}"
CLEANUP_SRC=0
if [ -n "$SELF" ] && [ -f "$SELF" ] && [ -d "$(cd "$(dirname "$SELF")" && pwd)/Skills" ]; then
  # Running from inside a clone of this repo.
  SRC="$(cd "$(dirname "$SELF")" && pwd)"
  # Default target = the clone's PARENT, so skills don't get installed inside the clone.
  [ -z "$TARGET" ] && TARGET="$(dirname "$SRC")"
else
  # Running via `curl | bash` (no repo on disk) — clone to a temp dir.
  command -v git >/dev/null 2>&1 || { echo "git is required" >&2; exit 1; }
  SRC="$(mktemp -d)"
  CLEANUP_SRC=1
  echo "Cloning $REPO_URL ..."
  git clone --depth 1 "$REPO_URL" "$SRC" >/dev/null 2>&1
  # Default target = current directory (your project root).
  [ -z "$TARGET" ] && TARGET="$(pwd)"
fi

# Sanity: SRC must look like this repo.
[ -d "$SRC/Skills" ] && [ -d "$SRC/Next-Move-Theory-Canon" ] || {
  echo "ERROR: source at $SRC does not look like the canon repo (missing Skills/ or Next-Move-Theory-Canon/)." >&2
  exit 1
}
TARGET="$(cd "$TARGET" 2>/dev/null && pwd || { echo "ERROR: target dir not found: $TARGET" >&2; exit 1; })"

# Guard: never install into the clone itself (would create nested loops).
if [ "$TARGET" = "$SRC" ]; then
  echo "ERROR: target equals the repo clone ($SRC)." >&2
  echo "Run from your PROJECT ROOT, or pass --target <your-project-root>." >&2
  exit 1
fi

echo "Installing Next Move Theory canon + skills"
echo "  source: $SRC"
echo "  target: $TARGET"

mkdir -p "$TARGET/.claude/skills" "$TARGET/.agents/skills"

# 1. Canon at the root (keep the exact name — skills read it by this relative path).
rm -rf "$TARGET/Next-Move-Theory-Canon"
cp -r "$SRC/Next-Move-Theory-Canon" "$TARGET/Next-Move-Theory-Canon"

# 2. Skills — the Claude copy to .claude/skills, the Codex copy to .agents/skills.
#    Copied in place (existing unrelated skills in those dirs are left untouched).
#    First drop our own renamed skill: nmt-upgrade became nmt-update. Only this
#    one folder is ever removed; nothing else in those dirs is touched.
rm -rf "$TARGET/.claude/skills/nmt-upgrade" "$TARGET/.agents/skills/nmt-upgrade"
cp -r "$SRC"/Skills/claude/. "$TARGET/.claude/skills/"
cp -r "$SRC"/Skills/codex/.  "$TARGET/.agents/skills/"

# 3. README, renamed (so it doesn't clobber your project's own README).
cp "$SRC/README.md" "$TARGET/NextMoveTheory-README.md"

# 3b. Record the installed version (top entry of the changelog) so the skills'
#     end-of-run update check can compare it against the changelog in the public
#     GitHub repo. Best-effort — never fail the install over this.
if [ -f "$SRC/CHANGELOG.md" ]; then
  # First heading whose title starts with a digit = the latest release version
  # (skips prose headings like "## Versioning").
  VER="$(grep -m1 -E '^##[[:space:]]+[0-9]' "$SRC/CHANGELOG.md" | sed -E 's/^##[[:space:]]+([^[:space:]]+).*/\1/')"
  if [ -n "$VER" ]; then
    cat > "$TARGET/.nmt-version" <<NMTV
# Next Move Theory — installed version. Please keep this file.
# It records which version of the canon + skills you have installed. At the end
# of a run, the skills read it to check whether a newer version is out and let
# you know (see "Updates & telemetry" in NextMoveTheory-README.md).
# Safe to keep, not safe to lose: delete it and update notices simply stop —
# nothing breaks, but you can silently fall behind on new canon + skills.
# It's only a few bytes. Refresh everything (including this file) with /nmt-update, or:
#   curl -fsSL https://raw.githubusercontent.com/zamesin/Next-Move-Theory-Canon-and-Skills/main/install.sh | bash
# The line below is the installed version — don't edit it.
$VER
NMTV
  fi
fi

# 4. Inject a short pointer block between the markers into CLAUDE.md and AGENTS.md.
#    Creates the file if absent. If the markers are already there, ONLY the text
#    between them is replaced — everything outside the markers (including your own
#    rules, and the long block older versions of this installer wrote) is kept
#    byte-for-byte. The block stays deliberately tiny: it points at the canon and
#    the README instead of duplicating them in every project's rules file.
python3 - "$TARGET" <<'PY'
import sys, pathlib
target = pathlib.Path(sys.argv[1])
S, E = "<!-- Next-Move-Theory-Rules:start -->", "<!-- Next-Move-Theory-Rules:end -->"
RULES = """Next Move Theory (NMT) skills are installed in this project.

- Methodology source of truth: ./Next-Move-Theory-Canon/ — for product/strategy work always prefer it over generic Jobs To Be Done knowledge (the definitions differ substantially).
- New here? Start with /nmt-chat — it routes you to the right skill.
- Skill outputs go to Skills-Results/ (path configurable per run).
- Full guide + updates & telemetry policy: ./NextMoveTheory-README.md"""
block = f"{S}\n{RULES}\n{E}\n"
for name in ("CLAUDE.md", "AGENTS.md"):
    t = target / name
    cur = t.read_text() if t.exists() else ""
    if S in cur and E in cur:
        pre, rest = cur.split(S, 1)
        _, post = rest.split(E, 1)
        cur = pre + block.rstrip("\n") + post
    else:
        cur = (cur.rstrip() + "\n\n" if cur.strip() else "") + block
    t.write_text(cur)
    print("  injected rules ->", t)
PY

[ "$CLEANUP_SRC" = "1" ] && rm -rf "$SRC"

echo ""
cat <<'EOF'
============================================================================
  Next Move Theory is installed.   Free and open-source.
============================================================================

  >>  Start with   /nmt-chat   (Claude Code)   or   $nmt-chat   (Codex)
      — it routes you to the right skill.

      Paste whatever you have — a rough idea, messy notes, a chat thread, a
      doc — and it pulls out the context and tells you your next move. No
      methodologically-perfect brief required.

  --------------------------------------------------------------------------
  Where each starting point leads   (Claude Code: /name   ·   Codex: $name)

    new idea            ->  /nmt-chat  ->  /nmt-market-research
                        ->  /nmt-craft-value-proposition
                        ->  /nmt-product-requirements
                        ->  /nmt-craft-go-to-market
    live product        ->  /nmt-diagnose
    interviews on disk  ->  /nmt-analyze-interviews
    update everything   ->  /nmt-update

  Jump in wherever you already are — each skill takes what you hand it, or
  routes you back to the step it needs first.
  --------------------------------------------------------------------------
EOF
echo ""
echo "  Installed into: $TARGET"
echo "    Claude skills:  $TARGET/.claude/skills/   (invoke with /nmt-…)"
echo "    Codex skills:   $TARGET/.agents/skills/   (invoke with \$nmt-…)"
echo "    canon:          $TARGET/Next-Move-Theory-Canon/"
echo "    readme:         $TARGET/NextMoveTheory-README.md"
echo ""
cat <<'EOF'
  Codex tip — to let skills ask structured questions outside Plan mode, add
  to ~/.codex/config.toml:
      [features]
      default_mode_request_user_input = true

  Updates & telemetry — skills check for a newer version at the END of a run.
  The request sends ONLY the skill name and the installed version; no project
  content and no personal data. Downloads always come from GitHub.
  Disable: add   update-check: off   to .nmt-config in your project root.
  Details: ./NextMoveTheory-README.md (section "Updates & telemetry").

  Update anytime — safe & idempotent (refreshes canon, skills, and rules in
  place; leaves your own files untouched). Run /nmt-update, or:
      curl -fsSL https://raw.githubusercontent.com/zamesin/Next-Move-Theory-Canon-and-Skills/main/install.sh | bash

  Free & open:   https://github.com/zamesin/Next-Move-Theory-Canon-and-Skills
  New releases:  subscribe at https://nextmovetheory.com
EOF

# Auto-remove the clone when we installed from one sitting directly inside the
# target (the `git clone … && bash …/install.sh --target .` flow), so the command
# leaves no leftover repo folder. Opt out with --keep-clone. (The curl|bash path
# already cleaned its temp clone above.) cd to the target first so we never delete
# the shell's working directory.
if [ "${CLEANUP_SRC}" = "0" ] && [ "$(dirname "$SRC")" = "$TARGET" ]; then
  if [ "${KEEP_CLONE}" = "1" ]; then
    echo "Clone kept at $SRC (remove it with: rm -rf \"$SRC\")."
  else
    cd "$TARGET" 2>/dev/null || cd /
    rm -rf "$SRC"
    echo "Removed the clone folder: $SRC"
  fi
fi
