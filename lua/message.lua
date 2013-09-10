
message = {}
message.list = {}

function message.push( msg )
	local t = {}
	
	t.msg = msg
	t.time = game.globalTurn
	t.flags = {}

	table.insert( message.list, t )
end

