<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:eb="http://grtjn.nl/ns/xproc/ebook"
	xmlns:x="http://www.w3.org/1999/xhtml"

	exclude-result-prefixes="#all">
	
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:param name="debug" select="false()"/>
	<xsl:param name="verbose" select="false()"/>

	<xsl:param name="debug_" select="lower-case(string($debug)) = ('1', 'j', 'y', 'yes', 'true')"/>
	<xsl:param name="verbose_" select="lower-case(string($verbose)) = ('1', 'j', 'y', 'yes', 'true')"/>
	
	<xsl:variable name="front-page-count" select="count(//eb:front//eb:page)"/>
	<xsl:variable name="main-page-count" select="count(//eb:main//eb:page)"/>
	
	<xsl:template match="@*|node()" mode="#all">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="#current" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="eb:page[not(@n)]">
		<xsl:variable name="n">
			<xsl:choose>
				<xsl:when test="exists(parent::eb:section/preceding-sibling::eb:section[1]/eb:page[last()]/@n)">
					<xsl:value-of select="concat(parent::eb:section/preceding-sibling::eb:section[1]/eb:page[last()]/@n, 'b')" />
				</xsl:when>
				<xsl:when test="exists(ancestor::eb:front)">
					<xsl:number value="count(preceding::eb:page) + 1" format="I"/>
				</xsl:when>
				<xsl:when test="exists(ancestor::eb:back)">
					<xsl:number value="count(preceding::eb:page) + 1 - $front-page-count - $main-page-count" format="A"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:number value="count(preceding::eb:page) + 1 - $front-page-count" format="1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$debug_">
			<xsl:message>Assigning page-number <xsl:value-of select="$n"/> to page <xsl:value-of select="@id"/></xsl:message>
		</xsl:if>
		<eb:page n="{$n}" preceding="{count(preceding::eb:page)}" front="{$front-page-count}" main="{$main-page-count}">
			<xsl:apply-templates select="@*|node()" />
		</eb:page>
	</xsl:template>

</xsl:stylesheet>
