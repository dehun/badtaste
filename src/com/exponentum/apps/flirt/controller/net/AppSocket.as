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
import flash.utils.setTimeout;

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
			writeUnsignedInt(str.length);
			writeUTFBytes(str);
		}
		catch (e:IOError)
		{
			trace(e);
		}
	}

	public function sendRequest(data:Object):void
	{
		response = "";
		write(JSON.encode(data));
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

//	private function socketDataHandler(event:ProgressEvent):void
//	{
//		while (bytesAvailable) {
//			try
//			{
//				var size:int = readInt();
//				var str:String = readUTFBytes(size);
//				trace(str);
//				response += str;
//
//
//			}
//			catch( e : EOFError )
//			{
//				trace("\n", e );     // EOFError: Error #2030: End of file was encountered.
//			}
//
//			trace("<-\n", response);
//			Cc.log("<-", response);
//			for (var key:String in JSON.decode(response))
//			{
//				dispatchEvent(new ObjectEvent(key, JSON.decode(response)[key]));
//			}
//			response = "";
//		}
//
//	}
	private function readResponse():int
	{
		var size:int = readInt();
		var str:String = readUTFBytes(size);
		response += str;
		trace("->", response);
		Cc.log("<-", response);
		for (var key:String in JSON.decode(response))
		{
			dispatchEvent(new ObjectEvent(key, JSON.decode(response)[key]));
		}
		response = "";
		return size + 4;
	}

	private function socketDataHandler(event:ProgressEvent):void
	{
		var dataToProcess:int = bytesAvailable;
		var dataProcessed:int = 0;
		while (dataProcessed < dataToProcess) {
			dataProcessed += readResponse();
		}
	}
}
}