addEvent("onClientEntityDataChange", true)
addEvent("onClientTransactionChange", true)
addEvent("onClientSyncEntityData", true)
addEvent("onClientSyncKeyFlag", true)

entityData = {}
entityData.flag = {}
entityData.type = {
	['local'] = {},
	['public'] = {},
	['private'] = {},
}
entityData.coroutine = {}
entityData.transaction = {}

function isTransaction(transaction)
	return entityData.transaction[transaction] ~= nil
end

function isEntityData(Entity)
	if Entity and type(Entity) == "userdata" or type(Entity) == "string" or type(Entity) == "table" then
		return true
	else
		return false
	end
end

local function stringToBoolean(str)
	if str:lower() == "true" then
		return true
	elseif str:lower() == "false" then
		return false
	else
		return nil
	end
end

local function getTableFreeIndex(tableName)
  local Count = 1
  local CurrentVal = (tableName[tonumber(Count)])
  local repeating = true
  while repeating == true do
    if CurrentVal ~= nil then
      Count = Count + 1
      CurrentVal = tableName[tonumber(Count)]
     else
      repeating = false
      TableSize = Count - 1
    end
  end
  return TableSize+1
end

function setKeyFlag(cKey, cFlag)
	local scope = {}
	scope.validKey = type(cKey) == "table" or type(cKey) == "string"
	scope.validFlag = type(cFlag) == "table" or cFlag == nil
	if scope.validKey and scope.validFlag then
		scope.isKeyTable = type(cKey) == "table"
		if scope.isKeyTable then
			for keyID = 1, #cKey do
				entityData.flag[cKey[keyID]] = cFlag == nil and nil or cFlag
			end
		else
			entityData.flag[cKey] = cFlag == nil and nil or cFlag
		end
		if eventName == nil then
				triggerServerEvent("onServerSyncKeyFlag", root, cKey, cFlag)
		end
		return true
	else
		return false
	end
end
addEventHandler("onClientSyncKeyFlag", root, setKeyFlag)

function onClientEntityDataChange(theKey, oldValue, newValue, dataType)
	if dataType == "private" and newValue ~= nil then
		local elements = getElementsByEntityDataKey(theKey, dataType)
		for element in pairs(elements) do
			entityData.type[dataType][element][theKey] = newValue
		end
	-- elseif dataType == "public" then
	-- 	if entityData.type['local'][source] == nil then 
	-- 		entityData.type['local'][source] = {}
	-- 	end
	-- 	entityData.type["local"][source][theKey] = newValue
	end
end
addEventHandler("onClientEntityDataChange", root, onClientEntityDataChange)

function createTransaction()
	local index = getTableFreeIndex(entityData.transaction)
	entityData.transaction[index] = {}
	return index
end

function cancelTransaction(cTransaction)
	if isTransaction(cTransaction) then
		entityData.transaction[cTransaction] = nil
		return true
	else
		return false
	end
end

function executeTransaction(cTransaction, executeData)
	if type(cTransaction) == "table" or entityData.coroutine[cTransaction] then
		local i = 0
		for _,v in pairs(executeData) do
			if setEntityData(v[1], v[2], v[3], v[4], false) then i = i+1 end
			if i%5 == 0 then
				setTimer(function(cTransaction, executeData) coroutine.resume(entityData.coroutine[cTransaction], cTransaction, executeData) end, 150, 1, cTransaction, executeData)
				coroutine.yield()
			end
		end
		triggerEvent("onClientTransactionChange", root, cTransaction)
		entityData.coroutine[cTransaction] = nil
	end
end

function triggerTransaction(cTransaction)
	if isTransaction(cTransaction) then
		entityData.coroutine[cTransaction] = coroutine.create(executeTransaction)
		coroutine.resume(entityData.coroutine[cTransaction], cTransaction, entityData.transaction[cTransaction])
		entityData.transaction[cTransaction] = nil
	elseif type(cTransaction) == "table" then
		local index = getTableFreeIndex(entityData.coroutine)
		entityData.coroutine[index] = coroutine.create(executeTransaction)
		coroutine.resume(entityData.coroutine[index], index, cTransaction )
	end
end


function getElementsByEntityDataKey(cKey, cType)
	local scope = {elements = {}}
	scope.validKey = type(cKey) == "string"
	scope.validType = type(entityData.type[cType]) == "table" and cType or cType == "all" and cType or cType
	if scope.validKey and scope.validType then
		if cType == "all" then
			for _,typeData in pairs(entityData.type) do
				if type(typeData) == "table" then
					for element in pairs(typeData) do
						if scope.elements[element] == nil then
							scope.elements[element] = true
						end
					end
				end
			end
			return scope.elements
		else
			for element in pairs(entityData.type[cType]) do
				if scope.elements[element] == nil then
					scope.elements[element] = true
				end
			end
			return scope.elements
		end
	end
	return false
end

function getAllEnintyData(cEntity, cType)
	local scope = { elements = {}, values = {}, result = {}}
	scope.validEntity = isEntityData(cEntity)
	scope.validType = type(entityData.type[cType]) == "table" and cType or "public"
	cType = scope.validType
	if scope.validEntity and scope.validType then
		scope.isEntityTable = type(cEntity) == "table"
		if scope.isEntityTable then
			for entityID = 1, #cEntity do
				scope.elements[entityID] = isEntityData(cEntity) and cEntity[entityID] or nil
			end
		else
			scope.elements[1] = isEntityData(cEntity) and cEntity
		end
		for entityID = 1, #scope.elements do
			scope.result[entityID] = entityData.type[cType][scope.elements[entityID]]
		end
		local result = scope.isEntityTable and scope.result or scope.result[1]
		return result
	end
end

function hasEntityData(cEntity, cKey, cType)
	local scope = { elements = {}, values = {}, result = {}}
	scope.validEntity = isEntityData(cEntity)
	scope.validKey = type(cKey) == "table" or type(cKey) == "string"
	scope.validType = type(entityData.type[cType]) == "table" and cType or "public"
	cType = scope.validType
	if scope.validEntity and scope.validKey and scope.validType then
		scope.isEntityTable = type(cEntity) == "table"
		scope.isKeyTable = type(cKey) == "table"
		if scope.isEntityTable then
			for entityID = 1, #cEntity do
				scope.elements[entityID] = isEntityData(cEntity) and cEntity[entityID] or nil
			end
		else
			scope.elements[1] = isEntityData(cEntity) and cEntity
		end
		if scope.isKeyTable then
			for keyID = 1, #cKey do
				for entityID = 1, #scope.elements do
					if entityData.type[cType][scope.elements[entityID]] ~= nil then
						scope.result[keyID] = entityData.type[cType][scope.elements[entityID]][ cKey[keyID] ] ~= nil
					else
						scope.result[keyID] = false
					end
				end
			end
		else
			for entityID = 1, #scope.elements do
				if entityData.type[cType][scope.elements[entityID]] ~= nil then
					scope.result[1] = entityData.type[cType][scope.elements[entityID]][cKey] ~= nil
				else
					scope.result[1] = false
				end
			end
		end
		local result = scope.isKeyTable and scope.result or scope.result[1]
		return result
	end
	return false
end

function getEntityData(cEntity, cKey, cType)
	local scope = { elements = {}, values = {}, result = {}}
	scope.validEntity = isEntityData(cEntity)
	scope.validKey = type(cKey) == "table" or type(cKey) == "string"
	scope.validType = type(entityData.type[cType]) == "table" and cType or "public"
	cType = scope.validType
	if scope.validEntity and scope.validKey and scope.validType then
		scope.isEntityTable = type(cEntity) == "table"
		scope.isKeyTable = type(cKey) == "table"
		if scope.isEntityTable then
			for entityID = 1, #cEntity do
				scope.elements[entityID] = isEntityData(cEntity) and cEntity[entityID] or nil
			end
		else
			scope.elements[1] = isEntityData(cEntity) and cEntity
		end
		if scope.isKeyTable then
			for keyID = 1, #cKey do
				for entityID = 1, #scope.elements do
					if entityData.type[cType][scope.elements[entityID]] ~= nil and entityData.type[cType][scope.elements[entityID]][cKey[keyID]] ~= nil then
							scope.result[keyID] = entityData.type[cType][scope.elements[entityID]][ cKey[keyID] ]
					elseif cType ~= "private" then
						if entityData.type["public"][scope.elements[entityID]] ~= nil and entityData.type["public"][scope.elements[entityID]][cKey[keyID]] ~= nil then
								scope.result[keyID] = entityData.type["public"][scope.elements[entityID]][cKey[keyID]]
						elseif entityData.type["local"][scope.elements[entityID]] ~= nil and entityData.type["local"][scope.elements[entityID]][cKey[keyID]] ~= nil then
								scope.result[keyID] = entityData.type["local"][scope.elements[entityID]][cKey[keyID]]
						else
								scope.result[keyID] = false				
						end							
					else
							scope.result[keyID] = false
					end
				end
			end
		else
			for entityID = 1, #scope.elements do
				if entityData.type[cType][scope.elements[entityID]] ~= nil and entityData.type[cType][scope.elements[entityID]][cKey] ~= nil then
						scope.result[1] = entityData.type[cType][scope.elements[entityID]][cKey]
				elseif cType ~= "private" then
						if entityData.type["public"][scope.elements[entityID]] ~= nil and entityData.type["public"][scope.elements[entityID]][cKey] ~= nil then
								scope.result[1] = entityData.type["public"][scope.elements[entityID]][cKey]
						elseif entityData.type["local"][scope.elements[entityID]] ~= nil and entityData.type["local"][scope.elements[entityID]][cKey] ~= nil then
								scope.result[1] = entityData.type["local"][scope.elements[entityID]][cKey]
						else
								scope.result[1] = false				
						end
				else
						scope.result[1] = false
				end
			end
		end
		local result = scope.isKeyTable and scope.result or scope.result[1]
		return result
	end
	return false
end

function setEntityData(cEntity, cKey, sValue, cType, cTransaction, cCancelTrigger)
	local scope = { elements = {}, values = {} }
	scope.validEntity = isEntityData(cEntity)
	scope.validKey = type(cKey) == "table" or type(cKey) == "string"
	scope.validType = type(entityData.type[cType]) == "table" and cType or "public"
	scope.validTransaction = isTransaction(cTransaction)
	scope.cancelTrigger = cCancelTrigger == true and true or false
	cType = scope.validType
	if scope.validEntity and scope.validKey and scope.validType and not scope.validTransaction then
		scope.isEntityTable = type(cEntity) == "table"
		scope.isKeyTable = type(cKey) == "table"
		scope.isValueTable = type(sValue) == "table"
		if scope.isEntityTable then
			for entityID = 1, #cEntity do
				scope.elements[entityID] = isEntityData(cEntity) and cEntity[entityID] or nil
				if not scope.cancelTrigger then
						scope.cancelTrigger = isElementLocal(cEntity[entityID])
				end
			end
		else
			scope.elements[1] = isEntityData(cEntity) and cEntity
			if not scope.cancelTrigger then
					scope.cancelTrigger = isElementLocal(cEntity)
			end
		end
		if scope.isValueTable then
			for valueID = 1, #sValue do
				scope.values[valueID] = sValue[valueID]
			end
		else
			scope.values[1] = sValue
		end

		if scope.isKeyTable then
			for keyID = 1, #cKey do
				for entityID = 1, #scope.elements do
					if entityData.type[cType][scope.elements[entityID]] == nil then
						entityData.type[cType][scope.elements[entityID]] = {}
					end
					scope.validFlag = entityData.flag[ cKey[keyID] ] == nil and true or reviesFlagKey(entityData.flag[cKey[keyID]], scope.values[keyID] or scope.values[1])
					if scope.validFlag then
						local value = scope.values[keyID] or scope.values[1]
						if value ~= entityData.type[cType][ scope.elements[entityID] ][ cKey[keyID] ] then
							triggerEvent("onClientEntityDataChange", scope.elements[entityID], cKey[keyID], entityData.type[cType][ scope.elements[entityID] ][ cKey[keyID] ], value, cType)
						end
						entityData.type[cType][ scope.elements[entityID] ][ cKey[keyID] ] = value
					else
						return false
					end
				end
			end
		else
			for entityID = 1, #scope.elements do
				if entityData.type[cType][scope.elements[entityID]] == nil then
					entityData.type[cType][scope.elements[entityID]] = {}
				end
				scope.validFlag = entityData.flag[ cKey ] == nil and true or reviesFlagKey(entityData.flag[cKey], scope.values[1])
				if scope.validFlag then
					if scope.values[1] ~= entityData.type[cType][ scope.elements[entityID] ][ cKey ] then
						triggerEvent("onClientEntityDataChange", scope.elements[entityID], cKey, entityData.type[cType][ scope.elements[entityID] ][ cKey ], scope.values[1], cType)
					end
					entityData.type[cType][ scope.elements[entityID] ][ cKey ] = scope.values[1]
				else
					return false
				end
			end
		end
		if cType ~= "local" and not scope.cancelTrigger then
				triggerServerEvent("onServerSyncEntityData", root, false, cEntity, cKey, sValue, cType, nil)
		end
		return true
	elseif scope.validEntity and scope.validKey and scope.validType and scope.validTransaction then
		table.insert(entityData.transaction[cTransaction], {cEntity, cKey, sValue, cType, cTransaction} )
		return true
	end
	return false
end

function onClientSyncEntityData(cEntity, cKey, sValue, cType)
		setEntityData(cEntity, cKey, sValue, cType, nil, false)
end
addEventHandler("onClientSyncEntityData", root, onClientSyncEntityData)

function onClientSyncEntitsData(sPublic, sPrivate, cFlag)
		entityData.type.public = sPublic or {}
		entityData.type.private = sPrivate or {}
		entityData.flag = cFlag or {}

		local download = getElementData(root, "EntityData")
		if type(download) == "table" then
				entityData.type.public = download.public or {}
				entityData.type.private = download.private or {}
				entityData.type['local'] = download['local'] or {}
				setElementData(root, "EntityData", nil)
		end
end
addEvent("onClientSyncEntitsData", true)
addEventHandler("onClientSyncEntitsData", root, onClientSyncEntitsData)

function onClientforceRemoveEntityData()
	entityData.type['local'][source] = nil
	entityData.type['public'][source] = nil
	entityData.type['private'][source] = nil
end
addEventHandler("onClientPlayerQuit", root, onClientforceRemoveEntityData, true, "low")
addEventHandler("onClientElementDestroy", root, onClientforceRemoveEntityData, true, "low")

function storageEntityData()
		setElementData(root, "EntityData", entityData.type, false)
end
addEventHandler( "onClientResourceStop", resourceRoot, storageEntityData)