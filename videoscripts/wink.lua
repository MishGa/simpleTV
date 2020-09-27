-- видеоскрипт для плейлиста "wink" https://wink.rt.ru (19/9/20)
-- Copyright © 2017-2020 Nexterr
-- открывает подобные ссылки:
-- https://zabava-htlive.cdn.ngenix.net/hls/CH_MATCHTVHD/variant.m3u8
-- http://hlsstr03.svc.iptv.rt.ru/hls/CH_TNTHD/variant.m3u8
-- http://rt-vlg-samara-htlive-lb.cdn.ngenix.net/hls/CH_R03_OTT_VLG_SAMARA_M1/variant.m3u8
-- ## юзер агент ##
local userAgent = 'Mozilla/5.0 (SMART-TV; Linux; Tizen 4.0.0.2) AppleWebkit/605.1.15 (KHTML, like Gecko) SamsungBrowser/9.2 TV Safari/605.1.15'
-- ## Пртокол ##
local http = 1
-- 0 - httpS
-- 1 - http
-- ## Прокси ##
local proxy = ''
-- '' - нет
--'http://217.150.200.152:8081' - (пример)
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('rt%.ru/hls/CH_')
			and not m_simpleTV.Control.CurrentAddress:match('ngenix%.net[:%d]*/hls/CH_')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	if http == 0 then
		inAdr = inAdr:gsub('^http://', 'https://')
	else
		inAdr = inAdr:gsub('^https://', 'http://')
	end
	local host = inAdr:match('https?://.-/')
	local extOpt = '$OPT:http-user-agent=' .. userAgent
	if proxy ~= '' then
		extOpt = extOpt .. '$OPT:http-proxy=' .. proxy
	end
	local session = m_simpleTV.Http.New(userAgent, proxy, false)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	inAdr = inAdr:gsub('$OPT:.+', '')
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
			adr = adr:gsub('/playlist%.', '/variant.')
			adr = adr:gsub('https?://.-/', host)
			adr = adr:gsub('%?.-$', '')
			t[i] = {}
			t[i].Id = name
			t[i].Name = (name / 1000) .. ' кбит/с'
			t[i].Address = adr .. extOpt
			i = i + 1
		end
		if i == 1 then
			m_simpleTV.Control.CurrentAddress = inAdr .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('wink_qlty') or 100000000)
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
		if m_simpleTV.Control.MainMode == 0 then
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtParams = {LuaOnOkFunName = 'winkSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function winkSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('wink_qlty', tostring(id))
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')