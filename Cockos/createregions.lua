-- Set the starting and ending notes
local startNote = 40 -- MIDI note for E2
local endNote = 88   -- MIDI note for E6

-- Set the pattern for the region names
local pattern = "#%d_NOTE_%s%d_%s"

-- Function to create regions
function createRegions()
    for note = startNote, endNote do
        local noteName = reaper.MIDI_GetNoteName(0, note, true)
        local dynamics = {"mf", "f", "ff"}

        for _, dynamic in ipairs(dynamics) do
            local regionName = string.format(pattern, note, noteName, dynamic)
            reaper.AddProjectMarker2(0, true, note, note + 1, regionName, -1, 0)
        end
    end
end

-- Run the function
reaper.Undo_BeginBlock()
createRegions()
reaper.Undo_EndBlock("Create Regions", -1)
