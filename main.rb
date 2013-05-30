require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK_NUMBER = 21
DEALER_HIT_NUMBER = 17

helpers do
	def calculate_total(cards)
		arr = cards.map{|element| element[1]}

		total = 0
		arr.each do |a|
			if a == "A"
				total += 11
			else
				# If face card is 10, otherwise number card use value
				total += a.to_i == 0 ? 10 : a.to_i
			end
		end

		# Aces
		arr.select{|element| element == "A"}.count.times do
			break if total <= BLACKJACK_NUMBER
			total -= 10
		end

		total
	end

	def display_card_images(card)
		#format is # ['H', '9']

		case card[0]
		when "C"
			suit = "clubs"
		when "D"
			suit = "diamonds"
		when "H"
			suit = "hearts"
		when "S"
			suit = "spades"
		end

		case card[1]
		when "10"
			number = "10.jpg"
		when "2"
			number = "2.jpg"
		when "3"
			number = "3.jpg"
		when "4"
			number = "4.jpg"
		when "5"
			number = "5.jpg"
		when "6"
			number = "6.jpg"
		when "7"
			number = "7.jpg"
		when "8"
			number = "8.jpg"
		when "9"
			number = "9.jpg"
		when "A"
			number = "ace.jpg"
		when "J"
			number = "jack.jpg"
		when "K"
			number = "king.jpg"
		when "Q"
			number = "queen.jpg"
		end

		#Return 
		"<img src='/images/cards/#{suit}_#{number}' class='img-polaroid'>"
	end

	def winner!(msg)
		@play_again = true
		@show_buttons = false
		session[:total_money] += session[:bet_amount]
		@winner ="<strong>#{session[:player_name]} wins!</strong> #{msg} #{session[:player_name]} now has <strong>$#{session[:total_money]}</strong>."
	end

	def loser!(msg)
		@play_again = true
		@show_buttons = false
		session[:total_money] -= session[:bet_amount] 
		@loser ="<strong>#{session[:player_name]} loses.</strong> #{msg} #{session[:player_name]} now has <strong>$#{session[:total_money]}</strong>."
	end

	def tie!(msg)
		@play_again = true
		@show_buttons = false
		@winner ="<strong>It's a tie.</strong> #{msg}"
	end

end

before do
		#Hit and Stay Buttons
		@show_buttons = true
		#Dealer show cards button
		@show_dealer_button = false

end



get '/' do 
	if session[:player_name]
			redirect '/bet'
	else
			redirect '/new_player'
	end
end

get '/new_player' do
	erb :new_player
end

# Enter your name form
post '/new_player' do
	if params['player_name'].empty?
		@error = "Name is required"
		halt erb(:new_player)
	end

	session[:player_name] = params['player_name']

	#Bet variable
	session[:total_money] = 500

	redirect '/bet'
end

#Bet Page
get '/bet' do

	if session[:total_money] == 0
		redirect '/nomoney'
	end

	erb :bet
end

post '/bet' do
	session[:bet_amount] = params['bet_amount'].to_i

	if params['bet_amount'].empty? || session[:bet_amount] == 0
		@error = "You must enter a bet."
		halt erb(:bet)
	elsif session[:bet_amount] > session[:total_money]
		@error = "You don't have enough money to bet that much."
		halt erb(:bet)
	end

	redirect '/game'
end

get '/nomoney' do
	erb :nomoney
end

get '/game' do

	session[:turn] = session[:player_name]

	# Setup Deck
  suits = ['H', 'D', 'S', 'C']
  cards = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(cards)
  session[:deck].shuffle!

  # Initialize in the array
 	session[:player_cards] = []
	session[:dealer_cards] = []

	# Deal Cards
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop

	erb :game
end


# Player Hit Button
post '/game/player/hit' do	
	session[:player_cards] << session[:deck].pop

	player_total = calculate_total(session[:player_cards])
	if player_total == BLACKJACK_NUMBER
		winner!("#{session[:player_name]} hit blackjack.")
	elsif player_total > BLACKJACK_NUMBER
		loser!("#{session[:player_name]} busted at #{player_total}.")
	end

 	erb :game, layout: false
end

# Player Stay Button
post '/game/player/stay' do
	@success = "#{session[:player_name]} has chosen to stay."
	@show_buttons = false
	@show_dealer_button = true

  redirect '/game/dealer'  
end


get '/game/dealer' do
	session[:turn] = "dealer"
	@show_buttons = false

	dealer_total = calculate_total(session[:dealer_cards])

	if dealer_total == BLACKJACK_NUMBER
		loser!("Dealer hit blackjack.")
	elsif dealer_total > BLACKJACK_NUMBER
		winner!("Dealer busted at #{dealer_total}.")
	elsif dealer_total >= DEALER_HIT_NUMBER
		redirect '/game/winner'
	else
		#dealer hits
		@show_dealer_button = true

	end

	erb :game, layout: false
end

# Dealer hit
post '/game/dealer/hit' do
	session[:dealer_cards] << session[:deck].pop
	redirect '/game/dealer'
end

get '/game/winner' do
	@show_buttons = false
	player_total = calculate_total(session[:player_cards])
	dealer_total = calculate_total(session[:dealer_cards])

	if player_total < dealer_total
		loser!("#{session[:player_name]} stayed at #{player_total} and the dealer stayed at #{dealer_total}.")
	elsif player_total > dealer_total
		winner!("#{session[:player_name]} stayed at #{player_total} and the dealer stayed at #{dealer_total}.")
	elsif player_total == dealer_total
		tie!("Both #{session[:player_name]} and the dealer stayed at #{player_total}.")
	end

	erb :game, layout: false
end

get '/game_over' do
	erb :game_over
end

