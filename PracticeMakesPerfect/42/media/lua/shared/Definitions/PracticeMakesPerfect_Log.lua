PMP = PMP or {}

PMP.LogLevel = {
    ERROR = 1,
    WARN  = 2,
    INFO  = 3,
    DEBUG = 4,
    TRACE = 5,
}

-- Default level is INFO. Override via sandbox option LogLevel (1..5) or by writing
-- PMP.currentLogLevel = PMP.LogLevel.DEBUG in the in-game Lua console at runtime.
PMP.currentLogLevel = PMP.LogLevel.INFO

local LEVEL_NAMES = { "ERROR", "WARN", "INFO", "DEBUG", "TRACE" }

local function readLevelFromSandbox()
    local sv = SandboxVars and SandboxVars.PracticeMakesPerfect
    if sv and sv.LogLevel then
        local n = tonumber(sv.LogLevel)
        if n and n >= 1 and n <= 5 then
            PMP.currentLogLevel = n
        end
    end
end

function PMP.log(level, fmt, ...)
    if level > (PMP.currentLogLevel or PMP.LogLevel.INFO) then return end
    local msg = fmt
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, fmt, ...)
        if ok then msg = formatted end
    end
    print("[PMP][" .. LEVEL_NAMES[level] .. "] " .. tostring(msg))
end

function PMP.logError(fmt, ...) PMP.log(PMP.LogLevel.ERROR, fmt, ...) end
function PMP.logWarn(fmt, ...)  PMP.log(PMP.LogLevel.WARN,  fmt, ...) end
function PMP.logInfo(fmt, ...)  PMP.log(PMP.LogLevel.INFO,  fmt, ...) end
function PMP.logDebug(fmt, ...) PMP.log(PMP.LogLevel.DEBUG, fmt, ...) end
function PMP.logTrace(fmt, ...) PMP.log(PMP.LogLevel.TRACE, fmt, ...) end

-- Pull sandbox-configured level when world/save is ready.
if Events and Events.OnGameStart then
    Events.OnGameStart.Add(function()
        readLevelFromSandbox()
        PMP.logInfo("Log level = %s (%d). Set in-game via SandboxVars.PracticeMakesPerfect.LogLevel or by running PMP.currentLogLevel = N in the Lua console.",
            LEVEL_NAMES[PMP.currentLogLevel], PMP.currentLogLevel)
    end)
end

PMP.MOD_VERSION = "0.1.0"
PMP.logInfo("PracticeMakesPerfect v%s — Log module loaded", PMP.MOD_VERSION)
