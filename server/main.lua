local math = lib.math
lib.callback.register('nz_garbage:callback:SpawnVehicelSync', function(source, coords, vehname)
    local src = source
    if Config.debug then print(coords, coords.xyz, coords.w) end
    local Properties = {plate = 'GARBAGE '.. math.random(100, 999)} -- Sets the vehicle Properties, set to nil or {} for no properties to be set
    ESX.OneSync.SpawnVehicle(vehname, coords.xyz, coords.w, Properties, function(NetworkId)
        Wait(100) -- While not needed, it is best to wait a few milliseconds to ensure the vehicle is available
        local Vehicle = NetworkGetEntityFromNetworkId(NetworkId) -- returns the vehicle handle, from the NetworkId.
        -- NetworkId is sent over, since then it can also be sent to a client for them to use, vehicle handles cannot.
        local Exists = DoesEntityExist(Vehicle) -- returns true/false depending on if the vehicle exists.
        if Config.debug then print(Exists and 'Successfully Spawned Vehicle! '..NetworkId or 'Failed to Spawn Vehicle!') end
        TriggerClientEvent('nz_garbage:client:SyncVehicelData', src, NetworkId)
    end)
end)

lib.callback.register('nz_garbage:callback:giveReward', function(source, item, status)
    if not status then return end

    if Config.debug then print(item, status) end
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if exports.ox_inventory:CanCarryItem(src, item, Config.amountToGive) then
        local success, response = exports.ox_inventory:AddItem(src, item, Config.amountToGive)
        if not success then
            lib.notify({
                title = 'Terjadi masalah',
                description = 'Respon Code : '..response,
                type = 'error'
            })
            return 406
        end
    else
        lib.notify({
            title = 'Tas kamu terlalu penuh',
            description = 'Harap kosongkan tas kamu',
            type = 'error'
        })
        return 406
    end

    return 200
end)

lib.callback.register('nz_garbage:callback:giveMoney', function(source, tipe, amount, status)
    if not status then return end

    if Config.debug then print(tipe, amount, status) end
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.addAccountMoney(tipe, amount)
    lib.notify({
        title = 'Slip gaji',
        description = 'Berhasil memberikan kamu slip gaji',
        type = 'success'
    })
    return 200
end)
  
ESX.RegisterCommand({'+deletetrash'}, 'user', function(xPlayer, args, showError)
    print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
    TriggerClientEvent('nz_garbage:client:deletvehicel', xPlayer.source)
end, false, {help = 'untuk garbage job'})
RegisterKeyMapping('+deletetrash', 'Grabage Job', 'keyboard', 'e')