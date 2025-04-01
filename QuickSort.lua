--- STEAMODDED HEADER
--- MOD_NAME: Quick Sort
--- MOD_ID: lowking
--- MOD_AUTHOR: [lowking]
--- MOD_DESCRIPTION: quick sort
----------------------------------------------
------------MOD CODE -------------------------
local keyupdate_ref = Controller.key_press_update
function Controller.key_press_update(self, key, dt)
    keyupdate_ref(self, key, dt)
    if key == 'w' then
        G.FUNCS.sort_hand_value()
    elseif key == 'e' then
        G.FUNCS.sort_hand_suit()
    end
end

----------------------------------------------
------------MOD CODE END----------------------
