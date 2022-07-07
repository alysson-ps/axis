defmodule ExDeployer.Services.HostService do
  alias ExDeployer.Outputs, as: Outputs
  alias ExDeployer.Services.ProjectService, as: ProjectService
  alias ExDeployer.Services.ServerService, as: ServerService
  alias ExDeployer.Services.SSHService, as: SSHService
  alias ExDeployer.Services.TasksService, as: TasksService

  def hosts(%{project: project, hosts: hosts, repository: %{branch: branch}} = _config, urls) do
    dir = project.directory

    vars = %{
      "{{PROJECT_DIR}}" => dir,
      "{{URL_REPOSITORY}}" => urls.deploy,
      "{{URL_REPOSITORY_ORIGIN}}" => urls.origin,
      "{{BRANCH}}" => branch
    }

    hosts
    |> Enum.map(fn {host, %{user: user, password: password, tasks: tasks} = _value} ->
      Outputs.info("Deploying #{project.name} to #{host} - branch: #{branch}")

      conn =
        SSHService.connect(%{
          host: host,
          user: user,
          password: password
        })

      exists =
        if is_nil(conn),
          do: throw("error connecting to server"),
          else: conn |> ServerService.has(dir, :directory)

      Outputs.info("the project exists in server: #{exists}")
      Outputs.info("saving dotenv (.env) in file temp", :newline)

      env =
        ProjectService.enviroment(
          exists,
          dir,
          conn
        )

      tasks |> TasksService.run(vars, conn)

      if !is_nil(env) do
        Outputs.info("recovering dotenv")

        ProgressBar.render_spinner([frames: :braille], fn ->
          get_enviroment(env, conn, dir)
        end)
      else
        {:ok, _} = SSHService.execute(conn, "cp #{dir}/.env.example #{dir}/.env")
        {:ok, _} = SSHService.execute(conn, "php #{dir}/artisan key:generate")
      end

      ProjectService.storage_perms(conn, dir)

      Outputs.info("Closing ssh connection")
      Process.exit(conn, :normal)
    end)
  end

  defp get_enviroment(path, conn, dir) do
    File.read!(path)
    |> String.split("\n")
    |> Enum.map(fn var ->
      ServerService.cp_env(conn, var, dir)
    end)
  end
end
