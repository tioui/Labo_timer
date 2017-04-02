note
	description: "Association between {USER} and {LABORATORY}"
	author: "Louis Marchand"
	date: "Sun, 26 Mar 2017 18:59:34 +0000"
	revision: "0.1"

class
	USERS_LABORATORIES

create
	make

feature {NONE} -- Initialization

	make(a_user_id, a_laboratory_id:INTEGER)
			-- Initialization of `Current' usign `a_user_id' as `user_id'
			-- and `a_laboratory_id' as `laboratory_id'
		do
			user_id := a_user_id
			laboratory_id := a_laboratory_id
		end

feature -- Access

	user_id:INTEGER
			-- The identifier of the {USER}

	laboratory_id:INTEGER
			-- The identifier of the {LABORATORY}

end
