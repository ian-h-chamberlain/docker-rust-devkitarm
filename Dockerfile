FROM buildpack-deps:buster as builder

# Install some additional tools required for building Rust.
RUN apt-get update -y && apt-get install -y \
    cmake ninja-build

WORKDIR /usr/src
# Commit date is old enough to get the LLVM artifacts downloaded from upstream CI
RUN git clone --shallow-since=2021-12-01 --recurse-submodules https://github.com/Meziu/rust-horizon.git

WORKDIR /usr/src/rust-horizon
COPY config.toml /usr/src/rust-horizon/
RUN ./x.py build
RUN ./x.py dist

FROM devkitpro/devkitarm

COPY --from=builder /usr/src/rust-horizon/build/dist /tmp/dist

CMD [ "rustc", "--version" ]
