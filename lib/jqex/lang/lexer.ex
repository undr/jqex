defmodule JQex.Lang.Lexer do
  def tokenize(input_string) when is_binary(input_string) do
    input_string |> to_char_list |> tokenize
  end

  def tokenize(input_string) do
    input_string |> :jq_lexer.string |> format_result
  end

  defp format_result({ :ok, tokens, _}) do
    { :ok, tokens }
  end

  defp format_result({ :error, { line_number, :jq_lexer, { :illegal, exp } }, _ }) do
    { :error, %{ errors: [
      %{ "message" => "JQex: Illegal expression: '#{exp}' on line #{line_number}", "line_number" => line_number }
    ] } }
  end
end
