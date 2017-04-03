note
	description: "CRUD controller for {USER}."
	author: "Louis Marchand"
	date: "Fri, 10 Feb 2017 18:53:38 +0000"
	revision: "0.1"

class
	USERS_CONTROLLER

inherit
	CRUD_CONTROLLER
		rename
			model_repository as users_repository,
			login_cookie_manager as administrator_cookie_manager
		end
	LOGIN_COOKIE_MANAGER_SHARED
		undefine
			default_create
		end
	VIEWS_SHARED
		undefine
			default_create
		end

feature {NONE} -- Implementation

	model_name:READABLE_STRING_8
			-- <Precursor>
		once
			Result := "user"
		end

	model:USER
			-- <Precursor>
		do
			Result := users_repository.create_new
		end

	view_model:USER_VIEW_MODEL
			-- <Precursor>
		do
			create Result
		end

	adding_model_edit_errors_to_template(a_template:TEMPLATE_FILE; a_user:like view_model)
			-- <Precursor>
		do
			has_error := not a_user.is_valid
			adding_error_message_to_template(a_template, a_user.is_user_name_valid, "user_name_not_valid")
			adding_error_message_to_template(a_template, a_user.is_first_name_valid, "first_name_not_valid")
			adding_error_message_to_template(a_template, a_user.is_last_name_valid, "last_name_not_valid")
			users_repository.fetch_by_user_name (a_user.user_name)
			if attached users_repository.item as la_item and then a_user.id /= la_item.id then
				has_error := True
				adding_error_message_to_template(a_template, False, "user_name_not_unique")
			end
		end

end
