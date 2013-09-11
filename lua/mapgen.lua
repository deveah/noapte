
mapgen = {}

-- don't touch; it's magic.
mapgen.magicNumber = 9999

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

function mapgen.countNeighbours( m, x, y, t )
	assert( type( m ) == "table" )
	assert( type( x ) == "number" )
	assert( type( y ) == "number" )
	assert( type( t ) == "table" )

	local r = 0

	for i = x-1, x+1 do
		for j = y-1, y+1 do
			if map.isLegal( m, i, j ) then
				if m.terrain[i][j] == t then
					r = r + 1
				end
			end
		end
	end

	return r
end

function mapgen.rectCost( m, x, y, w, h )
	assert( type( m ) == "table" )
	assert( type( x ) == "number" )
	assert( type( y ) == "number" )
	assert( type( w ) == "number" )
	assert( type( h ) == "number" )

	local r = 0

	for i = x, x+w do
		for j = y, y+h do
			if map.isLegalStrict( m, i, j ) then
				r = r + mapgen.countNeighbours( m, i, j, tile.floor )
			else
				return false
			end
		end
	end

	return r
end

function mapgen.fillRect( m, x, y, w, h, t )
	assert( type( m ) == "table" )
	assert( type( x ) == "number" )
	assert( type( y ) == "number" )
	assert( type( w ) == "number" )
	assert( type( h ) == "number" )
	assert( type( t ) == "table" )

	for i = x, x+w do
		for j = y, y+h do
			if map.isLegal( m, i, j ) then
				m.terrain[i][j] = t
			end
		end
	end
end

function mapgen.formScatter( width, height )
	assert( type( width ) == "number" )
	assert( type( height ) == "number" )

	local m = map.new( width, height )

	local rx, ry, rw, rh = 0, 0, 0, 0

	repeat
		rx = math.random( 1, width )
		ry = math.random( 1, height )
		rw = math.random( 1, 5 )
		rh = math.random( 1, 5 )
	until map.isLegalStrict( m, rx+rw, ry+rh )

	mapgen.fillRect( m, rx, ry, rw, rh, tile.floor )

	local tries = 0

	while tries < mapgen.magicNumber do
		repeat
			rx = math.random( 1, width )
			ry = math.random( 1, height )
			if math.random() < 0.1 then
				rw = math.random( 0, 3 )
				rh = math.random( 0, 3 )
			else
				rw = math.random( 1, 5 )
				rh = math.random( 1, 5 )
			end
		until map.isLegalStrict( m, rx+rw, ry+rh )

		local c = mapgen.rectCost( m, rx, ry, rw, rh )
		if c then
			if	( c > 0 and c < 4 ) or
				( c > 0 and math.random() < 0.005 ) then
				mapgen.fillRect( m, rx, ry, rw, rh, tile.floor )
			else
				tries = tries + 1
			end
		else
			tries = tries + 1
		end
	end

	for i = 1, width do
		for j = 1, height do
			if	m.terrain[i][j] == tile.void and
				mapgen.countNeighbours( m, i, j, tile.floor ) > 0 then
				m.terrain[i][j] = tile.wall
			end
		end
	end

	return m
end
