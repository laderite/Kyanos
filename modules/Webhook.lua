local WebhookService = {
    ErrorPrinting = true,
    ThumbnailSizes = {
        ["48x48"] = true,
        ["50x50"] = true,
        ["60x60"] = true,
        ["75x75"] = true,
        ["100x100"] = true,
        ["150x150"] = true,
        ["180x180"] = true,
        ["353x352"] = true,
        ["420x420"] = true,
        ["720x720"] = true
    }
}

-- Services
local HttpService = game:GetService("HttpService")

-- Constants
local PROXY_DOMAINS = {
    "hooks.hyra.io",
    "webhook.newstargeted.com",
    "webhook.lewisakura.moe"
}

local ERROR_MESSAGES = {
    [403] = {
        ["IP Has Been Banned"] = "This Roblox Server IP Has Been Temporarily Banned Due To Abuse.",
        ["Webhook Has Been Blocked"] = "%s" -- Filled with reason
    },
    [429] = "Hit ratelimit.",
    [404] = "Provided Webhook Is Not Valid.",
    [400] = "Error Occurred: %s" -- Filled with body message
}

-- HTTP Request Handler
local function getHttpRequest()
    return (syn and syn.request) or 
           (http and http.request) or 
           http_request or 
           (fluxus and fluxus.request) or 
           request
end

-- Core HTTP Functions
local function makeHttpRequest(url, data)
    local HttpRequest = getHttpRequest()
    
    local response = HttpRequest({
        Url = url,
        Method = "POST",
        Body = data,
        Headers = {["Content-Type"] = "application/json"}
    })
    
    if response.StatusCode == 204 then
        return true, 204, nil
    end
    
    return response.Success, response.StatusCode, response.Body
end

local function handleErrorStatus(statusCode, body)
    if not WebhookService.ErrorPrinting then return end
    
    local errorMessage = ERROR_MESSAGES[statusCode]
    if errorMessage then
        if type(errorMessage) == "table" then
            errorMessage = errorMessage[body.message]
            if errorMessage then
                warn(string.format("[WebhookService]: %s", string.format(errorMessage, body.reason)))
            end
        else
            warn(string.format("[WebhookService]: %s", string.format(errorMessage, body.message)))
        end
    end
end

-- URL Validation
local function isValidUrl(url)
    return typeof(url) == "string" and url:match("^https?://[%w-_%.%?%.:/%+=&]+$") ~= nil
end

-- Webhook Processing
local function processWebhook(url, data)
    -- Try original URL first
    local success, statusCode, body = makeHttpRequest(url, data)
    if success then return true end
    
    -- Try proxy domains if original fails
    for _, domain in ipairs(PROXY_DOMAINS) do
        local proxyUrl = url:gsub("discord.com", domain)
        success, statusCode, body = makeHttpRequest(proxyUrl, data)
        if success then return true end
        
        handleErrorStatus(statusCode, body)
    end
    
    return false
end

-- Queue System
local WebhookQueue = {
    queue = {},
    isProcessing = false,
    maxSize = 1000
}

function WebhookQueue:process()
    if #self.queue == 0 then
        self.isProcessing = false
        return
    end
    
    local data = table.remove(self.queue, 1)
    processWebhook(data.url, HttpService:JSONEncode(data.payload))
    
    task.wait(2) -- Rate limiting protection
    self:process()
end

function WebhookQueue:add(data)
    if #self.queue >= self.maxSize then
        if WebhookService.ErrorPrinting then
            warn("[WebhookService]: Queue limit reached. Skipping webhook request.")
        end
        return
    end
    
    table.insert(self.queue, data)
    
    if not self.isProcessing then
        self.isProcessing = true
        self:process()
    end
end

-- Public API
function WebhookService:Send(config)
    assert(typeof(config) == "table", "Expected table for webhook configuration")
    assert(config.url or config.urls, "No webhook URL provided")
    assert(config.content or config.embeds, "No content or embeds provided")
    
    local urls = config.urls or {config.url}
    local payload = {
        content = config.content,
        embeds = config.embeds and table.clone(config.embeds) or {}
    }
    
    for _, url in ipairs(urls) do
        if isValidUrl(url) then
            WebhookQueue:add({url = url, payload = payload})
        else
            warn("[WebhookService]: Invalid URL format: " .. tostring(url))
        end
    end
end

-- Formatting Utilities
WebhookService.Format = {
    Bold = function(text) return "**" .. text .. "**" end,
    Italic = function(text) return "*" .. text .. "*" end,
    Underline = function(text) return "__" .. text .. "__" end,
    Strike = function(text) return "~~" .. text .. "~~" end,
    Code = function(text, lang) return "```" .. (lang or "") .. "\n" .. text .. "\n```" end,
    InlineCode = function(text) return "`" .. text .. "`" end,
    Quote = function(text) return "> " .. text end,
    Spoiler = function(text) return "||" .. text .. "||" end
}

-- Mention Utilities
WebhookService.Mention = {
    User = function(id) return "<@" .. id .. ">" end,
    Role = function(id) return "<@&" .. id .. ">" end,
    Channel = function(id) return "<#" .. id .. ">" end
}

-- Color Converter
function WebhookService:ColorFromRGB(r, g, b)
    return (r * 65536) + (g * 256) + b
end

return WebhookService
