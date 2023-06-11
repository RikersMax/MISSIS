# encoding: UTF-8
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new ('database.db')
	@db.results_as_hash = true
end

before do
   	init_db
end

configure do
	init_db
	@db.execute('CREATE TABLE IF NOT EXISTS "Accounting" 
		(
		"id" INTEGER PRIMARY KEY AUTOINCREMENT,
		"id_number" VARCHAR(50),
		"name_item" NVARCHAR(100),
		"summa" INTEGER,
		"target" TEXT,
		"datestemp" DATE
		)')

	@db.execute('CREATE TABLE IF NOT EXISTS "Items"
		(
		"id" INTEGER PRIMARY KEY AUTOINCREMENT,
		"id_number" VARCHAR(50),
		"name_item" NVARCHAR(100),
		"summary" TEXT,
		"target_item" TEXT
		)')

end

#enable :sessions

get '/' do
	erb(:index)
end

get '/create_items' do
	@results = @db.execute('SELECT * FROM Items')
	erb(:create_items)
end

post '/create_items/add' do 

	id_number = params[:id_number]
	name_item = params[:name_item]
	summary_item = params[:summary_item] 
	target = params[:target]

   	@db.execute('INSERT INTO "Items"
	(
	id_number, 
	name_item,
	target_item,
	summary
	) 
	VALUES (?,?,?,?)',[id_number, name_item, target, summary_item])
	
	@results = @db.execute('SELECT * FROM Items')
	erb(:create_items)
#	erb(params.inspect)	
end



get '/accounting' do 

	@results = @db.execute('SELECT Accounting.id, Accounting.id_number, Items.name_item, Accounting.summa, Accounting.target, Accounting.datestemp
	FROM Accounting JOIN Items 
	ON Accounting.name_item = Items.id
	ORDER BY datestemp DESC
	')
	
	@items = @db.execute('SELECT * FROM Items')	


   	erb(:accounting)
end

get '/consumption' do

end


post '/accounting/add' do
	item_hash = eval(params[:choice_item])
	summa = params[:kolvo]
	datestemp = params[:add_data]
	target = params[:target]

	@db.execute('INSERT INTO "Accounting" 
	(
	id_number, 
	name_item, 
	summa,
	target, 
	datestemp
	) 
	VALUES (?,?,?,?, Datetime())', [item_hash['id_number'], item_hash['id'], summa, target])

	@items = @db.execute('SELECT * FROM Items')		

	redirect to('/accounting')
end


get '/plan' do
   	erb(:plan)
end

