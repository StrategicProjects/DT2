# app.R
library(shiny)
library(bslib)
library(DT2)
library(htmlwidgets)

ui <- page_fluid(
  theme = bs_theme(version = 5, bootswatch = bootswatch_themes(5)[20], font_scale = .9),
  layout_sidebar(
    sidebar = sidebar(
      h4("Ajustes de layout (apenas v2)"),
      p("Sem extensões, sem 'dom'.")
    ),
    card(
      card_header("DT2"),
      dt2_output("tbl", height = "auto")
    ),
    card(
      card_header("Estado recebido do cliente (debug)"),
      verbatimTextOutput("state")
    )
  )
)

server <- function(input, output, session) {
  # dados menores só pra ver paginação
  iris_small <- iris
  opts <- list(
    lengthChange = TRUE,
    pageLength   = 10,
    lengthMenu = c(10, 25, 50, -1),
    layout = list(
      topStart = list("pageLength"),
      topEnd    = list(
                       buttons = list(
                         list(
                           extend = 'colvis',
                           text = "Colunas"
                             ),
                         list(
                           extend = 'collection',
                           text = 'Exportar',
                           buttons = list(
                             list(extend="copyHtml5", text = 'Copiar'),
                             list(extend="csvHtml5"),
                             list(extend="excelHtml5", title = "Dados exportados"),
                             list(extend="pdfHtml5", title = "Dados exportados"),
                             list(extend="print", text = "Imprimir",
                                  title = "Dados exportados",
                                  messageTop = '')
                           )
                         )
                         # list(extend="copyHtml5", text = 'Copiar'),
                         # list(extend="csvHtml5"),
                         # list(extend="excelHtml5"),
                         # list(extend="pdfHtml5"),
                         # list(extend="print", text = "Imprimir")
                       ),
                       search = list(placeholder = "")
                       ),
      # top2End = list(
      #   buttons = list(
      #     list(extend="copyHtml5", text = 'Copiar'),
      #     list(extend="csvHtml5"),
      #     list(extend="excelHtml5"),
      #     list(extend="pdfHtml5"),
      #     list(extend="print", text = "Imprimir")
      #   )),
      bottomEnd = list(paging = list(
        firstLast = TRUE,
        previousNext = TRUE,
        numbers = FALSE
        ))
    ),
    language = list(
      lengthMenu    = "Mostrar&nbsp; _MENU_",
      lengthLabels = list(
        `10` = "10",
        `25` = "25",
        `50` = "50",
        `-1` = "Todas"
      ),
      search        = "Buscar",
      paginate      = list(
        first = "&laquo;",
        previous="‹",
        `next`="›",
        last= "&raquo;" #"Último"
        ),
      info          = "Mostrando _START_ a _END_ de _TOTAL_ registros",
      infoEmpty     = "Mostrando 0 a 0 de 0 registros",
      infoFiltered  = "(filtrado de _MAX_ registros no total)",
      zeroRecords   = "Nenhum registro encontrado",
      emptyTable    = "Nenhum dado disponível",
      infoPostFix   =    "",
      loadingRecords= "Carregando dados...",
      decimal       = ",",
      thousands     = ".",
      infoThousands = ".",
      buttons = list(
        copyTitle   = "Copiado para a área de transferência",
        copyKeys    = "Pressione <i>Ctrl</i> ou <i>\u2318</i> + <i>C</i> para copiar os dados da tabela para a área de transferência.<br><br>Para cancelar, clique nesta mensagem ou pressione Esc.",
        copySuccess = list(
          `_` = "%d linhas copiadas",
          `1` = "1 linha copiada"
        )
      ),
      url = 'https://cdn.datatables.net/plug-ins/2.3.3/i18n/pt-BR.json'
    ),
    #select = TRUE
    select = list(style = "os", items = "row", selector = "td:not(.control)")
  )

  output$tbl <- render_dt2(
    dt2(
      data    = iris_small,
      options = dt2_theme(opts, compact = TRUE, striped = TRUE, hover = TRUE),
      extensions = c("select", "responsive")
    )
  )

  # Mostra o estado que o JS envia (útil para debug)
  output$state <- renderPrint(input$tbl_state)
}

shinyApp(ui, server)
