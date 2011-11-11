<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:eb="http://grtjn.nl/ns/xproc/ebook"
	xmlns:x="http://www.w3.org/1999/xhtml"

	exclude-result-prefixes="#all">
	
	<xsl:output method="xml" encoding="UTF-8" indent="no" />
	<xsl:strip-space elements="*" />

	<xsl:param name="debug" select="false()"/>
	<xsl:param name="verbose" select="false()"/>

	<xsl:param name="debug_" select="lower-case(string($debug)) = ('1', 'j', 'y', 'yes', 'true')"/>
	<xsl:param name="verbose_" select="lower-case(string($verbose)) = ('1', 'j', 'y', 'yes', 'true')"/>
	
	<xsl:key name="id" match="*[@id]" use="@id"/>
	<xsl:variable name="root" select="/"/>

	<xsl:template match="@*|node()" mode="#all">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="#current" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="eb:page-refs">
		<xsl:variable name="page-refs">
			<xsl:for-each select="eb:page-ref">
				<xsl:copy>
					<xsl:copy-of select="key('id', @ref-id, $root)/(child::eb:page, ancestor::eb:page)[1]/@*"/>
					<xsl:copy-of select="@*|node()"/>
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:for-each-group select="$page-refs/*" group-starting-with="*[number(@n) gt (number(preceding-sibling::*[1]/@n) + 1)]">
			<xsl:variable name="current-ref-node" select="key('id', @ref-id, $root)"/>

			<x:span class="{local-name($current-ref-node)}-page {local-name($current-ref-node)}-level-{count($current-ref-node/ancestor-or-self::eb:section)}">
				<x:a href="{@id}.xhtml#{@ref-id}">
					<xsl:text>p.</xsl:text>
					<xsl:value-of select="@n"/>
				
					<xsl:if test="@n ne current-group()[last()]/@n">
						<xsl:text>-</xsl:text>
						<xsl:value-of select="current-group()[last()]/@n"/>
					</xsl:if>
				</x:a>
			</x:span>
			
			<xsl:if test="not(position() = last())">
				<xsl:text>, </xsl:text>
			</xsl:if>
		</xsl:for-each-group>
	</xsl:template>

	<xsl:template match="eb:page-ref">
		<xsl:variable name="ref-page" select="(key('id', @ref-id, $root)/(child::eb:page[1], ancestor::eb:page[1]))[1]"/>
		
		<xsl:variable name="page-id" select="string($ref-page/@id)" />
		<xsl:variable name="page-nr" select="string($ref-page/@n)" />
		
		<x:a href="{$page-id}.xhtml#{@ref-id}">
			<xsl:text>p.</xsl:text>
			<xsl:value-of select="$page-nr"/>
		</x:a>
	</xsl:template>

	<xsl:template match="eb:note-ref">
		<xsl:variable name="ref-page" select="(key('id', @ref-id, $root)/(child::eb:page[1], ancestor::eb:page[1]))[1]"/>
		
		<xsl:variable name="page-id" select="string($ref-page/@id)" />
		
		<x:a name="{@id}" />
		<x:span class="notenr">
			<x:a href="{$page-id}.xhtml#{@ref-id}">
				<xsl:apply-templates select="node()"/>
			</x:a>
		</x:span>
	</xsl:template>

	<xsl:template match="eb:ref">
		<xsl:variable name="ref-page" select="(key('id', @ref-id, $root)/(child::eb:page[1], ancestor::eb:page[1]))[1]"/>
		
		<xsl:variable name="page-id" select="string($ref-page/@id)" />
		
		<x:a href="{$page-id}.xhtml#{@ref-id}">
			<xsl:apply-templates select="node()"/>
		</x:a>
	</xsl:template>

</xsl:stylesheet>
