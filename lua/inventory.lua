
inventory = {}

-- TODO: logging

function inventory.addObj( ent, obj )
	assert( type( e ) == "table" )
	assert( type( o ) == "table" )

	local found = false
	for i = 1, #ent.inventory do
		if ent.inventory[i].name == obj.name then
			ent.inventory[i].quantity = ent.inventory[i].quantity + obj.quantity
			found = true
		end
	end

	if not found then
		table.insert( ent.inventory, obj )
	end

	-- TODO: check weight overload?
	return true
end

function inventory.dropObj( ent, objId )
	assert( type( e ) == "table" )
	assert( type( objId ) == "number" )

	if objId > #ent.inventory then
		return false
	end

	if objId < 1 then
		return false
	end

	obj = clone( ent.inventory[objId] )
	table.remove( ent.inventory, objId )

	obj.x = ent.x
	obj.y = ent.y
	obj.map = ent.map

	table.insert( game.object, obj )

	return true
end

