--[[
################################################################################
# 
# Copyright (c) 2014-2019 Ultraschall (http://ultraschall.fm)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 
################################################################################
]]

-------------------------------------
--- ULTRASCHALL - API - FUNCTIONS ---
-------------------------------------
---      Ultraschall Module       ---
-------------------------------------

if type(ultraschall)~="table" then 
  -- update buildnumber and add ultraschall as a table, when programming within this file
  local retval, string = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "Functions-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  local retval, string = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "Ultraschall-Module-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  local retval, string2 = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "API-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  if string=="" then string=10000 
  else 
    string=tonumber(string) 
    string=string+1
  end
  if string2=="" then string2=10000 
  else 
    string2=tonumber(string2)
    string2=string2+1
  end 
  reaper.BR_Win32_WritePrivateProfileString("Ultraschall-Api-Build", "Functions-Build", string, reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  reaper.BR_Win32_WritePrivateProfileString("Ultraschall-Api-Build", "API-Build", string2, reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")  
  ultraschall={} 
  
  ultraschall.API_TempPath=reaper.GetResourcePath().."/UserPlugins/ultraschall_api/temp/"
end

function ultraschall.pause_follow_one_cycle()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>pause_follow_one_cycle</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>ultraschall.pause_follow_one_cycle()</functioncall>
  <description>
    Skips auto-follow-off-checking-script for one cycle.
    FollowMode in Ultraschall turns on Autoscrolling in a useable way. In addition, under certain circumstances, followmode will be turned off automatically. 
    If you experience this but want to avoid the follow-off-functionality, use this function.
    
    This function is only relevant, if you want to develop scripts that work perfectly within the Ultraschall.fm-extension.
  </description>
  <chapter_context>
    Ultraschall Specific
    Followmode
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>ultraschall, userinterface, follow, off, followmode, turn off one cycle</tags>
</US_DocBloc>
--]]
  local follow_actionnumber = reaper.NamedCommandLookup("_Ultraschall_Toggle_Follow")
  if reaper.GetToggleCommandState(follow_actionnumber)==1 then
    reaper.SetExtState("follow", "skip", "true", false)
  end
end 


function ultraschall.IsTrackSoundboard(tracknumber)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsTrackSoundboard</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.IsTrackSoundboard(integer tracknumber)</functioncall>
  <description>
    Returns, if this track is a soundboard-track, means, contains an Ultraschall-Soundboard-plugin.
    
    Only relevant in Ultraschall-installations
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, it is an Ultraschall-Soundboard-track; false, it is not
  </retvals>
  <parameters>
    integer tracknumber - the tracknumber to check for; 0, for master-track; 1, for track 1; n for track n
  </parameters>
  <chapter_context>
    Ultraschall Specific
    Track Management
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>ultraschall, isvalid, soundboard, track</tags>
</US_DocBloc>
--]]
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("IsTrackSoundboard", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("IsTrackSoundboard", "tracknumber", "no such track; must be between 1 and "..reaper.CountTracks(0).." for the current project. 0, for master-track.", -2) return false end
  if tracknumber==0 then track=reaper.GetMasterTrack(0) else track=reaper.GetTrack(0,tracknumber-1) end
  if track~=nil then
    local count=0
    while reaper.TrackFX_GetFXName(track, count, "")~="" do
      local retval, buf = reaper.TrackFX_GetFXName(track, count, "")
      if buf=="AUi: Ultraschall: Soundboard" then return true, count end -- Mac-check
      if buf=="VSTi: Soundboard (Ultraschall)" then return true, count end -- Windows-check
      if buf=="" then return false end
      count=count+1
    end
  end
  return false
end

--A=ultraschall.IsTrackSoundboard(33)

function ultraschall.IsTrackStudioLink(tracknumber)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsTrackStudioLink</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.IsTrackStudioLink(integer tracknumber)</functioncall>
  <description>
    Returns, if this track is a StudioLink-track, means, contains a StudioLink-Plugin
    
    Only relevant in Ultraschall-installations
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, it is a StudioLink-track; false, it is not
  </retvals>
  <parameters>
    integer tracknumber - the tracknumber to check for; 0, for master-track; 1, for track 1; n for track n
  </parameters>
  <chapter_context>
    Ultraschall Specific
    Track Management
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>ultraschall, isvalid, studiolink, track</tags>
</US_DocBloc>
--]]
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("IsTrackStudioLink", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("IsTrackStudioLink", "tracknumber", "no such track; must be between 1 and "..reaper.CountTracks(0).." for the current project. 0, for master-track.", -2) return false end
  if tracknumber==0 then track=reaper.GetMasterTrack(0) else track=reaper.GetTrack(0,tracknumber-1) end
  if track~=nil then
    local count=0
    while reaper.TrackFX_GetFXName(track, count, "")~="" do
      local retval, buf = reaper.TrackFX_GetFXName(track, count, "")
      if buf=="AU: ITSR: StudioLink" then return true, count end -- Mac-check
      if buf=="VST: StudioLink (IT-Service Sebastian Reimers)" then return true, count end -- Windows-check
      if buf=="" then return false end
      count=count+1
    end
  end
  return false
end

--A=ultraschall.IsTrackStudioLink(3)


function ultraschall.IsTrackStudioLinkOnAir(tracknumber)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsTrackStudioLinkOnAir</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.IsTrackStudioLinkOnAir(integer tracknumber)</functioncall>
  <description>
    Returns, if this track is a StudioLinkOnAir-track, means, contains a StudioLinkOnAir-Plugin
    
    Only relevant in Ultraschall-installations
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, it is a StudioLinkOnAir-track; false, it is not
  </retvals>
  <parameters>
    integer tracknumber - the tracknumber to check for; 0, for master-track; 1, for track 1; n for track n
  </parameters>
  <chapter_context>
    Ultraschall Specific
    Track Management
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>ultraschall, isvalid, studiolinkonair, track</tags>
</US_DocBloc>
--]]
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("IsTrackStudioLinkOnAir", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("IsTrackStudioLinkOnAir", "tracknumber", "no such track; must be between 1 and "..reaper.CountTracks(0).." for the current project. 0, for master-track.", -2) return false end
  if tracknumber==0 then track=reaper.GetMasterTrack(0) else track=reaper.GetTrack(0,tracknumber-1) end
  if track~=nil then
    local count=0
    while reaper.TrackFX_GetFXName(track, count, "")~="" do
      local retval, buf = reaper.TrackFX_GetFXName(track, count, "")
      if buf=="ITSR: StudioLinkOnAir" then return true, count end -- Mac-check
      if buf=="VST: StudioLinkOnAir (IT-Service Sebastian Reimers)" then return true, count end -- Windows-check
      if buf=="" then return false end
      count=count+1
    end
  end
  return false
end


function ultraschall.GetTypeOfTrack(tracknumber)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTypeOfTrack</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>string type, boolean multiple = ultraschall.GetTypeOfTrack(integer tracknumber)</functioncall>
  <description>
    Returns the tracktype of a specific track. Will return the type of the first valid SoundBoard, StudioLink, StudioLinkOnAir-plugin in the track-fx-chain.
    If there are multiple valid plugins and therefore types, the second retval multiple will be set to true, else to false.
    
    Only relevant in Ultraschall-installations
    
    returns "", false in case of an error
  </description>
  <retvals>
    string type - Either "StudioLink", "StudioLinkOnAir", "SoundBoard" or "Other". "", in case of an error
    boolean multiple - true, the track has other valid plugins as well; false, it is a "pure typed" track
  </retvals>
  <parameters>
    integer tracknumber - the tracknumber to check for; 0, for master-track; 1, for track 1; n for track n
  </parameters>
  <chapter_context>
    Ultraschall Specific
    Track Management
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>ultraschall, get, type, soundboard, studiolink, studiolinkonair, track</tags>
</US_DocBloc>
--]]
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("IsTrackStudioLinkOnAir", "tracknumber", "must be an integer", -1) return "", false end
  if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("IsTrackStudioLinkOnAir", "tracknumber", "no such track; must be between 1 and "..reaper.CountTracks(0).." for the current project. 0, for master-track.", -2) return "", false end
  if tracknumber==0 then track=reaper.GetMasterTrack(0) else track=reaper.GetTrack(0,tracknumber-1) end
  local A,A1=ultraschall.IsTrackStudioLink(tracknumber)
  local B,B1=ultraschall.IsTrackStudioLinkOnAir(tracknumber)
  local C,C1=ultraschall.IsTrackSoundboard(tracknumber)
  
  -- hacky, find a better way
  if A1==nil then A1=99999999999 end 
  if B1==nil then B1=99999999999 end
  if C1==nil then C1=99999999999 end
  
  if A==true and B==false and C==false then return "StudioLink", false
  elseif A==false and B==true and C==false then return "StudioLinkOnAir", false
  elseif A==false and B==false and C==true then return "SoundBoard", false
  elseif A==true and B==true and C==false then 
    if A1<B1 then return "StudioLink", true else return "StudioLinkOnAir", true end
  elseif A==false and B==true and C==true then 
    if B1<C1 then return "StudioLinkOnAir", true else return "SoundBoard", true end
  elseif A==true and B==false and C==true then 
    if A1<C1 then return "StudioLink", true else return "SoundBoard", true end
  elseif A==true and B==true and C==true then
    if A1<B1 and A1<C1 then return "StudioLink", true
    elseif B1<A1 and B1<C1 then return "StudioLinkOnAir", true
    elseif C1<A1 and C1<B1 then return "SoundBoard", true
    end
  else
    return "Other", false
  end
end


--DABBA,DBABBA=ultraschall.GetTypeOfTrack(1)


function ultraschall.GetAllAUXSendReceives2()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllAUXSendReceives2</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>table AllAUXSendReceives, integer number_of_tracks = ultraschall.GetAllAUXSendReceives2()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    returns a table with all AUX-SendReceive-settings of all tracks, excluding master-track
    
    like [GetAllAUXSendReceives](#GetAllAUXSendReceives), but returns the type of a track as well
    
    returned table is of structure:
      table["AllAUXSendReceive"]=true                               - signals, this is an AllAUXSendReceive-table. Don't alter!
      table["number\_of_tracks"]                                     - the number of tracks in this table, from track 1 to track n
      table[tracknumber]["type"]                                    - type of the track, SoundBoard, StudioLink, StudioLinkOnAir or Other
      table[tracknumber]["AUXSendReceives_count"]                   - the number of AUXSendReceives of tracknumber, beginning with 1
      table[tracknumber][AUXSendReceivesIndex]["recv\_tracknumber"] - the track, from which to receive audio in this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["post\_pre_fader"]   - the setting of post-pre-fader of this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["volume"]            - the volume of this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["pan"]               - the panning of this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["mute"]              - the mute-setting of this AUXSendReceivesIndex  of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["mono\_stereo"]      - the mono/stereo-button-setting of this AUXSendReceivesIndex  of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["phase"]             - the phase-setting of this AUXSendReceivesIndex  of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["chan\_src"]         - the audiochannel-source of this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["snd\_src"]          - the send-to-channel-target of this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["pan\_law"]           - pan-law, default is -1
      table[tracknumber][AUXSendReceivesIndex]["midichanflag"]      - the Midi-channel of this AUXSendReceivesIndex of tracknumber, leave it 0
      table[tracknumber][AUXSendReceivesIndex]["automation"]        - the automation-mode of this AUXSendReceivesIndex  of tracknumber
      
      See [GetTrackAUXSendReceives](#GetTrackAUXSendReceives) for more details on the individual settings, stored in the entries.
  </description>
  <retvals>
    table AllAUXSendReceives - a table with all SendReceive-entries of the current project.
    integer number_of_tracks - the number of tracks in the AllMainSends-table
  </retvals>
  <chapter_context>
    Ultraschall Specific
    Routing
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>routing, trackmanagement, track, get, all, send, receive, aux, routing</tags>
</US_DocBloc>
]]

  local AllAUXSendReceives, number_of_tracks = ultraschall.GetAllAUXSendReceives()
  for i=1, number_of_tracks do
    AllAUXSendReceives[i]["type"]=ultraschall.GetTypeOfTrack(i)
  end
  return AllAUXSendReceives, number_of_tracks
end

--A,B=ultraschall.GetAllAUXSendReceives2()

function ultraschall.GetAllHWOuts2()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllHWOuts2</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>table AllHWOuts, integer number_of_tracks = ultraschall.GetAllHWOuts2()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    returns a table with all HWOut-settings of all tracks, including master-track(track index: 0)
    
    like [GetAllHWOuts](#GetAllHWOuts) but includes the type of a track as well
    
    returned table is of structure:
      table["HWOuts"]=true                              - signals, this is a HWOuts-table; don't change that!
      table["number\_of_tracks"]                         - the number of tracks in this table, from track 0(master) to track n
      table[tracknumber]["type"]                        - type of the track, SoundBoard, StudioLink, StudioLinkOnAir or Other
      table[tracknumber]["HWOut_count"]                 - the number of HWOuts of tracknumber, beginning with 1
      table[tracknumber][HWOutIndex]["outputchannel"]   - the number of outputchannels of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["post\_pre_fader"] - the setting of post-pre-fader of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["volume"]          - the volume of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["pan"]             - the panning of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["mute"]            - the mute-setting of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["phase"]           - the phase-setting of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["source"]          - the source/input of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["pan\law"]         - pan-law, default is -1
      table[tracknumber][HWOutIndex]["automationmode"]  - the automation-mode of this HWOutIndex of tracknumber    
      
      See [GetTrackHWOut](#GetTrackHWOut) for more details on the individual settings, stored in the entries.
  </description>
  <retvals>
    table AllHWOuts - a table with all HWOuts of the current project.
    integer number_of_tracks - the number of tracks in the AllMainSends-table
  </retvals>
  <chapter_context>
    Ultraschall Specific
    Routing
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>ultraschall, trackmanagement, track, get, all, hwouts, hardware outputs, routing</tags>
</US_DocBloc>
]]

  local AllHWOuts, number_of_tracks = ultraschall.GetAllHWOuts()
  for i=0, number_of_tracks do
    AllHWOuts[i]["type"]=ultraschall.GetTypeOfTrack(i)
  end
  return AllHWOuts, number_of_tracks
end

--A=ultraschall.GetAllHWOuts2()

function ultraschall.GetAllMainSendStates2()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllMainSendStates2</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>table AllMainSends, integer number_of_tracks  = ultraschall.GetAllMainSendStates2()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    returns a table with all MainSend-settings of all tracks, excluding master-track.
    
    like [GetAllMainSendStates](#GetAllMainSendStates), but includes the type of the track as well.
    
    The MainSend-settings are the settings, if a certain track sends it's signal to the Master Track
    
    returned table is of structure:
      Table["number\_of_tracks"]            - The number of tracks in this table, from track 1 to track n
      Table[tracknumber]["type"]           - type of the track, SoundBoard, StudioLink, StudioLinkOnAir or Other
      Table[tracknumber]["MainSend"]       - Send to Master on(1) or off(1)
      Table[tracknumber]["ParentChannels"] - the parent channels of this track
      
      See [GetTrackMainSendState](#GetTrackMainSendState) for more details on the individual settings, stored in the entries.
  </description>
  <retvals>
    table AllMainSends - a table with all AllMainSends-entries of the current project.
    integer number_of_tracks - the number of tracks in the AllMainSends-table
  </retvals>
  <chapter_context>
    Ultraschall Specific
    Routing
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>ultraschall, trackmanagement, track, get, all, send, main send, master send, routing</tags>
</US_DocBloc>
]]

  local AllMainSends, number_of_tracks = ultraschall.GetAllMainSendStates()
  for i=1, number_of_tracks do
    AllMainSends[i]["type"]=ultraschall.GetTypeOfTrack(i)
  end
  return AllMainSends, number_of_tracks
end

--A,B=ultraschall.GetAllMainSendStates2()


function ultraschall.SetUSExternalState(section, key, value)
-- stores value into ultraschall.ini
-- returns true if successful, false if unsuccessful
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetUSExternalState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetUSExternalState(string section, string key, string value)</functioncall>
  <description>
    stores values into ultraschall.ini. Returns true if successful, false if unsuccessful.
    
    unlike other Ultraschall-API-functions, this converts the values, that you pass as parameters, into strings, regardless of their type
  </description>
  <retvals>
    boolean retval - true, if successful, false if unsuccessful.
  </retvals>
  <parameters>
    string section - section within the ini-file
    string key - key within the section
    string value - the value itself
  </parameters>
  <chapter_context>
    Ultraschall Specific
    Ultraschall.ini
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, value, insert, store</tags>
</US_DocBloc>
--]]
  -- check parameters
  section=tostring(section)
  key=tostring(key)
  value=tostring(value)  
  
  if section:match(".*(%=).*")=="=" then ultraschall.AddErrorMessage("SetUSExternalState","section", "no = allowed in section", -4) return false end

  -- set value
  return ultraschall.SetIniFileValue(section, key, value, reaper.GetResourcePath()..ultraschall.Separator.."ultraschall.ini")
end

function ultraschall.GetUSExternalState(section, key)
-- gets a value from ultraschall.ini
-- returns length of entry(integer) and the entry itself(string)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetUSExternalState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string value = ultraschall.GetUSExternalState(string section, string key)</functioncall>
  <description>
    gets a value from ultraschall.ini. 
    
    returns an empty string in case of an error
  </description>
  <retvals>
    string value  - the value itself; empty string in case of an error or no such extstate
  </retvals>
  <parameters>
    string section - the section of the ultraschall.ini.
    string key - the key of which you want it's value.
  </parameters>
  <chapter_context>
    Ultraschall Specific
    Ultraschall.ini
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, value, get</tags>
</US_DocBloc>
--]]
  -- check parameters
  if type(section)~="string" then ultraschall.AddErrorMessage("GetUSExternalState","section", "only string allowed", -1) return "" end
  if type(key)~="string" then ultraschall.AddErrorMessage("GetUSExternalState","key", "only string allowed", -2) return "" end
 
  -- get value
  local A, B = ultraschall.GetIniFileValue(section, key, "", reaper.GetResourcePath()..ultraschall.Separator.."ultraschall.ini")
  return B
end

--A,AA=ultraschall.GetUSExternalState("ultraschall_clock","docked")

function ultraschall.CountUSExternalState_sec()
--count number of sections in the ultraschall.ini
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CountUSExternalState_sec</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer section_count = ultraschall.CountUSExternalState_sec()</functioncall>
  <description>
    returns the number of [sections] in the ultraschall.ini
  </description>
  <retvals>
    integer section_count  - the number of section in the ultraschall.ini
  </retvals>
  <chapter_context>
    Ultraschall Specific
    Ultraschall.ini
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, count, section</tags>
</US_DocBloc>

--]]
  -- check existence of ultraschall.ini
  if reaper.file_exists(reaper.GetResourcePath()..ultraschall.Separator.."ultraschall.ini")==false then ultraschall.AddErrorMessage("CountUSExternalState_sec","", "ultraschall.ini does not exist", -1) return -1 end
  
  -- count external-states
  local count=0
  for line in io.lines(reaper.GetResourcePath()..ultraschall.Separator.."ultraschall.ini") do
    --local check=line:match(".*=.*")
    local check=line:match("%[.*.%]")
    if check~=nil then check="" count=count+1 end
  end
  return count
end

--A=ultraschall.CountUSExternalState_sec()

function ultraschall.CountUSExternalState_key(section)
--count number of keys in the section in ultraschall.ini
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CountUSExternalState_key</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer key_count = ultraschall.CountUSExternalState_key(string section)</functioncall>
  <description>
    returns the number of keys in the given [section] in ultraschall.ini
    
    returns -1 in case of an error
  </description>
  <retvals>
    integer key_count  - the number of keys within an ultraschall.ini-section
  </retvals>
  <parameters>
    string section - the section of the ultraschall.ini, of which you want the number of keys.
  </parameters>
  <chapter_context>
    Ultraschall Specific
    Ultraschall.ini
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, count, key</tags>
</US_DocBloc>
--]]
  -- check parameter and existence of ultraschall.ini
  if type(section)~="string" then ultraschall.AddErrorMessage("CountUSExternalState_key","section", "only string allowed", -1) return -1 end
  if reaper.file_exists(reaper.GetResourcePath()..ultraschall.Separator.."ultraschall.ini")==false then ultraschall.AddErrorMessage("CountUSExternalState_key","", "ultraschall.ini does not exist", -2) return -1 end

  -- prepare variables
  local count=0
  local startcount=0
  
  -- count keys
  for line in io.lines(reaper.GetResourcePath()..ultraschall.Separator.."ultraschall.ini") do
   local check=line:match("%[.*.%]")
    if startcount==1 and line:match(".*=.*") then
      count=count+1
    else
      startcount=0
    if "["..section.."]" == check then startcount=1 end
    if check==nil then check="" end
    end
  end
  
  return count
end

--A=ultraschall.CountUSExternalState_key("view")

function ultraschall.EnumerateUSExternalState_sec(number)
-- returns name of the numberth section in ultraschall.ini or nil, if invalid
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>EnumerateUSExternalState_sec</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string section_name = ultraschall.EnumerateUSExternalState_sec(integer number)</functioncall>
  <description>
    returns name of the numberth section in ultraschall.ini or nil if invalid
  </description>
  <retvals>
    string section_name  - the name of the numberth section within ultraschall.ini
  </retvals>
  <parameters>
    integer number - the number of section, whose name you want to know
  </parameters>
  <chapter_context>
    Configuration-Files Management
    Ultraschall.ini
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, enumerate, section</tags>
</US_DocBloc>
--]]
  -- check parameter and existence of ultraschall.ini
  if math.type(number)~="integer" then ultraschall.AddErrorMessage("EnumerateUSExternalState_sec", "number", "only integer allowed", -1) return false end
  if reaper.file_exists(reaper.GetResourcePath()..ultraschall.Separator.."ultraschall.ini")==false then ultraschall.AddErrorMessage("EnumerateUSExternalState_sec", "", "ultraschall.ini does not exist", -2) return -1 end

  if number<=0 then ultraschall.AddErrorMessage("EnumerateUSExternalState_sec","number", "no negative number allowed", -3) return nil end
  if number>ultraschall.CountUSExternalState_sec() then ultraschall.AddErrorMessage("EnumerateUSExternalState_sec","number", "only "..ultraschall.CountUSExternalState_sec().." sections available", -4) return nil end

  -- look for and return the requested line
  local count=0
  for line in io.lines(reaper.GetResourcePath()..ultraschall.Separator.."ultraschall.ini") do
    local check=line:match("%[.-%]")
    if check~=nil then count=count+1 end
    if count==number then return line:sub(2,-2) end
  end
end 
--A=ultraschall.EnumerateUSExternalState_sec(10)

function ultraschall.EnumerateUSExternalState_key(section, number)
-- returns name of a numberth key within a section in ultraschall.ini or nil if invalid or not existing
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>EnumerateUSExternalState_key</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string key_name = ultraschall.EnumerateUSExternalState_key(string section, integer number)</functioncall>
  <description>
    returns name of a numberth key within a section in ultraschall.ini or nil if invalid or not existing
  </description>
  <retvals>
    string key_name  - the name ob the numberth key in ultraschall.ini.
  </retvals>
  <parameters>
    string section - the section within ultraschall.ini, where the key is stored.
    integer number - the number of the key, whose name you want to know; 1 for the first one
  </parameters>
  <chapter_context>
    Ultraschall Specific
    Ultraschall.ini
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, enumerate, key</tags>
</US_DocBloc>
--]]
  -- check parameter
  if type(section)~="string" then ultraschall.AddErrorMessage("EnumerateUSExternalState_key", "section", "only string allowed", -1) return nil end
  if math.type(number)~="integer" then ultraschall.AddErrorMessage("EnumerateUSExternalState_key", "number", "only integer allowed", -2) return nil end

  -- prepare variables
  local count=0
  local startcount=0
  
  -- find and return the proper line
  for line in io.lines(reaper.GetResourcePath()..ultraschall.Separator.."ultraschall.ini") do
    local check=line:match("%[.*.%]")
    if startcount==1 and line:match(".*=.*") then
      count=count+1
      if count==number then local temp=line:match(".*=") return temp:sub(1,-2) end
    else
      startcount=0
      if "["..section.."]" == check then startcount=1 end
      if check==nil then check="" end
    end
  end
  return nil
end
