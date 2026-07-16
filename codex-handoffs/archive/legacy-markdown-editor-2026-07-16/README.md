# Legacy Markdown editor archive

Archived on 2026-07-16 while activating the Android structured-document contract.

These files implemented the retired WebView Markdown preview, its render cache, the task-property live Markdown field, and the bundled JavaScript rendering engines. They are intentionally outside Android source and assets so they cannot ship in the APK.

The active editor stores and edits typed `DocumentBlock` payloads. Markdown remains supported only at import, export, print, and interoperability boundaries. Do not copy these files back into the app without an explicit product-contract change.
