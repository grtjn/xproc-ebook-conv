<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:x="http://www.w3.org/1999/xhtml"
	
	exclude-result-prefixes="#all">

	<xsl:template match="/">
		<!-- already xhtml -->
		<xsl:copy-of select="x:html/x:body/*"/>
	</xsl:template>
	
</xsl:stylesheet>