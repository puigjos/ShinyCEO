
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
require(shinydashboard)
require(zoo)
library(httr)
library(googleVis)
library(googleAnalyticsR)
require(ca)
require(plotly)
library(googleAuthR)
require(dplyr)
require(haven)
require(factoextra)
require(ggmosaic)
require(FactoMineR)
require(data.table)

source('functions/functions.R')
shinyServer(function(input, output) {

  independencia = reactive('P31')
  partit_parlament = reactive('P37') 
  partit_congres = reactive("P39")
  eix_esq = reactive('P25')
  sexe = reactive("SEXE")
  edat = reactive("EDAT")
  cat_esp = reactive('P27')
  naix = reactive('C100')
  antiguesParl = reactive('P38B')
  antiguesCong = reactive('P40B')
  sentiment = reactive('C700')
  llengua = reactive('C706')
  classe_social = reactive('C800')
  comunicacio = reactive('P16A_REC')
  
  
  data2_2017 <- reactive({
    tot('2_2017', independencia(), partit_parlament(),
        partit_congres(), eix_esq(), edat(),sexe(),  cat_esp(), comarca = 'COMARCA',
        provincia='PROVI', naix(), antiguesParl(), antiguesCong(), sentiment(),
        llengua(), classe_social(),comunicacio())
  })
  
  data1_2017 <- reactive({
    tot('1_2017', independencia(), partit_parlament(),
        partit_congres(), eix_esq(), edat(),sexe(),  cat_esp(), comarca = 'COMARCA',
        provincia='PROVI', naix(), antiguesParl(), antiguesCong(), sentiment(),
        llengua(), classe_social(),comunicacio())
  })
  data3_2016 <- reactive({
    tot('3_2016', independencia(), partit_parlament(),
        partit_congres(), eix_esq(), edat(),sexe(),  cat_esp(), comarca = 'COMARCA',
        provincia='PROVI', naix(), antiguesParl(), antiguesCong(), sentiment(),
        llengua(), classe_social(),comunicacio())
  })
  data2_2016 <- reactive({
    tot('2_2016', independencia(), partit_parlament(),
        partit_congres(), eix_esq(), edat(),sexe(),  cat_esp(), comarca = 'COMARCA',
        provincia='PROVI', naix(), antiguesParl(), antiguesCong(), sentiment(),
        llengua(), classe_social(),comunicacio())
  })
  data1_2016 <- reactive({
    tot('1_2016', independencia(), partit_parlament(),
        partit_congres(), eix_esq(), edat(),sexe(),  cat_esp(), comarca = 'COMARCA',
        provincia='PROVI', naix(), antiguesParl(), antiguesCong(), sentiment(),
        llengua(), classe_social(),comunicacio())
  })
  data3_2015 <- reactive({
    tot('3_2015', independencia(), partit_parlament(),
        partit_congres(), eix_esq(), edat(),sexe(),  cat_esp(), comarca = 'COMARCA',
        provincia='PROVI', naix(), antiguesParl(), antiguesCong(), sentiment(),
        llengua(), classe_social(),comunicacio())
  })
  data2_2015 <- reactive({
    tot('2_2015', independencia(), partit_parlament(),
        partit_congres(), eix_esq(), edat(),sexe(),  cat_esp(), comarca = 'COMARCA',
        provincia='PROVI', naix(), antiguesParl(), antiguesCong(), sentiment(),
        llengua(), classe_social(),comunicacio())
  })
  data1_2015 <- reactive({
    tot('1_2015', independencia(), partit_parlament(),
        partit_congres(), eix_esq(), edat(),sexe(),  cat_esp(), comarca = 'COMARCA',
        provincia='PROVI', naix(), antiguesParl(), antiguesCong(), sentiment(),
        llengua(), classe_social(),comunicacio())
  })
  

  
  
  data <- reactive({
    eval(parse(text = paste0('data =', paste0('data', input$input,'()'))))
    # data = data1_2017()
    data
  })
  
  par <- reactive({
    x = data()
    x1 = partit(x, partit = input$par)
    par = unique(data.table(x1[, .(get(input$par), media_esq_dret, 
                                   media_esp_cat, P,count_SI,count_NO,
                                   count_No_ho_sap, count_No_Contesta)]))
    names(par)[1] = input$par
    par
  })
  
  output$plotInd <- renderHighchart({
    data <- data() %>% group_by(independencia) %>% 
      summarise(values = n()/nrow(data()))
    
    highchart() %>% 
      hc_add_series_labels_values(labels = data$independencia, values = 100*data$values, type='pie') %>% 
      hc_tooltip(pointFormat = '<b>{point.y:.2f} % </b>')

  })

  output$plotPart <- renderHighchart({
    data <- data() %>% group_by_(input$par) %>% 
      summarise(values = n()/nrow(data())) %>% 
      filter(values>.02) %>% 
      droplevels()
    highchart() %>% 
      hc_add_series_labels_values(labels = data[[input$par]], values = 100*data$values, type='pie') %>% 
      hc_tooltip(pointFormat = '<b>{point.y:.2f} % </b>')
  })
  
  output$plotIndPar <- renderHighchart({
    par = par()
    highchart() %>% 
      hc_xAxis(categories = par[[input$par]]) %>% 
      hc_add_series_labels_values(labels = par[[input$par]], 
                                  values = par$count_SI*100, type='bar', name = 'Si') %>% 
      hc_add_series_labels_values(labels = par[[input$par]], 
                                  values = par$count_NO*100, type='bar', name='No') %>% 
      hc_add_series_labels_values(labels = par[[input$par]], 
                                  values = par$count_No_Contesta*100, type='bar', name='No contesta') %>%
      hc_add_series_labels_values(labels = par[[input$par]], 
                                  values = par$count_No_ho_sap*100, type='bar', name = 'No ho sap') %>% 
      hc_plotOptions(bar = list(
        stacking = "normal")
      ) %>% 
      hc_tooltip(pointFormat = '<b>{point.y:.2f} % </b>', crosshairs = TRUE)
  })
  
  output$plotParIdeo <- renderHighchart({
    par = par()
    highchart() %>% 
      hc_title(text = 'Partits i pensament dels votants') %>% 
      hc_add_series_scatter(par$media_esq_dret, par$media_esp_cat,
                            label = par[[input$par]],z = par$P*100 ) %>% 
      hc_xAxis(title = list(text = "Eix esquerra-dreta"),
               plotLines = list(
                 list(color = "#FF0000",
                      width = 1,
                      value = 5))) %>% 
      hc_yAxis(title = list(text = "Eix espanyolisme-catalanisme"),
               plotLines = list(
                 list(color = "#FF0000",
                      width = 2,
                      value = 5))) %>% 
      hc_tooltip(useHTML = TRUE,
                 headerFormat = "<table>",
                 pointFormat = paste("<tr><th Partit =\"1\"><b>{point.label}</b></th></tr>",
                                     "<tr><th>Ideologia: </th><td>{point.x:.2f} </td></tr>",
                                     "<tr><th>Sentiment: </th><td>{point.y:.2f} </td></tr>",
                                     "<tr><th> % de vot: </th><td>{point.z:.2f} % </td></tr>"),
                 footerFormat = "</table>")
  })
  
  output$sankey <-  googleVis::renderGvis({
    dt = data()[,.(partit_parlament, partit_congres)]
    dt = dt %>% group_by(partit_parlament) %>% 
      mutate(weight = n()/nrow(dt)) %>% 
      ungroup() %>% filter(weight > .025) %>% droplevels() %>% 
      group_by(partit_congres) %>% 
      mutate(w = n()/nrow(dt)) %>% filter(w > 0.0065) %>% 
      droplevels()
    
    links = data.frame(dt)
    links$partit_parlament = as.character(links$partit_parlament)
    links$partit_congres = paste(as.character(links$partit_congres),'.')
    sk1 <- gvisSankey(links, from='partit_parlament', to="partit_congres",
                      weight = 'weight', 
                      options=list(title="Hello World")
                      )
    sk1
  })
  
  output$sankeyhist <- googleVis::renderGvis({
    par = input$par
    var <- paste0(input$par, '_antic')
    xx <- data() %>% 
      dplyr::select_(var, par) %>% 
      group_by_(par) %>% mutate(weight = n()/nrow(data())) %>% 
      ungroup() %>% group_by_(var) %>% 
      mutate(p = n()/nrow(data())) %>% filter(weight>.02) %>% 
      filter(p>.02) %>% droplevels() %>% 
      ungroup
    xx$from = paste0(xx[[var]], '.')
    xx$to = xx[[par]]
    xx <- xx %>% 
      dplyr::select(from, to, weight)
    xx = as.data.frame(xx)
    sk1 <- gvisSankey(xx, from="from", to="to",
                      weight = 'weight')
    
  })
  
  output$llengua_ref <- renderPlot({
    res = data() %>% select(independencia, llengua) 
    
    p <- ggplot(res, aes(x=product(independencia),  fill = llengua, 
                         weights=independencia)) + 
      geom_mosaic() + xlab('Vot al referendum') + theme_minimal()+
      scale_fill_discrete(guide = guide_legend(nrow = 6)) +
      theme(legend.position="bottom")
    p
  })
  
  output$mitjans <- renderPlot({
    res <- data() %>% select(independencia, comunicacio) %>% 
      group_by(comunicacio) %>% mutate(com = n()/nrow(.)) %>% 
      dplyr::filter(com>(input$filtre_mitjans/100)) %>% droplevels() %>% 
      select(-com)
    res1 = with(res, table(independencia, comunicacio))
    
    CA = ca(res1)
    fviz_ca_biplot(CA,geom = c('point','text'), geom.row = c('arrow', 'text'), repel = T )
  })
  
  

# Dinamica ----------------------------------------------------------------


  total = reactive({
    total = list(D1_2015 = data1_2015(),D2_2015 = data2_2015(),D3_2015=data3_2015(),
                 D1_2016=data1_2016(),D2_2016=data2_2016(),D3_2016=data3_2016(),
                 D1_2017=data1_2017(),D2_2017=data2_2017())
    total
  })

  output$indEvol <- renderHighchart({
    data = agPartits(datos = total(), lloc = 'independencia')
    dtlarge = melt(data, id ='Date')
    hchart(dtlarge, "line", hcaes(x = Date, y = value*100, group = variable, label = variable)) %>% 
      hc_tooltip(useHTML = TRUE,
                 headerFormat = "<table>",
                 pointFormat = paste("<tr><th Resposta =\"1\"><b>{point.label}</b></th></tr>",
                                     "<tr><th>% de votants: </th><td>{point.y:.2f} % </td></tr>"),
                 footerFormat = "</table>") %>%       
      hc_xAxis(title = list(text = "Date")) %>% 
      hc_yAxis(title=list(text = '% de votants'))

  })
  output$ParEvolCat <- renderHighchart({
    data = agPartits(datos = total(), lloc = 'partit_parlament')
    dtlarge = melt(data, id ='Date')
    hchart(dtlarge, "line", hcaes(x = Date, y = value*100, group = variable, label = variable)) %>% 
      hc_tooltip(useHTML = TRUE,
                 headerFormat = "<table>",
                 pointFormat = paste("<tr><th Resposta =\"1\"><b>{point.label}</b></th></tr>",
                                     "<tr><th>% de votants: </th><td>{point.y:.2f} % </td></tr>"),
                 footerFormat = "</table>") %>% 
      hc_xAxis(title = list(text = "Date")) %>% 
      hc_yAxis(title=list(text = '% de votants'))
  })
  
  output$ParEvolEsp <- renderHighchart({
    data = agPartits(datos = total(), lloc = 'partit_congres')
    dtlarge = melt(data, id ='Date')
    hchart(dtlarge, "line", hcaes(x = Date, y = value*100, group = variable, label = variable)) %>% 
      hc_tooltip(useHTML = TRUE,
                 headerFormat = "<table>",
                 pointFormat = paste("<tr><th Resposta =\"1\"><b>{point.label}</b></th></tr>",
                                     "<tr><th>% de votants:  </th><td>{point.y:.2f} % </td></tr>"),
                 footerFormat = "</table>") %>% 
      hc_xAxis(title = list(text = "Date")) %>% 
      hc_yAxis(title=list(text = '% de votants'))
    
  })
  
  
  pcadata <- reactive({
    datos1 = read_sav("data/Microdades_anonimitzades_2_2017.sav")
    datos1$P31 = as_factor(datos1$P31, levels = 'labels')
    val1 =datos1 %>% dplyr::select(P31, starts_with('P21')) %>% dplyr::select(-P21O)
    datos2 = read_sav("data/Microdades_anonimitzades_2_2016.sav")
    datos2$P31 = as_factor(datos2$P31, levels = 'labels')
    val2 =datos2 %>% dplyr::select(P31, starts_with('P21')) %>% dplyr::select(-P21O)
    val = rbind(val1, val2)
    val[val==99] = NA
    val[val==98] = NA
    val = na.omit(val)
    name = c('Vota', 'tribunals de justícia', 'Els partits polítics','ajuntament','El Govern espanyol','sindicats',
             'Govern de la Generalitat' ,'Congrés dels Diputats','Parlament de Catalunya',
             'Unió Europea','Monarquia espanyola', 'Exercit', 'Policia Nacional','Mossos Esquadra',
             'Església Catòlica','banca','mitjans de comunicació',
             'Tribunal Constitucional','universitats')
    names(val) = name
    val
  })
  
  output$PCA <- renderPlot({
    val = pcadata()
    pca.cat  = PCA(val[,-1], scale.unit = F, graph = F)
    
    fviz_pca_biplot(pca.cat,axes = c(input$pca1, input$pca2),  geom = c('point'), 
                    pointsize=.7,habillage = val$Vota) + theme_minimal()
    # + ggtitle(color = 'Independencia?')
  })
  
  
  
  

# Test --------------------------------------------------------------------

  modelo <- reactive({
    readRDS('data/modelo.rds')
  })
  
  dataModelo <- reactive({
    readRDS('data/datosMod.rds')
  }) 
  
  output$onvasneixer <- renderUI({
    selectInput('onvasneixerID', 'On vas néixer', unique(dataModelo()$`Lloc de naixament`))
  })
  
  output$provincia <- renderUI({
    selectInput('provinciaID', 'On vius actualment (provincia)?', unique(dataModelo()$provincia))
  })
  
  output$sentiment <- renderUI({
    selectInput('sentimentID', 'Sentiment', unique(dataModelo()$sentiment))
  })
  
  output$comunicacio <- renderUI({
    selectInput('comunicacioID', 'Mitjà de comunicació que veus les noticies:',
                unique(dataModelo()$comunicacio))
  })
  output$llengua <- renderUI({
    selectInput('llenguaID', 'Llengua que utilitzes normalment',
                unique(dataModelo()$llengua))
  })
  
  prediction <- eventReactive(input$go,  {
    x = data.table(eix_esq = input$esq_dre, edat = input$edat, sexe = input$sexe,
                   provincia = input$provinciaID, cat_esp = input$cat_esp,
                   `Lloc de naixament` = input$onvasneixerID, sentiment = input$sentimentID,
                   comunicacio = input$comunicacioID, llengua = input$llenguaID
                   )
    if(input$comunicacioID %in% c("TVE 1","TV3","Antena 3","Tele 5","La Sexta")){
      predict(modelo()[[2]], x, type='response')
    }else{
      predict(modelo()[[1]], x, type='response')
    }
    


  })
  
  output$result <- renderHighchart({
   col = palete(prediction(), min=0, max=1, pal = 'BuGn', n=9) 
   x = round(100*prediction(),2)
   highchart() %>% 
     hc_add_series_labels_values(labels = 'Tu', values = x, name = 'Tu',
                                 type='column', color = col) %>% 
     hc_yAxis(min=0, max=100) 
   
  })
  
  output$sorpresa  = renderUI({
    if(is.null(prediction())){
      NULL
    }
    
    if(prediction()<.05){
      tagList(tags$h4('Si fa falta entres a la diagonal amb els tancs!!'),
              tags$img(src ='https://media.giphy.com/media/l41YgmUasxscF1J7i/giphy.gif' ))
    }else if(prediction()>= 0.05 & prediction() < .20){
      tagList(tags$h4('No vols la independencia, y punto!'),
              tags$img(src ='https://media.giphy.com/media/g69ZPJfLy7hD2/giphy.gif' ))
    }else if(prediction()>= .20 & prediction() < .35){
      tagList(tags$h4('No voldries la independencia, 
                      però vigila que encara et podrien convéncer!'),
              tags$img(src ='https://media.giphy.com/media/UB2GxvYsswbBu/giphy.gif' ))
    }else if(prediction()>= .35 & prediction() < .65){
      tagList(tags$h4('No ho tens clar! Depen del dia i de com et despertes'),
              tags$img(src ='https://media.giphy.com/media/26tk182taXxISsuEo/giphy.gif'))
    }else if(prediction()>= .65 & prediction() < .80){
      tagList(tags$h4('Voldries la independencia, 
                      però si no, continuaràs vivint tranquil/a'),
              tags$img(src ='https://media.giphy.com/media/PinQmyLYvrGVO/giphy.gif' ))
    }else if(prediction() >= .8 & prediction() < .95){
      tagList(tags$h4('Vols la independencia, fes-te voluntari!'),
              tags$img(src ='https://media.giphy.com/media/l4q83E0RjRSGLXBLO/giphy.gif' ))
    }else if(prediction() >= .95){
      tagList(tags$h4('No te vuelvas loco!!'),
              tags$img(src ='https://media.giphy.com/media/l4JyJirVHOJiSFVFm/giphy.gif' ))
    }
    
    
  })
  
  
  ###########
  
  p_all <- reactive({
    x_w = dataModelo() %>% filter(!is.na(comunicacio) & 
                         comunicacio %in% c("TVE 1","TV3","Antena 3","Tele 5","La Sexta"))
    x_wn <- dataModelo()[!dataModelo()$id %in% x_w$id , ]
    p1 = predict(modelo()[[1]], x_wn, type='response')
    p2 = predict(modelo()[[2]], x_w, type='response')
    data.table(obj = c(x_w$obj, x_wn$obj), p = c(p2, p1),
               independencia = c(as.character(x_w$independencia),
                                 as.character(x_wn$independencia)))
    
  })
  
  output$roc <- renderPlot({
    x = p_all()
    ggplot(x, aes(d = obj, m = p)) + geom_roc()+style_roc()
    
  })
  
  output$model_graf <- renderPlot({
    ggplot(p_all(), aes( x = p, fill = independencia)) +
      geom_histogram(alpha = .6, position = 'identity') + 
      scale_fill_manual(values = c('purple','orange')) + 
      labs(x = 'Probabilitat de votar Si',
           fill = 'Resposta') + theme_minimal()
  })

  
  
  
  
  
})
