note
	description: "Summary description for {CONFIGURATION_SHARED}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CONFIGURATION_SHARED

feature {NONE} -- Initialization

	configurations:STRING_TABLE[detachable ANY]
		once
			create Result.make_caseless (2)
		end

	configuratons_boolean_value(a_key:READABLE_STRING_GENERAL):BOOLEAN
		do
			Result := attached {READABLE_STRING_GENERAL} configurations.at (a_key) as la_verbose and then
					(la_verbose.is_case_insensitive_equal ("true") or la_verbose.is_case_insensitive_equal ("yes"))
		end

	is_verbose:BOOLEAN
		do
			Result :=configuratons_boolean_value("verbose")
		end

end
