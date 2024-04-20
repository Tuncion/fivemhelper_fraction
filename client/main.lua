local Locales = Config.Translation[Config.Language]

if not Locales then
	print(('[^1FiveM-Helper^7] ^1ERROR: ^7The language ^3%s^7 does not exist in the configuration file.'):format(Config.Language))
	return
end

-- Create Blips
local BlipList = {}
Citizen.CreateThread(function()
	RefreshBlips()
end)

-- Change Blips when the job changes
Bridge.SetJobEvent(function(NewJob)
	RefreshBlips(NewJob)
end)

function RefreshBlips(NewJob)
	local PlayerJob = NewJob or Bridge.getPlayerJob()

	-- Remove all blips
	for k, v in pairs(BlipList) do
		RemoveFractionBlip(v)
	end

	-- Stamp Clocks
	for k, v in pairs(Config.StampClocks) do
		if PlayerJob == v.job then
			BlipID = CreateFractionBlip(v.blip.label, v.coords, 0.7, v.blip.sprite, v.blip.color)
			table.insert(BlipList, BlipID)
		end
	end
end

-- Variables
local IsInteractionActive = false
local IsMenuOpen = false
local IsStampCooldownActive = false

-- Interaction
Citizen.CreateThread(function()
	local sleep = 1000
	while true do
		local PlayerPos = GetEntityCoords(cache.ped)

		-- All Stamp Clocks
		for k, v in pairs(Config.StampClocks) do
			if not IsInteractionActive or (v.coords == IsInteractionActive.coords) then
				local Distance = #(PlayerPos - v.coords)

				if Distance <= 2.0 then
					-- Check if the player is in the job
					if Bridge.getPlayerJob() == v.job then
						lib.showTextUI(Locales.stampclock.interaction,
							{
								position = "right-center",
								icon = 'stopwatch',
								iconAnimation = 'bounce',
								style = {
									borderRadius = 5,
									backgroundColor = '#ffa600',
									color = 'white'
								}
							}
						)
						IsInteractionActive = v
						IsInteractionActive.type = 'stampclock'
						sleep = 250
					end
				else
					if IsInteractionActive then
						lib.hideTextUI()
						sleep = 1000
						IsInteractionActive = false
					end
				end
			end
		end

		Citizen.Wait(sleep)
	end
end)

-- Open the stamp clock
RegisterKeyMapping('OpenStampClock', 'Open the stamp clock', 'keyboard', 'E')
RegisterCommand('OpenStampClock', function()
	if IsInteractionActive then
		if IsInteractionActive.type == 'stampclock' then
			IsMenuOpen = true

			local LastStamp = lib.callback.await('fivemhelper_fraction:server:getLastStamp', false, { fractionId = IsInteractionActive.id })

			if LastStamp then
				local LastStampType = LastStamp.stampType

				-- Register Menu Context
				lib.registerContext({
					id = 'fivemhelper_stampclock',
					title = Locales.stampclock.contextMenuTitle,
					options = {
						{
							title = Locales.stampclock.contextMenuLastStampTitle:format(Locales.stampclock.contextMenuLastStampTypes[LastStampType]),
							readOnly = true,
							iconColor = LastStampType == 'IN' and '#00E785' or '#F44600',
							icon = 'chart-simple',
						},

						{
							title = Locales.stampclock.contextMenuPreviousStampsTitle,
							description = Locales.stampclock.contextMenuPreviousStampsDescription,
							icon = 'clock',
							menu = 'fivemhelper_stampclock_previousstamps',
						},

						{
							title = Locales.stampclock.contextMenuStampInTitle,
							description = Locales.stampclock.contextMenuStampInDescription,
							iconColor = '#00E785',
							icon = 'stopwatch',
							onSelect = function()
								if IsStampCooldownActive then
									Config.Notify(Locales.stampclock.notifyStampTitle['IN'], Locales.stampclock.notifyCooldownStamp, 'error')
									return
								end
								local StampResponse = lib.callback.await('fivemhelper_fraction:server:stamp', false, { fractionId = IsInteractionActive.id, type = 'IN' })
								if StampResponse?.status == 200 then
									Config.Notify(Locales.stampclock.notifyStampTitle['IN'], Locales.stampclock.notifySuccessStamp, 'success')
								else
									Config.Notify(Locales.stampclock.notifyStampTitle['IN'], Locales.stampclock.notifyFailedStamp, 'error')
								end

								-- Stamp Cooldown
								IsStampCooldownActive = true
								Citizen.SetTimeout(5000, function()
									IsStampCooldownActive = false
								end)
							end
						},

						{
							title = Locales.stampclock.contextMenuStampOutTitle,
							description = Locales.stampclock.contextMenuStampOutDescription,
							iconColor = '#F44600',
							icon = 'stopwatch',
							onSelect = function()
								if IsStampCooldownActive then
									Config.Notify(Locales.stampclock.notifyStampTitle['OUT'], Locales.stampclock.notifyCooldownStamp, 'error')
									return
								end
								local StampResponse = lib.callback.await('fivemhelper_fraction:server:stamp', false, { fractionId = IsInteractionActive.id, type = 'OUT' })
								if StampResponse?.status == 200 then
									Config.Notify(Locales.stampclock.notifyStampTitle['OUT'], Locales.stampclock.notifySuccessStamp, 'success')
								else
									Config.Notify(Locales.stampclock.notifyStampTitle['OUT'], Locales.stampclock.notifyFailedStamp, 'error')
								end

								-- Stamp Cooldown
								IsStampCooldownActive = true
								Citizen.SetTimeout(5000, function()
									IsStampCooldownActive = false
								end)
							end
						}
					}
				})

				-- Previous Stamps Context
				local PreviousStamps = lib.callback.await('fivemhelper_fraction:server:getPreviousStamps', false, { fractionId = IsInteractionActive.id })
				local PreviousStampsList = {}

				for k, v in pairs(PreviousStamps) do
					if v.stampType == 'IN' then
						table.insert(PreviousStampsList, {
							title = ('[%s] %s'):format(v.id, Locales.stampclock.contextMenuLastStampTypes[v.stampType]),
							description = v.stampTime,
							iconColor = '#00E785',
							icon = 'stopwatch',
							readOnly = true,
						})
					else
						table.insert(PreviousStampsList, {
							title = ('[%s] %s'):format(v.id, Locales.stampclock.contextMenuLastStampTypes[v.stampType]),
							description = v.stampTime,
							iconColor = '#F44600',
							icon = 'stopwatch',
							readOnly = true,
						})
					end
				end

				if #PreviousStampsList <= 0 then
					table.insert(PreviousStampsList, {
						title = Locales.stampclock.contextMenuPreviousMenuEmpty,
						iconColor = '#F44600',
						icon = 'stopwatch',
						readOnly = true,
					})
				end

				lib.registerContext({
					id = 'fivemhelper_stampclock_previousstamps',
					title = Locales.stampclock.contextMenuPreviousMenuTitle,
					options = PreviousStampsList
				})

				-- Show the context
				lib.showContext('fivemhelper_stampclock')
			else
				print(('[^1FiveM-Helper^7] ^1ERROR: ^7Failed to get the last stamp for the player^7.'))
			end
		end
	end
end, false)

--- Creates a blip on the map with the specified parameters.
--- @param DisplayName The name to be displayed for the blip.
--- @param BlipCoords The coordinates where the blip should be placed.
--- @param BlipScale The scale of the blip.
--- @param BlipSprite The sprite of the blip.
--- @param BlipColor The color of the blip.
--- @param BlipDisplay (optional) The display mode of the blip. Defaults to 4.
--- @param BlipShortRange (optional) Whether the blip should only be visible at short range. Defaults to true.
--- @return NewBlip The handle of the created blip.
function CreateFractionBlip(DisplayName, BlipCoords, BlipScale, BlipSprite, BlipColor, BlipDisplay, BlipShortRange)
	local BlipDisplay = BlipDisplay or 4
	local BlipShortRange = BlipShortRange
	if not BlipShortRange then BlipShortRange = true end

	local NewBlip = AddBlipForCoord(BlipCoords)
	SetBlipScale(NewBlip, BlipScale)
	SetBlipSprite(NewBlip, BlipSprite)
	SetBlipColour(NewBlip, BlipColor)
	SetBlipDisplay(NewBlip, BlipDisplay)
	SetBlipAsShortRange(NewBlip, BlipShortRange)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(DisplayName)
	EndTextCommandSetBlipName(NewBlip)

	return NewBlip
end

--- Removes a blip from the game world.
--- @param BlipID number The ID of the blip to remove.
--- @return boolean True if the blip was successfully removed, false otherwise.
function RemoveFractionBlip(BlipID)
	return RemoveBlip(BlipID)
end

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then return end
	if IsInteractionActive then lib.hideTextUI() end
	if IsMenuOpen then lib.hideMenu() end
end)
