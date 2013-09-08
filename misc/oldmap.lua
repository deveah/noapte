
function newMap( width, height )
	local m = {}
	m.width = width
	m.height = height

	for i = 1, width do
		m[i] = {}
		for j = 1, height do
			m[i][j] = 0
		end
	end

	return m
end

function isLegal( m, x, y )
	return x > 0 and y > 0 and x <= m.width and y <= m.height
end

function getAvg( m, x, y, r )
	local a, n = 0, 0

	for i = x-r, x+r do
		for j = y-r, y+r do
			if isLegal( m, i, j ) then
				a = a + m[i][j]
				n = n + 1
			end
		end
	end

	return a/n
end

function getQAvg( m, x, y )
	local a, n = 0, 0

	if isLegal( m, x-1, y ) then a = a + m[x-1][y]; n = n + 1; end
	if isLegal( m, x+1, y ) then a = a + m[x+1][y]; n = n + 1; end
	if isLegal( m, x, y-1 ) then a = a + m[x][y-1]; n = n + 1; end
	if isLegal( m, x, y+1 ) then a = a + m[x][y+1]; n = n + 1; end

	return a/n
end

function fillNoise( map, f )
	for i = 1, map.width do
		for j = 1, map.height do
			if f > math.random() then
				map[i][j] = math.random( 0, 100 ) / 1000 + 0.9
			else
				map[i][j] = math.random()
			end
		end
	end
end

function grow( map, noise )
	local m = newMap( map.width*2-1, map.height*2-1 )

	for i = 1, m.width do
		for j = 1, m.height do
			if i % 2 == 1 and j % 2 == 1 then
				m[i][j] = map[math.ceil(i/2)][math.ceil(j/2)]
			elseif i % 2 == 0 and j % 2 == 0 then
				m[i][j] = getAvg( map, math.ceil(i/2), math.ceil(j/2), 1 )
				m[i][j] = m[i][j] + ( math.random() * noise - noise/2 )
				if m[i][j] < 0 then m[i][j] = 0 end
				if m[i][j] > 1 then m[i][j] = 1 end
			else
				m[i][j] = -1
			end
		end
	end

	for i = 1, m.width do
		for j = 1, m.height do
			if m[i][j] == -1 then
				m[i][j] = getQAvg( m, i, j )
				m[i][j] = m[i][j] + ( math.random() * noise - noise/2 )
				if m[i][j] < 0 then m[i][j] = 0 end
				if m[i][j] > 1 then m[i][j] = 1 end
			end
		end
	end

	return m
end

function blur( m, r )
	local mm = newMap( m.width, m.height )

	for i = 1, mm.width do
		for j = 1, mm.height do
			mm[i][j] = getAvg( m, i, j, r )
		end
	end

	return mm
end

function showMap( m )
	--local tileset = "~.,:;+*#"
	local tileset = "~.,:+"

	for j = 1, m.height do
		for i = 1, m.width do
			local l = math.floor( m[i][j] * ( string.len( tileset ) - 1 ) ) + 1
			io.write( string.char( string.byte( tileset, l ) ) )
		end
		io.write( '\n' )
	end
end

function drawMap( m )
	x, y = curses.init()

	local cx, cy = math.floor(m.width/2), math.floor(m.height/2)
	local k = ""

	while k ~= "q" do
		
		for i = -math.floor(x/2), math.floor(x/2) do
			for j = -math.floor(y/2), math.floor(y/2) do
				local ax, ay = i+cx, j+cy
				
				if isLegal( m, ax, ay ) then
					local tileset = "~..,:+#"
					local c = string.char( string.byte( tileset, math.floor( ( string.len( tileset ) - 1 ) * m[ax][ay] ) + 1 ) )
				
					local attr = 0

					if m[ax][ay] < 0.3 then
						attr = curses.blue
					elseif m[ax][ay] < 0.6 then
						attr = curses.green
					elseif m[ax][ay] < 0.85 then
						attr = curses.yellow
					else
						attr = curses.black
					end

					if i == 0 and j == 0 then
						attr = attr + curses.reverse
					end

					curses.attr( attr )
					curses.write( i+math.floor(x/2), j+math.floor(y/2), c )
				else
					curses.write( i+math.floor(x/2), j+math.floor(y/2), " " )
				end
			end
		end

		curses.attr( curses.white + curses.reverse )
		curses.write( 0, 0, string.format( "%i, %i [%f]", cx, cy, m[cx][cy] ) )

		k = curses.getch()
		if k == "up" then cy = cy - 1 end
		if k == "down" then cy = cy + 1 end
		if k == "left" then cx = cx - 1 end
		if k == "right" then cx = cx + 1 end
	end

	curses.terminate()
end

function main()
	math.randomseed( os.time() )

	local m = newMap( 11, 4 )
	fillNoise( m, 0.66 )
	
	m = grow( m, 2.0 )
	m = grow( m, 1.0 )
	m = grow( m, 0.5 )
	m = grow( m, 0.3 )
	m = grow( m, 0.1 )
	m = grow( m, 0.05 )
	m = grow( m, 0.01 )

	m = blur( m, 3 )

	--showMap( m )
	drawMap( m )

	print( "size: " .. m.width .. "x" .. m.height )
end

main()

