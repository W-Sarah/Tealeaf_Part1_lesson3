require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do
  def cards_total(array)
  values = {"2" => 2, "3" => 3, "4" => 4,"5" => 5,"6" => 6,"7" => 7,"8" => 8,"9" => 9,"10" => 10, "jack" => 10,"queen" => 10, "king" => 10, "ace" =>  [1, 11] }
  hand = []
  total = 0
  total_1 = 0
  total_11 = 0

  array.each do |suit,card|
    hand << card
  end

  if hand.include?("ace")
    non_aces = hand.select { |value| value != "ace"}
    aces = hand.select {|value| value == "ace"}
    total_1 = non_aces.inject(0) {|sum, card| sum + values[card]} + aces.to_a.length
    total_11 = non_aces.inject(0) {|sum, card| sum + values[card]} + aces.to_a.length * 11
    if (total_11 <= 21) 
      total = total_11
    else 
      total = total_1
    end
  else total = hand.inject(0) {|sum, card| sum + values[card]}
  end
  return total
  end
end

helpers do
  def img(card)
      "<img src='/images/cards/#{card[0]}_#{card[1]}.jpg' alt='#{card[1]} of #{card[0]}' style='padding:2px;border:1px solid black;' />"
  end
end


get '/' do
  if session[:player_name]
    redirect '/game/initiate'
  else
  redirect '/new_player'
  end 
end

get '/new_player' do
  erb :username_form
end

post '/new_player' do
  session[:player_name] = params[:player_name]
  redirect '/game/initiate'
end

get '/game/initiate' do
  session[:suits] = [ "diamonds", "hearts", "clubs", "spades"]
  session[:cards] = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king", "ace"]
  session[:deck] = session[:suits].product(session[:cards])
  session[:deck].shuffle!
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards]<< session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  if cards_total(session[:player_cards]) == 21
    redirect '/game/player/win'
  else
  redirect '/game/player'
  end
end

get '/game/player' do
  erb :game_player
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  if cards_total(session[:player_cards]) == 21
    redirect '/game/player/win'
  elsif cards_total(session[:player_cards]) > 21
    redirect '/game/player/loose'
  else redirect '/game/player'
  end
end

get '/game/player/win' do
  erb :player_win
end

get '/game/player/loose' do
  erb :player_loose
end

post '/game/player/stay' do
  redirect '/game/dealer'
end

get '/game/dealer' do
  if cards_total(session[:dealer_cards]) == 21
    redirect '/game/player/loose'
  else
  erb :game_dealer
  end
end

post '/game/dealer/show'do
  until cards_total(session[:dealer_cards]) > 17
    session[:dealer_cards]<< session[:deck].pop
  end
  redirect '/game/comparison'
end

get '/game/comparison' do
  if cards_total(session[:dealer_cards]) > cards_total(session[:player_cards]) && cards_total(session[:dealer_cards]) < 22
    redirect '/game/player/loose'
  elsif cards_total(session[:dealer_cards]) == cards_total(session[:player_cards])
    redirect 'game/tie'
  else
    redirect 'game/player/win'
  end
end

get 'game/tie' do
  erb :game_tie
end













