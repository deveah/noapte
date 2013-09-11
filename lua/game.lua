
require "lua/log"
require "lua/message"
require "lua/tile"
require "lua/map"
require "lua/mapgen"
require "lua/entity"
require "lua/util"
require "lua/sight"
require "lua/ui"
require "lua/settings"

game = {}

game.defaultMapWidth = 100
game.defaultMapHeight = 40

game.sightRadius = 10

function game.init()
	-- init tables that hold general game data
	game.map = {}
	game.object = {}
	game.entity = {}

	-- activate logging
	log.init()
	log.file:write( "[init] Started log.\n" )

	-- set random seed
	local seed = os.time()
	math.randomseed( seed )
	log.file:write( "[init] Seed: " .. seed .. "\n" )

	-- create map
	--local m = mapgen.dummy( game.defaultMapWidth, game.defaultMapHeight )
	local m = mapgen.formScatter( game.defaultMapWidth, game.defaultMapHeight )
	table.insert( game.map, m )
	log.file:write( "[init] Generated dummy map.\n" )

	-- create the player
	game.player = entity.makePlayer( "Player" )
	table.insert( game.entity, game.player )
	game.player.map = m
	
	repeat
		game.player.x = math.random( 1, m.width )
		game.player.y = math.random( 1, m.height )
	until m.terrain[game.player.x][game.player.y] == tile.floor

	game.player.hp = 10
	game.player.maxHp = 10
	sight.initMap( game.player )
	log.file:write( "[init] Generated the player: " .. tostring( game.player )
		.. "\n" )

	-- create some dumb entities
	game.makeRandomEntities( 10 )

	-- create the interface
	ui.init()
	log.file:write( "[init] Started the interface.\n" )

	game.running = true
	log.file:write( "[init] Game now up and running.\n" )

	-- a global turn is one in which one entity acts;
	-- a player turn is a turn in which the player executes a single action
	game.globalTurns = 0
	game.playerTurns = 0

	ui.centerCameraOnPlayer()
end

function game.loop()
	while game.running do

		local activeEntities = 0

		for i = 1, #game.entity do
			local e = game.entity[i]
			
			if e.active then
				log.file:write( "[loop] current entity: " .. tostring( e )
					.. "\n" )
				e.ap = e.ap + e.agility
				
				entity.act( e )
				
				game.globalTurns = game.globalTurns + 1

				activeEntities = activeEntities + 1
			end
		end

		-- sweep for dead bodies, marking them as inactive
		for i = 1, #game.entity do
			if game.entity[i].hp <= 0 then
				game.entity[i].active = false
			end
		end

		log.file:write( "[loop] Active entities: " .. activeEntities .. "\n" )
	end
end

function game.terminate()
	log.file:write( "[terminate] Terminating game...\n" )
	game.running = false

	log.file:write( "[terminate] Terminating interface...\n" )
	ui.terminate()
	
	log.file:write( "[terminate] Closing log.\n" )
	log.terminate()
end

function game.handleKey( k )
	assert( type( k ) == "string" )
	
	if contains( keymap.quit, k ) then
		game.running = false
		return true
	end

	if contains( keymap.north, k ) then
		return entity.moveRelative( game.player, 0, -1 )
	end

	if contains( keymap.south, k ) then
		return entity.moveRelative( game.player, 0, 1 )
	end

	if contains( keymap.west, k ) then
		return entity.moveRelative( game.player, -1, 0 )
	end

	if contains( keymap.east, k ) then
		return entity.moveRelative( game.player, 1, 0 )
	end

	if contains( keymap.northwest, k ) then
		return entity.moveRelative( game.player, -1, -1 )
	end

	if contains( keymap.northeast, k ) then
		return entity.moveRelative( game.player, 1, -1 )
	end

	if contains( keymap.southwest, k ) then
		return entity.moveRelative( game.player, -1, 1 )
	end

	if contains( keymap.southeast, k ) then
		return entity.moveRelative( game.player, 1, 1 )
	end

	if contains( keymap.meleeAttack, k ) then
		message.push( "Attack where?" )
		ui.drawMainScreen()

		local kk = ui.inputDirection()
		if kk then
			local e = entity.findByPosition( game.player.map,
				game.player.x + kk.x, game.player.y + kk.y )
			if not e then
				message.push( "There's noone there." )
				return false
			end

			return entity.meleeAttack( game.player, e )
		else
			return false
		end
	end

	if contains( keymap.debugShowMap, k ) then
		for i = 1, game.player.map.width do
			for j = 1, game.player.map.height do
				if game.player.sightMap[i][j] ~= sight.lit then
					game.player.sightMap[i][j] = sight.seen
				end
			end
		end

		return false
	end

	message.push( "That's not a valid key." )

	return false
end

function game.makeRandomEntities( n )
	assert( type( n ) == "number" )

	for i = 1, n do
		local e = clone( entity.proto )
		e.name = "Hurr-durr #" .. i
		e.hp = 1
		e.maxHp = 1
		e.agility = math.random( 5, 13 )
		e.ap = 0

		e.map = game.player.map

		repeat
			e.x = math.random( 1, game.player.map.width )
			e.y = math.random( 1, game.player.map.height )
		until game.player.map.terrain[e.x][e.y] == tile.floor

		e.active = true

		log.file:write( "[makeRandomEntities] Made entity " .. tostring( e )
			.. ".\n" )
		table.insert( game.entity, e )
	end
end

