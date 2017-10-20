note
	description: "Used to route Web request (URI) to the correct {CONTROLLER}"
	author: "Louis Marchand"
	date: "Sun, 02 Apr 2017 21:53:15 +0000"
	revision: "0.1"

class
	LABO_TIMER_ROUTER


inherit
	WSF_FILTERED_ROUTED_EXECUTION
	WSF_ROUTED_URI_TEMPLATE_HELPER
	CONFIGURATION_SHARED


create
	make

feature {NONE} -- Initialization



feature -- Filter

	create_filter
			-- Create `filter'
		do
				--| Example using Maintenance filter.
			create {WSF_MAINTENANCE_FILTER} filter
		end

	setup_filter
			-- Setup `filter'
		local
			f: like filter
		do
			create {WSF_CORS_FILTER} f
			f.set_next (create {WSF_LOGGING_FILTER})

				--| Chain more filters like {WSF_CUSTOM_HEADER_FILTER}, ...
				--| and your owns filters.

			filter.append (f)
		end


feature -- Router

	setup_router
			-- Setup `router'
		local
			l_file_handler: WSF_FILE_SYSTEM_HANDLER
			l_prefix:STRING_8
		do
			if
				attached {READABLE_STRING_GENERAL} configurations.at ("uri_prefix") as la_uri_prefix and then
				la_uri_prefix.is_string_8
			then
				l_prefix := la_uri_prefix.to_string_8
			else
				l_prefix := ""
			end
			map_uris_template (<<l_prefix, l_prefix + "/">>, create {LABORATORIES_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<l_prefix + "/log", l_prefix + "/log/">>, create {LOGIN_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<l_prefix + "/log/{type}", l_prefix + "/log/{type}/">>, create {LOGIN_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<l_prefix + "/log/{type}/{model_id}", l_prefix + "/log/{type}/{model_id}/">>, create {LOGIN_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<l_prefix + "/laboratories/{type}/{model_id}/{sub_type}", l_prefix + "/laboratories/{type}/{model_id}/{sub_type}/">>, create {LABORATORIES_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<l_prefix + "/laboratories/{type}/{model_id}/{sub_type}/{sub_model_id}", l_prefix + "/laboratories/{type}/{model_id}/{sub_type}/{sub_model_id}/">>, create {LABORATORIES_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<l_prefix + "/groups/{type}/{model_id}/{sub_type}", l_prefix + "/groups/{type}/{model_id}/{sub_type}/">>, create {GROUPS_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<l_prefix + "/groups/{type}/{model_id}/{sub_type}/{sub_model_id}", l_prefix + "/groups/{type}/{model_id}/{sub_type}/{sub_model_id}/">>, create {GROUPS_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<l_prefix + "/labo/{model_id}", l_prefix + "/labo/{model_id}/">>, create {EXECUTION_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<l_prefix + "/labo/{model_id}/{type}", l_prefix + "/labo/{model_id}/{type}/">>, create {EXECUTION_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<l_prefix + "/labo/{model_id}/{type}/{sub_type}/{sub_model_id}", l_prefix + "/labo/{model_id}/{type}/{sub_type}/{sub_model_id}/">>, create {GROUPS_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<l_prefix + "/labo/{model_id}/{type}/{sub_type}", l_prefix + "/labo/{model_id}/{type}/{sub_type}/">>, create {EXECUTION_CONTROLLER}, router.methods_GET_POST)
			map_crud(l_prefix, "laboratories", create {LABORATORIES_CONTROLLER})
			map_crud(l_prefix, "users", create {USERS_CONTROLLER})
			map_crud(l_prefix, "groups", create {GROUPS_CONTROLLER})
			map_crud(l_prefix, "administrators", create {ADMINISTRATORS_CONTROLLER})

			if attached {READABLE_STRING_GENERAL} configurations.at ("public_directory") as la_public_directory then
				create l_file_handler.make_hidden (la_public_directory)
			else
				create l_file_handler.make_hidden ("www")
			end
			l_file_handler.set_directory_index (<<"index.html">>)
			router.handle (l_prefix + "/www", l_file_handler, router.methods_GET)
		end

	map_crud(a_prefix, a_name:STRING_8; a_handler: WSF_URI_TEMPLATE_HANDLER)
			-- Map a standard CRUD router line
		do
			map_uris_template (<<a_prefix + "/" + a_name, a_prefix + "/" + a_name + "/">>, a_handler, router.methods_GET_POST)
			map_uris_template (<<a_prefix + "/" + a_name + "/{type}", a_prefix + "/" + a_name + "/{type}/">>, a_handler, router.methods_GET_POST)
			map_uris_template (<<a_prefix + "/" + a_name + "/{type}/{model_id}", a_prefix + "/" + a_name + "/{type}/{model_id}/">>, a_handler, router.methods_GET_POST)
		end

	map_uris_template(a_templates: ARRAY[STRING_8]; a_handler: WSF_URI_TEMPLATE_HANDLER; a_request_methods: detachable WSF_REQUEST_METHODS)
			-- Map `a_templates' router lines to `a_handler' handeling `a_request_methods'
		do
			across create {ARRAYED_LIST[STRING_8]}.make_from_array (a_templates) as la_templates loop
				map_uri_template (la_templates.item, a_handler, a_request_methods)
			end
		end

end
