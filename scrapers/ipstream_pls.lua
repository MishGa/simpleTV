-- скрапер TVS для загрузки плейлиста "ipstream" https://www.ipstream.one (10/9/20)
-- Copyright © 2017-2020 Nexterr
-- логин, пароль установить в дополнении 'Password Manager', для id - ipstream
-- ## Переименовать каналы ##
local filter = {
	{'', ''},
	}
-- ##
	module('ipstream_pls', package.seeall)
	local my_src_name = 'ipstream'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\ipstream.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local error_text, pm = pcall(require, 'pm')
			if not package.loaded.pm then
				showMess('дополнение "Password Manager" не установлено', 0xffff6600)
			 return
			end
		local ret, login, pass = pm.GetTestPassword('ipstream', 'ipstream', true)
			if not login or not pass
				or login == '' or pass == ''
			then
				showMess('логин/пароль установить\nв дополнении "Password Manager"\nдля id - ipstream', 0xffff6600)
			 return
			end
		local url = 'https://www.ipstream.one/iptv/m3u_plus-'
					.. m_simpleTV.Common.toPercentEncoding(login)
					.. '-'
					.. m_simpleTV.Common.toPercentEncoding(pass)
					.. '-m3u8'
		local outm3u, err = tvs_func.get_m3u(url)
		if err ~= '' then
			tvs_core.tvs_ShowError(err) m_simpleTV.Common.Sleep(1000)
		end
			if not outm3u or outm3u == '' then
			 return ''
			end
		outm3u = outm3u:gsub('#EXTM3U.-\n', '#EXTM3U\n')
		outm3u = outm3u:gsub('#EXTGRP:.-\n', '')
		-- outm3u = outm3u:gsub('group%-title=".-"' , '')
		-- outm3u = outm3u:gsub('tvg%-logo=".-"' , '')
-- debug_in_file(outm3u .. '\n')
		local t_pls = tvs_core.GetPlsAsTable(outm3u)
		t_pls = ProcessFilterTableLocal(t_pls)
		m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' (' .. #t_pls .. ')'
									, color = 0xff99ff99
									, showTime = 1000 * 5
									, id = 'channelName'})
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end