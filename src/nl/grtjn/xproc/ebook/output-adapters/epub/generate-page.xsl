<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:eb="http://grtjn.nl/ns/xproc/ebook"
	xmlns:x="http://www.w3.org/1999/xhtml"
	
	exclude-result-prefixes="#all">
	
	<xsl:output method="xml" encoding="UTF-8" indent="no" doctype-public="-//W3C//DTD XHTML 1.1//EN" doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" />
	<xsl:strip-space elements="*" />
	
	<xsl:param name="output-style" select="'#default'" />
	<xsl:param name="section-id" />
	<xsl:param name="styles-uri"/>
	
	<xsl:variable name="styles" select="doc($styles-uri)/*"/>
	<xsl:variable name="head" select="$styles/generic-style/output[@method='epub']/x:head/node(), ($styles/style[@name = ($output-style, '#default')]/output[@method='epub']/x:head)[1]/node()"/>
	<xsl:variable name="pagenr-format" select="string(($styles/style[@name = ($output-style, '#default')]/output[@method='epub']/pagenr/@format, '$1')[1])"/>
	
	<xsl:template match="/">
		<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
			<head>
				<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />
				<title><xsl:value-of select="(x:div/x:h1 | x:div/x:h2 | x:div/x:h3 | x:div/x:h4)"/></title>
				<xsl:copy-of select="$head"/>
			</head>
			<body>
				<div class="body">
					<div class="contentholder">
						<xsl:if test="string-length($section-id) > 0">
							<!--a xmlns="http://www.w3.org/1999/xhtml" name="{$section-id}"/-->
							<a xmlns="http://www.w3.org/1999/xhtml" id="{$section-id}"/>
						</xsl:if>
						<xsl:apply-templates select="*" />
						<div class="bodystretcher"/>
					</div>
				</div>
				<div class="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="@*|comment()|processing-instruction()" mode="#all">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="x:*" mode="#all">
		<xsl:element name="{local-name()}" namespace="{namespace-uri()}">
			<xsl:apply-templates select="@*|node()" mode="#current"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="x:body" mode="#all">
		<x:div>
			<xsl:apply-templates select="@*|node()" mode="#current"/>
		</x:div>
	</xsl:template>

	<xsl:template match="x:p" priority="2">
		<xsl:variable name="p" select="."/>
		
		<!-- move non-inlines outside p element -->
		
		<xsl:for-each-group select="node()" group-starting-with="x:table | eb:table | x:figure | eb:image | x:blockquote">
			<xsl:variable name="non-inlines" select="current-group()[self::x:table or self::eb:table or self::x:figure or self::eb:image or self::x:blockquote]"/>
			<xsl:variable name="remainder" select="current-group()[not(self::x:table or self::eb:table or self::x:figure or self::eb:image or self::x:blockquote)]"/>
			
			<xsl:apply-templates select="$non-inlines" />
			
			<xsl:if test="exists($remainder)">
				<xsl:element name="{local-name($p)}" namespace="{namespace-uri($p)}">
					<xsl:choose>
						<xsl:when test="(position() = 1) and empty($non-inlines) and $p/preceding-sibling::*[1][self::x:h1 or self::x:h2 or self::x:h3 or self::x:h4]">
							<xsl:apply-templates select="$p/@*" />
							<xsl:apply-templates select="$remainder[1]" mode="first-char"/>
							<xsl:apply-templates select="$remainder[position() > 1]" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="$p/@*|$remainder" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:if>
		</xsl:for-each-group>
	</xsl:template>

	<xsl:template match="x:figure">
		<div xmlns="http://www.w3.org/1999/xhtml" class="figure">
			<xsl:apply-templates select="node()" />
		</div>
	</xsl:template>

	<xsl:template match="x:a/@name" mode="#all" priority="2">
		<xsl:attribute name="id">
			<xsl:value-of select="." />
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="eb:*" mode="#all">
		<!--a xmlns="http://www.w3.org/1999/xhtml" name="{@id}"/-->
		<a xmlns="http://www.w3.org/1999/xhtml" id="{@id}"/>
		<xsl:apply-templates select="node()" mode="#current" />
	</xsl:template>
	
	<xsl:template match="eb:page" mode="#all">
		<!--a xmlns="http://www.w3.org/1999/xhtml" name="{@id}"/-->
		<a xmlns="http://www.w3.org/1999/xhtml" id="{@id}"/>
		<xsl:if test="(string-length(@n) > 0) and (string-length(normalize-space((*/(x:h1 | x:h2 | x:h3 | x:h4 | x:h5 | x:h6))[1])) > 0)">
			<div xmlns="http://www.w3.org/1999/xhtml" class="pb"><xsl:value-of select="replace(@n, '^(.+)$', $pagenr-format)" /></div>
		</xsl:if>
		<xsl:apply-templates select="node()" mode="#current"/>
	</xsl:template>
	
	<xsl:template match="eb:note" mode="#all">
		<xsl:apply-templates select="*" mode="#current"/>
	</xsl:template>

	<xsl:template match="eb:note-ref" mode="#all">
		<!--a xmlns="http://www.w3.org/1999/xhtml" name="{@id}"/-->
		<a xmlns="http://www.w3.org/1999/xhtml" id="{@id}"/>
		<span xmlns="http://www.w3.org/1999/xhtml" class="note-ref notenr">
			<xsl:apply-templates select="node()" mode="#current"/>
		</span>
	</xsl:template>

	<xsl:template match="x:*" mode="first-char" priority="2">
		<xsl:element name="{local-name()}" namespace="{namespace-uri()}">
			<xsl:apply-templates select="@*" />
			<xsl:apply-templates select="node()[1]" mode="#current"/>
			<xsl:apply-templates select="node()[position() > 1]" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="text()" mode="first-char" priority="2">
		<xsl:variable name="first-char" select="substring(., 1, 1)"/>
		<xsl:variable name="is-begin-caps" select="matches($first-char, '^[A-Z]$')"/>
		<xsl:variable name="remainder" select="substring-after(., $first-char)"/>
		<xsl:choose>
			<xsl:when test="$is-begin-caps">
				<span xmlns="http://www.w3.org/1999/xhtml" class="first-char first-char-{lower-case($first-char)}">
					<xsl:value-of select="$first-char"/>
				</span>
				<xsl:value-of select="$remainder"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
