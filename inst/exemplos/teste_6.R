library(shiny)
library(bslib)
library(DT2)

ui <- page_fluid(
  theme = bs_theme(5, bootswatch = "flatly"),
  card(
    card_header("Select + Responsive"),
    dt2_output("tbl", height = "auto")
  ),
  verbatimTextOutput("state")
)

server <- function(input, output, session) {
  opts <- list(
    pageLength = 10,
    layout = list(
      topStart = list("pageLength"),
      #top2End = list("buttons"),
      top2End = list(
        buttons = list(
          list(extend="copyHtml5", text = 'Copiar'),
          list(extend="csvHtml5"),
          list(extend="excelHtml5"),
          list(extend="pdfHtml5"),
          list(extend="print", text = "Imprimir")
        )),
      topEnd   = list(search = list(placeholder = "Buscar")),
      bottomEnd = list("paging")
    ),
    # Select + Responsive (note o selector para evitar a coluna control)
    select = list(style = "os", items = "row"),  #
    #buttons  = list("copy", "csv", "excel", "pdf"),
    #responsive = TRUE,
    language = list(
      lengthMenu = "Mostrar _MENU_ linhas",
      lengthLabels = list(`-1` = "Todas"),
      info = "Mostrando _START_ a _END_ de _TOTAL_ registros"
    )
  )

  output$tbl <- render_dt2(
    dt2(
      data = head(iris, 50),
      options = opts
      #extensions = c("buttons", "responsive")  # << imprescindível
    )
  )

  output$state <- renderPrint(input$tbl_state)
}

shinyApp(ui, server)
