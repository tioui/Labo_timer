note
	description: "Summary description for {LABORATORY_VIEW_MODEL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	LABORATORY_VIEW_MODEL

inherit
	VIEW_MODEL
		rename
			fill_model as fill_laboratory
		redefine
			default_create,
			make,
			fill_laboratory
		end

create
	default_create,
	make

feature -- Initialization

	default_create
		do
			Precursor
			name := ""
			password := ""
			date := ""
			start_time := ""
			end_time := ""
		end

	make(a_laboratory:LABORATORY)
		do
			Precursor(a_laboratory)
			name := a_laboratory.name
			password := a_laboratory.password
			date := a_laboratory.start_date.formatted_out (Get_date_format_string)
			start_time := a_laboratory.start_date.formatted_out (Get_Time_format_string)
			end_time := a_laboratory.end_date.formatted_out (Get_Time_format_string)
		end

feature -- Access

	name:READABLE_STRING_GENERAL

	password:READABLE_STRING_GENERAL

	date:READABLE_STRING_GENERAL

	start_time:READABLE_STRING_GENERAL

	end_time:READABLE_STRING_GENERAL

	is_valid:BOOLEAN
		do
			Result := is_name_valid and is_password_valid and is_date_valid and is_start_time_valid and is_end_time_valid
		end

	is_name_valid:BOOLEAN
		do
			Result := True
		end

	is_password_valid:BOOLEAN
		do
			Result := True
		end

	is_date_valid:BOOLEAN
		local
			l_now:DATE
		do
			create l_now.make_now
			Result := l_now.date_valid (date.to_string_8, Put_date_format_string)
		end

	is_start_time_valid:BOOLEAN
		local
			l_now:TIME
		do
			create l_now.make_now
			Result := l_now.time_valid ((start_time + ":00").to_string_8, Put_time_format_string)
		end

	is_end_time_valid:BOOLEAN
		local
			l_now:TIME
		do
			create l_now.make_now
			Result := l_now.time_valid ((end_time + ":00").to_string_8, Put_time_format_string)
		end

	fill_laboratory(a_laboratory:LABORATORY)
		local
			l_date_string:STRING_8
			l_date_start, l_date_end, l_now:DATE_TIME
		do
			Precursor(a_laboratory)
			a_laboratory.set_name (name)
			a_laboratory.set_password (password)
			create l_now.make_now
			l_date_string := (date + " " + start_time + ":00").to_string_8
			if l_now.date_time_valid (l_date_string, Date_time_format_string) then
				create l_date_start.make_from_string (l_date_string, Date_time_format_string)
				a_laboratory.set_start_date (l_date_start)
			end
			l_date_string := (date + " " + end_time + ":00").to_string_8
			if l_now.date_time_valid (l_date_string, Date_time_format_string) then
				create l_date_end.make_from_string (l_date_string, Date_time_format_string)
				a_laboratory.set_end_date (l_date_end)
			end
		end



feature {NONE} -- Implementation

	Date_time_format_string: STRING_8 = "mm/dd/yyyy hh:mi:ss"

	Put_date_format_string: STRING_8 = "mm/dd/yyyy"

	Get_date_format_string: STRING_8 = "[0]mm/[0]dd/yyyy"

	Put_time_format_string: STRING_8 = "hh:mi:ss"

	Get_time_format_string: STRING_8 = "hh:[0]mi"



end
