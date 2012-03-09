--[[
	WARNING: This is a generated file.
	If you wish to perform or update localizations, please go to our Localizer website at:
	http://localizer.norganna.org/

	AddOn: AucDb
	Revision: $Id$
	Version: <%version%> (<%codename%>)

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
		You have an implicit licence to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

AucDbLocalizations = {

	enUS = {

		-- Section: Help
		["AucDbAnswer"]	= "AucDb is an extension module AddOn for the Auctioneer AddOn. It provides in-game access to the price data collected by the online database.";
		["AucDbHelp"]	= "What is the AucDb AddOn?";
		["AuctioneerDbAnswer"]	= "AuctioneerDb (http://auctioneerdb.com) is an online resource that allows collaboration between the many auctioners in World of Warcraft™ by letting people upload their data from the game and download new data to the game.";
		["AuctioneerDbHelp"]	= "What is AuctioneerDb?";
		["UpdatingAnswer"]	= "Simply regularly download the BaseData file from the AuctioneerDb (http://auctioneerdb.com) website into your Interface/AddOns/Auc-Db folder, and you will have the latest data available in your game.\n";
		["UpdatingHelp"]	= "How do I keep my database updated?\n";

		-- Section: HelpTooltip
		["DisableAgeTip"]	= "The item tooltip will stop displaying stats when data is more than this old.";
		["MarketOptionTip"]	= "Allows AucDb statistics to contribute to the market value.";
		["MinSeenTip"]	= "The minimum seen count, below which AucDb will not return stats for an item.";
		["PreferStatTip"]	= "The statistic that AucDb will use to base it's returned valuation price.";
		["ShowOptionTip"]	= "Enables the display of AucDb statistics in item tooltips.";
		["StatOptionTip"]	= "Causes AucDb to provide statistics to other modules as Stat:AucDb.";
		["WarnAgeTip"]	= "The item tooltip will display a warning when data is getting more than this old.";

		-- Section: Interface
		["DisableAge"]	= "Disable when older than: %d days";
		["MarketOption"]	= "Contributes to market price value";
		["MinSeen"]	= "Minimum seen: %d";
		["PreferEither"]	= "Realm, then Global";
		["PreferGlobal"]	= "Global data";
		["PreferRealm"]	= "Realm data";
		["PreferStat"]	= "Prefer to use:";
		["SetupAucDb"]	= "AucDb configuration";
		["ShowOption"]	= "Show AucDb stats in tooltip";
		["StatOption"]	= "Provide price value data";
		["WarnAge"]	= "Warn when older than: %d days";

		-- Section: Tooltip
		["AucDbNoseen"]	= "AucDb: No data.";
		["AucDbPrices"]	= "AucDb: Seen %d times.";
		["GettingOld"]	= "AucDb %d days old. Please update.";
		["Label_average"]	= "average";
		["Label_deviation"]	= "deviation";
		["Label_global"]	= "Global";
		["Label_maximum"]	= "maximum";
		["Label_minimum"]	= "minimum";
		["Label_realm"]	= "Realm";
		["OutOfDate"]	= "AucDb %d days old. Disabled.";
		["PriceLabel"]	= "%s %s buyout price";
		["SaleLabel"]	= "%s %s sale price";

	};

	ruRU = {

		-- Section: Tooltip
		["AucDbNoseen"]	= "AucDb: Нет данных";
		["AucDbPrices"]	= "AucDb: Встречен %d раз.";
		["GettingOld"]	= "AucDb %d-дневной давности. Обновите, пожалуйста.";
		["Label_average"]	= "средняя";
		["Label_deviation"]	= "отклонение";
		["Label_global"]	= "Глобально -";
		["Label_maximum"]	= "максимальная";
		["Label_minimum"]	= "минимальная";
		["Label_realm"]	= "Игровой мир -";
		["OutOfDate"]	= "AucDb %d-дневной давности. Выключен.";
		["PriceLabel"]	= "%s %s цена покупки";
		["SaleLabel"]	= "%s %s цена продажи";

	};

}