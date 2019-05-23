%%% ----------------------------------------------------------------------------
%%% @author <pouriya.jahanbakhsh@gmail.com>
%%% @doc
%%%         High level API module.
%%% @end

%% -----------------------------------------------------------------------------
-module(opentsdb_encoderl).
-author('pouriya.jahanbakhsh@gmail.com').
%% -----------------------------------------------------------------------------
%% Exports:

-export([
    encode/1,
    encode/2
]).


encode(Data, Opts) when erlang:is_map(Opts) ->
    Result = encode(Data),
    case maps:get(return_type, Opts, iolist) of
        iolist ->
            Result;
        string ->
            erlang:binary_to_list(erlang:iolist_to_binary(Result));
        unsafe_string ->
            lists:flatten(Result);
        _ -> % binary
            erlang:iolist_to_binary(Result)
    end.


encode({Key, Value, Tags}) ->
    [
        "put ",
        encode_key(Key),
        " ",
        begin
            {Mega, Sec, _} = os:timestamp(),
            erlang:integer_to_list(((Mega * 1000000) + Sec))
        end,
        " ",
        encode_value(Value),
        encode_tags(Tags),
        "\n"
    ];

encode({Key, Value, Tags, Timestamp}) when erlang:is_integer(Timestamp) ->
    [
        "put ",
        encode_key(Key),
        " ",
        erlang:integer_to_list(Timestamp),
        " ",
        encode_value(Value),
        encode_tags(Tags),
        "\n"
    ];

encode({Key, Value, Tags, {Mega, Sec, _}}) ->
    [
        "put ",
        encode_key(Key),
        " ",
        erlang:integer_to_list(((Mega * 1000000) + Sec)),
        " ",
        encode_value(Value),
        encode_tags(Tags),
        "\n"
    ];

encode([_|_]=L) ->
    encode_list(L);

encode(Map) when erlang:map_size(Map) > 0 ->
    encode_list(maps:to_list(Map));

encode({Key, {Value, Tags}}) ->
    [
        "put ",
        encode_key(Key),
        " ",

        begin
            {Mega, Sec, _} = os:timestamp(),
            erlang:integer_to_list(((Mega * 1000000) + Sec))
        end,
        " ",
        encode_value(Value),
        encode_tags(Tags),
        "\n"
    ].


encode_list([Item | Rest]) ->
    [encode(Item) | encode_list(Rest)];

encode_list(_) ->
    [].


encode_key(Key) when erlang:is_binary(Key) ->
    Key;

encode_key([Char|_]=Key) when erlang:is_integer(Char) ->
    Key;

encode_key(Key) when erlang:is_atom(Key) ->
    erlang:atom_to_list(Key);

encode_key([Key]) ->
    [encode_key(Key)];

encode_key([Key|Keys]) ->
    [encode_key(Key), "." | encode_key(Keys)].


encode_value(Value) when erlang:is_float(Value) ->
    erlang:float_to_list(Value, [compact, {decimals, 12}]);

encode_value(Value) ->
    io_lib:print(Value).


encode_tags({Key, Value}) ->
    [" " , encode_key(Key), "=", encode_key(Value)];

encode_tags([{Key, Value}]) ->
    [" ", encode_key(Key), "=", encode_key(Value)];

encode_tags([{_, _}=Item|Rest]) ->
    [encode_tags(Item) | encode_tags(Rest)];

encode_tags(Tags) when erlang:map_size(Tags) > 0 ->
    encode_tags(maps:to_list(Tags)).