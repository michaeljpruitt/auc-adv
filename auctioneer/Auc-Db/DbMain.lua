--[[
	AuctioneerDB
	Revision: $Id: DbCore.lua 3583 2008-10-11 16:50:02Z Norganna $
	Version: <%version%>

	This is an addon for World of Warcraft that integrates with the online
	auction database site at http://auctioneerdb.com.
	This addon provides detailed price data for auctionable items based off
	an online database that is contributed to by users just like you.
	If you want to contribute your data and keep your price up-to-date, you
	can easily update your pricelist by using the sychronization utility
	which is provided with this addon.
	To syncronize you data, run the SyncDb executable for your platform.

	License:
		AuctioneerDB AddOn for World of Warcraft.
		Copyright (C) 2007, Norganna's AddOns Pty Ltd.

		This program is free software: you can redistribute it and/or modify
		it under the terms of the GNU General Public License as published by
		the Free Software Foundation, either version 3 of the License, or
		(at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program.  If not, see <http://www.gnu.org/licenses/>.

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit license to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]
LibStub("LibRevision"):Set("$URL: http://dev.norganna.org/auctioneer/trunk/Auc-Db/DbCore.lua $","$Rev: 3583 $","5.1.DEV.", 'auctioneer', 'libs')

if not AucDb then return end
local lib = AucDb
local private = lib.Private

local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()
local _T = lib.localizations

local function getTime()
	return time()
end

local rope = LibStub("StringRope"):New()
local faction, designation, scanid
local result = {}

local function RealmDesignation(faction, portal)
	local realm

	if not portal then portal = GetCVar("portal") or "??" end
	portal = portal:upper()

	if faction then
		local a,b = strmatch(faction, "(.+)%-(%u%l+)$")
		if a and b then
			realm, faction = a, b
		else
			realm = GetRealmName() 
		end
	end

	if (not realm or not faction) and AucAdvanced and AucAdvanced.GetFaction then
		local _, a, b = AucAdvanced.GetFaction()
		if not realm then realm = a end
		if not faction then faction = b end
	end

	if not realm then realm = GetRealmName() end

	if not realm then realm = "Unknown" end
	if not faction then faction = "Unknown" end
	return portal.."/"..realm.."-"..faction, portal, realm, faction
end
AucDb.RealmDesignation = RealmDesignation

function private.SetDefaults()
	default("aucdb.enable.tooltip", true)
	default("aucdb.enable.stats", true)
	default("aucdb.enable.market", true)
	default("aucdb.prefer", "either")
	default("aucdb.minseen", 3)
	default("aucdb.age.warn", 15)
	default("aucdb.age.expire", 45)
end

function private.SetupConfigGui(gui)
	local id = gui:AddTab(lib.libName, lib.libType.." Modules" )

	local function addHelp(section)
		gui:AddHelp(id, 'help'..section, _T(section.."Help"), _T(section.."Answer"))
	end
	local function addCheckbox(setting, trans)
		gui:AddControl(id, "Checkbox", 0, 1, setting, _T(trans))
		gui:AddTip(id, _T(trans.."Tip"))
	end
	local function addSlider(setting, trans, min,max)
		gui:AddControl(id, "WideSlider", 0, 1, setting, min, max, 1, _T(trans))
		gui:AddTip(id, _T(trans.."Tip"))
	end
	local function addSelect(setting, trans, menu)
		gui:AddControl(id, "Selectbox", 0, 1, menu, setting, _T(trans))
		gui:AddTip(id, _T(trans.."Tip"))
	end

	addHelp('AuctioneerDb')
	addHelp('AucDb')
	addHelp('Updating')

	gui:AddControl(id, "Header", 0, _T('SetupAucDb'))

	addCheckbox('aucdb.enable.stats', 'StatOption')
	addCheckbox('aucdb.enable.tooltip', 'ShowOption')
	addCheckbox('aucdb.enable.market', 'MarketOption')

	addSelect('aucdb.prefer', "PreferStat", {
		{"global", _T('PreferGlobal') },
		{"realm", _T('PreferRealm') },
		{"either", _T('PreferEither') },
	})
	addSlider('aucdb.minseen', 'MinSeen', 0,20)

	addSlider('aucdb.age.warn', 'WarnAge', 7,90)
	addSlider('aucdb.age.expire', 'WarnAge', 7,120)
end

function private.ProcessTooltip(tooltip, name, hyperlink, quality, quantity, cost)
	if not lib.Base then return end
	if not get("aucdb.enable.stats") then return end
	if not get("aucdb.enable.tooltip") then return end
	if not quantity or quantity < 1 then quantity = 1 end

	local age = math.floor((time() - lib.Base.buildtime)/86400)
	if age > (tonumber(get("aucdb.age.expire")) or 45) then
		tooltip:AddLine(_T('OutOfDate', age))
		return
	end
	if age > (tonumber(get("aucdb.age.warn")) or 15) then
		tooltip:AddLine(_T('GettingOld', age))
	end

	lib.GetPriceArray(hyperlink)
	if not result.seen then
		tooltip:AddLine(_T('AucDbNoseen'))
	else
		tooltip:AddLine(_T('AucDbPrices', result.seen))
		tooltip:AddLine("  ".._T('PriceLabel', _T('Label_'..result.use), _T('Label_average')), result.price)
		if (result.saleseen > 0) then
			tooltip:AddLine("  ".._T('SaleLabel', _T('Label_'..result.use), _T('Label_average')), result.saleprice)
		end
	end
end

function lib.GetPriceArray(hyperlink)
	if not lib.Base then return end
	if not get("aucdb.enable.stats") then return end

	local linkType,item,suffix,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end

	local age = math.floor((time() - lib.Base.buildtime)/86400)
	if age > (tonumber(get("aucdb.age.expire")) or 45) then return end
	local designation, portal, realm, faction = RealmDesignation()
	faction = faction:lower()
	
	local sig = ("%d:%d"):format(item, suffix)
	if (result.sig == sig) then return result end

	local prefer = get('aucdb.prefer')
	local minseen = get('aucdb.minseen')

	empty(result)
	result.use="realm"
	result.sig=sig

	local base = lib.Base
	local lots,min,avg,max,std,q1,q2,q3,iqr,iqm,mod
	for i,r in ipairs({"realm", "global"}) do
		for j,f in ipairs({"alliance", "horde", "neutral"}) do
			for k,t in ipairs({"bid", "buy"}) do
				lots,min,avg,max,std = 0,0,0,0,0
				if base[r] and base[r][f] and base[r][f][t] and base[r][f][t][sig] then
					lots,min,avg,max,std,q1,q2,q3,iqr,iqm,mod = strsplit(":", base[r][f][t][sig])
				end
				
				result[r..f..t.."seen"]=tonumber(lots) or 0
				result[r..f..t.."minimum"]=tonumber(min)
				result[r..f..t.."average"]=tonumber(avg)
				result[r..f..t.."maximum"]=tonumber(max)
				result[r..f..t.."deviation"]=tonumber(std)
				result[r..f..t.."quartile1"]=tonumber(q1)
				result[r..f..t.."quartile2"]=tonumber(q2)
				result[r..f..t.."quartile3"]=tonumber(q3)
				result[r..f..t.."interquartilerange"]=tonumber(iqr)
				result[r..f..t.."interquartilemean"]=tonumber(iqm)
				result[r..f..t.."mode"]=tonumber(mod)
			end
		end
	end

	if (prefer == 'either' and result["realm"..faction.."buyseen"] < minseen) or prefer == "global" then
		result.use = "global"
	end

	result.stddev = result[result.use..faction.."buydeviation"]
	result.price = result[result.use..faction.."buyaverage"]
	result.seen = result[result.use..faction.."buyseen"]
	result.saleprice = result[result.use..faction.."bidaverage"]
	result.saleseen = result[result.use..faction.."bidseen"]
end

local bellCurve = AucAdvanced.API.GenerateBellCurve()
function lib.GetItemPDF(hyperlink)
	if not lib.Base then return end
	if not get("aucdb.enable.stats") then return end
	if not get("aucdb.enable.market") then return end

	lib.GetPriceArray(hyperlink)
	local seenCount, stddev, mean = result.seen, result.stddev, result.price
    if seenCount == 0 or stddev ~= stddev or mean ~= mean or not mean or mean == 0 then return end
    if stddev == 0 then stddev = mean / sqrt(seenCount); end
    local lower, upper = mean - 3*stddev, mean + 3*stddev
    bellCurve:SetParameters(mean, stddev)
    return bellCurve, lower, upper
end

function private.getLink(itemName)
	local _, itemLink = GetItemInfo(itemName)
	local itemId, itemSuffix
	if itemLink then
		_, itemId, itemSuffix = AucAdvanced.DecodeLink(itemLink)
	else
		for sig, name in pairs(AucDbData.started) do
			if name == itemName then
				itemId, itemSuffix = strsplit(":", sig)
				_, itemLink = GetItemInfo("item:"..itemId..":0:0:0:0:0:"..itemSuffix)
			end
		end
	end
	return itemLink, tonumber(itemId), tonumber(itemSuffix) or 0
end

function private.getPrice(itemId)
	itemId = tonumber(itemId)
	if itemId then
		local price = AucDbData.price[itemId]
		if not price and GetSellValue then
			price = GetSellValue(itemId)
		end
		return tonumber(price)
	end
end

function private.findDeposit(deposit, rate, price, buyout, ...)
	local n = select("#", ...)
	for i=1, n do
		local detail = select(i, ...)
		local detailBuyout, count, runTime = strsplit(":", detail)
		detailBuyout = tonumber(detailBuyout)
		count = tonumber(count)
		runTime = tonumber(runTime)
		if buyout == detailBuyout then
			if deposit == 0 then
				return count, run
			end
			local run = runTime/720
			local total = math.floor(price * rate * count) * run
			if total == deposit then
				return count, run
			end
		end
	end
end

function private.guessCount(itemId, itemSuffix, faction, deposit, buyout)
	local price = private.getPrice(itemId)
	if price == nil then return end

	local rate = 0.15
	if faction:lower() == "neutral" then rate = 0.75 end

	private.setDesignation()

	if AucDbData.count[designation] then
		local search = itemId..":"..itemSuffix
		if AucDbData.count[designation][search] then
			for dayidx, details in pairs(AucDbData.count[designation][search]) do
				local count, run = private.findDeposit(deposit, rate, price, buyout, strsplit(";", details))
				if count and run then
					return count, run
				end
			end
		end
	end
end

function private.setDesignation(force)
	if not designation or force then
		faction = AucAdvanced.GetFaction()
		designation = RealmDesignation(faction)
	end
end

function private.begin()
	rope:Clear()
	scanid = getTime()
	private.setDesignation(true)
	if not AucDbData then AucDbData = {} end
	if not AucDbData.scans then AucDbData.scans = {} end
	if not AucDbData.scans[designation] then AucDbData.scans[designation] = {} end
end

function private.process(operation, itemData, oldData)
	if designation and scanid then
		if not rope:IsEmpty() then rope:Add(";") end
		rope:AddDelimited(":", itemData.itemId, itemData.itemSuffix, itemData.itemEnchant, itemData.itemFactor, itemData.itemSeed, itemData.stackSize, itemData.sellerName, itemData.minBid, itemData.buyoutPrice, itemData.curBid, itemData.timeLeft)
	end
end
function private.complete()
	if (designation and scanid) then
		AucDbData.scans[designation][scanid] = rope:Get()
	end
	if rope then
		rope:Clear()
	end
end

function private.bid(operation, itemData, bidType, index, bid)
	local prevLine = ""
	local timeidx = getTime()
	local line = strjoin(":", itemData.itemId,itemData.itemSuffix,itemData.itemEnchant, itemData.itemFactor, itemData.itemSeed, itemData.stackSize, itemData.sellerName, itemData.minBid, itemData.buyoutPrice, itemData.curBid, itemData.timeLeft, bidType, bid)
	print("Accepted bid for", itemData.itemName)

	private.setDesignation()

	if not AucDbData then AucDbData = {} end
	if not AucDbData.bids then AucDbData.bids = {} end
	if not AucDbData.bids[designation] then AucDbData.bids[designation] = {} end
	if AucDbData.bids[designation][timeidx] then prevLine = AucDbData.bids[designation][timeidx] .. ";" end

	AucDbData.bids[designation][timeidx] = prevLine .. line
end

function private.start(operation, itemData, minBid, buyoutPrice, runTime, price)
	local prevLine = ""
	local timeidx = getTime()
	local dayidx = math.floor(timeidx / 86400)
	local line = strjoin(":", itemData.itemId,itemData.itemSuffix,itemData.itemEnchant, itemData.itemFactor, itemData.itemSeed, itemData.stackSize, itemData.sellerName, itemData.minBid, itemData.buyoutPrice, itemData.curBid, itemData.timeLeft)
	print("Started auction for", itemData.itemName)

	private.setDesignation()

	if not AucDbData then AucDbData = {} end
	if not AucDbData.price then AucDbData.price = {} end
	if not AucDbData.count then AucDbData.count = {} end
	if not AucDbData.start then AucDbData.start = {} end
	if not AucDbData.started then AucDbData.started = {} end
	if not AucDbData.start[designation] then AucDbData.start[designation] = {} end
	if AucDbData.start[designation][timeidx] then prevLine = AucDbData.start[designation][timeidx] .. ";" end

	local sig = ("%d:%d:%d"):format(itemData.itemId,itemData.itemSuffix,0)
	AucDbData.started[sig] = itemData.itemName
	AucDbData.price[itemData.itemId] = price
	AucDbData.start[designation][timeidx] = prevLine .. line

	sig = ("%d:%d"):format(itemData.itemId,itemData.itemSuffix)
	if not AucDbData.count[designation] then AucDbData.count[designation] = {} end
	if not AucDbData.count[designation][sig] then AucDbData.count[designation][sig] = {} end
	if AucDbData.count[designation][sig][dayidx] then prevLine = AucDbData.count[designation][sig][dayidx] .. ";" end
	AucDbData.count[designation][sig][dayidx] = prevLine .. strjoin(":", itemData.buyoutPrice, itemData.stackSize, runTime)
end

function private.sale(operation, faction, itemName, playerName, bid, buyout, deposit, consignment)
	local prevLine = ""
	local timeidx = getTime()
	local designation = RealmDesignation(faction)
	local itemLink, itemId, itemSuffix = private.getLink(itemName)
	if not itemLink then return end
	local count, runTime = private.guessCount(itemId, itemSuffix, faction, deposit, buyout)
	if not count then return end

	local line = strjoin(":", itemId,itemSuffix,0,0,0,count,UnitName("player"),0,buyout,bid,0)
	print("Processed sale for", itemName)

	if not AucDbData then AucDbData = {} end
	if not AucDbData.start then AucDbData.start = {} end
	if not AucDbData.sales[designation] then AucDbData.sales[designation] = {} end
	if AucDbData.sales[designation][timeidx] then prevLine = AucDbData.sales[designation][timeidx] .. ";" end

	AucDbData.sales[designation][timeidx] = prevLine .. line
end

lib.ScanProcessors = {
	begin = private.begin,
	create = private.process,
	update = private.process,
	complete = private.complete,
	placebid = private.bid,
	aucsold = private.sale,
	newauc = private.start,
}


