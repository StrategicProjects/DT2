library(shiny)
library(DT2)

ui <- fluidPage(
  h3("DT2 server-side (v2) – exemplo mínimo"),
  DT2::dt2_output("tbl"),
  verbatimTextOutput("dbg")  # para ver o estado enviado pelo JS (opcional)
)

server <- function(input, output, session) {
  df <- iris

  # 1) liga o pipeline server-side para o outputId "tbl"
  DT2::dt2_bind_server("tbl", df)  # usa o handler padrão (filtro+ordem+pagina)

  # 2) renderiza a tabela em modo server-side (sem ajax custom)
  output$tbl <- DT2::render_dt2({
    opts <- list(
      columns = names(df),
      pageLength = 10,
      language = list(lengthMenu = "Mostrar _MENU_ linhas")
    )
    DT2::dt2(data = df, options = opts, server_side = FALSE)
  })

  output$dbg <- renderPrint(input$tbl_state)
}

shinyApp(ui, server)
