note
	description: "Class representing an exercices lecture or laboratory."
	author: "Louis Marchand"
	date: "Mon, 27 Mar 2017 01:05:13 +0000"
	revision: "0.1"

class
	LABORATORY

inherit
	MODEL
		rename
			repository as laboratories_repository
		redefine
			default_create,
			out_32
		end
	REPOSITORIES_SHARED
		undefine
			default_create,
			out,
			is_equal
		end

create
	default_create

feature {NONE} -- Initialization

	default_create
			-- Initialization of `Current'
		do
			Precursor {MODEL}
			set_name ("")
			set_password ("")
			set_start_date(create {DATE_TIME}.make_now)
			set_end_date((create {DATE_TIME}.make_now) + (create {DATE_TIME_DURATION}.make (0, 0, 0, 2, 0, 0)))
		end

feature -- Access

	name:READABLE_STRING_GENERAL
			-- The visual identifier of `Current'

	set_name(a_name:READABLE_STRING_GENERAL)
			-- Assign `name' with the value of `a_name'
		do
			name := a_name
		ensure
			Is_Assign: name ~ a_name
		end

	password:READABLE_STRING_GENERAL
			-- The password used to identify invited guest

	set_password(a_password:READABLE_STRING_GENERAL)
			-- Assign `password' with the value of `a_password'
		do
			password := a_password
		ensure
			Is_Assign: password ~ a_password
		end

	start_date:DATE_TIME
			-- The beginning of `Current'
		do
			Result := get_valid_date(date_start)
		end

	set_start_date(a_start_date:DATE_TIME)
			-- Assign `start_date' with the value of `a_start_date'
		do
			date_start := a_start_date.out
		ensure
			Is_Assign: start_date ~ a_start_date
		end

	end_date:DATE_TIME
			-- The end of `Current'
		do
			Result := get_valid_date(date_end)
		end

	set_end_date(a_end_date:DATE_TIME)
			-- Assign `end_date' with the value of `a_end_date'
		do
			date_end := a_end_date.out
		ensure
			Is_Assign: end_date ~ a_end_date
		end

	guests:LIST[USER]
			-- The {USER} that can access `Current'
		do
			if attached internal_guests as la_guests then
				Result := la_guests
			else
				update_guests
				Result := guests
			end
		end

	update_guests
			-- Update `guests' values
		local
			l_guests:LIST[USER]
		do
			users_repository.fetch_by_laboratory_id (id)
			create {ARRAYED_LIST[USER]}l_guests.make (users_repository.items.count)
			l_guests.append (users_repository.items)
			internal_guests := l_guests
		end

	interventions:LIST[INTERVENTION]
			-- Every {INTERVENTION} asked in `Current'
		do
			if attached internal_interventions as la_interventions then
				Result := la_interventions
			else
				update_interventions
				Result := interventions
			end
		end

	update_interventions
			-- Update `interventions' values
		local
			l_interventions:LIST[INTERVENTION]
		do
			interventions_repository.fetch_by_laboratory_id (id)
			create {ARRAYED_LIST[INTERVENTION]}l_interventions.make (interventions_repository.items.count)
			l_interventions.append (interventions_repository.items)
			internal_interventions := l_interventions
		end

feature -- Status report

	is_presently_executing:BOOLEAN
			-- `True' if `Current' is presently in execution
		local
			l_now:DATE_TIME
		do
			create l_now.make_now
			if l_now >= start_date and l_now <= end_date then
				Result := True
			else
				Result := False
			end
		end


feature -- Output

	out_32: STRING_32
			-- <Precursor>
		do
			Result := Precursor {MODEL}
			Result.append (name.to_string_32 + {STRING_32} "%N")
			Result.append (password.to_string_32 + {STRING_32} "%N")
			Result.append (date_start.out + {STRING_32} "%N")
			Result.append (date_end.out + {STRING_32} "%N")
		end

feature {NONE} -- Implementation

	internal_guests:detachable LIST[USER]
			-- The internal value of the lazy evaluated `guests' attribute

	internal_interventions:detachable LIST[INTERVENTION]
			-- The internal value of the lazy evaluated `interventions' attribute

	date_start:READABLE_STRING_GENERAL
			-- Internal value of `start_date'

	date_end:READABLE_STRING_GENERAL
			-- Internal value of `end_date'

	get_valid_date(a_date:READABLE_STRING_GENERAL):DATE_TIME
			-- Get the {DATE_TIME} from `a_date' if it is in a valid format
		local
			l_date_text:STRING_8
		do
			l_date_text := a_date.to_string_8
			create Result.make_now
			if Result.date_time_valid (l_date_text, Result.default_format_string) then
				Result.make_from_string_default (l_date_text)
			end
		end


end
