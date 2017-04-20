defmodule JQex.Lang.ParserTest do
  use ExUnit.Case, async: true

  import ExUnit.TestHelpers

  test "Report error with message" do
    assert_parse "a)", %{ errors: [%{ "message" => "JQex: syntax error before: ')' on line 1", "line_number" => 1 }] }, :error
  end

  test "Handle unicode in string values" do
    assert_parse ~S["é"], %{ kind: :Document, expressions: ["é"] }
  end

  test "Import" do
    assert_parse ~S[import "data" as $d; .], %{
      kind: :Document,
      expressions: [%{ kind: :IdentityExpression }],
      imports: [%{ kind: :Import, as: "d", from: "data", json: true }]
    }

    assert_parse ~S[import "data" as d; .], %{
      kind: :Document,
      expressions: [%{ kind: :IdentityExpression }],
      imports: [%{ kind: :Import, as: "d", from: "data", json: false }]
    }

    #                                 -> ----------------
    # assert_parse ~S[import "data" as d { search: "./" }; .], %{
    #   kind: :Document,
    #   expressions: [%{ kind: :IdentityExpression }],
    #   imports: [%{ kind: :Import, as: "d", from: "data", json: false, metadata: {} }]
    # }
  end

  test "Function definitions" do
    assert_parse ~S[def a: 0;], %{
      kind: :Document,
      definitions: [%{ kind: :FuncDefinition, arguments: [], body: [0], name: "a" }]
    }

    assert_parse ~S[def a(arg1; arg2): 0;], %{
      kind: :Document,
      definitions: [%{ kind: :FuncDefinition, arguments: ["arg1", "arg2"], body: [0], name: "a" }]
    }
  end

  test "try/catch expression" do
    assert_parse "try .x catch .", %{
      kind: :Document,
      expressions: [%{
        kind: :TryExpression,
        block: [%{ kind: :IndexExpression, key: "x", optional: false }],
        handler: [%{ kind: :IdentityExpression }]
      }]
    }

    assert_parse "try .x", %{
      kind: :Document,
      expressions: [%{
        kind: :TryExpression,
        block: [%{ kind: :IndexExpression, key: "x", optional: false }]
      }]
    }

    assert_parse ".?", %{
      kind: :Document,
      expressions: [%{
        kind: :TryExpression,
        block: %{ kind: :IdentityExpression }
      }]
    }
  end

  test "Operators" do
    assert_parse ".x = 1", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_assign,
        input: %{ kind: :IndexExpression, key: "x", optional: false },
        arguments: [1]
      }]
    }

    assert_parse ".a |= .", %{
      kind: :Document,
      expressions: [
        %{
          kind: :FuncCallExpression,
          name: :_modify,
          input: %{ kind: :IndexExpression, key: "a", optional: false },
          arguments: [%{ kind: :IdentityExpression }]
        }
      ]
    }

    assert_parse ".a + .b", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_plus,
        input: %{ kind: :IndexExpression, key: "a", optional: false },
        arguments: [%{ kind: :IndexExpression, key: "b", optional: false }]
      }]
    }

    assert_parse ".a += .b", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_modify,
        input: %{ kind: :IndexExpression, key: "a", optional: false },
        arguments: [%{
          kind: :FuncCallExpression,
          name: :_plus,
          input: %{ key: "a", kind: :IndexExpression, optional: false },
          arguments: [%{ key: "b", kind: :IndexExpression, optional: false }]
        }]
      }]
    }

    assert_parse "-.a", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_negate,
        input: %{ kind: :IndexExpression, key: "a", optional: false },
        arguments: []
      }]
    }

    assert_parse ".a - .b", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_minus,
        input: %{ kind: :IndexExpression, key: "a", optional: false },
        arguments: [%{ kind: :IndexExpression, key: "b", optional: false }]
      }]
    }

    assert_parse ".a -= .b", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_modify,
        input: %{ kind: :IndexExpression, key: "a", optional: false },
        arguments: [%{
          kind: :FuncCallExpression,
          name: :_minus,
          input: %{ kind: :IndexExpression, key: "a", optional: false },
          arguments: [%{ key: "b", kind: :IndexExpression, optional: false }]
        }]
      }]
    }

    assert_parse ".a * .b", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_multiply,
        input: %{ kind: :IndexExpression, key: "a", optional: false },
        arguments: [%{ kind: :IndexExpression, key: "b", optional: false }]
      }]
    }

    assert_parse ".a *= .b", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_modify,
        input: %{ kind: :IndexExpression, key: "a", optional: false },
        arguments: [%{
          kind: :FuncCallExpression,
          name: :_multiply,
          input: %{ key: "a", kind: :IndexExpression, optional: false },
          arguments: [%{ key: "b", kind: :IndexExpression, optional: false }]
        }]
      }]
    }

    assert_parse ".a / .b", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_divide,
        input: %{ kind: :IndexExpression, key: "a", optional: false },
        arguments: [%{ kind: :IndexExpression, key: "b", optional: false }]
      }]
    }

    assert_parse ".a /= .b", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_modify,
        input: %{ kind: :IndexExpression, key: "a", optional: false },
        arguments: [%{
          kind: :FuncCallExpression,
          name: :_divide,
          input: %{ key: "a", kind: :IndexExpression, optional: false },
          arguments: [%{ key: "b", kind: :IndexExpression, optional: false }]
        }]
      }]
    }

    assert_parse ".a % .b", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_mod,
        input: %{ kind: :IndexExpression, key: "a", optional: false },
        arguments: [%{ kind: :IndexExpression, key: "b", optional: false }]
      }]
    }

    assert_parse ".a %= .b", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_modify,
        input: %{ kind: :IndexExpression, key: "a", optional: false },
        arguments: [%{
          kind: :FuncCallExpression,
          name: :_mod,
          input: %{ kind: :IndexExpression, key: "a", optional: false },
          arguments: [%{ key: "b", kind: :IndexExpression, optional: false }]
        }]
      }]
    }

    assert_parse ".a == .b", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_equal,
        input: %{ kind: :IndexExpression, key: "a", optional: false },
        arguments: [%{ kind: :IndexExpression, key: "b", optional: false }]
      }]
    }

    assert_parse ".a != .b", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_notequal,
        input: %{ kind: :IndexExpression, key: "a", optional: false },
        arguments: [%{ kind: :IndexExpression, key: "b", optional: false }]
      }]
    }

    assert_parse ".a < .b", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_less,
        input: %{ kind: :IndexExpression, key: "a", optional: false },
        arguments: [%{ kind: :IndexExpression, key: "b", optional: false }]
      }]
    }

    assert_parse ".a > .b", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_greater,
        input: %{ kind: :IndexExpression, key: "a", optional: false },
        arguments: [%{ kind: :IndexExpression, key: "b", optional: false }]
      }]
    }

    assert_parse ".a <= .b", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_lesseq,
        input: %{ kind: :IndexExpression, key: "a", optional: false },
        arguments: [%{ kind: :IndexExpression, key: "b", optional: false }]
      }]
    }

    assert_parse ".a >= .b", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :_greatereq,
        input: %{ kind: :IndexExpression, key: "a", optional: false },
        arguments: [%{ kind: :IndexExpression, key: "b", optional: false }]
      }]
    }
  end

  test "Compound expressions" do
    assert_parse "(.a, .b, 3)", %{
      kind: :Document,
      expressions: [%{
        kind: :CompoundExpression,
        children: [
          %{ kind: :IndexExpression, key: "a", optional: false },
          %{ kind: :IndexExpression, key: "b", optional: false },
          3
        ]
      }]
    }

    assert_parse "(.a, .b)", %{
      kind: :Document,
      expressions: [%{
        kind: :CompoundExpression,
        children: [
          %{ kind: :IndexExpression, key: "a", optional: false },
          %{ kind: :IndexExpression, key: "b", optional: false }
        ]
      }]
    }

    # TODO: Perhaps, it should unfold to flat expression. `(.a, (.b, 3))` => `(.a, .b, 3)`
    # assert_parse "(.a, (.b, 3))", %{
    #   kind: :Document,
    #   expressions: [%{
    #     kind: :CompoundExpression,
    #     children: [
    #       %{ kind: :IndexExpression, key: "a", optional: false },
    #       %{ kind: :IndexExpression, key: "b", optional: false },
    #       3
    #     ]
    #   }]
    # }

    # TODO: Handle of parentheseless compound node, like: `.x, .y, .z`
    # assert_parse ".a, .b, 3", %{
    #   kind: :Document,
    #   expressions: [%{
    #     kind: :CompoundExpression,
    #     children: [
    #       %{ kind: :IndexExpression, key: "a", optional: false },
    #       %{ kind: :IndexExpression, key: "b", optional: false },
    #       3
    #     ]
    #   }]
    # }
  end

  test "Expressions sequence" do
    assert_parse ".a | .b | 3", %{
      kind: :Document,
      expressions: [
        %{ kind: :IndexExpression, key: "a", optional: false },
        %{ kind: :IndexExpression, key: "b", optional: false },
        3
      ]
    }

    assert_parse ".a | .b", %{
      kind: :Document,
      expressions: [
        %{ kind: :IndexExpression, key: "a", optional: false },
        %{ kind: :IndexExpression, key: "b", optional: false }
      ]
    }
  end

  test "Identity expression" do
    assert_parse ".", %{ kind: :Document, expressions: [%{ kind: :IdentityExpression }] }
  end

  test "Recurse expression" do
    assert_parse "..", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: :recurse,
        input: %{ kind: :IdentityExpression },
        arguments: []
      }]
    }
  end

  test "Break expression" do
    assert_parse "break $a", %{
      kind: :Document,
      expressions: [%{ kind: :BreakExpression, label: "a" }]
    }
  end

  test "Optional index expression" do
    assert_parse ". .a?", %{
      kind: :Document,
      expressions: [%{ kind: :IndexExpression, key: "a", input: %{ kind: :IdentityExpression }, optional: true }]
    }

    assert_parse ".a?", %{ kind: :Document, expressions: [%{ kind: :IndexExpression, key: "a", optional: true }] }
  end

  test "Index expression" do
    assert_parse ". .a", %{
      kind: :Document,
      expressions: [%{ kind: :IndexExpression, key: "a", input: %{ kind: :IdentityExpression }, optional: false }]
    }

    assert_parse ".a", %{ kind: :Document, expressions: [%{ kind: :IndexExpression, key: "a", optional: false }] }
  end

  test "String expression" do
    assert_parse ~S["a"], %{ kind: :Document, expressions: ["a"] }
    # TODO: Fix escaping special symbols inside string expression
    # assert_parse ~S["\"a"], %{ kind: :Document, expressions: ["\"a"] }
    # assert_parse ~S["\t"], %{ kind: :Document, expressions: ["\t"] }
  end

  test "Integer expression" do
    assert_parse "1", %{ kind: :Document, expressions: [1] }
    assert_parse "1050", %{ kind: :Document, expressions: [1050] }
    assert_parse "-1050", %{ kind: :Document, expressions: [-1050] }
  end

  test "Float expression" do
    assert_parse "1.0", %{ kind: :Document, expressions: [1.0] }
    assert_parse "1050.5", %{ kind: :Document, expressions: [1050.5] }
    assert_parse "-1050.5", %{ kind: :Document, expressions: [-1050.5] }
    # TODO: Fix exponential format
    # assert_parse "1050e10", %{ kind: :Document, expressions: [] }
    # assert_parse "1050e-10", %{ kind: :Document, expressions: [] }
  end

  test "Constant expression" do
    assert_parse "$a", %{ kind: :Document, expressions: [%{ kind: :ConstantExpression, variable: true, name: "a" }] }
    assert_parse "a", %{ kind: :Document, expressions: [%{ kind: :ConstantExpression, variable: false, name: "a" }] }
  end

  test "Function call" do
    assert_parse "c()", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: "c",
        input: %{ kind: :IdentityExpression },
        arguments: []
      }]
    }

    assert_parse "c(.a; .b)", %{
      kind: :Document,
      expressions: [%{
        kind: :FuncCallExpression,
        name: "c",
        input: %{ kind: :IdentityExpression },
        arguments: [
          %{ kind: :IndexExpression, key: "a", optional: false },
          %{ kind: :IndexExpression, key: "b", optional: false }
        ]
      }]
    }
  end
end
