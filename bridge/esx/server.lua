-- Serverside ESX bridge
if GetResourceState('es_extended') ~= 'started' then return end

ESX = exports['es_extended']:getSharedObject()

while not ESX do
    ESX = exports['es_extended']:getSharedObject()
    Citizen.Wait(500)
end
Bridge.ServerFramework = 'esx'
Bridge.ServerFrameworkLoaded = true

-- Bridge Functions

-- Nothing yet 🔨
