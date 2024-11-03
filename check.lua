-- ฟังก์ชันเพื่อตรวจสอบประเภทของเบราว์เซอร์จาก User-Agent
local userAgent = os.getenv("HTTP_USER_AGENT")
local browser = ""

if userAgent:find("MSIE") then
    browser = "MSIE"
elseif userAgent:find("Trident") then
    browser = "Trident"
elseif userAgent:find("Firefox") then
    browser = "Firefox"
elseif userAgent:find("Chrome") then
    browser = "Chrome"
elseif userAgent:find("Opera Mini") then
    browser = "Opera Mini"
elseif userAgent:find("Opera") then
    browser = "Opera"
elseif userAgent:find("Safari") then
    browser = "Safari"
elseif userAgent:find("Mozilla") then
    browser = "Mozilla"
end

print("\n" .. browser)

-- ฟังก์ชันบันทึกข้อมูลผู้ใช้งานลงในไฟล์ logs.txt
local protocol = os.getenv("SERVER_PROTOCOL")
local ip = os.getenv("REMOTE_ADDR")
local port = os.getenv("REMOTE_PORT")
local hostname = io.popen("nslookup " .. ip):read("*a"):match("name = ([%w%.%-]+)")

local logData = string.format("IP: %s\nProtocol: %s\nPort: %s\nUser-Agent: %s\nHostname: %s\n\n", 
    ip, protocol, port, userAgent, hostname or "N/A")

local file = io.open("logs.txt", "a")
file:write(logData)
file:close()

-- ฟังก์ชันตรวจสอบคีย์ใน Whitelist
local keys = { "Key-12", "key-34" }
local sub = os.getenv("QUERY_STRING"):match("key=([^&]*)") or ""

local whitelisted = false
for _, key in ipairs(keys) do
    if key == sub then
        whitelisted = true
        break
    end
end

print(whitelisted and "Whitelisted" or "Not Whitelisted")
