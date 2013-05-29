	def display_card_images(card)
		#format is # ['H', '9']
		
		arr_card = card

		case arr_card[0]
		when "C"
			suit = "clubs_"
		when "D"
			suit = "diamonds_"
		when "H"
			suit = "hearts_"
		when "S"
			suit = "spades_"
		end

		case arr_card[1]
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
		image = suit + number
	end

puts display_card_images(['H', '9'])