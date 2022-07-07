defmodule ExDeployer.Module.GitDriver.GitLab do
  alias ExDeployer.Utils, as: Utils
  alias ExDeployer.Http, as: HTTP

  def get_remote_url(repository) do
    HTTP.start()
    projectId = repository.project_id
    user = repository.deploy.user
    token = repository.deploy.token
    privateToken = repository.private_token

    headers = [
      Authorization: "Bearer #{privateToken}",
      Accept: "Application/json"
    ]

    case HTTP.get(Path.join(["projects"], projectId), headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        with body do
          json =
            body
            |> Utils.json_decode()

          repositoryUrl =
            json.http_url_to_repo
            |> String.replace("https://", "https://#{user}:#{token}@")

          {:ok, %{origin: json.http_url_to_repo, deploy: repositoryUrl}}
        end

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "not found"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def tag_exist(repository) do
    HTTP.start()
    privateToken = repository.private_token
    projectId = repository.project_id
    branch = repository.branch

    headers = [
      Authorization: "Bearer #{privateToken}",
      Accept: "Application/json"
    ]

    tag =
      case HTTP.get(Path.join(["projects", projectId, "repository", "tags"]), headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          with body do
            body
            |> Utils.json_decode()
            |> Enum.map(&(Map.take(&1, [:name]) |> Map.get(:name)))
          end

        {:ok, %HTTPoison.Response{status_code: 404}} ->
          {:error, "not found"}

        {:error, %HTTPoison.Error{reason: _}} ->
          {:error, "error"}
      end
      |> Enum.find(fn tag -> tag == branch end)

    !!tag
  end
end
