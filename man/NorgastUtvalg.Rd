% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/NorgastUtvalg.R
\name{NorgastUtvalg}
\alias{NorgastUtvalg}
\title{Funksjon som gjør utvalg av dataene, returnerer det reduserte datasettet og utvalgsteksten.}
\usage{
NorgastUtvalg(
  RegData,
  datoFra = "2014-01-01",
  datoTil = "2100-01-01",
  minald = 0,
  maxald = 120,
  erMann = 99,
  elektiv = 99,
  BMI = "",
  hastegrad = 99,
  valgtShus = "",
  tilgang = "",
  minPRS = 0,
  maxPRS = 2.2,
  ASA = "",
  whoEcog = "",
  modGlasgow = "",
  forbehandling = "",
  malign = 99,
  fargepalett = "BlaaRapp",
  op_gruppe = "",
  ncsp = "",
  icd = "",
  icd_kode = "",
  hastegrad_hybrid = 99,
  dagtid = 99,
  robotassiastanse = 99,
  kun_ferdigstilte = TRUE,
  tilgang_utvidet = "",
  ny_stomi = 99,
  accordion = "",
  ny_anastomose = 99
)
}
\arguments{
\item{RegData}{En dataramme med alle nødvendige variabler fra registeret}

\item{datoFra}{Tidligste dato i utvalget (vises alltid i figuren).}

\item{datoTil}{Seneste dato i utvalget (vises alltid i figuren).}

\item{minald}{Alder, fra og med (Default: 0)}

\item{maxald}{Alder, til og med (Default: 130)}

\item{erMann}{kjønn
1: menn
0: kvinner
99: begge (alt annet enn 0 og 1) (Default)}

\item{elektiv}{Elektiv eller øyeblikkelig hjelp
0: Øyeblikkelig hjelp
1: Elektiv
99: Begge deler (Default)}

\item{BMI}{BMI-klasse, flervalg hvor (Default alle)
1: Alvorlig undervekt
2: Undervekt
3: Mild undervekt
4: Normal
5: Overvekt
6: Moderat fedme, klasse I
7: Fedme, klasse II
8: Fedme, klasse III}

\item{valgtShus}{Vektor med AvdResh over hvilke sykehus man genererer rapporten for.
Denne overstyrer reshID og er bare tilgjengelig for SC-bruker.}

\item{tilgang}{Tilgang i abdomen
1: Åpen eller konvertert
2: Lapaoskopisk
99: Alle (Default)}

\item{minPRS}{Minimum PRS (Default 0?)}

\item{maxPRS}{Maksimum PRS (Default 2?)}

\item{ASA}{ASA-grad, flervalg hvor (Default alle)
1: Ingen organisk, fysiologisk, biokjemisk eller psykisk forstyrrelse.
Den aktuelle lidelsen er lokalisert og gir ikke generelle systemforstyrrelser.
2: Moderat sykdom eller forstyrrelser som ikke forårsaker funksjonelle begrensninger.
3: Alvorlig sykdom eller forstyrrelse som gir definerte funksjonelle begrensninger.
4: Livstruende organisk sykdom som ikke behøver å være knyttet til den aktuelle
kirurgiske lidelsen eller som ikke alltid bedres ved det planlagte kirurgiske inngrepet.
5: Døende pasient som ikke forventes å overleve 24 timer uten kirurgi.}

\item{whoEcog}{WHO WCOG score, flervalg hvor (Default alle)
0: Fullt aktiv
1: Lett husarbeid og sittende arbeid
2: Oppe > 50% av dagen, selvstelt
3: Oppe < 50% av dagen, delvis selvstelt
4: Kun i stol/seng, hjelp til alt stell
9: Ukjent}

\item{forbehandling}{Onkologisk forbehandling
1: Cytostatika
2: Stråleterapi
3: Komb. kjemo/radioterapi
4: Ingen
99: Alle}

\item{malign}{Er diagnosen malign eller benign
0: Benign
1: Malign
99: Alle}

\item{fargepalett}{Hvilken fargepalett skal brukes i figurer (Default: BlaaRapp)}

\item{op_gruppe}{Reseksjonsgruppe
1: Kolonreseksjoner
2: Rektumreseksjoner
3: Øsofagusreseksjoner
4: Ventrikkelreseksjoner
5: Leverreseksjoner
6: Whipple's operasjon
7: Andre pankreas
8: Cholecystektomi
9: Appendektomi
10: Tynntarmsreseksjon
11: Gastric bypass
12: Gastric sleeve}

\item{ncsp}{NCSP-koder(r) som skal være inkludert i utvalget}
}
\value{
UtData En liste bestående av det filtrerte datasettet, utvalgstekst for figur og tekststreng som angir fargepalett
}
\description{
Funksjon som gjør utvalg av dataene, returnerer det reduserte datasettet og utvalgsteksten.
}
