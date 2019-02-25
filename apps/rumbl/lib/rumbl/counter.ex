defmodule Rumbl.Counter do
  use GenServer

  # Client functions (API)

  def inc(pid), do: GenServer.cast(pid, :inc)

  def dec(pid), do: GenServer.cast(pid, :dec)

  def val(pid), do: GenServer.call(pid, :val)

  def start_link(initial_value) do
    GenServer.start_link(__MODULE__, initial_value)
  end

  # Server functions (callbacks)

  def init(initial_value) do
    Process.send_after(self(), :tick, 1000)
    {:ok, initial_value}
  end

  def handle_cast(:inc, val) do
    {:noreply, val + 1}
  end

  def handle_cast(:dec, val) do
    {:noreply, val - 1}
  end

  def handle_call(:val, _from, val) do
    {:reply, val, val}
  end

  def handle_info(:tick, val) when val <= 0, do:  raise "boom!"

  def handle_info(:tick, val) do
    IO.puts("tick #{val}")
    Process.send_after(self(), :tick, 1000)
    {:noreply, val - 1}
  end

end
