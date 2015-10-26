-module(mnesia_test).
-author('X.D Yang').
-export([write_test/0,
	 read_test/0,
	 init_disk_db/0,
	 write/1]).

-record(msg,{key,value}).

-define(KB,1024).

-define(INFO_MSG(Format,Msg),
	io:format(Format,Msg)).
-define(DEBUG(Format,Msg),
	io:format(Format,Msg)).
-define(ERROR_MSG(Format,Msg),
	io:format(Format,Msg)).

-define(INFO_MSG(Format),
	io:format(Format)).
-define(DEBUG(Format),
	io:format(Format)).
-define(ERROR_MSG(Format),
	io:format(Format)).

-include_lib("eunit/include/eunit.hrl").


fib(0) ->
    1;
fib(1) ->
    1;
fib(N) when N > 1 ->
    fib(N-1) + fib(N-2).

fib_test_()->
    [?_assert( fib(0) =:= 1),
     ?_assert( fib(1) =:= 1)].





init_disk_db() ->
    mnesia:create_schema([node()]),
    mnesia:start(),
    mnesia:create_table(msg,[{attributes,record_info(fields,msg)},{ram_copies,[node()]}]).
						%    mnesia:stop().

start_db() ->
						%mnesia:create_schema(nodes()),
						%mnesia:start(),
						%mnesia:wait_for_tables([msg]). 
    ok.
stop_db() ->
						% mnesia:stop().
    mnesia:dump_tables([msg]),
    ok.
write_test() ->
    start_db(),
    Value = [X div X || X <- lists:seq(1,?KB*5)],
    V = list_to_binary(Value),
    F = fun(E) ->
		mnesia:dirty_write(msg,#msg{key = E,value = V})
	end,

    {Mega1,Sec1,Micro1} = os:timestamp(),    
    lists:foreach(F, lists:seq(1,100000)),
    {Mega2,Sec2,Micro2} = os:timestamp(),
    Total = (Sec2-Sec1) * 1000000 + Micro2 - Micro1,
    Total2 = Total div 1000,
    ?DEBUG("Total is:~p~n",[Total2]),
						%Total = Total div 1000,
    ?INFO_MSG("Time Elapsed:~p ms~n",[Total2]),
    stop_db().
write(E) ->
    mnesia:dirty_write(msg,#msg{key = E, value = E}).
read_test() ->
    init_disk_db(),
    R =  mnesia:wait_for_tables([msg],1000),
    ?DEBUG("Wait For tables Result:~p~n",[R]),
    start_db(),
    F = fun(E) ->
		Res = mnesia:dirty_read(msg,E),
		?INFO_MSG("Msg: ~p~n",[Res])
	end,
    lists:foreach(F,lists:seq(1,3)),
    stop_db().


