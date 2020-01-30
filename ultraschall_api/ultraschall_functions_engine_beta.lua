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


if type(ultraschall)~="table" then 
  -- update buildnumber and add ultraschall as a table, when programming within this file
  local retval, string = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "Functions-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
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
  dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
end
    
function ultraschall.ApiBetaFunctionsTest()
    -- tell the api, that the beta-functions are activated
    ultraschall.functions_beta_works="on"
end

  


--ultraschall.ShowErrorMessagesInReascriptConsole(true)

--ultraschall.WriteValueToFile()

--ultraschall.AddErrorMessage("func","parm","desc",2)




function ultraschall.GetProject_RenderOutputPath(projectfilename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProject_RenderOutputPath</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string render_output_directory = ultraschall.GetProject_RenderOutputPath(string projectfilename_with_path)</functioncall>
  <description>
    returns the output-directory for rendered files of a project.

    Doesn't return the correct output-directory for queued-projects!
    
    returns nil in case of an error
  </description>
  <parameters>
    string projectfilename_with_path - the projectfilename with path, whose renderoutput-directories you want to know
  </parameters>
  <retvals>
    string render_output_directory - the output-directory for projects
  </retvals>
  <chapter_context>
    Project-Files
    Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>render management, get, project, render, outputpath</tags>
</US_DocBloc>
]]
  if type(projectfilename_with_path)~="string" then ultraschall.AddErrorMessage("GetProject_RenderOutputPath", "projectfilename_with_path", "must be a string", -1) return nil end
  if reaper.file_exists(projectfilename_with_path)==false then ultraschall.AddErrorMessage("GetProject_RenderOutputPath", "projectfilename_with_path", "file does not exist", -2) return nil end
  local ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path)
  local QueueRendername=ProjectStateChunk:match("(QUEUED_RENDER_OUTFILE.-)\n")
  local QueueRenderProjectName=ProjectStateChunk:match("(QUEUED_RENDER_ORIGINAL_FILENAME.-)\n")
  local OutputRender, RenderPattern, RenderFile
  
  if QueueRendername~=nil then
    QueueRendername=QueueRendername:match(" \"(.-)\" ")
    QueueRendername=ultraschall.GetPath(QueueRendername)
  end
  
  if QueueRenderProjectName~=nil then
    QueueRenderProjectName=QueueRenderProjectName:match(" (.*)")
    QueueRenderProjectName=ultraschall.GetPath(QueueRenderProjectName)
  end


  RenderFile=ProjectStateChunk:match("(RENDER_FILE.-)\n")
  if RenderFile~=nil then
    RenderFile=RenderFile:match("RENDER_FILE (.*)")
    RenderFile=string.gsub(RenderFile,"\"","")
  end
  
  RenderPattern=ProjectStateChunk:match("(RENDER_PATTERN.-)\n")
  if RenderPattern~=nil then
    RenderPattern=RenderPattern:match("RENDER_PATTERN (.*)")
    if RenderPattern~=nil then
      RenderPattern=string.gsub(RenderPattern,"\"","")
    end
  end

  -- get the normal render-output-directory
  if RenderPattern~=nil and RenderFile~=nil then
    if ultraschall.DirectoryExists2(RenderFile)==true then
      OutputRender=RenderFile
    else
      OutputRender=ultraschall.GetPath(projectfilename_with_path)..ultraschall.Separator..RenderFile
    end
  elseif RenderFile~=nil then
    OutputRender=ultraschall.GetPath(RenderFile)    
  else
    OutputRender=ultraschall.GetPath(projectfilename_with_path)
  end


  -- get the potential RenderQueue-renderoutput-path
  -- not done yet...todo
  -- that way, I may be able to add the currently opened projects as well...
--[[
  if RenderPattern==nil and (RenderFile==nil or RenderFile=="") and
     QueueRenderProjectName==nil and QueueRendername==nil then
    QueueOutputRender=ultraschall.GetPath(projectfilename_with_path)
  elseif RenderPattern~=nil and RenderFile~=nil then
    if ultraschall.DirectoryExists2(RenderFile)==true then
      QueueOutputRender=RenderFile
    end
  end
  --]]
  
  OutputRender=string.gsub(OutputRender,"\\\\", "\\")
  
  return OutputRender, QueueOutputRender
end

--A="c:\\Users\\meo\\Desktop\\trss\\20Januar2019\\rec\\rec3.RPP"

--B,C=ultraschall.GetProject_RenderOutputPath()


function ultraschall.ResolveRenderPattern(renderpattern)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ResolveRenderPattern</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string resolved_renderpattern = ultraschall.ResolveRenderPattern(string render_pattern)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    resolves a render-pattern into its render-filename(without extension).

    returns nil in case of an error    
  </description>
  <parameters>
    string render_pattern - the render-pattern, that you want to resolve into its render-filename
  </parameters>
  <retvals>
    string resolved_renderpattern - the resolved renderpattern, that is used for a render-filename.
                                  - just add extension and path to it.
                                  - Stems will be rendered to path/resolved_renderpattern-XXX.ext
                                  -    where XXX is a number between 001(usually for master-track) and 999
  </retvals>
  <chapter_context>
    Rendering Projects
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>rendermanagement, resolve, renderpattern, filename</tags>
</US_DocBloc>
]]
  if type(renderpattern)~="string" then ultraschall.AddErrorMessage("ResolveRenderPattern", "renderpattern", "must be a string", -1) return nil end
  if renderpattern=="" then return "" end
  local TempProject=ultraschall.Api_Path.."misc/tempproject.RPP"
  local TempFolder=ultraschall.Api_Path.."misc/"
  TempFolder=string.gsub(TempFolder, "\\", ultraschall.Separator)
  TempFolder=string.gsub(TempFolder, "/", ultraschall.Separator)
  
  ultraschall.SetProject_RenderFilename(TempProject, "")
  ultraschall.SetProject_RenderPattern(TempProject, renderpattern)
  ultraschall.SetProject_RenderStems(TempProject, 0)
  
  reaper.Main_OnCommand(41929,0)
  reaper.Main_openProject(TempProject)
  
  A,B=ultraschall.GetProjectStateChunk()
  reaper.Main_SaveProject(0,false)
  reaper.Main_OnCommand(40860,0)
  if B==nil then B="" end
  
  count, split_string = ultraschall.SplitStringAtLineFeedToArray(B)

  for i=1, count do
    split_string[i]=split_string[i]:match("\"(.-)\"")
  end
  if split_string[1]==nil then split_string[1]="" end
  return string.gsub(split_string[1], TempFolder, ""):match("(.-)%.")
end

--for i=1, 10 do
--  O=ultraschall.ResolveRenderPattern("I would find a way $day")
--end

ultraschall.ShowLastErrorMessage()


function ultraschall.InsertMediaItemArray2(position, MediaItemArray, trackstring)
  
--ToDo: Die Möglichkeit die Items in andere Tracks einzufügen. Wenn trackstring 1,3,5 ist, die Items im MediaItemArray
--      in 1,2,3 sind, dann landen die Items aus track 1 in track 1, track 2 in track 3, track 3 in track 5
--
-- Beta 3 Material
  
  if type(position)~="number" then return -1 end
  local trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 then return -1 end
  local count=1
  local i
  if type(MediaItemArray)~="table" then return -1 end
  local NewMediaItemArray={}
  local _count, individual_values = ultraschall.CSV2IndividualLinesAsArray(trackstring) 
  local ItemStart=reaper.GetProjectLength()+1
  while MediaItemArray[count]~=nil do
    local ItemStart_temp=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_POSITION")
    if ItemStart>ItemStart_temp then ItemStart=ItemStart_temp end
    count=count+1
  end
  count=1
  while MediaItemArray[count]~=nil do
    local ItemStart_temp=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_POSITION")
    local MediaTrack=reaper.GetMediaItem_Track(MediaItemArray[count])
    --nur einfügen, wenn mediaitem aus nem Track stammt, der in trackstring vorkommt
    i=1
    while individual_values[i]~=nil do
--    reaper.MB("Yup"..i,individual_values[i],0)
    if reaper.GetTrack(0,individual_values[i]-1)==reaper.GetMediaItem_Track(MediaItemArray[count]) then 
    NewMediaItemArray[count]=ultraschall.InsertMediaItem_MediaItem(position+(ItemStart_temp-ItemStart),MediaItemArray[count],MediaTrack)
    end
    i=i+1
    end
    count=count+1
  end  
--  TrackArray[count]=reaper.GetMediaItem_Track(MediaItem)
--  MediaItem reaper.AddMediaItemToTrack(MediaTrack tr)
end

--C,CC=ultraschall.GetAllMediaItemsBetween(1,60,"1,3",false)
--A,B=reaper.GetItemStateChunk(CC[1], "", true)
--reaper.ShowConsoleMsg(B)
--ultraschall.InsertMediaItemArray(82, CC, "4,5")

--tr = reaper.GetTrack(0, 1)
--MediaItem=reaper.AddMediaItemToTrack(tr)
--Aboolean=reaper.SetItemStateChunk(CC[1], PUH, true)
--PCM_source=reaper.PCM_Source_CreateFromFile("C:\\Recordings\\01-te.flac")
--boolean=reaper.SetMediaItemTake_Source(MediaItem_Take, PCM_source)
--reaper.SetMediaItemInfo_Value(MediaItem, "D_POSITION", "1")
--ultraschall.InsertMediaItemArray(0,CC)


function ultraschall.RippleDrag_Start(position, trackstring, deltalength)
  A,MediaItemArray = ultraschall.GetMediaItemsAtPosition(position, trackstring)
  ultraschall.ChangeDeltaLengthOfMediaItems_FromArray(MediaItemArray, deltalength)
  C,CC=ultraschall.GetAllMediaItemsBetween(position, reaper.GetProjectLength(), trackstring, false)
  for i=C, 1, -1 do
    for j=A, 1, -1 do
--      reaper.MB(j,"",0)
      if MediaItemArray[j]==CC[i] then  table.remove(CC, i) end 
    end
  end
  ultraschall.ChangePositionOfMediaItems_FromArray(CC, deltalength)
end

--ultraschall.RippleDrag_Start(13,"1,2,3",-1)

function ultraschall.RippleDragSection_Start(startposition, endposition, trackstring, newoffset)
end

function ultraschall.RippleDrag_StartOffset(position, trackstring, newoffset)
--unfertig und buggy
  A,MediaItemArray = ultraschall.GetMediaItemsAtPosition(position, trackstring)
  ultraschall.ChangeOffsetOfMediaItems_FromArray(MediaItemArray, newoffset)
  ultraschall.ChangeDeltaLengthOfMediaItems_FromArray(MediaItemArray, -newoffset)
  C,CC=ultraschall.GetAllMediaItemsBetween(position, reaper.GetProjectLength(), trackstring, false)
  for i=C, 1, -1 do
    for j=A, 1, -1 do
--      reaper.MB(j,"",0)
      if MediaItemArray[j]==CC[i] then  table.remove(CC, i) end 
    end
  end
  ultraschall.ChangePositionOfMediaItems_FromArray(CC, newoffset)
end

--ultraschall.RippleDrag_StartOffset(13,"2",10)

--A=ultraschall.CreateRenderCFG_MP3CBR(1, 4, 10)
--B=ultraschall.CreateRenderCFG_MP3CBR(1, 10, 10)
--L,L2,L3,L4=ultraschall.RenderProject_RenderCFG(nil, "c:\\Reaper-Internal-Docs.mp3", 0, 10, false, true, true,A)
--L,L1,L2,L3,L4=ultraschall.RenderProjectRegions_RenderCFG(nil, "c:\\Reaper-Internal-Docs.mp3", 1, false, false, true, true,A)
--L=reaper.IsProjectDirty(0)

--outputchannel, post_pre_fader, volume, pan, mute, phase, source, unknown, automationmode = ultraschall.GetTrackHWOut(0, 1)

--count, MediaItemArray_selected = ultraschall.GetAllSelectedMediaItems() -- get old selection
--A=ultraschall.PutMediaItemsToClipboard_MediaItemArray(MediaItemArray_selected)

---------------------------
---- Routing Snapshots ----
---------------------------

function ultraschall.SetRoutingSnapshot(snapshot_nr)
end

function ultraschall.RecallRoutingSnapshot(snapshot_nr)
end

function ultraschall.ClearRoutingSnapshot(snapshot_nr)
end




function ultraschall.RippleDragSection_StartOffset(position,trackstring)
end

function ultraschall.RippleDrag_End(position,trackstring)

end

function ultraschall.RippleDragSection_End(position,trackstring)
end



--ultraschall.ShowLastErrorMessage()

function ultraschall.GetProjectReWireSlave(projectfilename_with_path)
--To Do
-- ProjectSettings->Advanced->Rewire Slave Settings
end

function ultraschall.GetLastEnvelopePoint(Envelopeobject)
end

function ultraschall.GetAllTrackEnvelopes_EnvelopePointArray(tracknumber)
--returns all track-envelopes from tracknumber as EnvelopePointArray
end

function ultraschall.GetAllTrackEnvelopes_EnvelopePointArray2(MediaTrack)
--returns all track-envelopes from MediaTrack as EnvelopePointArray
end



function ultraschall.OnlyMediaItemsInBothMediaItemArrays()
end

function ultraschall.OnlyMediaItemsInOneMediaItemArray()
end

function ultraschall.GetMediaItemTake_StateChunk(MediaItem, idx)
--returns an rppxml-statechunk for a MediaItemTake (not existing yet in Reaper!), for the idx'th take of MediaItem

--number reaper.GetMediaItemTakeInfo_Value(MediaItem_Take take, string parmname)
--MediaItem reaper.GetMediaItemTake_Item(MediaItem_Take take)

--[[Get parent item of media item take

integer reaper.GetMediaItemTake_Peaks(MediaItem_Take take, number peakrate, number starttime, integer numchannels, integer numsamplesperchannel, integer want_extra_type, reaper.array buf)
Gets block of peak samples to buf. Note that the peak samples are interleaved, but in two or three blocks (maximums, then minimums, then extra). Return value has 20 bits of returned sample count, then 4 bits of output_mode (0xf00000), then a bit to signify whether extra_type was available (0x1000000). extra_type can be 115 ('s') for spectral information, which will return peak samples as integers with the low 15 bits frequency, next 14 bits tonality.

PCM_source reaper.GetMediaItemTake_Source(MediaItem_Take take)
Get media source of media item take

MediaTrack reaper.GetMediaItemTake_Track(MediaItem_Take take)
Get parent track of media item take


MediaItem_Take reaper.GetMediaItemTakeByGUID(ReaProject project, string guidGUID)
--]]
end

function ultraschall.GetAllMediaItemTake_StateChunks(MediaItem)
--returns an array with all rppxml-statechunk for all MediaItemTakes of a MediaItem.
end


function ultraschall.SetReaScriptConsole_FontStyle(style)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>SetReaScriptConsole_FontStyle</slug>
    <requires>
      Ultraschall=4.00
      Reaper=5.965
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.SetReaScriptConsole_FontStyle(integer style)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      If the ReaScript-console is opened, you can change the font-style of it.
      You can choose between 19 different styles, with 3 being of fixed character length. It will change the next time you output text to the ReaScriptConsole.
      
      If you close and reopen the Console, you need to set the font-style again!
      
      You can only have one style active in the console!
      
      Returns false in case of an error
    </description>
    <retvals>
      boolean retval - true, displaying was successful; false, displaying wasn't successful
    </retvals>
    <parameters>
      integer length - the font-style used. There are 19 different ones.
                      - fixed-character-length:
                      -     1,  fixed, console
                      -     2,  fixed, console alt
                      -     3,  thin, fixed
                      - 
                      - normal from large to small:
                      -     4-8
                      -     
                      - bold from largest to smallest:
                      -     9-14
                      - 
                      - thin:
                      -     15, thin
                      - 
                      - underlined:
                      -     16, underlined, thin
                      -     17, underlined
                      -     18, underlined
                      - 
                      - symbol:
                      -     19, symbol
    </parameters>
    <chapter_context>
      User Interface
      Miscellaneous
    </chapter_context>
    <target_document>US_Api_Documentation</target_document>
    <source_document>ultraschall_functions_engine.lua</source_document>
    <tags>user interface, reascript, console, font, style</tags>
  </US_DocBloc>
  ]]
  if math.type(style)~="integer" then ultraschall.AddErrorMessage("SetReaScriptConsole_FontStyle", "style", "must be an integer", -1) return false end
  if style>19 or style<1 then ultraschall.AddErrorMessage("SetReaScriptConsole_FontStyle", "style", "must be between 1 and 17", -2) return false end
  local reascript_console_hwnd = ultraschall.GetReaScriptConsoleWindow()
  if reascript_console_hwnd==nil then return false end
  local styles={32,33,36,31,214,37,218,1606,4373,3297,220,3492,3733,3594,35,1890,2878,3265,4392}
  local Textfield=reaper.JS_Window_FindChildByID(reascript_console_hwnd, 1177)
  reaper.JS_WindowMessage_Send(Textfield, "WM_SETFONT", styles[style] ,0,0,0)
  return true
end
--reaper.ClearConsole()
--ultraschall.SetReaScriptConsole_FontStyle(1)
--reaper.ShowConsoleMsg("ABCDEFGhijklmnop\n123456789.-,!\"§$%&/()=\n----------\nOOOOOOOOOO")




--a,b=reaper.EnumProjects(-1,"")
--A=ultraschall.ReadFullFile(b)

--Mespotine



--[[
hwnd = ultraschall.GetPreferencesHWND()
hwnd2 = reaper.JS_Window_FindChildByID(hwnd, 1110)

--reaper.JS_Window_Move(hwnd2, 110,11)


for i=-1000, 10 do
  A,B,C,D=reaper.JS_WindowMessage_Post(hwnd2, "TVHT_ONITEM", i,i,i,i)
end
--]]


function ultraschall.get_action_context_MediaItemDiff(exlude_mousecursorsize, x, y)
-- TODO:: nice to have feature: when mouse is above crossfades between two adjacent items, return this state as well as a boolean
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>get_action_context_MediaItemDiff</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>MediaItem MediaItem, MediaItem_Take MediaItem_Take, MediaItem MediaItem_unlocked, boolean Item_moved, number StartDiffTime, number EndDiffTime, number LengthDiffTime, number OffsetDiffTime = ultraschall.get_action_context_MediaItemDiff(optional boolean exlude_mousecursorsize, optional integer x, optional integer y)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the currently clicked MediaItem, Take as well as the difference of position, end, length and startoffset since last time calling this function.
    Good for implementing ripple-drag/editing-functions, whose position depends on changes in the currently clicked MediaItem.
    Repeatedly call this (e.g. in a defer-cycle) to get all changes made, during dragging position, length or offset of the MediaItem underneath mousecursor.
    
    This function takes into account the size of the start/end-drag-mousecursor, that means: if mouse-position is within 3 pixels before start/after end of the item, it will get the correct MediaItem. 
    This is a workaround, as the mouse-cursor changes to dragging and can still affect the MediaItem, even though the mouse at this position isn't above a MediaItem anymore.
    To be more strict, set exlude_mousecursorsize to true. That means, it will only detect MediaItems directly beneath the mousecursor. If the mouse isn't above a MediaItem, this function will ignore it, even if the mouse could still affect the MediaItem.
    If you don't understand, what that means: simply omit exlude_mousecursorsize, which should work in almost all use-cases. If it doesn't work as you want, try setting it to true and see, whether it works now.    
    
    returns nil in case of an error
  </description>
  <retvals>
    MediaItem MediaItem - the MediaItem at the current mouse-position; nil if not found
    MediaItem_Take MediaItem_Take - the MediaItem_Take underneath the mouse-cursor
    MediaItem MediaItem_unlocked - if the MediaItem isn't locked, you'll get a MediaItem here. If it is locked, this retval is nil
    boolean Item_moved - true, the item was moved; false, only a part(either start or end or offset) of the item was moved
    number StartDiffTime - if the start of the item changed, this is the difference;
                         -   positive, the start of the item has been changed towards the end of the project
                         -   negative, the start of the item has been changed towards the start of the project
                         -   0, no changes to the itemstart-position at all
    number EndDiffTime - if the end of the item changed, this is the difference;
                         -   positive, the end of the item has been changed towards the end of the project
                         -   negative, the end of the item has been changed towards the start of the project
                         -   0, no changes to the itemend-position at all
    number LengthDiffTime - if the length of the item changed, this is the difference;
                         -   positive, the length is longer
                         -   negative, the length is shorter
                         -   0, no changes to the length of the item
    number OffsetDiffTime - if the offset of the item-take has changed, this is the difference;
                         -   positive, the offset has been changed towards the start of the project
                         -   negative, the offset has been changed towards the end of the project
                         -   0, no changes to the offset of the item-take
                         - Note: this is the offset of the take underneath the mousecursor, which might not be the same size, as the MediaItem itself!
                         - So changes to the offset maybe changes within the MediaItem or the start of the MediaItem!
                         - This could be important, if you want to affect other items with rippling.
  </retvals>
  <parameters>
    optional boolean exlude_mousecursorsize - false or nil, get the item underneath, when it can be affected by the mouse-cursor(dragging etc): when in doubt, use this
                                            - true, get the item underneath the mousecursor only, when mouse is strictly above the item,
                                            -       which means: this ignores the item when mouse is not above it, even if the mouse could affect the item
    optional integer x - nil, use the current x-mouseposition; otherwise the x-position in pixels
    optional integer y - nil, use the current y-mouseposition; otherwise the y-position in pixels
  </parameters>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, get, action, context, difftime, item, mediaitem, offset, length, end, start, locked, unlocked</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then ultraschall.AddErrorMessage("get_action_context_MediaItemDiff", "x", "must be either nil or an integer", -1) return nil end
  if y~=nil and math.type(y)~="integer" then ultraschall.AddErrorMessage("get_action_context_MediaItemDiff", "y", "must be either nil or an integer", -2) return nil end
  if (x~=nil and y==nil) or (y~=nil and x==nil) then ultraschall.AddErrorMessage("get_action_context_MediaItemDiff", "x or y", "must be either both nil or both an integer!", -3) return nil end
  local MediaItem, MediaItem_Take, MediaItem_unlocked
  local StartDiffTime, EndDiffTime, Item_moved, LengthDiffTime, OffsetDiffTime
  if x==nil and y==nil then x,y=reaper.GetMousePosition() end
  MediaItem, MediaItem_Take = reaper.GetItemFromPoint(x, y, true)
  MediaItem_unlocked = reaper.GetItemFromPoint(x, y, false)
  if MediaItem==nil and exlude_mousecursorsize~=true then
    MediaItem, MediaItem_Take = reaper.GetItemFromPoint(x+3, y, true)
    MediaItem_unlocked = reaper.GetItemFromPoint(x+3, y, false)
  end
  if MediaItem==nil and exlude_mousecursorsize~=true then
    MediaItem, MediaItem_Take = reaper.GetItemFromPoint(x-3, y, true)
    MediaItem_unlocked = reaper.GetItemFromPoint(x-3, y, false)
  end
  
  -- crossfade-stuff
  -- example-values for crossfade-parts
  -- Item left: 811 -> 817 , Item right: 818 -> 825
  --               6           7
  -- first:  get, if the next and previous items are at each other/crossing; if nothing -> no crossfade
  -- second: get, if within the aforementioned pixel-ranges, there's another item
  --              6 pixels for the one before the current item
  --              7 pixels for the next item
  -- third: if yes: crossfade-area, else: no crossfade area
  --[[
  -- buggy: need to know the length of the crossfade, as the aforementioned attempt would work only
  --        if the items are adjacent but not if they overlap
  --        also need to take into account, what if zoomed out heavily, where items might be only
  --        a few pixels wide
  
  if MediaItem~=nil then
    ItemNumber = reaper.GetMediaItemInfo_Value(MediaItem, "IP_ITEMNUMBER")
    ItemTrack  = reaper.GetMediaItemInfo_Value(MediaItem, "P_TRACK")
    ItemBefore = reaper.GetTrackMediaItem(ItemTrack, ItemNumber-1)
    ItemAfter = reaper.GetTrackMediaItem(ItemTrack, ItemNumber+1)
    if ItemBefore~=nil then
      ItemBefore_crossfade=reaper.GetMediaItemInfo_Value(ItemBefore, "D_POSITION")+reaper.GetMediaItemInfo_Value(ItemBefore, "D_LENGTH")>=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
    end
  end
  --]]
  
  if ultraschall.get_action_context_MediaItem_old~=MediaItem then
    StartDiffTime=0
    EndDiffTime=0
    LengthDiffTime=0
    OffsetDiffTime=0
    if MediaItem~=nil then
      ultraschall.get_action_context_MediaItem_Start=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
      ultraschall.get_action_context_MediaItem_End=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")+reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
      ultraschall.get_action_context_MediaItem_Length=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
      ultraschall.get_action_context_MediaItem_Offset=reaper.GetMediaItemTakeInfo_Value(MediaItem_Take, "D_STARTOFFS")
    end
  else
    if MediaItem~=nil then      
      StartDiffTime=ultraschall.get_action_context_MediaItem_Start
      EndDiffTime=ultraschall.get_action_context_MediaItem_End
      LengthDiffTime=ultraschall.get_action_context_MediaItem_Length
      OffsetDiffTime=ultraschall.get_action_context_MediaItem_Offset
      
      ultraschall.get_action_context_MediaItem_Start=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
      ultraschall.get_action_context_MediaItem_End=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")+reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
      ultraschall.get_action_context_MediaItem_Length=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
      ultraschall.get_action_context_MediaItem_Offset=reaper.GetMediaItemTakeInfo_Value(MediaItem_Take, "D_STARTOFFS")
      
      Item_moved=(ultraschall.get_action_context_MediaItem_Start~=StartDiffTime
              and ultraschall.get_action_context_MediaItem_End~=EndDiffTime)
              
      StartDiffTime=ultraschall.get_action_context_MediaItem_Start-StartDiffTime
      EndDiffTime=ultraschall.get_action_context_MediaItem_End-EndDiffTime
      LengthDiffTime=ultraschall.get_action_context_MediaItem_Length-LengthDiffTime
      OffsetDiffTime=ultraschall.get_action_context_MediaItem_Offset-OffsetDiffTime
      
    end    
  end
  ultraschall.get_action_context_MediaItem_old=MediaItem

  return MediaItem, MediaItem_Take, MediaItem_unlocked, Item_moved, StartDiffTime, EndDiffTime, LengthDiffTime, OffsetDiffTime
end

--a,b,c,d,e,f,g,h,i=ultraschall.get_action_context_MediaItemDiff(exlude_mousecursorsize, x, y)



function ultraschall.TracksToColorPattern(colorpattern, startingcolor, direction)
end


function ultraschall.GetTrackPositions()
  -- only possible, when tracks can be seen...
  -- no windows above them are allowed :/
  local Arrange_view, timeline, TrackControlPanel = ultraschall.GetHWND_ArrangeViewAndTimeLine()
  local retval, left, top, right, bottom = reaper.JS_Window_GetClientRect(Arrange_view)
  local Tracks={}
  local x=left+2
  local OldItem=nil
  local Counter=0
  local B
  for y=top, bottom do
    A,B=reaper.GetTrackFromPoint(x,y)
    if OldItem~=A and A~=nil then
      Counter=Counter+1
      Tracks[Counter]={}
      Tracks[Counter][tostring(A)]=A
      Tracks[Counter]["Track_Top"]=y
      Tracks[Counter]["Track_Bottom"]=y
      OldItem=A
    elseif A==OldItem and A~=nil and B==0 then
      Tracks[Counter]["Track_Bottom"]=y
    elseif A==OldItem and A~=nil and B==1 then
      if Tracks[Counter]["Env_Top"]==nil then
        Tracks[Counter]["Env_Top"]=y
      end
      Tracks[Counter]["Env_Bottom"]=y
    elseif A==OldItem and A~=nil and B==2 then
      if Tracks[Counter]["TrackFX_Top"]==nil then
        Tracks[Counter]["TrackFX_Top"]=y
      end
      Tracks[Counter]["TrackFX_Bottom"]=y
    end
  end
  return Counter, Tracks
end

--A,B=ultraschall.GetTrackPositions()

function ultraschall.GetAllTrackHeights()
  -- can't calculate the dependency between zoom and trackheight... :/
  HH=reaper.SNM_GetIntConfigVar("defvzoom", -999)
  Heights={}
  for i=0, reaper.CountTracks(0) do
    Heights[i+1], heightstate2, unknown = ultraschall.GetTrackHeightState(i)
   -- if Heights[i+1]==0 then Heights[i+1]=HH end
  end

end

--ultraschall.GetAllTrackHeights()



--[[
A=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
--print2(22)
B=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
--print2(22)
C=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
D=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
E=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
F=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
G=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
H=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
--]]


function ultraschall.GetTrackEnvelope_ClickState()
-- how to get the connection to clicked envelopepoint, when mouse moves away from the item while retaining click(moving underneath the item for dragging)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackEnvelope_ClickState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.981
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>boolean clickstate, number position, MediaTrack track, TrackEnvelope envelope, integer EnvelopePointIDX = ultraschall.GetTrackEnvelope_ClickState()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the currently clicked Envelopepoint and TrackEnvelope, as well as the current timeposition.
    
    Works only, if the mouse is above the EnvelopePoint while having it clicked!
    
    Returns false, if no envelope is clicked at
  </description>
  <retvals>
    boolean clickstate - true, an envelopepoint has been clicked; false, no envelopepoint has been clicked
    number position - the position, at which the mouse has clicked
    MediaTrack track - the track, from which the envelope and it's corresponding point is taken from
    TrackEnvelope envelope - the TrackEnvelope, in which the clicked envelope-point lies
    integer EnvelopePointIDX - the id of the clicked EnvelopePoint
  </retvals>
  <chapter_context>
    Envelope Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>envelope management, get, clicked, envelope, envelopepoint</tags>
</US_DocBloc>
--]]
  -- TODO: Has an issue, if the mousecursor drags the item, but moves above or underneath the item(if item is in first or last track).
  --       Even though the item is still clicked, it isn't returned as such.
  --       The ConfigVar uiscale supports dragging information, but the information which item has been clicked gets lost somehow
  --local B, Track, Info, TrackEnvelope, TakeEnvelope, X, Y
  
  B=reaper.SNM_GetDoubleConfigVar("uiscale", -999)
  if tostring(B)=="-1.#QNAN" then
    ultraschall.EnvelopeClickState_OldTrack=nil
    ultraschall.EnvelopeClickState_OldInfo=nil
    ultraschall.EnvelopeClickState_OldTrackEnvelope=nil
    ultraschall.EnvelopeClickState_OldTakeEnvelope=nil
    return 1
  else
    Track=ultraschall.EnvelopeClickState_OldTrack
    Info=ultraschall.EnvelopeClickState_OldInfo
    TrackEnvelope=ultraschall.EnvelopeClickState_OldTrackEnvelope
    TakeEnvelope=ultraschall.EnvelopeClickState_OldTakeEnvelope
  end
  
  if Track==nil then
    X,Y=reaper.GetMousePosition()
    Track, Info = reaper.GetTrackFromPoint(X,Y)
    ultraschall.EnvelopeClickState_OldTrack=Track
    ultraschall.EnvelopeClickState_OldInfo=Info
  end
  
  -- BUggy, til the end
  -- Ich will hier mir den alten Take auch noch merken, und danach herausfinden, welcher EnvPoint im Envelope existiert, der
  --   a) an der Zeit existiert und
  --   b) selektiert ist
  -- damit könnte ich eventuell es schaffen, die Info zurückzugeben, welcher Envelopepoint gerade beklickt wird.
  if TrackEnvelope==nil then
    reaper.BR_GetMouseCursorContext()
    TrackEnvelope = reaper.BR_GetMouseCursorContext_Envelope()
    ultraschall.EnvelopeClickState_OldTrackEnvelope=TrackEnvelope
  end
  
  if TakeEnvelope==nil then
    reaper.BR_GetMouseCursorContext()
    TakeEnvelope = reaper.BR_GetMouseCursorContext_Envelope()
    ultraschall.EnvelopeClickState_OldTakeEnvelope=TakeEnvelope
  end
  --[[
  
  
  
  reaper.BR_GetMouseCursorContext()
  local TrackEnvelope, TakeEnvelope = reaper.BR_GetMouseCursorContext_Envelope()
  
  if Track==nil then Track=ultraschall.EnvelopeClickState_OldTrack end
  if Track~=nil then ultraschall.EnvelopeClickState_OldTrack=Track end
  if TrackEnvelope~=nil then ultraschall.EnvelopeClickState_OldTrackEnvelope=TrackEnvelope end
  if TrackEnvelope==nil then TrackEnvelope=ultraschall.EnvelopeClickState_OldTrackEnvelope end
  if TakeEnvelope~=nil then ultraschall.EnvelopeClickState_OldTakeEnvelope=TakeEnvelope end
  if TakeEnvelope==nil then TakeEnvelope=ultraschall.EnvelopeClickState_OldTakeEnvelope end
  
  --]]
  --[[
  if TakeEnvelope==true or TrackEnvelope==nil then return false end
  local TimePosition=ultraschall.GetTimeByMouseXPosition(reaper.GetMousePosition())
  local EnvelopePoint=
  return true, TimePosition, Track, TrackEnvelope, EnvelopePoint
  --]]
  if TrackEnvelope==nil then TrackEnvelope=TakeEnvelope end
  return true, ultraschall.GetTimeByMouseXPosition(reaper.GetMousePosition()), Track, TrackEnvelope--, reaper.GetEnvelopePointByTime(TrackEnvelope, TimePosition)
end


function ultraschall.SetLiceCapExe(PathToLiceCapExecutable)
-- works on Mac too?
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetLiceCapExe</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.975
    SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetLiceCapExe(string PathToLiceCapExecutable)</functioncall>
  <description>
    Sets the path and filename of the LiceCap-executable

    Note: Doesn't work on Linux, as there isn't a Linux-port of LiceCap yet.
    
    Returns false in case of error.
  </description>
  <parameters>
    string SetLiceCapExe - the LiceCap-executable with path
  </parameters>
  <retvals>
    boolean retval - false in case of error; true in case of success
  </retvals>
  <chapter_context>
    API-Helper functions
    LiceCap
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, set, licecap, executable</tags>
</US_DocBloc>
]]  
  if type(PathToLiceCapExecutable)~="string" then ultraschall.AddErrorMessage("SetLiceCapExe", "PathToLiceCapExecutable", "Must be a string", -1) return false end
  if reaper.file_exists(PathToLiceCapExecutable)==false then ultraschall.AddErrorMessage("SetLiceCapExe", "PathToLiceCapExecutable", "file not found", -2) return false end
  local A,B=reaper.BR_Win32_WritePrivateProfileString("REAPER", "licecap_path", PathToLiceCapExecutable, reaper.get_ini_file())
  return A
end

--O=ultraschall.SetLiceCapExe("c:\\Program Files (x86)\\LICEcap\\LiceCap.exe")

function ultraschall.SetupLiceCap(output_filename, title, titlems, x, y, right, bottom, fps, gifloopcount, stopafter, prefs)
-- works on Mac too?
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetupLiceCap</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.975
    SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetupLiceCap(string output_filename, string title, integer titlems, integer x, integer y, integer right, integer bottom, integer fps, integer gifloopcount, integer stopafter, integer prefs)</functioncall>
  <description>
    Sets up an installed LiceCap-instance.
    
    To choose the right LiceCap-version, run the action 41298 - Run LICEcap (animated screen capture utility)
    
    Note: Doesn't work on Linux, as there isn't a Linux-port of LiceCap yet.
    
    Returns false in case of error.
  </description>
  <parameters>
    string output_filename - the output-file; you can choose whether it shall be a gif or an lcf by giving it the accompanying extension "mylice.gif" or "milice.lcf"; nil, keep the current outputfile
    string title - the title, which shall be shown at the beginning of the licecap; newlines will be exchanged by spaces, as LiceCap doesn't really support newlines; nil, keep the current title
    integer titlems - how long shall the title be shown, in milliseconds; nil, keep the current setting
    integer x - the x-position of the LiceCap-window in pixels; nil, keep the current setting
    integer y - the y-position of the LiceCap-window in pixels; nil, keep the current setting
    integer right - the right side-position of the LiceCap-window in pixels; nil, keep the current setting
    integer bottom - the bottom-position of the LiceCap-window in pixels; nil, keep the current setting
    integer fps - the maximum frames per seconds, the LiceCap shall have; nil, keep the current setting
    integer gifloopcount - how often shall the gif be looped?; 0, infinite looping; nil, keep the current setting
    integer stopafter - stop recording after xxx milliseconds; nil, keep the current setting
    integer prefs - the preferences-settings of LiceCap, which is a bitfield; nil, keep the current settings
                  - &1 - display in animation: title frame - checkbox
                  - &2 - Big font - checkbox
                  - &4 - display in animation: mouse button press - checkbox
                  - &8 - display in animation: elapsed time - checkbox
                  - &16 - Ctrl+Alt+P pauses recording - checkbox
                  - &32 - Use .GIF transparency for smaller files - checkbox
                  - &64 - Automatically stop after xx seconds - checkbox           
  </parameters>
  <retvals>
    boolean retval - false in case of error; true in case of success
  </retvals>
  <chapter_context>
    API-Helper functions
    LiceCap
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, licecap, setup</tags>
</US_DocBloc>
]]  
  if output_filename~=nil and type(output_filename)~="string" then ultraschall.AddErrorMessage("SetupLiceCap", "output_filename", "Must be a string", -2) return false end
  if title~=nil and type(title)~="string" then ultraschall.AddErrorMessage("SetupLiceCap", "title", "Must be a string", -3) return false end
  if titlems~=nil and math.type(titlems)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "titlems", "Must be an integer", -4) return false end
  if x~=nil and math.type(x)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "x", "Must be an integer", -5) return false end
  if y~=nil and math.type(y)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "y", "Must be an integer", -6) return false end
  if right~=nil and math.type(right)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "right", "Must be an integer", -7) return false end
  if bottom~=nil and math.type(bottom)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "bottom", "Must be an integer", -8) return false end
  if fps~=nil and math.type(fps)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "fps", "Must be an integer", -9) return false end
  if gifloopcount~=nil and math.type(gifloopcount)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "gifloopcount", "Must be an integer", -10) return false end
  if stopafter~=nil and math.type(stopafter)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "stopafter", "Must be an integer", -11) return false end
  if prefs~=nil and math.type(prefs)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "prefs", "Must be an integer", -12) return false end
  
  local CC
  local A,B=reaper.BR_Win32_GetPrivateProfileString("REAPER", "licecap_path", -1, reaper.get_ini_file())
  if B=="-1" or reaper.file_exists(B)==false then ultraschall.AddErrorMessage("SetupLiceCap", "", "LiceCap not installed, please run action \"Run LICEcap (animated screen capture utility)\" to set up LiceCap", -1) return false end
  local Path, File=ultraschall.GetPath(B)
  if reaper.file_exists(Path.."/".."licecap.ini")==false then ultraschall.AddErrorMessage("SetupLiceCap", "", "Couldn't find licecap.ini in LiceCap-path. Is LiceCap really installed?", -13) return false end
  if output_filename~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "lastfn", output_filename, Path.."/".."licecap.ini") end
  if title~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "title", string.gsub(title,"\n"," "), Path.."/".."licecap.ini") end
  if titlems~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "titlems", titlems, Path.."/".."licecap.ini") end
  
  local retval, oldwnd_r=reaper.BR_Win32_GetPrivateProfileString("licecap", "wnd_r", -1, Path.."/".."licecap.ini")  
  if x==nil then x=oldwnd_r:match("(.-) ") end
  if y==nil then y=oldwnd_r:match(".- (.-) ") end
  if right==nil then right=oldwnd_r:match(".- .- (.-) ") end
  if bottom==nil then bottom=oldwnd_r:match(".- .- .- (.*)") end
  
  CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "wnd_r", x.." "..y.." "..right.." "..bottom, Path.."/".."licecap.ini")
  if fps~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "maxfps", fps, Path.."/".."licecap.ini") end
  if gifloopcount~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "gifloopcnt", gifloopcount, Path.."/".."licecap.ini") end
  if stopafter~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "stopafter", stopafter, Path.."/".."licecap.ini") end
  if prefs~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "prefs", prefs, Path.."/".."licecap.ini") end
  
  return true
end


function ultraschall.StartLiceCap(autorun)
-- doesn't work, as I can't click the run and save-buttons
-- maybe I need to add that to the LiceCap-codebase myself...somehow
  reaper.Main_OnCommand(41298, 0)  
  O=0
  while reaper.JS_Window_Find("LICEcap v", false)==nil do
    O=O+1
    if O==1000000 then break end
  end
  local HWND=reaper.JS_Window_Find("LICEcap v", false)
  reaper.JS_WindowMessage_Post(reaper.JS_Window_FindChildByID(HWND, 1001), "WM_LBUTTONDOWN", 1,0,0,0)
  reaper.JS_WindowMessage_Post(reaper.JS_Window_FindChildByID(HWND, 1001), "WM_LBUTTONUP", 1,0,0,0)

  HWNDA0=reaper.JS_Window_Find("Choose file for recording", false)

--[[    
  O=0
  while reaper.JS_Window_Find("Choose file for recording", false)==nil do
    O=O+1
    if O==100 then break end
  end

  HWNDA=reaper.JS_Window_Find("Choose file for recording", false)
  TIT=reaper.JS_Window_GetTitle(HWNDA)
  
  for i=-1000, 10000 do
    if reaper.JS_Window_FindChildByID(HWNDA, i)~=nil then
      print_alt(i, reaper.JS_Window_GetTitle(reaper.JS_Window_FindChildByID(HWNDA, i)))
    end
  end

  print(reaper.JS_Window_GetTitle(reaper.JS_Window_FindChildByID(HWNDA, 1)))

  for i=0, 100000 do
    AA=reaper.JS_WindowMessage_Post(reaper.JS_Window_FindChildByID(HWNDA, 1), "WM_LBUTTONDOWN", 1,0,0,0)
    BB=reaper.JS_WindowMessage_Post(reaper.JS_Window_FindChildByID(HWNDA, 1), "WM_LBUTTONUP", 1,0,0,0)
  end
  
  return HWND
  --]]
  
  ultraschall.WriteValueToFile(ultraschall.API_TempPath.."/LiceCapSave.lua", [[
    dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
    P=0
    
    function main3()
      LiceCapWinPreRoll=reaper.JS_Window_Find(" [stopped]", false)
      LiceCapWinPreRoll2=reaper.JS_Window_Find("LICEcap", false)
      
      if LiceCapWinPreRoll~=nil and LiceCapWinPreRoll2~=nil and LiceCapWinPreRoll2==LiceCapWinPreRoll then
        reaper.JS_Window_Destroy(LiceCapWinPreRoll)
        print("HuiTja", reaper.JS_Window_GetTitle(LiceCapWinPreRoll))
      else
        reaper.defer(main3)
      end
    end
    
    function main2()
      print("HUI:", P)
      A=reaper.JS_Window_Find("Choose file for recording", false)
      if A~=nil and P<20 then  
        P=P+1
        print_alt(reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(A, 1), "WM_LBUTTONDOWN", 1,1,1,1))
        print_alt(reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(A, 1), "WM_LBUTTONUP", 1,1,1,1))
        reaper.defer(main2)
      elseif P~=0 and A==nil then
        reaper.defer(main3)
      else
        reaper.defer(main2)
      end
    end
    
    
    main2()
    ]])
    local retval, script_identifier = ultraschall.Main_OnCommandByFilename(ultraschall.API_TempPath.."/LiceCapSave.lua")
end

--ultraschall.StartLiceCap(autorun)

--ultraschall.SetupLiceCap("Hula", "Hachgotterl\nahh", 20, 1, 2, 3, 4, 123, 1, 987, 64)
--ultraschall.SetupLiceCap("Hurtz.lcf")



function ultraschall.SaveProjectAs(filename_with_path, fileformat, overwrite, create_subdirectory, copy_all_media, copy_rather_than_move)
  -- TODO:  - if a file exists already, fileformats like edl and txt may lead to showing of a overwrite-prompt of the savedialog
  --                this is mostly due Reaper adding the accompanying extension to the filename
  --                must be treated somehow or the other formats must be removed
  --        - convert mediafiles into another format(possible at all?)
  --        - check on Linux and Mac
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SaveProjectAs</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    SWS=2.10.0.1
    JS=0.963
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string newfilename_with_path = ultraschall.SaveProjectAs(string filename_with_path, integer fileformat, boolean overwrite, boolean create_subdirectory, integer copy_all_media, boolean copy_rather_than_move)</functioncall>
  <description>
    Saves the current project under a new filename.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, saving was successful; false, saving wasn't succesful
    string newfilename_with_path - the new projectfilename with path, helpful if you only gave the filename
  </retvals>
  <parameters>
    string filename_with_path - the new projectfile; omitting the path saves the project in the last used folder
    integer fileformat - the fileformat, in which you want to save the project
                       - 0, REAPER Project files (*.RPP)
                       - 1, EDL TXT (Vegas) files (*.TXT)
                       - 2, EDL (Samplitude) files (*.EDL)
    boolean overwrite - true, overwrites the projectfile, if it exists; false, keep an already existing projectfile
    boolean create_subdirectory - true, create a subdirectory for the project; false, save it into the given folder
    integer copy_all_media - shall the project's mediafiles be copied or moved or left as they are?
                           - 0, don't copy/move media
                           - 1, copy the project's mediafiles into projectdirectory
                           - 2, move the project's mediafiles into projectdirectory
    boolean copy_rather_than_move - true, copy rather than move source media if not in old project media path; false, leave the files as they are
  </parameters>
  <chapter_context>
    Project-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>project management, save, project as, edl, rpp, vegas, samplitude</tags>
</US_DocBloc>
--]]
  -- check parameters
  local A=ultraschall.GetSaveProjectAsHWND()
  if A~=nil then ultraschall.AddErrorMessage("SaveProjectAs", "", "SaveAs-dialog already open", -1) return false end
  if type(filename_with_path)~="string" then ultraschall.AddErrorMessage("SaveProjectAs", "filename_with_path", "must be a string", -2) return false end
  local A,B=reaper.BR_Win32_GetPrivateProfileString("REAPER", "lastprojuiref", "", reaper.get_ini_file())
  local C,D=ultraschall.GetPath(B)
  local E,F=ultraschall.GetPath(filename_with_path)
  
  if E=="" then filename_with_path=C..filename_with_path end
  if E~="" and ultraschall.DirectoryExists2(E)==false then 
    reaper.RecursiveCreateDirectory(E,1)
    if ultraschall.DirectoryExists2(E)==false then 
      ultraschall.AddErrorMessage("SaveProjectAs", "filename_with_path", "invalid path", -3)
      return false
    end
  end
  if type(overwrite)~="boolean" then ultraschall.AddErrorMessage("SaveProjectAs", "overwrite", "must be a boolean", -4) return false end
  if type(create_subdirectory)~="boolean" then ultraschall.AddErrorMessage("SaveProjectAs", "create_subdirectory", "must be a boolean", -5) return false end
  if math.type(copy_all_media)~="integer" then ultraschall.AddErrorMessage("SaveProjectAs", "copy_all_media", "must be an integer", -6) return false end
  if type(copy_rather_than_move)~="boolean" then ultraschall.AddErrorMessage("SaveProjectAs", "copy_rather_than_move", "must be a boolean", -7) return false end
  if math.type(fileformat)~="integer" then ultraschall.AddErrorMessage("SaveProjectAs", "fileformat", "must be an integer", -8) return false end
  if fileformat<0 or fileformat>2 then ultraschall.AddErrorMessage("SaveProjectAs", "fileformat", "must be between 0 and 2", -9) return false end
  if copy_all_media<0 or copy_all_media>2 then ultraschall.AddErrorMessage("SaveProjectAs", "copy_all_media", "must be between 0 and 2", -10) return false end
  
  -- management of, if file already exists
  if overwrite==false and reaper.file_exists(filename_with_path)==true then ultraschall.AddErrorMessage("SaveProjectAs", "filename_with_path", "file already exists", -11) return false end
  if overwrite==true and reaper.file_exists(filename_with_path)==true then os.remove(filename_with_path) end

  
  -- create the background-script, which will manage the saveas-dialog and run it
      ultraschall.WriteValueToFile(ultraschall.API_TempPath.."/saveprojectas.lua", [[
      dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
      num_params, params, caller_script_identifier = ultraschall.GetScriptParameters()

      filename_with_path=params[1]
      fileformat=tonumber(params[2])
      create_subdirectory=toboolean(params[3])
      copy_all_media=params[4]
      copy_rather_than_move=toboolean(params[5])
      
      function main2()
        --if A~=nil then print2("Hooray") end
        translation=reaper.JS_Localize("Create subdirectory for project", "DLG_185")
        PP=reaper.JS_Window_Find("Create subdirectory", false)
        A2=reaper.JS_Window_GetParent(PP)
        ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1042), create_subdirectory)
        if copy_all_media==1 then 
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1043), true)
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1044), false)
        elseif copy_all_media==2 then 
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1043), false)
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1044), true)
        else
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1043), false)
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1044), false)
        end
        ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1045), copy_rather_than_move)
        A3=reaper.JS_Window_FindChildByID(A, 0)
        A3=reaper.JS_Window_FindChildByID(A3, 0)
        A3=reaper.JS_Window_FindChildByID(A3, 0)
        A3=reaper.JS_Window_FindChildByID(A3, 0)
        reaper.JS_Window_SetTitle(A3, filename_with_path)
        reaper.JS_WindowMessage_Send(A3, "WM_LBUTTONDOWN", 1,1,1,1)
        reaper.JS_WindowMessage_Send(A3, "WM_LBUTTONUP", 1,1,1,1)
        
        XX=reaper.JS_Window_FindChild(A, "REAPER Project files (*.RPP)", true)

        reaper.JS_WindowMessage_Send(XX, "WM_LBUTTONDOWN", 1,1,1,1)
        reaper.JS_WindowMessage_Send(XX, "WM_LBUTTONUP", 1,1,1,1)
        reaper.JS_WindowMessage_Send(XX, "CB_SETCURSEL", fileformat,0,0,0)
        reaper.JS_WindowMessage_Send(XX, "WM_LBUTTONDOWN", 1,1,1,1)
        reaper.JS_WindowMessage_Send(XX, "WM_LBUTTONUP", 1,1,1,1)
        
        reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(A, 1), "WM_LBUTTONDOWN", 1,1,1,1)
        reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(A, 1), "WM_LBUTTONUP", 1,1,1,1)
      end

      function main1()
        A=ultraschall.GetSaveProjectAsHWND()
        if A==nil then reaper.defer(main1) else main2() end
      end
      
      --print("alive")
      
      main1()
      ]])
      local retval, script_identifier = ultraschall.Main_OnCommandByFilename(ultraschall.API_TempPath.."/saveprojectas.lua", filename_with_path, fileformat, create_subdirectory, copy_all_media, copy_rather_than_move)
    
  -- open SaveAs-dialog
  reaper.Main_SaveProject(0, true)
  -- remove background-script
  os.remove(ultraschall.API_TempPath.."/saveprojectas.lua")
  return true, filename_with_path
end

--reaper.Main_SaveProject(0, true)
--ultraschall.SaveProjectAs("Fix it all of that HUUUIII", true, 0, true)


function ultraschall.TransientDetection_Set(Sensitivity, Threshold, ZeroCrossings)
  -- needs to take care of faulty parametervalues AND of correct value-entering into an already opened
  -- 41208 - Transient detection sensitivity/threshold: Adjust... - dialog
  reaper.SNM_SetDoubleConfigVar("transientsensitivity", Sensitivity) -- 0.0 to 1.0
  reaper.SNM_SetDoubleConfigVar("transientthreshold", Threshold) -- -60 to 0
  local val=reaper.SNM_GetIntConfigVar("tabtotransflag", -999)
  if val&2==2 and ZeroCrossings==false then
    reaper.SNM_SetIntConfigVar("tabtotransflag", val-2)
  elseif val&2==0 and ZeroCrossings==true then
    reaper.SNM_SetIntConfigVar("tabtotransflag", val+2)
  end
end

--ultraschall.TransientDetection_Set(0.1, -9, false)



function ultraschall.ReadSubtitles_VTT(filename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ReadSubtitles_VTT</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string Kind, string Language, integer Captions_Counter, table Captions = ultraschall.ReadSubtitles_VTT(string filename_with_path)</functioncall>
  <description>
    parses a webvtt-subtitle-file and returns its contents as table
    
    returns nil in case of an error
  </description>
  <retvals>
    string Kind - the type of the webvtt-file, like: captions
    string Language - the language of the webvtt-file
    integer Captions_Counter - the number of captions in the file
    table Captions - the Captions as a table of the format:
                   -    Captions[index]["start"]= the starttime of this caption in seconds
                   -    Captions[index]["end"]= the endtime of this caption in seconds
                   -    Captions[index]["caption"]= the caption itself
  </retvals>
  <parameters>
    string filename_with_path - the filename with path of the webvtt-file
  </parameters>
  <chapter_context>
    File Management
    Read Files
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement, read, file, webvtt, subtitle, import</tags>
</US_DocBloc>
--]]
  if type(filename_with_path)~="string" then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "must be a string", -1) return end
  if reaper.file_exists(filename_with_path)=="false" then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "must be a string", -2) return end
  local A, Type, Offset, Kind, Language, Subs, Subs_Counter, i
  Subs={}
  Subs_Counter=0
  A=ultraschall.ReadFullFile(filename_with_path)
  Type, Offset=A:match("(.-)\n()")
  if Type~="WEBVTT" then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "not a webvtt-file", -3) return end
  A=A:sub(Offset,-1)
  Kind, Offset=A:match(".-: (.-)\n()")
  A=A:sub(Offset,-1)
  Language, Offset=A:match(".-: (.-)\n()")
  A=A:sub(Offset,-1)
  
  i=0
  for k in string.gmatch(A, "(.-)\n") do
    i=i+1
    if i==2 then 
      Subs_Counter=Subs_Counter+1
      Subs[Subs_Counter]={} 
      Subs[Subs_Counter]["start"], Subs[Subs_Counter]["end"] = k:match("(.-) --> (.*)")
      if Subs[Subs_Counter]["start"]==nil or Subs[Subs_Counter]["end"]==nil then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "can't parse the file; probably invalid", -3) return end
      Subs[Subs_Counter]["start"]=reaper.parse_timestr(Subs[Subs_Counter]["start"])
      Subs[Subs_Counter]["end"]=reaper.parse_timestr(Subs[Subs_Counter]["end"])
    elseif i==3 then 
      Subs[Subs_Counter]["caption"]=k
      if Subs[Subs_Counter]["caption"]==nil then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "can't parse the file; probably invalid", -4) return end
    end
    if i==3 then i=0 end
  end
  
  
  return Kind, Language, Subs_Counter, Subs
end


--A,B,C,D,E=ultraschall.ReadSubtitles_VTT("c:\\test.vtt")

-- These seem to work:

function ultraschall.LoadFXStateChunkFromRFXChainFile(filename, trackfx_or_takefx)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>LoadFXStateChunkFromRFXChainFile</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>string FXStateChunk = ultraschall.LoadFXStateChunkFromRFXChainFile(string filename, integer trackfx_or_takefx)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Loads an FXStateChunk from an RFXChain-file.
    
    If you don't give a path, it will try to load the file from the folder ResourcePath()/FXChains.
    
    returns nil in case of an error
  </description>
  <retvals>
    string FXStateChunk - the loaded FXStateChunk; nil, in case of an error
  </retvals>
  <parameters>
    string filename - the filename of the RFXChain-file(must include ".RfxChain"); omit the path to load it from the folder ResourcePath()/FXChains
    integer trackfx_or_takefx - 0, return the FXStateChunk as Track-FXStateChunk; 1, return the FXStateChunk as Take-FXStateChunk
  </parameters>
  <chapter_context>
    FX-Management
    FXStateChunks
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>fx management, load, fxstatechunk, trackfx, itemfx, takefx, rfxchain</tags>
</US_DocBloc>
]]
  if type(filename)~="string" then ultraschall.AddErrorMessage("LoadFXStateChunkFromRFXChainFile", "filename", "must be a string", -1) return end
  if reaper.file_exists(filename)==false and reaper.file_exists(reaper.GetResourcePath().."/FXChains/"..filename)==false then
    ultraschall.AddErrorMessage("LoadFXStateChunkFromRFXChainFile", "filename", "file not found", -2) return
  end
  if math.type(trackfx_or_takefx)~="integer" then ultraschall.AddErrorMessage("LoadFXStateChunkFromRFXChainFile", "trackfx_or_takefx", "must be an integer", -3) return end
  if trackfx_or_takefx~=0 and trackfx_or_takefx~=1 then ultraschall.AddErrorMessage("LoadFXStateChunkFromRFXChainFile", "trackfx_or_takefx", "must be either 0(TrackFX) or 1 (TakeFX)", -4) return end
  ultraschall.SuppressErrorMessages(true)
  local FXStateChunk=ultraschall.ReadFullFile(filename)
  if FXStateChunk==nil then FXStateChunk=ultraschall.ReadFullFile(reaper.GetResourcePath().."/FXChains/"..filename) end
  ultraschall.SuppressErrorMessages(false)
  if FXStateChunk:sub(1,6)~="BYPASS" then ultraschall.AddErrorMessage("LoadFXStateChunkFromRFXChainFile", "filename", "no FXStateChunk found or RFXChain-file is empty", -5) return end
  if trackfx_or_takefx==0 then 
    FXStateChunk="<FXCHAIN\n"..FXStateChunk
  else 
    FXStateChunk="<TAKEFX\n"..FXStateChunk
  end
  return ultraschall.StateChunkLayouter(FXStateChunk)..">"
end

function ultraschall.SaveFXStateChunkAsRFXChainfile(filename, FXStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SaveFXStateChunkAsRFXChainfile</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.SaveFXStateChunkAsRFXChainfile(string filename, string FXStateChunk)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Loads an FXStateChunk from an RFXChain-file.
    
    If you don't give a path, it will try to load the file from the folder ResourcePath/FXChains.
    
    returns -1 in case of an error
  </description>
  <retvals>
    integer retval - -1 in case of failure, 1 in case of success
  </retvals>
  <parameters>
    string filename - the filename of the output-RFXChain-file(must include ".RfxChain"); omit the path to save it into the folder ResourcePath/FXChains
    string FXStateChunk - the FXStateChunk, which you want to set into the TrackStateChunk
  </parameters>
  <chapter_context>
    FX-Management
    FXStateChunks
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>fx management, save, fxstatechunk, trackfx, itemfx, takefx, rfxchain</tags>
</US_DocBloc>
]]
  if type(filename)~="string" then ultraschall.AddErrorMessage("SaveFXStateChunkAsRFXChainfile", "FXStateChunk", "Must be a string.", -1) return -1 end
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("SaveFXStateChunkAsRFXChainfile", "FXStateChunk", "Not a valid FXStateChunk.", -2) return -1 end
  if filename:match("/")==nil and filename:match("\\")==nil then filename=reaper.GetResourcePath().."/FXChains/"..filename end
  local New=FXStateChunk:match(".-\n(.*)>")
  local New2=""
  if New:sub(1,2)=="  " then
    for k in string.gmatch(New, "(.-)\n") do
      New2=New2..k:sub(3,-1).."\n"
    end
    New=New2:sub(1,-2)
  end
  return ultraschall.WriteValueToFile(filename, New)
end

function ultraschall.GetAllRFXChainfilenames()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllRFXChainfilenames</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer count_of_RFXChainfiles, array RFXChainfiles = ultraschall.GetAllRFXChainfilenames()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns all available RFXChainfiles in the folder ResourcePath/FXChains
  </description>
  <retvals>
    integer count_of_RFXChainfiles - the number of available RFXChainFiles
    array RFXChainfiles - the filenames of the RFXChainfiles
  </retvals>
  <chapter_context>
    FX-Management
    FXStateChunks
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>fx management, get, trackfx, itemfx, takefx, rfxchain, all, filenames, fxchains</tags>
</US_DocBloc>
]]
  local A,B=ultraschall.GetAllFilenamesInPath(reaper.GetResourcePath().."/FXChains/")
  local C=(reaper.GetResourcePath().."/FXChains/"):len()
  for i=1, A do
    B[i]=B[i]:sub(C+1, -1)
  end
  return A,B
end

function ultraschall.GetRecentProjects()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetRecentProjects</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>integer count_of_RecentProjects, array RecentProjectsFilenamesWithPath = ultraschall.GetRecentProjects()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    returns all available recent projects, as listed in the File -> Recent projects-menu
  </description>
  <retvals>
    integer count_of_RecentProjects - the number of available recent projects
    array RecentProjectsFilenamesWithPath - the filenames of the recent projects
  </retvals>
  <chapter_context>
    Project-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>projectmanagement, get, all, recent, projects, filenames, rpp</tags>
</US_DocBloc>
]]
  local Length_of_value, Count = ultraschall.GetIniFileValue("REAPER", "numrecent", -100, reaper.get_ini_file())
  local Count=tonumber(Count)
  local RecentProjects={}
  for i=1, Count do
    if i<10 then zero="0" else zero="" end
    Length_of_value, RecentProjects[i] = ultraschall.GetIniFileValue("Recent", "recent"..zero..i, -100, reaper.get_ini_file())  
  end
  
  return Count, RecentProjects
end

function ultraschall.GetRecentFX()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetRecentFX</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>integer count_of_RecentFX, array RecentFX = ultraschall.GetRecentFX()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the recent fx-list
  </description>
  <retvals>
    integer count_of_RecentFX - the number of available recent fx
    array RecentFX - the names of the recent fx
  </retvals>
  <chapter_context>
    FX-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>fxmanagement, get, all, recent, fx</tags>
</US_DocBloc>
]]
  local Length_of_value, Count = ultraschall.GetIniFileValue("RecentFX", "Count", -100, reaper.get_ini_file())
  local Count=tonumber(Count)
  local RecentFXs={}
  for i=1, Count do
    if i<10 then zero="0" else zero="" end
    Length_of_value, RecentFXs[i] = ultraschall.GetIniFileValue("RecentFX", "RecentFX"..zero..i, -100, reaper.get_ini_file())  
  end
  
  return Count, RecentFXs
end

function ultraschall.QueryKeyboardShortcutByKeyID(modifier, key)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>QueryKeyboardShortcutByKeyID</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>string Shortcutname = ultraschall.QueryKeyboardShortcutByKeyID(integer modifier, integer key)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the name of the shortcut of the modifier-key-values, as stored in the KEY-entries within the reaper-kb.ini
    
    That way, you can take a KEY-entry from the reaper-kb.ini, like
     
          KEY 1 65 _Ultraschall_Play_From_Editcursor_Position 0
          
    Extract the modifier and key-values(1 and 65 in the example) and pass them to this function.
    You will get returned "A" as 1 and 65 is the keyboard-shortcut-code for the A-key.
    
    Only necessary for those, who try to read keyboard-shortcuts directly from the reaper-kb.ini to display them in some way.
    
    returns nil in case of an error
  </description>
  <retvals>
    string Shortcutname - the actual name of the shortcut, like "A" or "F1" or "Ctrl+Alt+Shift+Win+PgUp".
  </retvals>
  <parameters>
    integer modifier - the modifier value, which is the first one after KEY in a KEY-entry in the reaper-kb.ini-file
    integer key - the key value, which is the second one after KEY in a KEY-entry in the reaper-kb.ini-file
  </parameters>
  <chapter_context>
    Configuration-Files Management
    Reaper-kb.ini
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurations management, key, shortcut, name, query, get</tags>
</US_DocBloc>
]]
  if math.type(modifier)~="integer" then ultraschall.AddErrorMessage("QueryKeyboardShortcutByKeyID", "modifier", "must be an integer", -1) return nil end
  if math.type(key)~="integer" then ultraschall.AddErrorMessage("QueryKeyboardShortcutByKeyID", "key", "must be an integer", -2) return nil end
  local length_of_value, value = ultraschall.GetIniFileValue("Code", modifier.."_"..key, -999, ultraschall.Api_Path.."/IniFiles/Reaper-KEY-Codes_for_reaper-kb_ini.ini")
  return value
end

function ultraschall.QueryMIDIMessageNameByID(modifier, key)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>QueryMIDIMessageNameByID</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>string midimessage_name = ultraschall.QueryMIDIMessageNameByID(integer modifier, integer key)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the name of the MIDI-message, as used by Reaper's function StuffMIDIMessage.
    
    Just pass over the first and second value. The last one is always velocity, which is ~=0 for it to be accepted.
    However, some codes don't have a name associated. In that case, this function returns "-1"
    
    Only returns the names for mode 1 and english on Windows!
    
    returns nil in case of an error
  </description>
  <retvals>
    string midimessage_name - the actual name of the midi-message, like "A" or "F1" or "Ctrl+Alt+Shift+Win+PgUp".
  </retvals>
  <parameters>
    integer modifier - the modifier value, which is the second parameter of StuffMIDIMessage
    integer key - the key value, which is the third parameter of StuffMIDIMessage
  </parameters>
  <chapter_context>
    MIDI Management
    Notes
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurations management, key, shortcut, name, query, get</tags>
</US_DocBloc>
]]
  if math.type(modifier)~="integer" then ultraschall.AddErrorMessage("QueryMIDIMessageNameByID", "modifier", "must be an integer", -1) return nil end
  if math.type(key)~="integer" then ultraschall.AddErrorMessage("QueryMIDIMessageNameByID", "key", "must be an integer", -2) return nil end
  local length_of_value, value = ultraschall.GetIniFileValue("All_StuffMIDIMessage_Messages_english_windows", modifier.."_"..key.."_1", -1, ultraschall.Api_Path.."/IniFiles/StuffMidiMessage-AllMessages_Englisch_Windows.ini")
  return value
end

function ultraschall.GetAllThemeLayoutNames()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllThemeLayoutNames</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer index, table ThemeLayoutNames= ultraschall.GetAllThemeLayoutNames()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    returns all layout-names and values of the current theme
    
    the table ThemeLayoutNames is of the following format:
    
      ThemeLayoutNames[parameter_index]["layout section"] - the name of the layout-section of the parameter
      ThemeLayoutNames[parameter_index]["value"] - the value of the parameter
      ThemeLayoutNames[parameter_index]["description"] - the description of the parameter
    
    returns nil in case of an error
  </description>
  <retvals>
    integer index - the number of theme-layout-parameters available
    table ThemeLayoutParameters - a table with all theme-layout-parameter available in the current theme
  </retvals>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>theme management, get, all, parameters</tags>
</US_DocBloc>
]]
  local Aretval=true
  local Layoutnames={}
  local i=1
  while Aretval==true do
    Layoutnames[i]={}
    Aretval, Layoutnames[i]["layout section"] = reaper.ThemeLayout_GetLayout("seclist", i)
    Aretval, Layoutnames[i]["value"] = reaper.ThemeLayout_GetLayout(Layoutnames[i]["layout section"], -1)
    Aretval, Layoutnames[i]["description"] = reaper.ThemeLayout_GetLayout(Layoutnames[i]["layout section"], -2)
    
    i=i+1
  end
  table.remove(Layoutnames, i-1)
  return i-2, Layoutnames
end

--A,B,C=ultraschall.GetAllThemeLayoutNames()

--Q,R = reaper.ThemeLayout_GetLayout("trans", -1)

function ultraschall.GetAllThemeLayoutParameters()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllThemeLayoutParameters</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer index, table ThemeLayoutParameters = ultraschall.GetAllThemeLayoutParameters()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    returns all theme-layout-parameter attributes of the current theme
    
    the table ThemeLayoutParameters is of the following format:
    
      ThemeLayoutParameters[parameter_index]["name"] - the name of the parameter
      ThemeLayoutParameters[parameter_index]["description"] - the description of the parameter
      ThemeLayoutParameters[parameter_index]["value"] - the value of the parameter
      ThemeLayoutParameters[parameter_index]["value default"] - the defult value of the parameter
      ThemeLayoutParameters[parameter_index]["value min"] - the minimum value of the parameter
      ThemeLayoutParameters[parameter_index]["value max"] - the maximum value of the parameter
    
    returns nil in case of an error
  </description>
  <retvals>
    integer index - the number of theme-layout-parameters available
    table ThemeLayoutParameters - a table with all theme-layout-parameter available in the current theme
  </retvals>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>theme management, get, all, parameters</tags>
</US_DocBloc>
]]
  local i=1
  local ParamsIdx ={}
  
  while reaper.ThemeLayout_GetParameter(i) ~= nil do
    local tmp, desc, C, D, E, F = reaper.ThemeLayout_GetParameter(i)
    ParamsIdx[i]={}
    ParamsIdx[i]["name"]=tmp
    ParamsIdx[i]["description"]=desc
    ParamsIdx[i]["value"]=C
    ParamsIdx[i]["value default"]=D
    ParamsIdx[i]["value min"]=E
    ParamsIdx[i]["value max"]=F
    
    i = i + 1
  end
  
  return i-1, ParamsIdx
end


function ultraschall.GetEnvelopeState_NumbersOnly(state, EnvelopeStateChunk, functionname, numbertoggle)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetEnvelopeState_NumbersOnly</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>table values = ultraschall.GetEnvelopeState_NumbersOnly(string state, optional string EnvelopeStateChunk, optional string functionname, optional boolean numbertoggle)</functioncall>
  <description>
    returns a state from an EnvelopeStateChunk.
    
    It only supports single-entry-states with numbers/integers, separated by spaces!
    All other values will be set to nil and strings with spaces will produce weird results!
    
    returns nil in case of an error
  </description>
  <parameters>
    string state - the state, whose attributes you want to retrieve
    string TrackStateChunk - a statechunk of an envelope
    optional string functionname - if this function is used within specific gettrackstate-functions, pass here the "host"-functionname, so error-messages will reflect that
    optional boolean numbertoggle - true or nil; converts all values to numbers; false, keep them as string versions
  </parameters>
  <retvals>
    table values - all values found as numerical indexed array
  </retvals>
  <chapter_context>
    Envelope Management
    Get Envelope States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>envelopemanagement, get, state, envelopestatechunk, envelope</tags>
</US_DocBloc>
]]
  if functionname~=nil and type(functionname)~="string" then ultraschall.AddErrorMessage(functionname,"functionname", "Must be a string or nil!", -6) return nil end
  if functionname==nil then functionname="GetEnvelopeState_NumbersOnly" end
  if type(state)~="string" then ultraschall.AddErrorMessage(functionname, "state", "Must be a string", -7) return nil end
  if projectfilename_with_path==nil and ultraschall.IsValidEnvStateChunk(EnvelopeStateChunk)==false then ultraschall.AddErrorMessage(functionname,"TrackStateChunk", "No valid TrackStateChunk!", -2) return nil end
  
  EnvelopeStateChunk=EnvelopeStateChunk:match(state.." (.-)\n")
  if EnvelopeStateChunk==nil then return end
  local count, individual_values = ultraschall.CSV2IndividualLinesAsArray(EnvelopeStateChunk, " ")
  if numbertoggle~=false then
    for i=1, count do
      individual_values[i]=tonumber(individual_values[i])
    end
  end
  return table.unpack(individual_values)
end

function ultraschall.GetEnvelopeState_Act(TrackEnvelope, EnvelopeStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetEnvelopeState_Act</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer act, integer automation_settings = ultraschall.GetEnvelopeState_Act(TrackEnvelope TrackEnvelope, optional string EnvelopeStateChunk)</functioncall>
  <description>
    Returns the current act-state of a TrackEnvelope-object or EnvelopeStateChunk.
    
    It is the state entry ACT
    
    returns nil in case of error
  </description>
  <retvals>
    integer act - 0, bypass on
                - 1, no bypass
    integer automation_settings - automation item-options for this envelope
                                - -1, project default behavior, outside of automation items
                                - 0, automation items do not attach underlying envelope
                                - 1, automation items attach to the underlying envelope on the right side
                                - 2, automation items attach to the underlying envelope on both sides
                                - 3, no automation item-options for this envelope
                                - 4, bypass underlying envelope outside of automation items
  </retvals>
  <parameters>
    TrackEnvelope TrackEnvelope - the TrackEnvelope, whose state you want to know; nil, to use parameter EnvelopeStateChunk instead
    optional string EnvelopeStateChunk - if TrackEnvelope is set to nil, you can pass an EnvelopeStateChunk into this parameter, to get that armed state
  </parameters>
  <chapter_context>
    Envelope Management
    Get Envelope States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>envelope states, get, act, envelopestatechunk</tags>
</US_DocBloc>
]]  
  if TrackEnvelope~=nil and ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("GetEnvelopeState_Act", "TrackEnvelope", "Must be a valid TrackEnvelope-object", -1) return end
  if TrackEnvelope==nil and ultraschall.IsValidEnvStateChunk(EnvelopeStateChunk)==false then ultraschall.AddErrorMessage("GetEnvelopeState_Act", "EnvelopeStateChunk", "Must be a valid EnvelopeStateChunk", -2) return end
  local retval, str
  if TrackEnvelope==nil then 
    str=EnvelopeStateChunk
  else
    retval, str = reaper.GetEnvelopeStateChunk(TrackEnvelope, "", false)
  end
  return ultraschall.GetEnvelopeState_NumbersOnly("ACT", str, "GetEnvelopeState_Act")
end

function ultraschall.GetEnvelopeState_Vis(TrackEnvelope, EnvelopeStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetEnvelopeState_Vis</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer visible, integer lane, integer unknown = ultraschall.GetEnvelopeState_Vis(TrackEnvelope TrackEnvelope, optional string EnvelopeStateChunk)</functioncall>
  <description>
    Returns the current visibility-state of a TrackEnvelope-object or EnvelopeStateChunk.
    
    It is the state entry VIS
    
    returns nil in case of error
  </description>
  <retvals>
    integer visible - 1, envelope is visible
                    - 0, envelope is not visible
    integer lane - 1, envelope is in it's own lane 
                 - 0, envelope is in media-lane
    integer unknown - unknown; default=1
  </retvals>
  <parameters>
    TrackEnvelope TrackEnvelope - the TrackEnvelope, whose state you want to know; nil, to use parameter EnvelopeStateChunk instead
    optional string EnvelopeStateChunk - if TrackEnvelope is set to nil, you can pass an EnvelopeStateChunk into this parameter, to get that armed state
  </parameters>
  <chapter_context>
    Envelope Management
    Get Envelope States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>envelope states, get, vis, envelopestatechunk</tags>
</US_DocBloc>
]]  
  if TrackEnvelope~=nil and ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("GetEnvelopeState_Vis", "TrackEnvelope", "Must be a valid TrackEnvelope-object", -1) return end
  if TrackEnvelope==nil and ultraschall.IsValidEnvStateChunk(EnvelopeStateChunk)==false then ultraschall.AddErrorMessage("GetEnvelopeState_Vis", "EnvelopeStateChunk", "Must be a valid EnvelopeStateChunk", -2) return end
  local retval, str
  if TrackEnvelope==nil then 
    str=EnvelopeStateChunk
  else
    retval, str = reaper.GetEnvelopeStateChunk(TrackEnvelope, "", false)
  end
  return ultraschall.GetEnvelopeState_NumbersOnly("VIS", str, "GetEnvelopeState_Vis")
end

function ultraschall.GetEnvelopeState_LaneHeight(TrackEnvelope, EnvelopeStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetEnvelopeState_LaneHeight</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer height, integer compacted = ultraschall.GetEnvelopeState_LaneHeight(TrackEnvelope TrackEnvelope, optional string EnvelopeStateChunk)</functioncall>
  <description>
    Returns the current laneheight-state of a TrackEnvelope-object or EnvelopeStateChunk.
    
    It is the state entry LANEHEIGHT
    
    returns nil in case of error
  </description>
  <retvals>
    integer height - the height of this envelope in pixels; 24 - 263 pixels
    integer compacted - 1, envelope-lane is compacted("normal" height is not shown but still stored in height); 
                      - 0, envelope-lane is "normal" height
  </retvals>
  <parameters>
    TrackEnvelope TrackEnvelope - the TrackEnvelope, whose state you want to know; nil, to use parameter EnvelopeStateChunk instead
    optional string EnvelopeStateChunk - if TrackEnvelope is set to nil, you can pass an EnvelopeStateChunk into this parameter, to get that armed state
  </parameters>
  <chapter_context>
    Envelope Management
    Get Envelope States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>envelope states, get, laneheight, envelopestatechunk</tags>
</US_DocBloc>
]]  
  if TrackEnvelope~=nil and ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("GetEnvelopeState_LaneHeight", "TrackEnvelope", "Must be a valid TrackEnvelope-object", -1) return end
  if TrackEnvelope==nil and ultraschall.IsValidEnvStateChunk(EnvelopeStateChunk)==false then ultraschall.AddErrorMessage("GetEnvelopeState_LaneHeight", "EnvelopeStateChunk", "Must be a valid EnvelopeStateChunk", -2) return end
  local retval, str
  if TrackEnvelope==nil then 
    str=EnvelopeStateChunk
  else
    retval, str = reaper.GetEnvelopeStateChunk(TrackEnvelope, "", false)
  end
  return ultraschall.GetEnvelopeState_NumbersOnly("LANEHEIGHT", str, "GetEnvelopeState_LaneHeight")
end

function ultraschall.GetEnvelopeState_DefShape(TrackEnvelope, EnvelopeStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetEnvelopeState_DefShape</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer shape, integer b, integer c = ultraschall.GetEnvelopeState_DefShape(TrackEnvelope TrackEnvelope, optional string EnvelopeStateChunk)</functioncall>
  <description>
    Returns the current default-shape-state of a TrackEnvelope-object or EnvelopeStateChunk.
    
    It is the state entry DEFSHAPE
    
    returns nil in case of error
  </description>
  <retvals>
   integer shape - 0, linear
                 - 1, square
                 - 2, slow start/end
                 - 3, fast start
                 - 4, fast end
                 - 5, bezier
   integer b - unknown; default value is -1; probably pitch/snap
             - -1, unknown
             -  2, unknown                        
   integer c - unknown; default value is -1; probably pitch/snap
             - -1, unknown
             -  2, unknown 
  </retvals>
  <parameters>
    TrackEnvelope TrackEnvelope - the TrackEnvelope, whose state you want to know; nil, to use parameter EnvelopeStateChunk instead
    optional string EnvelopeStateChunk - if TrackEnvelope is set to nil, you can pass an EnvelopeStateChunk into this parameter, to get that armed state
  </parameters>
  <chapter_context>
    Envelope Management
    Get Envelope States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>envelope states, get, defshape, envelopestatechunk</tags>
</US_DocBloc>
]]  
  if TrackEnvelope~=nil and ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("GetEnvelopeState_DefShape", "TrackEnvelope", "Must be a valid TrackEnvelope-object", -1) return end
  if TrackEnvelope==nil and ultraschall.IsValidEnvStateChunk(EnvelopeStateChunk)==false then ultraschall.AddErrorMessage("GetEnvelopeState_DefShape", "EnvelopeStateChunk", "Must be a valid EnvelopeStateChunk", -2) return end
  local retval, str
  if TrackEnvelope==nil then 
    str=EnvelopeStateChunk
  else
    retval, str = reaper.GetEnvelopeStateChunk(TrackEnvelope, "", false)
  end
  return ultraschall.GetEnvelopeState_NumbersOnly("DEFSHAPE", str, "GetEnvelopeState_DefShape")
end

function ultraschall.GetEnvelopeState_Voltype(TrackEnvelope, EnvelopeStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetEnvelopeState_Voltype</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer voltype = ultraschall.GetEnvelopeState_Voltype(TrackEnvelope TrackEnvelope, optional string EnvelopeStateChunk)</functioncall>
  <description>
    Returns the current voltype-state of a TrackEnvelope-object or EnvelopeStateChunk.
    
    It is the state entry VOLTYPE
    
    returns nil in case of error
  </description>
  <retvals>
   integer voltype - 1, default volume-type is fader-scaling; if VOLTYPE-entry is not existing, default volume-type is amplitude-scaling
  </retvals>
  <parameters>
    TrackEnvelope TrackEnvelope - the TrackEnvelope, whose state you want to know; nil, to use parameter EnvelopeStateChunk instead
    optional string EnvelopeStateChunk - if TrackEnvelope is set to nil, you can pass an EnvelopeStateChunk into this parameter, to get that armed state
  </parameters>
  <chapter_context>
    Envelope Management
    Get Envelope States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>envelope states, get, voltype, envelopestatechunk</tags>
</US_DocBloc>
]]  
  if TrackEnvelope~=nil and ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("GetEnvelopeState_Voltype", "TrackEnvelope", "Must be a valid TrackEnvelope-object", -1) return end
  if TrackEnvelope==nil and ultraschall.IsValidEnvStateChunk(EnvelopeStateChunk)==false then ultraschall.AddErrorMessage("GetEnvelopeState_Voltype", "EnvelopeStateChunk", "Must be a valid EnvelopeStateChunk", -2) return end
  local retval, str
  if TrackEnvelope==nil then 
    str=EnvelopeStateChunk
  else
    retval, str = reaper.GetEnvelopeStateChunk(TrackEnvelope, "", false)
  end
  local A={ultraschall.GetEnvelopeState_NumbersOnly("VOLTYPE", str, "GetEnvelopeState_Voltype")}
  if A[1]==nil then return 0 else return table.unpack(A) end
end

function ultraschall.GetEnvelopeState_PooledEnvInstance(index, TrackEnvelope, EnvelopeStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetEnvelopeState_PooledEnvInstance</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer id, number position, number length, number start_offset, number playrate, integer selected, number baseline, integer loopsource, integer i, number j, integer pool_id, integer mute = ultraschall.GetEnvelopeState_PooledEnvInstance(integer index, TrackEnvelope TrackEnvelope, optional string EnvelopeStateChunk)</functioncall>
  <description>
    Returns the current state of a certain automation-item within a TrackEnvelope-object or EnvelopeStateChunk.
    
    It is the state entry POOLEDENVINST
    
    returns nil in case of error
  </description>
  <retvals>
    integer id - counter of automation-items; 1-based
    number position - position in seconds
    number length - length in seconds
    number start_offset - offset in seconds
    number playrate - playrate; minimum value is 0.001; default is 1.000
    integer selected - 1, automation item is selected; 0, automation item isn't selected
    number baseline - 0(-100) to 1(+100); default 0.5(0)
    number amplitude - -2(-200) to 2(+200); default 1 (100)
    integer loopsource - Loop Source; 0 and 1 are allowed settings; 1 is default
    integer i - unknown; 0 is default
    number j - unknown; 0 is default
    integer pool_id - counts the automation-item-instances in this project, including deleted ones; 1-based
    integer mute - 1, mute automation-item; 0, unmute automation-item
  </retvals>
  <parameters>
    integer index - the index-number of the automation-item, whose states you want to have
    TrackEnvelope TrackEnvelope - the TrackEnvelope, whose state you want to know; nil, to use parameter EnvelopeStateChunk instead
    optional string EnvelopeStateChunk - if TrackEnvelope is set to nil, you can pass an EnvelopeStateChunk into this parameter, to get that armed state
  </parameters>
  <chapter_context>
    Envelope Management
    Get Envelope States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>envelope states, get, pooled env instance, automation items, envelopestatechunk</tags>
</US_DocBloc>
]]  
  if TrackEnvelope~=nil and ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("GetEnvelopeState_PooledEnvInstance", "TrackEnvelope", "Must be a valid TrackEnvelope-object", -1) return end
  if TrackEnvelope==nil and ultraschall.IsValidEnvStateChunk(EnvelopeStateChunk)==false then ultraschall.AddErrorMessage("GetEnvelopeState_PooledEnvInstance", "EnvelopeStateChunk", "Must be a valid EnvelopeStateChunk", -2) return end
  if math.type(index)~="integer" then ultraschall.AddErrorMessage("GetEnvelopeState_PooledEnvInstance", "index", "Must be an integer", -3) return end
  local retval, str
  if TrackEnvelope==nil then 
    str=EnvelopeStateChunk
  else
    retval, str = reaper.GetEnvelopeStateChunk(TrackEnvelope, "", false)
  end
  
  local count, individual_values, found
  count=0
  found=false
  
  for k in string.gmatch(str, "(POOLEDENVINST.-)\n") do
    count=count+1
    if index==count then
      k=k.." "
      count, individual_values = ultraschall.CSV2IndividualLinesAsArray(k, " ")
      found=true
      break
    end
  end
  
  if found==false then 
    ultraschall.AddErrorMessage("GetEnvelopeState_PooledEnvInstance", "index", "no such automation-item available", -4)
    return 
  else 
    for i=1, count do
      individual_values[i]=tonumber(individual_values[i])
    end
    return table.unpack(individual_values)
  end
end

function ultraschall.GetEnvelopeState_PT(index, TrackEnvelope, EnvelopeStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetEnvelopeState_PT</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>number position, integer volume, integer point_shape_1, integer point_shape_2, integer selected, number bezier_tens1, number bezier_tens2 = ultraschall.GetEnvelopeState_PT(TrackEnvelope TrackEnvelope, optional string EnvelopeStateChunk)</functioncall>
  <description>
    Returns the current state of a certain envelope-point within a TrackEnvelope-object or EnvelopeStateChunk.
    
    It is the state entry PT
    
    returns nil in case of error
  </description>
  <retvals>
    number position - position of the point in seconds
    integer volume - volume as fader-value
    integer point_shape - may disappear with certain shapes, when point is unselected
                        - the values for point_shape_1 and point_shape_2 are:
                        - 0 0, linear
                        - 1 0, square
                        - 2 0, slow start/end
                        - 3 0, fast start
                        - 4 0, fast end
                        - 5 1, bezier
    integer selected - 1, selected; disappearing, unselected
    number unknown - disappears, if no bezier is set
    number bezier_tens2 - disappears, if no bezier is set; -1 to 1 
                        - 0, for no bezier tension
                        - -0.5, for fast-start-beziertension
                        - 0.5, for fast-end-beziertension
                        - 1, for square-tension
  </retvals>
  <parameters>
    integer index - the index-number of the envelope-point, whose states you want to have
    TrackEnvelope TrackEnvelope - the TrackEnvelope, whose state you want to know; nil, to use parameter EnvelopeStateChunk instead
    optional string EnvelopeStateChunk - if TrackEnvelope is set to nil, you can pass an EnvelopeStateChunk into this parameter, to get that armed state
  </parameters>
  <chapter_context>
    Envelope Management
    Get Envelope States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>envelope states, get, pt, envelope point, envelopestatechunk</tags>
</US_DocBloc>
]]  
  if TrackEnvelope~=nil and ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("GetEnvelopeState_PT", "TrackEnvelope", "Must be a valid TrackEnvelope-object", -1) return end
  if TrackEnvelope==nil and ultraschall.IsValidEnvStateChunk(EnvelopeStateChunk)==false then ultraschall.AddErrorMessage("GetEnvelopeState_PT", "EnvelopeStateChunk", "Must be a valid EnvelopeStateChunk", -2) return end
  if math.type(index)~="integer" then ultraschall.AddErrorMessage("GetEnvelopeState_PT", "index", "Must be an integer", -3) return end
  local retval, str
  if TrackEnvelope==nil then 
    str=EnvelopeStateChunk
  else
    retval, str = reaper.GetEnvelopeStateChunk(TrackEnvelope, "", false)
  end
  
  local count, individual_values, found
  count=0
  found=false
  
  for k in string.gmatch(str, "(PT .-)\n") do
    count=count+1
    if index==count then
      k=k.." "
      count, individual_values = ultraschall.CSV2IndividualLinesAsArray(k, " ")
      found=true
      break
    end
  end
  
  if found==false then 
    ultraschall.AddErrorMessage("GetEnvelopeState_PT", "index", "no such automation-item available", -4)
    return 
  else 
    for i=1, count do
      individual_values[i]=tonumber(individual_values[i])
    end
    return table.unpack(individual_values)
  end
end

function ultraschall.IsValidProjectBayStateChunk(ProjectBayStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsValidProjectBayStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.IsValidProjectBayStateChunk(string ProjectBayStateChunk)</functioncall>
  <description>
    checks, if ProjectBayStateChunk is a valid ProjectBayStateChunk
    
    returns false in case of an error
  </description>
  <parameters>
    string ProjectBayStateChunk - a string, that you want to check for being a valid ProjectBayStateChunk
  </parameters>
  <retvals>
    boolean retval - true, valid ProjectBayStateChunk; false, not a valid ProjectBayStateChunk
  </retvals>
  <chapter_context>
    Project-Management
    ProjectBay
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>project management, check, projectbaystatechunk, is valid</tags>
</US_DocBloc>
]]
  if type(ProjectBayStateChunk)~="string" then ultraschall.AddErrorMessage("IsValidProjectBayStateChunk", "ProjectBayStateChunk", "must be a string", -1) return false end
  if ProjectBayStateChunk:match("<PROJBAY.-\n  >")==nil then return false else return true end
end


function ultraschall.GetAllMediaItems_FromProjectBayStateChunk(ProjectBayStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllMediaItems_FromProjectBayStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer count, array MediaItemStateChunkArray = ultraschall.GetAllMediaItems_FromProjectBayStateChunk(string ProjectBayStateChunk)</functioncall>
  <description>
    returns all items from a ProjectBayStateChunk as MediaItemStateChunkArray
    
    returns -1 in case of an error
  </description>
  <parameters>
    string ProjectBayStateChunk - a string, that you want to check for being a valid ProjectBayStateChunk
  </parameters>
  <retvals>
    integer count - the number of items found in the ProjectBayStateChunk
    array MediaitemStateChunkArray - all items as ItemStateChunks in a handy array
  </retvals>
  <chapter_context>
    Project-Management
    ProjectBay
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>project management, get, projectbaystatechunk, all items, mediaitemstatechunkarray</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidProjectBayStateChunk(ProjectBayStateChunk)==false then ultraschall.AddErrorMessage("GetAllMediaItems_FromProjectBayStateChunk", "ProjectBayStateChunk", "must be a valid ProjectBayStateChunk", -1) return -1 end
  local MediaItemStateChunkArray={}
  local count=0
  for k in string.gmatch(ProjectBayStateChunk, "    <DATA.-\n    >") do
    count=count+1
    MediaItemStateChunkArray[count]=string.gsub(string.gsub(k, "    <DATA", "<ITEM"),"\n%s*", "\n").."\n"
  end
  return count, MediaItemStateChunkArray
end

function ultraschall.SetHelpDisplayMode(helpcontent, mouseediting)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetHelpDisplayMode</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetHelpDisplayMode(integer helpcontent, boolean mouseediting)</functioncall>
  <description>
    sets the help-display-mode, as shown in the area beneath the track control panels.
    
    returns false in case of an error
  </description>
  <parameters>
    integer helpcontent - 0, No information display  
                        - 1, Reaper tips  
                        - 2, Track/item count  
                        - 3, selected track/item/envelope details  
                        - 4, CPU/RAM use, time since last save  
    boolean mouseediting - true, show mouse editing-help; false, don't show mouse editing-help
  </parameters>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <chapter_context>
    User Interface
    misc
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>userinterface, set, show, help, helpcontent, mouseediting, tips</tags>
</US_DocBloc>
]]
  if math.type(helpcontent)~="integer" then ultraschall.AddErrorMessage("SetHelpDisplayMode", "mode", "must be an integer", -1) return false end
  if helpcontent<0 or helpcontent>4 then ultraschall.AddErrorMessage("SetHelpDisplayMode", "mode", "must be between 0 and 4", -2) return false end
  if mouseediting==false then helpcontent=helpcontent+65536 end
  if type(mouseediting)~="boolean" then ultraschall.AddErrorMessage("SetHelpDisplayMode", "mouseediting", "must be a boolean", -3) return false end
  return reaper.SNM_SetIntConfigVar("help", helpcontent)
end

function ultraschall.GetHelpDisplayMode()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetHelpDisplayMode</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>integer helpcontent, boolean mouseediting = ultraschall.GetHelpDisplayMode()</functioncall>
  <description>
    gets the current help-display-mode, as shown in the area beneath the track control panels.
  </description>
  <retvals>
    integer helpcontent - 0, No information display  
                        - 1, Reaper tips  
                        - 2, Track/item count  
                        - 3, selected track/item/envelope details  
                        - 4, CPU/RAM use, time since last save  
    boolean mouseediting - true, show mouse editing-help; false, don't show mouse editing-help
  </retvals>
  <chapter_context>
    User Interface
    misc
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>userinterface, get, show, help, helpcontent, mouseediting, tips</tags>
</US_DocBloc>
]]
  local A1,B1=reaper.SNM_GetIntConfigVar("help", -999)
  local mouse_editing=A1&65536~=0
  A1=A1-65536
  return A1, mouse_editing
end

function ultraschall.WiringDiagram_SetOptions(show_send_wires, show_routing_controls, show_hardware_outputs)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>WiringDiagram_SetOptions</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.WiringDiagram_SetOptions(boolean show_send_wires, boolean show_routing_controls, boolean show_hardware_outputs)</functioncall>
  <description>
    sets the current wiring-display-options
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was not successful
  </retvals>
  <parameters>
    boolean show_send_wires - only show send wires on track mouseover; true, it's set; false, it's unset
    boolean show_routing_controls - show routing controls when creating send/hardware output; true, it's set; false, it's unset
    boolean show_hardware_outputs - only show hardware output/input wires on track mouseover; true, it's set; false, it's unset
  </parameters>
  <chapter_context>
    User Interface
    misc
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>userinterface, set, wiring display, options</tags>
</US_DocBloc>
]]
  local mode=0
  if show_send_wires==true then mode=mode+1 end
  if show_routing_controls==true then mode=mode+8 end
  if show_hardware_outputs==true then mode=mode+16 end
  return reaper.SNM_SetIntConfigVar("wiring_options", mode)
end

function ultraschall.WiringDiagram_GetOptions()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>WiringDiagram_GetOptions</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>boolean show_send_wires, boolean show_routing_controls, boolean show_hardware_outputs = ultraschall.WiringDiagram_GetOptions()</functioncall>
  <description>
    gets the current wiring-display-options
  </description>
  <retvals>
    boolean show_send_wires - only show send wires on track mouseover; true, it's set; false, it's unset
    boolean show_routing_controls - show routing controls when creating send/hardware output; true, it's set; false, it's unset
    boolean show_hardware_outputs - only show hardware output/input wires on track mouseover; true, it's set; false, it's unset
  </retvals>
  <chapter_context>
    User Interface
    misc
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>userinterface, get, wiring display, options</tags>
</US_DocBloc>
]]
  local mode=reaper.SNM_GetIntConfigVar("wiring_options", -99)
  return mode&1==1, mode&8==8, mode&16==16
end

function ultraschall.ProjExtState_CountAllKeys(section)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ProjExtState_CountAllKeys</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer count = ultraschall.ProjExtState_CountAllKeys(string section)</functioncall>
  <description>
    Counts all keys stored within a certain ProjExtState-section.
    
    Be aware: if you want to enumerate them using reaper.EnumProjExtState, the first key is indexed 0, the second 1, etc!
    
    returns -1 in case of an error 
  </description>
  <parameters>
    string section - the section, of which you want to count all keys
  </parameters>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <chapter_context>
    Metadata Management
    Extension States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>metadate management, projextstate, project, extstate, count</tags>
</US_DocBloc>
]]
  if type(section)~="string" then ultraschall.AddErrorMessage("ProjExtState_CountAllKeys", "section", "must be a string", -1) return -1 end
  local dingo=1
  local stringer
  while dingo~=0 do
    stringer=reaper.genGuid("")..reaper.genGuid("")..reaper.genGuid("")..reaper.genGuid("")..reaper.genGuid("")..reaper.genGuid("")..reaper.genGuid("")..reaper.genGuid("")
    dingo=reaper.GetProjExtState(0, section, stringer)
  end
  
  return reaper.SetProjExtState(0, section, stringer, "")
end  


function ultraschall.ResizePNG(filename_with_path, outputfilename_with_path, aspectratio, width, height)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ResizePNG</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    JS=0.997
    Lua=5.3
  </requires>
  <functioncall>integer count = ultraschall.ResizePNG(string filename_with_path, string outputfilename_with_path, boolean aspectratio, integer width, integer height)</functioncall>
  <description>
    resizes a png-file. It will stretch/shrink the picture by that. That means you can't crop or enhance pngs with this function.
    
    If you set aspectratio=true, then the image will be resized with correct aspect-ratio. However, it will use the value from parameter width as maximum size for each side of the picture.
    So if the height of the png is bigger than the width, the height will get the size and width will be shrinked accordingly.
    
    When making pngs bigger, pixelation will occur. No pixel-filtering within this function!
    
    returns false in case of an error 
  </description>
  <parameters>
    string filename_with_path - the png-file, that you want to resize
    string outputfilename_with_path - the output-file, where to store the resized png
    boolean aspectratio - true, keep aspect-ratio(use size of param width as base); false, don't keep aspect-ratio
    integer width - the width of the newly created png in pixels
    integer height - the height of the newly created png in pixels
  </parameters>
  <retvals>
    boolean retval - true, resizing was successful; false, resizing was unsuccessful
  </retvals>
  <chapter_context>
    Image File Handling
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>image file handling, resize, png, image, graphics</tags>
</US_DocBloc>
]]
  if type(filename_with_path)~="string" then ultraschall.AddErrorMessage("ResizePNG", "filename_with_path", "must be a string", -1) return false end
  if type(outputfilename_with_path)~="string" then ultraschall.AddErrorMessage("ResizePNG", "outputfilename_with_path", "must be a string", -2) return false end
  if reaper.file_exists(filename_with_path)==false then ultraschall.AddErrorMessage("ResizePNG", "filename_with_path", "file can not be opened", -3) return false end
  if type(aspectratio)~="boolean" then ultraschall.AddErrorMessage("ResizePNG", "aspectratio", "must be a boolean", -4) return false end
  if math.type(width)~="integer" then ultraschall.AddErrorMessage("ResizePNG", "width", "must be an integer", -5) return false end
  if aspectratio==false and math.type(height)~="integer" then ultraschall.AddErrorMessage("ResizePNG", "height", "must be an integer, when aspectratio==false", -6) return false end
  
  local Identifier, Identifier2, squaresize, NewWidth, NewHeight, Height, Width, Retval
  Identifier=reaper.JS_LICE_LoadPNG(filename_with_path)
  Width=reaper.JS_LICE_GetWidth(Identifier)
  Height=reaper.JS_LICE_GetHeight(Identifier)
  if aspectratio==true then
    squaresize=width
    if Width>Height then 
      NewWidth=squaresize
      NewHeight=((100/Width)*Height)
      NewHeight=NewHeight/100
      NewHeight=math.floor(squaresize*NewHeight)
    else
      NewHeight=squaresize
      NewWidth=((100/Height)*Width)
      NewWidth=NewWidth/100
      NewWidth=math.floor(squaresize*NewWidth)
    end
  else
    NewHeight=height
    NewWidth=width
  end
  
  Identifier2=reaper.JS_LICE_CreateBitmap(true, NewWidth, NewHeight)
  reaper.JS_LICE_ScaledBlit(Identifier2, 0, 0, NewWidth, NewHeight, Identifier, 0, 0, Width, Height, 1, "COPY")
  Retval=reaper.JS_LICE_WritePNG(outputfilename_with_path, Identifier2, true)
  reaper.JS_LICE_DestroyBitmap(Identifier)
  reaper.JS_LICE_DestroyBitmap(Identifier2)
  if Retval==false then ultraschall.AddErrorMessage("ResizePNG", "outputfilename_with_path", "Can't write outputfile", -7) return false end
end

ultraschall.ShowLastErrorMessage()
