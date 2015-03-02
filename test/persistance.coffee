global.localStorage = require './helpers/localStorageShim'
persistance = require '../lib/persistance'
expect = chai.expect

describe 'persistance', ->

	it 'should exist', ->
		expect(persistance).to.exist