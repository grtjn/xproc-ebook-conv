<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:eb="http://grtjn.nl/ns/xproc/ebook"
	xmlns:x="http://www.w3.org/1999/xhtml"

	exclude-result-prefixes="#all">
	
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />
	
	<xsl:param name="title" />
	<xsl:param name="part" />
	<xsl:param name="position" />

	<xsl:variable name="this-list" select="//eb:notes-page[local-name(parent::*) = $part][count(preceding-sibling::eb:notes-page) + 1 = number($position)]"/>
	
	<xsl:param name="output-style" select="'#default'" />
	<xsl:param name="styles-uri"/>

	<xsl:variable name="styles" select="doc($styles-uri)/*"/>
	<xsl:param name="notes-page-break" select="($this-list/@page-break, $styles/style[@name = ($output-style, '#default')]/notes/@page-break, 5)[1]"/>
	
	<xsl:template match="/">
		<eb:part type="notes">
			<eb:section id="section-{generate-id()}">
				<x:div class="notes">
					<x:h1><xsl:value-of select="$title"/></x:h1>
					<x:table class="notes">
						<xsl:apply-templates select="//eb:note" />
					</x:table>
				</x:div>
			</eb:section>
		</eb:part>
	</xsl:template>
	
	<xsl:template match="eb:note">
		<x:tr class="note-item note-level{count(ancestor-or-self::eb:section)}">
			<x:td valign="top" class="note-ref">
				<xsl:value-of select="eb:note-ref/@n" />
			</x:td>
			<x:td valign="top" class="note-item-text">
				<eb:note-text>
					<xsl:copy-of select="eb:note-text/@*" />
					<x:div class="note-text">
						<xsl:copy-of select="eb:note-text/node()" />
					</x:div>
				</eb:note-text>
			</x:td>
			<x:td valign="bottom" class="note-item-page">
				<eb:page-ref ref-id="{eb:note-ref/@id}" />
			</x:td>
		</x:tr>
		<xsl:if test="((position() mod number($notes-page-break)) = 0) and not(position() = last())">
			<eb:page-break id="page-{generate-id()}"/>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
