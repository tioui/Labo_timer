note
	description: "Summary description for {INTERVENTION_VIEW_MODEL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	INTERVENTION_VIEW_MODEL

inherit
	VIEW_MODEL
		redefine
			default_create,
			make
		end

create
	default_create,
	make

feature {NONE} -- Initialization

	default_create
			-- <Precursor>
		do
			name := ""
			time := "0:00"
		end

	make(a_intervention:INTERVENTION)
			-- Initialization of `Current' using `a_intervention' to initialize attributes
		local
			l_now, l_time:TIME
			l_seconds:INTEGER
		do
			Precursor(a_intervention)
			if attached a_intervention.user as la_user then
				name := la_user.first_name + " " + la_user.last_name
			else
				name := ""
			end
			create l_now.make_now
			create l_time.make_by_seconds ((create {TIME}.make_now).seconds - a_intervention.start_time.seconds)
			time := l_time.formatted_out ("mi:[0]ss")
		end

feature -- Access

	is_valid:BOOLEAN = True
			-- <Precursor>

	name:READABLE_STRING_GENERAL
			-- The name of the {USER} that has create the {INTERVENTION}

	time:READABLE_STRING_GENERAL
			-- The number of seconds since the start of the {INTERVENTION}

end
