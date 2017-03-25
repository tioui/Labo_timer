note
	description: "Summary description for {DATABASE_TABLE_NAMES}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	DATABASE_TABLE_NAMES

feature {NONE} -- Initialiation

	users_table_name:STRING_32
		once
			Result := "users"
		end

	administrators_table_name:STRING_32
		once
			Result := "administrators"
		end

	users_laboratories_table_name:STRING_32
		once
			Result := "guests"
		end

	laboratories_table_name:STRING_32
		once
			Result := "laboratories"
		end
end
