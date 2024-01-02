
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

emP = {}
local idgens = Tools.newIDGenerator()
Tunnel.bindInterface("brn_npcdrogavende",emP)
-----------------------------------------------------------------------------------------------------------------------------------------
vRP = Proxy.getInterface("vRP")

local quantidade = {}
function emP.Quantidade()
	local source = source
	if quantidade[source] == nil then
		quantidade[source] = 1
	end
	return quantidade[source]
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- ITENS
-----------------------------------------------------------------------------------------------------------------------------------------
function emP.checkItens()
	emP.Quantidade()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then 
        return vRP.getInventoryItemAmount(user_id,"tablete") > quantidade[source] or vRP.getInventoryItemAmount(user_id,"cocaembalada") >= quantidade[source]  or  vRP.getInventoryItemAmount(user_id,"lsdembalado") >= quantidade[source]  or  vRP.getInventoryItemAmount(user_id,"lsd") >= quantidade[source]  or  vRP.getInventoryItemAmount(user_id,"ecstasy") >= quantidade[source]
	end
end


function emP.checkPermissao()
	local source = source
	local user_id = vRP.getUserId(source)
	if not vRP.terPemissao(user_id,"policia.permissao") then 
		return true
	else 
		return false
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- PAGAMENTO
-----------------------------------------------------------------------------------------------------------------------------------------
function emP.checkPayment()
	local source = source
	local user_id = vRP.getUserId(source)
	local policia = {}
	policia = vRP.getUsersByPermission("policia.permissao")
	local bonus = 0

	if #policia >= 0 and #policia <= 3 then
        bonus = 0
    elseif #policia >= 4 and #policia <= 6 then
        bonus = 50
    elseif #policia >= 7 and #policia <= 10 then
		bonus = 100
	elseif #policia >= 11 and #policia <= 14 then
        bonus = 200
    elseif #policia > 15 then
        bonus = 300
    end

	if user_id then
		if vRP.tryGetInventoryItem(user_id,"tablete", quantidade[source]) then
			vRP.giveInventoryItem(user_id,"dinheirosujo", (parseInt(1800) + bonus) * quantidade[source])

		end
		if vRP.tryGetInventoryItem(user_id,"cocaembalada",quantidade[source]) then
			vRP.giveInventoryItem(user_id,"dinheirosujo", (parseInt(1800) + bonus) * quantidade[source])
			
		end
		if vRP.tryGetInventoryItem(user_id,"lsdembalado",quantidade[source]) then
			vRP.giveInventoryItem(user_id,"dinheirosujo", (parseInt(1800) + bonus) * quantidade[source])
			
		end
		quantidade[source] = nil
		return true
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- POLICIA
-----------------------------------------------------------------------------------------------------------------------------------------
local blips = {}
function emP.MarcarOcorrencia()
	local source = source
	local user_id = vRP.getUserId(source)
	local x,y,z = vRPclient.getPosition(source)
	local identity = vRP.getUserIdentity(user_id)
	if user_id then
		local policiais = vRP.getUsersByPermission("policia.permissao")
		for l,w in pairs(policiais) do
			local player = vRP.getUserSource(parseInt(w))
			local playerId = vRP.getUserId(player)
			if player then
				async(function()				
					TriggerClientEvent("NotifyPush",player,{ time = os.date("%H:%M:%S - %d/%m/%Y"), code = 32, title = "Tráfico Em Andamento", x = x, y = y, z = z, rgba = {0,0,0} })
					TriggerClientEvent('trafico',player,x,y,z,user_id)
			   end)
			end
		end 
		-- SendWebhookMessage(webhookdrugs,"```prolog\n[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[FOI DENUNCIADO] "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
	end
end