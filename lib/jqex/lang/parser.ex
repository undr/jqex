defmodule JQex.Lang.Parser do
  import JQex.Lang.Lexer

  def parse(source) do
    case source |> tokenize |> :jq_parser.parse do
      { :ok, parse_result } ->
        { :ok, parse_result }

      { :error, { line_number, _, errors } } ->
        { :error, %{ errors: [
          %{ "message" => "JQex: #{errors} on line #{line_number}", "line_number" => line_number }
        ] } }
    end
  end
end
