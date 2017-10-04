
require(dplyr)
require(haven)
require(data.table)
library(shiny)
require(plotly)
require(zoo)
require(plotROC)
require(highcharter)
require(htmltools)
require(googleVis)
library(httr)
require(htmlwidgets)

shinyUI(navbarPage("Baròmetre d'opinió",
                   tabPanel('Visió estàtica',
                            tags$head(
                              tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
                            ),
                            sidebarLayout(
                              sidebarPanel(width = 2,
                                           p("Aplicació feta amb R i Shiny que permet d'una manera molt visual i senzilla visualitzar alguns dels resultats del barómetre d'opinió del CEO. Són dades anonimitzades i des de fa un temps, són públiques"),
                                           a("Centre d'estudis d'opinió", href = 'http://ceo.gencat.cat/ceop/AppJava/pages/index.html'),
                                           p("A l'última part, a través d'un petit qüestionari, s'intenta esbrinar si ets o no independentista."), 
                                           p("Autor de l'aplicació: Josep Puig Sallés"),
                                           icon("fa fa-linkedin"), a("Linkedin", href =  'https://www.linkedin.com/in/puigjos/'),
                                           hr(),
                                selectInput('input','Seleccione el barometre',c('2_2017',
                                                                           '1_2017', '3_2016','2_2016','1_2016',
                                                                           '3_2015','2_2015','1_2015')),
                                selectInput('par', 'Seleccioni la institució', c('Parlament' = 'partit_parlament',
                                                                                 'Congres' = 'partit_congres'))
                              
                              ),
                              mainPanel(
                                fluidRow(
                                  column(width = 6,
                                    h2('Pregunta: Vols que Catalunya sigui un estat independent?'),
                                    highchartOutput("plotInd"),
                                    hr()
                                  ),
                                  column(width = 6,
                                     h2('Pregunta: A quin partit votaries?'),
                                     p('Pot escollir o bé el Parlament de Catalunya o al Congrés dels Diputats'),
                                     highchartOutput("plotPart"),
                                     hr()
                                  )
                                ), 
                                fluidRow(
                                  column(width=6,
                                         h3('Relació entre partit i si és o no independentista'),
                                         highchartOutput("plotIndPar"),
                                         hr()
                                         ),
                                  column(width=6,
                                         h3('Partit amb ideologia'),
                                         p('Relació entre eix esquerra(0)-dreta(10) i el sentiment espanyol (0) o bé máxim català (10). 
                                           Els partits que tenen menys dun 3% d"elecció, s"han eliminat per tal de que no sigui molt carregós a nivell visual'),
                                         highchartOutput("plotParIdeo"),
                                         hr()
                                         )
                                ),
                                fluidRow(
                                  column(width=6,
                                         h3('Vot históric amb intenció de vot actual'),
                                         p("En la següent gràfica, a l'esquerra és el record de vot (en funció de la naturalesa de les eleccions, Congrés o Parlament),
                                              mentre que a la dreta és la intenció de vot per unes hipotètiques futures eleccions.
                                           Es veu com canvia la mentalitat dels enquestats en funció de la naturalesa de les eleccions"),
                                         htmlOutput('sankeyhist'),
                                         hr()
                                         ),
                                  column(width=6,
                                         h3('Vot al Parlament vs vot al Congrés'),
                                         p("En la següent gràfica, a l'esquerra és la intenció de vot al Parlment de Catalunya, mentre que a la dreta és la intenció de vot al Congrés del Diputats.
                                           Representació del traspàs de vots"),
                                         htmlOutput('sankey'),
                                         hr()
                                  )
                                  ),
                                fluidRow(
                                  column(width = 6,
                                         h3('Relació entre llengua vs resposta al referéndum'),
                                         p('En el següent gráfic (gráfic mosaic) es relaciona la pregunta al referendum amb la llengua propia. Veiem dues poblacions diferents.'),
                                         plotOutput('llengua_ref',height = '500px')
                                         ),
                                  column(width = 6,
                                         h3('Relació mitjà de comunicació vs resposta al referendum'),
                                         p('Es mostra en el següent gráfic la pregunta de quin mitjà es veuen les notícies i la pregunta del referendum, mitjançant un análisis de correspondencies.
                                           Amb el filtre, pot decidir el porcentatge de persones que veuen el mitjà (com més baix, més mitjans apareixeran i pot donar resultats borrosos ja que no hi ha suficient mostra)'),
                                         sliderInput('filtre_mitjans', '% de persones que veuen aquest mitjà', min=1, max=25, value=5),
                                         plotOutput('mitjans')
                                         )
                                )
                                )
                            )
                            ),
                   tabPanel('Visió dinàmica',
                                fluidRow(
                                  column(width = 6,
                                         h2('Parlament de Catalunya'),
                                         p('Evolució de la mentalitat de vot per al Parlament. Cal tenir en compte els diferents canvis de partit i de noms que fan més difícil l"anàlisi.'),
                                         highchartOutput('ParEvolCat'),
                                         hr()
                                     ),
                                  column(width = 6,
                                         h2("Evolució de l'independentisme"),
                                         p('Evolució dels diferents barómetres davant la pregunta: “Vol que Catalunya esdevingui un Estat independent”? '),
                                         highchartOutput('indEvol'),
                                         hr()
                                         )
                                    ),
                                fluidRow(
                                  column(width = 6, 
                                         h2('Congrés dels Diputats'), 
                                         highchartOutput('ParEvolEsp'),
                                         hr()
                                         ),
                                  column(width = 6,
                                         h3('Valoració de diverses institucions'),
                                         p('Anàlisi de components principals: es demana puntuar a diferents institucions del 0 al 10 (on 0 es molt dolent i 10 molt bé).
                                           Aquesta técnica permet reduir la dimensió i visualitzar-ho d"una manera gràfica. El color és la pregunta sobre la independencia. Podríem trobar alguna relació...'),
                                         a('Referencia',href = 'http://setosa.io/ev/principal-component-analysis/'),
                                         h4('Any 2017 i 2016 (falta de dades)'),
                                         div(style="display: inline-block;vertical-align:top; width: 150px;",
                                             numericInput("pca1", "Dimensió:",min=1, max=3, value=1)), 
                                         div(style="display: inline-block;vertical-align:top; width: 150px;",
                                             numericInput("pca2", "Dimensió:",min=2, max=4, value=2)),
                                         plotOutput('PCA')
                                         )
                                )
                   ),                                         
                   tabPanel('Quant independentista ets?',
                            sidebarLayout(
                              sidebarPanel(width=3,
                                           actionButton('go', 'Estima'),
                                           selectInput('sexe', 'Sexe',c('Home','Dona')),
                                           numericInput('edat','Edat', min=18, max=90, value=30),
                                           sliderInput('cat_esp', 'Sentiment (0=molt espanyol, 10=molt català)',
                                                       min=0, max=10, value=5),
                                           sliderInput('esq_dre', 'Ideologia (0=extrema esquerra, 10=extrema dreta)',
                                                       min=0, max=10, value=5),
                                           uiOutput('onvasneixer'),
                                           uiOutput('provincia'),
                                           uiOutput('llengua'),
                                           uiOutput('sentiment'),
                                           uiOutput('comunicacio')
                              ),
                              mainPanel(
                                fluidRow(
                                  column(width = 6, 
                                         h1("Nivell d'independentista (0-100)"),
                                         highchartOutput('result')
                                         ),
                                  column(width = 6,
                                         uiOutput('sorpresa'))
                                )

                              )
                            )
                   ),
                   tabPanel('Model de predicció',
                            fluidRow(
                              column(width = 6,
                                     h1('Model predictiu'),
                                     p("L'objectiu d'aquest apartat és explicar com he desenvolupat l'apartat anterior, on, a partir d'una serie de preguntes s'intenta predir la probabilitat de que una persona sigui o no independentista'.
                                        La construcció d'aquest model és molt senzilla: tenim una serie de preguntes que els enquestats han respós i a partir d'un model estadístic intentem predir quina seria la resposta davant de la pregunta de si vol o no la independencia.
                                       Models com aquest s'utilitzen en gairabé tots els sectors: models per predir la capacitat de pagament d'un client amb un préstec, si un client ens comprarà el nostre producte o no,
                                       quant vendré la setmana que ve, etc. En definitiva, utilitzar unes variables x per tal de predir una variable y"),
                                     hr(),
                                     h3('Técnica utilitzada'),
                                     p("Aquest punt és una mica més avançat: la técnica que he utilitzat és la regressió logística. La regressió logística, a diferencia de la regressió lineal (apliament coneguda amb la fòrmula: y = a + b*x),
                                         s'utilitza per predir una variable dicotómica: 0 o 1, compra o no-compra, pagarà o no-pagarà; és a dir, solament accepta dues respostes posibles."),
                                     h1('Curva ROC del model'),
                                     plotOutput('roc')
                                     ),
                              column(width=6, 
                                
                                h1('Anàlisis dels valors predits'),
                                plotOutput('model_graf')
                                
                                
                                
                              )
                              
                              
                                     
                            )
                            )
)
)

