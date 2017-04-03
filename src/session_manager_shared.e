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

inherit
	CONFIGURATION_SHARED

feature {NONE} -- Implementation

	administrator_session_manager:WSF_SESSION_MANAGER
			-- The session used by administration pages
		local
			l_folder:READABLE_STRING_GENERAL
		once
			if attached {READABLE_STRING_GENERAL} configurations.at ("session_folder") as la_session_folder then
				l_folder := la_session_folder
			else
				l_folder := "./session_folder"
			end
			create {WSF_FS_SESSION_MANAGER}Result.make_with_folder (l_folder + "/administrators/")
		end

	user_session_manager:WSF_SESSION_MANAGER
			-- The session used by guest pages
		local
			l_folder:READABLE_STRING_GENERAL
		once
			if attached {READABLE_STRING_GENERAL} configurations.at ("session_folder") as la_session_folder then
				l_folder := la_session_folder
			else
				l_folder := "./session_folder"
			end
			create {WSF_FS_SESSION_MANAGER}Result.make_with_folder (l_folder + "/guests/")
		end
end
