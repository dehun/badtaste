%%%-------------------------------------------------------------------
%%% @author  <dehun@localhost>
%%% @copyright (C) 2012, 
%%% @doc
%%% Proxy module. It registers origins of clients. 
%%% And all other subsystems know where to route messages from that moment.
%%% Module works in cooperations with gateway_srv
%%% @end
%%% Created : 30 May 2012 by  <dehun@localhost>
%%%-------------------------------------------------------------------
-module(proxy_srv).

-behaviour(gen_server).
-include("origin.hrl").
-record(user_origin, {guid, origin}).

%% API
-export([start_link/0]).
-export([register_origin/2, 
         get_origin/1,
         route_messages/2,
         drop_all/0,
         drop_origin/1,
         async_route_messages/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% registers users origin. It means that gateway tells us from where 
%% user come( node and socket id)
%% @spec
%% register_origin(Guid, Origin) -> ok
%% @end
%%--------------------------------------------------------------------
register_origin(Guid, Origin) ->
    gen_server:call(?SERVER, {reigster_origin, Guid, Origin}).


%%--------------------------------------------------------------------
%% @doc
%% drops all the user->origin mappings
%% @spec
%% drop_all() -> ok
%% @end
%%--------------------------------------------------------------------
drop_all() ->
    gen_server:call(?SERVER, {drop_all}).


%%--------------------------------------------------------------------
%% @doc
%% drops origin of user. gateway calls this function when client disconnects from origin
%% @spec
%% drop_origin(Guid) ->  ok | unknown_origin
%% @end
%%--------------------------------------------------------------------
drop_origin(Guid) ->
    gen_server:call(?SERVER, {drop_origin, Guid}).

%%--------------------------------------------------------------------
%% @doc
%% gets the origin of user
%% @spec
%% get_origin(Guid) -> {ok, Origin} | unknown_origin
%% @end
%%--------------------------------------------------------------------
get_origin(Guid) ->
    gen_server:call(?SERVER, {get_origin, Guid}).

%%--------------------------------------------------------------------
%% @doc
%% routes messages to a origin of user
%% @spec
%% route_messages(Guid, Messages) -> ok | unknown_origin
%% @end
%%--------------------------------------------------------------------
route_messages(Guid, Messages) ->
    gen_server:call(?SERVER, {route_messages, Guid, Messages}).

%%--------------------------------------------------------------------
%% @doc
%% same as route_messages but don't wait for answer
%% @spec
%% async_route_messages(Guid, Messages) 
%% @end
%%--------------------------------------------------------------------
async_route_messages(Guid, Messages) ->
    gen_server:cast(?SERVER, {route_messages, Guid, Messages}).

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    init_db(),
    {ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_call({register_origin, Guid, Origin}, _From, State) ->
    Reply = inner_register_origin(Guid, Origin),
    {reply, Reply, State};
handle_call({drop_all}, _From, State) ->
    Reply = inner_drop_all(),
    {reply, Reply, State};
handle_call({drop_origin, Guid}, _From, State) ->
    Reply = inner_drop_origin(Guid),
    {reply, Reply, State};
handle_call({get_origin, Guid}, _From, State) ->
    Reply = inner_get_origin(Guid),
    {reply, Reply, State};
handle_call({route_messages, Guid, Messages}, _From, State) ->
    Reply = inner_route_messages(Guid, Messages),
    {reply, Reply, State}.
%% handle_call(_Request, _From, State) ->
%%     Reply = ok,
%%     {reply, Reply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_cast({route_messages, Guid, Messages}, State) ->
    inner_route_messages(Guid, Messages),
    {noreply, State}.
%% handle_cast(_Msg, State) ->
%%     {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
init_db() ->
    mnesia:create_schema([node() | nodes()]),
    mnesia:start(),
    Result = mnesia:create_table(user_origin, [{ram_copies, [node() | nodes()]},
                                            {attributes, record_info(fields, user_origin)}]),
    case Result of 
        {atomic, ok} ->
            mnesia:wait_for_tables([user_origin], 5000),
            ok;
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([user_origin], 5000),
            ok;
        {aborted, Reason} ->
            erlang:error(Reason)
    end.

inner_register_origin(Guid, Origin) ->
    Trans = fun() ->
                    Existance = mnesia:read(user_origin, Guid, write),
                    NewOrigin = #user_origin{guid = Guid, origin = Origin},
                    case Existance of
                        [] ->
                            mnesia:write(NewOrigin),
                            {ok, pure};
                        [OldOrigin] ->
                            mnesia:delete(OldOrigin),
                            mnesia:write(NewOrigin),
                            {ok, dirty, OldOrigin#user_origin.origin}
                    end
            end,
    
    {atomic, {ok, Result}} = mnesia:transaction(Trans),
    case Result of
        pure ->
            ok;
        {dirty, OldOrigin} ->
            gateway_srv:disconnect_origin(OldOrigin),
            ok
    end.

inner_drop_all() ->
    Trans = fun() ->
                    [mnesia:delete({user_origin, Key}) || Key <- mnesia:all_keys(user_origin)],
                    ok
            end,
    {atomic, ok} = mnesia:transaction(Trans),
    ok.

inner_get_origin(Guid) ->
    Trans = fun() ->
                    Existance = mnesia:read(user_origin, Guid),
                    case Existance of 
                        [] ->
                            unknown_origin;
                        [UserOrigin] ->
                            {ok, UserOrigin#user_origin.origin}
                    end
            end,
    {atomic, Result} = mnesia:transaction(Trans),
    Result.

inner_drop_origin(Guid) ->
    Trans = fun() ->
                    Existance = mnesia:read(user_origin, Guid, write),
                    case Existance of
                        [] ->
                            unknown_origin;
                        [UserOrigin] ->
                            mnesia:delete(UserOrigin),
                            {ok, UserOrigin#user_origin.origin}
                        end
            end,
    {atomic, Result} = mnesia:activity(Trans),
    case Result of
        {ok, Origin} ->
            gateway_str:disconnect_origin(Origin),
            ok;
        Other ->
            Other
        end.

inner_route_messages(Guid, Messages) ->
    OriginGetResult = inner_get_origin(Guid),
    case OriginGetResult of
        unknown_origin ->
            unknown_origin;
        {ok, Origin} ->
            gateway_srv:route_messages(Origin, Messages)
    end.
                    
