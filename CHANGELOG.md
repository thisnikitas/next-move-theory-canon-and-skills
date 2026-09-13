# Next Move Theory — Changelog

What changed in the Next Move Theory canon + skills. Newest release is at the top.

Each entry's **Summary** line is what the installed skills show you when a newer
version is available. To update to the latest at any time, run from your project
root:

```bash
curl -fsSL https://raw.githubusercontent.com/zamesin/Next-Move-Theory-Canon-and-Skills/main/install.sh | bash
```

or use the `/nmt-update` skill (Codex: `$nmt-update`). Windows (PowerShell):
`irm https://raw.githubusercontent.com/zamesin/Next-Move-Theory-Canon-and-Skills/main/install.ps1 | iex`.

## Versioning

One version covers the whole bundle (canon + skills), tracking **Next Move
Theory** as SemVer `MAJOR.MINOR.PATCH`:

- **MAJOR** — a major version of the Next Move Theory methodology.
- **MINOR** — a significant methodology update (new or reworked theses).
- **PATCH** — small skill updates and methodology patches.

The current version is the top entry below. The installer records it in
`.nmt-version`; at the end of a run each skill checks whether a newer version is
published and tells you what changed since yours. The check sends only the skill
name and the installed version, and it is opt-out — see *Updates & telemetry* in
the README. Updates themselves always download from the public GitHub repo. (The
README also shows the methodology maturity badges — Advanced JTBD `v3.4 · stable`
and Next Move Theory `v0.6 · in active development`.)

---

## 0.6.18 — Transparent updates, GitHub-based installs, and an anti-hallucination pack
**Summary:** Update checks are now transparent and one-line opt-out, updates download from GitHub, `/nmt-upgrade` became `/nmt-update`, the rules block injected into your CLAUDE.md shrank to five lines, and the producer skills got a hard anti-hallucination pack — frequency counts, claim statuses, segmentation guards, and honesty about thin input.
**Released:** 2026-09-13

- **Transparent, opt-out update checks.** The check runs at the end of a run, announces itself in one line the first time, and sends only the skill name and the installed version. Turn it off with `update-check: off` in `.nmt-config`, or `DO_NOT_TRACK=1`, or `NMT_NO_UPDATE_CHECK=1`. The new *Updates & telemetry* section of the README states exactly what is and isn't collected.
- **Updates come from GitHub.** The installer, the one-liners, and the version lookup all read the public repo (`zamesin/Next-Move-Theory-Canon-and-Skills`) directly — no site round-trip in the update path.
- **`nmt-upgrade` is now `nmt-update`** (`/nmt-update`, Codex `$nmt-update`). The installer removes the old skill folder and installs the new one, so you won't end up with both.
- **A much smaller footprint in your rules file.** The block injected between the `Next-Move-Theory-Rules` markers in `CLAUDE.md` / `AGENTS.md` is five lines: where the canon is, start with `/nmt-chat`, where outputs go, where the full guide is. Your own content outside the markers is untouched, as before.
- **Anti-hallucination pack in the producer skills.** Every aggregated claim now carries a frequency count and its source references, and a single-source claim can no longer become a segment-level conclusion — it goes to a *Single signals* list. Every claim is tagged as backed by a quote, derived from the data, or the model's own hypothesis; numbers a respondent said out loud are labelled as that person's opinion, not market fact; ideas the model invented live only in *Hypotheses to validate*. Segmentation runs through an explicit guard list: purchase channel is not a segment, industry is not a segment when the Core Jobs and success criteria coincide, and every segment is defined through Core Jobs + success criteria. Interview analysis ships a source-to-segment appendix so every "16 deals in this segment" total can be re-checked line by line.
- **Honesty scaled to your input.** With thin input the report says so in the header, gives ranges instead of point numbers, and lists the top three inputs that would most improve the answer.
- **Market and language are asked up front.** Examples, channels, price anchors, competitors, and tone all come from your market — no silent US or Russian default.
- **Repo context is read only with permission.** The skills list the context files they found in your folder and ask before opening them, with a plain notice that the content is processed locally and sent nowhere.
- **Plain tooltips in HTML output.** Every abbreviation and methodology term is explained on first use, in words that assume no methodology knowledge.

## 0.6.17 — Plain-language skills + a clearer first run
**Summary:** Skills now lead in plain words (methodology terms in parentheses), point you to /nmt-chat when you're unsure where to start, ask "quick vs thorough" up front, and keep answers shorter. No methodology change.
**Released:** 2026-06-24

- Plain-first wording across every skill: an everyday explanation leads, the methodology term follows in parentheses — or is used directly for common words like *segment*, *Aha moment*, and *problem*. All glosses were re-verified against the canon.
- Every skill now opens with a "New here? Start here" pointer to `/nmt-chat`, so you always know which skill to run first.
- The producer skills ask how deep to go up front — a few key questions for a fast pass, or the full interview for the highest-confidence result.
- Shorter by default: the one-page answer leads; the deeper work is opt-in, not a wall.
- `nmt-craft-value-proposition` and `nmt-product-requirements` no longer ask you to write a Job in formal notation — describe it in plain words and the skill structures it for you.
- The post-install message now points you straight to `/nmt-chat` and maps every skill.

## 0.6.16 — Faster launch-time update check
**Summary:** The skills' update check now runs inline instead of reading a separate file, so skills start a touch faster. No change to what the check does.
**Released:** 2026-06-22

- Inlined the update check into each skill's body — removed the separate `VERSION-CHECK.md` read on launch; behaviour unchanged (best-effort, ≤2s, never blocks).
- Trimmed the Codex skill descriptions to sit well under the platform's description-length limit.

## 0.6.15 — Auto-update checks + one-command upgrade
**Summary:** Skills now check on launch whether a newer version is available and show what changed since yours. Added the `/nmt-upgrade` one-command updater (Codex: `$nmt-upgrade`).
**Released:** 2026-06-22

- New `nmt-upgrade` skill — re-runs the official installer to pull the latest canon + skills from the public repo, in place and idempotently.
- Every skill now runs a lightweight, best-effort version check on launch (≤2s, silent on failure, never blocks): if your installed version is behind, it tells you the gap and the main changes per version, then how to update.
- The installer now records the installed version in `.nmt-version` so the check can compare it against this changelog.

## 0.6.14 — nmt- prefix, Claude/Codex split, Windows installer
**Summary:** All skills moved to the `nmt-` prefix with separate Claude (`/nmt-…`) and Codex (`$nmt-…`) variants, and a Windows PowerShell installer was added.
**Released:** 2026-06-22

- Skills republished as two agent variants under `Skills/{claude,codex}`: seven `nmt-`prefixed skills (`nmt-chat`, `nmt-diagnose`, `nmt-market-research`, `nmt-craft-value-proposition`, `nmt-product-requirements`, `nmt-craft-go-to-market`, `nmt-analyze-interviews`).
- Claude uses `/nmt-…` and installs to `.claude/skills`; Codex uses `$nmt-…` and installs to `.agents/skills`.
- Added `install.ps1` (Windows PowerShell) and `nmt-chat` zero-state onboarding (paste what you have → next move).

## 0.6.13 — One-command installer + the diagnose skill
**Summary:** Added the one-command `curl … | bash` installer and a new `nmt-diagnose` front-door skill, alongside shared producer and readability contracts.
**Released:** 2026-06-20

- One-command installer (`install.sh`) that clones the repo and installs the canon, skills, and rules block into your project root, idempotently.
- New `nmt-diagnose` skill — a conversational front door for live products that surfaces risks, growth points, and risky assumptions, then routes to the right producer skill.
- Producer + readability contracts shared across the producer skills.
