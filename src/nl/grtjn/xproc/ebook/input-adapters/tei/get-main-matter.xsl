<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:eb="http://grtjn.nl/ns/xproc/ebook"
	
	exclude-result-prefixes="#all">
	
	<xsl:param name="debug" select="false()"/>
	<xsl:param name="verbose" select="false()"/>
	
	<xsl:param name="debug_" select="lower-case(string($debug)) = ('1', 'j', 'y', 'yes', 'true')"/>
	<xsl:param name="verbose_" select="lower-case(string($verbose)) = ('1', 'j', 'y', 'yes', 'true')"/>

	<xsl:template match="/">
		<body xml:base="{base-uri(.)}">
			<xsl:apply-templates select="TEI.2/text/body/node()" />
		</body>
	</xsl:template>

	<xsl:template match="comment()|processing-instruction()">
		<xsl:copy-of select="."/>
	</xsl:template>

	<!-- all relevant attributes are dealt with specifically below, prevents defaulted ones from being inserted.. -->
	<xsl:template match="@*"/>

	<xsl:template match="*">
		<xsl:if test="$verbose_">
			<xsl:message>WARN: default rule for TEI element &lt;<xsl:value-of select="local-name()"/><xsl:for-each select="@*"><xsl:text> </xsl:text><xsl:value-of select="local-name()"/>="<xsl:value-of select="."/>"</xsl:for-each>&gt;!</xsl:message>
		</xsl:if>
		<xsl:apply-templates select="." mode="copy"/>
	</xsl:template>

	<xsl:template match="*" mode="copy">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="@*|node()" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="div | p | figure">
		<xsl:element name="{local-name()}">
			<!--xsl:apply-templates select="@*" /-->
			<xsl:apply-templates select="node()" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="p">
		<p>
			<xsl:apply-templates select="@*" />
			<xsl:if test="preceding-sibling::p and not(exists(preceding-sibling::*[1][string(self::p) = '&#160;']))">
				<xsl:attribute name="class">indent</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()" />
		</p>
	</xsl:template>

	<xsl:template match="pb">
		<eb:page-break>
			<xsl:apply-templates select="@*" />
		</eb:page-break>
	</xsl:template>

	<xsl:template match="pb/@*">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	<xsl:template match="TEI.2">
		<html>
			<xsl:apply-templates select="text/body" />
		</html>
	</xsl:template>

	<xsl:template match="hi[@rend = ('i', 'b', 'sup', 'sub')] | head">
		<xsl:element name="{@rend}">
 			<xsl:apply-templates select="@* except @rend" />
 			<xsl:apply-templates select="node()" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="hi[@rend = 'sc']">
		<!-- Adobe Digital Editions doesn't support font-variant: small-caps, so faking it.. -->
		<span class="smallcaps">
			<xsl:value-of select="upper-case(substring(., 1, 1))" />
			<span class="smallercaps">
				<xsl:value-of select="upper-case(substring(., 2))" />
			</span>
		</span>
	</xsl:template>

	<xsl:template match="hi[@rend = 'spat']">
		<span class="spatial">
			<xsl:apply-templates select="@* except @rend" />
			<xsl:apply-templates select="node()" />
		</span>
	</xsl:template>

	<xsl:template match="figure">
		<xsl:apply-templates select="." mode="copy"/>
	</xsl:template>
	
	<xsl:template match="xptr">
		<img src="{@to}" alt="{@to}"/>
	</xsl:template>
	
	<xsl:template match="table">
		<table>
			<xsl:apply-templates select="@*" />
			<xsl:if test="row[cell/@role = 'header']">
				<thead>
					<xsl:apply-templates select="row[cell/@role = 'header']"/>
				</thead>
			</xsl:if>
			<xsl:if test="row[not(cell/@role = 'header')]">
				<tbody>
					<xsl:apply-templates select="row[not(cell/@role = 'header')]"/>
				</tbody>
			</xsl:if>
		</table>
	</xsl:template>
	
	<xsl:template match="row">
		<tr>
 			<xsl:apply-templates select="@* | node()" />
		</tr>
	</xsl:template>
	
	<xsl:template match="cell[@role = 'header']">
		<th>
 			<xsl:apply-templates select="@* | node()" />
		</th>
	</xsl:template>
	
	<xsl:template match="cell[not(@role = 'header')]">
		<td>
 			<xsl:apply-templates select="@* | node()" />
		</td>
	</xsl:template>

	<xsl:template match="list">
		<ul>
 			<xsl:apply-templates select="@* except @type | node()" />
		</ul>
	</xsl:template>

	<xsl:template match="lg">
		<ul class="{@type}">
 			<xsl:apply-templates select="@* except @type | node()" />
		</ul>
	</xsl:template>

	<xsl:template match="item | l">
		<li>
 			<xsl:apply-templates select="@* | node()" />
		</li>
	</xsl:template>

	<xsl:template match="q[@rend = 'bq']">
		<blockquote>
			<p>
				<xsl:apply-templates select="@* except @rend | node()" />
			</p>
		</blockquote>
	</xsl:template>

	<xsl:template match="lb">
		<br/>
		<br/>
	</xsl:template>

	<xsl:template match="note">
		<eb:note>
			<xsl:apply-templates select="@*|node()" />
		</eb:note>
	</xsl:template>
	
	<xsl:template match="note/@*">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	<xsl:template match="interpGrp"/>
	
</xsl:stylesheet>