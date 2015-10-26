-module(mqueue).
-behaviour(gen_server).
-export([start/1,
	 init/1,
	 handle_call/3,
	 handle_cast/2,
	 handle_info/2,
	 terminate/2,
	 code_change/3,
	 for/3]).
-include("logger.hrl").
-include("sock.hrl").
start(State) ->
    gen_server:start_link(?MODULE,[State],[]).
init([State]) ->
    #state{sock = Sock} = State,
    ?DEBUG("Sock is:~p~n",[Sock]),
   {ok,State}.
handle_call(Request,From,State) ->
    {reply,ok,State}.
handle_cast(Request,State) ->
    {noreply,State}.
handle_info(timeout,State) ->
    {noreply,State};
handle_info({tcp,Socket,Data},State)->
    ?DEBUG("Recv Data:~p~n",[Data]),
    {noreply,State};
handle_info({tcp_error_Socket,Reason},State) ->
    ?INFO_MSG("Error:~p~n",[Reason]),
    {stop,normal,State};
handle_info({tcp_closed,Sock},State) ->
    ?DEBUG("Closed ~p~n",[Sock]),
    {stop,normal,State};
handle_info(Info,State) ->
    {noreply,State}.

terminate(Reason,State) ->
    %?INFO_MSG("Socket Closed~p~n",[Reason]),
    ok.

code_change(OldVsn,State, Extra) ->
    {ok,State}.


for(I,J,Fun) when I >= J ->
    ok;
for(I,J,Fun) when I < J ->  
    spawn(Fun),
    for(I+1,J,Fun).

active_sock(Sock) ->
    inet:setopts(Sock,?TCP_OPT).
