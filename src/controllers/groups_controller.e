note
	description: "CRUD controller for {GROUP}."
	author: "Louis Marchand"
	date: "Fri, 20 Oct 2017 19:58:47 +0000"
	revision: "0.1"

class
	GROUPS_CONTROLLER

inherit
	LABO_TIMER_CRUD_CONTROLLER
		rename
			model_repository as groups_repository,
			login_cookie_manager as administrator_cookie_manager
		redefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
			-- <Precursor>
		do
			make_with_response_method_map_size(1)
			response_method_map.put ([agent member_get, agent member_post], "member")
		end

feature {NONE} -- Implementation

	model_name:READABLE_STRING_8
			-- <Precursor>
		once
			Result := "group"
		end

	model:GROUP
			-- <Precursor>
		do
			Result := groups_repository.create_new
		end

	view_model:GROUP_VIEW_MODEL
			-- <Precursor>
		do
			create Result
		end

	adding_model_edit_errors_to_template(a_template:TEMPLATE_FILE; a_group:like view_model)
			-- <Precursor>
		do
			has_error := not a_group.is_valid
			adding_error_message_to_template(a_template, a_group.is_name_valid, "group_name_not_valid")
			groups_repository.fetch_by_name (a_group.name)
			if attached groups_repository.item as la_item and then a_group.id /= la_item.id then
				has_error := True
				adding_error_message_to_template(a_template, False, "name_not_unique")
			end
		end

	member_get (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the 'member' management pages
		local
			l_type:STRING_8
		do
			if attached administrator_cookie_manager.login_user (a_request) then
				if attached a_request.path_parameter ("sub_type") as la_type then
					l_type := la_type.string_representation.as_lower.to_string_8
					if l_type ~ "list" then
						Result := member_list_get(a_request)
					elseif l_type ~ "adding" then
						Result := member_adding_get(a_request)
					elseif l_type ~ "remove" then
						Result := member_remove_get(a_request)
					else
						Result := argument_not_valid_response (a_request, l_type.string_representation)
					end
				else
					Result := member_list_get (a_request)
				end
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (script_url (a_request, login_url))
			end
		end

	member_post (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the POST `a_request' of the 'member' management pages
		do
			if attached administrator_cookie_manager.login_user (a_request) then
				if attached a_request.path_parameter ("sub_type") as l_type then
					Result := argument_not_valid_response (a_request, l_type.string_representation)
				else
					Result := unsupported_method_response (a_request, False, True)
				end
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (script_url (a_request, login_url))
			end
		end

	member_list_get(a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the member 'list' page
		local
			l_template:TEMPLATE_FILE
			l_view_models:LINKED_LIST[USER_VIEW_MODEL]
		do
			if attached request_model_id (a_request) as la_id then
				groups_repository.fetch_by_id (la_id.item)
				if attached groups_repository.item as la_group then
					create l_template.make_from_file (view_path_prefix + "member_list" + view_path_sufix)
					initialize_template (l_template, a_request)
					l_template.add_value (create {GROUP_VIEW_MODEL}.make (la_group) , "group")
					create l_view_models.make
					across la_group.members as la_members loop
						l_view_models.extend (create {USER_VIEW_MODEL}.make (la_members.item))
					end
					l_template.add_value (l_view_models, "members")
					create {HTML_TEMPLATE_PAGE_RESPONSE} Result.make(l_template)
				else
					Result := object_not_found (a_request)
				end
			else
				Result := argument_not_found_response (a_request)
			end
		end

	member_adding_get(a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the member 'adding' page
		local
			l_template:TEMPLATE_FILE
			l_view_models:LINKED_LIST[USER_VIEW_MODEL]
		do
			if attached request_model_id (a_request) as la_id then
				groups_repository.fetch_by_id (la_id.item)
				if attached groups_repository.item as la_group then
					create l_template.make_from_file (view_path_prefix + "member_adding" + view_path_sufix)
					initialize_template (l_template, a_request)
					if
						attached a_request.path_parameter ("sub_model_id") as la_user_id and then
						la_user_id.string_representation.is_integer
					then
						adding_member(l_template, la_group, la_user_id.string_representation.to_integer)
					end
					l_template.add_value (create {GROUP_VIEW_MODEL}.make (la_group) , "group")
					create l_view_models.make
					users_repository.fetch_all
					across users_repository.items.twin as la_items loop
						if not across la_group.members as la_members some la_members.item.id = la_items.item.id end then
							l_view_models.extend (create {USER_VIEW_MODEL}.make (la_items.item))
						end
					end
					l_template.add_value (l_view_models, "members")
					create {HTML_TEMPLATE_PAGE_RESPONSE} Result.make(l_template)
				else
					Result := object_not_found (a_request)
				end
			else
				Result := argument_not_found_response (a_request)
			end
		end

	adding_member(a_template:TEMPLATE_FILE; a_group:GROUP; a_member_id:INTEGER)
			-- Adding `a_member_id' as `a_group' member. Update `a_template' if there is an error
		do
			if not across a_group.members as la_members some la_members.item.id = a_member_id end then
				users_repository.fetch_by_id (a_member_id)
				if attached users_repository.item as la_user then
					a_group.members.extend (la_user)
					a_group.save
				else
					a_template.add_value (True, "member_not_found")
				end
			end

		end

	member_remove_get(a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the member 'remove' page
		do
			if attached request_model_id (a_request) as la_id then
				groups_repository.fetch_by_id (la_id.item)
				if attached groups_repository.item as la_group then
					if
						attached a_request.path_parameter ("sub_model_id") as la_user_id and then
						la_user_id.string_representation.is_integer
					then
						removing_member(la_group, la_user_id.string_representation.to_integer)
					end
					Result := member_list_get (a_request)
				else
					Result := object_not_found (a_request)
				end
			else
				Result := argument_not_found_response (a_request)
			end
		end

	removing_member(a_group:GROUP; a_member_id:INTEGER)
			-- Adding `a_member_id' as `a_group' member.
		local
			l_found:BOOLEAN
		do
			users_repository.fetch_by_id (a_member_id)
			if attached users_repository.item as la_user then
				from
					a_group.members.start
					l_found := False
				until
					l_found or a_group.members.exhausted
				loop
					if a_group.members.item.id = a_member_id then
						a_group.members.remove
						l_found := True
					else
						a_group.members.forth
					end
				end
				if l_found then
					a_group.save
				end
			end
		end

end
