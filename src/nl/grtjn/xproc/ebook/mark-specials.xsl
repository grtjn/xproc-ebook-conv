<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:x="http://www.w3.org/1999/xhtml"
	xmlns:eb="http://grtjn.nl/ns/xproc/ebook"

	exclude-result-prefixes="x">
	
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:param name="debug" select="false()"/>
	<xsl:param name="verbose" select="false()"/>

	<xsl:param name="debug_" select="lower-case(string($debug)) = ('1', 'j', 'y', 'yes', 'true')"/>
	<xsl:param name="verbose_" select="lower-case(string($verbose)) = ('1', 'j', 'y', 'yes', 'true')"/>

	<xsl:template match="@*|comment()|processing-instruction()">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="*" name="copy">
		<xsl:element name="{name()}" namespace="{namespace-uri()}">
			<xsl:apply-templates select="@*|node()" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="x:span[@class = ('smallcaps', 'spatial')]">
		<eb:index-item id="item-{generate-id()}">
			<xsl:call-template name="copy"/>
		</eb:index-item>
	</xsl:template>

	<xsl:template match="x:figure">
		<eb:image xml:base="{base-uri(.)}" id="image-{generate-id()}" src="{.//x:img/@src}">
			<xsl:variable name="label" select="normalize-space(.)" />
			<xsl:choose>
				<xsl:when test="string-length($label) > 0">
					<xsl:attribute name="label" select="$label"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="label" select="concat('Ill. ', string(count(preceding::x:figure) + 1))"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="copy"/>
		</eb:image>
	</xsl:template>
	
	<xsl:template match="x:table">
		<eb:table id="table-{generate-id()}">
			<xsl:variable name="label" select="normalize-space(xxx)" /> <!-- disabled, no sensible result -->
			<xsl:choose>
				<xsl:when test="string-length($label) > 0">
					<xsl:attribute name="label" select="$label"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="label" select="concat('Tab. ', string(count(preceding::x:table) + 1))"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="copy"/>
		</eb:table>
	</xsl:template>
	
	<xsl:template match="eb:note">
		<eb:note>
			<eb:note-ref id="note-{generate-id()}-ref" ref-id="note-{generate-id()}">
				<xsl:copy-of select="@*" />
				<xsl:value-of select="@n"/>
			</eb:note-ref>
			<eb:note-text id="note-{generate-id()}">
				<xsl:apply-templates select="@*|node()" />
			</eb:note-text>
		</eb:note>
	</xsl:template>
	
</xsl:stylesheet>
