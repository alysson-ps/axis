defmodule ExDeployerTest do
  use ExUnit.Case
  doctest ExDeployer

  test "greets the world" do
    assert ExDeployer.hello() == :world
  end
end
