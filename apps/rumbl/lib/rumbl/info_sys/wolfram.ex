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
    [%Result{backend: __MODULE__, score: 95, text: to_string(answer)}]
  end

  @http_client Application.get_env(:rumbl, :wolfram)[:http_client] || :httpc
  defp fetch_xml(query) do
    {:ok, result} =
      query
      |> url()
      |> String.to_charlist()
      |> @http_client.request()
    # Extract the response body. This is slightly different and more explicit
    # than the book's code
    {_status_ln, _headers, body} = result
    body
  end

  defp url(input) do
    "#{@base}?" <>
      URI.encode_query(appid: id(), input: input, format: "plaintext")
  end

  defp id(), do: Application.get_env(:rumbl, :wolfram)[:app_id]
end
