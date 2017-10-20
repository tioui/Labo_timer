note
	description: "Manager of the database in the system"
	author: "Louis Marchand"
	date: "2014, September 29"
	revision: "1.0"

class
	DATABASE_ACCESS

inherit
	HANDLE_USE
		export
			{ANY} is_database_set
		end
	DISPOSABLE

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization of `Current'
		require
			Is_Set:is_database_set
		do
			create database_session.make
			database_format := handle.database.db_format
			create last_id_selector.make
		end

feature -- Access

	connect
			-- Connect the `database_session'
		require
			Not_Connected: not database_session.is_connected
			Has_Base: database_session.is_database_set
		do
			database_session.connect
			if is_connected then
				last_id_selector.set_query ("SELECT LAST_INSERT_ID()")
			end
		end

	is_connected:BOOLEAN
			-- `Current' has connected correctly
		do
			Result := database_session.is_connected
		end

	database_session: DB_CONTROL
			-- Manage the connection session of the database

	database_format:DATABASE_FORMAT[DATABASE]
			-- Use to retreive database specific format

	last_inserted_id:INTEGER
			-- The unique autoincrement identifier of the last inserted object in the database.
		require
			Is_Connected: is_connected
		local
			l_tuple:DB_TUPLE
		do
			last_id_selector.execute_query
			if last_id_selector.is_ok then
				last_id_selector.load_result
				if attached last_id_selector.cursor as la_result then
					create l_tuple.copy(la_result)
					if l_tuple.count > 0 and then
							attached l_tuple.item (1) as la_item and then
							la_item.out.is_integer then
						Result := la_item.out.to_integer
					end
				end
			end
			last_id_selector.terminate
		end

feature {NONE} -- Implementation

	last_id_selector:DB_SELECTION
			-- Precompile selector to retreive the `last_inserted_id'

	dispose
			-- <Precursor>
		do
			if database_session.is_connected then
				database_session.disconnect
			end
		end

feature -- Constants

	Default_Query_allocation_size:INTEGER = 255
			-- The number of character to initialize when crating query

end
