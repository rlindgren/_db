_ = require 'lodash'

class Storage
	constructor: ->

	readFile: (filename) ->
		localStorage.getItem filename

	writeFile: (filename, contents) ->
		localStorage.setItem filename contents
