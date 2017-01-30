note
	description: "Summary description for {USER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	USER

inherit
	MODEL
		rename
			repository as user_repository
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
			set_user_name ("")
			set_first_name ("")
			set_last_name ("")
		end


feature -- Access

	user_name: READABLE_STRING_GENERAL
			-- The unique identifiant of `Current'

	first_name: READABLE_STRING_GENERAL
			-- The first part of real name of `Current'

	last_name: READABLE_STRING_GENERAL
			-- The last part of real name of `Current'

feature -- Settings

	is_equal (a_other: like Current): BOOLEAN
			-- <Precursor>
		do
			Result :=
					Precursor{MODEL}(a_other) and
					user_name.same_string (a_other.user_name) and
					first_name.same_string (a_other.first_name) and
					last_name.same_string (a_other.last_name)
		end

	set_user_name (a_user_name: READABLE_STRING_GENERAL)
			-- Assign the value of `user_name' to `a_user_name'
		require
			value_exists: a_user_name /= Void
		do
			user_name := a_user_name
		ensure
			user_name_set: a_user_name.same_string (user_name)
		end

	set_first_name (a_first_name: READABLE_STRING_GENERAL)
			-- Assign the value of `first_name' to `a_first_name'
		require
			value_exists: a_first_name /= Void
		do
			first_name := a_first_name
		ensure
			first_name_set: a_first_name.same_string (first_name)
		end

	set_last_name (a_last_name: READABLE_STRING_GENERAL)
			-- Assign the value of `last_name' to `a_last_name'
		require
			value_exists: a_last_name /= Void
		do
			last_name := a_last_name
		ensure
			last_name_set: a_last_name.same_string (last_name)
		end

feature -- Output

	out_32: STRING_32
			-- <Precursor>
		do
			Result := Precursor {MODEL}
			Result.append (user_name.out + "%N")
			Result.append (first_name.out + "%N")
			Result.append (last_name.out + "%N")
		end


end
