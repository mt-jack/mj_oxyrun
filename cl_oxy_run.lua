local QBCore = exports['qb-core']:GetCoreObject()

local startedrun = false
local candeliver = false
local oxydelivered = 0
local candropoff = false
local hasdropoff = false
local lastdelivery = 1
local inUse = true
local cooldown = math.random(900000,1200000)
local stealingPed = nil
local getRobbed = math.random(1, 100)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(cooldown)
	inUse = false
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(10000)
		inUse = false
	end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(cooldown)
		if inUse then
			inUse = false
		end
    end
end)

local function transaction(deliveryped)
	exports['qb-target']:AddTargetEntity(deliveryped, {
		options = {
			{
				type = "client",
				event = "mtj_oxyrun:client:check",
				icon = 'fas fa-capsules',
				label = 'Deliver Oxy',
				args = deliveryped,
			}
		},
		distance = 2.0
	})
end

local function oxydeliverblip()
	dropoffblip = AddBlipForCoord(dropoffcoords.x, dropoffcoords.y, dropoffcoords.z)
	SetBlipSprite(dropoffblip, 51)
	SetBlipColour(dropoffblip, 0)
	SetBlipScale(dropoffblip, 0.8)
	SetBlipRoute(dropoffblip, true)
	SetBlipRouteColour(dropoffblip, 11)
    SetBlipAsShortRange(dropoffblip, false)
end

local function oxydeliveryped()
	local oxyped = Config.DropOffPeds[math.random(#Config.DropOffPeds)]
	RequestModel(oxyped)
	while not HasModelLoaded(oxyped) do 
		Wait(10) 
	end
	local dropoffped = CreatePed(0, oxyped, dropoffcoords.x, dropoffcoords.y, dropoffcoords.z-1.0, dropoffcoords.w, false, false)
	FreezeEntityPosition(dropoffped, true)
	SetEntityInvincible(dropoffped, true)
	SetBlockingOfNonTemporaryEvents(dropoffped, true)
	transaction(dropoffped)
end

local function DeleteOxyPed(pedhash)
	FreezeEntityPosition(pedhash, false)
	SetPedKeepTask(pedhash, false)
	TaskSetBlockingOfNonTemporaryEvents(pedhash, false)
	ClearPedTasks(pedhash)
	TaskWanderStandard(pedhash, 10.0, 10)
	SetPedAsNoLongerNeeded(pedhash)
	Wait(5000)
	DeletePed(pedhash)
end

local function fetchlocation()
	local curk = Config.DropOffLocation[math.random(#Config.DropOffLocation)]
	if curk ~= lastdelivery then 
		return curk
	else 
		return fetchlocation()
	end
end

local function CreateRun()
	if oxydelivered == Config.MaxRuns then
		QBCore.Functions.Notify("You finished the Delivery", "success", 5000)
		oxydelivered = 0
		startedrun = false
		candeliver = false
		candropoff = false
		hasdropoff = false
		TriggerServerEvent("mtj_oxyrun:server:finishedrun")
		RemoveBlip(dropoffblip)
		DeleteOxyPed()
	else
		oxydelivered = oxydelivered + 1
		dropoffcoords = fetchlocation()
		lastdelivery = dropoffcoords
		oxydeliverblip()
		oxydeliveryped()
		QBCore.Functions.Notify("Proceed to the next drop off location", "success", 5000)
	end
end

RegisterNetEvent("mtj_oxyruns:client:StartOxy", function()
	if oxydelivered <= Config.MaxRuns then
		candeliver = true
		if startedrun == true then
			candeliver = false
			QBCore.Functions.Notify("You have already started a run.", "error", 3000) 
		elseif startedrun == false then
			hasdropoff = false
			CreateRun()
			startedrun = true
		end
	end
end)

RegisterNetEvent("mtj_oxyrun:client:check", function(data)
	local ped = PlayerPedId()
	if candeliver then
		exports['qb-target']:RemoveTargetEntity(data.args)
		FreezeEntityPosition(data.args, false)
		TaskTurnPedToFaceEntity(data.args, ped, 1.0)
		TaskTurnPedToFaceEntity(ped, data.args, 1.0)
		Wait(1500)
		PlayAmbientSpeech1(data.args, "Generic_Hi", "Speech_Params_Force")
		Wait(1000)

		RequestAnimDict("mp_safehouselost@")
		while not HasAnimDictLoaded("mp_safehouselost@") do Wait(10) end
		TaskPlayAnim(ped, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
		Wait(3100)

		if getRobbed > 5 and getRobbed < 100 then
			exports['qb-target']:RemoveTargetEntity(data.args)
			SetPedKeepTask(data.args, false)
			TaskSetBlockingOfNonTemporaryEvents(data.args, false)
			SetEntityInvincible(data.args, false)
			ClearPedTasks(data.args)
			local moveto = GetEntityCoords(PlayerPedId())
			local movetoCoords = {x = moveto.x + math.random(100, 500), y = moveto.y + math.random(100, 500), z = moveto.z, }
			TaskGoStraightToCoord(data.args, movetoCoords.x, movetoCoords.y, movetoCoords.z, 70.0, -1, 0.0, 0.0)
			QBCore.Functions.Notify("Go get your delivery back", "primary", 5000)

			ClearPedTasksImmediately(ped)

			stealingPed = data.args

			while stealingPed do
				if IsEntityDead(stealingPed) then
					local playerPed = PlayerPedId()
					local pos = GetEntityCoords(playerPed)
					local pedpos = GetEntityCoords(stealingPed)
					if #(pos - pedpos) < 1.5 then
						if not textDrawn then
							textDrawn = true
							exports['qb-core']:DrawText("[E] pick_up_button")
						end
						if IsControlJustReleased(0, 38) then
							oxydelivered = oxydelivered - 1
							exports['qb-core']:KeyPressed()
							textDrawn = false
							RequestAnimDict("pickup_object")
							while not HasAnimDictLoaded("pickup_object") do
								Wait(0)
							end
							TaskPlayAnim(playerPed, "pickup_object", "pickup_low", 8.0, -8.0, -1, 1, 0, false, false, false)
							Wait(2000)
							ClearPedTasks(playerPed)
							
							stealingPed = nil
							candeliver = false
							hasdropoff = false
							RemoveBlip(dropoffblip)
							QBCore.Functions.Notify("Wait for Next delivery", "primary", 5000)
							startedrun = false
							DeleteOxyPed(data.args)
							Wait(Config.TBR)
							TriggerEvent("mtj_oxyruns:client:StartOxy")
						end
					end
				else
					local playerPed = PlayerPedId()
					local pos = GetEntityCoords(playerPed)
					local pedpos = GetEntityCoords(stealingPed)
					if #(pos - pedpos) > 20 then
						stealingPed = nil
						candeliver = false
						hasdropoff = false
						RemoveBlip(dropoffblip)
						QBCore.Functions.Notify("You lost a delivery", "error", 5000)
						Wait(3000)
						QBCore.Functions.Notify("Wait for another delivery", "primary", 5000)
						startedrun = false
						DeleteOxyPed(data.args)
						Wait(Config.TBR)
						TriggerEvent("mtj_oxyruns:client:StartOxy")
						break
					end
				end
				Wait(0)
			end

		else
			exports['qb-target']:RemoveTargetEntity(data.args)
			PlayAmbientSpeech1(data.args, "Chat_State", "Speech_Params_Force")
			Wait(500)
			RequestAnimDict("mp_safehouselost@")
			while not HasAnimDictLoaded("mp_safehouselost@") do Wait(10) end
			TaskPlayAnim(data.args, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )
			Wait(3000)
			TriggerServerEvent("mtj_oxyrun:server:reward")
			candeliver = false
			hasdropoff = false
			RemoveBlip(dropoffblip)
			QBCore.Functions.Notify("Wait for another delivery", "primary", 5000)
			startedrun = false
			DeleteOxyPed(data.args)
			Wait(Config.TBR)
			TriggerEvent("mtj_oxyruns:client:StartOxy")
		end
	else
		QBCore.Functions.Notify("You already Delivered the Oxy", "error", 3000)
	end
end)

RegisterNetEvent("mtj_oxyrun:client:spawnoxyvehicle", function()
	local vehicle = Config.VehicleModel
	local coords = Config.VehicleSpawnLocation.xyzw

	QBCore.Functions.SpawnVehicle(vehicle, function(veh)
		SetVehicleNumberPlateText(veh, "OXY-"..tostring(math.random(1000, 9999)))
		SetEntityHeading(veh, coords.w)
		exports['cdn-fuel']:SetFuel(veh, 100.0)
		TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
	end, coords, true)
end)

function playAnim(animDict, animName, duration)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
      Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
    RemoveAnimDict(animDict)
end


Citizen.CreateThread(function()
	local sleep
	Citizen.Wait(0)
	while true do
		sleep = 5
		local player = PlayerPedId()
		local playercoords = GetEntityCoords(player)
		local dist = #(vector3(playercoords.x, playercoords.y, playercoords.z)- vector3(Config.StartLocation.x, Config.StartLocation.y, Config.StartLocation.z))
		if not inUse then
			if dist <= 2.0 then
				sleep = 5
				local ClockTime = GetClockHours()
				if ClockTime >= Config.OpenHour and ClockTime <= Config.CloseHour - 1 then
					if (ClockTime >= Config.OpenHour and ClockTime < 24) or (ClockTime <= Config.CloseHour -1 and ClockTime > 0) then
						QBCore.Functions.DrawText3D(Config.StartLocation.x, Config.StartLocation.y, Config.StartLocation.z, '~g~[E]~w~ - Start Oxy')
						if IsControlJustPressed(1, 51) then
							if not IsAnyVehicleNearPoint(vector3(Config.VehicleSpawnLocation.x, Config.VehicleSpawnLocation.y, Config.VehicleSpawnLocation.z), 3.5) then
								SetEntityCoords(player, Config.StartLocation.x-0.1, Config.StartLocation.y-0.1, Config.StartLocation.z-1, 0.0,0.0,0.0, false)
								SetEntityHeading(player, 226.4802)
								playAnim("gestures@f@standing@casual", "gesture_point", 3000)
								Citizen.Wait(3000)
								TriggerServerEvent("mtj_oxyrun:server:StartOxyPayment")
								inUse = true
							else
								QBCore.Functions.Notify("Spawn Point are not clear.", "error")
							end
						end
					end
				else
					QBCore.Functions.DrawText3D(Config.StartLocation.x, Config.StartLocation.y, Config.StartLocation.z + 1, "Opens at ~r~" .. Config.OpenHour .. "~r~:00~g~--TO--~r~" .. Config.CloseHour .."~r~:00")
				end
				
			else
				sleep = 2000
			end
		elseif dist <= 3 and inUse then
			sleep = 5
			QBCore.Functions.DrawText3D(Config.StartLocation.x, Config.StartLocation.y, Config.StartLocation.z + 1, '~g~Stock Not Available...!')
		else
			sleep = 3000
		end
		Citizen.Wait(sleep)
	end
end)
