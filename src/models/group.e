note
	description: "Class representing a group of {USER}s"
	author: "Louis Marchand"
	date: "Fri, 20 Oct 2017 19:58:47 +0000"
	revision: "0.1"

class
	GROUP

inherit
	MODEL
		rename
			repository as groups_repository
		redefine
			is_equal,
			default_create,
			out_32
		end
	REPOSITORIES_SHARED
		undefine
			is_equal,
			out,
			default_create
		end

create
	default_create

feature {NONE} -- Initialization

	default_create
			-- Initialization of `Current'
		do
			Precursor {MODEL}
			set_name ("")
		end


feature -- Access

	name: READABLE_STRING_GENERAL
			-- The unique identifiant of `Current'

feature -- Settings

	is_equal (a_other: like Current): BOOLEAN
			-- <Precursor>
		do
			Result :=
					Precursor{MODEL}(a_other) and
					name.same_string (a_other.name)
		end

	set_name (a_name: READABLE_STRING_GENERAL)
			-- Assign the value of `name' to `a_name'
		require
			value_exists: a_name /= Void
		do
			name := a_name
		ensure
			Name_set: a_name.same_string (name)
		end

	members:LIST[USER]
			-- The {USER} that can access `Current'
		do
			if attached internal_members as la_members then
				Result := la_members
			else
				update_members
				Result := members
			end
		end

	update_members
			-- Update `members' values
		local
			l_members:LIST[USER]
		do
			users_repository.fetch_by_group_id (id)
			create {ARRAYED_LIST[USER]}l_members.make (users_repository.items.count)
			l_members.append (users_repository.items)
			internal_members := l_members
		end

feature -- Output

	out_32: STRING_32
			-- <Precursor>
		do
			Result := Precursor {MODEL}
			Result.append (name.to_string_32 + {STRING_32} "%N")
		end

feature {NONE} -- Implementation

	internal_members:detachable LIST[USER]
			-- The internal value of the lazy evaluated `members' attribute

end
