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

	<xsl:template match="w:wordDocument">
		<x:html>
			<xsl:apply-templates select="w:body" />
		</x:html>
	</xsl:template>

	<xsl:template match="w:body">
		<x:body>
			<xsl:apply-templates select=".//w:p" />
		</x:body>
	</xsl:template>
	
	<xsl:template match="w:p">
		<x:p>
			<xsl:value-of select="normalize-space(.)" />
		</x:p>
	</xsl:template>
</xsl:stylesheet>