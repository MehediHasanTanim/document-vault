# ADR-011: Secure export and PDF redaction

## Status

Accepted for image exports; PDF rendering backend pending platform security approval.

## Decision

Image exports are decoded from the encrypted vault source, redactions are painted into the pixels, an optional watermark is painted into the same pixels, and the result is JPEG re-encoded. The output therefore contains no source EXIF/XMP, embedded thumbnail, image comment, or removable overlay layer.

The app creates opaque filenames only inside the private vault temporary directory. It holds them until the platform share sheet is dismissed, records a non-sensitive `share_handoff` event only when the OS accepted handoff, then deletes the workspace. Startup cleanup removes interrupted export workspaces.

PDF redaction has no raw-PDF fallback. A future approved rasterizer must render selected pages inside the private workspace and return raster pixels; those pixels follow the same flattening pipeline. Raster output intentionally removes selectable text, annotations, attachments, JavaScript, metadata, and hidden PDF objects.

## Research gate before enabling a PDF backend

- Pin and review the native renderer/library version for Android and iOS.
- Ensure parsing and rendering occur offline and only in the vault workspace.
- Bound page count, raster dimensions, memory, and execution time.
- Test malformed/encrypted PDFs, incremental updates, annotations, attachments, AcroForms, JavaScript, layers, embedded fonts, and alternate images.
- Verify that redacted text cannot be selected, copied, extracted, or recovered from the resulting export.
- Run device-level tests for cancellation, process death, low storage, and cleanup.

## Consequence

PDF export with watermark or redaction remains disabled until that gate passes. This is intentional: a visually covered PDF is not a secure redaction.
