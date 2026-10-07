# Cross-Sprint Accessibility Workstream

Accessibility is part of feature completion. Every screen must remain usable
with English and বাংলা, system text scaling, TalkBack/VoiceOver, light/dark
themes, and without relying on colour, an icon, or motion as the only signal.

## Required screen review

For each changed screen, verify:

- **Semantics:** controls have concise localized labels, state/value where
  helpful, and no duplicate announcements. Decorative imagery is excluded.
- **Focus:** reading and keyboard focus follow the visual task order. Modal,
  destructive, error, and loading states retain a clear focus entry point.
- **Touch:** controls meet at least 48 dp on Android and 44 pt on iOS. Do not
  shrink hit areas to match a visual icon.
- **Text scaling:** do not clamp `TextScaler` or hardcode a text scale factor.
  Use wrapping, scrolling, and flexible layouts; test the largest supported
  setting with Bengali glyphs and mixed-language document data.
- **Contrast and status:** meet platform contrast guidance in light/dark mode.
  Pair success/warning/error colours with an icon and explicit descriptive
  text; do not convey validity, expiry, archive, trash, or errors by colour
  alone.
- **Errors:** explain the problem, whether user data is safe, and the next
  action. Keep failure copy privacy-safe and announce asynchronous failures
  through a live semantic region.

## Shared defaults

`AppTheme` provides padded material targets, 48dp button/icon-button minimums,
and scalable typography. `VaultEmptyState` provides a semantic summary;
`VaultErrorState` marks failures as live regions so an error is announced with
its title and recovery guidance. The app shell uses a focus traversal group
and an explicitly labelled Scan action.

These defaults do not remove feature responsibility. Custom gesture areas,
charts, viewers, camera controls, drag/reorder handles, and platform pickers
need their own semantic/focus review.

## Manual evidence

Record the device, OS, locale, theme, and text-size setting for affected
screens. Exercise: initial focus, every action, validation failure, loading,
empty/error state, modal confirmation, navigation back, and lock/unlock. Use
synthetic content only; never attach private documents or exposed identifiers
to QA evidence.
