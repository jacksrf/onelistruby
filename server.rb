require 'sinatra'
require 'sqlite3'

onelist_db = SQLite3::Database.new "onelist.db"

get '/' do
  erb :index
end

get '/signin' do
  erb :signin
end


get '/signup' do
  erb :signup
end

post '/userHome' do
  userCheck = onelist_db.execute("SELECT 1 FROM users WHERE name = ?", params["name"]).length > 0
  passCheck = onelist_db.execute("SELECT 1 FROM users WHERE password = ?", params['password']).length > 0
  if userCheck == true && passCheck == true
      username = params["name"]
      currentUser = onelist_db.execute("SELECT * FROM users WHERE name=?", username)
      puts username + ": passed"
      puts currentUser[0][4]
      lists = onelist_db.execute("SELECT * FROM #{currentUser[0][4]}")
      list = "No Current List Chosen, Create a List!"
      currentList = []
      erb :userHome, locals: {currentUser: currentUser, lists: lists, list: list, currentList: currentList}
  elsif userCheck == false
    ##prompt wrong username
  elsif passCheck == false
    ##prompt wrong pass
  end
end

post '/signup' do
  username = params["name"]
  listTable = username + "_lists"
  onelist_db.execute("INSERT INTO users (name, password, email, listTable) VALUES (?,?,?,?)", params["name"],params["password"],params["email"],listTable)
  onelist_db.execute("CREATE TABLE #{listTable} (id INTEGER PRIMARY KEY, listName TEXT, listId TEXT)")
  redirect '/signin'
end

post '/userHome/:username/newList' do
  username = params[:username]
  currentUser = onelist_db.execute("SELECT * FROM users WHERE name=?", username)
  newList = params["list"]
  listId = username + "_" + newList
  puts newList
  onelist_db.execute("INSERT INTO #{currentUser[0][4]} (listName, listId) VALUES (?, ?)", newList, listId)
  onelist_db.execute("CREATE TABLE #{listId} (id INTEGER PRIMARY KEY, item TEXT, link TEXT, buy TEXT)")
  lists = onelist_db.execute("SELECT * FROM #{currentUser[0][4]}")
  list = "No Current List Chosen, Create a List!"
  currentList = []
  erb :userHome, locals: {lists: lists, currentUser: currentUser, list: list, currentList: currentList}
end

get '/userHome/:username/:list' do
  username = params[:username]
  list = params[:list]
  listId = username + "_" + list
  currentUser = onelist_db.execute("SELECT * FROM users WHERE name=?", username)
  currentList = onelist_db.execute("SELECT * FROM #{listId}")
  lists = onelist_db.execute("SELECT * FROM #{currentUser[0][4]}")
  puts currentList.length
  erb :userHome, locals: {currentUser: currentUser, currentList: currentList, list: list, lists: lists}
end


# get '/pets' do
#   pets = db.execute("SELECT * FROM pets")
#   erb :index, locals: {pets: pets}
# end
#
# get '/pet/:id' do
#   id = params[:id].to_i
#   thispet = db.execute("SELECT * FROM pets WHERE id=?", id)
#   erb :show, locals: {thispet: thispet}
# end
#
# put '/pet/:id' do
#   id = params[:id].to_i
#   db.execute("UPDATE pets SET name=? WHERE id=?", params["newname"], id)
#   redirect '/pets'
# end
#
# delete '/pet/:id' do
#   id = params[:id].to_i
#   db.execute("DELETE FROM pets WHERE id=?", id)
#   redirect '/pets'
# end
