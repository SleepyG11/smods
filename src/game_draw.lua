SMODS.GameDrawSteps = {}
SMODS.GameDrawStep = SMODS.GameObject:extend({
	obj_table = SMODS.GameDrawSteps,
	obj_buffer = {},
	required_params = {
		"key",
		"order",
		"func",
	},
    force = true,
	ignore_debug_ui_toggle = false,
	hide_on_overlay_menu = false,
    debug_splash_size_toggle = false,
	-- func = function(card, layer) end,
	set = "Game Draw Step",
	register = function(self)
		if self.registered then
			sendWarnMessage(("Detected duplicate register call on object %s"):format(self.key), self.set)
			return
		end
		SMODS.GameDrawStep.super.register(self)
	end,
	inject = function() end,
	post_inject_class = function(self)
		table.sort(self.obj_buffer, function(_self, _other)
			return self.obj_table[_self].order < self.obj_table[_other].order
		end)
	end,

	check_conditions = function(self)
        if self.force then return true end
		if G.debug_UI_toggle and not self.ignore_debug_ui_toggle then return end
        if self.debug_splash_size_toggle ~= nil and ((G.debug_splash_size_toggle or false) ~= self.debug_splash_size_toggle) then return end
		if self.hide_on_overlay_menu and G.OVERLAY_MENU and G.F_HIDE_BG then return end
		return true
	end,

	draw_ui_element = function(self, v, with_children)
		love.graphics.push()
		v:translate_container()
		v:draw()
		if with_children and v.draw_children then
			v:draw_self()
			v:draw_children()
		end
		love.graphics.pop()
	end,
})

-- Variables reset

SMODS.GameDrawStep({
	key = "start",
	order = -2000,
    force = true,

	func = function(self)
		G.FRAMES.DRAW = G.FRAMES.DRAW + 1
		reset_drawhash()
		if G.OVERLAY_TUTORIAL and not G.OVERLAY_MENU then G.under_overlay = true end
	end,
})

-- Canvases and stencil reset
-- Global love.graphics.push()
-- Timer checkpoint: start->canvas

SMODS.GameDrawStep({
	key = "reset",
	order = -1000,
    force = true,

	func = function(self)
        timer_checkpoint("start->canvas", "draw")

		love.graphics.setCanvas({ G.CANVAS, depthstencil = SMODS.stencil_canvas })
		love.graphics.push()
		love.graphics.scale(G.CANV_SCALE)

		love.graphics.setShader()
		love.graphics.clear(0, 0, 0, 1)
        SMODS.reset_stencil_stack()
	end,
})

-- Background

SMODS.GameDrawStep({
	key = "splash_back",
	order = -900,
    force = true,

	func = function(self)
		if G.SPLASH_BACK then
			if G.debug_background_toggle then
				love.graphics.clear({ 0, 1, 0, 1 })
			else
				self:draw_ui_element(G.SPLASH_BACK)
			end
		end
	end,
})

-- Elements under overlay menu

SMODS.GameDrawStep({
	key = "nodes",
	order = -700,

	func = function(self)
		for k, v in pairs(G.I.NODE) do
			if not v.parent then self:draw_ui_element(v) end
		end
	end,
})

SMODS.GameDrawStep({
	key = "moveables",
	order = -650,

	func = function(self)
		for k, v in pairs(G.I.MOVEABLE) do
			if not v.parent then self:draw_ui_element(v) end
		end
	end,
})

SMODS.GameDrawStep({
	key = "splash_logo",
	order = -500,

	func = function(self)
		if G.SPLASH_LOGO then self:draw_ui_element(G.SPLASH_LOGO) end
	end,
})

-- Timer checkpoint: primatives

SMODS.GameDrawStep({
	key = "checkpoint_primatives",
	order = -400,
    hide_on_overlay_menu = true,

	func = function(self)
        timer_checkpoint('primatives', 'draw')
	end,
})

SMODS.GameDrawStep({
	key = "uiboxes",
	order = -350,
	hide_on_overlay_menu = true,
    force = true,

	exceptions = {
		"OVERLAY_MENU",
		"screenwipe",
		"OVERLAY_TUTORIAL",
		"debug_tools",
		"online_leaderboard",
		"achievement_notification",
	},

	func = function(self)
		for k, v in pairs(G.I.UIBOX) do
			if not v.attention_text and not v.parent then
				for _, exception in ipairs(self.exceptions) do
					if v == G[exception] then goto skip end
				end
				self:draw_ui_element(v)
                ::skip::
			end
		end
	end,
})

-- Timer checkpoint: uiboxes

SMODS.GameDrawStep({
	key = "checkpoint_uiboxes",
	order = -300,
    hide_on_overlay_menu = true,

	func = function(self)
        timer_checkpoint('uiboxes', 'draw')
	end,
})

SMODS.GameDrawStep({
	key = "cardareas",
	order = -250,
	hide_on_overlay_menu = true,
    debug_splash_size_toggle = nil,

	func = function(self)
		for k, v in pairs(G.I.CARDAREA) do
			if not v.parent then self:draw_ui_element(v) end
		end
	end,
})

SMODS.GameDrawStep({
	key = "cards",
	order = -225,
	hide_on_overlay_menu = true,

	func = function(self)
		for k, v in pairs(G.I.CARD) do
			if not v.parent and v ~= G.CONTROLLER.dragging.target and v ~= G.CONTROLLER.focused.target then
				self:draw_ui_element(v)
			end
		end
	end,
})

SMODS.GameDrawStep({
	key = "attention_uiboxes",
	order = -200,
	hide_on_overlay_menu = true,

	exceptions = {
		"debug_tools",
		"online_leaderboard",
		"achievement_notification",
	},

	func = function(self)
		for k, v in pairs(G.I.UIBOX) do
			if v.attention_text then
				for _, exception in ipairs(self.exceptions) do
					if v == G[exception] then goto skip break end
				end
				self:draw_ui_element(v)
                ::skip::
			end
		end
	end,
})

SMODS.GameDrawStep({
	key = "splash_front",
	order = -100,
	hide_on_overlay_menu = true,

	func = function(self)
		if G.SPLASH_FRONT then self:draw_ui_element(G.SPLASH_FRONT) end
	end,
})

SMODS.GameDrawStep({
	key = "overlay_tutorial",
	order = -50,
	hide_on_overlay_menu = true,

	func = function(self)
		G.under_overlay = false
		if G.OVERLAY_TUTORIAL then
			self:draw_ui_element(G.OVERLAY_TUTORIAL)
			if G.OVERLAY_TUTORIAL.highlights then
				for k, v in ipairs(G.OVERLAY_TUTORIAL.highlights) do
					self:draw_ui_element(v, true)
				end
			end
		end
	end,
})

SMODS.GameDrawStep({
	key = "dropdown",
	order = -30,
	hide_on_overlay_menu = true,

	func = function(self)
		for k, v in pairs(G.I.DROPDOWN) do
			if v.parent == G.ROOM_ATTACH then self:draw_ui_element(v) end
		end
	end,
})

-- Overlay menu

SMODS.GameDrawStep({
	key = "overlay_menu",
	order = 0,

	func = function(self)
		if G.OVERLAY_MENU and G.OVERLAY_MENU ~= G.CONTROLLER.dragging.target then
			self:draw_ui_element(G.OVERLAY_MENU)
		end
	end,
})

-- Elements over overlay menu

SMODS.GameDrawStep({
	key = "debug_tools",
	order = 100,

	func = function(self)
		if G.debug_tools and G.debug_tools ~= G.CONTROLLER.dragging.target then
			self:draw_ui_element(G.debug_tools)
		end
	end,
})

SMODS.GameDrawStep({
	key = "alerts",
	order = 200,

	func = function(self)
		G.ALERT_ON_SCREEN = nil
		for k, v in pairs(G.I.ALERT) do
			self:draw_ui_element(v)
			G.ALERT_ON_SCREEN = true
		end
	end,
})

SMODS.GameDrawStep({
	key = "overlay_dropdown",
	order = 250,

	func = function(self)
		for k, v in pairs(G.I.DROPDOWN) do
			if v.parent == G.OVERLAY_MENU then self:draw_ui_element(v) end
		end
	end,
})

SMODS.GameDrawStep({
	key = "dragging_target",
	order = 500,

	func = function(self)
		if G.CONTROLLER.dragging.target and G.CONTROLLER.dragging.target ~= G.CONTROLLER.focused.target then
			self:draw_ui_element(G.CONTROLLER.dragging.target)
		end
	end,
})

SMODS.GameDrawStep({
	key = "focused_card",
	order = 550,

	func = function(self)
		local focus = G.CONTROLLER.focused.target
		if focus and getmetatable(focus) == Card and (focus.area ~= G.hand or focus == G.CONTROLLER.dragging.target) then
			self:draw_ui_element(focus)
		end
	end,
})

SMODS.GameDrawStep({
	key = "sprite_particles",
	order = 600,

	func = function(self)
		for i, particle_sprite in ipairs(SMODS.SPRITE_PARTICLES or {}) do
			if particle_sprite.sprite_particle_key then
				local sprite_particle_obj = SMODS.SpriteParticles[particle_sprite.sprite_particle_key]
				if sprite_particle_obj and type(sprite_particle_obj.draw) == "function" then
					sprite_particle_obj:draw(particle_sprite, self)
				else
					particle_sprite:draw()
				end
			else
				particle_sprite:draw()
			end
		end
	end,
})

SMODS.GameDrawStep({
	key = "popups",
	order = 700,

	func = function(self)
		for k, v in pairs(G.I.POPUP) do self:draw_ui_element(v) end
	end,
})

SMODS.GameDrawStep({
	key = "splash_front",
	order = 800,

	func = function(self)
		if G.achievement_notification then self:draw_ui_element(G.achievement_notification) end
	end,
})

SMODS.GameDrawStep({
	key = "screenwipe",
	order = 850,

	func = function(self)
		if G.screenwipe then self:draw_ui_element(G.screenwipe) end
	end,
})

SMODS.GameDrawStep({
	key = "cursor",
	order = 900,

	func = function(self)
		love.graphics.push()
		G.CURSOR:translate_container()
		love.graphics.translate(
			-G.CURSOR.T.w * G.TILESCALE * G.TILESIZE * 0.5,
			-G.CURSOR.T.h * G.TILESCALE * G.TILESIZE * 0.5
		)
		G.CURSOR:draw()
		love.graphics.pop()
	end,
})

-- Global love.graphics.pop()
-- Timer checkpoint: rest

SMODS.GameDrawStep({
	key = "aa",
	order = 1000,
    force = true,

	func = function(self)
        timer_checkpoint('rest', 'draw')

        love.graphics.pop()
		love.graphics.setCanvas(G.AA_CANVAS)
		love.graphics.push()
		love.graphics.setColor(G.C.WHITE)

		if not G.recording_mode or G.video_control then
			G.ARGS.eased_cursor_pos = G.ARGS.eased_cursor_pos or {
                x = G.CURSOR.T.x,
                y = G.CURSOR.T.y,
                sx = G.CONTROLLER.cursor_position.x,
                sy = G.CONTROLLER.cursor_position.y,
            }
			G.screenwipe_amt = G.screenwipe_amt and (0.95 * G.screenwipe_amt + 0.05 * ((G.screenwipe and 0.4 or G.screenglitch and 0.4) or 0)) or 1
		end
		love.graphics.draw(G.CANVAS, 0, 0)

		love.graphics.pop()
		love.graphics.setCanvas()
		love.graphics.setShader()
	end,
})

SMODS.GameDrawStep({
	key = "screenshaders",
	order = 1100,
    force = true,

	func = function(self)
		local last_canvas = G.CANVAS
		G.SHADER_CANVAS_A = G.SHADER_CANVAS_A or SMODS.create_canvas()
		G.SHADER_CANVAS_B = G.SHADER_CANVAS_B or SMODS.create_canvas()
		for index, key in ipairs(SMODS.ScreenShader.obj_buffer) do
			local shader = SMODS.ScreenShaders[key]
			if (shader.should_apply and shader:should_apply()) or not shader.should_apply then
				--hypothetically less table accesses
				local shader_object = G.SHADERS[shader.shader]
				assert(shader_object, "Shader " .. shader.key .. " not found in G.SHADERS")

				-- effectively swaps between A and B
				local current_canvas = (last_canvas == G.SHADER_CANVAS_A) and G.SHADER_CANVAS_B or G.SHADER_CANVAS_A

				if shader.send_vars then
					local vars = shader:send_vars()
					for k, v in pairs(vars) do
						shader_object:send(k, unpack((type(v) == "table" and v.array) and v.array or { v }))
					end
				end

				love.graphics.setCanvas(current_canvas)
				shader:draw(shader_object, last_canvas)

				last_canvas = current_canvas
			end
		end
		-- I don't like having this out here but id rather not run it when i don't have to
		-- also less setcanvas and setshader means it should run a smidge faster
		love.graphics.setCanvas()
		love.graphics.setShader()
		if last_canvas then
			love.graphics.clear({ 0, 0, 0, 1 })
			love.graphics.draw(last_canvas, 0, 0)
			-- Draw everything we just did to the main canvas (what the player actually sees)
		end
	end,
})

SMODS.GameDrawStep({
	key = "end",
	order = 2000,
    force = true,

	func = function(self)
		if G.AA_CANVAS then
			love.graphics.push()
			love.graphics.scale(1 / G.CANV_SCALE)
			love.graphics.draw(G.AA_CANVAS, 0, 0)
			love.graphics.pop()
		end
	end,
})

SMODS.GameDrawStep({
	key = "debug",
	order = 3000,
    force = true,

	func = function(self)
        if not _RELEASE_MODE and G.DEBUG and not G.video_control and G.F_VERBOSE then 
            love.graphics.push()
            love.graphics.setColor(0, 1, 1,1)
            local fps = love.timer.getFPS( )
            love.graphics.print("Current FPS: "..fps, 10, 10)

            if G.check and G.SETTINGS.perf_mode then
                local section_h = 30
                local resolution = 60*section_h
                local poll_w = 1
                local v_off = 100
                for a, b in ipairs({G.check.update, G.check.draw}) do
                    for k, v in ipairs(b.checkpoint_list) do
                        love.graphics.setColor(0,0,0,0.2)
                        love.graphics.rectangle('fill', 12, 20 + v_off,poll_w+poll_w*#v.trend,-section_h + 5)
                        for kk, vv in ipairs(v.trend) do
                            if a == 2 then 
                                love.graphics.setColor(0.3,0.7,0.7,1)
                            else
                                love.graphics.setColor(self:state_col(v.states[kk] or 123))
                            end
                            love.graphics.rectangle('fill', 10+poll_w*kk,  20 + v_off, 5*poll_w, -(vv)*resolution)
                        end
                        love.graphics.setColor(a == 2 and 0.5 or 1, a == 2 and 1 or 0.5, 1,1)
                        love.graphics.print(v.label..': '..(string.format("%.2f",1000*(v.average or 0)))..'\n', 10, -section_h + 30 + v_off)
                        v_off = v_off + section_h
                    end
                end
            end

            love.graphics.pop()
        end
        timer_checkpoint('debug', 'draw')
	end,
})

function Game:draw()
    for _, step_key in ipairs(SMODS.GameDrawStep.obj_buffer) do
        local step = SMODS.GameDrawSteps[step_key]
        if step:check_conditions() then step:func() end
    end
end