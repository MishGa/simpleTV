-- видеоскрипт для плейлиста "ДомаТвНет" http://tv.domatv.net (26/8/20)
-- Copyright © 2017-2020 Nexterr
-- необходим скрапер TVS: domatv_pls
-- необходим модуль: /core/playerjs.lua
-- открывает подобные ссылки:
-- http://tv.domatv.net/107-bbc-world-news.html
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[%a%.]*domatv%.net') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	require 'playerjs'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:80.0) Gecko/20100101 Firefox/80.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	answer = answer:gsub('<!%-%-.-%-%->', ''):gsub('/%*.-%*/', '')
	local retAdr = answer:match('file%s*:%s*"([^"]+)')
		if not retAdr then return end
	local playerjs_url = answer:match('src="(/templates/shamanim/js/tv.-)"')
		if not playerjs_url then return end
	playerjs_url = inAdr:match('^https?://[^/]+') .. playerjs_url
	retAdr = playerjs.decode(retAdr, playerjs_url)
		if not retAdr or retAdr == '' then return end
	local v1 = answer:match('firstIpProtect = \'([^\']+)') or ''
	local v2 = answer:match('secondIpProtect = \'([^\']+)') or ''
	local v3 = answer:match('portProtect = \'([^\']+)') or ''
	retAdr = retAdr:gsub('{v1}', v1):gsub('{v2}', v2):gsub('{v3}', v3)
	retAdr = retAdr .. '$OPT:http-referrer=' .. inAdr
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')