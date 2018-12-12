<cfif(isDefined("arrForms"))>
<!---
    Let's get the form off of the Flickr.com homagepage.
    This should be the search form. We could do the CFHttp
    ourselves, but the GetPageForms() function will do this
    for us if we pass in a URL (instead of page content).
--->
<cfset arrForms = GetPageForms("http://www.flickr.com/") />


<!--- Dump out the Flickr.com form data. --->
<cfdump var="#arrForms#" label="Flickr.com Form Data"/>

</cfif>