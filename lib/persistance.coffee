_ = require 'lodash'

class Persistance
	DELIMITER = "--"
	NEWLINE = "\n"
	NEWLINE_RE = new RegExp NEWLINE, 'g'
	REPEATED_NEWLINES_RE = new RegExp NEWLINE+'{2,}', 'g'
	constructor: (@db) ->

	loadDatabase: () ->
		if not @db.inMemoryOnly
			buffer = @db.storage.readFile @db.filename
			@db._ = if buffer then JSON.parse(@bufferToJson(buffer)) else @_
			if @db._.$$primaryKey is not @db.primaryKey then return @initDatabase()
			@db._.$$indexed = _.indexBy(@db._.$$data, @db.primaryKey) if buffer
			@db.loaded = true

	initDatabase: () ->
		@db.storage.writeFile @db.filename, @initBuffer(@db._)

	bufferToJson: (buffer) ->
		res = '{"$$primaryKey":"PRIMARYKEY", "$$data":DATA}'
		configIndex = buffer.indexOf(NEWLINE+DELIMITER+NEWLINE)
		config = buffer.slice(0, configIndex)
		res = res.replace("PRIMARYKEY", config.match(/primaryKey\:\s*(.*)/)[1])
		res = res.replace("DATA", "[" + buffer.slice(configIndex + 4).replace(NEWLINE_RE, ",") + "]")
		res

	initBuffer: (config) ->
		contents = ''
		# we will replace repeating newline chars
		contents += '$$primaryKey: "' + config.$$primaryKey + '"' + NEWLINE+DELIMITER+NEWLINE
		_.each config.$$data, (d) -> contents += JSON.stringify(d) + NEWLINE
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
		if newContents is contents then newContents += JSON.stringify(newDocs[i]) + NEWLINE
		contents = newContents
		@db.storage.writeFile @db.filename, contents

	updateDocs: (newDocs, oldDocs) ->
		contents = @db.storage.readFile @db.filename
		_.each oldDocs, (d, i) ->
			newContents = contents.replace JSON.stringify(d), (match, offset, _contents) ->
				if _contents then return JSON.stringify(newDocs[i])
			if newContents is contents then newContents += JSON.stringify(newDocs[i]) + NEWLINE
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

module.exports = Persistance