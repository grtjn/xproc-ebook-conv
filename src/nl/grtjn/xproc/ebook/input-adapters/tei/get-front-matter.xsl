<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns="http://www.w3.org/1999/xhtml"
	
	exclude-result-prefixes="#all">

	<xsl:param name="debug" select="false()"/>
	<xsl:param name="verbose" select="false()"/>

	<xsl:param name="debug_" select="lower-case(string($debug)) = ('1', 'j', 'y', 'yes', 'true')"/>
	<xsl:param name="verbose_" select="lower-case(string($verbose)) = ('1', 'j', 'y', 'yes', 'true')"/>

	<xsl:template match="*">
		<xsl:if test="$verbose_">
			<xsl:message>WARN: default rule for TEI element &lt;<xsl:value-of select="local-name()"/><xsl:for-each select="@*"><xsl:text> </xsl:text><xsl:value-of select="local-name()"/>="<xsl:value-of select="."/>"</xsl:for-each>&gt;!</xsl:message>
		</xsl:if>
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="@*|node()" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="/">
		<body xml:base="{base-uri(.)}">
			<div class="cover">
				<div class="title">
					<xsl:apply-templates select="TEI.2/teiHeader/fileDesc/titleStmt/title/node()" />
				</div>
				<div class="author">
					<xsl:apply-templates select="TEI.2/teiHeader/fileDesc/titleStmt/author/node()" />
				</div>
				<div class="source">
					<xsl:apply-templates select="TEI.2/teiHeader/fileDesc/sourceDesc/node()" />
				</div>
				<div class="copyright">
					<xsl:text>&#169;</xsl:text>
					<xsl:apply-templates select="TEI.2/teiHeader/fileDesc/publicationStmt/availability/node()" />
				</div>
				<div class="id">
					<xsl:apply-templates select="TEI.2/teiHeader/fileDesc/publicationStmt/idno/node()" />
				</div>
			</div>
			<div class="disclaimer">
				<xsl:apply-templates select="TEI.2/teiHeader/fileDesc/editionStmt/node()" />
			</div>
		</body>
	</xsl:template>
	
	<xsl:template match="@*|comment()|processing-instruction()">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="hi[@rend = ('i', 'b', 'sup', 'sub')]">
		<xsl:element name="{@rend}">
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
			<xsl:apply-templates select="node()" />
		</span>
	</xsl:template>

	<xsl:template match="p">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="node()" />
		</xsl:element>
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