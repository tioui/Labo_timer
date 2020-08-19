note
	description: "Repository used to manage {USER} database."
	author: "Louis Marchand"
	date: "Mon, 27 Mar 2017 00:26:54 +0000"
	revision: "0.1"

class
	USER_REPOSITORY

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
			create guest_store.make_with_keys ({ARRAY[READABLE_STRING_GENERAL]}<<"users_id", "laboratories_id">>)
			guest_store.set_table_name (users_laboratories_table_name)
			guest_store.set_associations ({ARRAY[TUPLE[READABLE_STRING_GENERAL, READABLE_STRING_GENERAL]]}<<["users_id", "user_id"], ["laboratories_id", "laboratory_id"]>>)
			create guest_delete.make
		end

feature -- Access

	fetch_by_user_name(a_user_name:READABLE_STRING_GENERAL)
			-- Get a {USER} from the database using `a_user_name' as username. The fetched object can be retreive with `item'
		require
			Is_Connected: database_access.is_connected
		do
			fetch_with_and_where(<<["user_name", a_user_name]>>)
--			execute_fetch_with_where_clause("where `user_name` = " + database_access.database_format.string_format_32 (a_user_name))
		ensure
			Fetched_Object_Valid: attached item as la_item implies la_item.user_name.same_string (a_user_name)
		end

	fetch_by_laboratory_id(a_id:INTEGER)
			-- Fetch every {USER} associated with the {LABORATORY}
			-- having the identifier `a_id'
			-- Result can be retreived with `items'
		do
			execute_fetch(
							{STRING_32} "select * from " + users_laboratories_table_name +
							{STRING_32} " inner join " + users_table_name +
							{STRING_32} " where `users_id` = `id` and `laboratories_id` = '" + a_id.out + {STRING_32} "' "
						)
		end

	fetch_by_group_id(a_id:INTEGER)
			-- Fetch every {USER} associated with the {GROUP}
			-- having the identifier `a_id'
			-- Result can be retreived with `items'
		do
			execute_fetch(
							{STRING_32} "select * from " + groups_users_table_name +
							{STRING_32} " inner join " + users_table_name +
							{STRING_32} " where `users_id` = `id` and `groups_id` = '" + a_id.out + {STRING_32} "' "
						)
		end

	update_laboratories(a_user:USER;a_laboratories:ITERABLE[LABORATORY])
			-- Put in the database every `a_laboratories' in association with `a_user'
			-- Every other {LABORATORY} already assiciated with `a_user'
			-- will be desassociated.
		local
			l_guest:USERS_LABORATORIES
		do
			guest_delete.set_query (
								{STRING_32} "DELETE FROM `" + users_laboratories_table_name +
								{STRING_32} "` WHERE `users_id` = '" + a_user.id.out +
								{STRING_32} "' "

							)
			across a_laboratories as la_laboratories loop
				create l_guest.make (a_user.id, la_laboratories.item.id)
				guest_store.insert (l_guest)
			end
		end

feature {CONTROLLER} -- Implementation

	prototype:USER
			-- <Precursor>
		once
			create Result
		end

feature {NONE} -- Implementation

	guest_delete:DB_CHANGE
			-- Manage the deletion part of `update_laboratories'

	guest_store:STORAGE
			-- To insert, update or delete a guest from the database

	table_name:STRING_32
			-- The name of the database table used by `Current'
		once
			Result := users_table_name
		end

end
