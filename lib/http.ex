defmodule Http do
  require Logger

  # listen to port until connection
  def start_link(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("Accepting connections on port: #{port}")
    # {:ok, spawn_link(Http, :accept, [socket])}
    accept(socket)
  end

  # handle connections
  defp accept(socket) do
    {:ok, request} = :gen_tcp.accept(socket)
    serve(request)
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
