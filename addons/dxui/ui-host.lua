local uiHost = {
    views = {
        require('views/party')
    }
}

function uiHost:init()
    for _, view in ipairs(self.views) do
        view:init()
    end

    return self
end

function uiHost:update()
    for _, view in ipairs(self.views) do
        view:update()
    end

    return self
end

function uiHost:draw(dxui)
    for _, view in ipairs(self.views) do
        view:draw(dxui)
    end
end

return uiHost
