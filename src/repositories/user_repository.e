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

	make(l_database_access:DATABASE_ACCESS)
			-- <Precursor>
		do
			Precursor {MODEL_REPOSITORY}(l_database_access)
			create filler.make (selection, prototype.twin)
			selection.set_action (filler)
			create guest_store.make_with_keys (<<"users_id", "laboratories_id">>)
			guest_store.set_table_name (users_laboratories_table_name)
			guest_store.set_associations (<<["users_id", "user_id"], ["laboratories_id", "laboratory_id"]>>)
			create guest_delete.make
		end

feature -- Access

	fetch_by_user_name(a_user_name:READABLE_STRING_GENERAL)
			-- Get a {USER} from the database using `a_user_name' as username. The fetched object can be retreive with `item'
		require
			Is_Connected: database_access.is_connected
		do
			execute_fetch_with_where_clause("where `user_name` = '" + a_user_name + "'")
		ensure
			Fetched_Object_Valid: attached item as la_item implies la_item.user_name.same_string (a_user_name)
		end

	fetch_by_laboratory_id(a_id:INTEGER)
		do
			execute_fetch(
							{STRING_32} "select * from " + users_laboratories_table_name +
							{STRING_32} " inner join " + users_table_name +
							{STRING_32} " where `users_id` = `id` and `laboratories_id` = '" + a_id.out + {STRING_32} "' "
						)
		end

	update_laboratories(a_user:USER;a_laboratories:ITERABLE[LABORATORY])
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

	guest_store:STORAGE
			-- To insert, update or delete a guest from the database

	table_name:STRING_32
			-- The name of the database table used by `Current'
		once
			Result := users_table_name
		end

end