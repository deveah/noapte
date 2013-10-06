
ui = {}

function ui.init()
	ui.cols, ui.rows = curses.init()
	log.file:write( "[ui] Screen has " .. ui.cols .. " cols and " .. ui.rows
		.. " rows.\n" )

	ui.camera = {}
	ui.camera.x = 0
	ui.camera.y = 0
end

function ui.terminate()
	curses.clear()
	curses.refresh()
	curses.terminate()
end

function ui.drawMainScreen()
	ui.updateCamera()

	sight.updateFOV( game.player, game.sightRadius )

	for i = 0, ui.cols - 1 do
		for j = 1, ui.rows - 3 do
			local ax = i + ui.camera.x - math.floor( ui.cols/2 )
			local ay = j + ui.camera.y - math.floor( ui.rows/2 )

			if map.isLegal( game.player.map, ax, ay ) then
				local e = entity.findByPosition( game.player.map, ax, ay )
				local o = object.findByPosition( game.player.map, ax, ay )
				
				if e and e.active and game.player.sightMap[ax][ay] == sight.lit then
					curses.attr( e.color )
					curses.write( i, j, e.face )
				elseif o and game.player.sightMap[ax][ay] == sight.lit then
					-- only the topmost object is drawn
					curses.attr( o[1].color )
					curses.write( i, j, o[1].face )
				else
					if game.player.sightMap[ax][ay] == sight.lit then
						curses.attr( game.player.map.terrain[ax][ay].color )
						curses.write( i, j, game.player.map.terrain[ax][ay].face )
					elseif game.player.sightMap[ax][ay] == sight.seen then
						curses.attr( curses.blue )
						curses.write( i, j, game.player.map.terrain[ax][ay].face )
					else
						curses.write( i, j, " " )
					end
				end
			else
				curses.write( i, j, " " )
			end
		end
	end

	curses.attr( curses.white )

	-- hack to clear the message line
	for i = 0, ui.cols - 1 do
		curses.write( i, 0, " " )
	end

	local currentMessages = {}
	for i = 1, #message.list do
		if not contains( message.list[i].flags, "read" ) then
			table.insert( currentMessages, message.list[i].msg )
			table.insert( message.list[i].flags, "read" )
		end
	end

	local msgLine = ""
	for i = 1, #currentMessages do
		if string.len( msgLine ) + string.len( currentMessages[i] ) < ui.cols - 1 then
			msgLine = msgLine .. currentMessages[i] .. " "
		else
			-- TODO: unhandled if message line exceeds screen width!
		end
	end

	curses.write( 0, 0, msgLine )

	local infoString = string.format( "%s (%i/%i)", game.player.name,
		game.player.hp, game.player.maxHp )
	curses.write( 0, ui.rows-2, infoString )

	curses.refresh()
end

function ui.updateCamera()
	while ui.camera.x - game.player.x < -math.floor( ui.cols * 0.25 ) do
		ui.camera.x = ui.camera.x + 1
	end

	while ui.camera.x - game.player.x > math.floor( ui.cols * 0.25 ) do
		ui.camera.x = ui.camera.x - 1
	end

	while ui.camera.y - game.player.y < -math.floor( ui.rows * 0.25 ) do
		ui.camera.y = ui.camera.y + 1
	end

	while ui.camera.y - game.player.y > math.floor( ui.rows * 0.25 ) do
		ui.camera.y = ui.camera.y - 1
	end
end

function ui.centerCameraOnPlayer()
	ui.camera.x = game.player.x
	ui.camera.y = game.player.y
end

function ui.inputDirection()

	local k = curses.getch()

	if contains( keymap.north, k ) then
		return { x = 0, y = -1 }
	end

	if contains( keymap.south, k ) then
		return { x = 0, y = 1 }
	end

	if contains( keymap.west, k ) then
		return { x = -1, y = 0 }
	end

	if contains( keymap.east, k ) then
		return { x = 1, y = 0 }
	end

	if contains( keymap.northwest, k ) then
		return { x = -1, y = -1 }
	end

	if contains( keymap.northeast, k ) then
		return { x = 1, y = -1 }
	end

	if contains( keymap.southwest, k ) then
		return { x = -1, y = 1 }
	end

	if contains( keymap.southeast, k ) then
		return { x = 1, y = 1 }
	end

	return false
end

function ui.listInventory()
	for i = 1, #game.player.inventory do
		curses.write( 0, i, game.player.inventory[i].name )
	end

	curses.getch()
end

