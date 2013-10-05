
combat = {}

function combat.meleeAttack( atk, def )
	assert( type( atk ) == "table" )
	assert( type( def ) == "table" )

	log.file:write( "[meleeAttack] Entity " .. tostring( atk ) ..
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

