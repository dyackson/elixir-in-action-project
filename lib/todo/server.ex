defmodule Todo.Server do
  use Agent, restart: :temporary

  def start_link(list_name) do
    Agent.start_link(
      fn ->
        IO.puts("Starting Server for #{list_name}")
        {list_name, Todo.Database.get(list_name) || Todo.List.new()}
      end,
      name: via_tuple(list_name)
    )
  end

  def add_entry(pid, entry) do
    Agent.cast(
      pid,
      fn {list_name, todo_list} ->
        new_list = Todo.List.add_entry(todo_list, entry)
        Todo.Database.store(list_name, new_list)
        {list_name, new_list}
      end
    )
  end

  def delete_entry(pid, entry_id) do
    Agent.cast(
      pid,
      fn {list_name, todo_list} ->
        new_list = Todo.List.delete_entry(todo_list, entry_id)
        Todo.Database.store(list_name, new_list)
        {list_name, new_list}
      end
    )
  end

  def update_entry(pid, entry) do
    Agent.cast(
      pid,
      fn {list_name, todo_list} ->
        new_list = Todo.List.update_entry(todo_list, entry)
        Todo.Database.store(list_name, new_list)
        {list_name, new_list}
      end
    )
  end

  def update_entry(pid, entry_id, lambda) do
    Agent.cast(
      pid,
      fn {list_name, todo_list} ->
        new_list = Todo.List.update_entry(todo_list, entry_id, lambda)
        Todo.Database.store(list_name, new_list)
        {list_name, new_list}
      end
    )
  end

  def entries(pid, date) do
    Agent.get(
      pid,
      fn {_list_name, todo_list} -> Todo.List.entries(todo_list, date) end
    )
  end

  defp via_tuple(list_name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, list_name})
  end
end
