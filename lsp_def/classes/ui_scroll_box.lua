---@meta

---@class SMODS.UIScrollBox.Input
---@field content Moveable | { definition: UINode, config: table, T?: table } Moveable or UIBox definition which will be rendered inside scrollable content (passed to G.UIT.O).
---@field container? { node_config?: UINode.config, config?: table, T?: table } UIBox args for scroll container which will be moved to create scroll effect.
---@field overflow? { node_config?: UINode.config, config?: table, T?: table } UIBox args for main element.
---@field progress? { x: number, y: number } Value of scroll content relative offset in directions (0-1). Keeps reference for original table.
---@field offset? { x: number, y: number } Value of scroll content absolute offset in directions (in game units). Keeps reference for original table.
---@field sync_mode? "offset" | "progress" | "none" Sync mode. `offset` sync progress to match offset, `progress` sync offset to match progress, `none` disables syncing. Default is `progress`.
---@field scroll_move? fun(self: SMODS.UIScrollBox, dt: number) Function which calld every frame before scroll syncing and can be used to perform automatic scrolling.

---@class SMODS.UIScrollBox: UIBox
---@field content Moveable Displayed content.
---@field content_container UIBox Container which positions `content` according to scroll offset.
---@field scroll_args SMODS.UIScrollBox.Input Input args
---@field scroll_progress { x: number, y: number } Value of scroll content relative offset in directions (0-1). Keeps reference for original table.
---@field scroll_offset { x: number, y: number } Value of scroll content absolute offset in directions (in game units). Keeps reference for original table.
---@field scroll_sync_mode "offset" | "progress" | "none" Sync mode. `offset` sync progress to match offset, `progress` sync offset to match progress, `none` disables syncing. Default is `progress`.
---@overload fun(args: SMODS.UIScrollBox.Input): SMODS.UIScrollBox
SMODS.UIScrollBox = {}
SMODS.UIScrollBox.__index = SMODS.UIScrollBox
SMODS.UIScrollBox.super = UIBox

---@return number, number
--- Distance of content overflow in both directions
function SMODS.UIScrollBox:get_scroll_distance() end

--- Update offset to match progress. Called every frame if `scroll_sync_mode = "progress"`
function SMODS.UIScrollBox:sync_scroll_offset() end

--- Update progress to match offset. Called every frame if `scroll_sync_mode = "offset"`
function SMODS.UIScrollBox:sync_scroll_progress() end

---@param t { x: number, y: number }
--- Set new table for offset (keeps reference), and sync progress to match new offset
function SMODS.UIScrollBox:set_scroll_offset(t) end

---@param t { x: number, y: number }
--- Set new table for progress (keeps reference), and sync offset to match new progress
function SMODS.UIScrollBox:set_scroll_progress(t) end

---@param dt number
---@param init? boolean Is sync called during initialization
--- Perform syncing according to `scroll_sync_mode`, and position elements to match result offset
function SMODS.UIScrollBox:sync_scroll(dt, init) end
