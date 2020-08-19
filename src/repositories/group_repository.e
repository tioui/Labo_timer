note
	description: "Repository used to manage {GROUP} database."
	author: "Louis Marchand"
	date: "Fri, 20 Oct 2017 19:58:47 +0000"
	revision: "0.1"

class
	GROUP_REPOSITORY

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
			create members_store.make_with_keys ({ARRAY[READABLE_STRING_GENERAL]}<<"groups_id", "users_id">>)
			members_store.set_table_name (groups_users_table_name)
			members_store.set_associations ({ARRAY[TUPLE[READABLE_STRING_GENERAL, READABLE_STRING_GENERAL]]}<<["groups_id", "group_id"], ["users_id", "user_id"]>>)
			create members_delete.make
		end

feature -- Access

	fetch_by_name(a_name:READABLE_STRING_GENERAL)
			-- Get a {GROUP} from the database using `a_name' as name. The fetched object can be retreive with `item'
		require
			Is_Connected: database_access.is_connected
		do
			fetch_with_and_where(<<["name", a_name]>>)
		ensure
			Fetched_Object_Valid: attached item as la_item implies la_item.name.same_string (a_name)
		end

	update_members(a_group:GROUP;a_members:ITERABLE[USER])
			-- Put in the database every `a_members' in association with `a_group'
			-- Every other {USER} already assiciated with `a_group'
			-- will be desassociated.
		local
			l_group_has_user:GROUPS_USERS
		do
			members_delete.set_query (
								{STRING_32} "DELETE FROM `" + groups_users_table_name +
								{STRING_32} "` WHERE `groups_id` = '" + a_group.id.out +
								{STRING_32} "' "

							)
			members_delete.execute_query
			across a_members as la_members loop
				create l_group_has_user.make (a_group.id, la_members.item.id)
				members_store.insert (l_group_has_user)
			end
		end

	insert(a_object:like prototype)
			-- <Precursor>
		do
			Precursor (a_object)
			a_object.set_id (database_access.last_inserted_id)
			update_members(a_object, a_object.members)
		end

	update(a_object:like prototype)
			-- <Precursor>
		do
			Precursor (a_object)
			update_members(a_object, a_object.members)
		end

feature {CONTROLLER} -- Implementation

	prototype:GROUP
			-- <Precursor>
		once
			create Result
		end

feature {NONE} -- Implementation

	members_delete:DB_CHANGE
			-- Manage the deletion part of `update_laboratories'

	members_store:STORAGE
			-- To insert, update or delete a guest from the database

	table_name:STRING_32
			-- <Precursor>
		once
			Result :=groups_table_name
		end

end
