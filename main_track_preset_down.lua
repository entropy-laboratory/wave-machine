-- AUTOMATYCZNE PRZEŁĄCZANIE NA "POPRZEDNIĄ" ŚCIEŻKĘ WG KOLEJNOŚCI

-- Mapa logicznych nazw do rzeczywistych nazw ścieżek
local logical_order = {
    "1", "2", "3", "4",
    "A", "B", "C", "D"
}

local track_name_map = {
    ["1"] = "AMB DRV",
    ["2"] = "WHAKKA CHIKKI",
    ["3"] = "FUSION",
    ["4"] = "SYNTH LEAD",
    ["A"] = "AMBIENT",
    ["B"] = "CLEAN",
    ["C"] = "RHYTM",
    ["D"] = "LEAD"
}

-- Ustawienia presetów / FX
local allowed_fx_names = {
    ["MAIN"] = true,
    ["ADDITIONAL"] = true,
    ["VOID"] = true
}

local main_preset_name = "PRIMARY"
local synth_special_preset_name = "LEAD SYNTH"

local fx_to_disable_on_synth = {
    ["SYNTH"] = true,
    ["VOCO"] = true,
    ["VOID"] = true
}

-- === FUNKCJE ===

function FindFXByName(track, name_part)
    for i = 0, reaper.TrackFX_GetCount(track) - 1 do
        local _, fx_name = reaper.TrackFX_GetFXName(track, i, "")
        if fx_name:match(name_part) then
            return i
        end
    end
    return -1
end

function EnableOnlyAllowedFX(track, allowed_fx_table)
    for i = 0, reaper.TrackFX_GetCount(track) - 1 do
        local _, fx_name = reaper.TrackFX_GetFXName(track, i, "")
        local base_name = fx_name:match("([^%/]+)$") or fx_name
        reaper.TrackFX_SetEnabled(track, i, allowed_fx_table[base_name] or false)
    end
end

function DisableAllFX(track)
    reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 1)
    for i = 0, reaper.TrackFX_GetCount(track) - 1 do
        reaper.TrackFX_SetEnabled(track, i, false)
    end
end

-- Zwraca logiczną nazwę (np. "C") dla aktualnie zaznaczonej ścieżki
function GetActiveLogicalName()
    local selected_track = reaper.GetSelectedTrack(0, 0)
    if not selected_track then return nil end

    local _, name = reaper.GetSetMediaTrackInfo_String(selected_track, "P_NAME", "", false)
    for logical, actual in pairs(track_name_map) do
        if name == actual then
            return logical
        end
    end
    return nil
end

-- START
reaper.Undo_BeginBlock()

local current_name = GetActiveLogicalName()
if not current_name then return end

-- Znajdź indeks w logicznym porządku
local target_index = nil
for i, v in ipairs(logical_order) do
    if v == current_name and i > 1 then
        target_index = i - 1
        break
    end
end

-- Jeśli nie można znaleźć poprzednika, wyjdź
if not target_index then return end

local TARGET_NAME = logical_order[target_index]
local TARGET_REAL_NAME = track_name_map[TARGET_NAME]

local track_count = reaper.CountTracks(0)

for i = 0, track_count - 1 do
    local track = reaper.GetTrack(0, i)
    local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)

    local is_target = (name == track_name_map[TARGET_NAME])
    local is_synth = (name == "SYNTH")

    if is_target then
        -- Aktywuj wybrany tor
        reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 0)
        EnableOnlyAllowedFX(track, allowed_fx_names)

        local fx_index = FindFXByName(track, "MAIN")
        if fx_index ~= -1 then
            reaper.TrackFX_SetPreset(track, fx_index, main_preset_name)
        end

    elseif is_synth then
        if TARGET_NAME == "C" then
            -- Dla C włączamy SYNTH z presetem LEAD SYNTH
            reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 0)
            local synth_fx_index = FindFXByName(track, "SYNTH")
            if synth_fx_index ~= -1 then
                reaper.TrackFX_SetEnabled(track, synth_fx_index, true)
                reaper.TrackFX_SetPreset(track, synth_fx_index, synth_special_preset_name)
            end
        else
            -- Dla innych mute SYNTH + wyłącz wskazane FX
            reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 1)
            for j = 0, reaper.TrackFX_GetCount(track) - 1 do
                local _, fx_name = reaper.TrackFX_GetFXName(track, j, "")
                local base_name = fx_name:match("([^%/]+)$") or fx_name
                if fx_to_disable_on_synth[base_name] then
                    reaper.TrackFX_SetEnabled(track, j, false)
                end
            end
        end
    else
        -- Pozostałe ścieżki: mute + off FX
        DisableAllFX(track)
    end
end

reaper.Undo_EndBlock("Activate previous track logic", -1)
