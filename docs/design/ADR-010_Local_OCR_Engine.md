# ADR-010 — Local OCR Engine

## Decision

Use Tesseract 4 through `flutter_tesseract_ocr` for Android and iOS. Bundle
the official `eng` and `ben` fast trained-data models in the application
package. Recognition receives only a short-lived, private decrypted image and
returns text to Dart memory. There is no remote OCR endpoint, runtime model
download, document upload, or OCR analytics path.

Tesseract is selected because the official trained-data catalog includes
English (`eng`) and Bengali (`ben`), while the product must support Bangladesh-
first bilingual documents. The Flutter wrapper invokes Tesseract4Android and
the iOS native implementation locally. Model assets are non-sensitive and may
remain in app storage; all document-derived text remains transient until a user
explicitly accepts it.

## Data handling

1. Decrypt one image to a vault-owned temporary workspace.
2. Invoke Tesseract with `eng`, `ben`, or `ben+eng`.
3. Delete the workspace even when recognition fails or the user leaves.
4. Show candidate text for review; never overwrite user metadata.
5. Encrypt approved text in the `ocr_text` document field with document-bound
   authenticated encryption.
6. Add only accepted OCR text to the existing in-memory search index.
7. Clear search and presentation candidates on vault lock.

PDF OCR, background/batch OCR, remote OCR, automatic field extraction, and
automatic title/category changes are out of scope for this increment.

## Platform note

The current SwiftyTesseract dependency builds for physical iOS devices but does
not support arm64 iOS simulators. Run OCR acceptance testing on a real iPhone
or iPad; the rest of the Flutter suite remains simulator-independent.

## Verification

Automated tests cover English, Bengali, mixed-language text, Bengali numerals,
encrypted persistence, search indexing, replacement without overwriting user
fields, failure copy, and workspace cleanup. Device validation must include
Android and iOS recognition using representative Bangla and English documents.
