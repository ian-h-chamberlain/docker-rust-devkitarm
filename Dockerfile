FROM buildpack-deps:buster as builder

# Install some additional tools required for building Rust.
RUN apt-get update -y && apt-get install -y \
    cmake ninja-build

ARG FORK=Meziu/rust-horizon
ARG BRANCH=horizon-std

WORKDIR /usr/src
RUN git clone --depth 1 --shallow-submodules https://github.com/${FORK}.git --branch ${BRANCH}

WORKDIR /usr/src/rust-horizon
COPY config.toml .
RUN ./x.py build
RUN ./x.py install

FROM devkitpro/devkitarm

COPY --from=builder /usr/src/dist /tmp/dist

CMD [ "rustc", "--version" ]
