defmodule Axis.Services.HostService do
  alias Axis.Outputs, as: Outputs
  alias Axis.Services.ServerService, as: ServerService
  alias Axis.Services.SSHService, as: SSHService
  alias Axis.Services.TasksService, as: TasksService

  def hosts(urls) do
    config = Application.fetch_env!(:axis, :config)

    %{
      project: project,
      hosts: hosts,
      repository: %{branch: branch},
      strategy: strategy,
      debug: debug
    } = config

    dir = project.directory

    vars = %{
      "{{URL_REPOSITORY}}" => urls.deploy,
      "{{URL_REPOSITORY_ORIGIN}}" => urls.origin,
      "{{BRANCH}}" => branch,
      "{{PROJECT_DIR}}" => dir
    }

    hosts
    |> Enum.each(fn {host, %{user: user, password: password, tasks: tasks} = values} ->
      Outputs.info("Deploying #{project.name} to #{host} - branch: #{branch}")

      {vars, dir} =
        if Map.has_key?(values, :directory),
          do: {%{vars | "{{PROJECT_DIR}}" => values.directory}, values.directory},
          else: {vars, dir}

      # connection ssh
      conn =
        SSHService.connect(%{
          host: host,
          user: user,
          password: password
        })

      if is_nil(conn), do: throw("error connecting to server")

      # verify if project exists
      exists = conn |> ServerService.has(dir, :directory)

      Outputs.info("the project exists in server: #{exists}")

      tasks
      |> TasksService.run(
        vars,
        conn,
        strategy,
        dir,
        %{
          project_exist: exists,
          directory: dir,
          debug: debug
        }
      )

      Outputs.info("Closing ssh connection")
      Process.exit(conn, :normal)
    end)
  end

  def hosts_async(urls) do
    config = Application.fetch_env!(:axis, :config)

    %{
      project: project,
      hosts: hosts,
      repository: %{branch: branch},
      strategy: strategy,
      debug: debug
    } = config

    dir = project.directory

    vars = %{
      "{{URL_REPOSITORY}}" => urls.deploy,
      "{{URL_REPOSITORY_ORIGIN}}" => urls.origin,
      "{{BRANCH}}" => branch,
      "{{PROJECT_DIR}}" => dir
    }

    hosts
    |> Enum.each(fn {host, %{user: user, password: password, tasks: tasks} = values} ->
      spawn(fn ->
        Outputs.info("Deploying #{project.name} to #{host} - branch: #{branch}")

        {vars, dir} =
          if Map.has_key?(values, :directory),
            do: {%{vars | "{{PROJECT_DIR}}" => values.directory}, values.directory},
            else: {vars, dir}

        # connection ssh
        conn =
          SSHService.connect(%{
            host: host,
            user: user,
            password: password
          })

        if is_nil(conn), do: throw("error connecting to server")

        # verify if project exists
        exists = conn |> ServerService.has(dir, :directory)

        Outputs.info("the project exists in server: #{exists}")

        tasks
        |> TasksService.run(
          vars,
          conn,
          strategy,
          dir,
          %{
            project_exist: exists,
            directory: dir,
            debug: debug
          }
        )

        Outputs.info("Closing ssh connection")
        Process.exit(conn, :normal)
      end)
      |> Process.info()
      |> IO.inspect()
    end)
  end
end
