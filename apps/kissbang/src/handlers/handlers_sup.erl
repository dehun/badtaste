%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 26 Jun 2012 by  <>
%%%-------------------------------------------------------------------
-module(handlers_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @spec init(Args) -> {ok, {SupFlags, [ChildSpec]}} |
%%                     ignore |
%%                     {error, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    RestartStrategy = one_for_one,
    MaxRestarts = 1000,
    MaxSecondsBetweenRestarts = 3600,

    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

    Restart = permanent,
    Shutdown = 2000,
    Type = worker,

    Handlers = [{HandlerName, {HandlerName, start_link, []},
                Restart, Shutdown, Type, [HandlerName]} || HandlerName <- get_all_handlers()],

    {ok, {SupFlags, Handlers}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
get_all_handlers() ->
    lists:flatten(['ping_handler_srv',
                   get_admin_handlers(),
                   get_room_handlers(),
                   get_user_info_handlers(),
                   get_kiss_game_handlers(),
                   get_time_handlers(),
                   get_bank_handlers(),
                   get_rate_handlers(),
                   get_sympathy_handlers(),
                   get_decorations_handlers(),
                   get_followers_handlers(),
                   get_gift_handlers(),
                   get_vip_handlers(),
                   get_mail_handlers(),
                   get_chat_handlers(),
                   get_job_handlers(),
                   get_wannachat_handlers()]).


get_user_info_handlers() ->
    ['get_user_info_handler_srv',
    'get_user_info_by_social_id_handler_srv'].

get_admin_handlers() ->
    ['touch_user_info_handler_srv'].

get_room_handlers() ->
    ['join_main_roomqueue_handler_srv',
     'join_tagged_roomqueue_handler_srv'].

get_chat_handlers() ->
    ['send_chat_message_to_room_handler_srv',
     'send_vip_chat_message_to_room_handler_srv'].

get_kiss_game_handlers() ->
    ['kiss_handler_srv',
     'refuse_to_kiss_handler_srv',
     'swingbottle_handler_srv'].

get_time_handlers() ->
    ['get_current_time_handler_srv'].

get_bank_handlers() ->
    ['check_bank_balance_handler_srv'].

get_rate_handlers() ->
    ['get_user_rate_handler_srv',
     'delete_rate_point_handler_srv',
     'rate_user_handler_srv',
     'are_user_rated_handler_srv'].

get_gift_handlers() ->
    ['get_my_gifts_handler_srv',
     'get_user_gifts_handler_srv',
     'present_gift_handler_srv'].

get_vip_handlers() ->
    ['get_vip_points_handler_srv',
     'buy_vip_points_handler_srv',
     'get_random_vip_handler_srv'].

get_followers_handlers() ->
    ['get_followers_handler_srv',
     'buy_user_following_handler_srv'].

get_mail_handlers() ->
    ['check_mailbox_handler_srv',
     'mark_mail_as_read_handler_srv',
     'send_mail_handler_srv'].

get_sympathy_handlers() ->
    ['get_user_sympathies_handler_srv'].

get_decorations_handlers() ->
    ['get_decorations_for_handler_srv',
     'buy_decoration_handler_srv'].

get_job_handlers() ->
    ['get_user_completed_jobs_handler_srv'].
    
get_wannachat_handlers() ->
    ['buy_random_chatter_handler_srv',
     'get_random_chatter_handler_srv'].

