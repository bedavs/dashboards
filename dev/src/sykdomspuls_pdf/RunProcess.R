con <- file("/tmp/computer","r")
COMPUTER_NAME <- readLines(con,n=1)
close(con)
Sys.setenv(COMPUTER=COMPUTER_NAME)

cat(sprintf("%s/%s/R/sykdomspuls_pdf STARTING UP!!",Sys.time(),Sys.getenv("COMPUTER")),"\n")

suppressMessages(library(data.table))
suppressMessages(library(ggplot2))
#devtools::use_package("odfWeave")

if(Sys.getenv("RSTUDIO") == "1"){
  devtools::load_all("/packages/fhi/", export_all=FALSE)
  devtools::load_all("/packages/dashboards_sykdomspuls_pdf/", export_all=FALSE)
  
} else {
  library(sykdomspulspdf)
}

DashboardFolder <- fhi::DashboardFolder
fhi::DashboardInitialise(
  STUB="/",
  SRC="src",
  NAME="sykdomspuls_pdf"
)



files <- IdentifyDatasets()
mydate <- format(Sys.time(), "%d.%m.%y")



if(nrow(files)==0){
  cat(sprintf("%s/%s/R/SYKDOMSPULS_pdf No new data",Sys.time(),Sys.getenv("COMPUTER")),"\n")
  return(FALSE)
  
} else {
  
  
  d <- fread(fhi::DashboardFolder("data_raw",files$raw))
  fylke <-fread(system.file("extdata", "fylke.csv", package = "sykdomspulspdf"))
  lastestUpdate <- as.Date(gsub("_","-",LatestRawID()))
  
  cat(sprintf("%s/%s/R/SYKDOMSPULSSYKDOMSPULS_pdf Generating monthly pdf",Sys.time(),Sys.getenv("COMPUTER")),"\n")
  
  
  #Alle konsultasjoner:
  data <- CleanData(d)
  alle <- tapply(data$gastro, data[, c("year","week")], sum)
  weeknow <-findLastWeek(lastestUpdate,alle) ### need to be fixed
  cat(paste("Last week",weeknow,sep = " "))
  
  ##BY FYLKE
  for (SYNDROM in CONFIG$SYNDROMES) {
    sykdompulspdf_template_copy(fhi::DashboardFolder("data_raw"),SYNDROM)
    sykdompulspdf_resources_copy(fhi::DashboardFolder("data_raw"))
    
    if (SYNDROM=="mage") {
      add="magetarm"
      mytittle="Mage-tarminfeksjoner"
      
    } else if (SYNDROM=="luft") {
      add="luftvei"
      mytittle="Luftveisinfeksjoner"
      
    }
    
    ###########################################
    for (f in fylke$Fylkename) {
      
      Fylkename=f
      data <- CleanDataByFylke(d, fylke,f)
      alle <- tapply(getdataout(data,SYNDROM), data[, c("year","week")], sum)
      yrange <- max(alle,na.rm=T)+(roundUpNice(max(alle,na.rm=T))*.20)
      
      
      
      rmarkdown::render(input = fhi::DashboardFolder("data_raw",paste("monthly_report_",SYNDROM,".Rmd",sep="")),
                        output_file = paste(gsub(" ", "", f, fixed = TRUE),"_",add,".pdf", sep=""),
                        output_dir = fhi::DashboardFolder("results",paste("PDF",mydate,sep="_")))
      
    }
    
    sykdompulspdf_template_remove(fhi::DashboardFolder("data_raw"),SYNDROM)
    
  }
  
  sykdompulspdf_resources_remove(fhi::DashboardFolder("data_raw"))
  
}
