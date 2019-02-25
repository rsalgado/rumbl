# Since configuration is shared in umbrella projects, this file
# should only configure the :rumbl application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :rumbl,
  ecto_repos: [Rumbl.Repo]

import_config "#{Mix.env()}.exs"
