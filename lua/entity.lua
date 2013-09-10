
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
			if entity.dumbAI( e ) then
				e.ap = e.ap - 10
			end
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
					" has bumped into entity " .. tostring( ee ) )

				if e == game.player then
					message.push( "You bump into " .. ee.name .. "." )
				end
			end
		else
			log.file:write( "[moveRelative] Entity " .. tostring( e ) ..
				" bumped into terrain at " .. e.x+x .. "," .. e.y+y .. "\n" )

			if e == game.player then
				message.push( "Bump!" )
			end

			return false
		end
	else
		log.file:write( "[moveRelative] Entity " .. tostring( e ) ..
			" tried an illegal move at " .. e.x+x .. "," .. e.y+y .. "\n" )

		if e == game.player then
			message.push( "Nuh-uh." )
		end

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

	message.push( e.name .. " has died." )

	log.file:write( "[die] Entity " .. tostring( e ) .. " has passed away.\n" )

	e.hp = 0
	e.active = false

	if e == game.player then
		message.push( "You die... Press any key to exit." )
		ui.drawMainScreen()
		curses.getch()

		game.running = false
	end
end

-- if near player, attack; else move randomly
-- that's, like, the definition of DumbAI (TM)
function entity.dumbAI( e )
	local dir = {
		{ -1,  0 },
		{  1,  0 },
		{  0, -1 },
		{  0,  1 }
	}

	local d = dir[ math.random( 1, 4 ) ]

	if entity.nearPlayer( e ) then
		return entity.meleeAttack( e, game.player )
	else
		return entity.moveRelative( e, d[1], d[2] )
	end
end

function entity.meleeAttack( atk, def )
	assert( type( atk ) == "table" )
	assert( type( def ) == "table" )

	log.file:write( "[moveRelative] Entity " .. tostring( atk ) ..
		" has tried to attack entity " .. tostring( def ) .. "\n" )
	if atk == game.player then
		message.push( "You attack " .. def.name .. "." )
	else
		message.push( atk.name .. " attacks " .. def.name .. "." )
	end

	def.hp = def.hp - 1
	if def.hp <= 0 then
		entity.die( def )
	end

	return true
end

function entity.nearPlayer( e )
	assert( type( e ) == "table" )

	return math.abs( e.x - game.player.x ) <= 1 and
		math.abs( e.y - game.player.y ) <= 1
end

