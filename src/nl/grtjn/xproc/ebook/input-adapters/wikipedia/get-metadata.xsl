<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:x="http://www.w3.org/1999/xhtml"
	
	exclude-result-prefixes="#all">

	<xsl:template match="/">
		<!-- convert head to metadata -->
		<xsl:for-each select="x:html/x:head/*">
			<xsl:copy-of select="."/>
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>