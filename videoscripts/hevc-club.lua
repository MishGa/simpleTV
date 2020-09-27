-- видеоскрипт для сайта https://rips.club (30/8/20)
-- Copyright © 2017-2020 Nexterr
-- открывает подобные ссылки:
-- https://rips.club/video-2079
		if not m_simpleTV.Control.CurrentAddress:match('^https?://rips%.club/video') then return end
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'rips.club ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/81.0.3809.87 Safari/537.36')
		if not session then
			showError('1')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			showError('2')
			m_simpleTV.Http.Close(session)
		 return
		end
	answer = answer:gsub('<!%-%-.-%-%->', ''):gsub('/%*.-%*/', '')
	local retAdr = answer:match('[^"\']+/torrent%.php[^"\']+')
		if not retAdr then
			showError('3')
		 return
		end
	local title = answer:match('"og:title" content="([^"]+)') or 'HEVC-CLUB'
	title = title:gsub(' %(20%d%d%) .-$', '')
	title = title:gsub(' %(19%d%d%) .-$', '')
	local poster = answer:match('"og:image" content="([^"]+)') or ''
	local desc = answer:match('<b>(Год:</b>.-)<b>Продолжительность:')
				or answer:match('name="description" content="(.-)"%s*>')
				or ''
	desc = desc:gsub('<b>Студия:.-<br>', '')
	desc = desc:gsub('%c', '')
	desc = desc:gsub('<br><b>', ' | ')
	desc = desc:gsub('</b>', '')
	desc = desc:gsub('<br>', '')
	local desc_text = answer:match('<b>Описание:</b>([^<]+)')
					or answer:match('name="description" content="(.-)"%s*>')
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = poster, TypeBackColor = 0, UseLogo = 3, Once = 1})
	end
	local host = inAdr:match('^https?://.-/')
	retAdr = retAdr:gsub('^/', host)
	local rc, torFile = m_simpleTV.Http.Request(session, {url = retAdr, writeinfile = true})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('4')
		 return
		end
	retAdr = 'torrent://' .. torFile
	m_simpleTV.Control.CurrentAddress = retAdr
	function OnMultiAddressOk_hevcClub(Object, id)
		if id == 0 then
			OnMultiAddressCancel_hevcClub(Object)
		end
	end
	function OnMultiAddressCancel_hevcClub(Object)
		m_simpleTV.Control.ExecuteAction(36, 0)
	end
	local t = {}
	t[1] = {}
	t[1].Id = 1
	t[1].Name = title
	t[1].InfoPanelDesc = desc_text
	t[1].InfoPanelTitle = desc
	t[1].InfoPanelName = title
	t[1].InfoPanelShowTime = 8000
	t[1].InfoPanelLogo = poster
	t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
	t.ExtParams = {}
	t.ExtParams.LuaOnCancelFunName = 'OnMultiAddressCancel_hevcClub'
	t.ExtParams.LuaOnOkFunName = 'OnMultiAddressOk_hevcClub'
	m_simpleTV.OSD.ShowSelect_UTF8('HEVC-CLUB', 0, t, 8000, 32 + 64 + 128)
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID, 'CHANGE_IF_NOT_EQUAL')
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
	end
-- debug_in_file(retAdr .. '\n')