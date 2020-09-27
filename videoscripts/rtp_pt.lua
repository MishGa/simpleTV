-- видеоскрипт для сайта https://www.rtp.pt (5/4/20)
-- открывает подобные ссылки:
-- https://www.rtp.pt/play/direto/rtpinternacional
-- https://www.rtp.pt/play/direto/antena3
-- https://www.rtp.pt/play/p6296/planeta-safari
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAdress:match('^https?://www%.rtp%.pt') then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = 'https://cdn-images.rtp.pt/common/img/channels/logos/color-negative/horizontal/rtpplay.png?w=160&q=100', UseLogo = 1, Once = 1})
		m_simpleTV.Control.ChangeChannelLogo('https://cdn-images.rtp.pt/common/img/channels/logos/gray-negative/horizontal/rtp.png?w=204&q=100&fm=png32', m_simpleTV.Control.ChannelID)
	end
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/79.0.2785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	answer = answer:gsub('<!%-%-.-%-%->', ''):gsub('/%*.-%*/', '')
	local retAdr = answer:match('https?://[^\'"<>]+%.m3u8[^<>\'"]*') or answer:match('https?://[^\'"<>]+%.mp3[^<>\'"]*')
		if not retAdr then return end
	retAdr = retAdr
			.. '$OPT:NO-STIMESHIFT'
			.. '$OPT:http-referrer=' .. inAdr
	m_simpleTV.Control.CurrentAdress = retAdr
-- debug_in_file(retAdr .. '\n')