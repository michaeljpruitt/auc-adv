--[[
Auctioneer - StatNow
Version: <%version%> (<%codename%>)
Revision: $Id$
URL: http://auctioneeraddon.com/

This module for Auctioneer provides statistics based only on the
most recent auction house scan, and does not save any stat data
across sessions.  It is primarily for those who want a small
memory footprint and are willing to accept recommendations based
only on the current market, without historical information to
help.

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
along with this program(see GPL.txt); if not, write to the Free 
Software Foundation, Inc., 51 Franklin Street, Fifth Floor, 
Boston, MA  02110-1301, USA.

Note:
This AddOn's source code is specifically designed to work with
World of Warcraft's interpreted AddOn system.
You have an implicit license to use this AddOn with these 
facilities since that is its designated purpose as per:
http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]
if not AucAdvanced then return end

local libType, libName = "Stat", "Now"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end

local aucPrint,decode,_,_,replicate,_,get,set,default,debugPrint,fill, _TRANS = AucAdvanced.GetModuleLocals()

local GetFaction = AucAdvanced.GetFaction

-- Eliminate some global lookups
---- Math functions
local ceil,floor,max,min,sqrt,tonumber = ceil,floor,max,min,sqrt,tonumber
---- Iterator functions and select
local select,ipairs,pairs = select,ipairs,pairs
---- Table functions
local tconcat,tinsert,tsort=table.concat,table.insert,table.sort
---- String functions
local strsplit,strfind=strsplit,strfind
---- Sundry functions
local unpack,assert,type,time,wipe,QueryImage = unpack,assert,type,time,wipe,AucAdvanced.API.QueryImage
--[[	QueryImage: A function used to get information from the current
AH snapshot.  It can be called as follows:
someTable = QueryImage(queryTable, serverKey, reserved, ...)
where someTable becomes a table of results.  It's actually a table of
	tables with the following numbered fields:
		1 - item link
		2 - iLvl
		3 - item type
		4 - item subtype
		5 - item equip location
		6 - item price (probably sell-to-vendor price)
		7 - time left
		8 - seen time
		9 - name
		10 - texture
		11 - stack size
		12 - quality
		13 - Useable by the player
		14 - min level to use
		15 - minimum bid
		16 - minimum increment
		17 - buyout
		18 - current bid
		19 - If the player is the high bidder
		20 - Seller of the item
		21 - "flag"
		22 - ID
		23 - Item ID
		24 - Suffix "of the _______"
		25 - Factor
		26 - Enchant
		27 - Seed
	entries of particular interest to us are itemID (Const.ITEMID),
	suffix (Const.SUFFIX) and factor (Const.FACTOR), 
	bid (Const.CURBID), buyout (Const.BUYOUT), and
	stacksize (Const.STACKSIZE).  These should technically
	be handled by importing Auctioneer's Constant table, ie
local Const = AucAdvanced.API.Const

queryTable is a table that may contain the following fields:
	queryTable.itemId (self-explanatory, if missing, you loop the 
		whole image for results, else you get just auctions for
		the specified itemId.)
	queryTable.name (searches the image for items that contain the
		specified string in their names)
	queryTable.link (searches the image for items that match the
		supplied item link)
	queryTable.suffix (searches the image for items matching the 
		specified "of the _______", though this must be a
		numerical code, not a string.)
	queryTable.factor (not actually interesting for me, but I don't
		want to forget what it is.  This is the suffixFactor
		associated with random-enchant items)
	queryTable.perItem (if this exists, the prices returned will be
		returned as prices for one item, regardless of the stack
		size for the auction in the image)
There are many more possible fields, but these are the most pertinent to 
this module.

serverKey: the serverKey you're interested in.  This will always be
	the current server in StatNow
reserved: must always be nil
Anything after 'reserved' only gets used if queryTable.filter exists.
	queryTable.filter must be a function that can be passed two
	arguments: a line of information from the snapshot and the
	filter string.  If this function returns true, the item is
	not included in the results that get from QueryImage.
	--]]
local constants = AucAdvanced.API.Const

local function findmean(meantype,data)
	if meantype == "trimmed" then
		-- Sort the table by numerical value
		tsort(data, function(a,b) return a[constants.BUYOUT]<b[constants.BUYOUT] end)
		-- Determine the number of entries to remove from each end
		local trim = floor(#data*(get("stat.now.trim")/100))
		-- Now slice off the appropriate number of entries.
		for i=1,trim do
			tremove(data)
			tremove(data,1)
			i=i+1
		end
	end
	-- Calculate the mean, variance, and Std. Dev.
	local mean,variance,stddev = 0,0,0
	for i=1,#data do
		mean = mean + data[i][constants.BUYOUT]
	end
	mean = mean/#data
	for i=1,#data do
		variance = variance + (data[i][constants.BUYOUT]-mean)^2
	end
	variance = variance/#data
	stddev = sqrt(variance)
	return mean,variance,stddev
end

function lib.CommandHandler(command, ...)
	local serverKey = GetFaction()
	local _,_,keyText = AucAdvanced.SplitServerKey(serverKey)
	if (command == "help") then
		aucPrint(_TRANS('SNOW_Help_SlashHelp1') ) --Help for Auctioneer Advanced - StatNow
		local line = AucAdvanced.Config.GetCommandLead(libType, libName)
		aucPrint(line, "help}} - ".._TRANS('SNOW_Help_SlashHelp2') ) --this StatNow help
		aucPrint(line, "clear}} - ".._TRANS('SNOW_Help_SlashHelp3'):format(keyText) ) --clear current %s StatNow price database
	elseif (command == "clear") then
		lib.ClearData(serverKey)
	end
end

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		private.ProcessTooltip(...)
	elseif (callbackType == "config") then
		--Called when you should build your Configator tab.
		private.SetupConfigGui(...)
	end
end

lib.Processors = {}
lib.Processors.tooltip = lib.Processor
lib.Processors.config = lib.Processor

lib.ScanProcessors = {}
function lib.ScanProcessors.create(operation, itemData, oldData)
	if not get("stat.now.enable") then return end
	--ToDo: Figure out how to wipe our cache, perhaps by item type
	--if this was a partial scan, and the whole table if it was a
	--full scan.
end


local snowCache = {}

function lib.GetPrice(hyperlink, serverKey)
	if not get("stat.now.enable") then return end
-- Decode the link passed to us, check it's an item link, note item and stack size
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end
	if (factor ~= 0) then property = property.."x"..factor end
	serverKey = serverKey or GetFaction()
	if snowCache[itemId] and snowCache[itemId].stats then
		--Stats stuff
	elseif snowCache[itemId] and snowCache[itemId].checked then
		--No info in the image don't requery.
	else
		--Attempt to build stats
		local query = {itemId = itemId, suffix = property, factor = factor}
		local data = QueryImage(query,serverKey)
		local currentauctions = #data
		local itemvalue
		local valuetype
		if currentauctions > 0 then
			if currentauctions < 5 or get(snow.settings.valuetype) == 1 then
				--Grab the MBO
				valuetype = "MBO"
			elseif (currentauctions > 4 and currentauctions < 20) or get(snow.settings.valuetype) == 2 then
				--Calculate a simple mean
				valuetype = "SMEAN"
			else
				--Calculate a trimmed mean
				valuetype = "TMEAN"
			end
		else
			--No data for item in current image
		end
	end
return itemvalue,false,valuetype,count,confidence
end

function lib.GetPriceColumns()
	return "ItemValue",false,"ValueType","Seen","Confidence"
end

local array = {}
function lib.GetPriceArray(hyperlink, serverKey)
	if not get("stat.now.enable") then return end
	-- Clean out the old array
	wipe(array)

	-- Get our statistics
	local itemvalue,_,valuetype,seen,confidence = lib.GetPrice(hyperlink, serverKey)

	--if nothing is returned, return nil
	if not itemvalue then return end
	array.price = itemvalue
	array.seen = seen
	array.confidence = confidence

	-- Return a temporary array. Data in this array is
	-- only valid until this function is called again.
	return array
end

local bellCurve = AucAdvanced.API.GenerateBellCurve();
-- Gets the PDF curve for a given item. This curve indicates
-- the probability of an item's mean price. Uses an estimation
-- of the normally distributed bell curve by performing
-- calculations on the daily, 3-day, 7-day, and 14-day averages
-- stored by SIMP
-- @param hyperlink The item to generate the PDF curve for
-- @param serverKey The realm-faction key from which to look up the data
-- @return The PDF for the requested item, or nil if no data is available
-- @return The lower limit of meaningful data for the PDF (determined
-- as the mean minus 5 standard deviations)
-- @return The upper limit of meaningful data for the PDF (determined
-- as the mean plus 5 standard deviations)
function lib.GetItemPDF(hyperlink, serverKey)

	if not get("stat.now.enable") then return end
	if not get("stat.now.market") then return end
-- STOPPED HERE -- STOPPED HERE -- STOPPED HERE -- STOPPED HERE -- STOPPED HERE -- STOPPED HERE --
	-- Calculate the lower and upper bounds as +/- 3 standard deviations
	local lower, upper = mean - 3*stddev, mean + 3*stddev;

	bellCurve:SetParameters(mean, stddev);
	return bellCurve, lower, upper;
end

function lib.OnLoad(addon)
	if SSRealmData then return end

	-- Set defaults
	default("stat.now.tooltip", false)
	default("stat.now.avg3", false)
	default("stat.now.avg7", false)
	default("stat.now.avg14", false)
	default("stat.now.minbuyout", true)
	default("stat.now.avgmins", true)
	default("stat.now.quantmul", true)
	default("stat.now.enable", true)
	default("stat.now.reportsafe", false)
end

function lib.ClearItem(hyperlink, serverKey)
	local linkType, itemID, property, factor = AucAdvanced.DecodeLink(hyperlink)
	if linkType ~= "item" then
		return
	end
	if (factor ~= 0) then property = property.."x"..factor end

	serverKey = serverKey or GetFaction ()
	local data = private.GetPriceData (serverKey)

	local cleareditem = false

	if data.daily[itemID] then
		local stats = private.UnpackStats (data.daily[itemID])
		if stats[property] then
			stats[property] = nil
			cleareditem = true
			data.daily[itemID] = private.PackStats (stats)
		end
	end

	if data.means[itemID] then
		local stats = private.UnpackStats (data.means[itemID])
		if stats[property] then
			stats[property] = nil
			cleareditem = true
			data.means[itemID] = private.PackStats (stats)
		end
	end

	if cleareditem then
		local _, _, keyText = AucAdvanced.SplitServerKey(serverKey)
		aucPrint(_TRANS('SIMP_Help_SlashHelpClearingData'):format(libType, hyperlink, keyText)) --%s - Simple: clearing data for %s for {{%s}}
	end
end

function private.SetupConfigGui(gui)
	local id = gui:AddTab(lib.libName, lib.libType.." Modules" )

	gui:AddHelp(id, "what simple stats",
	_TRANS('SIMP_Help_SimpleStats') ,--What are simple stats?
	_TRANS('SIMP_Help_SimpleStatsAnswer')
	)--Simple stats are the numbers that are generated by the Simple module, the Simple module averages all of the prices for items that it sees and provides moving 3, 7, and 14 day averages.  It also provides daily minimum buyout along with a running average minimum buyout within 10% variance.

	--all options in here will be duplicated in the tooltip frame
	function private.addTooltipControls(id)
		gui:AddHelp(id, "what moving day average",
		_TRANS('SIMP_Help_MovingAverage') , --What does \'moving day average\' mean?
		_TRANS('SIMP_Help_MovingAverageAnswer') --Moving average means that it places more value on yesterday\'s moving averagethan today\'s average.  The determined amount is then used for tomorrow\'s moving average calculation.
		)

		gui:AddHelp(id, "how day average calculated",
		_TRANS('SIMP_Help_HowAveragesCalculated') , --How is the moving day averages calculated exactly?
		_TRANS('SIMP_Help_HowAveragesCalculatedAnswer') --Todays Moving Average is ((X-1)*YesterdaysMovingAverage + TodaysAverage) / X, where X is the number of days (3,7, or 14).
		)

		gui:AddHelp(id, "no day saved",
		_TRANS('SIMP_Help_NoDaySaved') ,--So you aren't saving a day-to-day average?
		_TRANS('SIMP_Help_NoDaySavedAnswer') )--No, that would not only take up space, but heavy calculations on each auction house scan, and this is only a simple model.

		gui:AddHelp(id, "minimum buyout",
		_TRANS('SIMP_Help_MinimumBuyout') ,--Why do I need to know minimum buyout?
		_TRANS('SIMP_Help_MinimumBuyoutAnswer')--While some items will sell very well at average within 2 days, others may sell only if it is the lowest price listed.  This was an easy calculation to do, so it was put in this module.
		)

		gui:AddHelp(id, "average minimum buyout",
		_TRANS('SIMP_Help_AverageMinimumBuyout') ,--What's the point in an average minimum buyout?
		_TRANS('SIMP_Help_AverageMinimumBuyoutAnswer')--This way you know how good a market is dealing.  If the MBO (minimum buyout) is bigger than the average MBO, then it\'s usually a good time to sell, and if the average MBO is greater than the MBO, then it\'s a good time to buy.
		)

		gui:AddHelp(id, "average minimum buyout variance",
		_TRANS('SIMP_Help_MinimumBuyoutVariance') ,--What\'s the \'10% variance\' mentioned earlier for?
		_TRANS('SIMP_Help_MinimumBuyoutVarianceAnswer')--If the current MBO is inside a 10% range of the running average, the current MBO is averaged in to the running average at 50% (normal).  If the current MBO is outside the 10% range, the current MBO will only be averaged in at a 12.5% rate.
		)

		gui:AddHelp(id, "why have variance",
		_TRANS('SIMP_Help_WhyVariance') ,--What\'s the point of a variance on minimum buyout?
		_TRANS('SIMP_Help_WhyVarianceAnswer') --Because some people put their items on the market for rediculous price (too low or too high), so this helps keep the average from getting out of hand.
		)

		gui:AddHelp(id, "why multiply stack size simple",
		_TRANS('SIMP_Help_WhyMultiplyStack') ,--Why have the option to multiply stack size?
		_TRANS('SIMP_Help_WhyMultiplyStackAnswer') --The original Stat-Simple multiplied by the stack size of the item, but some like dealing on a per-item basis.
		)

		gui:AddControl(id, "Header",     0,    _TRANS('SIMP_Interface_SimpleOptions') )--Simple options'
		gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
		gui:AddControl(id, "Checkbox",   0, 1, "stat.now.enable", _TRANS('SIMP_Interface_EnableSimpleStats') )--Enable Simple Stats
		gui:AddTip(id, _TRANS('SIMP_HelpTooltip_EnableSimpleStats') )--Allow Simple Stats to gather and return price data
		gui:AddControl(id, "Note",       0, 1, nil, nil, " ")

		gui:AddControl(id, "Checkbox",   0, 4, "stat.now.tooltip", _TRANS('SIMP_Interface_Show') )--Show simple stats in the tooltips?
		gui:AddTip(id, _TRANS('SIMP_HelpTooltip_Show') )--Toggle display of stats from the Simple module on or off
		gui:AddControl(id, "Checkbox",   0, 6, "stat.now.avg3", _TRANS('SIMP_Interface_Toggle3Day') )--Display Moving 3 Day Average
		gui:AddTip(id, _TRANS('SIMP_HelpTooltip_Toggle3Day') )--Toggle display of 3-Day average from the Simple module on or off
		gui:AddControl(id, "Checkbox",   0, 6, "stat.now.avg7", _TRANS('SIMP_Interface_Toggle7Day') )--Display Moving 7 Day Average
		gui:AddTip(id, _TRANS('SIMP_HelpTooltip_Toggle7Day') )--Toggle display of 7-Day average from the Simple module on or off
		gui:AddControl(id, "Checkbox",   0, 6, "stat.now.avg14", _TRANS('SIMP_Interface_Toggle14Day') )--Display Moving 14 Day Average
		gui:AddTip(id,_TRANS( 'SIMP_HelpTooltip_Toggle14Day') )--Toggle display of 14-Day average from the Simple module on or off
		gui:AddControl(id, "Checkbox",   0, 6, "stat.now.minbuyout", _TRANS('SIMP_Interface_MinBuyout') )--Display Daily Minimum Buyout
		gui:AddTip(id, _TRANS('SIMP_HelpTooltip_MinBuyout') )--Toggle display of Minimum Buyout from the Simple module on or offMultiplies by current stack size if on
		gui:AddControl(id, "Checkbox",   0, 6, "stat.now.avgmins", _TRANS('SIMP_Interface_MinBuyoutAverage') )--Display Average of Daily Minimum Buyouts
		gui:AddTip(id,_TRANS( 'SIMP_HelpTooltip_MinBuyoutAverage') )--Toggle display of Minimum Buyout average from the Simple module on or off
		gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
		gui:AddControl(id, "Checkbox",   0, 4, "stat.now.quantmul", _TRANS('SIMP_Interface_MultiplyStack') )--Multiply by stack size
		gui:AddTip(id, _TRANS('SIMP_HelpTooltip_MultiplyStack') )--Multiplies by current stack size if on
		gui:AddControl(id, "Checkbox",   0, 4, "stat.now.reportsafe", _TRANS('SIMP_Interface_LongerAverage') )--Report safer prices for low volume items
		gui:AddTip(id, _TRANS('SIMP_HelpTooltip_LongerAverage') )--Returns longer averages (7-day, or even 14-day) for low-volume items
		gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	end
	--This is the Tooltip tab provided by aucadvnced so all tooltip configuration is in one place
	local tooltipID = AucAdvanced.Settings.Gui.tooltipID

	--now we create a duplicate of these in the tooltip frame
	private.addTooltipControls(id)
	if tooltipID then private.addTooltipControls(tooltipID) end
end

--[[ Local functions ]]--

function private.ProcessTooltip(tooltip, name, hyperlink, quality, quantity, cost)
	-- In this function, you are afforded the opportunity to add data to the tooltip should you so
	-- desire. You are passed a hyperlink, and it's up to you to determine whether or what you should
	-- display in the tooltip.

	if not get("stat.now.tooltip") then return end

	if not quantity or quantity < 1 then quantity = 1 end
	if not get("stat.now.quantmul") then quantity = 1 end

	local serverKey, realm, faction = GetFaction () -- realm/faction requested for anticipated changes to add cross-faction tooltips
	local dayAverage, avg3, avg7, avg14, minBuyout, avgmins, _, dayTotal, dayCount, seenDays, seenCount = lib.GetPrice(hyperlink, serverKey)
	local dispAvg3 = get("stat.now.avg3")
	local dispAvg7 = get("stat.now.avg7")
	local dispAvg14 = get("stat.now.avg14")
	local dispMinB = get("stat.now.minbuyout")
	local dispAvgMBO = get("stat.now.avgmins")
	if (not dayAverage) then return end

	if (seenDays + dayCount > 0) then
		tooltip:AddLine(_TRANS('SIMP_Tooltip_SimplePrices') )--Simple prices:

		if (seenDays > 0) then
			if (dayCount>0) then seenDays = seenDays + 1 end
			tooltip:AddLine("  ".._TRANS('SIMP_Tooltip_SeenNumberDays'):format(seenCount+dayCount, seenDays) ) --Seen {{%s}} over {{%s}} days:

		end
		if (seenDays > 6) and dispAvg14 then
			tooltip:AddLine("  ".._TRANS('SIMP_Tooltip_14DayAverage') , avg14*quantity)--  14 day average
		end
		if (seenDays > 2) and dispAvg7 then
			tooltip:AddLine("  ".._TRANS('SIMP_Tooltip_7DayAverage') , avg7*quantity) --  7 day average
		end
		if (seenDays > 0) and dispAvg3 then
			tooltip:AddLine("  ".._TRANS('SIMP_Tooltip_3DayAverage') , avg3*quantity)--  3 day average
		end
		if (seenDays > 0) and (avgmins > 0) and dispAvgMBO then
			tooltip:AddLine("  ".._TRANS('SIMP_Tooltip_AverageMBO') , avgmins*quantity)--  Average MBO
		end
		if (dayCount > 0) then
			tooltip:AddLine("  ".._TRANS('SIMP_Tooltip_SeenToday'):format(dayCount) , dayAverage*quantity) --Seen {{%s}} today:
		end
		if (dayCount > 0) and (minBuyout > 0) and dispMinB then
			tooltip:AddLine("  ".._TRANS('SIMP_Tooltip_TodaysMBO') , minBuyout*quantity)-- Today's Min BO
		end
	end
end

function private.UnpackStatIter(data, ...)
	local c = select("#", ...)
	local v
	for i = 1, c do
		v = select(i, ...)
		local property, info = strsplit(":", v)
		property = tonumber(property) or property
		if (property and info) then
			data[property] = {strsplit(";", info)}
			local item
			for i=1, #data[property] do
				item = data[property][i]
				data[property][i] = tonumber(item) or item
			end
		end
	end
end

function private.UnpackStats(dataItem)
	local data = {}
	private.UnpackStatIter(data, strsplit(",", dataItem))
	return data
end

local tmp={}
function private.PackStats(data)
	local n=0
	for property, info in pairs(data) do
		n=n+1
		tmp[n]=property..":"..concat(info, ";")
	end
	return concat(tmp,",",1,n)
end

-- The following Functions are the routines used to access the permanent store data

function lib.ClearData(serverKey)
	serverKey = serverKey or GetFaction()
	if AucAdvanced.API.IsKeyword(serverKey, "ALL") then
		wipe(SSRealmData)
		aucPrint(_TRANS('SIMP_Interface_ClearingSimple').." {{".._TRANS("ADV_Interface_AllRealms").."}}") --Clearing Simple stats for // All realms
	elseif SSRealmData[serverKey] then
		local _,_,keyText = AucAdvanced.SplitServerKey(serverKey)
		keyText = keyText or tostring(serverKey) -- avoid display error if database entry is not a valid serverKey (due to minor database corruption)
		SSRealmData[serverKey] = nil
		aucPrint(_TRANS('SIMP_Interface_ClearingSimple').." {{"..keyText.."}}") --Clearing Simple stats for
	end
end

function private.GetPriceData(serverKey)
	local data = snowCache[serverKey]
	if not data then
		if not AucAdvanced.SplitServerKey(serverKey) then
			error("Invalid serverKey passed to Stat-Simple")
		end
		data = {means = {}, daily = {created = time ()}}
		SSRealmData[serverKey] = data
	end
	return data
end

function private.InitData()
	private.InitData = nil

	-- Load data
	private.UpgradeDb()
	SSRealmData = AucAdvancedStatSimpleData.RealmData
	if not SSRealmData then
		SSRealmData = {} -- dummy value to avoid more errors - will not get saved
		error("Error loading or creating StatSimple database")
	end

	-- Note: database errors can occur if user tries to run an older version of StatSimple after the database is upgraded.
	for serverKey, data in pairs (SSRealmData) do
		if type(serverKey) ~= "string" or not strfind (serverKey, ".%-%u%l") then
			-- not a valid serverKey - remove it
			SSRealmData[serverKey] = nil
		else
			-- aggressive checks to strip out any data that is the wrong type
			for key, _ in pairs (data) do
				if key ~= "means" and key ~= "daily" then
					data[key] = nil
				end
			end
			if type(data.means) == "table" then
				for id, packed in pairs (data.means) do
					if type(id) ~= "number" or type(packed) ~= "string" then
						data.means[id] = nil
					end
				end
			else
				data.means = {}
			end
			if type(data.daily) == "table" then
				for id, packed in pairs (data.daily) do
					if id ~= "created" and (type(id) ~= "number" or type(packed) ~= "string") then
						data.daily[id] = nil
					end
				end
				if type(data.daily.created) ~= "number" then
					data.daily.created = time ()
				end
			else
				data.daily = {created = time()}
			end

			-- database maintenance
			if time() - data.daily.created > 3600*16 then
				-- This data is more than 16 hours old, we classify this as "yesterday's data"
				private.PushStats(serverKey)
			end
		end
	end
end


AucAdvanced.RegisterRevision("$URL$", "$Rev$")
