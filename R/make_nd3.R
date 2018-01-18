#' Make ND3
#'
#' Make nd3
#' @param some_param This is not yet documented
#' @return A html widget
#' @import nd3
#' @export


make_nd3 <- function (Links, Nodes, Source, Target, Value, NodeID, NodeGroup = NodeID, 
                      LinkGroup = NULL, units = "", colourScale = JS("d3.scaleOrdinal(d3.schemeCategory20);"), 
                      fontSize = 7, fontFamily = NULL, nodeWidth = 15, nodePadding = 10, 
                      margin = NULL, height = NULL, width = NULL, iterations = 32, 
                      sinksRight = TRUE) 
{
  check_zero(Links[, Source], Links[, Target])
  colourScale <- as.character(colourScale)
  Links <- tbl_df_strip(Links)
  Nodes <- tbl_df_strip(Nodes)
  if (!is.data.frame(Links)) {
    stop("Links must be a data frame class object.")
  }
  if (!is.data.frame(Nodes)) {
    stop("Nodes must be a data frame class object.")
  }
  if (missing(Source)) 
    Source = 1
  if (missing(Target)) 
    Target = 2
  if (missing(Value)) {
    LinksDF <- data.frame(Links[, Source], Links[, Target])
    names(LinksDF) <- c("source", "target")
  }
  else if (!missing(Value)) {
    LinksDF <- data.frame(Links[, Source], Links[, Target], 
                          Links[, Value])
    names(LinksDF) <- c("source", "target", "value")
  }
  if (missing(NodeID)) 
    NodeID = 1
  NodesDF <- data.frame(Nodes[, NodeID])
  names(NodesDF) <- c("name")
  if (is.character(NodeGroup)) {
    NodesDF$group <- Nodes[, NodeGroup]
  }
  if (is.character(LinkGroup)) {
    LinksDF$group <- Links[, LinkGroup]
  }
  margin <- margin_handler(margin)
  options = list(NodeID = NodeID, NodeGroup = NodeGroup, LinkGroup = LinkGroup, 
                 colourScale = colourScale, fontSize = fontSize, fontFamily = fontFamily, 
                 nodeWidth = nodeWidth, nodePadding = nodePadding, units = units, 
                 margin = margin, iterations = iterations, sinksRight = sinksRight)
  htmlwidgets::createWidget(name = "sankeyNetwork", x = list(links = LinksDF, 
                                                             nodes = NodesDF, options = options), width = width, height = height, 
                            htmlwidgets::sizingPolicy(padding = 10, browser.fill = TRUE), 
                            package = "nd3")
}
