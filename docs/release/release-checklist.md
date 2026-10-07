# Release checklist

## Automated gate

- [ ] `dart format --output=none --set-exit-if-changed lib test`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] Android debug/release-candidate build succeeds.
- [ ] iOS debug/release-candidate build succeeds.

## Product and privacy

- [ ] Full English/বাংলা, light/dark, text-scale, TalkBack/VoiceOver, and
  low/mid Android plus supported iPhone matrix is recorded.
- [ ] Offline vault, lock/unlock, notifications, import, viewer, backup,
  restore, migration, and force-stop recovery scenarios pass.
- [ ] Security, database, localization, and accessibility PR checklists have
  evidence; no sensitive data appears in logs, screenshots, or QA records.
- [ ] Backup creation is verified; restore into a clean device/profile and
  rollback/interruption tests pass.
- [ ] Version numbers, release notes, licences, privacy explanation, and
  known limitations are reviewed.

## Sign-off

Record build/commit, date, tester, devices/OS versions, manual evidence, open
risks, and release owner. Any missing security, recovery, or backup/restore
evidence blocks release.

