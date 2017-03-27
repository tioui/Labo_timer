note
	description: "A view model used to connect {USER} to {LABORATORY}."
	author: "Louis Marchand"
	date: "Sun, 26 Mar 2017 18:59:34 +0000"
	revision: "0.1"

class
	GUEST_VIEW_MODEL

inherit
	ANY
		redefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
			-- <Precursor>
		do
			user_name := ""
			password := ""
		end

feature -- Access

	user_name:READABLE_STRING_GENERAL
			-- The user_name of the {USER} trying to connect

	password:READABLE_STRING_GENERAL
			-- The password of the {LABORATORY}
end
