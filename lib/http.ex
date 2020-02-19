defmodule Http do
  require Logger

  # listen to port until connection
  def start_link(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("Accepting connections on port: #{port}")

    accept(socket)
  end

  # handle connections
  defp accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Http.TaskSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid) # assign child process to control client - to prevent all clients from crashing
    accept(socket)
  end

  # receive and send data
  defp serve(socket) do
    socket
    |> readline()
    |> writeline(socket)
    serve(socket)
  end

  defp readline(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp writeline(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
