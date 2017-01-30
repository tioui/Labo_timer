note
	description: "Summary description for {ADMINISTRATOR_REPOSITORY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ADMINISTRATOR_REPOSITORY

inherit
	USER_REPOSITORY
		redefine
			prototype
		end

create {REPOSITORIES_SHARED}
	make

feature {CONTROLLER} -- Implementation

	prototype:ADMINISTRATOR
			-- <Precursor>
		once
			create Result
		end

end
