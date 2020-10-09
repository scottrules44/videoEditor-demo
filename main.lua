local videoEditor = require "plugin.videoEditor"
local json = require "json"
local widget = require( "widget" )
--
local showTrimVideo
local showCropVideo
--
local function doesFileExist( fname, path )
 
    local results = false
 
    -- Path for the file
    local filePath = system.pathForFile( fname, path )
 
    if ( filePath ) then
        local file, errorString = io.open( filePath, "r" )
 
        if not file then
            -- Error occurred; output the cause
            print( "File error: " .. errorString )
        else
            -- File exists!
            print( "File found: " .. fname )
            results = true
            -- Close the file handle
            file:close()
        end
    end
 
    return results
end
function copyFile( srcName, srcPath, dstName, dstPath, overwrite )
 
    local results = false
 
    local fileExists = doesFileExist( srcName, srcPath )
    if ( fileExists == false ) then
        return nil  -- nil = Source file not found
    end
 
    -- Check to see if destination file already exists
    if not ( overwrite ) then
        if ( fileLib.doesFileExist( dstName, dstPath ) ) then
            return 1  -- 1 = File already exists (don't overwrite)
        end
    end
 
    -- Copy the source file to the destination file
    local rFilePath = system.pathForFile( srcName, srcPath )
    local wFilePath = system.pathForFile( dstName, dstPath )
 
    local rfh = io.open( rFilePath, "rb" )
    local wfh, errorString = io.open( wFilePath, "wb" )
 
    if not ( wfh ) then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
        return false
    else
        -- Read the file and write to the destination directory
        local data = rfh:read( "*a" )
        if not ( data ) then
            print( "Read error!" )
            return false
        else
            if not ( wfh:write( data ) ) then
                print( "Write error!" )
                return false
            end
        end
    end
 
    results = 2  -- 2 = File copied successfully!
 
    -- Close file handles
    rfh:close()
    wfh:close()
 
    return results
end
copyFile( "myVideo.m4v.txt", nil, "myVideo.m4v", system.DocumentsDirectory, true )
--
local bg = display.newRect(display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight )
bg:setFillColor( .5 )
local title = display.newText( "Video Editor Plugin", display.contentCenterX, 30, native.systemFontBold, 20 )

local myVideoUrl = system.pathForFile( "myVideo.m4v", system.DocumentsDirectory )
local outputHalfVideo = system.pathForFile( "trimVideo.mp4", system.DocumentsDirectory )
local snapshotOfFirstSecond = system.pathForFile( "firstSecond.png", system.DocumentsDirectory )
local videoInfo = videoEditor.getVideoInfo(myVideoUrl)
local cropUrl = system.pathForFile( "cropVideo.mp4", system.DocumentsDirectory )
--
print( "Video Info" )
print( "--------------------------" )
print(json.encode(videoInfo))
print( "--------------------------" )
os.remove( outputHalfVideo )
os.remove( cropUrl )

showCropVideo = widget.newButton( {
    label = "Show Croped Video",
    id = "showHalfVideo",
    onRelease = function ( )
        media.playVideo( "cropVideo.mp4", system.DocumentsDirectory, true )
    end
} )
showCropVideo.x, showCropVideo.y = display.contentCenterX, display.contentCenterY -100
showCropVideo.alpha = 0

if (videoInfo) then
    videoEditor.trim(myVideoUrl, 1, videoInfo.duration/2, outputHalfVideo, function ( e )
        print(json.encode(e))
        if (e.isError == false) then
            showTrimVideo.alpha = 1
        end
    end)
    videoEditor.createThumbnail(myVideoUrl, snapshotOfFirstSecond, 1, videoInfo.width, videoInfo.height, 100)
    videoEditor.cropVideo(myVideoUrl, cropUrl, 200, 200, function(e)
        if (e.isError == false) then
            showCropVideo.alpha = 1
        end
    end)
end

--
showTrimVideo = widget.newButton( {
	label = "Show Half Video",
	id = "showHalfVideo",
	onRelease = function ( )
		media.playVideo( "trimVideo.mp4", system.DocumentsDirectory, true )
	end
} )
showTrimVideo.x, showTrimVideo.y = display.contentCenterX, display.contentCenterY -50
showTrimVideo.alpha = 0



timer.performWithDelay( 1000, function (  )
    if (videoInfo) then
        local thumbnail = display.newImageRect( "firstSecond.png", system.DocumentsDirectory, videoInfo.width, videoInfo.height )
        thumbnail:scale( .3, .3 )
        thumbnail.x, thumbnail.y = display.contentCenterX, display.contentCenterY +100
            
    end
	
end )

