<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>

<xsl:template match="field">
  <xsl:value-of select="@name"/>
</xsl:template>

<xsl:template match="message">
  	-record(<xsl:value-of select="@name"/>, {
	<xsl:for-each select="field">
	  <xsl:apply-templates select="."/>
	  <xsl:if test="position() != last()">
                <xsl:text>,  </xsl:text>
      </xsl:if>
	</xsl:for-each>
	}).
</xsl:template>

<xsl:template match="/protocol">
  <xsl:apply-templates select="message"/>
</xsl:template>


</xsl:stylesheet>
