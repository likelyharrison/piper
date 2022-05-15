local micro = import("micro")
local config = import("micro/config")
local autocomplete = import("micro/autocomplete")
local io = require "io"

function pipeAction(buf, args)
	if micro.InfoBar() == nil then
		return
	end
	if (#args) == 0 then
		return
	end
	command = ""
	for i = 1,(#args) do
		command = command .. " " .. args[i]
	end
	result = io.popen(command):read('*a')
	micro.InfoBar():Message(result)
end

function preinit()
	config.MakeCommand("pipe", pipeAction, config.NoComplete)
end
