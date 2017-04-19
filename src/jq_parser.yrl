Nonterminals
  Document Module Imports Import ImportWhat FuncDefs FuncDef Params Param Exps Exp Compound Term Args.

Terminals
  ident string_value float_value int_value format field
  or and as import include module def if then else elif reduce foreach try catch label break __loc__
  '.' '?' '=' ';' ',' ':' '|' '+' '-' '*' '/' '%' '$' '<' '>' '!=' '==' '//' '|=' '+=' '-=' '*=' '/='
  '//=' '<=' '>=' '..' '?//' '%=' '[' '{' '(' ']' '}' ')'.

Rootsymbol Document.

Right 100 '|'.
Left 200 ','.
Right 300 '//'.
Nonassoc 400 '=' '|=' '+=' '-=' '*=' '/=' '%=' '//='.
Left 500 'or'.
Left 510 'and'.
Nonassoc 600 '!=' '==' '<' '>' '<=' '>='.
Left 710 '+'.
Left 720 '-'.
Left 730 '*'.
Left 740 '/'.
Left 750 '%'.
Nonassoc 800 '?'.
Nonassoc 810 try.
Nonassoc 820 catch.

% Document
Document -> Module Imports Exps :
  build_ast_node('Document', #{ 'module' => '$1', 'imports' => '$2', 'expressions' => '$3' }).

Document -> Module Exps : build_ast_node('Document', #{ 'module' => '$1', 'expressions' => '$2' }).
Document -> Imports Exps : build_ast_node('Document', #{ 'imports' => '$1', 'expressions' => '$2' }).
Document -> Exps : build_ast_node('Document', #{ 'expressions' => '$1' }).
Document -> Module Imports FuncDefs :
  build_ast_node('Document', #{ 'module' => '$1', 'imports' => '$2', 'definitions' => '$3' }).

Document -> Imports FuncDefs : build_ast_node('Document', #{ 'imports' => '$1', 'definitions' => '$2' }).
Document -> Module FuncDefs : build_ast_node('Document', #{ 'module' => '$1', 'definitions' => '$2' }).
Document -> FuncDefs : build_ast_node('Document', #{ 'definitions' => '$1' }).
Document -> FuncDefs Exps : build_ast_node('Document', #{ 'definitions' => '$1', 'expressions' => '$2' }).

% Module
Module -> module Exp ';' : build_ast_node('Module', #{ 'metadata' => '$2' }).

% Imports
Imports -> Import : ['$1'].
Imports -> Import Imports : ['$1'|'$2'].

% Import
Import -> ImportWhat ';' : '$1'.
Import -> ImportWhat Exp ';' : merge_nodes('$1', #{ 'metadata' => '$2' }).

% ImportWhat
ImportWhat -> import string_value as '$' ident :
  build_ast_node(
    'Import',
    #{ 'from' => extract_quoted_string_token('$2'), 'as' => extract_token('$5'), 'json' => true }
  ).

ImportWhat -> import string_value as ident :
  build_ast_node(
    'Import',
    #{ 'from' => extract_quoted_string_token('$2'), 'as' => extract_token('$4'), 'json' => false }
  ).

% FuncDefs
FuncDefs -> FuncDef          : ['$1'].
FuncDefs -> FuncDef FuncDefs : ['$1'|'$2'].

% Exp
% TODO:
% - Add `input` attribute to be able override an input of function
%   Each function has an input and arguments.
%   For example: `length/0` has zero arity and it calculates length of input.
%                `map/1` has arity equals one, that means the `map/1` has access to an argument besides an input.
%                See definition of the `map/1`: `def map(f): [.[] | f];`
%   You can access input using `.` expression.
%   Strictly talking, operator functions have arity equals one and first argument should be an input.
%   Input should be equal `.` by default.
%   Example:
%   1 + 2 => #{ kind: :FuncCallExpression, name: '_plus', input: 1, arguments: [2] }
%   length => #{
%     kind: :FuncCallExpression,
%     name: 'length',
%     input: #{ kind: IdentityExpression },
%     arguments: []
%   }
%
% - Inline func definitions
% - Variable / Symbolic Binding Operator
% - Reduce, foreach and if/then/else
% - Labels: Exp -> label '$' ident '|' Exp : build_label('$3', '$5').
Exp -> try Exps catch Exps : build_try('$2', '$4').
Exp -> try Exps           : build_try('$2').
Exp -> Exp '?'           : build_try('$1').
Exp -> Exp '=' Exp       : build_call('_assign', ['$1', '$3']).
% Exp -> Exp 'or' Exp  : build_binary('or', '$1', '$3').
% Exp -> Exp 'and' Exp : build_binary('and', '$1', '$3').
% Exp -> Exp '//' Exp  : build_binary('//', '$1', '$3').
% Exp -> Exp '//=' Exp : build_binary('//=', '$1', '$3').
Exp -> Exp '|=' Exp      : build_call('_modify', ['$1', '$3']).
Exp -> Exp '+' Exp       : build_call('_plus', ['$1', '$3']).
Exp -> Exp '+=' Exp      : build_update('_plus', '$1', '$3').
Exp -> '-' Exp           : build_call('_negate', ['$2']).
Exp -> Exp '-' Exp       : build_call('_minus', ['$1', '$3']).
Exp -> Exp '-=' Exp      : build_update('_minus', '$1', '$3').
Exp -> Exp '*' Exp       : build_call('_multiply', ['$1', '$3']).
Exp -> Exp '*=' Exp      : build_update('_multiply', '$1', '$3').
Exp -> Exp '/' Exp       : build_call('_divide', ['$1', '$3']).
Exp -> Exp '/=' Exp      : build_update('_divide', '$1', '$3').
Exp -> Exp '%' Exp       : build_call('_mod', ['$1', '$3']).
Exp -> Exp '%=' Exp      : build_update('_mod', '$1', '$3').
Exp -> Exp '==' Exp      : build_call('_equal', ['$1', '$3']).
Exp -> Exp '!=' Exp      : build_call('_notequal', ['$1', '$3']).
Exp -> Exp '<' Exp       : build_call('_less', ['$1', '$3']).
Exp -> Exp '>' Exp       : build_call('_greater', ['$1', '$3']).
Exp -> Exp '<=' Exp      : build_call('_lesseq', ['$1', '$3']).
Exp -> Exp '>=' Exp      : build_call('_greatereq', ['$1', '$3']).
% TODO: Need to add handling of parentheseless compound node `.x, .y, .z`
Exp -> '(' Compound ')'  : build_ast_node('CompoundExpression', #{ 'children' => '$2' }).
Exp -> Term              : '$1'.

% Compound
Compound -> Exp ',' Exp      : ['$1', '$3'].
Compound -> Exp ',' Compound : ['$1'|'$3'].

% Exps
Exps -> Exp               : ['$1'].
Exps -> Exp '|' Exps      : ['$1'|'$3'].

% FuncDef
FuncDef -> def ident ':' Exps ';' :
  build_ast_node('FuncDefinition', #{ 'name' => extract_token('$2'), 'arguments' => [], 'body' => '$4' }).

FuncDef -> def ident '(' Params ')' ':' Exps ';' :
  build_ast_node('FuncDefinition', #{ 'name' => extract_token('$2'), 'arguments' => '$4', 'body' => '$7' }).

% Params
Params -> Param : ['$1'].
Params -> Param ';' Params : ['$1'|'$3'].

% Param
Param -> '$' ident : extract_token('$2').
Param -> ident : extract_token('$1').

% Term
Term -> '.' : build_ast_node('IdentityExpression', #{}).
Term -> '..' : build_call('recurse', []).
Term -> break '$' ident : build_ast_node('BreakExpression', #{ 'label' => extract_token('$3') }).
Term -> Term field '?' :
  build_ast_node('IndexExpression', #{ 'key' => extract_token('$2'), 'object' => '$1', 'optional' => true }).

Term -> field '?' :
  build_ast_node('IndexExpression', #{ 'key' => extract_token('$1'), 'optional' => true }).

% TODO: Add a support of keys that contains special characters
% Term -> Term '.' String '?' :
%   build_ast_node('IndexExpression', #{ 'key' => '$3', 'object' => '$1', 'optional' => true }).
%
% Term -> '.' String '?' :
%   build_ast_node('IndexExpression', #{ 'key' => '$2', 'optional' => true }).

Term -> Term field :
  build_ast_node('IndexExpression', #{ 'key' => extract_token('$2'), 'object' => '$1', 'optional' => false }).

Term -> field :
  build_ast_node('IndexExpression', #{ 'key' => extract_token('$1'), 'optional' => false }).

% TODO: Add a support of keys that contains special characters
% Term -> Term '.' String :
%   build_ast_node('IndexExpression', #{ 'key' => '$3', 'object' => '$1', 'optional' => false }).
%
% Term -> '.' String :
%   build_ast_node('IndexExpression', #{ 'key' => '$2', 'optional' => false }).

Term -> string_value : extract_quoted_string_token('$1').
Term -> float_value : extract_float('$1').
Term -> int_value : extract_integer('$1').
Term -> '$' ident : build_ast_node('IdentExpression', #{ 'name' => extract_token('$2'), 'dollar' => true }).
Term -> ident : build_ast_node('IdentExpression', #{ 'name' => extract_token('$1'), 'dollar' => false }).
Term -> ident '(' ')' : build_call(extract_token('$1'), []).
Term -> ident '(' Args ')' : build_call(extract_token('$1'), lists:reverse('$3')).

Args -> Exp : ['$1'].
Args -> Args ';' Exp : ['$3'|'$1'].

% Arg -> Exp.

Erlang code.

extract_atom({ Value, _Line }) -> Value.
extract_token({ _Token, _Line, Value }) -> list_to_binary(Value).
extract_quoted_string_token({ _Token, _Line, Value }) ->
  unicode:characters_to_binary(lists:sublist(Value, 2, length(Value) - 2)).

extract_integer({ _Token, _Line, Value }) -> { Int, [] } = string:to_integer(Value), Int.
extract_float({ _Token, _Line, Value }) -> { Float, [] } = string:to_float(Value), Float.
build_ast_node(Type, Node) -> Node#{ kind => Type }.
build_try(Exp) -> build_ast_node('TryExpression', #{ 'block' => Exp }).
build_try(Exp, Handler) -> build_ast_node('TryExpression', #{ 'block' => Exp, 'handler' => Handler }).
build_call(Function, Args) -> build_ast_node('FuncCallExpression', #{ 'name' => Function, 'arguments' => Args }).
build_update(Operator, Left, Right) -> build_call('_modify', [Left, build_call(Operator, [Left, Right])]).
merge_nodes(Node1, Node2) -> maps:merge(Node2, Node1).
