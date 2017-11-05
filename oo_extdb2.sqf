	/*
	Authors: 
	Code34 <nicolas_boiteux@yahoo.fr>
	Aloe <itfruit@mail.ru>
	
	Copyright (C) 2016-2018

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
			DEBUG(#, "OO_extDB2::constructor")
			private _databasename = param [0, "", [""]];
			private _filenamestatement = param [1, "extDB2", [""]];
			MEMBER("version", 0.1);
			MEMBER("dllversionrequired", 62);
			if!(MEMBER("checkExtDB2isLoaded", nil)) exitwith { MEMBER("sendError", "OO_extDB2 required extDB2 Dll"); };
			if!(MEMBER("checkDllVersion", nil)) exitwith { MEMBER("sendLog", "Required extDB2 Dll version is " + (str MEMBER("dllversionrequired", nil)) + " or higher."); };
			if(isnil MEMBER("sessions", nil)) then { MEMBER("sessions", [];) ;};
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
			DEBUG(#, "OO_extDB2::generateSessionId")
			private _sessionid = str(round(random(999999))) + str(round(random(999999)));
			while { _sessionid in MEMBER("sessions", nil) } do {
				_sessionid = str(round(random(999999))) + str(round(random(999999)));
				sleep 0.01;
			};
			MEMBER("sessions", nil) pushBack _sessionid;
			MEMBER("sessionid", _sessionid);
			_sessionid;
		};

		PUBLIC FUNCTION("", "getSessionId") {
			DEBUG(#, "OO_extDB2::getSessionId")
			MEMBER("sessionid", nil);
		};

		PUBLIC FUNCTION("string", "existsSessionId") {
			DEBUG(#, "OO_extDB2E::existsSessionId")
			if(_this in MEMBER("sessions", nil)) then { true; } else { false; };
		};

		PUBLIC FUNCTION("", "checkDllVersion") {
			DEBUG(#, "OO_extDB2E::checkDllVersion")
			if(MEMBER("getDllVersion", nil) > MEMBER("dllversionrequired", nil)) then { true;} else {false;};
		};

		PUBLIC FUNCTION("", "checkExtDB2isLoaded") {
			DEBUG(#, "OO_extDB2E::checkExtDB2isLoaded")	
			if(MEMBER("getDllVersion", nil) == 0) then { false; } else { true;};
		};

		PUBLIC FUNCTION("", "getVersion") {
			DEBUG(#, "OO_extDB2E::getVersion")
			 format["OO_extDB2: %1 Dll: %2", MEMBER("getDllVersion", nil), MEMBER("version", nil)];
		};

		/*
		Lock mode
		Parameters: none
		Return : true is success
		*/		
		PUBLIC FUNCTION("", "lock") {
			DEBUG(#, "OO_extDB2E::lock")
			private _result = call compile ("extDB2" callExtension "9:LOCK");
			if ((_result select 0) isEqualTo 1) then { MEMBER("sendLog", "Locked"); true; } else { false; };
		};
		
		/*
		Check if mode is locked
		Parameters: none
		Return : true is success
		*/
		PUBLIC FUNCTION("", "isLocked") {
			DEBUG(#, "OO_extDB2E::isLocked")
			private _result = call compile ("extDB2" callExtension "9:LOCK_STATUS");		
			if((_result select 0) isEqualTo 1) then { true; } else { false; };
		};


		/*
		Set the filename of prepared statements (without .ini extension)
		The filename should be in @extDB2\extDB\sql_custom_v2\ path

		Example can be found at this place
		https://github.com/Torndeco/extDB2/blob/master/examples/sql_custom_v2/example.ini
		*/
		PUBLIC FUNCTION("string", "setStatementFileName") {
			DEBUG(#, "OO_extDB2E::setStatementFileName")
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
			DEBUG(#, "OO_extDB2E::setMode")
			private _mode = toUpper(param [0, "", [""]]);
			private _modeoptions = param [1, "", [""]];
			private _database = MEMBER("databasename", nil);
			private _sessionid = MEMBER("generateSessionId", nil);
			private _filename = "";
			private _result = [0,[]];
			private _return = false;

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
			if(isNil "_result") then { _result = [0,"No database avalaible"];};

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
			DEBUG(#, "OO_extDB2E::executeQuery")
			private _query = param [0, "", [""]];
			private _defaultreturn = param [1, "", ["", true, 0, []]];
			private _result = _defaultreturn;
			private _mode = 0;
			private _key = call compile ("extDB2" callExtension format["%1:%2:%3",_mode, MEMBER("sessionid", nil), _query]);
			private _loop = 0;
			private _pipe = "";

			if((_key select 0) isEqualTo 2) then {_mode = 2;};
			switch(_mode) do {
				case 0 : { _result = _key; };
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
			DEBUG(#, "OO_extDB2E::connect")
			private _return = false;	
			private _result = call compile ("extDB2" callExtension format["9:ADD_DATABASE:%1", _this]);
		
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
			DEBUG(#, "OO_extDB2E::testConnexion")
			private _array = ["SQLQUERY", "ADD_QUOTES"];
			MEMBER("setMode", _array);
			_array = ["SELECT date('now');", []];
			private _return = false;
			if(MEMBER("executeQuery", _array)  isEqualTo 0) then { _return = false; };
			_return;
		};

		PUBLIC FUNCTION("", "disconnect") {
			DEBUG(#, "OO_extDB2E::disconnect")
		};

		PUBLIC FUNCTION("", "isconnected") {
			DEBUG(#, "OO_extDB2E::isconnected")
		};		
				
		PRIVATE FUNCTION("", "getDllVersion") {
			DEBUG(#, "OO_extDB2E::getDllVersion")
			private _version = "extDB2" callExtension "9:VERSION";
			if(_version isequalto "") then {
				_version = 0;
			} else {
				_version = parsenumber _version;
			};
			_version;
		};
				
		PRIVATE FUNCTION("string", "sendLog") {
			DEBUG(#, "OO_extDB2E::sendLog")
			diag_log (format ["extDB2 Log: %1", _this]);
		};
		
		PRIVATE FUNCTION("string", "sendError") {
			DEBUG(#, "OO_extDB2E::sendError")
			private _error = format["extDB2 Error: %1", _this];
			_error call BIS_fnc_error;
			diag_log _error;
		};

		PUBLIC FUNCTION("", "deconstructor") {
			DEBUG(#, "OO_extDB2E::deconstructor")
			private _temp = MEMBER("sessions", nil) - [MEMBER("sessionid", nil)];
			MEMBER("sessions", _temp);
			DELETE_VARIABLE("sessionid");
			DELETE_VARIABLE("dllversionrequired");
			DELETE_VARIABLE("databasename");
			DELETE_VARIABLE("filenamestatement");
			DELETE_VARIABLE("version");
		};		
		
	ENDCLASS;