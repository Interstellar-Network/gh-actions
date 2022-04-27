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
