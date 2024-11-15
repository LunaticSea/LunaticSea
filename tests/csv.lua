-- local prefix = 'CSV | '


-- db:load()

-- require('tap')(function (test)
--   test(prefix .. 'Set data test', function ()
--     db:set('hello', 'This is data is kjf')
--     db:set('project', 'current: 78')
--   end)

--   test(prefix .. 'Get data test', function ()
--     p(db:get('hello'))
--   end)

--   test(prefix .. 'Overwrite data test', function ()
--     db:set('hello', 'This is data what')
--     p(db:get('hello'))
--   end)

--   test(prefix .. 'Get all data test', function ()
--     p(db:all())
--   end)

--   test(prefix .. 'Delete data test', function ()
--     db:delete('hello')
--     p(db:all())
--   end)

--   test(prefix .. 'Create new database test', function ()
--     local new_db = db:db_create('luna')
--     new_db:set('gender', 'she/her')
--     new_db:set('age', '16')
--     new_db:set('cred', '47893578934')
--     db:set('override', '789354')
--   end)

--   -- test(prefix .. 'Drop database test', function ()
--   --   db:db_drop('luna')
--   -- end)
-- end)