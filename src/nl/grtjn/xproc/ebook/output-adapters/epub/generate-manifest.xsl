<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:eb="http://grtjn.nl/ns/xproc/ebook"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:opf="http://www.idpf.org/2007/opf"
	xmlns="http://www.idpf.org/2007/opf"
	
	xmlns:local="local"
	
	exclude-result-prefixes="#all">
	
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />
	
	<xsl:param name="output-basename" />
	
	<xsl:param name="output-style" select="'#default'" />
	<xsl:param name="styles-uri"/>
	
	<xsl:variable name="styles" select="doc($styles-uri)/*"/>
	<xsl:variable name="files" select="$styles/generic-style/output[@method='epub']/files, ($styles/style[@name = ($output-style, '#default')]/output[@method='epub']/files)[1]"/>

	<xsl:param name="dc-bookid" select="(/eb:ebook/eb:metadata//dc:identifier[@id = 'BookId'][string-length(.) > 0])[1]" />
	
	<!--+ Specs:
		|	http://idpf.org/epub/20/spec/OPF_2.0.1_draft.htm
		|	http://dublincore.org/documents/dc-xml-guidelines/
		+-->
	
	<xsl:template match="/">
		<xsl:variable name="metadata" select="eb:ebook/eb:metadata"/>
		<xsl:variable name="dc-title" select="$metadata//dc:title[string-length(.) > 0]" />
		<xsl:variable name="dc-language" select="$metadata//dc:language[string-length(.) > 0]" />
		
		<xsl:if test="not($dc-title and $dc-language and $dc-bookid)">
			<xsl:message terminate="yes">dc:title, dc:language and dc:identifier[@id='BookId'] are required metadata fields.</xsl:message>
		</xsl:if>

		<package version="2.0" unique-identifier="BookId">
		 
			<metadata>
				<xsl:copy-of select="$metadata//*[not(*)]"/>
			</metadata>
		 
			<manifest>
				<item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
				<xsl:for-each select="//eb:page">
					<item id="{@id}" href="{@id}.xhtml" media-type="application/xhtml+xml"/>
				</xsl:for-each>
				
				<!-- write each image only once -->
				<xsl:for-each-group select="//eb:image" group-by="@src">
					<xsl:variable name="extension" select="replace(@src, '^(.*[\.])?([^\.]+)', '$2')"/>
					<item id="{@id}" href="{@src}" media-type="{local:get-mimetype(@src)}"/>
				</xsl:for-each-group>
				
				<!--item id="stylesheet" href="css/epub.css" media-type="text/css"/>
				<item id="myfont" href="css/myfont.otf" media-type="application/x-font-opentype"/-->
				
				<xsl:for-each select="$files/file">
					<item id="{generate-id()}" href="{@href}" media-type="{local:get-mimetype(@href)}"/>
				</xsl:for-each>
			</manifest>
		 
			<spine toc="ncx">
				<xsl:for-each select="//eb:page">
					<itemref idref="{@id}" />
				</xsl:for-each>
			</spine>
		 
			<guide>
				<!--
					cover 		the book cover(s), jacket information, etc. 
					title-page 	page with possibly title, author, publisher, and other metadata 
					toc 		table of contents 
					index 		back-of-book style index 
					glossary 
					acknowledgements 
					bibliography 
					colophon 
					copyright-page 
					dedication 
					epigraph 
					foreword 
					loi 	list of illustrations 
					lot 	list of tables 
					notes 
					preface 
					text	First "real" page of content (e.g. "Chapter 1") 
				-->
				<xsl:for-each select="//eb:section">
					<reference type="{local:type-lookup(ancestor::eb:part/@type)}" title="{ancestor::eb:part/@type}" href="{(eb:page/@id)[1]}.xhtml" />
				</xsl:for-each>
				
			</guide>
		 
		</package>
	</xsl:template>
	
	<xsl:function name="local:type-lookup">
		<xsl:param name="part-type" as="xs:string?"/>
		
		<xsl:choose>
			<xsl:when test="$part-type eq 'table-of-contents'">toc</xsl:when>
			<xsl:when test="$part-type eq 'list of illustrations'">loi</xsl:when>
			<xsl:when test="$part-type eq 'list of tables'">lot</xsl:when>
			<xsl:when test="$part-type eq 'index'">index</xsl:when>
			<xsl:when test="$part-type eq 'notes'">notes</xsl:when>
			<xsl:otherwise>text</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="local:get-mimetype">
		<xsl:param name="filename" as="xs:string"/>
		
		<xsl:variable name="extension" select="replace($filename, '^(.*[\.])?([^\.]+)', '$2')"/>
		
		<xsl:choose>
			<xsl:when test="$extension = ('gif', 'png')">image/<xsl:value-of select="$extension"/></xsl:when>
			<xsl:when test="$extension = ('jpg')">image/jpeg</xsl:when>
			<xsl:when test="$extension = ('css', 'html')">text/<xsl:value-of select="$extension"/></xsl:when>
			<xsl:when test="$extension eq 'xhtml'">application/xhtml+xml</xsl:when>
			<xsl:when test="$extension eq 'otf'">application/x-font-opentype</xsl:when>
			<!--xsl:when test="$extension eq 'otf'">font/opentype</xsl:when-->
			<xsl:when test="$extension eq 'eot'">application/vnd.ms-fontobject</xsl:when>
			<xsl:when test="$extension eq 'woff'">application/x-font-woff</xsl:when>
			<xsl:otherwise>application/octet-stream</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>
