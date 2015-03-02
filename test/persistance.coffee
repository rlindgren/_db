dataFilePath = './test/helpers/persistanceData.txt'
TESTDB = 'TestDB'
db = null

describe 'persistance', ->

	describe 'config', ->

		it 'should call loadDatabase', ->
			db = new Datastore
				filename: TESTDB
				primaryKey: "Id"
				inMemoryOnly: false
				storage: new Storage()
				autoload: true

			expect(db.storage.readFile db.filename).to.exist
			expect(db._.$$primaryKey).to.equal('Id')
			db.wipe()

		it 'should persist the primaryKey', ->
			db = new Datastore
				filename: TESTDB
				primaryKey: "UnlikelyId"
				inMemoryOnly: false
				storage: new Storage()
				autoload: true
				
			expect(db._.$$primaryKey).to.equal('UnlikelyId')
			db.wipe()


	describe 'data', ->
		beforeEach ->
			# set up data
			localStorage.setItem(TESTDB, '{"$$primaryKey": "Id"}\n--\n{"name":"Olga Lowe","age":58,"Id":"1"}\n{"name":"Mike Weber","age":36,"Id":"2"}\n{"name":"Ralph Roy","age":20,"Id":"3"}\n{"name":"Maud Lawrence","age":40,"Id":"4"}\n{"name":"Marian Terry","age":41,"Id":"5"}\n{"name":"Emily Abbott","age":58,"Id":"6"}\n{"name":"Bryan Turner","age":49,"Id":"7"}\n{"name":"Alan Fitzgerald","age":63,"Id":"8"}\n{"name":"Louise Klein","age":59,"Id":"9"}\n{"name":"Anne Cobb","age":56,"Id":"10"}');
			# load db
			db = new Datastore
				filename: TESTDB
				primaryKey: "Id"
				inMemoryOnly: false
				storage: new Storage()
				autoload: true

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

