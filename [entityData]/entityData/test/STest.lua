--- Test 1
addCommandHandler("sTest", function(player)
	local ct = createTransaction()
	local types = {"public", "private", "local"}
	for i=1,28 do
		setEntityData(player, "ExampleTest1:"..i, math.random()*128, types[math.random(1, #types)], ct)
	end
	local seconds = math.random(1, 10)*1000
	outputChatBox("The transaction will be sent in 5 seconds")
	setTimer(function(ct)
		triggerTransaction(ct)
	end, seconds, 1, ct)
end)

--- Test 2
addCommandHandler("sTest2", function(player)
	local tables = {}
	local types = {"public", "private", "local"}
	for i=1,50 do
		tables[i] = {player, "ExampleTest2:"..i, math.random()*128, types[math.random(1, #types)]}
	end
	triggerTransaction(tables)
end)

--- Test 3
addCommandHandler("sTest3", function(player)
	setKeyFlag("money", {type = "number", value = "int", between = {0, 50} } )
	setKeyFlag("money:float", {type = "number", value = "float", between = {0, 50} } )
	local types = {"public", "private", "local"}
	setEntityData(player, "money:float", 25.5, types[math.random(1, #types)])
	timer3 = setTimer(function(player)
		setEntityData(player, {"money", "money:float"}, {math.random(1, 50), math.random()}, types[math.random(1, #types)])
	end, 500, 50, player)
end)

--- Test 4
addCommandHandler("sTest4", function()
	local players = getElementsByType("player")
	setEntityData(players, "Key", "Value", "private")
	print(inspect(players))
	setTimer(function(players)
		setEntityData(players[1], "Key", "NewValue", "private")
	end, 1500, 1, players)
end)

-- Test 5
timerTest = {}
addCommandHandler("sTest5", function(player)
	setKeyFlag("money", {func = function(value)  return value == 35 end} )
	timerTest[player] = setTimer(function(player)
		if setEntityData(player, "money", math.random(1, 2) == 1 and math.random(1, 100)*0.35 or math.random(0, 100) ) then
			if isTimer( timerTest[player] ) then
				killTimer( timerTest[player] )
			end
		end
	end, 500, 0, player)

end)

-- Test 6
addCommandHandler("sTest6", function(player)
	local tables = {}
	local types = {"public", "private", "local"}
	for i=1,50 do
		tables[i] = {player, "ExampleTest6:"..i, math.random()*128, types[math.random(1, #types)]}
	end
	triggerTransaction(tables)
end)


-- Test 7
addCommandHandler("sTest7", function(player)
	local tables = {}
	local types = {"public", "private", "local"}
	for i=1,50 do
		tables[i] = {player, "ExampleTest6:"..i, math.random()*128, types[math.random(1, #types)]}
	end
	triggerTransaction(tables)
end)


-- Test 8
addCommandHandler("sTest8", function(player)
	local element = createElement("Example", "Test Element")
	setEntityData(element, "Animal", "Dog", "private")
	setEntityData(element, "Animal", "Horse", "public")
	setEntityData(element, "Animal", "Cat", "local")

	setEntityData(player, "Animal", "Cat", "private")
	setEntityData(player, "Animal", "Dog", "public")
	setEntityData(player, "Animal", "Horse", "local")

	addEventHandler( "onElementDestroy", element, function()
		setEntityData(player, "Animal", "Cow", "private")
	end)

	setTimer(function(thisElement)
		destroyElement(thisElement)
		setEntityData(player, "Animal", "Bunny", "private")
	end, 5000, 1, element)
end)