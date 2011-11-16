<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:x="http://www.w3.org/1999/xhtml"
	
	exclude-result-prefixes="#all">

	<xsl:include href="../xhtml/get-main-matter.xsl"/>
	
	<xsl:template match="/" priority="10">
		<!-- already xhtml -->
		<x:div>
			<xsl:apply-templates select="//x:div[@id = 'content']"/>
		</x:div>
	</xsl:template>
	
	<xsl:template match="*[@class = ('editsection', 'toc', 'articleFeedback', 'navbox') or @id = ('jump-to-nav', 'catlinks')]"/>
	
</xsl:stylesheet>