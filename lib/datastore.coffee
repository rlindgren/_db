


class Datastore
	@inMemoryOnly = false
	@storage = new window.Storage()
	@autoload = true
	@primaryKey = "_id"
	constructor: (config) ->
		@loaded = false
		@filename = config.filename or throw Error '_db needs a filename'
		@inMemoryOnly = config.inMemoryOnly || Datastore.inMemoryOnly
		@storage = config.storage || Datastore.storage
		@autoload = config.autoload || Datastore.autoload
		@primaryKey = config.primaryKey || Datastore.primaryKey
		@_ = 
			$$primaryKey: @primaryKey
			$$data: []
		@persistance = new window.Persistance(@) if not @inMemoryOnly
		if @persistance and @autoload then @persistance.loadDatabase()

	@config: (opts) ->
		{ @primaryKey, @inMemoryOnly, @storage, @autoload } = opts


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

	wipe: ->
		if not @inMemoryOnly
			@storage.removeFile(@filename)
		@_.$$data = []
		@_.$$indexed = {}

	_insert: () ->
		runInsert = (docs) =>

		Storage.readFile(@filename).then (contents) =>

	_update: () ->

	_remove: () ->

	_addIndex: (conf) ->
		@$$indexes[conf.fieldname] = { unique: !!conf.unique }

@Datastore = Datastore