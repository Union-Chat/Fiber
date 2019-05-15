use Mix.Config

# Configures Elixir's Logger
config :logger,
       :console,
       format: "$time $metadata[$level] $message\n"

# Nerve cfg
config :nerve,
       port: 8880,
       cookie: "use something *very* long. Used to secure communications between nodes across network"
