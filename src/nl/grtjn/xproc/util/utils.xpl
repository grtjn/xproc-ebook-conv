<?xml version="1.0"?>
<!--+
	| Utils - various useful steps
	|
	| Declares:
	| - delete			Delete files and directories (recursively).
	| - empty			Short-cut for p:indentity returning p:empty.
	| - expand-dirs		Recurse on directory-list input.
	| - insert-doc		Uses xquery and xinclude to dynamically insert doc within root element.
	| - log				Write xml for debugging purposes based on debug parameter.
	| - message			Show message on console based on verbose parameter.
	| - parameters		Short-cut for p:parameters which passes through input, and with primary parameters input.
	| - sys-info		Java System Properties returned as info elements. (external)
	| - throw-error		Throw error based on string message (instead of input source).
	| - wrap			Wraps string value in a custom element.
	| - xquery			Accepts both unescaped query and external file ref as query source.
	| - xslt			Accepts external file ref as stylesheet source.
	| - zip				Accepts directory-list as manifest source.
	+-->
<p:library version="1.0"

	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	
	xmlns:cx="http://xmlcalabash.com/ns/extensions"
	xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
	xmlns:ml="http://xmlcalabash.com/ns/extensions/marklogic"
	xmlns:cos="http://xmlcalabash.com/ns/extensions/osutils"
	
	xmlns:ut="http://grtjn.nl/ns/xproc/util"
	
	exclude-inline-prefixes="#all">
	
<!--+========================================================+
	| Imports
	+-->
	
	<!-- extension declarations provided for xmlcalabash -->
	<p:import href="../../../../com/xmlcalabash/extensions/library-1.0.xpl" />
	<p:import href="../../../../com/xmlcalabash/extensions/fileutils.xpl" />
	<p:import href="../../../../com/xmlcalabash/extensions/osutils.xpl" />

<!--+========================================================+
	| Step delete
	|
	| Delete files and directories (recursively).
	+-->
		
	<p:declare-step type="ut:delete" name="current">
		<p:input port="source" sequence="true" primary="true"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result" primary="true">
			<p:pipe step="current" port="source"/>
		</p:output>
		
		<p:option name="recursive" select="false()"/>
		<p:option name="href" required="true"/>
		<p:option name="fail-on-error" select="false()"/>
		
		<ut:parameters name="params"/>

		<p:try>
			<p:group>
				<p:variable name="log-dir" select="(//c:param[@name = 'log-dir']/@value, '.')[1]"><p:pipe step="params" port="parameters"/></p:variable>
				
				<cxf:info name="info">
					<p:with-option name="href" select="$href"/>
				</cxf:info>
		
				<ut:log>
					<p:with-option name="href" select="resolve-uri('info.xml', $log-dir)"/>
				</ut:log>
							
				<p:group>
					<p:variable name="is-dir" select="exists(/c:directory)"><p:pipe step="info" port="result"/></p:variable>
					
					<p:choose>
						<p:when test="string($is-dir) eq 'true'">
							<ut:message>
								<p:with-option name="message" select="concat('Deleting dir ', $href)"/>
							</ut:message>
							
							<p:directory-list>
								<p:with-option name="path" select="$href"/>
							</p:directory-list>
							
							<ut:log>
								<p:with-option name="href" select="resolve-uri('delete.xml', $log-dir)"/>
							</ut:log>
							
							<p:choose>
								<p:when test="string($recursive) eq 'true'">
									<p:viewport match="c:directory[not(*) and parent::*]">
										<p:variable name="path" select="resolve-uri(concat(/c:directory/@name, '/'), $href)"/>
										
										<ut:delete recursive="true">
											<p:with-option name="href" select="$path"/>
										</ut:delete>
										
										<!-- flush current c:directory -->
										<p:sink/>
										<ut:empty/>
									</p:viewport>
								</p:when>
								<p:otherwise>
									<p:identity/>
								</p:otherwise>
							</p:choose>
							
							<ut:log>
								<p:with-option name="href" select="resolve-uri('delete-recursed.xml', $log-dir)"/>
							</ut:log>
							
							<p:viewport match="c:file">
								<p:variable name="path" select="resolve-uri(/c:file/@name, $href)"/>
								
								<p:sink/>
								
								<cxf:delete>
									<p:with-option name="href" select="$path"/>
								</cxf:delete>
								
								<!-- flush current c:file -->
								<ut:empty/>
								
							</p:viewport>
							
							<p:viewport match="c:directory[not(*)]">
								<p:variable name="path" select="if (string-length(/c:directory/@path) > 0) then resolve-uri(/c:directory/@path, $href) else $href"/>
								
								<p:sink/>
								
								<cxf:delete>
									<p:with-option name="href" select="$path"/>
								</cxf:delete>
								
								<!-- flush current c:directory -->
								<ut:empty/>
							</p:viewport>
						</p:when>
						<p:otherwise>
							<ut:message>
								<p:with-option name="message" select="concat('Deleting file ', $href)"/>
							</ut:message>
							
							<p:sink/>
							
							<cxf:delete>
								<p:with-option name="href" select="$href"/>
							</cxf:delete>
							
							<!-- flush current input -->
							<ut:empty/>
						</p:otherwise>
					</p:choose>
				</p:group>
			</p:group>
			<p:catch>
				<p:choose>
					<p:when test="string($fail-on-error) eq 'true'">
						<ut:throw-error code="DELFAIL"><p:with-option name="message" select="concat('Failed to delete ', $href)"/></ut:throw-error>
					</p:when>
					<p:otherwise>
						<ut:empty/>
					</p:otherwise>
				</p:choose>
			</p:catch>
		</p:try>
		
		<p:sink/>
		
	</p:declare-step>

<!--+========================================================+
	| Step empty
	|
	| Short-cut for p:indentity returning p:empty.
	+-->
		
	<p:declare-step type="ut:empty" name="empty">
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>
		
		<p:identity>
			<p:input port="source">
				<p:empty/>
			</p:input>
		</p:identity>
	</p:declare-step>
						
<!--+========================================================+
	| Step expand-dirs
	|
	| Recurse on directory-list input.
	+-->
		
	<p:declare-step type="ut:expand-dirs" name="current">
		<p:input port="source" sequence="true" primary="true"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result" primary="true"/>
		
		<p:option name="recursive" select="true()"/>
		<p:option name="base-uri" select="''"/>

		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="log-dir" select="(//c:param[@name = 'log-dir']/@value, '.')[1]"><p:pipe step="params" port="parameters"/></p:variable>
			<p:variable name="base-uri_" select="if ($base-uri eq '') then base-uri(/*) else $base-uri"/>
		
			<p:viewport match="c:directory[not(*) and parent::*]">
				<p:variable name="path" select="concat(resolve-uri(/c:directory/@name, $base-uri_), '/')"/>
							
				<p:try>
					<p:group>
						<p:directory-list>
							<p:with-option name="path" select="$path"/>
						</p:directory-list>
						
						<ut:log>
							<p:with-option name="href" select="resolve-uri('dir-list.xml', $log-dir)"/>
						</ut:log>
						
						<!-- recursive -->
						<p:choose>
							<p:when test="string($recursive) eq 'true'">
								<ut:expand-dirs>
									<p:with-option name="recursive" select="$recursive" />
									<p:with-option name="base-uri" select="$path" />
								</ut:expand-dirs>
							</p:when>
							<p:otherwise>
								<p:identity/>
							</p:otherwise>
						</p:choose>
					</p:group>
					
					<p:catch>
						<ut:throw-error code="EXPFAIL"><p:with-option name="message" select="concat('Failed to read ', $path)"/></ut:throw-error>
					</p:catch>
				</p:try>
			</p:viewport>
		</p:group>
	</p:declare-step>

<!--+========================================================+
	| Step insert-doc
	|
	| Uses xquery and xinclude to dynamically insert doc within root element.
	+-->
		
	<p:declare-step type="ut:insert-doc" name="insert-doc">
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>
		
		<p:option name="xref" required="true" />
		
		<!-- add xinclude statement -->
		<ut:xquery>
			<p:input port="query">
				<p:inline>
					<c:query>
						declare variable $xref as xs:string external;
						element {node-name(*)} {
							*/@*,
							*/node(),
							if (starts-with($xref, 'http://')) then
								<xi:include href="{$xref}" xmlns:xi="http://www.w3.org/2001/XInclude"/>
							else
								<xi:include href="{resolve-uri($xref, base-uri(*))}" xmlns:xi="http://www.w3.org/2001/XInclude"/>
						}
					</c:query>
				</p:inline>
			</p:input>
			<p:with-param name="xref" select="$xref"/>
		</ut:xquery>
		
		<!-- exec xinclude statement -->
		<p:xinclude />
					
	</p:declare-step>
	
<!--+========================================================+
	| Step log
	|
	| Write debug xml based on debug parameter.
	+-->

	<p:declare-step type="ut:log" name="current">
		<p:input port="source" sequence="true"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result" sequence="true">
			<!-- pipe input straight through to output -->
			<p:pipe step="current" port="source"/>
		</p:output>
		
		<p:option name="href" required="true"/>
		<p:option name="method" select="'xml'"/>
		<p:option name="indent" select="'true'"/>
		
		<p:wrap-sequence wrapper="sequence"/>
		
		<!-- clean up parameters port input to stop p:variable from complaining -->
		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="debug" select="(//c:param[@name='debug']/@value, false())[1]"><p:pipe step="params" port="parameters"/></p:variable>
			
			<p:choose>
				<p:when test="string($debug) eq 'true'">
					<ut:message>
						<p:with-option name="message" select="concat('Logging to ', $href)" />
					</ut:message>

					<p:store>
						<p:with-option name="href" select="$href"/>
						<p:with-option name="method" select="$method"/>
						<p:with-option name="indent" select="$indent"/>
					</p:store>
				</p:when>
				<p:otherwise>
					<p:sink/>
				</p:otherwise>
			</p:choose>
		</p:group>
	</p:declare-step>

<!--+========================================================+
	| Step message
	|
	| Show message on console based on verbose parameter.
	+-->

	<p:declare-step type="ut:message" name="current">
		<p:input port="source" sequence="true"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result" sequence="true">
			<!-- pipe input straight through to output -->
			<p:pipe step="current" port="source"/>
		</p:output>
		
		<p:option name="message" required="true"/>
		
		<!-- clean up parameters port input to stop p:variable from complaining -->
		<ut:parameters name="params"/>
		
		<!-- cx:message doesn't take a sequence.. -->
		<p:wrap-sequence wrapper="x"/>
		
		<p:group>
			<p:variable name="verbose" select="(//c:param[@name='verbose']/@value, false())[1]"><p:pipe step="params" port="parameters"/></p:variable>
			
			<p:choose>
				<p:when test="string($verbose) eq 'true'">
					<cx:message>
						<p:with-option name="message" select="$message"/>
					</cx:message>
				</p:when>
				<p:otherwise>
					<p:identity/>
				</p:otherwise>
			</p:choose>
		</p:group>
		
		<p:sink/>
	</p:declare-step>

<!--+========================================================+
	| Step parameters
	|
	| Short-cut for p:parameters which passes through input, and with primary parameters input.
	+-->
	
	<p:declare-step type="ut:parameters" name="current">
		<p:input port="source" sequence="true" primary="true"/>
		<p:input port="in-parameters" kind="parameter" sequence="true" primary="true"/>
		<p:output port="result" sequence="true" primary="true">
			<!-- pipe input straight through to output -->
			<p:pipe step="current" port="source"/>
		</p:output>
		
		<!-- extra output port for cleaned params -->
		<p:output port="parameters" sequence="false" primary="false">
			<p:pipe step="params" port="result"/>
		</p:output>
		
		<p:parameters name="params">
			<p:input port="parameters">
				<p:pipe step="current" port="in-parameters"/>
			</p:input>
		</p:parameters>
	</p:declare-step>
	
<!--+========================================================+
	| Step sys-info
	|
	| Java System Properties returned as info elements. (external)
	+-->
	
	<p:declare-step type="ut:sys-info">
		<p:output port="result"/>
	</p:declare-step>
	
<!--+========================================================+
	| Step throw-error
	|
	| Throw error based on string message (instead of input source).
	+-->
	
   <p:declare-step type="ut:throw-error">
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result" primary="true">
			<p:pipe step="error" port="result" />
		</p:output>
		
		<p:option name="code" required="true"/>
		<p:option name="message" required="true"/>
		
		<!-- wrap message in a tag -->
		<ut:wrap wrapper="message">
			<p:with-option name="value" select="$message"/>
		</ut:wrap>
			
		<p:error name="error">
			<p:with-option name="code" select="$code"/>
		</p:error>
	</p:declare-step>
	
<!--+========================================================+
	| Step wrap
	|
	| Wraps string value in a custom element.
	+-->
		
    <p:declare-step type="ut:wrap">
		<p:input port="source" primary="true">
			<p:empty/>
		</p:input>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result" primary="true"/>
		
		<p:option name="wrapper" required="true"/>
		<p:option name="value" select="''"/>
		
		<!-- wrap message in a tag -->
		<ut:xquery>
			<p:input port="query">
				<p:inline>
					<c:query>
						declare variable $wrapper as xs:string external;
						declare variable $value as xs:string external;
						element {$wrapper} { if ($value) then $value else / }
					</c:query>
				</p:inline>
			</p:input>
			<p:with-param name="wrapper" select="$wrapper"/>
			<p:with-param name="value" select="$value"/>
		</ut:xquery>
	</p:declare-step>
	
<!--+========================================================+
	| Step xquery
	|
	| Accepts both unescaped query and external file ref as query source.
	| Note: make sure to pass in an absolute path.
	+-->
	
    <p:declare-step type="ut:xquery" name="current">
		<p:input port="source" sequence="true" primary="true"/>
		<p:input port="query" />
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result" primary="true"/>
		
		<p:option name="href" select="''"/>
		
		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="log-dir" select="(//c:param[@name = 'log-dir']/@value, '.')[1]"><p:pipe step="params" port="parameters"/></p:variable>
			<p:variable name="query-id" select="string-length(.)"><p:pipe step="current" port="query"/></p:variable>
			
			<ut:log>
				<p:with-option name="href" select="resolve-uri(concat('xquery-params-', $query-id, '.xml'), $log-dir)"/>
				<p:input port="source">
					<p:pipe step="params" port="parameters"/>
				</p:input>
			</ut:log>

			<p:choose>
				<p:when test="string-length($href) > 0">
					<p:load name="load-file">
						<p:with-option name="href" select="$href"/>
					</p:load>
					
					<p:xquery>
						<p:input port="query">
							<p:pipe port="result" step="load-file"/>
						</p:input>
						<p:input port="source">
							<p:pipe port="source" step="current"/>
						</p:input>
					</p:xquery>
				</p:when>
				<p:otherwise>
					<!-- escape xml within the query -->
					<p:escape-markup name="escaped-query">
						<p:input port="source">
							<p:pipe port="query" step="current"/>
						</p:input>
					</p:escape-markup>
					
					<ut:log>
						<p:with-option name="href" select="resolve-uri(concat('escaped-xquery-', $query-id, '.xml'), $log-dir)"/>
					</ut:log>
						
					<!-- execute query -->
					<p:xquery>
						<p:input port="query">
							<p:pipe port="result" step="escaped-query"/>
						</p:input>
						<p:input port="source">
							<p:pipe port="source" step="current"/>
						</p:input>
					</p:xquery>
					
					<ut:log>
						<p:with-option name="href" select="resolve-uri(concat('query-result-', $query-id, '.xml'), $log-dir)"/>
					</ut:log>
				</p:otherwise>
			</p:choose>
		</p:group>
	</p:declare-step>
	
<!--+========================================================+
	| Step xslt
	|
	| Accepts external file ref as stylesheet source.
	| Note: make sure to pass in an absolute path.
	+-->
	
    <p:declare-step type="ut:xslt" name="current">
		<p:input port="source" sequence="true" primary="true"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result" primary="true"/>
		<p:output port="secondary" sequence="true">
			<p:pipe step="xslt" port="secondary"/>
		</p:output>
		
		<p:option name="href" required="true"/>
		
		<p:load name="load-file">
			<p:with-option name="href" select="$href"/>
		</p:load>
		
		<p:xslt name="xslt">
			<p:input port="stylesheet">
				<p:pipe port="result" step="load-file"/>
			</p:input>
			<p:input port="source">
				<p:pipe port="source" step="current"/>
			</p:input>
		</p:xslt>
	</p:declare-step>
	
<!--+========================================================+
	| Step zip
	|
	| Accepts directory-list as manifest source.
	+-->

	<p:declare-step type="ut:zip" name="current">
		<p:input port="source" primary="true"/>
		<p:input port="parameters" kind="parameter"/>
		
		<p:option name="command" select="'update'"/>
		<p:option name="href" required="true" cx:type="xs:anyURI"/>
		<p:option name="recursive" select="true()"/>
		
		<ut:parameters name="params"/>
		
		<p:group>
			<p:variable name="log-dir" select="(//c:param[@name = 'log-dir']/@value, '.')[1]"><p:pipe step="params" port="parameters"/></p:variable>
		
			<ut:log>
				<p:with-option name="href" select="resolve-uri('zip-input.xml', $log-dir)"/>
			</ut:log>
			
			<ut:expand-dirs>
				<p:with-option name="recursive" select="$recursive"/>
			</ut:expand-dirs>
			
			<ut:log>
				<p:with-option name="href" select="resolve-uri('expanded-dir-list.xml', $log-dir)"/>
			</ut:log>
			
			<!-- convert dir listings into zip manifest -->
			<ut:xquery name="zip-manifest">
				<p:input port="query">
					<p:inline>
						<c:query>
							declare namespace c="http://www.w3.org/ns/xproc-step";
							<c:zip-manifest>{
								for $file in //c:file
								let $name := string-join($file/ancestor-or-self::*/@name, '/')
								let $path := resolve-uri($file/@name, base-uri($file))
								return
									<c:entry name="{$name}" href="{$path}" compression-method="{if ($file/@name eq 'mimetype') then 'stored' else 'deflated'}" compression-level="default"/>
							}</c:zip-manifest>
						</c:query>
					</p:inline>
				</p:input>
			</ut:xquery>
			
			<ut:log>
				<p:with-option name="href" select="resolve-uri('zip-manifest.xml', $log-dir)"/>
			</ut:log>
			
			<p:sink/>
			<ut:empty/>
			
			<cx:zip>
				<p:with-option name="command" select="$command"/>
				<p:input port="manifest">
					<p:pipe step="zip-manifest" port="result"/>
				</p:input>
				<p:with-option name="href" select="$href"/>
			</cx:zip>
		</p:group>
		
		<p:sink/>
			
	</p:declare-step>
	
 </p:library>