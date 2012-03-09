--[[
	Constructor Library for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/dl
	Copyright: (C) 2007 Esteban Santana Santana (MentalPower)

	Sample frame definition for use with the Constructor library.
	The frame included was originally designed for Itemizer.

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

local Constructor = LibStub:GetLibrary("Constructor")
local frameTemplate = {
	"Main Sample Frame",
	{
		type="Frame",
		name="ConstructorTest",
		parent="UIParent",
		methods = {
			{ f="SetToplevel", true },
			{ f="SetSize", 384, 512 },
			{ f="SetFrameStrata", "MEDIUM" },
			{ f="SetPoint", "TOPLEFT", 100, -104 },
		},
		children = {
			{
				type="Texture", --Main Texture (Dark Blue)
				methods = {
					{ f="SetAlpha", 0.87 },
					{ f="SetDrawLayer", "BACKGROUND" },
					{ f="SetTexCoord", 0.1, 1.0, 0.03, 0.9 },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, -67 },
					{ f="SetTexture", "Interface\\Stationery\\Stationery_ill1" },
					{ f="SetPoint", "BOTTOMRIGHT", "&parent", "BOTTOMRIGHT", -20, 0 },
				}
			},
			{
				type="Texture", --TopLeft corner texture (70% Gray Round Corner)
				methods = {
					{ f="SetWidth", 32 },
					{ f="SetHeight", 32 },
					{ f="SetDrawLayer", "BACKGROUND" },
					{ f="SetVertexColor", 0, 0, 0.5, 0.8 },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, 0 },
					{ f="SetTexture", "Interface\\AddOns\\Constructor\\Test\\Art\\RoundCorner" },
				}
			},
			{
				type="Texture", --Header Texture (70% Gray)
				methods = {
					{ f="SetHeight", 35 },
					{ f="SetTexture", 0, 0, 0.5, 0.8 },
					{ f="SetDrawLayer", "BACKGROUND" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 32, 0 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, 0 },
				}
			},
			{
				type="Texture", --Secondary Header Texture (70% Gray)
				methods = {
					{ f="SetHeight", 32 },
					{ f="SetTexture", 0.29, 0.31, 0.35, 0.8 },
					{ f="SetDrawLayer", "BACKGROUND" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, -35 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", -20, -35 },
				}
			},
			{
				type="Texture", --Separator (Black)
				methods = {
					{ f="SetHeight", 3 },
					{ f="SetTexture", 0, 0, 0, 0.8 },
					{ f="SetDrawLayer", "ARTWORK" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, -32 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, -32 },
				}
			},
			{
				type="FontString", --Window Title
				name="Title",
				inherits="GameFontNormalHuge",
				methods = {
					{ f="SetHeight", 30 },
					{ f="SetJustifyV", "CENTER" },
					{ f="SetJustifyH", "CENTER" },
					{ f="SetDrawLayer", "ARTWORK" },
					{ f="SetText", "Sample Window" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, 0 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, 0 },
				}
			},
			{
				type="FontString",--Window Sub-Title
				name="NumItems",
				inherits="GameFontNormalLarge",
				methods = {
					{ f="SetHeight", 30 },
					{ f="SetJustifyV", "CENTER" },
					{ f="SetJustifyH", "CENTER" },
					{ f="SetText", "Sub-Heading" },
					{ f="SetDrawLayer", "ARTWORK" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, -32 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, -32 },
				}
			},
			{
				type="Button",
				name="SortButton",
				scripts = {
					OnLoad = [[
						local self = ...
						local fontString = self:GetFontString()
						local normalTexture = self:GetNormalTexture()
						local pushedTexture = self:GetPushedTexture()
						local highlightTexture = self:GetHighlightTexture()

						fontString:ClearAllPoints()
						fontString:SetPoint("LEFT", self, "LEFT", 10, 0)

						Constructor.HelperWidgetMethods.Texture.RotateTexture(normalTexture, 180)
						Constructor.HelperWidgetMethods.Texture.RotateTexture(pushedTexture, 180)
						Constructor.HelperWidgetMethods.Texture.RotateTexture(highlightTexture, 180)

						normalTexture:SetVertexColor(0, 0, 0.5, 0.75)
						pushedTexture:SetVertexColor(0, 0, 0.5, 0.75)
						highlightTexture:SetVertexColor(0.6, 0.6, 0.6, 0.1)

						self:SetPushedTextOffset(2, -2);
					]],
				},
				methods = {
					{ f="SetText", "Sort" },
					{ f="SetSize", 64, 32 },
					{ f="SetTextFontObject", "GameFontNormalLarge" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, -35 },
					{ f="SetNormalTexture", "Interface\\AddOns\\Constructor\\Test\\Art\\RoundedButton" },
					{ f="SetPushedTexture", "Interface\\AddOns\\Constructor\\Test\\Art\\RoundedButton" },
					{ f="SetHighlightTextureEx", "Interface\\AddOns\\Constructor\\Test\\Art\\RoundedButton" },
				},
			},
			{
				type="Button",
				name="SearchButton",
				scripts = {
					OnLoad = [[
						local self = ...
						local fontString = self:GetFontString()
						local normalTexture = self:GetNormalTexture()
						local pushedTexture = self:GetPushedTexture()
						local highlightTexture = self:GetHighlightTexture()

						fontString:ClearAllPoints()
						fontString:SetPoint("RIGHT", self, "RIGHT", -6, 0)

						normalTexture:SetVertexColor(0, 0, 0.5, 0.75)
						pushedTexture:SetVertexColor(0, 0, 0.5, 0.75)
						highlightTexture:SetVertexColor(0.6, 0.6, 0.6, 0.1)

						self:SetPushedTextOffset(2, -2)
					]],
				},
				methods = {
					{ f="SetSize", 80, 32 },
					{ f="SetText", "Search" },
					{ f="SetTextFontObject", "GameFontNormalLarge" },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", -20, -35 },
					{ f="SetNormalTexture", "Interface\\AddOns\\Constructor\\Test\\Art\\RoundedButton" },
					{ f="SetPushedTexture", "Interface\\AddOns\\Constructor\\Test\\Art\\RoundedButton" },
					{ f="SetHighlightTextureEx", "Interface\\AddOns\\Constructor\\Test\\Art\\RoundedButton" },
				},
			},
			{
				type="Button",
				name="CloseButton",
				scripts = {
					OnClick = [[
						local self = ...
						return self:GetParent():Hide()
					]],
					OnLoad = [[
						local self = ...
						local normalTexture = self:GetNormalTexture();
						local pushedTexture = self:GetPushedTexture();
						local highlightTexture = self:GetHighlightTexture();

						normalTexture:SetVertexColor(1,0,0);
						pushedTexture:SetVertexColor(1,0,0);

						pushedTexture:ClearAllPoints();
						pushedTexture:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2);
						pushedTexture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 2, -2);

						highlightTexture:ClearAllPoints();
						highlightTexture:SetPoint("TOPRIGHT", self:GetParent(), "TOPRIGHT");
						highlightTexture:SetPoint("BOTTOMLEFT", self:GetParent(), "TOPRIGHT", -32, -32);
					]],
				},
				methods = {
					{ f="SetSize", 20, 20 },
					{ f="SetHighlightTextureEx", 0.4, 0.4, 0.5, 0.5 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", -5, -5 },
					{ f="SetNormalTexture", "Interface\\AddOns\\Constructor\\Test\\Art\\CloseButton" },
					{ f="SetPushedTexture", "Interface\\AddOns\\Constructor\\Test\\Art\\CloseButton" },
				},
			},
			{
				type="Frame",
				name="List",
				methods = {
					{ f="EnableMouseWheel", true },
					{ f="SetPoint", "LEFT", "&parent", "LEFT", 0, 0 },
					{ f="SetPoint", "TOP", "&parent", "TOP", 0, -35 },
					{ f="SetPoint", "RIGHT", "&parent", "RIGHT", 0, 0 },
					{ f="SetPoint", "BOTTOM", "&parent", "BOTTOM", 0, 0 },
				},
				children = {
					{
						type="Texture",
						name="SliderTex",
						methods = {
							{ f="SetWidth", 20 },
							{ f="SetDrawLayer", "BACKGROUND" },
							{ f="SetTexture", 0.29, 0.31, 0.35, 0.8 },
							{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, -32 },
							{ f="SetPoint", "BOTTOMRIGHT", "&parent", "BOTTOMRIGHT", 0, 32 },
						},
					},
					{
						type="Texture",
						methods = {
							{ f="SetSize", 20, 32 },
							{ f="SetDrawLayer", "BACKGROUND" },
							{ f="SetVertexColor", 0.29, 0.31, 0.35, 0.8 },
							{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, 0 },
							{ f="SetTexture", "Interface\\AddOns\\Constructor\\Test\\Art\\TallRoundCorner" },
						},
					},
					{
						type="Texture",
						name="UpCorner",
						methods = {
							{ f="SetAllPoints", "&prev" },
							{ f="SetDrawLayer", "ARTWORK" },
							{ f="SetVertexColor", 0, 0, 0.5, 0.75 },
							{ f="SetTexture", "Interface\\AddOns\\Constructor\\Test\\Art\\TallRoundCorner" },
						},
					},
					{
						type="Button",
						name="Up",
						scripts = {
							OnLoad = [[
								local self = ...
								local normalTexture = self:GetNormalTexture();
								local pushedTexture = self:GetPushedTexture();
								local highlightTexture = self:GetHighlightTexture();

								pushedTexture:ClearAllPoints();
								pushedTexture:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1);
								pushedTexture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 1, -1);

								normalTexture:SetVertexColor(0.8, 0.6, 0, 1);
								pushedTexture:SetVertexColor(0.8, 0.6, 0, 1);

								highlightTexture:ClearAllPoints();
								highlightTexture:SetVertexColor(1, 1, 1, 0.1);
								highlightTexture:SetAllPoints(UIParent.ConstructorTest.List.UpCorner);
							]],
						},
						methods = {
							{ f="SetSize", 20, 20 },
							{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, -7 },
							{ f="SetNormalTexture", "Interface\\AddOns\\Constructor\\Test\\Art\\UpDownButton" },
							{ f="SetPushedTexture", "Interface\\AddOns\\Constructor\\Test\\Art\\UpDownButton" },
							{ f="SetHighlightTextureEx", "Interface\\AddOns\\Constructor\\Test\\Art\\TallRoundCorner" },
						}
					},
					{
						type="Texture",
						name="DownCorner",
						methods = {
							{ f="SetSize", 20, 32 },
							{ f="SetDrawLayer", "BACKGROUND" },
							{ f="SetVertexColor", 0.29, 0.31, 0.35, 0.8 },
							{ f="SetTexCoord", 0, 1, 0, 0, 1, 1, 1, 0 },
							{ f="SetPoint", "BOTTOMRIGHT", "&parent", "BOTTOMRIGHT", 0, 0 },
							{ f="SetTexture", "Interface\\AddOns\\Constructor\\Test\\Art\\TallRoundCorner" },
						},
					},
					{
						type="Button",
						name="Down",
						scripts = {
							OnLoad = [[
								local self = ...
								local normalTexture = self:GetNormalTexture();
								local pushedTexture = self:GetPushedTexture();
								local highlightTexture = self:GetHighlightTexture();

								Constructor.HelperWidgetMethods.Texture.RotateTexture(normalTexture, 180);
								Constructor.HelperWidgetMethods.Texture.RotateTexture(pushedTexture, 180);
								highlightTexture:SetTexCoord(0, 1, 0, 0, 1, 1, 1, 0);

								pushedTexture:ClearAllPoints();
								pushedTexture:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1);
								pushedTexture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 1, -1);

								normalTexture:SetVertexColor(0.8, 0.6, 0, 1);
								pushedTexture:SetVertexColor(0.8, 0.6, 0, 1);

								highlightTexture:ClearAllPoints();
								highlightTexture:SetVertexColor(1, 1, 1, 0.1);
								highlightTexture:SetAllPoints(UIParent.ConstructorTest.List.DownCorner);
							]],
						},
						methods = {
							{ f="SetSize", 20, 20 },
							{ f="SetPoint", "BOTTOMRIGHT", "&parent", "BOTTOMRIGHT", 0, 7 },
							{ f="SetNormalTexture", "Interface\\AddOns\\Constructor\\Test\\Art\\UpDownButton" },
							{ f="SetPushedTexture", "Interface\\AddOns\\Constructor\\Test\\Art\\UpDownButton" },
							{ f="SetHighlightTextureEx", "Interface\\AddOns\\Constructor\\Test\\Art\\TallRoundCorner" },
						}
					},
					{
						type="Slider",
						name="Slider",
						scripts = {
							OnLoad = [[
								local self = ...
								local thumbTexture = self:GetThumbTexture();

								thumbTexture:SetVertexColor(0.8, 0.6, 0, 1);
							]],
						},
						methods= {
							{ f="SetThumbTextureEx", "Interface\\AddOns\\Constructor\\Test\\Art\\Slider", 20, 20 },
							{ f="SetAllPoints", "&parent.SliderTex" },
							{ f="SetOrientation", "VERTICAL" },
 							{ f="SetMinMaxValues", 1, 3 },
							{ f="SetValueStep", 1 },
							{ f="SetValue", 2 },
						},
					},
					{
						type="Frame",
						name="Anchor",
						methods = {
							{ f="SetHeight", 37 },
							{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 2, -2 },
							{ f="SetPoint", "TOPRIGHT", "&parent.Up", "TOPLEFT", -2, -2 },
						}
					},
					{
						type="Button",
						name="$count",
						count=25,
						methods = {
							{ f="Show" },
							{ f="SetHeight", 17 },
							{ f="SetID", "$count" },
							{ f="SetText", "Button #$count" },
							{ f="SetPoint", "TOP", "&prev", "BOTTOM", 0, 0 },
							{ f="SetHighlightTextureEx", 0.4, 0.4, 0.5, 0.5 },
							{ f="SetTextFontObject", "GameTooltipHeaderText" },
							{ f="RegisterForClicks", "LeftButtonUp", "RightButtonUp" },
							{ f="SetPoint", "RIGHT", "&parent.Anchor", "RIGHT", 0, 0 },
						},
					},
				},
			},
		},
	},
}

ConstructorTest = Constructor(frameTemplate, UIParent)
