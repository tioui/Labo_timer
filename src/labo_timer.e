note
	description: "Root class of the application"
	author: "Louis Marchand"
	date: "Sun, 02 Apr 2017 21:53:15 +0000"
	revision: "0.1"
class
	LABO_TIMER


inherit
	WSF_LAUNCHABLE_SERVICE
		redefine
			initialize
		end
	APPLICATION_LAUNCHER [LABO_TIMER_ROUTER]
	DATABASE_APPL [MYSQL]
        rename
            login as database_login,
            set_application as set_database_schema,
            set_base as set_database_base
        end
    VIEWS_SHARED
    DATABASE_ACCESS_SHARED
    REPOSITORIES_SHARED
    SHARED_TEMPLATE_CONTEXT


create
	make_and_launch

feature {NONE} -- Initialization

	initialize
			-- Initialize current service.
		do
			Precursor
			load_configuration_file("/etc/labo_timer/config.ini")
			load_configuration_file("config.ini")
			from
				configurations.start
			until
				configurations.after
			loop
				configurations.forth
			end
			initialize_database
			initialize_template_context
		end

	load_configuration_file(a_filename:READABLE_STRING_GENERAL)
			-- Load the configuration file `a_filename' in `configuration' and `service_options'
		local
			f: PLAIN_TEXT_FILE
			l, v: STRING_8
			p: INTEGER_32
		do
			create f.make_with_name (a_filename)
			if f.exists and f.is_readable then
				f.open_read
				from
					f.read_line
				until
					f.exhausted
				loop
					l := f.last_string
					l.left_adjust
					if not l.is_empty and then l [1] /= '#' then
						p := l.index_of ('=', 1)
						if p > 1 then
							v := l.substring (p + 1, l.count)
							l.keep_head (p - 1)
							v.left_adjust
							v.right_adjust
							l.right_adjust
							set_option (l.as_lower, v)
						end
					end
					f.read_line
				end
				f.close
			end
		end

	initialize_database
			-- Initialize the database
		local
			l_user_name, l_password:STRING_8
		do
			if
				(attached {READABLE_STRING_GENERAL} configurations.at ("database_schema") as la_database_schema and
				attached {READABLE_STRING_GENERAL} configurations.at ("database_user") as la_database_user and
				attached {READABLE_STRING_GENERAL} configurations.at ("database_password") as la_database_password) and then
				(la_database_schema.is_valid_as_string_8 and la_database_user.is_valid_as_string_8 and la_database_password.is_valid_as_string_8)
			then
				l_user_name := la_database_user.to_string_8
				l_password := la_database_password.to_string_8
				if db_spec.user_name_ok (l_user_name) and db_spec.password_ok (l_password) then
					database_login (la_database_user.as_string_8, la_database_password.as_string_8)
					set_database_schema (la_database_schema.as_string_8)
					set_database_base
					database_access.connect
				end
				if not is_database_set or else not database_access.is_connected then
					if is_verbose then
						io.error.put_string ("Cannot initialize MySQL Database. Check that the information in the 'config.ini' file are valid.")
					end
				end
			else
				if is_verbose then
					io.error.put_string ("Cannot initialize MySQL Database. Check that the information in the 'config.ini' file are valid.")
				end
			end
		end

	initialize_template_context
			-- Initialize the `views_path' in the `Template_context'
		local
			l_path:PATH
		do
			create l_path.make_from_string (views_path)
			template_context.set_template_folder (l_path)
		end


feature {NONE} -- Implementation

	set_option(a_name: READABLE_STRING_GENERAL; a_value: detachable ANY)
			-- Add options in `configurations' and in `service_options'
		do
			set_service_option(a_name, a_value)
			configurations.force (a_value, a_name)
		end

end
