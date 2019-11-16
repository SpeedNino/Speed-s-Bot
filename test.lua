local discordia = require('discordia')
local client = discordia.Client()
local Prefix = 's:'
local cmds = {}

function addCmd(Table)
    table.insert(cmds, #cmds + 1, Table)
end

local clock = os.clock
function sleep(n)
  local t0 = clock()
  while clock() - t0 <= n do end
end
function check(message, data, e, user)
    sleep(0.01)
    local date = split(os.date())
    local date2 = split(date[4], ':')
    date2 = date2[1] ..':'.. date2[2]
    if tostring(data) == tostring(date2) then
        message:reply('Alarm! <@'.. user ..'>, '.. data ..', '.. e)
        return
    else
        check(message, data, e, user)
    end
end

function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function sendEmbed(message, title, msg, desc)
    message.channel:send {
        embed = {
            title = title,
            fields = {
                {name = msg, value = desc, inline = true},
            },
            color = discordia.Color.fromRGB(114, 137, 218).value
        }
    }
end

addCmd({
    Command = 'help',
    Desc = 'Gives you all commands avaliable.',
    MoreArgs = false,
    exe = 
    function(message, msg, author)
        for _,v in pairs(cmds) do
            sendEmbed(message, 'Commands',Prefix ..'**'.. v.Command ..'**', v.Desc)
        end
    end,
    howUse = Prefix ..'help'
})
addCmd({
    Command = 'clear',
    Desc = 'Clear messages that are not 2 weeks older.',
    MoreArgs = true,
    exe = 
    function(message, msg, author, args)
        if type(tonumber(args[2])) ~= 'number' then
            return
        end
        message:reply('Please Wait a couple seconds before all '.. args[2] ..' messages have been deleted.')
        local messages = message.channel:getMessagesAround(message.id, args[2])
        local array = messages:toArray()
        for i,v in pairs(array) do
            if v then
                v:delete()
            end
        end
        message:reply('All '.. args[2] ..' messages have been deleted.')
    end,
    howUse = Prefix ..'clear [value]'
})
addCmd({
    Command = 'spam',
    Desc = 'spams something in the chat.',
    MoreArgs = true,
    exe = 
    function(message, msg, author, args)
        local a = 0
        repeat 
            message:reply(tostring(args[2]))
            a = a + 1
        until a >= tonumber(args[3])
    end,
    howUse = Prefix ..'spam [your shit] [value]'
})
addCmd({
    Command = 'leave',
    Desc = 'the bot leaves the server.',
    MoreArgs = false,
    exe = 
    function(message, msg, author)
        message.channel:leave()
        message:reply('Test: Leaving...')
    end,
    howUse = Prefix ..'leave'
})
addCmd({
    Command = 'tell-tha-truth',
    Desc = 'I WILL TELL THE TRUTH.',
    MoreArgs = false,
    exe = 
    function(message, msg, author)
        message:reply('no <@550883907940253716>')
    end,
    howUse = Prefix ..'tell-tha-truth'
})
addCmd({
    Command = 'nitro',
    Desc = 'Will generate a nitro link but without a checker.',
    MoreArgs = false,
    exe = 
    function(message, msg, author)
        local link = ''
        local d = 'ABCDEFGHIJKLMNOPQSTUVWXYZ1234567890'
        for i = 0, 24 do
            local a = math.random(1, 2)
            local b = math.random(1, 36)
            if a == 1 then
                link = link .. string.sub(d:lower(), b, b)
            else
                link = link .. string.sub(d:upper(), b, b)
            end
        end
        message:reply('nitro lenk: discord.gift/'.. link)
    end,
    howUse = Prefix ..'nitro'
})
addCmd({
    Command = 'reminder',
    Desc = 'Reminder of wat u ned to do',
    MoreArgs = true,
    exe = 
    function(message, msg, author, args)
        local reminder = io.open('./reminder.txt', 'r+')
        local r = tostring('{Reason = '.. args[2] ..', Time = '.. args[3] ..'}|')
        reminder:write(r)
        reminder:close()
        check(message, args[3], args[2], message.member.id)
        message:reply('Reminder Marked!')
    end,
    howUse = Prefix ..'reminder [go-to-my-house] [20:10]'
})
addCmd({
    Command = 'detector',
    Desc = 'Detetec wharever u want.',
    MoreArgs = true,
    exe = 
    function(message, msg, author, args)
        if type(tostring(args[2])) ~= 'string' and type(tostring(args[3])) ~= 'string' then
            return
        end
        local detec = math.random(0, 100)
        message:reply('The detection for '.. args[3] ..' of being '.. args[2] ..' is of '.. detec .. '%.')
    end,
    howUse = Prefix ..'detector [What do you want to detetec] [User]'
})


client:on('messageCreate', function(message)
    local msg = message.content
    local author = message.author
    local authorID = message.member.id
    if authorID == io.open('./ClientID.txt'):read() and authorID ~= 256172719538700289 then
        return
    end
    for i, v in pairs(cmds) do
        if v.MoreArgs then
            if string.match(msg:lower(), Prefix .. v.Command ..' ') then
                local args = split(msg)
                v.exe(message, msg, author, args)
            end
        elseif msg:lower() == Prefix .. v.Command then
            v.exe(message, msg, author)
        end
    end
end)

client:run('Bot '.. io.open('./token.txt'):read())