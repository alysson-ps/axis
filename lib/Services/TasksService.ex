defmodule Axis.Services.TasksService do
  alias Axis.Utils, as: Utils
  alias Axis.Outputs, as: Outputs
  alias Axis.Services.SSHService, as: SSHService

  def run(tasks, maps_vars, conn, :cloneAlways) do
    Outputs.info("Running tasks", :newline)

    Enum.map(clone_always() ++ tasks, fn task ->
      task = elem(task, 0)
      command = if task.log, do: task.command <> " | tee -a Axis.log", else: task.command
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

  def run(tasks, maps_vars, conn, :checkoutTag) do
    Outputs.info("Running tasks", :newline)

    Enum.map(checkout_tag() ++ tasks, fn task ->
      task = elem(task, 0)
      command = if task.log, do: task.command <> " | tee -a Axis.log", else: task.command
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

  defp checkout_tag do
    [
      {%{
         command: "git checkout --git-dir={{PROJECT_DIR}}/.git "
       }}
    ]
  end

  defp clone_always do
    [
      {%{
         command:
           "git clone --origin deploy --branch {{BRANCH}} {{URL_REPOSITORY}} {{PROJECT_DIR}}",
         description: "clone project in dir",
         log: false
       }},
      {%{
         command: "composer install --working-dir={{PROJECT_DIR}}",
         description: "execute composer install",
         log: true
       }},
      {%{
         command:
           "git --git-dir={{PROJECT_DIR}}/.git remote add origin {{URL_REPOSITORY_ORIGIN}}",
         description: "add remote in origin in project",
         log: false
       }}
    ]
  end
end
