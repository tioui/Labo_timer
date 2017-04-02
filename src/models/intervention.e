note
	description: "Class representing an intervention of a {USER} in a {LABORATORY}."
	author: "Louis Marchand"
	date: "Mon, 27 Mar 2017 01:05:13 +0000"
	revision: "0.1"

class
	INTERVENTION

inherit
	MODEL
		rename
			repository as interventions_repository
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


feature {NONE} -- Initialisation

	default_create
			-- <Precursor>
		do
			set_start_time(create {TIME}.make_now)
			set_end_time(create {TIME}.make_by_seconds (0))
		end

feature -- Access

	is_active:BOOLEAN
			-- Is `Current' presently active
		do
			Result := start_time > end_time
		end

	start_time:TIME
			-- The starting {TIME} of `Current'
		do
			Result := get_valid_time(time_start)
		end

	set_start_time(a_start_time:TIME)
			-- Assign `start_time' with the value of `a_start_time'
		do
			time_start := a_start_time.out
		ensure
			Is_Assign: start_time ~ a_start_time
		end

	end_time:TIME
			-- The answering {TIME} of `Current'
		do
			Result := get_valid_time(time_end)
		end

	set_end_time(a_end_time:TIME)
			-- Assign `end_time' with the value of `a_end_time'
		do
			time_end := a_end_time.out
		ensure
			Is_Assign: end_time ~ a_end_time
		end

	user:detachable USER
			-- The {USER} asking `Current'
		do
			users_repository.fetch_by_id (guests_users_id)
			Result := users_repository.item
		end

	set_user(a_user:USER)
			-- Assign `user' with the value of `a_user'
		require
			Is_In_Database:a_user.id > 0
		do
			guests_users_id := a_user.id
		end

	laboratory:detachable LABORATORY
			-- The {LABORATORY} where `Current' has been asked
		do
			laboratories_repository.fetch_by_id (guests_laboratories_id)
			Result := laboratories_repository.item
		end

	set_laboratory(a_laboratory:LABORATORY)
			-- Assign `laboratory' with the value of `a_laboratory'
		require
			Is_In_Database:a_laboratory.id > 0
		do
			guests_laboratories_id := a_laboratory.id
		end

feature -- Settings

	is_equal (a_other: like Current): BOOLEAN
			-- <Precursor>
		do
			Result :=
					Precursor{MODEL}(a_other) and
					start_time ~ a_other.start_time and
					end_time ~ a_other.end_time and
					user ~ a_other.user and
					laboratory ~ a_other.laboratory

		end

feature -- Output

	out_32: STRING_32
			-- <Precursor>
		do
			Result := Precursor {MODEL}
			Result.append (start_time.out + {STRING_32} "%N")
			Result.append (end_time.out + {STRING_32} "%N")
			if attached user as la_user then
				Result.append (la_user.id.out + {STRING_32} "%N")
			end
			if attached laboratory as la_laboratory then
				Result.append (la_laboratory.id.out + {STRING_32} "%N")
			end
		end

feature {NONE} -- Implementation

	guests_users_id:INTEGER
			-- Internal value of `user'

	guests_laboratories_id:INTEGER
			-- Internal value of `laboratory'

	time_start:READABLE_STRING_GENERAL
			-- Internal value of `start_time'

	time_end:READABLE_STRING_GENERAL
			-- Internal value of `end_time'

	get_valid_time(a_time:READABLE_STRING_GENERAL):TIME
			-- Get the {TIME} from `a_time' if it is in a valid format
		local
			l_time_text:STRING_8
		do
			l_time_text := a_time.to_string_8
			create Result.make_now
			if Result.time_valid (l_time_text, Default_time_format) then
				Result.make_from_string (l_time_text, Default_time_format)
			end
		end

	Default_time_format: STRING_8 = "hh12:[0]mi:[0]ss.ff3 AM"
			-- Format String to put value into `*_time' fields

invariant
	Is_User_Id_Valid: attached user as la_user implies la_user.id = guests_users_id
	Is_Laboratory_Id_Valid: attached laboratory as la_laboratory implies la_laboratory.id = guests_laboratories_id
end
