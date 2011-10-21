<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:eb="http://grtjn.nl/ns/xproc/ebook"
	xmlns:x="http://www.w3.org/1999/xhtml"

	exclude-result-prefixes="#all">
	
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:param name="debug" select="false()"/>
	<xsl:param name="verbose" select="false()"/>
	<xsl:param name="strip-notes" select="true()"/>

	<xsl:param name="debug_" select="lower-case(string($debug)) = ('1', 'j', 'y', 'yes', 'true')"/>
	<xsl:param name="verbose_" select="lower-case(string($verbose)) = ('1', 'j', 'y', 'yes', 'true')"/>
	<xsl:param name="strip-notes_" select="lower-case(string($strip-notes)) = ('1', 'j', 'y', 'yes', 'true')"/>
	
	<xsl:template match="@*|node()" mode="#all">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="#current" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="eb:note">
		<xsl:apply-templates select="eb:note-ref" />
	</xsl:template>
	
	<xsl:template match="eb:note-nr">
		<eb:note-ref>
			<xsl:apply-templates select="@*|node()" mode="#current" />
		</eb:note-ref>
	</xsl:template>
	
</xsl:stylesheet>
