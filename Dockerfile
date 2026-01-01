# We use the latest Rust stable release as base image
FROM rust:1.80.1

# Switch our working directory to 'app'
# Docker will create the folder if it doesn't already exist
WORKDIR /app 

# Install the required system dependencies for our linking configuration
RUN apt update && apt install lld clang -y

# Copy all file from our working environment to our Docker image
COPY . .

# Force sqlx to look at saved metadata instead of querying the live database
ENV SQLX_OFFLINE=true

# Build the binary
RUN cargo build --release

# When 'docker run' is executed, launch the binary
ENTRYPOINT ["./target/release/zero2prod"]