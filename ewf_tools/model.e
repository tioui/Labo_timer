note
	description: "Ancestor of every model class of the system (the field should be equivalent to the table on the DataBase)"
	author: "Louis Marchand"
	date: "Sun, 29 Jan 2017 18:27:02 +0000"
	revision: "1.0"

deferred class
	MODEL

inherit
	ANY
		redefine
			is_equal,
			default_create,
			out
		end

feature {NONE} -- Initialization

	default_create
			-- Initialisation of `Current'
		do
			set_id(0)
		end

feature -- Access

	id: INTEGER
			-- Unique identifier of `Current'

	is_equal (a_other: like Current): BOOLEAN
			-- <Precursor>
		do
			Result := id = a_other.id
		end

	out_32: STRING_32
			-- Test representation of `Current'
		do
			Result := {STRING_32}""
			Result.append (id.out + "%N")
		end

	out:STRING
			-- <Precursor>
		do
			Result := out_32.to_string_8
		end


feature -- Settings

	save
			-- Insert or update `Current' in the database
		require
			Is_Connected: repository.database_access.is_connected
		do
			if id = 0 then
				repository.insert (Current)
			else
				repository.update (Current)
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
				repository.delete (Current)
				set_id (0)
			end
		end

	repository:REPOSITORY
			-- {REPOSITORY} managing object like `Current'
		deferred
		end

feature {REPOSITORY, VIEW_MODEL} -- Implementation

	set_id (a_id: INTEGER)
			-- Assign the unique identifier of `Current'
		do
			id := a_id
		ensure
			id_set: a_id = id
		end

end
