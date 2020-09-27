-- видеоскрипт для сайта http://europaplustv.com (31/12/19)
-- открывает ссылкy:
-- http://europaplustv.com/online
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('https?://[w%.]*europaplustv%.com/online') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'europaplustv ошибка: ' .. str, showTime = 8000, color = ARGB(255, 255, 0, 0), id = 'channelName'})
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36')
		if not session then
			showError('1')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local u = {url = 'http://europaplustv.com/embed/video?online=1', headers = 'Referer: ' .. inAdr}
	local rc, answer = m_simpleTV.Http.Request(session, u)
	if rc ~= 200 then
		rc, answer = m_simpleTV.Http.Request(session, {url = u})
	end
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('2')
		 return
		end
	local retAdr = answer:match('[^\'"<>]+%.m3u8[^<>\'"]*')
		if not retAdr then
			showError('3')
		 return
		end
	retAdr = retAdr:gsub('^//', 'http://')
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('4')
		 return
		end
	local base = retAdr:match('.+/')
	local t, i = {}, 1
	local name, adr
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-%.m3u8.-)\n') do
			adr = w:match('\n(.+)')
			name = w:match('RESOLUTION=%d+x(%d+)')
				if not adr or not name then break end
			if not adr:match('^http') then
				adr = adr:gsub('^%.%./', ''):gsub('^/', '')
				adr = base .. adr
			end
			t[i] = {}
			t[i].Id = tonumber(name)
			t[i].Name = name .. 'p'
			t[i].Address = adr
			i = i + 1
		end
		if i == 1 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('europaplustv_qlty') or 5000)
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
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtParams = {LuaOnOkFunName = 'europaplustvSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function europaplustvSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('europaplustv_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')