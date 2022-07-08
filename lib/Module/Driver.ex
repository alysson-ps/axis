defmodule Axis.Module.Driver do
  @spec import(binary) :: Axis.Module.GitDriver.GitLab
  def import(driver) do
    case driver do
      "gitlab" ->
        with do
          alias Axis.Module.GitDriver.GitLab, as: GitDriver

          GitDriver
        end
    end
  end
end
