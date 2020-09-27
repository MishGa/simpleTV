-- видеоскрипт для видеобазы "Wink" https://wink.rt.ru (3/6/20)
-- открывает подобные ссылки:
-- http://vod-ott.svc.iptv.rt.ru/hls/sd_2017_Istorii_prizrakov__q0w2_film/variant.m3u8
-- https://zabava-htvod.cdn.ngenix.net/hls/hd_1997_Zvezdnyy_desant__q0w0_ar6e6_film/variant.m3u8
-- ## Прокси ##
local proxy = ''
-- '' - нет
--'http://217.150.200.152:8081' - (пример)
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://vod%-ott%.svc%.iptv%.rt%.ru/')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://zabava%-htvod%.cdn%.ngenix%.net/')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local fromScr
	if inAdr:match('&fromScr=true') then
		fromScr = true
		inAdr = inAdr:gsub('%?&isPlst=.-$', '')
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	if not inAdr:match('&kinopoisk') then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local userAgent = 'Mozilla/5.0 (SMART-TV; Linux; Tizen 4.0.0.2) AppleWebkit/605.1.15 (KHTML, like Gecko) SamsungBrowser/9.2 TV Safari/605.1.15'
	inAdr = inAdr:gsub('&kinopoisk', '')
	local extOpt = '$OPT:NO-STIMESHIFT$OPT:http-user-agent=' .. userAgent
	if proxy ~= '' then
		extOpt = extOpt .. '$OPT:http-proxy=' .. proxy
	end
	if fromScr then
		extOpt = extOpt .. '$OPT:NO-SEEKABLE'
	end
	local session = m_simpleTV.Http.New(userAgent, proxy, false)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	inAdr = inAdr:gsub('%$OPT:.+', '')
	inAdr = inAdr:gsub('bw%d+/', '')
	inAdr = inAdr:gsub('%?.-$', '')
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	answer = answer .. '\n'
	local t, i = {}, 1
	local name, adr
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-\n.-)\n') do
			adr = w:match('\n(.+)')
			name = w:match('BANDWIDTH=(%d+)')
				if not adr or not name then break end
			name = tonumber(name)
			t[i] = {}
			t[i].Id = name
			t[i].Name = (name / 1000) .. ' кбит/с'
			t[i].Address = adr .. extOpt
			i = i + 1
		end
		if i == 1 then return end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('wink_vod_qlty') or 100000000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 100000000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 500000000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = inAdr .. extOpt
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
		if not fromScr then
			if m_simpleTV.Control.MainMode == 0 then
				t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
				t.ExtParams = {LuaOnOkFunName = 'wink_vodSaveQuality'}
				m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
			end
		end
	end
	if fromScr then
		local t = m_simpleTV.Control.GetCurrentChannelInfo()
		if t
			and t.MultiHeader
			and t.MultiName
		then
			title = t.MultiHeader .. ': ' .. t.MultiName
		end
		m_simpleTV.Control.SetTitle(title)
		m_simpleTV.Control.CurrentTitle_UTF8 = title
		m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function wink_vodSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('wink_vod_qlty', tostring(id))
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')