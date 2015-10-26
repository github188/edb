-module(test).
-export([start/0,
	 mnesia_write_test/0,
	 mnesia_read_test/0,
	 write_test/0]).
-include("logger.hrl").
-record(msg,{key = <<"">>, value = <<"">>}).

-define(OUTPUT(F,M),
       io:format(F,M)).
-define(OUTPUT(F),
       io:format(F)).

conn(Host,Port,Pid) when is_integer(Port)->
    case gen_tcp:connect(Host,Port,[{packet,2},{active,once}]) of
	{ok,Sock} ->
	    ?DEBUG("Connected:~p~n",[Sock]),
	    Pid ! {ok},
	    ?DEBUG("Send Ok to Pid:~p~n",[Pid]),
	    Res = gen_tcp:close(Sock),
	    ?DEBUG("Close Sock:~p",[Res]);
	{error,Reason} ->
	    ?DEBUG("Connect Error:~p~n",[Reason])
    end.
write_test() ->
    ok.
mnesia_write_test() ->
    %lager:start(),
    %?LOG_LVL(debug),
    init_db(),
    F = fun(I) ->
		Msg = #msg{key = <<I>>, value = <<I>>},
%		%?DEBUG("MSG: ~p~n",[Msg]),
		%?OUTPUT("MSG: ~p~n",[Msg]),
		mnesia:dirty_write(msg,Msg)
	end,
    lists:foreach(F,lists:seq(1,10000)),
    mnesia:dump_tables([msg]),
    ok.
mnesia_read_test() ->
    init_db(),
    mnesia:wait_for_tables([msg],2000),
    
    lists:foreach(
      fun(I) ->
	      Msg = mnesia:dirty_read(msg,<<I/integer>>),
	      ?INFO_MSG("data ~p~n",[Msg])
      end, lists:seq(1,10)
     ).
start() ->
    lager:start(),
    lager:set_loglevel(lager_console_backend, info),
    {Mega1,Sec1,Micro1} = os:timestamp(),
    start(10000),
    {Mega2,Sec2,Micro2} = os:timestamp(),
    Total = (Sec2-Sec1) * 1000000 + Micro2 - Micro1,
    ?INFO_MSG("Time Elapsed:~p ms~n",[Total div 1000]).


start(I) when  I > 0 ->
    lager:start(),
    Pid = self(),
    ?DEBUG("Process Pid:~p~n",[self()]),
    F = fun() ->
		conn("192.168.1.117",9000,Pid)
	end,
    for(0,I,F),
    wait_for_end(I).

wait_for_end(0) ->
    ?INFO_MSG("Run Ok ~p~n",[self()]);
wait_for_end(Count) ->
    ?DEBUG("Count:~p, PID:~p~n",[Count,self()]),
    receive
	{ok} ->
	    ?DEBUG("Ok:~p~n",[Count]);
	_  ->
	    error
    after 100 ->
	    ?DEBUG("Time Out:~p~n",[Count])
    end,
    wait_for_end(Count-1).

for(I,J,Fun) when I >= J ->
    ?INFO_MSG("Client Finish ~p~n",[J]);
for(I,J,Fun) when I<J ->
    spawn(Fun),
    for(I+1,J,Fun).

init() ->
    lager:start(),
    ?LOG_LVL(debug),
    init_db().
init_db() ->
    lager:start(),
    mnesia:create_schema([node()]),
    mnesia:start(),
    mnesia:create_table(msg,[{attributes,record_info(fields,msg)},{ram_copies,[node()]}]).
