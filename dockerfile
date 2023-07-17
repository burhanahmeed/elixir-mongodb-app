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
FROM bitwalker/alpine-elixir:latest AS run_stage

RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

# Copy the release from the build stage
COPY --from=build /app/_build .

RUN chown -R default: ./prod
USER default

# Set the environment variables
ENV REPLACE_OS_VARS=true
ENV PORT=80
ENV MIX_ENV=prod

EXPOSE 80

CMD ["./prod/rel/todo_app/bin/todo_app", "start"]
