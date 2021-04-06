FROM elixir:1.11.3-alpine

WORKDIR /app

COPY . ./

RUN mix deps.get && \
  mix deps.compile

CMD ["mix", "test"]