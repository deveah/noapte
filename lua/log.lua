
log = {}

function log.init()
	if misc.logging then
		log.file = io.open( "log.txt", "w" )
		assert( log.file )
		log.file:write( "==\n" )
	else
		-- hackety-hack-hack
		log.file = {}
		function log.file:write( string )
			return true
		end
		function log.file:close()
			return true
		end
	end
end

function log.terminate()
	log.file:write( "==\n" )
	log.file:close()
end

