Lazy = require 'Lazy'
_ = require 'lodash'

class Cursor extends _
	constructor: (@db) ->
		# return Lazy Seq


class Pager
	constructor: (cursor, @pageSize) ->
		{ @Seq, @db, @query } = cursor

	page: (num) ->
		new Page @, num


class Page extends Cursor
	constructor: (pager, pageNum) ->
