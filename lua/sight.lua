
sight = {}

function sight.initMap( ent )
	assert( type( ent ) == "table" )

	ent.sightMap = {}

	for i = 1, ent.map.width do
		ent.sightMap[i] = {}
		for j = 1, ent.map.height do
			ent.sightMap[i][j] = false
		end
	end
end

function sight.updateMap( ent )
	assert( type( ent ) == "table" )

	for i = 1, ent.map.width do
		for j = 1, ent.map.height do
			if ent.sightMap[i][j] == true then
				ent.map.memory[i][j] = ent.map.terrain[i][j]
			end
			ent.sightMap[i][j] = false
		end
	end
end

-- Bresenham's Line algorithm, from Wikipedia
function sight.doRay( m, x1, y1, x2, y2 )
	assert( type( map ) == "table" )
	assert( type( x1 ) == "number" )
	assert( type( y1 ) == "number" )
	assert( type( x2 ) == "number" )
	assert( type( y2 ) == "number" )

	local x, y = x1, y1
	local dx, dy = math.abs( x2-x1 ), math.abs( y2-y1 )
	local sx, sy = 0, 0

	if x2 > x1 then sx = 1 else sx = -1 end
	if y2 > y1 then sy = 1 else sy = -1 end

	local err = dx - dy
	local e2 = 0

	while true do
		if map.isLegal( m, x, y ) then
			if contains( m.terrain[x][y].flags, "opaque" ) then
				return false
			end
		end

		if err * 2 > -dy then
			err = err - dy
			x = x + sx
		end

		if x == x2 and y == y2 then
			return true
		end

		if err * 2 < dx then
			err = err + dx
			y = y + sy
		end
		
		if x == x2 and y == y2 then
			return true
		end

	end
end

function sight.updateFOV( ent, radius )
	assert( type( ent ) == "table" )
	assert( type( radius ) == "number" )
	assert( type( ent.sightMap ) == "table" )

	sight.updateMap( ent )

	for i = ent.x - radius, ent.x + radius do
		for j = ent.y - radius, ent.y + radius do
			if map.isLegal( ent.map, i, j ) then
				if	dist( ent.x, ent.y, i, j ) <= radius and
					sight.doRay( ent.map, ent.x, ent.y, i, j ) then
					ent.sightMap[i][j] = true
				end
			end
		end
	end
end
