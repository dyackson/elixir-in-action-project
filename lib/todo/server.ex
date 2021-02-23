defmodule Todo.Server do
  use GenServer, restart: :temporary

  # :timer.secons returns an integer number of ms 10_000
  @expiry_idle_timeout :timer.seconds(10)

  def start_link(list_name) do
    GenServer.start_link(__MODULE__, list_name, name: via_tuple(list_name))
  end

  @impl true
  def init(list_name) do
    IO.puts("Starting Server for #{list_name}")
    todo_list = Todo.Database.get(list_name) || Todo.List.new()
    # if server process is idle for timeout period, call handle_info(:timeout)
    {:ok, {list_name, todo_list}, @expiry_idle_timeout}
  end

  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry});
  end

  def delete_entry(pid, entry_id) do
    GenServer.cast(pid, {:delete_entry, entry_id})
  end

  def update_entry(pid, entry) do
    GenServer.cast(pid, {:update_entry, entry})
  end

  def update_entry(pid, entry_id, lambda) do
    GenServer.cast(pid, {:update_entry, entry_id, lambda})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  @impl true
  def handle_cast({:delete_entry, entry_id}, {list_name, todo_list}) do
    new_list = Todo.List.delete_entry(todo_list, entry_id)
    Todo.Database.store(list_name, new_list)
    {:noreply, {list_name, new_list}, @expiry_idle_timeout}
  end

  @impl true
  def handle_cast({:update_entry, entry}, {list_name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, entry)
    Todo.Database.store(list_name, new_list)
    {:noreply, {list_name, new_list}, @expiry_idle_timeout}
  end

  @impl true
  def handle_cast({:add_entry, entry}, {list_name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(list_name, new_list)
    {:noreply, {list_name, new_list}, @expiry_idle_timeout}
  end

  @impl true
  def handle_cast({:update_entry, entry_id, lambda}, {list_name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, entry_id, lambda)
    Todo.Database.store(list_name, new_list)
    {:noreply, {list_name, new_list}, @expiry_idle_timeout}
  end

  @impl true
  def handle_call({:entries, date}, _sender, {list_name, todo_list}) do
    result = Todo.List.entries(todo_list, date)
    {:reply, result, {list_name, todo_list}, @expiry_idle_timeout}
  end

  @impl true
  def handle_info(:timeout, {list_name, todo_list}) do
    IO.puts("Stopping Todo.Server for #{list_name}")
    {:stop, :normal, {list_name, todo_list}}
  end

  defp via_tuple(list_name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, list_name})
  end
end
