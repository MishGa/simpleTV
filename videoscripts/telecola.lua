-- видеоскрипт для плейлиста "telecola" https://telecola.tv (30/8/20)
-- Copyright © 2017-2020 Nexterr
-- логин, пароль установить в 'Password Manager', для id - telecola
-- необходим скрапер TVS: telecola_pls
-- открывает подобные ссылки:
-- https://player.telecola.tv/71
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://player%.telecola%.tv/%d') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.telecola then
		m_simpleTV.User.telecola = {}
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'telecola ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	m_simpleTV.User.telecola.cid_sid = nil
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.3945.96 Safari/537.36'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then
			showError('0')
		 return
		end
	function telecola(offset)
		local offset = offset / 1000
		offset = math.floor(offset)
		offset = os.time() - offset
		local session = m_simpleTV.Http.New(userAgent)
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local url = 'https://api.telecola.tv/api/json/get_url?'
					.. m_simpleTV.User.telecola.cid_sid
					.. '&gmt=' .. offset
					.. '&force_ts=1&use_hls=1&protect_code='
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		local url = answer:match('"url":%s*"([^"]+)')
			if not url then return end
		offset = os.time() - offset
		url = url:gsub('%d+%.m3u8', offset .. '.m3u8')
	 return url
	end
	m_simpleTV.Http.SetTimeout(session, 16000)
	local function GetSid()
		local url, ret, login, pass
		local error_text, pm = pcall(require, 'pm')
		if package.loaded.pm then
			ret, login, pass = pm.GetTestPassword('telecola', 'telecola', true)
			if login and pass and login ~= '' and pass ~= '' then
				login = m_simpleTV.Common.toPercentEncoding(login)
				pass = m_simpleTV.Common.toPercentEncoding(pass)
				url = 'https://api.telecola.tv/api/json/login?login=' .. login .. '&pass=' .. pass
			end
		end
			if not url then return end
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		local sid = answer:match('"sid":%s*"([^"]+)')
		local sid_name = answer:match('"sid_name":%s*"([^"]+)')
			if not sid or not sid_name then return end
	 return sid_name .. '=' .. sid .. '&protect_code=' .. pass
	end
	if not m_simpleTV.User.telecola.sid then
		local sid = GetSid()
			if not sid then
				showError('1')
			 return
			end
		m_simpleTV.User.telecola.sid = sid
	end
	m_simpleTV.User.telecola.cid_sid = 'cid=' .. inAdr:match('%d+') .. '&' .. m_simpleTV.User.telecola.sid
	local url = 'https://api.telecola.tv/api/json/get_url?' .. m_simpleTV.User.telecola.cid_sid
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			m_simpleTV.User.telecola.sid = nil
			showError('2')
		 return
		end
	local retAdr = answer:match('"url":%s*"([^"]+)')
		if not retAdr then
			m_simpleTV.User.telecola.sid = nil
			showError('3')
		 return
		end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')