ExUnit.start()

defmodule ExUnit.TestHelpers do
  import ExUnit.Assertions

  alias JQex.Lang.Parser

  def assert_tokens(input, tokens) do
    case :jq_lexer.string(input) do
      { :ok, output, _ } ->
        assert output == tokens

      { :error, { _, :jq_lexer, output }, _ } ->
        assert output == tokens
    end
  end

  def assert_parse(input_string, expected_output, type \\ :ok) do
    assert Parser.parse(input_string) == { type, expected_output }
  end
end
