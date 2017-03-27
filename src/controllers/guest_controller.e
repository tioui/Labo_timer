note
	description: "{CONTROLLER} that is used to manage laboratory guests."
	author: "Louis Marchand"
	date: "Sun, 26 Mar 2017 18:59:34 +0000"
	revision: "0.1"

deferred class
	GUEST_CONTROLLER

feature {NONE} -- Implementation

	user_has_access_to_laboratory(a_user:USER; a_laboratory:LABORATORY):BOOLEAN
			-- `True' if `a_user' can be a guest to the `a_laboratory'
		do
			from
				a_laboratory.guests.start
				Result := False
			until
				a_laboratory.guests.exhausted or
				Result
			loop
				if a_laboratory.guests.item.id = a_user.id then
					Result := True
				end
				a_laboratory.guests.forth
			end
		end

end
