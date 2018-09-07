note
	description: "Common ancestor for every {CRUD_CONTROLLER} in the labo_timer project"
	author: "Louis Marchand"
	date: "Thu, 06 Sep 2018 05:15:20 +0000"
	revision: "0.1"

deferred class
	LABO_TIMER_CRUD_CONTROLLER

inherit
	CRUD_CONTROLLER
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
			Precursor {CRUD_CONTROLLER}(a_size)
			initialize_suffix
		end
end
