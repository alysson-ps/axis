defmodule Axis.Services.Email.BackupEnvService do
  import Bamboo.Email

  @spec backup_env_email(binary) :: Bamboo.Email.t()
  def backup_env_email(env) do
    new_email(
      to: "alisson@example.com",
      from: "dev@myapp.com",
      subject: "Welcome to the app.",
      html_body: "#{env}",
      text_body: "Thanks for joining!"
    )
  end
end
