
class Storage
	constructor: ->


	readFile: (filename) ->
		localStorage.getItem filename

	writeFile: (filename, contents) ->
		localStorage.setItem filename, contents

	removeFile: (filename, contents) ->
		localStorage.removeItem filename

@Storage = Storage