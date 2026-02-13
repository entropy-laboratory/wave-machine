local ENGINE_CMD = "_RS3c479dc54dc4258750b0c9cc4a38d474ec939234"

reaper.SetExtState("LOOPER", "ACTION", "PANIC", false)
reaper.Main_OnCommand(reaper.NamedCommandLookup(ENGINE_CMD), 0)