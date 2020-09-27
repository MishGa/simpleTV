-- видеоскрипт для сайта https://silatv.ru (24/5/20)
-- открывает подобные ссылки:
-- https://silatv.ru/live/
-- https://silatv.ru/video/8366
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://silatv%.ru') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local logo = 'https://fcdn.silatv.ru/static/img/sila-logo.svg'
	if m_simpleTV.Control.MainMode == 0 then
		local logo0
		if inAdr:match('/live') then
			logo0 = ''
		else
			logo0 = logo
		end
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo0, UseLogo = 1, Once = 1})
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/81.0.2785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	answer = answer:gsub('<!%-%-.-%-%->', '')
	local Adr = answer:match('http[^\'"<>]+tele%-sport%.ru/embeded/[^\'"<>]+')
	if Adr then
		rc, answer = m_simpleTV.Http.Request(session, {url = Adr, headers = 'Referer: ' .. inAdr})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
	end
	answer = answer:gsub('<!%-%-.-%-%->', '')
	local retAdr = answer:match('data%-quality="auto" src="(.-)"')
		if not retAdr then return end
	retAdr = retAdr:gsub('&amp;', '&')
	local extOpt = '$OPT:http-referrer=' .. (Adr or inAdr)
	if not inAdr:match('/live') then
		local title = answer:match('<title>(.-)</title>')
		title = title:gsub(' на сайте silatv%.ru', ''):gsub('^%s+', ''):gsub('%s+$', ''):gsub('&quot;', '"')
		if title then
			m_simpleTV.Control.CurrentTitle_UTF8 = title
		end
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
		end
		extOpt = extOpt .. '$OPT:NO-STIMESHIFT'
	end
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local base = retAdr:match('.+/')
	local i, t = 1, {}
	local adr, name
		for w in answer:gmatch('EXT%-X%-STREAM%-INF.-\n.-\n') do
			adr = w:match('\n(.-)\n')
			name = w:match('RESOLUTION=%d+x(%d+)')
				if not adr or not name then break end
			name = tonumber(name)
			if name > 300 then
				if not adr:match('^http') then
					adr = base .. adr
				end
				t[i] = {}
				t[i].Id = name
				t[i].Name = name .. 'p'
				t[i].Address = adr .. extOpt
				i = i + 1
			end
		end
		if i == 1 then
			m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('silatv_qlty') or 5000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 5000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 10000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr .. extOpt
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
			t.ExtParams = {LuaOnOkFunName = 'silatvSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function silatvSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('silatv_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')