defmodule KeyValue do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def put(key, val) do
    GenServer.cast(__MODULE__, {:put, key, val})
  end

  def handle_call({:get, key}, _caller, map) do
    val = Map.get(map, key)
    {:reply, val, map}
  end

  def handle_cast({:put, key, val}, map)  do
    new_map = Map.put(map, key, val)
    {:noreply, new_map}
  end
end
