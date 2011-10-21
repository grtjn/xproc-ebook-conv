<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:opf="http://www.idpf.org/2007/opf"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	
	exclude-result-prefixes="#all">

	<xsl:param name="debug" select="false()"/>
	<xsl:param name="verbose" select="false()"/>

	<xsl:param name="debug_" select="lower-case(string($debug)) = ('1', 'j', 'y', 'yes', 'true')"/>
	<xsl:param name="verbose_" select="lower-case(string($verbose)) = ('1', 'j', 'y', 'yes', 'true')"/>

	<xsl:template match="/">
		<dc:metadata>
			<xsl:apply-templates select="TEI.2/teiHeader/node()" />
		</dc:metadata>
	</xsl:template>
	
	<xsl:template match="@*|comment()|processing-instruction()">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="*">
		<xsl:if test="$verbose_">
			<xsl:message>WARN: default rule for TEI element &lt;<xsl:value-of select="local-name()"/><xsl:for-each select="@*"><xsl:text> </xsl:text><xsl:value-of select="local-name()"/>="<xsl:value-of select="."/>"</xsl:for-each>&gt;!</xsl:message>
		</xsl:if>
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="@*|node()" />
		</xsl:element>
	</xsl:template>

<!--
http://dublincore.org/documents/dc-xml-guidelines/

5.3 Example - a qualified DC record

<metadata
  xmlns="http://example.org/myapp/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://example.org/myapp/ http://example.org/myapp/schema.xsd"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/">

  <dc:title>
    UKOLN
  </dc:title>
  <dcterms:alternative>
    UK Office for Library and Information Networking
  </dcterms:alternative>
  <dc:subject>
    national centre, network information support, library
    community, awareness, research, information services,public
    library networking, bibliographic management, distributed
    library systems, metadata, resource discovery,
    conferences,lectures, workshops
  </dc:subject>
  <dc:subject xsi:type="dcterms:DDC">
    062
  </dc:subject>
  <dc:subject xsi:type="dcterms:UDC">
    061(410)
  </dc:subject>
  <dc:description>
    UKOLN is a national focus of expertise in digital information
    management. It provides policy, research and awareness services
    to the UK library, information and cultural heritage communities.
    UKOLN is based at the University of Bath.
  </dc:description>
  <dc:description xml:lang="fr">
    UKOLN est un centre national d'expertise dans la gestion de l'information
    digitale.
  </dc:description>
  <dc:publisher>
    UKOLN, University of Bath
  </dc:publisher>
  <dcterms:isPartOf xsi:type="dcterms:URI">
    http://www.bath.ac.uk/
  </dcterms:isPartOf>
  <dc:identifier xsi:type="dcterms:URI">
    http://www.ukoln.ac.uk/
  </dc:identifier>
  <dcterms:modified xsi:type="dcterms:W3CDTF">
    2001-07-18
  </dcterms:modified>
  <dc:format xsi:type="dcterms:IMT">
    text/html
  </dc:format>
  <dcterms:extent>
    14 Kbytes
  </dcterms:extent>

</metadata>
-->
	
	<xsl:template match="fileDesc | titleStmt">
		<xsl:apply-templates select="node()" />
	</xsl:template>
	
	<xsl:template match="title">
		<dc:title>
			<xsl:apply-templates select="node()" />
		</dc:title>
	</xsl:template>
	
	<xsl:template match="author">
		<dc:creator opf:role="aut">
			<xsl:apply-templates select="node()" />
		</dc:creator>
	</xsl:template>

	<xsl:template match="editionStmt">
		<dc:description>
			<xsl:for-each select="p">
				<xsl:value-of select="."/>
				<xsl:text>&#10;</xsl:text>
			</xsl:for-each>
		</dc:description>
	</xsl:template>

	<xsl:template match="publicationStmt">
		<dc:identifier>
			<xsl:value-of select="normalize-space(.)"/>
		</dc:identifier>
	</xsl:template>

	<xsl:template match="sourceDesc">
		<dc:publisher>
			<xsl:value-of select="normalize-space(.)"/>
		</dc:publisher>
	</xsl:template>

	<xsl:template match="notesStmt"/>
	
	<xsl:template match="encodingDesc">
		<dc:format>
			<xsl:value-of select="normalize-space(.)"/>
		</dc:format>
	</xsl:template>

	<xsl:template match="revisionDesc">
		<dcterms:modified xsi:type="dcterms:W3CDTF">
			<xsl:value-of select="normalize-space(change/date)"/>
		</dcterms:modified>
	</xsl:template>
	
<!--
<teiHeader>
<fileDesc><titleStmt>
    <title type="main">Millioenen-studiën</title>
    <author>Multatuli</author>
</titleStmt><editionStmt>
<p>GEBRUIKT EXEMPLAAR</p>
    <p>exemplaar universiteitsbibliotheek Leiden, signatuur: 1212 E 21</p>
<p>&nbsp;</p>
<p>ALGEMENE OPMERKINGEN</p>
    <p>Dit bestand biedt, behoudens een aantal hierna te noemen ingrepen, een
        diplomatische weergave van <hi rend="i"
            >Millioenen-studiën</hi>
        van Multatuli uit 1972.</p>
<p>&nbsp;</p>
<p>REDACTIONELE INGREPEN</p>
    <p>p. III: kop ‘[Woord vooraf]’ toegevoegd.</p>
    <p>p. 193, 222, 223, 230: In deze digitale versie kan een accolade niet over meerdere regels
        weergegeven worden. De accolade op de betreffende pagina's is daarom herhaald.</p>
    <p>p. 288: deze pagina is verkeerd genummerd: 268 → 288.</p>
    <p>p. 305: noot ‘*)’ heeft in de tekst geen nootverwijzing; deze verwijzing is door de redactie
        alsnog geplaatst.</p>
    <p>&nbsp;</p>
<p>Bij de omzetting van de gebruikte bron naar deze publicatie in de dbnl is een aantal delen van de
    tekst niet overgenomen. Hieronder volgen de tekstgedeelten die wel in het origineel voorkomen
    maar hier uit de lopende tekst zijn weggelaten. Ook de blanco pagina's (p. II, IV) zijn niet opgenomen in de lopende tekst.</p>
    <p>&nbsp;</p>
    <p>
        <hi rend="b">[pagina ongenummerd (I)]</hi>
    </p>
    <p>MILLIOENEN-STUDIËN <hi rend="sc">door</hi> MULTATULI.</p>
    <p>&nbsp;</p>
    <p>DELFT. - J. WALTMAN <hi rend="sc">Jr.</hi></p>
    <p>1872.</p>
</editionStmt><publicationStmt>
<availability>
<p>2007 dbnl</p>
<p>&nbsp;</p>
</availability>
<idno>mult001mill01_01</idno>
</publicationStmt>
<notesStmt>
<note>grieks</note>
</notesStmt>
<sourceDesc>
    <p>Multatuli, <hi rend="i">Millioenen-studiën</hi>. J. Waltman jr., Delft 1872</p>
<p>&nbsp;</p>
</sourceDesc></fileDesc>
<encodingDesc>
<p>DBNL-TEI 1</p>
</encodingDesc>
<revisionDesc>
<change>
<date>2007-08-16</date>
<respStmt>
<name type="person">DH</name>
</respStmt>
<item>colofon toegevoegd</item>
</change>
</revisionDesc>
</teiHeader> 
-->
	
</xsl:stylesheet>