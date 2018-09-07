note
	description: "Summary description for {LABO_TIMER_CONTROLLER_SUFFIX}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	LABO_TIMER_CONTROLLER_SUFFIX

inherit
	LOGIN_COOKIE_MANAGER_SHARED
		redefine
			default_create
		end
	VIEWS_SHARED
		redefine
			default_create
		end


feature {NONE} -- Initialization

	default_create
			-- <Precursor>
		do
			if attached {STRING_8} configurations.at ("url_suffix") as la_url_suffix then
				set_script_url_suffix (la_url_suffix)
			end
		end

feature -- Access

	set_script_url_suffix(a_suffix:STRING_8)
			-- Assign `script_url_suffix' with the value of `a_sufix'
		deferred
		end

end
