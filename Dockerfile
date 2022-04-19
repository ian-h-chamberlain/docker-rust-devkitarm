# Builder image, still needs devkitARM for building C code
FROM devkitpro/devkitarm as builder

# Install some additional tools required for building Rust.
RUN apt-get update -y && apt-get install -y \
    cmake gcc g++ libssl-dev ninja-build

ARG FORK=AzureMarker/rust-horizon
ARG BRANCH=feature/horizon-threads
# Commit old enough to see upstream rust-lang/rust
ARG SHALLOW_SINCE="2022-03-01"

WORKDIR /tmp/rust-src
# Clone as little as possible. The rust repo (and LLVM submodule) are *big*.
RUN git clone \
    --shallow-since=${SHALLOW_SINCE} --recurse-submodules --shallow-submodules \
    --branch ${BRANCH} https://github.com/${FORK}.git .

# Target-specific flags for building compiler_builtins. Possible not needed if
# upstreamed to cc-rs, but for now needs this as a workaround.
ENV CFLAGS_armv6k_nintendo_3ds="-mfloat-abi=hard -mtune=mpcore -mtp=soft -march=armv6k"

COPY config.toml .
RUN --mount=type=cache,target=/tmp/rust-src/build,sharing=locked \
    python3 x.py build && \
    python3 x.py install

# Use latest cargo-3ds from git
RUN cargo install --git https://github.com/Meziu/cargo-3ds.git

# Main image, so we don't need to bring along the rustbuild repo + extra artifacts
FROM devkitpro/devkitarm

COPY --from=builder /usr/local /usr/local
COPY --from=builder /root/.cargo /root/.cargo

ENV PATH=/root/.cargo/bin:${DEVKITARM}/bin:${PATH}

CMD [ "rustc", "--version" ]
