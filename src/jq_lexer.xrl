Definitions.

% Ignored tokens
WhiteSpace          = [\x{0009}\x{000B}\x{000C}\x{0020}\x{00A0}]
_LineTerminator     = \x{000A}\x{000D}\x{2028}\x{2029}
LineTerminator      = [{_LineTerminator}]
Comment             = #[^{_LineTerminator}]*
Ignored             = {WhiteSpace}|{LineTerminator}|{Comment}

% Int Value
Digit               = [0-9]
NonZeroDigit        = [1-9]
NegativeSign        = -
IntegerPart         = {NegativeSign}?(0|{NonZeroDigit}{Digit}*)
IntValue            = {IntegerPart}

% Float Value
FractionalPart      = \.{Digit}+
Sign                = [+\-]
ExponentIndicator   = [eE]
ExponentPart        = {ExponentIndicator}{Sign}?{Digit}+
FloatValue          = {IntegerPart}{FractionalPart}|{IntegerPart}{ExponentPart}|{IntegerPart}{FractionalPart}{ExponentPart}

% String Value
HexDigit            = [0-9A-Fa-f]
EscapedUnicode      = u{HexDigit}{HexDigit}{HexDigit}{HexDigit}
EscapedCharacter    = ["\\\/bfnrt]
StringCharacter     = ([^\"{_LineTerminator}]|\\{EscapedUnicode}|\\{EscapedCharacter})
StringValue         = "{StringCharacter}*"

% Reserved words
ReservedWord        = and|or|as|import|include|module|def|if|then|else|elif|reduce|foreach|try|catch|label|break|__loc__
Operator            = \.|\?|\=|\;|\,|\:|\||\+|\-|\*|\/|\%|\$|\<|\>|\!=|==|\/\/|\|=|\+=|\-=|\*=|\/=|\/\/=|\<=|\>=|\.\.|\?\/\/|\%=
Brace               = \[|\{|\(|\]|\}|\)

Field               = \.[a-zA-Z_][a-zA-Z_0-9]*
Ident               = ([a-zA-Z_][a-zA-Z_0-9]*::)*[a-zA-Z_][a-zA-Z_0-9]*

Rules.

{Ignored}           : skip_token.
{ReservedWord}      : {token, {list_to_atom(TokenChars), TokenLine}}.
{Operator}          : {token, {list_to_atom(TokenChars), TokenLine}}.
{Brace}             : {token, {list_to_atom(TokenChars), TokenLine}}.
{IntValue}          : {token, {int_value, TokenLine, TokenChars}}.
{FloatValue}        : {token, {float_value, TokenLine, TokenChars}}.
{StringValue}       : {token, {string_value, TokenLine, TokenChars}}.

{Field}             : {token, {field, TokenLine, string:sub_string(TokenChars, 2)}}.
{Ident}             : {token, {ident, TokenLine, TokenChars}}.
@[a-zA-Z0-9_]+      : {token, {format, TokenLine, string:sub_string(TokenChars, 2)}}.

Erlang code.
