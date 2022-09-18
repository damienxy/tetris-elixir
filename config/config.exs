# This file is responsible for configuring your application
# and its dependencies with the aid of the Elixir Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :tetris,
  ecto_repos: [Tetris.Repo]

# Configures the endpoint
config :tetris, TetrisWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "JDuLO2PSt8zWt6LABXGz3jSzS6wZJHr3L2PTxaKnm4x8jxqLZZy5QOr1UFytD71O",
  render_errors: [view: TetrisWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Tetris.PubSub,
  live_view: [signing_salt: "S62vrm4l"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
