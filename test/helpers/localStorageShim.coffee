class Storage
	constructor: (prepopulate) ->
		@store = if prepopulate then prepopulate else {};
	
	getItem: (key) ->
		@store[key]

	setItem: (key, value) ->
		@store[key] = JSON.stringify value

	removeItem: (key) ->
		delete @store[key]

	clear: ->
		@store = {}

module.exports = Storage