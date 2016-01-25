	//Run examples
	call compile preprocessFileLineNumbers "oo_extdb2.sqf";

	_extdb2 = ["new",  "test_database"] call OO_extDB2;

	//["setDatabaseProtocol", ["SQL_RAW_V2", "ADD_QUOTES"]] call _extdb2;
	//_query = "INSERT INTO test_table_1 (some_string, some_not_null_string, some_float,some_text) VALUES ('MAS IMPORT BB', 'NO NULL AA', 214, 'HIHA POEME')";
	//_query = "SELECT some_integer, some_string, some_not_null_string, some_float,some_text FROM test_table_1 where id = 3630";
	//_query = "SELECT * FROM test_table_1";
	//_result = ["sendRequest", [0, _query]] call _extdb2;	
	//hint format ["SQL_RAW_V2: %1", _result];

	sleep 2;

	["setDatabaseProtocol", ["SQL_CUSTOM_V2", "/"]] call _extdb2;	
	_result = ["executeQuery", ["Player_GetByUID2", []]] call _extdb2; 
	hint format ["SQL_CUSTOM_V2: %1", _result];

	

		


		



