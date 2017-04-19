defmodule JQex.Lang.Lexer do
  def tokenize(input_string) when is_binary(input_string) do
    input_string |> to_char_list |> tokenize
  end

  def tokenize(input_string) do
    {:ok, tokens, _} = :jq_lexer.string(input_string)
    tokens
  end
end
