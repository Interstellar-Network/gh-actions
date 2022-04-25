# gh-actions

Contains the various actions used by all repositories for the CI.

## About caching

- [GH] DOES NOT share caches at the system level(contrary to Gitlab)
    - &rarr; It is NOT possible to cache a given crate/library between two different projects
- [general] sccache DOES NOT work with Rust incremental which is the default for dev/debug: make sure to disable it
- [general] C++: sccache and ccache by default use the full path to the source which means that the same lib in two different project will get a cache miss.
    - [local] TODO use correct sccache?ccache? option to avoid this
    - cf https://ccache.dev/manual/latest.html#_compiling_in_different_directories
    - and https://github.com/mozilla/sccache/issues/196
- [GH] https://github.com/hendrikmuhs/ccache-action is using ccache from APT which is really old, and deprecated
    - But OK for sccache b/c using prebuilt binary in this case

TODO test "Rust sccache + action-cache" VS "Rust NO sccache + action-cache"

### Bench: hot cache

ie
- `git commit --amend --no-edit --all`
- `git push --force`

NOTE for Rust: use /home/runner/.cargo/bin/cargo clippy -- -D warnings instead of cargo test (ie the first `Finished dev [unoptimized + debuginfo] target(s)`)
and make sure `ccache --show-stats` is >99% cache hits else that would mix C++ compilation time with Rust's

#### lib_garble CI: sccache v0.2.15

[hot cache]

- 1: 1m 49s
Generate project files with CMake
⏱ elapsed: 38.783 seconds
Build with CMake
⏱ elapsed: 36.759 seconds
- 2: 2m 8s
Generate project files with CMake
⏱ elapsed: 42.454 seconds
Build with CMake
⏱ elapsed: 39.522 seconds

#### lib_garble CI: ccache 4.6

hot cache

- 1:  2m 6s
Generate project files with CMake
⏱ elapsed: 46.543 seconds
Build with CMake
⏱ elapsed: 15.625 seconds
- 2:  1m 50s
Generate project files with CMake
⏱ elapsed: 42.937 seconds
Build with CMake
⏱ elapsed: 16.336 seconds

#### api_circuits: Swatinem/rust-cache + ccache for C++ (NO sccache for Rust)

hot cache

- 1: 8m 14s
/home/runner/.cargo/bin/cargo clippy -- -D warnings
Finished dev [unoptimized + debuginfo] target(s) in 2m 25s
Finished test [unoptimized + debuginfo] target(s) in 2m 14s
- 2: 7m 47s
/home/runner/.cargo/bin/cargo clippy -- -D warnings
Finished dev [unoptimized + debuginfo] target(s) in 2m 14s
Finished test [unoptimized + debuginfo] target(s) in 2m 04s

#### api_garble: Swatinem/rust-cache + ccache for C++ (NO sccache for Rust)

hot cache

- 1:  4m 52s
/home/runner/.cargo/bin/cargo clippy -- -D warnings
Finished dev [unoptimized + debuginfo] target(s) in 1m 00s
Finished test [unoptimized + debuginfo] target(s) in 1m 50s
- 2:  5m 18s
/home/runner/.cargo/bin/cargo clippy -- -D warnings
Finished dev [unoptimized + debuginfo] target(s) in 1m 06s
Finished test [unoptimized + debuginfo] target(s) in 2m 05s

#### api_circuits: no cargo cache + ccache for C++ (NO sccache for Rust)

no cache at all for Rust(no sccache, no cargo cache)

-  9m 40s
/home/runner/.cargo/bin/cargo clippy -- -D warnings
Finished dev [unoptimized + debuginfo] target(s) in 3m 36s
/home/runner/.cargo/bin/cargo check
Finished dev [unoptimized + debuginfo] target(s) in 2m 42s
/home/runner/.cargo/bin/cargo test
Finished test [unoptimized + debuginfo] target(s) in 1m 54s

#### api_garble: no cargo cache + ccache for C++ (NO sccache for Rust)

no cache at all for Rust(no sccache, no cargo cache)

- 7m 23s
/home/runner/.cargo/bin/cargo clippy -- -D warnings
Finished dev [unoptimized + debuginfo] target(s) in 2m 39s
/home/runner/.cargo/bin/cargo check
Finished dev [unoptimized + debuginfo] target(s) in 1m 49s
/home/runner/.cargo/bin/cargo test
Finished test [unoptimized + debuginfo] target(s) in 1m 50s

#### api_circuits: cargo cache custom + ccache for C++ (NO sccache for Rust)

Cache Size: ~1470 MB

- 1: 5m 26s
/home/runner/.cargo/bin/cargo clippy -- -D warnings
Finished dev [unoptimized + debuginfo] target(s) in 32.24s
/home/runner/.cargo/bin/cargo check
Finished dev [unoptimized + debuginfo] target(s) in 12.85s
/home/runner/.cargo/bin/cargo test
Finished test [unoptimized + debuginfo] target(s) in 18.42s

#### api_garble: cargo cache custom + ccache for C++ (NO sccache for Rust)

Cache Size: ~1037 MB (1087541143 B)

- 1:  4m 23s
/home/runner/.cargo/bin/cargo clippy -- -D warnings
Finished dev [unoptimized + debuginfo] target(s) in 29.93s
/home/runner/.cargo/bin/cargo check
Finished dev [unoptimized + debuginfo] target(s) in 5.30s
/home/runner/.cargo/bin/cargo test
Finished test [unoptimized + debuginfo] target(s) in 13.48s

#### api_circuits: cargo cache custom NO target/ + ccache for C++ + sccache for Rust

- 1:
/home/runner/.cargo/bin/cargo clippy -- -D warnings
Finished dev [unoptimized + debuginfo] target(s) in 2m 38s
/home/runner/.cargo/bin/cargo check
Finished dev [unoptimized + debuginfo] target(s) in 3.65s
/home/runner/.cargo/bin/cargo test
Finished test [unoptimized + debuginfo] target(s) in 1m 04s
- 2:
Finished dev [unoptimized + debuginfo] target(s) in 2m 32s
Finished dev [unoptimized + debuginfo] target(s) in 3.51s
Finished test [unoptimized + debuginfo] target(s) in 58.32s

#### api_garble: cargo cache custom NO target/ + ccache for C++ + sccache for Rust

- 1:
/home/runner/.cargo/bin/cargo clippy -- -D warnings
Finished dev [unoptimized + debuginfo] target(s) in 1m 23s
/home/runner/.cargo/bin/cargo check
Finished dev [unoptimized + debuginfo] target(s) in 3.75s
/home/runner/.cargo/bin/cargo test
Finished test [unoptimized + debuginfo] target(s) in 55.67s
- 2:
Finished dev [unoptimized + debuginfo] target(s) in 1m 24s
Finished dev [unoptimized + debuginfo] target(s) in 3.25s
Finished test [unoptimized + debuginfo] target(s) in 51.58s

#### api_circuits: rust-cache + ccache for C++ + sccache for Rust

- 1:
Finished dev [unoptimized + debuginfo] target(s) in 1m 34s
Finished dev [unoptimized + debuginfo] target(s) in 3.74s
Finished test [unoptimized + debuginfo] target(s) in 1m 04s

#### api_garble: rust-cache + ccache for C++ + sccache for Rust

- 1:
Finished dev [unoptimized + debuginfo] target(s) in 53.73s
Finished dev [unoptimized + debuginfo] target(s) in 4.47s
Finished test [unoptimized + debuginfo] target(s) in 1m 03s