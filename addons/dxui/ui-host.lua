local uiHost = {
    views = {
        party = require('views/party')
    }
}

function uiHost:init()
    for _, view in pairs(self.views) do
        view:init()
    end

    return self
end

function uiHost:pos(view, x, y)
    if not self.views[view] then
        return
    end

    self.views[view]:pos(x, y)
    return self
end

function uiHost:update()
    for _, view in pairs(self.views) do
        view:update()
    end

    return self
end

function uiHost:draw(dxui)
    for _, view in pairs(self.views) do
        view:draw(dxui)
    end

    return self
end

return uiHost
