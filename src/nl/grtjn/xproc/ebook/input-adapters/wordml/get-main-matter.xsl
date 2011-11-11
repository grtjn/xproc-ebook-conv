<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:aml="http://schemas.microsoft.com/aml/2001/core"
	xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"
	xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006"
	xmlns:o="urn:schemas-microsoft-com:office:office"
	xmlns:v="urn:schemas-microsoft-com:vml"
	xmlns:w10="urn:schemas-microsoft-com:office:word"
	xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml"
	xmlns:wx="http://schemas.microsoft.com/office/word/2003/auxHint"
	xmlns:wsp="http://schemas.microsoft.com/office/word/2003/wordml/sp2"
	xmlns:sl="http://schemas.microsoft.com/schemaLibrary/2003/core"

	xmlns:x="http://www.w3.org/1999/xhtml"
	
	exclude-result-prefixes="#all">
	
	<xsl:key use="w:name/@w:val, wx:uiName/@wx:val, @w:styleId" match="w:style" name="styles"/>

	<xsl:template match="@*|comment()|processing-instruction()"/>

	<xsl:template match="*">
		<xsl:message terminate="no">Unknown element <xsl:value-of select="name()" /> in mapping</xsl:message>
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="/">
		<x:html>
			<xsl:apply-templates select="w:wordDocument/w:body" />
		</x:html>
	</xsl:template>

	<xsl:template match="w:body">
		<x:body>
			<xsl:apply-templates />
		</x:body>
	</xsl:template>
	
	<xsl:template match="wx:sect|wx:sub-section">
		<x:div>
			<xsl:apply-templates />
		</x:div>
	</xsl:template>

	<xsl:template match="w:t">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="wx:pBdrGroup">
		<x:div class="space-before" style="border: solid black 1px;">
			<xsl:apply-templates />
		</x:div>
	</xsl:template>

	<xsl:template match="w:tab">
		<x:span class="tab" style="padding-left: 1em;">&#160;&#160;</x:span>
	</xsl:template>

	<xsl:template match="w:p">
		<xsl:variable name="style" select="key('styles', w:pPr/w:pStyle/@w:val)[1]"/>
		<xsl:choose>
		<xsl:when test="exists($style) and exists($style/w:pPr/w:outlineLvl)">
			<xsl:element name="x:h{number($style/w:pPr/w:outlineLvl/@w:val) + 1}">
				<xsl:if test="exists(($style, self::*)/w:pPr[w:jc[@w:val = 'center'] | w:rPr[w:color | w:b | w:i]])">
					<xsl:attribute name="style">
						<xsl:if test="exists(($style, self::*)/w:pPr/w:rPr/w:color)">color: #<xsl:value-of select="($style, self::*)/w:pPr/w:rPr/w:color/@w:val"/>;</xsl:if>
						<!--xsl:if test="exists(w:pPr/w:rPr/w:b)">font-weight: bold;</xsl:if>
						<xsl:if test="exists(w:pPr/w:rPr/w:i)">font-style: italic;</xsl:if-->
						<xsl:if test="exists(($style, self::*)/w:pPr/w:jc)">width: 100%; text-align: <xsl:value-of select="($style, self::*)/w:pPr/w:jc/@w:val"/>;</xsl:if>
					</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates />
			</xsl:element>
		</xsl:when>
		<xsl:when test="exists(w:pPr/w:listPr) and empty(preceding-sibling::*[1]/self::w:p/w:pPr/w:listPr)">
			<xsl:variable name="type" select="if (matches(w:pPr/w:listPr/wx:t/@wx:val, '\d')) then 'ol' else 'ul'"/>
			<xsl:element name="x:{$type}">
				<x:li>
					<xsl:apply-templates />
				</x:li>
				<xsl:apply-templates select="following-sibling::*[1]/self::w:p" mode="list-continue"/>
			</xsl:element>
		</xsl:when>
		<xsl:when test="empty(w:pPr/w:listPr)">
			<x:p class="space-before">
				<xsl:if test="exists(($style, self::*)/w:pPr[w:jc[@w:val = 'center'] | w:rPr[w:color | w:b | w:i]])">
					<xsl:attribute name="style">
						<xsl:if test="exists(($style, self::*)/w:pPr/w:rPr/w:color)">color: #<xsl:value-of select="($style, self::*)/w:pPr/w:rPr/w:color/@w:val"/>;</xsl:if>
						<xsl:if test="exists(($style, self::*)/w:pPr/w:jc)">width: 100%; text-align: <xsl:value-of select="($style, self::*)/w:pPr/w:jc/@w:val"/>;</xsl:if>
					</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates />
			</x:p>
		</xsl:when>
		<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="w:p" mode="list-continue">
		<xsl:if test="exists(w:pPr/w:listPr)">
			<x:li>
				<xsl:apply-templates />
			</x:li>
			<xsl:apply-templates select="following-sibling::*[1]/self::w:p" mode="list-continue"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="o:DocumentProperties
		|w:fonts|w:styles
		|w:docPr|w:sectPr|w:pPr|w:rPr
		|w:proofErr|@wsp:*|wx:*" />
		
	<xsl:template match="w:r">
		<xsl:choose>
		<xsl:when test="exists(w:rPr/w:color | w:rPr/w:b | w:rPr/w:i)">
			<x:span>
				<xsl:attribute name="style">
					<xsl:if test="exists(w:rPr/w:color)">color: #<xsl:value-of select="w:rPr/w:color/@w:val"/>;</xsl:if>
					<xsl:if test="exists(w:rPr/w:b)">font-weight: bold;</xsl:if>
					<xsl:if test="exists(w:rPr/w:i)">font-style: italic;</xsl:if>
				</xsl:attribute>
				<xsl:apply-templates />
			</x:span>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates />
		</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="w:hlink">
		<x:a href="{@w:dest}">
			<xsl:apply-templates />
		</x:a>
	</xsl:template>
	
	<xsl:template match="w:pict">
		<x:figure>
			<x:img src="{substring-after(v:shape/v:imagedata/@src, 'wordml://')}" alt="{v:shape/@alt}">
			<!--width="{replace(v:shape/@style, '^.*width:([^;]+).*$', '$1')}" height="{replace(v:shape/@style, '^.*height:([^;]+).*$', '$1')}"/-->
			<xsl:if test="contains(v:shape/@style, 'position:absolute;left:0;text-align:left;')">
				<xsl:attribute name="style">float:left;</xsl:attribute>
			</xsl:if>
			</x:img>
		</x:figure>
	</xsl:template>

	
</xsl:stylesheet>
