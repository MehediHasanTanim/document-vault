# Cross-Sprint Localization Workstream

All user-facing product copy is resolved from generated ARB localization keys.
The supported product locales are English (`en`) and বাংলা (`bn`). A widget
must resolve copy at build time through `AppLocalizations` (normally
`context.l10n`); do not concatenate bilingual literals such as
`'Save / সংরক্ষণ করুন'`, select copy from `Locale` manually, or hardcode a
visible English fallback.

## Required change sequence

For every new or changed visible string:

1. add a semantic camelCase key to `lib/l10n/app_en.arb` and its natural
   বাংলা equivalent to `lib/l10n/app_bn.arb`;
2. add ARB metadata for placeholders, plurals, or select values when needed;
3. regenerate `AppLocalizations` with `flutter gen-l10n` rather than editing
   generated Dart files by hand;
4. use the generated key in the widget, tooltip, semantic label, dialog,
   empty/error/loading state, and notification permission explanation; and
5. test English and বাংলা with text scaling, mixed-language document data,
   and the target platform's accessibility reader.

Domain data supplied by the user (for example a document title, name, tag, or
physical location) is not translated. Format it into localized surrounding
copy without logging or exposing hidden data.

## Approved terminology

Use these terms consistently. Prefer natural Bangla over word-for-word
translation; retain a familiar acronym such as PIN, PDF, NID, or TIN where it
is clearer to Bangladeshi users.

| English | বাংলা |
| --- | --- |
| Documents | ডকুমেন্ট |
| Family | পরিবার |
| Backup | ব্যাকআপ |
| Restore | পুনরুদ্ধার |
| Expiring soon | শিগগির মেয়াদ শেষ হবে |
| Reminder | রিমাইন্ডার |
| Scan | স্ক্যান |
| Archive | আর্কাইভ |
| Trash | ট্র্যাশ |
| Settings | সেটিংস |
| Privacy | গোপনীয়তা |
| Physical location | আসল নথির স্থান |

## Review rules

- Never mix both locales in one visible label merely to simulate localization.
- Keep labels short enough for the smallest supported screen at large text.
  Prefer a natural shorter Bangla phrase over an awkward literal translation.
- Localize plural and parameterized copy with ICU/ARB rather than string
  interpolation that assumes English word order.
- Localize dates and numerals according to the user's selected locale where
  product requirements call for them; preserve user-entered document values.
- Treat screen-reader labels, validation, error, destructive-confirmation,
  permission, backup/restore, and notification-settings copy as user-facing
  strings too.

## Automated safeguards

`test/app/localization_workstream_test.dart` verifies English/Bangla ARB key
parity, canonical terminology, the localization PR checklist, and that the
shared navigation/onboarding/lock shell has no direct `Text('...')` literals.
It complements visual Bengali QA; it cannot prove translation quality or
platform rendering by itself.
