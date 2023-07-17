FROM elixir:1.15.1 as build

ADD . /app
WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix compile

# Copy the production.env.exs file to the container
COPY config/prod.env.exs config/

# Build the release
RUN MIX_ENV=prod mix release

# Final stage for the production release
FROM alpine:3.14 AS run_stage

RUN apk add --no-cache bash openssl ncurses-libs

WORKDIR /app

# Copy the release from the build stage
COPY --from=build /app/_build/prod/rel/todo_app .

# Copy the Erlang runtime files
COPY --from=build /app/_build/prod/rel/todo_app/erts-* /app/erts/

# Set the environment variables
ENV REPLACE_OS_VARS=true
ENV PORT=80
ENV MIX_ENV=prod

EXPOSE 80

CMD ["bin/todo_app", "start"]
