require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
  erb :username_form
end

post '/username_filled' do
  session[:username] = params[:username]
  redirect '/bet'
end

get '/bet' do
  erb :bet_form
end








