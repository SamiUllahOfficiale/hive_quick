## 1.0.3

- Added WASM-compatible test adjustments for web platform support, securing full pub.dev analysis points.

## 1.0.2

- Added official web platform support.
- Updated `flutter_secure_storage` dependency constraints to target version `^10.3.1`.

## 1.0.1

- Updated `flutter_secure_storage` dependency constraints to latest stable versions.
- Explicitly configured supported platform declarations for mobile and desktop environments.

## 1.0.0

- Initial official release of `hive_quick`.
- Introduced Mongoose-style API methods: `findOne`, `findMany`, `updateOne`, `updateMany`, `deleteOne`, `deleteMany`, and `clearAll`.
- Added partial update support merging map changes into existing stored records.
- Added deterministic key-ordering preservation for keeping newly inserted records at top (index 0).
- Added built-in AES-256 box encryption support using `flutter_secure_storage`.
- Added reactive streaming with `watchAll()`.
