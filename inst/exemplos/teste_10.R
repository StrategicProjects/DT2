library(shiny)
library(DT2)

ui <- fluidPage(
  tags$head(tags$style(".highlight { background-color: #fff3cd; font-weight: bold;}")),
  dt2_output("tbl"),
  verbatimTextOutput("state")
)

server <- function(input, output, session) {
  df <- head(iris, 20)
  opts <- list(
    columns = names(df),
    pageLength = 5
  )

  opts$createdRow <- htmlwidgets::JS("
  function(row, data, dataIndex, cells) {
    //console.log('[DT2 createdRow] called — data:', data, 'row:', row, 'index:', dataIndex);
    // Exemplo de lógica existente (adaptar ao formato data):
    //var val = typeof data === 'object'
    //  ? parseFloat(data['Petal.Length'])
    //  : parseFloat(data[2]);  // índice se for array
    console.log('[DT2 createdRow] Petal.Length value:', data[2]);

    if (!isNaN(data['Petal.Length']) && (data['Petal.Length']) >= 1.4) {
      //row.classList.add('highlight');
      console.log('[DT2 createdRow] Highlight added on row index', dataIndex);
      // Opcional: highlight da célula
      if (cells && cells[2]) {
        cells[2].classList.add('highlight');
      }
    }
  }
")
  output$tbl <- render_dt2(dt2(df, options = opts, extensions = character()))
  output$state <- renderPrint(input$tbl_state)
}

shinyApp(ui, server)
