local function GetVehicleName(veh)
    local modelHash = GetEntityModel(veh)
    local displayName = GetDisplayNameFromVehicleModel(modelHash)
    return GetLabelText(displayName)
end

local function UseLivery()
    local veh = cache.vehicle
    if not veh then return end

    SetVehicleModKit(veh, 0)

    local options = {}
    local stickerCount = GetNumVehicleMods(veh, 48)
    local liveryCount  = GetVehicleLiveryCount(veh)
    local currentSticker = GetVehicleMod(veh, 48)
    local currentLivery  = GetVehicleLivery(veh)
    
    for i = 0, stickerCount - 1 do
        local label = GetLabelText(GetModTextLabel(veh, 48, i)) or "Null"
        local selected = currentSticker == i

        table.insert(options, {
            title = string.format("ID #%s - %s", i, label),
            icon = selected and "toggle-on" or "toggle-off",
            onSelect = function()
                SetVehicleMod(veh, 48, i)
                UseLivery()
            end
        })
    end

    for i = 0, liveryCount - 1 do
        local label = GetLabelText(GetLiveryName(veh, i)) or "Null"
        local selected = currentLivery == i

        table.insert(options, {
            title = string.format("ID #%s - %s", i, label),
            icon = selected and "toggle-on" or "toggle-off",
            onSelect = function()
                SetVehicleLivery(veh, i)
                UseLivery()
            end
        })
    end
    lib.registerContext({
        id = "liveries_menu",
        title = string.format("Liveries - %s", GetVehicleName(veh)),
        options = options
    })
    lib.showContext("liveries_menu")
end

local function UseExtras()
    local veh = cache.vehicle
    if not veh then return end
    if IsVehicleDamaged(veh) then
        return
    end

    local options = {}
    for extraID = 0, 20 do
        if DoesExtraExist(veh, extraID) then
            local isOn = IsVehicleExtraTurnedOn(veh, extraID)
            table.insert(options, {
                title = string.format("Toggle Extra ID #%d", extraID),
                icon = isOn and "toggle-on" or "toggle-off",
                onSelect = function()
                    SetVehicleExtra(veh, extraID, isOn and 1 or 0)
                    UseExtras()
                end
            })
        end
    end
    if #options == 0 then return end
    lib.registerContext({
        id = "extras_menu",
        title = string.format("Extras - %s", GetVehicleName(veh)),
        options = options
    })

    lib.showContext("extras_menu")
end

RegisterCommand("vehmenu", function()
    local playerPed = cache.ped

    lib.registerContext({
        id = 'vehmenu',
        title = "Car menu",
        canClose = true,
        options = {
            {
                title = "Extras",
                description = "Enable or disable extras",
                onSelect = function()
                    UseExtras()
                end
            },
            {
                title = "Livery",
                description = "Enable or disable livery",
                onSelect = function()
                    UseLivery()
                end
            }
        }
    })
    lib.showContext('vehmenu')
end)

exports('UseLivery', UseLivery)
exports('UseExtras', UseExtras)