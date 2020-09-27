-- видеоскрипт для сайта https://www.redtube.com (6/1/20)
-- открывает подобные ссылки:
-- https://ru.redtube.com/26159981
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAdress:match('^https?://[%a%.]*redtube%.com/%d') then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local logo = 'https://ei.rdtcdn.com/www-static/cdn_files/redtube/images/pc/logo/redtube_logo.png'
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.redtube then
		m_simpleTV.User.redtube = {}
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'redtube ошибка: ' .. str, showTime = 8000, color = ARGB(255, 255, 0, 0), id = 'channelName'})
	end
	local function Thumbs(thumbsInfo)
			if m_simpleTV.Control.MainMode ~= 0 then return end
		m_simpleTV.User.redtube.ThumbsInfo = nil
		thumbsInfo = thumbsInfo:match('thumbs:.-},')
			if not thumbsInfo then return end
		local samplingFrequency = tonumber(thumbsInfo:match('samplingFrequency:%s*(%d+)') or 0)
		local thumbsPerImage = 25
		local thumbWidth = tonumber(thumbsInfo:match('thumbWidth:%s*"(%d+)') or 0)
		local thumbHeight = tonumber(thumbsInfo:match('thumbHeight:%s*"(%d+)') or 0)
		local urlPattern = thumbsInfo:match('urlPattern:%s*"([^"]+)')
			if samplingFrequency == 0
				or thumbsPerImage == 0
				or thumbWidth == 0
				or thumbHeight == 0
				or not urlPattern
			then
			 return
			end
		m_simpleTV.User.redtube.ThumbsInfo = {}
		m_simpleTV.User.redtube.ThumbsInfo.currentAddress = inAdr
		m_simpleTV.User.redtube.ThumbsInfo.samplingFrequency = samplingFrequency
		m_simpleTV.User.redtube.ThumbsInfo.thumbsPerImage = thumbsPerImage
		m_simpleTV.User.redtube.ThumbsInfo.thumbWidth = thumbWidth
		m_simpleTV.User.redtube.ThumbsInfo.thumbHeight = thumbHeight
		m_simpleTV.User.redtube.ThumbsInfo.urlPattern = urlPattern:gsub('\\/', '/')
		if not m_simpleTV.User.redtube.PositionThumbsHandler then
			local handlerInfo = {}
			handlerInfo.luaFunction = 'PositionThumbs_redtube'
			handlerInfo.regexString = '\.redtube\.com/.*'
			handlerInfo.sizeFactor = 0.18
			handlerInfo.backColor = ARGB(200, 0, 0, 0)
			handlerInfo.glowParams = 'glow="7" samples="5" extent="4" color="0xB0000000"'
			handlerInfo.minImageWidth = 80
			handlerInfo.minImageHeight = 45
			m_simpleTV.User.redtube.PositionThumbsHandler = m_simpleTV.PositionThumbs.AddHandler(handlerInfo)
		end
	end
	function redtubeSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('redtube_qlty', id)
	end
	function PositionThumbs_redtube(queryType, address, forTime)
		if queryType == 'testAddress' then
		 return false
		end
		if queryType == 'getThumbs' then
				if not m_simpleTV.User.redtube.ThumbsInfo then
				 return true
				end
			local imgLen = m_simpleTV.User.redtube.ThumbsInfo.samplingFrequency * m_simpleTV.User.redtube.ThumbsInfo.thumbsPerImage * 1000
			local index = math.floor(forTime / imgLen)
			local t = {}
			t.playAddress = address
			t.url = m_simpleTV.User.redtube.ThumbsInfo.urlPattern:gsub('{.-}', index)
			t.httpParams = {}
			t.httpParams.userAgent = userAgent
			-- t.httpParams.proxy
			t.httpParams.extHeader = 'Referer: ' .. address
			t.elementWidth = m_simpleTV.User.redtube.ThumbsInfo.thumbWidth
			t.elementHeight = m_simpleTV.User.redtube.ThumbsInfo.thumbHeight
			t.startTime = index * imgLen
			t.length = imgLen
			m_simpleTV.PositionThumbs.AppendThumb(t)
		 return true
		end
	end
	local session = m_simpleTV.Http.New(userAgent)
		if not session then
			showError('1')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('2 - ' .. rc)
		 return
		end
	local answer0 = answer:match('mediaDefinition:%s*(%[[^%]]+)')
		if not answer0 then
			showError('3')
		 return
		end
	local title = answer:match('title" content="([^"]+)')
	local addTitle = 'REDTUBE'
	if not title then
		title = addTitle
	else
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
			local poster = answer:match('poster:%s*"([^"]+)') or logo
			poster = poster:gsub('\\/', '/')
			m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
		end
		title = addTitle .. ' - ' .. title
	end
	local extOpt = '$OPT:NO-STIMESHIFT'
	local t, i = {}, 1
	local name, adr
		for w in answer0:gmatch('"defaultQuality([^}]+)') do
			adr = w:match('"videoUrl":"([^"]+)')
			name = w:match('"quality":"(%d+)')
				if adr and name then
					t[i] = {}
					t[i].Id = tonumber(name)
					t[i].Name = name .. 'p'
					t[i].Address = adr:gsub('\\/', '/') .. extOpt
					i = i + 1
				end
		end
		if i == 1 then
			showError('4')
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('redtube_qlty') or 5000)
	local index = #t
	if #t > 1 then
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
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtParams = {LuaOnOkFunName = 'redtubeSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	Thumbs(answer)
-- debug_in_file(t[index].Address .. '\n')