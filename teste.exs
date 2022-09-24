with {:ok, modules} <- :application.get_key(:axis, :modules) do
  modules |> Enum.each(fn module ->
    IO.inspect (module.__info__(:functions))
  end)
end
