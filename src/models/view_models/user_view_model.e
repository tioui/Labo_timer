note
	description: "Summary description for {USER_VIEW_MODEL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	USER_VIEW_MODEL

inherit
	VIEW_MODEL
		rename
			fill_model as fill_user
		redefine
			default_create,
			make,
			fill_user
		end

create
	default_create,
	make

feature -- Initialization

	default_create
		do
			Precursor
			user_name := ""
			first_name := ""
			last_name := ""
		end

	make(a_user:USER)
		do
			Precursor(a_user)
			user_name := a_user.user_name
			first_name := a_user.first_name
			last_name := a_user.last_name
		end


feature -- Access

	user_name: READABLE_STRING_GENERAL
			-- The unique identifiant of `Current'

	first_name: READABLE_STRING_GENERAL
			-- The first part of real name of `Current'

	last_name: READABLE_STRING_GENERAL
			-- The last part of real name of `Current'

	is_valid:BOOLEAN
		do
			Result := is_user_name_valid and is_first_name_valid and is_last_name_valid
		end

	is_user_name_valid:BOOLEAN
		do
			Result := not user_name.is_empty
		end

	is_first_name_valid:BOOLEAN = True

	is_last_name_valid:BOOLEAN = True

	fill_user(a_user:USER)
		do
			Precursor(a_user)
			a_user.set_user_name(user_name)
			a_user.set_first_name (first_name)
			a_user.set_last_name (last_name)
		end

end
