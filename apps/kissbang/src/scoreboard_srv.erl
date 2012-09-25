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

-record(userscore, {user_guid, tag, score}).
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
    Result = mnesia:create_table(userscore,
                                 [{frag_properties, [{node_pool, [node() | nodes()]}, {n_fragments, 32}, {n_disc_copies, 1}]},
                                  {type, bag},
                                  {index, [user_guid, tag]},
                                  {attributes, record_info(fields, userscore)}]),
    case Result of
        {atomic, ok} ->
            mnesia:wait_for_tables([userscore], 5000);
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([userscore], 5000);
        {aborted, Reason} ->
            erlang:error(Reason)
    end,
    Result = mnesia:create_table(toplist, [{disc_copies, [node() | nodes()]}, 
                                            {attributes, record_info(fields, toplist)}]),
    case Result of
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
                    case qlc:e(qlc:e([E || E <- mnesia:table(userscore), E#userscore.tag =:= Tag, E#userscore.user_guid =:= UserGuid])) of
                        [] ->
                            [];
                        [OldScore] ->
                            mnesia:delete_object(OldScore)
                    end,
                    mnesia:write(#userscore{user_guid = UserGuid, tag = Tag, score = Amount})
            end,
    mnesia:activity(sync_dirty, Trans, [], mnesia_frag).

inner_add_score(UserGuid, Tag, Amount) ->
    Trans = fun() ->
                    case qlc:e(qlc:e([E || E <- mnesia:table(userscore), E#userscore.tag =:= Tag, E#userscore.user_guid =:= UserGuid])) of
                        [] ->
                            mnesia:write(#userscore{user_guid = UserGuid, tag = Tag, score = Amount});
                        [OldScore] ->
                            mnesia:write(OldScore#userscore{score = Amount + OldScore#userscore.score})
                    end
            end,
    mnesia:activity(sync_dirty, Trans, [], mnesia_frag).

inner_get_top_list(Tag, Period)  ->
    inner_try_rebuild_top_list(Tag, Period),
    Trans = fun() ->
                    [TopList] = qlc:e(qlc:q([T || T <- mnesia:table(toplist), T#toplist.tag =:= Tag, T#toplist.period =:= Period])),
                    TopList
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
                       C = qlc:cursor(qlc:sort(qlc:q([E || E <- mnesia:table(userscore), E#userscore.tag =:= Tag]), 
                                                 fun(E1, E2) -> E1#userscore.score < E2#userscore.score end)),
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
    

    
