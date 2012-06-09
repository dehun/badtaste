<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>

<xsl:template match="field" mode="param">
  <xsl:value-of select="@name"/>
</xsl:template>

<xsl:template match="field" mode="init">
        self.<xsl:value-of select="@name"/> = <xsl:value-of select="@name"/>
</xsl:template>

<xsl:template match="field" mode="serialize">
        fields.append("\"<xsl:value-of select="@name"/>\" :" + "\"" + str(self.<xsl:value-of select="@name"/>) + "\"")
</xsl:template>

<xsl:template match="message">
class <xsl:value-of select="@name"/>:
    <xsl:if test="count(field) != 0">
    def __init__(self, <xsl:for-each select="field"><xsl:apply-templates select="." mode="param"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>):
        <xsl:apply-templates select="field" mode="init"/>
    </xsl:if>

    def serialize(self):
        result = "{"
        result += "\"<xsl:value-of select="@name"/>\" : {"
        fields = []
        <xsl:apply-templates select="field" mode="serialize"/>
        result += ','.join(fields)
        result += "}"
        result += "}"
        return result

    @staticmethod
    def deserialize():
        return <xsl:value-of select="@name"/>()
</xsl:template>

<xsl:template match="/protocol">
  <xsl:text>
import json
  </xsl:text>
  <xsl:apply-templates select="message"/>
</xsl:template>
</xsl:stylesheet>