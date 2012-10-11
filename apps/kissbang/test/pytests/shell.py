from connection import Connection
from kissbang_messaging import *
from kissbang_json_messaging import jsonSerializer, jsonDeserializer
import os

class Shell:
    def __init__(self, addr, port):
        self._connection = Connection(addr, port, [self])

    def connect(self):
        self._connection.connect()

    def send_message(self, message):
        jsonMessage = jsonSerializer.serialize(message)
        print "[>>>] " + jsonMessage
        self._connection.send_message(jsonMessage)

    def on_got_message(self, message):
        print "[<<<] " + message
        try:
            jsonDeserializer.deserialize(message)
        except Exception as e:
            print "[!!!] error on message deserializing"
            print e
