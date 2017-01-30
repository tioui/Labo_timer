note
	description: "Summary description for {SESSION_MANAGER_SHARED}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SESSION_MANAGER_SHARED

feature {NONE} -- Implementation

	session_manager:WSF_SESSION_MANAGER
		once
			create {WSF_FS_SESSION_MANAGER}Result.make_with_folder ("./session_folder")
		end
end
