defmodule Axis.Services.ServerService do
  alias Axis.Services.SSHService, as: SSHService

  @spec has(pid, binary, atom) :: boolean
  def has(conn, path, type) do
    stdout =
      case type do
        :directory ->
          with do
            {:ok, stdout} = SSHService.execute(conn, "[ -d '#{path}' ] &&  echo 1 || echo 0")
            stdout
          end

        :file ->
          with do
            {:ok, stdout} = SSHService.execute(conn, "[ -f '#{path}' ] &&  echo 1 || echo 0")
            stdout
          end
      end
      |> String.to_integer()

    if stdout == 1, do: true, else: false
  end

  def cp_env(conn, content, dir) do
    SSHService.execute(conn, "echo #{content} >> #{Path.join([dir, ".env"])}")
  end
end
