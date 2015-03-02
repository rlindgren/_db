#!/usr/bin/env node

var chance = require('chance')()
	, fs = require('fs')
	, path = require('path')
	, _ = require('lodash')
	;

var NEWLINE = "\n";
var DELIMITER = "--";
var PRIMARYKEY = "Id";

var filePath = './test/helpers/persistanceData.txt';
var contents = '{ "$$primaryKey" : "'+PRIMARYKEY+'"}'+NEWLINE+DELIMITER

_.range(100).forEach(function (i) {
	var res = {
		name: chance.name(),
		age: chance.age()
	};
	res[PRIMARYKEY] = String(i);
	contents += NEWLINE + JSON.stringify(res);
});

fs.writeFileSync(filePath, contents);