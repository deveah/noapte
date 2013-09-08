
mapgen = {}

function mapgen.dummy( width, height )
	assert( type( width ) == "number" )
	assert( type( height ) == "number" )

	local m = map.new( width, height )

	for i = 1, m.width do
		for j = 1, m.height do
			if math.random() < 0.1 then
				m.terrain[i][j] = tile.wall
			else
				m.terrain[i][j] = tile.floor
			end
		end
	end

	return m
end

