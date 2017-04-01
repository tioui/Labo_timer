note
	description: "A view model used of an {INTERVENTION}."
	author: "Louis Marchand"
	date: "Sun, 26 Mar 2017 18:59:34 +0000"
	revision: "0.1"

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
			l_intervention_start_time, l_now, l_time:TIME
		do
			Precursor(a_intervention)
			if attached a_intervention.user as la_user then
				name := la_user.first_name + " " + la_user.last_name
			else
				name := ""
			end
			l_intervention_start_time := a_intervention.start_time
			create l_now.make_now
			if l_now < l_intervention_start_time then
				create l_time.make_by_seconds (0)
			else
				create l_time.make_by_seconds ((l_now).seconds - l_intervention_start_time.seconds)
			end
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
