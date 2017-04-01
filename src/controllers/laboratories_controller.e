note
	description: "CRUD controller for {LABORATORY}."
	author: "Louis Marchand"
	date: "Fri, 10 Feb 2017 18:53:38 +0000"
	revision: "0.1"

class
	LABORATORIES_CONTROLLER

inherit
	CRUD_CONTROLLER
		rename
			model_repository as laboratories_repository,
			login_cookie_manager as administrator_cookie_manager
		redefine
			model_collection_name,
			default_create
		end
	LOGIN_COOKIE_MANAGER_SHARED
		undefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
			-- <Precursor>
		do
			Precursor {CRUD_CONTROLLER}
			response_method_map.put ([agent guest_get, agent guest_post], "guest")
		end

feature {NONE} -- Implementation

	model_name:READABLE_STRING_8
			-- <Precursor>
		once
			Result := "laboratory"
		end

	model_collection_name:READABLE_STRING_8
			-- <Precursor>
		do
			Result := "laboratories"
		end

	model:LABORATORY
			-- <Precursor>
		do
			Result := laboratories_repository.create_new
		end

	view_model:LABORATORY_VIEW_MODEL
			-- <Precursor>
		do
			create Result
		end

	adding_model_edit_errors_to_template(a_template:TEMPLATE_FILE; a_laboratory:LABORATORY_VIEW_MODEL)
			-- Look for `a_laboratory' fields validity and add errors messages in `a_template' if needed
		do
			has_error := not a_laboratory.is_valid
			adding_error_message_to_template(a_template, a_laboratory.is_date_valid, "date_not_valid")
			adding_error_message_to_template(a_template, a_laboratory.is_name_valid, "name_not_valid")
			adding_error_message_to_template(a_template, a_laboratory.is_password_valid, "password_not_valid")
			adding_error_message_to_template(a_template, a_laboratory.is_start_time_valid, "start_time_not_valid")
			adding_error_message_to_template(a_template, a_laboratory.is_end_time_valid, "end_time_not_valid")
		end

	guest_get (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the 'guest' management pages
		local
			l_type:STRING_8
		do
			if attached administrator_cookie_manager.login_user (a_request) then
				if attached a_request.path_parameter ("sub_type") as la_type then
					l_type := la_type.string_representation.as_lower.to_string_8
					if l_type ~ "list" then
						Result := guest_list_get(a_request)
					elseif l_type ~ "adding" then
						Result := guest_adding_get(a_request)
					elseif l_type ~ "remove" then
						Result := guest_remove_get(a_request)
					else
						Result := argument_not_valid_response (a_request, l_type.string_representation)
					end
				else
					Result := guest_list_get (a_request)
				end
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url (login_url))
			end
		end

	guest_post (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the POST `a_request' of the 'guest' management pages
		do
			if attached administrator_cookie_manager.login_user (a_request) then
				if attached a_request.path_parameter ("sub_type") as l_type then
					Result := argument_not_valid_response (a_request, l_type.string_representation)
				else
					Result := unsupported_method_response (a_request, False, True)
				end
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url (login_url))
			end
		end

	guest_list_get(a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the guest 'list' page
		local
			l_template:TEMPLATE_FILE
			l_view_models:LINKED_LIST[USER_VIEW_MODEL]
		do
			if attached request_model_id (a_request) as la_id then
				laboratories_repository.fetch_by_id (la_id.item)
				if attached laboratories_repository.item as la_laboratory then
					create l_template.make_from_file (view_path_prefix + "guest_list" + view_path_sufix)
					initialize_template (l_template, a_request)
					l_template.add_value (create {LABORATORY_VIEW_MODEL}.make (la_laboratory) , "laboratory")
					create l_view_models.make
					across la_laboratory.guests as la_guests loop
						l_view_models.extend (create {USER_VIEW_MODEL}.make (la_guests.item))
					end
					l_template.add_value (l_view_models, "guests")
					create {HTML_TEMPLATE_PAGE_RESPONSE} Result.make(l_template)
				else
					Result := object_not_found (a_request)
				end
			else
				Result := argument_not_found_response (a_request)
			end
		end

	guest_adding_get(a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the guest 'adding' page
		local
			l_template:TEMPLATE_FILE
			l_view_models:LINKED_LIST[USER_VIEW_MODEL]
		do
			if attached request_model_id (a_request) as la_id then
				laboratories_repository.fetch_by_id (la_id.item)
				if attached laboratories_repository.item as la_laboratory then
					create l_template.make_from_file (view_path_prefix + "guest_adding" + view_path_sufix)
					initialize_template (l_template, a_request)
					if
						attached a_request.path_parameter ("sub_model_id") as la_user_id and then
						la_user_id.string_representation.is_integer
					then
						adding_guest(l_template, la_laboratory, la_user_id.string_representation.to_integer)
					end
					l_template.add_value (create {LABORATORY_VIEW_MODEL}.make (la_laboratory) , "laboratory")
					create l_view_models.make
					users_repository.fetch_all
					across users_repository.items.twin as la_items loop
						if not across la_laboratory.guests as la_guests some la_guests.item.id = la_items.item.id end then
							l_view_models.extend (create {USER_VIEW_MODEL}.make (la_items.item))
						end
					end
					l_template.add_value (l_view_models, "guests")
					create {HTML_TEMPLATE_PAGE_RESPONSE} Result.make(l_template)
				else
					Result := object_not_found (a_request)
				end
			else
				Result := argument_not_found_response (a_request)
			end
		end

	adding_guest(a_template:TEMPLATE_FILE; a_laboratory:LABORATORY; a_guest_id:INTEGER)
			-- Adding `a_guest_id' as `a_laboratory' guest. Update `a_template' if there is an error
		do
			if not across a_laboratory.guests as la_guests some la_guests.item.id = a_guest_id end then
				users_repository.fetch_by_id (a_guest_id)
				if attached users_repository.item as la_user then
					a_laboratory.guests.extend (la_user)
					a_laboratory.save
				else
					a_template.add_value (True, "guest_not_found")
				end
			end

		end

	guest_remove_get(a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the guest 'remove' page
		do
			if attached request_model_id (a_request) as la_id then
				laboratories_repository.fetch_by_id (la_id.item)
				if attached laboratories_repository.item as la_laboratory then
					if
						attached a_request.path_parameter ("sub_model_id") as la_user_id and then
						la_user_id.string_representation.is_integer
					then
						removing_guest(la_laboratory, la_user_id.string_representation.to_integer)
					end
					Result := guest_list_get (a_request)
				else
					Result := object_not_found (a_request)
				end
			else
				Result := argument_not_found_response (a_request)
			end
		end

	removing_guest(a_laboratory:LABORATORY; a_guest_id:INTEGER)
			-- Adding `a_guest_id' as `a_laboratory' guest.
		local
			l_found:BOOLEAN
		do
			users_repository.fetch_by_id (a_guest_id)
			if attached users_repository.item as la_user then
				from
					a_laboratory.guests.start
					l_found := False
				until
					l_found or a_laboratory.guests.exhausted
				loop
					if a_laboratory.guests.item.id = a_guest_id then
						a_laboratory.guests.remove
						l_found := True
					else
						a_laboratory.guests.forth
					end
				end
				if l_found then
					a_laboratory.save
				end
			end
		end


end
