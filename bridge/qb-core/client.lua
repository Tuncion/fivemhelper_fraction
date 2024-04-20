-- Serverside QBCore bridge
if GetResourceState('qb-core') ~= 'started' then return end

QBCore = exports['qb-core']:GetCoreObject()

while not QBCore do
    QBCore = exports['qb-core']:GetCoreObject()
    Citizen.Wait(500)
end
Bridge.ServerFramework = 'qb-core'
Bridge.ServerFrameworkLoaded = true

-- Player Data
function Bridge.IsPlayerDataValid()
    return QBCore.Functions.GetPlayerData() ~= nil
end

function Bridge.getPlayerJob()
    if Bridge.IsPlayerDataValid() then
        return QBCore.Functions.GetPlayerData().job.name
    end
end

local SetJobFunction = function() print('ERROR - SetJobFunction not set') end
function Bridge.SetJobEvent(EventFunction)
    SetJobFunction = EventFunction
end

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    SetJobFunction(JobInfo.name)
end)
