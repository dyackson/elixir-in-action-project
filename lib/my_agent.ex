defmodule MyAgent do
  use GenServer

  def start_link(fun) do
    GenServer.start_link(__MODULE__, fun)
  end

  @impl true
  def init(fun) do
    {:ok, fun.()}
  end

  def get(pid, fun) do
    GenServer.call(pid, {:get, fun})
  end

  def update(pid, fun) do
    GenServer.call(pid, {:update, fun})
  end

  @impl true
  def handle_call({:get, fun}, _sender, state) do
    {:reply, fun.(state), state}
  end

  @impl true
  def handle_call({:update, fun}, _sender, state) do
    {:reply, :ok, fun.(state)}
  end
end
