defmodule Axis.Services.SSHService do
  def connect(%{host: host, user: user, password: password} = _args) do
    case SSHEx.connect(ip: host, user: user, password: password) do
      {:ok, conn} ->
        conn

      {:error, reason} ->
        with do
          IO.inspect(reason)
          nil
        end
    end
  end

  def execute(conn, command) do
    case SSHEx.run(conn, command) do
      {:ok, output, 0} ->
        with output <- output |> String.replace("\n", "") do
          {:ok, output}
        end

      {:ok, output, 1} ->
        with do
          IO.inspect(output)
          {:ok, :warning}
        end

      {:error, reason} ->
        with do
          {:error, reason}
        end
    end
  end

  def execute(conn, command, _opt = :noremove) do
    case SSHEx.run(conn, command) do
      {:ok, output, 0} ->
        with do
          {:ok, output}
        end

      {:ok, output, 1} ->
        with do
          IO.inspect(output)
          {:ok, :warning}
        end

      {:error, reason} ->
        with do
          {:error, reason}
        end
    end
  end
end
