-- видеоскрипт для сайта https://media.mediavitrina.ru (28/5/20)
-- необходимы скрипты: russiatv
-- открывает:
-- открывает подобные ссылки:
-- https://player.mediavitrina.ru/ctc_ext/ontvtimeru_web/player.html
-- https://player.mediavitrina.ru/kultura/limehd_web/player.html
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://player%.mediavitrina%.ru') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'mediavitrina ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.3987.122 Safari/537.36')
		if not session then
			showError('0')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('1')
		 return
		end
	local url = answer:match('http[^\'"<>]+as_array%.json')
		if not url then
			m_simpleTV.Http.Close(session)
			local live_id = answer:match('live_id = \'(%d+)')
			local sid = answer:match('sid = \'(%w+)')
				if not live_id or not sid then
					showError('2')
				 return
				end
			local retAdr = 'https://player.vgtrk.com/iframe/datalive/id/' .. live_id .. '/sid/' .. sid
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = retAdr
			dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
		 return
		end
	local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://media.mediavitrina.ru/get_token'})
		if rc ~= 200 then
			showError('3')
			m_simpleTV.Http.Close(session)
		 return
		end
	local token = answer:match('"token":"([^"]+)')
		if not token then
			showError('4')
		 return
		end
	url = url .. '?token=' .. token
	rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then
			showError('5')
			m_simpleTV.Http.Close(session)
		 return
		end
	local retAdr = answer:match('"hls":%["([^"]+)')
		if not retAdr then
			showError('6')
		 return
		end
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('7')
		 return
		end
	local t, i = {}, 1
	local name, adr
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-\n.-)\n') do
			adr = w:match('\n(.+)')
			name = w:match('BANDWIDTH=(%d+)')
				if not adr or not name then break end
			name = tonumber(name)
			t[i] = {}
			t[i].Id = name
			t[i].Name = math.ceil(name / 100000) * 100 .. ' кбит/с'
			t[i].Address = adr
			i = i + 1
		end
		if i == 1 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('mediavitrina_qlty') or 5000000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 5000000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 10000000
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
			t.ExtParams = {LuaOnOkFunName = 'mediavitrinaSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function mediavitrinaSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('mediavitrina_qlty', tostring(id))
	end
-- debug_in_file(t[index].Address .. '\n')