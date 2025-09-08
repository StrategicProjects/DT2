library(shiny)
library(bslib)
library(DT2)

ui <- page_fluid(
  theme = bs_theme(5, bootswatch = "flatly"),
  card(
    card_header(
      div(class = "d-flex justify-content-between align-items-center",
          span("Iris table with Buttons"),
          div(id = "btn-slot", class = "d-flex gap-2")   # <- destino dos botões
      )
    ),
    dt2_output("tbl", height = "auto")
  ),
  tags$style(HTML("
    #btn-slot .dt-buttons .btn
  "))
)

server <- function(input, output, session) {
  opts <- list(
    pageLength = 5,
    layout = list(
      topStart = list("pageLength"),
      topEnd   = list(search = list(placeholder = "Buscar")),
      # Não precisamos colocar 'buttons' no layout — o JS cria/move se faltarem
      bottomEnd = list("paging"),
      responsive = TRUE,
      columnDefs = list(
        list(responsivePriority = 1, targets = 0),
        list(responsivePriority = 3, targets = 1),
        list(responsivePriority = 2, targets = -1)
      )
    )
  )

  # Acrescenta botões e diz onde quer o container
  opts <- dt2_buttons(
    options = opts,
    buttons = c("copy", "csv", "excel", "pdf", "print"),
    target  = "#btn-slot"
  )

  output$tbl <- render_dt2(
    dt2(
      data      = head(iris, 30),
      options   = opts,
      extensions = "buttons"   # <- imprescindível
      # Se quiser CSV/Excel/PDF: garanta JSZip + pdfMake nas deps
    )
  )
}

shinyApp(ui, server)
