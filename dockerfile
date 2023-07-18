FROM elixir:1.15.1 as builder
WORKDIR /app
COPY . .
ENV MIX_ENV=prod
COPY lib ./lib
COPY mix.exs .
COPY mix.lock .
COPY config/prod.env.exs config/

RUN mix local.rebar --force \
    && mix local.hex --force \
    && mix deps.get \
    && mix release

# ---- Application Stage ----
# RUN apk add --no-cache --update bash openssl
CMD ["_build/prod/rel/todo_app/bin/todo_app", "start"]