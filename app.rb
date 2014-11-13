require 'sinatra'
require 'sinatra/reloader'
require 'data_mapper'
require 'pry'
require 'rubygems'
require 'better_errors'


# Configure BetterErrors for enhancing error messages
configure :development do
 use BetterErrors::Middleware
 BetterErrors.application_root = __dir__
end


# Need install dm-sqlite-adapter
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/plog.db")


# Create a type : Log
class Log
  include DataMapper::Resource
  property :id,       Serial
  property :author,   Text
  property :message,  Text
end


# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize


# automatically create the post table
Log.auto_upgrade!


get '/admin' do
  @logs = Log.all(:order => [ :id.desc], :limit => 10)
  erb :admin
end

# create makes the resource immediately
post '/admin' do
@log = Log.create(
  :author      => params[:author],
  :message     => params[:message],
)

redirect '/admin'
end


get '/delete/:id' do
  @log = Log.first(:id => params[:id])
  erb :delete
end

delete '/delete/:id' do
  if params.has_key?("ok")
    log = Log.first(:id => params[:id])
    log.destroy
    redirect '/admin'
  else
    redirect '/admin'
  end
end

get '/modify/:id' do
  @log = Log.first(:id => params[:id])
  erb :modify
end

post '/modify/:id' do
  log = Log.first(:id => params[:id])
  log.update(
  :message     => params[:message],
)
  redirect '/admin'
end

get '/accueil' do
  erb :accueil
end

get '/visiteur' do
  @logs = Log.all(:order => [ :id.desc], :limit => 10)
  erb :visiteur
end

# essai d'identification administrateur
set :username, 'amandine'
set :password, 'roxy'
set :token, 'amandineroxy'

get '/identification' do
  erb :identification
end

post '/identification' do
  if params['username'] == settings.username && params['password'] == settings.password
    response.set_cookie(settings.username,settings.token)
    redirect '/admin'
  elsif params['username'] != settings.username && params['password'] != settings.password
    "code utilisateur ou mot de passe incorrect"
  elsif redirect '/identification'
  else
    redirect '/accueil'
  end
end

get '/logout' do
  response.set_cookie(settings.username, false) ;
  redirect '/'
end