local valueTypes = {
	["userdata"] = {
		["resource-data"] = true,
		["xml-node"] = true,
		["lua-timer"] = true,
		["vector2"] = true,
		["vector3"] = true,
		["vector4"] = true,
		["matrix"] = true,
		["account"] = true,
		["db-query"] = true,
		["acl"] = true,
		["acl-group"] = true,
		["ban"] = true,
		["text-item"] = true,
		["text-display"] = true,
		["vehicle"] = true,
		["ped"] = true,
		["player"] = true,
		["object"] = true,
		["gui"] = true,
		["element"] = true,
	},
	["number"] = {
		["int"] = true,
		["float"] = true,
	},
	["string"] = true,
	["table"] = true,
}

function round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function between(a, b, c)
	return c >= a and c <= b
end

function reviesFlagKey(flags, value)
	local toggle = false
	local flagsType = flags.type
	local flagsValue = flags.value
	local flagsbetween = flags.between
	local flagsFunc = flags.func
	local flagsLen = flags.len
	local typeFunc = type(flagsFunc)
	if flagsType and valueTypes[flagsType] and flagsType == type(value) then
		if valueTypes[flagsType] ~= true and flagsValue then
			if flagsType == "userdata" then
				if flagsValue and valueTypes[flagsType][flagsValue] and flagsValue == getUserdataType(value) then
					toggle = true
				elseif not flagsValue then
					toggle = true
				end
			elseif flagsType == "string" then
				if flagsLen and tonumber(flagsLen) then
					toggle = flagsLen < value:len()
				end
				if toggle and flagsbetween and type(flagsbetween) == "table" then
					toggle = between(flagsbetween[1], flagsbetween[2], value:len())
				end
			elseif flagsType == "number" then
				if flagsValue == "int" then
					toggle = round(value) == value
				elseif flagsValue == "float" then
					toggle = round(value) ~= value
				else
					toggle = false
				end
				if toggle and flagsbetween and type(flagsbetween) == "table" then
					toggle = between(flagsbetween[1], flagsbetween[2], value)
				end
			end
		elseif not flagsType then
			toggle = true
		end
	end
	if typeFunc == "function" then
		toggle = flagsFunc(value) or false
	elseif typeFunc == "string" then
		toggle = assert( loadstring("return ".. flagsFunc) )(value) or false
	end
	return toggle
end