
map = {}

map.proto = {

	name = "Unnamed place",
	width = 0,
	height = 0,

	terrain = {},

	flags = {}
}

function map.new( width, height )
	assert( type( width ) == "number" )
	assert( type( height ) == "number" )
	
	local m = {}

	m.width = width
	m.height = height

	m.terrain = {}
	for i = 1, width do
		m.terrain[i] = {}
		for j = 1, height do
			m.terrain[i][j] = tile.void
		end
	end

	return m
end

function map.isLegal( m, x, y )
	assert( type( m ) == "table" )
	assert( type( x ) == "number" )
	assert( type( y ) == "number" )

	return x > 0 and y > 0 and x <= m.width and y <= m.height
end

