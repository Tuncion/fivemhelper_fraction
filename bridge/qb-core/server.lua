-- Serverside QBCore bridge
if GetResourceState('qb-core') ~= 'started' then return end

QBCore = exports['qb-core']:GetCoreObject()

while not QBCore do
    QBCore = exports['qb-core']:GetCoreObject()
    Citizen.Wait(500)
end
Bridge.ServerFramework = 'qb-core'
Bridge.ServerFrameworkLoaded = true

-- Bridge Functions

-- Nothing yet 🔨
