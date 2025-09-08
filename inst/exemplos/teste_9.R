library(shiny)
library(DT2)

ui <- fluidPage(
  tags$style(".table td { vertical-align: middle }"),
  DT2::dt2_output("x")
)

server <- function(input, output, session) {
  df <- data.frame(
    hits    = c(950, 1200, 15300, 2.1e6),
    created = c(Sys.time() - 60, Sys.time() - 3600*5, Sys.time() - 86400*3, Sys.time() - 15)
  )
  df$created <- format(df$created, "%Y-%m-%d %H:%M:%S") # string

  opts <- list(columns = names(df))
  opts <- dt2_format_number_abbrev(opts, "hits", locale = "pt-BR", digits = 1)
  opts <- dt2_format_time_relative(opts, "created", locale = "pt-BR")

  output$x <- DT2::render_dt2(DT2::dt2(df, options = opts, extensions = "responsive"))
}

shinyApp(ui, server)
