-- видеоскрипт для сайта https://vimeo.com (6/9/20)
-- Copyright © 2017-2020 Nexterr
-- открывает подобные ссылки:
-- https://vimeo.com/channels/musicvideoland/368152561
-- https://vimeo.com/channels/staffpicks/204150149?autoplay=1
-- https://vimeo.com/156942975
-- https://vimeo.com/2196013
-- https://player.vimeo.com/video/344303837?wmode=transparent$OPT:http-referrer=https://www.clubbingtv.com/video/play/4194/live-dj-set-with-dan-lo/
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[%a%.]*vimeo%.com/.+') then return end
	local urlAdr = m_simpleTV.Control.CurrentAddress
	local inAdr = urlAdr:gsub('%$OPT:.-$', '')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	if not inAdr:match('player%.vimeo%.com/') then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = 'https://raw.githubusercontent.com/Nexterr/simpleTV.img/master/vimeo.png', UseLogo = 1, Once = 1})
		end
	end
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0'
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'vimeo ошибка: ' .. str, showTime = 1000 * 5, color = 0xffff1000, id = 'vimeo'})
	end
	local id = inAdr:match('vimeo%.com/(%d+)') or inAdr:match('/video/(%d+)') or inAdr:match('/channels/.-/(%d+)')
		if not id then
			showError('1')
		 return
		end
	local session = m_simpleTV.Http.New(userAgent)
		if not session then
			showError('2')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.vimeo then
		m_simpleTV.User.vimeo = {}
	end
	local function Thumbs(tab)
			if m_simpleTV.Control.MainMode ~= 0 then return end
		m_simpleTV.User.vimeo.ThumbsInfo = nil
			if not tab.request.thumb_preview
				or not tab.request.thumb_preview.url
				or not tab.request.thumb_preview.frame_width
				or not tab.request.thumb_preview.frame_height
				or not tab.video.duration
			then
			 return
			end
		m_simpleTV.User.vimeo.ThumbsInfo = {}
		m_simpleTV.User.vimeo.ThumbsInfo.duration = tab.video.duration
		m_simpleTV.User.vimeo.ThumbsInfo.urlPattern = tab.request.thumb_preview.url
		m_simpleTV.User.vimeo.ThumbsInfo.thumbHeight = tab.request.thumb_preview.frame_height
		m_simpleTV.User.vimeo.ThumbsInfo.thumbWidth = tab.request.thumb_preview.frame_width
		if not m_simpleTV.User.vimeo.PositionThumbsHandler then
			local handlerInfo = {}
			handlerInfo.luaFunction = 'PositionThumbs_vimeo'
			handlerInfo.regexString = '//vimeo\.com/.*'
			handlerInfo.sizeFactor = 0.18
			handlerInfo.backColor = 0xf0000000
			handlerInfo.glowParams = 'glow="7" samples="5" extent="4" color="0xB0000000"'
			handlerInfo.minImageWidth = 80
			handlerInfo.minImageHeight = 45
			m_simpleTV.User.vimeo.PositionThumbsHandler = m_simpleTV.PositionThumbs.AddHandler(handlerInfo)
		end
	end
	function PositionThumbs_vimeo(queryType, address, forTime)
		if queryType == 'testAddress' then
		 return false
		end
		if queryType == 'getThumbs' then
				if not m_simpleTV.User.vimeo.ThumbsInfo then
				 return true
				end
			local t = {}
			t.playAddress = address
			t.url = m_simpleTV.User.vimeo.ThumbsInfo.urlPattern
			t.httpParams = {}
			t.httpParams.userAgent = userAgent
			t.httpParams.extHeader = 'Referer: ' .. address
			t.elementWidth = m_simpleTV.User.vimeo.ThumbsInfo.thumbWidth
			t.elementHeight = m_simpleTV.User.vimeo.ThumbsInfo.thumbHeight
			t.startTime = 0
			t.length = m_simpleTV.User.vimeo.ThumbsInfo.duration * 1000
			m_simpleTV.PositionThumbs.AppendThumb(t)
		 return true
		end
	end
	function vimeoSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('vimeo_qlty', id)
	end
	local headers = 'Referer: ' .. (urlAdr:match('$OPT:http%-referrer=(.+)') or inAdr)
	local rc, answer, config_url
	if not inAdr:match('player%.vimeo%.com/') then
		rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, headers = headers})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
				showError('3 - ' .. rc)
			 return
			end
		config_url = answer:match('"config_url":"([^"]+)') or answer:match('data%-config%-url="([^"]+)')
			if not config_url then
				showError('4')
			 return
			end
		config_url = config_url:gsub('\\/', '/'):gsub('&amp;', '&')
	else
		config_url = 'https://player.vimeo.com/video/' .. id .. '/config'
	end
	rc, answer = m_simpleTV.Http.Request(session, {url = config_url, headers = headers})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('5 - ' .. rc)
		 return
		end
	answer = answer:gsub(':%s*%[%]', ':""')
	answer = answer:gsub('%[%]', ' ')
	require 'json'
	local tab = json.decode(answer)
		if not tab
			or not tab.video
			or not tab.request
			or not tab.request.files
			or not tab.request.files.progressive
		then
			showError('6')
		 return
		end
	local title = tab.video.title
	if not inAdr:match('player%.vimeo%.com/') then
		local addTitle = 'vimeo'
		if not title then
			title = addTitle
		else
			if m_simpleTV.Control.MainMode == 0 then
				m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
				local thumbs
				if tab.video.thumbs and tab.video.thumbs.base then
					thumbs = tab.video.thumbs.base .. '?mw=240&q=85'
				end
				thumbs = thumbs or 'https://image.flaticon.com/icons/png/128/889/889149.png'
				m_simpleTV.Control.ChangeChannelLogo(thumbs, m_simpleTV.Control.ChannelID)
			end
			title = addTitle .. ' - ' .. title
		end
	end
	local referer = tab.request.referrer or inAdr
	local extOpt = '$OPT:NO-STIMESHIFT$OPT:http-user-agent=' .. userAgent .. '$OPT:http-referrer=' .. referer
	local t, i = {}, 1
		while true do
				if not tab.request.files.progressive[i] then break end
			t[i] = {}
			t[i].Id = tab.request.files.progressive[i].height
			t[i].Name = tab.request.files.progressive[i].quality
			t[i].Address = tab.request.files.progressive[i].url:gsub('%?.-$', '') .. extOpt
			i = i + 1
		end
		if i == 1 then
			showError('7')
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('vimeo_qlty') or 5000)
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
			t.ExtParams = {LuaOnOkFunName = 'vimeoSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	if not inAdr:match('player%.vimeo%.com/') then
		m_simpleTV.Control.CurrentTitle_UTF8 = title
	end
	Thumbs(tab)
-- debug_in_file(t[index].Address .. '\n')