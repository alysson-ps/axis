defmodule ExDeployer.Services.ProjectService do
  @perms """
  chgrp -Rf www-data {{PROJECT_DIR}}/storage {{PROJECT_DIR}}/bootstrap &&
  chmod -Rf ug+rwx {{PROJECT_DIR}}/storage {{PROJECT_DIR}}/bootstrap &&
  chown $USER:www-data PROJECT_DIR -Rf &&
  chmod -Rf 775 {{PROJECT_DIR}}/storage {{PROJECT_DIR}}/bootstrap
  """

  alias ExDeployer.Services.SSHService, as: SSHService
  alias ExDeployer.Services.ServerService, as: ServerService
  alias ExDeployer.Services.Email.BackupEnvService, as: BackupEnvService
  alias ExDeployer.Mailer, as: Mailer
  alias ExDeployer.Utils, as: Utils

  def storage_perms(conn, dir) do
    cmd =
      Utils.parser_vars(@perms, %{
        "{{PROJECT_DIR}}" => dir
      })

    SSHService.execute(conn, cmd)
  end

  @spec enviroment(boolean, binary, pid) :: nil | binary
  def enviroment(exists, dir, conn) do
    if exists do
      env = Path.join([dir, ".env"])

      path =
        if ServerService.has(conn, env, :file) do
          {:ok, content} =
            SSHService.execute(
              conn,
              "cat #{env}",
              :noremove
            )

          content |> BackupEnvService.backup_env_email() |> Mailer.deliver_now()

          save_enviroment(content)
        else
          nil
        end

      SSHService.execute(conn, "rm -r #{dir}")
      path
    else
      nil
    end
  end

  defp save_enviroment(content) do
    {:ok, path} = Briefly.create()
    File.write!(path, content)
    path
  end
end
