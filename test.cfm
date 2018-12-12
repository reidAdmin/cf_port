<cffunction
    name="ParseHTMLTag"
    access="public"
    returntype="struct"
    output="false"
    hint="Parses the given HTML tag into a ColdFusion struct.">

	<!--- Define arguments. --->
    <cfargument
        name="HTML"
        type="string"
        required="true"
        hint="The raw HTML for the tag."
        />

	 <!--- Define the local scope. --->
     <cfset var LOCAL = StructNew() />

	 <!--- Create a structure for the taget tag data. --->
     <cfset LOCAL.Tag = StructNew() />

	<!--- Store the raw HTML into the tag. --->
    <cfset LOCAL.Tag.HTML = ARGUMENTS.HTML />

	<!--- Set a default name. --->
    <cfset LOCAL.Tag.Name = "" />

	 <!---
        Create an structure for the attributes. Each
        attribute will be stored by it's name.
    --->
    <cfset LOCAL.Tag.Attributes = StructNew() />

	 <!---
        Create a pattern to find the tag name. While it
        might seem overkill to create a pattern just to
        find the name, I find it easier than dealing with
        token / list delimiters.
    --->
    <cfset LOCAL.NamePattern = CreateObject(
        "java",
        "java.util.regex.Pattern"
        ).Compile(
            "^<(\w+)"
            )
        />

	<!--- Get the matcher for this pattern. --->
    <cfset LOCAL.NameMatcher = LOCAL.NamePattern.Matcher(
        ARGUMENTS.HTML
        ) />

	    <!---
        Check to see if we found the tag. We know there
        can only be ONE tag name, so using an IF statement
        rather than a conditional loop will help save us
        processing time.
    --->
    <cfif LOCAL.NameMatcher.Find()>


        <!--- Store the tag name in all upper case. --->
        <cfset LOCAL.Tag.Name = UCase(
            LOCAL.NameMatcher.Group( 1 )
            ) />

    </cfif>

	    <!---
        Now that we have a tag name, let's find the
        attributes of the tag. Remember, attributes may
        or may not have quotes around their values. Also,
        some attributes (while not XHTML compliant) might
        not even have a value associated with it (ex.
        disabled, readonly).
    --->
    <cfset LOCAL.AttributePattern = CreateObject(
        "java",
        "java.util.regex.Pattern"
        ).Compile(
            "\s+(\w+)(?:\s*=\s*(""[^""]*""|[^\s>]*))?"
            )
        />

		    <!--- Get the matcher for the attribute pattern. --->
    <cfset LOCAL.AttributeMatcher = LOCAL.AttributePattern.Matcher(
        ARGUMENTS.HTML
        ) />


    <!---
        Keep looping over the attributes while we
        have more to match.
    --->
    <cfloop condition="LOCAL.AttributeMatcher.Find()">


        <!--- Grab the attribute name. --->
        <cfset LOCAL.Name = LOCAL.AttributeMatcher.Group( 1 ) />

		        <!---
            Create an entry for the attribute in our attributes
            structure. By default, just set it the empty string.
            For attributes that do not have a name, we are just
            going to have to store this empty string.
        --->
        <cfset LOCAL.Tag.Attributes[ LOCAL.Name ] = "" />


        <!---
            Get the attribute value. Save this into a scoped
            variable because this might return a NULL value
            (if the group in our name-value pattern failed
            to match).
        --->
        <cfset LOCAL.Value = LOCAL.AttributeMatcher.Group( 2 ) />


        <!---
            Check to see if we still have the value. If the
            group failed to match then the above would have
            returned NULL and destroyed our variable.
        --->
        <cfif StructKeyExists( LOCAL, "Value" )>

		            <!---
                We found the attribute. Now, just remove any
                leading or trailing quotes. This way, our values
                will be consistent if the tag used quoted or
                non-quoted attributes.
            --->
            <cfset LOCAL.Value = LOCAL.Value.ReplaceAll(
                "^""|""$",
                ""
                ) />

				            <!---
                Store the value into the attribute entry back
                into our attributes structure (overwriting the
                default empty string).
            --->
            <cfset LOCAL.Tag.Attributes[ LOCAL.Name ] = LOCAL.Value />

        </cfif>

		    </cfloop>


    <!--- Return the tag. --->
    <cfreturn LOCAL.Tag />
</cffunction>
