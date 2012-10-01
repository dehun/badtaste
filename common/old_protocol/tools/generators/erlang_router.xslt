<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>

<xsl:template match="message[destination != 'client']">
   route_message(UserId, Message=#<xsl:value-of select="@name"/>{}, Callback) <xsl:text disable-output-escaping="yes">-></xsl:text>
       vs_logger:debug("[vs_proxy] routing message <xsl:value-of select="destination"/>"),
       <xsl:value-of select="destination"/>:handle_message(UserId, Message, Callback);
</xsl:template>

<xsl:template match="message">
</xsl:template>

<xsl:template match="/protocol">
  -module(<xsl:value-of select="@name"/>_router).
  -include("<xsl:value-of select="@name"/>.hrl").
  -export([route_message/3]).
  <xsl:apply-templates select="message"/>
  <xsl:text disable-output-escaping="yes">
  route_message(_UserId, UnknownMessage, _Callback) ->	
  	   {unknown_message, UnknownMessage}.
  </xsl:text>
</xsl:template>


</xsl:stylesheet>
