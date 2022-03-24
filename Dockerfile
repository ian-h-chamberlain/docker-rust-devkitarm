FROM devkitpro/devkitarm as builder

# Install some additional tools required for building Rust.
RUN apt-get update -y && apt-get install -y \
    cmake gcc g++ libssl-dev ninja-build

ARG FORK=AzureMarker/rust-horizon
ARG BRANCH=feature/horizon-std
# Commit old enough to see upstream rust-lang/rust
ARG SHALLOW_SINCE="2022-03-01"

WORKDIR /usr/src
RUN git clone --shallow-since=${SHALLOW_SINCE} --recurse-submodules --shallow-submodules \
        --branch ${BRANCH} \
        https://github.com/${FORK}.git

ENV CFLAGS_armv6k_nintendo_3ds="-mfloat-abi=hard -mtune=mpcore -mtp=soft -march=armv6k"
WORKDIR /usr/src/rust-horizon

COPY config.toml .
RUN python3 x.py build
RUN python3 x.py install

FROM devkitpro/devkitarm

COPY --from=builder /usr/local /usr/local

CMD [ "rustc", "--version" ]
