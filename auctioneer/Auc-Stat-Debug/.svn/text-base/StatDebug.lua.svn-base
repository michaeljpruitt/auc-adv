--[[
	Auctioneer - StatDebug
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
	when the auction is scanned, so that you can easily determine what price
	you will be able to sell an item for at auction or at a vendor whenever you
	mouse-over an item in the game

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
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit license to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]
if not AucAdvanced then return end

local libType, libName = "Stat", "Debug"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()

local data

function lib.CommandHandler(command, ...)
	if (command == "help") then
		print("Help for Auctioneer Advanced - "..libName)
		local line = AucAdvanced.Config.GetCommandLead(libType, libName)
		print(line, "help}} - show this help")
		print(line, "clear}} - clear current price database")
	elseif (command == "clear") then
		lib.ClearData()
	end
end

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		private.ProcessTooltip(...)
	elseif (callbackType == "config") then
		--Called when you should build your Configator tab.
		private.SetupConfigGui(...)
	elseif (callbackType == "load") then
		lib.OnLoad(...)
	end
end

lib.Processors = {}
function lib.Processors.tooltip(callbackType, ...)
	private.ProcessTooltip(...)
end

function lib.Processors.config(callbackType, ...)
	--Called when you should build your Configator tab.
	private.SetupConfigGui(...)
end

function lib.Processors.load(callbackType, ...)
	lib.OnLoad(...)
end




lib.ScanProcessors = {}
function lib.ScanProcessors.create(operation, itemData, oldData)
	-- This function is responsible for processing and storing the stats after each scan
	-- Note: itemData gets reused over and over again, so do not make changes to it, or use
	-- it in places where you rely on it. Make a deep copy of it if you need it after this
	-- function returns.

	-- We're only interested in items with buyouts.
	local buyout = itemData.buyoutPrice
	if not buyout or buyout == 0 then return end
	local count = itemData.stackSize or 1
	if count < 1 then count = 1 end

	-- In this case, we're only interested in the initial create, other
	-- Get the signature of this item and find it's stats.
	local itemType, itemId, property, factor = AucAdvanced.DecodeLink(itemData.link)
	local id = strjoin(":", itemId, property, factor)

	local data = private.GetPriceData()
	if not data[id] then data[id] = {} end

	while (#data[id] >= 10) do table.remove(data[id], 1) end
	table.insert(data[id], buyout/count)
end

function lib.GetPrice(hyperlink)
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end

	local id = strjoin(":", itemId, property, factor)
	local data = private.GetPriceData()
	if not data or not data[id] then return end
	return unpack(data[id])
end

local array = {}
function lib.GetPriceArray(hyperlink)
	local data = private.GetPriceData()
	if not data then return end

	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end

	local id = strjoin(":", itemId, property, factor)
	if not data[id] then return end

	wipe(array)
	array.seen = #data[id]
	array.price = data[id][array.seen]
	array.pricelist = data[id]

	-- Return a temporary array. Data in this array is
	-- only valid until this function is called again.
	return array
end

local function fakePDF()
    return 0;               -- Always return 0 probability - never gets added.
end

-- Send back a fake PDF. We don't want Debug to influence statistic scores
function lib.GetItemPDF(hyperlink)
    return;
end

function lib.OnLoad(addon)

end

function lib.CanSupplyMarket()
	return false
end

AucAdvanced.Settings.SetDefault("stat.debug.tooltip", true)

function private.SetupConfigGui(gui)
	local id = gui:AddTab(lib.libName, lib.libType.." Modules")
	--gui:MakeScrollable(id)

	gui:AddHelp(id, "what debug stats",
		"What are debug stats?",
		"Debug stats are the numbers that are generated by the debug module, these are used "..
		"to assist the developers in determining whether a stats module is working properly.\n\n"..
		""..
		"If you are not a developer, these numbers will not add any information that is "..
		"meaningful, and therefore, this should be unchecked.")

	gui:AddControl(id, "Header",     0,    libName.." options")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.debug.tooltip", "Show debug stats in the tooltips?")
	gui:AddTip(id, "Toggle display of stats from the debug module on or off")

end

function lib.ClearData(serverKey)
	-- Stat-Debug ignores serverKeys, so this function always clears ALL.
	if not next(private.GetPriceData()) then return end -- bail if data is already empty
	print("Clearing all "..libName.." stats")
	private.ClearAllData()
end

function lib.ClearItem(hyperlink, serverKey)
	-- serverKey is ignored
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end

	local id = strjoin(":", itemId, property, factor)
	local data = private.GetPriceData()
	if not data[id] then return end
	print("Clearing "..libName.." stats for "..hyperlink)
	data[id] = nil
end

--[[ Local functions ]]--

function private.ProcessTooltip(tooltip, name, hyperlink, quality, quantity, cost)
	-- In this function, you are afforded the opportunity to add data to the tooltip should you so
	-- desire. You are passed a hyperlink, and it's up to you to determine whether or what you should
	-- display in the tooltip.

	if not AucAdvanced.Settings.GetSetting("stat.debug.tooltip") then return end

	tooltip:SetColor(0.8, 0.9, 0.3)

	if not quantity or quantity < 1 then quantity = 1 end
	local array = lib.GetPriceArray(hyperlink)
	if not array then
		tooltip:AddLine("Debug: No price data")
		return
	end

	tooltip:AddLine("Debug pricing")
	for i = 1, #array.pricelist do
		tooltip:AddLine("  Debug "..i..":", array.pricelist[i])
	end
end

local StatData

function private.LoadData()
	if (StatData) then return end
	if (not AucAdvancedStatDebugData) then AucAdvancedStatDebugData = {Version='1.0', Data = {}} end
	StatData = AucAdvancedStatDebugData
	private.DataLoaded()
end

function private.ClearAllData()
	if (not StatData) then private.LoadData() end
	wipe(StatData.Data)
end

function private.GetPriceData()
	if (not StatData) then private.LoadData() end
	return StatData.Data
end

function private.DataLoaded()
	if (not StatData) then return end
end

-- Determines the minimum value in the tuple
-- @param ... The values to iterate over, determining
-- the minimum and maximum
-- @return The minimum value in the tuple, or 0 if no values exist
-- @return The maximum value in the tuple, or 0 if no values exist
function private.getBounds(...)
    local n = select('#', ...);
    if n == 0 then
        return 0, 0;
    end

    local min = select(1, ...)
    local max = min;

    for x = 2, n do
        local val = select(x, ...);
        if min > val then
            min = val;
        end

        if max < val then
            max = val;
        end
    end

    return min, max;
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
