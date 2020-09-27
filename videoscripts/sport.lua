-- видеоскрипт для плейлиста "Спорт" https://ntvplus.tv (29/9/20)
-- Copyright © 2017-2020 Nexterr
-- открывает подобные ссылки:
-- http://sport.ntv/1040
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^http://sport%.ntv/%d+$') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.ntvsport then
		m_simpleTV.User.ntvsport = {}
	end
	local function GetPlst()
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL21hcGkubnR2cGx1cy50di92MS90di9jaGFubmVscz9hcHBUeXBlPWlvcw')})
			if rc ~= 200 then return end
		local t, i = {}, 1
		require 'json'
		answer = answer:gsub('%[%]', '"nil"')
		local tab = json.decode(answer)
			if not tab then return end
			while true do
					if not tab[i] then break end
				t[i] = {}
				t[i].ServerId = tab[i].streamServerId
				t[i].videoUrl = tab[i].videoUrl.multi
				if tab[i].name:match('%(HD%)$') or tab[i].name:match(' HD$') then
					t[i].hd = true
				end
				i = i + 1
			end
			if i == 1 then return end
	 return t
	end
	if not m_simpleTV.User.ntvsport.plst then
		local plst = GetPlst()
			if not plst then return end
		m_simpleTV.User.ntvsport.plst = plst
	end
	inAdr = inAdr:gsub('^http://sport%.ntv/', '')
	local retAdr, hd
		for _, v in pairs(m_simpleTV.User.ntvsport.plst) do
			if tonumber(inAdr) == tonumber(v.ServerId) then
				retAdr = v.videoUrl
				hd = v.hd
			 break
			end
		end
		if not retAdr then
			m_simpleTV.User.ntvsport = nil
		 return
		end
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then
			m_simpleTV.User.ntvsport = nil
		 return
		end
	local retAdr = answer:match('http[^\'\"<>]+%.[^<>\'\"]*')
		if not retAdr then
			m_simpleTV.User.ntvsport = nil
		 return
		end
	retAdr = retAdr:gsub('%?audio%-only.+', '')
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	local t0, i = {}, 1
		for adr in answer:gmatch('EXT%-X%-STREAM.-\n(.-)\n') do
			local res = adr:match('(%d+)p%.m3u8')
			if res and tonumber(res) ~= 720 then
				t0[i] = {}
				t0[i].Name = res .. 'p'
				t0[i].Id = tonumber(res)
				t0[i].Address = adr
				i = i + 1
			end
		end
		if i == 1 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	table.sort(t0, function(a, b) return a.Id < b.Id end)
	local hash, t = {}, {}
		for i = 1, #t0 do
			if not hash[t0[i].Name] then
				t[#t + 1] = t0[i]
				hash[t0[i].Name] = true
			end
		end
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('sport_qlty') or 5000)
	local index = #t
	if #t > 1 then
		if hd then
			t[#t + 1] = {}
			t[#t].Id = 720
			t[#t].Name = '1080p'
			t[#t].Address = t[#t - 1].Address:gsub('(%d+)p%.m3u8', '720p.m3u8')
		end
		t[#t + 1] = {}
		t[#t].Id = 5000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
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
			if m_simpleTV.User.paramScriptForSkin_buttonOk then
				t.OkButton = {ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
			end
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtParams = {LuaOnOkFunName = 'sportSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function sportSaveQuality(obj, id)
		if id > 0 then
			m_simpleTV.Config.SetValue('sport_qlty', id)
		end
	end
-- debug_in_file(t[index].Address .. '\n')