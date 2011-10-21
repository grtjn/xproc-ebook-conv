<?xml version="1.0"?>
<p:library version="1.0"
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:ut="http://grtjn.nl/ns/xproc/util"

	xmlns:eb="http://grtjn.nl/ns/xproc/ebook"
	xmlns:out="http://grtjn.nl/ns/xproc/ebook/output-adapters"
	xmlns:epub="http://grtjn.nl/ns/xproc/ebook/output-adapters/epub"

	exclude-inline-prefixes="#all">

<!--+========================================================+
	| Imports
	+-->
	
	<p:import href="../../util/utils.xpl"/>
	<p:import href="epub/epub.xpl"/>

<!--+========================================================+
	| Step apply-output-adapters
	+-->
	
	<p:declare-step type="out:apply-output-adapter" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>

		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="output-method" select="//c:param[@name = 'output-method']/@value"><p:pipe step="params" port="parameters"/></p:variable>

			<p:choose>
				<p:when test="$output-method = 'epub'">
					<epub:store />
				</p:when>
				<p:otherwise>
					<ut:throw-error code="UNKNOWN-OUTPUT">
						<p:with-option name="message" select="concat('Unknown output-method ', $output-method)"/>
					</ut:throw-error>
				</p:otherwise>
			</p:choose>
		</p:group>
		
	</p:declare-step>
	
</p:library>