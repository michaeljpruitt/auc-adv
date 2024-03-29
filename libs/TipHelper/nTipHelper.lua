--[[
	Norganna's Tooltip Helper class
	Version: 1,3
	Revision: $Id: nTipHelper.lua 315 2011-07-18 11:53:36Z brykrys $
	URL: http://norganna.org/tthelp

	This is a slide-in helper class for the Norganna's AddOns family of AddOns
	It is designed to work with the LibExtraTip tooltip library and provide additional
	information that is useful for the Auctioneer et al AddOns.

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

	Note:
		This source code is specifically designed to work with World of Warcraft's
		interpreted AddOn system.
		You have an implicit licence to use this code with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat

		If you copy this code, please rename it to your own tastes, as this file is
		liable to change without notice and could possibly destroy any code that relies
		on it staying the same.
		We will attempt to avoid this happening where possible (of course).

	Requires:
		LibExtraTip must be loaded first. If the libraries are embedded it is up to the
		packager to ensure they load in the correct order.
]]

if not LibStub then -- LibStub is included in LibExtraTip
	error("TipHelper cannot load because LibExtraTip is not loaded (LibStub missing)")
end
local MAJOR,MINOR,REVISION = "nTipHelper", 1, 3
local LIBSTRING = MAJOR..":"..MINOR
local lib = LibStub:NewLibrary(LIBSTRING,REVISION)
if not lib then return end

local type = type
local gsub = gsub

do -- tooltip class definition
	local libTT = LibStub("LibExtraTip-1", true)
	if not libTT then
		lib.LoadError = "Missing LibExtraTip"
		error("TipHelper cannot load because LibExtraTip is not loaded (LibExtraTip-1 missing)")
	end
	local MoneyViewClass = LibStub("LibMoneyFrame-1")
	local libACL = LibStub("LibAltChatLink")

	local curFrame = nil
	local asText = false
	local defaultR = 0.7
	local defaultG = 0.7
	local defaultB = 0.7
	local defaultEmbed = false
	local itemData

	local activated = false
	local inLayout = false

	local GOLD="ffd100"
	local SILVER="e6e6e6"
	local COPPER="c8602c"

	local GSC_3 = "|cff%s%d|cff000000.|cff%s%02d|cff000000.|cff%s%02d|r"
	local GSC_2 = "|cff%s%d|cff000000.|cff%s%02d|r"
	local GSC_1 = "|cff%s%d|r"

	local iconpath = "Interface\\MoneyFrame\\UI-"
	local goldicon = "%d|T"..iconpath.."GoldIcon:0|t"
	local silvericon = "%s|T"..iconpath.."SilverIcon:0|t"
	local coppericon = "%s|T"..iconpath.."CopperIcon:0|t"


	local function coins(money, graphic)
		money = math.floor(tonumber(money) or 0)
		local g = math.floor(money / 10000)
		local s = math.floor(money % 10000 / 100)
		local c = money % 100

		if not graphic then
			if g > 0 then
				return GSC_3:format(GOLD, g, SILVER, s, COPPER, c)
			elseif s > 0 then
				return GSC_2:format(SILVER, s, COPPER, c)
			else
				return GSC_1:format(COPPER, c)
			end
		else
			if g > 0 then
				return goldicon:format(g)..silvericon:format("%02d"):format(s)..coppericon:format("%02d"):format(c)
			elseif s > 0  then
				return silvericon:format("%d"):format(s)..coppericon:format("%02d"):format(c)
			else
				return coppericon:format("%d"):format(c)
			end
		end
	end

	local function breakHyperlink(match, matchlen, ...)
		local v
		local n = select("#", ...)
		for i = 2, n do
			v = select(i, ...)
			if (v:sub(1,matchlen) == match) then
				return strsplit(":", v:sub(2))
			end
		end
	end

	function lib:BreakHyperlink(...)
		return breakHyperlink(...)
	end

	function lib:GetFactor(suffix, seed)
		if (suffix < 0 and seed) then
			return bit.band(seed, 65535)
		end
		return 0
	end

	local lastSaneLink, lastSanitized
	function lib:SanitizeLink(link)
		if not link then
			return
		end
		if lastSanitized == link or lastSaneLink == link then
			return lastSaneLink
		end
		if type(link) == "number" then
			local _, tlink = GetItemInfo(link)
			link = tlink
		end
		if type(link) ~= "string" then
			return
		end
		local newlink, test = gsub(link, "(|Hitem:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+):%d+([|:][^h]*h)", "%1:80%2")
		lastSaneLink = newlink
		lastSanitized = link
		return lastSaneLink
	end

	function lib:DecodeLink(link, info)
		local lType,id,enchant,gem1,gem2,gem3,gemBonus,suffix,seed,factor,ulevel,reforge
		local vartype = type(link)
		if (vartype == "string") then
			lType,id,enchant,gem1,gem2,gem3,gemBonus,suffix,seed,ulevel,reforge = strsplit(":", link)
			lType = lType:sub(-4)
			if (lType ~= "item") then return end
			id = tonumber(id) or 0
			enchant = tonumber(enchant) or 0
			suffix = tonumber(suffix) or 0
			seed = tonumber(seed) or 0
			factor = lib:GetFactor(suffix, seed)
			gem1 = tonumber(gem1) or 0
			gem2 = tonumber(gem2) or 0
			gem3 = tonumber(gem3) or 0
			gemBonus = tonumber(gemBonus) or 0
			if reforge then
				reforge = tonumber((strsplit("|", reforge))) or 0
			else
				reforge = 0
			end
		elseif (vartype == "number") then
			lType,id, suffix,factor,enchant,seed, gem1,gem2,gem3,gemBonus,reforge =
				"item",link, 0,0,0,0, 0,0,0,0, 0
		end
		if info and type(info) == "table" then
			info.itemLink      = link
			info.itemType      = lType
			info.itemId        = id
			info.itemSuffix    = suffix
			info.itemFactor    = factor
			info.itemEnchant   = enchant
			info.itemSeed      = seed
			info.itemGem1      = gem1
			info.itemGem2      = gem2
			info.itemGem3      = gem3
			info.itemGemBonus  = gemBonus
			info.itemReforge   = reforge
		end
		return lType,id,suffix,factor,enchant,seed,gem1,gem2,gem3,gemBonus,reforge
	end

	function lib:GetLinkQuality(link)
		if not link or type(link) ~= "string" then return end
		local color = link:match("(|c%x+)|Hitem:")
		if color then
			local _, hex
			for i = 0, 6 do
				_,_,_, hex = GetItemQualityColor(i)
				if color == hex then return i end
			end
		end
		return -1
	end

	-- Call the given frame's SetHyperlink call
	function lib:ShowItemLink(frame, link, count, additional)
		libTT:SetHyperlinkAndCount(frame, link, count, additional)
	end

	-- Activation function. All client addons should call this when they get ADDON_LOADED
	function lib:Activate()
		if activated then return end
		libTT:RegisterTooltip(GameTooltip)
		libTT:RegisterTooltip(ItemRefTooltip)
		activated = true
	end

	-- Allow client addon to add their callback
	function lib:AddCallback(callback, priority)
		self:Activate() -- We should be activated by now, but make sure.
		libTT:AddCallback(callback, priority)
	end

	-- Accessor functions for the current frame that the tooltip is affecting
	function lib:SetFrame(frame)
		assert(libTT:IsRegistered(frame), "Error, frame is not registered with LibExtraTip in nTipHelper:SetFrame()")

		curFrame = frame
		inLayout = true
	end
	function lib:GetFrame()
		return curFrame
	end
	-- Try to Clear the frame after you've finished using it, this will stop stray reuse
	-- of the tooltip other than at the proper layout time.
	function lib:ClearFrame(tip)
		assert(tip == curFrame, "Error, frame is not the current frame in nTipHelper:ClearFrame()")
		curFrame = nil
		inLayout = false
	end

	-- Accessor functions for the data the tooltip contains
	function lib:SetData(data)
		itemData = data
	end
	function lib:GetData()
		return itemData
	end

	-- Sets the color that the tooltip will use from now on.
	-- (resets to default color between calls to modules)
	function lib:SetColor(r, g, b)
		defaultR = r
		defaultG = g
		defaultB = b
	end

	-- Sets the embed mode that the tooltip will use from now on.
	-- (resets to default mode between calls to modules)
	function lib:SetEmbed(embed)
		defaultEmbed = embed
	end

	-- Sets the money mode that the tooltip will use from now on.
	-- (resets to default mode between calls to modules)
	function lib:SetMoneyAsText(text)
		asText = text
	end

	-- Gets money as colorized text
	function lib:Coins(amount, graphic)
		return coins(amount, graphic)
	end

	--[[
	  Adds a line of text to the tooltip.

	  Supported calling formats:
	  lib:AddLine(text, [rightText | amount], [red, green, blue], [embed])
	]]
	function lib:AddLine(...)
		assert(inLayout, "Error, no tooltip to add line to in nTipHelper:AddLine()")

		local left, right, amount, red,green,blue, embed
		local numArgs = select("#", ...)
		local left = ...
		left = tostring(left)

		if numArgs > 1 then
			-- Check if the last arg is a boolean
			local lastArg = select(numArgs, ...)
			if type(lastArg) == "boolean" then
				-- Strip it off
				embed = lastArg
				numArgs = numArgs - 1
			end
		end

		if numArgs > 3 then
			-- Possible that the last 3 numbers are colors
			local r,g,b = select(numArgs-2, ...)

			if type(r)=="number" and type(g)=="number" and type(b)=="number" then
				if r>=0 and r<=1 and g>=0 and g<=1 and b>=0 and b<=1 then
					-- Assumption is that these are colors
					red,green,blue = r,g,b
					numArgs = numArgs - 3
				end
			end
		end

		if numArgs > 1 then
			-- There's a second parameter, if it's a number, it's a money amount
			-- otherwise it's the right-aligned text.
			local secondArg = select(2, ...)
			if type(secondArg) == "number" then
				if asText then
					right = coins(secondArg)
				else
					amount = secondArg
				end
			elseif right ~= nil then
				right = tostring(secondArg)
			end
		end

		red = tonumber(red)
		green = tonumber(green)
		blue = tonumber(blue)

		if red == nil or green == nil or blue == nil then
			-- Not all colors supplied
			red,green,blue = defaultR,defaultG,defaultB
		end
		if embed == nil then
			embed = defaultEmbed
		end
		left = left:gsub("{{", "|cffddeeff"):gsub("}}", "|r")
		if amount then
			libTT:AddMoneyLine(curFrame, left, amount, red, green, blue, embed)
		elseif right then
			libTT:AddDoubleLine(curFrame, left, right, red, green, blue, embed)
		else
			libTT:AddLine(curFrame, left, red, green, blue, embed)
		end
	end

	-- Return the extra information from this tooltip
	function lib:GetExtra()
		assert(inLayout, "Error, no tooltip to get extra info in nTipHelper:Extra()")
		return libTT:GetTooltipAdditional(curFrame)
	end

	function lib:CreateMoney(high, wide, red,green,blue)
		local m = MoneyViewClass:new(high, wide, red,green,blue);
		return m
	end

	function lib:AltChatLinkRegister(callback)
		-- 'callback' is a function which should take the same parameters as SetItemRef
		-- and should return one of the LibAltChatLink constants (may return nil instead of NO_ACTION)
		libACL:AddCallback(callback)
	end

	function lib:AltChatLinkConstants()
		return libACL.OPEN_TOOLTIP, libACL.NO_ACTION, libACL.BLOCK_TOOLTIP
	end

end -- tooltip class definition

LibStub("LibRevision"):Set("$URL: http://svn.norganna.org/libs/trunk/TipHelper/nTipHelper.lua $","$Rev: 315 $","5.12.DEV.", 'auctioneer', 'libs')
