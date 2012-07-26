-module(room_ext).

-export([link_room/2,
         on_room_became_active/1, 
         on_user_join/2, 
         on_user_leave/2, 
         on_room_death/1,
         handle_extension_message/2]).

%%%===================================================================
%%% API
%%%===================================================================
link_room(ExtensionsPid, RoomPid) ->
    link(RoomPid),
    gen_fsm:sync_send_all_state_event(ExtensionsPid, {link_room, RoomPid}).

on_room_became_active(ExtensionPid) ->
    gen_fsm:sync_send_event(ExtensionPid, {on_room_became_active}).

on_user_join(ExtensionPid, UserGuid) ->
    gen_fsm:sync_send_all_state_event(ExtensionPid, {on_user_join, UserGuid}).

on_user_leave(ExtensionPid, UserGuid) ->
    gen_fsm:sync_send_all_state_event(ExtensionPid, {on_user_leave, UserGuid}).

on_room_death(ExtensionPid) ->
    gen_fsm:sync_send_all_state_event(ExtensionPid, {on_room_death}).

handle_extension_message(ExtensionPid, Message) ->
    gen_fsm:send_event(ExtensionPid, {handle_extension_message, Message}).

