--[[
	AuctioneerDB
	Revision: $Id$
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
LibStub("LibRevision"):Set("$URL$","$Rev$","5.1.DEV.", 'auctioneer', 'libs')

if not AucAdvanced then return end

local libType, libName = "Stat", "AucDb"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
AucDb = lib

local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()

local Babylonian = LibStub("Babylonian")
assert(Babylonian, "Babylonian is not installed")
local babylonian = Babylonian(AucDbLocalizations)
function lib.localizations(key, ...)
	local locale =  get("SelectedLocale")--locales are user choosable
	local fmt
	if locale then
		if type(locale) == "string" then
			fmt = babylonian(locale, key) or key
		else
			fmt = babylonian(GetLocale(), key)
		end
	else
		fmt = babylonian[key] or key
	end
	if select('#', ...) > 0 then
		return fmt:format(...)
	end
	return fmt
end
local _T = lib.localizations

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		private.ProcessTooltip(...)
	elseif (callbackType == "config") then
		private.SetupConfigGui(...)
	elseif (callbackType == "configchanged") then
		local setting, value = ...
		if setting == "aucdb.enabled.market"
		or setting == "aucdb.enabled.stats" then
			AucAdvanced.API.ClearMarketCache()
		end
	end
end

lib.Processors = {}
function lib.Processors.tooltip(callbackType, ...)
	private.ProcessTooltip(...)
end

function lib.Processors.config(callbackType, ...)
	private.SetupConfigGui(...)
end

function lib.Processors.configchanged(callbackType, ...)
	local setting, value = ...
	if setting == "aucdb.enabled.market"
	or setting == "aucdb.enabled.stats" then
		AucAdvanced.API.ClearMarketCache()
	end
end




lib.LoadTriggers = { ["auc-db"] = true }
function lib.OnLoad()
	if not AucDbData then AucDbData = {} end
	if not AucDbData.bids then AucDbData.bids = {} end
	if not AucDbData.sales then AucDbData.sales = {} end
	if not AucDbData.scans then AucDbData.scans = {} end
	if not AucDbData.price then AucDbData.price = {} end
	if not AucDbData.count then AucDbData.count = {} end
	if not AucDbData.started then AucDbData.started = {} end

	local expires
	if AucDb.Enabled then
		expires = time() - (86400 * 3) -- 3 day expiry
	else
		expires = time() - (86400 * 1) -- 1 day expiry
	end
	local dExpires = math.floor(time()/86400) - 14 -- 14 day expiry
	local update = tonumber(lib.UpToDate) or 0
	if update > expires then expires = update end
	for section, sData in pairs(AucDbData) do
		if section == "bids" or section == "sales" or section == "scans" then
			for realm, rData in pairs(sData) do
				for tStamp, tData in pairs(rData) do
					if tStamp <= expires then
						rData[tStamp] = nil
					end
				end
			end
		elseif section == "count" then
			for realm, rData in pairs(sData) do
				for itemSig, iData in pairs(rData) do
					local c = 0
					for dStamp, dData in pairs(iData) do
						c = c + 1
						if dStamp <= dExpires then
							iData[dStamp] = nil
							c = c - 1
						end
					end
					if c == 0 then
						rData[itemSig] = nil
					end
				end
			end
		elseif not (section == "started" or section == "price") then
			AucDbData[section] = nil
		end
	end

	-- Set defaults
	private.SetDefaults()
end
