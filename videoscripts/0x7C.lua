-- видеоскрипт заменяет "|" в ссылках (28/1/20)
-- открывает подобные ссылки:
-- https://ictv-hls5.cosmonova.net.ua/hls/ictv_ua_hi/index.m3u8|COMPONENT=HLS|Referer="https://live-ictv.cosmonova.net.ua/online.php?width=623&height=350&lang=ru&autostart=0"|user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.140 Safari/537.36 Edge/18.17763|test||
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAdress:match('%|') then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
 	inAdr = inAdr:gsub('"', '')
	inAdr = inAdr:gsub('%%22', '')
	inAdr = inAdr:gsub('%|user%-agent', '$OPT:http-user-agent')
	inAdr = inAdr:gsub('%|X%-Forwarded%-For=', '$OPT:http-ext-header=X-Forwarded-For:')
	inAdr = inAdr:gsub('%|Referer=', '$OPT:http-referrer=')
	inAdr = inAdr:gsub('%|Cookie=', '$OPT:http-ext-header=cookie:')
	inAdr = inAdr:gsub('%|[^$]*', '')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = inAdr
-- debug_in_file(inAdr .. '\n')