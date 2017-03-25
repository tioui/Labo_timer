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
		do
			id := 0
		end

	make(a_model:MODEL)
		do
			id := a_model.id
		end

feature -- Access

	id:INTEGER

	fill_model(a_model:MODEL)
		do
			a_model.set_id (id)
		end

	is_valid:BOOLEAN
		deferred
		end

end
