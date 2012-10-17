%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 25 Sep 2012 by  <>
%%%-------------------------------------------------------------------
-module(scoreboard_srv).

-behaviour(gen_server).
-include_lib("stdlib/include/qlc.hrl").
-include("server_user_score.hrl").

%% API
-export([start_link/0,
         setup_db/0]).

-export([add_score/3,
         add_score/2,
         set_score/3,
         get_top_list/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {}).

-record(toplist, {period, tag, scorelist, build_time}).

%%%===================================================================
%%% API
%%%===================================================================
add_score(UserGuid, Tag) ->
    add_score(UserGuid, Tag, 1).

add_score(UserGuid, Tag, Amount) ->
    gen_server:cast(?SERVER, {add_score, UserGuid, Tag, Amount}).

set_score(UserGuid, Tag, Amount) ->
    gen_server:cast(?SERVER, {set_score, UserGuid, Tag, Amount}).

get_top_list(Tag, Period) ->
    gen_server:call(?SERVER, {get_top_list, Tag, Period}).
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
    Result = mnesia:create_table(server_user_score,
                                 [{frag_properties, [{node_pool, [node() | nodes()]}, 
                                                     {n_fragments, 8}, 
                                                     {n_disc_copies, 1}]},
                                  {type, bag},
                                  {attributes, record_info(fields, server_user_score)}]),
    case Result of
        {atomic, ok} ->
            mnesia:wait_for_tables([server_user_score], 5000);
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([server_user_score], 5000);
        {aborted, Reason} ->
            erlang:error(Reason)
    end,
    Result2 = mnesia:create_table(toplist, [{disc_copies, [node() | nodes()]}, 
                                            {attributes, record_info(fields, toplist)}]),
    case Result2 of
        {atomic, ok} ->
            mnesia:wait_for_tables([toplist], 5000),
            ok;
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([toplist], 5000),
            ok;
        {aborted, Reason2} ->
            erlang:error(Reason2)
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
    timer:send_interval(1000*60*60*24, self(), {rebuild_common}),
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
handle_call({get_top_list, Tag, Period}, From, State) ->
    utils:acall(fun() -> inner_get_top_list(Tag, Period) end, From),
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
handle_cast({add_score, UserGuid, Tag, Amount}, State)  ->
    spawn_link(fun() -> inner_add_score(UserGuid, Tag, Amount) end),
    {noreply, State};
handle_cast({set_score, UserGuid, Tag, Amount}, State) ->
    spawn_link(fun() -> inner_set_score(UserGuid, Tag, Amount) end),
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
handle_info({rebuild_common}, State) ->
    spawn_link(fun() -> inner_rebuild_common() end),
    {noreply, State};
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

inner_set_score(UserGuid, Tag, Amount) ->
    Trans = fun() ->
                    case qlc:e(qlc:q([E || E <- mnesia:table(server_user_score), E#server_user_score.tag =:= Tag, E#server_user_score.user_guid =:= UserGuid])) of
                        [] ->
                            [];
                        [OldScore] ->
                            mnesia:delete_object(OldScore)
                    end,
                    mnesia:write(#server_user_score{user_guid = UserGuid, tag = Tag, score = Amount})
            end,
    mnesia:activity(sync_dirty, Trans, [], mnesia_frag).

inner_add_score(UserGuid, Tag, Amount) ->
    log_srv:debug("adding ~p scorepoints to user ~p by tag ~p", [Amount, UserGuid, Tag]),
    Trans = fun() ->
                    case qlc:e(qlc:q([E || E <- mnesia:table(server_user_score), E#server_user_score.tag =:= Tag, E#server_user_score.user_guid =:= UserGuid])) of
                        [] ->
                            mnesia:write(#server_user_score{user_guid = UserGuid, tag = Tag, score = Amount});
                        [OldScore] ->
                            mnesia:delete_object(OldScore),
                            mnesia:write(OldScore#server_user_score{score = Amount + OldScore#server_user_score.score})
                    end
            end,
    mnesia:activity(sync_dirty, Trans, [], mnesia_frag).

inner_get_top_list(Tag, Period)  ->
    inner_try_rebuild_top_list(Tag, Period),
    Trans = fun() ->
                    [TopList] = qlc:e(qlc:q([T || T <- mnesia:table(toplist), T#toplist.tag =:= Tag, T#toplist.period =:= Period])),
                    TopList#toplist.scorelist
            end,
    mnesia:activity(sync_dirty, Trans).


inner_try_rebuild_top_list(Tag, Period) ->
    case mnesia:activity(sync_dirty, fun() ->
                                             case qlc:e(qlc:q([E || E <- mnesia:table(toplist), E#toplist.tag =:= Tag, E#toplist.period =:= Period])) of
                                                 [] ->
                                                     need_rebuild;
                                                 [OldTopList] ->
                                                     NeedRebuild = OldTopList#toplist.build_time + get_period_in_seconds(Period) < utils:unix_time(),
                                                     if 
                                                         NeedRebuild ->
                                                             need_rebuild;
                                                         true ->
                                                             ok
                                                     end
                                                 end
                                     end) of
        need_rebuild ->
            inner_rebuild_top_list(Tag, Period),
            ok;
        _ ->
            ok
        end.

get_period_in_seconds(hour) ->
    60*60;
get_period_in_seconds(day) ->
    24*get_period_in_seconds(hour);
get_period_in_seconds(week) ->
    7*get_period_in_seconds(day);
get_period_in_seconds(month) ->
    get_period_in_seconds(week) * 30.


inner_rebuild_top_list(Tag, Period) ->
    TopTrans = fun() ->
                       C = qlc:cursor(qlc:sort(qlc:q([E || E <- mnesia:table(server_user_score), E#server_user_score.tag =:= Tag]), 
                                                 {order, fun(E1, E2) -> E1#server_user_score.score > E2#server_user_score.score end})),
                       TopList = qlc:next_answers(C, 100),
                       qlc:delete_cursor(C),
                       TopList
            end,
    TopList = mnesia:activity(async_dirty, TopTrans, [], mnesia_frag),
    Trans = fun() ->
                    case qlc:e(qlc:q([E || E <- mnesia:table(toplist), E#toplist.tag =:= Tag, E#toplist.period =:= Period])) of
                        [] ->
                            ok;
                        [OldTopList] ->
                            mnesia:delete_object(OldTopList)
                    end,
                    mnesia:write(#toplist{period = Period,
                                          tag = Tag,
                                          scorelist = TopList,
                                          build_time = utils:unix_time()})
            end,
    mnesia:activity(sync_dirty, Trans).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% common rating rebuild
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inner_rebuild_common() ->
    log_srv:info("rebuilding common scores"),
    ok = mnesia:activity(sync_dirty, fun() ->
                                        qlc:fold(fun(UserScore, Acc) -> per_user_try_common_rebuild(UserScore, Acc) end,
                                                 sets:new(), qlc:q([E || E <- mnesia:table(server_user_score)])),
                                        ok
                                end, [], mnesia_frag).

per_user_try_common_rebuild(UserScore, ProcessedUsersSet) ->
    UserGuid = UserScore#server_user_score.user_guid,
    log_srv:debug("trying to rebuild common for ~p", [UserGuid]),
    case sets:is_element(UserGuid, ProcessedUsersSet) of
        true ->
            ProcessedUsersSet;
        false ->
            spawn_link(fun() -> per_user_common_rebuild(UserGuid) end),
            sets:add_element(UserGuid, ProcessedUsersSet)
    end.

per_user_common_rebuild(UserGuid) ->
    log_srv:debug("rebuilding common score for ~p", [UserGuid]),
    mnesia:activity(sync_dirty, fun() ->
                            AllUserScores = qlc:e(qlc:q([E || E <- mnesia:table(server_user_score), E#server_user_score.user_guid =:= UserGuid])),
                            CommonScore = calculate_common_score(AllUserScores),
                            inner_set_score(UserGuid, common, CommonScore)
                    end, [], mnesia_frag).

calculate_common_score(AllScores) ->
    lists:foldl(fun(UserScore, Accum) ->
                        Score = UserScore#server_user_score.score,
                        case UserScore#server_user_score.tag of
                            sympathy ->
                                Accum + Score * 12;
                            received_gifts ->
                                Accum + Score * 20;
                            sended_gifts ->
                                Accum + Score * 17;
                            rated ->
                                Accum + Score * 8;
                            vippoints ->
                                Accum + Score * 18;
                            _Other ->
                                Accum
                        end
                end, 0, AllScores).
