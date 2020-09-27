-- скрапер TVS для загрузки видео плейлиста "Детское" https://itv.rt.ru (9/12/19)
	module('child_itv_20_pls', package.seeall)
	local my_src_name = 'Детское'
	function GetSettings()
		local scrap_settings = {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\child_rt.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 0, RefreshButton = 0, AutoBuild = 0, show_progress = 1, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 0, FilterGR = 0, GetGroup = 0, LogoTVG = 0}, STV = {add = 1, ExtFilter = 0, FilterCH = 0, FilterGR = 0, GetGroup = 1, HDGroup = 0, AutoSearch = 0, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 1}}
	 return scrap_settings
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite(p)
			local function getReting(kpR, imdR)
					local function round(str)
					 return string.format('%.' .. (1 or 0) .. 'f', str)
					end
				local kp, imd
				if kpR and kpR ~= '0' then
					kp = 'КП: ' .. round(kpR)
				end
				if imdR and imdR ~= '0' then
					imd = 'IMDb: ' .. round(imdR)
				end
					if not kp and not imd then return end
				local slsh = ''
				if kp and imd then
					slsh = ' / '
				end
			 return (kp or '') .. slsh .. (imd or '')
			end
		local session = m_simpleTV.Http.New('Mozilla/5.0 (SmartHub; SMART-TV; U; Linux/SmartTV) AppleWebKit/531.2+ (KHTML, like Gecko) WebBrowser/1.0 SmartTV Safari/531.2+')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 120000)
		m_simpleTV.OSD.ShowMessageT({text = '«Детское» загрузка ...', color = 0xff9bffff, showTime = 1000 * 200, id = 'channelName'})
		local rc, answer = m_simpleTV.Http.Request(session, {url = p})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		answer = answer:gsub(':%s*%[%]', ':""')
		answer = answer:gsub('%[%]', ' ')
		require 'json'
		local tab = json.decode(answer)
			if not tab or not tab.movie_list then return end
		local t, i = {}, 1
		local j = 1
			while true do
					if not tab.movie_list[j] then break end
				if tab.movie_list[j].assets
					and tab.movie_list[j].assets.ott_content_asset
					and tab.movie_list[j].assets.ott_content_asset.ifn
					and tab.movie_list[j].assets.ott_content_asset.ifn ~= ''
					and tab.movie_list[j].isChild
					and tab.movie_list[j].isChild == '1'
				then
					t[i] = {}
					t[i].year = tab.movie_list[j].year
					t[i].address = tab.movie_list[j].assets.ott_content_asset.ifn
					t[i].name = tab.movie_list[j].name
					t[i].logo = tab.movie_list[j].logo2 or tab.movie_list[j].logo
					t[i].kpR = tab.movie_list[j].kinopR
					t[i].imdR = tab.movie_list[j].imdbR
					t[i].country = tab.movie_list[j].country
					i = i + 1
				end
				j = j + 1
			end
			if i == 1 then return end
		local reting, year, country, video_title
			for i = 1, #t do
				t[i].address = 'https://zabava-htvod.cdn.ngenix.net/' .. t[i].address
				if t[i].logo then
					t[i].logo = 'http://sdp.svc.iptv.rt.ru:8080/images/' .. t[i].logo
				end
				reting = getReting(t[i].kpR, t[i].imdR)
				if reting then
					t[i].name = t[i].name .. ' (' .. reting .. ')'
				end
				t[i].name = t[i].name:gsub(',', '%%2C')
				if t[i].year then
					t[i].year = t[i].year:gsub('209', '2019')
					year = ' | ' .. t[i].year
					t[i].group = t[i].year
				else
					t[i].group = 'нет года'
				end
				if t[i].country then
					country = ' | ' .. t[i].country:gsub(',', ', ')
				end
				video_title = (country or '') .. (year or '')
				video_title = video_title:gsub('|%s*|', '|'):gsub('%s+', ' '):gsub('^[%s|]*(.-)%s*$', '%1')
				t[i].video_title = video_title
			end
		local hash, t0 = {}, {}
			for i = 1, #t do
				if not hash[t[i].address] then
					t0[#t0 + 1] = t[i]
					hash[t[i].address] = true
				end
			end
			if #t0 == 0 then return end
	 return t0
	end
	function GetList(UpdateID, m3u_file)
			if m_simpleTV.Common.GetVlcVersion() < 3000 then return end
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local w = decode64('aHR0cHM6Ly9mZS5zdmMuaXB0di5ydC5ydS9DYWNoZUNsaWVudEpzb24vanNvbi9Wb2RQYWNrYWdlL2xpc3RfbW92aWVzP2xvY2F0aW9uSWQ9NzAwMDAxJmZyb209MCZ0bz05OTk5OTk5OSZwYWNrYWdlSWQ9') .. '1000,21713942'
		local t_pls = LoadFromSite(w)
			if not t_pls then
				m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' - ошибка загрузки плейлиста', color = 0xffff6600, showTime = 1000 * 5, id = 'channelName'})
			 return
			end
		m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' (' .. #t_pls .. ')', color = 0xff9bffff, showTime = 1000 * 5, id = 'channelName'})
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')