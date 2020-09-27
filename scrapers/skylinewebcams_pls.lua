-- скрапер TVS для загрузки плейлиста веб камер "SkylineWebcams" https://www.skylinewebcams.com (19/4/20)
-- необходим видоскрипт: skylinewebcams
	module('skylinewebcams_pls', package.seeall)
	local my_src_name = 'SkylineWebcams'
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\skylinewebcams.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 0, RefreshButton = 0, AutoBuild = 0, show_progress = 1, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 0, FilterGR = 0, GetGroup = 0, LogoTVG = 0}, STV = {add = 1, ExtFilter = 0, FilterCH = 0, FilterGR = 0, GetGroup = 1, HDGroup = 0, AutoSearch = 0, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 3}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local function translateName(str)
			local t = {
						{'Argentina', 'Аргентина', 'flag-of-Argentina.png'},
						{'Anguilla', 'Ангилья', ''},
						{'Australia', 'Австралия', 'flag-of-Australia.png'},
						{'Austria', 'Австрия', 'flag-of-Austria.png'},
						{'Barbados', 'Барбадос', 'flag-of-Barbados.png'},
						{'Belgium', 'Бельгия', 'flag-of-Belgium.png'},
						{'Bolivia', 'Боливия', 'flag-of-Bolivia.png'},
						{'Brazil', 'Бразилия', 'flag-of-Brazil.png'},
						{'Caribbean Netherlands', 'Карибские острова Нидерланды', ''},
						{'Chile', 'Чили', 'flag-of-Chile.png'},
						{'China', 'Китай', 'flag-of-China.png'},
						{'Costa Rica', 'Коста Рика', 'flag-of-Costa-Rica.png'},
						{'Croatia', 'Хорватия', 'flag-of-Croatia.png'},
						{'Curaçao', 'Кюрасао', ''},
						{'Czech Republic', 'Чехия', 'flag-of-Czech-Republic.png'},
						{'Dominican Republic', 'Доминиканская Респблика', ''},
						{'Ecuador', 'Эквадор', 'flag-of-Ecuador.png'},
						{'El Salvador', 'Сальвадор', 'flag-of-El-Salvador.png'},
						{'Faroe Islands', 'Фарерские острова', ''},
						{'France', 'Франция', 'flag-of-France.png'},
						{'Germany', 'Германия', 'flag-of-Germany.png'},
						{'Greece', 'Греция', 'flag-of-Greece.png'},
						{'Grenada', 'Гренада', 'flag-of-Grenada.png'},
						{'Honduras', 'Гондурас', 'flag-of-Honduras.png'},
						{'Hungary', 'Венгрия', 'flag-of-Hungary.png'},
						{'Iceland', 'Исландия', 'flag-of-Iceland.png'},
						{'Ireland', 'Ирландия', 'flag-of-Ireland.png'},
						{'Israel', 'Израиль', 'flag-of-Israel.png'},
						{'Italy', 'Италия', 'flag-of-Italy.png'},
						{'Jordan', 'Иордания', 'flag-of-Jordan.png'},
						{'Kenya', 'Кения', 'flag-of-Kenya.png'},
						{'Maldives', 'Мальдивы', ''},
						{'Malta', 'Мальта', 'flag-of-Malta.png'},
						{'Mexico', 'Мексика', 'flag-of-Mexico.png'},
						{'Morocco', 'Марокко', 'flag-of-Morocco.png'},
						{'Netherlands', 'Нидерланды', 'flag-of-Netherlands.png'},
						{'Nicaragua', 'Никарагуа', 'flag-of-Nicaragua.png'},
						{'Norway', 'Норвегия', 'flag-of-Norway.png'},
						{'Panama', 'Панама', 'flag-of-Panama.png'},
						{'Peru', 'Перу', 'flag-of-Peru.png'},
						{'Philippines', 'Филиппины', 'flag-of-Philippines.png'},
						{'Poland', 'Польша', 'flag-of-Poland.png'},
						{'Portugal', 'Португалия', 'flag-of-Portugal.png'},
						{'Republic of San Marino', 'Республика Сан-Марино', ''},
						{'Serbia', 'Сербия', 'flag-of-Serbia.png'},
						{'Seychelles', 'Сейшельские острова', 'flag-of-Seychelles.png'},
						{'Slovenia', 'Словения', 'flag-of-Slovenia.png'},
						{'South Africa', 'Южная Африка', 'flag-of-South-Africa.png'},
						{'Spain', 'Испания', 'flag-of-Spain.png'},
						{'Switzerland', 'Швейцария', 'flag-of-Switzerland.png'},
						{'Thailand', 'Таиланд', 'flag-of-Thailand.png'},
						{'Turkey', 'Турция', 'flag-of-Turkey.png'},
						{'US Virgin Islands', 'Американские Виргинские острова', ''},
						{'United Arab Emirates', 'Объединенные Арабские Эмираты', 'flag-of-United-Arab-Emirates.png'},
						{'United Kingdom', 'Соединенное Королевство', 'flag-of-United-Kingdom.png'},
						{'United States', 'Соединенные Штаты', 'flag-of-United-States-of-America.png'},
						{'Venezuela', 'Венесуэла', 'flag-of-Venezuela.png'},
						{'Zambia', 'Замбия', 'flag-of-Zambia.png'},
						{'Zanzibar', 'Занзибар', ''},
					}
			local flag
				for i = 1, #t do
					if str == t[i][1] then
						if m_simpleTV.Interface.GetLanguage() == 'ru' then
							str = t[i][2]
						end
						if flag ~= '' then
							flag = 'https://www.countries-ofthe-world.com/flags-normal/' .. t[i][3]
						end
					 break
					end
				end
		 return str, flag
		end
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.3945.79 Safari/537.36')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 16000)
		local url = 'https://www.skylinewebcams.com'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
		answer = answer:match('id="live%-cams".-<li class="dropdown"')
			if not answer then
				m_simpleTV.Http.Close(session)
			 return
			end
		local adr, title, flag
		local t, i = {}, 1
			for w in answer:gmatch('<a.-</a>') do
				adr = w:match('href="([^"]+)')
				title = w:match('"menu%-item">([^<]+)')
					if not adr or not title then break end
				t[i] = {}
				t[i].name, t[i].grouplogo = translateName(title, flag)
				t[i].address = url .. adr
				i = i + 1
			end
			if i == 1 then
				m_simpleTV.Http.Close(session)
			 return
			end
		local t0, j = {}, 1
			for i = 1, #t do
				rc, answer = m_simpleTV.Http.Request(session, {url = t[i].address})
					if rc ~= 200 then break end
					for w in answer:gmatch('<li class="webcam".-</li>') do
						adr = w:match('href="([^"]+)')
						title = w:match('"title">([^<]+)')
						if adr and title then
							t0[j] = {}
							t0[j].name = title:gsub(',', '%%2C')
							t0[j].address = url .. adr
							t0[j].group = t[i].name
							t0[j].group_logo = t[i].grouplogo
							t0[j].group_is_unique = 1
							t0[j].logo = w:match('data%-original="([^"]+)')
							t0[j].video_title = w:match('"description">([^<]+)')
							j = j + 1
						end
					end
				i = i + 1
			end
		m_simpleTV.Http.Close(session)
			if j == 1 then return end
	 return t0
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls then
				m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' - ошибка загрузки плейлиста'
											, color = ARGB(255, 255, 100, 0)
											, showTime = 1000 * 5
											, id = 'channelName'})
			 return
			end
		m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' (' .. #t_pls .. ')'
									, color = ARGB(255, 155, 255, 155)
									, showTime = 1000 * 5
									, id = 'channelName'})
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')