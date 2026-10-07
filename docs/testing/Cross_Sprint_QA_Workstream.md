# Cross-Sprint QA Workstream

This is the release QA record for every sprint. It complements feature tests;
it does not replace physical-device sign-off. Do not record a manual scenario
as passed without a build identifier, tester, date, and device entry.

## Required automated gate

Run before merging a sprint and attach the output to the change record:

```sh
flutter analyze
flutter test
flutter build ios --debug --no-codesign
flutter build apk --debug
```

`flutter test` includes database migration/recovery, encrypted file integrity,
backup/restore, search, reminders, lifecycle, sharing, cloud/offline, OCR and
emergency-pack regressions. The `cross_sprint_qa_test.dart` guard verifies:

- English/light and বাংলা/dark application startup;
- direct navigation remains protected while locked (router regression tests);
- startup/recovery maintenance and process-interruption cases remain covered;
- sensitive field sanitization; and
- no production `print` or `debugPrint` calls outside `SecureLogger`.

Android build failures caused by a dependency/toolchain issue are release
blockers, not a passing substitute for this gate. Record the exact plugin and
error in the sprint evidence.

## Every-sprint checklist

| Check | Automated evidence | Manual sign-off requirement |
| --- | --- | --- |
| Regression | `flutter analyze`, `flutter test` | Exercise affected user flow on every required device tier. |
| English / বাংলা | locale + widget smoke tests | Check truncation, Bengali shaping, mixed text and Bengali numerals on affected screens. |
| Light / dark / system | theme smoke tests | Check contrast, icons, error states and keyboard surfaces. |
| Offline | repository/service tests including cloud explicit-offline failures | Disable data/Wi-Fi; core vault, import, viewing and local reminders remain functional. |
| Lock / unlock | router + security manager tests | Lock during the affected feature; ensure no sensitive screen, thumbnail, search cache, or temporary plaintext remains. |
| Process restart | journal, restore, cleanup and maintenance tests | Kill/force-stop at each affected file/database boundary, reopen, unlock and verify reconciliation. |
| Sensitive logging | logger sanitization + source guard | Review device logs while exercising the feature; no PIN, token, title, document number, filename, path, OCR or content. |

## Physical-device matrix

Maintain at least these named test slots. Replace the examples with the actual
model, OS build, app build, tester, date, and pass/fail evidence for each
release candidate.

| Slot | Representative device | Required scenarios |
| --- | --- | --- |
| Android low/mid | 3–4 GB RAM Android device, oldest supported API | cold launch, unlock, capture/import, multi-page scan, scroll, low storage, force-stop recovery |
| Android current | current supported Pixel/Samsung API | camera permission, biometric, notifications, document provider, backup/export, offline and process death |
| iPhone current | current supported iPhone/iOS | camera/photos/files, Face ID/Touch ID, share sheet, background transition, memory pressure, restore |
| iPhone older | oldest supported iPhone/iOS practical for release | launch/unlock, large image/PDF, dynamic type, বাংলা rendering, background/termination recovery |

## Evidence template

Copy this for each sprint/release candidate:

```text
Build / commit:
Date / tester:
flutter analyze:
flutter test:
iOS debug build:
Android debug build:

Device slot / model / OS:
English + বাংলা:
Light + dark + system:
Offline:
Lock/unlock:
Process restart boundary:
Sensitive log review:
Result / linked issue:
```

Never add production documents, PINs, passwords, tokens, screenshots with
visible document data, filenames, or device logs containing sensitive content
to QA evidence.
