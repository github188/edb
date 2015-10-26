-module(dboper).
-export([init/1,close/0]).

init([]) ->
    io:format("error arguments~n");
init([Host,Db,Usr,Pwd]) ->
    pgsql_connection_sup:start_link(),
    PGConn =  pgsql_connection:open(Host,Db,Usr,Pwd),
    put(con,PGConn).

close() ->
    PGConn= get(con),
    pgsql_connection:close(PGConn).
