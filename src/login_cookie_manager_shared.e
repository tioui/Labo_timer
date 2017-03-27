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

	administrator_cookie_manager:LOGIN_COOKIE_MANAGER
			-- The cookie manager that manage aministrator login
		once
			create Result.make (administrator_session_manager, administrators_repository)
		end

	user_cookie_manager:LOGIN_COOKIE_MANAGER
			-- The cookie manager that manage user login
		once
			create Result.make (user_session_manager, users_repository)
		end

end
