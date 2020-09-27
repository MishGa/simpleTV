-- видеоскрипт для плейлиста "allplay" https://allplay.uz (19/10/19)
-- логин, пароль установить в 'Password Manager', для id - allplay
-- открывает подобные ссылки:
-- https://allplay.uz/channel/play/36
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
		if not inAdr:match('^https?://allplay%.uz/channel') then return end
	m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = '', TypeBackColor = 0, UseLogo = 3, Once = 1})
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = 'error'
	local session = m_simpleTV.Http.New(decode64('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/78.0.3809.87 Safari/537.36'))
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.allplay then
		m_simpleTV.User.allplay = {}
	end
	local function GetCookies()
		local error_text, pm = pcall(require, 'pm')
		if package.loaded.pm then
			local ret, login, pass = pm.GetTestPassword('allplay', 'allplay', false)
			if pass and pass ~= '' and login and login ~= '' then
				local body = 'email=' .. m_simpleTV.Common.toPersentEncoding(login) .. '&password=' .. m_simpleTV.Common.toPersentEncoding(pass) .. '&remember=1'
				local url = 'https://allplay.uz/login'
				local rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post' , body = body})
					if rc ~= 200 then return end
					if rc == 200 and answer:match('<!DOCTYPE') then return end
				local cooki = m_simpleTV.Http.GetCookies(session, url, 'ls')
					if cooki then
					 return 'ls=' .. cooki
					end
			end
		end
	 return
	end
	if not m_simpleTV.User.allplay.cooki then
		m_simpleTV.User.allplay.cooki = GetCookies() or 'ls=eyJpdiI6Ikh0RmhKR2tNS0h1UmRyTVhjMktkVmc9PSIsInZhbHVlIjoicWVrdjJ2Y1BXbFFES0hHMjYrb095ckwzR0dJeUZRZ2xYbVBPeXVqaENxMXR6OUxYVlVRZk1BTzQ5YzZudDVWdEpqbFNxbkNISXlhVE5jSFZqZHlYMlE9PSIsIm1hYyI6IjBlNTc0YTQ0ZjUwMzg5ODQyMjBkNmNmNzE5MmM4ZDg1OTExNWQzZmI3MjdmNWIyNmMwYzM5MWZlNTkyMDYxMTcifQ%3D%3D'
	end
	m_simpleTV.Http.SetCookies(session, inAdr, '', m_simpleTV.User.allplay.cooki)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, headers = 'X-Requested-With: XMLHttpRequest'})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			local title = 'allplay ошибка[1]'
			if answer then
				title = answer:match('errors":{"default":%["(.-)"%]}') or title
				title = unescape3(title)
				title = title:gsub('\\"', '"')
			end
			m_simpleTV.OSD.ShowMessageT({text = title, color = ARGB(255, 155, 255, 255), showTime = 1000 * 5, id = 'channelName'})
		 return
		end
	local retAdr = answer:match('http[^\'"]+%.m3u8[^\'"]*')
		if not retAdr then
			m_simpleTV.OSD.ShowMessageT({text = 'allplay ошибка[2]', color = ARGB(255, 155, 255, 255), showTime = 1000 * 5, id = 'channelName'})
		 return
		end
	retAdr = retAdr:gsub('\\/', '/')
	m_simpleTV.Control.CurrentAdress = retAdr
-- debug_in_file(retAdr .. '\n')