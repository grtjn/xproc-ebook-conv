<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:eb="http://grtjn.nl/ns/xproc/ebook"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:x="http://www.w3.org/1999/xhtml"
	xmlns="http://www.daisy.org/z3986/2005/ncx/"
	
	exclude-result-prefixes="#all">
	
	<xsl:output method="xml" encoding="UTF-8" indent="yes" doctype-public="-//NISO//DTD ncx 2005-1//EN" doctype-system="http://www.daisy.org/z3986/2005/ncx-2005-1.dtd" />
	<xsl:strip-space elements="*" />
	
	<xsl:param name="output-basename" />
	
	<xsl:template match="/">
		<ncx version="2005-1" xml:lang="en">
		
			<head>
				<!-- The following four metadata items are required for all NCX documents,
				including those conforming to the relaxed constraints of OPS 2.0 -->
				
				<meta name="dtb:uid" content="{$output-basename}"/> <!-- same as in .opf -->
				<meta name="dtb:depth" content="{max(//eb:section/@level/number(.))}"/> <!-- 1 or higher -->
				<meta name="dtb:totalPageCount" content="{count(//eb:page)}"/> <!-- must be 0 -->
				<meta name="dtb:maxPageNumber" content="{(//eb:page)[last()]/@n}"/> <!-- must be 0 -->
			</head>
			 
			<docTitle>
				<text><xsl:value-of select="/eb:ebook/eb:metadata//dc:title"/></text>
			</docTitle>
			
			<xsl:for-each select="/eb:ebook/eb:metadata//dc:creator">
				<docAuthor>
					<text><xsl:value-of select="."/></text>
				</docAuthor>
			</xsl:for-each>
			 
			<navMap>
				<!-- navInfo/(text,img)? -->
				<navLabel>
					<text><xsl:value-of select="(/eb:ebook/*/*/eb:table-of-contents)[1]/@label"/></text>
				</navLabel>
				<xsl:apply-templates select="*" mode="navMap"/>
			</navMap>
		 
			<pageList>
				<!-- navInfo/(text,img)? -->
				<navLabel>
					<text>Pagina's</text>
				</navLabel>
				<xsl:apply-templates select="*" mode="pageList"/>
			</pageList>
			
			<xsl:if test="//eb:image">
				<xsl:for-each select="/eb:ebook/*/*/eb:list-of-illustrations">
					<navList>
						<!-- navInfo/(text,img)? -->
						<navLabel>
							<text><xsl:value-of select="@label"/></text>
						</navLabel>
						<xsl:apply-templates select="/*" mode="navListIllustrations"/>
					</navList>
				</xsl:for-each>
			</xsl:if>
			
			<xsl:if test="//eb:table">
				<xsl:for-each select="/eb:ebook/*/*/eb:list-of-tables">
					<navList>
						<!-- navInfo/(text,img)? -->
						<navLabel>
							<text><xsl:value-of select="@label"/></text>
						</navLabel>
						<xsl:apply-templates select="/*" mode="navListTables"/>
					</navList>
				</xsl:for-each>
			</xsl:if>
		</ncx>
	</xsl:template>

	<xsl:template match="*" mode="#all">
		<xsl:apply-templates select="*" mode="#current"/>
	</xsl:template>

	<xsl:template match="eb:section" mode="navMap">
		<xsl:if test="number(@level) eq 1">
			<xsl:apply-templates select="." mode="navMap-continue"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="eb:section" mode="navMap-continue">
		<xsl:param name="level" select="1" />
		<xsl:if test="number(@level) eq $level">
			<navPoint class="chapter" id="{@id}" playOrder="{count(ancestor::eb:section) + count(preceding::eb:section) + 1}">
				<navLabel><text><xsl:value-of select="normalize-space((eb:page/*/(x:h1 | x:h2 | x:h3 | x:h4 | x:h5 | x:h6))[1])"/></text></navLabel>
				<content src="{eb:page[1]/@id}.xhtml"/>
				<xsl:apply-templates select="* | following-sibling::*[1]" mode="#current">
					<xsl:with-param name="level" select="$level + 1"/>
				</xsl:apply-templates>
			</navPoint>
			<xsl:if test="number(@level) gt 1">
				<xsl:apply-templates select="following-sibling::*[1]" mode="#current">
					<xsl:with-param name="level" select="$level"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<xsl:variable name="section-count" select="count(//eb:section)" />
	
	<xsl:template match="eb:page" mode="pageList">
		<pageTarget id="{@id}" type="{if (exists(ancestor::eb:front)) then 'front' else if (exists(ancestor::eb:back)) then 'special' else 'normal'}" value="{@n}" playOrder="{$section-count + count(ancestor::eb:page) + count(preceding::eb:page) + 1}">
			<navLabel><text><xsl:value-of select="@n"/></text></navLabel>
			<content src="{@id}.xhtml#{@id}"/>
		</pageTarget>
		<xsl:apply-templates select="*" mode="#current"/>
	</xsl:template>
	
	<xsl:template match="eb:image" mode="navListIllustrations">
		<navTarget id="{@id}">
			<navLabel><text><xsl:value-of select="@label"/></text></navLabel>
			<content src="{ancestor::eb:page[1]/@id}#{@id}"/>
		</navTarget>
		<xsl:apply-templates select="*" mode="#current"/>
	</xsl:template>
	
	<xsl:template match="eb:table" mode="navListTables">
		<navTarget id="{@id}">
			<navLabel><text><xsl:value-of select="@label"/></text></navLabel>
			<content src="{ancestor::eb:page[1]/@id}#{@id}"/>
		</navTarget>
		<xsl:apply-templates select="*" mode="#current"/>
	</xsl:template>
	
</xsl:stylesheet>
