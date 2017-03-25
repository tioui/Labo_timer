note
	description: "Summary description for {LABORATORY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

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
			create {ARRAYED_LIST[USER]}guests.make (0)
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

feature {REPOSITORY, VIEW_MODEL} -- Implementation

	update_guests
			-- <Precursor>
		do
			users_repository.fetch_by_laboratory_id (id)
			create {ARRAYED_LIST[USER]}guests.make (users_repository.items.count)
			guests.append (users_repository.items)
		end

feature {NONE} -- Implementation

	date_start:READABLE_STRING_GENERAL

	date_end:READABLE_STRING_GENERAL

	get_valid_date(a_date:READABLE_STRING_GENERAL):DATE_TIME
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
