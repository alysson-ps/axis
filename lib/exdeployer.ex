defmodule ExDeployer.CLI do
  alias ExDeployer.Utils, as: Utils
  # alias ExDeployer.Services.SSHService, as: SSHService
  # alias ExDeployer.Services.TasksService, as: TasksService
  # alias ExDeployer.Services.ServerService, as: ServerService
  # alias ExDeployer.Services.ProjectService, as: ProjectService
  # alias ExDeployer.Services.RepositoryService, as: RepositoryService
  alias ExDeployer.Services.HostService, as: HostService



  # alias ExDeployer.Services.Email.BackupEnvService, as: BackupEnvService
  # alias ExDeployer.Mailer, as: Mailer

  @rootDir File.cwd!()

  @spec main([binary]) :: :ok | list | {:error, atom}
  def main(args \\ []) do
    {opts, args} =
      Optimus.new!(
        name: "exDeployer",
        description: "The deployment helper",
        version: "1.0.0",
        author: "Alisson Santos dev.alysson@hotmail.com",
        allow_unknown_args: false,
        parse_double_dash: true,
        subcommands: [
          deploy: [
            name: "deploy",
            about: "Start process deploy",
            args: [
              branch: [
                value_name: "BRANCH",
                help: "Branch in which will be the current version of the server",
                required: true,
                parser: :string
              ]
            ]
          ],
          init: [
            name: "init",
            about: "Create config file for deploy",
            args: []
          ]
        ]
      )
      |> Optimus.parse!(args)

    case List.first(opts) do
      :deploy ->
        with %{args: args} <- args do
          args.branch |> deploy()
        end

      :init ->
        init()
    end
  end

  defp deploy(branch) do
    with {:ok, file} <- File.open(Path.join([@rootDir, ".deployrc"]), [:read]) do
      file
      |> IO.read(:all)
      |> Utils.json_decode()
      |> Map.update!(:repository, &Map.put(&1, :branch, branch))
      |> start()
    else
      {:error, _} -> IO.puts("call the command init for create a config file deploy")
    end
  end

  defp init do
    deployrc =
      Application.fetch_env!(
        :ex_deployer,
        ExDeployer.DeployResource
      )

    {:ok, file} = File.open(".deployrc", [:write])
    IO.write(file, deployrc)
    File.close(file)
  end

  defp start(%{repository: repository} = config) do
    use ExDeployer.Module.Driver, :GitLabDriver

    GitDriver.get_remote_url(repository) |> IO.inspect()

    # {:ok, remotes} = RepositoryService.get_remote_url(repository)

    # if !RepositoryService.tag_exist(repository) do
    #   throw("the informed tag does not exist")
    # end

    # HostService.hosts(config, remotes)
  end
end
