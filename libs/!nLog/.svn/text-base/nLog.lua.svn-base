--[[
	nLog - A debugging console for World of Warcraft.
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/dl/nLog/
	Copyright (C) 2006 Norganna

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
]]
LibStub("LibRevision"):Set("$URL$","$Rev$","5.1.DEV.", 'auctioneer', 'libs')

-- /run for i = 1, 100000 do nLog.AddMessage("Auctioneer", N_NOTICE, "Scan", "Empty Auction "..i, "Found empty auction with item "..i) end

-- Call nLog.AddMessage(addon, type, level, title, message1, message2, ...)
-- all messages are simply concatenated
-- Eg: nLog.AddMessage("Auctioneer", "Scan", N_NOTICE, "Empty Auction", "Found empty auction on page 10")

-- Message Levels
N_CRITICAL = 1 -- used for critical errors which might crash the addon or
               -- result in corrupted data (especially in the db)
N_ERROR    = 2 -- used for non-critical errors which won't end up in any addon
               -- non-responding or result in incorrect data
N_WARNING  = 3 -- used for states which might cause an error, if they are
               -- unexpected
N_NOTICE   = 4 -- used to give notice of current states which might be useful
               -- and clarify the current functional behaviour
N_INFO     = 5 -- used to inform of less important states which still might be
               -- useful to track down how the code behaves
N_DEBUG    = 6 -- used for local debugging, only - this level MUST NOT be used
               -- in checked-in code - it is designed to provide easy means to
               -- quickly debug code - one of that features is that Swatter can
               -- be set up to output messages of that debuglevel; therefore
               -- it MUST NOT be used in checked-in code, since it would pollute
               -- the chat output of other developers

nLog = {
	messages = {},
	levels = {
		[N_CRITICAL] = "Critical",
		[N_ERROR]    = "Error",
		[N_WARNING]  = "Warning",
		[N_NOTICE]   = "Notice",
		[N_INFO]     = "Info",
		[N_DEBUG]    = "Debug",
	}
}

-- generate the variables used to create the nLogFrame lateron
local iNumOfLevels   = #nLog.levels
local strLevelFilter = "Filter by maximum message priority type ("
for key, data in ipairs(nLog.levels) do
	strLevelFilter = strLevelFilter..key.."="..data.." "
end
-- remove the last whitespace and close the brackets
strLevelFilter = string.sub(strLevelFilter, 1, #strLevelFilter-1)..")"

nLog.Version="<%version%>"
if (nLog.Version == "<%".."version%>") then
	nLog.Version = "4.9.DEV"
end
NLOG_VERSION = nLog.Version

function nLog.ChatMsg(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end

local chat = nLog.ChatMsg
local broken = false
if not p then p = function () end end

function nLog.IsEnabled()
	return nLogData.enabled
end

local function dump(...)
	local out = "";
	local n = select("#", ...)
	for i = 1, n do
		local d = select(i, ...);
		local t = type(d);
		if (t == "table") then
			out = out .. "{";
			local first = true;
			for k, v in pairs(d) do
				if (not first) then out = out .. ", "; end
				first = false;
				out = out .. dump(k);
				out = out .. " = ";
				out = out .. dump(v);
			end
			out = out .. "}";
		elseif (t == "nil") then
			out = out .. "NIL";
		elseif (t == "number") then
			out = out .. d;
		elseif (t == "string") then
			out = out .. "\"" .. d .. "\"";
		elseif (t == "boolean") then
			if (d) then
				out = out .. "true";
			else
				out = out .. "false";
			end
		else
			out = out .. string.upper(t) .. "??";
		end

		if (i < n) then out = out .. ", "; end
	end
	return out;
end

local function format(...)
	local n = select("#", ...)
	local out = ""
	for i = 1, n do
		if i > 1 and out:sub(-1) ~= " " then out = out .. " "; end
		local d = select(i, ...)
		if (type(d) == "string") then
			if (d:sub(1,1) == " ") then
				out = out .. d:sub(2)
			else
				out = out..d;
			end
		else
			out = out..dump(d);
		end
	end
	return out
end

local pid = 0
function nLog.AddMessage(mAddon, mType, mLevel, mTitle, ...)
	if broken then return end
	if not (nLogData.enabled and mAddon and mType and mLevel and mTitle) then return end
	local ts = date("%b %d %H:%M:%S");
	pid = pid + 1
	local msg = format(...)

	-- safety
	if (type(mLevel) ~= "number") then mLevel = tonumber(mLevel) end

	-- sanity
	if (mLevel < N_CRITICAL) then mLevel = N_CRITICAL end
	if (mLevel > N_DEBUG) then mLevel = N_DEBUG end

	-- Once we fill up to 64k entries, treat the table like a loop buffer
	if (#nLog.messages >= 65536) then
		local ofs = nLog.Message.ofs or 0
		ofs = (ofs % 65536) + 1
		-- reuse the old message table
		local message = nLog.messages[ofs]
		if (not message) then chat("Error logging message at offset("..ofs..")") broken = true return end
		message[1] = ts
		message[2] = pid
		message[3] = mAddon
		message[4] = mType
		message[5] = mLevel
		message[6] = mTitle
		message[7] = msg
		nLog.Message.ofs = ofs
	else
		table.insert(nLog.messages, {
			ts, pid, mAddon, mType, mLevel, mTitle, msg
		})
	end

	-- output debug level messages to the chat channel, too, if set so
	if (mLevel == N_DEBUG) and nLogData.chatPrint then
		chat(msg)
	end
end

-- ccox - for those days when you don't want to think too hard about what you're trying to log
function nLog.AddSimpleMessage(...)
	nLog.AddMessage("SimpleMessage", "", N_DEBUG, "", ...)
end

-- blloyd aka prowell -- for those days when you don't want to think too hard about what you're trying to log
--  and don't want to have to view the message itself.
function nLog.AddSimpleTitledMessage(title, ...)
	nLog.AddMessage("SimpleMessage", "", N_DEBUG, title, ...)
end


function nLog.OnEvent(frame, event, ...)
	if (event == "ADDON_LOADED") then
		local addon = ...
		if (addon:lower() == "!nlog") then
			frame:UnregisterEvent("ADDON_LOADED")

			-- create nLogData for the first time
			if not nLogData then
				nLogData = {}
			elseif (nLogData.saveData) then
				nLogData.saveData = nil
			end

			-- enable nlog each session
			nLogData.enabled = true

			-- default chatPrint to false
			if nLogData.chatPrint == nil then
				nLogData.chatPrint = false
			end

			-- initialize nlog's message frame
			nLog.Message.ChatPrint:SetChecked(nLogData.chatPrint)
		end
	end
end


local updateInterval = 1
local updated = 0
function nLog.OnUpdate(frame, delay)
	updated = updated + delay
	if (updated > delay) then
		updated = 0
		-- Do update stuff
		nLog.UpdateDisplay()
	end
end

function nLog.OnClickChatPrintButton()
	nLogData.chatPrint = (nLog.Message.ChatPrint:GetChecked() == 1)
end

function nLog.MessageShow()
	nLog.Message.pos = table.getn(nLog.messages)
	nLog.MessageDisplay()
end

function nLog.MessageDisplay(id)
	nLog.MessageUpdate()
	nLog.Message:Show()
end

function nLog.MessageDone()
	nLog.Message:Hide()
end

function nLog.MessageClicked(...)
end


-- keep track of which message is being displayed
-- invalidate this when the filter changes?
nLog.currentFilteredMessage = nil;

local lastLine = 0
local LOG_LINES = 16
local ENTRY_SIZE = 16  -- number of pixels per entry


-- display a particular message
function nLog.ShowFilteredMessage(fidx)
	nLog.currentFilteredMessage = fidx;
	local idx = nLog.filtered[fidx];
	if (idx) then
		local ts, mId, mAddon, mType, mLevel, mTitle, msg = unpack(nLog.messages[idx])
		local mLevelName = nLog.levels[mLevel]
		local text = string.format("|cffffaa11Date:|r  %s\n|cffffaa11MsgId:|r %s\n|cffffaa11AddOn:|r %s\n|cffffaa11Type:|r  %s\n|cffffaa11Level:|r %s\n|cffffaa11Title:|r %s\n|cffffaa11Message:|r\n%s\n", ts, mId, mAddon, mType, mLevelName, mTitle, msg)
		nLog.Message.Box:SetText(text)
		if select(4, GetBuildInfo() ) >= 30000 then
			local nPos = FauxScrollFrame_GetOffset(nLogMessageScroll)	
			if (nPos >= fidx) then
				FauxScrollFrame_OnVerticalScroll(nLog.Message.MsgScroll, (fidx-1)*ENTRY_SIZE, LOG_LINES, nLog.UpdateDisplay)
			elseif (nPos + LOG_LINES < fidx) then
				FauxScrollFrame_OnVerticalScroll(nLog.Message.MsgScroll, (fidx-LOG_LINES)*ENTRY_SIZE, LOG_LINES, nLog.UpdateDisplay)
			end
		end
	end
end

-- display the message clicked on
function nLog.LineClicked(frame)
	nLog.ShowFilteredMessage(frame.fidx);
end

function nLog.PreviousMessage()
	if (nLog.currentFilteredMessage) then
		-- message displayed, go to previous if we can
		if (nLog.currentFilteredMessage > 1) then
			nLog.ShowFilteredMessage(nLog.currentFilteredMessage - 1)
		end
	else
		-- nothing being displayed, or not in filter, go to last available message
		if (#nLog.filtered > 0) then
			nLog.ShowFilteredMessage(#nLog.filtered);
		end
	end
end

function nLog.NextMessage()
	if (nLog.currentFilteredMessage) then
		-- message displayed, go to next if we can
		if (nLog.currentFilteredMessage < #nLog.filtered) then
			nLog.ShowFilteredMessage(nLog.currentFilteredMessage + 1)
		end
	else
		-- nothing being displayed, go to first available message
		if (#nLog.filtered > 0) then
			nLog.ShowFilteredMessage(1);
		end
	end
end

function nLog.MessageUpdate()
	nLog.Message.BoxScroll:UpdateScrollChildRect()
end

nLog.filtered = {}
function nLog.FilterUpdate()
	nLog.filterLevel = nLog.Message.LevelFilt:GetValue()
	nLog.filterAddon = nLog.Message.AddonFilt:GetText()
	nLog.filterType = nLog.Message.TypeFilt:GetText()
	nLog.filterLabel = nLog.Message.LabelFilt:GetText()

	if nLog.filtered.filterLevel == nLog.filterLevel
	and nLog.filtered.filterAddon == nLog.filterAddon
	and nLog.filtered.filterType == nLog.filterType
	and nLog.filtered.filterLabel == nLog.filterLabel
	and nLog.filtered.count == #nLog.messages
	and nLog.filtered.ofs == nLog.Message.ofs
	then
		return
	end

	-- invalidate the currently shown filtered message index only if the filters changed
	if nLog.filtered.filterLevel ~= nLog.filterLevel
	or nLog.filtered.filterAddon ~= nLog.filterAddon
	or nLog.filtered.filterType ~= nLog.filterType
	or nLog.filtered.filterLabel ~= nLog.filterLabel
	then
		nLog.currentFilteredMessage = nil;
	end

	-- Clean out the filter list and update
	for key in ipairs(nLog.filtered) do
		nLog.filtered[key] = nil
	end

	-- Rebuild the filter list
	local message, mAddon, mType, mLevel, mLabel
	nLog.filtered.filterLevel = nLog.filterLevel
	nLog.filtered.filterAddon = nLog.filterAddon
	nLog.filtered.filterType = nLog.filterType
	nLog.filtered.filterLabel = nLog.filterLabel
	nLog.filtered.count = #nLog.messages
	nLog.filtered.ofs = nLog.Message.ofs

	local fLevel = tonumber(nLog.filtered.filterLevel)
	local fAddon = (nLog.filtered.filterAddon or ""):lower()
	local fType = (nLog.filtered.filterType or ""):lower()
	local fLabel = (nLog.filtered.filterLabel or ""):lower()
	local fOfs = nLog.filtered.ofs or 0
	if (fAddon == "") then fAddon = nil end
	if (fType == "") then fType = nil end
	if (fLabel == "") then fLabel = nil end
	for i = 0, #nLog.messages-1 do
		local fIdx = ((i + fOfs) % 65536)+1
		message = nLog.messages[fIdx]
		mAddon, mType, mLevel, mLabel = message[3], message[4], message[5], message[6]
		if (not fLevel or fLevel >= mLevel)
		and (not fAddon or fAddon == mAddon:sub(1, #fAddon):lower())
		and (not fType or fType == mType:sub(1, #fType):lower())
		and (not fLabel or fLabel == mLabel:sub(1, #fLabel):lower())
		then
			table.insert(nLog.filtered, fIdx)
		end
	end

	if (nLog.Message.AutoScroll:GetChecked() == 1) then
		nLog.ShowFilteredMessage(#nLog.filtered)
	end	

end

function nLog.UpdateDisplay()
	local message, ts, mId, mAddon, mType, mLevel, mLevelName, mTitle, msg, idx, midx
	nLog.FilterUpdate()

	local rows = #nLog.filtered
	local scrollrows = rows
	if (scrollrows > 0 and scrollrows < LOG_LINES+1) then scrollrows = LOG_LINES+1 end
	FauxScrollFrame_Update(nLogMessageScroll, scrollrows, LOG_LINES, ENTRY_SIZE)

	local cpos = FauxScrollFrame_GetOffset(nLogMessageScroll)
	if (cpos ~= lastline) then
		lastline = cpos
	end

	for i = 1, LOG_LINES do
		idx = cpos + i
		midx = nLog.filtered[idx]
		if (midx) then
			message = nLog.messages[midx]
			if (message) then
				ts, mId, mAddon, mType, mLevel, mTitle, msg = unpack(message)
				mLevelName = nLog.levels[mLevel]
				nLog.Message.Lines[i]:SetText(string.format("%s: %s-%s-%s: %s", ts, mAddon, mType, mLevelName, mTitle, msg))
				nLog.Message.Lines[i]:Show()
				nLog.Message.Lines[i].idx = midx
				nLog.Message.Lines[i].fidx = idx;
			else
				nLog.Message.Lines[i]:Hide()
			end
		else
			nLog.Message.Lines[i]:Hide()
		end
	end
end

function nLog.ClearLog()
	nLog.messages = {}
	nLog.UpdateDisplay()
	nLog.Message.Box:SetText("")
	chat("Clearing nLog messages.")
end

function nLog.SaveFilteredMessages()
	nLog.FilterUpdate()
	
	local save = { }
	chat( ("Filtered Count: %d"):format(#nLog.filtered))

	local idx, midx, message
	for idx = 1, #nLog.filtered do
		midx = nLog.filtered[idx]
		if (midx) then
			message = nLog.messages[midx]
			if (message) then
				local tmsg = { }
				local ts, mId, mAddon, mType, mLevel, mTitle, msg = unpack(message)
				local mLevelName = nLog.levels[mLevel]
				tmsg.timeStamp = ts
				tmsg.addon = mAddon
				tmsg.type = mType
				tmsg.level = mLevelName
				tmsg.title = mTitle	
				tmsg.message = msg
				tinsert(save, tmsg)
			else
				chat( ("Missing message for record %d"):format(idx))
			end
		else
			chat( ("Missing midx for record %d"):format(idx))
		end
	end
	if (not nLogData.saveData) then nLogData.saveData = { } end
	tinsert(nLogData.saveData, save)
	chat("Log Saved")
end

local function showTooltip(obj)
	local tooltip = obj.tooltip
	GameTooltip:SetOwner(obj, "ANCHOR_RIGHT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(tooltip)
	GameTooltip:Show()
end

local function hideTooltip()
	GameTooltip:Hide()
end


-- Create our message frame
nLog.Message = CreateFrame("Frame", nil, UIParent)
nLog.Message:Hide()
nLog.Message:SetPoint("CENTER", "UIParent", "CENTER")
nLog.Message:SetFrameStrata("DIALOG")
nLog.Message:SetHeight(440)
nLog.Message:SetWidth(600)
nLog.Message:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true, tileSize = 32, edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
nLog.Message:SetBackdropColor(0,0,0.5, 0.8)
nLog.Message:SetScript("OnShow", nLog.MessageShow)
nLog.Message:SetMovable(true)

nLog.Message.Drag = CreateFrame("Button", nil, nLog.Message)
nLog.Message.Drag:SetPoint("TOPLEFT", nLog.Message, "TOPLEFT", 10,-5)
nLog.Message.Drag:SetPoint("TOPRIGHT", nLog.Message, "TOPRIGHT", -10,-5)
nLog.Message.Drag:SetHeight(6)
nLog.Message.Drag:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
nLog.Message.Drag:SetScript("OnMouseDown", function() nLog.Message:StartMoving() end)
nLog.Message.Drag:SetScript("OnMouseUp", function() nLog.Message:StopMovingOrSizing() end)


-- bottom row
nLog.Message.AddonFilt = CreateFrame("EditBox", "nLogAddFilt", nLog.Message, "InputBoxTemplate")
nLog.Message.AddonFilt:SetPoint("BOTTOMLEFT", nLog.Message, "BOTTOMLEFT", 20, 12)
nLog.Message.AddonFilt:SetAutoFocus(false)
nLog.Message.AddonFilt:SetHeight(15)
nLog.Message.AddonFilt:SetWidth(80)
nLog.Message.AddonFilt.tooltip = "Filter by AddOn"
nLog.Message.AddonFilt:SetScript("OnEnter", showTooltip)
nLog.Message.AddonFilt:SetScript("OnLeave", hideTooltip)

nLog.Message.TypeFilt = CreateFrame("EditBox", "nLogTypeFilt", nLog.Message, "InputBoxTemplate")
nLog.Message.TypeFilt:SetPoint("BOTTOMLEFT", nLog.Message.AddonFilt, "BOTTOMRIGHT", 5, 0)
nLog.Message.TypeFilt:SetAutoFocus(false)
nLog.Message.TypeFilt:SetHeight(15)
nLog.Message.TypeFilt:SetWidth(80)
nLog.Message.TypeFilt.tooltip = "Filter by Type"
nLog.Message.TypeFilt:SetScript("OnEnter", showTooltip)
nLog.Message.TypeFilt:SetScript("OnLeave", hideTooltip)

nLog.Message.LabelFilt = CreateFrame("EditBox", "nLogLabelFilt", nLog.Message, "InputBoxTemplate")
nLog.Message.LabelFilt:SetPoint("BOTTOMLEFT", nLog.Message.TypeFilt, "BOTTOMRIGHT", 5, 0)
nLog.Message.LabelFilt:SetAutoFocus(false)
nLog.Message.LabelFilt:SetHeight(15)
nLog.Message.LabelFilt:SetWidth(80)
nLog.Message.LabelFilt.tooltip = "Filter by Label"
nLog.Message.LabelFilt:SetScript("OnEnter", showTooltip)
nLog.Message.LabelFilt:SetScript("OnLeave", hideTooltip)

nLog.Message.LevelFilt = CreateFrame("Slider", "nLogLevelFilt", nLog.Message, "OptionsSliderTemplate")
nLog.Message.LevelFilt:SetPoint("BOTTOMLEFT", nLog.Message.LabelFilt, "BOTTOMRIGHT", 5, -3)
nLog.Message.LevelFilt:SetHeight(20)
nLog.Message.LevelFilt:SetWidth(60)
nLogLevelFiltLow:SetText("")
nLogLevelFiltHigh:SetText("")
nLog.Message.LevelFilt:SetMinMaxValues(1, iNumOfLevels)
nLog.Message.LevelFilt:SetValueStep(1)
nLog.Message.LevelFilt:SetValue(N_DEBUG)
nLog.Message.LevelFilt:SetHitRectInsets(0,0,0,0)
nLog.Message.LevelFilt.tooltip = strLevelFilter
nLog.Message.LevelFilt:SetScript("OnEnter", showTooltip)
nLog.Message.LevelFilt:SetScript("OnLeave", hideTooltip)

nLog.Message.ChatPrint = CreateFrame("CheckButton", "nLogChatPrint", nLog.Message, "OptionsCheckButtonTemplate")
nLog.Message.ChatPrint:SetPoint("TOPLEFT", nLog.Message.LevelFilt, "TOPRIGHT", 50, 10)
nLog.Message.ChatPrint:SetScript("OnClick", nLog.OnClickChatPrintButton)
nLog.Message.ChatPrint:SetHitRectInsets(0, 0, 0, 0)
_G["nLogChatPrintText"]:SetText("ChatPrint")

nLog.Message.Done = CreateFrame("Button", nil, nLog.Message, "OptionsButtonTemplate")
nLog.Message.Done:SetText("Close")
nLog.Message.Done:SetPoint("BOTTOMRIGHT", nLog.Message, "BOTTOMRIGHT", -20, 10)
nLog.Message.Done:SetScript("OnClick", nLog.MessageDone)


-- just below message box (above bottom row)
nLog.Message.Previous = CreateFrame("Button", nil, nLog.Message, "OptionsButtonTemplate")
nLog.Message.Previous:SetText("Previous")
nLog.Message.Previous:SetPoint("BOTTOMRIGHT", nLog.Message.Done, "TOPRIGHT", 0, 10)
nLog.Message.Previous:SetScript("OnClick", nLog.PreviousMessage)

nLog.Message.Next = CreateFrame("Button", nil, nLog.Message, "OptionsButtonTemplate")
nLog.Message.Next:SetText("Next")
nLog.Message.Next:SetPoint("BOTTOMRIGHT", nLog.Message.Previous, "BOTTOMLEFT", -10, 0)
nLog.Message.Next:SetScript("OnClick", nLog.NextMessage)

nLog.Message.Save = CreateFrame("Button", nil, nLog.Message, "OptionsButtonTemplate")
nLog.Message.Save:SetText("Save")
nLog.Message.Save:SetPoint("BOTTOMRIGHT", nLog.Message.Next, "BOTTOMLEFT", -10, 0)
nLog.Message.Save:SetScript("OnClick", nLog.SaveFilteredMessages)

nLog.Message.AutoScroll = CreateFrame("CheckButton", "nLogAutoScroll", nLog.Message, "OptionsCheckButtonTemplate")
nLog.Message.AutoScroll:SetPoint("BOTTOMLEFT", nLog.Message.AddonFilt, "TOPLEFT", 0, 10)
nLog.Message.AutoScroll:SetScript("OnClick", nLog.OnClickAutoScroll)
nLog.Message.AutoScroll:SetHitRectInsets(0, 0, 0, 0)
_G["nLogAutoScrollText"]:SetText("Auto Show Latest")

-- scroll bar for the list
nLog.Message.MsgScroll = CreateFrame("ScrollFrame", "nLogMessageScroll", nLog.Message, "FauxScrollFrameTemplate")
nLog.Message.MsgScroll:SetPoint("TOPLEFT", nLog.Message, "TOPLEFT", 20, -20)
nLog.Message.MsgScroll:SetPoint("RIGHT", nLog.Message, "RIGHT", -40, 0)
nLog.Message.MsgScroll:SetHeight(200)
if select(4, GetBuildInfo() ) >= 30000 then
	-- ccox - WoW 3.0 changed the FauxScrollFrame_OnVerticalScroll function
	nLog.Message.MsgScroll:SetScript("OnVerticalScroll", function (args, offset) FauxScrollFrame_OnVerticalScroll(nLog.Message.MsgScroll, offset, ENTRY_SIZE, nLog.UpdateDisplay) end)
else
	nLog.Message.MsgScroll:SetScript("OnVerticalScroll", function () FauxScrollFrame_OnVerticalScroll(ENTRY_SIZE, nLog.UpdateDisplay) end)
end
nLog.Message.MsgScroll:SetScript("OnShow", function() nLog.UpdateDisplay() end)

-- box frame for the message text and scroller
nLog.Message.BoxFrame = CreateFrame("Frame", nil, nLog.Message)
nLog.Message.BoxFrame:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true, tileSize = 32, edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
nLog.Message.BoxFrame:SetBackdropColor(0,0,0.5, 0.8)
nLog.Message.BoxFrame:SetPoint("TOPLEFT", nLog.Message.MsgScroll, "BOTTOMLEFT", -5, 0)
nLog.Message.BoxFrame:SetPoint("RIGHT", nLog.Message, "RIGHT", -15, 0)
nLog.Message.BoxFrame:SetPoint("BOTTOM", nLog.Message.Previous, "TOP", 0, 5)

-- scroll bar for the message text
nLog.Message.BoxScroll = CreateFrame("ScrollFrame", "nLogMessageInputScroll", nLog.Message.BoxFrame, "UIPanelScrollFrameTemplate")
nLog.Message.BoxScroll:SetPoint("TOPLEFT", nLog.Message.BoxFrame, "TOPLEFT", 10, -5)
nLog.Message.BoxScroll:SetPoint("BOTTOMRIGHT", nLog.Message.BoxFrame, "BOTTOMRIGHT", -27, 4)

-- the message box itself
nLog.Message.Box = CreateFrame("EditBox", "nLogMessageEditBox", nLog.Message.BoxScroll)
nLog.Message.Box:SetFont("Interface\\AddOns\\!nLog\\VeraMono.TTF", 11)
nLog.Message.Box:SetPoint("BOTTOM", nLog.Message.BoxFrame, "BOTTOM", 0,0)
nLog.Message.Box:SetWidth(550)
nLog.Message.Box:SetMultiLine(true)
nLog.Message.Box:SetAutoFocus(false)
nLog.Message.Box:SetFontObject(GameFontHighlight)
nLog.Message.Box:SetScript("OnEscapePressed", nLog.MessageDone)
nLog.Message.Box:SetScript("OnTextChanged", nLog.MessageUpdate)
nLog.Message.Box:SetScript("OnEditFocusGained", nLog.MessageClicked)
nLog.Message.Box:SetText("|cffffa011Select a message above to view it's contents.|r")
nLog.Message.BoxScroll:SetScrollChild(nLog.Message.Box)

-- the message list (faked with buttons)
nLog.Message.Lines = {}
for i=1, 16 do
	local line = CreateFrame("Button", nil, nLog.Message)
	nLog.Message.Lines[i] = line
	line.id = i
	if (i == 1) then
		line:SetPoint("TOPLEFT", nLog.Message.MsgScroll, "TOPLEFT", 0, 0)
	else
		line:SetPoint("TOPLEFT", nLog.Message.Lines[i-1], "BOTTOMLEFT", 0, 0)
	end
	line:SetPoint("RIGHT", nLog.Message.MsgScroll, "RIGHT", -5, 0)
	line:SetHeight(12)
	line:SetScript("OnClick", nLog.LineClicked)
	line.text = line:CreateFontString(nil, "HIGH")
	line.text:SetPoint("LEFT", line, "LEFT")
	line.text:SetPoint("RIGHT", line, "RIGHT")
	line.text:SetFont("Interface\\AddOns\\!nLog\\VeraMono.TTF", 11)
	line.text:SetJustifyH("LEFT")
	line.SetText = function(obj, ...) obj.text:SetText(...) end
	line:SetText("LINE "..i)
end

nLog.UpdateDisplay()

nLog.Frame = CreateFrame("Frame")
nLog.Frame:Show()
nLog.Frame:SetScript("OnEvent", nLog.OnEvent)
nLog.Frame:SetScript("OnUpdate", nLog.OnUpdate)
nLog.Frame:RegisterEvent("ADDON_LOADED")

SLASH_NLOG1 = "/nlog"
SlashCmdList["NLOG"] = function(msg)
	if (not msg or msg == "" or msg == "help") then
		chat("nLog help:")
		chat("  /nlog enable      -  Enables nLog")
		chat("  /nlog disable     -  Disables nLog")
		chat("  /nlog show        -  Shows the nLog frame")
		chat("  /nlog clear       -  Clears current nLog messages")
		chat("  /nlog save        -  Saves the current message view (with filters on) into the LUA store")
		chat("                       Note that the save is deleted next time WoW is (re)started")
		chat("                       You can also save multiple views to file during a single session if desired")
		chat("  /nlog chatEnable  -  Prints debug level messages also to the chat channel")
		chat("  /nlog chatDisable -  Do no longer print debug level messages to the chat channel")
	elseif (msg == "show") then
		nLog.Message:Show()
	elseif (msg == "enable") then
		nLogData.enabled = true
		chat("nLog will now catch messages")
	elseif (msg == "disable") then
		nLogData.enabled = false
		chat("nLog will no longer catch messages")
	elseif (msg == "clear") then
		nLog.ClearLog()
	elseif (msg == "chatEnable") then
		nLogData.chatPrint = true
		nLog.Message.ChatPrint:SetChecked(true)
	elseif (msg == "chatDisable") then
		nLogData.chatPrint = false
		nLog.Message.ChatPrint:SetChecked(false)
	elseif (msg == "save") then
		nLog.SaveFilteredMessages()
	else
		chat("Unknown nLog command: "..(msg or "nil"))
	end
end

local function toggle()
	if nLog.Message:IsVisible() then
		nLog.Message:Hide()
	else
		nLog.Message:Show()
	end
end

if LibStub then
	local LibDataBroker = LibStub:GetLibrary("LibDataBroker-1.1", true)
	if not LibDataBroker then return end
	local LDBButton = LibDataBroker:NewDataObject("nLog", {
				type = "launcher",
				icon = "Interface\\AddOns\\!nLog\\Textures\\nLogIcon",
				OnClick = function(self, button) toggle(self, button) end,
				})
	
	function LDBButton:OnTooltipShow()
		self:AddLine("Norganna's Log",  1,1,0.5, 1)
		self:AddLine("nLog is a debugging utility designed for use by AddOn authors or professional testers only.",  1,1,0.5, 1)
		self:AddLine("If you have inadvertently found yourself with this addon installed, and are a normal end-user, we recommend that you disable it from loading.",  1,1,0.5, 1)
		self:AddLine("|cff1fb3ff".."Click".."|r ".."to open the log window.",  1,1,0.5, 1)
	end
	function LDBButton:OnEnter()
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
		GameTooltip:ClearLines()
		LDBButton.OnTooltipShow(GameTooltip)
		GameTooltip:Show()
	end
	function LDBButton:OnLeave()
		GameTooltip:Hide()
	end
end	
