note
	description: "Summary description for {REPOSITORIES_SHARED}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	REPOSITORIES_SHARED

inherit
	DATABASE_ACCESS_SHARED

feature {NONE} -- Implementation

	user_repository:USER_REPOSITORY
			-- The {REPOSITORY} used to create {USER}
		once
			create Result.make (database_access)
		end

end
