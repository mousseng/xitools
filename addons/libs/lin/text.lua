local text = {}

---@param number number
---@return boolean
local function IsNan(number)
  return type(number) == 'number'
    and number ~= number
end

---@param width integer
---@param percent number
---@param f string Character to represent a full section
---@param h string Character to represent a partial section
---@param n string Character to represent an empty section
---@return string
function text.PercentBar(width, percent, f, h, n)
    if f == nil then f = '=' end
    if h == nil then h = '-' end
    if n == nil then n = ' ' end
    if IsNan(percent) then percent = 0 end
    if percent > 1 then percent = 1 end

    local bar_width = width - 2

    local full_step = math.min(1, 1 / bar_width)
    local half_step = math.min(1, 1 / (bar_width * 2))

    local full_bars = math.floor(percent / full_step)
    local half_bars = math.floor((percent % full_step) / half_step)

    local fb = f:rep(full_bars)
    local hb = h:rep(half_bars)
    local nb = n:rep(bar_width - (full_bars + half_bars))

    return string.format('[%s%s%s]', fb, hb, nb)
end

---@param number integer
---@param include_unit boolean
---@return string
function text.FormatXp(number, include_unit)
    if number < 10000 then
        return string.format('%4i', number)
    elseif include_unit then
        return string.format('%4.1fk', number / 1000)
    else
        return string.format('%4.1f', number / 1000)
    end
end

---@param text string
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@return string
function text.Colorize(text, r, g, b, a)
    if a == nil then a = 255 end

    if r < 0 then r = 0 elseif r > 255 then r = 255 end
    if g < 0 then g = 0 elseif g > 255 then g = 255 end
    if b < 0 then b = 0 elseif b > 255 then b = 255 end
    if a < 0 then a = 0 elseif a > 255 then a = 255 end

    return string.format('|c%02x%02x%02x%02x|%s|r', a, r, g, b, text)
end

---@param hp_percent number
---@return integer, integer, integer
function text.GetHpColor(hp_percent)
        if hp_percent > 0.75 then return 255, 255, 255
    elseif hp_percent > 0.50 then return 255, 255,   0
    elseif hp_percent > 0.25 then return 255, 165,   0
    elseif hp_percent > 0.00 then return 243,  50,  50
    else                          return 255, 255, 255 end
end

---@param tp_percent number
---@return integer, integer, integer
function text.GetTpColor(tp_percent)
    if tp_percent > 0.33 then return   0, 255, 255
    else                      return 255, 255, 255 end
end

return text
