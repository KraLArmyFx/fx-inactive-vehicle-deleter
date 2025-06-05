local inactiveVehicles = {}
local sqlPlates = {}

local function Debug(message)
    if Config.DebugPrint then
        print("[fx-inactive-vehicle-deleter] " .. message)
    end
end

local function GetVehiclePlate(vehicle)
    return string.gsub(GetVehicleNumberPlateText(vehicle), "%s+", ""):upper()
end

local function DeleteVehicleSafe(vehicle)
    if DoesEntityExist(vehicle) then
        NetworkRequestControlOfEntity(vehicle)
        local attempts = 0
        while not NetworkHasControlOfEntity(vehicle) and attempts < 20 do
            Wait(100)
            attempts += 1
        end
        if NetworkHasControlOfEntity(vehicle) then
            SetEntityAsMissionEntity(vehicle, true, true)
            DeleteEntity(vehicle)
        end
    end
end

local function RefreshSQLPlates()
    if Config.UseSQLVehicleTable then
        local result = MySQL.query.await("SELECT plate FROM " .. Config.SQLVehicleTable, {})
        sqlPlates = {}
        for _, row in ipairs(result) do
            sqlPlates[row.plate:upper()] = true
        end
        Debug("Vehicle plate list updated from SQL.")
    end
end

CreateThread(function()
    if Config.UseSQLVehicleTable then
        RefreshSQLPlates()
        while true do
            Wait(300000)
            RefreshSQLPlates()
        end
    end
end)

CreateThread(function()
    while true do
        Wait(Config.InactivityCheckInterval)
        local now = os.time()
        for _, vehicle in ipairs(GetAllVehicles()) do
            if DoesEntityExist(vehicle) and not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1)) then
                local coords = GetEntityCoords(vehicle)
                local model = GetEntityModel(vehicle)
                local plate = GetVehiclePlate(vehicle)

                if Config.WhitelistModels[model] then
                    Debug(("Whitelisted vehicle: %s"):format(model))
                elseif Config.UseSQLVehicleTable and sqlPlates[plate] then
                    Debug(("Player vehicle (from DB), skipping: %s"):format(plate))
                else
                    if not inactiveVehicles[vehicle] then
                        inactiveVehicles[vehicle] = { coords = coords, lastTime = now }
                        Debug(("Tracking new vehicle: %s"):format(plate))
                    else
                        local last = inactiveVehicles[vehicle]
                        local dist = #(coords - last.coords)
                        if dist < 0.5 then
                            local idle = (now - last.lastTime) * 1000
                            if idle >= Config.InactiveTimeBeforeDelete then
                                DeleteVehicleSafe(vehicle)
                                inactiveVehicles[vehicle] = nil
                                Debug(("Deleted inactive vehicle: %s"):format(plate))
                            end
                        else
                            inactiveVehicles[vehicle] = { coords = coords, lastTime = now }
                            Debug(("Vehicle moved: %s"):format(plate))
                        end
                    end
                end
            else
                inactiveVehicles[vehicle] = nil
            end
        end
    end
end)
