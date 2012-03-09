--[[
	Constructor Library for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/dl
	Copyright: (C) 2007 Esteban Santana Santana (MentalPower)

	This library accepts a frame's definition (a table) and converts it
	into actual WoW frames, complete with scripts. It does not name the frames
	so as not to pollute the global name-space. Constructor is inspired by and
	semi-compatible with Mikk's Etch-A-Sketch library.

	Usage:
		Stub > Constructor = LibStub:GetLibrary("Constructor")
		Call   >   mainFrame = Constructor(frameDefinition)

	License:
		This library is free software; you can redistribute it and/or
		modify it under the terms of the GNU Lesser General Public
		License as published by the Free Software Foundation; either
		version 2.1 of the License, or (at your option) any later version.

		This library is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
		Lesser General Public License for more details.

		You should have received a copy of the GNU Lesser General Public
		License along with this library (see LGPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit license to use this AddOn with these facilities
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

--LibStub stuff
local LIBRARY_VERSION_MAJOR = "Constructor"
local LIBRARY_VERSION_MINOR = 1

--Functions needed from the global environment
local _G = _G
local type = type
local pairs = pairs
local select = select
local loadstring = loadstring
local CreateFrame = CreateFrame
local CreateTexture = CreateTexture
local CreateFontString = CreateFontString

--Call LibStub and see if we need to create or update the lib's table
assert(LibStub and LibStub.NewLibrary, "Constructor requires LibStub")
local Constructor = LibStub:NewLibrary(LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR)
if (not Constructor) then return end --We don't need to create or update our lib

--Our main table. Redirect any lookups to this table first, then to the global namespace.
setmetatable(Constructor, { __index = _G })
setfenv(1, Constructor)

--Make any calls to the Constructor table default to generating frames.
getmetatable(Constructor).__call = function (self, ...) return GenerateFrames(...) end

--A local counter to use in identifying unnamed objects
local nextObjectNumber = 1

--A local table containing the compiled versions of function definitions.
local compiledFunctions = {}

--Global environment assigned to the compiled functions
local environment = {Constructor = Constructor}
setmetatable(environment, { __index = _G })

--These functions are used in some of the extended widget methods defined below
function TextureCreationHelper(self, texture, arg1, arg2, arg3, arg4)
	texture = texture or self:CreateTexture()
	texture:SetTexture(arg1, arg2, arg3, arg4)
	texture:SetAllPoints(self)
	return texture
end

--These are the definitions for a set of extra widget methods that are helpful in the creation of frames.
HelperWidgetMethods = {
	Region = {
		SetSize = function(self, widthSize, heightSize)
			self:SetWidth(widthSize);
			self:SetHeight(heightSize);
		end
	},

	Slider = {
		SetThumbTextureEx = function(self, arg1, arg2, arg3, arg4, arg5, arg6)
			local texture = self:CreateTexture()

			if (type(arg1)=="string") then --texture:SetTexture(texturePath)
				texture:SetTexture(arg1)
				texture:SetWidth(arg2 or 16)
				texture:SetHeight(arg3 or 16)

			else --texture:SetTexture(redComponent, greenComponent, blueComponent, alphaComponent)
				texture:SetTexture(arg1, arg2, arg3, arg4)
				texture:SetWidth(arg5 or 16)
				texture:SetHeight(arg6 or 16)
			end

			return self:SetThumbTexture(texture)
		end
	},

	Button = {
		SetHighlightTextureEx = function(self, arg1, arg2, arg3, arg4)
			self:SetHighlightTexture(TextureCreationHelper(self, self:GetHighlightTexture(), arg1, arg2, arg3, arg4))
		end,

		SetDisabledTextureEx = function(self, arg1, arg2, arg3, arg4)
			self:SetDisabledTexture(TextureCreationHelper(self, self:GetDisabledTexture(), arg1, arg2, arg3, arg4))
		end,

		SetNormalTextureEx = function(self, arg1, arg2, arg3, arg4)
			self:SetNormalTexture(TextureCreationHelper(self, self:GetNormalTexture(), arg1, arg2, arg3, arg4))
		end,

		SetPushedTextureEx = function(self, arg1, arg2, arg3, arg4)
			self:SetPushedTexture(TextureCreationHelper(self, self:GetPushedTexture(), arg1, arg2, arg3, arg4))
		end
	},

	StatusBar = {
		SetStatusBarTextureEx = function(self, arg1, arg2, arg3, arg4)
			self:SetStatusBarTexture(
				TextureCreationHelper(self, self:GetStatusBarTexture(), arg1, arg2, arg3, arg4)
			)
		end
	},

	Texture = {
		RotateTexture = function(self, degrees)
			local angle = math.rad(degrees)
			local cos, sin = math.cos(angle), math.sin(angle)
			self:SetTexCoord((sin - cos), -(cos + sin), -cos, -sin, sin, -cos, 0, 0)
		end
	}
}

function GenerateFrames(framesDefinition, parentTableOrFrame)
	local validDefinition, reason = ValidateFramesDefinition(framesDefinition)
	if (not validDefinition) then
		return error("Invalid Frame Definition Encountered: "..reason)
	end

	for index = 1, #framesDefinition, 2 do
		local frameName = framesDefinition[index] --Is this of any use?
		local frameDefinition = framesDefinition[index + 1]

		InstantiateSingleObject(frameDefinition, parentTableOrFrame or frameDefinition.parent)
	end
end

function InstantiateSingleObject(singleObjectDefinition, parentObjectReference, previousObject, objectCount)
	local objectType = singleObjectDefinition.type
	local objectName = singleObjectDefinition.name
	local objectParent = parentObjectReference
	local objectMethods = singleObjectDefinition.methods
	local objectScripts = singleObjectDefinition.scripts
	local objectChildren = singleObjectDefinition.children
	local objectInherits = singleObjectDefinition.inherits

	if (objectCount and singleObjectDefinition.count and (objectCount > singleObjectDefinition.count)) then
		return
	end

	--Normalize the name
	local fakeName
	if (objectName) then
		if (objectName == "$count") then
			objectName = objectCount or 1
		end
		fakeName = false
	else
		objectName = "(unamed"..objectType.."-"..nextObjectNumber..")"
		nextObjectNumber = nextObjectNumber + 1
		fakeName = true
	end

	--Normalize the parent if its defined
	if (_G[objectParent]) then
		objectParent = _G[objectParent]
	end

	--Create the object using the appropriate function
	local currentObject
	if (objectType == "Texture") then
		currentObject = objectParent:CreateTexture(nil, nil, objectInherits)
	elseif (objectType == "FontString") then
		currentObject = objectParent:CreateFontString(nil, nil, objectInherits)
	else
		if (objectParent and objectParent[0]) then
			currentObject = CreateFrame(objectType, nil, objectParent, objectInherits)
		else
			currentObject = CreateFrame(objectType, nil, nil, objectInherits)
		end
	end

	--Set this frame as a member of its parent's table if the parent was supplied
	if (type(objectParent) == "table") then
		objectParent[objectName] = currentObject
	end

	--If this object has methods defined, run them
	if (objectMethods) then
		for index, methodCallDefinition in ipairs(objectMethods) do
			local methodCallFunction = methodCallDefinition.f

			if (currentObject[methodCallFunction]) then
				currentObject[methodCallFunction](currentObject, SubstituteArguments(methodCallDefinition, objectParent, previousObject, currentObject, objectCount))

			elseif (HelperWidgetMethods[objectType] and HelperWidgetMethods[objectType][methodCallFunction]) then
				HelperWidgetMethods[objectType][methodCallFunction](currentObject, SubstituteArguments(methodCallDefinition, objectParent, previousObject, currentObject, objectCount))

			elseif (HelperWidgetMethods.Region[methodCallFunction]) then
				HelperWidgetMethods.Region[methodCallFunction](currentObject, SubstituteArguments(methodCallDefinition, objectParent, previousObject, currentObject, objectCount))
			end
		end
	end

	--If this object is part of a set of objects, instantiate them too by recursively calling ourselves.
	if (singleObjectDefinition.count) then
		InstantiateSingleObject(singleObjectDefinition, objectParent, currentObject, (objectCount or 1) + 1)
	end

	--If this object has children defined, instantiate them too by recursively calling ourselves.
	if (objectChildren) then
		for index, childObjectDefinition in ipairs(objectChildren) do
			previousObject = InstantiateSingleObject(childObjectDefinition, currentObject, previousObject or currentObject)
		end
	end

	--Set the scripts defined for this object
	if (objectScripts) then
		for scriptName, scriptContents in pairs(objectScripts) do
			if (type(scriptContents) == "string") then
				if (not compiledFunctions[scriptContents]) then
					local functionName

					if (fakeName) then
						functionName = objectName.." <"..scriptName..">"

					else
						functionName = objectType.." "..objectName.." <"..scriptName..">"
					end

					--Compile the function, and error out if it fails to compile
					local tempScriptContents, compileError = loadstring(scriptContents, functionName)
					if (compileError) then
						error("Constructor: FrameScript Compilation Failed\n"..compileError.."\n"..scriptName.."\n"..scriptContents)
					end

					--Assign the envionment to the newly created function, that will inject the Constructor variable
					setfenv(tempScriptContents, environment)

					--Add the compiled function to the compiled functions list, so that we only compile the same function once.
					compiledFunctions[scriptContents] = tempScriptContents
					scriptContents = tempScriptContents

				else
					scriptContents = compiledFunctions[scriptContents]
				end
			end

			--Check the type of the function so that its valid before trying to use it
			if (CheckObjectType(scriptContents, "function", "nil")) then
				currentObject:SetScript(scriptName, scriptContents)

				--If the script is an <OnLoad> script, run it now since otherwise it will never run
				if (scriptName == "OnLoad") then
					scriptContents(currentObject)
				end
			else
				error("Constructor: Attempt to use invalid variable type in Frame:SetScript(), expected function or nil, got '"..type(scriptContents).."'")
			end
		end
	end

	--Return the newly created object
	return currentObject
end

--All this function does is that it feeds SubstituteArgument() the arguments one at a time
local tempTable = {}
function SubstituteArguments(methodCallDefinition, ...)
	for key in pairs(tempTable) do --Flush the temp table first
		tempTable[key] = nil
	end

	for index = 1, #methodCallDefinition do --Do our substitutions
		tempTable[index] = SubstituteArgument(methodCallDefinition[index], ...)
	end

	return unpack(tempTable) --Return the correct params
end

--This function currently has more arguments than it needs, this is so that its semi future-proof
function SubstituteArgument(currentArgument, parentObjectReference, previousObject, currentObject, objectCount)
	if (type(currentArgument) ~= "string") then --Just return the param since its not a substitution kinda thing
		return currentArgument

	else --Its a string, parse it
		if (currentArgument == "&parent") then --Return the parent object
			return parentObjectReference

		elseif (currentArgument == "&prev") then --Return the previous object in the frame definition
			return previousObject

		elseif (currentArgument == "$count") then --Just return the current count
			return objectCount or 1

		elseif (currentArgument:find("$count")) then --Embed the count in the string
			return currentArgument:gsub("%$count", objectCount or 1)

		elseif (currentArgument:find("%.")) then --Lets find that frame!
			currentArgument = currentArgument:gsub("%$count", objectCount or 1)
			if (currentArgument:find("%.")) then
				local subtitutionType, identifiers = currentArgument:match("(%&.-)%.(.+)")

				if (subtitutionType and identifiers) then
					if (subtitutionType == "&parent") then
						return RecurseTable(parentObjectReference, ("."):split(identifiers))

					elseif (subtitutionType == "&prev") then
						return RecurseTable(previousObject, ("."):split(identifiers))
					end
				else
					local rootObjectName, identifiers = currentArgument:match("(.-)%.(.+)")
					local rootObjectReference = _G[rootObjectName]

					if (rootObjectReference) then
						return RecurseTable(rootObjectReference, ("."):split(identifiers))
					else
						return currentArgument
					end
				end
			end

		else --We don't know what to do with it, return it unscathed
			return currentArgument
		end
	end
end

function RecurseTable(rootTable, currentChildDefinition, ...)
	if (...) then
		return RecurseTable(rootTable[currentChildDefinition], ...)
	else
		return rootTable[currentChildDefinition]
	end
end

--This is a non-exaustive frame definition validation.
--It is meant as a way to catch obvious syntax errors, nothing more.
function ValidateFramesDefinition(framesDefinition)
	for index = 1, #framesDefinition, 2 do
		local frameName = framesDefinition[index]
		local frameDefinition = framesDefinition[index + 1]

		if (not (type(frameName) == "string")) then
			return false, "Invalid Name"
		else
			return ValidateSingleFrame(frameDefinition)
		end
	end
	return false, "Empty table passed"
end

function ValidateSingleFrame(singleObjectDefinition)
	--Make local references of all the valid definition parameters
	local objectType = singleObjectDefinition.type
	local objectName = singleObjectDefinition.name
	local objectMethods = singleObjectDefinition.methods
	local objectScripts = singleObjectDefinition.scripts
	local objectChildren = singleObjectDefinition.children
	local objectInherits = singleObjectDefinition.inherits

	--Check that all the definition parameters are of the correct type
	if (not (type(objectType) == "string")) then
		return false, "Invalid Object Type"
	elseif (not CheckObjectType(objectName, "string", "nil")) then
		return false, "Invalid Object Name"
	elseif (not CheckObjectType(objectMethods, "table", "nil")) then
		return false, "Invalid Object Methods"
	elseif (not CheckObjectType(objectScripts, "table", "nil")) then
		return false, "Invalid Object Scripts"
	elseif (not CheckObjectType(objectChildren, "table", "nil")) then
		return false, "Invalid Object Children"
	elseif (not CheckObjectType(objectInherits, "string", "nil")) then
		return false, "Invalid Object Inheritance"
	end

	--Validate the methods table
	if (objectMethods) then
		for index, methodDefinition in ipairs(objectMethods) do
			if (not (type(methodDefinition) == "table")) then
				return false, "Invalid Object Method Definition"
			elseif (not (type(methodDefinition.f) == "string")) then
				return false, "Invalid Object Method function entry"
			end
		end
	end

	--Validate the scripts table
	if (objectScripts) then
		for event, handler in ipairs(objectScripts) do
			if (not (type(event) == "string")) then
				return false, "Invalid Object event reference"
			elseif (not (type(handler) == "string")) then
				return false, "Invalid Object event handler reference"
			end
		end
	end

	--Validate the children table
	if (objectChildren) then
		--If the current object has no name it cannot have any children
		if (not objectName) then
			return false, "Unnamed Objects cannot have any children"
		end

		for index, child in ipairs(objectChildren) do
			if (type(child) == "table") then
				if (not ValidateSingleFrame(child)) then
					return false, "Invalid Child reference"
				end
			else
				return false, "Invalid Child definition"
			end
		end
	end

	--Default to declaring the definition valid
	return true
end

function CheckObjectType(object, ...)
	local objectType = type(object)

	for i=1, select("#", ...) do
		if (objectType == select(i, ...)) then
			return true
		end
	end
end
