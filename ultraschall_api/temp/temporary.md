The Ultraschall-Extension is intended to be an extension for the DAW Reaper, that enhances it with podcast functionalities. Most DAWs are intended to be used by musicians, for music, but podcasters have their own needs to be fulfilled. In fact, in some places their needs differ from the needs of a musician heavily. Ultraschall is intended to optimise the Reaper's workflows, by reworking them with functionalities for the special needs of podcasters.

The Ultraschall-Framework itself is intended to include a set of Lua-functions, that help creating such functionalities. By giving programmers helper functions to get access to each and every corner of Reaper. That way, extending Ultraschall and Reaper is more comfortable to do.

This API was to be used within Ultraschall only, but quickly evolved into a huge 700 function-library, that many 3rd-party programmers and scripters may find use in, with many useful features, like:

   - [Rendering](#Rendering_001_Introduction) - you can render your projects without having to use the render-dialog. You can customize the rendering-workflow in every way you want.
                   Just create a renderstring and pass it over to [RenderProject_RenderCFG](US_Api_Functions.html#RenderProject_RenderCFG) or [RenderProjectRegions_RenderCFG](US_Api_Functions.html#RenderProjectRegions_RenderCFG)
   - [Navigation, Follow and Arrangeview-Manipulation](#Navigation_001_Introduction) - get/set cursors, zoom, autoscroll-management, scroll, etc
   - [ArrangeView-Snapshots](#Arrangeview_Snapshots_001_Introduction) - you can save, retrieve snapshots of the arrangeview, including position, zoomstates to quickly jump through parts of your project
   - [Trackstates](#Trackstate_Management_001_Introduction) - you can access and set all(!) track-states available
   - [Mediaitem-states](#GetSetStates_Project_Track_Item_Env_001_Introduction) - you can access and set many mediaitem-states (more will follow)
   - [ItemExtStates/TrackExtStates](#ExtStateManagement_005_TrackItemExtStates) - you can save additional metadata easily for specific tracks and items using ItemExtStates and TrackExtStates
   - [File access](#1FileManagement_001_Introduction) - many helperfunctions for reading, writing, copying files. No more hassle writing it yourself!
       e.g [ReadFullFile](US_Api_Functions.html#ReadFullFile), [WriteValueToFile](US_Api_Functions.html#WriteValueToFile), etc
   - [Cough-Mute-management](#Cough_Mute_Buttons_001_Introduction) - you can write your own cough-buttons, that set the state of the mute-envelope of a track easily
   - [Marker](#MarkersAndRegions_001_Introduction) - extensive set of marker functions, get, set, export, import, enumerate, etc
   - [Spectrogram](#Getting_Manipulating_Items_008_Spectral_Edit) - you can program the spectrogram-view
   - [Routing](#Routing_001_Introduction) - you can set Sends/Receives and HWOuts more straightforward than with Reaper's own Routing-functions. Includes mastertrack as well.
   - [Get MediaItems](#Getting_Manipulating_Items_002_GetMediaItems) - you can get all media-items within a time-range AND within the tracks you prefer; a 2D-approach
       e.g. [GetAllMediaItemsBetween](US_Api_Functions.html#GetAllMediaItemsBetween) and [GetMediaItemsAtPosition ](US_Api_Functions.html#GetMediaItemsAtPosition ), etc
   - Gaps between items - you can get the gaps between items in a track, using [GetGapsBetweenItems](US_Api_Functions.html#GetGapsBetweenItems)
   - [Edit item(s)](#Getting_Manipulating_Items_001_Introduction) - Split, Cut, Copy, Paste, Move, RippleCut, RippleInsert, SectionCut by tracks AND time/start to endposition
       e.g. [RippleCut](US_Api_Functions.html#RippleCut), [RippleInsert](RippleInsert), [SectionCut](US_Api_Functions.html#SectionCut), [SplitMediaItems_Position](US_Api_Functions.html#SplitMediaItems_Position), [MoveMediaItemsBefore_By](US_Api_Functions.html#MoveMediaItemsBefore_By), [MoveMediaItemsSectionTo](US_Api_Functions.html#MoveMediaItemsSectionTo) and many more
   - [Previewing MediaItems and files](#Getting_Manipulating_Items_009_Miscellaneous) - you can preview MediaItems and files without having to start playback of a project
   - KB-Ini-Management - manipulate the reaper-kb.ini-file with custom-settings
   - [Checking for Datatypes](#Datatypes_050_CheckingDatatypes) - check all datatypes introduced with Ultraschall-API and all Lua/Reaper-datatypes
   - [UndoManagement](#Helper_Functions_004_UndoManagement) - functions for easily making undoing of functions as well as preventing creating an undo-point
   - [Run an Action](#Helper_Functions_005_Miscellaneous) for Items/Tracks - apply actions to specific items/tracks
   - [Checking for changed projecttabs](#Project_Management_002_Check_Changed_Projecttabs) - check, if projecttabs have been added/removed
   - [ExtState-Management](#ExtStateManagement_001_Introduction) - an extensive set of functions for working with extstates as well as ini-files
   - [Data Manipulation](#Helper_Functions_003_Data_Manipulation) - manipulate a lot of your data, including bitwise-integers, tables, etc
   - [Clipboard-Management](#Helper_Functions_002_ClipboardManagement) - get items from clipboard, put them to clipboard, even multiple ones
   - [Error Messaging System](#Error_Messaging_System_001_Introduction) - all functions create useful error-messages that can be shown using, eg: [ShowLastErrorMessage](US_Api_Functions.html#ShowLastErrorMessage), for easier debugging
   - tons of other helper-functions
   - my Reaper-Internals Documentation AND

   - it's documented with this documentation. :D

   Happy coding and let's see, what you can do with it :D
    
   Meo Mespotine (mespotine.de) (api.ultraschall.fm)

For more information about Ultraschall itself, see [ultraschall.fm](http://www.ultraschall.fm) and if you want to support us, see [ultraschall.fm/danke](http://www.ultraschall.fm/danke) for donating to us.

PS: In this documentation, I assume you have some basic knowledge in Lua and in using Reaper's own API-functions. Explaining both of these is beyond the scope of this doc.
