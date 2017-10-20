note
	description: "Repository used to manage {INTERVENTION} database."
	author: "Louis Marchand"
	date: "Mon, 27 Mar 2017 00:26:54 +0000"
	revision: "0.1"

class
	INTERVENTION_REPOSITORY

inherit
	MODEL_REPOSITORY
		redefine
			make
		end
	DATABASE_TABLE_NAMES

create {REPOSITORIES_SHARED}
	make

feature {NONE} -- Initialization

	make(a_database_access:DATABASE_ACCESS)
			-- <Precursor>
		do
			Precursor {MODEL_REPOSITORY}(a_database_access)
			create filler.make (selection, prototype.twin)
			selection.set_action (filler)
		end

feature -- Access

	fetch_by_laboratory_id(a_laboratory_id:INTEGER)
			-- Get every {INTERVENTION} that has been created in the {LABORATORY} with the index `a_laboratory_id'
		require
			Is_Connected: database_access.is_connected
		do
			fetch_with_and_where(<<["guests_laboratories_id", a_laboratory_id]>>)
--			execute_fetch_with_where_clause("where `guests_laboratories_id` = '" + a_laboratory_id.out + "'")
		ensure
			Fetched_Object_Valid: across items as la_items all attached la_items.item.laboratory as la_laboratory and then la_laboratory.id = a_laboratory_id end
		end

feature {CONTROLLER} -- Implementation

	prototype:INTERVENTION
			-- <Precursor>
		once
			create Result
		end

feature {NONE} -- Implementation

	table_name:STRING_32
			-- <Precursor>
		once
			Result := interventions_table_name
		end
end
