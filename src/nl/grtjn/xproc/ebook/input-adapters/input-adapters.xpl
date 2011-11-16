<?xml version="1.0"?>
<p:library version="1.0"
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions"
	xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
	xmlns:ut="http://grtjn.nl/ns/xproc/util"

	xmlns:eb="http://grtjn.nl/ns/xproc/ebook"
	xmlns:in="http://grtjn.nl/ns/xproc/ebook/input-adapters"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:opf="http://www.idpf.org/2007/opf"
	xmlns:x="http://www.w3.org/1999/xhtml" 
	
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
								<ut:xslt name="xslt">
									<p:with-option name="href" select="resolve-uri(concat($type, '/', $action, '.xsl'), $lib-base-uri)"/>
								</ut:xslt>

								<!-- debug logging -->
								<ut:log>
									<p:with-option name="href" select="resolve-uri(concat($type, '-', $action, '.xml'), $log-dir)"/>
								</ut:log>
								<ut:log>
									<p:input port="source">
										<p:pipe step="xslt" port="secondary"/>
									</p:input>
									<p:with-option name="href" select="resolve-uri(concat($type, '-', $action, '-extra.xml'), $log-dir)"/>
								</ut:log>
								<p:sink/>
								<p:identity>
									<p:input port="source">
										<p:pipe step="xslt" port="result"/>
									</p:input>
								</p:identity>
								<!-- /debug logging -->
								
								<in:store-extra-files>
									<p:input port="secondary">
										<p:pipe step="xslt" port="secondary"/>
									</p:input>
								</in:store-extra-files>
							</p:viewport>
							
							<in:download-images />
							
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

<!--+========================================================+
	| Step store-extra-files
	+-->
	
	<p:declare-step type="in:store-extra-files" name="current">
		<p:input port="source" primary="true"/>
		<p:input port="secondary" sequence="true"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result">
			<p:pipe step="current" port="source"/>
		</p:output>
		
		<ut:parameters name="params"/>
		
		<p:sink/>
		
		<p:group>
			<p:variable name="input-dir" select="//c:param[@name = 'input-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>

			<p:for-each name="for-each">
				<p:iteration-source select="/"><p:pipe step="current" port="secondary"/></p:iteration-source>
				
				<p:variable name="outpath" select="base-uri(/*)"/>
				
				<ut:message>
					<p:with-option name="message" select="concat('Storing extra file to ', $outpath, '..')" />
				</ut:message>
				
				<p:rename match="/*[@encoding = 'base64']" new-name="c:data"/>
				
				<!-- only c:data is actually decoded, other contents is passed through untouched, despite the cx:decode=true -->
				<p:store cx:decode="true">
					<p:with-option name="href" select="$outpath" />
				</p:store>
			</p:for-each>
		</p:group>
		
	</p:declare-step>

<!--+========================================================+
	| Step download-images
	+-->
	
	<p:declare-step type="in:download-images" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>
		
		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="input-dir" select="//c:param[@name = 'input-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>

			<p:viewport match="x:img[starts-with(@src, 'http://')]" name="viewport">
				<p:variable name="src" select="/*/@src"/>
				<p:variable name="outfile" select="translate($src, ':/', '__')"/>
				
				<cxf:info name="file-info">
					<p:with-option name="href" select="resolve-uri($outfile, $input-dir)" />
				</cxf:info>
				
				<p:wrap-sequence wrapper="c:file-info" />
				
				<p:group>
					<p:variable name="file-exists" select="exists(/*/*)"/>
					
					<ut:empty/>
					
					<p:choose>
						<p:when test="string($file-exists) = 'false'">
							<ut:message>
								<p:with-option name="message" select="concat('Downloading image from ', $src, ' to ', resolve-uri($outfile, $input-dir), '..')" />
							</ut:message>
							
							<p:template>
								<p:input port="template">
									<p:inline>
										<c:request method="GET" href="{$src}" />
									</p:inline>
								</p:input>
								<p:with-param name="src" select="$src"/>
							</p:template>

							<p:http-request/>
							
							<p:store cx:decode="true">
								<p:with-option name="href" select="resolve-uri($outfile, $input-dir)" />
							</p:store>
							
							<p:identity>
								<p:input port="source">
									<p:pipe step="viewport" port="current"/>
								</p:input>
							</p:identity>
						</p:when>
						<p:otherwise>
							<ut:message>
								<p:with-option name="message" select="concat('Skipping image from ', $src, '..')" />
							</ut:message>
							
							<p:identity>
								<p:input port="source">
									<p:pipe step="viewport" port="current"/>
								</p:input>
							</p:identity>
						</p:otherwise>
					</p:choose>
					
					<p:add-attribute match="*" attribute-name="src">
						<p:with-option name="attribute-value" select="$outfile"/>
					</p:add-attribute>
				</p:group>
			</p:viewport>
		</p:group>
		
	</p:declare-step>

</p:library>