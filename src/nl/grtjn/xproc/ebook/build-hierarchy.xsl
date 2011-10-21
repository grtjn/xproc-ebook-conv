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
			<xsl:apply-templates select="@*|node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="x:body/x:div[not(.//*[self::x:h1 or self::x:h2 or self::x:h3 or self::x:h4 or self::x:h5 or self::x:h6])]">
		<xsl:variable name="id" select="concat('section-', generate-id())" />
		<xsl:if test="$debug_">
			<xsl:message><xsl:value-of select="$id"/>: <xsl:value-of select="substring(., 1, 15)"/>..</xsl:message>
		</xsl:if>
		<eb:section id="{$id}" level="0">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()" />
			</xsl:copy>
		</eb:section>
	</xsl:template>
	
	<xsl:template match="*[x:h1 | x:h2 | x:h3 | x:h4 | x:h5 | x:h6]">
		<xsl:variable name="parent" select="." />
		
		<xsl:for-each-group select="node()" group-starting-with="x:h1">
			
			<xsl:choose>
			<xsl:when test="empty(current-group()[not(self::eb:page-break)])"/>
			<xsl:when test="self::x:h1">
				<xsl:variable name="id" select="concat('section-', generate-id())" />
				<xsl:if test="$debug_">
					<xsl:message><xsl:value-of select="$id"/>: h1 <xsl:value-of select="self::x:h1"/></xsl:message>
				</xsl:if>
				<eb:section id="{$id}">
					
					<xsl:element name="{name($parent)}" namespace="{namespace-uri($parent)}">
						<xsl:copy-of select="$parent/@*" />
						
						<xsl:copy-of select="preceding-sibling::*[1]/self::eb:page-break" />
						
						<xsl:apply-templates select="." mode="h2">
							<xsl:with-param name="parent" select="$parent"/>
							<xsl:with-param name="parent-group" select="current-group()"/>
						</xsl:apply-templates>
						
					</xsl:element>
					
				</eb:section>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="h2">
					<xsl:with-param name="parent" select="$parent"/>
					<xsl:with-param name="parent-group" select="current-group()"/>
				</xsl:apply-templates>
			</xsl:otherwise>
			</xsl:choose>
			
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template match="*" mode="h2">
		<xsl:param name="parent" />
		<xsl:param name="parent-group" />
		
		<xsl:for-each-group select="$parent-group" group-starting-with="x:h2">
			
			<xsl:choose>
			<xsl:when test="empty(current-group()[not(self::eb:page-break)])"/>
			<xsl:when test="self::x:h2">
				<xsl:variable name="id" select="concat('section-', generate-id())" />
				<xsl:if test="$debug_">
					<xsl:message><xsl:value-of select="$id"/>: h2 <xsl:value-of select="self::x:h2"/></xsl:message>
				</xsl:if>
				<eb:section id="{$id}">
					
					<xsl:element name="{name($parent)}" namespace="{namespace-uri($parent)}">
						<xsl:copy-of select="$parent/@*" />
						
						<xsl:copy-of select="preceding-sibling::*[1]/self::eb:page-break" />
						
						<xsl:apply-templates select="." mode="h3">
							<xsl:with-param name="parent" select="$parent"/>
							<xsl:with-param name="parent-group" select="current-group()"/>
						</xsl:apply-templates>
						
					</xsl:element>
					
				</eb:section>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="h3">
					<xsl:with-param name="parent" select="$parent"/>
					<xsl:with-param name="parent-group" select="current-group()"/>
				</xsl:apply-templates>
			</xsl:otherwise>
			</xsl:choose>
			
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template match="*" mode="h3">
		<xsl:param name="parent" />
		<xsl:param name="parent-group" />
		
		<xsl:for-each-group select="$parent-group" group-starting-with="x:h3">
			
			<xsl:choose>
			<xsl:when test="empty(current-group()[not(self::eb:page-break)])"/>
			<xsl:when test="self::x:h3">
				<xsl:variable name="id" select="concat('section-', generate-id())" />
				<xsl:if test="$debug_">
					<xsl:message><xsl:value-of select="$id"/>: h3 <xsl:value-of select="self::x:h3"/></xsl:message>
				</xsl:if>
				<eb:section id="{$id}">
					
					<xsl:element name="{name($parent)}" namespace="{namespace-uri($parent)}">
						<xsl:copy-of select="$parent/@*" />
						
						<xsl:copy-of select="preceding-sibling::*[1]/self::eb:page-break" />
						
						<xsl:apply-templates select="." mode="h4">
							<xsl:with-param name="parent" select="$parent"/>
							<xsl:with-param name="parent-group" select="current-group()"/>
						</xsl:apply-templates>
						
					</xsl:element>
					
				</eb:section>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="h4">
					<xsl:with-param name="parent" select="$parent"/>
					<xsl:with-param name="parent-group" select="current-group()"/>
				</xsl:apply-templates>
			</xsl:otherwise>
			</xsl:choose>
			
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template match="*" mode="h4">
		<xsl:param name="parent" />
		<xsl:param name="parent-group" />
		
		<xsl:for-each-group select="$parent-group" group-starting-with="x:h4">
			
			<xsl:choose>
			<xsl:when test="empty(current-group()[not(self::eb:page-break)])"/>
			<xsl:when test="self::x:h4">
				<xsl:variable name="id" select="concat('section-', generate-id())" />
				<xsl:if test="$debug_">
					<xsl:message><xsl:value-of select="$id"/>: h4 <xsl:value-of select="self::x:h4"/></xsl:message>
				</xsl:if>
				<eb:section id="{$id}">
					
					<xsl:element name="{name($parent)}" namespace="{namespace-uri($parent)}">
						<xsl:copy-of select="$parent/@*" />
						
						<xsl:copy-of select="preceding-sibling::*[1]/self::eb:page-break" />
						
						<xsl:apply-templates select="." mode="h5">
							<xsl:with-param name="parent" select="$parent"/>
							<xsl:with-param name="parent-group" select="current-group()"/>
						</xsl:apply-templates>
						
					</xsl:element>
					
				</eb:section>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="h5">
					<xsl:with-param name="parent" select="$parent"/>
					<xsl:with-param name="parent-group" select="current-group()"/>
				</xsl:apply-templates>
			</xsl:otherwise>
			</xsl:choose>
			
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template match="*" mode="h5">
		<xsl:param name="parent" />
		<xsl:param name="parent-group" />
		
		<xsl:for-each-group select="$parent-group" group-starting-with="x:h5">
			
			<xsl:choose>
			<xsl:when test="empty(current-group()[not(self::eb:page-break)])"/>
			<xsl:when test="self::x:h5">
				<xsl:variable name="id" select="concat('section-', generate-id())" />
				<xsl:if test="$debug_">
					<xsl:message><xsl:value-of select="$id"/>: h5 <xsl:value-of select="self::x:h5"/></xsl:message>
				</xsl:if>
				<eb:section id="{$id}">
					
					<xsl:element name="{name($parent)}" namespace="{namespace-uri($parent)}">
						<xsl:copy-of select="$parent/@*" />
						
						<xsl:copy-of select="preceding-sibling::*[1]/self::eb:page-break" />
						
						<xsl:apply-templates select="." mode="h6">
							<xsl:with-param name="parent" select="$parent"/>
							<xsl:with-param name="parent-group" select="current-group()"/>
						</xsl:apply-templates>
						
					</xsl:element>
					
				</eb:section>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="h6">
					<xsl:with-param name="parent" select="$parent"/>
					<xsl:with-param name="parent-group" select="current-group()"/>
				</xsl:apply-templates>
			</xsl:otherwise>
			</xsl:choose>
			
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template match="*" mode="h6">
		<xsl:param name="parent" />
		<xsl:param name="parent-group" />
		
		<xsl:for-each-group select="$parent-group" group-starting-with="x:h6">
			
			<xsl:choose>
			<xsl:when test="empty(current-group()[not(self::eb:page-break)])"/>
			<xsl:when test="self::x:h6">
				<xsl:variable name="id" select="concat('section-', generate-id())" />
				<xsl:if test="$debug_">
					<xsl:message><xsl:value-of select="$id"/>: h6 <xsl:value-of select="self::x:h6"/></xsl:message>
				</xsl:if>
				<eb:section id="{$id}">
					
					<xsl:element name="{name($parent)}" namespace="{namespace-uri($parent)}">
						<xsl:copy-of select="$parent/@*" />
						
						<xsl:copy-of select="preceding-sibling::*[1]/self::eb:page-break" />
						
						<xsl:apply-templates select="current-group()"/>
						
					</xsl:element>
					
				</eb:section>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="current-group()"/>
			</xsl:otherwise>
			</xsl:choose>
			
		</xsl:for-each-group>
	</xsl:template>
	
</xsl:stylesheet>
