-module(edb_listener).
-author("X.D Yang").
-export([start_link/0,init/1]).
-include("logger.hrl").
-include("sock.hrl").
-compile([{parse_transform, lager_transform}]).

start_link() ->
    Pid = start(),
    io:format("PID ~p~n",[Pid]),
    ?INFO_MSG("Start ~p~n",[Pid]),
    {ok,Pid}.
start() ->
    spawn( 
      fun() ->
	 start(?Port)
      end
	 ).

start(Port) when is_integer(Port) ->
    case init([Port]) of
	{ok,#state{lsock=LSock}} ->
	    mqueue:for(0,2,fun()-> do_accept(LSock) end ),
	    do_accept(LSock);
	_ ->
	    error
    end.
    
init([Port]) ->
    lager:start(),
    lager:set_loglevel(lager_console_backend, info),
    {ok,Pid} = pgsql_connection_sup:start_link(),
    ?INFO_MSG("PGSQL Started:~p~n",[Pid]),
    case gen_tcp:listen(Port,?TCP_OPT) of
	{ok,LSock}->
	    {ok,#state{lsock = LSock}};
	 _ ->
	    {error,#state{}}
    end.
    
do_accept(LSock) ->
    case gen_tcp:accept(LSock) of
	{ok,Sock}->
	    State = #state{sock = Sock},
	    ?DEBUG("Accept New Client:~p~n",[Sock]),
	    {ok,Pid} = mqueue:start(State),
	    ?DEBUG("NEW Process:~p~n",[Pid]),
	    gen_tcp:controlling_process(Sock,Pid),
	    ok;
	_  ->
	    error
    end,
    do_accept(LSock).
