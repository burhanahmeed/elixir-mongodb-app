FROM elixir:1.15.2-erlang-26.0.1-alpine-3.18.2 as build

ADD . /app
WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix deps.compile

EXPOSE 8081

CMD ["mix"]