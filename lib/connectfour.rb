class Slot
	attr_accessor :coord, :token

	def initialize (coord=nil, token=nil)
		@coord ||= coord
		@token ||= token
	end
end