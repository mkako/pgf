-- Copyright 2010 by Renée Ahrens, Olof Frahm, Jens Kluttig, Matthias Schulz, Stephan Schuster
-- Copyright 2011 by Jannis Pohlmann
--
-- This file may be distributed an/or modified
--
-- 1. under the LaTeX Project Public License and/or
-- 2. under the GNU Public License
--
-- See the file doc/generic/pgf/licenses/LICENSE for more information

-- @release $Header: /home/mojca/cron/mojca/github/cvs/pgf/pgf/generic/pgf/graphdrawing/core/lualayer/control/pgfgd-core-tex-interface.lua,v 1.1 2012/04/12 15:16:07 tantau Exp $

-- This file defines the Interface global object, which is used as a
-- simplified frontend in the TeX part of the library.

pgf.module("pgf.graphdrawing")



--- Sits between the TikZ/TeX side and Lua.
Interface = {
  graphStack = {},
  defaultGraphParameters = {},
  texboxes = {}
}
Interface.__index = Interface



--- Creates a new graph and adds it to the graph stack.
--
-- The options string consisting of |{key}{value}| pairs is parsed and 
-- assigned to the graph. These options are used to configure the different
-- graph drawing algorithms shipped with \tikzname.
--
-- @see finishGraph
--
-- @param options A string containing |{key}{value}| pairs of 
--                \tikzname\ options.
--
function Interface:newGraph(options)
  self.graph = Graph:new()
  table.insert(self.graphStack, self.graph)
  self.graph:mergeOptions(string.parse_braces(options))
end



--- Sets the graph option \meta{name} to \meta{value}. Only affects the current graph.
--
-- @param name  The name of the option to set.
-- @param value New value for the option.
--
function Interface:setOption(name, value)
  self.graph:setOption(name, value)
end



--- Returns the value of the graph option \meta{name}.
--
-- @param name Name of the option.
--
-- @return The value of the \meta{name} option or |nil|.
--
function Interface:getOption(name)
  return self.graph:getOption(name)
end



--- Adds a new node to the graph.
--
-- This function is called for each node of the graph by the \TeX\
-- layer. The \meta{name} is the name of the node including the
-- internal prefix added by the \TeX\ layer to indicate that the node
-- ``does not yet exist.'' The parameters \meta{xMin} to \meta{yMax}
-- specify a bounding box around the node; note that the origin lies
-- at the anchor postion of the node. The \meta{options} are a string
-- in the format of a sequence of |{key}{value}| pairs. They are
-- parsed and stored in the newly created node object on the Lua
-- layer. Graph drawing algorithms may use these options to treat 
-- the node in special ways. The \meta{lateSetup} is \TeX\ code that
-- just needs to be passed back when the node is finally
-- positioned. It is used to add ``decorations'' to a node after
-- positioning like a label.
--
-- @param name      Name of the node.
-- @param shape     The pgf shape of the node (e.g. "circle" or "rectangle")
-- @param xMin      Minimum x point of the bouding box.
-- @param yMin      Minimum y point of the bouding box.
-- @param xMax      Maximum x point of the bouding box.
-- @param yMax      Maximum y point of the bouding box.
-- @param options   Lua-Options for the node.
-- @param lateSetup Options for the node.
--
function Interface:addNode(name, shape, xMin, yMin, xMax, yMax, options, lateSetup)
  assert(self.graph, "no graph created")
  self.texboxes[#self.texboxes + 1] = Sys:getTeXBox()
  local tex = {
    texNode = #self.texboxes,
    shape = shape,
    maxX = xMax,
    minX = xMin,
    maxY = yMax,
    minY = yMin,
    texLateSetup = lateSetup
  }
  local node = Node:new{
    name = Sys:unescapeTeXNodeName(name), 
    tex = tex, 
    options = string.parse_braces(options),
    event_index = #self.graph.events + 1
  }
  self.graph.events[#self.graph.events + 1] = { kind = 'node', parameters = node }
  self.graph:addNode(node)
end




--- Sets options for an already existing node
--
-- This function allows you to change the options of a node that already exists. 
--
-- @param name      Name of the node.
-- @param options   Lua-Options for the node.

function Interface:setLateNodeOptions(name, options)
  local node = self.graph:findNode(name)
  if node then
    for k,v in string.parse_braces(options) do
      node.options [k] = v
    end
  end
end


--- Adds an edge from one node to another by name.  
--
-- Both parameters are node names and have to exist before an edge can be
-- created between them.
--
-- @see addNode
--
-- @param from         Name of the node the edge begins at.
-- @param to           Name of the node the edge ends at.
-- @param direction    Direction of the edge (e.g. |--| for an undirected edge 
--                     or |->| for a directed edge from the first to the second 
--                     node).
-- @param parameters   A string of parameters pairs of edge options that are
--                     relevant to graph drawing algorithms.
-- @param tikz_options A string that should be passed back to \pgfgddraw unmodified.
-- @param aux          Another string that should be passed back to \pgfgddraw unmodified.
--
function Interface:addEdge(from, to, direction, parameters, tikz_options, aux)
  assert(self.graph, "no graph created")
  local from_node = self.graph:findNode(from)
  local to_node = self.graph:findNode(to)
  assert(from_node and to_node, 'cannot add the edge because its nodes "' .. from .. '" and "' .. to .. '" are missing')
  if direction ~= Edge.NONE then
    local edge = self.graph:createEdge(from_node, to_node, direction, aux, string.parse_braces(parameters), tikz_options)
    edge.event_index = #self.graph.events + 1
    self.graph.events[#self.graph.events + 1] = { kind = 'edge', parameters = edge }
  end
end




--- Adds an event to the event sequence.
--
-- @param kind         Name/kind of the event.
-- @param parameters   Parameters of the event.
--
function Interface:addEvent(kind, param)
  assert(self.graph, "no graph created")
  self.graph.events[#self.graph.events + 1] = { kind = kind, parameters = param}
end



function Interface:addNodeToCluster(node_name, cluster_name)
  assert(self.graph, 'no graph created')
  
  -- find the node
  local node = self.graph:findNode(node_name)

  assert(node, 'cannot add node "' .. node_name .. '" to cluster "' .. cluster_name .. '" because the node does not exist')
  
  -- find the cluster
  local cluster = self.graph:findClusterByName(cluster_name)

  -- if it doesn't exist yet, create it on demand
  if not cluster then
    cluster = Cluster:new(cluster_name)
    self.graph:addCluster(cluster)
  end

  -- add the node to the cluster
  cluster:addNode(node)
end



--- Attempts to load the algorithm with the given \meta{name}.
--
-- This function tries to look up the corresponding algorithm file
-- |pgfgd-algorithms-<name>.lua| and attempts to
-- look up the class for calling the algorithm.
--
-- @param name Name of the algorithm.
--
-- @return The algorithm function or nil.
--
function Interface:loadAlgorithm(name)

   -- Load the file (if necessary)
   pgf.load("pgfgd-algorithm-" .. name .. ".lua", "tex", false)

   -- look up the main algorithm function
   return pgf.graphdrawing[name]
end


--- Arranges the current graph using the specified algorithm. 
--
-- The algorithm is derived from the graph options and is loaded on
-- demand from the corresponding algorithm file. For a fictitious algorithm 
-- |simple| this file is per convention called 
-- |pgflibrarygraphdrawing-algorithms-simple.lua|. It is required to define
-- at least one function as an entry point to the algorithm. The name of the
-- function is again predetermined as |graph_drawing_algorithm_simple|.
-- When a graph is to be layed out, this function is called with the graph
-- as its only parameter.
--
function Interface:drawGraph()
  if #self.graph.nodes == 0 then
    -- Nothing needs to be done
    return
  end
  
  local name = self:getOption("/graph drawing/algorithm"):gsub(' ', '')
  local algorithm_class = pgf.graphdrawing[name]
  
  -- if not defined, try to load the corresponding file
  if not algorithm_class then
    algorithm_class = self:loadAlgorithm(name)
  end
  
  assert(algorithm_class, "No algorithm named '" .. name .. "' was found. " ..
	 "Either the file does not exist or the class declaration is wrong.")
  local start = os.clock()
  -- Ok, everything setup.
  
  pipeline.run_graph_drawing_pipeline(self.graph, algorithm_class)
  
  local stop = os.clock()
  Sys:log(string.format("Graph drawing engine: algorithm '" .. name .. "' took %.4f seconds", stop - start))
end



--- Passes the current graph back to the \TeX\ layer and removes it from the stack.
--
function Interface:finishGraph()
  assert(self.graph, "no graph created")
  Sys:beginShipout()
  local graph = table.remove(self.graphStack)
  self.graph = self.graphStack[#self.graphStack]
  
  Sys:beginNodeShipout()
  for node in table.value_iter(graph.nodes) do
    self:drawNode(node)
  end
  Sys:endNodeShipout()

  Sys:beginEdgeShipout()
  for edge in table.value_iter(graph.edges) do
    self:drawEdge(edge)
  end
  Sys:endEdgeShipout()
  
  Sys:endShipout()
end



--- Passes a node back to the \TeX\ layer.
--
-- @param node The node to pass back to the \TeX\ layer.
--
function Interface:drawNode(node)
  Sys:putTeXBox(node,
                node.tex.texNode,
                node.tex.minX,
                node.tex.minY,
                node.tex.maxX,
                node.tex.maxY,
                node.pos.x,
                node.pos.y,
                node.tex.texLateSetup)
end


function Interface:getBox(box_reference)
  local ret = self.texboxes[box_reference]
  self.texboxes[box_reference] = nil
  return ret
end



--- Passes an edge back to the \TeX\ layer.
--
-- Edges with a direction of |Edge.NONE| are skipped and not passed
-- back to \TeX.
--
-- @param edge The edge to pass back to the \TeX\ layer.
--
function Interface:drawEdge(edge)
  if edge.direction ~= Edge.NONE then
    Sys:putEdge(edge)
  end
end



--- Defines a default value for a graph parameter. 
--
-- Whenever a graph parameter has not been set by the user explicitly,
-- the value that was last set using this function is used instead.
--
-- @param key The commplete path of the to-be-defined key
-- @param value A string containing the value
--
function Interface:setGraphParameterDefault(key,value)
  self.defaultGraphParameters[key] = value
end
