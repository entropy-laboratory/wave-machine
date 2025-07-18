-- ReaScript: Activate track "TARGET_NAME" and mute+FX off others
-- Author: Raven Trophy
-- Description: Mutes and disables FX on all target tracks except selected one

local TARGET_NAME = "3"  -- <- <- <- ZMIEŃ NA: "1", "2", ..., "D" dla konkretnego tracka

-- Lista dozwolonych prefiksów (rozpoznaje po początku nazwy ścieżki)
local valid_prefixes = {
    ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true,
    ["A"] = true, ["B"] = true, ["C"] = true, ["D"] = true
}

local track_count = reaper.CountTracks(0)

reaper.Undo_BeginBlock()

for i = 0, track_count - 1 do
    local track = reaper.GetTrack(0, i)
    local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)

    local prefix = name:match("^(%w)")  -- wyciąga pierwszy znak (np. "A", "1" itd.)

    if prefix and valid_prefixes[prefix] then
        local is_target = (prefix == TARGET_NAME)

        -- Mute / Unmute
        reaper.SetMediaTrackInfo_Value(track, "B_MUTE", is_target and 0 or 1)

        -- Włącz/wyłącz FX-y
        local fx_count = reaper.TrackFX_GetCount(track)
        for fx = 0, fx_count - 1 do
            reaper.TrackFX_SetEnabled(track, fx, is_target)
        end
    end
end

reaper.Undo_EndBlock("Activate track prefix '" .. TARGET_NAME .. "', mute others", -1)

