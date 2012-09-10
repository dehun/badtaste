/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 7/4/12
 * Time: 10:13 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.controller.net
{
import com.adobe.serialization.json.JSON;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.junkbyte.console.Cc;

import flash.errors.EOFError;
import flash.errors.IOError;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.system.Security;
import flash.utils.ByteArray;

public class AppSocket extends Socket
{
	private var response:String;

	public function AppSocket(server:String, port:int)
	{
		super();
		configureListeners();

		Security.loadPolicyFile("http://" + ServerConfig.SERVER + "/crossdomain.xml");

		super.connect(server, port);
	}

	private function configureListeners():void
	{
		addEventListener(Event.CLOSE, closeHandler);
		addEventListener(Event.CONNECT, connectHandler);
		addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
	}

	private function write(str:String):void
	{
		try
		{
			writeUnsignedInt(getNumBytesUTF8(str));
			writeUTFBytes(str);
		}
		catch (e:IOError)
		{
			trace(e);
		}
	}

	private function getNumBytesUTF8 (s:String):Number {
		var byteArray:ByteArray = new ByteArray();
		byteArray.writeUTFBytes(s);
		return byteArray.length;
	}

	public function sendRequest(data:Object):void
	{
		response = "";
		write(JSON.encode(data));
		trace("->", JSON.encode(data).length);
		trace("->", JSON.encode(data));
		Cc.log("->", JSON.encode(data));
		flush();
	}

	private function closeHandler(event:Event):void
	{
		trace("closeHandler: " + event);
		trace(response.toString());
	}

	private function connectHandler(event:Event):void
	{
		trace("~~~ connection established ~~~");
		Cc.log("~~~ connection established ~~~");

	}

	private function ioErrorHandler(event:IOErrorEvent):void
	{
		trace("IOError: " + event);
	}

	private function securityErrorHandler(event:SecurityErrorEvent):void
	{
		trace("SecurityError: " + event);
	}

	private function readResponse():int
	{
		var size:int = readInt();
		var str:String = "";
		trace("\n",size,"\n");
		try{
			str = readUTFBytes(size);
			response += str;
			trace("->", response);
			for (var key:String in JSON.decode(response))
				dispatchEvent(new ObjectEvent(key, JSON.decode(response)[key]));
			response = "";
		}catch(e:EOFError)
		{
			trace(e);
		}
		return size + 4;
	}

	private var _lastSize:int;
	private function readChunk():int
	{
		// extract data from buff
		var sizeToReturn:int = 0;
		var data:String = "";
		if (_lastSize == 0) {
			_lastSize = readInt();
			sizeToReturn = _lastSize + 4;
		} else {
			sizeToReturn = _lastSize;
		}
		data = readUTFBytes(_lastSize);
		_lastSize = 0;

		// process data
		trace("->", data);
		//Cc.log("<-", data);

		for (var key:String in JSON.decode(data))
		{
			dispatchEvent(new ObjectEvent(key, JSON.decode(data)[key]));
		}
		return sizeToReturn;
	}

	private function socketDataHandler(event:ProgressEvent):void
	{
		var dataToProcess:int = event.bytesLoaded;
		var dataProcessed:int = 0;
		try {
			while (dataProcessed < dataToProcess) {
				dataProcessed += readChunk();
			}
		} catch (e:EOFError) {}// here catch EOF

	}
}
}