## Builder Stage

# We use the latest Rust stable release as base image
###FROM rust:latest AS builder
FROM lukemathwalker/cargo-chef:latest AS chef

# Switch our working directory to 'app'
# Docker will create the folder if it doesn't already exist
WORKDIR /app 

# Install the required system dependencies for our linking configuration
RUN apt update && apt install lld clang -y

FROM chef AS planner

# Copy all file from our working environment to our Docker image
COPY . .

# Compute a lock-like file for our project
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder

COPY --from=planner /app/recipe.json recipe.json
# Build out project dependencies, not our application
RUN cargo chef cook --release --recipe-path recipe.json

# Up to this point, if our dependency tree stays the same,
# all layers should be cached.
COPY . .

# Force sqlx to look at saved metadata instead of querying the live database
ENV SQLX_OFFLINE=true

# Build the binary
RUN cargo build --release --bin zero2prod

## Runtime Stage

FROM debian:bookworm-slim AS runtime

WORKDIR /app

# Install OpenSSL - it is linked to some of our dependencies
# Install ca-certificate - it's needed to verify TLS certs when using HTTPS
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends openssl ca-certificates \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Copy compiled binary from the builder environment
COPY --from=builder /app/target/release/zero2prod zero2prod

# We also need to copy the configuration file
COPY configuration configuration

# Set our app environment to production
ENV APP_ENVIRONMENT=production

# When 'docker run' is executed, launch the binary
ENTRYPOINT ["./zero2prod"]