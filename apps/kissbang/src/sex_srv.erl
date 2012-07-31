%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 17 Jul 2012 by  <>
%%%-------------------------------------------------------------------
-module(sex_srv).

-behaviour(gen_server).

%% API
-export([start_link/0, setup_db/0]).
-export([get_sex/1, set_sex/2, async_set_sex/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).
-record(sex, {user_guid, is_male}).

%%%===================================================================
%%% API
%%%===================================================================
get_sex(UserGuid) ->
    gen_server:call(?SERVER, {get_sex, UserGuid}).

set_sex(UserGuid, IsMale) when is_list(IsMale) ->
    set_sex(UserGuid, list_to_atom(IsMale));
set_sex(UserGuid, IsMale) when is_integer(IsMale) ->
    set_sex(UserGuid, IsMale /= 0);
set_sex(UserGuid, IsMale) when is_atom(IsMale) ->
    gen_server:call(?SERVER, {set_sex, UserGuid, IsMale}).

async_set_sex(UserGuid, IsMale) ->
    gen_server:cast(?SERVER, {set_sex, UserGuid, IsMale}).
%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


setup_db() ->
    Result = mnesia:create_table(sex, [{disc_copies, [node() | nodes()]}, 
                                       {attributes, record_info(fields, sex)}]),
    case Result of
        {atomic, ok} ->
            mnesia:wait_for_tables([sex], 5000),
            ok;
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([sex], 5000),
            ok;
        {aborted, Reason} ->
            erlang:error(Reason)
        end.

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
handle_call({set_sex, UserGuid, IsMale}, _From, State) ->
    Reply = inner_set_sex(UserGuid, IsMale),
    {reply, Reply, State};
handle_call({get_sex, UserGuid}, _From, State) ->
    Reply = inner_get_sex(UserGuid),
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
handle_cast({set_sex, UserGuid, IsMale}, State) ->
    Reply = inner_set_sex(UserGuid, IsMale),
    {reply, Reply, State}.
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
inner_get_sex(UserGuid) ->
    Trans = fun() ->
                    Existance = mnesia:read({sex, UserGuid}),
                    case Existance of
                        [Sex] ->
                            if
                                Sex#sex.is_male ->
                                    male;
                                true ->
                                    female
                                end;
                        [] ->
                            unknown
                        end
            end,
    mnesia:activity(sync_dirty, Trans).

inner_set_sex(UserGuid, IsMale) ->
    Trans = fun() ->
                    NewSex = #sex{user_guid = UserGuid,
                                  is_male = IsMale},
                    mnesia:write(NewSex),
                    ok
            end,
    mnesia:activity(sync_dirty, Trans).
