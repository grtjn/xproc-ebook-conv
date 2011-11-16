<?xml version="1.0"?>
<p:library version="1.0"
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
	xmlns:cos="http://xmlcalabash.com/ns/extensions/osutils"
	xmlns:ut="http://grtjn.nl/ns/xproc/util"

	xmlns:eb="http://grtjn.nl/ns/xproc/ebook"
	xmlns:out="http://grtjn.nl/ns/xproc/ebook/output-adapters"
	xmlns:epub="http://grtjn.nl/ns/xproc/ebook/output-adapters/epub"

	exclude-inline-prefixes="#all">

<!--+========================================================+
	| Imports
	+-->
	
	<p:import href="../../../util/utils.xpl"/>

<!--+========================================================+
	| Step store
	+-->
	
	<p:declare-step type="epub:store">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>

		<epub:store-mimetype/>
		<epub:store-container/>
		<epub:store-manifest/>
		<epub:store-navigation/>
		<epub:store-pages/>
		<epub:copy-images/>
		<epub:copy-style/>
		<epub:create-epub/>
		<epub:check-epub/>
		
	</p:declare-step>

<!--+========================================================+
	| Step store-mimetype
	+-->
	
	<p:declare-step type="epub:store-mimetype" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result">
			<p:pipe step="current" port="source"/>
		</p:output>

		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="temp-dir" select="//c:param[@name = 'temp-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			
			<ut:message message="Adding mimetype to epub"/>
					
			<p:store method="text">
				<p:with-option name="href" select="resolve-uri('epub/mimetype', $temp-dir)"/>
				<p:input port="source">
					<p:inline><c:text>application/epub+zip</c:text></p:inline>
				</p:input>
			</p:store>
		</p:group>
		
	</p:declare-step>

<!--+========================================================+
	| Step store-container
	+-->
	
	<p:declare-step type="epub:store-container" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result">
			<p:pipe step="current" port="source"/>
		</p:output>

		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="temp-dir" select="//c:param[@name = 'temp-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			
			<ut:message message="Adding META-INF/container.xml to epub"/>
					
			<p:store indent="true">
				<p:with-option name="href" select="resolve-uri('epub/META-INF/container.xml', $temp-dir)"/>
				<p:input port="source">
					<p:inline>
						<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
						  <rootfiles>
							<rootfile full-path="OPS/manifest.opf" media-type="application/oebps-package+xml"/>
						  </rootfiles>
						</container>
					</p:inline>
				</p:input>
			</p:store>
		</p:group>
		
	</p:declare-step>

<!--+========================================================+
	| Step store-manifest
	+-->
	
	<p:declare-step type="epub:store-manifest" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result">
			<p:pipe step="current" port="source"/>
		</p:output>

		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="lib-base-uri" select="base-uri(.)"><p:inline><x/></p:inline></p:variable>
			<p:variable name="temp-dir" select="//c:param[@name = 'temp-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>

			<ut:message message="Adding OPS/manifest.opf to epub"/>

			<ut:xslt>
				<p:with-option name="href" select="resolve-uri('generate-manifest.xsl', $lib-base-uri)" />
			</ut:xslt>
			
			<p:store indent="true">
				<p:with-option name="href" select="resolve-uri('epub/OPS/manifest.opf', $temp-dir)"/>
			</p:store>
		</p:group>
	</p:declare-step>
	
<!--+========================================================+
	| Step store-navigation
	+-->
	
	<p:declare-step type="epub:store-navigation" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result">
			<p:pipe step="current" port="source"/>
		</p:output>

		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="lib-base-uri" select="base-uri(.)"><p:inline><x/></p:inline></p:variable>
			<p:variable name="temp-dir" select="//c:param[@name = 'temp-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>

			<ut:message message="Adding OPS/toc.ncx to epub"/>

			<ut:xslt>
				<p:with-option name="href" select="resolve-uri('generate-navigation.xsl', $lib-base-uri)" />
			</ut:xslt>
			
			<p:store indent="true">
				<p:with-option name="href" select="resolve-uri('epub/OPS/toc.ncx', $temp-dir)"/>
			</p:store>
		</p:group>
	</p:declare-step>
	
<!--+========================================================+
	| Step store-pages
	+-->
	
	<p:declare-step type="epub:store-pages" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result">
			<p:pipe step="current" port="source"/>
		</p:output>

		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="lib-base-uri" select="base-uri(.)"><p:inline><x/></p:inline></p:variable>
			<p:variable name="temp-dir" select="//c:param[@name = 'temp-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			<p:variable name="debug" select="//c:param[@name = 'debug']/@value"><p:pipe step="params" port="parameters"/></p:variable>
		
			<p:viewport match="eb:section[eb:page and not(descendant::eb:section[eb:page])]">
				<p:variable name="section-id" select="*/@id" />
				
				<p:viewport match="eb:page[not(descendant::eb:page)]">
					<p:variable name="id" select="*/@id" />
					<p:variable name="nr" select="*/@n"/>
					
					<ut:message>
						<p:with-option name="message" select="concat('Adding OPS/', $id, '.xhtml to epub')" />
					</ut:message>

					<ut:xslt>
						<p:with-option name="href" select="resolve-uri('generate-page.xsl', $lib-base-uri)" />
						<p:with-param name="section-id" select="$section-id"/>
						<p:with-param name="page-number" select="$nr"/>
					</ut:xslt>
			
					<p:store>
						<p:with-option name="indent" select="$debug"/>
						<p:with-option name="href" select="resolve-uri(concat('epub/OPS/', $id, '.xhtml'), $temp-dir)"/>
					</p:store>
					
					<ut:empty/>
				</p:viewport>
			</p:viewport>
			
			<p:choose>
				<p:when test="/descendant::eb:section[eb:page]">
					<epub:store-pages/>
				</p:when>
				<p:otherwise>
					<p:identity/>
				</p:otherwise>
			</p:choose>
		</p:group>
		
		<p:sink/>
		
	</p:declare-step>
	
<!--+========================================================+
	| Step copy-images
	+-->
	
	<p:declare-step type="epub:copy-images" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result">
			<p:pipe step="current" port="source"/>
		</p:output>

		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="temp-dir" select="//c:param[@name = 'temp-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			<p:variable name="log-dir" select="//c:param[@name = 'log-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>

			<!-- loop over images to copy them -->
			
			<p:viewport match="*[eb:image]">
				<p:variable name="parent-base-uri" select="base-uri(*)"/>
				
				<p:viewport match="eb:image">
					<p:variable name="src" select="*/@src" />
					<p:variable name="dir" select="replace($src, '^(.*/)?([^/]+)$', '$1')" />
					<p:variable name="base-uri" select="base-uri(*)"/>
					<p:variable name="href" select="if (starts-with($base-uri, 'http://')) then resolve-uri($src, $parent-base-uri) else resolve-uri($src, $base-uri)" />
					
					<ut:message>
						<p:with-option name="message" select="concat('Adding OPS/', $src, ' to epub')" />
					</ut:message>
					
					<p:try name="try">
						<p:group>
							<p:choose>
								<p:when test="contains($src, '/')">
									<p:sink/>
									<cxf:mkdir> 
										<p:with-option name="href" select="$dir" />
									</cxf:mkdir>
									<ut:empty/>
								</p:when>
								<p:otherwise>
									<p:identity/>
								</p:otherwise>
							</p:choose>

							<cxf:copy fail-on-error="false">
								<p:with-option name="href" select="$href" />
								<p:with-option name="target" select="resolve-uri(concat('epub/OPS/', $src), $temp-dir)" />
							</cxf:copy>
							
							<ut:empty/>
						</p:group>
						<p:catch name="catch">
							<ut:log>
								<p:with-option name="href" select="resolve-uri('catch.xml', $log-dir)"/>
								<p:input port="source">
									<p:pipe step="catch" port="error"/>
								</p:input>
							</ut:log>
							
							<ut:message message="..copying image failed!!"/>
						</p:catch>
					</p:try>
					
				</p:viewport>
			</p:viewport>
		</p:group>
		
		<p:sink/>
		
	</p:declare-step>

<!--+========================================================+
	| Step copy-style
	+-->
	
	<p:declare-step type="epub:copy-style" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result">
			<p:pipe step="current" port="source"/>
		</p:output>

		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="temp-dir" select="//c:param[@name = 'temp-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			<p:variable name="log-dir" select="//c:param[@name = 'log-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			
			<p:variable name="output-style" select="//c:param[@name = 'output-style']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			<p:variable name="styles-uri" select="//c:param[@name = 'styles-uri']/@value"><p:pipe step="params" port="parameters"/></p:variable>

			<!-- copy style files for selected output style -->
			<ut:message>
				<p:with-option name="message" select="concat('Copying style files using configuration ', $styles-uri)"/>
			</ut:message>
				
			<p:sink/>
							
			<p:load>
				<p:with-option name="href" select="$styles-uri"/>
			</p:load>
			
			<p:filter>
				<p:with-option name="select" select="concat('//*[self::generic-style or @name = &quot;', $output-style, '&quot;]/output[@method = &quot;epub&quot;]/files')"/>
			</p:filter>
			
			<p:wrap-sequence wrapper="wrapper" />

			<p:viewport match="file">
				<p:variable name="src" select="*/@href" />
				<p:variable name="dir" select="replace($src, '^(.*/)?([^/]+)$', '$1')" />
				<p:variable name="base-uri" select="base-uri(*)"/>
				<p:variable name="href" select="resolve-uri($src, $base-uri)" />
				
				<ut:message>
					<p:with-option name="message" select="concat('Adding OPS/', $src, ' to epub')" />
				</ut:message>
				
				<p:try>
					<p:group>
						<p:choose>
							<p:when test="contains($src, '/')">
								<p:sink/>
								<cxf:mkdir> 
									<p:with-option name="href" select="resolve-uri(concat('epub/OPS/', $dir), $temp-dir)" />
								</cxf:mkdir>
								<ut:empty/>
							</p:when>
							<p:otherwise>
								<p:identity/>
							</p:otherwise>
						</p:choose>
						<cxf:copy fail-on-error="false">
							<p:with-option name="href" select="$href" />
							<p:with-option name="target" select="resolve-uri(concat('epub/OPS/', $src), $temp-dir)" />
						</cxf:copy>
						<ut:empty/>
					</p:group>
					<p:catch name="catch">
						<ut:log>
							<p:with-option name="href" select="resolve-uri('catch.xml', $log-dir)"/>
							<p:input port="source">
								<p:pipe step="catch" port="error"/>
							</p:input>
						</ut:log>

						<ut:message message="..copying style failed!!"/>
					</p:catch>
				</p:try>
			</p:viewport>
		</p:group>
		
		<p:sink/>
		
	</p:declare-step>

<!--+========================================================+
	| Step create-epub
	+-->
	
	<p:declare-step type="epub:create-epub" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result">
			<p:pipe step="current" port="source"/>
		</p:output>
		
		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="lib-base-uri" select="base-uri(.)"><p:inline><x/></p:inline></p:variable>
			<p:variable name="temp-dir" select="//c:param[@name = 'temp-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			<p:variable name="log-dir" select="//c:param[@name = 'log-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>
		
			<p:variable name="output-file" select="//c:param[@name = 'output-file']/@value"><p:pipe step="params" port="parameters"/></p:variable>
		
			<!-- logging -->
			
			<ut:message>
				<p:with-option name="message" select="concat('Writing output to ', $output-file)" />
			</ut:message>
			
			<p:sink/>
			
			<!-- manually create dir list for zip -->
			
			<p:add-attribute match="/*" attribute-name="xml:base" name="zip-files">
				<p:input port="source">
					<p:inline>
						<c:files>
							<c:file name="mimetype"/>
							<c:directory name="META-INF"/>
							<c:directory name="OPS"/>
						</c:files>
					</p:inline>
				</p:input>
				<p:with-option name="attribute-value" select="resolve-uri('epub/', $temp-dir)"/>
			</p:add-attribute>
			
			<ut:log>
				<p:with-option name="href" select="resolve-uri('zip-files.xml', $log-dir)"/>
			</ut:log>

			<p:sink/>

			<!-- create the epub using zip -->
			
			<ut:zip>
				<p:with-option name="href" select="$output-file"/>
				<p:input port="source">
					<p:pipe step="zip-files" port="result" />
				</p:input>
			</ut:zip>
		</p:group>
		
	</p:declare-step>
	
<!--+========================================================+
	| Step check-epub
	+-->
	
	<p:declare-step type="epub:check-epub" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result">
			<p:pipe step="current" port="source"/>
		</p:output>
		
		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="log-dir" select="//c:param[@name = 'log-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			<p:variable name="output-file" select="replace(replace(//c:param[@name = 'output-file']/@value, '^file:/+', ''), '%20', ' ')"><p:pipe step="params" port="parameters"/></p:variable>
		
			<p:variable name="quot" select="string(.)"><p:inline><x>"</x></p:inline></p:variable>
		
			<!-- logging -->
			
			<ut:message>
				<p:with-option name="message" select="concat('Checking epub ', $output-file)" />
			</ut:message>
			
			<p:sink/>
			
			<!-- get java home -->
			
			<ut:sys-info name="sysinfo"/>
			
			<p:group>
				<p:variable name="java-home" select="string(//c:info[@name = 'java.home']/@value)">
					<p:pipe step="sysinfo" port="result"/>
				</p:variable>
			
				<!-- check the epub -->
			
				<p:exec source-is-xml="false" result-is-xml="false" name="exec">
					<p:with-option name="command" select="concat($java-home, '/bin/java')"/>
					<p:with-option name="args" select="concat('-jar lib/epubcheck-1.2/epubcheck-1.2.jar -v ', $quot, $output-file, $quot, '')"/>
					<p:input port="source">
						<p:empty/>
					</p:input>
				</p:exec>
			
				<!-- results are written to console, but save a copy to file if debug is enabled as well -->
			
				<ut:log>
					<p:input port="source">
						<p:pipe step="exec" port="errors"/>
					</p:input>
					<p:with-option name="href" select="resolve-uri('epubcheck.xml', $log-dir)"/>
				</ut:log>
			</p:group>
		</p:group>

		<p:sink/>
		
	</p:declare-step>
	
</p:library>