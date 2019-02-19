defmodule Rumbl.InfoSys.Wolfram do
  import SweetXml
  alias Rumbl.InfoSys.Result

  @behaviour Rumbl.InfoSys.Backend

  @base "http://api.wolframalpha.com/v2/query"

  @impl true
  def name, do: "wolfram"


  @impl true
  def compute(query_str, opts) do
    # TODO: Continue
  end
end
