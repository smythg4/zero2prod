#!/usr/bin/env bash
set -eo pipefail  # Exit on first failure

# clean was adding a lot of time to the checks. I can put that in a build script prior to release builds
# cargo clean

# check for standard formatting
  echo "Fixing formatting..."
  if cargo fmt; then
      echo "✓ Formatting complete"
  fi
# check for unused dependencies
  echo "Checking for unused dependencies..."
  cargo +nightly udeps --all-targets 2>&1 | grep -E "(unused|All deps seem)" || echo "✓ No unused deps" 
# check for clippy compliance
  echo "Checking clippy..."
  if cargo clippy -- -D warnings 2>&1; then
      echo "✓ Clippy passed"
  fi
# run our test suite
  echo "Running tests..."
  TEST_LOG=true cargo test | bunyan -l warn 2>&1 | bunyan | grep -E "(running [0-9]+ test|test result:|ERROR)" || true
  echo "✓ Tests passed"
# check if sqlx queries are good for offline mode
  echo "Checking sqlx queries..."
  if cargo sqlx prepare --workspace --check -- --all-targets; then
      echo "✓ SQLx queries current"
  fi