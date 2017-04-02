note
	description: "[
				Every class wanting use system wide configuration must inherit
				from this class.
			]"
	author: "Louis Marchand"
	date: "Sun, 26 Mar 2017 18:59:34 +0000"
	revision: "0.1"

class
	CONFIGURATION_SHARED

feature {NONE} -- Initialization

	configurations:STRING_TABLE[detachable ANY]
			-- Every configurations of the system
		once
			create Result.make_caseless (2)
		end

	configuratons_boolean_value(a_key:READABLE_STRING_GENERAL):BOOLEAN
			-- Get a {BOOLEAN} configuration value
		do
			Result := attached {READABLE_STRING_GENERAL} configurations.at (a_key) as la_verbose and then
					(la_verbose.is_case_insensitive_equal ("true") or la_verbose.is_case_insensitive_equal ("yes"))
		end

	is_verbose:BOOLEAN
			-- Is the system have to be verbose when warning or error happen
		do
			Result :=configuratons_boolean_value("verbose")
		end

end
