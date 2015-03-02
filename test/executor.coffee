Executor = require '../lib/executor'
Query = require '../lib/Query'

describe 'Executor', ->
	executor = null

	beforeEach ->
		executor = new Executor()

	afterEach ->
		executor.close()

	it 'should execute queries in series', ->