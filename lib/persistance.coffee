
class Persistance
	DELIMITER = "--"
	NEWLINE = "\n"
	NEWLINE_RE = new RegExp NEWLINE, 'g'
	REPEATED_NEWLINES_RE = new RegExp NEWLINE+'{2,}', 'g'
	constructor: (@db) ->

	loadDatabase: () ->
		if not @db.inMemoryOnly
			buffer = @db.storage.readFile @db.filename
			JSONBUFFER = @bufferToJson(buffer) if buffer
			# console.log(JSONBUFFER)
			@db._ = if buffer then JSON.parse(JSONBUFFER) else @db._
			if not buffer then @initDatabase()
			if @db._.$$primaryKey is not @db.primaryKey then return @initDatabase()
			@db._.$$indexed = _.indexBy(@db._.$$data, @db.primaryKey) if buffer
			@db.loaded = true
		else
			initDatabase()

	initDatabase: () ->
		@db.storage.writeFile(@db.filename, @initBuffer(@db._)) if not @db.inMemoryOnly

	bufferToJson: (buffer) ->
		res = '{"$$primaryKey":"PRIMARYKEY", "$$data":DATA}'
		configIndex = buffer.indexOf(DELIMITER) - 1
		configBuffer = buffer.slice(0, configIndex)
		dataBuffer = buffer.slice(configIndex + 4)
		config = JSON.parse configBuffer
		res = res.replace("PRIMARYKEY", config.$$primaryKey)
		res = res.replace("DATA", "[" + dataBuffer.replace(NEWLINE_RE, ",") + "]")
		res

	initBuffer: (config) ->
		contents = ''
		# we will replace repeating newline chars, hence the DELIMITER
		contents += '{"$$primaryKey": "' + config.$$primaryKey + '"}' + NEWLINE+DELIMITER
		_.each config.$$data, (d) -> contents += NEWLINE + JSON.stringify(d)
		contents

	insertDoc: (doc) ->
		contents = @db.storage.readFile @db.filename
		contents += NEWLINE + JSON.stringify(doc)
		@db.storage.writeFile @db.filename, contents

	insertDocs: (docs) ->
		contents = @db.storage.readFile @db.filename
		_.each docs, (d) -> contents += NEWLINE + JSON.stringify(d)
		@db.storage.writeFile @db.filename, contents

	updateDoc: (newDoc, oldDoc) ->
		contents = @db.storage.readFile @db.filename
		newContents = contents.replace JSON.stringify(oldDoc), (match, offset, _contents) ->
			if _contents then return JSON.stringify(newDoc)
		if newContents is contents then newContents += NEWLINE + JSON.stringify(newDoc)
		contents = newContents
		@db.storage.writeFile @db.filename, contents

	updateDocs: (newDocs, oldDocs) ->
		contents = @db.storage.readFile @db.filename
		_.each newDocs, (d, i) ->
			newContents = contents.replace JSON.stringify(oldDocs[i]), (match, offset, _contents) ->
				if _contents then return JSON.stringify(d)
			if newContents is contents then newContents += NEWLINE + JSON.stringify(d)
			contents = newContents
		@db.storage.writeFile @db.filename, contents

	removeDoc: (doc) ->
		contents = @db.storage.readFile @db.filename
		contents = contents.replace JSON.stringify(doc), ''
		contents = contents.replace(REPEATED_NEWLINES_RE, NEWLINE)
		@db.storage.writeFile @db.filename, contents

	removeDocs: (docs) ->
		contents = @db.storage.readFile @db.filename
		_.each docs, (d, i) -> contents = contents.replace JSON.stringify(d), ''
		contents = contents.replace(REPEATED_NEWLINES_RE, NEWLINE)
		@db.storage.writeFile @db.filename, contents

@Persistance = Persistance