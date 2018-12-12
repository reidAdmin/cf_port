<cfparam name="postTextBox" default="" type="String">

<cfoutput>
		<form action="readTest.cfm" method="get">

			<input name="name" type="htmlcodeformat()" value="$(this).formName">

		</form>

</cfoutput>

<cfdocument format="pdf">



	<cfpdfform source="testForm4.pdf" action="populate">
		<cfpdfformparam name="formName" value="$(this).formName" />
	</cfpdfform>

</cfdocument>