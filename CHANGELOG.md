## 1.0.0

- Initial official release of `hive_quick`.
- Introduced Mongoose-style API methods: `findOne`, `findMany`, `updateOne`, `updateMany`, `deleteOne`, `deleteMany`, and `clearAll`.
- Added partial update support merging map changes into existing stored records.
- Added deterministic key-ordering preservation for keeping newly inserted records at top (index 0).
- Added built-in AES-256 box encryption support using `flutter_secure_storage`.
- Added reactive streaming with `watchAll()`.
