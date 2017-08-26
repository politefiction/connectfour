class Slot
	attr_accessor :coord, :token

	def initialize (coord=nil, token=nil)
		@coord ||= coord
		@token ||= token
	end
end

class CFBoard
	attr_accessor :slots, :victory

	def initialize
		@slots = []
		create_slots
		@victory = false
	end

	def create_slots
		row = (0..5).to_a
		col = (0..6).to_a
		row.each { |x| col.each { |y| @slots << Slot.new([x, y]) } }
	end

	def display_board
		puts; puts (1..7).to_a.join("   "); puts
		cr = 0
		while cr < 42
			printed_row = []
			@slots[cr..(cr+6)].each { |slot| slot.token.nil? ? printed_row << "⚊" : printed_row << slot.token }
			puts printed_row.join("   ")
			cr += 7
		end
	end

	def check_board
		check_rows
		check_columns
		check_diagonals
	end

	def check_rows
		cr = 5
		while cr >= 0
			row = @slots.select { |slot| slot.coord[0] == cr }
			any_matches?(row)
			cr -= 1
		end
	end

	def check_columns
		cc = 0
		while cc <= 6
			col = @slots.select { |slot| slot.coord[1] == cc }
			any_matches?(col)
			cc += 1
		end
	end

	def check_diagonals
		@slots.each_with_index do |slot, index|
			diag1 = [slot]
			diag2 = [slot]
			main_ind = index
			@slots.each_with_index { |slot, index| diag1 << slot if index > main_ind and (index - main_ind) % 8 == 0 }
			@slots.each_with_index { |slot, index| diag2 << slot if index > main_ind and (index - main_ind) % 6 == 0 }
			any_matches?(diag1)
			any_matches?(diag2)
		end
	end

	def any_matches?(array)
		matches = []
		array.each do |slot|
			unless matches.length == 4
				if matches.include? slot.token
					matches << slot.token
				elsif !slot.token.nil?
					matches = [slot.token]
				else
					matches = []
				end
			end
		end
		@victory = true if matches.length == 4
	end

end

class CFPlayer
	attr_accessor :id, :token, :board

	@@player_count = 0
	@@board = CFBoard.new

	def initialize(token=nil)
		@@player_count += 1
		@id = "Player #{@@player_count}"
		@token = token
		@board = @@board
	end

	# For testing purposes
	def copy_board
		@board = @@board
	end

	def place_token(col)
		empty_slots = @@board.slots.select { |slot| slot.coord[1] == (col.to_i - 1) and slot.token.nil? }
		if empty_slots.empty?
			puts "Sorry, this column is full. Please try again."
			turn
		else
			empty_slots[-1].token = @token
		end
	end

	def turn
		puts; puts "#{self.id}'s turn. Choose a column (1-7):"
		@@board.display_board
		col = gets.chomp.strip
		if col.to_i < 8 and col.to_i > 0
			place_token(col)
			copy_board
		else
			puts "Invalid entry. Please try again."
			turn
		end
	end

	def connect_four?
		@@board.check_board
		if @@board.victory
			@@board.display_board
			puts "Game over! #{self.id} wins!"
		end
	end

	def self.establish_players (p1, p2)
		[p1, p2].each do |p|
			if p.token.nil?
				puts "#{p.id}, choose your token (one character please):"
				token = gets.chomp
				p.token = token[0]
				puts "#{p.id} has chosen #{p1.token}."
			end
		end
	end

	def self.game(p1=nil, p2=nil)
		p1 ||= CFPlayer.new
		p2 ||= CFPlayer.new
		puts "Welcome to Connect Four!"
		CFPlayer.establish_players(p1, p2) 
		turns = 42
		current_turn = p1
		while turns > 0
			if current_turn == p1
				p1.turn
				p1.connect_four?
				CFPlayer.play_again?(p1, p2) if @@board.victory
				current_turn = p2
			else
				p2.turn
				p2.connect_four?
				CFPlayer.play_again?(p1, p2) if @@board.victory
				current_turn = p1
			end
			turns -= 1
		end
		@@board.display_board 
		puts "Game over! Nobody wins!"
		CFPlayer.play_again?(p1, p2)
	end

	def self.play_again?(p1, p2)
		puts "Would you like to play again? (Y/N)"
		answer1 = gets.chomp; puts
		if answer1[0].downcase == "y"
			puts "Would you like to change your tokens? (Y/N)"
			answer2 = gets.chomp; puts
			if answer2[0].downcase == "y"
				[p1, p2].each { |p| p.token = nil } if answer2[0].downcase == "y"
			elsif answer2[0].downcase != "n"
				puts "Game will assume you meant 'no'."; puts
			end
			@@board.slots.each { |slot| slot.token = nil }
			CFPlayer.game(p1, p2)
		elsif answer1[0].downcase == "n"
			puts "Thanks for playing!"
			exit
		else
			puts "Invalid entry. Please try again."
			CFPlayer.play_again?(p1, p2)
		end
	end
end


#CFPlayer.game

#player1 = CFPlayer.new("⚙")
#player2 = CFPlayer.new("♥")
#CFPlayer.game(player1, player2)
