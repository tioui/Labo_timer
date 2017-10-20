note
	description: "Fetch and store {MODEL} object"
	author: "Louis Marchand"
	date: "2014, September 29"
	revision: "1.0"

deferred class
	REPOSITORY

feature {NONE} -- Initialization

	make(a_database_access:DATABASE_ACCESS; a_keys: ARRAY [READABLE_STRING_GENERAL])
			-- Initialization of `Current' using `a_database_access' as database manager
		require
			Is_Set: a_database_access.is_database_set
		local
			l_repository: DB_REPOSITORY
		do
			database_access := a_database_access
			create l_repository.make (table_name)
			l_repository.load
			check l_repository.exists end
			create store.make_with_keys (a_keys)
			store.set_associations_from_repository (l_repository)
			create selection.make
			selection.object_convert (prototype.twin)
		end

feature -- Access

	database_access:DATABASE_ACCESS
			-- The database manager

	create_new:like prototype
			-- New empty instance of an object managed by `Current'
		do
			Result := prototype.twin
		end

	fetch_with_and_where(a_keys_values:ITERABLE[TUPLE[key:READABLE_STRING_GENERAL; value:detachable ANY]])
			-- Fetch all `items' using where clause anding every `a_keys_values'.`key' as test keys and
			-- `a_keys_values'.`value' as test values.

		local
			l_fetch_clause:STRING_32
			l_first:BOOLEAN
		do
			create l_fetch_clause.make (database_access.Default_query_allocation_size)
			l_first := True
			across a_keys_values as la_keys_values loop
				if not l_first then
					l_fetch_clause.append ({STRING_32} " AND ")
				else
					l_fetch_clause.append ({STRING_32} "WHERE ")
				end
				l_fetch_clause.append ({STRING_32} "`" + la_keys_values.item.key.to_string_32 + {STRING_32} "`")
				if attached la_keys_values.item.value then
					l_fetch_clause.append ({STRING_32} " = ")
				end
				if attached {READABLE_STRING_GENERAL} la_keys_values.item.value as la_string then
					l_fetch_clause.append (database_access.database_format.string_format_32 (la_string))
				elseif attached {DATE_TIME} la_keys_values.item.value as la_date_time then
					l_fetch_clause.append (database_access.database_format.string_format_32 (database_access.database_format.date_format (la_date_time)))
				elseif attached la_keys_values.item.value as la_value then
					l_fetch_clause.append (database_access.database_format.string_format_32 (la_value.out))
				else
					l_fetch_clause.append ({STRING_32} " IS NULL")
				end
			end
			execute_fetch_with_where_clause (l_fetch_clause)
		end

	fetch_all
			-- Get every objects from the database. The fetched objects can be retreive with `items'
		require
			Is_Connected: database_access.is_connected
		do
			execute_fetch_with_where_clause ("")
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

	insert(a_object:like prototype)
			-- Insert `a_object' in the database
		do
			store.insert (a_object)
		end

	update(a_object:like prototype)
			-- Modify `a_object' in the database
		do
			store.update (a_object)
		end

	delete(a_object:like prototype)
			-- Remove `a_object' in the database
		do
			store.delete (a_object)
		end


feature {CONTROLLER} -- Implementation

	prototype:ANY
			-- A default {MODEL} object managed by `Current'
		deferred
		end

feature {NONE} -- Implementation

	store:STORAGE
			-- To insert, update or delete an object from the database

	select_join_clause:STRING_32
			-- The "INNER JOIN" clause of every fetch call
		do
			Result := {STRING_32} "SELECT * FROM `" + table_name + "` ";
		end

	selection:DB_SELECTION
			-- To fetch objects from the database

	filler: DB_ACTION [like prototype]
			-- Transform fetched object using `selection' to {MODEL} object

	table_name:STRING_32
			-- The name of the database table used by `Current'
		deferred
		end

	execute_fetch_with_where_clause(a_where_clause:READABLE_STRING_GENERAL)
			-- Launch a fetch using the standard `select_join_clause' and `a_where_clause' as SQL query
		require
			Is_Connected: database_access.is_connected
		do
			execute_fetch(select_join_clause + a_where_clause)
		end

	execute_fetch(a_sql_query:READABLE_STRING_GENERAL)
			-- Launch a fetch using `a_query' as SQL query
		require
			Is_Connected: database_access.is_connected
		do
			filler.list.wipe_out
			selection.set_query (a_sql_query)
			selection.execute_query
			if selection.is_ok then
				selection.load_result
			end
			selection.terminate
		end


end
