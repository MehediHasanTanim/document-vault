# Document Vault BD --- Detailed UI Specification

**Product:** Document Vault BD\
**Platforms:** Android and iOS\
**Target market:** Bangladesh\
**Languages:** বাংলা and English\
**Core model:** Offline-first, local-only, privacy-first\
**Primary navigation:** Home, Documents, Scan, Reminders, More

------------------------------------------------------------------------

# 1. Purpose

This document defines the detailed mobile UI/UX specification for all
MVP screens of Document Vault BD.

The specification is intended for:

-   Product designers.
-   Flutter developers.
-   QA engineers.
-   Accessibility reviewers.
-   Product owners.

Every screen should be designed for users with different levels of
digital literacy. The interface should prioritize clarity, privacy,
large touch targets, familiar language, and predictable navigation.

------------------------------------------------------------------------

# 2. Design Principles

## 2.1 Privacy First

Sensitive document information must not be unnecessarily exposed.

Rules:

-   Do not display full document numbers in list cards by default.
-   Do not show sensitive content on lock-screen notifications.
-   Hide/obscure vault content in the app switcher.
-   Avoid sensitive filenames.
-   Require deliberate confirmation before export/share.
-   Lock the vault after configured inactivity.

## 2.2 Bangladesh-First

Use categories and terminology familiar to Bangladeshi users.

Examples:

-   NID / জাতীয় পরিচয়পত্র
-   Birth Certificate / জন্ম নিবন্ধন
-   Passport / পাসপোর্ট
-   TIN / টিআইএন
-   Trade Licence / ট্রেড লাইসেন্স
-   Land Documents / জমির কাগজপত্র
-   Khatian / খতিয়ান
-   Mutation / নামজারি

## 2.3 Simple Before Advanced

Primary tasks should require minimal decisions.

Advanced metadata should be progressively disclosed.

## 2.4 Offline Confidence

Users should never feel that internet access is required for ordinary
vault operations.

## 2.5 Explicit Destructive Actions

Archive, delete, restore, overwrite, and permanent-delete actions must
clearly explain their effect.

------------------------------------------------------------------------

# 3. Global Visual System

## 3.1 Layout

Use:

-   Safe-area-aware layout.
-   16--20 px horizontal page padding.
-   8 px spacing grid.
-   Large section separation.
-   Sticky primary action only when useful.

## 3.2 Typography

Suggested hierarchy:

-   Display/hero: 28--32 sp.
-   Screen title: 22--24 sp.
-   Section heading: 18--20 sp.
-   Body: 15--17 sp.
-   Supporting text: 13--14 sp.
-   Caption: 12--13 sp.

Support system text scaling.

## 3.3 Touch Targets

Minimum target:

-   44×44 pt iOS.
-   48×48 dp Android preferred.

## 3.4 Cards

Cards should have:

-   Clear title.
-   Optional subtitle.
-   Optional status.
-   Limited actions.
-   No dense technical metadata.

## 3.5 Status Chips

Common states:

-   Valid / বৈধ
-   Expiring Soon / শিগগির মেয়াদ শেষ
-   Expired / মেয়াদ শেষ
-   Renewal in Progress / নবায়ন চলছে
-   Archived / আর্কাইভ করা
-   Favorite / প্রিয়
-   Backup Needed / ব্যাকআপ প্রয়োজন

Never rely on color alone.

## 3.6 Icons

Use familiar platform-consistent icons for:

-   Home.
-   Folder/document.
-   Camera/scan.
-   Bell/reminder.
-   More/menu.
-   Search.
-   Lock.
-   Favorite.
-   Archive.
-   Trash.
-   Backup.
-   Restore.
-   Share.

Always add semantic labels.

------------------------------------------------------------------------

# 4. Global App Navigation

Bottom navigation:

1.  **Home / হোম**
2.  **Documents / ডকুমেন্ট**
3.  **Scan / স্ক্যান**
4.  **Reminders / রিমাইন্ডার**
5.  **More / আরও**

`Scan` should be visually prominent.

Bottom navigation is hidden on:

-   Splash.
-   Onboarding.
-   Unlock.
-   Full-screen viewer.
-   Camera.
-   Critical backup/restore flows where distraction should be minimized.

------------------------------------------------------------------------

# 5. Screen 1 --- Splash

## Purpose

Initialize the application while avoiding sensitive content exposure.

## Layout

Center:

-   App logo.
-   `Document Vault BD`.
-   Optional Bengali product tagline.

Bottom:

-   Small version text if useful.

## Behavior

Check:

-   First launch.
-   Existing vault.
-   Migration requirement.
-   Secure-storage availability.

Route:

-   First launch → Welcome.
-   Existing vault → Unlock.
-   Migration issue → Recovery state.

Do not display document previews.

------------------------------------------------------------------------

# 6. Screen 2 --- Welcome

## Purpose

Introduce the product.

## Layout

Top:

-   Illustration/icon representing a secure document vault.

Middle:

**Keep your important documents safe and organized**

বাংলা:

**গুরুত্বপূর্ণ কাগজপত্র নিরাপদে গুছিয়ে রাখুন**

Three short benefits:

-   Works offline.
-   Stored on this device.
-   Expiry reminders and encrypted backup.

Bottom:

Primary:

`Get Started / শুরু করুন`

Secondary:

`Change Language / ভাষা পরিবর্তন`

## Important Copy

Explain clearly:

`Document Vault BD does not require an account or application cloud database.`

------------------------------------------------------------------------

# 7. Screen 3 --- Language Selection

## Layout

Title:

`Choose Language / ভাষা নির্বাচন করুন`

Options:

-   বাংলা
-   English

Each option:

-   Large radio/selectable card.
-   Language name in native script.

Primary:

`Continue / চালিয়ে যান`

## Behavior

Language applies immediately after confirmation.

User can change it later.

------------------------------------------------------------------------

# 8. Screen 4 --- Privacy and Local Storage Explanation

## Purpose

Explain the local-only model before vault creation.

## Content

Sections:

### Stored on your device

Documents and vault data are stored locally.

### No app account required

No registration or email is required.

### Backups are your responsibility

Device loss can cause data loss unless an encrypted backup exists.

### Sharing leaves the vault

Files exported/shared may no longer be protected by the vault.

Primary:

`I Understand — Continue`

Secondary:

`Learn More`

Checkbox should not be required unless legal/product requirements demand
explicit consent.

------------------------------------------------------------------------

# 9. Screen 5 --- Create Vault PIN

## Layout

Title:

`Create Vault PIN`

বাংলা:

`ভল্ট পিন তৈরি করুন`

Supporting text:

`Use this PIN to unlock your document vault.`

PIN input:

-   6 digits recommended.
-   Large digit indicators.
-   Numeric keyboard.

Security hint:

`Do not use an easy PIN such as 123456.`

Primary action automatically enables when valid.

## Validation

Reject or warn against:

-   Repeated digits.
-   Simple sequential PIN.
-   Invalid length.

Do not display PIN in logs or analytics.

------------------------------------------------------------------------

# 10. Screen 6 --- Confirm PIN

Title:

`Confirm your PIN`

PIN entry.

On mismatch:

`PINs do not match. Try again.`

বাংলা equivalent required.

Do not clear the original setup state until confirmation succeeds.

------------------------------------------------------------------------

# 11. Screen 7 --- Enable Biometrics

## Layout

Icon:

-   Fingerprint or Face ID depending on device.

Title:

`Unlock faster with biometrics`

Explain:

-   PIN remains available.
-   Biometrics are handled by the device.

Primary:

`Enable Biometrics`

Secondary:

`Not Now`

Handle:

-   Not available.
-   Not enrolled.
-   Permission/system failure.

------------------------------------------------------------------------

# 12. Screen 8 --- Notifications Introduction

## Purpose

Explain why notifications are useful before requesting permission.

Title:

`Never miss an expiry date`

Examples:

-   Passport renewal.
-   Driving licence.
-   Vehicle fitness.
-   Trade licence.

Primary:

`Enable Reminders`

Secondary:

`Not Now`

Only trigger system permission after the user chooses Enable.

------------------------------------------------------------------------

# 13. Screen 9 --- Setup Complete

Illustration/checkmark.

Title:

`Your vault is ready`

Summary:

-   Local storage active.
-   PIN configured.
-   Biometrics status.
-   Reminder status.

Primary:

`Open Vault`

------------------------------------------------------------------------

# 14. Screen 10 --- Vault Unlock

## Layout

Top:

-   App logo.
-   Optional owner avatar.

Middle:

`Unlock Document Vault`

PIN keypad/input.

Biometric action:

`Use Fingerprint / Use Face ID`

Bottom:

`Forgot PIN?`

## Privacy

No document counts, names, thumbnails, expiry alerts, or sensitive
information before unlock.

## Failed Attempts

Show generic:

`Incorrect PIN`

After repeated attempts:

`Too many attempts. Try again shortly.`

Do not reveal security implementation details.

------------------------------------------------------------------------

# 15. Screen 11 --- Forgot PIN / Recovery Explanation

Because there is no server, this screen must not imply email reset.

Explain:

`Document Vault BD cannot reset your vault PIN from a server.`

Available recovery options depend on implemented security architecture:

-   Device-protected recovery if configured.
-   Restore encrypted backup.
-   Reset app and create a new empty vault.

Destructive reset must require strong confirmation.

------------------------------------------------------------------------

# 16. Screen 12 --- Home Dashboard

## App Bar

Left:

-   Greeting or `My Vault`.

Optional profile/household indicator.

Right:

-   Search.
-   Lock.

## Quick Actions

Four compact actions:

-   Scan.
-   Import.
-   Add Document.
-   Backup.

## Expiring Soon

Horizontal/vertical cards:

-   Document type.
-   Owner.
-   Days remaining.
-   Status.

CTA:

`View All`

## Favorites

Show up to 4--6 favorites.

## Family

Profile chips/cards:

-   Self.
-   Spouse.
-   Children.
-   Parents.
-   Household.

## Recent Documents

Show recent safe summaries.

## Backup Health

Examples:

`Last backup: 18 days ago`

or:

`You added 14 documents since your last backup.`

CTA:

`Back Up Now`

## Empty Vault Variant

Hero:

`Your vault is empty`

Supporting text:

`Scan or import your first important document.`

Primary:

`Scan Document`

Secondary:

`Import File`

------------------------------------------------------------------------

# 17. Screen 13 --- Expiring Soon

## App Bar

Title:

`Expiring Soon`

Filter icon.

## Sections

-   Expired.
-   Next 7 days.
-   Next 30 days.
-   Next 90 days.

Card:

-   Document title.
-   Owner.
-   Expiry date.
-   Remaining days.
-   Reminder status.

Tap → Document Details.

------------------------------------------------------------------------

# 18. Screen 14 --- Recent Documents

List recently:

-   Added.
-   Viewed.
-   Modified.

Allow sorting:

-   Recent activity.
-   Recently added.
-   Recently modified.

Do not expose sensitive document numbers.

------------------------------------------------------------------------

# 19. Screen 15 --- Favorites

List favorite documents.

Empty:

`No favorite documents yet.`

Explain:

`Mark frequently used documents as favorites for quick access.`

------------------------------------------------------------------------

# 20. Screen 16 --- All Documents

## App Bar

Title:

`Documents`

Actions:

-   Search.
-   View toggle.
-   More.

## Secondary Controls

-   Filter.
-   Sort.

## List/Grid

Recommended default: list.

Each item:

-   Safe thumbnail/document icon.
-   Title.
-   Owner.
-   Category.
-   Expiry/status.
-   Favorite indicator.

Swipe actions should not be required for important operations.

## Floating/Primary Action

`Add Document`

------------------------------------------------------------------------

# 21. Screen 17 --- Category List

Display system categories:

-   Identity.
-   Tax & Financial.
-   Education.
-   Land & Property.
-   Vehicle.
-   Medical.
-   Marriage & Family.
-   Employment.
-   Business.
-   School & Children.
-   Travel.
-   Warranty & Purchases.
-   Legal.
-   Other.

Each card:

-   Icon.
-   Category.
-   Document count.

Tap → Category Documents.

------------------------------------------------------------------------

# 22. Screen 18 --- Category Documents

App bar:

-   Category icon.
-   Category name.

Controls:

-   Search.
-   Filter.
-   Sort.

List all active documents in category.

If subcategories exist, optionally show subcategory chips.

------------------------------------------------------------------------

# 23. Screen 19 --- Person Documents

Header:

-   Avatar.
-   Person name.
-   Relationship.
-   Document count.

Quick category summary.

List documents owned by the person.

Actions:

-   Filter.
-   Sort.
-   Add Document for this person.

------------------------------------------------------------------------

# 24. Screen 20 --- Search

## Initial State

Search field focused.

Placeholder:

`Search documents`

বাংলা:

`ডকুমেন্ট খুঁজুন`

Optional suggestions:

-   Recent categories.
-   Family members.

Avoid persistent recent search history if privacy settings disable it.

## Results

Group or list by relevance.

Show matched metadata safely.

## Filters

Button opens Search Filters.

## No Results

`No documents found for “...”`

Actions:

-   Clear filters.
-   Change search.
-   Browse categories.

------------------------------------------------------------------------

# 25. Screen 21 --- Filter and Sort

Use bottom sheet or full-screen sheet.

## Filters

-   Owner.
-   Category.
-   Tag.
-   Expiry state.
-   Favorite.
-   Archived.
-   File type.
-   Date range.

Bottom:

-   `Reset`
-   `Apply`

## Sort

Options:

-   Recently added.
-   Recently modified.
-   Title A--Z.
-   Title Z--A.
-   Expiry soonest.
-   Issue date.
-   Owner.
-   Category.

Show active filter count on calling screen.

------------------------------------------------------------------------

# 26. Screen 22 --- Document Details

## App Bar

Back.

Title or category.

Actions:

-   Favorite.
-   More.

## Hero Preview

Safe preview of first page.

Tap → Viewer.

## Primary Information

-   Title.
-   Owner(s).
-   Category.
-   Status.

## Important Dates

-   Issue date.
-   Expiry date.
-   Days remaining.

## Document Information

-   Document number, masked by default where appropriate.
-   Issuing authority.
-   Custom fields.

Add reveal/copy only when useful.

## Organization

-   Tags.
-   Physical original location.

## Notes

Private notes section.

## Reminder

Show:

-   Enabled/disabled.
-   Next reminder.

CTA:

`Edit Reminder`

## Files/Pages

Show page count and thumbnails.

## Bottom Actions

-   Edit.
-   Share/Export.
-   More.

More:

-   Archive.
-   Add replacement/version.
-   Move to Trash.

------------------------------------------------------------------------

# 27. Screen 23 --- Image Viewer

Full-screen dark/neutral viewer.

Controls:

-   Back.
-   Page number.
-   More.

Gestures:

-   Pinch zoom.
-   Pan.
-   Double-tap zoom.

Bottom page thumbnails for multi-page document.

More:

-   Rotate view.
-   Export selected page if permitted.
-   Document info.

UI controls fade while viewing.

Vault security remains active.

------------------------------------------------------------------------

# 28. Screen 24 --- PDF Viewer

Full-screen viewer.

Features:

-   Page indicator.
-   Scroll pages.
-   Zoom.
-   Jump to page.
-   Thumbnail navigation.
-   Search within PDF only if securely supported in future.

More:

-   Document details.
-   Export/share.

Avoid creating long-lived decrypted PDF copies.

------------------------------------------------------------------------

# 29. Screen 25 --- Add Document Method

Bottom sheet/full screen.

Title:

`Add Document`

Options:

### Scan with Camera

Best for physical documents.

### Import Photos

Select existing document images.

### Import PDF/File

Choose from device or system provider.

Cancel action.

------------------------------------------------------------------------

# 30. Screen 26 --- Camera Capture

## Camera UI

Top:

-   Close.
-   Flash.
-   Help.

Center:

-   Camera preview.
-   Document edge guide.

Bottom:

-   Gallery shortcut if allowed.
-   Shutter.
-   Page count.

After capture:

-   Accept.
-   Retake.

Privacy:

Do not save captures to public gallery automatically.

------------------------------------------------------------------------

# 31. Screen 27 --- Crop and Adjust

Display captured page.

Tools:

-   Crop corners.
-   Rotate.
-   Reset.
-   Retake.

Primary:

`Use Page`

Do not overcomplicate with image filters in MVP.

------------------------------------------------------------------------

# 32. Screen 28 --- Multi-Page Review

Title:

`Review Pages`

Display page thumbnails.

Actions:

-   Drag reorder.
-   Rotate.
-   Delete.
-   Retake.
-   Add Page.

Bottom:

`Continue`

If deleting last page:

Confirm/cancel scan.

------------------------------------------------------------------------

# 33. Screen 29 --- Import File

System picker launches.

On return show selected file summary:

-   Safe filename display.
-   Type.
-   Size.
-   PDF page count where available.

Actions:

-   Continue.
-   Choose Another.

Error states:

-   Unsupported.
-   Corrupt.
-   Too large.
-   Insufficient storage.

------------------------------------------------------------------------

# 34. Screen 30 --- Select Owner

Title:

`Who does this document belong to?`

Options:

-   Me.
-   Household.
-   Family members.

Support multi-select where category permits.

Search field for larger families.

Bottom:

`Continue`

Secondary:

`Add Family Member`

------------------------------------------------------------------------

# 35. Screen 31 --- Select Category

Title:

`Choose document type`

Search.

Recent categories.

System categories.

Expandable subcategories.

Examples:

Identity:

-   NID.
-   Birth Certificate.
-   Passport.
-   Driving Licence.

Land & Property:

-   Deed.
-   Khatian.
-   Mutation.
-   Tax record.
-   Lease.

Option:

`Other`

------------------------------------------------------------------------

# 36. Screen 32 --- Document Information

## Fields

Required:

-   Document title.

Optional:

-   Document number.
-   Issuing authority.
-   Description.

Category-specific fields appear below.

Sensitive document-number field:

-   Mask when not editing.
-   Never auto-copy.

Primary:

`Continue`

Secondary:

`Save and Finish` if minimum requirements are complete.

------------------------------------------------------------------------

# 37. Screen 33 --- Important Dates

Fields:

-   Issue date.
-   Expiry date.
-   Renewal date if applicable.

Options:

`This document does not expire`

Validation:

-   Expiry cannot normally precede issue date.
-   Explain unusual valid cases if allowed.

Quick action:

`Set Reminder`

------------------------------------------------------------------------

# 38. Screen 34 --- Tags and Notes

## Tags

Selectable chips.

`+ Add Tag`

## Physical Original

Field:

`Where is the original kept?`

Select existing or add location.

## Notes

Multiline field.

Helper:

`Add private notes such as renewal instructions or where to find related paperwork.`

------------------------------------------------------------------------

# 39. Screen 35 --- Reminder Setup

Toggle:

`Remind me before expiry`

Preset chips:

-   90 days.
-   60 days.
-   30 days.
-   14 days.
-   7 days.
-   3 days.
-   1 day.

Allow multiple selections.

Custom:

`Add Custom Reminder`

Notification preview:

`Passport renewal reminder — expires in 30 days.`

Privacy note:

`Document numbers are hidden from notifications by default.`

------------------------------------------------------------------------

# 40. Screen 36 --- Saving Document

Blocking progress state only for short critical commit.

Show:

`Securing your document...`

Steps may be simplified:

-   Encrypting.
-   Saving.
-   Finishing.

Do not let users accidentally navigate away during critical
finalization.

------------------------------------------------------------------------

# 41. Screen 37 --- Document Saved

Success illustration.

Title:

`Document saved securely`

Actions:

Primary:

`View Document`

Secondary:

`Add Another`

Tertiary:

`Go Home`

------------------------------------------------------------------------

# 42. Screen 38 --- Family Member List

App bar:

`Family`

Action:

`Add`

Cards:

-   Avatar.
-   Name.
-   Relationship.
-   Document count.

Include:

`Household`

Archived members accessible from menu/filter.

------------------------------------------------------------------------

# 43. Screen 39 --- Add Family Member

Fields:

-   Name.\*
-   Nickname.
-   Relationship.\*
-   Date of birth.
-   Blood group.
-   Avatar.
-   Notes.

Primary:

`Save`

Validation displayed inline.

Keep form short; optional fields can be under `More Information`.

------------------------------------------------------------------------

# 44. Screen 40 --- Family Member Details

Header:

-   Avatar.
-   Name.
-   Relationship.

Summary:

-   Total documents.
-   Expiring soon.
-   Expired.

Actions:

-   Add Document.
-   Edit.

Sections:

-   Important Documents.
-   Categories.
-   All Documents.

------------------------------------------------------------------------

# 45. Screen 41 --- Edit Family Member

Same fields as Add.

Actions:

-   Save.
-   Archive Member.

Archive confirmation explains documents are retained.

------------------------------------------------------------------------

# 46. Screen 42 --- Reminder Dashboard

App bar:

`Reminders`

Tabs or sections:

-   Overdue.
-   Upcoming.
-   Completed optional.

Upcoming grouped:

-   Today.
-   Next 7 Days.
-   Next 30 Days.
-   Later.

Reminder card:

-   Document.
-   Owner.
-   Expiry date.
-   Countdown.

Actions:

-   View.
-   Snooze.

------------------------------------------------------------------------

# 47. Screen 43 --- Reminder Details

Show:

-   Document.
-   Owner.
-   Expiry/target date.
-   Reminder schedule.
-   Last reminder.
-   Next reminder.

Actions:

-   Edit.
-   Snooze.
-   Mark handled.
-   Disable.

------------------------------------------------------------------------

# 48. Screen 44 --- Edit Reminder

Allow:

-   Enable/disable.
-   Preset offsets.
-   Custom date.
-   Snooze rules.

Save.

If notifications disabled at OS level, show warning with:

`Open Settings`

------------------------------------------------------------------------

# 49. Screen 45 --- Tags

List:

-   Tag name.
-   Document count.

Actions:

-   Add.
-   Rename.
-   Delete.

Deleting a tag does not delete documents.

------------------------------------------------------------------------

# 50. Screen 46 --- Add/Edit Tag

Field:

`Tag name`

Validation:

-   Required.
-   Duplicate normalized name not allowed.

Actions:

-   Save.
-   Cancel.

------------------------------------------------------------------------

# 51. Screen 47 --- Archived Documents

Explain:

`Archived documents are kept safely but hidden from your active document lists.`

List archived documents.

Actions:

-   View.
-   Restore.
-   Move to Trash.

------------------------------------------------------------------------

# 52. Screen 48 --- Trash

Banner:

`Documents in Trash may be permanently deleted after 30 days.`

List:

-   Document.
-   Owner.
-   Deleted date.
-   Days remaining.

Actions:

-   Restore.
-   Delete Permanently.

Top action:

`Empty Trash`

Requires confirmation.

------------------------------------------------------------------------

# 53. Screen 49 --- Permanent Delete Confirmation

Use destructive modal/bottom sheet.

Title:

`Delete permanently?`

Explain:

`This document and its stored files will be removed from this device and cannot be recovered from the vault. Existing external backups are not affected.`

Actions:

-   Cancel.
-   Delete Permanently.

For highly sensitive/destructive bulk actions, require stronger
confirmation.

------------------------------------------------------------------------

# 54. Screen 50 --- Backup & Restore Home

Header:

`Backup & Restore`

## Backup Health Card

Show:

-   Last successful backup.
-   Documents changed since backup.
-   Backup status.

Primary:

`Create Backup`

## Restore

Card:

`Restore from Backup`

Warning:

`Restoring can replace the current vault.`

## Backup Reminder

Show schedule.

## Information

`Backups are encrypted and can be stored wherever you choose.`

------------------------------------------------------------------------

# 55. Screen 51 --- Create Backup

Summary:

-   Documents.
-   Files.
-   Estimated size.

Sections:

### Backup Security

`Protect this backup with a password.`

### Destination

Chosen later through system save flow.

Primary:

`Continue`

------------------------------------------------------------------------

# 56. Screen 52 --- Backup Password

Fields:

-   Backup password.
-   Confirm password.

Controls:

-   Show/hide.
-   Strength guidance.

Warning:

`If you forget this password, the backup may not be recoverable.`

Checkbox/acknowledgement may be used for this critical warning.

Primary:

`Create Backup`

------------------------------------------------------------------------

# 57. Screen 53 --- Backup Progress

Title:

`Creating encrypted backup`

Progress indicator.

Status:

-   Preparing.
-   Packaging.
-   Encrypting.
-   Verifying.

Show percentage only if technically reliable.

Message:

`Keep the app open until this step finishes.`

Support safe cancellation only if implementation guarantees cleanup.

------------------------------------------------------------------------

# 58. Screen 54 --- Backup Result

Success:

`Backup verified successfully`

Show:

-   Date/time.
-   Size.
-   Verification status.

Primary:

`Save Backup`

Then invoke system destination picker.

After destination success:

`Done`

Failure state:

-   Retry.
-   View simple reason.
-   Cancel.

Never expose cryptographic internals.

------------------------------------------------------------------------

# 59. Screen 55 --- Restore Backup Selection

Title:

`Restore Backup`

Explain:

`Choose a Document Vault BD encrypted backup.`

Primary:

`Choose Backup File`

After selection:

Show:

-   File size.
-   Backup format recognized/unrecognized.

Continue.

------------------------------------------------------------------------

# 60. Screen 56 --- Restore Password

Title:

`Unlock Backup`

Password field.

Primary:

`Continue`

Errors:

-   Incorrect password.
-   Backup damaged.
-   Unsupported backup.

Do not distinguish cryptographic failures more precisely than necessary.

------------------------------------------------------------------------

# 61. Screen 57 --- Restore Summary

After successful authentication show:

-   Backup date.
-   Document count.
-   Family-member count.
-   Backup size.
-   Backup version if useful.

Warning card:

`Restoring this backup will replace the current vault.`

Explain current vault safety snapshot behavior in user-friendly terms.

Primary destructive action:

`Restore This Backup`

Secondary:

`Cancel`

------------------------------------------------------------------------

# 62. Screen 58 --- Restore Progress

Progress stages:

-   Checking backup.
-   Preparing.
-   Restoring documents.
-   Updating data.
-   Verifying.
-   Finishing.

Do not allow normal navigation.

If app interruption occurs, startup recovery handles it.

------------------------------------------------------------------------

# 63. Screen 59 --- Restore Result

Success:

`Vault restored successfully`

Next steps:

-   Configure PIN if required.
-   Enable biometrics.
-   Enable reminders.

Primary:

`Open Vault`

Failure:

`Your current vault was not replaced.`

Actions:

-   Retry.
-   Choose Another Backup.
-   Cancel.

This reassurance is important when rollback succeeded.

------------------------------------------------------------------------

# 64. Screen 60 --- Settings Home

Sections:

### General

-   Language.
-   Appearance.
-   Date format.

### Security

-   PIN.
-   Biometrics.
-   Auto-lock.
-   Privacy.

### Reminders

-   Notification settings.
-   Default expiry reminders.

### Data

-   Backup & Restore.
-   Storage.

### Support

-   Privacy.
-   Security information.
-   Help.
-   About.

------------------------------------------------------------------------

# 65. Screen 61 --- General Settings

Options:

-   Language.
-   Theme: Light/Dark/System.
-   Date format.
-   Default document view.
-   Default family profile.

Save immediately where safe.

------------------------------------------------------------------------

# 66. Screen 62 --- Security Settings

Show:

### Vault PIN

`Change PIN`

### Biometrics

Toggle.

### Auto-Lock

Options:

-   Immediately.
-   30 seconds.
-   1 minute.
-   5 minutes.
-   Custom if supported.

### Screen Privacy

-   Hide content in app switcher.
-   Screenshot protection where supported.

### Notification Privacy

-   Hide sensitive details.

Sensitive setting changes may require re-authentication.

------------------------------------------------------------------------

# 67. Screen 63 --- Change PIN

Flow:

1.  Current PIN.
2.  New PIN.
3.  Confirm new PIN.
4.  Save.

On success:

`PIN changed successfully.`

Do not disrupt vault encryption key unnecessarily if key wrapping can be
updated safely.

------------------------------------------------------------------------

# 68. Screen 64 --- Notification Settings

Settings:

-   Expiry reminders.
-   Backup reminders.
-   Default reminder schedule.
-   Notification privacy.

Show OS permission status.

If disabled:

`Notifications are turned off in device settings.`

CTA:

`Open Settings`

------------------------------------------------------------------------

# 69. Screen 65 --- Storage Management

Summary cards:

-   Total vault size.
-   Documents.
-   Images/PDFs.
-   Thumbnails/cache.
-   Trash.
-   Estimated backup size.

Actions:

-   Clear Safe Temporary Files.
-   Review Large Documents.
-   Empty Trash.
-   Run Integrity Check.

Warning:

`Original documents will never be removed automatically.`

------------------------------------------------------------------------

# 70. Screen 66 --- Privacy & Permissions

Show each permission:

### Camera

Status and reason.

### Photos/Files

Status and reason.

### Notifications

Status.

### Biometrics

Status.

Actions:

-   Request if possible.
-   Open device settings.

Privacy section:

`Your document vault is stored locally on this device.`

------------------------------------------------------------------------

# 71. Screen 67 --- About & Help

Sections:

-   How Document Vault Works.
-   Backup Guide.
-   Restore Guide.
-   Security Information.
-   Privacy Policy.
-   Legal Disclaimer.
-   Open-source Licences.
-   App Version.

No support workflow should silently attach vault contents.

------------------------------------------------------------------------

# 72. Screen 68 --- More

Top:

Optional profile/vault summary.

Menu groups:

## Organize

-   Family.
-   Categories.
-   Tags.
-   Archived.
-   Trash.

## Data

-   Backup & Restore.
-   Storage.

## App

-   Settings.
-   Help & About.

Bottom:

`Lock Vault`

------------------------------------------------------------------------

# 73. Screen 69 --- Category Management

For MVP, system categories cannot be deleted.

Display:

-   Category.
-   Document count.
-   System/custom indicator.

Future/custom support:

-   Add Category.
-   Edit custom category.
-   Reorder.

------------------------------------------------------------------------

# 74. Screen 70 --- Physical Storage Locations

List examples:

-   Bedroom locker.
-   Bank locker.
-   Office cabinet.

Each:

-   Name.
-   Number of linked documents.

Actions:

-   Add.
-   Edit.
-   Archive.

Treat names as sensitive.

------------------------------------------------------------------------

# 75. Screen 71 --- Add/Edit Physical Location

Fields:

-   Location name.\*
-   Notes.

Example:

`Bedroom locker`

Avoid asking for unnecessary exact address/location data.

------------------------------------------------------------------------

# 76. Screen 72 --- Edit Document

Same sections as document creation.

Tabs/sections:

-   Basic Information.
-   Dates.
-   Owners.
-   Tags & Notes.
-   Reminder.
-   Files/Pages.

Primary:

`Save Changes`

If user exits with changes:

Show Unsaved Changes confirmation.

------------------------------------------------------------------------

# 77. Screen 73 --- Add/Replace Document Version

Purpose:

Store a renewed/reissued version while preserving history.

Show:

`Current document`

Then actions:

-   Scan New Version.
-   Import New Version.

Fields:

-   New issue date.
-   New expiry date.
-   Notes.

On save:

-   New version becomes current.
-   Old version becomes superseded.

------------------------------------------------------------------------

# 78. Screen 74 --- Version History

Timeline/list:

-   Current version.
-   Previous versions.

Each:

-   Issue date.
-   Expiry.
-   Added date.
-   Status.

Tap to view historical version.

------------------------------------------------------------------------

# 79. Screen 75 --- Share/Export Confirmation

Before system share sheet:

Title:

`Share document?`

Show:

-   Document.
-   Number of pages.
-   Export format.

Options:

-   All pages.
-   Selected pages.

Warning:

`Shared files leave the protected vault and may be stored by another app or person.`

Primary:

`Continue to Share`

Secondary:

`Cancel`

------------------------------------------------------------------------

# 80. Screen 76 --- Export Progress

Show only when export requires processing.

Status:

`Preparing secure export...`

Do not expose internal file paths.

On completion invoke OS share/save flow.

Clean temporary files afterward.

------------------------------------------------------------------------

# 81. Screen 77 --- Document Actions Menu

Bottom sheet:

-   Edit.
-   Favorite/Unfavorite.
-   Set Reminder.
-   Share/Export.
-   Add New Version.
-   Archive.
-   Move to Trash.

Separate destructive actions visually and position them last.

------------------------------------------------------------------------

# 82. Screen 78 --- Backup Reminder Prompt

Non-blocking card/dialog:

`It has been 30 days since your last backup.`

or:

`You added 25 documents since your last backup.`

Actions:

-   Back Up Now.
-   Remind Me Later.

Never use fear-heavy language.

------------------------------------------------------------------------

# 83. Screen 79 --- Database Upgrade

Shown only when migration needs visible progress.

Title:

`Updating your vault`

Message:

`We are preparing your saved documents for this app version.`

Progress indicator.

Warning:

`Keep the app open.`

On success → Unlock.

On failure → Recovery screen.

------------------------------------------------------------------------

# 84. Screen 80 --- Vault Recovery Error

Purpose:

Handle serious migration/storage problems without implying data loss
prematurely.

Title:

`We couldn't open the vault safely`

Actions depending on state:

-   Try Again.
-   Restore Backup.
-   View Help.

Never offer destructive reset as the primary action.

------------------------------------------------------------------------

# 85. Common State --- Initial Loading

Use skeletons where decrypted metadata is available and loading is safe.

Before vault unlock, never show cached document skeleton content that
implies document names/counts.

------------------------------------------------------------------------

# 86. Common State --- Empty List

Structure:

-   Simple icon/illustration.
-   Clear title.
-   One-sentence explanation.
-   Primary action.

Example:

`No documents here yet`

`Add a document to start organizing this category.`

------------------------------------------------------------------------

# 87. Common State --- No Search Results

Show query.

`No documents found for “passport 2024”.`

Actions:

-   Clear filters.
-   Try another search.
-   Browse categories.

------------------------------------------------------------------------

# 88. Common State --- Save in Progress

Use inline progress when possible.

For critical encrypted writes:

-   Prevent duplicate submit.
-   Show clear progress.
-   Avoid allowing conflicting edits.

------------------------------------------------------------------------

# 89. Common State --- Save Successful

Prefer subtle confirmation:

-   Snackbar/banner.

Example:

`Changes saved.`

Do not force a modal for routine success.

------------------------------------------------------------------------

# 90. Common State --- Save Failed

Message:

`We couldn't save these changes.`

Actions:

-   Retry.
-   Cancel.

Preserve user's entered data.

------------------------------------------------------------------------

# 91. Common State --- Unsupported File

Title:

`This file type isn't supported`

Explain supported types:

-   Images.
-   PDF.

Action:

`Choose Another File`

------------------------------------------------------------------------

# 92. Common State --- Corrupted File

Title:

`This document can't be opened`

Explain:

`The file may be damaged or incomplete.`

Actions:

-   Choose Another.
-   Remove Import.

Do not crash viewer.

------------------------------------------------------------------------

# 93. Common State --- Storage Nearly Full

Title:

`Device storage is almost full`

Explain:

`You may not be able to add or back up documents until space is available.`

Actions:

-   Open Storage Management.
-   Cancel.

------------------------------------------------------------------------

# 94. Common State --- Permission Denied

Explain:

-   Which permission.
-   Why needed.
-   What still works without it.

Actions:

-   Try Again.
-   Open Settings.
-   Not Now.

------------------------------------------------------------------------

# 95. Common State --- Notification Permission Denied

Do not block document use.

Banner in reminder screen:

`Notifications are off. Your reminder dates are saved, but the device cannot alert you.`

CTA:

`Open Settings`

------------------------------------------------------------------------

# 96. Common State --- Biometric Unavailable

Message:

`Biometric unlock isn't available right now. Use your PIN.`

Primary:

`Use PIN`

------------------------------------------------------------------------

# 97. Common State --- Unsaved Changes

Dialog:

`Discard changes?`

Text:

`Your changes have not been saved.`

Actions:

-   Keep Editing.
-   Discard.

------------------------------------------------------------------------

# 98. Common State --- Archive Confirmation

Title:

`Archive this document?`

Explain:

`It will remain in your vault but will be hidden from active document lists.`

Actions:

-   Cancel.
-   Archive.

------------------------------------------------------------------------

# 99. Common State --- Backup Failed

Title:

`Backup couldn't be completed`

Possible user-friendly reasons:

-   Not enough storage.
-   Destination unavailable.
-   Operation interrupted.

Actions:

-   Retry.
-   Choose Another Location.
-   Cancel.

Do not expose cryptographic stack traces.

------------------------------------------------------------------------

# 100. Common State --- Backup Verification Failed

Title:

`Backup could not be verified`

Message:

`For your safety, this backup has not been marked as successful.`

Actions:

-   Try Again.
-   Cancel.

------------------------------------------------------------------------

# 101. Common State --- Wrong Backup Password

Message:

`The password is incorrect or this backup cannot be unlocked.`

Action:

`Try Again`

Avoid leaking cryptographic distinctions.

------------------------------------------------------------------------

# 102. Common State --- Incompatible Backup

Title:

`This backup isn't supported by this app version`

Actions:

-   Update App if appropriate.
-   Choose Another Backup.
-   Cancel.

------------------------------------------------------------------------

# 103. Common State --- Restore Failed Safely

Title:

`Restore wasn't completed`

Message:

`Your previous vault is still available.`

Actions:

-   Retry.
-   Choose Another Backup.
-   Return to Vault.

Only show reassurance if technically verified.

------------------------------------------------------------------------

# 104. Common State --- Expired Document

Use clear status:

`Expired 12 days ago`

Actions:

-   Add New Version.
-   Set Reminder.
-   View Details.

------------------------------------------------------------------------

# 105. Common State --- Expiring Soon

Example:

`Expires in 14 days`

Primary contextual action:

`Review`

Optional:

`Set Reminder`

------------------------------------------------------------------------

# 106. Common State --- Duplicate Detected

Title:

`Similar document found`

Show safe comparison:

-   Existing document title.
-   Owner.
-   Category.
-   Added date.

Actions:

-   View Existing.
-   Add Anyway.
-   Cancel.

Never auto-delete.

------------------------------------------------------------------------

# 107. Common State --- Screenshot Blocked

If user attempts screenshot and platform/app policy blocks it, provide
contextual explanation only if technically feasible:

`Screenshots are restricted to protect your documents.`

Settings may allow change where supported.

------------------------------------------------------------------------

# 108. Common State --- Offline

Core app should not show an alarming offline banner because ordinary
functionality works offline.

Only optional online features should state:

`Internet connection is required for this optional feature.`

------------------------------------------------------------------------

# 109. Global Form Behavior

All forms should:

-   Keep labels visible.
-   Use correct keyboard.
-   Validate near the field.
-   Preserve values after recoverable errors.
-   Avoid huge single-page forms.
-   Mark optional fields clearly.
-   Avoid mandatory data that is not required for functionality.

Date fields should use platform-friendly date pickers.

------------------------------------------------------------------------

# 110. Date Picker

Requirements:

-   Calendar picker.
-   Manual date entry where appropriate.
-   Clear selected date.
-   Today shortcut where useful.
-   Localized month/day names.

Expiry dates should not default silently.

------------------------------------------------------------------------

# 111. Family Member Selector

Use searchable bottom sheet.

Rows:

-   Avatar.
-   Name.
-   Relationship.

Support multi-select where applicable.

Include:

`Household`

and:

`Add Family Member`

------------------------------------------------------------------------

# 112. Category Selector

Searchable hierarchical sheet.

Show:

-   Icon.
-   Category.
-   Common subcategories.

Recent categories at top.

Do not force users through deep navigation for common documents.

------------------------------------------------------------------------

# 113. Tag Selector

Bottom sheet.

-   Search tags.
-   Multi-select.
-   Create new tag.

Selected tags appear as chips.

------------------------------------------------------------------------

# 114. Confirmation Bottom Sheet

Use for medium-risk actions.

Structure:

-   Icon.
-   Title.
-   Explanation.
-   Primary action.
-   Cancel.

For permanent deletion/restore replacement, use stronger confirmation.

------------------------------------------------------------------------

# 115. Search & Filter Sheet

Show active filters.

Allow individual removal.

Bottom sticky actions:

-   Reset.
-   Apply.

Display result count if available without expensive processing.

------------------------------------------------------------------------

# 116. Loading Skeletons

Create skeletons for:

-   Home.
-   Document list.
-   Document details.
-   Family list.
-   Reminder list.

Never show stale sensitive content before unlock.

------------------------------------------------------------------------

# 117. Snackbar and Banner Rules

Snackbar:

-   Routine save success.
-   Favorite added.
-   Tag created.

Banner:

-   Backup overdue.
-   Notification permission disabled.
-   Storage low.
-   Restore/recovery warning.

Modal:

-   Permanent delete.
-   Replace vault restore.
-   Serious migration issue.

------------------------------------------------------------------------

# 118. Accessibility Requirements

All screens must support:

-   TalkBack.
-   VoiceOver.
-   Text scaling.
-   Logical focus order.
-   Descriptive buttons.
-   Non-color status indicators.
-   Large touch targets.

Examples:

Instead of semantic label:

`button`

Use:

`Scan new document`

For status:

`Passport, expires in 14 days`

------------------------------------------------------------------------

# 119. Bengali UX Requirements

Bangla copy should be simple and conversational.

Avoid overly formal or bureaucratic terminology where a common word
exists.

Examples:

**Backup**

Can display:

`ব্যাকআপ`

with helper:

`আপনার ভল্টের নিরাপদ কপি`

**Restore**

Can display:

`পুনরুদ্ধার`

with explanatory helper text.

Use English abbreviations familiar in Bangladesh when appropriate:

-   NID.
-   TIN.
-   PDF.

------------------------------------------------------------------------

# 120. Privacy Display Rules

## Document Numbers

List:

-   Hidden.

Details:

-   Masked by default where practical.

Example:

`••••••6789`

Allow reveal when user intentionally taps.

## Notifications

No numbers by default.

## Recent Apps

No document content.

## Search

Clear index on lock.

## Export

Always warn that exported files leave vault protection.

------------------------------------------------------------------------

# 121. Android Platform Adaptation

Use Android-native conventions for:

-   Back navigation.
-   Permission prompts.
-   Biometric prompt.
-   File picker.
-   Notification settings.
-   Material controls.

Respect predictive back where supported.

------------------------------------------------------------------------

# 122. iOS Platform Adaptation

Use iOS conventions for:

-   Navigation.
-   Sheets.
-   Destructive confirmations.
-   Face ID/Touch ID.
-   File picker.
-   Share sheet.
-   Settings redirects.

Avoid forcing Android visual patterns onto iOS where platform adaptation
improves familiarity.

------------------------------------------------------------------------

# 123. Screen Transition Rules

Recommended:

-   Bottom tabs preserve navigation state.
-   Detail → standard push.
-   Add document → focused workflow.
-   Camera → full-screen.
-   Selectors → bottom sheet.
-   Critical backup/restore → full-screen flow.
-   Viewer → full-screen.
-   Settings subsections → standard push.

Avoid unnecessary animations.

Respect reduced-motion preference.

------------------------------------------------------------------------

# 124. App Lock During Active Work

If auto-lock triggers while user is:

-   Viewing document → lock immediately according to policy.
-   Editing metadata → preserve encrypted draft state if safely
    supported.
-   Creating backup → define operation-specific behavior.
-   Restoring → do not corrupt operation; show authentication when safe.

Never sacrifice data integrity solely to display the lock screen
instantly.

------------------------------------------------------------------------

# 125. Home Information Priority

Home should prioritize:

1.  Expired/urgent documents.
2.  Expiring soon.
3.  Backup health.
4.  Quick actions.
5.  Favorites.
6.  Recent documents.
7.  Family shortcuts.

Avoid turning Home into a statistics dashboard.

------------------------------------------------------------------------

# 126. MVP Screen Map

``` text
Launch
 ├── Splash
 ├── Welcome
 ├── Language
 ├── Privacy
 ├── Create PIN
 ├── Confirm PIN
 ├── Biometrics
 ├── Notifications
 └── Setup Complete

Locked
 ├── Unlock
 └── Recovery

Home
 ├── Dashboard
 ├── Expiring Soon
 ├── Recent
 └── Favorites

Documents
 ├── All Documents
 ├── Categories
 │    └── Category Documents
 ├── Person Documents
 ├── Search
 ├── Filter/Sort
 └── Document Details
      ├── Image Viewer
      ├── PDF Viewer
      ├── Edit
      ├── Version History
      └── Share/Export

Add
 ├── Method
 ├── Camera
 ├── Crop
 ├── Page Review
 ├── Import
 ├── Owner
 ├── Category
 ├── Information
 ├── Dates
 ├── Tags/Notes
 ├── Reminder
 ├── Saving
 └── Success

Family
 ├── List
 ├── Add
 ├── Details
 └── Edit

Reminders
 ├── Dashboard
 ├── Details
 └── Edit

Organization
 ├── Tags
 ├── Categories
 ├── Locations
 ├── Archive
 └── Trash

Backup
 ├── Backup Home
 ├── Create
 ├── Password
 ├── Progress
 └── Result

Restore
 ├── Select
 ├── Password
 ├── Summary
 ├── Progress
 └── Result

More
 ├── Family
 ├── Tags
 ├── Archive
 ├── Trash
 ├── Backup & Restore
 ├── Storage
 ├── Settings
 └── Help

Settings
 ├── General
 ├── Security
 ├── Change PIN
 ├── Notifications
 ├── Storage
 ├── Privacy & Permissions
 └── About & Help
```

------------------------------------------------------------------------

# 127. Recommended Design Deliverables

For implementation, produce high-fidelity designs for at least:

1.  Splash.
2.  Welcome.
3.  Language.
4.  Privacy explanation.
5.  Create PIN.
6.  Confirm PIN.
7.  Biometrics.
8.  Notification intro.
9.  Unlock.
10. Recovery.
11. Home.
12. Expiring Soon.
13. Recent.
14. Favorites.
15. All Documents.
16. Categories.
17. Category Documents.
18. Person Documents.
19. Search.
20. Filter/Sort.
21. Document Details.
22. Image Viewer.
23. PDF Viewer.
24. Add Method.
25. Camera.
26. Crop.
27. Multi-page Review.
28. Import.
29. Owner Selector.
30. Category Selector.
31. Document Information.
32. Important Dates.
33. Tags & Notes.
34. Reminder Setup.
35. Saving.
36. Save Success.
37. Family List.
38. Add Family.
39. Family Details.
40. Edit Family.
41. Reminder Dashboard.
42. Reminder Details.
43. Edit Reminder.
44. Tags.
45. Archive.
46. Trash.
47. Delete Confirmation.
48. Backup Home.
49. Create Backup.
50. Backup Password.
51. Backup Progress.
52. Backup Result.
53. Restore Select.
54. Restore Password.
55. Restore Summary.
56. Restore Progress.
57. Restore Result.
58. More.
59. Settings.
60. General Settings.
61. Security Settings.
62. Change PIN.
63. Notification Settings.
64. Storage.
65. Privacy & Permissions.
66. About & Help.
67. Edit Document.
68. Add Version.
69. Version History.
70. Share Confirmation.
71. Recovery/Migration states.
72. Common loading/empty/error states.

------------------------------------------------------------------------

# 128. Final UX Direction

Document Vault BD should feel less like a generic file manager and more
like a **private family document organizer**.

The most important user journey is:

``` text
Open App
   ↓
Unlock Securely
   ↓
Immediately See What Needs Attention
   ↓
Find or Add a Document in Seconds
   ↓
Know Where the Original Is
   ↓
Receive Expiry Reminders
   ↓
Create a Verified Encrypted Backup
```

The design should communicate security without making the product
intimidating. Users should not need to understand encryption, database
architecture, or key management. Those mechanisms should remain
invisible until the user needs a simple explanation about PIN recovery,
backups, sharing, or privacy.

The resulting experience should be:

-   Simple enough for everyday Bangladeshi family use.
-   Secure enough for sensitive personal records.
-   Fully functional without internet.
-   Comfortable in বাংলা and English.
-   Predictable across Android and iOS.
-   Explicit about backup and recovery.
-   Resistant to accidental deletion or disclosure.
