note
	description: "Used to store new object, modify object or delete object in the database"
	author: "Louis Marchand"
	date: "2014, September 29"
	revision: "1.0"

class
	STORAGE

inherit
	DB_STORE

create
	make_with_keys

feature {NONE} -- Initialization

	make_with_keys(a_keys:ARRAY[READABLE_STRING_GENERAL])
			-- Initialization of `Current' using `a_keys' as unique database
			-- keys to uniquely identify database record from object
		do
			make
			db_spec := handle.database.db_status.db_spec
			db_change := handle.database.db_change
			create {ARRAYED_LIST[READABLE_STRING_GENERAL]}keys.make_from_array (a_keys)
		end

feature -- Status report

	repository: detachable like implementation.repository
			-- Associated repository
		do
			Result := implementation.repository
		end

feature -- Access

	update(a_object:ANY)
			-- Modify the data in the database using `object' to get new values.
		require
			object_exists: a_object /= Void
			owns_repository: owns_repository
			repository_exists: attached repository as lr_repository and then lr_repository.exists
		local
			l_reflection:REFLECTED_REFERENCE_OBJECT
			l_field_map:HASH_TABLE[INTEGER,INTEGER]
		do
			if attached repository as la_repository then
				create l_reflection.make (a_object)
				l_field_map := field_map(l_reflection, la_repository)
				sql_string.wipe_out
				sql_string.append ({STRING_32} "UPDATE ")
				append_table_name_to_sql_string(la_repository)
				append_set_clause_to_sql_string (l_field_map, l_reflection, la_repository)
				append_where_clause_to_sql_string (l_field_map, l_reflection, la_repository)
				db_change.modify (sql_string)
				db_change.clear_all
			end
		end

	delete(a_object:ANY)
			-- Remove every records representing `a_object' in the database
		require
			object_exists: a_object /= Void
			owns_repository: owns_repository
			repository_exists: attached repository as lr_repository and then lr_repository.exists
		local
			l_reflection:REFLECTED_REFERENCE_OBJECT
			l_field_map:HASH_TABLE[INTEGER,INTEGER]
		do
			if attached repository as la_repository then
				create l_reflection.make (a_object)
				l_field_map := field_map(l_reflection, la_repository)
				sql_string.wipe_out
				sql_string.append ({STRING_32} "DELETE FROM ")
				append_table_name_to_sql_string(la_repository)
				append_where_clause_to_sql_string (l_field_map, l_reflection, la_repository)
				db_change.modify (sql_string)
				db_change.clear_all
			end
		end

feature {NONE} -- Implementation

	keys:LIST[READABLE_STRING_GENERAL]
			-- unique database keys to uniquely identify database record from object

	field_map(a_reflection:REFLECTED_REFERENCE_OBJECT; a_repository : attached like repository):HASH_TABLE[INTEGER,INTEGER]
			-- A map that identify a field of `a_reflection' associate to every field of `a_repository'
		require
			reflection_exists: a_reflection /= Void
			Repository_Valid: a_repository /= Void
			repository_exists: attached a_repository as lr_repository and then lr_repository.exists
		local
			i, j:INTEGER
		do
			create Result.make (a_repository.column_number)
			from
				i := 1
			until
				i > a_repository.column_number
			loop
				from
					j := 1
				until
					j > a_reflection.field_count
				loop
					if attached a_repository.column_name (i) as la_column_name and then
							la_column_name.same_string_general (a_reflection.field_name(j)) then
						Result.put (j, i)
					end
					j := j + 1
				end
				i := i + 1
			end
		end

	append_table_name_to_sql_string(a_repository : attached like repository)
			-- Add to the end of `sql_string' the name of the database table represented by `a_repository'
		require
			Repository_valid: a_repository /= Void
			repository_exists: attached a_repository as lr_repository and then lr_repository.exists
		local
			l_separator, l_quoter: STRING_32
		do
			l_quoter := db_spec.identifier_quoter
			l_separator := db_spec.qualifier_separator
			if (a_repository.rep_qualifier /= Void and then a_repository.rep_qualifier.count > 0) then
				sql_string.append(l_quoter)
				sql_string.append_string_general(a_repository.rep_qualifier)
				sql_string.append(l_quoter)
			end
			if (a_repository.rep_owner /= Void and then a_repository.rep_owner.count > 0) then
				sql_string.append(l_separator)
				sql_string.append(l_quoter)
				sql_string.append_string_general(a_repository.rep_owner)
				sql_string.append(l_quoter)
			end
			if ((a_repository.rep_owner /= Void and then a_repository.rep_owner.count > 0) or (a_repository.rep_qualifier /= Void and then a_repository.rep_qualifier.count > 0)) then
				sql_string.append_character ({CHARACTER_32} '.')
			end
			sql_string.append(l_quoter)
			sql_string.append_string_general (a_repository.repository_name)
			sql_string.append(l_quoter)
		end

	append_set_clause_to_sql_string(a_field_map:HASH_TABLE[INTEGER,INTEGER]; a_reflection:REFLECTED_REFERENCE_OBJECT; a_repository : attached like repository)
			-- Add to the end of `sql_string' the "SET" section of a "MODIFY" SQL query using every column of
			-- `a_repository' as column name and the field of `a_reflection' as value using `a_field_map' to
			-- map column of `a_repository' to field of `a_reflection'.
		require
			Field_map_Not_Void: a_field_map /= Void
			Reflection_exists: a_reflection /= Void
			Repository_valid: a_repository /= Void
			Repository_exists: attached a_repository as lr_repository and then lr_repository.exists
		local
			l_separator, l_quoter: STRING_32
			l_is_first : BOOLEAN
		do
			l_quoter := db_spec.identifier_quoter
			l_separator := db_spec.qualifier_separator
			sql_string.append ({STRING_32} " SET ")
			l_is_first := True
			across (1 |..| a_repository.column_number) as la_column_index loop
				if attached a_repository.column_name (la_column_index.item) as la_column_name then
					a_field_map.search (la_column_index.item)
					if a_field_map.found and then attached a_reflection.field (a_field_map.found_item) as la_object_field then
						if not l_is_first then
							sql_string.append ({STRING_32} ", ")
						end
						sql_string.append(l_quoter)
						sql_string.append (la_column_name)
						sql_string.append(l_quoter)
						sql_string.append ({STRING_32} "=")
						sql_string.append (":" + la_column_name + " ")
						db_change.set_map_name (la_object_field, la_column_name)
						l_is_first := False
					end
				end
			end
		end

	append_where_clause_to_sql_string(a_field_map:HASH_TABLE[INTEGER,INTEGER]; a_reflection:REFLECTED_REFERENCE_OBJECT; a_repository : attached like repository)
			-- Add to the end of `sql_string' the "WHERE" section of a SQL query using every column pointed by `keys'
			-- in `a_repository' as column name and the field of `a_reflection' as value using `a_field_map' to
			-- map column of `a_repository' to field of `a_reflection'.
		require
			Field_map_Not_Void: a_field_map /= Void
			Reflection_exists: a_reflection /= Void
			Repository_valid: a_repository /= Void
			Repository_exists: attached a_repository as lr_repository and then lr_repository.exists
		local
			l_separator, l_quoter: STRING_32
			l_key_map :HASH_TABLE[INTEGER,INTEGER]
			l_is_first : BOOLEAN
			l_column_name:READABLE_STRING_32
		do
			l_quoter := db_spec.identifier_quoter
			l_separator := db_spec.qualifier_separator
			sql_string.append ({STRING_32} " WHERE ")
			l_key_map := key_map(a_repository)
			l_is_first := True
			across (1 |..| keys.count) as la_key_index loop
				l_column_name := keys.at (la_key_index.item).to_string_32
				l_key_map.search (la_key_index.item)
				if l_key_map.found then
					a_field_map.search (l_key_map.found_item)
					if a_field_map.found and then attached a_reflection.field (a_field_map.found_item) as la_object_field then
						if not l_is_first then
							sql_string.append ({STRING_32} " AND ")
						end
						sql_string.append(l_quoter)
						sql_string.append (l_column_name)
						sql_string.append(l_quoter)
						sql_string.append ({STRING_32} "=")
						sql_string.append (":key" + a_repository.repository_name + l_column_name + " ")
						db_change.set_map_name (la_object_field, "key" + a_repository.repository_name + l_column_name)
						l_is_first := False
					end
				end
			end
		end

	key_map(a_repository : attached like repository):HASH_TABLE[INTEGER,INTEGER]
			-- Map every `keys' to a column of `a_repository'
		require
			Repository_valid: a_repository /= Void
			Repository_exists: attached a_repository as lr_repository and then lr_repository.exists
		do
			create Result.make (keys.count)
			across (1 |..| keys.count) as la_key_index loop
				across (1 |..| a_repository.column_number) as la_column_index loop
					if attached a_repository.column_name (la_column_index.item) as la_column_name and then
							la_column_name.same_string_general(keys.at (la_key_index.item)) then
						Result.put(la_key_index.item, la_column_index.item)
					end
				end
			end
		end

	db_spec:DATABASE
			-- The specification of the database

	db_change:DATABASE_CHANGE[DATABASE]
			-- Used to launch and manage a "MODIFY" and "DELETE" SQL query.

	sql_string: STRING_32
			-- Constant string
		once
			create Result.make (256)
		end

end
