require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
  erb :username_form
end

post '/username_filled' do
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  session[:suits] = [ "D", "H", "C", "S"]
  session[:cards] = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace"]
  session[:deck] = session[:suits].product(session[:cards])
  session[:deck].shuffle!
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards]<< session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  erb :game
end








