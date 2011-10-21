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
	
	<xsl:variable name="this-list" select="//eb:list-of-tables[local-name(parent::*) = $part][count(preceding-sibling::eb:list-of-tables) + 1 = number($position)]"/>
	
	<xsl:param name="output-style" select="'#default'" />
	<xsl:param name="styles-uri"/>

	<xsl:variable name="styles" select="doc($styles-uri)/*"/>
	<xsl:param name="lot-page-break" select="($this-list/@page-break, $styles/style[@name = ($output-style, '#default')]/lot/@page-break, 20)[1]"/>
	
	<xsl:template match="/">
		<eb:part type="list-of-tables">
			<eb:section id="section-{generate-id()}">
				<x:div class="list-of-tables">
					<x:h1><xsl:value-of select="$title"/></x:h1>
					<x:table class="list-of-tables">
						<xsl:apply-templates select="//eb:table" />
					</x:table>
				</x:div>
			</eb:section>
		</eb:part>
	</xsl:template>
	
	<xsl:template match="eb:table">
		<x:tr class="toc-item">
			<x:td class="toc-item-text">
				<xsl:value-of select="@label"/>
			</x:td>
			<x:td class="toc-item-page">
				<eb:page-ref ref-id="{@id}" />
			</x:td>
		</x:tr>
		<xsl:if test="((position() mod number($lot-page-break)) = 0) and not(position() = last())">
			<eb:page-break id="page-{generate-id()}"/>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
