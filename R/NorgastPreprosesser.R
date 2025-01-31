#' Denne funksjonen definerer en del nye (sammensatte) variabler relevante for rapporter i NORGAST
#' og rensker opp i andre.
#'
#' Må ha tilgang til filen Helligdager2008-2022.csv
#'
#' @inheritParams FigAndeler
#'
#' @return Data En list med det filtrerte datasettet og sykehusnavnet som tilsvarer reshID
#'
#' @export

NorgastPreprosess <- function(RegData, behold_kladd = FALSE)

{
  RegData$Sykehusnavn <- trimws(RegData$SykehusNavn)
  RegData$AvdRESH <- as.numeric(RegData$AvdRESH)
  RegData$erMann <- as.numeric(RegData$erMann)
  # names(RegData)[which(names(RegData)=='ErMann')]<-'erMann'
  names(RegData)[which(names(RegData)=='PasientAlder')]<-'Alder'
  if (!behold_kladd) {RegData <- RegData[which(RegData$RegistreringStatus==1),]}
  # RegData <- RegData[which(RegData$RegistreringStatus==1),] # Inkluder kun lukkede registreringer
  RegData$OperasjonsDato <- as.Date(RegData$OpDato, format="%Y-%m-%d") # %H:%M:%S" )  #"%d.%m.%Y"	"%Y-%m-%d"
  RegData$HovedDato <- as.Date(RegData$HovedDato, format="%Y-%m-%d")
  RegData$Mnd <- as.numeric(format(RegData$OperasjonsDato, '%m')) # RegData$OperasjonsDato$mon +1
  RegData$Kvartal <- floor((RegData$Mnd - 1)/3)+1
  RegData$Halvaar <- floor((RegData$Mnd - 1)/6)+1
  RegData$Aar <- as.numeric(format(RegData$OperasjonsDato, '%Y')) # RegData$OperasjonsDato$year + 1900
  RegData$DoedsDato <- as.Date(RegData$AvdodDato, format="%Y-%m-%d")
  RegData$OpDoedTid <- difftime(RegData$DoedsDato, RegData$OperasjonsDato, units = 'days')
  RegData$Mort90 <- 0
  RegData$Mort90[which(RegData$OpDoedTid <= 90 & RegData$OpDoedTid >= 0)] <- 1
  RegData <- RegData[RegData$Tilgang %in% 1:3, ] # Fjerner endoskopiske og "notes" inngrep.
  RegData$DodUnderOpphold[which(RegData$OppfDodUnderOpphold == 1)] <- 1

  RegData$ncsp_lowercase <- substr(tolower(RegData$Hovedoperasjon), 1, 5)
  lowercase <- which(substr(RegData$Hovedoperasjon, 1, 5)!=toupper(substr(RegData$Hovedoperasjon, 1, 5))) # index til der NCSP-kode er i lowercase
  uppercase <- match(toupper(RegData$Hovedoperasjon[lowercase]), substr(RegData$Hovedoperasjon, 1, 5))  # index til første forekomst av samme NCSP-kode i uppercase
  # som den som finnes i lowercase
  RegData$Hovedoperasjon[lowercase[which(!is.na(uppercase))]] <- RegData$Hovedoperasjon[uppercase[which(!is.na(uppercase))]] # Der det finnes, erstatt lowercase
  # tilfellet med den fulle beskrivelsen fra uppercase
  RegData$Hovedoperasjon <- iconv(RegData$Hovedoperasjon, "UTF-8", "")
  RegData$Vektendring <- -RegData$VekttapProsent
  RegData$Forbehandling <- NA
  RegData$Forbehandling[which(as.numeric(RegData$KunCytostatika)==1)] <- 1
  RegData$Forbehandling[which(as.numeric(RegData$KunStraaleterapi)==1)] <- 2
  RegData$Forbehandling[which(as.numeric(RegData$KjemoRadioKombo)==1)] <- 3
  RegData$Forbehandling[intersect(intersect(which(as.numeric(RegData$KunCytostatika)==0),
                                            which(as.numeric(RegData$KunStraaleterapi)==0)),
                                  which(as.numeric(RegData$KjemoRadioKombo)==0))] <- 4


  # BMI-klassifisering basert på https://www.fhi.no/fp/overvekt/kroppsmasseindeks-kmi-og-helse/
  RegData$BMI_kategori <- cut(RegData$BMI, breaks = c(0, 16, 17, 18.5, 25, 30, 35, 40, 500), include.lowest = F, right = F,
                              levels=1:8, labels = c('Alvorlig undervekt', 'Moderat undervekt', 'Mild undervekt', 'Normal', 'Overvekt',
                                                     'Fedme klasse I', 'Fedme klasse II', 'Fedme klasse III'))

  RegData$BMI_kodet <- as.numeric(RegData$BMI_kategori)

  # Definer operasjonsgrupper basert på NCSP kode
  RegData <- RegData[which(RegData$ncsp_lowercase!=''),]    # Fjerner registreringer uten operasjonskode
  RegData$Operasjonsgrupper <- "Annet"
  RegData$Operasjonsgrupper[which(substr(RegData$ncsp_lowercase,1,3)=="jfh")] <- "Kolonreseksjoner"
  RegData$Operasjonsgrupper[intersect(which(substr(RegData$ncsp_lowercase,1,3)=="jfb"),
                                      which(as.numeric(substr(RegData$ncsp_lowercase,4,5)) %in% 20:64))] <- "Kolonreseksjoner"
  RegData$Operasjonsgrupper[which(substr(RegData$ncsp_lowercase,1,3)=="jgb")] <- "Rektumreseksjoner"
  RegData$Operasjonsgrupper[which(substr(RegData$ncsp_lowercase,1,3)=="jcc")] <- "Øsofagusreseksjoner"
  RegData$Operasjonsgrupper[which(substr(RegData$ncsp_lowercase,1,3)=="jdc")] <- "Ventrikkelreseksjoner"
  RegData$Operasjonsgrupper[which(substr(RegData$ncsp_lowercase,1,3)=="jdd")] <- "Ventrikkelreseksjoner"
  RegData$Operasjonsgrupper[which(substr(RegData$ncsp_lowercase,1,3)=="jjb")] <- "Leverreseksjoner"
  RegData$Operasjonsgrupper[which(substr(RegData$ncsp_lowercase,1,5) %in% c('jlc10','jlc11'))] <- "Distale pankreasreseksjoner"
  RegData$Operasjonsgrupper[which(substr(RegData$ncsp_lowercase,1,5) %in% c('jlc00','jlc20','jlc40', 'jlc50', 'jlc96'))] <- "Andre pankreasreseksjoner"
  RegData$Operasjonsgrupper[which(substr(RegData$ncsp_lowercase,1,5) %in% c("jlc30","jlc31"))] <- "Whipples operasjon"
  RegData$Operasjonsgrupper[which(substr(RegData$ncsp_lowercase,1,5) %in% c("jka20","jka21"))] <- "Cholecystektomi"
  RegData$Operasjonsgrupper[which(substr(RegData$ncsp_lowercase,1,5) %in% c("jea00","jea01"))] <- "Appendektomi"
  RegData$Operasjonsgrupper[which(substr(RegData$ncsp_lowercase,1,5) %in% c("jfb00","jfb01"))] <- "Tynntarmsreseksjon"
  RegData$Operasjonsgrupper[which(substr(RegData$ncsp_lowercase,1,5) %in% c("jdf10","jdf11"))] <- "Gastric bypass"
  RegData$Operasjonsgrupper[which(substr(RegData$ncsp_lowercase,1,5) %in% c("jdf96","jdf97"))] <- "Gastric sleeve"

  RegData$Op_gr <- NA
  RegData$Op_gr[which(RegData$Operasjonsgrupper == "Kolonreseksjoner")] <- 1
  RegData$Op_gr[which(RegData$Operasjonsgrupper == "Rektumreseksjoner")] <- 2
  RegData$Op_gr[which(RegData$Operasjonsgrupper == "Øsofagusreseksjoner")] <- 3
  RegData$Op_gr[which(RegData$Operasjonsgrupper == "Ventrikkelreseksjoner")] <- 4
  RegData$Op_gr[which(RegData$Operasjonsgrupper == "Leverreseksjoner")] <- 5
  RegData$Op_gr[which(RegData$Operasjonsgrupper == "Whipples operasjon")] <- 6
  RegData$Op_gr[which(RegData$Operasjonsgrupper == "Distale pankreasreseksjoner")] <- 7
  RegData$Op_gr[which(RegData$Operasjonsgrupper == "Andre pankreasreseksjoner")] <- 7 + 1
  RegData$Op_gr[which(RegData$Operasjonsgrupper == "Cholecystektomi")] <- 8 + 1
  RegData$Op_gr[which(RegData$Operasjonsgrupper == "Appendektomi")] <- 9 + 1
  RegData$Op_gr[which(RegData$Operasjonsgrupper == "Tynntarmsreseksjon")] <- 10 + 1
  RegData$Op_gr[which(RegData$Operasjonsgrupper == "Gastric bypass")] <- 11 + 1
  RegData$Op_gr[which(RegData$Operasjonsgrupper == "Gastric sleeve")] <- 12 + 1
  RegData$Op_gr[which(RegData$Operasjonsgrupper == "Annet")] <- 99

  RegData$Op_gr2 <- 9
  RegData$Op_gr2[intersect(which(RegData$Operasjonsgrupper=='Kolonreseksjoner'), which(RegData$NyAnastomose==1))] <- 1
  RegData$Op_gr2[intersect(which(RegData$Operasjonsgrupper=='Kolonreseksjoner'), which(RegData$NyAnastomose==0))] <- 2
  RegData$Op_gr2[intersect(which(RegData$Operasjonsgrupper=='Rektumreseksjoner'), which(RegData$NyAnastomose==1))] <- 3
  RegData$Op_gr2[intersect(which(RegData$Operasjonsgrupper=='Rektumreseksjoner'), which(RegData$NyAnastomose==0))] <- 4
  RegData$Op_gr2[RegData$Operasjonsgrupper=='Øsofagusreseksjoner'] <- 5
  RegData$Op_gr2[intersect(which(RegData$Operasjonsgrupper=='Ventrikkelreseksjoner'), which(RegData$NyAnastomose==1))] <- 6
  RegData$Op_gr2[intersect(which(RegData$Operasjonsgrupper=='Ventrikkelreseksjoner'), which(RegData$NyAnastomose==0))] <- 7
  RegData$Op_gr2[RegData$Operasjonsgrupper=='Whipples operasjon'] <- 8

  RegData$Op_grAarsrapp <- 99
  RegData$Op_grAarsrapp[which(RegData$Operasjonsgrupper == "Kolonreseksjoner")] <- 1
  RegData$Op_grAarsrapp[which(RegData$Operasjonsgrupper == "Rektumreseksjoner")] <- 2
  RegData$Op_grAarsrapp[which(RegData$Operasjonsgrupper == "Øsofagusreseksjoner")] <- 3
  RegData$Op_grAarsrapp[which(RegData$Operasjonsgrupper == "Ventrikkelreseksjoner")] <- 4
  RegData$Op_grAarsrapp[which(RegData$Operasjonsgrupper == "Leverreseksjoner")] <- 5
  RegData$Op_grAarsrapp[which(RegData$Operasjonsgrupper == "Whipples operasjon")] <- 6
  RegData$Op_grAarsrapp[which(substr(RegData$ncsp_lowercase,1,3)=="jlc" &
                                (as.numeric(substr(RegData$ncsp_lowercase,4,5)) %in% 0:20 |
                                   as.numeric(substr(RegData$ncsp_lowercase,4,5)) %in% 40:99))] <- 7 # Øvrige pancreas
  RegData$Op_grAarsrapp[which(substr(RegData$ncsp_lowercase,1,3)=="jhc" &
                                (as.numeric(substr(RegData$ncsp_lowercase,4,5)) %in% 10:99))] <- 8 # Gallegang

  #### Quickfix: OppfStatus skal være numerisk kodet i AlleVariablerNum
  RegData$OppfStatus <- as.character(RegData$OppfStatus)
  RegData$OppfStatus[RegData$OppfStatus=='Opprettet'] <- '-1'
  RegData$OppfStatus[RegData$OppfStatus=='Kladd'] <- '0'
  RegData$OppfStatus[RegData$OppfStatus=='Ferdigstilt'] <- '1'
  RegData$OppfStatus[RegData$OppfStatus=='Ukjent'] <- ''
  RegData$OppfStatus <- as.numeric(RegData$OppfStatus)

  RegData$FerdigForlop <- 0
  RegData$FerdigForlop[
    RegData$RegistreringStatus == 1 &
      (RegData$OppfStatus == 1 | is.na(RegData$OppfStatus))] <- 1
  RegData$FerdigForlop_v2 <- 0
  RegData$FerdigForlop_v2[
    RegData$RegistreringStatus == 1 &
      (RegData$OppfStatus == 1 |
         (is.na(RegData$OppfStatus) & RegData$DodUnderOpphold==1) |
         (is.na(RegData$OppfStatus) & RegData$PostopLiggedogn>=30) |
         (is.na(RegData$OppfStatus) & RegData$OpDoedTid<40))] <- 1


  #### Inkluder ACCORDION SCORE fra oppfølgingsskjema
  RegData$AccordionGrad <- as.character(RegData$AccordionGrad)
  RegData$AccordionGrad[RegData$AccordionGrad=='Mindre enn 3'] <- '1'
  RegData$AccordionGrad <- as.numeric(RegData$AccordionGrad)
  RegData$OppfAccordionGrad <- as.character(RegData$OppfAccordionGrad)
  RegData$OppfAccordionGrad[RegData$OppfAccordionGrad=='Mindre enn 3'] <- 1
  RegData$OppfAccordionGrad <- as.numeric(RegData$OppfAccordionGrad)
  RegData$OppfAccordionGrad[RegData$OppfStatus!=1]<-NA
  RegData$AccordionGrad[!is.na(pmax(RegData$AccordionGrad, RegData$OppfAccordionGrad))] <-
    pmax(RegData$AccordionGrad, RegData$OppfAccordionGrad)[!is.na(pmax(RegData$AccordionGrad,
                                                                       RegData$OppfAccordionGrad))]

  #### Definerer variabelen Saarruptur basert på funn ved reoperasjon under opphold eller v/ reinnleggelse innen 30 dager
  #### UTELUKKER LAPAROSKOPISKE INNGREP, PR. BESTILLING LINN.
  RegData$Saarruptur <- NA
  RegData$Saarruptur[RegData$Tilgang %in% 1:3] <- 0
  RegData$Saarruptur[which(RegData$ViktigsteFunn==4 | RegData$OppfViktigsteFunn==4)] <- 1
  RegData$Saarruptur[!(RegData$Tilgang %in% 1:3)] <- NA

  #### Inkluder Relaparotomi fra oppfølgingsskjema

  RegData$OppfReLapNarkose[RegData$OppfStatus!=1] <- NA
  RegData$OppfViktigsteFunn[RegData$OppfStatus!=1] <- NA
  RegData$ReLapNarkose <- pmax(RegData$ReLapNarkose, RegData$OppfReLapNarkose, na.rm = TRUE)
  RegData$ViktigsteFunn <- pmin(RegData$ViktigsteFunn, RegData$OppfViktigsteFunn, na.rm = TRUE)

  Helligdager <- norgast::Helligdager

  RegData$Dagtid <- NA
  RegData$Dagtid[as.numeric(RegData$AnestesiStartKl) %in% 7:15] <- 1
  RegData$Dagtid[as.numeric(RegData$AnestesiStartKl) %in% c(1:6, 16:24)] <- 0

  RegData$Hastegrad_tid <- NA
  RegData$Hastegrad_tid[as.numeric(RegData$AnestesiStartKl) %in% 8:15] <- 1
  RegData$Hastegrad_tid[as.numeric(RegData$AnestesiStartKl) %in% c(1:7, 16:24)] <- 0
  # RegData$Hastegrad_tid[RegData$OperasjonsDato$wday %in% c(0, 6)] <- 0 # gammel
  RegData$Hastegrad_tid[as.numeric(format(RegData$OperasjonsDato, '%w')) %in% c(0, 6)] <- 0
  RegData$Hastegrad_tid[RegData$OperasjonsDato %in% Helligdager] <- 0

  RegData$Hastegrad_hybrid <- 2 - RegData$Hastegrad# Definerer en hybridhastegrad som bruker gammel tidsbasert definisjon før
  # 2018-04-18 og den nye direkteregistrerte etter det.
  RegData$Hastegrad_hybrid[RegData$HovedDato < '2018-04-18'] <- RegData$Hastegrad_tid[RegData$HovedDato < '2018-04-18']

  RegData$AvlastendeStomiRektum <- NA
  RegData$AvlastendeStomiRektum[
    intersect(intersect(which(as.numeric(RegData$NyAnastomose)==1), which(RegData$Op_gr==2)),
              which(as.numeric(RegData$NyStomi)==0))] <- 0
  RegData$AvlastendeStomiRektum[
    union(which(is.na(RegData$NyAnastomose)), which(is.na(RegData$NyStomi)))] <- NA
  RegData$AvlastendeStomiRektum[
    intersect(intersect(which(as.numeric(RegData$NyAnastomose)==1),
                        which(as.numeric(RegData$NyStomi)==1)),which(RegData$Op_gr==2))] <- 1

  RegData$PermanentStomiColorektal <- NA
  RegData$PermanentStomiColorektal[intersect(union(which(as.numeric(RegData$NyAnastomose)==1), which(as.numeric(RegData$NyStomi)==0)),
                                             union(which(RegData$Op_gr==1),which(RegData$Op_gr==2)))] <- 0
  RegData$PermanentStomiColorektal[union(which(is.na(RegData$NyAnastomose)), which(is.na(RegData$NyStomi)))] <- NA
  RegData$PermanentStomiColorektal[intersect(intersect(which(as.numeric(RegData$NyAnastomose)==0),which(as.numeric(RegData$NyStomi)==1)),
                                             union(which(RegData$Op_gr==1),which(RegData$Op_gr==2)))] <- 1

  RegData$Anastomoselekkasje <- NA
  RegData$Anastomoselekkasje[RegData$NyAnastomose==1] <- 0
  RegData$Anastomoselekkasje[RegData$ViktigsteFunn==1] <- 1
  RegData$Anastomoselekkasje[RegData$NyAnastomose!=1] <- NA      #########  DISKUTER MED REGISTER !!!!!!!!!!!!!
  RegData$Anastomoselekkasje[is.na(RegData$NyAnastomose)] <- NA  #########  SPESIELT MED TANKE PÅ WHIPPLES !!!!

  RegData$LapTilgang <- as.numeric(RegData$Tilgang)  # Konverterte gruppert med åpne
  RegData$LapTilgang[RegData$LapTilgang %in% c(1,3)] <- 0
  RegData$LapTilgang[RegData$LapTilgang == 2] <- 1
  RegData$LapTilgang[!(RegData$LapTilgang %in% c(0,1))] <- NA

  RegData$LapTilgang2 <- as.numeric(RegData$Tilgang) # Konverterte gruppert med laparoskopiske
  RegData$LapTilgang2[RegData$LapTilgang2 == 1] <- 0
  RegData$LapTilgang2[RegData$LapTilgang2 %in% c(2,3)] <- 1
  RegData$LapTilgang2[!(RegData$LapTilgang2 %in% c(0,1))] <- NA

  RegData$Tilgang_utvidet <- RegData$Tilgang
  RegData$Tilgang_utvidet[RegData$Tilgang == 2 & RegData$Robotassistanse == 0] <- 2
  RegData$Tilgang_utvidet[RegData$Tilgang == 2 & RegData$Robotassistanse == 1] <- 3
  RegData$Tilgang_utvidet[RegData$Tilgang == 3 & RegData$Robotassistanse == 0] <- 4
  RegData$Tilgang_utvidet[RegData$Tilgang == 3 & RegData$Robotassistanse == 1] <- 5

  RegData$KumAcc <- NA
  RegData$KumAcc[RegData$AccordionGrad < 3] <- 0
  RegData$KumAcc[RegData$AccordionGrad >= 3] <- 1

  RegData$KumAcc2 <- NA
  RegData$KumAcc2[RegData$AccordionGrad < 4] <- 0
  RegData$KumAcc2[RegData$AccordionGrad >= 4] <- 1

  RegData$MissingVekt <- 0
  RegData$MissingVekt[is.na(RegData$VekttapProsent)] <- 1

  RegData <- RegData[order(RegData$HovedDato, decreasing = TRUE), ]
  # RegData <- RegData[match(unique(RegData$PasientID), RegData$PasientID), ]

  RegData$Malign <- NA
  RegData$Malign[which(substr(RegData$Hoveddiagnose, 1, 1) == 'C')] <- 1
  RegData$Malign[which(substr(RegData$Hoveddiagnose, 1, 1) != 'C')] <- 0
  RegData$Malign[which(substr(RegData$Hoveddiagnose, 1, 1) == '')] <- 9

  RegData$Hoveddiagnose2 <- sub("(\\w+).*", "\\1", RegData$Hoveddiagnose)
  RegData$Hoveddiagnose2 <- RegData$Hoveddiagnose[match(RegData$Hoveddiagnose2, sub("(\\w+).*", "\\1", RegData$Hoveddiagnose))]
  # tmp1 <- table(RegData$Hoveddiagnose)
  # tmp2 <- table(RegData$Hoveddiagnos2)
  # table(RegData$Hoveddiagnose[sub("(\\w+).*", "\\1", RegData$Hoveddiagnose) %in% sub("(\\w+).*", "\\1", setdiff(names(tmp1), names(tmp2)))])

  RegData$AvstandAnalVerge_kat <- cut(RegData$AvstandAnalVerge, breaks = c(0,5,10,15.9),
                                      labels = c("0-5.9 cm", "6.0-10.9 cm", "11.0-15.9 cm"), include.lowest = T)
  levels(RegData$AvstandAnalVerge_kat) <- c(levels(RegData$AvstandAnalVerge_kat), "Ikke målt")
  RegData$AvstandAnalVerge_kat[is.na(RegData$AvstandAnalVerge)] <- "Ikke målt"

  return(invisible(RegData))

}
