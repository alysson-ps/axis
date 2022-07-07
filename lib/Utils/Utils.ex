defmodule ExDeployer.Utils do
  def typeof(a) do
    cond do
      is_float(a) -> "float"
      is_number(a) -> "number"
      is_atom(a) -> "atom"
      is_boolean(a) -> "boolean"
      is_binary(a) -> "binary"
      is_function(a) -> "function"
      is_list(a) -> "list"
      is_tuple(a) -> "tuple"
      is_map(a) -> "map"
      true -> "idunno"
    end
  end

  defp keys_atoms(value) when is_binary(value) do
    # IO.inspect("with binary")
    value
  end

  defp keys_atoms(value) when is_map(value) do
    # IO.inspect("with map")
    {Map.new(value, fn {k, v} -> keys_atoms(k, v) end)}
  end

  defp keys_atoms(key, value) when is_map(value) do
    # IO.inspect("with map")
    {String.to_atom(key), Map.new(value, fn {k, v} -> keys_atoms(k, v) end)}
  end

  defp keys_atoms(key, value) when is_list(value) do
    # IO.inspect("with list")
    {String.to_atom(key), Enum.map(value, fn value -> keys_atoms(value) end)}
  end

  defp keys_atoms(key, value) do
    # IO.inspect("with boolen")
    {String.to_atom(key), value}
  end

  def json_decode(json) do
    json = json |> Jason.decode!()

    case json do
      json when is_list(json) ->
        Enum.map(json, fn value ->
          Map.new(value, fn {k, v} -> keys_atoms(k, v) end)
        end)

      json when is_map(json) ->
        Map.new(json, fn {k, v} -> keys_atoms(k, v) end)
    end
  end

  @spec parser_vars(binary, map) :: binary
  def parser_vars(string, map_vars) do
    Enum.reduce(map_vars, string, fn {key, value}, string ->
      String.replace(string, key, value)
    end)
  end
end
