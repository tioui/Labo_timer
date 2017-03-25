note
	description: "Summary description for {USERS_LABORATORIES}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	USERS_LABORATORIES

create
	make

feature {NONE} -- Initialization

	make(a_user_id, a_laboratory_id:INTEGER)
		do
			user_id := a_user_id
			laboratory_id := a_laboratory_id
		end

feature -- Access

	user_id:INTEGER

	laboratory_id:INTEGER

end
