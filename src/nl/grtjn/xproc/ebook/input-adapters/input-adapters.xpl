<?xml version="1.0"?>
<p:library version="1.0"
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:ut="http://grtjn.nl/ns/xproc/util"

	xmlns:eb="http://grtjn.nl/ns/xproc/ebook"
	xmlns:in="http://grtjn.nl/ns/xproc/ebook/input-adapters"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:opf="http://www.idpf.org/2007/opf"
	
	exclude-inline-prefixes="#all">

<!--+========================================================+
	| Imports
	+-->
	
	<p:import href="../../util/utils.xpl"/>

<!--+========================================================+
	| Step apply-input-adapters
	+-->
	
	<p:declare-step type="in:apply-input-adapters">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>
		
		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="lib-base-uri" select="base-uri(.)"><p:inline><x/></p:inline></p:variable>
			<p:variable name="log-dir" select="//c:param[@name = 'log-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>

			<p:viewport match="eb:metadata|eb:front|eb:main|eb:back">
				<p:variable name="part" select="local-name(*)"/>
				
				<!-- apply all content inserts -->
				<p:viewport match="eb:metadata/eb:get-metadata|eb:front/eb:get-front-matter|eb:main/eb:get-main-matter|eb:back/eb:get-back-matter|eb:part[not(@type)]" name="part">
					<p:variable name="action" select="local-name(*)"/>
					<p:variable name="type" select="*/@type"/>
								
					<p:try>
						<p:group>
							<p:variable name="xref" select="resolve-uri(*/@href, base-uri(.))" />
							<ut:message>
								<p:with-option name="message" select="concat('Inserting ', $type, ' ', replace($action, 'get-', ''), ' ', $xref, ' into ', $part, ' part')" />
							</ut:message>
				
							<ut:insert-doc>
								<p:with-option name="xref" select="$xref"/>
							</ut:insert-doc>

							<p:rename match="eb:get-metadata|eb:get-front-matter|eb:get-main-matter|eb:get-back-matter" new-name="eb:part"/>
							
							<p:add-attribute match="eb:part" attribute-name="type">
								<p:with-option name="attribute-value" select="replace($action, 'get-', '')"/>
							</p:add-attribute>
							
							<!-- apply xsl input-adapter on current part -->
							<p:viewport match="eb:part/*">
								<ut:xslt>
									<p:with-option name="href" select="resolve-uri(concat($type, '/', $action, '.xsl'), $lib-base-uri)"/>
								</ut:xslt>
							</p:viewport>
							
							<p:delete match="eb:part/*[empty(*)]" />
							<p:delete match="eb:part[empty(*)]" />
						</p:group>
						
						<p:catch>
							<ut:throw-error code="UNKNOWN-INPUT">
								<p:with-option name="message" select="concat('Unsupported input type ', $type, ' or action ', $action, ' (', resolve-uri(concat($type, '/', $action, '.xsl'), $lib-base-uri), ')')"/>
							</ut:throw-error>
						</p:catch>
					</p:try>
				</p:viewport>
				
			</p:viewport>
			
			<p:identity name="input" />
			<p:sink/>
			
			<!-- insert default metadata values -->
			
			<p:document-template name="default-metadata">
				<p:input port="template">
					<p:inline>
						<eb:default-metadata>
							<dc:source>Derived from {$input-filename}</dc:source>
							<dc:creator opf:role="oth">Generated using {$app-name}</dc:creator>
							<dc:identifier id="BookId">{$output-basename}</dc:identifier>
						</eb:default-metadata>
					</p:inline>
				</p:input>
				<p:input port="source">
					<p:empty/>
				</p:input>
				<p:input port="parameters">
					<p:pipe step="params" port="parameters"/>
				</p:input>
			</p:document-template>
			
			<p:insert match="eb:metadata" position="last-child">
				<p:input port="source">
					<p:pipe step="input" port="result"/>
				</p:input>
				<p:input port="insertion">
					<p:pipe step="default-metadata" port="result"/>
				</p:input>
			</p:insert>
		</p:group>
		
	</p:declare-step>

</p:library>