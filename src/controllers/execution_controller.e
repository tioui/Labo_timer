note
	description: "Manage the execution of a laboratory"
	author: "Louis Marchand"
	date: "Mon, 27 Mar 2017 18:49:52 +0000"
	revision: "0.1"

class
	EXECUTION_CONTROLLER

inherit
	CONTROLLER
		redefine
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
			create response_method_map.make (5)
			response_method_map.compare_objects
			response_method_map.put ([agent guest_get, void], "")
			response_method_map.put ([agent guest_raise_get, void], "raise")
			response_method_map.put ([agent guest_lower_get, void], "lower")
			response_method_map.put ([agent guest_is_raised_get, void], "is_raised")
			response_method_map.put ([agent admin_get, void], "admin")
		end


feature {NONE} -- Implementation

	guest_get (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the execution guest view page
		local
			l_template:TEMPLATE_FILE
			l_count:INTEGER
		do
			if attached {USER} user_cookie_manager.login_user (a_request) as la_user then
				if attached request_model_id (a_request) as la_id then
					laboratories_repository.fetch_by_id (la_id.item)
					if attached  laboratories_repository.item as la_laboratory then
						if la_laboratory.is_presently_executing then
							create l_template.make_from_file (views_path + "/labo_exec.tpl")
							initialize_template (l_template, a_request)
							l_template.add_value (la_laboratory, "laboratory")
							if has_intervention(la_user, la_laboratory)  then
								l_template.add_value (True, "is_raised")
							end
							l_count := 0
							across la_laboratory.interventions as la_interventions loop
								if la_interventions.item.start_time > la_interventions.item.end_time then
									l_count := l_count + 1
								end
							end
							l_template.add_value (l_count, "nb_questions")
							create {HTML_TEMPLATE_PAGE_RESPONSE} Result.make(l_template)
						else
							Result := argument_not_valid_response (a_request, la_laboratory.id.out)
						end

					else
						Result := object_not_found (a_request)
					end
				else
					Result := argument_not_found_response (a_request)
				end
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url ("/log/labo/2"))
			end
		end

	guest_is_raised_get (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the ajax GET `a_request'.
			-- Put `1' in `Result' if the current {USER} `has_intervention' in the {LABORATORY} and `0' if not
		local
			l_result:INTEGER
		do
			if attached {USER} user_cookie_manager.login_user (a_request) as la_user then
				if attached request_model_id (a_request) as la_id then
					laboratories_repository.fetch_by_id (la_id.item)
					if attached  laboratories_repository.item as la_laboratory then
						if la_laboratory.is_presently_executing and has_intervention(la_user, la_laboratory)  then
							l_result := 1
						else
							l_result := 0
						end
						create {WSF_PAGE_RESPONSE} Result.make_with_body (l_result.out)
					else
						Result := object_not_found (a_request)
					end
				else
					Result := argument_not_found_response (a_request)
				end
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url ("/log/labo/2"))
			end
		end

	guest_raise_get (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' when a guest is raising hand
		local
			l_intervention:INTERVENTION
		do
			if attached {USER} user_cookie_manager.login_user (a_request) as la_user then
				if attached request_model_id (a_request) as la_id then
					laboratories_repository.fetch_by_id (la_id.item)
					if attached  laboratories_repository.item as la_laboratory then
						if la_laboratory.is_presently_executing then
							if not has_intervention(la_user, la_laboratory)  then
								create l_intervention
								l_intervention.set_laboratory (la_laboratory)
								l_intervention.set_user (la_user)
								l_intervention.save
							end
							create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url ("/labo/2"))
						else
							Result := argument_not_valid_response (a_request, la_laboratory.id.out)
						end
					else
						Result := object_not_found (a_request)
					end
				else
					Result := argument_not_found_response (a_request)
				end
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url ("/log/labo/2"))
			end
		end

	guest_lower_get (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' when a guest is lowering hand
		local
			l_interventions:LIST[INTERVENTION]
			l_found:BOOLEAN
			l_now:TIME
		do
			if attached {USER} user_cookie_manager.login_user (a_request) as la_user then
				if attached request_model_id (a_request) as la_id then
					laboratories_repository.fetch_by_id (la_id.item)
					if attached  laboratories_repository.item as la_laboratory then
						if la_laboratory.is_presently_executing then
							l_interventions := la_laboratory.interventions
							from
								l_interventions.start
								l_found := False
							until
								l_interventions.exhausted or
								l_found
							loop
								if
									attached l_interventions.item.user as la_intervention_user and then
									(la_intervention_user.id = la_user.id and
									l_interventions.item.start_time > l_interventions.item.end_time)
								then
									create l_now.make_now
									if l_now <= l_interventions.item.start_time then
										l_interventions.item.set_start_time (l_now + create {TIME_DURATION}.make (0, 0, -1))
									end
									l_interventions.item.set_end_time (l_now)
									l_interventions.item.save
									l_found := True
								end
								l_interventions.forth
							end
							create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url ("/labo/2"))
						else
							Result := argument_not_valid_response (a_request, la_laboratory.id.out)
						end
					else
						Result := object_not_found (a_request)
					end
				else
					Result := argument_not_found_response (a_request)
				end
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url ("/log/labo/2"))
			end
		end

	has_intervention(a_user:USER; a_laboratory:LABORATORY):BOOLEAN
			-- Check if `a_user' has an active {INTERVENTION} in `a_laboratory'
		do
			Result := across a_laboratory.interventions as la_interventions some
							attached la_interventions.item.user as la_user and then la_user.id = a_user.id and la_interventions.item.is_active
						end
		end

	admin_get (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the execution admin view page
		local
			l_template:TEMPLATE_FILE
		do
			if attached a_request.path_parameter ("sub_type") as la_type and then la_type.string_representation.as_lower.as_string_8 ~ "answering" then
				Result := admin_answering_get(a_request)
			elseif attached a_request.path_parameter ("sub_type") as la_type and then la_type.string_representation.as_lower.as_string_8 ~ "update_interventions" then
				Result := admin_update_interventions_get(a_request)
			else
				if attached administrator_cookie_manager.login_user (a_request) then
					if attached request_model_id (a_request) as la_id then
						laboratories_repository.fetch_by_id (la_id.item)
						if attached  laboratories_repository.item as la_laboratory then
							create l_template.make_from_file (views_path + "/labo_admin.tpl")
							initialize_template (l_template, a_request)
							l_template.add_value (la_laboratory, "laboratory")
							l_template.add_value (a_request.absolute_script_url ("/labo/" + la_laboratory.id.out), "participations_link")
							l_template.add_value (table_interventions_table(la_laboratory), "table_interventions")
							create {HTML_TEMPLATE_PAGE_RESPONSE} Result.make(l_template)
						else
							Result := object_not_found (a_request)
						end
					else
						Result := argument_not_found_response (a_request)
					end
				else
					create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url ("/log/in"))
				end
			end
		end

	admin_update_interventions_get (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET of the AJAX `a_request' to get the `table_interventions_table'
		local
			l_interventions_table:STRING_8
			l_utf_converter:UTF_CONVERTER
		do
			if attached administrator_cookie_manager.login_user (a_request) then
				if attached request_model_id (a_request) as la_id then
					laboratories_repository.fetch_by_id (la_id.item)
					if attached  laboratories_repository.item as la_laboratory then
						create l_utf_converter

						l_interventions_table := table_interventions_table(la_laboratory)
						create {WSF_PAGE_RESPONSE} Result.make_with_body (l_utf_converter.string_32_to_utf_8_string_8 (l_interventions_table))
					else
						Result := argument_not_valid_response (a_request, la_id.item.out)
					end
				else
					Result := argument_not_found_response (a_request)
				end
			else
				Result := unauthorized_response(a_request)
			end
		end

	admin_answering_get (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Manage the GET `a_request' of the execution admin view page
		local
			l_id_string:READABLE_STRING_GENERAL
			l_id:INTEGER
			l_now:TIME
		do
			if attached administrator_cookie_manager.login_user (a_request) then
				if
					attached a_request.path_parameter ("sub_model_id") as la_intervention_id and
					attached request_model_id (a_request) as la_laboratory_id
				then
					l_id_string := la_intervention_id.string_representation
					if l_id_string.is_integer then
						l_id := l_id_string.to_integer
						interventions_repository.fetch_by_id (l_id)
						if
							attached interventions_repository.item as la_intervention and then
							(la_intervention.start_time > la_intervention.end_time and
							(attached la_intervention.laboratory as la_laboratory and then la_laboratory.id = la_laboratory_id.item))
						then
							create l_now.make_now
							if l_now <= la_intervention.start_time then
								la_intervention.set_start_time (l_now + create {TIME_DURATION}.make (0, 0, -1))
							end
							la_intervention.set_end_time (l_now)
							la_intervention.save
						end
						create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url ("/labo/" + la_laboratory_id.item.out + "/admin"))
					else
						Result := argument_not_valid_response (a_request, l_id_string)
					end
				else
					Result := argument_not_found_response (a_request)
				end
			else
				create {WSF_REDIRECTION_RESPONSE} Result.make (a_request.script_url ("/log/in"))
			end
		end

	table_interventions_table(a_laboratory:LABORATORY):STRING_8
			-- Generate the view table of `a_laboratory'.`intervention'
		local
			l_template:TEMPLATE_FILE
			l_interventions:ARRAYED_LIST[INTERVENTION_VIEW_MODEL]
		do
			create l_template.make_from_file (views_path + "/labo_admin_table.tpl")
			create l_interventions.make (a_laboratory.interventions.count)
			across a_laboratory.interventions as la_interventions loop
				if la_interventions.item.start_time > la_interventions.item.end_time then
					l_interventions.extend (create {INTERVENTION_VIEW_MODEL}.make (la_interventions.item))
				end
			end
			l_template.add_value (l_interventions, "interventions")
			l_template.analyze
			l_template.get_output
			if attached l_template.output as la_output then
				Result := la_output
			else
				Result := ""
			end

		end


end
