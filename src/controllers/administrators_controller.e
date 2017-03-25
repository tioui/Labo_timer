note
	description: "CRUD controller for {ADMINISTRATOR}."
	author: "Louis Marchand"
	date: "Fri, 10 Feb 2017 18:53:38 +0000"
	revision: "0.1"

class
	ADMINISTRATORS_CONTROLLER

inherit
	CRUD_CONTROLLER
		rename
			model_repository as administrators_repository
		redefine
			adding_model_create_errors_to_template,
			edit_post
		end
	LOGIN_COOKIE_MANAGER_SHARED
		undefine
			default_create
		end

feature {NONE} -- Implementation

	model_name:READABLE_STRING_8
			-- <Precursor>
		once
			Result := "administrator"
		end

	model:ADMINISTRATOR
			-- <Precursor>
		do
			Result := administrators_repository.create_new
		end

	view_model:ADMINISTRATOR_VIEW_MODEL
			-- <Precursor>
		do
			create Result
		end

	adding_model_edit_errors_to_template(a_template:TEMPLATE_FILE; a_administrator:like view_model)
			-- <Precursor>
		do
			has_error := not a_administrator.is_valid
			adding_error_message_to_template(a_template, a_administrator.is_user_name_valid, "user_name_not_valid")
			adding_error_message_to_template(a_template, a_administrator.is_first_name_valid, "first_name_not_valid")
			adding_error_message_to_template(a_template, a_administrator.is_last_name_valid, "last_name_not_valid")
			adding_error_message_to_template(a_template, a_administrator.is_password_valid, "password_not_valid")
			adding_error_message_to_template(a_template, a_administrator.is_passwords_same, "password_differ")
			administrators_repository.fetch_by_user_name (a_administrator.user_name)
			if attached administrators_repository.item as la_item and then a_administrator.id /= la_item.id then
				has_error := True
				adding_error_message_to_template(a_template, False, "user_name_not_unique")
			end
		end

	adding_model_create_errors_to_template(a_template:TEMPLATE_FILE; a_administrator:like view_model)
			-- <Precursor>
		do
			adding_model_edit_errors_to_template(a_template, a_administrator)
			if a_administrator.password1.is_empty then
				has_error := True
				adding_error_message_to_template(a_template, False, "password_empty")
			end
		end

	edit_post (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- <Precursor>
		local
			l_template:TEMPLATE_FILE
			l_administrator:ADMINISTRATOR

		do
			if attached login_cookie_manager.login_user (a_request) then
				if attached a_request.form_parameter ("cancel") then
					create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url (url_prefix + "list/"))
				else
					if attached {ADMINISTRATOR_VIEW_MODEL} object_from_form (a_request, view_model , "", "") as la_view_model then
						if attached a_request.form_parameter ("reset") then
							Result := edit_get_with_id(a_request, la_view_model.id)
						else
							create l_template.make_from_file (view_path_prefix + "edit" + view_path_sufix)
							initialize_template (l_template, a_request)
							l_template.add_value (la_view_model, model_name)
							adding_model_edit_errors_to_template(l_template, la_view_model)
							if has_error then
								create {HTML_TEMPLATE_PAGE_RESPONSE} Result.make(l_template)
							else
								l_administrator := model
								la_view_model.fill_administrator(l_administrator)
								administrators_repository.fetch_by_id (l_administrator.id)
								if attached administrators_repository.item as la_item and la_view_model.password1.is_empty then
									l_administrator.set_password(la_item.password)
								end
								l_administrator.save
								create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url (url_prefix + "list/"))
							end
						end
					else
						Result := unmanaged_error (a_request)
					end
				end
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url (login_url))
			end
		end

end
