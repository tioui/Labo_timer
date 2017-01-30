note
	description: "[
					Manage Web cookie session.
					Inherit from this class to use it's features
				]"
	author: "Louis Marchand"
	date: "2014, September 29"
	revision: "1.0"

class
	LOGIN_COOKIE_MANAGER

create
	make


feature {NONE} -- Initialization

	make(a_session_manager:WSF_SESSION_MANAGER; a_user_repository:REPOSITORY)
		do
			user_repository := a_user_repository
			session_manager := a_session_manager
		end

feature {NONE} -- Implementation

	user_repository:REPOSITORY
			-- The {REPOSITORY} used to create user {MODEL}

	session_manager:WSF_SESSION_MANAGER
			-- The internal web session

	session(a_request: WSF_REQUEST):WSF_COOKIE_SESSION
			-- Repersent a multi request Web session. You can add and retreive data.
		do
			create {WSF_COOKIE_SESSION} Result.make (a_request, session_name, session_manager)
		end

	login_user(a_request: WSF_REQUEST):detachable MODEL
			-- Currently logged user {MODEL} in the Web `session'. Void if no user logged
		do
			if attached session(a_request).item (login_user_key) as la_user_id then
				if attached {INTEGER} la_user_id as la_id then
					user_repository.fetch_by_id (la_id)
					Result := user_repository.item
				end
			end
		end

	set_login_user(a_request: WSF_REQUEST;a_response: WSF_RESPONSE; a_user:MODEL)
			-- Assign `a_user' to `login_user'
		local
			l_session:WSF_SESSION
		do
			l_session := session(a_request)
			l_session.remember (a_user.id, login_user_key)
			l_session.commit
			l_session.apply (a_request, a_response, "/")
		end

	login_user_key:READABLE_STRING_GENERAL
			-- The key used in the `session' to store the `login_user'
		once
			Result := "user_id"
		end

	logout_user (a_request: WSF_REQUEST; a_response: WSF_RESPONSE)
			-- Remove the `login_user' from the current Web `session'
		local
			l_date:DATE_TIME
			l_session:WSF_COOKIE_SESSION
		do
			create l_date.make_now
			l_date.day_add (-1)
			l_session := session(a_request)
			l_session.set_expiration(l_date)
			l_session.apply (a_request, a_response, "/")
			l_session.destroy
		end

	session_name:READABLE_STRING_8
		once
			Result := "login"
		end

end
