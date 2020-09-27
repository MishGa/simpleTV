-- видеоскрипт для сайта https://www.twitch.tv (18/5/20)
-- открывает подобные ссылки:
-- https://www.twitch.tv/jonnykuik
-- https://www.twitch.tv/SpeedrunHypeTV
-- https://www.twitch.tv/videos/124888396
-- https://www.twitch.tv/beyondthesummit/clip/NastyAbstemiousHareTTours
-- https://clips.twitch.tv/NastyAbstemiousHareTTours
-- https://www.twitch.tv/videos/478330615?filter=archives&sort=time
-- https://clips.twitch.tv/embed?clip=InquisitiveBreakableYogurtJebaited
-- https://m.twitch.tv/rossbroadcast/clip/ConfidentBraveHumanChefFrank
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[%w%.]*twitch%.tv/.+') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'twitch ошибка: ' .. str, showTime = 1000 * 5, color = 0xffff1000, id = 'channelName'})
	end
		if m_simpleTV.Common.GetVersion() < 820 then
			showError('это устаревшая версия simpleTV ['.. select(2, m_simpleTV.Common.GetVersion()) .. ']\nнеобходима 0.5.0 B10 или новее')
		 return
		end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = 'https://icon-library.net/images/twitch-icon-transparent-background/twitch-icon-transparent-background-0.jpg', UseLogo = 1, Once = 1})
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.3945.138 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local function title(adr, client)
		local rc, answer = m_simpleTV.Http.Request(session, {url = adr, headers = 'client-id: ' .. client})
			if rc ~= 200 then
			 return 'twitch', nil
			end
		local banner
		local addTitle = 'twitch'
		local title = answer:match('"title":"([^"]+)') or answer:match('"display_name":"([^"]+)')
		if not title then
			title = addTitle
		else
			if m_simpleTV.Control.MainMode == 0 then
				m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
				local logo = answer:match('"logo":"([^"]+)') or answer:match('"preview":"([^"]+)') or answer:match('"thumbnail_url":"([^"]+)')
				if logo then
					m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
				end
				banner = answer:match('"video_banner":"([^"]+)') or answer:match('"profile_banner":"([^"]+)')
			end
			title = addTitle .. ' - ' .. title
		end
	 return title, banner
	end
	require 'json'
	inAdr = inAdr:gsub('embed%?clip=', '')
	inAdr = inAdr:gsub('[%?&].-$', '')
	inAdr = inAdr:gsub('[%s/]+$', '')
	local client_id = 'kimne78kx3ncx6brgo4mv6wki5h1ko'
	local id = inAdr:match('([^/]+)$')
	local retAdr, types, token, sig, url
	if inAdr:match('/videos?/') then
		types = 'vods'
	elseif inAdr:match('/clip/') or inAdr:match('clips%.twitch') then
		types = 'clips'
	else
		types = 'channels'
	end
	if types ~= 'clips' then
		local headers = 'x-requested-with: XMLHttpRequest\nclient-id: ' .. client_id .. '\nReferer: ' .. inAdr
		retAdr = 'https://api.twitch.tv/api/' .. types .. '/' .. id .. '/access_token?oauth_token=undefined&need_https=true&platform=_&player_type=site&player_backend=mediaplayer'
		local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr, headers = headers})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
				showError('Это содержимое более недоступно')
			 return
			end
		answer = answer:gsub('\\', '')
		token = answer:match('"token":"(.-})","sig')
		token = token:gsub('u0026', '\\u0026')
		sig = answer:match('"sig":"([^"]+)')
			if not token or not sig then
				m_simpleTV.Http.Close(session)
				showError('2')
			 return
			end
	end
	if types == 'vods' then
		retAdr = 'https://usher.twitch.tv/vod/' .. id .. '.m3u8?nauth=' .. token .. '&nauthsig=' .. sig .. '&allow_source=true'
		url = 'https://api.twitch.tv/kraken/videos/v' .. id
	elseif types == 'channels' then
		retAdr = 'https://usher.ttvnw.net/api/channel/hls/' .. string.lower(id) .. '.m3u8?allow_source=true&allow_audio_only=true&allow_spectre=true&p=' .. math.random(1000000, 10000000) .. '&player=twitchweb&playlist_include_framerate=true&segment_preference=4&sig=' .. sig .. '&token=' .. m_simpleTV.Common.toPercentEncoding(token)
		url = 'https://api.twitch.tv/kraken/channels/' .. id
	elseif types == 'clips' then
		url = 'https://api.twitch.tv/helix/clips?id=' .. id
	end
	local title, banner = title(url, client_id)
	local rc, answer
	local headers = 'client-id: ' .. client_id
	if types == 'clips' then
		retAdr = 'https://gql.twitch.tv/gql'
		local body = '{"query":"query getClipStatus($slug:ID!) {clip(slug: $slug) {creationState videoQualities {frameRate quality sourceURL}}}","variables":{"slug":"' .. id .. '"}}'
		rc, answer = m_simpleTV.Http.Request(session, {url = retAdr, headers = headers, body = body, method = 'post'})
			if rc ~= 200 then
				showError('no clip')
				m_simpleTV.Http.Close(session)
			 return
			end
	else
		rc, answer = m_simpleTV.Http.Request(session, {url = retAdr, headers = headers})
			if rc ~= 200 then
				showError('недоступно')
				m_simpleTV.Http.Close(session)
				if banner then
					m_simpleTV.Control.CurrentAddress = banner .. '$OPT:image-duration=5$OPT:NO-STIMESHIFT'
				end
			 return
			end
	end
	m_simpleTV.Http.Close(session)
	local i, t = 1, {}
	local adr, name, qlty, fps
	if types == 'clips' then
		answer = answer:gsub('(%[%])', '"nil"')
		local tab = json.decode(answer)
			if not tab or not tab.data or not tab.data.clip or not tab.data.clip.creationState == 'CREATED' then return end
			while true do
					if not tab.data.clip.videoQualities[i] then break end
				fps = tonumber(tab.data.clip.videoQualities[i].frameRate or '0')
				qlty = tonumber(tab.data.clip.videoQualities[i].quality)
				name = qlty
				if fps <= 30 then
					fps = ''
				else
					qlty = qlty + 6
					fps = math.ceil(fps / 10) * 10
				end
				t[i] = {}
				t[i].Id = qlty
				t[i].Name = name .. 'p' .. fps
				t[i].Address = tab.data.clip.videoQualities[i].sourceURL .. '$OPT:NO-STIMESHIFT'
				i = i + 1
			end
			if i == 1 then
				showError('3')
			 return
			end
	else
			for w in answer:gmatch('EXT%-X%-MEDIA(.-%.m3u8)') do
				adr = w:match('http.-%.m3u8')
				name = w:match('NAME="(%d+[^"]+)') or w:match('RESOLUTION=%d+x(%d+)')
					if not adr or not name then break end
				qlty = tonumber(name:match('%d+'))
				if qlty > 200 then
					fps = tonumber(name:match('p(%d+)') or '0')
					if fps > 30 then
						qlty = qlty + 6
					end
					t[i] = {}
					t[i].Id = qlty
					t[i].Name = name
					t[i].Address = adr
					i = i + 1
				end
			end
			if i == 1 then
				m_simpleTV.Control.CurrentAddress = retAdr
				m_simpleTV.Control.CurrentTitle_UTF8 = title
			 return
			end
	end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('twitch_qlty') or 5000)
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
			t.ExtParams = {LuaOnOkFunName = 'twitchSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	function twitchSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('twitch_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')