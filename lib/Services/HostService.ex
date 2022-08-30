defmodule Axis.Services.HostService do
  alias Axis.Outputs, as: Outputs
  # alias Axis.Services.ProjectService, as: ProjectService
  alias Axis.Services.ServerService, as: ServerService
  alias Axis.Services.SSHService, as: SSHService
  alias Axis.Services.TasksService, as: TasksService


  def hosts(urls) do
    # get config of env elixir
    config = Application.fetch_env!(:ex_deployer, :config)
    %{project: project, hosts: hosts, repository: %{branch: branch}, strategy: strategy} = config

    dir = project.directory

    vars = %{
      "{{PROJECT_DIR}}" => dir,
      "{{URL_REPOSITORY}}" => urls.deploy,
      "{{URL_REPOSITORY_ORIGIN}}" => urls.origin,
      "{{BRANCH}}" => branch
    }

    hosts
    |> Enum.each(fn {host, %{user: user, password: password, tasks: tasks} = values} ->
      Outputs.info("Deploying #{project.name} to #{host} - branch: #{branch}")

      {vars, dir} =
        if Map.has_key?(values, :directory),
          do:
            {%{
               "{{PROJECT_DIR}}" => values.directory,
               "{{URL_REPOSITORY}}" => urls.deploy,
               "{{URL_REPOSITORY_ORIGIN}}" => urls.origin,
               "{{BRANCH}}" => branch
             }, values.directory},
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
      # Outputs.info("saving dotenv (.env) in file temp", :newline)

      # ProjectService.enviroment(
      #   exists,
      #   dir,
      #   conn
      # )

      SSHService.execute(conn, ". testerc'") |> IO.inspect()
      SSHService.execute(conn, "pwd") |> IO.inspect()


      # tasks
      # |> TasksService.run(
      #   vars,
      #   conn,
      #   strategy,
      #   %{
      #     project_exist: exists
      #   }
      # )

      # if !is_nil(env) do
      #   Outputs.info("recovering dotenv")

      #   ProgressBar.render_spinner([frames: :braille], fn ->
      #     # get_enviroment(env, conn, dir)
      #   end)
      # else
      #   {:ok, _} = SSHService.execute(conn, "cp #{dir}/.env.example #{dir}/.env")
      #   {:ok, _} = SSHService.execute(conn, "php #{dir}/artisan key:generate")
      # end

      # ProjectService.storage_perms(conn, dir)

      Outputs.info("Closing ssh connection")
      Process.exit(conn, :normal)
    end)
  end
end
