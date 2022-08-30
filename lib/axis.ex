defmodule Axis.CLI do
  alias Axis.Utils, as: Utils
  # alias Axis.Services.SSHService, as: SSHService
  # alias Axis.Services.TasksService, as: TasksService
  # alias Axis.Services.ServerService, as: ServerService
  # alias Axis.Services.ProjectService, as: ProjectService
  alias Axis.Services.HostService, as: HostService
  alias Axis.Module.Driver, as: GitDriver

  # alias Axis.Services.Email.BackupEnvService, as: BackupEnvService
  # alias Axis.Mailer, as: Mailer

  @rootDir File.cwd!()

  @spec main([binary]) :: :ok | list | {:error, atom}
  def main(args \\ []) do
    try do
      optimus =
        Optimus.new!(
          name: "axis",
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

      {opts, args} = Optimus.parse!(optimus, args)

      case List.first(opts) do
        :deploy ->
          with %{args: args} <- args do
            args.branch |> deploy()
          end

        :init ->
          init()
      end
    catch
      # refactor with method for to parse of error
      {:configException, errors} ->
        with do
          errors =
            errors
            |> Enum.map(fn error ->
              [message, key] = Tuple.to_list(error)

              key = key |> String.replace("#/", "") |> String.split("/") |> List.last()

              [key, message]
            end)

          if {:unix, :linux} == :os.type(),
            do: Axis.Outputs.banner(:configError)

          Prompt.table([["json key", "message error"]] ++ errors, header: true)
        end
    end
  end

  defp deploy(branch) do
    with {:ok, file} <- File.open(Path.join([@rootDir, ".deployrc"]), [:read]) do
      file
      |> IO.read(:all)
      |> Utils.json_decode(:config)
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
        Axis.DeployResource
      )

    {:ok, file} = File.open(".deployrc", [:write])
    IO.write(file, deployrc)
    File.close(file)
  end

  defp start(%{repository: repository} = config) do
    Application.put_env(:ex_deployer, :config, config)

    driver = repository.driver |> GitDriver.import()

    {:ok, remotes} = driver.get_remote_url(repository)

    if !driver.tag_exist(repository) do
      throw("the informed tag does not exist")
    end

    HostService.hosts(remotes)
  end
end
