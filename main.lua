local function GetVehicleName(veh)
    local modelHash = GetEntityModel(veh)
    local displayName = GetDisplayNameFromVehicleModel(modelHash)
    return GetLabelText(displayName)
end

local function UseLivery(veh)
    SetVehicleModKit(veh, 0)

    local options = {}
    local stickerCount = GetNumVehicleMods(veh, 48)
    local liveryCount  = GetVehicleLiveryCount(veh) - 1
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

    for i = 0, liveryCount do
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
        menu = 'samy_extras',
        options = options
    })
    lib.showContext("liveries_menu")
end

local function UseExtras(veh)
    if IsVehicleDamaged(veh) then
        return
    end

    local options = {}
    for extraID = 0, 20 do
        if DoesExtraExist(veh, extraID) then
            local isOn = IsVehicleExtraTurnedOn(veh, extraID)
            table.insert(options, {
                title = string.format("ID #%d", extraID),
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
        menu = 'samy_extras',
        title = string.format("Extras - %s", GetVehicleName(veh)),
        options = options
    })

    lib.showContext("extras_menu")
end

RegisterCommand("extras", function()
    local veh = cache.vehicle
    if not veh then return end
    lib.registerContext({
        id = 'samy_extras',
        title = "Car menu",
        canClose = true,
        options = {
            {
                title = "Extras",
                description = "Enable or disable extras",
                onSelect = function()
                    UseExtras(veh)
                end
            },
            {
                title = "Livery",
                description = "Enable or disable livery",
                onSelect = function()
                    UseLivery(veh)
                end
            }
        }
    })
    lib.showContext('samy_extras')
end)

exports('UseLivery', UseLivery)
exports('UseExtras', UseExtras)

