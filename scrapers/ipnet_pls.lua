-- скрапер TVS для загрузки плейлиста "ipnet" http://tv.ipnet.ua (20/4/20)
-- ## переименовать каналы ##
local filter = {
	{'5 Канал', '5 Канал (ukr)'},
	{'Культура', 'Культура (ukr)'},
	}
-- ##
	module('ipnet_pls', package.seeall)
	local my_src_name = 'ipnet'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\ipnet.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 0, FilterGR = 0, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 0}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.3785.121 Safari/537.36')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL2FwaS50di5pcG5ldC51YS9hcGkvdjIvc2l0ZS9jaGFubmVscw')})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
			if not answer:match('^{') then return end
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local tab = json.decode(answer)
			if not tab
				or not tab.data
				or not tab.data.img_to_category
				or not tab.data.categories
				or not tab.data.categories[1].channels
			then
			 return
			end
		local t0, c = {}, 1
			while tab.data.categories[c] do
				t0[c] = tab.data.categories[c].name
				c = c + 1
			end
		local t, i = {}, 1
			for c = 1, #t0 do
				local j = 1
					while tab.data.categories[c].channels[j] do
						if tab.data.categories[c].channels[j].url
							and tab.data.categories[c].channels[j].url ~= ''
						then
							t[i] = {}
							t[i].name = tab.data.categories[c].channels[j].name:gsub(':', '%%3A')
							t[i].address = tab.data.categories[c].channels[j].url
							if tab.data.categories[c].channels[j].youtube_playlist_id
								and tab.data.categories[c].channels[j].youtube_playlist_id ~= ''
							then
								t[i].address = 'http://music.youtu.be/embed/videoseries?list_id='
											.. tab.data.categories[c].channels[j].youtube_playlist_id
							end
							t[i].logo = tab.data.categories[c].channels[j].icon_url
							t[i].group = t0[c]
							if tab.data.categories[c].note then
								for k, v in pairs(tab.data.img_to_category) do
									if k == tab.data.categories[c].note then
										t[i].group_logo = 'https://tv.ipnet.ua/images/' .. v
										t[i].group_is_unique = 1
									 break
									end
								end
							end
							if tab.data.categories[c].channels[j].is_tshift_allowed == true
								and tab.data.categories[c].channels[j].tshift_duration
								and tab.data.categories[c].channels[j].tshift_duration > 0
							then
								t[i].RawM3UString = 'catchup="append" catchup-minutes="'
												.. (tab.data.categories[c].channels[j].tshift_duration / 60)
												.. '" catchup-source="?timeshift=${start}"'
							end
							i = i + 1
					end
					j = j + 1
				end
			end
			if i == 1 then return end
	 return t
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
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')