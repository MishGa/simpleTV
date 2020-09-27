-- видеоскрипт для сайтов https://www.google.ru , https://yandex.ru (21/2/20)
-- открывает ссылки со страниц поиска Google и Yandex
-- необходимы соответсвующие видеоскрипты
-- открывает подобные ссылки:
-- https://www.google.ru/url?sa=t&rct=j&q=&esrc=s&source=web&cd=27&cad=rja&uact=8&ved=2ahUKEwiap8CWjePnAhVUwcQBHeQ0DZIQFjAaegQIARAB&url=https%3A%2F%2Fyoutu.be%2FoRdxUFDoQe0%3Ft%3D176&usg=AOvVaw1k-81FOOBBFFVwT3Sla1FA
-- http://yandex.ru/clck/jsredir?bu=jjov49&from=yandex.ru%3Bsearch%2F%3Bweb%3B%3B&text=&etext=2202.l5z3bF83qnLCO9mt8d3ikMXd1nY1uUBZpm6SVRNJ_gx0aXZucnRwcmNiZ2N3ZGhp.c317126d6864921f74be60b7f152733ab8244db6&uuid=&state=jLT9ScZ_wbo,&&cst=AiuY0DBWFJ4RhQyBNHa0i4Obn-WCHZtcaZYkaLUbHgs5YfLMTc4F9v2dP_x52tdWgN-b_S-fI-oE_kJF1gNGRGZYS5_Idhwx4X8or0Pty0nKFQ7Q75YmW-vFkqGT6bJ0ZcH-EuiE3hgHkoV1pgFossflOiJuxkv_ywrIdWA65U1Ryl5G5hHbuszpMQ-N2V2VfBq4h1hG6wANAAFjKTlhYRBqEtoKXHN-gq5jobHkxTkysd8l6DKaMxB8yhaXXXjvs7fn0ZVkT8R1CzSuo2vYKinBiV666f_NLAXsIPrEldPyd-BdS0BHTqhYwXQ0ryZPi2sAZNo9jQCcMGYx9Fr51phHya8p4-Wmw77raEj_C2h3mvN6fsUa5G9Y_DwctVOcBn8Q6-BDorBqMXkxOGKHTO-LIpZ3gEvY1GzQDSpNUJlZOCwoZt5R93Wtn-KQHODnfqVfUGZu_jlAoLTMUBitLTemOLRnOR27dl2fs0JQ4WY,&data=UlNrNmk5WktYejY4cHFySjRXSWhXR2R1LW1ndHp4dHh1d2Z3WU13bkx0REdTUWRwcXpZM1ZNMm1HMlFMQ1RGel9yNXhGbDJsdFF5TUI4aGJtVmNOWDZOVHVuOW4wMl8yWTFWMnA1cHhxdFpVQVF2NWxDeHkyQSws&sign=d0380f7196dc13e11b5233330f06d6b6&keyno=0&b64e=2&ref=orjY4mGPRjk5boDnW0uvlrrd71vZw9kpupzVJzJ54VoGK541xDCYVDPsgtTyiARnDMmTpgQaH1yWfndMCbffbKiHUEX7OY6YVE_yIhTDIg6C6W1mMfG8JkAN9lRwDtAlRU5l5UBQW7_IiOt1WuwZZAdpyszp1aHqk3Cq4PL7X7_MvsWZFrMdQg,,&l10n=ru&rp=1&cts=1582305043861%40%40events%3D%5B%7B%22event%22%3A%22click%22%2C%22id%22%3A%22jjov49%22%2C%22cts%22%3A1582305043861%2C%22fast%22%3A%7B%22organic%22%3A1%7D%2C%22service%22%3A%22web%22%2C%22event-id%22%3A%22k6wfkhp1ow%22%7D%5D&hdtime=20812.665
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://www%.google%.')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://[w%.]*yandex%..-/clck/')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local function yandexLink(url)
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/79.0.3785.143 Safari/537.36')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: https://yandex.ru/search/'})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
		url = answer:match('URL=\'([^\']+)')
			if not url then return end
		if url:match('redir_warning') then
			rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc ~= 200 then
					m_simpleTV.Http.Close(session)
				 return
				end
			url = answer:match('<a class="b%-link b%-redir%-warning__link".->([^<]+)')
		end
		m_simpleTV.Http.Close(session)
	 return url
	end
	local function googleLink(url)
		url = m_simpleTV.Common.fromPersentEncoding(url)
		url = url:match('url=([^&]*)')
	 return url
	end
	local retAdr
	if inAdr:match('^https?://[w.]*yandex%.') then
		retAdr = yandexLink(inAdr)
	else
		retAdr = googleLink(inAdr)
	end
	retAdr = retAdr or inAdr
	m_simpleTV.Control.PlayAddress(retAdr)
-- debug_in_file(retAdr .. '\n')