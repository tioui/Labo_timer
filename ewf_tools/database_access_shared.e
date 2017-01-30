note
	description: "Used to share the {DATABASE_ACCESS} singleton."
	author: "Louis Marchand"
	date: "Sat, 28 Jan 2017 01:39:28 +0000"
	revision: "1.0"

deferred class
	DATABASE_ACCESS_SHARED

feature {NONE} -- Implementation

	database_access:DATABASE_ACCESS
			-- The database session manager
		once
			create Result
		end

end
