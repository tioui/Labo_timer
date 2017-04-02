note
	description: "[
				Every class that have to used the login cookie functionnality
				(for exemple, connect, disconnect or validate the connected user)
				must inherit from this class.
			]"
	author: "Louis Marchand"
	date: "Sun, 02 Apr 2017 21:53:15 +0000"
	revision: "0.1"

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
