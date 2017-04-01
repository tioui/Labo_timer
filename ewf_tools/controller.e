note
	description: "Manage every site request"
	author: "Louis Marchand"
	date: "2014, September 29"
	revision: "1.0"

deferred class
	CONTROLLER

inherit
	WSF_URI_TEMPLATE_RESPONSE_HANDLER
		redefine
			response,
			default_create
		end

feature {NONE} -- Initialization

	default_create
			-- Initialization of `Current'
		do
			create response_method_map.make (3)
			response_method_map.compare_objects
		end

feature -- Access

	response_method_map:HASH_TABLE[TUPLE[
										get_method: detachable FUNCTION[WSF_REQUEST, WSF_RESPONSE_MESSAGE];
										post_method: detachable FUNCTION[WSF_REQUEST, WSF_RESPONSE_MESSAGE]
									], READABLE_STRING_GENERAL]
			-- Mapper for all GET and POST methods of every request `request_type'.

	response (a_request: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Generate the message (page) for the specified `request_type' of `a_request`
		do
			if attached request_type(a_request) as la_type then
				response_method_map.search (la_type)
				if response_method_map.found and then attached response_method_map.found_item as la_item then
					Result := launch_method(a_request, la_item)
				else
					Result := argument_not_valid_response(a_request, la_type)
				end
			else
				response_method_map.search ("")
				if response_method_map.found and then attached response_method_map.found_item as la_item then
					Result := launch_method(a_request, la_item)
				else
					Result := argument_not_found_response(a_request)
				end
			end

		end

feature {NONE} -- Implementation

	initialize_template(a_template:TEMPLATE_FILE; a_request: WSF_REQUEST)
		do
			a_template.add_value (a_request.script_url (""), "script_url")
		end

	launch_method(
					a_request: WSF_REQUEST;
					a_methods: TUPLE[
						get_method: detachable FUNCTION[WSF_REQUEST, WSF_RESPONSE_MESSAGE];
						post_method: detachable FUNCTION[WSF_REQUEST, WSF_RESPONSE_MESSAGE]
					]
				): WSF_RESPONSE_MESSAGE
			-- Launch the correct `a_methods' depending on the GET or POST status of `a_request'.
		do
			if a_request.is_request_method ("GET") and then attached a_methods.get_method as la_method then
				Result := la_method.item(a_request)
			elseif a_request.is_request_method ("POST") and then attached a_methods.post_method as la_method then
				Result := la_method.item(a_request)
			else
				Result := unsupported_method_response(a_request, attached a_methods.get_method, attached a_methods.post_method)
			end
		end

	request_type(a_request: WSF_REQUEST):detachable READABLE_STRING_8
			-- Type of `a_request'
		do
			if attached a_request.path_parameter ("type") as l_type then
				Result := l_type.string_representation.as_string_8.as_lower
			end
		end

	request_model_id(a_request: WSF_REQUEST):detachable CELL[INTEGER]
			-- Type of `a_request'
		local
			l_model_id_text:READABLE_STRING_GENERAL
		do
			if attached a_request.path_parameter ("model_id") as la_model_id then
				l_model_id_text := la_model_id.string_representation.as_string_8
				if l_model_id_text.is_integer then
					create Result.put (l_model_id_text.to_integer)
				end
			end
		end

	argument_not_valid_response (a_request: WSF_REQUEST; a_argument: READABLE_STRING_GENERAL): WSF_PAGE_RESPONSE
			-- Page to show when a path `a_argument' in `a_request' is not valid
		do
			create Result.make
			Result.set_status_code ({HTTP_STATUS_CODE}.bad_request)
			Result.put_string (a_request.request_uri + ": Argument " + a_argument + " not valid.")
		end

	unauthorized_response (a_request: WSF_REQUEST): WSF_PAGE_RESPONSE
			-- Page to show when the user doe's not have access to `a_request'
		do
			create Result.make
			Result.set_status_code ({HTTP_STATUS_CODE}.forbidden)
			Result.put_string ("Unauthorized access.")
		end

	argument_not_found_response (a_request: WSF_REQUEST): WSF_PAGE_RESPONSE
			-- Page to show when an argument is needed in `a_request'but not found
		do
			create Result.make
			Result.set_status_code ({HTTP_STATUS_CODE}.bad_request)
			Result.put_string (a_request.request_uri + ": Argument needed.")
		end

	unsupported_method_response (a_request: WSF_REQUEST; is_get_method, is_post_method:BOOLEAN): WSF_PAGE_RESPONSE
			-- Page to show when the method of `a_request' is not valid. This `a_request' manage only a GET method
			-- when `is_get_method' is set and POST method when `is_post_method' is set.
		local
			l_methods:STRING_8
		do
			create Result.make
			Result.set_status_code ({HTTP_STATUS_CODE}.bad_request)
			create l_methods.make_empty
			if is_get_method then
				l_methods.append ("GET")
			end
			if is_post_method then
				if not l_methods.is_empty then
					l_methods.append (" and ")
				end
				l_methods.append ("POST")
			end
			if not is_get_method and not is_post_method then
				l_methods.append ("no")
			end
			Result.put_string (a_request.request_uri + " only support: " + l_methods + " methods; " + a_request.request_method + " is not supported.")
		end

	object_not_found (a_request: WSF_REQUEST): WSF_PAGE_RESPONSE
			-- Page to show when the object requested by `a_request' is not found
		do
			create Result.make
			Result.set_status_code ({HTTP_STATUS_CODE}.not_found)
			Result.put_string ("This page is not valid or has been deleted.")
		end

	unmanaged_error (a_request: WSF_REQUEST): WSF_PAGE_RESPONSE
			-- Page to show when an unmanaged error occured
		do
			create Result.make
			Result.set_status_code ({HTTP_STATUS_CODE}.bad_request)
			Result.put_string (a_request.request_uri + ": An unmanaged error occured.")
		end

	adding_error_message_to_template(a_template:TEMPLATE_FILE;a_condition:BOOLEAN; a_error_key:READABLE_STRING_GENERAL)
			-- If `a_condition' is `False', put `a_error_key' in `a_template'
		do
			if not a_condition then
				a_template.add_value (True, a_error_key)
			end
		end

	object_from_form(a_request:WSF_REQUEST; a_object:ANY;a_prefix, a_sufix:READABLE_STRING_GENERAL):detachable ANY
			-- Generate a {MODEL} object base on `a_object' from the form parameter of `a_request' using `a_prefix' and
			-- `a_sufix' to complete the parameters name.
		local
			l_result:ANY
			l_reflexion:REFLECTED_REFERENCE_OBJECT
			l_error:BOOLEAN
			l_field_name, l_parameter:READABLE_STRING_GENERAL
			l_type_id, l_field_type, l_string_type:INTEGER
			l_constants:REFLECTOR_CONSTANTS
		do
			if a_request.is_request_method ("POST") then
				l_error := False
				l_result := a_object.twin
				create l_reflexion.make (l_result)
				l_type_id := l_reflexion.dynamic_type
				create l_constants
				across (1 |..| l_reflexion.field_count) as la_index loop
					create {STRING_8}l_field_name.make_from_c ({ISE_RUNTIME}.field_name_of_type (la_index.item, l_type_id))
					l_field_type := l_reflexion.field_type (la_index.item)
					if attached a_request.form_parameter (a_prefix + l_field_name + a_sufix) as la_parameter then
						l_parameter := la_parameter.string_representation
						if l_field_type = l_constants.integer_8_type and l_parameter.is_integer_8 then
							l_reflexion.set_integer_8_field (la_index.item, l_parameter.to_integer_8)
						elseif l_field_type = l_constants.integer_16_type and l_parameter.is_integer_16 then
							l_reflexion.set_integer_16_field (la_index.item, l_parameter.to_integer_16)
						elseif l_field_type = l_constants.integer_32_type and l_parameter.is_integer_32 then
							l_reflexion.set_integer_32_field (la_index.item, l_parameter.to_integer_32)
						elseif l_field_type = l_constants.integer_64_type and l_parameter.is_integer_64 then
							l_reflexion.set_integer_64_field (la_index.item, l_parameter.to_integer_64)
						elseif l_field_type = l_constants.natural_8_type and l_parameter.is_natural_8 then
							l_reflexion.set_natural_8_field (la_index.item, l_parameter.to_natural_8)
						elseif l_field_type = l_constants.natural_16_type and l_parameter.is_natural_16 then
							l_reflexion.set_natural_16_field (la_index.item, l_parameter.to_natural_16)
						elseif l_field_type = l_constants.natural_32_type and l_parameter.is_natural_32 then
							l_reflexion.set_natural_32_field (la_index.item, l_parameter.to_natural_32)
						elseif l_field_type = l_constants.natural_64_type and l_parameter.is_natural_64 then
							l_reflexion.set_natural_64_field (la_index.item, l_parameter.to_natural_64)
						elseif l_field_type = l_constants.real_32_type and l_parameter.is_real_32 then
							l_reflexion.set_real_32_field (la_index.item, l_parameter.to_real_32)
						elseif l_field_type = l_constants.real_64_type and l_parameter.is_real_64 then
							l_reflexion.set_real_64_field (la_index.item, l_parameter.to_real_64)
						elseif l_field_type = l_constants.reference_type then
							l_string_type := {ISE_RUNTIME}.field_static_type_of_type (la_index.item, l_type_id)
							if {ISE_RUNTIME}.type_conforms_to (Immutable_string_32_dtype, {ISE_RUNTIME}.detachable_type (l_string_type)) then
								l_reflexion.set_reference_field (la_index.item, create {IMMUTABLE_STRING_8}.make_from_string (l_parameter.as_string_8))
							elseif {ISE_RUNTIME}.type_conforms_to (Immutable_string_8_dtype, {ISE_RUNTIME}.detachable_type (l_string_type)) then
								l_reflexion.set_reference_field (la_index.item, create {IMMUTABLE_STRING_32}.make_from_string (l_parameter.as_string_32))
							elseif {ISE_RUNTIME}.type_conforms_to (string_32_dtype, {ISE_RUNTIME}.detachable_type (l_string_type)) then
								l_reflexion.set_reference_field (la_index.item, create {STRING_8}.make_from_string (l_parameter.as_string_8))
							elseif {ISE_RUNTIME}.type_conforms_to (string_8_dtype, {ISE_RUNTIME}.detachable_type (l_string_type)) then
								l_reflexion.set_reference_field (la_index.item, create {STRING_32}.make_from_string (l_parameter.as_string_32))
							end
						end
					end
				end
				if not l_error then
					Result := l_result
				end

			end
		end

	Immutable_string_8_dtype: INTEGER_32
			-- Dynamic type of IMMUTABLE_STRING_8
		local
			l_s: IMMUTABLE_STRING_8
			l_reflexion:REFLECTED_REFERENCE_OBJECT
		once
			create l_s.make_empty
			create l_reflexion.make (l_s)
			Result := l_reflexion.dynamic_type
		end

	Immutable_string_32_dtype: INTEGER_32
			-- Dynamic type of IMMUTABLE_STRING_32
		local
			l_s: IMMUTABLE_STRING_32
			l_reflexion:REFLECTED_REFERENCE_OBJECT
		once
			create l_s.make_empty
			create l_reflexion.make (l_s)
			Result := l_reflexion.dynamic_type
		end

	string_8_dtype: INTEGER_32
			-- Dynamic type of STRING_8
		local
			l_s: STRING_8
			l_reflexion:REFLECTED_REFERENCE_OBJECT
		once
			create l_s.make_empty
			create l_reflexion.make (l_s)
			Result := l_reflexion.dynamic_type
		end

	string_32_dtype: INTEGER_32
			-- Dynamic type of TRING_32
		local
			l_s: STRING_32
			l_reflexion:REFLECTED_REFERENCE_OBJECT
		once
			create l_s.make_empty
			create l_reflexion.make (l_s)
			Result := l_reflexion.dynamic_type
		end

end
