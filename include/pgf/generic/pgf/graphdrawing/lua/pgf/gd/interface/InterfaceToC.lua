-- Copyright 2012 by Till Tantau
--
-- This file may be distributed an/or modified
--
-- 1. under the LaTeX Project Public License and/or
-- 2. under the GNU Public License
--
-- See the file doc/generic/pgf/licenses/LICENSE for more information

-- @release $Header: /cvsroot-fuse/pgf/pgf/generic/pgf/graphdrawing/lua/pgf/gd/interface/InterfaceToC.lua,v 1.4 2013/03/03 22:13:12 tantau Exp $


---
-- This table contains functions that are used (on the Lua side) to
-- prepare a graph for use in C and, vice versa, to translate back the
-- results of C to Lua.

local InterfaceToC = {}

-- Imports

local lib = require "pgf.gd.lib"


---
-- This function is called by |declare| for ``algorithm
-- keys'' where the algorithm is not written in Lua, but rather in the
-- programming language C. You do not call this function yourself;
-- |InterfaceFromC.h| will do it for you. Nevertheless, if you
-- provide a table to |declare| with the field
-- |algorithm_written_in_c| set, the following happens: The table's
-- |algorithm| field is set to an algorithm class object whose |run|
-- method calls the function passed via the
-- |algorithm_written_in_c| field. It will be called with the
-- following parameters (in that order):   
-- \begin{enumerate}
-- \item The to-be-laid out digraph. This will not be the whole layout
-- graph (syntactic digraph) if preprocessing like decomposition into
-- connected components is used.
-- \item An array of the digraph's vertices, but with the table part
-- hashing vertex objects to their indices in the array part.
-- \item An array of the syntactic edges of the digraph. Like the
-- array, the table part will hash back the indices of the edge objects.
-- \item The algorithm object.
-- \end{enumerate}
--
-- @param t The table originally passed to |declare|.

function InterfaceToC.declare_algorithm_written_in_c (t)
  t.algorithm = {
    run = function (self)
	    local back_table = lib.icopy(self.digraph.vertices)
	    for i,v in ipairs(self.digraph.vertices) do
	      back_table[v] = i
	    end
	    local edges = {}
	    for _,a in ipairs(self.digraph.arcs) do
	      local a = self.layout_graph:arc(a.tail,a.head)
	      if a then
		lib.icopy(a.syntactic_edges, edges)
	      end
	    end
	    for i=1,#edges do
	      edges[edges[i]] = i
	    end
	    t.algorithm_written_in_c (self.digraph, back_table, edges, self)
	  end
  }  
end



-- Done

return InterfaceToC