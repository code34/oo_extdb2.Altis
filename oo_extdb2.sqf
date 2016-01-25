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
		PRIVATE VARIABLE("string", "protocol");
		PRIVATE VARIABLE("string", "sessionid");
		PRIVATE STATIC_VARIABLE("array", "sessions");
		PRIVATE VARIABLE("scalar", "version");

		PUBLIC FUNCTION("STRING", "constructor") {
			
			MEMBER("version", 0.1);
			MEMBER("dllversionrequired", 62);

			private ["_database", "_sessionid"];

			if!(MEMBER("checkExtDB2isLoaded", nil)) exitwith { MEMBER("sendError", "OO_extDB required extDB2 Dll"); };
			if!(MEMBER("checkDllVersion", nil)) exitwith { MEMBER("sendLog", "Required extDB2 Dll version is " + (str MEMBER("dllversionrequired", nil)) + " or higher."); };
			if(isnil MEMBER("sessions", nil)) then { _array = []; MEMBER("sessions", _array;);};
		
			MEMBER("databasename", _this);
			MEMBER("connect", _this);
			MEMBER("generateSessionId", nil);				
		};

		PUBLIC FUNCTION("", "generateSessionId") {
			private ["_sessionid"];
			_sessionid = str(round(random(999999)));
			while { _sessionid in MEMBER("sessions", nil) } do {
				_sessionid = str(round(random(999999)));
				sleep 0.01;
			};
			MEMBER("sessions", nil) pushBack _sessionid;
			MEMBER("sessionid", _sessionid);
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
		
		PUBLIC FUNCTION("", "lock") {
			private ["_result"];
			
			_result = call compile ("extDB2" callExtension "9:LOCK");
			if ((_result select 0) isEqualTo 1) then { MEMBER("sendLog", "Locked"); true; } else { false; };
		};
		
		PUBLIC FUNCTION("", "isLocked") {
			private ["_result"];
			
			_result = call compile ("extDB2" callExtension "9:LOCK_STATUS");		
			if((_result select 0) isEqualTo 1) then { true; } else { false; };
		};
		
		PUBLIC FUNCTION("array", "setDatabaseProtocol") {
			private ["_return", "_result", "_database", "_sessionid", "_protocol", "_protocoloptions"];
	
			_protocol = toUpper(_this select 0); 
			_protocoloptions = _this select 1;
			
			_database = MEMBER("databasename", nil);
			_sessionid = MEMBER("sessionid", nil);

			switch ( _protocol) do { 
				case "SQL_CUSTOM_V2" : { 
					_result = call compile ("extDB2" callExtension format["9:ADD_DATABASE_PROTOCOL:%1:%2:%3:%4", _database, _protocol, _sessionid, "extDB2"]);
				};
				case "SQL_RAW_V2" : { 
					_result = call compile ("extDB2" callExtension format["9:ADD_DATABASE_PROTOCOL:%1:%2:%3:%4", _database, _protocol, _sessionid, _protocoloptions]);
				}; 
				default { 
					_result = [0, "Protocol doesn't exist"];
				}; 
			};
						
			if ((_result select 0) isEqualTo 1) then {
				MEMBER("sendLog", "Protocol loaded - " + _protocol);
				_return = true;
			}else{
				MEMBER("sendError", _result select 1);
				_return = false;
			};		
			_return;
		};
				
		PUBLIC FUNCTION("array", "executeQuery") {
			private["_defaultreturn", "_query", "_queryResult", "_key", "_mode", "_loop"];

			_query = _this select 0;
			_defaultreturn = _this select 1;

			_queryResult = "";

			_mode = 0;

			_key = call compile ("extDB2" callExtension format["%1:%2:%3",_mode, MEMBER("sessionid", nil), _query]);
			if((_key select 0) isEqualTo 2) then {_mode = 2;};

			switch(_mode) do {
				case 0 : {
					_queryResult = _key;
				};
				case 2 : {
					uisleep 0.1;
					_loop = true;
					while{_loop} do {
						_queryResult = "extDB2" callExtension format["4:%1", _key select 1];
						if (_queryResult isEqualTo "[5]") then {
							_queryResult = "";
							while{true} do {
								_pipe = "extDB2" callExtension format["5:%1", _key select 1];
								if(_pipe isEqualTo "") exitWith {_loop = false};
								_queryResult = _queryResult + _pipe;
							};
						}else{
							if (_queryResult isEqualTo "[3]") then {
								uisleep 0.1;
							} else {
								_loop = false;
							};
						};
					};
					_queryResult = call compile _queryResult;
					if(isnil "_queryResult") then { 
						_queryResult = [0, "extDB2: error - return value is not compatible with SQF"];
					};
				};
				default {};
			};
			
			if ((_queryResult select 0) isEqualTo 0) then {
				MEMBER("sendError", (_queryResult select 1) + "-->" + _query);
				_queryResult = [1, _defaultreturn];
			};
			_queryResult select 1;
		};
				
		PRIVATE FUNCTION("string", "connect") {
			private ["_return", "_result"];

			_return = false;	
			_result = call compile ("extDB2" callExtension format["9:ADD_DATABASE:%1", _this]);
			
			if !(isNil "_result") then {
				if ((_result select 0) isEqualTo 1) then {
					MEMBER("sendLog", "Connected to " + _this);
					_return = true;
				}else{
					if(tolower(_result select 1) isEqualTo "already connected to database") then {
						MEMBER("sendLog", "Connected to " + _this);
						_return = true;
					} else {
						MEMBER("sendError", _result select 1);
					};
				};
			}else{
				MEMBER("sendError", "Unable to connect to database - extDB2 locked");
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
			diag_log (format ["extDB2 log: %1", _this]);
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
			DELETE_VARIABLE("protolist");
		};		
		
	ENDCLASS;