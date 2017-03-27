note
	description: "[
				application execution
			]"
	date: "$Date: 2016-10-21 10:45:18 -0700 (Fri, 21 Oct 2016) $"
	revision: "$Revision: 99331 $"

class
	LABO_TIMER_ROUTER


inherit
	WSF_FILTERED_ROUTED_EXECUTION
	WSF_ROUTED_URI_TEMPLATE_HELPER


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
			fhdl: WSF_FILE_SYSTEM_HANDLER
		do

			map_uris_template (<<"", "/">>, create {LABORATORIES_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<"/log", "/log/">>, create {LOGIN_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<"/log/{type}", "/log/{type}/">>, create {LOGIN_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<"/log/{type}/{model_id}", "/log/{type}/{model_id}/">>, create {LOGIN_CONTROLLER}, router.methods_GET_POST)
			map_crud("laboratories", create {LABORATORIES_CONTROLLER})
			map_uris_template (<<"/laboratories/{type}/{model_id}/{sub_type}", "/laboratories/{type}/{model_id}/{sub_type}/">>, create {LABORATORIES_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<"/laboratories/{type}/{model_id}/{sub_type}/{sub_model_id}", "/laboratories/{type}/{model_id}/{sub_type}/{sub_model_id}/">>, create {LABORATORIES_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<"/labo/{model_id}", "/labo/{model_id}/">>, create {EXECUTION_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<"/labo/{model_id}/{type}", "/labo/{model_id}/{type}/">>, create {EXECUTION_CONTROLLER}, router.methods_GET_POST)
			map_uris_template (<<"/labo/{model_id}/{type}/{sub_type}/{sub_model_id}", "/labo/{model_id}/{type}/{sub_type}/{sub_model_id}/">>, create {EXECUTION_CONTROLLER}, router.methods_GET_POST)
			map_crud("users", create {USERS_CONTROLLER})
			map_crud("administrators", create {ADMINISTRATORS_CONTROLLER})

			create fhdl.make_hidden ("www")
			fhdl.set_directory_index (<<"index.html">>)
			router.handle ("/www", fhdl, router.methods_GET)
		end

	map_crud(a_name:STRING_8; a_handler: WSF_URI_TEMPLATE_HANDLER)
		do
			map_uris_template (<<"/" + a_name, "/" + a_name + "/">>, a_handler, router.methods_GET_POST)
			map_uris_template (<<"/" + a_name + "/{type}", "/" + a_name + "/{type}/">>, a_handler, router.methods_GET_POST)
			map_uris_template (<<"/" + a_name + "/{type}/{model_id}", "/" + a_name + "/{type}/{model_id}/">>, a_handler, router.methods_GET_POST)
		end

	map_uris_template(a_templates: ARRAY[STRING_8]; a_handler: WSF_URI_TEMPLATE_HANDLER; a_request_methods: detachable WSF_REQUEST_METHODS)
		do
			across create {ARRAYED_LIST[STRING_8]}.make_from_array (a_templates) as la_templates loop
				map_uri_template (la_templates.item, a_handler, a_request_methods)
			end
		end

end
