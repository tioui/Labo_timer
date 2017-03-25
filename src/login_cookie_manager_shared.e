note
	description: "Summary description for {LOGIN_COOKIE_MANAGER_SHARED}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	LOGIN_COOKIE_MANAGER_SHARED

inherit
	SESSION_MANAGER_SHARED
	REPOSITORIES_SHARED

feature {NONE} -- Implementation

	login_cookie_manager:LOGIN_COOKIE_MANAGER
			-- The cookie manager that manage login
		once
			create Result.make (session_manager, administrators_repository)
		end

end
