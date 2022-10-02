defmodule Axis.Services.TasksService do
  alias Axis.Utils, as: Utils
  alias Axis.Outputs, as: Outputs
  alias Axis.Services.SSHService, as: SSHService

  def run(tasks, maps_vars, conn, "clone-always", directory, %{project_exist: exist} = params) do
    Outputs.info("Running tasks", :newline)

    tasks =
      if !exist,
        do: clone_project() ++ checkout_tag() ++ tasks,
        else: checkout_tag() ++ tasks

    Enum.filter(tasks, fn task ->
      when_key = elem(task, 0) |> Map.get(:when, true)

      if is_atom(when_key),
        do: true,
        else:
          Enum.reduce(when_key, true, fn current, prev ->
            {key, valor} = current
            prev && params[key] == valor
          end)
    end)

    Enum.map(clone_always() ++ tasks, fn task ->
      task = elem(task, 0)

      command =
        if Map.get(task, :add_prefix, true),
          do: "cd #{directory} && /usr/bin/env " <> task.command,
          else: task.command

      command =
        if task.log,
          do: command <> " | tee -a Axis.log",
          else: command

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

  def run(tasks, maps_vars, conn, "checkout-tag", directory, %{project_exist: exist} = params) do
    Outputs.info("Running tasks", :newline)

    tasks =
      if !exist,
        do: clone_project() ++ checkout_tag() ++ tasks,
        else: checkout_tag() ++ tasks

    Enum.filter(tasks, fn task ->
      when_key = elem(task, 0) |> Map.get(:when, true)

      if is_atom(when_key),
        do: true,
        else:
          Enum.reduce(when_key, true, fn current, prev ->
            {key, valor} = current
            prev && params[key] == valor
          end)
    end)

    Enum.map(tasks, fn task ->
      task = elem(task, 0)

      command =
        if Map.get(task, :add_prefix, true),
          do: "cd #{directory} && /usr/bin/env " <> task.command,
          else: task.command

      command =
        if task.log,
          do: command <> " | tee -a Axis.log",
          else: command

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

      IO.inspect(command)

      SSHService.execute(conn, command)
    end)
  end

  defp checkout_tag do
    [
      {%{
         command: "git fetch deploy",
         description: "fetch all tags",
         log: false
       }},
      {%{
         command: "git checkout {{BRANCH}}",
         description: "checkout tag in projects",
         log: false
       }}
    ]
  end

  defp clone_always do
    [
      {%{
         command: "rm -r .",
         description: "remove project",
         log: false
       }},
      {%{
         command:
           "git clone --origin deploy --branch {{BRANCH}} {{URL_REPOSITORY}} {{PROJECT_DIR}}",
         description: "clone project in dir",
         log: false
       }},
      {%{
         command: "git remote add origin {{URL_REPOSITORY_ORIGIN}}",
         description: "add remote in origin in project",
         log: false
       }},
      {%{
         command: "composer install",
         description: "execute composer install",
         log: false
       }}
    ]
  end

  defp clone_project do
    [
      {%{
         command:
           "git clone --origin deploy --branch {{BRANCH}} {{URL_REPOSITORY}} {{PROJECT_DIR}}",
         description: "clone project in dir",
         log: false,
         add_prefix: false
       }},
      {%{
         command: "git --git-dir={{PROJECT_DIR}}/.git remote add origin {{URL_REPOSITORY_ORIGIN}}",
         description: "add remote in origin in project",
         log: false,
         add_prefix: false
       }}
    ]
  end
end
