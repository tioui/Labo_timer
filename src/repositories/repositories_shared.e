note
	description: "[
				Every class that want to manage the database must
				inherit from this class
			]"
	author: "Louis Marchand"
	date: "Sun, 02 Apr 2017 21:53:15 +0000"
	revision: "0.1"

deferred class
	REPOSITORIES_SHARED

inherit
	DATABASE_ACCESS_SHARED

feature {NONE} -- Implementation

	users_repository:USER_REPOSITORY
			-- The {REPOSITORY} used to create {USER}
		once
			create Result.make (database_access)
		end

	administrators_repository:ADMINISTRATOR_REPOSITORY
			-- The {REPOSITORY} used to create {USER}
		once
			create Result.make (database_access)
		end

	laboratories_repository:LABORATORIES_REPOSITORY
			-- The {REPOSITORY} used to create {LABORATORY}
		once
			create Result.make (database_access)
		end

	interventions_repository:INTERVENTION_REPOSITORY
			-- The {REPOSITORY} used to create {INTERVENTION}
		once
			create Result.make(database_access)
		end

end
