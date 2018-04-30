note
	description: "A {CONTROLLER} used to manage the connexion of {USER}"
	author: "Louis Marchand"
	date: "Sun, 02 Apr 2017 21:53:15 +0000"
	revision: "0.1"

class
	LOGIN_CONTROLLER

inherit
	CONTROLLER
		redefine
			execute,
			default_create
		end
	LOGIN_COOKIE_MANAGER_SHARED
		undefine
			default_create
		end
	GUEST_CONTROLLER
		undefine
			default_create
		end
	VIEWS_SHARED
		undefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
			-- <Precursor>
		do
			create response_method_map.make (3)
			response_method_map.compare_objects
			response_method_map.put ([agent login_get, agent login_post], "")
			response_method_map.put ([agent login_get, agent login_post], "in")
			response_method_map.put ([agent logout_get, Void], "out")
			response_method_map.put ([agent login_labo_get, agent login_labo_post], "labo")
		end

feature -- Access

	execute (a_request: WSF_REQUEST; a_response: WSF_RESPONSE)
			-- <Precursor>
		local
			l_message:WSF_RESPONSE_MESSAGE
		do
			-- Todo: response is not pure: modify `new_login_user'
			new_connected_administrator := Void
			l_message := response (a_request)
			if attached request_type(a_request) as la_type then
				if la_type.is_equal("in") and attached new_connected_administrator as la_administrator then
					administrator_cookie_manager.set_login_user (a_request, a_response, la_administrator)
				elseif la_type.is_equal("out") then
					administrator_cookie_manager.logout_user(a_request, a_response)
					user_cookie_manager.logout_user(a_request, a_response)
				elseif la_type.is_equal("labo") and attached new_connected_guest as la_guest then
					user_cookie_manager.set_login_user (a_request, a_response, la_guest)
				end
			end
			a_response.send (l_message)
		end


feature {NONE} -- Initialization

	new_connected_administrator:detachable ADMINISTRATOR
			-- The {ADMINISTRATOR} that has been logged in

	new_connected_guest:detachable USER
			-- The {USER} that has been logged in

	login_get (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the 'login' page
		do
			if attached administrator_cookie_manager.login_user (a_request) then
				create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url ("/laboratories/list"))
			else
				Result := login_with_error(a_request, False)
			end
		end

	login_with_error(a_request: WSF_REQUEST; a_error:BOOLEAN): HTML_TEMPLATE_PAGE_RESPONSE
			-- Show the login page using `a_request' and put an error if `a_error' is `True'
		local
			l_template:TEMPLATE_FILE
		do
			create l_template.make_from_file ("login.tpl")
			initialize_template (l_template, a_request)
			if a_error then
				l_template.add_value (True, "has_error")
			end
			create Result.make(l_template)
		end

	login_post (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the POST `a_request' of the 'login' page
		local
			l_administrator:ADMINISTRATOR
		do
			if attached {ADMINISTRATOR_VIEW_MODEL} object_from_form (a_request, create {ADMINISTRATOR_VIEW_MODEL}, "", "") as la_user then
				administrators_repository.fetch_by_user_name (la_user.user_name)
				if attached {ADMINISTRATOR} administrators_repository.item as la_administrator then
					l_administrator := administrators_repository.create_new
					la_user.fill_administrator (l_administrator)
					if l_administrator.password.to_string_32 ~ la_administrator.password.to_string_32 then
						new_connected_administrator := la_administrator
						create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url ("/laboratories/list"))
					else
						Result := login_with_error(a_request, True)
					end
				else
					Result := login_with_error(a_request, True)
				end
			else
				Result := login_with_error(a_request, True)
			end
		end

	logout_get (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the 'logout' functionnality
		do
			create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url ("/laboratories/list"))
		end

	login_labo_get (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the 'login' page for laboratory guest page
		do
			if attached request_model_id(a_request) as la_id then
				laboratories_repository.fetch_by_id (la_id.item)
				if attached laboratories_repository.item as la_laboratory then
					if attached {USER} user_cookie_manager.login_user (a_request) as la_user then
						if user_has_access_to_laboratory(la_user, la_laboratory) then
							create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url ("/labo/" + la_laboratory.id.out))
						else
							Result := login_labo_with_errors(a_request, la_laboratory, False)
						end
					else
						Result := login_labo_with_errors(a_request, la_laboratory, False)
					end
				else
					Result := object_not_found (a_request)
				end
			else
				Result := argument_not_found_response (a_request)
			end
		end

	login_labo_with_errors(a_request: WSF_REQUEST; a_laboratory:LABORATORY; a_error:BOOLEAN): HTML_TEMPLATE_PAGE_RESPONSE
			-- Show the login page using `a_request' and put an error if `a_error' is `True'
			-- The laboratory to log into is `a_laboratory'
		local
			l_template:TEMPLATE_FILE
		do
			create l_template.make_from_file ("login_labo.tpl")
			initialize_template (l_template, a_request)
			if a_error then
				l_template.add_value (True, "has_error")
			end
			l_template.add_value (a_laboratory, "laboratory")
			create Result.make(l_template)
		end

	login_labo_post (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the POST `a_request' of the 'login' page for laboratory guest page
		do
			if attached {GUEST_VIEW_MODEL} object_from_form (a_request, create {GUEST_VIEW_MODEL}, "", "") as la_guest then
				if attached request_model_id (a_request) as la_id then
					laboratories_repository.fetch_by_id (la_id.item)
					if attached laboratories_repository.item as la_laboratory then
						users_repository.fetch_by_user_name (la_guest.user_name)
						if attached users_repository.item as la_user then
							if user_has_access_to_laboratory(la_user, la_laboratory) then
								new_connected_guest := la_user
								create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url ("/labo/" + la_laboratory.id.out))
							else
								Result := login_labo_with_errors(a_request, la_laboratory, True)
							end
						else
							Result := login_labo_with_errors(a_request, la_laboratory, True)
						end
					else
						Result := argument_not_valid_response (a_request, la_id.item.out)
					end
				else
					Result := object_not_found (a_request)
				end
			else
				Result := object_not_found (a_request)
			end
		end


end
