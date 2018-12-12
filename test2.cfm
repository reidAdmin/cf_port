<cffunction
    name="GetPageForms"
    access="public"
    returntype="array"
    output="false"
    hint="Takes a URL or page content and parsed the forms and form fields.">

	<!--- Define arguments. --->
    <cfargument
        name="HTML"
        type="string"
        required="true"
        hint="Page HTML or URL to page with the target HTML."
        />

	<!--- Define the local scope. --->
    <cfset var LOCAL = StructNew() />


    <!---
        Check to see if we are dealing with page content or
        a target url. For our purposes, if the text is a valid
        URL then we are going to assume that this is NOT the
        page data.
    --->
    <cfif IsValid( "url", ARGUMENTS.HTML )>

	        <!--- We are going to grab the URL file content. --->
        <cfhttp
            url="#ARGUMENTS.HTML#"
            method="get"
            useragent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/601.4.4 (KHTML, like Gecko) Version/9.0.3 Safari/601.4.4"
            resolveurl="true"
            result="LOCAL.HttpGet">


            <!---
                Pass in the referrer. This is just to help
                ensure that we are served the proper page data.
            --->
            <cfhttpparam
                type="CGI"
                name="referer"
                value="#GetDirectoryFromPath( ARGUMENTS.HTML )#"
                />

        </cfhttp>

		        <!---
            Store the returned file content back into our
            HTML argument so that we can treat it uniformly
            going forward.
        --->
        <cfset ARGUMENTS.HTML = LOCAL.HttpGet.FileContent />

    </cfif>

	    <!---
        ASSERT: At this point, whether we were given page
        content or a URL, we now have page HTML in our
        HTML argument. The HTML may not be valid (200 OK)
        response, or it might.
    --->


    <!---
        Create our return array to hold the form data.
        Each form found on the page will be a different
        index in this array.
    --->
    <cfset LOCAL.Forms = ArrayNew( 1 ) />

    <!---
        Create a pattern to search for the forms. This
        will start with the open form tag, then grab all
        the content before the close form tag, and then the
        close form tag.
    --->
    <cfset LOCAL.FormPattern = CreateObject(
        "java",
        "java.util.regex.Pattern"
        ).Compile(
            <!--- Open form tag. --->
            "(?i)(<form" &
            <!--- Form tag attributes. --->
            "(?:\s+\w+(?:\s*=\s*(?:""[^""]*""|[^\s>]*))?)*" &
            <!--- Close bracket of form tag. --->
            "[^>]*>)" &

			            <!---
                Form content. Here, we are doing a non greedy
                search for any chacacter until we match the
                close form tag.
            --->
            "([\w\W]*?)" &
            <!--- Close form tag. --->
            "</form[^>]*>"
            )
        />

		    <!--- Get the matcher for our form pattern. --->
    <cfset LOCAL.FormMatcher = LOCAL.FormPattern.Matcher(
        ARGUMENTS.HTML
        ) />


    <!---
        Keep looping over the form matcher while there
        are forms to parse in the target HTML.
    --->
    <cfloop condition="LOCAL.FormMatcher.Find()">



        <!---
            Create a structure to store this form instance. We
            are going to capture the form tag information, the
            raw form content and the form inputs.
        --->
        <cfset LOCAL.Form = StructNew() />

		        <!--- Create an array to capture the inputs. --->
        <cfset LOCAL.Form.Fields = ArrayNew( 1 ) />

		        <!--- Parse the form tag data. --->
        <cfset LOCAL.Form.Tag = ParseHTMLTag(
            LOCAL.FormMatcher.Group( 1 )
            ) />

			        <!--- Store the raw content. --->
        <cfset LOCAL.Form.HTML = LOCAL.FormMatcher.Group() />


 <!---
            Now, let's find the inputs. These are not just the
            INPUT tags, but also textareas and select fields.
            Create a pattern to find the field tags. Now, the
            selects and the textareas are not going to have
            such nice name and value attributes (like hidden
            form fields do), but to keep this simple, I am just
            going to grab the open tags for these form fields.
        --->
        <cfset LOCAL.FieldPattern = CreateObject(
            "java",
            "java.util.regex.Pattern"
            ).Compile(
                <!--- The tag name. --->
                "(?i)<(input|select|textarea)" &
                <!--- The tag attributes. --->
                "(?:\s+\w+(?:\s*=\s*(?:""[^""]*""|[^\s>]*))?)*" &

                <!--- The close tag. --->
                "[^>]*>"
                )
            />

			        <!--- Get the pattern matcher for the form fields. --->
        <cfset LOCAL.FieldMatcher = LOCAL.FieldPattern.Matcher(
            LOCAL.Form.HTML
            ) />


        <!---
            Keep looping over the field matcher while there
            are inputs left to parse in the target form.
        --->
        <cfloop condition="LOCAL.FieldMatcher.Find()">


            <!---
                Add this input to the array. As we add
                this field entry, parse the HTML tag into a
                ColdFusion structure.
            --->
            <cfset ArrayAppend(
                LOCAL.Form.Fields,
                ParseHTMLTag(
                    LOCAL.FieldMatcher.Group( 0 )
                    )
                ) />

        </cfloop>

		        <!---
            Now that we have captured all the information
            about this form that we can, add this form to
            the results array.
        --->
        <cfset ArrayAppend( LOCAL.Forms, LOCAL.Form ) />

    </cfloop>


    <!--- Return the form data. --->
    <cfreturn LOCAL.Forms />
</cffunction>





