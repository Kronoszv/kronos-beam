local enabled = false
local timer_opti = 1000

RegisterCommand('+Beam', function()
	local ped = PlayerPedId()
	for _, theWeapon in ipairs(Config.AllowedWeapons) do
		if GetSelectedPedWeapon(ped) == GetHashKey(theWeapon) then
			if enabled then
			enabled = false
			timer_opti = 1000
		else
			Citizen.CreateThread(function()
				enabled = true
				while enabled do 
					timer_opti = 1000
					local camview = GetFollowPedCamViewMode()
					local crouch = GetPedStealthMovement(ped)
					if IsPlayerFreeAiming(PlayerId()) then
						if GetSelectedPedWeapon(ped) == GetHashKey(theWeapon) then
							timer_opti = 0
							local weapon = GetCurrentPedWeaponEntityIndex(ped)
							local offset = GetOffsetFromEntityInWorldCoords(weapon, 0.00, -0.00, 0.02)
							local hit, coords = RayCastPed(offset, 15000, ped)
							if hit ~= 0 then
								DrawLine(offset.x, offset.y, offset.z, coords.x, coords.y, coords.z, Config.Color.r, Config.Color.g, Config.Color.b, Config.Color.a)
								DrawSphere2(coords, 0.05, Config.Color.r, Config.Color.g, Config.Color.b, Config.Color.a)
							end
						end
					end
					Citizen.Wait(timer_opti)
				end
			end)
		end
	end
end
end, false)

RegisterCommand('-Beam', function() end, false)
RegisterKeyMapping('+Beam', 'Toggle Beam', 'keyboard', Config.Key)

function RotationToDirection(rotation)
	local adjustedRotation = 
	{ 
		x = (math.pi / 180) * rotation.x, 
		y = (math.pi / 180) * rotation.y, 
		z = (math.pi / 180) * rotation.z 
	}
	local direction = 
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

function RayCastPed(pos,distance,ped)
    local cameraRotation = GetGameplayCamRot()
	local direction = RotationToDirection(cameraRotation)
	local destination = 
	{ 
		x = pos.x + direction.x * distance, 
		y = pos.y + direction.y * distance, 
		z = pos.z + direction.z * distance 
	}

	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(pos.x, pos.y, pos.z, destination.x, destination.y, destination.z, -1, ped, 1))
    return b, c
end

function DrawSphere2(pos, radius, r, g, b, a)
	DrawMarker(28, pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, radius, radius, radius, r, g, b, a, false, false, 2, nil, nil, false)
end
