-- Serverside ESX bridge
if GetResourceState('es_extended') ~= 'started' then return end

ESX = exports['es_extended']:getSharedObject()

while not ESX do
    ESX = exports['es_extended']:getSharedObject()
    Citizen.Wait(500)
end
Bridge.ServerFramework = 'esx'
Bridge.ServerFrameworkLoaded = true

-- Player Data
function Bridge.IsPlayerDataValid()
    return ESX.GetPlayerData() ~= nil
end

function Bridge.getPlayerJob()
    if Bridge.IsPlayerDataValid() then
        return ESX.GetPlayerData().job.name
    end
end

local SetJobFunction = function() print('ERROR - SetJobFunction not set') end
function Bridge.SetJobEvent(EventFunction)
    SetJobFunction = EventFunction
end

RegisterNetEvent('esx:setJob', function(job, lastJob)
    SetJobFunction(job.name)
end)
