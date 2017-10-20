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
	VIEWS_SHARED
		undefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
			-- <Precursor>
		do
			Precursor {CRUD_CONTROLLER}
			response_method_map.put ([agent guest_get, agent guest_post], "guest")
			response_method_map.put ([agent export_get, Void], "export")
			response_method_map.put ([agent export_all_get, Void], "export_all")
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
					elseif l_type ~ "adding_group" then
						Result := guest_adding_group_get(a_request)
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

	guest_adding_group_get(a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the guest 'adding group' page
		local
			l_template:TEMPLATE_FILE
			l_view_models:LINKED_LIST[GROUP_VIEW_MODEL]
		do
			if attached request_model_id (a_request) as la_id then
				laboratories_repository.fetch_by_id (la_id.item)
				if attached laboratories_repository.item as la_laboratory then
					create l_template.make_from_file (view_path_prefix + "guest_adding_group" + view_path_sufix)
					initialize_template (l_template, a_request)
					if
						attached a_request.path_parameter ("sub_model_id") as la_group_id and then
						la_group_id.string_representation.is_integer
					then
						adding_group(l_template, la_laboratory, la_group_id.string_representation.to_integer)
					end
					l_template.add_value (create {LABORATORY_VIEW_MODEL}.make (la_laboratory) , "laboratory")
					create l_view_models.make
					groups_repository.fetch_all
					la_laboratory.guests.compare_objects
					across groups_repository.items.twin as la_groups loop
						if across la_groups.item.members as la_members some not la_laboratory.guests.has (la_members.item) end then
							l_view_models.extend (create {GROUP_VIEW_MODEL}.make (la_groups.item))
						end
					end
					l_template.add_value (l_view_models, "groups")
					create {HTML_TEMPLATE_PAGE_RESPONSE} Result.make(l_template)
				else
					Result := object_not_found (a_request)
				end
			else
				Result := argument_not_found_response (a_request)
			end
		end

	adding_group(a_template:TEMPLATE_FILE; a_laboratory:LABORATORY; a_group_id:INTEGER)
			-- Adding members of `a_group_id' as `a_laboratory' guests. Update `a_template' if there is an error
		local
			l_has_changed:BOOLEAN
		do
			groups_repository.fetch_by_id (a_group_id)
			if attached groups_repository.item as la_group then
				a_laboratory.guests.compare_objects
				l_has_changed := False
				across la_group.members as la_members loop
					if not a_laboratory.guests.has (la_members.item) then
						a_laboratory.guests.extend (la_members.item)
						l_has_changed := True
					end
				end
				if l_has_changed then
					a_laboratory.save
				end
			else
				a_template.add_value (True, "group_not_found")
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

	export_get(a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the 'export' links
		local
			l_result:STRING_8
			l_page:WSF_PAGE_RESPONSE
		do
			if attached administrator_cookie_manager.login_user (a_request) then
				if attached request_model_id (a_request) as la_id then
					laboratories_repository.fetch_by_id (la_id.item)
					if attached laboratories_repository.item as la_laboratory and then la_laboratory.end_date > la_laboratory.start_date then
						l_result := ""
						get_csv_for_laboratory(l_result, la_laboratory)
						create l_page.make_with_body (l_result)
						l_page.header.put_content_type_text_csv
						Result := l_page
					else
						Result := object_not_found (a_request)
					end
				else
					Result := argument_not_found_response (a_request)
				end
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url (login_url))
			end
		end

	export_all_get(a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the 'export' links
		local
			l_result:STRING_8
			l_page:WSF_PAGE_RESPONSE
		do
			if attached administrator_cookie_manager.login_user (a_request) then
				l_result := ""
				laboratories_repository.fetch_all
				across laboratories_repository.items.twin as la_laboratories loop
					if la_laboratories.item.end_date > la_laboratories.item.start_date then
						get_csv_for_laboratory(l_result, la_laboratories.item)
					end
				end
				create l_page.make_with_body (l_result)
				l_page.header.put_content_type_text_csv
				Result := l_page
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url (login_url))
			end
		end

	get_csv_for_laboratory(a_csv_text:STRING;a_laboratory:LABORATORY)
			-- add the CSV representation of `a_laboratory' inside `a_csv_text'
		do
			across a_laboratory.interventions as la_intervention loop
				valid_intervention_date(la_intervention.item, a_laboratory)
				a_csv_text.append (a_laboratory.name.to_string_8 + "," + a_laboratory.start_date.out + "," + a_laboratory.end_date.out + ",")
				if attached la_intervention.item.user as la_user then
					a_csv_text.append (la_user.user_name.to_string_8 + "," + la_user.first_name + "," + la_user.last_name + ",")
				else
					a_csv_text.append (",,,")
				end
				a_csv_text.append (la_intervention.item.start_time.out + "," + la_intervention.item.end_time.out + ",")
				a_csv_text.append ((la_intervention.item.end_time.seconds - la_intervention.item.start_time.seconds).out)
				a_csv_text.append ("%N")
			end
		end

	valid_intervention_date(a_intervention:INTERVENTION; a_laboratory:LABORATORY)
			-- Be sure that the `a_intervention'.`start_time' and `a_intervention'.`end_time'
			-- are consistent with `a_laboratory'.`start_time' and `a_laboratory'.`end_time'
		require
			Laboratory_time_valid:a_laboratory.end_date > a_laboratory.start_date
		do
			if a_intervention.end_time > a_laboratory.end_date.time then
				a_intervention.set_end_time(a_laboratory.end_date.time)
			end
			if a_intervention.start_time < a_laboratory.start_date.time then
				a_intervention.set_start_time(a_laboratory.start_date.time)
			end
			if a_intervention.end_time <= a_intervention.start_time then
				a_intervention.set_end_time(a_laboratory.end_date.time)
				if a_intervention.end_time <= a_intervention.start_time then
					a_intervention.set_start_time(a_intervention.end_time + create {TIME_DURATION}.make_by_seconds (-1))
				end
			end
		end

end
