defmodule Rumbl.InfoSysTest do
  use ExUnit.Case, async: true
  alias Rumbl.InfoSys.Result

  @moduledoc """
  We solve the isolation problem by defining a stub called TestBackend.
  This module will act like our Wolfram backend, returning a response in the
  format that we expect. Since we don't use the URL query string to do actual
  work, we can use this string to identify specific types of results we want our
  test backend to fetch.
  """
  defmodule TestBackend do
    # TODO: Find out if this is gonna be needed in a future
    def start_link(query, ref, owner, limit) do
      IO.puts "This doesn't seem to be getting called. Is this necessary???"
      Task.start_link(__MODULE__, :fetch, [query, ref, owner, limit])
    end

    def name(), do: "Wolfram"

    def compute("result", _opts) do
      [%Result{backend: __MODULE__, text: "some fake result"}]
    end
    def compute("none", _opts), do: []
    def compute("timeout", _opts), do: :timer.sleep(:infinity)
    def compute("boom!", _opts), do: raise "boom!"
  end


  test "compute/2 with backend results (result)" do
    # We override the backends to use our TestBackend instead of the normal backends.
    # Then, we call compute with "result", which will ultimately trigger the
    # `compute("result", _opts)` clause of our TestBackend
    opts = [backends: [TestBackend]]
    results = Rumbl.InfoSys.compute("result", opts)
    assert  results == [%Result{backend: TestBackend, text: "some fake result"}]
  end

  test "compute/2 with no backend results (none)" do
    # We override the backends to use our TestBackend instead of the normal backends.
    # Then we call compute with "none", which will ultimately trigger the
    # `compute("none", _opts)` clause of our TestBackend
    opts = [backends: [TestBackend]]
    results = Rumbl.InfoSys.compute("none", opts)
    assert results == []
  end


  test "compute/2 with timeout returns no result (timeout)" do
    # We override the backends to use our TestBackend instead of the normal backends
    # and the timeout to be just 10 ms. Then call compute with "timeout", which
    # will ultimately trigger the `compute("timeout", _opts)` clause of our TestBackend
    opts = [backends: [TestBackend], timeout: 10]
    results = []
    assert results == Rumbl.InfoSys.compute("timeout", opts)
  end

  @tag :capture_log
  test "compute/2 discards backend errors (boom!)" do
    # We override the backends to use our TestBackend instead of the normal backends.
    # Then we call compute with "boom!" which will ultimately trigger the
    # `compute("boom!", _opts)` clause of our TestBackend.
    # NOTE: The `:capture_log` tag is to avoid showing the stacktrace on the console
    opts = [backends: [TestBackend]]
    results = Rumbl.InfoSys.compute("boom!", opts)
    assert results == []
  end
end

