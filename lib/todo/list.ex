defmodule Todo.List do
  defstruct auto_id: 1, entries: %{}
  # entries is a map of %{date, title}s keyed by id

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      # initial value
      %Todo.List{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(todo_list, entry) do
    id = todo_list.auto_id
    entry = Map.put(entry, :id, id)
    new_entries = Map.put(todo_list.entries, id, entry)

    %Todo.List{todo_list | entries: new_entries, auto_id: id + 1}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_id, entry} -> entry.date == date end)
    |> Enum.map(fn {_id, entry} -> entry end)
  end

  def update_entry(todo_list, id, lambda) do
    case Map.fetch(todo_list.entries, id) do
      :error ->
        todo_list

      {:ok, entry} ->
        updated_entry = %{id: ^id, title: _, date: _} = lambda.(entry)

        updated_entries = Map.put(todo_list.entries, id, updated_entry)

        %Todo.List{todo_list | entries: updated_entries}
    end
  end

  def update_entry(%Todo.List{} = todo_list, %{id: id, title: _, date: _} = updated_entry) do
    update_entry(todo_list, id, fn _ -> updated_entry end)
  end

  def delete_entry(todo_list = %Todo.List{entries: entries}, id) do
    %Todo.List{todo_list | entries: Map.delete(entries, id)}
  end
end

# Does not have to be in the same module or file as Todo.List. You can even
# implement a protocol for a Struct you did now write.
defimpl String.Chars, for: Todo.List do
  def to_string(_) do
    "#Todo.List"
  end
end

defimpl Collectable, for: Todo.List do
  # when into is called, return the appender lambda
  def into(original) do
    {original, &appender_lambda/2}
  end

  # hint = :cont , add a new one
  defp appender_lambda(todo_list, {:cont, entry}) do
    Todo.List.add_entry(todo_list, entry)
  end

  # hint = :done, done adding, return the collection
  defp appender_lambda(todo_list, :done), do: todo_list
  # hint = :halt, the operation has been cancelled
  defp appender_lambda(_todo_list, :halt), do: :ok
end
