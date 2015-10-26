
-define(TCP_OPT,[binary,{active,once},{packet,2},{backlog,10},{delay_send,false}]).
-define(Port,9000).
-define(Listen_Count,2).
-record(state,{lsock,sock}).
