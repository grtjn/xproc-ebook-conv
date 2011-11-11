<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:x="http://www.w3.org/1999/xhtml"
	
	exclude-result-prefixes="#all">

	<xsl:template match="/">
		<!-- already xhtml -->
		<x:div>
			<xsl:apply-templates select="//x:div[@id = 'content']"/>
		</x:div>
	</xsl:template>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@href | @src">
		<xsl:attribute name="{name()}">
			<xsl:choose>
				<xsl:when test="starts-with(., '//')">
					<xsl:value-of select="concat('http:', .)"/>
				</xsl:when>
				<xsl:when test="starts-with(., '/')">
					<xsl:value-of select="concat(replace(base-uri(), '^(http://[^/]+/).*$', '$1'), .)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="*[@class = ('editsection', 'toc', 'articleFeedback', 'navbox') or @id = ('jump-to-nav', 'catlinks')]"/>
	
	<xsl:template match="@class[. = '']"/>
	
</xsl:stylesheet>