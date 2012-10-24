%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 22 Oct 2012 by  <>
%%%-------------------------------------------------------------------
-module(vk_social_handler_srv).

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 
-include("item.hrl").


-record(state, {config}).
-record(config, {items = []}).


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
    {ok, #state{config = load_config()}}.

load_config() ->
    {ok, ItemsUrl} = application:get_env(kissbang, vk_items_cfg_url),
    #config{items = items_loader:load_items(ItemsUrl)}.
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
handle_cast({handle_social_callback, Req}, State) ->
    inner_handle_social_callback(Req, State#state.config),
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
inner_handle_social_callback(Req, Config) ->
    %% get post data
    PostData = Req:parse_post(),
    %% check signature
    case check_signature(PostData) of
        ok ->
            case proplists:get_value("notification_type", PostData) of
                "get_item" ->
                    inner_handle_get_item(PostData, Req, Config);
                "get_item_test" ->
                    inner_handle_get_item(PostData, Req, Config);
                "order_status_change" ->
                    inner_handle_order_status_change(PostData, Req, Config);
                "order_status_change_test" ->
                    inner_handle_order_status_change(PostData, Req, Config);
                _Other ->
                    Req:respond({200, ["Content-Type", "application/json"], '{"error" : "invalid notification type"'})
        end;
        fail ->
            Req:respond({200, ["Content-Type", "application/json"], '{"error" : "invalid signature"'})
    end.

check_signature(_PostData) ->
    %% TODO : implement me
    ok.
                
inner_handle_get_item(PostData, Req, Config) ->
    ItemId = list_to_integer(proplists:get_value("item", PostData)),
    false = ItemId == undefined,
    {value, Item} = lists:keysearch(ItemId, 2, Config#config.items),
    JsonResponse = io_lib:format('{"response" : {"item_id" : "~p", "title" : "~p", "photo_url" : "~p", "price" : "~p"}}',
                               [Item#item.item_id, Item#item.name, Item#item.image_url, Item#item.price]),
    Req:repond({200, ["Content-Type", "application/json"], JsonResponse}).

inner_handle_order_status_change(PostData, Req, Config) ->
    case proplists:get_value("status") of
        "chargeable" ->
            OrderId = proplists:get_value("order_id", PostData),
            ItemId = list_to_integer(proplists:get_value("item_id", PostData)),
            UserId = proplists:get_value("user_id", PostData),
            {value, Item} = lists:keysearch(ItemId, 2, Config#config.items),
            social_handler:on_item_bought(UserId, Item),
            JsonResponse = io_lib:format('{"response" : {"order_id" : "~p", "app_order_id" : "1"}}', [OrderId]),
            Req:respond({200, ["Content-Type", "application/json"], JsonResponse});
        _Other ->
            JsonResponse = '{"error" : {"error_code" : "100", "error_msg" : "non chargable", "critical" : "true"}}',
            Req:respond({200, ["Content-Type", "application/json"], JsonResponse})
    end.
                
