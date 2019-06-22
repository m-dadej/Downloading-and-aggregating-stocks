# this script is for adding companies with more than 8 characters which recently have done IPO
# exception file is crucial 2 (including the most important one) bossa scripts uses it 
# also it is kind of a backup of exception file

exception <- c("SILVAIR-REGS.mst","GRUPAAZOTY.mst","MDIENERGIA.mst","MILLENNIUM.mst","INVESTORMS.mst","4FUNMEDIA.mst",
               "ACAUTOGAZ.mst", "APSENERGY.mst","ASSECOPOL.mst","ASSECOSEE.mst","AUTOPARTN.mst","BAHOLDING.mst",
               "BIOMEDLUB.mst", "CDPROJEKT.mst", "CLNPHARMA.mst", "CYFRPLSAT.mst","EKOEXPORT.mst","ELEKTROTI.mst",
               "ELEMENTAL.mst", "ENERGOINS.mst","GETINOBLE.mst","GINOROSSI.mst","HOLLYWOOD.mst","IMCOMPANY.mst",
               "INSTALKRK.mst","INTERAOLT.mst", "INTERCARS.mst", "INTERSPPL.mst", "JWWINVEST.mst", "K2INTERNT.mst",
               "KOMPUTRON.mst", "KONSSTALI.mst", "KRUSZWICA.mst", "KRVITAMIN.mst", "LABOPRINT.mst", "MAKARONPL.mst",
               "MASTERPHA.mst", "MEXPOLSKA.mst", "MIRACULUM.mst", "MOSTALPLC.mst", "MOSTALWAR.mst", "NORTCOAST.mst",
               "NTTSYSTEM.mst", "OPONEO.PL.mst", "PCCROKITA.mst", "PEMANAGER.mst", "PLATYNINW.mst", "PLAZACNTR.mst",
               "POLIMEXMS.mst", "PRAGMAINK.mst", "PRIMETECH.mst", "PROJPRZEM.mst", "PROVIDENT.mst", "RANKPROGR.mst",
               "SANTANDER.mst", "STALPROFI.mst", "STARHEDGE.mst", "UNICREDIT.mst", "VENTUREIN.mst", "WIRTUALNA.mst",
               "IDMSA.mst", "WORKSERV.mst", "WITTCHEN.mst", "WARIMPEX.mst", "VINDEXUS.mst", "TRANSPOL.mst","TERMOREX.mst",
               "TAURONPE.mst", "SYNEKTIK.mst", "SWISSMED.mst", "STALPROD.mst", "SOPHARMA.mst", "SLEEPZAG.mst", 
               "SKARBIEC.mst", "SELENAFM.mst", "ABADONRE.mst", "ABMSOLID.mst", "AILLERON.mst", "ALCHEMIA.mst",
               "ALTUSTFI.mst", "ROPCZYCE.mst", "RAWLPLUG.mst", "ALUMETAL.mst", "APLISENS.mst", "ARCHICOM.mst",
               "ASMGROUP.mst", "ASSECOBS.mst","ATLANTIS.mst", "ATLASEST.mst", "ATMGRUPA.mst", "BOGDANKA.mst",
               "BORYSZEW.mst","BPHFIZDS.mst", "CITYSERV.mst", "DATAWALK.mst" ,"DROZAPOL.mst","EDINVEST.mst",
               "ELBUDOWA.mst", "ESSYSTEM.mst","EUROCASH.mst", "EUROHOLD.mst", "ORANGEPL.mst", "ORZBIALY.mst",
               "OTMUCHOW.mst","PATENTUS.mst", "PCCINTER.mst", "PFLEIDER.mst", "PHARMENA.mst", "PKNORLEN.mst",
               "PKPCARGO.mst", "PLASTBOX.mst", "PRAGMAFA.mst", "PROCHNIK.mst", "TRIGONPP.mst", "TRANSPOL.mst",
               "STALPROD.mst", "RAWLPLUG.mst", "PROCHNIK.mst", "NETMEDIA.mst" ,"NOWAGALA.mst", "ODLEWNIE.mst",
               "ORANGEPL.mst", "ORZBIALY.mst", "OTMUCHOW.mst", "PATENTUS.mst", "PCCINTER.mst", "PFLEIDER.mst",
               "PHARMENA.mst", "PKNORLEN.mst", "PKPCARGO.mst", "PLASTBOX.mst", "PRAGMAFA.mst" ,"NETMEDIA.mst",
               "NOWAGALA.mst", "ODLEWNIE.mst", "KOGENERA.mst", "KRAKCHEM.mst", "KREDYTIN.mst", "LIVECHAT.mst", 
               "MARVIPOL.mst", "MEDIACAP.mst", "MEDIATEL.mst", "MEDICALG.mst", "MERCATOR.mst", "MLPGROUP.mst", 
               "MLSYSTEM.mst", "ITMTRADE.mst", "IZOLACJA.mst", "JWCONSTR.mst",  "GLCOSMED.mst", "GRAVITON.mst",
               "HANDLOWY.mst", "HERKULES.mst", "HUBSTYLE.mst", "HYDROTOR.mst", "IDEABANK.mst", "IMMOBILE.mst",
               "IMPEXMET.mst", "INDYKPOL.mst", "TOWERINVT.mst", "SECOGROUP.mst", "PROTEKTOR.mst", "PRIMAMODA.mst",
               "ORCOGROUP.mst", "NOVATURAS.mst", "NANOGROUP.mst", "MOSTALZAB.mst", "MILKILAND.mst", "INTERFERI.mst",
               "IFCAPITAL.mst", "GEKOPLAST.mst", "EMCINSMED.mst", "CZTOREBKA.mst", "ATLANTAPL.mst", "TARCZYNSKI.mst")

write.csv(exception, file = "exceptions")