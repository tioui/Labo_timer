note
	description: "Common ancestor for every {CONTROLLER} in the labo_timer project that are not simple crud"
	author: "Louis Marchand"
	date: "Thu, 06 Sep 2018 05:15:20 +0000"
	revision: "0.1"

deferred class
	LABO_TIMER_CONTROLLER

inherit
	CONTROLLER
		redefine
			make_with_response_method_map_size
		select
			default_create
		end
	LABO_TIMER_CONTROLLER_SUFFIX
		rename
			default_create as initialize_suffix
		end

feature {NONE} -- Initialization

	make_with_response_method_map_size(a_size:INTEGER)
			-- <Precursor>
		do
			Precursor {CONTROLLER}(a_size)
			initialize_suffix
		end


end
