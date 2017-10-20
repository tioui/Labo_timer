note
	description: "Association between {USER} and {LABORATORY}."
	author: "Louis Marchand"
	date: "Fri, 20 Oct 2017 19:58:47 +0000"
	revision: "0.1"

class
	GROUPS_USERS

create
	make

feature {NONE} -- Initialization

	make(a_group_id, a_user_id:INTEGER)
			-- Initialization of `Current' usign `a_group_id' as `group_id'
			-- and `a_user_id' as `user_id'
		do
			group_id := a_group_id
			user_id := a_user_id
		end

feature -- Access

	group_id:INTEGER
			-- The identifier of the {GROUP}

	user_id:INTEGER
			-- The identifier of the {USER}


end
