<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:eb="http://grtjn.nl/ns/xproc/ebook"
	xmlns:x="http://www.w3.org/1999/xhtml"

	exclude-result-prefixes="#all">
	
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:param name="debug" select="false()"/>
	<xsl:param name="verbose" select="false()"/>

	<xsl:param name="debug_" select="lower-case(string($debug)) = ('1', 'j', 'y', 'yes', 'true')"/>
	<xsl:param name="verbose_" select="lower-case(string($verbose)) = ('1', 'j', 'y', 'yes', 'true')"/>

	<xsl:template match="@*|node()" mode="#all">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="#current" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="/">
		<!-- nested sections disturb pagination, flatten them first -->
		<xsl:variable name="flatten-sections">
			<xsl:apply-templates select="/" mode="flatten-sections"/>
		</xsl:variable>
		
		<!-- we need page-breaks as child of eb:section, split parent elements and move them up until the page-breaks do -->
		<xsl:variable name="fix-page-breaks">
			<xsl:apply-templates select="$flatten-sections" mode="fix-page-breaks"/>
		</xsl:variable>
		
		<!-- check how many top elements there are (this xsl may only return one!) -->
		<!-- and convert page-breaks into wrapping eb:page elements -->
		<xsl:choose>
			<xsl:when test="count($fix-page-breaks/*) > 1">
				<body>
					<xsl:apply-templates select="$fix-page-breaks/*"/>
				</body>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$fix-page-breaks/*"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="/" mode="flatten-sections">
		<xsl:variable name="flatten-sections">
			<xsl:apply-templates select="*" mode="flatten-sections"/>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$flatten-sections//eb:section[ancestor::eb:section]">
				<xsl:apply-templates select="$flatten-sections" mode="flatten-sections"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$flatten-sections/*"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="/" mode="fix-page-breaks">
		<xsl:variable name="fix-page-breaks">
			<xsl:apply-templates select="*" mode="fix-page-breaks"/>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$fix-page-breaks//eb:page-break[not(parent::eb:section)]">
				<xsl:apply-templates select="$fix-page-breaks" mode="fix-page-breaks"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$fix-page-breaks/*"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*[child::eb:section and ancestor-or-self::eb:section]" mode="flatten-sections">
		<xsl:variable name="parent" select="."/>
		
		<xsl:for-each-group select="node()" group-starting-with="eb:section">
	
			<xsl:choose>
				<xsl:when test="not(self::eb:section)">
					<xsl:element name="{name($parent)}" namespace="{namespace-uri($parent)}">
						<xsl:copy-of select="$parent/@*" />
						<xsl:apply-templates select="current-group()" mode="copy"/>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="current-group()" mode="flatten-sections"/>
				</xsl:otherwise>
			</xsl:choose>
			
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template match="eb:section" mode="flatten-sections">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="#current" />
			<xsl:attribute name="level" select="count(ancestor-or-self::eb:section)"/>
			<xsl:apply-templates select="node()" mode="#current" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*[not(self::eb:section)][eb:page-break]" mode="fix-page-breaks">
		<xsl:variable name="parent" select="."/>
		
		<xsl:for-each-group select="node()" group-starting-with="eb:page-break">
	
			<xsl:copy-of select="self::eb:page-break" />
			<xsl:element name="{name($parent)}" namespace="{namespace-uri($parent)}">
				<xsl:choose>
					<xsl:when test="$parent[self::x:p] and position() gt 1">
						<xsl:copy-of select="$parent/@* except $parent/@class[. = 'indent']" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="$parent/@*" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:apply-templates select="current-group()[not(self::eb:page-break)]" mode="copy"/>
			</xsl:element>
			
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template match="*[eb:page-break]">
		<xsl:copy>
			<xsl:apply-templates select="@*" />
			
			<xsl:for-each-group select="node()" group-starting-with="eb:page-break">
				<xsl:variable name="id" select="concat('page-', generate-id())" />
				<xsl:if test="$debug_">
					<xsl:message><xsl:value-of select="$id"/>: <xsl:value-of select="self::eb:page-break/@*"/></xsl:message>
				</xsl:if>
				<eb:page id="{$id}">
					<xsl:copy-of select="self::eb:page-break/@*" />
					<xsl:copy-of select="self::eb:page-break/node()" />
					<xsl:apply-templates select="current-group()[not(self::eb:page-break)]" />
				</eb:page>
			</xsl:for-each-group>
			
		</xsl:copy>
	</xsl:template>

	<xsl:template match="eb:section[not(eb:page or eb:page-break)]">
		<xsl:copy>
			<xsl:apply-templates select="@*" />
			
			<xsl:variable name="id" select="concat('page-', generate-id())" />
			<xsl:if test="$debug_">
				<xsl:message>Creating page <xsl:value-of select="$id"/></xsl:message>
			</xsl:if>
			<eb:page id="{$id}">
				<xsl:apply-templates select="node()" />
			</eb:page>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
