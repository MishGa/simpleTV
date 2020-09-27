-- видеоскрипт для плейлиста "Смотрёшка" https://smotreshka.tv (15/9/20)
-- Copyright © 2017-2020 Nexterr
-- необходим скрапер TVS: smotreshka_pls
-- логин, пароль установить в 'Password Manager', для id - smotreshka
-- открывает подобные ссылки:
-- https://smotreshka.tv/5aead81921887f04724d1780
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://smotreshka%.tv/%x') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'erorr'
	require 'json'
	local url = 'https://fe.smotreshka.tv/'
	inAdr = url .. 'playback-info/' .. inAdr:match('smotreshka%.tv/(%x+)')
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'Смотрёшка ошибка: ' .. str
											, color = 0xffff6600
											, showTime = 1000 * 5
											, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
		if not session then
			showError('1')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.smotreshka then
		m_simpleTV.User.smotreshka = {}
	end
	local function getCookies()
		local error_text, pm = pcall(require, 'pm')
			if not package.loaded.pm then return end
		local ret, login, pass = pm.GetTestPassword('smotreshka', 'Смотрёшка', true)
			if not login
				or not pass
				or login == ''
				or pass == ''
			then
			 return
			end
		login = m_simpleTV.Common.toPercentEncoding(login)
		pass = m_simpleTV.Common.toPercentEncoding(pass)
		local body = 'email=' .. login .. '&password=' .. pass
		local headers = 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8\nReferer: ' .. url
		local rc, answer = m_simpleTV.Http.Request(session, {body = body, url = url .. 'login', method = 'post', headers = headers})
			if rc ~= 200 then return end
		local tab = json.decode(answer)
			if not tab
				or not tab.session
			then
			 return
			end
	 return tab.session
	end
	if not m_simpleTV.User.smotreshka.cookies then
		local cookies = getCookies()
			if not cookies then
				m_simpleTV.Http.Close(session)
				showError('2\nнужен логин и пароль\nили продлите подписку')
			 return
			end
		m_simpleTV.User.smotreshka.cookies = cookies
	end
	m_simpleTV.Http.SetCookies(session, inAdr, '', 'session=' .. m_simpleTV.User.smotreshka.cookies)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			m_simpleTV.User.smotreshka = nil
			local err
			if answer then
				err = answer:match('"msg":"([^"]+)')
			end
			err = err or 'продлите подписку'
			showError('3\n' .. err)
		 return
		end
	answer = answer:gsub('%[%]', '""')
	local tab = json.decode(answer)
		if not tab
			or not tab.languages
			or not tab.languages[1].renditions[1]
			or not tab.languages[1].renditions[1].url
		then
			m_simpleTV.User.smotreshka = nil
			showError('4')
		 return
		end
	local retAdr = tab.languages[1].renditions[1].url:gsub('u0026', '&')
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local base = retAdr:match('.+/')
	local t, i = {}, 1
		for res, br, res1, adr in answer:gmatch('EXT%-X%-STREAM%-IN([%C]+)[:,]BANDWIDTH=(%d+)([%C]*).-\n(.-)\n') do
			t[i] = {}
			br = tonumber(br)
			br = math.ceil(br / 10000) * 10
			res = res:match('RESOLUTION=(%d+x%d+)')
				or res1:match('RESOLUTION=(%d+x%d+)')
			if res then
				t[i].Name = res .. ' (' .. br .. ' кбит/с)'
				res = res:match('x(%d+)')
				t[i].Id = tonumber(res)
			else
				t[i].Name = 'аудио (' .. br .. ' кбит/с)'
				t[i].Id = 0
			end
			if not adr:match('^%s*http') then
				adr = base .. adr:gsub('^[%s/%.]+', '')
			end
			t[i].Address = adr
			i = i + 1
		end
		if i == 1 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('smotreshka_qlty')) or 5000
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 5000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 10000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr
		index = #t
			for i = 1, #t do
				if t[i].Id >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if t[index].Id > lastQuality then
				index = index - 1
			end
		end
		if m_simpleTV.Control.MainMode == 0 then
			if m_simpleTV.User.paramScriptForSkin_buttonOk then
				t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
			end
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtParams = {LuaOnOkFunName = 'smotreshkaSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function smotreshkaSaveQuality(obj, id)
		if id > 0 then
			m_simpleTV.Config.SetValue('smotreshka_qlty', id)
		end
	end
-- debug_in_file(t[index].Address .. '\n')