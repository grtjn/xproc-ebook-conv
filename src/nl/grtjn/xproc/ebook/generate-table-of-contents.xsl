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

	<xsl:variable name="this-list" select="//eb:table-of-contents[local-name(parent::*) = $part][count(preceding-sibling::eb:table-of-contents) + 1 = number($position)]"/>
	
	<xsl:param name="output-style" select="'#default'" />
	<xsl:param name="styles-uri"/>

	<xsl:variable name="styles" select="doc($styles-uri)/*"/>
	<xsl:param name="toc-max-level" select="($this-list/@max-level, $styles/style[@name = ($output-style, '#default')]/toc/@max-level, 3)[1]"/>
	<xsl:param name="toc-page-break" select="($this-list/@page-break, $styles/style[@name = ($output-style, '#default')]/toc/@page-break, 20)[1]"/>
	
	<xsl:template match="/">
		<eb:part type="table-of-contents">
			<eb:section id="section-{generate-id($this-list)}">
				<x:div class="toc">
					<x:h1><xsl:value-of select="$title"/></x:h1>
					<x:table class="table-of-contents">
						<xsl:apply-templates select="*" />
					</x:table>
				</x:div>
			</eb:section>
		</eb:part>
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:apply-templates select="*" />
	</xsl:template>
	
	<xsl:template match="eb:section">
		<xsl:variable name="position" select="count((ancestor-or-self::eb:* | preceding::eb:*)[count(ancestor-or-self::eb:section) le number($toc-max-level)][self::eb:section or self::eb:table-of-contents]) + 1"/>
		<xsl:variable name="not-last" select="exists(following::eb:*[self::eb:section or self::eb:table-of-contents])"/>
		<xsl:variable name="toc-level" select="count(ancestor-or-self::eb:section)"/>
		<xsl:if test="$toc-level le number($toc-max-level)">
			<xsl:variable name="title" select="normalize-space((*/(x:h1 | x:h2 | x:h3 | x:h4 | x:h5 | x:h6))[1])"/>
			<xsl:if test="string-length($title) > 0">
				<x:tr class="toc-item toc-level{$toc-level}">
					<x:td class="toc-item-text">
						<xsl:value-of select="$title"/>
					</x:td>
					<x:td class="toc-item-page">
						<eb:page-ref ref-id="{@id}" />
					</x:td>
				</x:tr>
			</xsl:if>
			<xsl:if test="(($position mod number($toc-page-break)) = 0) and $not-last">
				<eb:page-break id="page-{generate-id()}"/>
			</xsl:if>
			<xsl:apply-templates select="*" />
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="eb:table-of-contents">
		<xsl:variable name="position" select="count((ancestor-or-self::eb:* | preceding::eb:*)[count(ancestor-or-self::eb:section) le number($toc-max-level)][self::eb:section or self::eb:table-of-contents]) + 1"/>
		<xsl:variable name="not-last" select="exists(following::eb:*[self::eb:section or self::eb:table-of-contents])"/>
		<xsl:variable name="toc-level" select="1"/>
		<xsl:if test="$toc-level le number($toc-max-level)">
			<x:tr class="toc-item toc-level{$toc-level}">
				<x:td class="toc-item-text">
					<xsl:value-of select="normalize-space(@label)"/>
				</x:td>
				<x:td class="toc-item-page">
					<eb:page-ref ref-id="section-{generate-id($this-list)}" />
				</x:td>
			</x:tr>
			<xsl:if test="(($position mod number($toc-page-break)) = 0) and $not-last">
				<eb:page-break id="page-{generate-id()}"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
