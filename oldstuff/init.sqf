	//Run examples
	call compile preprocessFileLineNumbers "oo_extdb2.sqf";

	_extdb2 = ["new",  "test_database"] call OO_extDB2;

	//["setDatabaseProtocol", ["SQL_RAW_V2", "ADD_QUOTES"]] call _extdb2;
	//_query = "INSERT INTO test_table_1 (some_string, some_not_null_string, some_float,some_text) VALUES ('MAS IMPORT BB', 'NO NULL AA', 214, 'HIHA POEME')";
	//_query = "SELECT some_integer, some_string, some_not_null_string, some_float,some_text FROM test_table_1 where id = 3630";
	// _result = ["sendRequest", [0, _query]] call _extdb2;	
	// hint format ["SQL_RAW_V2: %1", _result];

	sleep 2;

	["setDatabaseProtocol", ["SQL_CUSTOM_V2", "/"]] call _extdb2;
	_result = ["sendRequest", [0, "test_getraw_byid:9"]] call _extdb2; 
	hint format ["SQL_CUSTOM_V2: %1", _result];

	sleep 1000;

private["_database","_protocol","_protocol_options","_return","_result","_random_number","_extDB_SQL_CUSTOM_ID"];

_database = "test_database";
_protocol = "SQL_RAW_V2";
_protocol_options = "ADD_QUOTES";

_return = false;

if ( isNil {uiNamespace getVariable "extDB_SQL_CUSTOM_ID"}) then
{
	// extDB Version
	_result = "extDB2" callExtension "9:VERSION";

	diag_log format ["extDB2: Version: %1", _result];
	if(_result == "") exitWith {diag_log "extDB2: Failed to Load"; false};
	//if ((parseNumber _result) < 20) exitWith {diag_log "Error: extDB version 20 or Higher Required";};

	// extDB Connect to Database
	_result = call compile ("extDB2" callExtension format["9:ADD_DATABASE:%1", _database]);
	if (_result select 0 isEqualTo 0) exitWith {diag_log format ["extDB2: Error Database: %1", _result]; false};
	diag_log "extDB2: Connected to Database";

	// Generate Randomized Protocol Name
	_random_number = round(random(999999));
	_extDB_SQL_CUSTOM_ID = str(_random_number);
	extDB_SQL_CUSTOM_ID = compileFinal _extDB_SQL_CUSTOM_ID;

	// extDB Load Protocol
	_result = call compile ("extDB2" callExtension format["9:ADD_DATABASE_PROTOCOL:%1:%2:%3:%4", _database, _protocol, _extDB_SQL_CUSTOM_ID, _protocol_options]);
	if ((_result select 0) isEqualTo 0) exitWith {diag_log format ["extDB2: Error Database Setup: %1", _result]; false};

	diag_log format ["extDB2: Initalized %1 Protocol", _protocol];

	// extDB2 Lock
	"extDB2" callExtension "9:LOCK";
	diag_log "extDB2: Locked";

	// Save Randomized ID
	uiNamespace setVariable ["extDB_SQL_CUSTOM_ID", _extDB_SQL_CUSTOM_ID];
	_return = true;
}
else
{
	extDB_SQL_CUSTOM_ID = compileFinal str(uiNamespace getVariable "extDB_SQL_CUSTOM_ID");
	diag_log "extDB2: Already Setup";
	_return = true;
};

_return	