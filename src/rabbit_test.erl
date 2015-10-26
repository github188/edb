-module(rabbit_test).
-author("X.D Yang").
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").
-include_lib("amqp_client/include/amqp_client.hrl").

-define(INFO(Msg),
	io:format(Msg)).

-define(INFO(F,M),
	io:format(F,M)).

connect() ->
    ?INFO("connect test~n"),
    R = #amqp_params_network{},
    ?INFO("NetWork:~p~n",[R]),
    {ok,Conn} = amqp_connection:start(R),
    put(conn,Conn),
    {ok,Conn}.

get_channel()->
    Conn = get(conn),
    case amqp_connection:open_channel(Conn) of
	{ok,Channel} ->
	    put(channel,Channel),
	    {ok,Channel};
	_  ->
	    {error,failed}
    end.


rabbit_test_() ->
    fun() ->
	    ?assertMatch({ok,_},connect_test())
    end.
