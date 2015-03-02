Q = require 'q'
_ = require 'lodash'
Storage = require './storage'

class Datastore
	@inMemoryOnly = false
	@storageAdapter = Storage
	@autoload = true
	@primaryKey = "_id"
	constructor: (config) ->
		@loaded = false
		@filename = config.filename or throw Error '_db needs a filename'
		@inMemoryOnly = config.inMemoryOnly || Datastore.inMemoryOnly
		@storageAdapter = config.storageAdapter || Datastore.storageAdapter
		@autoload = config.autoload || Datastore.autoload
		@primaryKey = config.primaryKey || Datastore.primaryKey
		@_ = 
			$$primaryKey: @primaryKey
			$$data: []
		@persistance = new Persistance(@) if not @inMemoryOnly
		@persistance?.loadDatabase() if @autoload

	@config: (opts) ->
		{ @primaryKey, @inMemoryOnly, @storageAdapter, @autoload } = opts


	find: (query) ->
		
	findOne: (query) ->
		

	insert: (docs, modifier, events) ->
		@_.$$data.push()
		buffer = Storage.readFile @filename

	update: (query, doc, modifier,  events) -> 
		

	remove: (query, modifier, events) -> 
		Storage.flush()

	insertAll: (data, events) -> 
		Storage.flush()

	updateAll: (data, events) -> 
		Storage.flush()

	removeAll: (data, events) -> 
		data.map @remove.bind(@)

	_insert: () ->
		runInsert = (docs) =>

		Storage.readFile(@filename).then (contents) =>

	_update: () ->

	_remove: () ->

	_addIndex: (conf) ->
		@$$indexes[conf.fieldname] = { unique: !!conf.unique }

module.exports = Datastore