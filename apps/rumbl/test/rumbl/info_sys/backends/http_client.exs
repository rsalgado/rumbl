defmodule Rumbl.InfoSys.Test.HTTPClient do
  @wolfram_xml Path.join(__DIR__, ["../../", "/info_sys/fixtures/wolfram.xml"]) |> Path.expand() |> File.read!()

  def request(url) do
    url = to_string(url)

    cond do
      # If the URL input has "1 + 1", return the fixture XML result
      String.contains?(url, "1+%2B+1") ->
        {:ok, {[], [], @wolfram_xml}}
      # Otherwise, return an XML empty result
      true ->
        {:ok, {[], [], '<queryresult></queryresult>'}}
    end
  end
end
