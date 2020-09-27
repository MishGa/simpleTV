-- видеоскрипт для открытия плейлистов с диска (9/6/20)
-- необходимы скрипты: youtube
-- открывает файлы с расширением m3u, m3u8, pls, dpl, asx, xspf, xml, kpl, zpl, aimppl4, mpcpl, Enigma2
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^.:') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local adrEx = inAdr:gsub('%..-$', string.lower)
		if not adrEx:match('%.m3u8?$')
			and not adrEx:match('%.pls$')
			and not adrEx:match('%.dpl$')
			and not adrEx:match('%.asx$')
			and not adrEx:match('%.xspf$')
			and not adrEx:match('%.xml$')
			and not adrEx:match('%.kpl$')
			and not adrEx:match('%.zpl$')
			and not adrEx:match('%.aimppl4$')
			and not adrEx:match('%.mpcpl$')
			and not adrEx:match('%.tv$')
		then
		 return
		end
		if adrEx:match('%.tv$') and not (inAdr:match('bouquet') or inAdr:match('BOUQUET')) then return end
	require 'ex'
	require 'lfs'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local file = io.open(inAdr, 'rb')
		if not file then return end
	local list = file:read('*a')
	file:close()
	list = list:gsub(string.char(239, 187, 191), '')
	local answer = list
	if m_simpleTV.Common.isUTF8(list) == false then
		answer = m_simpleTV.Common.multiByteToUTF8(list)
		if answer:len() < 15 then
			answer = m_simpleTV.Common.UTF16ToUTF8(list)
		end
	end
	answer = answer .. '\n'
	local function trim(s)
	 return (s:gsub('^%s*(.-)%s*$', '%1'))
	end
	local function unescape_html(str)
		str = str:gsub('u0026', '&')
		str = str:gsub('&#39;', '\'')
		str = str:gsub('&ndash;', "-")
		str = str:gsub('&#8217;', '\'')
		str = str:gsub('&raquo;', '"')
		str = str:gsub('&laquo;', '"')
		str = str:gsub('&lt;', '<')
		str = str:gsub('&gt;', '>')
		str = str:gsub('&quot;', '"')
		str = str:gsub('&apos;', "'")
		str = str:gsub('&#(%d+);', function(n) return string.char(n) end)
		str = str:gsub('&#x(%d+);', function(n) return string.char(tonumber(n, 16)) end)
		str = str:gsub('&amp;', '&') -- Be sure to do this after all others
	 return str
	end
	local function ShowInfo(s)
		local q = {}
			q.once = 1
			q.zorder = 0
			q.cx = 0
			q.cy = 0
			q.id = 'AK_INFO_TEXT'
			q.class = 'TEXT'
			q.align = 0x0202
			q.top = 0
			q.color = 0xFFFFFFF0
			q.font_italic = 0
			q.font_addheight = 6
			q.padding = 20
			q.textparam = 1 + 4
			q.text = s
			q.background = 0
			q.backcolor0 = 0x90006496
		m_simpleTV.OSD.AddElement(q)
		if m_simpleTV.Common.WaitUserInput(5000) == 1 then
			m_simpleTV.OSD.RemoveElement('AK_INFO_TEXT')
		end
		m_simpleTV.OSD.RemoveElement('AK_INFO_TEXT')
	end
	local function clean_name(s)
		s = m_simpleTV.Common.fromPercentEncoding(s)
		s = unescape_html(s)
		s = trim(s)
	 return s
	end
	local function clean_adr(s)
 		if s:match('%|') then
			s = s:gsub('"', '')
			s = s:gsub('%%22', '')
			s = s:gsub('%|user%-agent', '$OPT:http-user-agent')
			s = s:gsub('%|X%-Forwarded%-For=', '$OPT:http-ext-header=X-Forwarded-For:')
			s = s:gsub('%|Referer=', '$OPT:http-referrer=')
			s = s:gsub('%|Cookie=', '$OPT:http-ext-header=cookie:')
			s = s:gsub('%|[^$]*', '')
		end
		s = unescape_html(s)
		s = trim(s)
	 return s
	end
	function SavePlst_playlists()
		if m_simpleTV.User.playlists.Table and m_simpleTV.User.playlists.header then
			local t = m_simpleTV.User.playlists.Table
			local header = m_simpleTV.User.playlists.header
			local adr, name
			local m3ustr = '#EXTM3U $ExtFilter="playlists" $BorpasFileFormat="1"\n'
				for i = 1, #t do
					name = t[i].Name
					adr = t[i].Address:gsub('%$OPT.+', '')
					m3ustr = m3ustr .. '#EXTINF:-1 group-title="' .. header .. '",' .. name .. '\n' .. adr .. '\n'
				end
			header = m_simpleTV.Common.UTF8ToMultiByte(header)
			local fileEnd = ' (playlists ' .. os.date('%d.%m.%y') ..').m3u8'
			local folder = m_simpleTV.Common.GetMainPath(2) .. m_simpleTV.Common.UTF8ToMultiByte('сохраненые плейлисты/')
			lfs.mkdir(folder)
			local folderAk = folder .. 'Playlists/'
			lfs.mkdir(folderAk)
			local filePath = folderAk .. header .. fileEnd
			local fhandle = io.open(filePath, 'w+')
			if fhandle then
				fhandle:write(m3ustr)
				fhandle:close()
				ShowInfo('плейлист сохранен в "m3u8" файл\n' .. m_simpleTV.Common.multiByteToUTF8(header) .. '\nв папку\n' .. m_simpleTV.Common.multiByteToUTF8(folderAk))
			else
				ShowInfo('невозможно сохранить плейлист')
			end
		end
	end
	local t, i = {}, 1
	local title, adr
	if adrEx:match('%.m3u8?$') then
			if answer:match('%#EXT%-X%-VERSION')
				or answer:match('%#EXT%-X%-MEDIA-SEQUENCE')
				or answer:match('%#EXT%-X%-TARGETDURATION')
			then
				m_simpleTV.OSD.ShowMessageT({text = 'не плейлист', color = 0xffff1000, showTime = 1000 * 5, id = 'channelName'})
			 return
			end
		answer = answer:gsub('\n%s*\n', '%\n')
		answer = answer:gsub('%#EXTINF:', '$title:')
		answer = answer:gsub('%#EXT.-\n', '')
		answer = answer:gsub('group%-title=".-"', '')
			for z in answer:gmatch('%$title:.-\n.-\n') do
				title = z:match(',(.-)\n')
				adr = z:match('\n(.-)\n')
					if not title or not adr then break end
				t[i] = {}
				t[i].Name = title
				t[i].Address = adr
				i = i + 1
			end
			if i == 1 then
				for z in answer:gmatch('%a+:.-\n') do
					t[i] = {}
					t[i].Name = z
					t[i].Address = z
					i = i + 1
				end
			end
				if i == 1 then return end
	end
	if adrEx:match('%.pls$')
		or adrEx:match('%.kpl$')
	then
			for z in answer:gmatch('File.-Title.-\n') do
				title = z:match('Title%d+=(.-)\n')
				adr = z:match('File%d+=(.-)\n')
					if not title or not adr then break end
				if title == '' then
					title = adr
				end
				t[i] = {}
				t[i].Name = title
				t[i].Address = adr
				i = i + 1
			end
				if i == 1 then
					for z in answer:gmatch('File%d+=(.-)\n') do
						t[i] = {}
						t[i].Name = z
						t[i].Address = z
						i = i + 1
					end
				end
					if i == 1 then return end
	end
	if adrEx:match('%.dpl$') then
			for z in answer:gmatch('%d+%*file.-title.-\n') do
				title = z:match('title%*(.-)\n')
				adr = z:match('file%*(.-)\n')
					if not title or not adr then break end
				t[i] = {}
				t[i].Name = title
				t[i].Address = adr
				i = i + 1
			end
				if i == 1 then return end
	end
	if adrEx:match('%.asx$') then
			answer = answer:gsub('<.-"', string.lower)
			answer = answer:gsub('</.->', string.lower)
			for z in answer:gmatch('<entry>.-</entry>') do
				adr = z:match('href%s*=%s*"(.-)"')
					if not adr then break end
				title = z:match('<title>%s*"(.-)"') or z:match('<title>(.-)</title>') or adr
				t[i] = {}
				t[i].Name = title
				t[i].Address = adr
				i = i + 1
			end
				if i == 1 then return end
	end
	if adrEx:match('%.xspf$') then
			for z in answer:gmatch('<track>.-</track>') do
				adr = z:match('<location>(.-)</location>')
					if not adr then break end
				title = z:match('<annotation>%s*Stream Title:(.-)\n') or z:match('<title>(.-)</title>') or adr
				t[i] = {}
				t[i].Name = title
				t[i].Address = adr
				i = i + 1
			end
				if i == 1 then return end
			if i == 2 and title == adr then
				local name = answer:match('<title>(.-)</title>')
				if name and name ~= '' then
					t[1].Name = name
				end
			end
	end
	if adrEx:match('%.xml$') then
			for z in answer:gmatch('<channel>.-</channel>') do
				title = z:match('<title>(.-)</title>')
				adr = z:match('<stream_url>(.-)</stream_url>')
					if not title or not adr then break end
				title = title:gsub('%<!%[CDATA%[(.-)%]%]%>', '%1' .. '')
				adr = adr:gsub('%<!%[CDATA%[(.-)%]%]%>', '%1' .. '')
				t[i] = {}
				t[i].Name = title
				t[i].Address = adr
				i = i + 1
			end
				if i == 1 then return end
	end
	if adrEx:match('%.zpl$') then
			for z in answer:gmatch('nm=.-tt=.-\n') do
				title = z:match('tt=(.-)\n')
				adr = z:match('nm=(.-)\n')
					if not title or not adr then break end
				t[i] = {}
				t[i].Name = title
				t[i].Address = adr
				i = i + 1
			end
				if i == 1 then return end
	end
	if adrEx:match('%.aimppl4$') then
		answer = answer:gsub('\n%-.-\n', '%\n')
			for z in answer:gmatch('%a+:.-|.-|.-\n') do
				title = z:match('|(.-)|')
				adr = z:match('(.-)|')
					if not adr then break end
				if title == '' then
					title = adr
				end
				t[i] = {}
				t[i].Name = title
				t[i].Address = adr
				i = i + 1
			end
				if i == 1 then return end
	end
	if adrEx:match('%.mpcpl$') then
			for z in answer:gmatch('%d+,type,0.-filename,.-\n') do
				title = z:match('%d+,label,(.-)\n') or i
				adr = z:match('%d+,filename,(.-)\n')
					if not adr then break end
				t[i] = {}
				t[i].Name = title
				t[i].Address = adr
				i = i + 1
			end
				if i == 1 then return end
	end
	if adrEx:match('%.tv$') then
		local titleEsc
			for z in answer:gmatch('#SERVICE.-#DESCRIPTION.-\n') do
				adr = z:match('#SERVICE %w+:%w+:%w+:%w+:%w+:%w+:%w+:%w+:%w+:%w+:(.-)\n')
				title = z:match('#DESCRIPTION (.-)\n')
					if not adr or not title then break end
				titleEsc = escape(':' .. title)
				titleEsc = titleEsc:gsub('%%', '%%%%')
				adr = escape(adr)
				adr = adr:gsub(titleEsc, '')
				adr = unescape(adr)
				adr = m_simpleTV.Common.fromPercentEncoding(adr)
				t[i] = {}
				t[i].Name = title
				t[i].Address = adr
				i = i + 1
			end
				if i == 1 then return end
	end
	local ytPlst = true
	local num = false
	local videoId
	local name
	local isinfoPanel = true
	local infoPanel = m_simpleTV.Config.GetValue('mainOsd/showTimeInfoPanel', 'simpleTVConfig') or 0
	if tostring(infoPanel) == '0' then
		isInfoPanel = false
	end
	local t0, j = {}, 1
		for i = 1, #t do
			if not t[i].Address:match('^.:') then
				t0[j] = {}
				t0[j].Name = clean_name(t[i].Name)
				t0[j].Address = clean_adr(t[i].Address)
				if t0[j].Address:match('^https?://[%a%.]*youtu[%.combe]') then
					videoId = t0[j].Address:match('v=(.+)') or t0[j].Address:match('youtu%.be/(.+)')
					if videoId then
						videoId = videoId:sub(1, 11)
						t0[1].videoId = videoId
						t0[j].Address = 'https://www.youtube.com/watch?v=' .. videoId .. '&isPlst=true'
						if isinfoPanel == true then
							t0[j].InfoPanelLogo = 'https://i.ytimg.com/vi/' .. videoId .. '/default.jpg'
							t0[j].InfoPanelName = t0[j].Name
							t0[j].InfoPanelTitle = ' '
							t0[j].InfoPanelShowTime = 8000
							t0[j].InfoPanelDesc = '💢 https://www.youtube.com/watch?v=' .. videoId
						end
					else
						ytPlst = false
					end
				else
					if ytPlst == true then
						ytPlst = false
					end
				end
				if num == false then
					local n = t0[j].Name:match('^%d+')
					if n and j == tonumber(n) then
						num = false
					else
						num = true
					end
				end
				if t0[j].Address:match('pcradio%.ru') then
					t0[j].Address = t0[j].Address .. '$OPT:http-user-agent=pcradio'
				end
				t0[j].Id = j
				j = j + 1
			end
		end
		if j == 1 then
			m_simpleTV.OSD.ShowMessageT({text = 'локальные ссылки в плейлисте\nне поддерживаются', color = 0xffff1000, showTime = 1000 * 5, id = 'channelName'})
		 return
		end
	local title = m_simpleTV.Common.multiByteToUTF8(inAdr)
	title = title:gsub('.+[\\/](.+)%..-$', '%1')
	title = title:gsub('%s+', ' ')
	title = trim(title)
		if ytPlst == true then
			if not m_simpleTV.User then
				m_simpleTV.User = {}
			end
			if not m_simpleTV.User.YT then
				m_simpleTV.User.YT = {}
			end
			m_simpleTV.Control.ChangeChannelLogo('https://i.ytimg.com/vi/' .. t0[1].Address:match('watch%?v=([^&]+)') .. '/hqdefault.jpg', m_simpleTV.Control.ChannelID, 'CHANGE_IF_NOT_EQUAL')
			m_simpleTV.User.YT.Plst = t0
			m_simpleTV.User.YT.isVideo = false
			m_simpleTV.User.YT.plstHeader = title
			m_simpleTV.User.YT.ChTitleForSave = nil
			m_simpleTV.User.YT.AddToBaseUrlinAdr = m_simpleTV.Common.multiByteToUTF8(inAdr)
			t0.ExtParams = {FilterType = 1, AutoNumberFormat = '%1. %2', LuaOnCancelFunName = 'OnMultiAddressCancel_YT'}
			if m_simpleTV.User.paramScriptForSkin_buttonOk then
				t0.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
			end
			if m_simpleTV.User.paramScriptForSkin_buttonOptions then
				t0.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'Qlty_YT()'}
			else
				t0.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_YT()'}
			end
			if m_simpleTV.User.paramScriptForSkin_buttonPlst then
				t0.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonPlst, ButtonScript = [[
						m_simpleTV.Control.ExecuteAction(37)
						m_simpleTV.Control.ChangeAddress = 'No'
						m_simpleTV.Control.CurrentAddress = 'https://www.youtube.com/channel/' .. m_simpleTV.User.YT.chId .. '&restart'
						dofile(m_simpleTV.MainScriptDir .. 'user\\video\\youtube.lua')
					]]}
			else
				t0.ExtButton1 = {ButtonEnable = true, ButtonName = '📋', ButtonScript = [[
						m_simpleTV.Control.ExecuteAction(37)
						m_simpleTV.Control.ChangeAddress = 'No'
						m_simpleTV.Control.CurrentAddress = 'https://www.youtube.com/channel/' .. m_simpleTV.User.YT.chId .. '&restart'
						dofile(m_simpleTV.MainScriptDir .. 'user\\video\\youtube.lua')
					]]}
			end
			m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t0, 10000)
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = t0[1].Address
			dofile(m_simpleTV.MainScriptDir .. 'user\\video\\youtube.lua')
		 return
		end
	for r = 1, #t do
		t0[r].Address = t0[r].Address .. '$OPT:NO-STIMESHIFT'
	end
	if #t > 1 then
		if not m_simpleTV.User then
			m_simpleTV.User = {}
		end
		if not m_simpleTV.User.playlists then
			m_simpleTV.User.playlists = {}
		end
		m_simpleTV.User.playlists.Table = t0
		m_simpleTV.User.playlists.header = title
		t0.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		t0.ExtButton0 = {ButtonEnable = true, ButtonName = '💾', ButtonScript = 'SavePlst_playlists()'}
		local FilterType
		if #t > 10 then
			FilterType = 1
		end
		if num == true and #t > 10 then
			num = '%1. %2'
		end
		t0.ExtParams = {AutoNumberFormat = num, FilterType = FilterType}
		m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t0, 30000)
	else
		m_simpleTV.Control.CurrentTitle_UTF8 = t[1].Name
	end
-- debug_in_file(title .. '\n')