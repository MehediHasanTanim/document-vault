# Sprint 19 secure sharing security review

## Scope reviewed

Selected-page image export, permanent raster redaction, watermarking, preview,
temporary export cleanup, OS share handoff, and local share audit records.

## Findings and controls

| Review question | Result |
| --- | --- |
| Does this create plaintext sensitive storage? | Yes, only a short-lived export JPEG under the app-private vault `temp/` directory. It is never placed in gallery/public storage by the app. |
| Is decrypted lifetime bounded? | Source bytes live only while rendering; private export files are deleted in `finally` after the native share sheet returns. Startup maintenance clears abandoned vault temporary workspaces after process death. |
| Are source originals modified? | No. Export always produces a new JPEG; originals remain encrypted and unchanged. |
| Are redactions recoverable? | No for images. Black rectangles are painted into raster pixels before JPEG encoding. There is no overlay, annotation, or coordinate persistence. |
| Is hidden image data removed? | Yes. Decode/re-encode removes EXIF/XMP, embedded thumbnails, comments, and container metadata. |
| Is watermark removable? | No. Text is rasterized into the export pixels. Unsupported glyphs are rejected rather than silently omitted. |
| What about PDFs? | Raw PDF export/redaction is denied. PDF support requires a reviewed rasterizer and flattened image output; ADR-011 defines the release gate. |
| Are sensitive values logged or audited? | No. The audit table records UUID, page count, format, watermark/redaction booleans, and timestamp only. No title, number, recipient, destination, filename, path, watermark text, or redaction geometry is stored. |
| What happens on cancellation or share failure? | The `finally` cleanup removes the export workspace. No audit event is written unless the platform reports OS handoff. |
| What happens on process death? | The existing vault startup temporary-workspace reconciliation deletes export workspaces. |

## Required release validation

Before enabling the screen in a production release, run the following on real
Android and iOS devices:

1. Share one and many pages to at least two target apps; confirm only selected pages arrive.
2. Inspect exported images with metadata tooling; confirm no EXIF/XMP/comment or source filename remains.
3. Attempt visual, OCR, pixel-level, and file-carving recovery of a redacted region; confirm no original pixels remain.
4. Cancel share, kill the app while the sheet is visible, and fill storage during rendering; confirm no private temporary file survives recovery.
5. Confirm no document title, number, recipient, or watermark text appears in logs, notifications, recent files, or the audit database.
6. Complete the PDF renderer security gate in ADR-011 before enabling any PDF sharing, watermark, or redaction path.

## Release decision

Image-only export is code-reviewed and covered by automated flattening,
selection, cleanup, audit, and migration tests. It remains subject to the
device-level checks above. PDF redaction is **not approved or enabled**.
