
function clone( tbl )
	assert( type( tbl ) == "table" )
	
	local t = {}

	for k, v in pairs( tbl ) do
		if type( v ) == "table" then
			t[k] = clone( v )
		else
			t[k] = v
		end
	end

	return t
end

function contains( tbl, value )
	assert( type( tbl ) == "table" )

	for k, v in pairs( tbl ) do
		if v == value then
			return true
		end
	end

	return false
end

function dist( x1, y1, x2, y2 )
	assert( type( x1 ) == "number" )
	assert( type( x2 ) == "number" )
	assert( type( y1 ) == "number" )
	assert( type( y2 ) == "number" )

	return math.sqrt( (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2) )
end
