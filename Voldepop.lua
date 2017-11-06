local MODNAME = "Voldepop"
local vp_addon = LibStub("AceAddon-3.0"):NewAddon(MODNAME, "AceConsole-3.0")

-- declare defaults to be used in the DB
local defaults = {
   profile = {
   }
}

function vp_addon:OnInitialize()
   -- Assuming the .toc says ## SavedVariables: vp_optionsDB
   vp_addon.db = LibStub("AceDB-3.0"):New("vp_optionsDB", defaults, true)
   vp_addon.player = UnitName("player")
   vp_updateScale()
   vp_options_init()
   vp_toggleMovable()
end

---------------------------------------------------------
-- Initialize Options

function vp_OptionsTable()
   if not vp_options then
      vp_options = {
         type = 'group',
         childGroups = "tab",
         get = Get,
         set = Set,
         args = {
            option1 = {
               name = "General",
               desc = "General options",
               type = "group",
               order = 0,
               args = {
                  version = {
                     order    = 11,
                     type    = "description",
                     name    = MODNAME .. " Version: " .. GetAddOnMetadata(MODNAME, "Version"),
                  },
                  spacer1 = {
                     order    = 12,
                     type    = "description",
                     name    = "\n",
                  },
                  header1 = {
                     order    = 15,
                     type    = "header",
                     name    = "Main Options",
                  },
                  enabled = {
                     order    = 21,
                     type = "toggle",
                     name = "Enable",
                     desc = "Tick to enable " .. MODNAME,
                     get    = function() return vp_addon.db.profile.vp_enable end,
                     set    = function() vp_addon.db.profile.vp_enable = not vp_addon.db.profile.vp_enable UpdateSpells() end,
                  },
                  toggleMovable = {
                     order    = 23,
                     type = "toggle",
                     name = "Move frame",
                     desc = "Tick to make frame draggable",
                     get    = function() return vp_addon.db.profile.vp_isMovable end,
                     set    = function() vp_addon.db.profile.vp_isMovable = not vp_addon.db.profile.vp_isMovable vp_toggleMovable() end,
                  },
                  scale = {
                     order    = 25,
                     type = "range",
                     name = "Scale",
                     softMin = 0.1, softMax = 1.4, step = 0.1,
                     get    = function() return vp_addon.db.profile.vp_scale end,
                     set    = function(info, value) vp_addon.db.profile.vp_scale = value vp_updateScale() end,
                  },
               },
            }
         }
      }

end
return vp_options
end

function vp_options_init()
   LibStub("AceConfig-3.0"):RegisterOptionsTable(MODNAME, vp_OptionsTable)
   vp_addon.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(MODNAME, MODNAME)
   vp_addon:RegisterChatCommand("vp", ChatCommand)
   vp_addon:RegisterChatCommand("Voldepop", ChatCommand)
end

function ChatCommand(chat_args)
   chatout = MODNAME
   
   if     chat_args == "enable" then chatout = chatout .. " [Enabled]"
   elseif chat_args == "disable" then chatout = chatout .. " [Disabled]"
   else chatout = chatout .. " use:\n" .. "- Enable\n" .. "- Disable"
   end
   print (chatout)
   
end

---------------------------------------------------------
-- Create frame and register events

local MyTextFrame = CreateFrame("frame","VoldepopFrame")
MyTextFrame:SetWidth(75)
MyTextFrame:SetHeight(30)
MyTextFrame:SetPoint("CENTER",UIParent,"CENTER",0,0)
MyTextFrame:SetFrameStrata("FULLSCREEN_DIALOG")
MyTextFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
MyTextFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
MyTextFrame:SetMovable(true)
MyTextFrame:SetUserPlaced(true)
MyTextFrame:SetFrameLevel(17)
MyTextFrame:SetScale(1)
MyTextFrame:EnableMouse(true)
MyTextFrame:RegisterForDrag("LeftButton")


local FontrString = MyTextFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
FontrString:SetPoint("CENTER")

local vp_frame = CreateFrame("Frame")

vp_frame:RegisterEvent("CHAT_MSG_ADDON")
vp_frame:RegisterEvent("CHAT_MSG_CHANNEL")
vp_frame:RegisterEvent("CHAT_MSG_SAY")
vp_frame:RegisterEvent("CURSOR_UPDATE")
---------------------------------------------------------
-- Frame scaler function

function vp_updateScale()
   MyTextFrame:SetScale(vp_addon.db.profile.vp_scale)
   return true
end

---------------------------------------------------------
-- Frame movable toggle function

function vp_toggleMovable()
   MyTextFrame:EnableMouse(vp_addon.db.profile.vp_isMovable)
   
   if (vp_addon.db.profile.vp_isMovable)
   then
      MyTextFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", --Set the background and border textures
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
            tile = true, tileSize = 16, edgeSize = 16, 
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
      })
      MyTextFrame:SetBackdropColor(0, 0, 0, 255) --Set the background colour to black
   else
      MyTextFrame:SetBackdrop({bgFile = "", --Set the background and border textures
            edgeFile = "", 
            tile = true, tileSize = 16, edgeSize = 16, 
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
      })
      MyTextFrame:SetBackdropColor(0, 0, 0, 0) --Set the background colour to black
   end
   
end


---------------------------------------------------------
-- Event script

vp_frame:SetScript("OnEvent", function(self, event, ...)
      
      if (vp_addon.db.profile.vp_enable) then else FontrString:SetText("") return end

      ---------------------------------------------------------
      -- Do work  
      vp_outText = ""
	  channelNo = GetNumDisplayChannels()
	  population = GetNumChannelMembers(channelNo)
	  
	  if (population == nil) then SetSelectedDisplayChannel(channelNo) return
	  else vp_outText = "Pop: " .. population
	  end
	  
	  --print(vp_outText)
	  FontrString:SetText(vp_outText)
      
end)