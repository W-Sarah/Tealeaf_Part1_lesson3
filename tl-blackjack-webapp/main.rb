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

  def img(card)
      "<img src='/images/cards/#{card[0]}_#{card[1]}.jpg' alt='#{card[1]} of #{card[0]}' style='padding:2px;border:1px solid black;' />"
  end

  def winner(msg)
    session[:bank] = session[:bank] + session[:bet].to_i
    @show_play_again = true
    @winner = "#{msg} Congratulations #{session[:player_name]}, you win the game! You now have $#{session[:bank]}"
  end

  def loser(msg)
    session[:bank] = session[:bank] - session[:bet].to_i
    @loser = "#{msg} Sorry #{session[:player_name]}, you loose the game.You now have $#{session[:bank]}"
    @show_play_again = true
  end

  def tie
    @show_play_again = true
    @winner = "It's a tie. Play again! You still have $#{session[:bank]}"
  end
end


before do
  @show_hit_or_stay = false
end

before do
  @show_dealer_cards = false
end

before do
  @show_play_again = false
end

before do
  @show_dealer_first_card = false
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
  if session[:player_name] == ""
    @error = "Please enter a name"
    erb :username_form
  else
  redirect '/bet'
  end
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
    @error = "Please enter a bet"
    erb :bet_form
  elsif session[:bet].to_i > session[:bank]
    @error = "Please enter a bet between 1 and #{session[:bank]}"
    erb :bet_form
  else
  redirect '/game'
  end
end


get '/game' do
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
    winner("Blackjack!")
  else
    @show_hit_or_stay = true
  end
  erb :game
end


post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  if cards_total(session[:player_cards]) == 21
    winner("Blackjack!")
  elsif cards_total(session[:player_cards]) > 21
    loser("Your total is over 21.")
  else 
    @show_hit_or_stay = true
  end
  erb :game, layout: false
end

post '/game/player/stay' do
  if cards_total(session[:dealer_cards]) == 21
    loser("The dealer hit blackjack.")
     @show_dealer_first_card = true
  else
     @show_dealer_first_card = false
     @show_dealer_cards = true
  end
  erb :game, layout: false
end

post '/game/dealer/show'do
  until cards_total(session[:dealer_cards]) > 17
    session[:dealer_cards]<< session[:deck].pop
  end
  @show_dealer_first_card = true
  if cards_total(session[:dealer_cards]) > cards_total(session[:player_cards]) && cards_total(session[:dealer_cards]) < 22
    loser("The dealer's score is higher.")
  elsif cards_total(session[:dealer_cards]) == cards_total(session[:player_cards])
    tie
  else
    winner("Your score is higher.")
  end
    erb :game, layout: false
end

get '/end_game' do
  erb :end_game
end













