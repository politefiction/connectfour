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