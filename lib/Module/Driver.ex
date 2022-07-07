defmodule ExDeployer.Module.Driver do
  defmacro __using__(:GitLabDriver) do
    quote do
      alias ExDeployer.Module.GitDriver.GitLab, as: GitDriver
    end
  end

  defmacro __using__(:GitHubDriver) do
    quote do
      # def do
      exit("github")
      # end
    end
  end
end
