defmodule ExDeployer.Outputs do
  def info(message, endline \\ "") do
    endline = parse_endline(endline)

    IO.puts(IO.ANSI.yellow() <> message <> IO.ANSI.reset() <> endline)
  end

  def text(message, opts) when is_binary(message) do
    prefix = IO.ANSI.green() <> opts[:prefix] <> IO.ANSI.reset()
    endline = parse_endline(opts[:endline]) || ""
    IO.puts("#{prefix}: " <> message <> endline)
  end

  def text(message, opts) when is_atom(message) do
    prefix = IO.ANSI.green() <> opts[:prefix] <> IO.ANSI.reset()
    endline = parse_endline(opts[:endline]) || ""
    IO.puts("#{prefix}: " <> Atom.to_string(message) <> endline)
  end

  defp parse_endline(endline) do
    case endline do
      :newline -> "\n"
      _ -> endline
    end
  end
end
