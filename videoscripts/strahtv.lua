-- видеоскрипт для плейлиста "Страх ТВ" https://strah.video (15/6/20)
-- необходим скрапер TVS: strahtv_pls
-- необходим модуль: /core/playerjs.lua
-- открывает подобные ссылки:
-- https://strah.video/id/2
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://strah%.video/') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'Ух ты, шмоль - Страх ТВ: ' .. str, showTime = 8000, color = 0xffff6600, id = 'channelName'})
	end
	require 'playerjs'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then
			showError('1')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local url = inAdr:gsub('/id/', '/stream?if=')
	local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: ' .. inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('2 - ' .. rc)
		 return
		end
	answer = answer:gsub('<!%-%-.-%-%->', '')
	answer = answer:gsub('/%*.-%*/', '')
	answer = answer:gsub('%s+', '')
	local playerjs_url = answer:match('<scripttype="text/javascript"src="([^"]+)')
		if not playerjs_url then
			showError('3\nУх ты, шмоль!')
		 return
		end
	local str = answer:match('[<>\'"]+(#%d[^<>\'"]+)')
		if not str then
			showError('4')
		 return
		end
	playerjs_url = 'https://strah.video' .. playerjs_url
	local retAdr = playerjs.decode(str, playerjs_url)
		if not retAdr
			or retAdr == ''
		then
			showError('5')
		 return
		end
	retAdr = retAdr:gsub('^.-](.+)', '%1')
	rc, answer = m_simpleTV.Http.Request(session, {url = playerjs_url, headers = 'Referer: ' .. url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('6 - ' .. rc)
		 return
		end
	local scr = answer:match('var StrahVideoStream.-$')
	if scr then
		local i = 1
		for w in scr:gmatch('=%s*"([^"]+)') do
			retAdr = retAdr:gsub('{v' .. i .. '}', w)
			i = i + 1
		end
	else
		showError('7')
	 return
	end
	retAdr = retAdr
			.. '$OPT:no-gnutls-system-trust'
			.. '$OPT:NO-STIMESHIFT'
			.. '$OPT:http-user-agent=' .. userAgent
			.. '$OPT:http-referrer=' .. url
			.. '$OPT:no-ts-cc-check'
			.. '$OPT:no-ts-trust-pcr'
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')