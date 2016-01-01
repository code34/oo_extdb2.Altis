	/*
	Author: code34 nicolas_boiteux@yahoo.fr
	Copyright (C) 2013-2016 Nicolas BOITEUX

	CLASS OO_EXTDB2
	
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

	CLASS("OO_EXTDB2")
		PRIVATE VARIABLE("string","dbname");
		PRIVATE VARIABLE("string","version");
		PRIVATE VARIABLE("string", "separator");
	
		PUBLIC FUNCTION("string","constructor") {
			MEMBER("version", "0.1");
			MEMBER("setDbName", _this);
			MEMBER("getSeparator", nil);
		};

		PUBLIC FUNCTION("string", "setDbName") {
			private ["_dbname"];
			_dbname = _this;
			if(_dbname == "") then {
				_dbname = "default";
			};
			MEMBER("dbname", _dbname);
		};

		PUBLIC FUNCTION("string", "setSeparator") {
			private ["_separator"];
			_separator = MEMBER("getSeparator", nil);
			"inidbi2" callExtension format["setseparator%1%2", _separator, _this];
			_separator = MEMBER("getSeparator", nil);
		};

		PUBLIC FUNCTION("", "getSeparator") {
			private ["_separator"];
			_separator = "inidbi2" callExtension "getseparator";
			MEMBER("separator", _separator);
			_separator;
		};

		PUBLIC FUNCTION("", "getDbName") {
			MEMBER("dbname", nil);
		};		

		PRIVATE FUNCTION("", "getFileName") {

		};

		PUBLIC FUNCTION("string", "encodeBase64") {

		};

		PUBLIC FUNCTION("string", "decodeBase64") {
		};

		PUBLIC FUNCTION("", "getTimeStamp") {
		};

		PUBLIC FUNCTION("", "getVersion") {
			private["_data"];
			_data = "extDB2" callExtension "9:VERSION";
			_data = format["OO_extdb2: %1 Dll: %2", MEMBER("version", nil), _data];
			_data;
		};

		// Get all tables name
		PUBLIC FUNCTION("", "getSections") {

		};

		PUBLIC FUNCTION("string", "log") {
			hint format["%1", _this];
			diag_log format["%1", _this];
		};

		// Check if DB exists
		// Return True if yes
		PUBLIC FUNCTION("", "exists") {
			private["_database"];
			_database = MEMBER("dbname", nil);
			_result = call compile ("extDB2" callExtension format["9:ADD_DATABASE:%1", _database]);
			if ((_result select 0) isEqualTo 0)  then { false; } else { true;};
		};

		// Delete DB
		PUBLIC FUNCTION("", "delete") {

		};

		// Delete a key - value
		PUBLIC FUNCTION("array", "deleteKey") {

		};		

		// Delete a table
		PUBLIC FUNCTION("string", "deleteSection") {

		};

		// Read a key - value
		PUBLIC FUNCTION("array", "read") {

		};

		// Check Type in array content
		PRIVATE FUNCTION("array", "parseArray"){
			private ["_data", "_exit", "_array"];

			_exit = _this select 0;
			_data = _this select 1;

			{
				if!(typename _x in ["BOOL", "ARRAY", "STRING", "SCALAR"]) then { _exit = true; };
				if(typename _x == "ARRAY") then { 
					_array = [_exit, _x];
					_exit = MEMBER("parseArray", _array); 
				};
				sleep 0.0001;
			}foreach _data;
			_exit;
		};

		// Write a key - value
		PUBLIC FUNCTION("array", "write") {
			
		};

		PUBLIC FUNCTION("","deconstructor") { 
			DELETE_VARIABLE("version");
			DELETE_VARIABLE("dbname");
			DELETE_VARIABLE("separator");
		};
	ENDCLASS;