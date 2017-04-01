note
	description: "Summary description for {VIEW_MODEL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	VIEW_MODEL

inherit
	ANY
		redefine
			default_create
		end

feature -- Initialization

	default_create
			-- Initialization of `Current'
		do
			id := 0
		end

	make(a_model:MODEL)
			-- Initialization of `Current' using `a_model' to fill `Current'
		do
			id := a_model.id
		end

feature -- Access

	id:INTEGER
			--The unique identifier of `Current'

	fill_model(a_model:MODEL)
			-- Used to fill `a_model' fields from `Current'
		do
			a_model.set_id (id)
		end

	is_valid:BOOLEAN
			-- `True' if `Current' has valid field
		deferred
		end

end
