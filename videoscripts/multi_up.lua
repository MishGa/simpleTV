-- видеоскрипт для сайта http://multi-up.com (11/8/18)
-- необходимы скрипты для хостингов
-- открывает подобные ссылки:
-- http://multi-up.com/1152916
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
		if not inAdr:match('https?://multi%-up%.com/%d+') then return end
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/68.0.2785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local retAdr
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local ulei = answer:match('</h2>(.-)</ul>')
		if not ulei then return end
	local a, j = {}, 1
	local name, url
		for ww in ulei:gmatch('<li>(.-)</li>') do
			name = ww:match('">(.-)</a>')
			url = ww:match('href="(.-)"')
			a[j] = {}
			a[j].Id = j
			a[j].Name = name
			a[j].Adress = url
			j = j + 1
		end
		if j == 1 then return end
	if j > 2 then
		local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберите', 0, a, 5000, 1)
		if not id then id = 1 end
		retAdr = a[id].Adress
	else
		retAdr = a[1].Adress
	end
	m_simpleTV.Control.ChangeAdress = 'No'
	m_simpleTV.Control.CurrentAdress = retAdr
	dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
-- debug_in_file(retAdr .. '\n')