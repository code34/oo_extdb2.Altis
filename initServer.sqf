	//Run examples
	call compile preprocessFileLineNumbers "oo_extdb2.sqf";

	_extdb2 = ["new",  "test_database"] call OO_extDB2;

	sleep 2;
	
	//_defaultreturn = [];
	//["setMode", ["SQLQUERY", "ADD_QUOTES"]] call _extdb2;
	//_query = "INSERT INTO test_table_1 (some_string, some_not_null_string, some_float,some_text) VALUES ('MAS IMPORT BB', 'NO NULL AA', 214, 'HIHA POEME')";
	//_query = "SELECT some_integer, some_string, some_not_null_string, some_float,some_text FROM test_table_1 where id = 3630";
	//_query = "SELECT * FROM test_table_1";
	//_result = ["executeQuery", [_query, _defaultreturn]] call _extdb2;	
	//hint format ["SQLQUERY: %1", _result];

	["setMode", ["PREPAREDSTATEMENT", "/"]] call _extdb2;
	_defaultreturn = [];
	_result = ["executeQuery", ["Player_GetByUID2", _defaultreturn]] call _extdb2; 
	hint format ["PREPAREDSTATEMENT: %1", _result];

	

		


		



