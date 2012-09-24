%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 10 Aug 2012 by  <>
%%%-------------------------------------------------------------------
-module(vip_srv).

-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([setup_db/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {}).
-record(vipinfo, {user_guid, points, last_update_time}).

%%%===================================================================
%%% API
%%%===================================================================
-export([buy_vip_points/3,
         buy_vip_points/2,
         get_vip_points/1,
         get_random_vip/0]).


buy_vip_points(UserGuid, Points) ->
    buy_vip_points(UserGuid, Points, fun() -> ok end).
buy_vip_points(UserGuid, Points, TransSync) ->
    gen_server:call(?SERVER, {buy_vip_points, UserGuid, Points, TransSync}).

get_vip_points(UserGuid) ->
    gen_server:call(?SERVER, {get_vip_points, UserGuid}).

get_random_vip() ->
    gen_server:call(?SERVER, {get_random_vip}).
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
    Result = mnesia:create_table(vipinfo, [{disc_copies, [node() | nodes()]}, 
                                            {attributes, record_info(fields, vipinfo)}]),
    case Result of
        {atomic, ok} ->
            mnesia:wait_for_tables([vipinfo], 5000),
            ok;
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([vipinfo], 5000),
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
handle_call({get_random_vip}, From, State) ->
    utils:acall(fun() -> inner_get_random_vip() end, From),
    {noreply, State};
handle_call({buy_vip_points, UserGuid, Points, TransSync}, From, State) ->
    utils:acall(fun() -> inner_buy_vip_points(UserGuid, Points, TransSync) end, From),
    {noreply, State};
handle_call({get_vip_points, UserGuid}, From, State) ->
    utils:acall(fun() -> inner_get_vip_points(UserGuid) end, From),
    {noreply, State}.
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
inner_buy_vip_points(UserGuid, Points, TransSync) ->
    Trans = dtranse:transefun(fun() -> 
                                      trans_touch_vip_points(UserGuid),
                                      job_srv:try_complete_job(UserGuid, <<"9">>),
                                      Existance = mnesia:read({vipinfo, UserGuid}),
                                      case Existance of
                                          [] ->
                                              NewVipInfo = #vipinfo{user_guid = UserGuid, 
                                                                    points = Points,
                                                                    last_update_time = utils:unix_time()},
                                              mnesia:write(NewVipInfo);
                                          [OldVipInfo] ->
                                              NewVipInfo = OldVipInfo#vipinfo{points = OldVipInfo#vipinfo.points + Points},
                                              AreJobCompleted = NewVipInfo#vipinfo.points > 10000,
                                              if
                                                  AreJobCompleted ->
                                                      job_srv:try_complete_job(UserGuid, <<"10">>);
                                                  true ->
                                                      []
                                              end,
                                              mnesia:write(NewVipInfo)
                                      end,
                                      {commit, ok}
                              end, TransSync),
    mnesia:activity(transaction, Trans).

inner_get_vip_points(UserGuid) ->
    Trans = fun() ->
                    trans_touch_vip_points(UserGuid),
                    Existance = mnesia:read({vipinfo, UserGuid}),
                    case Existance of
                        [] ->
                            0;
                        [VipInfo] ->
                            VipInfo#vipinfo.points
                    end
            end,
    mnesia:activity(transaction, Trans).


trans_touch_vip_points(UserGuid) ->
    Existance = mnesia:read({vipinfo, UserGuid}),
    case Existance of
        [] ->
            ok;
        [OldVipInfo] ->
            NewVipInfo = decrease_points_with_time(OldVipInfo),
            mnesia:write(NewVipInfo),
            ok
    end.

decrease_points_with_time(OldVipInfo) ->
    {ok, UpdateTime} = application:get_env(kissbang, vip_update_time),
    AreDecreaseTimeCame = OldVipInfo#vipinfo.last_update_time - utils:unix_time() > UpdateTime,
    if 
        AreDecreaseTimeCame ->
            {ok, DecreaseRate} = application:get_env(kissbang, vip_points_decrease_rate),
            decrease_points_with_time(OldVipInfo#vipinfo{points = OldVipInfo#vipinfo.points - DecreaseRate,
                                                         last_update_time = OldVipInfo#vipinfo.last_update_time + UpdateTime});
        true ->
            AreBelowZero = OldVipInfo#vipinfo.points < 0,
            if 
                AreBelowZero ->
                    OldVipInfo#vipinfo{points = 0};
                true ->
                    OldVipInfo
            end
    end.
    

inner_get_random_vip() ->
    Keys = mnesia:dirty_all_keys(vipinfo),
    _Guid = lists:nth(random:uniform(length(Keys)), Keys).

