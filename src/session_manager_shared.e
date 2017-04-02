note
	description: "[
				Every {CONTROLLER} wanting to use session variable must
				inherit from this class
			]"
	author: "Louis Marchand"
	date: "Sun, 26 Mar 2017 18:59:34 +0000"
	revision: "0.1"

deferred class
	SESSION_MANAGER_SHARED

feature {NONE} -- Implementation

	administrator_session_manager:WSF_SESSION_MANAGER
			-- The session used by administration pages
		once
			create {WSF_FS_SESSION_MANAGER}Result.make_with_folder ("./session_folder/administrators/")
		end

	user_session_manager:WSF_SESSION_MANAGER
			-- The session used by guest pages
		once
			create {WSF_FS_SESSION_MANAGER}Result.make_with_folder ("./session_folder/guests/")
		end
end
