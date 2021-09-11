--
-- created with TexturePacker - https://www.codeandweb.com/texturepacker
--
-- $TexturePacker:SmartUpdate:9e873e95db03ded63ff9a11629c5be11:066aa323d73fab12fbe65ae3a5cf5943:f1d8563e84a3821b0a7d7b4c225bcc70$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- 000
            x=0,
            y=0,
            width=108,
            height=200,

        },
        {
            -- 001
            x=108,
            y=0,
            width=108,
            height=200,

        },
        {
            -- 002
            x=216,
            y=0,
            width=108,
            height=200,

        },
        {
            -- 003
            x=324,
            y=0,
            width=108,
            height=200,

        },
        {
            -- 004
            x=432,
            y=0,
            width=108,
            height=200,

        },
        {
            -- 005
            x=540,
            y=0,
            width=108,
            height=200,

        },
        {
            -- 006
            x=648,
            y=0,
            width=108,
            height=200,

        },
        {
            -- 007
            x=756,
            y=0,
            width=108,
            height=200,

        },
        {
            -- 008
            x=864,
            y=0,
            width=108,
            height=200,

        },
    },

    sheetContentWidth = 972,
    sheetContentHeight = 200
}

SheetInfo.frameIndex =
{

    ["000"] = 1,
    ["001"] = 2,
    ["002"] = 3,
    ["003"] = 4,
    ["004"] = 5,
    ["005"] = 6,
    ["006"] = 7,
    ["007"] = 8,
    ["008"] = 9,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
