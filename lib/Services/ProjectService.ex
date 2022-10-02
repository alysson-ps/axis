defmodule Axis.Services.ProjectService do
  alias Axis.Services.SSHService, as: SSHService
  alias Axis.Services.ServerService, as: ServerService
  alias Axis.Services.Email.BackupEnvService, as: BackupEnvService
  alias Axis.Mailer, as: Mailer

  def enviroment(exists, dir, conn) do
    # SSHService.execute(conn, "rm -r #{dir}")
    config = Application.fetch_env!(:axis, :config)

    %{env: %{backup: %{active: active, send_to: emails}}} = config

    if exists do
      env = Path.join([dir, ".env"])

      if ServerService.has(conn, env, :file) do
        {:ok, content} =
          SSHService.execute(
            conn,
            "cat #{env}",
            :noremove
          )

        if active do
          Enum.each(emails, fn email ->
            content
            |> String.replace("\n", "<br>")
            |> BackupEnvService.backup_env_email(email)
            |> Mailer.deliver_now()
          end)
        end

        {:ok, file} = ServerService.create_temp_file(conn, content, "laravel-ci-env")

        file |> String.replace("\n", "")
      end
    end
  end
end
