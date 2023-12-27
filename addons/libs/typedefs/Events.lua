---@meta

---@class AshitaCommand
---@field args fun(self: AshitaCommand): string[]
---@field blocked boolean

---@class CommandEventArgs
---@field command AshitaCommand
---@field blocked boolean

---@class TextInEventArgs
---@field mode             integer
---@field mode_modified    integer
---@field message          string
---@field message_modified string
---@field indent           boolean
---@field indent_modified  boolean
---@field injected         boolean
---@field blocked          boolean

---@class PacketInEventArgs
---@field id                integer
---@field size              integer
---@field data              string
---@field data_raw          userdata
---@field data_modified     string
---@field data_modified_raw userdata
---@field injected          boolean
---@field blocked           boolean
