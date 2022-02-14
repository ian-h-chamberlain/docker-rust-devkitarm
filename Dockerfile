FROM buildpack-deps:buster as builder

WORKDIR /usr/src
RUN git clone --depth=1 https://github.com/Meziu/rust-horizon.git

# Install some additional tools required for building Rust.
RUN apt-get update -y && apt-get install -y \
    cmake ninja-build

WORKDIR /usr/src/rust-horizon
# Separate step to create a docker commit for submodule updates and building boostrap
RUN ./x.py -v || true
RUN ./x.py -v setup user
# --stage 0 just makes the build faster, really we should probably use --stage=2
RUN ./x.py -v dist --stage=0 \
    rustc rust-std rust-src cargo clippy rustfmt

FROM devkitpro/devkitarm

COPY --from=builder /usr/src/rust-horizon/build/dist /tmp/dist

CMD [ "rustc", "--version" ]
