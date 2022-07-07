defmodule ExDeployer.Services.SSHService do
  @spec connect(%{
          :host => String.t(),
          :password => String.t(),
          :user => String.t(),
          optional(map) => map
        }) :: pid | nil
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

  @spec execute(pid, String.t()) :: {:error, atom} | {:ok, binary}
  def execute(conn, command) do
    case SSHEx.run(conn, command) do
      {:ok, output, 0} ->
        with output <- output |> String.replace("\n", "") do
          {:ok, output}
        end

      {:ok, _output, 1} ->
        with do
          {:ok, :warning}
        end

      {:error, reason} ->
        with do
          {:error, reason}
        end
    end
  end

  @spec execute(any, any, :noremove) :: {:error, any} | {:ok, any}
  def execute(conn, command, _opt = :noremove) do
    case SSHEx.run(conn, command) do
      {:ok, output, 0} ->
        with do
          {:ok, output}
        end

      {:ok, _output, 1} ->
        with do
          {:ok, :warning}
        end

      {:error, reason} ->
        with do
          {:error, reason}
        end
    end
  end
end
