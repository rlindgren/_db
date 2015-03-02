dataFilePath = './test/helpers/persistanceData.txt'
TESTDB = 'TestDB'
db = null

loadData = (numDocs) ->
	NEWLINE = "\n";
	DELIMITER = "--";
	PRIMARYKEY = "Id";
	contents = '{"$$primaryKey" : "'+PRIMARYKEY+'"}'+NEWLINE+DELIMITER

	_.range(numDocs).forEach (i) ->
		res =
			name: chance.name()
			age: chance.age()
		res[PRIMARYKEY] = String(i)
		contents += NEWLINE + JSON.stringify(res)
	
	# load big data
	localStorage.setItem(TESTDB, contents)

loadDB = (config) ->
	defaultConf =
		filename: TESTDB
		primaryKey: "Id"
		inMemoryOnly: false
		storage: new Storage()
		autoload: true
	_.extend(defaultConf, config) if _.isObject(config)
	new Datastore defaultConf

describe 'persistance', ->

	before ->
		localStorage.removeItem(TESTDB)

	describe 'config', ->

		it 'should call loadDatabase', ->
			db = loadDB()
			expect(db.storage.readFile db.filename).to.exist
			expect(db._.$$primaryKey).to.equal('Id')
			db.wipe()

		it 'should persist the primaryKey', ->
			db = loadDB {primaryKey: "UnlikelyId" }
			expect(db._.$$primaryKey).to.equal('UnlikelyId')
			db.wipe()


	describe 'data', ->
		beforeEach ->
			# set up data
			localStorage.setItem(TESTDB, '{"$$primaryKey": "Id"}\n--\n{"name":"Olga Lowe","age":58,"Id":"1"}\n{"name":"Mike Weber","age":36,"Id":"2"}\n{"name":"Ralph Roy","age":20,"Id":"3"}\n{"name":"Maud Lawrence","age":40,"Id":"4"}\n{"name":"Marian Terry","age":41,"Id":"5"}\n{"name":"Emily Abbott","age":58,"Id":"6"}\n{"name":"Bryan Turner","age":49,"Id":"7"}\n{"name":"Alan Fitzgerald","age":63,"Id":"8"}\n{"name":"Louise Klein","age":59,"Id":"9"}\n{"name":"Anne Cobb","age":56,"Id":"10"}');
			# load db
			db = loadDB()

		afterEach -> 
			db.wipe() # wipe all data

		it 'should persist data', ->
			expect(db._.$$data.length).to.equal(10)

		it 'should build indexes', ->
			expect(Object.keys(db._.$$indexed).length).to.equal(10)

		it 'should persist doc with insertDoc', ->
			expect(db._.$$data.length).to.equal(10)
			db.persistance.insertDoc({Id: "11", name: "Harold Kumar", age: 31})
			db.persistance.loadDatabase() # called manually to simulate app reload
			expect(db._.$$data.length).to.equal(11)

		it 'should persist docs with insertDocs', ->
			expect(db._.$$data.length).to.equal(10)
			db.persistance.insertDocs([
				{Id: "11", name: "Harold Kumar", age: 31},
				{Id: "12", name: "Monty Python", age: 86}
			]);
			db.persistance.loadDatabase() # called manually to simulate app reload
			expect(db._.$$data.length).to.equal(12)

		it 'should persist doc with updateDoc', ->
			expect(db._.$$data.length).to.equal(10)
			oldDoc = _.find(db._.$$data, { Id: "3"})
			newDoc = _.cloneDeep(oldDoc);
			newDoc.name = "Mike Lindgren"
			db.persistance.updateDoc(newDoc, oldDoc);
			db.persistance.loadDatabase() # called manually to simulate app reload
			expect(db._.$$data.length).to.equal(10)
			expect(_.find(db._.$$data, {Id: "3"}).name).to.equal("Mike Lindgren")

		it 'should persist docs with updateDocs', ->
			expect(db._.$$data.length).to.equal(10)
			oldDocs = _.filter(db._.$$data, (d) -> d.Id > 7)
			expect(oldDocs.length).to.equal(3)
			newDocs = _.cloneDeep(oldDocs);
			newDocs[0].name = "Mike Lindgren"
			newDocs[1].name = "Brandon Lindgren"
			newDocs[2].name = "Stephen Lindgren"
			db.persistance.updateDocs(newDocs, oldDocs);
			db.persistance.loadDatabase() # called manually to simulate app reload
			expect(db._.$$data.length).to.equal(10)
			expect(_.find(db._.$$data, {Id: "8"}).name).to.equal("Mike Lindgren")
			expect(_.find(db._.$$data, {Id: "9"}).name).to.equal("Brandon Lindgren")
			expect(_.find(db._.$$data, {Id: "10"}).name).to.equal("Stephen Lindgren")

		it 'should persist removal of doc with removeDoc', ->
			expect(db._.$$data.length).to.equal(10)
			doc = _.find(db._.$$data, { Id: "3"})
			db.persistance.removeDoc(doc);
			db.persistance.loadDatabase() # called manually to simulate app reload
			expect(db._.$$data.length).to.equal(9)
			expect(_.find(db._.$$data, {Id: "3"})).to.not.exist

		it 'should persist removal of docs with removeDocs', ->
			expect(db._.$$data.length).to.equal(10)
			docs = _.filter(db._.$$data, (d) -> d.Id < 3)
			expect(docs.length).to.equal(2)
			db.persistance.removeDocs(docs);
			db.persistance.loadDatabase() # called manually to simulate app reload
			expect(db._.$$data.length).to.equal(8)
			expect(_.filter(db._.$$data, (d) -> d.Id < 3).length).to.equal(0)

		it 'should persist new doc with updateDoc (if is upsert)', ->
			expect(db._.$$data.length).to.equal(10)
			oldDoc = null
			newDoc = 
				Id: "12"
				name: "Mike Lindgren"
				age: 33
			db.persistance.updateDoc(newDoc, oldDoc);
			db.persistance.loadDatabase() # called manually to simulate app reload
			expect(db._.$$data.length).to.equal(11)
			expect(_.find(db._.$$data, {Id: "12"}).name).to.equal("Mike Lindgren")

		it 'should persist new docs with updateDocs (if is upsert). Existing docs should be clobbered', ->
			expect(db._.$$data.length).to.equal(10)
			oldDocs = _.filter(db._.$$data, (d) -> d.Id > 8) # two existing objects
			existingDocs = _.cloneDeep(oldDocs)
			existingDocs[0].name = "Stephen Lindgren"
			existingDocs[1].name = "Donna Lindgren"
			expect(existingDocs.length).to.equal(2)
			# two new documents
			newDocs = [
				{ Id: "11", name: "Mike Lindgren", age: 33 }
				{ Id: "12", name: "Brandon Lindgren", age: 29 }
			]

			newDocs = newDocs.concat existingDocs
			db.persistance.updateDocs(newDocs, oldDocs);
			db.persistance.loadDatabase() # called manually to simulate app reload
			expect(db._.$$data.length).to.equal(12)
			expect(_.find(db._.$$data, {Id: "9"}).name).to.equal("Stephen Lindgren")
			expect(_.find(db._.$$data, {Id: "10"}).name).to.equal("Donna Lindgren")
			expect(_.find(db._.$$data, {Id: "11"}).name).to.equal("Mike Lindgren")
			expect(_.find(db._.$$data, {Id: "12"}).name).to.equal("Brandon Lindgren")


	describe 'big-ish data (10,000 entries)', ->
		before -> loadData(10000)

		afterEach -> db.wipe()

		it 'should complete load in under 30ms for 10,000 docs (completes in <20ms on dev machine)', ->
			@timeout(30)
			# load db
			db = loadDB()

