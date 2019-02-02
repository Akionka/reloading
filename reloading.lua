script_name('Reloading')
script_author('akionka')
script_version('1.3')
script_version_number(4)

local sampev = require('lib.samp.events')
local encoding = require('encoding')
local inicfg = require('inicfg')
local dlstatus = require('moonloader').download_status
encoding.default = 'cp1251'
u8 = encoding.UTF8

local ini = inicfg.load({
  settings =
  {
    invex = true
  },
}, "akionka")

local weapons = {
	COLT45 = 22,
	SILENCED = 23,
	DESERTEAGLE = 24,
	SHOTGUN = 25,
	SAWNOFFSHOTGUN = 26,
	COMBATSHOTGUN = 27,
	UZI = 28,
	MP5 = 29,
	AK47 = 30,
	M4 = 31,
	TEC9 = 32,
	RIFLE = 33,
	SNIPERRIFLE = 34,
	ROCKETLAUNCHER = 35,
}

local id = weapons
weapons.names = {
	[id.COLT45] = 'Glock 18',
	[id.SILENCED] = 'Glock 18 c глушителем',
	[id.DESERTEAGLE] = 'Desert Eagle',
	[id.SHOTGUN] = 'Дробовик',
	[id.SAWNOFFSHOTGUN] = 'Обрез',
	[id.UZI] = 'Micro Uzi',
	[id.MP5] = 'MP5',
	[id.AK47] = 'AK-47',
	[id.M4] = 'M4',
	[id.TEC9] = 'TEC 9',
	[id.RIFLE] = 'Винтовка',
	[id.SNIPERRIFLE] = 'Снайперская винтовка',
	[id.ROCKETLAUNCHER] = 'РПГ-7',
}

local gun = 0
local gunn = ""
local state = 0
local list = 0
local takeback = false

local states = {
	NONE = 0,
	SEARCH_GUN = 1,
	CHOOSE_GUN = 2,
	CHOOSE_ACTION = 3,
	CLOSE_INV = 4,
	CLOSE_INV_AND_TAKE_GUN = 5
}

local ids = {
	done = 998,
	no_bullets_too_much = 999,
	main_inv = 1000,
	choose_action = 1200,
	enter_amount = 1201
}

function sampev.onShowDialog(id, stytle, title, btn1, btn2, text)
	if id == ids.main_inv then
		if state == states.SEARCH_GUN then
			local i = 0
			for item in text:gmatch("[^\r\n]+") do
				i = i + 1
				if item:find(u8:decode(gun..".+%[Используется%]")) ~= nil then
					state = states.CHOOSE_GUN
					takeback = true
					list = i-1
					sampSendDialogResponse(id, 1, list, "")
			 		return false
				end
			end
			local i = 0
			for item in text:gmatch("[^\r\n]+") do
				i = i + 1
				if item:find(u8:decode(gun)) ~= nil then
					state = states.CHOOSE_ACTION
					list = i-1
					sampSendDialogResponse(id, 1, list, "")
			 		return false
				end
			end
			sampSendDialogResponse(id, 0, 0, "")
			sampAddChatMessage(u8:decode("[Reloading]: {FF0000}Error!{FFFFFF} В вашем инвентаре отсутствует данное оружие."), -1)
			return false
		end
		if state == states.CHOOSE_GUN then
			sampSendDialogResponse(id, 1, list, "")
			state = states.CHOOSE_ACTION
			return false
		end
		if state == states.CLOSE_INV then
			sampSendDialogResponse(id, 0, 0, "")
			state = states.NONE
			return false
		end
		if state == states.CLOSE_INV_AND_TAKE_GUN then
			sampSendDialogResponse(id, 0, 0, "")
			sampSendChat("/take "..gunn)
			state = states.NONE
			return false
		end
	elseif id == ids.choose_action then
		if state == states.CHOOSE_ACTION then
			sampSendDialogResponse(id, 1, 6, "")
			return false
		end
		if state == states.CLOSE_INV then
			sampSendDialogResponse(id, 0, 0, "")
			state = states.NONE
			return false
		end
		if state == states.CLOSE_INV_AND_TAKE_GUN then
			sampSendDialogResponse(id, 0, 0, "")
			return false
		end
	elseif id == ids.enter_amount then
		if state ~= states.NONE then
			sampSendDialogResponse(id, 1, 0, text:match(u8:decode("{D8A903}(%d+) {abcdef}патр")))
			return false
		end
	elseif id == ids.done then
		if state ~= states.NONE then
			sampSendDialogResponse(id, 1, 0, "")
			state = states.CLOSE_INV_AND_TAKE_GUN
			return false
		end
	elseif id == ids.no_bullets_too_much then
		if state == states.CHOOSE_ACTION then
			sampSendDialogResponse(id, 1, 0, "")
			sampAddChatMessage(u8:decode("[Reloading]: {FF0000}Error!{FFFFFF} В вашем инвентаре отсутствуют патроны для этого вида оружия, либо оружие полностью заряжено."), -1)
			state = states.CLOSE_INV
			return false
		end
	end
end

function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(0) end
	sampAddChatMessage(u8:decode("[Reloading]: Скрипт {00FF00}успешно{FFFFFF} загружен. Версия: {2980b9}"..thisScript().version.."{FFFFFF}."), -1)
	update()
	while updateinprogess ~= false do wait(0) end
	sampRegisterChatCommand("pt", function(params)
		if params:lower() == "glock" then
			gun = weapons.names[22]
			state = states.SEARCH_GUN
			sampSendChat(ini.settings.invex and "/invex" or "/inv")
		end
		if params:lower() == "glocks" then
			gun = weapons.names[23]
			state = states.SEARCH_GUN
			sampSendChat(ini.settings.invex and "/invex" or "/inv")
		end
		if params:lower() == "deagle" then
			gun = weapons.names[24]
			state = states.SEARCH_GUN
			sampSendChat(ini.settings.invex and "/invex" or "/inv")
		end
		if params:lower() == "shot" or params:lower() == "shotgun"then
			gun = weapons.names[25]
			state = states.SEARCH_GUN
			sampSendChat(ini.settings.invex and "/invex" or "/inv")
		end
		if params:lower() == "sawnoff" then
			gun = weapons.names[26]
			state = states.SEARCH_GUN
			sampSendChat(ini.settings.invex and "/invex" or "/inv")
		end
		if params:lower() == "uzi" then
			gun = weapons.names[28]
			state = states.SEARCH_GUN
			sampSendChat(ini.settings.invex and "/invex" or "/inv")
		end
		if params:lower() == "mp5" or params:lower() == "mp" then
			gun = weapons.names[29]
			state = states.SEARCH_GUN
			sampSendChat(ini.settings.invex and "/invex" or "/inv")
		end
		if params:lower() == "ak" or params:lower() == "ak47" or params:lower() == "ak-47" then
			gun = weapons.names[30]
			state = states.SEARCH_GUN
			sampSendChat(ini.settings.invex and "/invex" or "/inv")
		end
		if params:lower() == "m4" then
			gun = weapons.names[31]
			state = states.SEARCH_GUN
			sampSendChat(ini.settings.invex and "/invex" or "/inv")
		end
		if params:lower() == "tec" or params:lower() == "tec9" or params:lower() == "tec-9" then
			gun = weapons.names[32]
			state = states.SEARCH_GUN
			sampSendChat(ini.settings.invex and "/invex" or "/inv")
		end
		if params:lower() == "rifle" then
			gun = weapons.names[33]
			state = states.SEARCH_GUN
			sampSendChat(ini.settings.invex and "/invex" or "/inv")
		end
		if params:lower() == "srifle" then
			gun = weapons.names[34]
			state = states.SEARCH_GUN
			sampSendChat(ini.settings.invex and "/invex" or "/inv")
		end
		if params:lower() == "rpg" or params:lower() == "rpg7" or params:lower() == "rpg-7" then
			gun = weapons.names[35]
			state = states.SEARCH_GUN
			sampSendChat(ini.settings.invex and "/invex" or "/inv")
		end
		gunn = params
	end)
	sampRegisterChatCommand("ptinv", function()
		ini.settings.invex = not ini.settings.invex
		inicfg.save(ini, "akionka")
		sampAddChatMessage(ini.settings.invex and u8:decode("[Reloading]: Скрипт теперь работает с {2980b9}/invex{FFFFFF}.") or u8:decode("[Reloading]: Скрипт теперь работает с {2980b9}/inv{FFFFFF}."), -1)
	end)
end

function update()
	local fpath = os.getenv('TEMP') .. '\\reloading-version.json'
	downloadUrlToFile('https://raw.githubusercontent.com/Akionka/reloading/master/version.json', fpath, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			local f = io.open(fpath, 'r')
			if f then
				local info = decodeJson(f:read('*a'))
				if info and info.version then
					version = info.version
					version_num = info.version_num
					if version_num > thisScript().version_num then
						sampAddChatMessage(u8:decode("[Reloading]: Найдено объявление. Текущая версия: {2980b9}"..thisScript().version.."{FFFFFF}, новая версия: {2980b9}"..version.."{FFFFFF}. Начинаю закачку."), -1)
						lua_thread.create(goupdate)
					else
						sampAddChatMessage(u8:decode("[Reloading]: У вас установлена самая свежая версия скрипта."), -1)
						updateinprogess = false
					end
				end
			end
		end
	end)
end

function goupdate()
	wait(300)
	downloadUrlToFile("https://raw.githubusercontent.com/Akionka/reloading/master/reloading.lua", thisScript().path, function(id3, status1, p13, p23)
		if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
			sampAddChatMessage(u8:decode('[Reloading]: Новая версия установлена! Чтобы скрипт обновился нужно либо перезайти в игру, либо ...'), -1)
			sampAddChatMessage(u8:decode('[Reloading]: ... если у вас есть автоперезагрузка скриптов, то новая версия уже готова и снизу вы увидите приветственное сообщение'), -1)
			sampAddChatMessage(u8:decode('[Reloading]: Если что-то пошло не так, то сообщите мне об этом в VK или Telegram > {2980b0}vk.com/akionka teleg.run/akionka{FFFFFF}.'), -1)
			updateinprogess = false
		end
	end)
end

function trim(s) return (string.gsub(s, "^%s*(.-)%s*$", "%1")) end
