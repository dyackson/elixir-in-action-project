defmodule Todo.System do
  def start_link do
    Supervisor.start_link(
      [
        Todo.Metrics,
        # ProcessRegistry needs to be first (probesses are started
        # synchronously) because the database is going to start workers that
        # regsister themselves.
        Todo.ProcessRegistry,
        Todo.Cache,
        Todo.Database
      ],
      strategy: :one_for_one)
  end
end
