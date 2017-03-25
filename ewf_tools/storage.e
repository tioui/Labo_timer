note
	description: "Used to store new object, modify object or delete object in the database"
	author: "Louis Marchand"
	date: "2014, September 29"
	revision: "1.0"

class
	STORAGE

inherit
	HANDLE_USE

--inherit
--	DB_STORE
--		redefine
--			set_repository
--		end

create
	make_with_keys

feature {NONE} -- Initialization

	make_with_keys(a_keys:ARRAY[READABLE_STRING_GENERAL])
			-- Initialization of `Current' using `a_keys' as primary and secondary key
			-- keys to uniquely identify database record from object
		do
--			make
			table_name := {STRING_32} ""
			create db_insert.make
			create db_update.make
			create db_delete.make
			db_spec := handle.database.db_status.db_spec
			create {ARRAYED_LIST[READABLE_STRING_GENERAL]}keys.make_from_array (a_keys)
			create {LINKED_LIST[TUPLE[table_field, object_field:READABLE_STRING_GENERAL]]}associations.make
			create {LINKED_LIST[READABLE_STRING_GENERAL]}ignored_associations.make
		end

feature -- Access


	set_associations_from_repository (a_repository: DB_REPOSITORY)
			-- Replace `associations' with the values of `a_repository'.
		local
			l_index:INTEGER
		do
			table_name := a_repository.repository_name
			create {LINKED_LIST[TUPLE[table_field, object_field:READABLE_STRING_GENERAL]]}associations.make
			from
				l_index := 1
			until
				l_index > a_repository.column_number
			loop
				if attached a_repository.column_i_th (l_index).column_name as la_column_name then
					associations.extend ([la_column_name, la_column_name])
				end
				l_index := l_index + 1
			end
			update_sql_query
		end

	keys:LIST[READABLE_STRING_GENERAL]
			-- unique database keys to uniquely identify database record from object

	associations:LIST[TUPLE[table_field, object_field:READABLE_STRING_GENERAL]]
			-- Associates every table fields to object reflection field

	set_associations(a_associations:ARRAY[TUPLE[table_field, object_field:READABLE_STRING_GENERAL]])
			-- Replace `associations' with the values of `a_associations'.
		do
			create {ARRAYED_LIST[TUPLE[table_field, object_field:READABLE_STRING_GENERAL]]}associations.make_from_array (a_associations)
			update_sql_query
		end

	ignored_associations:LIST[READABLE_STRING_GENERAL]
			-- The table field name that should not be updated (for example, auto-increment primary key)

	set_ignored_associations(a_ignored_associations:ARRAY[READABLE_STRING_GENERAL])
			-- Replace `ignored_associations' with the values in `a_ignored_associations'
		do
			create {ARRAYED_LIST[READABLE_STRING_GENERAL]}ignored_associations.make_from_array (a_ignored_associations)
			update_sql_query
		end

	remove_association(a_table_field:READABLE_STRING_GENERAL)
		local
			l_is_found:BOOLEAN
		do
			from
				associations.start
				l_is_found := False
			until
				l_is_found or associations.exhausted
			loop
				if associations.item.table_field.same_string (a_table_field) then
					associations.remove
					l_is_found := True
				else
					associations.forth
				end
			end
		end

	table_name:READABLE_STRING_GENERAL
			-- The name of the database table to use in `Current'

	set_table_name(a_name:READABLE_STRING_GENERAL)
			-- Assign `table_name' with the value of `a_name'
		require
			Not_Void: a_name /= Void
			Not_Empty: not a_name.is_empty
		do
			table_name := a_name
			update_sql_query
		ensure
			Is_Assign: table_name.same_string(a_name)
		end


	insert(a_object:ANY)
			-- Insert the data of `a_object' into the database.
			-- the primary key inserted record can be retreive using {DATABASE_ACCESS}.`last_inserted_id'
		require
			object_exists: a_object /= Void
		local
			l_reflection:REFLECTED_REFERENCE_OBJECT
		do
			if not table_name.is_empty and not associations.is_empty then
				create l_reflection.make (a_object)
				update_map_fields (db_insert, l_reflection)
				db_insert.execute_query
			end
		end


	update(a_object:ANY)
			-- Modify the data in the database using `object' to get new values.
		require
			object_exists: a_object /= Void
		local
			l_reflection:REFLECTED_REFERENCE_OBJECT
		do
			if not table_name.is_empty and not associations.is_empty then
				create l_reflection.make (a_object)
				db_update.clear_all
				update_map_fields (db_update, l_reflection)
				update_map_keys (db_update, l_reflection)
				db_update.execute_query
			end
		end

	delete(a_object:ANY)
			-- Remove every records representing `a_object' in the database
		require
			object_exists: a_object /= Void
		local
			l_reflection:REFLECTED_REFERENCE_OBJECT
		do
			if not table_name.is_empty and not associations.is_empty then
				create l_reflection.make (a_object)
				db_delete.clear_all
				update_map_keys (db_delete, l_reflection)
				db_delete.execute_query
			end
		end

feature {NONE} -- Implementation

	update_sql_query
			-- Precompile `db_insert', `db_update' and `db_delete'
		local
			l_query:STRING_32
		do
			l_query := {STRING_32} "INSERT INTO "
			append_table_name_to_sql_query(l_query)
			append_columns_list_to_sql_string({STRING_32}"", l_query)
			l_query.append ({STRING_32} " VALUES ")
			append_columns_list_to_sql_string({STRING_32}":", l_query)
			db_insert.set_query (l_query)
			l_query := {STRING_32} "UPDATE "
			append_table_name_to_sql_query(l_query)
			append_set_clause_to_sql_string(l_query)
			append_where_clause_to_sql_string(l_query)
			db_update.set_query (l_query)
			l_query := {STRING_32} "DELETE FROM "
			append_table_name_to_sql_query(l_query)
			append_where_clause_to_sql_string(l_query)
			db_delete.set_query (l_query)
		end

	append_table_name_to_sql_query(a_query:STRING_32)
			-- Add the table name clause in `a_query'
		local
			l_quoter: STRING_32
		do
			l_quoter := db_spec.identifier_quoter
			a_query.append(l_quoter)
			a_query.append_string_general (table_name)
			a_query.append(l_quoter)
		end

	append_set_clause_to_sql_string(a_query:STRING_32)
			-- Add the set clause in `a_query'
		local
			l_separator, l_quoter: STRING_32
			l_is_first : BOOLEAN
			l_column_name:STRING_32
		do
			l_quoter := db_spec.identifier_quoter
			l_separator := db_spec.qualifier_separator
			a_query.append ({STRING_32} " SET ")
			l_is_first := True
			across associations as la_associations loop

				if not
					across ignored_associations as la_ignored_associations some
						la_associations.item.table_field.same_string(la_ignored_associations.item)
					end
				then
					if not l_is_first then
						a_query.append ({STRING_32} ", ")
					end
					l_column_name := la_associations.item.table_field.to_string_32
					a_query.append(l_quoter)
					a_query.append (l_column_name)
					a_query.append(l_quoter)
					a_query.append ({STRING_32} "=")
					a_query.append (":" + l_column_name + " ")
					l_is_first := False
				end
			end
		end

	append_columns_list_to_sql_string(a_prefix, a_query:STRING_32)
			-- Add the set clause in `a_query'
		local
			l_separator, l_quoter: STRING_32
			l_is_first : BOOLEAN
		do
			l_quoter := db_spec.identifier_quoter
			l_separator := db_spec.qualifier_separator
			a_query.append ({STRING_32} "(")
			l_is_first := True
			across associations as la_associations loop
				if not
					across ignored_associations as la_ignored_associations some
						la_associations.item.table_field.same_string(la_ignored_associations.item)
					end
				then
					if not l_is_first then
						a_query.append ({STRING_32} ", ")
					end
					a_query.append(l_quoter)
					a_query.append(a_prefix)
					a_query.append (la_associations.item.table_field.to_string_32)
					a_query.append(l_quoter)
					l_is_first := False
				end
			end
			a_query.append ({STRING_32} ")")
		end

	append_where_clause_to_sql_string(a_query:STRING_32)
			-- Add the where clause in `a_query'
		local
			l_separator, l_quoter: STRING_32
			l_is_first : BOOLEAN
			l_key_name:READABLE_STRING_32
		do
			l_quoter := db_spec.identifier_quoter
			l_separator := db_spec.qualifier_separator
			a_query.append ({STRING_32} " WHERE ")
			l_is_first := True
			across keys as la_keys loop
				if not l_is_first then
					a_query.append ({STRING_32} " AND ")
				end
				l_key_name := la_keys.item.to_string_32
				a_query.append(l_quoter)
				a_query.append (l_key_name)
				a_query.append(l_quoter)
				a_query.append ({STRING_32} "=")
				a_query.append (":key" + l_key_name + " ")
				l_is_first := False
			end
		end


	update_map_fields(a_change:STRING_HDL;a_reflection:REFLECTED_REFERENCE_OBJECT)
			-- Put the table field -> data value association in `a_change'
			-- Get the table fields using `associations' and data value using `a_reflection'
		local
			l_index:INTEGER
			l_is_found:BOOLEAN
		do
			across associations as la_associations loop
				if not
					across ignored_associations as la_ignored_associations some
						la_associations.item.table_field.same_string(la_ignored_associations.item)
					end
				then
					from
						l_index := 1
						l_is_found := False
					until
						l_is_found or l_index > a_reflection.field_count
					loop
						if a_reflection.field_name (l_index).same_string_general (la_associations.item.object_field) then
							if attached a_reflection.field (l_index) as la_field then
								a_change.set_map_name (la_field, la_associations.item.table_field)
							else
								a_change.set_map_name ("", la_associations.item.table_field)
							end
							l_is_found := True
						end
						l_index := l_index + 1
					end
				end
			end
		end


	update_map_keys(a_change:STRING_HDL;a_reflection:REFLECTED_REFERENCE_OBJECT)
			-- Put the key field -> data value association in `a_change'
			-- Get the key fields using `keys' and data value using `a_reflection'
		local
			l_index:INTEGER
			l_is_found:BOOLEAN
			l_cursor:INDEXABLE_ITERATION_CURSOR[TUPLE[table_field, object_field:READABLE_STRING_GENERAL]]
		do
			across keys as la_keys loop
				from
					l_cursor := associations.new_cursor
					l_is_found := False
				until
					l_is_found or l_cursor.after
				loop
					if l_cursor.item.table_field.same_string(la_keys.item) then
						from
							l_index := 1
						until
							l_is_found or l_index > a_reflection.field_count
						loop
							if a_reflection.field_name (l_index).same_string_general (l_cursor.item.object_field) then
								if attached a_reflection.field (l_index) as la_field then
									a_change.set_map_name (la_field, {STRING_32}"key" + l_cursor.item.table_field)
								else
									a_change.set_map_name ("", {STRING_32}"key" + l_cursor.item.table_field)
								end
								l_is_found := True
							end
							l_index := l_index + 1
						end
						l_is_found := True
					end
					l_cursor.forth
				end
			end
		end

	db_spec:DATABASE
			-- The specification of the database

	db_insert:DB_CHANGE
			-- Used to launch and manage an `insert' SQL query.

	db_update:DB_CHANGE
			-- Used to launch and manage an `update' SQL query.

	db_delete:DB_CHANGE
			-- Used to launch and manage a `delete' SQL query.


end
