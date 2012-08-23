%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 23 Jul 2012 by  <>
%%%-------------------------------------------------------------------
-module(avatar_srv).
-include("admin_messaging.hrl").
-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([set_avatar/3]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================
set_avatar(UserGuid, ImageFormat, ImageDataBase64) ->
    gen_server:cast(?SERVER, {set_avatar, UserGuid, ImageFormat, ImageDataBase64}).
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
handle_cast({set_avatar, UserGuid, ImageFormat, ImageDataBase64}, State) ->
    inner_set_avatar(UserGuid, ImageFormat, ImageDataBase64),
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
inner_set_avatar(UserGuid, ImageFormat, ImageDataBase64) ->
    spawn_link(fun() ->
                       %% check input data
                       ok = check_format(ImageFormat),
                       %% decode image
                       ImageData = base64:decode(ImageDataBase64),
                       %% write data to file
                       AvatarGuid = UserGuid,
                       {ok, FileDevice} = file:open(get_out_avatar_path(AvatarGuid, ImageFormat), write),
                       ok = file:write(FileDevice, ImageData),
                       %% update avatar url in userinfo
                       {ok, OldUserInfo} = userinfo_srv:get_user_info(UserGuid),
                       NewUserInfo = OldUserInfo#user_info{avatar_url = get_avatar_url(AvatarGuid, ImageFormat)},
                       ok = userinfo_srv:update_user_info(UserGuid, NewUserInfo)
               end),
        ok.
    
check_format(ImageFormat) ->
    %% TODO : implement me
    ok.

get_out_avatar_path(AvatarGuid, ImageFormat) ->
    element(2, application:get_env(kissbang, avatar_base_path)) ++ AvatarGuid ++ "." ++ ImageFormat.

get_avatar_url(AvatarGuid, ImageFormat) ->
    element(2, application:get_env(kissbang, avatar_base_url)) ++ AvatarGuid ++ "." ++ ImageFormat.
