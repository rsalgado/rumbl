# Since configuration is shared in umbrella projects, this file
# should only configure the :rumbl application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# Configure your database
config :rumbl, Rumbl.Repo,
  username: "postgres",
  password: "postgres",
  database: "rumbl_dev",
  hostname: "localhost",
  pool_size: 10

import_config "dev.secret.exs"
