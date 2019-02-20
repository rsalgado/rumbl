defmodule Rumbl.InfoSys.Wolfram do
  import SweetXml
  alias Rumbl.InfoSys.Result

  @behaviour Rumbl.InfoSys.Backend

  @base "http://api.wolframalpha.com/v2/query"

  @impl true
  def name, do: "wolfram"

  @impl true
  def compute(query_str, _opts) do
    query_str
    |> fetch_xml()
    |> xpath(~x"/queryresult/pod[contains(@title, 'Result') or
                                 contains(@title, 'Definitions')]
                            /subpod/plaintext/text()")
    |> build_results()
  end

  defp build_results(nil), do: []
  defp build_results(answer) do
    [%Result{backend: name(), score: 95, text: to_string(answer)}]
  end

  defp fetch_xml(query) do
    {:ok, {_, _, body}} =
      query
      |> url()
      |> String.to_charlist()
      |> :httpc.request()

    body
  end

  defp url(input) do
    "#{@base}?" <>
      URI.encode_query(appid: id(), input: input, format: "plaintext")
  end

  defp id(), do: Application.get_env(:rumbl, :wolfram)[:app_id]
end
