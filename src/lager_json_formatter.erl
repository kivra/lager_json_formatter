-module(lager_json_formatter).

-include_lib("lager/include/lager.hrl").

-export([format/2, format/3]).

-spec format(lager_msg:lager_msg(),list(),any()) -> any().
format(Msg, Config, _) ->
  format(Msg, Config).

-spec format(lager_msg:lager_msg(),list()) -> any().
format(Msg, Config) ->
  [jsx:encode(json_handler(Msg)), <<"\n">>].

-spec json_handler(lager_msg:lager_msg()) -> any().
json_handler(Msg) ->
  {Date, Time} = lager_msg:datetime(Msg),
  Metadata = [ {K, make_printable(V)} || {K, V} <- lager_msg:metadata(Msg)],
  [
    {<<"@timestamp">>, iolist_to_binary([Date, $T, Time, $Z])},
    {message, iolist_to_binary(lager_msg:message(Msg))},
    {level, severity_to_binary(lager_msg:severity(Msg))},
    {level_as_int, lager_msg:severity_as_int(Msg)},
    {destinations, lager_msg:destinations(Msg)}
  | Metadata].

make_printable(A) when is_atom(A) orelse is_binary(A) orelse is_number(A) -> A;
make_printable(P) when is_pid(P) -> iolist_to_binary(pid_to_list(P));
make_printable(Other) -> iolist_to_binary(io_lib:format("~p",[Other])).

severity_to_binary(debug)     -> <<"DEBUG">>;
severity_to_binary(info)      -> <<"INFO">>;
severity_to_binary(notice)    -> <<"NOTICE">>;
severity_to_binary(warning)   -> <<"WARNING">>;
severity_to_binary(error)     -> <<"ERROR">>;
severity_to_binary(critical)  -> <<"CRITICAL">>;
severity_to_binary(alert)     -> <<"ALERT">>;
severity_to_binary(emergency) -> <<"EMERGENCY">>.
