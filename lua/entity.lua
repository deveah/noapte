
entity = {}

entity.proto = {
	
	name = "Unnamed being",

	active = false,

	face = "u",
	color = curses.cyan + curses.bold,

	x = 0,
	y = 0,
	map = nil,

	level = 0,
	hp = 0,
	maxHp = 0,

	body = 0,
	mind = 0,
	luck = 0,

	ap = 0,
	agility = 0,

	inventory = {},
	inHand = {},
	worn = {},

	flags = {}
}

function entity.makePlayer( name )
	assert( type( name ) == "string" )

	local p = clone( entity.proto )

	p.face = "@"
	p.name = name
	p.active = true
	p.agility = 10
	p.ap = 0
	p.hp = 1
	p.maxHp = 1

	table.insert( p.flags, "player" )

	return p
end

function entity.act( e )
	assert( type( e ) == "table" )

	-- since quitting the game is decided within the player's move, it's
	-- necessary to check if the game is still running every player turn

	while e.ap > 0 and game.running do
		
		if e == game.player then
			ui.drawMainScreen()
			local c = curses.getch()
			if game.handleKey( c ) then
				e.ap = e.ap - 10
				game.playerTurns = game.playerTurns + 1
			end
		else
			e.ap = e.ap - 10
		end
	end

end

function entity.moveRelative( e, x, y )
	assert( type( e ) == "table" )
	assert( type( x ) == "number" )
	assert( type( y ) == "number" )
	
	-- this if-in-if statement exists because of the fact that Lua doesn't have
	-- an 'andalso' operator...
	if map.isLegal( e.map, e.x+x, e.y+y ) then
		if not contains( e.map.terrain[e.x+x][e.y+y].flags, "solid" ) then
			local ee = entity.findByPosition( e.map, e.x+x, e.y+y )
			if not ee then
				e.x = e.x + x
				e.y = e.y + y
	 
				log.file:write( "[moveRelative] Entity " .. tostring( e ) ..
					" has moved to " .. e.x .. "," .. e.y .. "\n" )

				return true
			else
				log.file:write( "[moveRelative] Entity " .. tostring( e ) ..
					" has tried to attack entity " .. tostring( ee ) .. "\n" )
			
				if e == game.player then
					entity.die( ee )
				end
			end
		else
			log.file:write( "[moveRelative] Entity " .. tostring( e ) ..
				" bumped into terrain at " .. e.x+x .. "," .. e.y+y .. "\n" )
			return false
		end
	else
		log.file:write( "[moveRelative] Entity " .. tostring( e ) ..
			" tried an illegal move at " .. e.x+x .. "," .. e.y+y .. "\n" )
		return false
	end
end

-- note: no more than one entity can occupy a tile at a certain time.
function entity.findByPosition( map, x, y )
	assert( type( map ) == "table" )
	assert( type( x ) == "number" )
	assert( type( y ) == "number" )
	
	for i = 1, #game.entity do
		if	game.entity[i].map == map and
			game.entity[i].x == x and
			game.entity[i].y == y and
			game.entity[i].active then
			return game.entity[i]
		end
	end

	return nil
end

function entity.die( e )
	assert( type( e ) == "table" )

	log.file:write( "[die] Entity " .. tostring( e ) .. " has passed away.\n" )

	e.hp = 0
	e.active = false
end

