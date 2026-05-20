# Workflow migration status

## Repos using gh-actions

| Repo | uses `rust-build-and-test` | uses `cmake-build-and-test` | manual cargo calls |
|---|---|---|---|
| `lib_circuits-internal` | ✅ 3x + lint | ✅ 1x (cpp) | no_std job only |
| `lib-garble-rs-internal` | ✅ 2x + lint | ❌ | android job only |
| `wallet-app-internal` | ✅ 2x | ❌ | desktop build examples |
| `integritee-node-internal` | ✅ 1x | ❌ | ❌ |
| `integritee-worker-internal` | ✅ 2x | ❌ | ❌ (test step name but uses action) |
| `pallets-internal` | ✅ 2x | ❌ | ❌ |
| `pallets-internal-worktree` | ✅ 2x | ❌ | ❌ |
| `rs-common-internal` | ✅ 2x | ❌ | ❌ |
| `integritee-pallets` | ❌ | ❌ | ✅ `cargo build/test/clippy/fmt` |

## Repos NOT using build actions (need manual `save-cache`)

Only **`integritee-pallets`** is a pure Substrate pallets repo with manual `cargo build --release`, `cargo test`, `cargo clippy`, `cargo fmt` — no `rust-build-and-test` or `cmake-build-and-test`.

## Migration notes

- Repos using `rust-build-and-test` / `cmake-build-and-test` need to add `save-cache` steps after the build actions
- `integritee-pallets` needs full `prepare` → `prepare_rust` → `save-cache` wiring manually
- `no_std` jobs and `android` jobs in lib_circuits-internal / lib-garble-rs-internal / wallet-app-internal have manual cargo calls outside the build actions and need `save-cache` added there too
