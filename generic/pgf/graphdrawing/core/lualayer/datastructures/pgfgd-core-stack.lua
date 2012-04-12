-- Copyright 2011 by Jannis Pohlmann
--
-- This file may be distributed an/or modified
--
-- 1. under the LaTeX Project Public License and/or
-- 2. under the GNU Public License
--
-- See the file doc/generic/pgf/licenses/LICENSE for more information

-- @release $Header: /home/mojca/cron/mojca/github/cvs/pgf/pgf/generic/pgf/graphdrawing/core/lualayer/datastructures/pgfgd-core-stack.lua,v 1.1 2012/04/12 15:16:07 tantau Exp $

--- TODO Jannis: Add documentation.

pgf.module("pgf.graphdrawing")



Stack = {}
Stack.__index = Stack



function Stack:new()
  local stack = {
    elements = {},
  }
  setmetatable(stack, Stack)
  return stack
end



function Stack:push(data)
  table.insert(self.elements, data)
end



function Stack:peek()
  return self.elements[#self.elements]
end



function Stack:pop()
  return table.remove(self.elements, #self.elements)
end



function Stack:getSize()
  return #self.elements
end
