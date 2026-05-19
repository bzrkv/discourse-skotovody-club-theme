# Skotovody Club — Discourse theme

Phase D theme for `club.skotovody.com`. Implements the Claude Design package
(`docs/Club_Skotovody/`) as a proper Discourse theme.

## Status: SCAFFOLDED (not implementation-complete)

This is the **foundation** — design tokens, color schemes, base font loading,
2 simple components (banner + login wall). Full implementation of all 8 custom
components from Phase D spec §1.5 is multi-day work — see TODO section at
bottom of `common/common.scss`.

## What works now

- ✅ Design tokens (oklch palette) injected as CSS custom properties
- ✅ Fraunces + Manrope + JetBrains Mono fonts loaded
- ✅ Light + Dark color schemes registered
- ✅ Light/dark mode token switching via `[data-theme]` attribute
- ✅ Verified-badge classes (admin/expert/farm) — render-ready, no JS yet
- ✅ Login wall component CSS
- ✅ Admin banner component CSS
- ✅ Theme settings exposed (banner toggle, slider config, CTA URLs)

## What still needs to be built (Phase E)

| Component | Effort | Where to start |
|---|---|---|
| `.dc-toplist` — custom Latest list rendering | 1 day | Override `topic-list` template |
| `.dc-cat-grid` — categories with colored left edges | 0.5 day | Override `categories` template |
| `.dc-topic-layout` + `.dc-timeline` — scrubber | 0.5 day | Override `topic-post` template |
| `.dc-composer-dock` — bottom dock styling | 0.5 day | CSS-only override |
| `.dc-sidebar` — left rail | 0.5 day | Override discovery sidebar |
| `.dc-landing` — guest hero | 1 day | New connector in `home-logo-after` outlet |
| `.dc-cat-box[data-locked]` — blur preview | 1 day | JS hook on category renderer + CSS |
| Slider — homepage announcements | 1 day | New Ember component, pulls from `/c/news.json?tag=announcement` |

Reference: full implementation patterns in `docs/Club_Skotovody/club/screens/*.jsx`

## Installation

### As-is (local development / GitHub-not-yet)

1. Zip the `sktvd-club-theme/` directory
2. WP admin → Customize → Themes → Install → Upload Zip
3. Activate

### Production (recommended — via Git URL)

Once pushed to a dedicated GitHub repo `bzrkv/discourse-skotovody-club-theme`:

1. WP admin → Customize → Themes → Install → "From a git repository"
2. URL: `https://github.com/bzrkv/discourse-skotovody-club-theme.git`
3. Activate
4. "Check for updates" periodically auto-pulls

## Configuration

After install, configure in Customize → Themes → Skotovody Club → Settings:

- `enable_guest_landing` — show hero block for non-authenticated users
- `enable_admin_banner` — global announcement banner on top
- `slider_tag` — Discourse tag name for slider source topics
- `pricing_url` — link to /klub/ on skotovody.com
- `verified_badge_*_emoji` — emoji prefixes for badges

## Layered design

This theme is **CSS + JS only** — no server-side Ruby logic. All state about
Club membership lives in WP (subscription + user_meta) and is surfaced to
Discourse via:

1. **`sktvd-auth` Hook #2 — SSO payload** — adds `add_groups=members` /
   `remove_groups=members` based on WP state on every login
2. **`sktvd-club-bridge` Discourse plugin — webhook receiver** — immediate
   group update on subscription state change

This theme **renders** based on user's current group membership (and Discourse's
own permissions enforcement gates the actual access). It does NOT decide who
gets access — that's the WP + bridge plugin's responsibility.
