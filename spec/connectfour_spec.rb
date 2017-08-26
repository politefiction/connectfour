require 'connectfour'

describe Slot do 
	let(:slot) { Slot.new }
	context 'upon creation' do
		it 'responds to requests for coordinate and token' do
			expect(slot).to respond_to(:coord)
			expect(slot).to respond_to(:token)
		end

		it 'can store a coordinate and token' do
			expect(slot.coord = [0,0]).to eq([0,0])
			expect(slot.token = "♥").to eq("♥")
		end
	end
end

describe CFBoard do
	let(:test_board) { CFBoard.new }
	after(:each) do
		test_board.slots.each { |slot| slot.token = nil }
	end
	context 'upon creation' do
		it 'has 42 slots' do
			expect(test_board.slots.length).to eq(42)
		end

		it 'has 7 slots in each row' do
			row1 = test_board.slots.select { |slot| slot.coord[0] == 0 }
			expect(row1.length).to eq(7)
		end

		it 'has 6 slots in each column' do
			col1 = test_board.slots.select { |slot| slot.coord[1] == 0 }
			expect(col1.length).to eq(6)
		end
	end

	describe '#check_rows' do
		context 'when the row contains a Connect Four' do
			context 'at the beginning of the row' do
				before do
					test_board.slots[35..38].each { |slot| slot.token = "♥" }
					test_board.slots[39..41].each { |slot| slot.token = "♣" }
				end
				it 'triggers a victory' do
					test_board.check_rows
					expect(test_board.victory).to be true
				end
			end

			context 'towards the end of the row' do
				before do
					test_board.slots[35..37].each { |slot| slot.token = "♥" }
					test_board.slots[38..41].each { |slot| slot.token = "♣" }
				end
				it 'triggers a victory' do
					test_board.check_rows
					expect(test_board.victory).to be true
				end
			end
		end

		context 'when row is filled in without a Connect Four' do
			before do
				test_board.slots[35].token = "♥" 
				test_board.slots[37].token = "♥" 
				test_board.slots[36].token = "♣"
				test_board.slots[38].token = "♣"
			end
			it 'does not trigger a victory' do
				test_board.check_rows
				expect(test_board.victory).to be false
			end
		end

		context 'when tokens of consecutive slots in different rows match' do
			before do
				test_board.slots[33..36].each { |slot| slot.token = "♥" }
			end
			it 'does not trigger a victory' do
				test_board.check_rows
				expect(test_board.victory).to be false
			end
		end
	end

	describe '#check_columns' do
		context 'when the column contains a Connect Four' do
			context 'at the top of the column' do
				before do
					col = test_board.slots.select { |slot| slot.coord[1] == 3 }
					col[0..3].each { |slot| slot.token = "♣" }
					col[4..5].each { |slot| slot.token = "♥" }
					test_board.check_columns
				end
				it 'triggers a victory' do
					expect(test_board.victory).to be true
				end
			end

			context 'at the bottom of the column' do
				before do
					col = test_board.slots.select { |slot| slot.coord[1] == 3 }
					col[0..1].each { |slot| slot.token = "♣" }
					col[2..5].each { |slot| slot.token = "♥" }
					test_board.check_columns
				end
				it 'triggers a victory' do
					expect(test_board.victory).to be true
				end
			end
		end

		context 'when column is filled in without a Connect Four' do
			before do
				col = test_board.slots.select { |slot| slot.coord[1] == 1 }
				col[0..2].each { |slot| slot.token = "♣" }
				col[3..5].each { |slot| slot.token = "♥" }
				test_board.check_columns
			end
			it 'does not trigger a victory' do
				expect(test_board.victory).to be false
			end
		end
	end

	describe '#check_diagonals' do
		context 'when diagonal slots from top left corner match' do
			before do
				diag = test_board.slots.select.with_index { |slot, index| slot if index % 8 == 0 }
				diag[0..3].each { |slot| slot.token = "♥" }
			end
			it 'triggers a victory' do
				test_board.check_diagonals
				expect(test_board.victory).to be true
			end
		end

		context 'when diagonal slots from top right corner match' do
			before do
				diag = [test_board.slots[6]]
				test_board.slots.each_with_index { |slot, index| diag << slot if index > 6 and (index - 6) % 6 == 0 }
				diag[0..3].each { |slot| slot.token = "♣" }
			end
			it 'triggers a victory' do
				test_board.check_diagonals
				expect(test_board.victory).to be true
			end
		end

		context 'when diagonal slots in middle of board match' do
			before do
				diag = [test_board.slots[8]]
				test_board.slots.each_with_index { |slot, index| diag << slot if index > 8 and (index - 8) % 8 == 0 }
				diag[1..4].each { |slot| slot.token = "♣" }
			end
			it 'triggers a victory' do
				test_board.check_diagonals
				expect(test_board.victory).to be true
			end
		end

		context 'when diagonal slots do not match' do
			before do
				diag = []
				test_board.slots.each_with_index { |slot, index| diag << slot if index % 8 == 0 }
				diag[1..3].each { |slot| slot.token = "♣" }
				diag[4..5].each { |slot| slot.token = "♥" }
			end
			it 'does not trigger a victory' do
				test_board.check_diagonals
				expect(test_board.victory).to be false
			end
		end
	end
end

describe CFPlayer do
	let(:player1) { CFPlayer.new("♥") }
	let(:player2) { CFPlayer.new("♣") }

	before(:each) do
		player1.id = "Player 1"
		player2.id = "Player 2"
	end

	after(:each) do
		player1.board.slots.each { |slot| slot.token = nil }
		player2.board.slots.each { |slot| slot.token = nil }
	end

	context 'upon creation' do
		it 'has a player ID' do
			expect(player1).to respond_to(:id)
			expect(player1.id).to_not be nil
		end

		it 'has an assigned token' do
			expect(player1).to respond_to(:token)
			expect(player1.token).to_not be nil
		end
	end

	describe '#place_token' do
		context 'player picks empty column' do
			before { player1.place_token("3") }
			it 'places a token at the bottom of the third column' do
				expect(player1.board.slots[37].token).to eql(player1.token)
			end
		end

		context 'player picks column that has tokens' do
			before do
				2.times { player1.place_token("5") }
				player2.place_token("5")
			end
			it 'places token at lowest available slot in fifth column' do
				expect(player2.board.slots[25].token).to eql(player2.token)
			end
		end
	end

	describe '#turn' do
		after(:each) { $stdin = STDIN }
		context 'player chooses column 1' do
			before do 
				$stdin = StringIO.new("1\n")
				player1.turn
			end
			it 'places token at bottom of column 1' do
				expect(player1.board.slots[35].token).to eq(player1.token)
			end
		end

		context 'player chooses column 5' do
			before do 
				$stdin = StringIO.new("5\n")
				player2.turn
			end
			it 'places token at bottom of column 5' do
				expect(player2.board.slots[39].token).to eq(player2.token)
			end
		end
	end

	describe '#connect_four?' do
		context 'when a player wins' do
			before do
				4.times { player2.place_token("4") }			
			end
			output = /.*(Game over! Player 2 wins!)$/
			it 'returns winning message' do
				expect{ player2.connect_four? }.to output(output).to_stdout
			end
		end
	end

end
