	/*
	Authors: 
	Code34 <nicolas_boiteux@yahoo.fr>
	Aloe <itfruit@mail.ru>
	
	Copyright (C) 2016

	CLASS OO_extDB2 -  Class for connect to extDB2, send requests, get responses

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>. 
	*/
	
	#include "oop.h"

	CLASS("OO_extDB2")
		
		PRIVATE VARIABLE("scalar", "dllversionrequired");
		PRIVATE VARIABLE("string", "databasename");
		PRIVATE VARIABLE("string", "sessionid");
		PRIVATE VARIABLE("string", "filenamestatement");
		PRIVATE STATIC_VARIABLE("array", "sessions");
		PRIVATE VARIABLE("scalar", "version");

		/*
		Instanciate OO_extDB2

		params:
		_this select 0 : string - name of the dabase
		_this select 1 : string - name of the file containing the SQL prestatement without .ini extension (by default extDB2)

		return : nothing
		*/
		PUBLIC FUNCTION("array", "constructor") {	
			private ["_databasename", "_filenamestatement"];

			_databasename = param [0, "", [""]];
			_filenamestatement = param [1, "extDB2", [""]];

			MEMBER("version", 0.1);
			MEMBER("dllversionrequired", 62);

			if!(MEMBER("checkExtDB2isLoaded", nil)) exitwith { MEMBER("sendError", "OO_extDB2 required extDB2 Dll"); };
			if!(MEMBER("checkDllVersion", nil)) exitwith { MEMBER("sendLog", "Required extDB2 Dll version is " + (str MEMBER("dllversionrequired", nil)) + " or higher."); };
			if(isnil MEMBER("sessions", nil)) then { _array = []; MEMBER("sessions", _array;);};
		
			MEMBER("databasename", _databasename);
			MEMBER("filenamestatement", _filenamestatement);
			MEMBER("connect", _databasename);
		};

		/*
		Generate a unique session id. Unique session id is require when changing mode
		Parameters: none
		Return : string - sessionid
		*/
		PUBLIC FUNCTION("", "generateSessionId") {
			private ["_sessionid"];
			_sessionid = str(round(random(999999))) + str(round(random(999999)));
			while { _sessionid in MEMBER("sessions", nil) } do {
				_sessionid = str(round(random(999999))) + str(round(random(999999)));
				sleep 0.01;
			};
			MEMBER("sessions", nil) pushBack _sessionid;
			MEMBER("sessionid", _sessionid);
			_sessionid;
		};

		PUBLIC FUNCTION("", "getSessionId") {
			MEMBER("sessionid", nil);
		};

		PUBLIC FUNCTION("string", "existsSessionId") {
			if(_this in MEMBER("sessions", nil)) then { true; } else { false; };
		};

		PUBLIC FUNCTION("", "checkDllVersion") {
			if(MEMBER("getDllVersion", nil) > MEMBER("dllversionrequired", nil)) then { true;} else {false;};
		};

		PUBLIC FUNCTION("", "checkExtDB2isLoaded") {
			if(MEMBER("getDllVersion", nil) == 0) then { false; } else { true;};
		};

		PUBLIC FUNCTION("", "getVersion") {
			 format["OO_extDB2: %1 Dll: %2", MEMBER("getDllVersion", nil), MEMBER("version", nil)];
		};

		/*
		Lock mode
		Parameters: none
		Return : true is success
		*/		
		PUBLIC FUNCTION("", "lock") {
			private ["_result"];
			
			_result = call compile ("extDB2" callExtension "9:LOCK");
			if ((_result select 0) isEqualTo 1) then { MEMBER("sendLog", "Locked"); true; } else { false; };
		};
		
		/*
		Check if mode is locked
		Parameters: none
		Return : true is success
		*/
		PUBLIC FUNCTION("", "isLocked") {
			private ["_result"];
			
			_result = call compile ("extDB2" callExtension "9:LOCK_STATUS");		
			if((_result select 0) isEqualTo 1) then { true; } else { false; };
		};


		/*
		Set the filename of prepared statements (without .ini extension)
		The filename should be in @extDB2\extDB\sql_custom_v2\ path

		Example can be found at this place
		https://github.com/Torndeco/extDB2/blob/master/examples/sql_custom_v2/example.ini
		*/
		PUBLIC FUNCTION("string", "setStatementFileName") {
			MEMBER("filenamestatement", _this);
		};

		/*
		Set the option for prepared statements 

		/*
		setMode
		Parameters: 
			_this select 0 : string "PREPAREDSTATEMENT"|"SQLQUERY"
				SQLQUERY : standard sql query
				PREPAREDSTATEMENT : prepared sql queries in ini files
			_this select 1 : string
		Return : true is success
		*/
		PUBLIC FUNCTION("array", "setMode") {
			private ["_filename", "_return", "_result", "_database", "_sessionid", "_mode", "_modeoptions"];
	
			_mode = toUpper(param [0, "", [""]]);
			_modeoptions = param [1, "", [""]];
			
			_database = MEMBER("databasename", nil);
			_sessionid = MEMBER("generateSessionId", nil);

			switch ( _mode) do { 
				case "PREPAREDSTATEMENT" : { 
					_filename = MEMBER("filenamestatement", nil);
					_result = call compile ("extDB2" callExtension format["9:ADD_DATABASE_PROTOCOL:%1:SQL_CUSTOM_V2:%2:%3", _database, _sessionid,  _filename, _modeoptions]);
				};
				case "SQLQUERY" : { 
					_modeoptions = "ADD_QUOTES";
					_result = call compile ("extDB2" callExtension format["9:ADD_DATABASE_PROTOCOL:%1:SQL_RAW_V2:%2:%3", _database, _sessionid, _modeoptions]);
				}; 
				default { 
					_result = [0, format["Mode: %1 invalid. Expected Mode : PREPAREDSTATEMENT or  SQLQUERY", _mode]];
				}; 
			};
						
			if ((_result select 0) isEqualTo 1) then {
				MEMBER("sendLog", "Mode: " + _mode);
				_return = true;
			}else{
				MEMBER("sendError", _result select 1);
				_return = false;
			};		
			_return;
		};


		/*
		Execute SQL query or Prepared Statement
		Parameter: array
			_this select 0 : string - name of preparered statement or sql query
			_this select 1 : any - return default value if nothing is found in db or error happen

		return : value from db or default value
		*/		
		PUBLIC FUNCTION("array", "executeQuery") {
			private["_defaultreturn", "_query", "_result", "_key", "_mode", "_loop", "_pipe"];
		
			_query = param [0, "", [""]];
			_defaultreturn = param [1, "", ["", true, 0, []]];
		
			_result = _defaultreturn;
			_mode = 0;

			_key = call compile ("extDB2" callExtension format["%1:%2:%3",_mode, MEMBER("sessionid", nil), _query]);
			if((_key select 0) isEqualTo 2) then {_mode = 2;};

			switch(_mode) do {
				case 0 : {
					_result = _key;
				};
				case 2 : {
					_loop = true;
					while { _loop } do {
						_result = "extDB2" callExtension format["4:%1", _key select 1];
						switch (true) do {
							case (_result isEqualTo "[3]") : { uiSleep 0.1; };

							case (_result isEqualTo "[5]") : {
								_pipe = "go";
								_result = "";
								while{ !(_pipe isEqualTo "") } do {
									_pipe = "extDB2" callExtension format["5:%1", _key select 1];
									_result = _result + _pipe;
								};
								_loop= false;
							};
							default {_loop = false;};
						};
					};
					_result = call compile _result;
					if(isnil "_result") then { 
						_result = [0, "Return value is not compatible with SQF"];
					};
				};
				default {
					_result = [0, "Mode is not compatible with OO_extDB2"];
				};
			};
			
			if ((_result select 0) isEqualTo 0) then {
				MEMBER("sendError", (_result select 1) + "-->" + _query);
				_result = [0, _defaultreturn];
			};
			_result select 1;
		};
		
		/*
		Connect to Database
		parameter: string - name of database
		return : nothing
		*/
		PRIVATE FUNCTION("string", "connect") {
			private ["_return", "_result"];

			_return = false;	
			_result = call compile ("extDB2" callExtension format["9:ADD_DATABASE:%1", _this]);
		
			if !(isNil "_result") then {
				if ((_result select 0) isEqualTo 1) then {
					_return = MEMBER("testConnexion", nil);
				}else{
					if(tolower(_result select 1) isEqualTo "already connected to database") then {
						_return = MEMBER("testConnexion", nil);
					} ;
				};
			};

			if(_return) then {
				MEMBER("sendLog", "Connected to " + _this);
			} else {
				MEMBER("sendError", "Unable to connect to database");
			};
		};

		PRIVATE FUNCTION("", "testConnexion") {
			private ["_array", "_return"];
			
			_array = ["SQLQUERY", "ADD_QUOTES"];
			MEMBER("setMode", _array);
			_array = ["SELECT date('now');", []];
			
			if(MEMBER("executeQuery", _array)  isEqualTo 0) then {
				_return = false;
			} else {
				_return = true;
			};
			_return;
		};

		PUBLIC FUNCTION("", "disconnect") {

		};

		PUBLIC FUNCTION("", "isconnected") {

		};		
				
		PRIVATE FUNCTION("", "getDllVersion") {
			private ["_version"];
			_version = "extDB2" callExtension "9:VERSION";
			if(_version isequalto "") then {
				_version = 0;
			} else {
				_version = parsenumber _version;
			};
			_version;
		};
				
		PRIVATE FUNCTION("string", "sendLog") {
			diag_log (format ["extDB2 Log: %1", _this]);
		};
		
		PRIVATE FUNCTION("string", "sendError") {
			private ["_error"];
			_error = format["extDB2 Error: %1", _this];
			_error call BIS_fnc_error;
			diag_log _error;
		};

		PUBLIC FUNCTION("", "deconstructor") {
			private ["_temp"];
			_temp = MEMBER("sessions", nil) - [MEMBER("sessionid", nil)];
			MEMBER("sessions", _temp);
			DELETE_VARIABLE("sessionid");
			DELETE_VARIABLE("dllversionrequired");
			DELETE_VARIABLE("databasename");
			DELETE_VARIABLE("filenamestatement");
			DELETE_VARIABLE("version");
		};		
		
	ENDCLASS;