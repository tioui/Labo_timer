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

	fetch_by_users_id(a_id:INTEGER)
		do
			execute_fetch(
							{STRING_32} "select * from " + users_laboratories_table_name +
							{STRING_32} " inner join " + users_table_name +
							{STRING_32} " where `laboratories_id` = '" + a_id.out + {STRING_32} "' "
						)
		end

	update_users(a_laboratory:LABORATORY; a_users:ITERABLE[USER])
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

	guest_store:STORAGE
			-- To insert, update or delete a guest from the database

	table_name:STRING_32
			-- <Precursor>
		once
			Result := laboratories_table_name
		end


end
