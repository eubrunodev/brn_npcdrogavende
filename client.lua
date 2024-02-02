local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
-----------------------------------------------------------------------------------------------------------------------------------------
vRP = Proxy.getInterface("vRP")
emP = Tunnel.getInterface("brn_npcdrogavende")
vRPclient = Tunnel.getInterface("vRP")
-- INICIO DO SCRIPT DE VENDER DROGAS PARA OS NPCS

local aimingAtNPC = false
local cansell = true
local isAtPed = false
local npcPed
local isFrozen = false
local apertouE

local aimingAtNPC = false
local canSell = true

local vendendo = false
local cooldownTime = 10 -- Tempo de cooldown em segundos
local ped = PlayerPedId()

RegisterKeyMapping('brn_npcdrogavende:sell', 'Vender droga', 'keyboard', 'E')

RegisterCommand("brn_npcdrogavende:sell", function()
    if not vendendo and not IsPedInAnyVehicle(ped) then
        vendendo = true
        local playerPed = PlayerPedId()
        local nearestNpc = GetNearestNpc()

        if nearestNpc and emP.checkPayment() and emP.checkItens() then
            local distance = Vdist(GetEntityCoords(playerPed), GetEntityCoords(nearestNpc))

            if distance <= 2.0 then
                vRP._playAnim(true,{{"mp_common","givetake1_a"}},false)
                TriggerEvent("Notify", "sucesso", "Droga vendida com sucesso!")
                emP.MarcarOcorrencia()


                Citizen.Wait(cooldownTime)
                TriggerEvent("Notify", "aviso", "Você está liberado para vender outra droga!")
            end
        end
        vendendo = false
    end
end, false)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local nearestNpc = GetNearestNpc()

        if nearestNpc and canSell then
            local distance = Vdist(GetEntityCoords(playerPed), GetEntityCoords(nearestNpc))

            if emP.checkItens() and distance <= 2.0 and not IsPedInAnyVehicle(ped) then
                TriggerEvent("pNotify", "Pressione ~g~E~s~ para vender a droga", 1000)
            end
        end
    end
end)

function GetNearestNpc()
    local playerPed = PlayerPedId()
    local pedCoords = GetEntityCoords(playerPed)
    local npc = nil
    local minDistance = 9999.0

    for _, ped in ipairs(GetGamePool('CPed')) do
        if not IsPedAPlayer(ped) and not IsEntityDead(ped) and IsPedHuman(ped) and not IsPedInAnyVehicle(ped) then
            local dist = Vdist(pedCoords, GetEntityCoords(ped))

            if dist < minDistance then
                minDistance = dist
                npc = ped
            end
        end
    end

    return npc
end



local blips = {}
RegisterNetEvent('trafico')
AddEventHandler('trafico',function(x,y,z,user_id)
	if not DoesBlipExist(blips[user_id]) then
			blips[user_id] = AddBlipForCoord(x,y,z)
			SetBlipScale(blips[user_id],0.5)
			SetBlipSprite(blips[user_id],10)
			SetBlipColour(blips[user_id],49)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Trafico em andamento")
			EndTextCommandSetBlipName(blips[user_id])
			SetBlipAsShortRange(blips[user_id],false)
			SetBlipRoute(blips[user_id],true)
			TriggerEvent("Notify","aviso","Alerta de Tráfico, vá até o local marcado no seu GPS!", 3000)
			SetTimeout(30000,function()
				if DoesBlipExist(blips[user_id]) then
					RemoveBlip(blips[user_id])
				end
			end)
		end
	--end
end)

function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

function showNotification (text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(true, false)
end
