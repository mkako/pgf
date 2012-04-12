-- Copyright 2010 by Renée Ahrens, Olof Frahm, Jens Kluttig, Matthias Schulz, Stephan Schuster
--
-- This file may be distributed an/or modified
--
-- 1. under the LaTeX Project Public License and/or
-- 2. under the GNU Public License
--
-- See the file doc/generic/pgf/licenses/LICENSE for more information

-- @release $Header: /home/mojca/cron/mojca/github/cvs/pgf/pgf/generic/pgf/graphdrawing/core/lualayer/Attic/pgflibrarygraphdrawing-files.lua,v 1.11 2012/04/12 14:41:32 tantau Exp $

-- This file defines a list of initial files to load.

local files = {
  "module",
  "table",
  "stack",
  "iter",
  "string",
  "sys",
  "vector",
  "quadtree",
  "node",
  "edge",
  "cluster",
  "graph",
  "manipulation",
  "depth-first-search",
  "traversal",
  "fibonacci-heap",
  "priority-queue",
  "algorithms",
  "coarse-graph",
  "component-packing",
  "interface",
  "orientation",
  "positioning-helpers",
  "texboxregister",
  "ranking",
  "network-simplex",
  "anchoring",
  "componentdecomposition",
  "pipeline",
  "spanningtree",
  "spacing",
  "growth-adjust",
  "event-handling",
}

return files
