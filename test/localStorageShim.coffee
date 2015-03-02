Storage = require './helpers/localStorageShim'
expect = chai.expect

describe 'Storage', ->
	localStorage = null
	
	beforeEach ->
		localStorage = new Storage()

	it 'should exist', ->
		expect(localStorage).to.exist;

	describe 'setItem', ->
		it 'should store the value for `key` as JSON', ->
			localStorage.setItem('testValue', { Jerry: 'Garcia' });
			return expect(localStorage.store['testValue']).to.equal('{"Jerry":"Garcia"}')

	describe 'getItem', ->
		it 'should return `undefined` if no `value` at `key`', ->
			return expect(localStorage.getItem('noSuchValue')).not.exist

		it 'should return JSON if value exists', ->
			localStorage.setItem('testValue', { Jerry: 'Garcia' });
			return expect(localStorage.getItem('testValue')).to.equal('{"Jerry":"Garcia"}')

	describe 'removeItem', ->
		it 'should remove the key/value pair from storage', ->
			localStorage.setItem('testValue', { Jerry: 'Garcia' })
			expect(localStorage.getItem('testValue')).to.equal('{"Jerry":"Garcia"}')
			localStorage.removeItem('testValue')
			expect(localStorage.getItem('testValue')).to.equal(undefined)