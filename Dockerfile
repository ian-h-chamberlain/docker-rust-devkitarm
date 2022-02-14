FROM buildpack-deps:buster as builder

WORKDIR /usr/src
RUN git clone --shallow-since=2021-12-01 https://github.com/Meziu/rust-horizon.git && \
    git submodule update --init

# Install some additional tools required for building Rust.
RUN apt-get update -y && apt-get install -y \
    cmake ninja-build

WORKDIR /usr/src/rust-horizon
COPY config.toml /usr/src/rust-horizon/
RUN ./x.py -v dist

FROM devkitpro/devkitarm

COPY --from=builder /usr/src/rust-horizon/build/dist /tmp/dist

CMD [ "rustc", "--version" ]
