note
	description: "Summary description for {USER_REPOSITORY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	USER_REPOSITORY

inherit
	REPOSITORY
		redefine
			make
		end

create {REPOSITORIES_SHARED}
	make

feature {NONE} -- Initialization

	make(l_database_access:DATABASE_ACCESS)
			-- <Precursor>
		do
			Precursor {REPOSITORY}(l_database_access)
			create filler.make (selection, prototype.twin)
			selection.set_action (filler)
		end

feature {CONTROLLER} -- Implementation

	prototype:USER
			-- <Precursor>
		once
			create Result
		end

feature {NONE} -- Implementation

	table_name:STRING
			-- The name of the database table used by `Current'
		once
			Result := "administrateur"
		end

end
