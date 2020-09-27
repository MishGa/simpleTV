-- видеоскрипт для сайта http://onhdrezka-download.com (30/5/20)
-- необходим: Acestream
-- открывает подобные ссылки:
-- http://onhdrezka-download.com/p/866-vnutri-igry-2019-hdrezka-studio
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('^https?://%a+hdrezka%-download%.com') then return end
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'hdrezka-download ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.3729.121 Safari/537.36')
		if not session then
			showError('1')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			showError('2')
			m_simpleTV.Http.Close(session)
		 return
		end
	local host = inAdr:match('(https?://.-)/')
	local title = answer:match('"si%-title">(.-)<') or 'hdrezka'
	local cover = answer:match('<img src="([^"]+%.png)') or answer:match('<img src="([^"]+%.jpg)')
	answer = answer:match('<div class="dwn%-links%-list">.-</div>')
		if not answer then
			showError('3')
		 return
		end
	if cover then
		cover = cover:gsub('^/', host .. '/')
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = cover, TypeBackColor = 0, UseLogo = 3, Once = 1})
		m_simpleTV.Control.ChangeChannelLogo(cover, m_simpleTV.Control.ChannelID, 'CHANGE_IF_NOT_EQUAL')
	end
	local adr, name
	local t, i = {}, 1
		for w in answer:gmatch('<a.-</a>') do
			name = w:match('>(.-)</a>')
			adr = w:match('href="(.-)"')
				if not adr or not name then break end
			t[i] = {}
			t[i].Name = name
			t[i].Address = host .. adr
			i = i + 1
		end
		if i == 1 then
			showError('4')
		 return
		end
	t = table_reverse(t)
	for i = 1, #t do
		t[i].Id = i
	end
	if i > 2 then
		local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 5000, 1)
		id = id or 1
		inAdr = t[id].Address
	else
		inAdr = t[1].Address
	end
	rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, writeinfile = true})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('5')
		 return
		end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
	local retAdr = 'torrent://' .. answer
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')