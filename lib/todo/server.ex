defmodule Todo.Server do
  use GenServer, restart: :temporary

  def start_link(list_name) do
    GenServer.start_link(__MODULE__, list_name, name: via_tuple(list_name))
  end

  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end

  def delete_entry(pid, entry_id) do
    GenServer.cast(pid, {:delete_entry, entry_id})
  end

  def updated_entry(pid, entry) do
    GenServer.cast(pid, {:update_entry, entry})
  end

  def updated_entry(pid, entry_id, lambda) do
    GenServer.cast(pid, {:update_entry, entry_id, lambda})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  @impl GenServer
  def init(list_name) do
    IO.puts("Starting Server for #{list_name}")
    {:ok, {list_name, Todo.Database.get(list_name) || Todo.List.new()}}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, {list_name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(list_name,new_list)
    {:noreply, {list_name, new_list}}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, {list_name, todo_list}) do
    new_list = Todo.List.delete_entry(todo_list, entry_id)
    Todo.Database.store(list_name, new_list)
    {:noreply, {list_name, new_list}}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, lambda}, {list_name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, entry_id, lambda)
    Todo.Database.store(list_name,new_list)
    {:noreply, {list_name, new_list}}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry}, {list_name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, entry)
    Todo.Database.store(list_name,new_list)
    {:noreply, {list_name, new_list}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {list_name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {list_name, todo_list}}
  end

  defp via_tuple(list_name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, list_name})
  end
end
