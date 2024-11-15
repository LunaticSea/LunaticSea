local db_core = require('../src/database/core.lua')

local db = db_core:new()

print('set test')
db:set('Hello', 'Thiss is data')
p(db.cache, db.db_name)

print('get test')
p(db:get('Hello', 'This is data'))
p(db.cache, db.db_name)

print('delete test')
db:delete('Hello')
p(db.cache, db.db_name)

print('drop_db test')
db:drop_db('lunatic_db')
p(db.cache, db.db_name)

print('create_db test')
db:create_db('what')
p(db.cache, db.db_name)
db:create_db('hi')
p(db.cache, db.db_name)

print('switch_db test')
db:switch_db('what')
p(db.cache, db.db_name)

print('all test')
db:set('Hello', 'Thiss is data')
p(db:all(), db.db_name)

print('delete_all test')
db:delete_all()
p(db.cache, db.db_name)