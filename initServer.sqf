	call compile preprocessFileLineNumbers "oo_extdb2.sqf";

	sleep 2;

	/*
	_extdb2 = ["new",  ["test_database"]] call OO_extDB2;
	["setMode", ["SQLQUERY"]] call _extdb2;
	_query = "SELECT * FROM test_table_1";
	_result = ["executeQuery", [_query, []]] call _extdb2;	
	hint format ["SQL QUERY: %1", _result];
	*/


	/*
	Example with a PREPARED STATEMENT

	_extdb2 = ["new",  ["test_database", "extDB2"]] call OO_extDB2;

	["setMode", ["PREPAREDSTATEMENT"]] call _extdb2;

	_result = ["executeQuery", ["Player_GetByUID2", []]] call _extdb2; 

	hint format ["PREPARED STATEMENT: %1", _result];
	*/

	

		


		



