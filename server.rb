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
      erb :userHome, locals: {username: username, lists: lists}
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
  onelist_db.execute("CREATE TABLE #{listTable} (id INTEGER PRIMARY KEY, listName TEXT)")
  redirect '/signin'
end

post '/userHome/:username/newList' do
  username = params[:username]
  currentUser = onelist_db.execute("SELECT * FROM users WHERE name=?", username)
  newList = params["newList"]
  onelist_db.execute("INSERT INTO #{currenUser[5]} (listName) VALUES (?)", newList)
  lists = onelist_db.execute("SELECT * FROM #{currentUser[5]}")
  erb :userHome, locals: {lists: lists, username: username}
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
