note
	description: "Summary description for {LOGIN_CONTROLLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

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

feature {NONE} -- Initialization

	default_create
		do
			create response_method_map.make (3)
			response_method_map.compare_objects
			response_method_map.put ([agent login_get, agent login_post], "")
			response_method_map.put ([agent login_get, agent login_post], "in")
			response_method_map.put ([agent logout_get, Void], "out")
		end

feature -- Access

	execute (a_request: WSF_REQUEST; res: WSF_RESPONSE)
			-- <Precursor>
		local
			l_message:WSF_RESPONSE_MESSAGE
		do
			-- Todo: response is not pure: modify `new_login_user'
			new_connected_user := Void
			l_message := response (a_request)
			if attached request_type(a_request) as la_type then
				if la_type.is_equal("in") and attached new_connected_user as l_user then
					login_cookie_manager.set_login_user (a_request, res, l_user)
				elseif la_type.is_equal("out") then
					login_cookie_manager.logout_user(a_request, res)
				end
			end
			res.send (l_message)
		end


feature {NONE} -- Initialization

	new_connected_user:detachable ADMINISTRATOR

	login_get (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
		do
			if attached login_cookie_manager.login_user (a_request) then
				create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url ("/"))
			else
				Result := login_with_error(a_request, False)
			end
		end

	login_with_error(a_request: WSF_REQUEST; a_error:BOOLEAN): HTML_TEMPLATE_PAGE_RESPONSE
		local
			l_template:TEMPLATE_FILE
		do
			create l_template.make_from_file ("views/login.tpl")
			initialize_template (l_template, a_request)
			if a_error then
				l_template.add_value (True, "has_error")
			end
			create Result.make(l_template)
		end

	login_post (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
		local
			l_administrator:ADMINISTRATOR
		do
			if attached {ADMINISTRATOR_VIEW_MODEL} object_from_form (a_request, create {ADMINISTRATOR_VIEW_MODEL}, "", "") as la_user then
				administrators_repository.fetch_by_user_name (la_user.user_name)
				if attached {ADMINISTRATOR} administrators_repository.item as la_administrator then
					l_administrator := administrators_repository.create_new
					la_user.fill_administrator (l_administrator)
					if l_administrator.password.to_string_32 ~ la_administrator.password.to_string_32 then
						new_connected_user := la_administrator
						create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url ("/"))
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
		do
			create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url ("/"))
		end


end
