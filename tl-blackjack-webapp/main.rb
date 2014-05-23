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

before do
  @show_hit_or_stay = true
end

before do
  @show_dealer_cards = true
end

before do
  @show_play_again = false
end

get '/' do
  if session[:player_name]
    redirect '/bet'
  else
  redirect '/new_player'
  end 
end

get '/new_player' do
  session[:bank] = 500
  erb :username_form
end

post '/new_player' do
  session[:player_name] = params[:player_name]
  redirect '/bet'
end

get '/bet' do
  if session[:bank] > 0
  erb :bet_form
  else
  erb :game_over
  end
end

post '/bet' do
  session[:bet] = params[:bet]
  if session[:bet].to_i == 0
  redirect '/bet/error'
  else
  redirect 'game/initiate'
  end
end

get '/bet/error' do
  @error = "Please enter a bet"
  erb :bet_form
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
    session[:bank] = session[:bank] + session[:bet].to_i
    @success = "Blackjack! Congratulations you win the game! You now have $#{session[:bank]}"
    @show_play_again = true
    @show_hit_or_stay = false
    erb :game_player
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
    session[:bank] = session[:bank] + session[:bet].to_i
    @success = "Blackjack! Congratulations you win the game! You now have $#{session[:bank]}"
    @show_play_again = true
    @show_hit_or_stay = false
    erb :game_player
  elsif cards_total(session[:player_cards]) > 21
    session[:bank] = session[:bank] - session[:bet].to_i
    @error = "Sorry #{session[:player_name]}, your total is over 21, you loose the game.You now have $#{session[:bank]}"
    @show_play_again = true
    @show_hit_or_stay = false
    erb :game_player
  else redirect '/game/player'
  end
end

post '/game/player/stay' do
  redirect '/game/dealer'
end

get '/game/dealer' do
  if cards_total(session[:dealer_cards]) == 21
    session[:bank] = session[:bank] - session[:bet].to_i
     @error = "The dealer hit blackjack. Sorry #{session[:player_name]}, you loose the game. You now have $#{session[:bank]}"
     @show_dealer_cards = false
     @show_play_again = true
     erb :game_dealer
  else
  erb :game_dealer
  end
end

post '/game/dealer/show'do
  until cards_total(session[:dealer_cards]) > 17
    session[:dealer_cards]<< session[:deck].pop
  end
  @show_dealer_cards = false
  if cards_total(session[:dealer_cards]) > cards_total(session[:player_cards]) && cards_total(session[:dealer_cards]) < 22
    session[:bank] = session[:bank] - session[:bet].to_i
    @error = "Sorry #{session[:player_name]}, you loose this game. You now have $#{session[:bank]}"
    @show_play_again = true
    erb :game_dealer
  elsif cards_total(session[:dealer_cards]) == cards_total(session[:player_cards])
    @success = "It's a tie. Play again! You still have $#{session[:bank]}"
    @show_play_again = true
    erb :game_dealer
  else
    session[:bank] = session[:bank] + session[:bet].to_i
    @success ="Congratulations #{session[:player_name]}, you win the game! You now have $#{session[:bank]}"
    @show_play_again = true
    erb :game_dealer
  end
end

get '/end_game' do
  erb :end_game
end













