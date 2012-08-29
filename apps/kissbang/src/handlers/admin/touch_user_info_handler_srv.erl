%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 13 Jul 2012 by  <>
%%%-------------------------------------------------------------------
-module(touch_user_info_handler_srv).
-include("../../admin_messaging.hrl").
-include("../../kissbang_messaging.hrl").
-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([handle_touch_user_info/2]).

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
    handler_utils:register_handler(touch_user_info, fun handle_touch_user_info/2),
    handler_utils:register_handler(touch_user_info_by_user, fun handle_touch_user_info/2),
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
handle_touch_user_info(CallerGuid, Message) when CallerGuid =:= admin ->
    log_srv:debug("touching user info from social network"),
    UserInfo = Message#touch_user_info.user_info,
    UserId = UserInfo#user_info.user_id,
    UserExistance = auth_srv:is_registered(UserId),
    case UserExistance of
        {true, UserGuid} -> %% if user already registered sync only part of social net data
	    log_srv:debug("updating existant user info"),
            {ok, OldUserInfo} = userinfo_srv:get_user_info(UserGuid),
            NewUserInfo = OldUserInfo#user_info{birth_date = UserInfo#user_info.birth_date,
                                               city = UserInfo#user_info.city},
            ok = userinfo_srv:update_user_info(UserGuid, NewUserInfo),
            #touch_user_info_result{result = "ok"};
        _NoExists -> %% if user is not registered yet - sync all data from social net
	    log_srv:debug("social net : registering new user"),
            ok = auth_srv:register(UserInfo#user_info.user_id, ""),
	    {ok, NewUserGuid} = auth_srv:auth(UserInfo#user_info.user_id, ""),
            TouchResult = userinfo_srv:update_user_info(NewUserGuid, UserInfo),
            io:format("TouchResult = ~p", [TouchResult]),
            #touch_user_info_result{result = "ok"}
    end;

handle_touch_user_info(CallerGuid, Message) ->
    log_srv:debug("touching user info by user"),
    {ok, OldUserInfo} = userinfo_srv:get_user_info(CallerGuid),
    NewUserInfo = #user_info{user_id = OldUserInfo#user_info.user_id,
                             name = Message#touch_user_info_by_user.name,
                             profile_url = OldUserInfo#user_info.profile_url,
                             is_man = OldUserInfo#user_info.is_man,
                             birth_date = OldUserInfo#user_info.birth_date,
                             city = OldUserInfo#user_info.city,
                             avatar_url = OldUserInfo#user_info.avatar_url,
                             hide_social_info = Message#touch_user_info_by_user.hide_social_info,
                             hide_city = Message#touch_user_info_by_user.hide_city,
                             hide_name = Message#touch_user_info_by_user.hide_name
                            },
    userinfo_srv:update_user_info(CallerGuid, NewUserInfo),
    proxy_srv:async_route_messages(CallerGuid, [#touch_user_info_by_user_result{result = "ok"}]).
