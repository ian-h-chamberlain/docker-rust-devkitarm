FROM buildpack-deps:buster as builder

# Install some additional tools required for building Rust.
RUN apt-get update -y && apt-get install -y \
    cmake ninja-build

ARG FORK=Meziu/rust-horizon
ARG BRANCH=horizon-std
# Commit old enough to see upstream rust-lang/rust
ARG SHALLOW_SINCE="2022-02-01"

WORKDIR /usr/src
RUN git clone --shallow-since=${SHALLOW_SINCE} --recurse-submodules --shallow-submodules \
        --branch ${BRANCH} \
        https://github.com/${FORK}.git

WORKDIR /usr/src/rust-horizon

COPY config.toml .
RUN ./x.py build
RUN ./x.py install

FROM devkitpro/devkitarm

COPY --from=builder /usr/src/dist /tmp/dist

CMD [ "rustc", "--version" ]
