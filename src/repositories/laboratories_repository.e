note
	description: "Repository used to manage {LABORATORY} database."
	author: "Louis Marchand"
	date: "Mon, 27 Mar 2017 00:26:54 +0000"
	revision: "0.1"

class
	LABORATORIES_REPOSITORY

inherit
	MODEL_REPOSITORY
		redefine
			make, insert, update
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

	fetch_by_users_id(a_id:INTEGER)
			-- Fetch in the database the {USER} identified by `a_id'
			-- You can get the resulting {USER} with `item'
		do
			execute_fetch(
							{STRING_32} "select * from " + users_laboratories_table_name +
							{STRING_32} " inner join " + users_table_name +
							{STRING_32} " where `laboratories_id` = '" + a_id.out + {STRING_32} "' "
						)
		end

	update_users(a_laboratory:LABORATORY; a_users:ITERABLE[USER])
			-- Put in the database every `a_users' in `a_laboratory'
			-- Every other {USER} already assiciated with `a_laboratory'
			-- will be desassociated.
		local
			l_guest:USERS_LABORATORIES
		do
			guest_delete.set_query (
								{STRING_32} "DELETE FROM `" + users_laboratories_table_name +
								{STRING_32} "` WHERE `laboratories_id` = '" + a_laboratory.id.out +
								{STRING_32} "' "

							)
			guest_delete.execute_query
			across a_users as la_users loop
				create l_guest.make (la_users.item.id, a_laboratory.id)
				guest_store.insert (l_guest)
			end
		end

	insert(a_object:like prototype)
			-- <Precursor>
		do
			Precursor (a_object)
			a_object.set_id (database_access.last_inserted_id)
			update_users(a_object, a_object.guests)
		end

	update(a_object:like prototype)
			-- <Precursor>
		do
			Precursor (a_object)
			update_users(a_object, a_object.guests)
		end

feature {CONTROLLER} -- Implementation

	prototype:LABORATORY
			-- <Precursor>
		once
			create Result
		end

feature {NONE} -- Implementation

	guest_delete:DB_CHANGE
			-- Manage the deletion part of `update_users'

	guest_store:STORAGE
			-- To insert, update or delete a guest from the database

	table_name:STRING_32
			-- <Precursor>
		once
			Result := laboratories_table_name
		end


end
