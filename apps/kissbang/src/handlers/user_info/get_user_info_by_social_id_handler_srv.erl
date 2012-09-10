%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 10 Sep 2012 by  <>
%%%-------------------------------------------------------------------
-module(get_user_info_by_social_id_handler_srv).

-behaviour(gen_server).
-include("../../admin_messaging.hrl").
-include("../../kissbang_messaging.hrl").

%% API
-export([start_link/0]).
-export([handle_get_user_info_by_social_id/2]).

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
    handler_utils:register_handler(get_user_info_by_social_id, fun handle_get_user_info_by_social_id/2),
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
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

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
handle_cast(_Msg, State) ->
    {noreply, State}.

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
handle_get_user_info_by_social_id(CallerGuid, Message) ->
    TargetSocialId = Message#get_user_info_by_social_id.target_social_id,
    case auth_srv:auth(TargetSocialId, "") of
        {ok, TargetUserGuid} ->
            Money = bank_srv:check(TargetUserGuid),
            {ok, RawUserInfo} = userinfo_srv:get_user_info(TargetUserGuid),
            UserInfo = userinfo_srv:process_hides(RawUserInfo),
            ReplyMessage = #on_got_user_info_by_social_id_success{guid = TargetUserGuid,
                                                                   owner_social_id = UserInfo#user_info.user_id,
                                                                   name = UserInfo#user_info.name,
                                                                   profile_url = UserInfo#user_info.profile_url,
                                                                   is_man = UserInfo#user_info.is_man,
                                                                   picture_url = UserInfo#user_info.avatar_url,
                                                                   is_online = "false",
                                                                   city = UserInfo#user_info.city,
                                                                   birth_date = UserInfo#user_info.birth_date,
                                                                   coins = Money,
                                                                   kisses = 0,
                                                                   is_city_hidden = UserInfo#user_info.hide_city,
                                                                   is_birth_date_hidden = UserInfo#user_info.hide_birth_date,
                                                                   is_social_info_hidden = UserInfo#user_info.hide_social_info},
            proxy_srv:async_route_messages(CallerGuid, [ReplyMessage]);
        Error ->
            proxy_srv:async_route_messages(CallerGuid, [#on_got_user_info_by_social_id_fail{target_social_id = TargetSocialId}])
    end.
    
