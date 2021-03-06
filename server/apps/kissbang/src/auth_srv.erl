%%%-------------------------------------------------------------------
%%% @author  <dehun@localhost>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 28 May 2012 by  <dehun@localhost>
%%%-------------------------------------------------------------------
-module(auth_srv).

-behaviour(gen_server).

-include_lib("stdlib/include/qlc.hrl").


%% API
-export([start_link/0, setup_db/0]).
-export([auth/2, 
         register/2, 
         drop_all_users/0, 
         is_registered/1,
         get_guid_for/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {}).


%%%===================================================================
%%% API
%%%===================================================================
is_registered(Login) ->
    gen_server:call(?SERVER, {is_registered, Login}).

auth(Login, Pass) ->
    gen_server:call(?SERVER, {auth, Login, Pass}).

get_guid_for(Login) ->
    gen_server:call(?SERVER, {get_guid_for, Login}).

register(Login, Pass) ->
    gen_server:call(?SERVER, {register, Login, Pass}).

drop_all_users() ->
    gen_server:call(?SERVER, {drop_all_users}).

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
%    setup_db(),
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

handle_call({is_registered, Login}, From, State) ->
    spawn_link(fun() ->
                       Reply = inner_is_registered(Login),
                       gen_server:reply(From, Reply)
               end),
    {noreply, State};
handle_call({get_guid_for, Login}, From, State) ->
    spawn_link(fun() ->
                       Reply = inner_get_guid_for(Login),
                       gen_server:reply(From, Reply)
               end),
    {noreply, State};
handle_call({auth, Login, Pass}, From, State) ->
    spawn_link(fun() ->
                       Reply = inner_auth(Login, Pass),
                       gen_server:reply(From, Reply)
               end),
    {noreply, State};
handle_call({register, Login, Pass}, From, State) ->
    spawn_link(fun() ->
                       Reply = inner_register(Login, Pass),
                       gen_server:reply(From, Reply)
               end),
    {noreply, State};
handle_call({drop_all_users}, _From, State) ->
    Reply = inner_drop_all_users(),
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
-record(authinfo, {guid, login, password}).

setup_db() ->
    Result = mnesia:create_table(authinfo, [{disc_copies, [node() | nodes()]}, 
                                            {attributes, record_info(fields, authinfo)}]),
    case Result of
        {atomic, ok} ->
            mnesia:wait_for_tables([authinfo], 5000),
            ok;
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([authinfo], 5000),
            ok;
        {aborted, Reason} ->
            erlang:error(Reason)
        end.

inner_register(Login, Password) ->
    log_srv:info("registering user ~p with password ~p", [Login, Password]),
    Trans = fun() ->
                    Existance = qlc:e(qlc:q([X || X <- mnesia:table(authinfo),
                                      X#authinfo.login == Login])),
                    case Existance of
                        [] ->
                            AuthInfo = #authinfo{guid = element(2, guid_srv:create()),
                                                 login = Login,
                                                 password = Password},
                            mnesia:write(AuthInfo),
                            ok;
                        [_] ->
                            already_exists
                    end
            end,
    {atomic, Result} = mnesia:transaction(Trans),
    Result.
    
inner_auth(Login, Password) ->
    Trans = fun() ->
                    Existance = qlc:e(qlc:q([X || X <- mnesia:table(authinfo),
                                    X#authinfo.login == Login])),
                    case Existance of
                        [] ->
                            no_such_user;
                        [AuthRec] ->
                            case AuthRec#authinfo.password of
                                Password ->
                                    {ok, AuthRec#authinfo.guid};
                                _ ->
                                    invalid_password
                                end
                    end
            end,
    {atomic, Result} = mnesia:transaction(Trans),
    Result.

inner_drop_all_users() ->
    Trans = fun() ->
                    [mnesia:delete({authinfo, Key}) || Key <- mnesia:all_keys(authinfo)],
                    ok
            end,
    {atomic, ok} = mnesia:transaction(Trans),
    ok.
    
inner_is_registered(Login) ->
    Trans = fun() ->
                    Existance = qlc:e(qlc:q([X || X <- mnesia:table(authinfo),
                                                  X#authinfo.login =:= Login])),
                    case Existance of
                        [] ->
                            {false, no_such_user};
                        [UserInfo] ->
                            {true, UserInfo#authinfo.guid}
                        end
            end,
    mnesia:activity(sync_dirty, Trans).

inner_get_guid_for(Login) ->
    Trans = fun() ->
                    Existance = qlc:e(qlc:q([X || X <- mnesia:table(authinfo),
                                                  X#authinfo.login =:= Login])),
                    case Existance of
                        [] ->
                            {false, no_such_user};
                        [UserInfo] ->
                            {true, UserInfo#authinfo.guid}
                        end
            end,
    mnesia:activity(sync_dirty, Trans).
