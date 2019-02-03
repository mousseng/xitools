function percent_bar(width, percent, f, h, n)
    if f == nil then f = '=' end
    if h == nil then h = '-' end
    if n == nil then n = ' ' end

    local bar_width = width - 2

    local full_step = 1 / bar_width
    local half_step = 1 / (bar_width * 2)

    local full_bars = math.floor(percent / full_step)
    local half_bars = math.floor((percent % full_step) / half_step)

    local fb = f:rep(full_bars)
    local hb = h:rep(half_bars)
    local nb = n:rep(bar_width - (full_bars + half_bars))

    return string.format('[%s%s%s]', fb, hb, nb)
end

function format_xp(number, include_unit)
    if number < 10000 then
        return string.format('%4i', number)
    elseif include_unit then
        return string.format('%4.1fk', number / 1000)
    else
        return string.format('%4.1f', number / 1000)
    end
end

function colorize_text(text, r, g, b, a)
    if a == nil then a = 255 end

    if r < 0 then r = 0 elseif r > 255 then r = 255 end
    if g < 0 then g = 0 elseif g > 255 then g = 255 end
    if b < 0 then b = 0 elseif b > 255 then b = 255 end
    if a < 0 then a = 0 elseif a > 255 then a = 255 end

    return string.format('|c%02x%02x%02x%02x|%s|r', a, r, g, b, text)
end

function get_hp_color(hp_percent)
        if hp_percent > 0.75 then return 255, 255, 255
    elseif hp_percent > 0.50 then return 255, 255,   0
    elseif hp_percent > 0.25 then return 255, 165,   0
    elseif hp_percent > 0.00 then return 243,  50,  50
    else                          return 255, 255, 255 end
end

function get_tp_color(tp_percent)
    if tp_percent > 0.33 then return   0, 255, 255
    else return 255, 255, 255 end
end
