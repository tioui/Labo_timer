note
	description: "Summary description for {ADMINISTRATOR_REPOSITORY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ADMINISTRATOR_REPOSITORY

inherit
	USER_REPOSITORY
		rename
			table_name as user_table_name,
			store as store_user
		redefine
			prototype,
			make,
			insert,
			update,
			select_join_clause
		end

create {REPOSITORIES_SHARED}
	make

feature {NONE} -- Initialization

	make(a_database_access:DATABASE_ACCESS)
			-- Initialization of `Current' using `a_database_access' as database manager
		do
			Precursor(a_database_access)
			create store.make_with_keys (<<"users_id">>)
			store.set_table_name (table_name)
			store.set_associations (<<["users_id", "id"], ["password", "password"]>>)
		end

feature -- Access

	insert(a_object:like prototype)
			-- Insert `a_object' in the database
		do
			Precursor {USER_REPOSITORY}(a_object)
			store.insert (a_object)
		end

	update(a_object:like prototype)
			-- Modify `a_object' in the database
		do
			Precursor {USER_REPOSITORY}(a_object)
			store.update (a_object)
		end

feature {CONTROLLER} -- Implementation

	prototype:ADMINISTRATOR
			-- <Precursor>
		once
			create Result
		end

feature {NONE} -- Implementation

	store:STORAGE
			-- To insert, update or delete an object from the database

	table_name:STRING_32
			-- The name of the database table used by `Current'
		once
			Result := administrators_table_name
		end

	select_join_clause:STRING_32
			-- The "INNER JOIN" clause of every fetch call
		once
			Result :=
					{STRING_32} "SELECT * FROM `" + user_table_name +
					{STRING_32} "` INNER JOIN `" + table_name +
					{STRING_32} "` ON `" + user_table_name +
					{STRING_32} "`.`id` = `" + table_name +
					{STRING_32} "`.`users_id` ";
		end

end
