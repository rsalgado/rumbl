Code.require_file "../../rumbl/test/rumbl/info_sys/backends/http_client.exs", __DIR__
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Rumbl.Repo, :manual)
