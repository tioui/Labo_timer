note
	description: "Summary description for {ADMINISTRATOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ADMINISTRATOR

inherit
	USER
		redefine
			default_create,
			out_32,
			is_equal
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

	save
			-- Insert or update `Current' in the database
		require
			Is_Connected: repository.database_access.is_connected
		do
			if id = 0 then
				repository.store.put (Current)
				set_id (repository.database_access.last_inserted_id)
			else
				repository.store.update (Current)
			end
		ensure
			Is_In_BD: id > 0
		end

	delete
			-- Remove `Current' from the Database
		require
			Is_Connected: repository.database_access.is_connected
		do
			if id /= 0 then
				repository.store.delete (Current)
				set_id (0)
			end
		end

feature -- Output

	out_32: STRING_32
			-- <Precursor>
		do
			Result := Precursor {USER}
			Result.append (password.out + "%N")
		end

end
