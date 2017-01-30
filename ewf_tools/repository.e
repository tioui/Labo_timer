note
	description: "Fetch and store {MODEL} object"
	author: "Louis Marchand"
	date: "2014, September 29"
	revision: "1.0"

deferred class
	REPOSITORY

feature {NONE} -- Initialization

	make(a_database_access:DATABASE_ACCESS)
			-- Initialization of `Current' using `a_database_access' as database manager
		local
			l_repository: DB_REPOSITORY
		do
			database_access := a_database_access
			create l_repository.make (table_name)
			l_repository.load
			check l_repository.exists end
			create store.make_with_keys (<<"id">>)
			store.set_repository (l_repository)
			create selection.make
			selection.object_convert (prototype.twin)
		end

feature -- Access

	database_access:DATABASE_ACCESS
			-- The database manager

	create_new:like prototype
			-- New empty instance of a {MODEL} managed by `Current'
		do
			Result := prototype.twin
		end

	fetch_by_id(a_id:INTEGER)
			-- Get an object from the database using `a_id' as unique index. The fetched object can be retreive with `item'
		require
			Is_Connected: database_access.is_connected
		do
			execute_fetch("select * from `" + table_name + "` where id = '" +a_id.out + "'")
		ensure
			Fetched_Object_Valid: attached item as la_item implies la_item.id = a_id
		end

	fetch_all
			-- Get every objects from the database. The fetched objects can be retreive with `items'
		require
			Is_Connected: database_access.is_connected
		do
			execute_fetch ("select * from `" + table_name + "`")
		end

	fetch_last_inserted
			-- Get the last inserted objects from the database.
		require
			Is_Connected: database_access.is_connected
		do
			execute_fetch("select * from `" + table_name + "` where id = (select MAX(`ID`) from `" + table_name + "`)")
		end

	item:detachable like prototype
			-- First (or unique) fetched object
		require
			Is_Connected: database_access.is_connected
		do
			if attached items as la_items then
				if la_items.count > 0 then
					Result := la_items.first
				end
			end
		end

	items:LIST[like prototype]
			-- Every objects retreived from the database by the last fetch method
		require
			Is_Connected: database_access.is_connected
		do
			Result := filler.list
		end


feature {CONTROLLER} -- Implementation

	prototype:MODEL
			-- A default {MODEL} object managed by `Current'
		deferred
		end

feature {MODEL} -- Implementation

	store:STORAGE
			-- To insert, update or delete an object from the database

feature {NONE} -- Implementation

	selection:DB_SELECTION
			-- To fetch objects from the database

	filler: DB_ACTION [like prototype]
			-- Transform fetched object using `selection' to {MODEL} object

	table_name:STRING
			-- The name of the database table used by `Current'
		deferred
		end

	execute_fetch(a_query:READABLE_STRING_GENERAL)
			-- Launch every fetch using `a_query' as SQL query
		require
			Is_Connected: database_access.is_connected
		do
			filler.list.wipe_out
			selection.set_query (a_query)
			selection.execute_query
			if selection.is_ok then
				selection.load_result
			end
			selection.terminate
		end
end
