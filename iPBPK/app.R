library(shiny)          # for shiny App
library(shinydashboard) # for shiny App UI structure
library(shinyjs)   # for hide and show a shiny element
library(mrgsolve)  # for PBPK model
library(ggplot2)   # for plot output
library(truncnorm) # R package for Truncated normal distribution
library(EnvStats)  # Package for Environmental Statistics, Including US EPA Guidance
library(rmarkdown) # for output report
library(dplyr)     # for dataframe manupulation
library(knitr)     # for output report

## Sidebar content
sidebar <- dashboardSidebar(
  sidebarMenu(menuItem("Main Plot", tabName = 'plot', icon = icon("microchip"), selected = TRUE),
              menuItem('Model Parameters', tabName = 'modelparameter', icon = icon('line-chart')),
              menuItem("Output Table", tabName = 'table', icon = icon("table")),
              menuItem("Model Structure", tabName = 'modelstructure', icon = icon("area-chart")),
              menuItem("Code", tabName = 'code', icon = icon("code")),
              menuItem("Tutorial", tabName = "tutorial", icon = icon("mortar-board")),
              menuItem("Output Report", tabName = "report", icon = icon("file-pdf-o")),
              menuItem("About", tabName = 'about', icon = icon("question-circle"))
  )
)

body <- dashboardBody(
  tabItems(
    tabItem(
      tabName = 'plot',
      sidebarLayout(
        sidebarPanel(width = 2,
                     fluidRow(
                       useShinyjs(),
                       tags$h4("Parameters for Therapeutic Scenario"),
                       div(
                       id = "therapeutic",
                       selectInput(inputId = 'animal', label = 'Species', choices = c('Beef Cattle','Market-age Swine'), width = 150, selected = "Beef Cattle"
                       ),
                       selectInput(inputId = 'drug', label = 'Drug', choices = c('Flunixin'), width = 150
                       ),
                       conditionalPanel(condition = "input.animal == 'Market-age Swine'",
                                        selectInput(inputId = 'target_swine', label = 'Target tissue', choices = c('Plasma','Liver','Kidney','Muscle','Fat'),
                                                    selected = 'Liver', width = 150
                                        )),
                       conditionalPanel(condition = "input.animal == 'Beef Cattle'",
                                        selectInput(inputId = 'target', label = 'Target tissue', choices = c('Plasma','Liver','Kidney','Muscle','Fat'),
                                                    selected = 'Liver', width = 150
                                        )),
                       conditionalPanel(condition = "input.animal == 'Beef Cattle'",
                                        selectInput(inputId = 'route', label = 'Administration route', choices = c('iv','im','sc'),
                                                    selected = 'iv', width = 150             
                                        )),
                       conditionalPanel(condition = "input.animal == 'Market-age Swine'",
                                        selectInput(inputId = 'route_swine', label = 'Administration route', choices = c('iv','im'),
                                                    selected = 'im', width = 150 
                                        )),                  
                       numericInput(inputId = 'doselevel', label = 'Dose level (mg/kg)', value = 2.2, 
                                    min = 0,  step = 0.01, width = 150
                       ),
                      tags$p(" "),
                      numericInput(inputId = 'tinterval', label = 'Dose interval (h)', value = 24, 
                                   min = 1, max = 24*10, step = 1, width = 150
                      ),
                      numericInput(inputId = 'numdose', label = 'Number of administrations', value = 3, 
                                   min = 1, max = 5*10, step = 1, width = 150
                      ),
                      numericInput(inputId = 'N', label = 'Number of animials', value = 1000, min = 1, step = 1, width = 150),
                      conditionalPanel(condition = "input.animal == 'Beef Cattle'&& (input.target == 'Liver'|input.target == 'Plasma'|input.target == 'Kidney'|input.target == 'Fat') ",
                                       numericInput(inputId = 'tolerance', label = 'Tolerance or MRL (ug/mL or ug/g)', value = 0.125, 
                                       min = 0.01, step = 0.01, width = 150)),
                      conditionalPanel(condition = "input.animal == 'Beef Cattle'&& input.target == 'Muscle'",
                                       numericInput(inputId = 'tolerance', label = 'Tolerance or MRL (ug/mL or ug/g)', value = 0.025, 
                                                    min = 0.01, step = 0.01, width = 150)),
                      conditionalPanel(condition = "input.animal == 'Market-age Swine'&& (input.target_swine == 'Liver'|input.target == 'Plasma'|input.target == 'Kidney'|input.target == 'Fat')",
                                       numericInput(inputId = 'tolerance_swine', label = 'Tolerance or MRL (ug/mL or ug/g)', value = 0.030, 
                                       min = 0.01, step = 0.01, width = 150)),
                      conditionalPanel(condition = "input.animal == 'Market-age Swine'&& input.target_swine == 'Muscle'",
                                       numericInput(inputId = 'tolerance_swine', label = 'Tolerance or MRL (ug/mL or ug/g)', value = 0.025, 
                                                    min = 0.01, step = 0.01, width = 150)),
                      conditionalPanel(condition = "input.animal == 'Beef Cattle'",
                                       numericInput(inputId = 'simu_time', label = 'Simulation time after last administration', value = 15, 
                                                    min = 1, max = 100, step = 1, width = 150
                                       )),
                      conditionalPanel(condition = "input.animal == 'Market-age Swine'",
                                       numericInput(inputId = 'simu_time_swine', label = 'Simulation time after last administration', value = 22, 
                                                    min = 1, max = 100, step = 1, width = 150
                                       )),                      
                      conditionalPanel(condition = "input.animal == 'Beef Cattle'",                                       
                                       tags$strong(tags$a(href="https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfcfr/CFRSearch.cfm?fr=556.286", 'Tolerance by FDA', target="_blank"
                                       )),
                                       tags$p("Labeled WDT (day): 4"),
                                       tags$p("Labeled dose (mg/kg): 2.2"),
                                       tags$p("Tolerance in liver (ppm or ug/g): 0.125"),
                                       tags$p("Tolerance in muscle (ppm or ug/g): 0.025")
                                       ),
                       conditionalPanel(condition = "input.animal == 'Market-age Swine'",
                                        tags$strong(tags$a(href="https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfcfr/CFRSearch.cfm?fr=556.286", 'Tolerance by FDA', target="_blank"
                                        )),
                                       tags$p("Labeled WDT (day): 12"),
                                       tags$p("Labeled dose (mg/kg): 2.2"),
                                       tags$p("Tolerance in liver (ppm or ug/g): 0.030"),
                                       tags$p("Tolerance in muscle (ppm or ug/g): 0.025")
                                       ),
                       actionButton(inputId = 'action',label = 'Apply Changes'),
                       actionButton(inputId = 'reset', label = 'Default Values')
                       ))
        ),
        mainPanel(
          tabName = 'plot',
          fluidRow(
            box(title = 'Extralabel Withdrawal Interval Plot',
                plotOutput(outputId = 'wdtplot'),height = 800, width = 2000,
                br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),
                downloadButton('downloadwdt','Download')
            )
          )
        )
      )
    ),    
    tabItem(
      tabName = 'modelparameter',
      sidebarLayout(
        sidebarPanel(width = 3,
                     fluidRow(
                       useShinyjs(),
                       tabsetPanel(id = 'tabs', type = 'pills', # "tabs" = "tabs" in conditionalPanel
                       tabPanel(title = 'Physiological parameters'),
                       tabPanel(title = 'Chemical parameters')),
                       div(
                       id = "all_parameters",
                         actionButton(inputId = 'action1',label = 'Apply Changes'),
                         actionButton(inputId = 'reset1', label = 'Default Values'),
                         br(),
                         conditionalPanel(condition = "input.tabs == 'Physiological parameters'&& input.animal == 'Market-age Swine'",
                                        splitLayout(
                                          numericInput(inputId = 'BW.mean_swine', label = 'BW mean', value = 33.18, 
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'BW.sd_swine', label = 'BW SD', value = 6.451, 
                                                       step = 0.01, width = 100
                                          )),
                                        splitLayout(
                                          numericInput(inputId = 'QCC.mean_swine', label = 'QCC mean', value = 8.543,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'QCC.sd_swine', label = 'QCC SD', value = 1.91,
                                                       step = 0.01, width = 100
                                          )),
                                        splitLayout(
                                          numericInput(inputId = 'QLC.mean_swine', label = 'QLC mean', value = 0.273,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'QLC.sd_swine', label = 'QLC SD', value = 0.08175,
                                                       step = 0.01, width = 100
                                          )),
                                        splitLayout(
                                          numericInput(inputId = 'QKC.mean_swine', label = 'QKC mean', value = 0.116,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'QKC.sd_swine', label = 'QKC SD', value = 0.01733,
                                                       step = 0.01, width = 100
                                          )),
                                        splitLayout(
                                          numericInput(inputId = 'QMC.mean_swine', label = 'QMC mean', value = 0.293,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'QMC.sd_swine', label = 'QMC SD', value = 0.04216,
                                                       step = 0.01, width = 100
                                          )),
                                        splitLayout(
                                          numericInput(inputId = 'QFC.mean_swine', label = 'QFC mean', value = 0.128,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'QFC.sd_swine', label = 'QFC SD', value = 0.03825,
                                                       step = 0.010, width = 100
                                          )),
                                        splitLayout(
                                          numericInput(inputId = 'QrestC.mean_swine', label = 'QrestC mean', value = 0.190,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'QrestC.sd_swine', label = 'QrestC SD', value = 0.05712,
                                                       step = 0.001, width = 100
                                          )),
                                        splitLayout(
                                          numericInput(inputId = 'VLC.mean_swine', label = 'VLC mean', value = 0.023,
                                                       step = 0.001, width = 100
                                          ),
                                          numericInput(inputId = 'VLC.sd_swine', label = 'VLC SD', value = 3.609e-4,
                                                       step = 0.0001, width = 100
                                          )),
                                        splitLayout(
                                          numericInput(inputId = 'VKC.mean_swine', label = 'VKC mean', value = 0.005,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'VKC.sd_swine', label = 'VKC SD', value = 1.738e-4,
                                                       step = 0.00001, width = 100
                                          )),
                                        splitLayout(
                                          numericInput(inputId = 'VFC.mean_swine', label = 'VFC mean', value = 0.235,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'VFC.sd_swine', label = 'VFC SD', value = 1.802e-2,
                                                       step = 0.001, width = 100
                                          )),
                                        splitLayout(
                                          numericInput(inputId = 'VMC.mean_swine', label = 'VMC mean', value = 0.355,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'VMC.sd_swine', label = 'VMC SD', value = 2.494e-3,
                                                       step = 0.001, width = 100
                                          )),
                                        splitLayout(
                                          numericInput(inputId = 'VvenC.mean_swine', label = 'VvenC mean', value = 0.044,
                                                       step = 0.001, width = 100
                                          ),
                                          numericInput(inputId = 'VvenC.sd_swine', label = 'VvenC SD', value = 1.332e-2,
                                                       step = 0.0001, width = 100
                                          )),
                                        splitLayout(
                                          numericInput(inputId = 'VartC.mean_swine', label = 'VartC mean', value = 0.016,
                                                       step = 0.001, width = 100
                                          ),
                                          numericInput(inputId = 'VartC.sd_swine', label = 'VartC SD', value = 4.68e-3,
                                                       step = 0.0001, width = 100
                                          )),
                                        splitLayout(
                                          numericInput(inputId = 'VrestC.mean_swine', label = 'VrestC mean', value = 0.322,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'VrestC.sd_swine', label = 'VrestC SD', value = 9.66e-2,
                                                       step = 0.01, width = 100
                                          ))), 
                       
                       conditionalPanel(condition = "input.tabs == 'Chemical parameters'&& input.animal == 'Market-age Swine'",
                                        splitLayout(
                                          numericInput(inputId = 'PL.mean_swine', label = 'PL mean', value = 10.520,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'PL.sd_swine', label = 'PL SD', value = 2.104,
                                                       step = 0.01, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'PK.mean_swine', label = 'PK mean', value = 4.000,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'PK.sd_swine', label = 'PK SD', value = 0.800,
                                                       step = 0.01, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'PM.mean_swine', label = 'PM mean', value = 0.500,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'PM.sd_swine', label = 'PM SD', value = 0.100,
                                                       step = 0.001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'PF.mean_swine', label = 'PF mean', value = 0.600,
                                                       step = 0.0001, width = 100
                                          ),
                                          numericInput(inputId = 'PF.sd_swine', label = 'PF SD', value = 0.120,
                                                       step = 0.0001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'Prest.mean_swine', label = 'Prest mean', value = 8.000,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'Prest.sd_swine', label = 'Prest SD', value = 1.600,
                                                       step = 0.001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'Kim.mean_swine', label = 'Kim mean', value = 1.000,
                                                       step = 0.001, width = 100
                                          ),
                                          numericInput(inputId = 'Kim.sd_swine', label = 'Kim SD', value = 0.300,
                                                       step = 0.0001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'Ksc.mean_swine', label = 'Ksc mean', value = 0.400,
                                                       step = 0.001, width = 100
                                          ),
                                          numericInput(inputId = 'Ksc.sd_swine', label = 'Ksc SD', value = 0.120,
                                                       step = 0.0001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'PB.mean_swine', label = 'PB mean', value = 0.950,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'PB.sd_swine', label = 'PB SD', value = 0.285,
                                                       step = 0.001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'KmC.mean_swine', label = 'KmC mean', value = 0.200,
                                                       step = 1e-5, width = 100
                                          ),
                                          numericInput(inputId = 'KmC.sd_swine', label = 'KmC SD', value = 4.0e-2,
                                                       step = 1e-5, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'KurineC.mean_swine', label = 'KurineC mean', value = 0.100,
                                                       step = 0.001, width = 100
                                          ),
                                          numericInput(inputId = 'KurineC.sd_swine', label = 'KurineC SD', value = 0.030,
                                                       step = 0.0001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'KehcC.mean_swine', label = 'KehcC mean', value = 0.150,
                                                       step = 0.001, width = 100
                                          ),
                                          numericInput(inputId = 'KehcC.sd_swine', label = 'KehcC SD', value = 0.045,
                                                       step = 0.0001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'KbileC.mean_swine', label = 'KbileC mean', value = 0.100,
                                                       step = 0.001, width = 100
                                          ),
                                          numericInput(inputId = 'KbileC.sd_swine', label = 'KbileC SD', value = 0.030,
                                                       step = 0.0001, width = 100
                                          ))
                                        ),
                       
                       conditionalPanel(condition = "input.tabs == 'Physiological parameters'&& input.animal == 'Beef Cattle'",
                                        splitLayout(
                                          numericInput(inputId = 'BW.mean_cattle', label = 'BW mean', value = 299.96, 
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'BW.sd_cattle', label = 'BW SD', value = 46.18, 
                                                       step = 0.01, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'QCC.mean_cattle', label = 'QCC mean', value = 5.97,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'QCC.sd_cattle', label = 'QCC SD', value = 1.99,
                                                       step = 0.01, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'QLC.mean_cattle', label = 'QLC mean', value = 0.405,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'QLC.sd_cattle', label = 'QLC SD', value = 0.1942,
                                                       step = 0.01, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'QKC.mean_cattle', label = 'QKC mean', value = 0.090,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'QKC.sd_cattle', label = 'QKC SD', value = 0.027,
                                                       step = 0.01, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'QMC.mean_cattle', label = 'QMC mean', value = 0.180,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'QMC.sd_cattle', label = 'QMC SD', value = 0.054,
                                                       step = 0.01, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'QFC.mean_cattle', label = 'QFC mean', value = 0.080,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'QFC.sd_cattle', label = 'QFC SD', value = 0.024,
                                                       step = 0.010, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'QrestC.mean_cattle', label = 'QrestC mean', value = 0.245,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'QrestC.sd_cattle', label = 'QrestC SD', value = 0.0736,
                                                       step = 0.001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'VLC.mean_cattle', label = 'VLC mean', value = 0.014,
                                                       step = 0.001, width = 100
                                          ),
                                          numericInput(inputId = 'VLC.sd_cattle', label = 'VLC SD', value = 0.00163,
                                                       step = 0.0001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'VKC.mean_cattle', label = 'VKC mean', value = 0.002,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'VKC.sd_cattle', label = 'VKC SD', value = 4.321e-4,
                                                       step = 0.00001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'VFC.mean_cattle', label = 'VFC mean', value = 0.150,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'VFC.sd_cattle', label = 'VFC SD', value = 4.5e-2,
                                                       step = 0.001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'VMC.mean_cattle', label = 'VMC mean', value = 0.270,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'VMC.sd_cattle', label = 'VMC SD', value = 8.1e-2,
                                                       step = 0.001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'VvenC.mean_cattle', label = 'VvenC mean', value = 0.030,
                                                       step = 0.001, width = 100
                                          ),
                                          numericInput(inputId = 'VvenC.sd_cattle', label = 'VvenC SD', value = 8.88e-3,
                                                       step = 0.0001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'VartC.mean_cattle', label = 'VartC mean', value = 0.010,
                                                       step = 0.001, width = 100
                                          ),
                                          numericInput(inputId = 'VartC.sd_cattle', label = 'VartC SD', value = 3.12e-3,
                                                       step = 0.0001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'VrestC.mean_cattle', label = 'VrestC mean', value = 0.524,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'VrestC.sd_cattle', label = 'VrestC SD', value = 0.1572,
                                                       step = 0.01, width = 100
                                          ))), 
                       
                       conditionalPanel(condition = "input.tabs == 'Chemical parameters'&& input.animal == 'Beef Cattle'",
                                        splitLayout(
                                          numericInput(inputId = 'PL.mean_cattle', label = 'PL mean', value = 10.520,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'PL.sd_cattle', label = 'PL SD', value = 2.104,
                                                       step = 0.01, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'PK.mean_cattle', label = 'PK mean', value = 4.000,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'PK.sd_cattle', label = 'PK SD', value = 0.800,
                                                       step = 0.01, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'PM.mean_cattle', label = 'PM mean', value = 0.500,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'PM.sd_cattle', label = 'PM SD', value = 0.100,
                                                       step = 0.001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'PF.mean_cattle', label = 'PF mean', value = 0.600,
                                                       step = 0.0001, width = 100
                                          ),
                                          numericInput(inputId = 'PF.sd_cattle', label = 'PF SD', value = 0.120,
                                                       step = 0.0001, width = 100
                                          )),

                                        splitLayout(
                                          numericInput(inputId = 'Prest.mean_cattle', label = 'Prest mean', value = 8.000,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'Prest.sd_cattle', label = 'Prest SD', value = 1.600,
                                                       step = 0.001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'Kim.mean_cattle', label = 'Kim mean', value = 0.500,
                                                       step = 0.001, width = 100
                                          ),
                                          numericInput(inputId = 'Kim.sd_cattle', label = 'Kim SD', value = 0.150,
                                                       step = 0.0001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'Ksc.mean_cattle', label = 'Ksc mean', value = 0.4,
                                                       step = 0.001, width = 100
                                          ),
                                          numericInput(inputId = 'Ksc.sd_cattle', label = 'Ksc SD', value = 0.120,
                                                       step = 0.0001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'PB.mean_cattle', label = 'PB mean', value = 0.950,
                                                       step = 0.01, width = 100
                                          ),
                                          numericInput(inputId = 'PB.sd_cattle', label = 'PB SD', value = 0.285,
                                                       step = 0.001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'KmC.mean_cattle', label = 'KmC mean', value = 0.200,
                                                       step = 1e-5, width = 100
                                          ),
                                          numericInput(inputId = 'KmC.sd_cattle', label = 'KmC SD', value = 4e-2,
                                                       step = 1e-5, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'KurineC.mean_cattle', label = 'KurineC mean', value = 0.100,
                                                       step = 0.001, width = 100
                                          ),
                                          numericInput(inputId = 'KurineC.sd_cattle', label = 'KurineC SD', value = 0.030,
                                                       step = 0.0001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'KehcC.mean_cattle', label = 'KehcC mean', value = 0.050,
                                                       step = 0.001, width = 100
                                          ),
                                          numericInput(inputId = 'KehcC.sd_cattle', label = 'KehcC SD', value = 0.015,
                                                       step = 0.0001, width = 100
                                          )),
                                        
                                        splitLayout(
                                          numericInput(inputId = 'KbileC.mean_cattle', label = 'KbileC mean', value = 0.500,
                                                       step = 0.001, width = 100
                                          ),
                                          numericInput(inputId = 'KbileC.sd_cattle', label = 'KbileC SD', value = 0.150,
                                                       step = 0.0001, width = 100
                                          )))
                     )
        )),
        
        mainPanel(
          tabItem(tabName = 'modelparameter',
                  fluidRow(
                    box(width = 6,downloadButton('downl','Download'),
                        title = 'Concentrations in liver', status = "primary", solidHeader = TRUE,
                        plotOutput(outputId = 'liver', height = 350)
                    ),
                    box(width = 6,downloadButton('downk','Download'),
                        title = 'Concentrations in kidney',status = "primary", solidHeader = TRUE,
                        plotOutput(outputId = 'kidney', height = 350)
                    ),
                    box(width = 6,downloadButton('downm','Download'),
                        title = 'Concentrations in muscle',status = "primary", solidHeader = TRUE,
                        plotOutput(outputId = 'muscle', height = 350)
                    ),
                    box(width = 6,downloadButton('downf','Download'),
                        title = 'Concentrations in fat',status = "primary", solidHeader = TRUE,
                        plotOutput(outputId = 'fat', height = 350)
                    )
                  )
          )
        )
      )
    ),
    
    tabItem(
      tabName = 'table',
      box(width = 8, status = "primary", solidHeader = TRUE, title="Concentrations in tissues", 
          downloadButton('downloadtable','Download'),
          tableOutput("table1")
      )
    ),
    tabItem(
      tabName = 'report',
      box(width = 8, status = "primary", solidHeader = TRUE, title="Output Report", 
          radioButtons('format', 'Document format', c('PDF', 'HTML', 'Word'),
                       inline = TRUE),
          downloadButton('downloadreport', "Download Report")
      )
    ),
    tabItem(
      tabName = 'modelstructure',
      fluidRow(
        box(width = 4,status = "primary",title= "Model Structure", 
            solidHeader = TRUE, tags$img(src = 'modelstructure.png', width = "400"),
            tags$p("
                   Fig. 1. A schematic diagram of the physiologically based pharmacokinetic (PBPK)
                   model for Flunixin in swine and cattle. Three different administration routes
                   including intravascular (IV), intramuscular (IM) and subcutaneous (SC) injections are presented in the
                   model. 
                   ")
            )
            )
        ),
    tabItem(
      tabName = 'about',
      fluidRow(
        box(width = 10,status = "primary",title= "About", 
            solidHeader = TRUE, tags$img(src = 'farad.png',height = "50px"),tags$img(src = 'iccm.png',height = "100px"),
            tags$p("
                   The Extralabel Withdrawal Interval Simulator is based on a PBPK model for flunixin
                   in swine and cattle. The withdrawal interval calculation is for beef cattle and market-age swine based on NADA: 101-479
                   "), 
            tags$p("
                   More details for the model, please refer to the webpage of Institute of Computational
                   Computational Comparative Medicine (http://iccm.k-state.edu/models/pbpk/index.html). 
                   "), 
            tags$p("
                   The project is supported by the United States Department of Agriculture National Institute of Food and Agriculture for the Food Animal Residue
                   Avoidance Databank (FARAD) Program (http://www.farad.org/).
                   "), tags$p("Contact Info:",tags$br(),"Zhoumeng Lin, BMed, PhD, DABT",tags$br(),"zhoumeng@ksu.edu",tags$br(),
                              "(785) 532-4087")
            )
        
            )
        ),
    tabItem(
      tabName = 'tutorial',
      tabPanel("tutorial", 
               tags$iframe(style="height:800px; width:100%; scrolling=yes", 
                           src="https://www.dropbox.com/s/t26l2ze83lqzed5/tutorial2.pdf?raw=1"))
    ),
    tabItem(
      tabName = 'code',
      box( width = NULL, status = "primary", solidHeader = TRUE, title="Flunixin in Cattle.R",
           downloadButton('downloadcode', 'Download'),
           br(),br(),
           pre(includeText("Flunixin_Cattle.R"))
      )
    )
    )
    ) 

ui <- dashboardPage(
  skin = 'purple',
  dashboardHeader(
    title = 'Extralabel Withdrawal Interval Simulator', titleWidth = 500
  ),
  sidebar,
  body
)
# { 
#   Monte Carlo Analysis based on Penicillin PBPK model for Cattle (flow-limited model, linear metabolism equation, plasma protein binding)
#   The PBPK model code is based on the Oxytetracycline.mmd from Zhoumeng Lin
# }
server <- function(input, output) {
  TOL = isolate(input$tolerance)
  TOL_swine = isolate(input$tolerance_swine)
  animal = isolate(input$animal)
  Drug = isolate(input$drug)
  Dose = isolate(input$doselevel)
  Tdoses = isolate(input$numdose)  
  tinterval = isolate(input$tinterval)
  numberofsimulation = isolate(input$N)
  route = isolate(input$route)
  route_swine = isolate(input$route_swine)
  observeEvent(input$reset,{reset("therapeutic")})
  observeEvent(input$reset1,{reset("all_parameters")})
  
  pbpk.code <- '
  $PARAM @annotated
  QCC : 5.970 : L/h/kg, Cardiac Output (1960 Doyle)
  QLCa : 0.405	: Fraction of blood flow to the liver (1996 Lescoat, 1960 Dlyle)
  QKCa : 0.090	: Fraction of blood flow to the kidneys (2016 Lin)
  QMCa : 0.180	: Fraction of blood flow to the muscle (2016 Lin)
  QFCa : 0.080	: Fraction of blood flow to the fat (2016 Lin)
  QrestCa : 0.245 : Fraction of blood flow to the rest of body (total sum equals to 1) (1-QLC-QKC-QFC-QMC)
  QrestC1a : 0.505 : Fraction of blood flow to the rest of body for 5-OH FLU (total sum equals to 1) (1-QLC-QKC)
  
  BW : 299.96 : Body Weight (kg) (2011 Mirzaei)
  VLCa : 0.014 : Fractional liver tissue (1933 Swett)
  VKCa : 0.002 : Fractional kidney tissue (1933 Swett)
  VFCa : 0.150 : Fractional fat tissue (2016 Lin, 2014 Leavens)
  VMCa : 0.270 : Fractional muscle tissue (2016 Lin, 2014 Leavens)
  VvenCa : 0.030 : Venous blood volume, fraction of blood volume (2016 Lin# 2008 Leavens)
  VartCa : 0.010 : Arterial blood volume, fraction of blood volume (2016 Lin# 2008 Leavens)
  VbloodCa : 0.040 : Total blood volume (total sum of venous and arterial blood)
  VrestCa : 0.524 : Fractional rest of body (total sum equals to 1) (1-VLC-VKC-VFC-VMC-VbloodC)
  VrestC1a : 0.944 : Fractional rest of body for 5-OH FLU (total sum equals to 1) (1-VLC-VKC-VbloodC)
  
  MW : 296.24 : mg/mmol Molecular weight of flunixin
  MW1 : 312.24 : mg/mmol Molecular weight of 5-OH FLU
  
  PL : 10.52 : Liver/plasma PC 
  PK : 4.00 : Kidney/plasma PC
  PM : 0.50 : Muscle/plasma PC
  PF : 0.60 : Fat/plasma PC
  Prest : 10.00 : Rest of body/plasma PC
  
  PL1 : 9.26 : Liver/plasma PC of 5-OH FLU 
  PK1 : 13.49 : Kidney/plasma PC of 5-OH FLU 
  Prest1 : 8.00 : Rest of body/plasma PC of 5-OH FLU 
  
  Kint : 1.00 : /h, intestinal transit rate constant
  Kfeces : 0.01 : /h, fecal elimination rate constant
  
  Kim : 0.50 : 1/h, IM absorption rate constant 
  Ksc : 0.40 :  1/h, SC absorption rate constant
  
  PB : 0.95 : Percentage of drug bound to plasma proteins
  PB1 : 0.99 : Percentage of drug bound to plasma proteins for 5-OH FLU
  
  KmC : 0.20 : metabolic rate constant
  KehcC : 0.05 : rate constant for the enterohepatic circulation
  KurineC : 0.10 : L/h/kg
  KurineC1 : 0.20 : L/h/kg
  KbileC : 0.50 : L/h/kg
  KbileC1 : 0.10 : L/h/kg
  
  PDOSEiv : 0 : mg/kg
  PDOSEim : 0 : mg/kg
  PDOSEsc : 0 : mg/kg
  
  $MAIN
  double sumQ = QLCa + QKCa + QMCa + QFCa + QrestCa; // sum up cardiac output fraction
  double QLC = QLCa/sumQ; // adjusted blood flow rate fraction to liver
  double QKC = QKCa/sumQ; // adjusted blood flow rate fraction to kidney
  double QMC = QMCa/sumQ; // adjusted blood flow rate fraction to muscle
  double QFC = QFCa/sumQ; // adjusted blood flow rate fraction to fat
  double QrestC = QrestCa/sumQ; // adjusted blood flow rate fraction to rest of body
  double QrestC1 = 1-QLC-QKC; // adjusted blood flow rate fraction to rest of body for 5-OH FLU
  
  double sumV = VLCa + VKCa + VMCa + VFCa + VbloodCa + VrestCa; //sum up the tissue volumes
  double VLC = VLCa/sumV; //adjusted fraction of tissue volume of liver
  double VKC = VKCa/sumV; //adjusted fraction of tissue volume of kidney
  double VMC = VMCa/sumV; //adjusted fraction of tissue volume of muscle
  double VFC = VFCa/sumV; //adjusted fraction of tissue volume of fat
  double VbloodC = VbloodCa/sumV;
  double VrestC = VrestCa/sumV; //adjusted fraction of tissue volume of rest of body
  double VrestC1 = 1-VbloodC-VLC-VKC; // adjusted fraction of tissue volume of rest of body for 5-OH FLU
  
  double Free = 1-PB; //Percentage of drug not bound to plasma protein
  double Free1 = 1-PB1; 
  
  double QC = QCC*BW; //Cardiac output
  double QL = QLC*QC; //Liver
  double QK = QKC*QC; //Kidney
  double QF = QFC*QC; //Fat
  double QM = QMC*QC; //Muscle
  double QR = QrestC*QC; //Rest of body
  double QR1 = QrestC1*QC; //Rest of body for 5-OH FLU
  
  double VL = VLC*BW; //Liver
  double VK = VKC*BW; //Kidney
  double VF = VFC*BW; //Fat
  double VM = VMC*BW; //Muscle
  double VR = VrestC*BW; //Rest of body
  double VR1 = VrestC1*BW; //Rest of body for 5-OH FLU
  double Vblood = VbloodC*BW; //Blood
  
  double Kmet = KmC*BW;
  double Kehc = KehcC*BW;
  double Kurine = KurineC*BW;
  double Kurine1 = KurineC1*BW;
  double Kbile = KbileC*BW;
  double Kbile1 = KbileC1*BW;
  
  $CMT Absorbim Amtsiteim Absorbsc Amtsitesc AA AUCCV AA1 AUCCV1 AL AUCCL AL1 AUCCL1 Aehc 
  Amet Abile Abile1 Acolon AI Afeces Aurine AK AUCCK Aurine1 AK1 AUCCK1 AM AUCCM AF AUCCF AR 
  AUCCR AR1 AUCCR1 
  
  $ODE
  
  // Dosing, IM, intramuscular
  //double IMR = DOSEim/(MW*Timeim);
  //double Fim = IF MOD(time, tinterval) <= Timeim then 1 else 0;
  //double Rdoseim = IMR*Fim*Fmultiple;
  //double Rim = Kim*Amtsiteim;
  //double Rsiteim =  RdoseIM - Rim;
  //double Rim = Kim*Amtsiteim;
  //dxdt_Absorbim = Rim;
  //dxdt_Amtsiteim = Rsiteim;
  double Rim = Kim*Amtsiteim;
  double Rsiteim = - Rim;
  dxdt_Absorbim = Rim;
  dxdt_Amtsiteim = Rsiteim;
  
  // Dosing, SC, subcutaneous
  double Rsc = Ksc*Amtsitesc;
  double Rsitesc = - Rsc;
  dxdt_Absorbsc = Rsc;
  dxdt_Amtsitesc = Rsitesc;
  
  // Concentrations in the tissues and in the capillary blood of the tissues
  
  double CA = AA/Vblood; // CAfree concentration of unbound drug in the arterial blood (mg/L)
  double CAfree = CA*Free;
  
  double CL = AL/VL; // Concentration of parent drug in the tissue of liver
  double CVL = CL/PL; // Concentration of parent drug in the capillary blood of liver
  
  double CK = AK/VK; // Concentration of parent drug in the tissue of kidney
  double CVK = CK/PK; // Concentration of parent drug in the capillary blood of kidney 
  
  double CM = AM/VM; // Concentration of parent drug in the tissue of muscle
  double CVM = CM/PM; // Concentration of parent drug in the capillary blood of muscle 
  
  double CF = AF/VF; // Concentration of parent drug in the tissue of fat
  double CVF = CF/PF; // Concentration of parent drug in the capillary blood of  fat
  
  double CR = AR/VR; // Crest drug concentration in the rest of the body (mg/L)
  double CVR = CR/Prest; // Concentration of parent drug in the capillary blood of the rest of body
  
  double CA1 = AA1/Vblood; // CAfree concentration of unbound drug in the arterial blood (mg/L)
  double CAfree1 = CA1*Free1;
  
  double CL1 = AL1/VL; // Concentration of parent drug in the tissue of liver
  double CVL1 = CL1/PL1; // Concentration of parent drug in the capillary blood of liver
  
  double CK1 = AK1/VK; // Concentration of parent drug in the tissue of kidney
  double CVK1 = CK1/PK1; // Concentration of parent drug in the capillary blood of kidney 
  
  double CR1 = AR1/VR1; // Crest drug concentration in the rest of the body (mg/L)
  double CVR1 = CR1/Prest1; // Concentration of parent drug in the capillary blood of the rest of body
  
  // {Penicillin distribution in each compartment}
  // Penicillin in venous blood compartment
  double CV = (QL*CVL+QK*CVK+QF*CVF+QM*CVM+QR*CVR+Rim+Rsc)/QC; // CV the drug concentration in the venous blood (mmol/L)
  double RA = QC*(CV-CAfree);
  dxdt_AA = RA;
  double CVppm = CV*MW;
  dxdt_AUCCV = CV; // mg/L
  
  double CV1 = (QL*CVL1+QK*CVK1+QR1*CVR1)/QC; // CV1 the 5-OH FLU concentration in the venous blood (mmol/L)
  double RA1 = QC*(CV1-CAfree1);
  dxdt_AA1 = RA1;
  double CV1ppm = CV1*MW1;
  dxdt_AUCCV1 = CV1; // mg/L
  
  // FLU and 5-OH FLU in liver compartment, flow-limited model
  double Rmet1 = Kmet*CL*VL; // Rmet the metabolic rate in liver (mg/h)
  dxdt_Amet = Rmet1; // Amet the amount of drug metabolized in liver (mg)
  double Rehc = Kehc*AI;
  dxdt_Aehc = Rehc;
  double Rbile = Kbile*CVL;
  dxdt_Abile = Rbile;
  double RL = QL*(CAfree-CVL)-Rmet1-Rbile+Rehc; // RL the changing rate of the amount of drug in liver (mg/h)
  dxdt_AL = RL; // AL amount of drug in liver (mg) 
  double CLppm = CL*MW; // mg/L
  dxdt_AUCCL = CL; // AUCCL area under the curve of drug concentration in liver (mg*h/L)
  
  double Rbile1 = Kbile1*CVL1;
  dxdt_Abile1 = Rbile1;
  double RL1 = QL*(CAfree1-CVL1)+Rmet1-Rbile1; // RL1 the changing rate of the amount of drug in liver (mg/h)
  dxdt_AL1 = RL1; // AL1 amount of drug in liver (mg) 
  double CL1ppm = CL1*MW1; // mg/L
  dxdt_AUCCL1 = CL1; // AUCCL1 area under the curve of drug concentration in liver (mg*h/L)
  
  // Metabolism of FLU in liver compartment
  
  // Elimination of FLU and 5-OH FLU in liver compartment
  
  
  // GI compartments and Enterohepatic Circulation
  double Rcolon = Kint*AI;
  dxdt_Acolon = Rcolon;
  double RAI = Rbile + Rbile1-Kint*AI-Kehc*AI;
  dxdt_AI = RAI;
  double Rfeces = Kfeces*Acolon;
  dxdt_Afeces = Rfeces;
  
  // Penicillin in kidney compartment, flow-limited model
  double Rurine = Kurine*CVK;
  dxdt_Aurine = Rurine;
  double RK = QK*(CAfree-CVK)-Rurine; // RK the changing rate of the amount of drug in kidney (mg/h)
  dxdt_AK = RK; // AK amount of drug in kidney (mg)
  dxdt_AUCCK = CK; // AUCCK AUC of drug concentration in kidney (mg*h/L)
  double CKppm = CK*MW; // mg/L
  
  double Rurine1 = Kurine1*CVK1;
  dxdt_Aurine1 = Rurine1;
  double RK1 = QK*(CAfree1-CVK1)-Rurine1; // RK1 the changing rate of the amount of drug in kidney (mg/h)
  dxdt_AK1 = RK1; // AK amount of drug in kidney (mg)
  dxdt_AUCCK1 = CK1; // AUCCK AUC of drug concentration in kidney (mg*h/L)
  double CK1ppm = CK1*MW1; // mg/L
  
  // Penicillin in muscle compartment, flow-limited model
  double RM = QM*(CAfree-CVM); //  RM the changing rate of the amount of drug in muscle (mg/h) 
  dxdt_AM = RM; // AM amount of the drug in muscle (mg)
  dxdt_AUCCM = CM;
  double CMppm = CM*MW;
  
  // Penicillin in fat compartment, flow-limited model
  double RF = QF*(CAfree-CVF); // RF the changing rate of the amount of drug in fat (mg/h)
  dxdt_AF = RF; // AF amount of the drug in fat (mg)
  dxdt_AUCCF = CF; // AUCCF AUC of drug concentration in fat (mg*h/L)
  double CFppm = CF*MW;
  
  // Penicillin in the compartment of rest of body, flow-limited model
  double RR = QR*(CAfree-CVR); // Rrest the changing rate of the amount of drug in the rest of the body (mg/h)
  dxdt_AR = RR; // Arest amount of the drug in the rest of the body (mg)
  dxdt_AUCCR = CR; // AUCCrest AUC of drug concentration in the rest of the body (mg*h/L)
  double CRppm = CR*MW;
  
  double RR1 = QR1*(CAfree1-CVR1); // Rrest the changing rate of the amount of drug in the rest of the body (mg/h)
  dxdt_AR1 = RR1; // Arest amount of the drug in the rest of the body (mg)
  dxdt_AUCCR1 = CR1; // AUCCrest AUC of drug concentration in the rest of the body (mg*h/L)
  double CR1ppm = CR1*MW1;
  
  // {Mass balance equations}
  double Qbal = QC-QM-QR-QF-QK-QL;
  double Tmass = AA+AM+AR+AF+AK+AL+Aurine+Amet+Abile;
  double Input = Absorbim+Aehc;
  double Bal = Input-Tmass;
  
  double Qbal1 = QC-QL-QK-QR1;
  double Tmass1 = AA1+AR1+AK1+AL1+Aurine1+Abile1;
  double Input1 = Amet;
  double Bal1 = Input1-Tmass1;
  
  $TABLE
  capture Venous = CVppm;
  capture Liver = CLppm;
  capture Kidney = CKppm;
  capture Muscle= CMppm;
  capture Fat = CFppm;
  capture Venous1 = CV1ppm;
  capture Liver1 = CL1ppm;
  capture Kidney1 = CK1ppm;
  '
  
  ## Load Model
  mod <- mcode_cache("pbpk", pbpk.code)
  
  ## Set Up Simulation Subjects
  
  r1 <- reactive({
    if (input$animal == "Beef Cattle") 
    {TOL = isolate(input$tolerance)
    end_time = isolate(input$simu_time)}
    if (input$animal == "Market-age Swine") 
    {TOL = isolate(input$tolerance_swine)
    end_time = isolate(input$simu_time_swine)}
    
    N = input$N # 1000, Number of iterations in the Monte Carlo simulation

    # Dosing, repeated doses
    input$action | input$action1
    tinterval = isolate(input$tinterval)			# Varied dependent on the exposure paradigm (h)
    TDoses = isolate(input$numdose) 			# times for multiple oral gavage
    #{Parameters for Various Exposure Scenarios}
    
    PDOSEiv = isolate(input$doselevel)
    PDOSEsc = isolate(input$doselevel)	# (mg/kg)
    PDOSEim = isolate(input$doselevel) 	# (mg/kg)
    
    if (input$animal == "Beef Cattle") {
      BW.mean = input$BW.mean_cattle
      BW.sd = input$BW.sd_cattle
      QCC.mean = input$QCC.mean_cattle
      QCC.sd = input$QCC.sd_cattle
      QLC.mean = input$QLC.mean_cattle
      QLC.sd = input$QLC.sd_cattle
      QKC.mean = input$QKC.mean_cattle
      QKC.sd = input$QKC.sd_cattle
      QMC.mean = input$QMC.mean_cattle
      QMC.sd = input$QMC.sd_cattle
      QFC.mean = input$QFC.mean_cattle
      QFC.sd = input$QFC.sd_cattle
      QrestC.mean = input$QrestC.mean_cattle
      QrestC.sd = input$QrestC.sd_cattle
      QrestC1.mean = 0.505
      QrestC1.sd = 0.1515
      VLC.mean = input$VLC.mean_cattle
      VLC.sd = input$VLC.sd_cattle
      VKC.mean = input$VKC.mean_cattle
      VKC.sd = input$VKC.sd_cattle
      VFC.mean = input$VFC.mean_cattle
      VFC.sd = input$VFC.sd_cattle
      VMC.mean = input$VMC.mean_cattle
      VMC.sd = input$VMC.sd_cattle
      VvenC.mean = input$VvenC.mean_cattle
      VvenC.sd = input$VvenC.sd_cattle
      VartC.mean = input$VartC.mean_cattle
      VartC.sd = input$VartC.sd_cattle
      VrestC.mean = input$VrestC.mean_cattle
      VrestC.sd = input$VrestC.sd_cattle
      VrestC1.mean = 0.9440
      VrestC1.sd = 0.2832
      PL.mean = input$PL.mean_cattle
      PL.sd = input$PL.sd_cattle
      PL1.mean = 9.260
      PL1.sd = 1.852
      PK.mean = input$PK.mean_cattle
      PK.sd = input$PK.sd_cattle
      PK1.mean = 4.000
      PK1.sd = 0.800
      PM.mean = input$PM.mean_cattle
      PM.sd = input$PM.sd_cattle
      PF.mean = input$PF.mean_cattle
      PF.sd = input$PF.sd_cattle
      Prest.mean = input$Prest.mean_cattle
      Prest.sd = input$Prest.sd_cattle
      Prest1.mean = 5.000
      Prest1.sd = 1.000
      Kim.mean = input$Kim.mean_cattle
      Kim.sd = input$Kim.sd_cattle
      Ksc.mean = input$Ksc.mean_cattle
      Ksc.sd = input$Ksc.sd_cattle
      PB.mean = input$PB.mean_cattle
      PB.sd = input$PB.sd_cattle
      PB1.mean = 0.990
      PB1.sd = 0.297
      KmC.mean = input$KmC.mean_cattle
      KmC.sd = input$KmC.sd_cattle
      KurineC.mean = input$KurineC.mean_cattle
      KurineC.sd = input$KurineC.sd_cattle
      KurineC1.mean = 0.200
      KurineC1.sd = 0.06
      KehcC.mean = input$KehcC.mean_cattle
      KehcC.sd = input$KehcC.sd_cattle
      KbileC.mean = input$KbileC.mean_cattle
      KbileC.sd = input$KbileC.sd_cattle
      KbileC1.mean = 0.100
      KbileC1.sd = 0.030
    }
    
    if (input$animal == "Market-age Swine") {
      BW.mean = input$BW.mean_swine
      BW.sd = input$BW.sd_swine
      QCC.mean = input$QCC.mean_swine
      QCC.sd = input$QCC.sd_swine
      QLC.mean = input$QLC.mean_swine
      QLC.sd = input$QLC.sd_swine
      QKC.mean = input$QKC.mean_swine
      QKC.sd = input$QKC.sd_swine
      QMC.mean = input$QMC.mean_swine
      QMC.sd = input$QMC.sd_swine
      QFC.mean = input$QFC.mean_swine
      QFC.sd = input$QFC.sd_swine
      QrestC.mean = input$QrestC.mean_swine
      QrestC.sd = input$QrestC.sd_swine
      QrestC1.mean = 0.611
      QrestC1.sd = 0.1833
      VLC.mean = input$VLC.mean_swine
      VLC.sd = input$VLC.sd_swine
      VKC.mean = input$VKC.mean_swine
      VKC.sd = input$VKC.sd_swine
      VFC.mean = input$VFC.mean_swine
      VFC.sd = input$VFC.sd_swine
      VMC.mean = input$VMC.mean_swine
      VMC.sd = input$VMC.sd_swine
      VvenC.mean = input$VvenC.mean_swine
      VvenC.sd = input$VvenC.sd_swine
      VartC.mean = input$VartC.mean_swine
      VartC.sd = input$VartC.sd_swine
      VrestC.mean = input$VrestC.mean_swine
      VrestC.sd = input$VrestC.sd_swine
      VrestC1.mean = 0.912
      VrestC1.sd = 0.2736
      PL.mean = input$PL.mean_swine
      PL.sd = input$PL.sd_swine
      PL1.mean = 9.260
      PL1.sd = 1.852
      PK.mean = input$PK.mean_swine
      PK.sd = input$PK.sd_swine
      PK1.mean = 4.000
      PK1.sd = 0.800
      PM.mean = input$PM.mean_swine
      PM.sd = input$PM.sd_swine
      PF.mean = input$PF.mean_swine
      PF.sd = input$PF.sd_swine
      Prest.mean = input$Prest.mean_swine
      Prest.sd = input$Prest.sd_swine
      Prest1.mean = 5.000
      Prest1.sd = 1.000
      Kim.mean = input$Kim.mean_swine
      Kim.sd = input$Kim.sd_swine
      Ksc.mean = input$Ksc.mean_swine
      Ksc.sd = input$Ksc.sd_swine
      PB.mean = input$PB.mean_swine
      PB.sd = input$PB.sd_swine
      PB1.mean = 0.990
      PB1.sd = 0.297
      KmC.mean = input$KmC.mean_swine
      KmC.sd = input$KmC.sd_swine
      KurineC.mean = input$KurineC.mean_swine
      KurineC.sd = input$KurineC.sd_swine
      KurineC1.mean = 0.100
      KurineC1.sd = 0.030
      KehcC.mean = input$KehcC.mean_swine
      KehcC.sd = input$KehcC.sd_swine
      KbileC.mean = input$KbileC.mean_swine
      KbileC.sd = input$KbileC.sd_swine
      KbileC1.mean = 0.100
      KbileC1.sd = 0.030
    }
    
    sd.log.PL <-
      sqrt(log(1 + PL.sd ^ 2 / PL.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.PL <-
      log(PL.mean) - 0.5 * sd.log.PL ^ 2 # mean of lognormal distribution
    sd.log.PL1 <-
      sqrt(log(1 + PL1.sd ^ 2 / PL1.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.PL1 <-
      log(PL1.mean) - 0.5 * sd.log.PL1 ^ 2 # mean of lognormal distribution
    sd.log.PK <-
      sqrt(log(1 + PK.sd ^ 2 / PK.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.PK <-
      log(PK.mean) - 0.5 * sd.log.PK ^ 2 # mean of lognormal distribution
    sd.log.PK1 <-
      sqrt(log(1 + PK1.sd ^ 2 / PK1.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.PK1 <-
      log(PK1.mean) - 0.5 * sd.log.PK1 ^ 2 # mean of lognormal distribution    
    sd.log.PM <-
      sqrt(log(1 + PM.sd ^ 2 / PM.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.PM <-
      log(PM.mean) - 0.5 * sd.log.PM ^ 2 # mean of lognormal distribution
    sd.log.PF <-
      sqrt(log(1 + PF.sd ^ 2 / PF.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.PF <-
      log(PF.mean) - 0.5 * sd.log.PF ^ 2 # mean of lognormal distribution
    sd.log.Prest <-
      sqrt(log(1 + Prest.sd ^ 2 / Prest.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.Prest <-
      log(Prest.mean) - 0.5 * sd.log.Prest ^ 2 # mean of lognormal distribution
    sd.log.Prest1 <-
      sqrt(log(1 + Prest1.sd ^ 2 / Prest1.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.Prest1 <-
      log(Prest1.mean) - 0.5 * sd.log.Prest1 ^ 2 # mean of lognormal distribution
    sd.log.Kim <-
      sqrt(log(1 + Kim.sd ^ 2 / Kim.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.Kim <-
      log(Kim.mean) - 0.5 * sd.log.Kim ^ 2 # mean of lognormal distribution
    sd.log.Ksc <-
      sqrt(log(1 + Ksc.sd ^ 2 / Ksc.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.Ksc <-
      log(Ksc.mean) - 0.5 * sd.log.Ksc ^ 2 # mean of lognormal distribution
    sd.log.PB <-
      sqrt(log(1 + PB.sd ^ 2 / PB.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.PB <-
      log(PB.mean) - 0.5 * sd.log.PB ^ 2 # mean of lognormal distribution
    sd.log.PB1 <-
      sqrt(log(1 + PB1.sd ^ 2 / PB1.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.PB1 <-
      log(PB1.mean) - 0.5 * sd.log.PB1 ^ 2 # mean of lognormal distribution    
    sd.log.KmC <-
      sqrt(log(1 + KmC.sd ^ 2 / KmC.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.KmC <-
      log(KmC.mean) - 0.5 * sd.log.KmC ^ 2 # mean of lognormal distribution
    sd.log.KurineC <-
      sqrt(log(1 + KurineC.sd ^ 2 / KurineC.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.KurineC <-
      log(KurineC.mean) - 0.5 * sd.log.KurineC ^ 2 # mean of lognormal distribution
    sd.log.KurineC1 <-
      sqrt(log(1 + KurineC1.sd ^ 2 / KurineC1.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.KurineC1 <-
      log(KurineC1.mean) - 0.5 * sd.log.KurineC1 ^ 2 # mean of lognormal distribution
    sd.log.KehcC <-
      sqrt(log(1 + KehcC.sd ^ 2 / KehcC.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.KehcC <-
      log(KehcC.mean) - 0.5 * sd.log.KehcC ^ 2 # mean of lognormal distribution
    sd.log.KbileC <-
      sqrt(log(1 + KbileC.sd ^ 2 / KbileC.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.KbileC <-
      log(KbileC.mean) - 0.5 * sd.log.KbileC ^ 2 # mean of lognormal distribution
    sd.log.KbileC1 <-
      sqrt(log(1 + KbileC1.sd ^ 2 / KbileC1.mean ^ 2)) # standard deviation of lognormal distribution
    m.log.KbileC1 <-
      log(KbileC1.mean) - 0.5 * sd.log.KbileC1 ^ 2 # mean of lognormal distribution    
    a = 10 
    b = 4
      set.seed(324)#+i) # set random seed so that the simulation result is reproducible, because randomly generated data is same if you set same random seed.
      ##{Physiological Parameters}
      # Blood Flow Rates
      idata <- 
        data_frame(ID=1:N) %>% 
        
        mutate(
          QCC = rtruncnorm(
            n = N,
            a = qnorm(0.025, mean = QCC.mean, sd = QCC.sd),
            b = qnorm(0.975, mean = QCC.mean, sd = QCC.sd),
            mean = QCC.mean,
            sd = QCC.sd
          ),  # Cardiac output index (L/h/kg)
          # Fracion of blood flow to organs (unitless) 
          QLCa = rtruncnorm(
            n = N,
            a = qnorm(0.025, mean = QLC.mean, sd = QLC.sd),
            b = qnorm(0.975, mean = QLC.mean, sd = QLC.sd),
            mean = QLC.mean,
            sd = QLC.sd
          ),
          # Fraction of blood flow to the kidneys (2016 Lin)
          QKCa = rtruncnorm(
            n = N,
            a = qnorm(0.025, mean = QKC.mean, sd =  QKC.sd),
            b = qnorm(0.975, mean = QKC.mean, sd =  QKC.sd),
            mean = QKC.mean,
            sd =  QKC.sd
          ),
          #QMC = 0.180			# Fraction of blood flow to the muscle (2016 Lin)
          QMCa = rtruncnorm(
            n = N,
            a = qnorm(0.025, mean = QMC.mean, sd =  QMC.sd),
            b = qnorm(0.975, mean = QMC.mean, sd =  QMC.sd),
            mean = QMC.mean,
            sd =  QMC.sd
          ),
          # Fraction of blood flow to the fat (2016 Lin)
          QFCa = rtruncnorm(
            n = N,
            a = qnorm(0.025, mean = QFC.mean, sd =  QFC.sd),
            b = qnorm(0.975, mean = QFC.mean, sd =  QFC.sd),
            mean = QFC.mean,
            sd =  QFC.sd
          ),
          # Fraction of blood flow to the rest of body (total sum equals to 1)
          QrestCa = rtruncnorm(
            n = N,
            a = qnorm(0.025, mean = QrestC.mean, sd = QrestC.sd),
            b = qnorm(0.975, mean = QrestC.mean, sd = QrestC.sd),
            mean = QrestC.mean,
            sd = QrestC.sd
          ),
          QrestC1a = rtruncnorm(
            n = N,
            a = qnorm(0.025, mean = QrestC1.mean, sd = QrestC1.sd),
            b = qnorm(0.975, mean = QrestC1.mean, sd = QrestC1.sd),
            mean = QrestC1.mean,
            sd = QrestC1.sd
          ),
          BW = rtruncnorm(n = N, 
                          a = qnorm(0.025, mean = BW.mean, sd = BW.sd), 
                          b = qnorm(0.975, mean = BW.mean, sd = BW.sd), 
                          mean = BW.mean, sd = BW.sd), 
          # Fractional organ tissue volumes (unitless)
          # Fractional liver tissue (1933 Swett)
          VLCa = rtruncnorm(
            n = N,
            a = qnorm(0.025, mean = VLC.mean, sd =  VLC.sd),
            b = qnorm(0.975, mean = VLC.mean, sd =  VLC.sd) ,
            mean = VLC.mean,
            sd =  VLC.sd
          ),
          # Fractional kidney tissue (1933 Swett)
          VKCa = rtruncnorm(
            n = N,
            a = qnorm(0.025, mean = VKC.mean, sd =  VKC.sd),
            b = qnorm(0.975, mean = VKC.mean, sd =  VKC.sd),
            mean = VKC.mean,
            sd =  VKC.sd
          ),
          # Fractional fat tissue (2016 Lin, 2014 Leavens)
          VFCa = rtruncnorm(
            n = N,
            a = qnorm(0.025, mean = VFC.mean, sd =  VFC.sd),
            b = qnorm(0.975, mean = VFC.mean, sd =  VFC.sd),
            mean = VFC.mean,
            sd =  VFC.sd
          ),
          # Fractional muscle tissue (2016 Lin, 2014 Leavens)
          VMCa = rtruncnorm(
            n = N,
            a = qnorm(0.025, mean = VMC.mean, sd =  VMC.sd),
            b = qnorm(0.975, mean = VMC.mean, sd =  VMC.sd),
            mean = VMC.mean,
            sd =  VMC.sd
          ),
          # Venous blood volume, fraction of blood volume (2016 Lin# 2008 Leavens)
          VvenCa = rtruncnorm(
            n = N,
            a = qnorm(0.025, mean = VvenC.mean, sd =  VvenC.sd),
            b = qnorm(0.975, mean = VvenC.mean, sd =  VvenC.sd),
            mean = VvenC.mean,
            sd =  VvenC.sd
          ),
          # Arterial blood volume, fraction of blood volume (2016 Lin# 2008 Leavens)
          VartCa = rtruncnorm(
            n = N,
            a = qnorm(0.025, mean = VartC.mean, sd =  VartC.sd),
            b = qnorm(0.975, mean = VartC.mean, sd =  VartC.sd),
            mean = VartC.mean,
            sd =  VartC.sd
          ),
          # Fractional rest of body (total sum equals to 1)
          VrestCa = rtruncnorm(
            n = N,
            a = qnorm(0.025, mean = VrestC.mean, sd =  VrestC.sd),
            b = qnorm(0.975, mean = VrestC.mean, sd =  VrestC.sd),
            mean = VrestC.mean,
            sd =  VrestC.sd
          ),
          VrestC1a = rtruncnorm(
            n = N,
            a = qnorm(0.025, mean = VrestC1.mean, sd =  VrestC1.sd),
            b = qnorm(0.975, mean = VrestC1.mean, sd =  VrestC1.sd),
            mean = VrestC1.mean,
            sd =  VrestC1.sd
          ),
          PL = rlnormTrunc(
            N,
            meanlog = m.log.PL,
            sdlog = sd.log.PL,
            min = qlnorm(0.025, meanlog = m.log.PL, sdlog = sd.log.PL),
            max = qlnorm(0.975, meanlog = m.log.PL, sdlog = sd.log.PL)
          ),
          PL1 = rlnormTrunc(
            N,
            meanlog = m.log.PL1,
            sdlog = sd.log.PL1,
            min = qlnorm(0.025, meanlog = m.log.PL1, sdlog = sd.log.PL1),
            max = qlnorm(0.975, meanlog = m.log.PL1, sdlog = sd.log.PL1)
          ),
          PK = rlnormTrunc(
            N,
            meanlog = m.log.PK,
            sdlog = sd.log.PK,
            min = qlnorm(0.025, meanlog = m.log.PK, sdlog = sd.log.PK),
            max = qlnorm(0.975, meanlog = m.log.PK, sdlog = sd.log.PK)
          ),
          PK1 = rlnormTrunc(
            N,
            meanlog = m.log.PK1,
            sdlog = sd.log.PK1,
            min = qlnorm(0.025, meanlog = m.log.PK1, sdlog = sd.log.PK1),
            max = qlnorm(0.975, meanlog = m.log.PK1, sdlog = sd.log.PK1)
          ),
          PM = rlnormTrunc(
            N,
            meanlog = m.log.PM,
            sdlog = sd.log.PM,
            min = qlnorm(0.025, meanlog = m.log.PM, sdlog = sd.log.PM),
            max = qlnorm(0.975, meanlog = m.log.PM, sdlog = sd.log.PM)
          ),
          PF = rlnormTrunc(
            N,
            meanlog = m.log.PF,
            sdlog = sd.log.PF,
            min = qlnorm(0.025, meanlog = m.log.PF, sdlog = sd.log.PF),
            max = qlnorm(0.975, meanlog = m.log.PF, sdlog = sd.log.PF)
          ),
          Prest = rlnormTrunc(
            N,
            meanlog = m.log.Prest,
            sdlog = sd.log.Prest,
            min = qlnorm(0.025, meanlog = m.log.Prest, sdlog = sd.log.Prest),
            max = qlnorm(0.975, meanlog = m.log.Prest, sdlog = sd.log.Prest)
          ),
          Prest1 = rlnormTrunc(
            N,
            meanlog = m.log.Prest1,
            sdlog = sd.log.Prest1,
            min = qlnorm(0.025, meanlog = m.log.Prest1, sdlog = sd.log.Prest1),
            max = qlnorm(0.975, meanlog = m.log.Prest1, sdlog = sd.log.Prest1)
          ),
          #{Kinetic Constants}
          # IM Absorption Rate Constants
          # /h, IM absorption rate constant
          Kim = rlnormTrunc(
            N,
            meanlog = m.log.Kim,
            sdlog = sd.log.Kim,
            min = qlnorm(0.025, meanlog = m.log.Kim, sdlog = sd.log.Kim),
            max = qlnorm(0.975, meanlog = m.log.Kim, sdlog = sd.log.Kim)
          ),
          # SC Absorption Rate Constants
          # /h, SC absorption rate constant
          Ksc = rlnormTrunc(
            N,
            meanlog = m.log.Ksc,
            sdlog = sd.log.Ksc,
            min = qlnorm(0.025, meanlog = m.log.Ksc, sdlog = sd.log.Ksc),
            max = qlnorm(0.975, meanlog = m.log.Ksc, sdlog = sd.log.Ksc)
          ),
          # Percentage Plasma Protein Binding unitless
          PB = rlnormTrunc(
            N,
            meanlog = m.log.PB,
            sdlog = sd.log.PB,
            min = qlnorm(0.025, meanlog = m.log.PB, sdlog = sd.log.PB),
            max = 0.990
          ),
          PB1 = rlnormTrunc(
            N,
            meanlog = m.log.PB1,
            sdlog = sd.log.PB1,
            min = qlnorm(0.025, meanlog = m.log.PB1, sdlog = sd.log.PB1),
            max = 0.990
          ),
          #{Metabolic Rate Constant}
          KmC = rlnormTrunc(
            N,
            meanlog = m.log.KmC,
            sdlog = sd.log.KmC,
            min = qlnorm(0.025, meanlog = m.log.KmC, sdlog = sd.log.KmC),
            max = qlnorm(0.975, meanlog = m.log.KmC, sdlog = sd.log.KmC)
          ),
          # Urinary Elimination Rate Constants
          KurineC = rlnormTrunc(
            N,
            meanlog = m.log.KurineC,
            sdlog = sd.log.KurineC,
            min = qlnorm(0.025, meanlog = m.log.KurineC, sdlog = sd.log.KurineC),
            max = qlnorm(0.975, meanlog = m.log.KurineC, sdlog = sd.log.KurineC)
          ),
          KurineC1 = rlnormTrunc(
            N,
            meanlog = m.log.KurineC1,
            sdlog = sd.log.KurineC1,
            min = qlnorm(0.025, meanlog = m.log.KurineC1, sdlog = sd.log.KurineC1),
            max = qlnorm(0.975, meanlog = m.log.KurineC1, sdlog = sd.log.KurineC1)
          ),
          # Enterohepatic circulation rate constants
          KehcC = rlnormTrunc(
            N,
            meanlog = m.log.KehcC,
            sdlog = sd.log.KehcC,
            min = qlnorm(0.025, meanlog = m.log.KehcC, sdlog = sd.log.KehcC),
            max = qlnorm(0.975, meanlog = m.log.KehcC, sdlog = sd.log.KehcC)
          ),
          # Biliary elimination rate constants
          KbileC = rlnormTrunc(
            N,
            meanlog = m.log.KbileC,
            sdlog = sd.log.KbileC,
            min = qlnorm(0.025, meanlog = m.log.KbileC, sdlog = sd.log.KbileC),
            max = qlnorm(0.975, meanlog = m.log.KbileC, sdlog = sd.log.KbileC)
          ),
          KbileC1 = rlnormTrunc(
            N,
            meanlog = m.log.KbileC1,
            sdlog = sd.log.KbileC1,
            min = qlnorm(0.025, meanlog = m.log.KbileC1, sdlog = sd.log.KbileC1),
            max = qlnorm(0.975, meanlog = m.log.KbileC1, sdlog = sd.log.KbileC1)
          ),
          MW = 296.24, 
          DOSEiv = PDOSEiv*BW/MW, DOSEim = PDOSEim*BW/MW, DOSEsc = PDOSEsc*BW/MW)
      
      if (input$route == "iv" && input$animal == "Beef Cattle") {
      ex <- ev(ID=1:N, amt= idata$DOSEiv*a, ii=tinterval, addl=TDoses-1, cmt="AA", replicate = FALSE)
      }
      
      if (input$route == "im" && input$animal == "Beef Cattle") {
      ex <- ev(ID=1:N, amt= idata$DOSEim*a, ii=tinterval, addl=TDoses-1, cmt="Amtsiteim", replicate = FALSE)
      }
      
      if (input$route == "sc" && input$animal == "Beef Cattle") {
      ex <- ev(ID=1:N, amt= idata$DOSEsc*a, ii=tinterval, addl=TDoses-1, cmt="Amtsitesc", replicate = FALSE)
      }
      
      if (input$route_swine == "iv" && input$animal == "Market-age Swine") {
        ex <- ev(ID=1:N, amt= idata$DOSEiv*b, ii=tinterval, addl=TDoses-1, cmt="AA", replicate = FALSE)
      }
      
      if (input$route_swine == "im" && input$animal == "Market-age Swine") {
        ex <- ev(ID=1:N, amt= idata$DOSEim*b, ii=tinterval, addl=TDoses-1, cmt="Amtsiteim", replicate = FALSE)
      }
      
      ## set up time grid

      tsamp=tgrid(0,tinterval*(TDoses-1)+end_time*24,1)
      
      ## Combine data and run the simulation
      
      set.seed(11009)
        {
          out <- 
            mod %>% 
            data_set(ex) %>%
            idata_set(idata) %>%
            mrgsim(obsonly=TRUE, tgrid=tsamp)
        }
      
      pbpkout <- as.data.frame(out)
 #   }
    
    filename='Flunixin-Cattle'
    MW = 296.24
    out.sum = out %>% as_data_frame %>%
      mutate(Time1 = time/24 - (TDoses-1)*tinterval/24) %>%
      dplyr::select(ID, Time1, Venous:Fat) %>%
      arrange(Time1)  %>%
      group_by(Time1) %>%
      dplyr::summarise(CV1 = quantile(Venous, 0.025), CV50 = median(Venous), CV99 = quantile(Venous, 0.975), 
                       CL1 = quantile(Liver, 0.025), CL50 = median(Liver), CL99 = quantile(Liver, 0.975),
                       CK1 = quantile(Kidney, 0.025), CK50 = median(Kidney), CK99 = quantile(Kidney, 0.975),
                       CM1 = quantile(Muscle, 0.025), CM50 = median(Muscle), CM99 = quantile(Muscle, 0.975),
                       CF1 = quantile(Fat, 0.025), CF50 = median(Fat), CF99 = quantile(Fat, 0.975))
    
    if (input$animal == "Beef Cattle") 
      TOL = isolate(input$tolerance) 
    if (input$animal == "Market-age Swine") 
      TOL = isolate(input$tolerance_swine) 
    
    data_tissue <- as.data.frame(out.sum)
    
    return(data_tissue)
  })
  
  
  plot_liver <- reactive({
    if (input$animal == "Beef Cattle") 
    {TOL = isolate(input$tolerance)
    end_time = isolate(input$simu_time)}
    if (input$animal == "Market-age Swine") 
    {TOL = isolate(input$tolerance_swine)
    end_time = isolate(input$simu_time_swine)}
    
    # ggplot2; draw the concentration curve.
    a=ggplot(r1(), aes(Time1)) + 
      geom_ribbon(aes(ymin = CL1,
                      ymax = CL99
      ), fill = 'red',
      show.legend = T, 
      size = 0.2,
      alpha = 0.3) +  # alpha is transparency parameter. 
      geom_line(aes(y = CL50,
                    color = '50 Percentile'), 
                size = 1, 
                show.legend = T) + # draw the mean value to the chart.
      geom_line(aes(y = CL99,
                    color = '99 Percentile'), 
                size = 1, 
                show.legend = T) +  
      geom_line(aes(y = CL1,
                    color = '1 Percentile'), 
                size = 1, 
                show.legend = T) + 
      scale_x_continuous(name = c('Time (Day)'),breaks = c((-(Tdoses*tinterval/24-1)):end_time)) + 
      ylab(expression(paste('Concentration (',mu,'g/mL)'))) + 
      geom_line(aes(y = TOL),color = 'black',size = 0.5, linetype = 'twodash', show.legend = F) + # add tolerance line
      scale_y_log10() + theme_bw() + theme(axis.text=element_text(size=16), legend.title = element_blank()) +
      geom_vline(aes(xintercept = min(subset(r1(), CL99<= TOL & Time1 > 0) %>% dplyr::select(Time1))), 
                 size = 1, color = "red", linetype = 2,
                 show.legend = F)
    return(a)
  })
  
  plot_muscle <- reactive({
    if (input$animal == "Beef Cattle") 
    {TOL = isolate(input$tolerance)
    end_time = isolate(input$simu_time)}
    if (input$animal == "Market-age Swine") 
    {TOL = isolate(input$tolerance_swine)
    end_time = isolate(input$simu_time_swine)}
    
    # ggplot2; draw the concentration curve.
    ggplot(r1(), aes(Time1)) + 
      geom_ribbon(aes(ymin = CM1,
                      ymax = CM99
      ), fill = 'red',
      show.legend = T, 
      size = 0.2,
      alpha = 0.3) +  # alpha is transparency parameter. 
      geom_line(aes(y = CM50,
                    color = '50 Percentile'), 
                size = 1, 
                show.legend = T) + # draw the mean value to the chart.
      geom_line(aes(y = CM99,
                    color = '99 Percentile'), 
                size = 1, 
                show.legend = T) +  
      geom_line(aes(y = CM1,
                    color = '1 Percentile'), 
                size = 1, 
                show.legend = T) + 
      scale_x_continuous(name = c('Time (Day)'),breaks = c((-(Tdoses*tinterval/24-1)):end_time)) + 
      ylab(expression(paste('Concentration (',mu,'g/mL)'))) + 
      geom_line(aes(y = TOL),color = 'black',size = 0.5, linetype = 'twodash', show.legend = F) + # add tolerance line
      scale_y_log10() + theme_bw() + theme(axis.text=element_text(size=16), legend.title = element_blank())+
      geom_vline(aes(xintercept = min(subset(r1(), CM99<= TOL & Time1 > 0) %>% dplyr::select(Time1))), 
                 size = 1, color = "red", linetype = 2,
                 show.legend = F)
  })
  
  plot_kidney <- reactive({
    if (input$animal == "Beef Cattle") 
    {TOL = isolate(input$tolerance)
    end_time = isolate(input$simu_time)}
    if (input$animal == "Market-age Swine") 
    {TOL = isolate(input$tolerance_swine)
    end_time = isolate(input$simu_time_swine)}
    
    # ggplot2; draw the concentration curve.
    ggplot(r1(), aes(Time1)) + 
      geom_ribbon(aes(ymin = CK1,
                      ymax = CK99
      ), fill = 'red',
      show.legend = T, 
      size = 0.2,
      alpha = 0.3) +  # alpha is transparency parameter. 
      geom_line(aes(y = CK50,
                    color = '50 Percentile'), 
                size = 1, 
                show.legend = T) + # draw the mean value to the chart.
      geom_line(aes(y = CK99,
                    color = '99 Percentile'), 
                size = 1, 
                show.legend = T) +  
      geom_line(aes(y = CK1,
                    color = '1 Percentile'), 
                size = 1, 
                show.legend = T) + 
      scale_x_continuous(name = c('Time (Day)'),breaks = c((-(Tdoses*tinterval/24-1)):end_time)) + 
      ylab(expression(paste('Concentration (',mu,'g/mL)'))) + 
      geom_line(aes(y = TOL),color = 'black',size = 0.5, linetype = 'twodash', show.legend = F) + # add tolerance line
      scale_y_log10() + theme_bw() + theme(axis.text=element_text(size=16), legend.title = element_blank())
  })
  
  plot_fat <- reactive({
    if (input$animal == "Beef Cattle") 
    {TOL = isolate(input$tolerance)
    end_time = isolate(input$simu_time)}
    if (input$animal == "Market-age Swine") 
    {TOL = isolate(input$tolerance_swine)
    end_time = isolate(input$simu_time_swine)}
    
    # ggplot2; draw the concentration curve.
    ggplot(r1(), aes(Time1)) + 
      geom_ribbon(aes(ymin = CF1,
                      ymax = CF99
      ), fill = 'red',
      show.legend = T, 
      size = 0.2,
      alpha = 0.3) +  # alpha is transparency parameter. 
      geom_line(aes(y = CF50,
                    color = '50 Percentile'), 
                size = 1, 
                show.legend = T) + # draw the mean value to the chart.
      geom_line(aes(y = CF99,
                    color = '99 Percentile'), 
                size = 1, 
                show.legend = T) +  
      geom_line(aes(y = CF1,
                    color = '1 Percentile'), 
                size = 1, 
                show.legend = T) + 
      scale_x_continuous(name = c('Time (Day)'),breaks = c((-(Tdoses*tinterval/24-1)):end_time)) + 
      ylab(expression(paste('Concentration (',mu,'g/mL)'))) + 
      geom_line(aes(y = TOL),color = 'black',size = 0.5, linetype = 'twodash', show.legend = F) + # add tolerance line
      scale_y_log10() + theme_bw() + theme(axis.text=element_text(size=16), legend.title = element_blank())
  })
  
  plot_plasma <- reactive({
    if (input$animal == "Beef Cattle") 
    {TOL = isolate(input$tolerance)
    end_time = isolate(input$simu_time)}
    if (input$animal == "Market-age Swine") 
    {TOL = isolate(input$tolerance_swine)
    end_time = isolate(input$simu_time_swine)}
    
    # ggplot2; draw the concentration curve.
    ggplot(r1(), aes(Time1)) + 
      geom_ribbon(aes(ymin = CV1,
                      ymax = CV99
      ), fill = 'red',
      show.legend = T, 
      size = 0.2,
      alpha = 0.3) +  # alpha is transparency parameter. 
      geom_line(aes(y = CV50,
                    color = '50 Percentile'), 
                size = 1, 
                show.legend = T) + # draw the mean value to the chart.
      geom_line(aes(y = CV99,
                    color = '99 Percentile'), 
                size = 1, 
                show.legend = T) +  
      geom_line(aes(y = CV1,
                    color = '1 Percentile'), 
                size = 1, 
                show.legend = T) + 
      scale_x_continuous(name = c('Time (Day)'),breaks = c((-(Tdoses*tinterval/24-1)):end_time)) + 
      ylab(expression(paste('Concentration (',mu,'g/mL)'))) + 
      geom_line(aes(y = TOL),color = 'black',size = 0.5, linetype = 'twodash', show.legend = F) + # add tolerance line
      scale_y_log10() + theme_bw() + theme(axis.text=element_text(size=16), legend.title = element_blank())
  })
  
  output$fat <- renderPlot({
    print(plot_fat())
  })
  output$liver <- renderPlot({
    plot_liver() 
  })
  output$muscle <- renderPlot({
    print(plot_muscle())
  })
  output$kidney <- renderPlot({
    print(plot_kidney())
  })
  
  r2 <- reactive({
    if (input$animal == "Beef Cattle") 
      target = isolate(input$target)
    if (input$animal == "Market-age Swine") 
      target = isolate(input$target_swine)
    p <- switch(target,
                Liver = plot_liver(),
                Plasma = plot_plasma(),
                Kidney = plot_kidney(),
                Muscle = plot_muscle(),
                Fat = plot_fat())
    p
  })
  
  output$table1 <- renderTable ({
    #N <- (dim(r1())[2]-16)/5
    datatable <- r1()
    #names(datatable)[5*N+1] <- c('Time (Day)')
    #print(datatable[1:30,(-1):(-N)])
    
  })
  
  output$downloadtable <- downloadHandler(
    filename = 'table.csv',
    content = function(file) {
      write.csv(r1(),file)
    }
  )
  
  output$downloadreport <- downloadHandler(
    filename = function() {
      paste('my-report', sep = '.', switch(
        input$format, PDF = 'pdf', HTML = 'html', Word = 'docx'
      ))
    },
    
    content = function(file) {
      if (input$animal == "Beef Cattle")
        src <- normalizePath('report_cattle.Rmd')
      if (input$animal == "Market-age Swine")
        src <- normalizePath('report_swine.Rmd')
      
      # temporarily switch to the temp dir, in case you do not have write
      # permission to the current working directory
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      file.copy(src, 'report.Rmd', overwrite = TRUE)
      
      library(rmarkdown)
      out <- render('report.Rmd', switch(
        input$format,
        PDF = pdf_document(), HTML = html_document(), Word = word_document()
      ))
      file.rename(out, file)
    }
  )
  
  output$wdtplot <- renderPlot({
    withProgress(message = 'Creating plot', detail='Please Wait...', value = 0.1, 
    expr={input$action | input$action1
      a=isolate(r2())
      a
    })
  })
  
  output$downl <- downloadHandler(
    filename = "Concentrations in liver.jpg",
    content = function(file) {
      ggsave(file, plot_liver())
    },
    contentType = 'image/jpg'
  )
  
  output$downk <- downloadHandler(
    filename = "Concentrations in kidney.jpg",
    content = function(file) {
      ggsave(file, plot_kidney())
    },
    contentType = 'image/jpg'
  )
  
  output$downm <- downloadHandler(
    filename =  "Concentrations in muscle.jpg",
    content = function(file) {
      ggsave(file, plot_muscle())
    },
    contentType = 'image/jpg'
  )
  
  output$downf <- downloadHandler(
    filename = "Concentrations in fat.jpg",
    content = function(file) {
      ggsave(file, plot_fat())
    },
    contentType = 'image/jpg'
  )
  
  output$downloadwdt <- downloadHandler(
    filename = 'concentration.jpg',
    content = function(file) {
      ggsave(file, r2())
    },
    contentType = 'image/jpg'
  )
  
  output$downloadcode <- downloadHandler(
    filename = "Penicillin_Cattle.R",
    content = function(file) {
      con        = file("Penicillin_Cattle.R", open = "r")
      lines      = readLines(con)
      close(con)
      write(lines, file)
    }
  )
  
  get_WDI <- reactive ({
    data_tissue <- r1()
    WDI_data <- subset(data_tissue, data_tissue$CL99<= TOL & data_tissue$Time1 > 0)
    WDI <- ceiling(min(WDI_data$Time1))
    return(WDI)
  })
  
  get_WDI_swine <- reactive ({
    data_tissue <- r1()
    WDI_data <- subset(data_tissue, data_tissue$CL99<= TOL_swine & data_tissue$Time1 > 0)
    WDI <- ceiling(min(WDI_data$Time1))
    return(WDI)
  })
  
  get_days <- reactive ({
    data_tissue <- r1()
    WDI_data <- subset(data_tissue, data_tissue$CL99<= TOL & data_tissue$Time1 > 0)
    days <- round(min(WDI_data$Time1),2)
    return(days)
  })
  
  get_days_swine <- reactive ({
    data_tissue <- r1()
    WDI_data <- subset(data_tissue, data_tissue$CL99<= TOL_swine & data_tissue$Time1 > 0)
    days <- round(min(WDI_data$Time1),2)
    return(days)
  })
  
  get_numberofsimulation <- reactive ({
    numberofsimulation <- input$N
    return(numberofsimulation)
  })
  
  get_TOL <- reactive({
    TOL <- input$tolerance
    return(TOL)
  })
  
  get_TOL_swine <- reactive({
    TOL <- input$tolerance_swine
    return(TOL)
  })
  
  get_animal <- reactive({
    animal <- input$animal
    return(animal)
  })
  
  get_Drug <- reactive({
    Drug <- input$drug
    return(Drug)
  })
  
  get_Dose <- reactive({
    Dose <- input$doselevel
    return(Dose)
  })
  
  get_target <- reactive({
    target <- input$target
    return(target)
  })
  
  get_target_swine <- reactive({
    target <- input$target_swine
    return(target)
  })
  
  get_Tdoses <- reactive({
    Tdoses <- input$numdose
    return(Tdoses)
  })
  
  get_tinterval <- reactive({
    tinterval <- input$tinterval
    return(tinterval)
  }) 
  
  get_route <- reactive({
    route <- input$route
    return(route)
  })
  
  get_route_swine <- reactive({
    route <- input$route_swine
    return(route)
  })
}

shinyApp(ui = ui, server = server)
