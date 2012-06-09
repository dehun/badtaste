<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>

<!-- message declaration -->
<xsl:template match="field" mode="param">
  <xsl:value-of select="@name"/>
</xsl:template>

<xsl:template match="field" mode="init">
        self.<xsl:value-of select="@name"/> = <xsl:value-of select="@name"/>
</xsl:template>

<!-- field serialization -->
<xsl:template match="field[@type='list' and @of='message']" mode="serialize">
        fields.append("\"<xsl:value-of select="@name"/>\" :" + "[" + ",".join([field.serialize() for field in self.<xsl:value-of select="@name"/>]) + "]")
</xsl:template>


<xsl:template match="field[@type='list']" mode="serialize">
        fields.append("\"<xsl:value-of select="@name"/>\" :" + "[" + ",".join([str(field) for field in self.<xsl:value-of select="@name"/>]) + "]")
</xsl:template>

<xsl:template match="field[@type='message']" mode="serialize">
        fields.append("\"<xsl:value-of select="@name"/>\" :" + "\"" + self.<xsl:value-of select="@name"/>.serialize() + "\"")
</xsl:template>

<xsl:template match="field" mode="serialize">
        fields.append("\"<xsl:value-of select="@name"/>\" :" + "\"" + str(self.<xsl:value-of select="@name"/>) + "\"")
</xsl:template>

<!-- field deserialization -->
<xsl:template match="field" mode="deserialize">
  <xsl:value-of select="@name"/> = loadedJson["<xsl:value-of select="@name"/>"]
</xsl:template>

<xsl:template match="field[@type='message']" mode="deserialize">
  <xsl:value-of select="@name"/> = DeserializeFactory.deserialize(loadedJson["<xsl:value-of select="@name"/>"])
</xsl:template>

<xsl:template match="field[@type='list' and @of='message']" mode="deserialize">
  <xsl:value-of select="@name"/> = DeserializeFactory.deserialize(loadedJson["<xsl:value-of select="@name"/>"])
</xsl:template>

<!-- message declaration templates -->
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
    def deserialize(loadedJson):
         return <xsl:value-of select="@name"/>(
         <xsl:for-each select="field">
           <xsl:apply-templates select="." mode="deserialize"/>
           <xsl:if test="position() != last()">,</xsl:if>
         </xsl:for-each>
         )
</xsl:template>


<!-- protocol template -->
<xsl:template match="/protocol">
  <xsl:text>
import json
  </xsl:text>
  <xsl:apply-templates select="message"/>

class DeserializeFactory:
    @staticmethod
    def deserialize(jsonData):
        loadedJson = json.loads(jsonData)
        messageName = loadedJson.keys()[0]
        return globals()[messageName].deserialize(loadedJson[messageName])

</xsl:template>

</xsl:stylesheet>