
require "lua/tile"
require "lua/map"
require "lua/mapgen"
require "lua/entity"
require "lua/util"
require "lua/sight"
require "lua/ui"
require "lua/log"
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
	local m = mapgen.dummy( game.defaultMapWidth, game.defaultMapHeight )
	table.insert( game.map, m )
	log.file:write( "[init] Generated dummy map.\n" )

	-- create the player
	game.player = entity.makePlayer( "Player" )
	table.insert( game.entity, game.player )
	game.player.map = m
	game.player.x = 10
	game.player.y = 10
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

	-- a global turn is one in which all available entities act;
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
		e.x = math.random( 1, game.player.map.width )
		e.y = math.random( 1, game.player.map.height )

		e.active = true

		log.file:write( "[makeRandomEntities] Made entity " .. tostring( e )
			.. ".\n" )
		table.insert( game.entity, e )
	end
end

