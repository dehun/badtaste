-module(handler_utils).

-export([register_handler/2, register_handler/3]).

register_handler(MessageName, HandlerFun) ->
    register_handler(5000, MessageName, HandlerFun).


register_handler(UpdateInterval, MessageName, HandlerFun) ->
    handlermgr_srv:register_handler(MessageName, HandlerFun),
    {ok, _TRef} = timer:apply_after(UpdateInterval, handler_utils, register_handler, [UpdateInterval, MessageName, HandlerFun]).


