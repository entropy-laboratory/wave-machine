-- ReaScript: Toggle "Active Cab" envelopes on tracks starting with A or D
-- Author: Raven Trophy

local ALLOWED_PREFIXES = { A = true, B = true, C = true, D = true, 1 = true, 2 = true, 3 = true, 4 = true }

local track_count = reaper.CountTracks(0)
local time = reaper.GetCursorPosition()

reaper.Undo_BeginBlock()

for i = 0, track_count - 1 do
    local track = reaper.GetTrack(0, i)
    local _, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    local prefix = track_name:sub(1,1)

    if ALLOWED_PREFIXES[prefix] then
        local env_count = reaper.CountTrackEnvelopes(track)

        for j = 0, env_count - 1 do
            local envelope = reaper.GetTrackEnvelope(track, j)
            local _, env_name = reaper.GetEnvelopeName(envelope, "")

            if env_name:lower():find("active cab") then
                -- Pobierz najbliższy punkt envelope w czasie kursora
                local retval, value, _, _, _ = reaper.Envelope_Evaluate(envelope, time, 1, 0)

                -- Zaokrąglenie do 0 lub 1
                local current = (value >= 0.5) and 1.0 or 0.0
                local new_value = (current == 1.0) and 0.0 or 1.0

                -- Wstawienie punktu
                reaper.InsertEnvelopePoint(envelope, time, new_value, 0, 0, false, true)
                reaper.Envelope_SortPoints(envelope)
            end
        end
    end
end

reaper.Undo_EndBlock("Toggle 'Active Cab' envelopes on A and D tracks", -1)
