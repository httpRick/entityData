function importFunctions()
	if not sourceResource or sourceResource == getThisResource(  ) then return "return false" end
	local name = getResourceName( getThisResource(  ) )
	if name then
		local allCode = string.format([[
			function setKeyFlag(...)
				return call( getResourceFromName('%s'), "setKeyFlag", ...)
			end

			function hasEntityData(...)
				return call( getResourceFromName('%s'), "hasEntityData", ...)
			end

			function getEntityData(...)
				return call( getResourceFromName('%s'), "getEntityData", ...)
			end

			function getAllEnintyData(...)
				return call( getResourceFromName('%s'), "getAllEnintyData", ...)
			end

			function setEntityData(...)
				return call( getResourceFromName('%s'), "setEntityData", ...)
			end

			function createTransaction(...)
				return call( getResourceFromName('%s'), "createTransaction", ...)
			end

			function cancelTransaction(...)
				return call( getResourceFromName('%s'), "cancelTransaction", ...)
			end		

			function triggerTransaction(...)
				return call( getResourceFromName('%s'), "triggerTransaction", ...)
			end

			function getElementsByEntityDataKey(...)
				return call( getResourceFromName('%s'), "getElementsByEntityDataKey", ...)
			end
		]], name, name, name, name, name, name, name, name, name)
		return allCode
	end
end