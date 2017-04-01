note
	description: "Contain every database name."
	author: "Louis Marchand"
	date: "Mon, 27 Mar 2017 00:26:54 +0000"
	revision: "0.1"

deferred class
	DATABASE_TABLE_NAMES

feature {NONE} -- Initialiation

	users_table_name:STRING_32
		once
			Result := {STRING_32} "users"
		end

	administrators_table_name:STRING_32
		once
			Result := {STRING_32} "administrators"
		end

	users_laboratories_table_name:STRING_32
		once
			Result := {STRING_32} "guests"
		end

	laboratories_table_name:STRING_32
		once
			Result := {STRING_32} "laboratories"
		end

	interventions_table_name:STRING_32
		once
			Result := {STRING_32} "intervention"
		end
end