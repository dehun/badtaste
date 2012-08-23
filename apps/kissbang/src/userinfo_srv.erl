%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 16 Jul 2012 by  <>
%%%-------------------------------------------------------------------
-module(userinfo_srv).
-include("admin_messaging.hrl").
-behaviour(gen_server).

%% API
-export([start_link/0, setup_db/0]).
-export([get_user_info/1, update_user_info/2, async_update_user_info/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {}).
-record(byuserinfo, {user_guid, user_info}).

%%%===================================================================
%%% API
%%%===================================================================
get_user_info(UserGuid) ->
    gen_server:call(?SERVER, {get_user_info, UserGuid}).

update_user_info(UserGuid, UserInfo) ->
    gen_server:call(?SERVER, {update_user_info, UserGuid, UserInfo}).

async_update_user_info(UserGuid, UserInfo) ->
    gen_server:cast(?SERVER, {update_user_info, UserGuid, UserInfo}).
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
    Result = mnesia:create_table(byuserinfo, [{disc_copies, [node() | nodes()]}, 
                                              {attributes, record_info(fields, byuserinfo)}]),
    case Result of
        {atomic, ok} ->
            mnesia:wait_for_tables([byuserinfo], 5000),
            ok;
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([byuserinfo], 5000),
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
handle_call({update_user_info, UserGuid, UserInfo}, From, State) ->
    spawn_link(fun() ->
                       Reply = inner_update_user_info(UserGuid, UserInfo),
                       gen_server:reply(From, Reply)
               end),
    {noreply, State};
handle_call({get_user_info, UserGuid}, From, State) ->
    spawn_link(fun() ->
                       Reply = inner_get_user_info(UserGuid),
                       gen_server:reply(From, Reply)
               end),
    {noreply, State}.
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
handle_cast({update_user_info, UserGuid, UserInfo}, State) ->
    spawn_link(fun() ->
                       inner_update_user_info(UserGuid, UserInfo)
               end),
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
inner_get_user_info(UserGuid) ->
    Trans = fun() ->
                    Existance = mnesia:read({byuserinfo, UserGuid}),
                    case Existance of 
                        [] ->
                            no_info_for_user;
                        [UserInfo] ->
                            {ok, UserInfo#byuserinfo.user_info}
                    end
            end,
    mnesia:activity(sync_dirty, Trans).

inner_update_user_info(UserGuid, UserInfo) ->
    log_srv:debug("userinfo_srv : updating user info"),
    Trans = fun() ->
                    ByUserInfo = #byuserinfo{user_guid = UserGuid,
                                             user_info = UserInfo},
                    mnesia:write(ByUserInfo),
                    sex_srv:set_sex(UserGuid, UserInfo#user_info.is_man),
                    ok

            end,
    mnesia:activity(sync_dirty, Trans).

