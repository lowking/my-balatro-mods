--- Divvy's Simulation for Balatro - Utils.lua
--
-- Utilities for writing simulation functions for jokers.
--
-- In general, these functions replicate the game's internal calculations and
-- variables in order to avoid affecting the game's state during simulation.
-- These functions ensure that the score calculation remains identical to the
-- game; DO NOT directly modify the `DV.SIM.running` score variables.

--
-- HIGH-LEVEL:
--

function DV.SIM.JOKERS.add_suit_mult(joker_obj, context)
   if context.cardarea == G.play and context.individual then
      if DV.SIM.is_suit(context.other_card, joker_obj.ability.extra.suit) and not context.other_card.debuff then
         DV.SIM.add_mult(joker_obj.ability.extra.s_mult)
      end
   end
end

function DV.SIM.JOKERS.add_type_mult(joker_obj, context)
   if context.cardarea == G.jokers and context.global
      and next(context.poker_hands[joker_obj.ability.type])
   then
      DV.SIM.add_mult(joker_obj.ability.t_mult)
   end
end

function DV.SIM.JOKERS.add_type_chips(joker_obj, context)
   if context.cardarea == G.jokers and context.global
      and next(context.poker_hands[joker_obj.ability.type])
   then
      DV.SIM.add_chips(joker_obj.ability.t_chips)
   end
end

function DV.SIM.JOKERS.x_mult_if_global(joker_obj, context)
   if context.cardarea == G.jokers and context.global then
      if joker_obj.ability.x_mult > 1 and
         (joker_obj.ability.type == "" or next(context.poker_hands[joker_obj.ability.type])) then
         DV.SIM.x_mult(joker_obj.ability.x_mult)
      end
   end
end

function DV.SIM.get_probabilistic_extremes(random_value, odds, reward, default)
   -- Exact mirrors the game's probability calculation
   local exact = default
   if random_value < G.GAME.probabilities.normal/odds then
      exact = reward
   end

   -- Minimum is default unless probability is guaranteed (eg. 2 in 2 chance)
   local min = default
   if G.GAME.probabilities.normal >= odds then
      min = reward
   end

   -- Maximum is always reward (probability is always > 0); redundant variable is for readability
   local max = reward

   return exact, min, max
end

function DV.SIM.adjust_field_with_range(adj_func, field, mod_func, exact_value, min_value, max_value)
   if not exact_value then error("Cannot adjust field, exact_value is missing.") end

   if not min_value or not max_value then
      min_value = exact_value
      max_value = exact_value
   end

   DV.SIM.running.min[field]   = mod_func(adj_func(DV.SIM.running.min[field],   min_value))
   DV.SIM.running.exact[field] = mod_func(adj_func(DV.SIM.running.exact[field], exact_value))
   DV.SIM.running.max[field]   = mod_func(adj_func(DV.SIM.running.max[field],   max_value))
end

function DV.SIM.add_chips(exact, min, max)
   DV.SIM.adjust_field_with_range(function(x, y) return x + y end, "chips", mod_chips, exact, min, max)
end

function DV.SIM.add_mult(exact, min, max)
   DV.SIM.adjust_field_with_range(function(x, y) return x + y end, "mult", mod_mult, exact, min, max)
end

function DV.SIM.x_mult(exact, min, max)
   DV.SIM.adjust_field_with_range(function(x, y) return x * y end, "mult", mod_mult, exact, min, max)
end

function DV.SIM.add_dollars(exact, min, max)
   -- NOTE: no mod_func for dollars, so have to declare an identity function
   DV.SIM.adjust_field_with_range(function(x, y) return x + y end, "dollars", function(x) return x end, exact, min, max)
end

function DV.SIM.add_reps(n)
   DV.SIM.running.reps = DV.SIM.running.reps + n
end

--
-- LOW-LEVEL:
--

function DV.SIM.is_suit(card_data, suit, ignore_scorability)
   if card_data.debuff and not ignore_scorability then return end
   if card_data.ability.effect == "Stone Card" then
      return false
   end
   if card_data.ability.effect == "Wild Card" and not card_data.debuff then
      return true
   end
   if next(find_joker("Smeared Joker")) then
      local is_card_suit_light  = (card_data.suit == "Hearts" or card_data.suit == "Diamonds")
      local is_check_suit_light = (suit == "Hearts"           or suit == "Diamonds")
      if is_card_suit_light == is_check_suit_light then return true end
   end
   return card_data.suit == suit
end

function DV.SIM.get_rank(card_data)
   if card_data.ability.effect == "Stone Card" and not card_data.vampired then
      DV.SIM.misc.next_stone_id = DV.SIM.misc.next_stone_id - 1
      return DV.SIM.misc.next_stone_id
   end
   return card_data.rank
end

function DV.SIM.is_rank(card_data, ranks)
   if card_data.ability.effect == "Stone Card" then return false end

   if type(ranks) == "number" then ranks = {ranks} end
   for _, r in ipairs(ranks) do
      if card_data.rank == r then return true end
   end
   return false
end

function DV.SIM.check_rank_parity(card_data, check_even)
   if check_even then
      local is_even_numbered = (card_data.rank <= 10 and card_data.rank >= 0 and card_data.rank % 2 == 0)
      return is_even_numbered
   else
      local is_odd_numbered  = (card_data.rank <= 10 and card_data.rank >= 0 and card_data.rank % 2 == 1)
      local is_ace = (card_data.rank == 14)
      return (is_odd_numbered or is_ace)
   end
end

function DV.SIM.is_face(card_data)
   return (DV.SIM.is_rank(card_data, {11, 12, 13}) or next(find_joker("Pareidolia")))
end

function DV.SIM.set_ability(card_data, center)
   -- See Card:set_ability()
   card_data.ability = {
      name = center.name,
      effect = center.effect,
      set = center.set,
      mult = center.config.mult or 0,
      h_mult = center.config.h_mult or 0,
      h_x_mult = center.config.h_x_mult or 0,
      h_dollars = center.config.h_dollars or 0,
      p_dollars = center.config.p_dollars or 0,
      t_mult = center.config.t_mult or 0,
      t_chips = center.config.t_chips or 0,
      x_mult = center.config.Xmult or 1,
      h_size = center.config.h_size or 0,
      d_size = center.config.d_size or 0,
      extra = copy_table(center.config.extra) or nil,
      extra_value = 0,
      type = center.config.type or '',
      order = center.order or nil,
      forced_selection = card_data.ability and card_data.ability.forced_selection or nil,
      perma_bonus = card_data.ability and card_data.ability.perma_bonus or 0,
      bonus = (card_data.ability and card_data.ability.bonus or 0) + (center.config.bonus or 0)
   }
end

function DV.SIM.set_edition(card_data, edition)
   card_data.edition = nil
   if not edition then return end

   if edition.holo then
      if not card_data.edition then card_data.edition = {} end
      card_data.edition.mult = G.P_CENTERS.e_holo.config.extra
      card_data.edition.holo = true
      card_data.edition.type = 'holo'
   elseif edition.foil then
      if not card_data.edition then card_data.edition = {} end
      card_data.edition.chips = G.P_CENTERS.e_foil.config.extra
      card_data.edition.foil = true
      card_data.edition.type = 'foil'
   elseif edition.polychrome then
      if not card_data.edition then card_data.edition = {} end
      card_data.edition.x_mult = G.P_CENTERS.e_polychrome.config.extra
      card_data.edition.polychrome = true
      card_data.edition.type = 'polychrome'
   elseif edition.negative then
      -- TODO
   end
end
