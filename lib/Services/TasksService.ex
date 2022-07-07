defmodule ExDeployer.Services.TasksService do
  alias ExDeployer.Utils, as: Utils
  alias ExDeployer.Outputs, as: Outputs
  alias ExDeployer.Services.SSHService, as: SSHService

  def run(tasks, maps_vars, conn) do
    Outputs.info("Running tasks", :newline)

    Enum.map(tasks, fn task ->
      task = elem(task, 0)
      command = if task.log, do: task.command <> " | tee -a exDeployer.log", else: task.command
      command = Utils.parser_vars(command, maps_vars)

      Outputs.text(
        task.description,
        prefix: "description"
      )

      Outputs.text(
        command,
        prefix: "command"
      )

      Outputs.text(
        task.log,
        endline: :newline,
        prefix: "with log"
      )

      SSHService.execute(conn, command)
    end)
  end
end
