%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 21 Aug 2012 by  <>
%%%-------------------------------------------------------------------
-module(mail_srv).

-include_lib("stdlib/include/qlc.hrl").
-include("kissbang_messaging.hrl").
-behaviour(gen_server).

%% API
-export([start_link/0,
        setup_db/0]).

-export([get_user_mail/1,
         send_mail/5,
         send_mail/4,
         mark_mail_as_read/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================
get_user_mail(UserGuid) ->
    gen_server:call(?SERVER, {get_user_mail, UserGuid}).

send_mail(SenderGuid, ReceiverGuid, Subject, Body) ->
    send_mail(SenderGuid, ReceiverGuid, Subject, Body, "usermail").

send_mail(SenderGuid, ReceiverGuid, Subject, Body, Type) ->
    gen_server:call(?SERVER, {send_mail, SenderGuid, ReceiverGuid, Subject, Body, Type}).

mark_mail_as_read(MailGuid)->
    gen_server:call(?SERVER, {mark_mail_as_read, MailGuid}).

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
    Result = mnesia:create_table(mail,
                                 [{frag_properties, [{node_pool, [node() | nodes()]}, {n_fragments, 8}, {n_disc_copies, 1}]},
                                  {type, bag},
                                  {index, [mail_guid]},
                                  {attributes, record_info(fields, mail)}]),
    case Result of
        {atomic, ok} ->
            mnesia:wait_for_tables([mail], 5000),
            ok;
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([mail], 5000),
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
handle_call({get_user_mail, UserGuid}, From, State) ->
    utils:acall(fun() -> inner_get_mail_for(UserGuid) end, From),
    {noreply, State};
handle_call({send_mail, SenderGuid, ReceiverGuid, Subject, Body, Type}, From, State) ->
    utils:acall(fun() -> inner_send_mail(SenderGuid, ReceiverGuid, Subject, Body, Type) end, From),
    {noreply, State};
handle_call({mark_mail_as_read, MailGuid}, From, State) ->
    utils:acall(fun() -> inner_mark_mail_as_read(MailGuid) end, From),
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
inner_get_mail_for(UserGuid) ->
    Trans = fun() ->
                    qlc:e(qlc:q([Mail || Mail <- mnesia:table(mail), 
                                         (Mail#mail.sender_guid =:= UserGuid) or (Mail#mail.receiver_guid =:= UserGuid)]))
            end,
    mnesia:activity(sync_dirty, Trans, [], mnesia_frag).

inner_send_mail(SenderGuid, ReceiverGuid, Subject, Body, Type) ->
    Trans = fun() ->
                    {ok, NewMailGuid} = guid_srv:create(),
                    NewMail = #mail{mail_guid = NewMailGuid,
                                    sender_guid = SenderGuid,
                                    receiver_guid = ReceiverGuid,
                                    type = Type,
                                    date_send = utils:unix_time(),
                                    subject = Subject,
                                    body = Body,
                                    is_read = "false"},
                    mnesia:write(NewMail),
                    proxy_srv:route_messages(ReceiverGuid, [#on_got_new_mail{sender_guid = SenderGuid, 
                                                                             subject = Subject,
                                                                             body = Body}]),
                    ok
            end,
    mnesia:activity(sync_dirty, Trans, [], mnesia_frag).

inner_mark_mail_as_read(MailGuid) ->
    Trans = fun() ->
                    case qlc:e(qlc:q([Mail || Mail <- mnesia:table(mail), Mail#mail.mail_guid =:= MailGuid])) of
                        [] ->
                            no_such_mail;
                        [OldMail] ->
                            mnesia:delete(OldMail),
                            mnesia:write(OldMail#mail{is_read = "true"}),
                            ok
                        end
            end,
    mnesia:activity(sync_dirty, Trans, [], mnesia_frag).
