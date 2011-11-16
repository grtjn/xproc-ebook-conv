<?xml version="1.0"?>
<!--+
	| Main - Main ebook processing pipeline.
	|
	| Usage:
	|	java -jar lib/calabash.jar -i source=in\example-ebook-layout.xml -p debug=true src\nl\grtjn\xproc\ebook\main.xpl output-method=epub
	|
	| Input:
	| - source			Input or ebook config file.				[required]
	| - debug			Option to enable debug logging.			[default: false]
	| - output-method	Option determining output method.		[default: epub]
	| - output-style	Option determining output style.		[default: #default]
	| - verbose			Option to enable verbosity on console.	[default: true]
	|
	| Declares steps:
	| - compose							Compose ebook out of xml fragments.
	| - build-hierarchy					Add hierarchy to flat input structures.
	| - insert-index					Replace index marker with real index.
	| - insert-list-of-illustrations	Replace list-of-illustrations marker with real list of figures.
	| - insert-list-of-tables			Replace list-of-tables marker with real list of tables.
	| - insert-notes-page				Replace notes-page marker with page gathering all notes.
	| - insert-table-of-contents		Replace table-of-contents marker with real table of contents.
	| - paginate						Apply pagination if requested.
	| - resolve-links					Resolve links aka page refs and cross links.
	| - store							Write final output.
	+-->
<p:declare-step version="1.0"
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions"
	xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
	xmlns:ut="http://grtjn.nl/ns/xproc/util"
	
	xmlns:eb="http://grtjn.nl/ns/xproc/ebook"
	xmlns:in="http://grtjn.nl/ns/xproc/ebook/input-adapters"
	xmlns:out="http://grtjn.nl/ns/xproc/ebook/output-adapters"
	
	xmlns:x="http://www.w3.org/1999/xhtml"
	
	exclude-inline-prefixes="#all" name="main">

<!--+========================================================+
	| Imports
	+-->
	
	<!-- various convenience steps -->
	<p:import href="../util/utils.xpl"/>
	
	<!-- ebook input and output handling -->
	<p:import href="input-adapters/input-adapters.xpl"/>
	<p:import href="output-adapters/output-adapters.xpl"/>

<!--+========================================================+
	| Options
	+-->
	
	<p:option name="debug" select="false()"/>
	<p:option name="output-method" select="'epub'"/>
	<p:option name="output-style" select="'#default'"/>
	<p:option name="verbose" select="true()"/>

	<p:option name="styles-file" select="'style/styles.xml'"/>
	<p:option name="template-file" select="'style/default/input-template-nl.xml'"/>
		
<!--+========================================================+
	| Input
	+-->
	
	<p:input port="source"/>
	<p:input port="parameters" kind="parameter"/>

<!--+========================================================+
	| Globals
	+-->
	
	<p:variable name="version" select="'1.1'"/>
	<p:variable name="app-name" select="concat('XProc E-Book Processor v', $version, ' by @grtjn')"/>
	
	<p:variable name="lib-base-uri" select="base-uri(.)"><p:inline><x/></p:inline></p:variable>
	<p:variable name="project-base-uri" select="resolve-uri('../../../../..', $lib-base-uri)"/>

	<p:variable name="style-dir" select="resolve-uri('style/', $project-base-uri)"/>
	<p:variable name="input-dir" select="resolve-uri('in/', $project-base-uri)"/>
	<p:variable name="log-dir" select="resolve-uri('log/', $project-base-uri)"/>
	<p:variable name="output-dir" select="resolve-uri('out/', $project-base-uri)"/>
	<p:variable name="temp-dir" select="resolve-uri('tmp/', $project-base-uri)"/>
	
	<p:variable name="input-file" select="base-uri(/*)"/>
	<p:variable name="input-filename" select="replace($input-file, '^(.*/)?([^/]+)$', '$2')"/>
	<p:variable name="input-basename" select="replace($input-filename, '^(.+?)(\.[^\.]+)$', '$1')"/>

	<p:variable name="output-basename" select="concat($input-basename, '-', translate($output-style, '#', ''))"/>
	<p:variable name="output-filename" select="concat($output-basename, '.', $output-method)"/>
	<p:variable name="output-file" select="resolve-uri($output-filename, $output-dir)" />
	
	<p:variable name="styles-uri" select="resolve-uri($styles-file, $project-base-uri)"/>
	<p:variable name="template-uri" select="resolve-uri($template-file, $project-base-uri)"/>
		
<!--+========================================================+
	| Step apply-template
	|
	| Check for raw input, and apply template if so.
	+-->
	
	<p:declare-step type="eb:apply-template" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>
		
		<p:variable name="is-template" select="exists(/eb:ebook)"/>
		<p:variable name="input-type" select="replace(lower-case(local-name(/*)), '[^a-z]+', '')"/>
		
		<!-- merge parameters sequence to single doc for use in variable -->
		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="input-file" select="//c:param[@name = 'input-file']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			<p:variable name="output-style" select="//c:param[@name = 'output-style']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			<p:variable name="styles-uri" select="//c:param[@name = 'styles-uri']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			<p:variable name="template-uri" select="//c:param[@name = 'template-uri']/@value"><p:pipe step="params" port="parameters"/></p:variable>
		
			<p:choose>
				<p:when test="string($is-template) eq 'true'">
					<ut:message>
						<p:with-option name="message" select="'Input is template, continuing'"/>
					</ut:message>
				</p:when>
				<p:otherwise>
					<p:sink/>
					
					<p:load name="styles">
						<p:with-option name="href" select="$styles-uri"/>
					</p:load>
					
					<p:group>
						<p:variable name="template-file" select="($template-uri, //style[@name = ($output-style, '#default')]/input-template/@href)[1]"><p:pipe step="styles" port="result"/></p:variable>
						<p:variable name="real-template-uri" select="resolve-uri($template-file, base-uri(/*))"><p:pipe step="styles" port="result"/></p:variable>
			
						<ut:message>
							<p:with-option name="message" select="concat('Input is raw, applying template ', $real-template-uri, ' for type ', $input-type)"/>
						</ut:message>
						
						<p:load name="template">
							<p:with-option name="href" select="$real-template-uri"/>
						</p:load>
						
						<p:identity>
							<p:input port="source">
								<p:pipe step="template" port="result"/>
							</p:input>
						</p:identity>
						
						<p:add-attribute match="eb:get-metadata|eb:get-front-matter|eb:get-main-matter|eb:get-back-matter" attribute-name="type">
							<p:with-option name="attribute-value" select="$input-type"/>
						</p:add-attribute>
						
						<p:add-attribute match="eb:get-metadata|eb:get-front-matter|eb:get-main-matter|eb:get-back-matter" attribute-name="href">
							<p:with-option name="attribute-value" select="$input-file"/>
						</p:add-attribute>
						
					</p:group>
				</p:otherwise>
			</p:choose>

		</p:group>
		
	</p:declare-step>
	
<!--+========================================================+
	| Step process-ebook
	|
	| Main processing loop.
	+-->
	
	<p:declare-step type="eb:process-ebook">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>

		<!-- merge parameters sequence to single doc for use in variable -->
		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="log-dir" select="//c:param[@name = 'log-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			
			<p:variable name="debug" select="//c:param[@name = 'debug']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			<p:variable name="verbose" select="//c:param[@name = 'verbose']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			<p:variable name="output-method" select="//c:param[@name = 'output-method']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			<p:variable name="output-style" select="//c:param[@name = 'output-style']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			<p:variable name="styles-uri" select="//c:param[@name = 'styles-uri']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			<p:variable name="template-uri" select="//c:param[@name = 'template-uri']/@value"><p:pipe step="params" port="parameters"/></p:variable>

			<!-- show selected options on screen (only shown when verbose = true!) -->
			<ut:message message="verbose is activated"/>
			<p:choose>
				<p:when test="string($debug) eq 'true'">
					<ut:message message="debug is activated"/>
				</p:when>
				<p:otherwise>
					<p:identity/>
				</p:otherwise>
			</p:choose>
			<ut:message>
				<p:with-option name="message" select="concat('Using output-method: ', $output-method)"/>
			</ut:message>
			<ut:message>
				<p:with-option name="message" select="concat('Using output-style: ', $output-style)"/>
			</ut:message>
			<ut:message>
				<p:with-option name="message" select="concat('Using styles file: ', $styles-uri)"/>
			</ut:message>
			<ut:message>
				<p:with-option name="message" select="concat('Using template file: ', $template-uri)"/>
			</ut:message>
			
			<!-- preparations -->
			<eb:clear/>
			
			<!-- debug output -->
			<ut:log>
				<p:with-option name="href" select="resolve-uri('input.xml', $log-dir)"/>
			</ut:log>
			
			<!-- main processing steps -->
			<eb:compose/>
			<eb:mark-specials/>
			<eb:build-hierarchy/>
			<eb:insert-notes-page/>
			<eb:insert-index/>
			<eb:insert-list-of-illustrations/>
			<eb:insert-list-of-tables/>
			<eb:insert-table-of-contents/>
			
			<!-- debug output -->
			<ut:log>
				<p:with-option name="href" select="resolve-uri('enriched-input.xml', $log-dir)"/>
			</ut:log>
			
			<eb:paginate/>
			<eb:resolve-links/>
			<eb:store/>
		
			<!-- debug output -->
			<ut:log>
				<p:with-option name="href" select="resolve-uri('out.xml', $log-dir)"/>
			</ut:log>
		</p:group>
		
	</p:declare-step>
	
<!--+========================================================+
	| Step clear
	|
	| Clear temporary and output files before main processing.
	+-->
	
	<p:declare-step type="eb:clear" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result">
			<p:pipe step="current" port="source"/>
		</p:output>

		<!-- merge parameters sequence to single doc for use in variable -->
		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="temp-dir" select="//c:param[@name = 'temp-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			<p:variable name="output-file" select="//c:param[@name = 'output-file']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			
			<ut:message message="Clearing temporary files"/>
				
			<ut:delete recursive="true" fail-on-error="false">
				<p:with-option name="href" select="$temp-dir"/>
			</ut:delete>

			<ut:delete fail-on-error="false">
				<p:with-option name="href" select="$output-file"/>
			</ut:delete>
		</p:group>
			
		<p:sink/>
		
	</p:declare-step>
	
<!--+========================================================+
	| Step compose
	|
	| Compose ebook out of xml fragments.
	+-->
	
	<p:declare-step type="eb:compose">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>
		
		<in:apply-input-adapters />
		
	</p:declare-step>
	
<!--+========================================================+
	| Step mark-specials
	|
	| Add hierarchy to flat input structures.
	+-->
	
	<p:declare-step type="eb:mark-specials">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>

		<p:variable name="lib-base-uri" select="base-uri(.)"><p:inline><x/></p:inline></p:variable>

		<p:viewport match="eb:part">
			<p:variable name="type" select="*/@type"/>
			<p:variable name="href" select="*/@href"/>
			
			<p:viewport match="eb:part/*">
				<ut:message>
					<p:with-option name="message" select="concat('Marking specials within ', $type, ' ', $href)"/>
				</ut:message>
				
				<ut:xslt>
					<p:with-option name="href" select="resolve-uri('mark-specials.xsl', $lib-base-uri)" />
				</ut:xslt>
			</p:viewport>
		</p:viewport>
		
	</p:declare-step>
	
<!--+========================================================+
	| Step build-hierarchy
	|
	| Add hierarchy to flat input structures.
	+-->
	
	<p:declare-step type="eb:build-hierarchy">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>

		<p:variable name="lib-base-uri" select="base-uri(.)"><p:inline><x/></p:inline></p:variable>

		<p:viewport match="eb:part">
			<p:variable name="type" select="*/@type"/>
			<p:variable name="href" select="*/@href"/>
			
			<p:viewport match="eb:part/*">
				<ut:message>
					<p:with-option name="message" select="concat('Building hierarchy of ', $type, ' ', $href)"/>
				</ut:message>
				
				<ut:xslt>
					<p:with-option name="href" select="resolve-uri('build-hierarchy.xsl', $lib-base-uri)" />
				</ut:xslt>
			</p:viewport>
		</p:viewport>
		
	</p:declare-step>
	
<!--+========================================================+
	| Step insert-index
	|
	| Replace index marker with real index.
	+-->
	
	<p:declare-step type="eb:insert-index" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>

		<p:variable name="lib-base-uri" select="base-uri(.)"><p:inline><x/></p:inline></p:variable>

		<p:viewport match="eb:front|eb:back">
			<p:variable name="part" select="local-name(*)"/>
			
			<p:viewport match="eb:index">
				<p:variable name="title" select="*/@label"/>
				
				<ut:message>
					<p:with-option name="message" select="concat('Inserting an index ', $title, ' into ', $part, ' part')"/>
				</ut:message>
				
				<p:sink/>
				
				<ut:xslt>
					<p:input port="source">
						<p:pipe step="current" port="source"/>
					</p:input>
					<p:with-option name="href" select="resolve-uri('generate-index.xsl', $lib-base-uri)" />
					<p:with-param name="title" select="$title" />
					<p:with-param name="part" select="$part" />
					<p:with-param name="position" select="p:iteration-position()" />
				</ut:xslt>
			</p:viewport>
		</p:viewport>
		
	</p:declare-step>
	
<!--+========================================================+
	| Step insert-list-of-illustrations
	|
	| Replace list-of-illustrations marker with real list of illustrations.
	+-->
	
	<p:declare-step type="eb:insert-list-of-illustrations" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>

		<p:variable name="lib-base-uri" select="base-uri(.)"><p:inline><x/></p:inline></p:variable>

		<p:choose>
			<p:when test="exists(//eb:image)">
				<p:viewport match="eb:front|eb:back">
					<p:variable name="part" select="local-name(*)"/>
					
					<p:viewport match="eb:list-of-illustrations">
						<p:variable name="title" select="*/@label"/>
						
						<ut:message>
							<p:with-option name="message" select="concat('Inserting a list of illustrations ', $title, ' into ', $part, ' part')"/>
						</ut:message>

						<p:sink/>
						
						<ut:xslt>
							<p:input port="source">
								<p:pipe step="current" port="source"/>
							</p:input>
							<p:with-option name="href" select="resolve-uri('generate-list-of-illustrations.xsl', $lib-base-uri)" />
							<p:with-param name="title" select="$title" />
							<p:with-param name="part" select="$part" />
							<p:with-param name="position" select="p:iteration-position()" />
						</ut:xslt>
					</p:viewport>
				</p:viewport>
			</p:when>
			<p:otherwise>
				<ut:message message="No immages.."/>
			</p:otherwise>
		</p:choose>
		
	</p:declare-step>
	
<!--+========================================================+
	| Step insert-notes-page
	|
	| Replace notes-page marker with page gathering all notes.
	+-->
	
	<p:declare-step type="eb:insert-notes-page" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>

		<p:variable name="lib-base-uri" select="base-uri(.)"><p:inline><x/></p:inline></p:variable>
		
		<p:choose>
			<p:when test="exists(//eb:note) and exists(//eb:notes-page)">
				<p:viewport match="eb:main|eb:back">
					<p:variable name="part" select="local-name(*)"/>
					
					<p:viewport match="eb:notes-page">
						<p:variable name="title" select="*/@label"/>
						
						<ut:message>
							<p:with-option name="message" select="concat('Inserting a notes page ', $title, ' into ', $part, ' part')"/>
						</ut:message>
						
						<p:sink/>
						
						<ut:xslt>
							<p:input port="source">
								<p:pipe step="current" port="source"/>
							</p:input>
							<p:with-option name="href" select="resolve-uri('generate-notes-page.xsl', $lib-base-uri)" />
							<p:with-param name="title" select="$title" />
							<p:with-param name="part" select="$part" />
							<p:with-param name="position" select="p:iteration-position()" />
						</ut:xslt>
					</p:viewport>
				</p:viewport>
				
				<ut:message message="Cleaning up notes"/>
				
				<ut:xslt>
					<p:with-option name="href" select="resolve-uri('cleanup-notes.xsl', $lib-base-uri)" />
				</ut:xslt>
			</p:when>
			<p:otherwise>
				<ut:message message="No notes or notes pages.."/>
			</p:otherwise>
		</p:choose>
		
	</p:declare-step>
	
<!--+========================================================+
	| Step insert-list-of-tables
	|
	| Replace list-of-tables marker with real list of tables.
	+-->
	
	<p:declare-step type="eb:insert-list-of-tables" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>

		<p:variable name="lib-base-uri" select="base-uri(.)"><p:inline><x/></p:inline></p:variable>

		<p:choose>
			<p:when test="exists(//eb:table)">
				<p:viewport match="eb:front|eb:back">
					<p:variable name="part" select="local-name(*)"/>
					
					<p:viewport match="eb:list-of-tables">
						<p:variable name="title" select="*/@label"/>
						
						<ut:message>
							<p:with-option name="message" select="concat('Inserting a list of tables ', $title, ' into ', $part, ' part')"/>
						</ut:message>
						
						<p:sink/>
						
						<ut:xslt>
							<p:input port="source">
								<p:pipe step="current" port="source"/>
							</p:input>
							<p:with-option name="href" select="resolve-uri('generate-list-of-tables.xsl', $lib-base-uri)" />
							<p:with-param name="title" select="$title" />
							<p:with-param name="part" select="$part" />
							<p:with-param name="position" select="p:iteration-position()" />
						</ut:xslt>
					</p:viewport>
				</p:viewport>
			</p:when>
			<p:otherwise>
				<ut:message message="No tables.."/>
			</p:otherwise>
		</p:choose>
		
	</p:declare-step>
	
<!--+========================================================+
	| Step insert-table-of-contents
	|
	| Replace table-of-contents marker with real table of contents.
	+-->
	
	<p:declare-step type="eb:insert-table-of-contents" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>

		<p:variable name="lib-base-uri" select="base-uri(.)"><p:inline><x/></p:inline></p:variable>

		<p:viewport match="eb:front|eb:back">
			<p:variable name="part" select="local-name(*)"/>
			
			<p:viewport match="eb:table-of-contents">
				<p:variable name="title" select="*/@label"/>
				
				<ut:message>
					<p:with-option name="message" select="concat('Inserting table of contents ', $title, ' into ', $part, ' part')"/>
				</ut:message>
				
				<p:sink/>
				
				<ut:xslt>
					<p:input port="source">
						<p:pipe step="current" port="source"/>
					</p:input>
					<p:with-option name="href" select="resolve-uri('generate-table-of-contents.xsl', $lib-base-uri)" />
					<p:with-param name="title" select="$title" />
					<p:with-param name="part" select="$part" />
					<p:with-param name="position" select="p:iteration-position()" />
				</ut:xslt>
			</p:viewport>
		</p:viewport>
		
	</p:declare-step>
	
<!--+========================================================+
	| Step paginate
	|
	| Apply pagination if requested.
	+-->
	
	<p:declare-step type="eb:paginate">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>

		<!-- merge parameters sequence to single doc for use in variable -->
		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="lib-base-uri" select="base-uri(.)"><p:inline><x/></p:inline></p:variable>
			<p:variable name="log-dir" select="//c:param[@name = 'log-dir']/@value"><p:pipe step="params" port="parameters"/></p:variable>
			
			<p:viewport match="eb:part">
				<p:variable name="type" select="*/@type"/>
				<p:variable name="href" select="*/@href"/>
				
				<p:viewport match="eb:part/*">
					<ut:message>
						<p:with-option name="message" select="concat('Applying pagination to ', $type, ' ', $href)"/>
					</ut:message>
					
					<ut:xslt>
						<p:with-option name="href" select="resolve-uri('paginate.xsl', $lib-base-uri)" />
					</ut:xslt>
					
					<ut:log>
						<p:with-option name="href" select="resolve-uri('paginated-part.xml', $log-dir)"/>
					</ut:log>
				</p:viewport>
			</p:viewport>
			
			<ut:message message="Assigning page-numbers"/>
			
			<ut:xslt>
				<p:with-option name="href" select="resolve-uri('assign-page-numbers.xsl', $lib-base-uri)" />
			</ut:xslt>
		</p:group>
		
	</p:declare-step>
	
<!--+========================================================+
	| Step resolve-links
	|
	| Resolve links aka page refs and cross links.
	+-->
	
	<p:declare-step type="eb:resolve-links">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>

		<p:variable name="lib-base-uri" select="base-uri(.)"><p:inline><x/></p:inline></p:variable>

		<ut:message message="Resolving links"/>
		
		<ut:xslt>
			<p:with-option name="href" select="resolve-uri('resolve-links.xsl', $lib-base-uri)" />
		</ut:xslt>
		
	</p:declare-step>
	
<!--+========================================================+
	| Step store
	|
	| Write final output.
	+-->
	
	<p:declare-step type="eb:store" name="current">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>

		<out:apply-output-adapter/>
	</p:declare-step>
	
<!--+========================================================+
	| Main
	+-->
	
	<!-- externalize globals -->
	<p:in-scope-names name="vars"/>
	
	<p:identity>
		<p:input port="source">
			<p:pipe step="main" port="source"/>
		</p:input>
	</p:identity>
			
	<ut:message>
		<p:with-option name="message" select="$app-name"/>
		<!-- include in-scope vars (which includes options as well), and params -->
		<p:input port="parameters">
			<p:pipe step="vars" port="result"/>
			<p:pipe step="main" port="parameters"/>
		</p:input>
	</ut:message>
	
	<eb:apply-template>
		<!-- include in-scope vars (which includes options as well), and params -->
		<p:input port="parameters">
			<p:pipe step="vars" port="result"/>
			<p:pipe step="main" port="parameters"/>
		</p:input>
	</eb:apply-template>
	
	<eb:process-ebook>
		<!-- include in-scope vars (which includes options as well), and params -->
		<p:input port="parameters">
			<p:pipe step="main" port="parameters"/>
			<p:pipe step="vars" port="result"/>
		</p:input>
	</eb:process-ebook>
		
	<p:sink/>
	
</p:declare-step>
