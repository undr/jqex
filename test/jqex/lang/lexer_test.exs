defmodule JQex.Lang.LexerTest do
  use ExUnit.Case, async: true

  import ExUnit.TestHelpers

  # Ignored tokens
  test "WhiteSpace is ignored" do
    assert_tokens '\u0009', [] # horizontal tab
    assert_tokens '\u000B', [] # vertical tab
    assert_tokens '\u000C', [] # form feed
    assert_tokens '\u0020', [] # space
    assert_tokens '\u00A0', [] # non-breaking space
  end

  test "LineTerminator is ignored" do
    assert_tokens '\u000A', [] # new line
    assert_tokens '\u000D', [] # carriage return
    assert_tokens '\u2028', [] # line separator
    assert_tokens '\u2029', [] # paragraph separator
  end

  test "Comment is ignored" do
    assert_tokens '# some comment', []
  end

  test "IntValue" do
    assert_tokens '0',     [{ :int_value, 1, '0' }]
    assert_tokens '-0',    [{ :int_value, 1, '-0' }]
    assert_tokens '-1',    [{ :int_value, 1, '-1' }]
    assert_tokens '2340',  [{ :int_value, 1, '2340' }]
    assert_tokens '56789', [{ :int_value, 1, '56789' }]
  end

  test "FloatValue" do
    assert_tokens '0.0',      [{ :float_value, 1, '0.0' }]
    assert_tokens '-0.1',     [{ :float_value, 1, '-0.1' }]
    assert_tokens '0.1',      [{ :float_value, 1, '0.1' }]
    assert_tokens '2.340',    [{ :float_value, 1, '2.340' }]
    assert_tokens '5678.9',   [{ :float_value, 1, '5678.9' }]
    assert_tokens '1.23e+45', [{ :float_value, 1, '1.23e+45' }]
    assert_tokens '1.23E-45', [{ :float_value, 1, '1.23E-45' }]
    assert_tokens '0.23E-45', [{ :float_value, 1, '0.23E-45' }]
  end

  test "ReservedWord" do
    keywords = [
      'or', 'and', 'as', 'import', 'include', 'module', 'def', 'if', 'then', 'else',
      'elif', 'reduce', 'foreach', 'try', 'catch', 'label', 'break', '__loc__'
    ]

    Enum.each keywords, fn(keyword) ->
      assert_tokens keyword, [{ List.to_atom(keyword), 1 }]
    end
  end

  test "StringValue" do
    assert_tokens '""',           [{ :string_value, 1, '""' }]
    assert_tokens '"a"',          [{ :string_value, 1, '"a"' }]
    assert_tokens '"blah blah"',  [{ :string_value, 1, '"blah blah"' }]
    assert_tokens '"blah::blah"', [{ :string_value, 1, '"blah::blah"' }]
    assert_tokens '"\u000f"',     [{ :string_value, 1, '"\u000f"' }]
    assert_tokens '"\t"',         [{ :string_value, 1, '"\t"' }]
    assert_tokens '"\\""',        [{ :string_value, 1, '"\\""' }]
    assert_tokens '"a\\n"',       [{ :string_value, 1, '"a\\n"' }]
  end

  test "Field" do
    assert_tokens '.field_name',  [{ :field, 1, 'field_name' }]
    assert_tokens '._field_name', [{ :field, 1, '_field_name' }]
    assert_tokens '._field_001',  [{ :field, 1, '_field_001' }]
  end

  test "Format" do
    assert_tokens '@url',     [{ :format, 1, 'url' }]
    assert_tokens '@_url',    [{ :format, 1, '_url' }]
    assert_tokens '@001_url', [{ :format, 1, '001_url' }]
  end

  test "Operator" do
    operators = [
      '.', '?', '=', ';', ',', ':', '|', '+', '-', '*', '/', '%', '$', '<', '>',
      '!=', '==', '//', '|=', '+=', '-=', '*=', '/=', '//=', '<=', '>=', '..', '?//', '%='
    ]

    Enum.each operators, fn(operator) ->
      assert_tokens operator, [{ List.to_atom(operator), 1 }]
    end
  end

  test "Brace" do
    braces = ['[', '{', '(', ']', '}', ')']

    Enum.each braces, fn(brace) ->
      assert_tokens brace, [{ List.to_atom(brace), 1 }]
    end
  end

  test "Ident" do
    assert_tokens 'func',      [{:ident, 1, 'func'}]
    assert_tokens 'mod::func', [{:ident, 1, 'mod::func'}]
  end
end
