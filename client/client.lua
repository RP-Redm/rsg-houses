local RSGCore = exports['rsg-core']:GetCoreObject()

-- estate agent prompts
Citizen.CreateThread(function()
    for _, v in pairs(Config.EstateAgents) do
        exports['rsg-core']:createPrompt(v.prompt, v.coords, RSGCore.Shared.Keybinds['J'], 'Talk to ' .. v.name, {
            type = 'client',
            event = 'rsg-houses:client:agentmenu',
            args = { v.location },
        })
        if v.showblip == true then
            local AgentBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.coords)
            SetBlipSprite(AgentBlip, GetHashKey(Config.Blip.blipSprite), true)
            SetBlipScale(AgentBlip, Config.Blip.blipScale)
            Citizen.InvokeNative(0x9CB1A1623062F402, AgentBlip, Config.Blip.blipName)
        end
    end
end)

-- add map blips
Citizen.CreateThread(function()
    for _, v in pairs(Config.Houses) do
        if v.showblip == true then
            local HouseBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.blipcoords)
            SetBlipSprite(HouseBlip, `blip_proc_home`, true)
            SetBlipScale(HouseBlip, 0.2)
            Citizen.InvokeNative(0x9CB1A1623062F402, HouseBlip, v.name)
        end
    end
end)

-- agent menu
RegisterNetEvent('rsg-houses:client:agentmenu', function(location)
    exports['rsg-menu']:openMenu({
        {
            header = 'Estate Agent',
            isMenuHeader = true,
        },
        {
            header = 'Buy Property',
            txt = '',
            icon = "fas fa-home",
            params = {
                event = 'rsg-houses:client:buymenu',
                isServer = false,
                args = { agentlocation = location },
            }
        },
        {
            header = 'Sell Property',
            txt = '',
            icon = "fas fa-home",
            params = {
                event = 'rsg-houses:client:sellmenu',
                isServer = false,
                args = { agentlocation = location },
            }
        },
        {
            header = 'Close Menu',
            txt = '',
            params = {
                event = 'rsg-menu:closeMenu',
            }
        },
    })
end)

-- buy house menu
RegisterNetEvent('rsg-houses:client:buymenu', function(data)
    local GetHouseInfo = {
        {
            header = 'Buy House',
            isMenuHeader = true,
            icon = "fas fa-home",
        },
    }
    RSGCore.Functions.TriggerCallback('rsg-houses:server:GetHouseInfo', function(cb)
        for _, v in pairs(cb) do
            local agent = v.agent
            local houseid = v.houseid
            local citizenid = v.citizenid
            local owned = v.owned
            local price = v.price
            if agent == data.agentlocation and owned == 0 then
                GetHouseInfo[#GetHouseInfo + 1] = {
                    header = v.houseid,
                    txt = 'Price $'..v.price..' : Land Tax $'..Config.LandTax,
                    icon = "fas fa-home",
                    params = {
                        event = 'rsg-houses:server:buyhouse',
                        args = { 
                            house = v.houseid,
                            price = v.price
                        },
                        isServer = true,
                    }
                }
            end
        end
        exports['rsg-menu']:openMenu(GetHouseInfo)
    end)
end)

-- sell house menu
RegisterNetEvent('rsg-houses:client:sellmenu', function(data)
    local GetOwnedHouseInfo = {
        {
            header = 'Sell House',
            isMenuHeader = true,
            icon = "fas fa-home",
        },
    }
    RSGCore.Functions.TriggerCallback('rsg-houses:server:GetOwnedHouseInfo', function(cb)
        for _, v in pairs(cb) do
            local agent = v.agent
            local houseid = v.houseid
            local citizenid = v.citizenid
            local owned = v.owned
            local sellprice = (v.price * Config.SellBack)
            if agent == data.agentlocation and owned == 1 then
                GetOwnedHouseInfo[#GetOwnedHouseInfo + 1] = {
                    header = v.houseid,
                    txt = 'Sell Price $'..sellprice,
                    icon = "fas fa-home",
                    params = {
                        event = 'rsg-houses:server:sellhouse',
                        args = { 
                            house = v.houseid,
                            price = sellprice
                        },
                        isServer = true,
                    }
                }
            end
        end
        exports['rsg-menu']:openMenu(GetOwnedHouseInfo)
    end)
end)

--------------------------------------------------------------------------------------------------

-- lock doors and set newtworked
Citizen.CreateThread(function()
    for k,v in pairs(Config.HouseDoors) do
        Citizen.InvokeNative(0xD99229FE93B46286, v.doorid, 1,1,0,0,0,0) -- AddDoorToSystemNew
        Citizen.InvokeNative(0x51D99497ABF3F451, v.doorid) -- SetDoorNetworked
        DoorSystemSetDoorState(v.doorid, 1)
    end
end)

-- house door prompts
Citizen.CreateThread(function()
    for houses, v in pairs(Config.HouseDoors) do
        exports['rsg-core']:createPrompt(v.doorid, v.doorcoords, RSGCore.Shared.Keybinds['U'], 'Unlock ' .. v.name, {
            type = 'client',
            event = 'rsg-houses:client:toggledoor',
            args = { v.doorid, v.houseid },
        })
    end
end)

-- house door lock / unlock animation
local function unlockAnimation()
    local dict = "script_common@jail_cell@unlock@key"
    
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(10)
        end
    end

    local ped = PlayerPedId()

    local prop = CreateObject("P_KEY02X", GetEntityCoords(ped) + vec3(0, 0, 0.2), true, true, true)
    local boneIndex = GetEntityBoneIndexByName(ped, "SKEL_R_Finger12")

    TaskPlayAnim(ped, "script_common@jail_cell@unlock@key", "action", 8.0, -8.0, 2500, 31, 0, true, 0, false, 0, false)
    Wait(750)
    AttachEntityToEntity(prop, ped, boneIndex, 0.02, 0.0120, -0.00850, 0.024, -160.0, 200.0, true, true, false, true, 1, true)

    while IsEntityPlayingAnim(ped, "script_common@jail_cell@unlock@key", "action", 3) do
        Wait(100)
    end

    DeleteObject(prop)
end

-- lock / unlock door
RegisterNetEvent('rsg-houses:client:toggledoor', function(door, house)
    RSGCore.Functions.TriggerCallback('rsg-houses:server:GetHouseKeys', function(results)
        for _, v in pairs(results) do
            local playercitizenid = RSGCore.Functions.GetPlayerData().citizenid
            local resultcitizenid = v.citizenid
            local resulthouseid = v.houseid
            if resultcitizenid == playercitizenid and resulthouseid == house then
                local doorstate = DoorSystemGetDoorState(door)
                if doorstate == 1 then
                    unlockAnimation()
                    DoorSystemSetDoorState(door, 0)
                    RSGCore.Functions.Notify('unlocked', 'primary')
                end
                if doorstate == 0 then
                    unlockAnimation()
                    DoorSystemSetDoorState(door, 1)
                    RSGCore.Functions.Notify('locked', 'primary')
                end
            end
        end
    end)
end)

--------------------------------------------------------------------------------------------------

-- house menu prompt
Citizen.CreateThread(function()
    for _, v in pairs(Config.Houses) do
        exports['rsg-core']:createPrompt(v.houseprompt, v.menucoords, RSGCore.Shared.Keybinds['J'], 'Open House Menu', {
            type = 'client',
            event = 'rsg-houses:client:housemenu',
            args = { v.houseid },
        })
    end
end)

-- house menu
RegisterNetEvent('rsg-houses:client:housemenu', function(houseid)
    RSGCore.Functions.TriggerCallback('rsg-houses:server:GetHouseKeys', function(results)
        for _, v in pairs(results) do
            local playercitizenid = RSGCore.Functions.GetPlayerData().citizenid
            local resultcitizenid = v.citizenid
            local resulthouseid = v.houseid
            if resultcitizenid == playercitizenid and resulthouseid == houseid then
                exports['rsg-menu']:openMenu({
                    {
                        header = 'House Menu',
                        isMenuHeader = true,
                        icon = "fas fa-home",
                    },
                    {
                        header = 'Open Storage',
                        txt = '',
                        icon = 'fas fa-box',
                        params = {
                            event = 'rsg-houses:client:storage',
                            isServer = false,
                            args = { house = houseid },
                        }
                    },
                    {
                        header = 'Outfits',
                        txt = '',
                        icon = 'fas fa-hat-cowboy-side',
                        params = {
                            event = 'rsg-clothes:OpenOutfits',
                            isServer = false,
                            args = {},
                        }
                    },
                    {
                        header = 'Close Menu',
                        txt = '',
                        params = {
                            event = 'rsg-menu:closeMenu',
                        }
                    },
                })
            else
                RSGCore.Functions.Notify('You don\'t have access!', 'error')
            end
        end
    end)
end)

--------------------------------------------------------------------------------------------------

-- house storage
RegisterNetEvent('rsg-houses:client:storage', function(data)
    TriggerServerEvent("inventory:server:OpenInventory", "stash", data.house, {
        maxweight = Config.StorageMaxWeight,
        slots = Config.StorageMaxSlots,
    })
    TriggerEvent("inventory:client:SetCurrentStash", data.house)
end)

--------------------------------------------------------------------------------------------------

--[[
    0 = DOORSTATE_UNLOCKED,
    1 = DOORSTATE_LOCKED_UNBREAKABLE,
    2 = DOORSTATE_LOCKED_BREAKABLE,
    3 = DOORSTATE_HOLD_OPEN_POSITIVE,
    4 = DOORSTATE_HOLD_OPEN_NEGATIVE
--]]
