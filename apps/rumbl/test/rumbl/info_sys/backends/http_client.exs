defmodule Rumbl.InfoSys.Test.HTTPClient do
  @wolfram_xml File.read!("test/rumbl/info_sys/fixtures/wolfram.xml")

  def request(url) do
    url = to_string(url)

    cond do
      # If the URL input has "1+1", return the fixture XML result
      String.contains?(url, "1+%2B+1") ->
        {:ok, {[], [], @wolfram_xml}}
      # Otherwise, return an XML empty result
      true ->
        {:ok, {[], [], '<queryresult></queryresult>'}}
    end
  end
end
