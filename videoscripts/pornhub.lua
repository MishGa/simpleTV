-- (6/1/20)
-- PORNHUB simpleTV 0.5.0 b10  script
-- version 0.1
-- open links like *pornhub.com/view_video.php*
-- for choose quality: press ctrl+m
if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
if not string.match( m_simpleTV.Control.CurrentAddress, 'pornhub%.com/view_video%.php' )  then return end
local inAdr =  m_simpleTV.Control.CurrentAddress
m_simpleTV.Control.ChangeAddress = 'Yes'
m_simpleTV.Control.CurrentAddress = 'error'
-----------------------------------------------------------------------------------
local function showError(str)
 m_simpleTV.OSD.ShowMessageT({text = 'PORNHUB error: ' .. str, showTime = 1000 * 8, color = ARGB(255, 255, 0, 0), id = 'pornHub'})
end
-----------------------------------------------------------------------------------
 if m_simpleTV.Common.GetVersion() < 820 then
  showError( "simpleTV version too old [".. select(2,m_simpleTV.Common.GetVersion())  .. "], need 0.5.0 B10 or newer" )
  return
 end
local session = m_simpleTV.Http.New()
if session==nil then return end
if m_simpleTV.Control.MainMode == 0 then
 local backT={}
 backT.BackColor = 0
 backT.TypeBackColor = 0
 backT.PictFileName = 'https://di.phncdn.com/www-static/images/pornhub_logo_straight.png'
 backT.UseLogo = 1
 backT.Once = 1
 --backT.Blur = 3 -- 10.5
 m_simpleTV.Interface.SetBackground(backT)
end
local rc,answer = m_simpleTV.Http.Request(session,{url=inAdr})
m_simpleTV.Http.Close(session)
if rc~=200 then  return end
--debug_in_file(answer)
require('jsdecode')
if jsdecode.getVersion == nil or jsdecode.getVersion() < 1.0 then
 showError('jsdecode too old, update it')
 return
end
local scr = nil
for w in string.gmatch(answer,'<script type="text/javascript">(.-)</script>') do
 if string.match(w,'flashvars') then
	scr = w
	break
 end
end
if scr==nil then
 showError('video not found')
 return
end
local decodeScr = "loadScriptUniqueId =[];loadScriptVar = [];playerObjList = {};" .. scr ..
"var retA = [];\
	if (typeof(quality_240p) !== 'undefined')\
		 retA.push({'Id': '240', 'Name': '240p', 'Address':quality_240p});\
	if (typeof(quality_480p) !== 'undefined')\
		 retA.push({'Id': '480', 'Name': '480p', 'Address':quality_480p});\
	if (typeof(quality_720p) !== 'undefined')\
		 retA.push({'Id': '720', 'Name': '720p', 'Address':quality_720p});\
	if (typeof(quality_1080p) !== 'undefined')\
		 retA.push({'Id': '1080', 'Name': '1080p', 'Address':quality_1080p});\
	if (typeof(quality_1440p) !== 'undefined')\
		 retA.push({'Id': '1440', 'Name': '1440p', 'Address':quality_1440p});"
local q = jsdecode.DoDecode('retA', false, decodeScr, 0,0)
if type(q)~='table' or #q==0 then
 showError('address table not found')
 return
end
 local t = {}
 for k,v in pairs(q) do
	local i = #t+1
	t[i] = v
	t[i].Id = tonumber(v.Id)
	t[i].Address = t[i].Address .. '$OPT:NO-STIMESHIFT'
 end
table.sort(t,function(a,b) return a.Id < b.Id end)
 local lastQuality = tonumber(m_simpleTV.Config.GetValue("lastQuality","pornHub.ini") or 5000)
 local index = #t
 if #t>1 then
	table.insert(t,1,{})
	t[1].Id = 0
	t[1].Name = 'Always lowest'
	t[1].Address = t[2].Address
	t[#t+1] = {}
	t[#t].Id = 5000
	t[#t].Name = 'Always highest'
	t[#t].Address = t[#t-1].Address
	index = #t
	for i=1,#t do
	 if t[i].Id >= lastQuality then
	  index = i
	  break
	 end
	end
	if m_simpleTV.Control.MainMode == 0 then
	  t.ExtParams = {}
	  t.ExtParams.LuaOnOkFunName = 'pornHubSaveQuality'
	  m_simpleTV.OSD.ShowSelect_UTF8("PORNHUB - choose quality", index-1, t, 10000, 32 + 64 + 128)
	 end
 end
 local addTitle = 'PORNHUB'
 local title = findpattern(scr,'"video_title":%b""',1,15,1)
 if title==nil then
     title = addTitle
  else
     title = unescape1(title)
	 if  m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Control.ChangeChannelName(   title   --new name
											  , m_simpleTV.Control.ChannelID  --channel id
											  , false ) --try find epg
		local img_url = findpattern(scr,'"image_url":%b""',1,13,1)
		if img_url ~= nil then
		   img_url = string.gsub(img_url,'\\/','/')
		   m_simpleTV.Control.ChangeChannelLogo( img_url, m_simpleTV.Control.ChannelID )
		end
	 end
	  title =  addTitle  .. ' - ' ..   title
 end
----------------------------------------------------------------------------
--PositionThumbsHandler
----------------------------------------------------------------------------
 if m_simpleTV.User == nil then m_simpleTV.User = {} end
 if m_simpleTV.User.PornHub == nil then m_simpleTV.User.PornHub = {} end
 m_simpleTV.User.PornHub.ThumbsInfo = nil
 local thumbsInfo = findpattern(scr,'"thumbs":%b{}',1,0,0)
 if thumbsInfo ~= nil then
  --debug_in_file(thumbsInfo  )
  local samplingFrequency = tonumber(findpattern(thumbsInfo,'"samplingFrequency":(%d)',1,20,0) or 0)
  local urlPattern = findpattern(thumbsInfo,'"urlPattern":%b""',1,14,1)
  local thumbHeight = tonumber(findpattern(thumbsInfo,'"thumbHeight":%b""',1,15,1) or 0)
  local thumbWidth  = tonumber(findpattern(thumbsInfo,'"thumbWidth":%b""',1,14,1) or 0)
  --debug_in_file(samplingFrequency .. '\n' .. urlPattern  .. '\n' .. thumbHeight  .. '\n' .. thumbWidth .. '\n')
  if     samplingFrequency ~= 0
     and urlPattern  ~= nil
	 and thumbHeight ~=0
     and thumbWidth  ~=0 then
     m_simpleTV.User.PornHub.ThumbsInfo = {}
     m_simpleTV.User.PornHub.ThumbsInfo.currentAddress = inAdr
	 m_simpleTV.User.PornHub.ThumbsInfo.samplingFrequency = samplingFrequency
     m_simpleTV.User.PornHub.ThumbsInfo.urlPattern = string.gsub(urlPattern,'\\/','/')
     m_simpleTV.User.PornHub.ThumbsInfo.thumbHeight = thumbHeight
     m_simpleTV.User.PornHub.ThumbsInfo.thumbWidth  = thumbWidth
	 m_simpleTV.User.PornHub.ThumbsInfo.thumbsPerImage  = 25
	 --debug_in_file(m_simpleTV.User.PornHub.ThumbsInfo.samplingFrequency .. '\n' .. m_simpleTV.User.PornHub.ThumbsInfo.urlPattern
		--			.. '\n' .. m_simpleTV.User.PornHub.ThumbsInfo.thumbHeight  .. '\n' .. m_simpleTV.User.PornHub.ThumbsInfo.thumbWidth .. '\n')
	 if m_simpleTV.User.PornHub.PositionThumbsHandler == nil then
		local handlerInfo={}
		handlerInfo.luaFunction  = 'pornHubPositionThumbs'
		handlerInfo.regexString  = 'pornhub\.com/view_video\.php'  --optional,by default empty
		handlerInfo.minImageWidth   = m_simpleTV.User.PornHub.ThumbsInfo.thumbWidth --optional,by default 200
		handlerInfo.minImageHeight  = m_simpleTV.User.PornHub.ThumbsInfo.thumbHeight --optional,by default 100
		handlerInfo.sizeFactor   = 0.18 --optional,by default 0.2
		handlerInfo.backColor    = ARGB(200,0,0,0) --optional,by default ARGB(255,0,0,0)
		handlerInfo.glowParams = 'glow="7" samples="5" extent="4" color="0xB0000000" ' --optional,by default empty
		--handlerInfo.textColor     = ARGB(255,255,255,255) --optional,by default ARGB(255,255,255,255)
		--handlerInfo.marginLeft    = 5
		--handlerInfo.marginRight   = 5
		--handlerInfo.marginTop     = 5
		--handlerInfo.marginBottom  = 5
		--handlerInfo.clearImgCacheOnStop = false
		m_simpleTV.User.PornHub.PositionThumbsHandler = m_simpleTV.PositionThumbs.AddHandler(handlerInfo)
	 end
  end
 end
 ----------------------------------------------------------------------------
  --Chapters
  local act_tag = findpattern(scr,'"actionTags":%b""',1,14,1)
  if act_tag ~= nil then
   act_tag = string.gsub(act_tag, '[\n\r\t]','')
   --debug_in_file( act_tag .. '\n')
   local chaptersT = {}
   local video_duration =  findpattern(scr,'"video_duration":%b""',1,18,1)
   if video_duration ~= nil then
	--debug_in_file(  video_duration .. '\n')
	chaptersT.allTime = tonumber(video_duration)*1000
   end
   chaptersT.current = 0
   chaptersT.chapters = {}
   for w in string.gmatch(act_tag .. ',','(.-),') do
      --debug_in_file( w .. '\n')
	 local name = findpattern(w,'(.-):',1,0,1)
	 local seekpoint = findpattern(w,':(.+)',1,1,0)
     if name ~= nil and seekpoint ~= nil then
	  --debug_in_file( name .. seekpoint .. '\n')
	  local i = #chaptersT.chapters+1
      if i == 1 then
	    local s = tonumber(seekpoint)*1000
		if s>0 then
		  chaptersT.chapters[i] = {}
		  chaptersT.chapters[i].name = ''
		  chaptersT.chapters[i].seekpoint = 0
		  i = i+1
		end
	  end
	  chaptersT.chapters[i] = {}
      chaptersT.chapters[i].name = name
      chaptersT.chapters[i].seekpoint = tonumber(seekpoint)*1000
	 end
   end
   m_simpleTV.Control.SetChaptersDesc(chaptersT)
  end
 ----------------------------------------------------------------------------
 m_simpleTV.Control.CurrentTitle_UTF8 = title
 m_simpleTV.Control.CurrentAddress = t[index].Address
-----------------------------------------------------------------------------------
function pornHubSaveQuality(obj,id)
 m_simpleTV.Config.SetValue("lastQuality",id,"pornHub.ini")
end
----------------------------------------------------------------------------------
function pornHubPositionThumbs(queryType,address,forTime)
 --debug_in_file('queryType:' .. queryType .. '\naddress:' .. (address or '') .. '\nforTime:' .. (forTime or '') .. '\n\n')
 if queryType == 'testAddress' then
  --never called because we setted handlerInfo.regexString and testing address for this handler in core
  return false
 end
 if queryType == 'getThumbs' then
  --no need test address, we setted handlerInfo.regexString and testing address for this handler in core
  --if m_simpleTV.User.PornHub.ThumbsInfo.currentAddress ~= address then return false end
  if m_simpleTV.User.PornHub.ThumbsInfo == nil then return true end
  local imgLen = m_simpleTV.User.PornHub.ThumbsInfo.samplingFrequency*m_simpleTV.User.PornHub.ThumbsInfo.thumbsPerImage*1000
  local index = math.floor( forTime / imgLen )
  local t ={}
  t.playAddress = address
  --t.rawData  -- for direct loading  data of image, if setted then t.url, t.httpParams  will be ignored
  t.url = string.gsub(m_simpleTV.User.PornHub.ThumbsInfo.urlPattern,'{(.-)}','' .. index)
  t.httpParams = {}
  --t.httpParams.userAgent
  --t.httpParams.proxy
  t.httpParams.extHeader = 'referer:' .. address
  t.elementWidth  = m_simpleTV.User.PornHub.ThumbsInfo.thumbWidth
  t.elementHeight = m_simpleTV.User.PornHub.ThumbsInfo.thumbHeight
  t.startTime     = index * imgLen
  t.length        = imgLen
  --debug_in_file('index:' .. index .. '\nt.startTime:' .. t.startTime .. '\nt.length:' .. t.length .. '\n\n')
  m_simpleTV.PositionThumbs.AppendThumb(t)
  return true
 end
end
----------------------------------------------------------------------------------