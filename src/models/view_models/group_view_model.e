note
	description: "A view model used of a {GROUP}."
	author: "Louis Marchand"
	date: "Fri, 20 Oct 2017 19:58:47 +0000"
	revision: "0.1"

class
	GROUP_VIEW_MODEL

inherit
	VIEW_MODEL
		rename
			fill_model as fill_group
		redefine
			default_create,
			make,
			fill_group
		end

create
	default_create,
	make

feature -- Initialization

	default_create
			-- <Precursor>
		do
			Precursor
			name := ""
		end

	make(a_group:GROUP)
			-- <Precursor>
		do
			Precursor(a_group)
			name := a_group.name
		end


feature -- Access

	name: READABLE_STRING_GENERAL
			-- The unique identifiant of `Current'

	is_valid:BOOLEAN
			-- <Precursor>
		do
			Result := is_name_valid
		end

	is_name_valid:BOOLEAN
			-- Is the `name' valid
		do
			Result := not name.is_empty
		end

	fill_group(a_group:GROUP)
			-- <Precursor>
		do
			Precursor(a_group)
			a_group.set_name(name)
		end

end
