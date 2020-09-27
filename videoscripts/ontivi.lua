-- видеоскрипт для плейлиста "ontivi" http://ontivi.net (31/4/20)
-- необходим модуль: /core/playerjs.lua
-- необходим скрапер TVS: ontivi_pls
-- необходимы скрипты: youtube, ovvatv, mediavitrina, uma_media
-- открывает подобные ссылки:
-- http://ontivi.net/5-kanaltv.html
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://ontivi%.net') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	require 'playerjs'
	require 'jsdecode'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.3785.121 Safari/537.36'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local function checkAdr(adr)
		local rc = m_simpleTV.Http.Request(session, {url = adr, headers = 'Referer: ' .. inAdr})
			if rc ~= 200 then return end
	 return true
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local host = inAdr:match('https?://.-/')
	answer = answer:gsub('<!%-%-.-%-%->', ''):gsub('/%*.-%*/', '')
	local s = answer:match('%.get%("(open.-",%s*{%a+:\'[^\']+)')
		if not s then
			local retAdr
			local url = answer:match('else{window%.open%(\'([^\']+)') or ''
			if url:match('1plus1%.ua/ru/online') then
				retAdr = url
			elseif url:match('/2plus2/') then
				retAdr = url
			elseif url:match('chetv%.ru') then
				retAdr = 'https://player.mediavitrina.ru/che/che_web/player.html'
			elseif url:match('ren%.tv') then
				retAdr = 'https://player.mediavitrina.ru/rentv/rentv_web/player.html'
			elseif url:match('ntv%.ru/air') then
				retAdr = url
			elseif url:match('tnt%-online') then
				retAdr = 'https://uma.media/video/4e4e37727e07a7124cd7b29f2975e295/'
			elseif inAdr:match('tnt4tv%.html') then
				retAdr = 'https://uma.media/video/b0200b6f7a08fb0aad4e1289f491d1ea/'
			elseif inAdr:match('2na2tv%.html') then
				retAdr = 'https://uma.media/video/dcab9b90a33239837c0f71682d6606da/&referer=https://2x2tv.ru/online/'
			end
			if retAdr then
				m_simpleTV.Control.ChangeAddress = 'No'
				m_simpleTV.Control.CurrentAddress = retAdr
				dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
			else
				m_simpleTV.Control.CurrentAddress = host .. 'img/pley.jpg$OPT:image-duration=5'
			end
		 return
		end
	s = s:gsub('",%s*{', '?'):gsub(':\'', '=')
	rc, answer = m_simpleTV.Http.Request(session, {url = host .. s, headers = 'X-Requested-With: XMLHttpRequest\nReferer: ' .. inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local playerjs_url = answer:match('<script src="([^"]+)')
		if not playerjs_url then return end
	playerjs_url = host .. playerjs_url
	local scr = answer:match('glob%([^\;]+')
	if scr then
		scr = scr .. '; function glob(s){return atob(s.substring(2+(-~[])));}'
		answer = jsdecode.DoDecode(scr)
			if not answer then return end
	end
	local retAdr = answer:match('file:\'([^\']+)')
		if not retAdr then return end
	retAdr = playerjs.decode(retAdr, playerjs_url)
		if not retAdr or retAdr == '' then return end
		if retAdr:match('youtu[%.combe]') then
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = retAdr .. '&isLogo=false'
			dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
		 return
		end
	if not checkAdr(retAdr) then
		retAdr = answer:match('\'file\',\'([^\']+)')
			if not retAdr then return end
		retAdr = playerjs.decode(retAdr, playerjs_url)
			if not retAdr or retAdr == '' then return end
	end
	m_simpleTV.Http.Close(session)
	retAdr = retAdr:gsub('^//', 'http://')
			.. '$OPT:http-referrer=' .. inAdr
			.. '$OPT:http-user-agent=' .. userAgent
			.. '$OPT:NO-STIMESHIFT'
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')