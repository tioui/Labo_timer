note
	description: "Contain every database name."
	author: "Louis Marchand"
	date: "Mon, 27 Mar 2017 00:26:54 +0000"
	revision: "0.1"

deferred class
	DATABASE_TABLE_NAMES

feature {NONE} -- Initialiation

	users_table_name:STRING_32
			-- Database table containing {USER} data
		once
			Result := {STRING_32} "users"
		end

	administrators_table_name:STRING_32
			-- Database table containing {ADMINISTRATOR} data
		once
			Result := {STRING_32} "administrators"
		end

	users_laboratories_table_name:STRING_32
			-- Database table containing the association {USER} in {LABORATORY}
		once
			Result := {STRING_32} "guests"
		end

	laboratories_table_name:STRING_32
			-- Database table containing {LABORATORY} data
		once
			Result := {STRING_32} "laboratories"
		end

	interventions_table_name:STRING_32
			-- Database table containing {INTERVENTION} data
		once
			Result := {STRING_32} "interventions"
		end

	groups_table_name:STRING_32
			-- Database table containing {GROUP} data
		once
			Result := {STRING_32} "groups"
		end

	groups_users_table_name:STRING_32
			-- Database table containing the association {GROUP} in {USER}
		once
			Result := {STRING_32} "members"
		end
end
