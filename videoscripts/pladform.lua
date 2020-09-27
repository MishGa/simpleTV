-- видеоскрипт для https://pladform.ru (5/10/18)
-- необходимы скрипты: rutube
-- открывает подобные ссылки:
-- http://out.pladform.ru/player?swid=12&pl=13151&skinid=12&playlistid=58400
-- http://out.pladform.ru/player?pl=13151&seasonid=4739
---------------------------------------------------------------------------------------
local qlty = 0 -- качество: 0 - максимальное, от 480 - ограничить разрешение
---------------------------------------------------------------------------------------
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if inAdr == nil then return end
		if not inAdr:match('out%.pladform%.ru') then return end
	require 'json'
	inAdr = inAdr:gsub('/getPlaylist%?', '/player?')
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/68.0.2785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if m_simpleTV.Control.CurrentTitle_UTF8 == nil or m_simpleTV.Control.CurrentTitle_UTF8:match('out%.pladform%.ru') then m_simpleTV.Control.CurrentTitle_UTF8 = 'pladform видео' end
	local title = m_simpleTV.Control.CurrentTitle_UTF8
	local retAdr = inAdr
	local pl = inAdr:match('pl=(%d+)')
	local videoid = inAdr:match('videoid=(%d+)') or ''
	if not retAdr:match('videoid=') then
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
				m_simpleTV.OSD.ShowMessage_UTF8('pladform ошибка[1]-' .. rc, 255, 5)
			 return
			end
		local fv = answer:match('flashvars.-\'(.-)\'')
			if fv == nil then
				m_simpleTV.OSD.ShowMessage_UTF8('pladform ошибка[2]', 255, 5)
			 return
			end
		local rc, answer = m_simpleTV.Http.Request(session, {url = 'http://out.pladform.ru/getPlaylist?' .. fv .. '&format=json'})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
				m_simpleTV.OSD.ShowMessage_UTF8('pladform ошибка[3]-' .. rc, 255, 5)
			 return
			end
		local answer = answer:gsub('(%[%])', '"nil"')
		local t = json.decode(answer)
			if t == nil then return end
		local a, j = {}, 1
			while true do
				if t.video[j] == nil then break end
				a[j] = {}
				a[j].Id = j
				a[j].Name = t.video[j].title
				a[j].Adress = 'http://out.pladform.ru/getVideo?pl=' .. pl .. '&videoid=' .. t.video[j].id
				j = j + 1
			end
			if j > 2 then
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, a, 10000)
				if id == nil then id = 1 end
				 url = a[id].Adress
			else
				 url = a[1].Adress
			end
	else
		url = 'http://out.pladform.ru/getVideo?pl=' .. pl .. '&videoid=' .. videoid
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			m_simpleTV.OSD.ShowMessage_UTF8('pladform ошибка[4]-' .. rc, 255, 5)
		 return
		end
	local title = answer:match('<title>.-CDATA%[(.-)%].-</title>') or 'pladform'
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	local rutube = answer:match('<src.-!%[CDATA%[(.-rutube%.ru.-)%]%]></src>') or answer:match('<src type="rutube"><!%[CDATA%[(.-)%]%]></src>')
		if rutube then
			if not rutube:match('https?://') then
				retAdr = 'http://rutube.ru/play/embed/' .. rutube
				m_simpleTV.Control.ChangeAdress = 'No'
				m_simpleTV.Control.CurrentAdress = retAdr
				dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
			 return
			end
			m_simpleTV.Control.CurrentAdress = rutube
		 return
		end
	if qlty == 0 then qlty = 10000 end
	local max, r = 0, 0
	for url in answer:gmatch('<src type="video" quality=".-</src>') do
		local r = url:match('quality="(%d+)') or 0
		local r = tonumber(r)
			if max <= r and r <= qlty then
				max = r
				retAdr = url:match('CDATA%[(.-)%]')
			end
	end
		if retAdr == nil then
			m_simpleTV.OSD.ShowMessage_UTF8('pladform ошибка[5]', 255, 5)
		 return
		end
	m_simpleTV.Control.CurrentAdress = retAdr
-- debug_in_file(retAdr .. '\n')