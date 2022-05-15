VERSION = "0.0.0"

local micro = import("micro")
local config = import("micro/config")
local buffer = import("micro/buffer")
local autocomplete = import("micro/autocomplete")
local io = require "io"
local os = require "os"

function runShell(args, input)
	if (#args) == 0 then
		return
	end
	local tmpname = os.tmpname()
	local command = "< "
	command = command .. tmpname
	for i = 1,(#args) do
		command = command .. " " .. args[i]
	end
	local wfp = io.open(tmpname, "w+")
	wfp:write(input)
	wfp:close()
	micro.InfoBar():Message(command)
	result = io.popen(command):read('*a')
	os.remove(tmpname)
	return result
end
	
function writeAction(bp, args)
	local result = runShell(args, "")
	bp.Buf:Insert(-bp.Cursor.Loc, result)
end

function readAction(bp, args)
	if bp.Cursor:HasSelection() then
		bts = bp.Cursor:GetSelection()
		local selection = ""
		for i = 1,(#bts) do
			selection = selection  .. "" .. string.char(bts[i])
		end
		local result = runShell(args, selection)
		local newbuf = buffer.NewBuffer(result, "")
		bp:VSplitBuf(newbuf)
	end
end

function pipeAction(bp, args)
	if bp.Cursor:HasSelection() then
		bts = bp.Cursor:GetSelection()
		local selection = ""
		for i = 1,(#bts) do
			selection = selection  .. "" .. string.char(bts[i])
		end
		local result = runShell(args, selection)
		bp.Cursor:DeleteSelection()
		bp.Buf:Insert(-bp.Cursor.Loc, result)
	end
end

function init() 
	config.MakeCommand("write", writeAction, config.NoComplete)
	config.MakeCommand("read", readAction, config.NoComplete)
	config.MakeCommand("pipe", pipeAction, config.NoComplete)
end
