ARG ALPINE_VERSION=3.12.1
ARG ELIXIR_VERSION=1.11.2
ARG ERLANG_VERSION=23.1.3

#
# Builder Stage
#
# This stage is similar to a development environment. All tools and compile-time
# dependencies are packed here. You should be able to use this stage to run a
# developer workflow in Docker, using:
#
#     $ docker build -t my_builder --target=builder .
#     $ docker run -ti --mount type=bind,source="$PWD",target=/tmp -w /tmp \
#         my_builder /bin/sh
#
# NOTE that you have to replace the XXX with the Hex organization auth keys
# provided to you. More info at https://hexdocs.pm/hex/Mix.Tasks.Hex.Organization.html.
#

FROM hexpm/elixir:$ELIXIR_VERSION-erlang-$ERLANG_VERSION-alpine-$ALPINE_VERSION as builder

RUN mix local.hex --force \
  && mix local.rebar --force

RUN apk add --no-cache 'build-base=~0.5' \
  && apk add --no-cache 'git=~2.26' \
  && apk add --no-cache 'npm=~12.18' \
  && apk add --no-cache 'python3=~3.8' \
  && rm -rf /var/cache/apk/*

ENTRYPOINT ["sleep", "infinity"]

#
# Release Stage
#
# This stage builds an Elixir Release ready to be distributed. You can use the
# following commands to build the release in a container and extract it later:
#
#     $ docker build  -t my_release --target=release .
#     $ CONTAINER_ID=$(docker create my_release)
#     $ docker cp $CONTAINER_ID:/tmp/out my_release
#     $ docker rm -v $CONTAINER_ID
#
# Keep in mind that the release can only be run in targets that use the same
# operating system (OS) distribution and version as the builder stage.
#
# For more information check https://hexdocs.pm/phoenix/releases.html#containers.
#

FROM builder as release

ARG MIX_ENV

WORKDIR /tmp

ENV MIX_ENV=${MIX_ENV:-prod}

COPY config config
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV \
  && mix deps.compile

COPY assets/package.json assets/package-lock.json ./assets/
RUN npm install --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets assets
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

COPY lib lib
COPY rel rel
RUN mix do compile, release --path out

#
# Default Stage
#
# This stage packages the release built in the previous stage with the minimum
# system requirements to run it. This stage is the one used when running the
# project in Docker environment (Docker-compose, Swarm, ECS, Kubernetes, etc).
#
# We can build the image an run it using:
#
#     $ docker build -t discuss .
#     $ docker run discuss
#
# We can also start iex (or any other valid release command) using:
#
#     $ docker run -it discuss start_iex
#

FROM alpine:$ALPINE_VERSION AS default

WORKDIR /opt

RUN apk add --no-cache 'ncurses=~6.2' \
  && apk add --no-cache 'openssl=~1.1' \
  && rm -rf /var/cache/apk/*

COPY --from=release /tmp/out/ ./

ENTRYPOINT ["bin/discuss"]
CMD ["start"]