library(shiny)
library(DT2)
library(htmlwidgets)

ui <- fluidPage(
  tags$style(HTML("
    .table > tbody > tr > td {
      vertical-align: middle !important;
    }
    .table > tbody > tr > td > .progress {
      margin-bottom: 0 !important;
    }
  ")),
  h3("Data rendering com função JS"),
  dt2_output("tbl")
)

server <- function(input, output, session) {
  df <- head(iris, 8)
  # simular uma coluna “progress” só para render demo
  df$Progress <- c(15, 40, 60, 80, 35, 10, 95, 45)
  names(df)[1] <- "Salary"  # só para nomear como no exemplo

  opts <- list(
    columns = names(df),
    columnDefs = list(
      list(
        targets = which(names(df) == "Salary") - 1,
        # DataTables v2: helper JSON -> vira DataTable.render.number('.', ',', 2, 'R$ ')
        render  = list("number", ".", ",", 2, "R$ ")
      ),
      list(
        targets = 1,
        # DataTables v2: helper JSON -> vira DataTable.render.number('.', ',', 2, 'R$ ')
        render  = list("number", ".", ",", 2, "")
      ),
      # Coluna "Progress" -> progress bar (render só para display)
      list(
        targets = which(names(df) == "Progress") - 1,
        render = JS(
          "function(data, type, row, meta){
             if (type !== 'display') return data;
             var pct = parseFloat(data) || 0;
             return '<div class=\"progress\" style=\"height:12px;\">'
                  +   '<div class=\"progress-bar\" role=\"progressbar\"'
                  +   '     style=\"width:' + pct + '%\"'
                  +   '     aria-valuenow=\"' + pct + '\" aria-valuemin=\"0\" aria-valuemax=\"100\"></div>'
                  + '</div>';
          }"
        )
      )
      # Coluna "Salary" -> formatação numérica (ex.: milhares com ponto, 2 casas, prefixo R$)
      # list(
      #   targets = which(names(df) == "Salary") - 1,
      #   render  = JS("DataTable.render.number('.', ',', 2, 'R$ ')")
      # )
    ),
    pageLength = 8
  )

  output$tbl <- render_dt2(dt2(df, options = opts, extensions = "buttons"))
}

shinyApp(ui, server)
