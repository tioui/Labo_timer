note
	description: "Summary description for {GUESTS_REPOSITORY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GUESTS_REPOSITORY

inherit
	REPOSITORY
		rename
			make as make_repository
		end
	DATABASE_TABLE_NAMES

create
	make

feature {NONE} -- Initialization

	make(a_database_access:DATABASE_ACCESS)
		do
			make_repository(a_database_access, <<"users_id", "laboratories_id">>)
			create filler.make (selection, prototype.twin)
			selection.set_action (filler)
		end

feature -- Access


feature {CONTROLLER} -- Implementation

	prototype:USERS_LABORATORIES
			-- <Precursor>
		once
			create Result.make (1, 1)
		end

feature {NONE} -- Implementation

	table_name:STRING_32
			-- The name of the database table used by `Current'
		once
			Result := users_laboratories_table_name
		end


end
