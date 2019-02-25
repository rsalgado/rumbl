# Since configuration is shared in umbrella projects, this file
# should only configure the :rumbl_web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# General application configuration
config :rumbl_web,
  ecto_repos: [Rumbl.Repo],
  generators: [context_app: :rumbl]

# Configures the endpoint
config :rumbl_web, RumblWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "d8hv8WVqkBoNSjdxxpIEZzTHckOqYCXQq+pAJzQjpF4eF8/3FKKhGgXQKvqDLs3w",
  render_errors: [view: RumblWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: RumblWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
