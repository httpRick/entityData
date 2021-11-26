addEvent("onServerEntityDataChange", true)
addEvent("onServerTransactionChange", true)
addEvent("onServerSyncEntityData", true)
addEvent("onServerSyncKeyFlag", true)

entityData = {}
entityData.resource = getThisResource()
entityData.defaultSetting = get("entityDataSync")
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

function setKeyFlag(sKey, sFlag)
	local scope = {}
	scope.validKey = type(sKey) == "table" or type(sKey) == "string"
	scope.validFlag = type(sFlag) == "table" or sFlag == nil
	if scope.validKey and scope.validFlag then
		scope.isKeyTable = type(sKey) == "table"
		if scope.isKeyTable then
			for keyID = 1, #sKey do
				entityData.flag[sKey[keyID]] = sFlag == nil and nil or sFlag
			end
		else
			entityData.flag[sKey] = sFlag == nil and nil or sFlag
		end
		if eventName == nil then
				triggerClientEvent("onClientSyncKeyFlag", root, sKey, sFlag)
		end
		return true
	else
		return false
	end
end
addEventHandler("onServerSyncKeyFlag", root, setKeyFlag)

function onServerEntityDataChange(theKey, oldValue, newValue, dataType)
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
addEventHandler("onServerEntityDataChange", root, onServerEntityDataChange)

function createTransaction()
	local index = getTableFreeIndex(entityData.transaction)
	entityData.transaction[index] = {}
	return index
end

function cancelTransaction(sTransaction)
	if isTransaction(sTransaction) then
		entityData.transaction[sTransaction] = nil
		return true
	else
		return false
	end
end

function executeTransaction(sTransaction, executeData)
	if type(sTransaction) == "table" or entityData.coroutine[sTransaction] then
		local i = 0
		for _,v in pairs(executeData) do
			if setEntityData(v[1], v[2], v[3], v[4], false) then i = i+1 end
			if i%5 == 0 then
				setTimer(function(sTransaction, executeData) coroutine.resume(entityData.coroutine[sTransaction], sTransaction, executeData) end, 150, 1, sTransaction, executeData)
				coroutine.yield()
			end
		end
		entityData.coroutine[sTransaction] = nil
		triggerEvent("onServerTransactionChange", root, sTransaction)
	end
end

function triggerTransaction(sTransaction)
	if isTransaction(sTransaction) then
		entityData.coroutine[sTransaction] = coroutine.create(executeTransaction)
		coroutine.resume(entityData.coroutine[sTransaction], sTransaction, entityData.transaction[sTransaction])
		entityData.transaction[sTransaction] = nil
	elseif type(sTransaction) == "table" then
		local index = getTableFreeIndex(entityData.coroutine)
		entityData.coroutine[index] = coroutine.create(executeTransaction)
		coroutine.resume(entityData.coroutine[index], index, sTransaction )
	end
end


function getElementsByEntityDataKey(sKey, sType)
	local scope = {elements = {}}
	scope.validKey = type(sKey) == "string"
	scope.validType = type(entityData.type[sType]) == "table" and sType or sType == "all" and sType or sType
	if scope.validKey and scope.validType then
		if sType == "all" then
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
			for element in pairs(entityData.type[sType]) do
				if scope.elements[element] == nil then
					scope.elements[element] = true
				end
			end
			return scope.elements
		end
	end
	return false
end

function getAllEntityData(sEntity, sType)
	local scope = { elements = {}, values = {}, result = {}}
	scope.validEntity = isEntityData(sEntity)
	scope.validType = type(entityData.type[sType]) == "table" and sType or "public"
	sType = scope.validType
	if scope.validEntity and scope.validType then
		scope.isEntityTable = type(sEntity) == "table"
		if scope.isEntityTable then
			for entityID = 1, #sEntity do
				scope.elements[entityID] = isEntityData(sEntity) and sEntity[entityID] or nil
			end
		else
			scope.elements[1] = isEntityData(sEntity) and sEntity
		end
		for entityID = 1, #scope.elements do
			scope.result[entityID] = entityData.type[sType][scope.elements[entityID]]
		end
		local result = scope.isEntityTable and scope.result or scope.result[1]
		return result
	end
end

function hasEntityData(sEntity, sKey, sType)
	local scope = { elements = {}, values = {}, result = {}}
	scope.validEntity = isEntityData(sEntity)
	scope.validKey = type(sKey) == "table" or type(sKey) == "string"
	scope.validType = type(entityData.type[sType]) == "table" and sType or "public"
	sType = scope.validType
	if scope.validEntity and scope.validKey and scope.validType then
		scope.isEntityTable = type(sEntity) == "table"
		scope.isKeyTable = type(sKey) == "table"
		if scope.isEntityTable then
			for entityID = 1, #sEntity do
				scope.elements[entityID] = isEntityData(sEntity) and sEntity[entityID] or nil
			end
		else
			scope.elements[1] = isEntityData(sEntity) and sEntity
		end
		if scope.isKeyTable then
			for keyID = 1, #sKey do
				for entityID = 1, #scope.elements do
					if entityData.type[sType][scope.elements[entityID]] ~= nil then
						scope.result[keyID] = entityData.type[sType][scope.elements[entityID]][ sKey[keyID] ] ~= nil
					else
						scope.result[keyID] = false
					end
				end
			end
		else
			for entityID = 1, #scope.elements do
				if entityData.type[sType][scope.elements[entityID]] ~= nil then
					scope.result[1] = entityData.type[sType][scope.elements[entityID]][sKey] ~= nil
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

function getEntityData(sEntity, sKey, sType)
	local scope = { elements = {}, values = {}, result = {}}
	scope.validEntity = isEntityData(sEntity)
	scope.validKey = type(sKey) == "table" or type(sKey) == "string"
	scope.validType = type(entityData.type[sType]) == "table" and sType or "public"
	sType = scope.validType
	if scope.validEntity and scope.validKey and scope.validType then
		scope.isEntityTable = type(sEntity) == "table"
		scope.isKeyTable = type(sKey) == "table"
		if scope.isEntityTable then
			for entityID = 1, #sEntity do
				scope.elements[entityID] = isEntityData(sEntity) and sEntity[entityID] or nil
			end
		else
			scope.elements[1] = isEntityData(sEntity) and sEntity
		end
		if scope.isKeyTable then
			for keyID = 1, #sKey do
				for entityID = 1, #scope.elements do
					if entityData.type[sType][scope.elements[entityID]] ~= nil and entityData.type[sType][scope.elements[entityID]][sKey[keyID]] ~= nil then
							scope.result[keyID] = entityData.type[sType][scope.elements[entityID]][ sKey[keyID] ]
					elseif sType ~= "private" then
						if entityData.type["public"][scope.elements[entityID]] ~= nil and entityData.type["public"][scope.elements[entityID]][sKey[keyID]] ~= nil then
								scope.result[keyID] = entityData.type["public"][scope.elements[entityID]][sKey[keyID]]
						elseif entityData.type["local"][scope.elements[entityID]] ~= nil and entityData.type["local"][scope.elements[entityID]][sKey[keyID]] ~= nil then
								scope.result[keyID] = entityData.type["local"][scope.elements[entityID]][sKey[keyID]]
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
				if entityData.type[sType][scope.elements[entityID]] ~= nil and entityData.type[sType][scope.elements[entityID]][sKey] ~= nil then
						scope.result[1] = entityData.type[sType][scope.elements[entityID]][sKey]
				elseif sType ~= "private" then
						if entityData.type["public"][scope.elements[entityID]] ~= nil and entityData.type["public"][scope.elements[entityID]][sKey] ~= nil then
								scope.result[1] = entityData.type["public"][scope.elements[entityID]][sKey]
						elseif entityData.type["local"][scope.elements[entityID]] ~= nil and entityData.type["local"][scope.elements[entityID]][sKey] ~= nil then
								scope.result[1] = entityData.type["local"][scope.elements[entityID]][sKey]
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

function setEntityData(sEntity, sKey, sValue, sType, sTransaction, sCancelTrigger)
	local scope = { elements = {}, values = {} }
	scope.validEntity = isEntityData(sEntity)
	scope.validKey = type(sKey) == "table" or type(sKey) == "string"
	scope.validType = type(entityData.type[sType]) == "table" and sType or "public"
	scope.validTransaction = isTransaction(sTransaction)
	sType = scope.validType
	if scope.validEntity and scope.validKey and scope.validType and not scope.validTransaction then
		scope.isEntityTable = type(sEntity) == "table"
		scope.isKeyTable = type(sKey) == "table"
		scope.isValueTable = type(sValue) == "table"
		if scope.isEntityTable then
			for entityID = 1, #sEntity do
				scope.elements[entityID] = isEntityData(sEntity) and sEntity[entityID] or nil
			end
		else
			scope.elements[1] = isEntityData(sEntity) and sEntity
		end

		if scope.isValueTable then
			for valueID = 1, #sValue do
				scope.values[valueID] = sValue[valueID]
			end
		else
			scope.values[1] = sValue
		end

		if scope.isKeyTable then
			for keyID = 1, #sKey do
				for entityID = 1, #scope.elements do
					if entityData.type[sType][scope.elements[entityID]] == nil then
						entityData.type[sType][scope.elements[entityID]] = {}
					end
					scope.validFlag = entityData.flag[ sKey[keyID] ] == nil and true or reviesFlagKey(entityData.flag[sKey[keyID]], scope.values[keyID] or scope.values[1])
					if scope.validFlag then
						local value = scope.values[keyID] or scope.values[1]
						if value ~= entityData.type[sType][ scope.elements[entityID] ][ sKey[keyID] ] then
							triggerEvent("onServerEntityDataChange", scope.elements[entityID], sKey[keyID], entityData.type[sType][ scope.elements[entityID] ][ sKey[keyID] ], value, sType)
						end
						entityData.type[sType][ scope.elements[entityID] ][ sKey[keyID] ] = value
					else
						return false
					end
				end
			end
		else
			for entityID = 1, #scope.elements do
				if entityData.type[sType][scope.elements[entityID]] == nil then
					entityData.type[sType][scope.elements[entityID]] = {}
				end
				scope.validFlag = entityData.flag[ sKey ] == nil and true or reviesFlagKey(entityData.flag[sKey], scope.values[1])
				if scope.validFlag then
					if scope.values[1] ~= entityData.type[sType][ scope.elements[entityID] ][ sKey ] then
							triggerEvent("onClientSyncEntityData", scope.elements[entityID], sKey, entityData.type[sType][ scope.elements[entityID] ][ sKey ], scope.values[1], sType)
					end
					entityData.type[sType][ scope.elements[entityID] ][ sKey ] = scope.values[1]
				else
					return false
				end
			end
		end
		if sType ~= "local" and not sCancelTrigger then
				local request = isElement( source ) and source or root
				triggerClientEvent("onClientSyncEntityData", request, sEntity, sKey, sValue, sType, nil, false)
		end
		return true
	elseif scope.validEntity and scope.validKey and scope.validType and scope.validTransaction then
		table.insert(entityData.transaction[sTransaction], {sEntity, sKey, sValue, sType, sTransaction} )
		return true
	end
	return false
end


function onPlayerResourceStart(loadedResource)
	if getResourceRootElement(loadedResource) == resourceRoot then
			triggerClientEvent(source, "onClientSyncEntitsData", source, entityData.type["public"], entityData.type["private"], entityData.flag)
	end
end
addEventHandler("onPlayerResourceStart", root, onPlayerResourceStart)

function onServerSyncEntityData(sEntity, sKey, sValue, sType)
	if stringToBoolean(get("entityDataSync")) == true then
		  setEntityData(sEntity, sKey, sValue, sType, nil, false)
	end
end
addEventHandler("onServerSyncEntityData", root, onServerSyncEntityData)

function forceRemoveEntityData()
	entityData.type['local'][source] = nil
	entityData.type['public'][source] = nil
	entityData.type['private'][source] = nil
end
addEventHandler("onPlayerQuit", root, forceRemoveEntityData, true, "low")
addEventHandler("onElementDestroy", root, forceRemoveEntityData, true, "low")

function makeSettingsChangesVisible(setting, oldValue, newValue)
	if setting == string.format("*%s.%s", getResourceName( entityData.resource ), "entityDataSync") then
		if stringToBoolean( fromJSON(newValue) ) == nil then
			set("entityDataSync", entityData.defaultSetting)
		else
			set("entityDataSync", fromJSON(newValue):lower() )
		end
	end
end
addEventHandler("onSettingChange", root, makeSettingsChangesVisible)



function storageEntityData()
		if eventName == "onResourceStop" then
				setElementData(root, "EntityData", {entityData.type, entityData.flag}, false)
		elseif eventName == "onResourceStart" then
				local download = getElementData(root, "EntityData")
				if type(download) == "table" then
						entityData.flag = download[2] or {}
						entityData.type.public = download[1].public or {}
						entityData.type.private = download[1].private or {}
						entityData.type['local'] = download[1]['local'] or {}
						removeElementData(root, "EntityData", nil)
				end
		end
end
addEventHandler( "onResourceStart", resourceRoot, storageEntityData)
addEventHandler( "onResourceStop", resourceRoot, storageEntityData)
