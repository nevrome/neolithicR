#http://rich-iannone.github.io/DiagrammeR/ndfs_edfs.html
#http://graphviz.org/Documentation/dotguide.pdf

#### load libraries ####
library(DiagrammeR)
library(magrittr)

#### source dbs ####
sourceid <- 1:4
sourcelabel <- c("CALPAL", "aDRAC", "EUROEVOL", "RADON")

sourcedbs <- create_nodes(
  sourceid,
  label = sourcelabel,
  shape = "rectangle",
  width = 1.5,
  height = 1,
  color = "darkgreen",
  fontcolor = "darkgreen"
)

#### target db ####
targetid <- max(sourceid) + 1
targetlabel <- c("Internal SQLite 14C Database")

targetdb <- create_nodes(
  targetid,
  label = targetlabel,
  shape = "diamond",
  width = 4,
  height = 2
)

#### connect source dbs and target db ####
dbcons <- create_edges(
  from = sourceid,
  to = rep(targetid, length(sourceid)),
  label = "distinct interface",
  color = "darkgreen",
  fontcolor = "darkgreen",
  headport = "n"
)

#### RData ####
rdataid <- max(targetid) + 1
rdatalabel <- c("14C RData File")

rdata <- create_nodes(
  rdataid,
  label = rdatalabel,
  shape = "rectangle",
  width = 3,
  height = 1
)

#### connect target db and RData ####
rdatacons <- create_edges(
  from = targetid,
  to = rdataid,   
  label = "pull and save",
  tailport = "s"
)

#### app ####
appid <- max(rdataid) + 1
applabel <- c("Shiny Webapp neolithicRC")

app <- create_nodes(
  appid,
  label = applabel,
  width = 2,
  height = 2
)

#### connect target db and app ####
appcons <- create_edges(
  from = rdataid,
  to = appid   
)

#### db modifiers ####
dbmodcons <- create_edges(
  from = rep(targetid, 2),
  to = rep(targetid, 2),
  label = c("14C calibration", "spatial quality estimation"),
  color = "red",
  fontcolor = "red",
  minlen = 0.3,
  tailport = c("ne", "nw"),
  headport = c("se", "sw")
)

#### thesaurus ####
thesaurusid <- max(appid) + 1
thesauruslabel <- c("Thesaurus RData Files")

thesaurus <- create_nodes(
  thesaurusid,
  label = thesauruslabel,  
  shape = "rectangle",
  width = 3,
  height = 1,
  color = "blue",
  fontcolor = "blue"
)

thesauruscons <- create_edges(
  from = c(targetid, thesaurusid),
  to = c(thesaurusid, appid),
  label = c("thesaurus setup", ""),
  color = "blue",
  fontcolor = "blue",
  tailport = c("s", ""),
  style = c("dotted", "")
)

#### draw graph #####
graph <-
  create_graph() %>%
  set_global_graph_attrs(
    "graph", "overlap", "FALSE") %>%
  set_global_graph_attrs(
    "node", "fontname", "Arial") %>%
  set_global_graph_attrs(
    "edge", "fontname", "Arial") %>%
  set_global_graph_attrs(
    "edge", "penwidth", "2") %>%
  set_global_graph_attrs(
    "node", "penwidth", "2") %>%
  add_node_df(sourcedbs) %>%
  add_node_df(targetdb) %>%
  add_edge_df(dbcons) %>%
  add_node_df(rdata) %>%
  add_edge_df(rdatacons) %>%
  add_node_df(app) %>%
  add_edge_df(appcons) %>%
  add_edge_df(dbmodcons) %>%
  add_node_df(thesaurus) %>%
  add_edge_df(thesauruscons)
  
render_graph(graph)

#presentation/project_setup.png