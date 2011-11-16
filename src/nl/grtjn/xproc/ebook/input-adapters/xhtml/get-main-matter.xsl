<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:x="http://www.w3.org/1999/xhtml"
	
	exclude-result-prefixes="#all">
	
	<xsl:variable name="file-name" select="replace(base-uri(), '^(.*/)?([^/]+)$', '$2')"/>
	<xsl:variable name="file-name-id" select="replace($file-name, '[^a-zA-Z0-9_\.]', '_')"/>

	<xsl:template match="/">
		<!-- already xhtml -->
		<x:div>
			<xsl:apply-templates select="x:html/x:body/node()"/>
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

	<xsl:template match="@class[. = '']"/>
	
	<xsl:template match="@lang" priority="2">
		<xsl:attribute name="xml:lang" select="."/>
	</xsl:template>

	<xsl:template match="x:br[@clear]" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="@* except (@clear, @style)"/>
			<!-- transitional xhtml @clear not allowed in strict xhtml of epub, convert/append to style attribute -->
			<xsl:attribute name="style" select="string-join((@style, concat('clear: ', @clear)), '; ')"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="x:td[@width]" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="@* except (@width, @style)"/>
			<!-- @width is non-xhtml, convert/append to style attribute -->
			<xsl:attribute name="style" select="string-join((@style, concat('width: ', @width)), '; ')"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@id|x:a/@name" priority="2">
		<xsl:attribute name="id" select="concat($file-name-id, '_', translate(replace(., '^\.', '_'), ':', '_'))"/>
	</xsl:template>

	<xsl:template match="@href[starts-with(., '#')]" priority="2">
		<xsl:attribute name="href" select="concat('#', $file-name-id, '_', substring-after(., '#'))"/>
	</xsl:template>

	<xsl:template match="x:img[not(parent::x:figure)]">
		<x:figure>
			<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
			</xsl:copy>
		</x:figure>
	</xsl:template>
	
</xsl:stylesheet>