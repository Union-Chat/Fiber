use Mix.Config

# Configures Elixir's Logger
config :logger,
       :console,
       format: "$time $metadata[$level] $message\n"

# Fiber cfg
config :fiber,
       int_port: 6669,
       ext_port: 8880,
       redis_dsn: "redis://:password@127.0.0.1:6379/0",
       cookie: "use something *very* long. Used to secure communications between nodes across network",
       password: "use something also long here. Used for internal client authentication"
