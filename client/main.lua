-- Variabels
local garbageHQBlip, jobBlip, pointtruck, pointdump, VehicleZone, veh = nil, nil, nil, nil, nil, nil
local startJob, InDelTruck = false, false
local trashCount = 0
-- functions

collectedtrash = function(geeky, vehicle)
    if not ESX.PlayerData.job.name == Config.JobName then return end

    local pressed = false
    local trunkcoord = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "platelight"))
    local tdistance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),trunkcoord)
    local item = 'water'
    if Config.debug then print("trunk coordinates:", truckcoords, "trunk distance", tdistance) end

    pointtruck = lib.points.new({
        coords = trunkcoord,
        distance = 10,
    })
    function pointtruck:nearby()
        DrawMarker(20, trunkcoord + vector3(0.0,0.0,0.5), 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 120, 0, 200, false, true, 2, false, false, false, false)
     
        if self.currentDistance < 2 and IsControlJustReleased(0, 38) then
            if not pressed then
                -- lib.showTextUI('[E] - Lempar sampah')
                print('inside marker', self.id)
                item = Config.itemlist[math.random(0, #Config.itemlist - 1)]
                ClearPedTasksImmediately(PlayerPedId())
                TaskPlayAnim(PlayerPedId(), 'anim@heists@narcotics@trash', 'throw_b', 1.0, -1.0,-1,2,0,0, 0,0)
                pointtruck:remove()
                lib.callback.await('nz_garbage:callback:giveReward', false, item, startJob)
                Citizen.Wait(100)
                DeleteObject(geeky)
                Citizen.Wait(3000)
                ClearPedTasksImmediately(PlayerPedId())
                trashCount = trashCount + 1
                startMission(vehicle)
                pressed = true
                if Config.Debug then print("Trash count", trashCount) end
            end
        end
    end
end

startMission = function(vehicel)
    Wait(0)
    if Config.Debug then print("Start mission function") end
    if not ESX.PlayerData.job.name == Config.JobName then return end

    if not HasAnimDictLoaded("anim@heists@narcotics@trash") then
        RequestAnimDict("anim@heists@narcotics@trash")
    end
    while not HasAnimDictLoaded("anim@heists@narcotics@trash") do
        Citizen.Wait(0)
    end

    local random = math.random(1, #Config.JobCoords)
    local coordJob = vec3(Config.JobCoords[random].x, Config.JobCoords[random].y, Config.JobCoords[random].z)
    local pressed = false
    
    if Config.debug then print(coordJob.x, coordJob.y, coordJob.z) end
    for k, v in pairs(Config.Dumpsters) do 
        -- local NewBin = GetClosestObjectOfType(x, y, coordJob.z, 100.0, GetHashKey(Config.Dumpsters[i]), false)
        local NewBin = GetClosestObjectOfType(coordJob.x, coordJob.y, coordJob.z, 100.0, GetHashKey(v), false)
        if Config.debug then print("NewBin", NewBin, v) end
        if NewBin ~= 0 or nil then 
            local dumpCoords = GetEntityCoords(NewBin)
            jobBlip = AddBlipForCoord(dumpCoords)
            SetBlipSprite(jobBlip, 420)
            SetBlipScale (jobBlip, 0.8)
            SetBlipColour(jobBlip, 25)
            SetBlipRoute(jobBlip, true)
            SetBlipRouteColour(jobBlip, 25)
            local pointdump = lib.points.new({
                coords = dumpCoords,
                distance = 10,
            })
            function pointdump:nearby()
                DrawMarker(20, dumpCoords + vector3(0.0,0.0,2.5), 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 120, 0, 200, false, true, 2, false, false, false, false)
             
                if self.currentDistance < 2 and IsControlJustReleased(0, 38) then
                    if not pressed then
                        -- lib.showTextUI('[E] - Mengambil sampah')
                        print('inside marker', self.id)
                        local geeky = CreateObject(GetHashKey("hei_prop_heist_binbag"), 0, 0, 0, true, true, true)
                        AttachEntityToEntity(geeky, playerPed, boneindex, 0.12, 0.0, 0.00, 25.0, 270.0, 180.0, true, true, false, true, 1, true)
                        TaskPlayAnim(PlayerPedId(-1), 'anim@heists@narcotics@trash', 'walk', 1.0, -1.0,-1,49,0,0, 0,0)
                        pointdump:remove()
                        RemoveBlip(jobBlip)
                        collectedtrash(geeky, vehicel, coordJob)
                        lib.hideTextUI()
                        pressed = true
                    end
                end
            end
            return
        else
            lib.hideTextUI()
            return startMission(vehicel)
        end
    end
end

SpawnVehicel = function()
    if not ESX.PlayerData.job.name == Config.JobName then return end
    local CarSpawn = ESX.Game.IsSpawnPointClear(Config.vehicelSpawnLocation, 2.0)
    if startJob then
        lib.notify({
            title = 'Error ',
            description = 'Kamu sudah melakukan pekerjaan harap selesaikan terlebih dahulu',
            type = 'error'
        })
        return
    end
    if CarSpawn then 
        if Config.debug then print('spawning...') end
        local Netid = lib.callback.await('nz_garbage:callback:SpawnVehicelSync', false, Config.vehicelSpawnLocation, Config.vehicelName)
        startJob = true
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
        startJob = false
    end
end

finishJob = function()
    if not startJob and trashCount == 0 then
        lib.notify({
            title = 'Kamu belum memulai pekerjaan',
            description = 'Harap mulai mengambil pekerjaan',
            type = 'error'
        })
        return
    end
    lib.callback.await('nz_garbage:callback:giveMoney', false, Config.moneyType, trashCount * Config.PricePerBag, startJob)
    RemoveBlip(jobBlip)
    startJob = false
    trashCount = 0
    
    ESX.Game.DeleteVehicle(veh)
    if pointdump ~= nil or pointdump ~= nil then
        pointtruck:remove()
        pointdump:remove()
    end

    lib.notify({
        title = 'Berhasil menghapus kendaraan',
        type = 'success'
    })
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
    local options = {
        {
            name =  'start_job',
            label = 'Start Job',
            icon = 'fa-solid fa-car-side',
            groups = { [Config.JobName] = 0 },
            distance = 2,
            onSelect = function()
                SpawnVehicel()
            end
        },
        {
            name = 'stop_job',
            label = 'Finish Job',
            icon = 'fa-solid fa-car-side',
            groups = { [Config.JobName] = 0 },
            distance = 2,
            onSelect = function()
                finishJob()
            end
        }
    }
    exports.ox_target:addLocalEntity(ped, options)

end

-- event handlers

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    setupPed()
    setupBlip()
    delTruck()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
    setupBlip()
    setupPed()
    delTruck()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
    setupBlip()
    delTruck()
end)

RegisterNetEvent('nz_garbage:client:SyncVehicelData', function(vehicel)
    if Config.debug then print(vehicel) end
    veh = NetToVeh(vehicel)
    SetVehicleFuelLevel(veh, 100.0)
    SetVehicleEngineOn(veh, true, true, false)
    startMission(veh)
end)