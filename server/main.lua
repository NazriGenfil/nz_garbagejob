math = lib.math
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