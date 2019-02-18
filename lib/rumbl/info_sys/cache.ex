defmodule Rumbl.InfoSys.Cache do
  use GenServer

  def start_link(opts) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  # Client (API)

  def put(name \\ __MODULE__, key, value) do
    entry = {key, value}
    true = :ets.insert(tab_name(name), entry)
    :ok
  end

  def fetch(name \\ __MODULE__, key) do
    value = :ets.lookup_element(tab_name(name), key, 2)
    {:ok, value}
  rescue
    ArgumentError -> :error
  end

  # Server implementation and callbacks

  @clear_interval :timer.seconds(60)

  def init(opts) do
    state = %{
      interval: opts[:clear_interval] || @clear_interval,
      timer: nil,
      table: new_table(opts[:name])
    }

    {:ok, schedule_clear(state)}
  end

  def handle_info(:clear, state) do
    :ets.delete_all_objects(state.table)
    {:noreply, schedule_clear(state)}
  end

  def schedule_clear(state) do
    %{state | timer:  Process.send_after(self(), :clear, state.interval)}
  end

  def new_table(name) do
    name
    |> tab_name()
    |> :ets.new([:set, :named_table, :public,
                 read_concurrency: true, write_concurrency: true])
  end

  defp tab_name(name), do: :"#{name}_cache"

end
