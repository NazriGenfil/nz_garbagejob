local garbageHQBlip = nil
local startJob = false

-- functions

SpawnVehicel = function()
    local CarSpawn = ESX.Game.IsSpawnPointClear(Config.vehicelSpawnLocation, 2.0)
    if CarSpawn then 
        if Config.debug then print('spawning...') end
        local Netid = lib.callback.await('nz_garbage:callback:SpawnVehicelSync', false, Config.vehicelSpawnLocation, Config.vehicelName)
    else
        lib.notify({
            title = 'Spawn point tidak kosong!',
            type = 'error'
        })
    end
end

setupBlip = function()
    if ESX.PlayerData.job.name == Config.JobName then
        garbageHQBlip = AddBlipForCoord(Config.location.x, Config.location.y, Config.location.z)
        SetBlipSprite(garbageHQBlip, 467)
        SetBlipDisplay(garbageHQBlip, 4)
        SetBlipScale(garbageHQBlip, 1.0)
        SetBlipColour(garbageHQBlip, 25)
        SetBlipAsShortRange(garbageHQBlip, false)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Garbage HQ")
        EndTextCommandSetBlipName(garbageHQBlip)
    else
        RemoveBlip(garbageHQBlip)
        garbageHQBlip = nil
    end
end

setupPed = function()
    RequestModel(Config.PedModel)
        while not HasModelLoaded(Config.PedModel) do
            Wait(0)
            print("Waiting for model to load")
        end
    local ped = CreatePed(0, Config.PedModel, Config.location.x, Config.location.y, Config.location.z - 1, Config.location.w, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_MOBILE', true, true)
    if Config.Debug then print("Spawning ped object") end
    
    exports.ox_target:addLocalEntity(ped, { {
        name = 'GarbageMainPed',
        icon = 'fa-solid fa-car-side',
        label = "Start Job",
        distance = 1.5,
        onSelect = function()
            SpawnVehicel()
        end
    } })

end

-- event handlers

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    setupPed()
    setupBlip()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
    setupBlip()
    setupPed()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
    setupBlip()
end)

RegisterNetEvent('nz_garbage:client:SyncVehicelData', function(vehicel)
    if Config.debug then print(vehicel) end
    local veh = NetToVeh(vehicel)
    SetVehicleFuelLevel(veh, 100.0)
    SetVehicleEngineOn(veh, true, true, false)
end)