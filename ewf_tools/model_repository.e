note
	description: "A {REPOSITORY} used to manage {MODEL}"
	author: "Louis Marchand"
	date: "Sun, 02 Apr 2017 21:53:15 +0000"
	revision: "0.1"

deferred class
	MODEL_REPOSITORY

inherit
	REPOSITORY
		rename
			make as make_repository
		redefine
			insert,
			prototype
		end

feature {NONE} -- Initialization

	make(a_database_access:DATABASE_ACCESS)
			-- Initialization of `Current' using `a_database_access' as database manager
		require
			Is_Set: a_database_access.is_database_set
		do
			make_repository(a_database_access, {ARRAY[READABLE_STRING_GENERAL]}<<"id">>)
		end

feature -- Access

	fetch_by_id(a_id:INTEGER)
			-- Get an object from the database using `a_id' as unique index. The fetched object can be retreive with `item'
		require
			Is_Connected: database_access.is_connected
		do
			fetch_with_and_where(<<["id", a_id]>>)
--			execute_fetch_with_where_clause("where id = '" +a_id.out + "'")
		ensure
			Fetched_Object_Valid: attached item as la_item implies la_item.id = a_id
		end

	fetch_last_inserted
			-- Get the last inserted objects from the database.
		require
			Is_Connected: database_access.is_connected
		do
			execute_fetch_with_where_clause("where id = (select MAX(`ID`) from `" + table_name + "`)")
		end

	insert(a_object:like prototype)
			-- Insert `a_object' in the database
		do
			Precursor (a_object)
			a_object.set_id (database_access.last_inserted_id)
		end


feature {CONTROLLER} -- Implementation

	prototype:MODEL
			-- A default {MODEL} object managed by `Current'
		deferred
		end

end
