
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

