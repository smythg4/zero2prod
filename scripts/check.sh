#!/usr/bin/env bash

cargo fmt --check
cargo clippy -- -D warnings
cargo test
cargo sqlx prepare --workspace --check -- --all-targets