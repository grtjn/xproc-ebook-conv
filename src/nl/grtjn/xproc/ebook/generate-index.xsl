<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:eb="http://grtjn.nl/ns/xproc/ebook"
	xmlns:x="http://www.w3.org/1999/xhtml"

	exclude-result-prefixes="#all">
	
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />
	
	<xsl:key name="index-items" match="eb:index-item" use="lower-case(normalize-space(.))"/>
	
	<xsl:param name="title" />
	<xsl:param name="part" />
	<xsl:param name="position" />
	
	<xsl:variable name="this-list" select="//eb:index[local-name(parent::*) = $part][count(preceding-sibling::eb:index) + 1 = number($position)]"/>
	
	<xsl:param name="output-style" select="'#default'" />
	<xsl:param name="styles-uri"/>

	<xsl:variable name="styles" select="doc($styles-uri)/*"/>
	<xsl:param name="index-page-break" select="($this-list/@page-break, $styles/style[@name = ($output-style, '#default')]/index/@page-break, 15)[1]"/>
	
	<xsl:template match="/">
		<xsl:variable name="index-ids" as="element()*">
			<xsl:for-each-group select="//eb:index-item" group-by="upper-case(substring(normalize-space(.), 1, 1))">
				<xsl:sort select="upper-case(substring(normalize-space(.), 1, 1))"/>
				<eb:ref ref-id="section-{generate-id()}">
					<xsl:value-of select="current-grouping-key()"/>
				</eb:ref>
			</xsl:for-each-group>
		</xsl:variable>
		
		<eb:part type="index">
			<eb:section id="section-{generate-id()}">
				<x:div class="index">
					<x:h1><xsl:value-of select="$title"/></x:h1>
					<x:div class="index-navigation">
						<xsl:copy-of select="$index-ids" />
						<x:hr/>
					</x:div>
					
					<xsl:for-each select="$index-ids">
						<x:h1><xsl:copy-of select="."/></x:h1>
						<xsl:if test="((position() mod floor(number($index-page-break) div 2)) = 0) and not(position() = last())">
							<eb:page-break id="page-{generate-id()}"/>
						</xsl:if>
					</xsl:for-each>
						
					<xsl:for-each-group select="//eb:index-item" group-by="upper-case(substring(normalize-space(.), 1, 1))">
						<xsl:sort select="upper-case(substring(normalize-space(.), 1, 1))"/>
						<xsl:variable name="id" select="$index-ids[. = current-grouping-key()]/@ref-id"/>
						
						<eb:section id="{$id}">
							<x:div class="index">
								<x:div class="index-navigation">
									<xsl:copy-of select="$index-ids" />
									<x:hr/>
								</x:div>
								<x:h1><x:span class="first-char first-char-{lower-case(current-grouping-key())}"><xsl:value-of select="current-grouping-key()"/></x:span></x:h1>
								<x:table class="index">
									<xsl:for-each-group select="current-group()" group-by="lower-case(normalize-space(.))">
										<xsl:sort/>
										<xsl:apply-templates select="."/>
										<xsl:if test="((position() mod number($index-page-break)) = 0) and not(position() = last())">
											<eb:page-break id="page-{generate-id()}"/>
										</xsl:if>
									</xsl:for-each-group>
								</x:table>
							</x:div>
						</eb:section>
					</xsl:for-each-group>
				</x:div>
			</eb:section>
		</eb:part>
	</xsl:template>
	
	<xsl:template match="eb:index-item">
		<xsl:variable name="item-id" select="string(@id)" />
		<xsl:variable name="item" select="lower-case(normalize-space(.))" />
		<x:tr class="index-item">
			<x:td class="index-item-text">
				<xsl:value-of select="$item"/>
			</x:td>
			<x:td class="index-item-pages">
				<eb:page-refs>
					<xsl:for-each select="key('index-items', $item)">
						<eb:page-ref ref-id="{string(@id)}" />
					</xsl:for-each>
				</eb:page-refs>
			</x:td>
		</x:tr>
	</xsl:template>
	
</xsl:stylesheet>