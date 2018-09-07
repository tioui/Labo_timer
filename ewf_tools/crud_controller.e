note
	description: "[
				A {CONTROLLER} that manage the create, read,
				update and delete of a {MODEL}
			]"
	author: "Louis Marchand"
	date: "Sun, 02 Apr 2017 21:53:15 +0000"
	revision: "0.1"

deferred class
	CRUD_CONTROLLER

inherit
	CONTROLLER
		rename
			view_path_extension as view_path_sufix
		redefine
			make_with_response_method_map_size, initialize_template
		end

feature {NONE} -- Initialization

	make_with_response_method_map_size(a_size:INTEGER)
			-- <Precursor>
		do
			Precursor(a_size + 5)
			response_method_map.put ([agent list_get, void], "")
			response_method_map.put ([agent list_get, void], "list")
			response_method_map.put ([agent create_get, agent create_post], "create")
			response_method_map.put ([agent edit_get, agent edit_post], "edit")
			response_method_map.put ([agent remove_get, agent remove_post], "remove")
		end

feature {NONE} -- Implementation

	login_cookie_manager:LOGIN_COOKIE_MANAGER
			-- The cookie manager that manage login
		deferred
		end

	model:MODEL
			-- The {MODEL} used in `Current'
		deferred
		end

	view_model:VIEW_MODEL
			-- The {VIEW_MODEL} associate with `Current'
		deferred
		end

	model_name:READABLE_STRING_8
			-- The name of the {MODEL} used in `Current'
		deferred
		end

	model_repository:MODEL_REPOSITORY
			-- The {REPOSITORY} managing {MODEL} used in `Current'
		deferred
		end

	model_collection_name:READABLE_STRING_8
			-- The name of a collection of {MODEL} used in `Current'
		do
			Result := model_name + "s"
		end

	login_url:READABLE_STRING_8
			-- The name of a collection of {MODEL} used in `Current'
		do
			Result := "/log/in/"
		end

	url_prefix:READABLE_STRING_8
			-- The name of a collection of {MODEL} used in `Current'
		do
			Result := "/" + model_collection_name + "/"
		end

	view_path_prefix:READABLE_STRING_GENERAL
			-- The name of a collection of {MODEL} used in `Current'
		do
			Result := model_name + "_"
		end

	initialize_template(a_template:TEMPLATE_FILE; a_request: WSF_REQUEST)
			-- Initialize the common values in `a_template'.
			-- `a_request' is used to get the script url
		do
			Precursor(a_template, a_request)
			a_template.add_value (view_path_prefix, "views_path")
		end

	list_get (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the 'list' page
		local
			l_template:TEMPLATE_FILE
			l_view_model:like view_model
			l_view_models:LINKED_LIST[like view_model]
		do
			if attached login_cookie_manager.login_user (a_request) then
				create l_template.make_from_file (view_path_prefix + "list" + view_path_sufix)
				initialize_template (l_template, a_request)
				create l_view_models.make
				model_repository.fetch_all
				across model_repository.items.twin as la_items loop
					l_view_model := view_model
					l_view_model.make(la_items.item)
					l_view_models.extend(l_view_model)
				end
				l_template.add_value (l_view_models, model_collection_name)
				create {HTML_TEMPLATE_PAGE_RESPONSE} Result.make(l_template)
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (script_url (a_request, login_url))
			end
		end

	create_get (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the 'create' page
		local
			l_template:TEMPLATE_FILE
		do
			if attached login_cookie_manager.login_user (a_request) then
				l_template := create_template(a_request, view_model)
				create {HTML_TEMPLATE_PAGE_RESPONSE} Result.make(l_template)
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (script_url (a_request, login_url))
			end
		end

	create_template(a_request: WSF_REQUEST; a_model:like view_model):TEMPLATE_FILE
			-- Create a 'create' {TEMPLATE_FILE} file presenting `a_model'
		do
			create Result.make_from_file (view_path_prefix + "edit" + view_path_sufix)
			initialize_template (Result, a_request)
			Result.add_value (a_model, model_name)
			Result.add_value (True, "create")
		end

	adding_model_edit_errors_to_template(a_template:TEMPLATE_FILE; a_view_model:like view_model)
			-- Look for `a_view_model' edition fields validity and add errors messages in `a_template' if needed
		deferred
		end

	adding_model_create_errors_to_template(a_template:TEMPLATE_FILE; a_view_model:like view_model)
			-- Look for `a_view_model' creation fields validity and add errors messages in `a_template' if needed
		do
			adding_model_edit_errors_to_template(a_template, a_view_model)
		end

	has_error:BOOLEAN
			-- An error has been detected o the last call of `adding_model_errors_to_template'

	create_post (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the POST `a_request' of the 'create' page
		local
			l_template:TEMPLATE_FILE
			l_model:like model

		do
			if attached login_cookie_manager.login_user (a_request) then
				if attached a_request.form_parameter ("reset") then
					Result := create_get(a_request)
				elseif attached a_request.form_parameter ("cancel") then
					create {WSF_REDIRECTION_RESPONSE} Result.make (script_url (a_request, url_prefix + "list/"))
				else
					if attached {like view_model} object_from_form (a_request, view_model , "", "") as la_view_model then
						l_template := create_template(a_request, la_view_model)
						adding_model_create_errors_to_template(l_template, la_view_model)
						if has_error then
							create {HTML_TEMPLATE_PAGE_RESPONSE} Result.make(l_template)
						else
							l_model := model
							la_view_model.fill_model(l_model)
							l_model.save
							create {WSF_REDIRECTION_RESPONSE} Result.make (script_url (a_request, url_prefix + "list/"))
						end
					else
						Result := unmanaged_error (a_request)
					end
				end
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (script_url (a_request, login_url))
			end
		end

	edit_get (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the 'edit' page
		do
			if attached login_cookie_manager.login_user (a_request) then
				if attached request_model_id(a_request) as la_id then
					Result := edit_get_with_id(a_request, la_id.item)
				else
					Result := object_not_found (a_request)
				end
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (script_url (a_request, login_url))
			end
		end

	edit_get_with_id(a_request: WSF_REQUEST; a_id:INTEGER): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the 'edit' page using `a_id' as `id' for the edited {MODEL}
		local
			l_template:TEMPLATE_FILE
			l_view_model:like view_model
		do
			model_repository.fetch_by_id (a_id)
			if attached model_repository.item as la_model then
				create l_template.make_from_file (view_path_prefix + "edit" + view_path_sufix)
				initialize_template (l_template, a_request)
				l_view_model := view_model
				l_view_model.make(la_model)
				l_template.add_value (l_view_model, model_name)
				create {HTML_TEMPLATE_PAGE_RESPONSE} Result.make(l_template)
			else
				Result := object_not_found (a_request)
			end
		end

	edit_post (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the POST `a_request' of the 'edit' page
		local
			l_template:TEMPLATE_FILE
			l_model:like model

		do
			if attached login_cookie_manager.login_user (a_request) then
				if attached a_request.form_parameter ("cancel") then
					create {WSF_REDIRECTION_RESPONSE} Result.make (script_url (a_request, url_prefix + "list/"))
				else
					if attached {like view_model} object_from_form (a_request, view_model , "", "") as la_view_model then
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
								l_model := model
								la_view_model.fill_model(l_model)
								l_model.save
								create {WSF_REDIRECTION_RESPONSE} Result.make (script_url (a_request, url_prefix + "list/"))
							end
						end
					else
						Result := unmanaged_error (a_request)
					end
				end
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (script_url (a_request, login_url))
			end
		end


	remove_get (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the 'remove' page
		local
			l_template:TEMPLATE_FILE
			l_view_model: like view_model
		do
			if attached login_cookie_manager.login_user (a_request) then
				if attached request_model_id(a_request) as la_id then
					model_repository.fetch_by_id (la_id.item)
					if attached model_repository.item as la_model then
						create l_template.make_from_file (view_path_prefix + "remove" + view_path_sufix)
						initialize_template (l_template, a_request)
						l_view_model := view_model
						l_view_model.make(la_model)
						l_template.add_value (l_view_model, model_name)
						create {HTML_TEMPLATE_PAGE_RESPONSE} Result.make(l_template)
					else
						Result := object_not_found (a_request)
					end
				else
					Result := object_not_found (a_request)
				end
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (script_url (a_request, login_url))
			end
		end

	remove_post (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the POST `a_request' of the 'remove' page
		local
			l_model:like model

		do
			if attached login_cookie_manager.login_user (a_request) then
				if attached a_request.form_parameter ("cancel") then
					create {WSF_REDIRECTION_RESPONSE} Result.make (script_url (a_request, url_prefix + "list/"))
				else
					if attached {like view_model} object_from_form (a_request, view_model , "", "") as la_view_model then
						l_model := model
						la_view_model.fill_model (l_model)
						l_model.delete
						create {WSF_REDIRECTION_RESPONSE} Result.make (script_url (a_request, url_prefix + "list/"))
					else
						Result := unmanaged_error (a_request)
					end
				end
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (script_url (a_request, login_url))
			end
		end

end
