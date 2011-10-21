<p:library xmlns:p="http://www.w3.org/ns/xproc"
	   xmlns:cx="http://xmlcalabash.com/ns/extensions"
	   xmlns:cos="http://xmlcalabash.com/ns/extensions/osutils"
	   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	   version="1.0">

<!-- see http://exproc.org/proposed/steps/os.html for documentation -->
		   
	<!-- ============================================================ -->

	<p:declare-step type="cos:info">
		<p:output port="result"/>
	</p:declare-step>
	 
	<!-- ============================================================ -->

	<p:declare-step type="cos:cwd">
		<p:output port="result" sequence="true"/>
	</p:declare-step>
	 
	<!-- ============================================================ -->

	<p:declare-step type="cos:env">
		<p:output port="result"/>
	</p:declare-step>

</p:library>
