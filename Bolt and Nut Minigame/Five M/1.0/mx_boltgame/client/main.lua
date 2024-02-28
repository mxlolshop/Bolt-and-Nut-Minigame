
--[[
    + How to use (EVENT)
    + Move ui right or left, in percentage, 50% middle of the screen, without the % symbol
    x = 50

    + Move ui top or bottom, in percentage, 50% middle of the screen, without the % symbol
    y = 50

    + Speed ​​bolt, 1.0 normal, 0.5 slower, 1.5 faster, enter whatever value you want
    + Depending on the speed, it will make the minigame more difficult
    speed = 1.0

    + Nut position, creating difficulties. 1 to 4
    + 4 is the furthest, therefore more difficult.
    position = 2

    + callback = Defines whether the minigame succeeded or failed
        'SUCCESS' or 'FAILED'

    + Event usage example
    TriggerEvent("mxStartBoltGame", x, y, speed, position, function(callback)
        if callback == 'SUCCESS' then
            print(">> Bolt Game [ SUCCESS ]")
        elseif callback == 'FAILED' then
            print(">> Bolt Game [ FAILED ]")
        end
    end)
]]

callBackFunction = nil
RegisterCommand('startBoltGame', function(src, args, cmd) 
    TriggerEvent("mxStartBoltGame", args[1], args[2], args[3], args[4], function(callback)
        if callback == 'SUCCESS' then
            print(">> Bolt Game [ SUCCESS ]")
        elseif callback == 'FAILED' then
            print(">> Bolt Game [ FAILED ]")
        end
    end)
end, false)

RegisterNetEvent('mxStartBoltGame')
AddEventHandler('mxStartBoltGame', function(x, y, speed, position, callback)
    mxBoltGame(x, y, speed, position, callback)
end)

function mxBoltGame(x, y, speed, position, callback)
    Config.X = tonumber(x)
    Config.Y = tonumber(y)
    Config.SPEED = tonumber(speed)
    Config.nutPosition = tonumber(position)

    SetNuiFocus(true,true)
    SendNUIMessage({
        ui = 'open',
        NuiOpen = true,
        NameResource = GetCurrentResourceName(),
        Config = Config,
        translate = translate,
    })
    callBackFunction = callback
end

RegisterNUICallback('gameFinish', function(data, cb)
    if callBackFunction then
        if data.game then
            callBackFunction('SUCCESS')
        else
            callBackFunction('FAILED')
        end
    end
    cb('ok')
end)

RegisterNUICallback('CloseNui', function(data, cb)
    if data.game == -1 then
        if callBackFunction then
            callBackFunction('FAILED')
        end
    end

    SetNuiFocus(false, false)
    SendNUIMessage({
        ui = 'open',
        NameResource = GetCurrentResourceName(),
        NuiOpen = false,
    })
    cb('ok')
end)