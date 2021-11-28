local frame = CreateFrame("FRAME"); -- Need a frame to respond to events
-- frame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
frame:RegisterEvent("PLAYER_LOGIN");

base_texture_path = "Interface\\AddOns\\PajBlip\\data\\"

available_textures = {
    default = "default blip texture",
    transparent_raid = "30% transparent raid members, opaque party members",
    no_party_and_raid = "completely hide party and raid members",
    transparent_party_and_raid = "30% transparent party and raid members",
    red_dot_party_and_raid = "replace party and raid members with a smaller red dot",
    red_dot_party_blue_dot_raid = "replace party and raid members with a smaller red and blue dot",
}

local function useDefaultBlipTexture()
    Minimap:SetBlipTexture("Interface\\Minimap\\ObjectIconsAtlas")
end

local function updateBlipTexture()
    if Texture == nil then
        -- User has not selected a blip texture
        return
    end

    if Texture == "default" then
        useDefaultBlipTexture()
        Texture = nil
        return
    end

    chosen_texture = available_textures[Texture]

    if chosen_texture == nil then
        -- User has chosen an invalid texture - maybe this existed before but is removed now?
        -- Reset to default

        useDefaultBlipTexture()

        print("Your chosen blip texture is not valid anymore, resetting to default.")

        Texture = nil
    end

    print("Update blip texture to " .. Texture)

    Minimap:SetBlipTexture(base_texture_path .. Texture)
end

function frame:OnEvent(event, arg1)
    if event == "PLAYER_LOGIN" then
        updateBlipTexture()
    end
end
frame:SetScript("OnEvent", frame.OnEvent);

local function split(pString, pPattern)
    local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(Table,cap)
        end
        last_end = e+1
        s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
        cap = pString:sub(last_end)
        table.insert(Table, cap)
    end
    return Table
end


local function PajBlipUsage()
    print('PajBlip usage:')
    print(' /pajblip help - show this help message')
    print(' /pajblip texture <texture_name> - select which texture to use. If no arguments are specified, print the list of available textures.')
    print(' /pajblip flush - re-set the blip texture')
end

local function PajBlipListTextures()
    if Texture ~= nil then
        print("Currently set texture: " .. Texture)
    else
        print("No texture currently set")
    end

    print("Available textures:")
    table.foreach(available_textures, function(texture_name, texture_description) print("  " .. texture_name .. " - " .. texture_description) end)
end

local function PajBlipTexture(commands, command_i)
    texture_name = commands[command_i]
    if texture_name == nil then
        PajBlipListTextures()
        return
    end

    if available_textures[texture_name] == nil then
        print("Selected texture " .. texture_name .. " is not valid")
        PajBlipListTextures()
        return
    end

    Texture = texture_name
    print("Set texture to " .. Texture)

    updateBlipTexture()
end

local function PajBlipFlush(commands, command_i)
    updateBlipTexture()
end

local function PajBlipCommands(msg, editbox)
    commands = split(msg, " ")
    command_i = 1

    if commands[command_i] == "texture" then
        PajBlipTexture(commands, command_i + 1)
        return
    end
    if commands[command_i] == "flush" then
        PajBlipFlush(commands, command_i + 1)
        return
    end

    PajBlipUsage()
end

SLASH_PAJBLIP1 = '/pajblip'

SlashCmdList["PAJBLIP"] = PajBlipCommands
