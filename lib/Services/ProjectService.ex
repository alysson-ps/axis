defmodule Axis.Services.ProjectService do
  @perms """
  chgrp -Rf www-data {{PROJECT_DIR}}/storage {{PROJECT_DIR}}/bootstrap &&
  chmod -Rf ug+rwx {{PROJECT_DIR}}/storage {{PROJECT_DIR}}/bootstrap &&
  chown $USER:www-data PROJECT_DIR -Rf &&
  chmod -Rf 775 {{PROJECT_DIR}}/storage {{PROJECT_DIR}}/bootstrap
  """

  alias Axis.Services.SSHService, as: SSHService
  alias Axis.Services.ServerService, as: ServerService
  alias Axis.Services.Email.BackupEnvService, as: BackupEnvService
  alias Axis.Mailer, as: Mailer
  alias Axis.Utils, as: Utils

  def storage_perms(conn, dir) do
    cmd =
      Utils.parser_vars(@perms, %{
        "{{PROJECT_DIR}}" => dir
      })

    SSHService.execute(conn, cmd)
  end

  def enviroment(exists, dir, conn) do
    # SSHService.execute(conn, "rm -r #{dir}")
    config = Application.fetch_env!(:ex_deployer, :config)

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

  # defp save_enviroment(content) do
  #   {:ok, path} = Briefly.create()
  #   File.write!(path, content)
  #   path
  # end
end
