note
	description: "Summary description for {ADMINISTRATOR_VIEW_MODEL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ADMINISTRATOR_VIEW_MODEL

inherit
	USER_VIEW_MODEL
		rename
			fill_user as fill_administrator
		redefine
			default_create,
			make,
			fill_administrator,
			is_valid
		end


create
	default_create,
	make

feature -- Initialization

	default_create
		do
			Precursor
			password1 := ""
			password2 := ""
		end

	make(a_administrator:ADMINISTRATOR)
		do
			Precursor(a_administrator)
			password1 := ""
			password2 := ""
		end

feature -- Access

	password1:READABLE_STRING_GENERAL

	password2:READABLE_STRING_GENERAL

	is_valid:BOOLEAN
		do
			Result := Precursor and is_password_valid and is_passwords_same
		end

	is_password_valid:BOOLEAN = True

	is_passwords_same:BOOLEAN
		do
			Result := password1.to_string_32 ~ password2.to_string_32
		end

	fill_administrator(a_administrator:ADMINISTRATOR)
		local
			l_hash:SHA256_HASH
			l_converter:UTF_CONVERTER
		do
			Precursor(a_administrator)
			create l_converter
			create l_hash.make
			l_hash.sink_string (l_converter.string_32_to_utf_8_string_8 (password1.to_string_32))
			a_administrator.set_password (l_hash.current_out)
		end

end
