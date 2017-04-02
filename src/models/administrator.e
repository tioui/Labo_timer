note
	description: "A {USER} that can use administrative tools"
	author: "Louis Marchand"
	date: "Sun, 02 Apr 2017 21:53:15 +0000"
	revision: "0.1"

class
	ADMINISTRATOR

inherit
	USER
		rename
			users_repository as administrators_repository
		undefine
			administrators_repository
		redefine
			default_create,
			out_32,
			is_equal
		end
	REPOSITORIES_SHARED
		undefine
			default_create,
			out,
			is_equal
		select
			administrators_repository
		end

create
	default_create

feature {NONE} -- Initialization

	default_create
			-- Initialization of `Current'
		do
			Precursor {USER}
			set_password ("")
		end



feature -- Access

	password: READABLE_STRING_GENERAL
			-- Use to valid the identity of `Current'

feature -- Settings

	is_equal (a_other: like Current): BOOLEAN
			-- <Precursor>
		do
			Result :=
					Precursor{USER}(a_other) and
					password.same_string (a_other.password)
		end

	set_password (a_password: READABLE_STRING_GENERAL)
			-- Assign the value of `password' to `a_password'
		require
			value_exists: a_password /= Void
		do
			password := a_password
		ensure
			password_set: a_password.same_string (password)
		end

feature -- Output

	out_32: STRING_32
			-- <Precursor>
		do
			Result := Precursor {USER}
			Result.append (password.to_string_32 + {STRING_32} "%N")
		end

end
