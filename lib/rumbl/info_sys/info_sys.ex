defmodule Rumbl.InfoSys do
  alias Rumbl.InfoSys
  alias Rumbl.InfoSys.Cache

  @backends [InfoSys.Wolfram]

  defmodule Result do
    defstruct score: 0, text: nil, url: nil, backend: nil
  end

  def compute(query, opts \\ []) do
    timeout = opts[:timeout] || 10_000
    opts = Keyword.put_new(opts, :limit, 10)
    backends = opts[:backends] || @backends

    {uncached_backends, cached_results} =
      fetch_cached_results(backends, query, opts)

    uncached_backends                           # Query the all uncached backends
    |> Enum.map(&async_query(&1, query, opts))
    |> Task.yield_many(timeout)
    |> Enum.map(fn {task, res} ->               # Take results and kill unfinished tasks
        res || Task.shutdown(task, :brutal_kill) end)
    |> Enum.flat_map(fn                         # Filter results of finished tasks
      {:ok, results} -> results
      _ -> []
    end)
    |> write_results_to_cache(query, opts)      # Cache the new results
    |> Kernel.++(cached_results)                # Concat them with old cached results
    |> Enum.sort(&(&1.score >= &2.score))
    |> Enum.take(opts[:limit])
  end

  def fetch_cached_results(backends, query, opts) do
    # Code changed slightly from the book's one in order to be more explicit.
    {uncached_backends, results} =
      Enum.reduce(
        backends,
        {[], []},
        fn backend, {uncached_backends, acc_results} ->
          cache_key = {backend.name(), query, opts[:limit]}

          # Hit cache with the composite key and either
          case Cache.fetch(cache_key) do
            {:ok, results} ->   # accum results in corresponding list
              updated_list = [results | acc_results]
              {uncached_backends, updated_list}
            :error ->           # or accum backend in corresponding list
              updated_list = [backend | uncached_backends]
              {updated_list, acc_results}
          end
        end
      )

    {uncached_backends, List.flatten(results)}
  end

  defp write_results_to_cache(results, query, opts) do
    Enum.map(results, fn(%Result{backend: backend} = result) ->
      cache_key = {backend.name(), query, opts[:limit]}
      :ok = Cache.put(cache_key, result)
      result
    end)
  end

  defp async_query(backend, query, opts) do
    Task.Supervisor.async_nolink(InfoSys.TaskSupervisor,
      backend, :compute, [query, opts], shutdown: :brutal_kill
    )
  end
end
