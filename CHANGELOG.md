# Changelog

---

## [1.0.0] - 2024-12-10

### Initial Release

- Implemented a minimal `WaitGroup` inspired by Go's `sync.WaitGroup`.
- Added core task management features with `add`, `done`, and `wait`.
- Included pause and resume functionality to control asynchronous flows.
- Added a reset method to enable reusing the same `WaitGroup`.
- Added basic error handling for edge cases:
  - Adding tasks after WaitGroup completion.
  - Calling `done()` without corresponding tasks.
