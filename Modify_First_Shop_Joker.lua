--- STEAMODDED HEADER
--- MOD_NAME: Choose First Shop Joker
--- MOD_ID: choose_first_shop_Joker
--- MOD_AUTHOR: [infarctus]
--- MOD_DESCRIPTION: Testing shop
----------------------------------------------
------------MOD CODE -------------------------
local forced_joker_shop = nil
Orginal_get_current_pool = get_current_pool
function get_current_pool(_type, _rarity, _legendary, _append)
    sendDebugMessage(inspectDepth(G.GAME.current_round))
    if forced_joker_shop and G.shop and (_type == 'Joker' or _type== 'Tarot' or _type== 'Planet') and not(G.GAME.was_forced_joker_shop)  then
        local _pool, _pool_key = EMPTY(G.ARGS.TEMP_POOL), ''
        G.GAME.was_forced_joker_shop = true
        _pool_key = 'Joker'..(_rarity or pseudorandom('rarity'..G.GAME.round_resets.ante..(_append or '')) )..(_append or '')..G.GAME.round_resets.ante
        _pool[#_pool + 1] = forced_joker_shop
        return _pool, _pool_key
    end
    if G.shop and not(G.GAME.was_forced_joker_shop) then
        G.GAME.was_forced_joker_shop = true
    end
    return Orginal_get_current_pool(_type, _rarity, _legendary, _append)
end

local Original_Controller_key_press_update = Controller.key_press_update
function Controller:key_press_update(key, dt)
    Original_Controller_key_press_update(self, key, dt)
    if key == 'g' then
        if self.hovering.target and self.hovering.target:is(Card) and G.SETTINGS.paused and not(G.GAME.was_forced_joker_shop) then
            local joker_name_with_j = self.hovering.target.config.center.key
            if string.find( joker_name_with_j,"j_" ) then
                local edition = {negative = true}
                self.hovering.target:set_edition(edition, true, true)
                forced_joker_shop = joker_name_with_j
            end
        else
            G.GAME.was_forced_joker_shop = false
            G.SETTINGS.paused = true
            G.FUNCS:your_collection_jokers()
        end
    end
end
----------------------------------------------
------------MOD CODE END----------------------
