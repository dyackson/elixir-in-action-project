defmodule TodoCacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache_pid} = Todo.Cache.start()
    bob_list_pid = Todo.Cache.server_process(cache_pid, "bob")

    assert bob_list_pid == Todo.Cache.server_process(cache_pid, "bob")
    assert bob_list_pid != Todo.Cache.server_process(cache_pid, "steve")
  end

  test "to-do operation" do
    {:ok, cache_pid} = Todo.Cache.start()
    bob_list_pid = Todo.Cache.server_process(cache_pid, "bob")

    date = Date.utc_today()
    title = "Dentist"
    entry = %{date: date, title: title}
    Todo.Server.add_entry(bob_list_pid, entry)
    assert [%{date: ^date, title: ^title}] = Todo.Server.entries(bob_list_pid, date)
  end
end
