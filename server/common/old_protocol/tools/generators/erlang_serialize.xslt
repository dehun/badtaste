<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>

<!-- serialize templates -->

  <xsl:template match="field[@type='list' and @of='int']" mode="serialize">
	++ serialize_field(Message#<xsl:value-of select="../@name"/>.<xsl:value-of select="@name"/>, 
	list_int, <xsl:value-of select="@name"/>)
  </xsl:template>

  <xsl:template match="field[@type='list' and @of='float']" mode="serialize">
	++ serialize_field(Message#<xsl:value-of select="../@name"/>.<xsl:value-of select="@name"/>, 
	list_float, <xsl:value-of select="@name"/>)
  </xsl:template>

  <xsl:template match="field[@type='list' and @of='string']" mode="serialize">
	++ serialize_field(Message#<xsl:value-of select="../@name"/>.<xsl:value-of select="@name"/>, 
	list_string, <xsl:value-of select="@name"/>)
  </xsl:template>

  <xsl:template match="field[@type='list' and @of='message']" mode="serialize">
	++ serialize_field(Message#<xsl:value-of select="../@name"/>.<xsl:value-of select="@name"/>, 
	list_message, <xsl:value-of select="@name"/>)
  </xsl:template>

  <xsl:template match="field" mode="serialize">
	++ serialize_field(Message#<xsl:value-of select="../@name"/>.<xsl:value-of select="@name"/>, 
	<xsl:value-of select="@type"/>, <xsl:value-of select="@name"/>)
  </xsl:template>

  <xsl:template match="message" mode="serialize">
	serialize(Message=#<xsl:value-of select="@name"/>{}) <xsl:text disable-output-escaping="yes"> -></xsl:text>
	_Result = "{\"<xsl:value-of select="@name"/>\" : {" 
	<xsl:for-each select="field">
	  <xsl:apply-templates select="." mode="serialize"/>
	  <xsl:if test="position() != last()">
		<xsl:text>++","  </xsl:text>
      </xsl:if>
	</xsl:for-each>
	++ "}}"
	;
	
  </xsl:template>


<!-- deserialize templates -->
  <!-- field deserialize -->
  <xsl:template match="field[@type='string']" mode="deserialize">
	<xsl:value-of select="@name"/> = binary_to_list(
	proplists:get_value(<xsl:text>&lt;&lt;"</xsl:text><xsl:value-of select="@name"/><xsl:text>"&gt;&gt;</xsl:text>, MessageBody))
  </xsl:template>

  <xsl:template match="field[@type='int']" mode="deserialize">
	<xsl:value-of select="@name"/> = bstring_to_int(
	proplists:get_value(<xsl:text>&lt;&lt;"</xsl:text><xsl:value-of select="@name"/><xsl:text>"&gt;&gt;</xsl:text>, MessageBody))
  </xsl:template>

  <xsl:template match="field[@type='float']" mode="deserialize">
	<xsl:value-of select="@name"/> = bstring_to_float(
	proplists:get_value(<xsl:text>&lt;&lt;"</xsl:text><xsl:value-of select="@name"/><xsl:text>"&gt;&gt;</xsl:text>, MessageBody))
  </xsl:template>

  <xsl:template match="field[@type='message']" mode="deserialize">
	<xsl:value-of select="@name"/> = deserialize_inner(
		proplists:get_value(<xsl:text>&lt;&lt;"</xsl:text><xsl:value-of select="@name"/><xsl:text>"&gt;&gt;</xsl:text>, MessageBody)
	)
  </xsl:template>

  <!-- lists deserialize -->
  <xsl:template match="field[@type='list' and @of='int']" mode="deserialize">
	<xsl:value-of select="@name"/> = deserialize_list(
	proplists:get_value(<xsl:text>&lt;&lt;"</xsl:text><xsl:value-of select="@name"/><xsl:text>"&gt;&gt;</xsl:text>, MessageBody), 
	int)
  </xsl:template>

  <xsl:template match="field[@type='list' and @of='float']" mode="deserialize">
	<xsl:value-of select="@name"/> = deserialize_list(
	proplists:get_value(<xsl:text>&lt;&lt;"</xsl:text><xsl:value-of select="@name"/><xsl:text>"&gt;&gt;</xsl:text>, MessageBody), 
	float)
  </xsl:template>

  <xsl:template match="field[@type='list' and @of='string']" mode="deserialize">
	<xsl:value-of select="@name"/> = deserialize_list(
	proplists:get_value(<xsl:text>&lt;&lt;"</xsl:text><xsl:value-of select="@name"/><xsl:text>"&gt;&gt;</xsl:text>, MessageBody), 
	string)
  </xsl:template>

  <xsl:template match="field[@type='list' and @of='message']" mode="deserialize">
	<xsl:value-of select="@name"/> = deserialize_list(
	proplists:get_value(<xsl:text>&lt;&lt;"</xsl:text><xsl:value-of select="@name"/><xsl:text>"&gt;&gt;</xsl:text>, MessageBody), 
	message)
  </xsl:template>


  <xsl:template match="message" mode="deserialize">
	<xsl:text>deserialize_message(</xsl:text>
	<xsl:text>&lt;&lt;"</xsl:text><xsl:value-of select="@name"/><xsl:text>"&gt;&gt;</xsl:text>,
	<xsl:text>MessageBody)</xsl:text>
	<xsl:text disable-output-escaping="yes"> -></xsl:text>
	#<xsl:value-of select="@name"/>{
	<xsl:for-each select="field">
	  <xsl:apply-templates select="." mode="deserialize"/>
	  <xsl:if test="position() != last()">
		<xsl:text>, </xsl:text>
	  </xsl:if>
	</xsl:for-each>
	<xsl:text>};</xsl:text>
	<xsl:text>&#10; </xsl:text>
  </xsl:template>


<!-- protocol template aka main -->
  <xsl:template match="/protocol">
	-module(<xsl:value-of select="@name"/>).
	-export([serialize/1, deserialize/1]).
	-include("protocol.hrl").
	-import(lists).
	-import(string).

	<!-- deserialize list -->
	deserialize_list(List, int) ->
	    lists:map(fun(X) -> bstring_to_int(X) end, List);
	deserialize_list(List, float) ->
	    lists:map(fun(X) -> bstring_to_float(X) end, List);
	deserialize_list(List, string) ->
	    lists:map(fun(X) -> binary_to_list(X) end, List);
	deserialize_list(List, message) ->
	    lists:map(fun(X) -> deserialize_inner(X) end, List);
	deserialize_list(_List, _Message) ->
	    fail.

	<!-- misc -->
	bstring_to_int(Bstring) ->
	    {Int, _Rest} = string:to_integer(binary_to_list(Bstring)),
	    Int.

	bstring_to_float(Bstring) ->
	    {Float, _Rest} = string:to_float(binary_to_list(Bstring)),
	    Float.


	<!-- serialization -->
	<xsl:text disable-output-escaping="yes">
	serialize_list([H | T], Type) ->
	   Head = serialize_field_inner(H, Type),
	   Values = lists:concat(
                            lists:map(
                                     fun(Val) -> string:concat(", ", serialize_field_inner(Val, Type)) end,
                                     T)
                            ),
	   string:concat(Head, Values);
	serialize_list([], _Type) -> [].
	

	serialize_field_inner(Value, message) ->
	    serialize(Value);
	serialize_field_inner(Value, Type) ->
	    lists:concat(['"', Value, '"']).

    serialize_field(Value, int, Name) ->
         lists:concat(['"', Name, '"', " : ", '"', Value, '"']);
    serialize_field(Value, string, Name) ->
	     lists:concat(['"', Name, '"', " : ", '"', Value, '"']);
	serialize_field(Value, float, Name) ->
	     lists:concat(['"', Name, '"', " : ", '"', Value, '"']);
	serialize_field(Value, message, Name) ->
	     lists:concat(['"', Name, '"', " : ", serialize_field_inner(Value, message)]);
	serialize_field(Values, list_int, Name)  ->
	     lists:concat(['"', Name, '"', " : ", '[', serialize_list(Values, int), ']']);
	serialize_field(Values, list_float, Name)  ->
	     lists:concat(['"', Name, '"', " : ", '[', serialize_list(Values, float), ']']);
	serialize_field(Values, list_string, Name)  ->
	     lists:concat(['"', Name, '"', " : ", '[', serialize_list(Values, string), ']']);
	serialize_field(Values, list_message, Name)  ->
	     lists:concat(['"', Name, '"', " : ", '[', serialize_list(Values, message), ']']);

	
	serialize_field(_Value, Type, Name) ->
	     {unknow_type, Name, Type}.
	    
	</xsl:text>

	
	<xsl:apply-templates select="message" mode="serialize"/>
	<xsl:text disable-output-escaping="yes">
	  serialize(_AnyOther) ->
         {failed}.
	</xsl:text>

	<!-- deserialization -->
	<xsl:apply-templates select="message" mode="deserialize"/>
	<xsl:text disable-output-escaping="yes">
	  deserialize_message(_Uknown, _Body) ->
	    failed.
	</xsl:text>

	deserialize(JsonData) <xsl:text disable-output-escaping="yes"> -></xsl:text>
	    {struct, MessageSt} = mochijson2:decode(JsonData),    
	    [MessageName] = proplists:get_keys(MessageSt),
	    {struct, MessageBody} = proplists:get_value(MessageName, MessageSt),
	    deserialize_message(MessageName, MessageBody).
	
	deserialize_inner(JsonData) <xsl:text disable-output-escaping="yes"> -></xsl:text>
	    {struct, MessageSt} = JsonData,    
	    [MessageName] = proplists:get_keys(MessageSt),
	    {struct, MessageBody} = proplists:get_value(MessageName, MessageSt),
	    deserialize_message(MessageName, MessageBody).
	
  </xsl:template>


</xsl:stylesheet>
