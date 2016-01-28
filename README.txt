	Description:
	CLASS OO_extDB2 - A driver for extdb2

	Authors:  
	code34 nicolas_boiteux@yahoo.fr
	Aloe <itfruit@mail.ru>

	Copyright (C) 2016 Nicolas BOITEUX 
	
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

	How to install:
	1- Install the extDB2 addons: https://github.com/Torndeco/extDB2/releases
		move "@extDB2" folder  into your ARMA3 root directory
		move tbbmalloc.dll into the ARMA3 root directory
		create @extDB2/extDB/ directory
	2- Configure @extDB2/extdb-conf.ini with the type, name of your database / login / password / port etc 
	3- if you use prepared statement queries (recommanded instead standard sql queries)
		1 - create the @extDB2/extDB/sql_custom_v2 directory
		2 - put in this directory, the file from : https://github.com/Torndeco/extDB2/blob/master/examples/sql_custom_v2/example.ini
		3 - rename it like "extDB2.ini"
		4 - configure it
	4- if use :
		sqlite: create the  @extDB2/extDB/sqlite directory
			1 - put your sqlite db file inside
		mysql: your database should be installed and configured
	4- put the "oo_extDB2.sqf" and the "oop.h" files in your mission directory
	5- put this code once into your mission init.sqf :
		call compilefinal preprocessFileLineNumbers "oo_extDB2.sqf";

	Change log:
		V 0.1 : first release

