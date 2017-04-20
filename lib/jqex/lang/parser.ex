defmodule JQex.Lang.Parser do
  import JQex.Lang.Lexer

  def parse(source) do
    case source |> tokenize |> parse_tokens do
      { :ok, parse_result } ->
        { :ok, parse_result }

      { :error, { line_number, _, errors } } ->
        { :error, %{ errors: [
          %{ "message" => "JQex: #{errors} on line #{line_number}", "line_number" => line_number }
        ] } }

      { :error, reason } -> { :error, reason }
    end
  end

  defp parse_tokens({ :error, reason }) do
    { :error, reason }
  end

  defp parse_tokens({ :ok, tokens }) do
    :jq_parser.parse(tokens)
  end
end
