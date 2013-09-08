
log = {}

function log.init()
	--log.file = io.open( "log-" .. os.date( "%d-%m-%y-%H-%M-%S" ), "w" )
	log.file = io.open( "log.txt", "w" )
	assert( log.file )
	log.file:write( "==\n" )
end

function log.terminate()
	log.file:write( "==\n" )
	log.file:close()
end

