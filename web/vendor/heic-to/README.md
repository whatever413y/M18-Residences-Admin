# heic-to 1.6.5 (vendored)

Browser HEIC/HEIF decoder used by the admin app to convert iPhone photos before
uploading receipts (`lib/features/billing/receipt_converter.dart`). It is loaded
only when a HEIC file is picked.

- Source: https://www.npmjs.com/package/heic-to (https://github.com/hoppergee/heic-to), file `dist/iife/heic-to.js`, unmodified.
- License: LGPL-3.0 (see `LICENSE`); it bundles libheif (LGPL-3.0).
- Update: `npm pack heic-to@<version>`, copy `package/dist/iife/heic-to.js` and `package/LICENSE` here, update this file.
