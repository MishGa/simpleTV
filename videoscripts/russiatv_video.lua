-- видеоскрипт для сайтов (4/5/20)
-- http://russia.tv https://tvkultura.ru https://www.vesti.ru
-- открывает подобные ссылки:
-- https://russia.tv/video/show/brand_id/15369/episode_id/118601/video_id/118601/
-- https://tvkultura.ru/article/show/article_id/187807/?utm_source=sharik&utm_medium=banner&utm_campaign=sharik
-- http://player.vgtrk.com/iframe/video/id/1302294/start_zoom/true/showZoomBtn/false/sid/vesti/isPlay/false/?acc_video_id=294126
-- http://player.rutv.ru/iframe/video/id/996922
-- https://www.vesti.ru/videos/show/vid/738256/
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('^https?://russia%.tv')
			and not inAdr:match('^https?://tvkultura%.ru')
			and not inAdr:match('^https?://player%.vgtrk%.com/iframe/video/')
			and not inAdr:match('^https?://player%.rutv%.ru/iframe/video/')
			and not inAdr:match('^https?://[w%.]*vesti%.ru')
		then
		 return
		end
		if inAdr:match('%.m3u8') then return end
	local logo, addTitle
	if inAdr:match('//tvkultura%.ru') then
		logo = 'https://tvkultura.ru/i/logo/standart-russiak.png?v=1'
		addTitle = 'Россия Культура'
	elseif inAdr:match('//russia%.tv') then
		logo = 'https://russia.tv/i/logo/standart-russia1.png'
		addTitle = 'Россия 1'
	else
		logo = 'https://player.vgtrk.com/images/logos2/logo_vestiru.png'
		addTitle = 'Вести.ру'
	end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.russia_video then
		m_simpleTV.User.russia_video = {}
	end
	local function Thumbs(thumbsInfo)
			if m_simpleTV.Control.MainMode ~= 0 then return end
		m_simpleTV.User.russia_video.ThumbsInfo = nil
		thumbsInfo = thumbsInfo:match('"tooltip":{.-}}')
			if not thumbsInfo then return end
		thumbsInfo = thumbsInfo:match('"high":{.-}') or thumbsInfo:match('"low":{.-}')
			if not thumbsInfo then return end
		local samplingFrequency = tonumber(thumbsInfo:match('"periodSlide":(%d+)') or 0)
		local column = tonumber(thumbsInfo:match('"column":(%d+)') or 0)
		local row = tonumber(thumbsInfo:match('"row":(%d+)') or 0)
		local thumbsPerImage = column * row
		local thumbWidth = tonumber(thumbsInfo:match('"width":(%d+)') or 0)
		local thumbHeight = tonumber(thumbsInfo:match('"height":(%d+)') or 0)
		local urlPattern = thumbsInfo:match('"url":"([^"]+)')
			if samplingFrequency == 0
				or thumbsPerImage == 0
				or thumbWidth == 0
				or thumbHeight == 0
				or not urlPattern
			then
			 return
			end
		m_simpleTV.User.russia_video.ThumbsInfo = {}
		m_simpleTV.User.russia_video.ThumbsInfo.samplingFrequency = samplingFrequency
		m_simpleTV.User.russia_video.ThumbsInfo.thumbsPerImage = thumbsPerImage
		m_simpleTV.User.russia_video.ThumbsInfo.thumbWidth = thumbWidth / column
		m_simpleTV.User.russia_video.ThumbsInfo.thumbHeight = thumbHeight / row
		m_simpleTV.User.russia_video.ThumbsInfo.urlPattern = urlPattern
		if not m_simpleTV.User.russia_video.PositionThumbsHandler then
			local handlerInfo = {}
			handlerInfo.luaFunction = 'PositionThumbs_russia_video'
			handlerInfo.regexString = '//russia\.tv/.*|//tvkultura\.ru/.*|//www\.vesti\.ru/.*|//player\.rutv\.ru/.*|//player\.vgtrk\.com/.*'
			handlerInfo.sizeFactor = m_simpleTV.User.paramScriptForSkin_thumbsSizeFactor or 0.18
			handlerInfo.backColor = m_simpleTV.User.paramScriptForSkin_thumbsBackColor or ARGB(0, 0, 0, 0)
			handlerInfo.textColor = m_simpleTV.User.paramScriptForSkin_thumbsTextColor or ARGB(255, 127, 255, 0)
			handlerInfo.glowParams = m_simpleTV.User.paramScriptForSkin_thumbsGlowParams or 'glow="7" samples="5" extent="4" color="0xB0000000"'
			handlerInfo.marginBottom = m_simpleTV.User.paramScriptForSkin_thumbsMarginBottom or 0
			handlerInfo.minImageWidth = 80
			handlerInfo.minImageHeight = 45
			m_simpleTV.User.russia_video.PositionThumbsHandler = m_simpleTV.PositionThumbs.AddHandler(handlerInfo)
		end
	end
	function PositionThumbs_russia_video(queryType, address, forTime)
		if queryType == 'testAddress' then
		 return false
		end
		if queryType == 'getThumbs' then
				if not m_simpleTV.User.russia_video.ThumbsInfo then
				 return true
				end
			local imgLen = m_simpleTV.User.russia_video.ThumbsInfo.samplingFrequency * m_simpleTV.User.russia_video.ThumbsInfo.thumbsPerImage * 1000
			local index = math.floor(forTime / imgLen)
			local t = {}
			t.playAddress = address
			t.url = m_simpleTV.User.russia_video.ThumbsInfo.urlPattern:gsub('__num__', index)
			t.httpParams = {}
			t.httpParams.extHeader = 'Referer: ' .. address
			t.elementWidth = m_simpleTV.User.russia_video.ThumbsInfo.thumbWidth
			t.elementHeight = m_simpleTV.User.russia_video.ThumbsInfo.thumbHeight
			t.startTime = index * imgLen
			t.length = imgLen
			m_simpleTV.PositionThumbs.AppendThumb(t)
		 return true
		end
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 16000)
		if not inAdr:match('/iframe/') then
			local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
				if rc ~= 200 then m_simpleTV.Http.Close(session) return end
			if inAdr:match('vesti%.ru') then
				inAdr = answer:match('<div class="air%-video__player">.-<iframe src="([^"]+)') or answer:match('<a class="article__video%-link show%-video".-data%-video%-url="([^"]+)') or answer:match('<a class="article__video%-link" href.-data%-video%-url="([^"]+)') or answer:match('<meta property="og:video:iframe" content="([^"]+)') or answer:match('<div class="article__video".-<iframe src="([^"]+)')
			else
				inAdr = answer:match('<meta property="og:video:iframe" content="([^"]+)') or answer:match('<iframe src="(http.-)"')
			end
				if not inAdr then
					m_simpleTV.Http.Close(session)
				 return
				end
		end
	local id = inAdr:match('id[/=":]+(%d+)')
		if not id then
			m_simpleTV.Http.Close(session)
		 return
		end
	local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://player.vgtrk.com/iframe/datavideo/id/' .. id})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('"auto":"([^"]+)')
		if not retAdr then return end
	answer = answer:gsub('\\"', '%%22')
	local title = answer:match('"title":"([^"]+)')
	if not title then
		title = addTitle
	else
		if m_simpleTV.Control.MainMode == 0 then
			title = unescape3(title)
			title = title:gsub('%%22', '"')
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
			local poster = answer:match('"picture":"([^"]+)') or logo
			if poster then
				m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
			end
		end
		title = addTitle .. ' - ' .. title
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	if m_simpleTV.Common.GetVlcVersion() > 3000 then
		retAdr = retAdr .. '$OPT:no-gnutls-system-trust$OPT:demux=adaptive,any$OPT:adaptive-use-access'
	end
	m_simpleTV.Control.CurrentAddress = retAdr .. '$OPT:NO-STIMESHIFT$OPT:no-spu'
	Thumbs(answer)
-- debug_in_file(retAdr .. '\n')