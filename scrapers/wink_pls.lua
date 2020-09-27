-- скрапер TVS для загрузки плейлиста "Wink" https://wink.rt.ru (18/9/20)
-- Copyright © 2017-2020 Nexterr
-- ## переименовать каналы ##
local filter = {
	{'360 Подмосковье HD', '360 Подмосковье HD (Москва)'},
	{'5 канал', 'Пятый канал'},
	{'BOLT', 'BOLT HD'},
	{'CGTN Russian', 'CGTN Русский'},
	{'MTV', 'MTV Russia'},
	{'REN-TV HD', 'РЕН ТВ HD'},
	{'REN-TV', 'РЕН ТВ'},
	{'Sony Entertainment Television HD', 'SET HD'},
	{'Star Cinema HD', 'Star Cinema HD (Россия)'},
	{'Star Cinema', 'Star Cinema (Россия)'},
	{'Star Family HD', 'Star Family HD (Россия)'},
	{'Star Family', 'Star Family (Россия)'},
	{'Время далекое и близкое', 'Время'},
	{'Деда Мороза', 'Телеканал Деда Мороза'},
	{'Доверие', 'Москва. Доверие (Москва)'},
	{'КИНОУЖАС', 'Киноужас'},
	{'МАТЧ ПРЕМЬЕР', 'Матч! Премьер HD'},
	{'МАТЧ! ФУТБОЛ 1', 'Матч! Футбол 1 HD'},
	{'МАТЧ! ФУТБОЛ 2', 'Матч! Футбол 2 HD'},
	{'МАТЧ! ФУТБОЛ 3', 'Матч! Футбол 3 HD'},
	{'О, кино!', 'О!КИНО'},
	{'Общественное телевидение России', 'ОТР'},
	{'ПОБЕДА', 'Победа HD'},
	{'Россия-1 HD', 'Россия 1 HD'},
	{'Русский экстрим', 'Russian Extreme'},
	{'Телекомпания ПЯТНИЦА', 'Пятница'},
	}
-- ##
	module('wink_pls', package.seeall)
	local my_src_name = 'Wink'
	local function ProcessFilterTableLocal(t)
			if not type(t) == 'table' then return end
		for i = 1, #t do
			t[i].name = tvs_core.tvs_clear_double_space(t[i].name)
			for _, ff in ipairs(filter) do
				if (type(ff) == 'table' and t[i].name == ff[1]) then
					t[i].name = ff[2]
				end
			end
		end
	 return t
	end
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\wink.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, show_progress = 0, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 0, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function Itv20GetTbl(p, p1)
		local session = m_simpleTV.Http.New('Mozilla/5.0 (SmartHub; SMART-TV; U; Linux/SmartTV) AppleWebKit/531.2+ (KHTML, like Gecko) WebBrowser/1.0 SmartTV Safari/531.2+')
			if not session then return end
		require 'json'
		m_simpleTV.Http.SetTimeout(session, 12000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64(p)})
		local t, i = {}, 1
		if rc == 200 then
			answer = answer:gsub('%[%]', '""')
			local tab = json.decode(answer)
			if tab and tab.channels_list then
				while tab.channels_list[i] do
					t[i] = {}
					t[i].name = tab.channels_list[i].bcname
					t[i].address = tab.channels_list[i].smlOttURL
					i = i + 1
				end
			end
		end
		rc, answer = m_simpleTV.Http.Request(session, {url = decode64(p1)})
		m_simpleTV.Http.Close(session)
		if rc == 200 then
			answer = answer:gsub('%[%]', '""')
			local tab = json.decode(answer)
			if tab and tab.channels_list then
				local j = 1
				while tab.channels_list[j] do
					t[i] = {}
					t[i].name = tab.channels_list[j].bcname
					t[i].address = tab.channels_list[j].smlOttURL
					j = j + 1
					i = i + 1
				end
			end
		end
			if i == 1 then return end
		local hash, t1 = {}, {}
			for i = 1, #t do
				if not hash[t[i].address] then
					t1[#t1 + 1] = t[i]
					hash[t[i].address] = true
				end
			end
		local t0, j = {}, 1
			for _, v in pairs(t1) do
				if v.address:match('^http')
					and v.address:match('/CH_')
					and not (
							v.address:match('TEST')
							or v.address:match('_R%d+_')
							or v.name:match('^Тест')
							or v.name:match('^Test')
							or v.name:match('Sberbank')
							)
				then
					v.name = v.name:gsub('^Телеканал', '')
					v.name = v.name:gsub(' SD', '')
					v.name = v.name:gsub('«', '')
					v.name = v.name:gsub('»', '')
					v.name = v.name:gsub('"', '')
					v.name = v.name:gsub(':%s', ' ')
					v.name = v.name:gsub('^Канал', '')
					v.name = v.name:gsub('%.%s*$', '')
					if v.address:match('/CH_1TV/') then
						v.name = 'Первый канал HD'
					end
					if v.address:match('/CH_1TVSD/') then
						v.name = 'Первый канал'
					end
					t0[j] = v
					t0[j].RawM3UString = 'catchup="append" catchup-days="3" catchup-source="?offset=-${offset}&utcstart=${timestamp}" catchup-record-source="?utcstart=${start}&utcend=${end}"'
					j = j + 1
				end
			end
			if j == 1 then return end
	 return t0
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local w = 'aHR0cHM6Ly9mZS1tb3Muc3ZjLmlwdHYucnQucnUvQ2FjaGVDbGllbnRKc29uL2pzb24vQ2hhbm5lbFBhY2thZ2UvbGlzdF9jaGFubmVscz9jaGFubmVsUGFja2FnZUlkPTg0NDE1OTU3JmxvY2F0aW9uSWQ9NzAwMDAxJmZyb209MCZ0bz0yMTQ3NDgzNjQ3'
		local w1 = 'aHR0cHM6Ly9mZS5zdmMuaXB0di5ydC5ydS9DYWNoZUNsaWVudEpzb24vanNvbi9DaGFubmVsUGFja2FnZS9saXN0X2NoYW5uZWxzP2NoYW5uZWxQYWNrYWdlSWQ9NjcwODM0OTUmbG9jYXRpb25JZD0xMDAwMDEmZnJvbT0wJnRvPTIxNDc0ODM2NDc'
		local t_pls = Itv20GetTbl(w, w1)
			if not t_pls then
				m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' - ошибка загрузки плейлиста'
											, color = 0xffff6600
											, showTime = 1000 * 5
											, id = 'channelName'})
			 return
			end
		m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' (' .. #t_pls .. ')'
									, color = 0xff99ff99
									, showTime = 1000 * 5
									, id = 'channelName'})
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')