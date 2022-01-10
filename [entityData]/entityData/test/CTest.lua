local sx, sy = guiGetScreenSize(  )
local scaleValue = sy / 1080

addEventHandler( "onClientRender", root, function()
	dxDrawText("EntityData:\n"..tostring(inspect(entityData.type)), scaleValue*50, scaleValue*150, sx, sy)
	dxDrawText("EntityData Flag:\n"..tostring(inspect(entityData.flag)), scaleValue*400, scaleValue*150, sx, sy)
	dxDrawText("EntityData Transaction:\n", scaleValue*750, scaleValue*150, sx, sy)
	for i,v in ipairs(entityData.transaction) do
		for a,b in ipairs(v) do
			dxDrawText(tostring(inspect(b)), scaleValue*750, scaleValue*150+(scaleValue*25*a), sx, sy)
		end
	end
	dxDrawText("EntityData Coroutine:\n"..tostring(inspect(entityData.coroutine)), scaleValue*1100, scaleValue*150, sx, sy)
end)

--- Test 1
addCommandHandler("clearTest", function()
	if isTimer( timer3 ) then
		killTimer(timer3)
	end
	entityData.flag = {}
	entityData.type = {
		['local'] = {},
		['public'] = {},
		['private'] = {},
	}
	entityData.coroutine = {}
	entityData.transaction = {}
end)

--- Test 1
addCommandHandler("cTest", function()
	local ct = createTransaction()
	local types = {"public", "private", "local"}
	for i=1,28 do
		setEntityData(localPlayer, "ExampleTest1:"..i, math.random()*128, types[math.random(1, #types)], ct)
	end
	local seconds = math.random(1, 10)*1000
	outputChatBox("The transaction will be sent in 5 seconds")
	setTimer(function(ct)
		triggerTransaction(ct)
	end, seconds, 1, ct)
end)


--- Test 2
addCommandHandler("cTest2", function()
	local tables = {}
	local types = {"public", "private", "local"}
	for i=1,50 do
		tables[i] = {localPlayer, "ExampleTest2:"..i, math.random()*128, types[math.random(1, #types)]}
	end
	triggerTransaction(tables)
end)

-- Test 3
addCommandHandler("cTest3", function()
	setKeyFlag("money", {type = "number", value = "int", between = {0, 50} } )
	setKeyFlag("money:float", {type = "number", value = "float", between = {0, 50} } )
	local types = {"public", "private", "local"}
	setEntityData(localPlayer, "money:float", 25.5, types[math.random(1, #types)])
	timer3 = setTimer(function()
		setEntityData(localPlayer, {"money", "money:float"}, {math.random(1, 50), math.random()}, types[math.random(1, #types)])
	end, 500, 50)
end)

--- Test 4
addCommandHandler("cTest4", function()
	local players = getElementsByType("player")
	setEntityData(players, "Key", "Value", "private")
	setTimer(function(players)
		setEntityData(players[1], "Key", "NewValue", "private")
	end, 1500, 1, players)
end)

-- Test 5
addCommandHandler("cTest5", function()
	setKeyFlag("money", {func = function(value)  return value == 35 end} )
	timer5 = setTimer(function()
		if setEntityData(localPlayer, "money", math.random(1, 2) == 1 and math.random(1, 100)*0.35 or math.random(0, 100) ) then
			if isTimer( timer5 ) then
				killTimer( timer5 )
			end
		end
	end, 500, 0)

end)

-- Test 6
addCommandHandler("cTest6", function()
	local tables = {}
	local types = {"public", "private", "local"}
	for i=1,50 do
		tables[i] = {localPlayer, "ExampleTest6:"..i, math.random()*128, types[math.random(1, #types)]}
	end
	triggerTransaction(tables)
end)


-- Test 7
addCommandHandler("cTest7", function()
	local tables = {}
	local types = {"public", "private", "local"}
	for i=1,50 do
		tables[i] = {localPlayer, "ExampleTest6:"..i, math.random()*128, types[math.random(1, #types)]}
	end
	triggerTransaction(tables)
end)


-- Test 8
addCommandHandler("cTest8", function()
	local element = createElement("Example", "Test Element")
	setEntityData(element, "Animal", "Dog", "private")
	setEntityData(element, "Animal", "Horse", "public")
	setEntityData(element, "Animal", "Cat", "local")

	setEntityData(localPlayer, "Animal", "Cat", "private")
	setEntityData(localPlayer, "Animal", "Dog", "public")
	setEntityData(localPlayer, "Animal", "Horse", "local")

	setTimer(function(thisElement)
		destroyElement(thisElement)
	end, 5000, 1, element)
end)

--- Test 9
addCommandHandler("cTest9", function()
	for n=1,5 do
		local ct = createTransaction()
		local types = {"public", "private", "local"}
		for i=1,28 do
			setEntityData(localPlayer, "ExampleTest1:"..i.."["..n.."]", math.random()*128, types[math.random(1, #types)], ct)
		end
		local seconds = math.random(1, 10)*1000
		outputChatBox("The transaction will be sent in 5 seconds")
		setTimer(function(ct)
			triggerTransaction(ct)
		end, seconds, 1, ct)
	end
end)
