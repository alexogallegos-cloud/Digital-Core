CREATE PROCEDURE "informix".sp_comparar_info_tbl_prodtar ()
    RETURNING VARCHAR(5) as rCODIGO_RETORNO, VARCHAR (250) as rMENSAJE_RETORNO;
	
    DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80);    
    DEFINE RUTA_DESTINO VARCHAR(80);
    DEFINE vCodigoRetorno VARCHAR(5);
    DEFINE vMensajeRetorno VARCHAR(250);
    
    -------------
    DEFINE vPTcodproductotarjeta VARCHAR(3);
    DEFINE vPTdescproducto VARCHAR(30);
    DEFINE vPTporccomconsatmnac DECIMAL(9,6);
    DEFINE vPTporccomconsatmint DECIMAL(9,6);
    DEFINE vPTporccomretatmnac DECIMAL(9,6);
    DEFINE vPTporccomretatmint DECIMAL(9,6);
    DEFINE vPTporccomcompraposnac DECIMAL(9,6);
    DEFINE vPTporccomcompraposint DECIMAL(9,6);
    DEFINE vPTporccomrevatmnac DECIMAL(9,6);
    DEFINE vPTporccomrevatmint DECIMAL(9,6);
    DEFINE vPTporccomrevposnac DECIMAL(9,6);
    DEFINE vPTporccomrevposint DECIMAL(9,6);
    DEFINE vPTporccomfzdaposnac DECIMAL(9,6);
    DEFINE vPTporccomfzdaposint DECIMAL(9,6);
    DEFINE vPTlimdiarioretatmnac DECIMAL(19,4);
    DEFINE vPTlimdiarioretatmint DECIMAL(19,4);
    DEFINE vPTlimmensretatmnac DECIMAL(19,4);
    DEFINE vPTlimmensretatmint DECIMAL(19,4);
    DEFINE vPTlimdiariocompraposnac DECIMAL(19,4);
    DEFINE vPTlimdiariocompraposint DECIMAL(19,4);
    DEFINE vPTlimmenscompraposnac DECIMAL(19,4);
    DEFINE vPTlimmenscompraposint DECIMAL(19,4);
    DEFINE vPTlimhdretatmnac DECIMAL(19,4);
    DEFINE vPTlimhdretatmint DECIMAL(19,4);
    DEFINE vPTlimhdcompraposnac DECIMAL(19,4);
    DEFINE vPTlimhdcompraposint DECIMAL(19,4);
    DEFINE vPTnumtranhdretatmnac INTEGER;
    DEFINE vPTnumtranhdretatmint INTEGER;
    DEFINE vPTnumtranhdcompraposnac INTEGER;
    DEFINE vPTnumtranhdcompraposint INTEGER;
    DEFINE vPTnumtranconsatmlibresmens INTEGER;
    DEFINE vPTnumtranretatmlibresmens INTEGER;
    DEFINE vPTnumtrancompraposlibresmens INTEGER;
    DEFINE vPTmaxtranconsatmdiarias INTEGER;
    DEFINE vPTmaxtranretatmdiarias INTEGER;
    DEFINE vPTmaxtrancompraposdiarias INTEGER;
    DEFINE vPTmaxtranconsatmmens INTEGER;
    DEFINE vPTmaxtranretatmmens INTEGER;
    DEFINE vPTmaxtrancompraposmens INTEGER;
    DEFINE vPTsaldomaxamostrar DECIMAL(19,4);
    DEFINE vPTporccomconsatmpropio DECIMAL(9,6);
    DEFINE vPTporccomretatmpropio DECIMAL(9,6);
    DEFINE vPTporccomrevatmpropio DECIMAL(9,6);
    DEFINE vPTlimdiarioretatmpropio DECIMAL(19,4);
    DEFINE vPTlimmensretatmpropio DECIMAL(19,4);
    DEFINE vPTlimhdretatmpropio DECIMAL(19,4);
    DEFINE vPTnumtranhdretatmpropio INTEGER;
    DEFINE vPTnumtranconsatmlibresmenspropio INTEGER;
    DEFINE vPTnumtranretatmlibresmenspropio INTEGER;
    DEFINE vPTmaxtranconsatmdiariaspropio INTEGER;
    DEFINE vPTmaxtranretatmdiariaspropio INTEGER;
    DEFINE vPTmaxtranconsatmmenspropio INTEGER;
    DEFINE vPTmaxtranretatmmenspropio INTEGER;
    DEFINE vPTtarjetanorelacionada VARCHAR(1);
    DEFINE vPTcuentamaestra VARCHAR(13);
    DEFINE vPTsaldominimo DECIMAL(19,4);
    DEFINE vPTcodigoeventoerror VARCHAR(4);
    DEFINE vPTestatusprocesocargasaldos VARCHAR(1);
    DEFINE vPTestatusprocesocancelacion VARCHAR(1);
    DEFINE vPTregistrostotalcargasaldos INTEGER;
    DEFINE vPTregistrosavancecargasaldos INTEGER;
    DEFINE vPTregistrostotalcancelacion INTEGER;
    DEFINE vPTregistrosavancecancelacion INTEGER;
    DEFINE vPTtnrcobracomisiones VARCHAR(1);
    DEFINE vPTtnrporccomconsatmnac DECIMAL(9,6);
    DEFINE vPTtnrporccomconsatmint DECIMAL(9,6);
    DEFINE vPTtnrporccomretatmnac DECIMAL(9,6);
    DEFINE vPTtnrporccomretatmint DECIMAL(9,6);
    DEFINE vPTtnrporccomcompraposnac DECIMAL(9,6);
    DEFINE vPTtnrporccomcompraposint DECIMAL(9,6);
    DEFINE vPTtnrporccomrevatmnac DECIMAL(9,6);
    DEFINE vPTtnrporccomrevatmint DECIMAL(9,6);
    DEFINE vPTtnrporccomrevposnac DECIMAL(9,6);
    DEFINE vPTtnrporccomrevposint DECIMAL(9,6);
    DEFINE vPTtnrporccomfzdaposnac DECIMAL(9,6);
    DEFINE vPTtnrporccomfzdaposint DECIMAL(9,6);
    DEFINE vPTtnrporccomconsatmpropio DECIMAL(9,6);
    DEFINE vPTtnrporccomretatmpropio DECIMAL(9,6);
    DEFINE vPTtnrporccomrevatmpropio DECIMAL(9,6);
    DEFINE vPTcorporativa VARCHAR(1);
    DEFINE vPTnombreempresa VARCHAR(30);
    DEFINE vPTcomisioncargasaldos DECIMAL(19,4);
    DEFINE vPTtnrgenintervalo INTEGER;
    DEFINE vPTtnrgentipointervalo VARCHAR(2);
    DEFINE vPTtnrgenfechahorainicio DATETIME YEAR to FRACTION(5);
    DEFINE vPTtnrgenfechahorafinal DATETIME YEAR to FRACTION(5);
    DEFINE vPTtnrgenrutaarchivo VARCHAR(255);
    DEFINE vPTcobracomisionesenlinea VARCHAR(1);
    DEFINE vPTpermitecomisionespendientes VARCHAR(1);
    DEFINE vPTestatusprocesoasignacionmasiva VARCHAR(1);
    DEFINE vPTregistrostotalasignacionmasiva INTEGER;
    DEFINE vPTregistrosavanceasignacionmasiva INTEGER;
    DEFINE vPTtranscom VARCHAR(4);
    DEFINE vPTcobracomanualidad VARCHAR(1);
    DEFINE vPTimpcomanualidad DECIMAL(19,4);
    DEFINE vPTfechainicomanualidad DATETIME YEAR to FRACTION(5);
    DEFINE vPTpermitetnrpersonalizadas VARCHAR(1);
    DEFINE vPTtranscomexpedicion VARCHAR(4);
    DEFINE vPTcobracomexpedicion VARCHAR(1);
    DEFINE vPTimpcomexpedicion DECIMAL(19,4);
    DEFINE vPTtranscomrenovacion VARCHAR(4);
    DEFINE vPTcobracomrenovacion VARCHAR(1);
    DEFINE vPTimpcomrenovacion DECIMAL(19,4);
    DEFINE vPTtnrcuentadispersadora VARCHAR(13);
    DEFINE vPTtnrtranscargoctadispersadora VARCHAR(4);
    DEFINE vPTtnrtransabonoctainfraestructura VARCHAR(4);
    DEFINE vPTtnrtranscargoctainfraestructura VARCHAR(4);
    DEFINE vPTtnrtransabonoctadispersadora VARCHAR(4);
    DEFINE vPTtnrutilizactainfraestructura VARCHAR(1);
    DEFINE vPTtnrhabilitarproteccionsaldosasignados VARCHAR(1);
    DEFINE vPTtnrbloquearreversionasignaciones VARCHAR(1);
    DEFINE vPTtnrlapsoreversion INTEGER;
    DEFINE vPTtnrcongelarsaldoindividual VARCHAR(1);
    DEFINE vPTtnrlapsocongelarsaldo INTEGER;
    DEFINE vPTtnrimagenactualizada VARCHAR(1);
    DEFINE vPTestatusprocesosolicitudtarjeta VARCHAR(1);
    DEFINE vPTregistrostotalsolicitudtarjeta INTEGER;
    DEFINE vPTregistrosavancesolicitudtarjeta INTEGER;
    DEFINE vPTtnrlogo INTEGER;
    DEFINE vPTescredito VARCHAR(1);
    DEFINE vPTpermitecashback VARCHAR(1);
    DEFINE vPTpermitecashadvance VARCHAR(1);
    DEFINE vPTlimdiariocashadvanceposnac MONEY;
    DEFINE vPTlimmensualcashadvanceposnac MONEY;
    DEFINE vPTlimdiariocashbackposnac MONEY;
    DEFINE vPTlimmensualcashbackposnac MONEY;
    DEFINE vPTporccomcashbacknac DECIMAL(9,2);
    DEFINE vPTporccomcashadvancenac DECIMAL(9,2);
    DEFINE vPTnumtrancashbacklibresmens INTEGER;
    DEFINE vPTnumtrancashadvancelibresmens INTEGER;
    DEFINE vPTmaxtrancashbackdiarias INTEGER;
    DEFINE vPTmaxtrancashbackmensuales INTEGER;
    DEFINE vPTmaxtrancashadvancediarias INTEGER;
    DEFINE vPTmaxtrancashadvancemensuales INTEGER;
    DEFINE vPTpermitetransdigitadas VARCHAR(1);
    DEFINE vPTsoportatranatmcajeropropio VARCHAR(1);
    DEFINE vPTsoportatranatmcajeroconvenio VARCHAR(1);
    DEFINE vPTsoportatranatmcajerored VARCHAR(1);
    DEFINE vPTporccomconsatmconvenio DECIMAL(9,6);
    DEFINE vPTporccomretatmconvenio DECIMAL(9,6);
    DEFINE vPTporccomrevatmconvenio DECIMAL(9,6);
    DEFINE vPTlimdiarioretatmconvenio DECIMAL(19,4);
    DEFINE vPTlimmensretatmconvenio DECIMAL(19,4);
    DEFINE vPTnumtranconsatmconveniolibres INTEGER;
    DEFINE vPTnumtranretatmconveniolibres INTEGER;
    DEFINE vPTmaxtranconsatmconveniodiarias INTEGER;
    DEFINE vPTmaxtranconsatmconveniomens INTEGER;
    DEFINE vPTmaxtranretatmconveniodiarias INTEGER;
    DEFINE vPTmaxtranretatmconveniomens INTEGER;
    DEFINE vPTsoportatranatminternacional VARCHAR(1);
    DEFINE vPTvalidarcvv2 CHAR(1);
    DEFINE vPTlimdiarioqps DECIMAL(14,2) ;
    DEFINE vPTlimdiariocat DECIMAL(14,2) ;
    DEFINE vPTmontomaximotranqps DECIMAL(14,2) ;
    DEFINE vPTmontomaximotrancat DECIMAL(14,2) ;
    DEFINE vPTlimdiarioqpsudis DECIMAL(14,2) ;
    DEFINE vPTlimdiariocatudis DECIMAL(14,2) ;
    DEFINE vPTmontomaximotranqpsudis DECIMAL(14,2) ;
    DEFINE vPTmontomaximotrancatudis DECIMAL(14,2) ;
    DEFINE vPTlimitediariomotovoz DECIMAL(14,2) ;
    DEFINE vPTlimitediariomotoint DECIMAL(14,2) ;
    DEFINE vPTlimitemensualmotovoz DECIMAL(14,2) ;
    DEFINE vPTlimitemensualmotoint DECIMAL(14,2) ;
    DEFINE vPTmaxtransmotovozdiario INTEGER;
    DEFINE vPTmaxtransmotovozmensual INTEGER;
    DEFINE vPTmaxtransmotointdiario INTEGER;
    DEFINE vPTmaxtransmotointmensual INTEGER;
    DEFINE vPTpermitemotovoz VARCHAR(1);
    DEFINE vPTpermitemotointernet VARCHAR(1);
    DEFINE vPTpermitetranstag CHAR(1);
    DEFINE vPTlimitediariotag DECIMAL(14,2);
    DEFINE vPTlimitemensualtag DECIMAL(14,2);
    DEFINE vPTmaxtrandiariotag INTEGER;
    DEFINE vPTmaxtranmensualtag INTEGER;
    DEFINE vPTpermitedeposito CHAR(1);
    DEFINE vPTporccomdepositonac INTEGER;
    DEFINE vPTlimdiariodepositoposnac MONEY;
    DEFINE vPTlimmensualdepositoposnac MONEY;
    DEFINE vPTnumtrandepositolibresmens INTEGER;
    DEFINE vPTmaxtrandepositodiarias INTEGER;
    DEFINE vPTmaxtrandepositomensuales INTEGER;
    DEFINE vPTpermitecontactless_nac_atm CHAR(1);
    DEFINE vPTpermitecontactless_int_atm CHAR(1);
    DEFINE vPTmtomaxdianac_contless_atm DECIMAL(19,4);
    DEFINE vPTmtomaxmesnac_contless_atm DECIMAL(19,4);
    DEFINE vPTmtomaxdiaint_contless_atm DECIMAL(19,4);
    DEFINE vPTmtomaxmesint_contless_atm DECIMAL(19,4);
    DEFINE vPTcontmaxdianac_contless_atm INTEGER;
    DEFINE vPTcontmaxmesnac_contless_atm INTEGER;
    DEFINE vPTcontmaxdiaint_contless_atm INTEGER;
    DEFINE vPTcontmaxmesint_contless_atm INTEGER;
    DEFINE vPTmontomaxunicanac_contless_atm INTEGER;
    DEFINE vPTmontomaxunicanint_contless_atm INTEGER;
    DEFINE vPTpermitecontactless_nac_pos CHAR(1);
    DEFINE vPTpermitecontactless_int_pos CHAR(1);
    DEFINE vPTmtomaxdianac_contless_pos DECIMAL(19,4);
    DEFINE vPTmtomaxmesnac_contless_pos DECIMAL(19,4);
    DEFINE vPTmtomaxdiaint_contless_pos DECIMAL(19,4);
    DEFINE vPTmtomaxmesint_contless_pos DECIMAL(19,4);
    DEFINE vPTcontmaxdianac_contless_pos INTEGER;
    DEFINE vPTcontmaxmesnac_contless_pos INTEGER;
    DEFINE vPTcontmaxdiaint_contless_pos INTEGER;
    DEFINE vPTcontmaxmesint_contless_pos INTEGER;
    DEFINE vPTmontomaxunicanac_contless_pos INTEGER;
    DEFINE vPTmontomaxunicanint_contless_pos INTEGER;
    DEFINE vPTpermitemsi CHAR(1);
    DEFINE vPTcontmaxreversosdiariosatminternacional INTEGER;
    DEFINE vPTpermite_retiro_sin_tarjeta_atm CHAR(1);
    DEFINE vPTcampaniaNotif INTEGER;

    DEFINE vOncodproductotarjeta VARCHAR(3);
    DEFINE vOndescproducto VARCHAR(30);
    DEFINE vOnporccomconsatmnac DECIMAL(9,6);
    DEFINE vOnporccomconsatmint DECIMAL(9,6);
    DEFINE vOnporccomretatmnac DECIMAL(9,6);
    DEFINE vOnporccomretatmint DECIMAL(9,6);
    DEFINE vOnporccomcompraposnac DECIMAL(9,6);
    DEFINE vOnporccomcompraposint DECIMAL(9,6);
    DEFINE vOnporccomrevatmnac DECIMAL(9,6);
    DEFINE vOnporccomrevatmint DECIMAL(9,6);
    DEFINE vOnporccomrevposnac DECIMAL(9,6);
    DEFINE vOnporccomrevposint DECIMAL(9,6);
    DEFINE vOnporccomfzdaposnac DECIMAL(9,6);
    DEFINE vOnporccomfzdaposint DECIMAL(9,6);
    DEFINE vOnlimdiarioretatmnac DECIMAL(19,4);
    DEFINE vOnlimdiarioretatmint DECIMAL(19,4);
    DEFINE vOnlimmensretatmnac DECIMAL(19,4);
    DEFINE vOnlimmensretatmint DECIMAL(19,4);
    DEFINE vOnlimdiariocompraposnac DECIMAL(19,4);
    DEFINE vOnlimdiariocompraposint DECIMAL(19,4);
    DEFINE vOnlimmenscompraposnac DECIMAL(19,4);
    DEFINE vOnlimmenscompraposint DECIMAL(19,4);
    DEFINE vOnlimhdretatmnac DECIMAL(19,4);
    DEFINE vOnlimhdretatmint DECIMAL(19,4);
    DEFINE vOnlimhdcompraposnac DECIMAL(19,4);
    DEFINE vOnlimhdcompraposint DECIMAL(19,4);
    DEFINE vOnnumtranhdretatmnac INTEGER;
    DEFINE vOnnumtranhdretatmint INTEGER;
    DEFINE vOnnumtranhdcompraposnac INTEGER;
    DEFINE vOnnumtranhdcompraposint INTEGER;
    DEFINE vOnnumtranconsatmlibresmens INTEGER;
    DEFINE vOnnumtranretatmlibresmens INTEGER;
    DEFINE vOnnumtrancompraposlibresmens INTEGER;
    DEFINE vOnmaxtranconsatmdiarias INTEGER;
    DEFINE vOnmaxtranretatmdiarias INTEGER;
    DEFINE vOnmaxtrancompraposdiarias INTEGER;
    DEFINE vOnmaxtranconsatmmens INTEGER;
    DEFINE vOnmaxtranretatmmens INTEGER;
    DEFINE vOnmaxtrancompraposmens INTEGER;
    DEFINE vOnsaldomaxamostrar DECIMAL(19,4);
    DEFINE vOnporccomconsatmpropio DECIMAL(9,6);
    DEFINE vOnporccomretatmpropio DECIMAL(9,6);
    DEFINE vOnporccomrevatmpropio DECIMAL(9,6);
    DEFINE vOnlimdiarioretatmpropio DECIMAL(19,4);
    DEFINE vOnlimmensretatmpropio DECIMAL(19,4);
    DEFINE vOnlimhdretatmpropio DECIMAL(19,4);
    DEFINE vOnnumtranhdretatmpropio INTEGER;
    DEFINE vOnnumtranconsatmlibresmenspropio INTEGER;
    DEFINE vOnnumtranretatmlibresmenspropio INTEGER;
    DEFINE vOnmaxtranconsatmdiariaspropio INTEGER;
    DEFINE vOnmaxtranretatmdiariaspropio INTEGER;
    DEFINE vOnmaxtranconsatmmenspropio INTEGER;
    DEFINE vOnmaxtranretatmmenspropio INTEGER;
    DEFINE vOntarjetanorelacionada VARCHAR(1);
    DEFINE vOncuentamaestra VARCHAR(13);
    DEFINE vOnsaldominimo DECIMAL(19,4);
    DEFINE vOncodigoeventoerror VARCHAR(4);
    DEFINE vOnestatusprocesocargasaldos VARCHAR(1);
    DEFINE vOnestatusprocesocancelacion VARCHAR(1);
    DEFINE vOnregistrostotalcargasaldos INTEGER;
    DEFINE vOnregistrosavancecargasaldos INTEGER;
    DEFINE vOnregistrostotalcancelacion INTEGER;
    DEFINE vOnregistrosavancecancelacion INTEGER;
    DEFINE vOntnrcobracomisiones VARCHAR(1);
    DEFINE vOntnrporccomconsatmnac DECIMAL(9,6);
    DEFINE vOntnrporccomconsatmint DECIMAL(9,6);
    DEFINE vOntnrporccomretatmnac DECIMAL(9,6);
    DEFINE vOntnrporccomretatmint DECIMAL(9,6);
    DEFINE vOntnrporccomcompraposnac DECIMAL(9,6);
    DEFINE vOntnrporccomcompraposint DECIMAL(9,6);
    DEFINE vOntnrporccomrevatmnac DECIMAL(9,6);
    DEFINE vOntnrporccomrevatmint DECIMAL(9,6);
    DEFINE vOntnrporccomrevposnac DECIMAL(9,6);
    DEFINE vOntnrporccomrevposint DECIMAL(9,6);
    DEFINE vOntnrporccomfzdaposnac DECIMAL(9,6);
    DEFINE vOntnrporccomfzdaposint DECIMAL(9,6);
    DEFINE vOntnrporccomconsatmpropio DECIMAL(9,6);
    DEFINE vOntnrporccomretatmpropio DECIMAL(9,6);
    DEFINE vOntnrporccomrevatmpropio DECIMAL(9,6);
    DEFINE vOncorporativa VARCHAR(1);
    DEFINE vOnnombreempresa VARCHAR(30);
    DEFINE vOncomisioncargasaldos DECIMAL(19,4);
    DEFINE vOntnrgenintervalo INTEGER;
    DEFINE vOntnrgentipointervalo VARCHAR(2);
    DEFINE vOntnrgenfechahorainicio DATETIME YEAR to FRACTION(5);
    DEFINE vOntnrgenfechahorafinal DATETIME YEAR to FRACTION(5);
    DEFINE vOntnrgenrutaarchivo VARCHAR(255);
    DEFINE vOncobracomisionesenlinea VARCHAR(1);
    DEFINE vOnpermitecomisionespendientes VARCHAR(1);
    DEFINE vOnestatusprocesoasignacionmasiva VARCHAR(1);
    DEFINE vOnregistrostotalasignacionmasiva INTEGER;
    DEFINE vOnregistrosavanceasignacionmasiva INTEGER;
    DEFINE vOntranscom VARCHAR(4);
    DEFINE vOncobracomanualidad VARCHAR(1);
    DEFINE vOnimpcomanualidad DECIMAL(19,4);
    DEFINE vOnfechainicomanualidad DATETIME YEAR to FRACTION(5);
    DEFINE vOnpermitetnrpersonalizadas VARCHAR(1);
    DEFINE vOntranscomexpedicion VARCHAR(4);
    DEFINE vOncobracomexpedicion VARCHAR(1);
    DEFINE vOnimpcomexpedicion DECIMAL(19,4);
    DEFINE vOntranscomrenovacion VARCHAR(4);
    DEFINE vOncobracomrenovacion VARCHAR(1);
    DEFINE vOnimpcomrenovacion DECIMAL(19,4);
    DEFINE vOntnrcuentadispersadora VARCHAR(13);
    DEFINE vOntnrtranscargoctadispersadora VARCHAR(4);
    DEFINE vOntnrtransabonoctainfraestructura VARCHAR(4);
    DEFINE vOntnrtranscargoctainfraestructura VARCHAR(4);
    DEFINE vOntnrtransabonoctadispersadora VARCHAR(4);
    DEFINE vOntnrutilizactainfraestructura VARCHAR(1);
    DEFINE vOntnrhabilitarproteccionsaldosasignados VARCHAR(1);
    DEFINE vOntnrbloquearreversionasignaciones VARCHAR(1);
    DEFINE vOntnrlapsoreversion INTEGER;
    DEFINE vOntnrcongelarsaldoindividual VARCHAR(1);
    DEFINE vOntnrlapsocongelarsaldo INTEGER;
    DEFINE vOntnrimagenactualizada VARCHAR(1);
    DEFINE vOnestatusprocesosolicitudtarjeta VARCHAR(1);
    DEFINE vOnregistrostotalsolicitudtarjeta INTEGER;
    DEFINE vOnregistrosavancesolicitudtarjeta INTEGER;
    DEFINE vOntnrlogo INTEGER;
    DEFINE vOnescredito VARCHAR(1);
    DEFINE vOnpermitecashback VARCHAR(1);
    DEFINE vOnpermitecashadvance VARCHAR(1);
    DEFINE vOnlimdiariocashadvanceposnac MONEY;
    DEFINE vOnlimmensualcashadvanceposnac MONEY;
    DEFINE vOnlimdiariocashbackposnac MONEY;
    DEFINE vOnlimmensualcashbackposnac MONEY;
    DEFINE vOnporccomcashbacknac DECIMAL(9,2);
    DEFINE vOnporccomcashadvancenac DECIMAL(9,2);
    DEFINE vOnnumtrancashbacklibresmens INTEGER;
    DEFINE vOnnumtrancashadvancelibresmens INTEGER;
    DEFINE vOnmaxtrancashbackdiarias INTEGER;
    DEFINE vOnmaxtrancashbackmensuales INTEGER;
    DEFINE vOnmaxtrancashadvancediarias INTEGER;
    DEFINE vOnmaxtrancashadvancemensuales INTEGER;
    DEFINE vOnpermitetransdigitadas VARCHAR(1);
    DEFINE vOnsoportatranatmcajeropropio VARCHAR(1);
    DEFINE vOnsoportatranatmcajeroconvenio VARCHAR(1);
    DEFINE vOnsoportatranatmcajerored VARCHAR(1);
    DEFINE vOnporccomconsatmconvenio DECIMAL(9,6);
    DEFINE vOnporccomretatmconvenio DECIMAL(9,6);
    DEFINE vOnporccomrevatmconvenio DECIMAL(9,6);
    DEFINE vOnlimdiarioretatmconvenio DECIMAL(19,4);
    DEFINE vOnlimmensretatmconvenio DECIMAL(19,4);
    DEFINE vOnnumtranconsatmconveniolibres INTEGER;
    DEFINE vOnnumtranretatmconveniolibres INTEGER;
    DEFINE vOnmaxtranconsatmconveniodiarias INTEGER;
    DEFINE vOnmaxtranconsatmconveniomens INTEGER;
    DEFINE vOnmaxtranretatmconveniodiarias INTEGER;
    DEFINE vOnmaxtranretatmconveniomens INTEGER;
    DEFINE vOnsoportatranatminternacional VARCHAR(1);
    DEFINE vOnvalidarcvv2 CHAR(1);
    DEFINE vOnlimdiarioqps DECIMAL(14,2) ;
    DEFINE vOnlimdiariocat DECIMAL(14,2) ;
    DEFINE vOnmontomaximotranqps DECIMAL(14,2) ;
    DEFINE vOnmontomaximotrancat DECIMAL(14,2) ;
    DEFINE vOnlimdiarioqpsudis DECIMAL(14,2) ;
    DEFINE vOnlimdiariocatudis DECIMAL(14,2) ;
    DEFINE vOnmontomaximotranqpsudis DECIMAL(14,2) ;
    DEFINE vOnmontomaximotrancatudis DECIMAL(14,2) ;
    DEFINE vOnlimitediariomotovoz DECIMAL(14,2) ;
    DEFINE vOnlimitediariomotoint DECIMAL(14,2) ;
    DEFINE vOnlimitemensualmotovoz DECIMAL(14,2) ;
    DEFINE vOnlimitemensualmotoint DECIMAL(14,2) ;
    DEFINE vOnmaxtransmotovozdiario INTEGER;
    DEFINE vOnmaxtransmotovozmensual INTEGER;
    DEFINE vOnmaxtransmotointdiario INTEGER;
    DEFINE vOnmaxtransmotointmensual INTEGER;
    DEFINE vOnpermitemotovoz VARCHAR(1);
    DEFINE vOnpermitemotointernet VARCHAR(1);
    DEFINE vOnpermitetranstag CHAR(1);
    DEFINE vOnlimitediariotag DECIMAL(14,2);
    DEFINE vOnlimitemensualtag DECIMAL(14,2);
    DEFINE vOnmaxtrandiariotag INTEGER;
    DEFINE vOnmaxtranmensualtag INTEGER;
    DEFINE vOnpermitedeposito CHAR(1);
    DEFINE vOnporccomdepositonac INTEGER;
    DEFINE vOnlimdiariodepositoposnac MONEY;
    DEFINE vOnlimmensualdepositoposnac MONEY;
    DEFINE vOnnumtrandepositolibresmens INTEGER;
    DEFINE vOnmaxtrandepositodiarias INTEGER;
    DEFINE vOnmaxtrandepositomensuales INTEGER;
    DEFINE vOnpermitecontactless_nac_atm CHAR(1);
    DEFINE vOnpermitecontactless_int_atm CHAR(1);
    DEFINE vOnmtomaxdianac_contless_atm DECIMAL(19,4);
    DEFINE vOnmtomaxmesnac_contless_atm DECIMAL(19,4);
    DEFINE vOnmtomaxdiaint_contless_atm DECIMAL(19,4);
    DEFINE vOnmtomaxmesint_contless_atm DECIMAL(19,4);
    DEFINE vOncontmaxdianac_contless_atm INTEGER;
    DEFINE vOncontmaxmesnac_contless_atm INTEGER;
    DEFINE vOncontmaxdiaint_contless_atm INTEGER;
    DEFINE vOncontmaxmesint_contless_atm INTEGER;
    DEFINE vOnmontomaxunicanac_contless_atm INTEGER;
    DEFINE vOnmontomaxunicanint_contless_atm INTEGER;
    DEFINE vOnpermitecontactless_nac_pos CHAR(1);
    DEFINE vOnpermitecontactless_int_pos CHAR(1);
    DEFINE vOnmtomaxdianac_contless_pos DECIMAL(19,4);
    DEFINE vOnmtomaxmesnac_contless_pos DECIMAL(19,4);
    DEFINE vOnmtomaxdiaint_contless_pos DECIMAL(19,4);
    DEFINE vOnmtomaxmesint_contless_pos DECIMAL(19,4);
    DEFINE vOncontmaxdianac_contless_pos INTEGER;
    DEFINE vOncontmaxmesnac_contless_pos INTEGER;
    DEFINE vOncontmaxdiaint_contless_pos INTEGER;
    DEFINE vOncontmaxmesint_contless_pos INTEGER;
    DEFINE vOnmontomaxunicanac_contless_pos INTEGER;
    DEFINE vOnmontomaxunicanint_contless_pos INTEGER;
    DEFINE vOnpermitemsi CHAR(1);
    DEFINE vOncontmaxreversosdiariosatminternacional INTEGER;
    DEFINE vOnpermite_retiro_sin_tarjeta_atm CHAR(1);
    DEFINE vOncampaniaNotif INTEGER;
    
    DEFINE vContadorActualizacion INTEGER;
    
    LET vPTcodproductotarjeta = '';
    LET vPTdescproducto = '';
    LET vPTporccomconsatmnac = '';
    LET vPTporccomconsatmint = '';
    LET vPTporccomretatmnac = '';
    LET vPTporccomretatmint = '';
    LET vPTporccomcompraposnac = '';
    LET vPTporccomcompraposint = '';
    LET vPTporccomrevatmnac = '';
    LET vPTporccomrevatmint = '';
    LET vPTporccomrevposnac = '';
    LET vPTporccomrevposint = '';
    LET vPTporccomfzdaposnac = '';
    LET vPTporccomfzdaposint = '';
    LET vPTlimdiarioretatmnac = '';
    LET vPTlimdiarioretatmint = '';
    LET vPTlimmensretatmnac = '';
    LET vPTlimmensretatmint = '';
    LET vPTlimdiariocompraposnac = '';
    LET vPTlimdiariocompraposint = '';
    LET vPTlimmenscompraposnac = '';
    LET vPTlimmenscompraposint = '';
    LET vPTlimhdretatmnac = '';
    LET vPTlimhdretatmint = '';
    LET vPTlimhdcompraposnac = '';
    LET vPTlimhdcompraposint = '';
    LET vPTnumtranhdretatmnac = '';
    LET vPTnumtranhdretatmint = '';
    LET vPTnumtranhdcompraposnac = '';
    LET vPTnumtranhdcompraposint = '';
    LET vPTnumtranconsatmlibresmens = '';
    LET vPTnumtranretatmlibresmens = '';
    LET vPTnumtrancompraposlibresmens = '';
    LET vPTmaxtranconsatmdiarias = '';
    LET vPTmaxtranretatmdiarias = '';
    LET vPTmaxtrancompraposdiarias = '';
    LET vPTmaxtranconsatmmens = '';
    LET vPTmaxtranretatmmens = '';
    LET vPTmaxtrancompraposmens = '';
    LET vPTsaldomaxamostrar = '';
    LET vPTporccomconsatmpropio = '';
    LET vPTporccomretatmpropio = '';
    LET vPTporccomrevatmpropio = '';
    LET vPTlimdiarioretatmpropio = '';
    LET vPTlimmensretatmpropio = '';
    LET vPTlimhdretatmpropio = '';
    LET vPTnumtranhdretatmpropio = '';
    LET vPTnumtranconsatmlibresmenspropio = '';
    LET vPTnumtranretatmlibresmenspropio = '';
    LET vPTmaxtranconsatmdiariaspropio = '';
    LET vPTmaxtranretatmdiariaspropio = '';
    LET vPTmaxtranconsatmmenspropio = '';
    LET vPTmaxtranretatmmenspropio = '';
    LET vPTtarjetanorelacionada = '';
    LET vPTcuentamaestra = '';
    LET vPTsaldominimo = '';
    LET vPTcodigoeventoerror = '';
    LET vPTestatusprocesocargasaldos = '';
    LET vPTestatusprocesocancelacion = '';
    LET vPTregistrostotalcargasaldos = '';
    LET vPTregistrosavancecargasaldos = '';
    LET vPTregistrostotalcancelacion = '';
    LET vPTregistrosavancecancelacion = '';
    LET vPTtnrcobracomisiones = '';
    LET vPTtnrporccomconsatmnac = '';
    LET vPTtnrporccomconsatmint = '';
    LET vPTtnrporccomretatmnac = '';
    LET vPTtnrporccomretatmint = '';
    LET vPTtnrporccomcompraposnac = '';
    LET vPTtnrporccomcompraposint = '';
    LET vPTtnrporccomrevatmnac = '';
    LET vPTtnrporccomrevatmint = '';
    LET vPTtnrporccomrevposnac = '';
    LET vPTtnrporccomrevposint = '';
    LET vPTtnrporccomfzdaposnac = '';
    LET vPTtnrporccomfzdaposint = '';
    LET vPTtnrporccomconsatmpropio = '';
    LET vPTtnrporccomretatmpropio = '';
    LET vPTtnrporccomrevatmpropio = '';
    LET vPTcorporativa = '';
    LET vPTnombreempresa = '';
    LET vPTcomisioncargasaldos = '';
    LET vPTtnrgenintervalo = '';
    LET vPTtnrgentipointervalo = '';
    LET vPTtnrgenfechahorainicio = '';
    LET vPTtnrgenfechahorafinal = '';
    LET vPTtnrgenrutaarchivo = '';
    LET vPTcobracomisionesenlinea = '';
    LET vPTpermitecomisionespendientes = '';
    LET vPTestatusprocesoasignacionmasiva = '';
    LET vPTregistrostotalasignacionmasiva = '';
    LET vPTregistrosavanceasignacionmasiva = '';
    LET vPTtranscom = '';
    LET vPTcobracomanualidad = '';
    LET vPTimpcomanualidad = '';
    LET vPTfechainicomanualidad = '';
    LET vPTpermitetnrpersonalizadas = '';
    LET vPTtranscomexpedicion = '';
    LET vPTcobracomexpedicion = '';
    LET vPTimpcomexpedicion = '';
    LET vPTtranscomrenovacion = '';
    LET vPTcobracomrenovacion = '';
    LET vPTimpcomrenovacion = '';
    LET vPTtnrcuentadispersadora = '';
    LET vPTtnrtranscargoctadispersadora = '';
    LET vPTtnrtransabonoctainfraestructura = '';
    LET vPTtnrtranscargoctainfraestructura = '';
    LET vPTtnrtransabonoctadispersadora = '';
    LET vPTtnrutilizactainfraestructura = '';
    LET vPTtnrhabilitarproteccionsaldosasignados = '';
    LET vPTtnrbloquearreversionasignaciones = '';
    LET vPTtnrlapsoreversion = '';
    LET vPTtnrcongelarsaldoindividual = '';
    LET vPTtnrlapsocongelarsaldo = '';
    LET vPTtnrimagenactualizada = '';
    LET vPTestatusprocesosolicitudtarjeta = '';
    LET vPTregistrostotalsolicitudtarjeta = '';
    LET vPTregistrosavancesolicitudtarjeta = '';
    LET vPTtnrlogo = '';
    LET vPTescredito = '';
    LET vPTpermitecashback = '';
    LET vPTpermitecashadvance = '';
    LET vPTlimdiariocashadvanceposnac = '';
    LET vPTlimmensualcashadvanceposnac = '';
    LET vPTlimdiariocashbackposnac = '';
    LET vPTlimmensualcashbackposnac = '';
    LET vPTporccomcashbacknac = '';
    LET vPTporccomcashadvancenac = '';
    LET vPTnumtrancashbacklibresmens = '';
    LET vPTnumtrancashadvancelibresmens = '';
    LET vPTmaxtrancashbackdiarias = '';
    LET vPTmaxtrancashbackmensuales = '';
    LET vPTmaxtrancashadvancediarias = '';
    LET vPTmaxtrancashadvancemensuales = '';
    LET vPTpermitetransdigitadas = '';
    LET vPTsoportatranatmcajeropropio = '';
    LET vPTsoportatranatmcajeroconvenio = '';
    LET vPTsoportatranatmcajerored = '';
    LET vPTporccomconsatmconvenio = '';
    LET vPTporccomretatmconvenio = '';
    LET vPTporccomrevatmconvenio = '';
    LET vPTlimdiarioretatmconvenio = '';
    LET vPTlimmensretatmconvenio = '';
    LET vPTnumtranconsatmconveniolibres = '';
    LET vPTnumtranretatmconveniolibres = '';
    LET vPTmaxtranconsatmconveniodiarias = '';
    LET vPTmaxtranconsatmconveniomens = '';
    LET vPTmaxtranretatmconveniodiarias = '';
    LET vPTmaxtranretatmconveniomens = '';
    LET vPTsoportatranatminternacional = '';
    LET vPTvalidarcvv2 = '';
    LET vPTlimdiarioqps = '';
    LET vPTlimdiariocat = '';
    LET vPTmontomaximotranqps = '';
    LET vPTmontomaximotrancat = '';
    LET vPTlimdiarioqpsudis = '';
    LET vPTlimdiariocatudis = '';
    LET vPTmontomaximotranqpsudis = '';
    LET vPTmontomaximotrancatudis = '';
    LET vPTlimitediariomotovoz = '';
    LET vPTlimitediariomotoint = '';
    LET vPTlimitemensualmotovoz = '';
    LET vPTlimitemensualmotoint = '';
    LET vPTmaxtransmotovozdiario = '';
    LET vPTmaxtransmotovozmensual = '';
    LET vPTmaxtransmotointdiario = '';
    LET vPTmaxtransmotointmensual = '';
    LET vPTpermitemotovoz = '';
    LET vPTpermitemotointernet = '';
    LET vPTpermitetranstag = '';
    LET vPTlimitediariotag = '';
    LET vPTlimitemensualtag = '';
    LET vPTmaxtrandiariotag = '';
    LET vPTmaxtranmensualtag = '';
    LET vPTpermitedeposito = '';
    LET vPTporccomdepositonac = '';
    LET vPTlimdiariodepositoposnac = '';
    LET vPTlimmensualdepositoposnac = '';
    LET vPTnumtrandepositolibresmens = '';
    LET vPTmaxtrandepositodiarias = '';
    LET vPTmaxtrandepositomensuales = '';
    LET vPTpermitecontactless_nac_atm = '';
    LET vPTpermitecontactless_int_atm = '';
    LET vPTmtomaxdianac_contless_atm = '';
    LET vPTmtomaxmesnac_contless_atm = '';
    LET vPTmtomaxdiaint_contless_atm = '';
    LET vPTmtomaxmesint_contless_atm = '';
    LET vPTcontmaxdianac_contless_atm = '';
    LET vPTcontmaxmesnac_contless_atm = '';
    LET vPTcontmaxdiaint_contless_atm = '';
    LET vPTcontmaxmesint_contless_atm = '';
    LET vPTmontomaxunicanac_contless_atm = '';
    LET vPTmontomaxunicanint_contless_atm = '';
    LET vPTpermitecontactless_nac_pos = '';
    LET vPTpermitecontactless_int_pos = '';
    LET vPTmtomaxdianac_contless_pos = '';
    LET vPTmtomaxmesnac_contless_pos = '';
    LET vPTmtomaxdiaint_contless_pos = '';
    LET vPTmtomaxmesint_contless_pos = '';
    LET vPTcontmaxdianac_contless_pos = '';
    LET vPTcontmaxmesnac_contless_pos = '';
    LET vPTcontmaxdiaint_contless_pos = '';
    LET vPTcontmaxmesint_contless_pos = '';
    LET vPTmontomaxunicanac_contless_pos = '';
    LET vPTmontomaxunicanint_contless_pos = '';
    LET vPTpermitemsi = '';
    LET vPTcontmaxreversosdiariosatminternacional = '';
    LET vPTpermite_retiro_sin_tarjeta_atm = '';
    LET vPTcampaniaNotif = '';
    ----
    LET vOncodproductotarjeta = '';
    LET vOndescproducto = '';
    LET vOnporccomconsatmnac = '';
    LET vOnporccomconsatmint = '';
    LET vOnporccomretatmnac = '';
    LET vOnporccomretatmint = '';
    LET vOnporccomcompraposnac = '';
    LET vOnporccomcompraposint = '';
    LET vOnporccomrevatmnac = '';
    LET vOnporccomrevatmint = '';
    LET vOnporccomrevposnac = '';
    LET vOnporccomrevposint = '';
    LET vOnporccomfzdaposnac = '';
    LET vOnporccomfzdaposint = '';
    LET vOnlimdiarioretatmnac = '';
    LET vOnlimdiarioretatmint = '';
    LET vOnlimmensretatmnac = '';
    LET vOnlimmensretatmint = '';
    LET vOnlimdiariocompraposnac = '';
    LET vOnlimdiariocompraposint = '';
    LET vOnlimmenscompraposnac = '';
    LET vOnlimmenscompraposint = '';
    LET vOnlimhdretatmnac = '';
    LET vOnlimhdretatmint = '';
    LET vOnlimhdcompraposnac = '';
    LET vOnlimhdcompraposint = '';
    LET vOnnumtranhdretatmnac = '';
    LET vOnnumtranhdretatmint = '';
    LET vOnnumtranhdcompraposnac = '';
    LET vOnnumtranhdcompraposint = '';
    LET vOnnumtranconsatmlibresmens = '';
    LET vOnnumtranretatmlibresmens = '';
    LET vOnnumtrancompraposlibresmens = '';
    LET vOnmaxtranconsatmdiarias = '';
    LET vOnmaxtranretatmdiarias = '';
    LET vOnmaxtrancompraposdiarias = '';
    LET vOnmaxtranconsatmmens = '';
    LET vOnmaxtranretatmmens = '';
    LET vOnmaxtrancompraposmens = '';
    LET vOnsaldomaxamostrar = '';
    LET vOnporccomconsatmpropio = '';
    LET vOnporccomretatmpropio = '';
    LET vOnporccomrevatmpropio = '';
    LET vOnlimdiarioretatmpropio = '';
    LET vOnlimmensretatmpropio = '';
    LET vOnlimhdretatmpropio = '';
    LET vOnnumtranhdretatmpropio = '';
    LET vOnnumtranconsatmlibresmenspropio = '';
    LET vOnnumtranretatmlibresmenspropio = '';
    LET vOnmaxtranconsatmdiariaspropio = '';
    LET vOnmaxtranretatmdiariaspropio = '';
    LET vOnmaxtranconsatmmenspropio = '';
    LET vOnmaxtranretatmmenspropio = '';
    LET vOntarjetanorelacionada = '';
    LET vOncuentamaestra = '';
    LET vOnsaldominimo = '';
    LET vOncodigoeventoerror = '';
    LET vOnestatusprocesocargasaldos = '';
    LET vOnestatusprocesocancelacion = '';
    LET vOnregistrostotalcargasaldos = '';
    LET vOnregistrosavancecargasaldos = '';
    LET vOnregistrostotalcancelacion = '';
    LET vOnregistrosavancecancelacion = '';
    LET vOntnrcobracomisiones = '';
    LET vOntnrporccomconsatmnac = '';
    LET vOntnrporccomconsatmint = '';
    LET vOntnrporccomretatmnac = '';
    LET vOntnrporccomretatmint = '';
    LET vOntnrporccomcompraposnac = '';
    LET vOntnrporccomcompraposint = '';
    LET vOntnrporccomrevatmnac = '';
    LET vOntnrporccomrevatmint = '';
    LET vOntnrporccomrevposnac = '';
    LET vOntnrporccomrevposint = '';
    LET vOntnrporccomfzdaposnac = '';
    LET vOntnrporccomfzdaposint = '';
    LET vOntnrporccomconsatmpropio = '';
    LET vOntnrporccomretatmpropio = '';
    LET vOntnrporccomrevatmpropio = '';
    LET vOncorporativa = '';
    LET vOnnombreempresa = '';
    LET vOncomisioncargasaldos = '';
    LET vOntnrgenintervalo = '';
    LET vOntnrgentipointervalo = '';
    LET vOntnrgenfechahorainicio = '';
    LET vOntnrgenfechahorafinal = '';
    LET vOntnrgenrutaarchivo = '';
    LET vOncobracomisionesenlinea = '';
    LET vOnpermitecomisionespendientes = '';
    LET vOnestatusprocesoasignacionmasiva = '';
    LET vOnregistrostotalasignacionmasiva = '';
    LET vOnregistrosavanceasignacionmasiva = '';
    LET vOntranscom = '';
    LET vOncobracomanualidad = '';
    LET vOnimpcomanualidad = '';
    LET vOnfechainicomanualidad = '';
    LET vOnpermitetnrpersonalizadas = '';
    LET vOntranscomexpedicion = '';
    LET vOncobracomexpedicion = '';
    LET vOnimpcomexpedicion = '';
    LET vOntranscomrenovacion = '';
    LET vOncobracomrenovacion = '';
    LET vOnimpcomrenovacion = '';
    LET vOntnrcuentadispersadora = '';
    LET vOntnrtranscargoctadispersadora = '';
    LET vOntnrtransabonoctainfraestructura = '';
    LET vOntnrtranscargoctainfraestructura = '';
    LET vOntnrtransabonoctadispersadora = '';
    LET vOntnrutilizactainfraestructura = '';
    LET vOntnrhabilitarproteccionsaldosasignados = '';
    LET vOntnrbloquearreversionasignaciones = '';
    LET vOntnrlapsoreversion = '';
    LET vOntnrcongelarsaldoindividual = '';
    LET vOntnrlapsocongelarsaldo = '';
    LET vOntnrimagenactualizada = '';
    LET vOnestatusprocesosolicitudtarjeta = '';
    LET vOnregistrostotalsolicitudtarjeta = '';
    LET vOnregistrosavancesolicitudtarjeta = '';
    LET vOntnrlogo = '';
    LET vOnescredito = '';
    LET vOnpermitecashback = '';
    LET vOnpermitecashadvance = '';
    LET vOnlimdiariocashadvanceposnac = '';
    LET vOnlimmensualcashadvanceposnac = '';
    LET vOnlimdiariocashbackposnac = '';
    LET vOnlimmensualcashbackposnac = '';
    LET vOnporccomcashbacknac = '';
    LET vOnporccomcashadvancenac = '';
    LET vOnnumtrancashbacklibresmens = '';
    LET vOnnumtrancashadvancelibresmens = '';
    LET vOnmaxtrancashbackdiarias = '';
    LET vOnmaxtrancashbackmensuales = '';
    LET vOnmaxtrancashadvancediarias = '';
    LET vOnmaxtrancashadvancemensuales = '';
    LET vOnpermitetransdigitadas = '';
    LET vOnsoportatranatmcajeropropio = '';
    LET vOnsoportatranatmcajeroconvenio = '';
    LET vOnsoportatranatmcajerored = '';
    LET vOnporccomconsatmconvenio = '';
    LET vOnporccomretatmconvenio = '';
    LET vOnporccomrevatmconvenio = '';
    LET vOnlimdiarioretatmconvenio = '';
    LET vOnlimmensretatmconvenio = '';
    LET vOnnumtranconsatmconveniolibres = '';
    LET vOnnumtranretatmconveniolibres = '';
    LET vOnmaxtranconsatmconveniodiarias = '';
    LET vOnmaxtranconsatmconveniomens = '';
    LET vOnmaxtranretatmconveniodiarias = '';
    LET vOnmaxtranretatmconveniomens = '';
    LET vOnsoportatranatminternacional = '';
    LET vOnvalidarcvv2 = '';
    LET vOnlimdiarioqps = '';
    LET vOnlimdiariocat = '';
    LET vOnmontomaximotranqps = '';
    LET vOnmontomaximotrancat = '';
    LET vOnlimdiarioqpsudis = '';
    LET vOnlimdiariocatudis = '';
    LET vOnmontomaximotranqpsudis = '';
    LET vOnmontomaximotrancatudis = '';
    LET vOnlimitediariomotovoz = '';
    LET vOnlimitediariomotoint = '';
    LET vOnlimitemensualmotovoz = '';
    LET vOnlimitemensualmotoint = '';
    LET vOnmaxtransmotovozdiario = '';
    LET vOnmaxtransmotovozmensual = '';
    LET vOnmaxtransmotointdiario = '';
    LET vOnmaxtransmotointmensual = '';
    LET vOnpermitemotovoz = '';
    LET vOnpermitemotointernet = '';
    LET vOnpermitetranstag = '';
    LET vOnlimitediariotag = '';
    LET vOnlimitemensualtag = '';
    LET vOnmaxtrandiariotag = '';
    LET vOnmaxtranmensualtag = '';
    LET vOnpermitedeposito = '';
    LET vOnporccomdepositonac = '';
    LET vOnlimdiariodepositoposnac = '';
    LET vOnlimmensualdepositoposnac = '';
    LET vOnnumtrandepositolibresmens = '';
    LET vOnmaxtrandepositodiarias = '';
    LET vOnmaxtrandepositomensuales = '';
    LET vOnpermitecontactless_nac_atm = '';
    LET vOnpermitecontactless_int_atm = '';
    LET vOnmtomaxdianac_contless_atm = '';
    LET vOnmtomaxmesnac_contless_atm = '';
    LET vOnmtomaxdiaint_contless_atm = '';
    LET vOnmtomaxmesint_contless_atm = '';
    LET vOncontmaxdianac_contless_atm = '';
    LET vOncontmaxmesnac_contless_atm = '';
    LET vOncontmaxdiaint_contless_atm = '';
    LET vOncontmaxmesint_contless_atm = '';
    LET vOnmontomaxunicanac_contless_atm = '';
    LET vOnmontomaxunicanint_contless_atm = '';
    LET vOnpermitecontactless_nac_pos = '';
    LET vOnpermitecontactless_int_pos = '';
    LET vOnmtomaxdianac_contless_pos = '';
    LET vOnmtomaxmesnac_contless_pos = '';
    LET vOnmtomaxdiaint_contless_pos = '';
    LET vOnmtomaxmesint_contless_pos = '';
    LET vOncontmaxdianac_contless_pos = '';
    LET vOncontmaxmesnac_contless_pos = '';
    LET vOncontmaxdiaint_contless_pos = '';
    LET vOncontmaxmesint_contless_pos = '';
    LET vOnmontomaxunicanac_contless_pos = '';
    LET vOnmontomaxunicanint_contless_pos = '';
    LET vOnpermitemsi = '';
    LET vOncontmaxreversosdiariosatminternacional = '';
    LET vOnpermite_retiro_sin_tarjeta_atm = '';
    LET vOncampaniaNotif = '';
    
    LET vContadorActualizacion = 0;
    
    LET SQLERR = '';
	LET ISAM_ERR = '';
	LET ERROR_INFO = '';
    LET RUTA_DESTINO = '/RESPALDOSNEW/';
    
    
    LET vCodigoRetorno = '00000';
    LET vMensajeRetorno = 'Sin Datos Modificados  Prod Tarjeta';
    
    --SET DEBUG FILE TO RUTA_DESTINO|| 'sp_comparar_info_tbl_prodtar.out';
    --TRACE ON;
    
	BEGIN
    
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_DESTINO || "excep_sp_comparar_info_tbl_prodtar.err.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET vCodigoRetorno = SQLERR;
                LET vMensajeRetorno = ERROR_INFO;                
                RETURN vCodigoRetorno, vMensajeRetorno;
            END IF;
			
        END EXCEPTION;
		
        SET ISOLATION TO DIRTY READ; 
        SET LOCK MODE TO WAIT 3;
        
        
        FOREACH curIterarValidAuth WITH HOLD FOR
            SELECT         
            {+AVOID_FULL (bditarjeta:respaldo_control_prod)}            
            codproductotarjeta, descproducto, porccomconsatmnac, porccomconsatmint, porccomretatmnac, porccomretatmint,
            porccomcompraposnac, porccomcompraposint, porccomrevatmnac, porccomrevatmint, porccomrevposnac, porccomrevposint,
            porccomfzdaposnac, porccomfzdaposint, limdiarioretatmnac, limdiarioretatmint, limmensretatmnac, limmensretatmint,
            limdiariocompraposnac, limdiariocompraposint, limmenscompraposnac, limmenscompraposint, limhdretatmnac,
            limhdretatmint, limhdcompraposnac, limhdcompraposint, numtranhdretatmnac, numtranhdretatmint, numtranhdcompraposnac,
            numtranhdcompraposint, numtranconsatmlibresmens, numtranretatmlibresmens, numtrancompraposlibresmens, maxtranconsatmdiarias,
            maxtranretatmdiarias, maxtrancompraposdiarias, maxtranconsatmmens, maxtranretatmmens, maxtrancompraposmens, saldomaxamostrar,
            porccomconsatmpropio, porccomretatmpropio, porccomrevatmpropio, limdiarioretatmpropio, limmensretatmpropio, limhdretatmpropio,
            numtranhdretatmpropio, numtranconsatmlibresmenspropio, numtranretatmlibresmenspropio, maxtranconsatmdiariaspropio, maxtranretatmdiariaspropio,
            maxtranconsatmmenspropio, maxtranretatmmenspropio, tarjetanorelacionada, cuentamaestra, saldominimo, codigoeventoerror,
            estatusprocesocargasaldos, estatusprocesocancelacion, registrostotalcargasaldos, registrosavancecargasaldos, registrostotalcancelacion,
            registrosavancecancelacion, tnrcobracomisiones, tnrporccomconsatmnac, tnrporccomconsatmint, tnrporccomretatmnac, tnrporccomretatmint,
            tnrporccomcompraposnac, tnrporccomcompraposint, tnrporccomrevatmnac, tnrporccomrevatmint, tnrporccomrevposnac,
            tnrporccomrevposint, tnrporccomfzdaposnac, tnrporccomfzdaposint, tnrporccomconsatmpropio, tnrporccomretatmpropio,
            tnrporccomrevatmpropio, corporativa, nombreempresa, comisioncargasaldos, tnrgenintervalo, tnrgentipointervalo, tnrgenfechahorainicio,tnrgenfechahorafinal,
            tnrgenrutaarchivo, cobracomisionesenlinea, permitecomisionespendientes, estatusprocesoasignacionmasiva, registrostotalasignacionmasiva,
            registrosavanceasignacionmasiva, transcom, cobracomanualidad, impcomanualidad, fechainicomanualidad, permitetnrpersonalizadas,transcomexpedicion,
            cobracomexpedicion,impcomexpedicion, transcomrenovacion, cobracomrenovacion, impcomrenovacion, tnrcuentadispersadora, tnrtranscargoctadispersadora,
            tnrtransabonoctainfraestructura, tnrtranscargoctainfraestructura, tnrtransabonoctadispersadora, tnrutilizactainfraestructura, tnrhabilitarproteccionsaldosasignados,
            tnrbloquearreversionasignaciones, tnrlapsoreversion, tnrcongelarsaldoindividual, tnrlapsocongelarsaldo, tnrimagenactualizada, estatusprocesosolicitudtarjeta,
            registrostotalsolicitudtarjeta, registrosavancesolicitudtarjeta, tnrlogo, escredito, permitecashback, permitecashadvance, limdiariocashadvanceposnac,
            limmensualcashadvanceposnac, limdiariocashbackposnac, limmensualcashbackposnac, porccomcashbacknac, porccomcashadvancenac, numtrancashbacklibresmens,
            numtrancashadvancelibresmens, maxtrancashbackdiarias, maxtrancashbackmensuales, maxtrancashadvancediarias, maxtrancashadvancemensuales, permitetransdigitadas,
            soportatranatmcajeropropio, soportatranatmcajeroconvenio, soportatranatmcajerored, porccomconsatmconvenio, porccomretatmconvenio,
            porccomrevatmconvenio, limdiarioretatmconvenio, limmensretatmconvenio, numtranconsatmconveniolibres, numtranretatmconveniolibres,
            maxtranconsatmconveniodiarias, maxtranconsatmconveniomens, maxtranretatmconveniodiarias, maxtranretatmconveniomens, soportatranatminternacional,
            validarcvv2, limdiarioqps, limdiariocat, montomaximotranqps, montomaximotrancat, limdiarioqpsudis, limdiariocatudis,
            montomaximotranqpsudis, montomaximotrancatudis, limitediariomotovoz, limitediariomotoint, limitemensualmotovoz,
            limitemensualmotoint, maxtransmotovozdiario, maxtransmotovozmensual, maxtransmotointdiario, maxtransmotointmensual,
            permitemotovoz, permitemotointernet, permitetranstag, limitediariotag, limitemensualtag, maxtrandiariotag, maxtranmensualtag,
            permitedeposito, porccomdepositonac, limdiariodepositoposnac, limmensualdepositoposnac, numtrandepositolibresmens,maxtrandepositodiarias,
            maxtrandepositomensuales, permitecontactless_nac_atm, permitecontactless_int_atm, mtomaxdianac_contless_atm, mtomaxmesnac_contless_atm,
            mtomaxdiaint_contless_atm, mtomaxmesint_contless_atm, contmaxdianac_contless_atm, contmaxmesnac_contless_atm,contmaxdiaint_contless_atm,
            contmaxmesint_contless_atm, montomaxunicanac_contless_atm, montomaxunicanint_contless_atm, permitecontactless_nac_pos,
            permitecontactless_int_pos, mtomaxdianac_contless_pos, mtomaxmesnac_contless_pos, mtomaxdiaint_contless_pos,
            mtomaxmesint_contless_pos, contmaxdianac_contless_pos, contmaxmesnac_contless_pos, contmaxdiaint_contless_pos,
            contmaxmesint_contless_pos, montomaxunicanac_contless_pos, montomaxunicanint_contless_pos, permitemsi,
            contmaxreversosdiariosatminternacional, permite_retiro_sin_tarjeta_atm, campanianotif
            
            INTO 
                vPTcodproductotarjeta, vPTdescproducto, vPTporccomconsatmnac, vPTporccomconsatmint, vPTporccomretatmnac, vPTporccomretatmint, vPTporccomcompraposnac,
vPTporccomcompraposint, vPTporccomrevatmnac, vPTporccomrevatmint, vPTporccomrevposnac, vPTporccomrevposint, vPTporccomfzdaposnac, vPTporccomfzdaposint, vPTlimdiarioretatmnac,
vPTlimdiarioretatmint, vPTlimmensretatmnac, vPTlimmensretatmint, vPTlimdiariocompraposnac, vPTlimdiariocompraposint, vPTlimmenscompraposnac, vPTlimmenscompraposint, vPTlimhdretatmnac,
vPTlimhdretatmint, vPTlimhdcompraposnac, vPTlimhdcompraposint, vPTnumtranhdretatmnac, vPTnumtranhdretatmint, vPTnumtranhdcompraposnac, vPTnumtranhdcompraposint, vPTnumtranconsatmlibresmens,
vPTnumtranretatmlibresmens, vPTnumtrancompraposlibresmens, vPTmaxtranconsatmdiarias, vPTmaxtranretatmdiarias, vPTmaxtrancompraposdiarias, vPTmaxtranconsatmmens, vPTmaxtranretatmmens,
vPTmaxtrancompraposmens, vPTsaldomaxamostrar, vPTporccomconsatmpropio, vPTporccomretatmpropio, vPTporccomrevatmpropio, vPTlimdiarioretatmpropio, vPTlimmensretatmpropio,
vPTlimhdretatmpropio, vPTnumtranhdretatmpropio, vPTnumtranconsatmlibresmenspropio, vPTnumtranretatmlibresmenspropio, vPTmaxtranconsatmdiariaspropio, vPTmaxtranretatmdiariaspropio,
vPTmaxtranconsatmmenspropio, vPTmaxtranretatmmenspropio, vPTtarjetanorelacionada, vPTcuentamaestra, vPTsaldominimo, vPTcodigoeventoerror, vPTestatusprocesocargasaldos,
vPTestatusprocesocancelacion, vPTregistrostotalcargasaldos, vPTregistrosavancecargasaldos, vPTregistrostotalcancelacion, vPTregistrosavancecancelacion, vPTtnrcobracomisiones,
vPTtnrporccomconsatmnac, vPTtnrporccomconsatmint, vPTtnrporccomretatmnac, vPTtnrporccomretatmint, vPTtnrporccomcompraposnac, vPTtnrporccomcompraposint, vPTtnrporccomrevatmnac,
vPTtnrporccomrevatmint, vPTtnrporccomrevposnac, vPTtnrporccomrevposint, vPTtnrporccomfzdaposnac, vPTtnrporccomfzdaposint, vPTtnrporccomconsatmpropio, vPTtnrporccomretatmpropio,
vPTtnrporccomrevatmpropio, vPTcorporativa, vPTnombreempresa, vPTcomisioncargasaldos, vPTtnrgenintervalo, vPTtnrgentipointervalo, vPTtnrgenfechahorainicio, vPTtnrgenfechahorafinal,
vPTtnrgenrutaarchivo, vPTcobracomisionesenlinea, vPTpermitecomisionespendientes, vPTestatusprocesoasignacionmasiva, vPTregistrostotalasignacionmasiva, vPTregistrosavanceasignacionmasiva,
vPTtranscom, vPTcobracomanualidad, vPTimpcomanualidad, vPTfechainicomanualidad, vPTpermitetnrpersonalizadas, vPTtranscomexpedicion, vPTcobracomexpedicion, vPTimpcomexpedicion,
vPTtranscomrenovacion, vPTcobracomrenovacion, vPTimpcomrenovacion, vPTtnrcuentadispersadora, vPTtnrtranscargoctadispersadora, vPTtnrtransabonoctainfraestructura,
vPTtnrtranscargoctainfraestructura, vPTtnrtransabonoctadispersadora, vPTtnrutilizactainfraestructura, vPTtnrhabilitarproteccionsaldosasignados, vPTtnrbloquearreversionasignaciones,
vPTtnrlapsoreversion, vPTtnrcongelarsaldoindividual, vPTtnrlapsocongelarsaldo, vPTtnrimagenactualizada, vPTestatusprocesosolicitudtarjeta, vPTregistrostotalsolicitudtarjeta,
vPTregistrosavancesolicitudtarjeta, vPTtnrlogo, vPTescredito, vPTpermitecashback, vPTpermitecashadvance, vPTlimdiariocashadvanceposnac, vPTlimmensualcashadvanceposnac,
vPTlimdiariocashbackposnac, vPTlimmensualcashbackposnac, vPTporccomcashbacknac, vPTporccomcashadvancenac, vPTnumtrancashbacklibresmens, vPTnumtrancashadvancelibresmens,
vPTmaxtrancashbackdiarias, vPTmaxtrancashbackmensuales, vPTmaxtrancashadvancediarias, vPTmaxtrancashadvancemensuales, vPTpermitetransdigitadas, vPTsoportatranatmcajeropropio,
vPTsoportatranatmcajeroconvenio, vPTsoportatranatmcajerored, vPTporccomconsatmconvenio, vPTporccomretatmconvenio, vPTporccomrevatmconvenio, vPTlimdiarioretatmconvenio,
vPTlimmensretatmconvenio, vPTnumtranconsatmconveniolibres, vPTnumtranretatmconveniolibres, vPTmaxtranconsatmconveniodiarias, vPTmaxtranconsatmconveniomens, vPTmaxtranretatmconveniodiarias,
vPTmaxtranretatmconveniomens, vPTsoportatranatminternacional, vPTvalidarcvv2, vPTlimdiarioqps, vPTlimdiariocat, vPTmontomaximotranqps, vPTmontomaximotrancat,
vPTlimdiarioqpsudis, vPTlimdiariocatudis, vPTmontomaximotranqpsudis, vPTmontomaximotrancatudis, vPTlimitediariomotovoz, vPTlimitediariomotoint,
vPTlimitemensualmotovoz, vPTlimitemensualmotoint, vPTmaxtransmotovozdiario, vPTmaxtransmotovozmensual, vPTmaxtransmotointdiario, vPTmaxtransmotointmensual,
vPTpermitemotovoz, vPTpermitemotointernet, vPTpermitetranstag, vPTlimitediariotag, vPTlimitemensualtag, vPTmaxtrandiariotag, vPTmaxtranmensualtag, vPTpermitedeposito,
vPTporccomdepositonac, vPTlimdiariodepositoposnac, vPTlimmensualdepositoposnac, vPTnumtrandepositolibresmens, vPTmaxtrandepositodiarias, vPTmaxtrandepositomensuales,
vPTpermitecontactless_nac_atm, vPTpermitecontactless_int_atm, vPTmtomaxdianac_contless_atm, vPTmtomaxmesnac_contless_atm, vPTmtomaxdiaint_contless_atm, vPTmtomaxmesint_contless_atm,
vPTcontmaxdianac_contless_atm, vPTcontmaxmesnac_contless_atm, vPTcontmaxdiaint_contless_atm, vPTcontmaxmesint_contless_atm, vPTmontomaxunicanac_contless_atm, vPTmontomaxunicanint_contless_atm,
vPTpermitecontactless_nac_pos, vPTpermitecontactless_int_pos, vPTmtomaxdianac_contless_pos, vPTmtomaxmesnac_contless_pos, vPTmtomaxdiaint_contless_pos, vPTmtomaxmesint_contless_pos,
vPTcontmaxdianac_contless_pos, vPTcontmaxmesnac_contless_pos, vPTcontmaxdiaint_contless_pos, vPTcontmaxmesint_contless_pos, vPTmontomaxunicanac_contless_pos,
vPTmontomaxunicanint_contless_pos, vPTpermitemsi, vPTcontmaxreversosdiariosatminternacional, vPTpermite_retiro_sin_tarjeta_atm, vPTcampaniaNotif 
        FROM bditarjeta:"informix".respaldo_control_prod        
        
        
            SELECT 
                codproductotarjeta, descproducto, porccomconsatmnac, porccomconsatmint, porccomretatmnac, porccomretatmint,
            porccomcompraposnac, porccomcompraposint, porccomrevatmnac, porccomrevatmint, porccomrevposnac, porccomrevposint,
            porccomfzdaposnac, porccomfzdaposint, limdiarioretatmnac, limdiarioretatmint, limmensretatmnac, limmensretatmint,
            limdiariocompraposnac, limdiariocompraposint, limmenscompraposnac, limmenscompraposint, limhdretatmnac,
            limhdretatmint, limhdcompraposnac, limhdcompraposint, numtranhdretatmnac, numtranhdretatmint, numtranhdcompraposnac,
            numtranhdcompraposint, numtranconsatmlibresmens, numtranretatmlibresmens, numtrancompraposlibresmens, maxtranconsatmdiarias,
            maxtranretatmdiarias, maxtrancompraposdiarias, maxtranconsatmmens, maxtranretatmmens, maxtrancompraposmens, saldomaxamostrar,
            porccomconsatmpropio, porccomretatmpropio, porccomrevatmpropio, limdiarioretatmpropio, limmensretatmpropio, limhdretatmpropio,
            numtranhdretatmpropio, numtranconsatmlibresmenspropio, numtranretatmlibresmenspropio, maxtranconsatmdiariaspropio, maxtranretatmdiariaspropio,
            maxtranconsatmmenspropio, maxtranretatmmenspropio, tarjetanorelacionada, cuentamaestra, saldominimo, codigoeventoerror,
            estatusprocesocargasaldos, estatusprocesocancelacion, registrostotalcargasaldos, registrosavancecargasaldos, registrostotalcancelacion,
            registrosavancecancelacion, tnrcobracomisiones, tnrporccomconsatmnac, tnrporccomconsatmint, tnrporccomretatmnac, tnrporccomretatmint,
            tnrporccomcompraposnac, tnrporccomcompraposint, tnrporccomrevatmnac, tnrporccomrevatmint, tnrporccomrevposnac,
            tnrporccomrevposint, tnrporccomfzdaposnac, tnrporccomfzdaposint, tnrporccomconsatmpropio, tnrporccomretatmpropio,
            tnrporccomrevatmpropio, corporativa, nombreempresa, comisioncargasaldos, tnrgenintervalo, tnrgentipointervalo, tnrgenfechahorainicio,tnrgenfechahorafinal,
            tnrgenrutaarchivo, cobracomisionesenlinea, permitecomisionespendientes, estatusprocesoasignacionmasiva, registrostotalasignacionmasiva,
            registrosavanceasignacionmasiva, transcom, cobracomanualidad, impcomanualidad, fechainicomanualidad, permitetnrpersonalizadas,transcomexpedicion,
            cobracomexpedicion,impcomexpedicion, transcomrenovacion, cobracomrenovacion, impcomrenovacion, tnrcuentadispersadora, tnrtranscargoctadispersadora,
            tnrtransabonoctainfraestructura, tnrtranscargoctainfraestructura, tnrtransabonoctadispersadora, tnrutilizactainfraestructura, tnrhabilitarproteccionsaldosasignados,
            tnrbloquearreversionasignaciones, tnrlapsoreversion, tnrcongelarsaldoindividual, tnrlapsocongelarsaldo, tnrimagenactualizada, estatusprocesosolicitudtarjeta,
            registrostotalsolicitudtarjeta, registrosavancesolicitudtarjeta, tnrlogo, escredito, permitecashback, permitecashadvance, limdiariocashadvanceposnac,
            limmensualcashadvanceposnac, limdiariocashbackposnac, limmensualcashbackposnac, porccomcashbacknac, porccomcashadvancenac, numtrancashbacklibresmens,
            numtrancashadvancelibresmens, maxtrancashbackdiarias, maxtrancashbackmensuales, maxtrancashadvancediarias, maxtrancashadvancemensuales, permitetransdigitadas,
            soportatranatmcajeropropio, soportatranatmcajeroconvenio, soportatranatmcajerored, porccomconsatmconvenio, porccomretatmconvenio,
            porccomrevatmconvenio, limdiarioretatmconvenio, limmensretatmconvenio, numtranconsatmconveniolibres, numtranretatmconveniolibres,
            maxtranconsatmconveniodiarias, maxtranconsatmconveniomens, maxtranretatmconveniodiarias, maxtranretatmconveniomens, soportatranatminternacional,
            validarcvv2, limdiarioqps, limdiariocat, montomaximotranqps, montomaximotrancat, limdiarioqpsudis, limdiariocatudis,
            montomaximotranqpsudis, montomaximotrancatudis, limitediariomotovoz, limitediariomotoint, limitemensualmotovoz,
            limitemensualmotoint, maxtransmotovozdiario, maxtransmotovozmensual, maxtransmotointdiario, maxtransmotointmensual,
            permitemotovoz, permitemotointernet, permitetranstag, limitediariotag, limitemensualtag, maxtrandiariotag, maxtranmensualtag,
            permitedeposito, porccomdepositonac, limdiariodepositoposnac, limmensualdepositoposnac, numtrandepositolibresmens,maxtrandepositodiarias,
            maxtrandepositomensuales, permitecontactless_nac_atm, permitecontactless_int_atm, mtomaxdianac_contless_atm, mtomaxmesnac_contless_atm,
            mtomaxdiaint_contless_atm, mtomaxmesint_contless_atm, contmaxdianac_contless_atm, contmaxmesnac_contless_atm,contmaxdiaint_contless_atm,
            contmaxmesint_contless_atm, montomaxunicanac_contless_atm, montomaxunicanint_contless_atm, permitecontactless_nac_pos,
            permitecontactless_int_pos, mtomaxdianac_contless_pos, mtomaxmesnac_contless_pos, mtomaxdiaint_contless_pos,
            mtomaxmesint_contless_pos, contmaxdianac_contless_pos, contmaxmesnac_contless_pos, contmaxdiaint_contless_pos,
            contmaxmesint_contless_pos, montomaxunicanac_contless_pos, montomaxunicanint_contless_pos, permitemsi,
            contmaxreversosdiariosatminternacional, permite_retiro_sin_tarjeta_atm, campanianotif
            INTO
            
vOncodproductotarjeta, vOndescproducto, vOnporccomconsatmnac, vOnporccomconsatmint, vOnporccomretatmnac, vOnporccomretatmint, vOnporccomcompraposnac, vOnporccomcompraposint,
vOnporccomrevatmnac, vOnporccomrevatmint, vOnporccomrevposnac, vOnporccomrevposint, vOnporccomfzdaposnac, vOnporccomfzdaposint, vOnlimdiarioretatmnac, vOnlimdiarioretatmint,
vOnlimmensretatmnac, vOnlimmensretatmint, vOnlimdiariocompraposnac, vOnlimdiariocompraposint, vOnlimmenscompraposnac, vOnlimmenscompraposint, vOnlimhdretatmnac,
vOnlimhdretatmint, vOnlimhdcompraposnac, vOnlimhdcompraposint, vOnnumtranhdretatmnac, vOnnumtranhdretatmint, vOnnumtranhdcompraposnac, vOnnumtranhdcompraposint,
vOnnumtranconsatmlibresmens, vOnnumtranretatmlibresmens, vOnnumtrancompraposlibresmens, vOnmaxtranconsatmdiarias, vOnmaxtranretatmdiarias,
vOnmaxtrancompraposdiarias, vOnmaxtranconsatmmens, vOnmaxtranretatmmens, vOnmaxtrancompraposmens, vOnsaldomaxamostrar, vOnporccomconsatmpropio,
vOnporccomretatmpropio, vOnporccomrevatmpropio, vOnlimdiarioretatmpropio, vOnlimmensretatmpropio, vOnlimhdretatmpropio, vOnnumtranhdretatmpropio,
vOnnumtranconsatmlibresmenspropio, vOnnumtranretatmlibresmenspropio, vOnmaxtranconsatmdiariaspropio, vOnmaxtranretatmdiariaspropio,
vOnmaxtranconsatmmenspropio, vOnmaxtranretatmmenspropio, vOntarjetanorelacionada, vOncuentamaestra, vOnsaldominimo, vOncodigoeventoerror,
vOnestatusprocesocargasaldos, vOnestatusprocesocancelacion, vOnregistrostotalcargasaldos, vOnregistrosavancecargasaldos, vOnregistrostotalcancelacion,
vOnregistrosavancecancelacion, vOntnrcobracomisiones, vOntnrporccomconsatmnac, vOntnrporccomconsatmint, vOntnrporccomretatmnac,vOntnrporccomretatmint,
vOntnrporccomcompraposnac, vOntnrporccomcompraposint, vOntnrporccomrevatmnac, vOntnrporccomrevatmint, vOntnrporccomrevposnac, vOntnrporccomrevposint,
vOntnrporccomfzdaposnac, vOntnrporccomfzdaposint, vOntnrporccomconsatmpropio, vOntnrporccomretatmpropio, vOntnrporccomrevatmpropio,
vOncorporativa, vOnnombreempresa, vOncomisioncargasaldos, vOntnrgenintervalo, vOntnrgentipointervalo, vOntnrgenfechahorainicio,
vOntnrgenfechahorafinal, vOntnrgenrutaarchivo, vOncobracomisionesenlinea, vOnpermitecomisionespendientes, vOnestatusprocesoasignacionmasiva,
vOnregistrostotalasignacionmasiva, vOnregistrosavanceasignacionmasiva, vOntranscom, vOncobracomanualidad, vOnimpcomanualidad, vOnfechainicomanualidad, vOnpermitetnrpersonalizadas,
vOntranscomexpedicion, vOncobracomexpedicion, vOnimpcomexpedicion, vOntranscomrenovacion, vOncobracomrenovacion, vOnimpcomrenovacion, vOntnrcuentadispersadora,
vOntnrtranscargoctadispersadora, vOntnrtransabonoctainfraestructura, vOntnrtranscargoctainfraestructura,vOntnrtransabonoctadispersadora,
vOntnrutilizactainfraestructura, vOntnrhabilitarproteccionsaldosasignados, vOntnrbloquearreversionasignaciones, vOntnrlapsoreversion, vOntnrcongelarsaldoindividual,
vOntnrlapsocongelarsaldo, vOntnrimagenactualizada, vOnestatusprocesosolicitudtarjeta, vOnregistrostotalsolicitudtarjeta, vOnregistrosavancesolicitudtarjeta,
vOntnrlogo, vOnescredito, vOnpermitecashback, vOnpermitecashadvance, vOnlimdiariocashadvanceposnac, vOnlimmensualcashadvanceposnac, vOnlimdiariocashbackposnac,
vOnlimmensualcashbackposnac, vOnporccomcashbacknac, vOnporccomcashadvancenac, vOnnumtrancashbacklibresmens, vOnnumtrancashadvancelibresmens,
vOnmaxtrancashbackdiarias, vOnmaxtrancashbackmensuales, vOnmaxtrancashadvancediarias, vOnmaxtrancashadvancemensuales, vOnpermitetransdigitadas,
vOnsoportatranatmcajeropropio, vOnsoportatranatmcajeroconvenio, vOnsoportatranatmcajerored, vOnporccomconsatmconvenio, vOnporccomretatmconvenio,
vOnporccomrevatmconvenio, vOnlimdiarioretatmconvenio, vOnlimmensretatmconvenio, vOnnumtranconsatmconveniolibres, vOnnumtranretatmconveniolibres,
vOnmaxtranconsatmconveniodiarias, vOnmaxtranconsatmconveniomens, vOnmaxtranretatmconveniodiarias, vOnmaxtranretatmconveniomens, vOnsoportatranatminternacional,
vOnvalidarcvv2, vOnlimdiarioqps, vOnlimdiariocat, vOnmontomaximotranqps, vOnmontomaximotrancat, vOnlimdiarioqpsudis, vOnlimdiariocatudis,
vOnmontomaximotranqpsudis, vOnmontomaximotrancatudis, vOnlimitediariomotovoz, vOnlimitediariomotoint, vOnlimitemensualmotovoz, vOnlimitemensualmotoint,
vOnmaxtransmotovozdiario, vOnmaxtransmotovozmensual, vOnmaxtransmotointdiario, vOnmaxtransmotointmensual, vOnpermitemotovoz,
vOnpermitemotointernet, vOnpermitetranstag, vOnlimitediariotag, vOnlimitemensualtag, vOnmaxtrandiariotag, vOnmaxtranmensualtag, vOnpermitedeposito, vOnporccomdepositonac,
vOnlimdiariodepositoposnac, vOnlimmensualdepositoposnac, vOnnumtrandepositolibresmens, vOnmaxtrandepositodiarias, vOnmaxtrandepositomensuales, vOnpermitecontactless_nac_atm,
vOnpermitecontactless_int_atm, vOnmtomaxdianac_contless_atm, vOnmtomaxmesnac_contless_atm, vOnmtomaxdiaint_contless_atm, vOnmtomaxmesint_contless_atm, vOncontmaxdianac_contless_atm,
vOncontmaxmesnac_contless_atm, vOncontmaxdiaint_contless_atm, vOncontmaxmesint_contless_atm, vOnmontomaxunicanac_contless_atm, vOnmontomaxunicanint_contless_atm,
vOnpermitecontactless_nac_pos, vOnpermitecontactless_int_pos, vOnmtomaxdianac_contless_pos, vOnmtomaxmesnac_contless_pos, vOnmtomaxdiaint_contless_pos, vOnmtomaxmesint_contless_pos,
vOncontmaxdianac_contless_pos, vOncontmaxmesnac_contless_pos, vOncontmaxdiaint_contless_pos, vOncontmaxmesint_contless_pos, vOnmontomaxunicanac_contless_pos,
vOnmontomaxunicanint_contless_pos, vOnpermitemsi, vOncontmaxreversosdiariosatminternacional, vOnpermite_retiro_sin_tarjeta_atm, vOncampaniaNotif
                FROM intercard:"informix".productotarjeta
            WHERE codproductotarjeta = vPTcodproductotarjeta;
        
        
        IF ( vPTcodproductotarjeta = vOncodproductotarjeta ) THEN
            IF (
                ( vPTdescproducto <> vOndescproducto ) OR 
                ( vPTporccomconsatmnac <> vOnporccomconsatmnac ) OR 
                ( vPTporccomconsatmint <> vOnporccomconsatmint ) OR 
                ( vPTporccomretatmnac <> vOnporccomretatmnac ) OR 
                ( vPTporccomretatmint <> vOnporccomretatmint ) OR 
                ( vPTporccomcompraposnac <> vOnporccomcompraposnac ) OR 
                ( vPTporccomcompraposint <> vOnporccomcompraposint ) OR 
                ( vPTporccomrevatmnac <> vOnporccomrevatmnac ) OR 
                ( vPTporccomrevatmint <> vOnporccomrevatmint ) OR 
                ( vPTporccomrevposnac <> vOnporccomrevposnac ) OR 
                ( vPTporccomrevposint <> vOnporccomrevposint ) OR 
                ( vPTporccomfzdaposnac <> vOnporccomfzdaposnac ) OR 
                ( vPTporccomfzdaposint <> vOnporccomfzdaposint ) OR 
                ( vPTlimdiarioretatmnac <> vOnlimdiarioretatmnac ) OR 
                ( vPTlimdiarioretatmint <> vOnlimdiarioretatmint ) OR 
                ( vPTlimmensretatmnac <> vOnlimmensretatmnac ) OR 
                ( vPTlimmensretatmint <> vOnlimmensretatmint ) OR 
                ( vPTlimdiariocompraposnac <> vOnlimdiariocompraposnac ) OR 
                ( vPTlimdiariocompraposint <> vOnlimdiariocompraposint ) OR 
                ( vPTlimmenscompraposnac <> vOnlimmenscompraposnac ) OR 
                ( vPTlimmenscompraposint <> vOnlimmenscompraposint ) OR 
                ( vPTlimhdretatmnac <> vOnlimhdretatmnac ) OR 
                ( vPTlimhdretatmint <> vOnlimhdretatmint ) OR 
                ( vPTlimhdcompraposnac <> vOnlimhdcompraposnac ) OR 
                ( vPTlimhdcompraposint <> vOnlimhdcompraposint ) OR 
                ( vPTnumtranhdretatmnac <> vOnnumtranhdretatmnac ) OR 
                ( vPTnumtranhdretatmint <> vOnnumtranhdretatmint ) OR 
                ( vPTnumtranhdcompraposnac <> vOnnumtranhdcompraposnac ) OR 
                ( vPTnumtranhdcompraposint <> vOnnumtranhdcompraposint ) OR 
                ( vPTnumtranconsatmlibresmens <> vOnnumtranconsatmlibresmens ) OR 
                ( vPTnumtranretatmlibresmens <> vOnnumtranretatmlibresmens ) OR 
                ( vPTnumtrancompraposlibresmens <> vOnnumtrancompraposlibresmens ) OR 
                ( vPTmaxtranconsatmdiarias <> vOnmaxtranconsatmdiarias ) OR 
                ( vPTmaxtranretatmdiarias <> vOnmaxtranretatmdiarias ) OR 
                ( vPTmaxtrancompraposdiarias <> vOnmaxtrancompraposdiarias ) OR 
                ( vPTmaxtranconsatmmens <> vOnmaxtranconsatmmens ) OR 
                ( vPTmaxtranretatmmens <> vOnmaxtranretatmmens ) OR 
                ( vPTmaxtrancompraposmens <> vOnmaxtrancompraposmens ) OR 
                ( vPTsaldomaxamostrar <> vOnsaldomaxamostrar ) OR 
                ( vPTporccomconsatmpropio <> vOnporccomconsatmpropio ) OR 
                ( vPTporccomretatmpropio <> vOnporccomretatmpropio ) OR 
                ( vPTporccomrevatmpropio <> vOnporccomrevatmpropio ) OR 
                ( vPTlimdiarioretatmpropio <> vOnlimdiarioretatmpropio ) OR 
                ( vPTlimmensretatmpropio <> vOnlimmensretatmpropio ) OR 
                ( vPTlimhdretatmpropio <> vOnlimhdretatmpropio ) OR 
                ( vPTnumtranhdretatmpropio <> vOnnumtranhdretatmpropio ) OR 
                ( vPTnumtranconsatmlibresmenspropio <> vOnnumtranconsatmlibresmenspropio ) OR 
                ( vPTnumtranretatmlibresmenspropio <> vOnnumtranretatmlibresmenspropio ) OR 
                ( vPTmaxtranconsatmdiariaspropio <> vOnmaxtranconsatmdiariaspropio ) OR 
                ( vPTmaxtranretatmdiariaspropio <> vOnmaxtranretatmdiariaspropio ) OR 
                ( vPTmaxtranconsatmmenspropio <> vOnmaxtranconsatmmenspropio ) OR 
                ( vPTmaxtranretatmmenspropio <> vOnmaxtranretatmmenspropio ) OR 
                ( vPTtarjetanorelacionada <> vOntarjetanorelacionada ) OR 
                ( vPTcuentamaestra <> vOncuentamaestra ) OR 
                ( vPTsaldominimo <> vOnsaldominimo ) OR 
                ( vPTcodigoeventoerror <> vOncodigoeventoerror ) OR 
                ( vPTestatusprocesocargasaldos <> vOnestatusprocesocargasaldos ) OR 
                ( vPTestatusprocesocancelacion <> vOnestatusprocesocancelacion ) OR 
                ( vPTregistrostotalcargasaldos <> vOnregistrostotalcargasaldos ) OR 
                ( vPTregistrosavancecargasaldos <> vOnregistrosavancecargasaldos ) OR 
                ( vPTregistrostotalcancelacion <> vOnregistrostotalcancelacion ) OR 
                ( vPTregistrosavancecancelacion <> vOnregistrosavancecancelacion ) OR 
                ( vPTtnrcobracomisiones <> vOntnrcobracomisiones ) OR 
                ( vPTtnrporccomconsatmnac <> vOntnrporccomconsatmnac ) OR 
                ( vPTtnrporccomconsatmint <> vOntnrporccomconsatmint ) OR 
                ( vPTtnrporccomretatmnac <> vOntnrporccomretatmnac ) OR 
                ( vPTtnrporccomretatmint <> vOntnrporccomretatmint ) OR 
                ( vPTtnrporccomcompraposnac <> vOntnrporccomcompraposnac ) OR 
                ( vPTtnrporccomcompraposint <> vOntnrporccomcompraposint ) OR 
                ( vPTtnrporccomrevatmnac <> vOntnrporccomrevatmnac ) OR 
                ( vPTtnrporccomrevatmint <> vOntnrporccomrevatmint ) OR 
                ( vPTtnrporccomrevposnac <> vOntnrporccomrevposnac ) OR 
                ( vPTtnrporccomrevposint <> vOntnrporccomrevposint ) OR 
                ( vPTtnrporccomfzdaposnac <> vOntnrporccomfzdaposnac ) OR 
                ( vPTtnrporccomfzdaposint <> vOntnrporccomfzdaposint ) OR 
                ( vPTtnrporccomconsatmpropio <> vOntnrporccomconsatmpropio ) OR 
                ( vPTtnrporccomretatmpropio <> vOntnrporccomretatmpropio ) OR 
                ( vPTtnrporccomrevatmpropio <> vOntnrporccomrevatmpropio ) OR 
                ( vPTcorporativa <> vOncorporativa ) OR 
                ( vPTnombreempresa <> vOnnombreempresa ) OR 
                ( vPTcomisioncargasaldos <> vOncomisioncargasaldos ) OR 
                ( vPTtnrgenintervalo <> vOntnrgenintervalo ) OR 
                ( vPTtnrgentipointervalo <> vOntnrgentipointervalo ) OR 
                ( vPTtnrgenfechahorainicio <> vOntnrgenfechahorainicio ) OR 
                ( vPTtnrgenfechahorafinal <> vOntnrgenfechahorafinal ) OR 
                ( vPTtnrgenrutaarchivo <> vOntnrgenrutaarchivo ) OR 
                ( vPTcobracomisionesenlinea <> vOncobracomisionesenlinea ) OR 
                ( vPTpermitecomisionespendientes <> vOnpermitecomisionespendientes ) OR 
                ( vPTestatusprocesoasignacionmasiva <> vOnestatusprocesoasignacionmasiva ) OR 
                ( vPTregistrostotalasignacionmasiva <> vOnregistrostotalasignacionmasiva ) OR 
                ( vPTregistrosavanceasignacionmasiva <> vOnregistrosavanceasignacionmasiva ) OR 
                ( vPTtranscom <> vOntranscom ) OR 
                ( vPTcobracomanualidad <> vOncobracomanualidad ) OR 
                ( vPTimpcomanualidad <> vOnimpcomanualidad ) OR 
                ( vPTfechainicomanualidad <> vOnfechainicomanualidad ) OR 
                ( vPTpermitetnrpersonalizadas <> vOnpermitetnrpersonalizadas ) OR 
                ( vPTtranscomexpedicion <> vOntranscomexpedicion ) OR 
                ( vPTcobracomexpedicion <> vOncobracomexpedicion ) OR 
                ( vPTimpcomexpedicion <> vOnimpcomexpedicion ) OR 
                ( vPTtranscomrenovacion <> vOntranscomrenovacion ) OR 
                ( vPTcobracomrenovacion <> vOncobracomrenovacion ) OR 
                ( vPTimpcomrenovacion <> vOnimpcomrenovacion ) OR 
                ( vPTtnrcuentadispersadora <> vOntnrcuentadispersadora ) OR 
                ( vPTtnrtranscargoctadispersadora <> vOntnrtranscargoctadispersadora ) OR 
                ( vPTtnrtransabonoctainfraestructura <> vOntnrtransabonoctainfraestructura ) OR 
                ( vPTtnrtranscargoctainfraestructura <> vOntnrtranscargoctainfraestructura ) OR 
                ( vPTtnrtransabonoctadispersadora <> vOntnrtransabonoctadispersadora ) OR 
                ( vPTtnrutilizactainfraestructura <> vOntnrutilizactainfraestructura ) OR 
                ( vPTtnrhabilitarproteccionsaldosasignados <> vOntnrhabilitarproteccionsaldosasignados ) OR 
                ( vPTtnrbloquearreversionasignaciones <> vOntnrbloquearreversionasignaciones ) OR 
                ( vPTtnrlapsoreversion <> vOntnrlapsoreversion ) OR 
                ( vPTtnrcongelarsaldoindividual <> vOntnrcongelarsaldoindividual ) OR 
                ( vPTtnrlapsocongelarsaldo <> vOntnrlapsocongelarsaldo ) OR 
                ( vPTtnrimagenactualizada <> vOntnrimagenactualizada ) OR 
                ( vPTestatusprocesosolicitudtarjeta <> vOnestatusprocesosolicitudtarjeta ) OR 
                ( vPTregistrostotalsolicitudtarjeta <> vOnregistrostotalsolicitudtarjeta ) OR 
                ( vPTregistrosavancesolicitudtarjeta <> vOnregistrosavancesolicitudtarjeta ) OR 
                ( vPTtnrlogo <> vOntnrlogo ) OR 
                ( vPTescredito <> vOnescredito ) OR 
                ( vPTpermitecashback <> vOnpermitecashback ) OR 
                ( vPTpermitecashadvance <> vOnpermitecashadvance ) OR 
                ( vPTlimdiariocashadvanceposnac <> vOnlimdiariocashadvanceposnac ) OR 
                ( vPTlimmensualcashadvanceposnac <> vOnlimmensualcashadvanceposnac ) OR 
                ( vPTlimdiariocashbackposnac <> vOnlimdiariocashbackposnac ) OR 
                ( vPTlimmensualcashbackposnac <> vOnlimmensualcashbackposnac ) OR 
                ( vPTporccomcashbacknac <> vOnporccomcashbacknac ) OR 
                ( vPTporccomcashadvancenac <> vOnporccomcashadvancenac ) OR 
                ( vPTnumtrancashbacklibresmens <> vOnnumtrancashbacklibresmens ) OR 
                ( vPTnumtrancashadvancelibresmens <> vOnnumtrancashadvancelibresmens ) OR 
                ( vPTmaxtrancashbackdiarias <> vOnmaxtrancashbackdiarias ) OR 
                ( vPTmaxtrancashbackmensuales <> vOnmaxtrancashbackmensuales ) OR 
                ( vPTmaxtrancashadvancediarias <> vOnmaxtrancashadvancediarias ) OR 
                ( vPTmaxtrancashadvancemensuales <> vOnmaxtrancashadvancemensuales ) OR 
                ( vPTpermitetransdigitadas <> vOnpermitetransdigitadas ) OR 
                ( vPTsoportatranatmcajeropropio <> vOnsoportatranatmcajeropropio ) OR 
                ( vPTsoportatranatmcajeroconvenio <> vOnsoportatranatmcajeroconvenio ) OR 
                ( vPTsoportatranatmcajerored <> vOnsoportatranatmcajerored ) OR 
                ( vPTporccomconsatmconvenio <> vOnporccomconsatmconvenio ) OR 
                ( vPTporccomretatmconvenio <> vOnporccomretatmconvenio ) OR 
                ( vPTporccomrevatmconvenio <> vOnporccomrevatmconvenio ) OR 
                ( vPTlimdiarioretatmconvenio <> vOnlimdiarioretatmconvenio ) OR 
                ( vPTlimmensretatmconvenio <> vOnlimmensretatmconvenio ) OR 
                ( vPTnumtranconsatmconveniolibres <> vOnnumtranconsatmconveniolibres ) OR 
                ( vPTnumtranretatmconveniolibres <> vOnnumtranretatmconveniolibres ) OR 
                ( vPTmaxtranconsatmconveniodiarias <> vOnmaxtranconsatmconveniodiarias ) OR 
                ( vPTmaxtranconsatmconveniomens <> vOnmaxtranconsatmconveniomens ) OR 
                ( vPTmaxtranretatmconveniodiarias <> vOnmaxtranretatmconveniodiarias ) OR 
                ( vPTmaxtranretatmconveniomens <> vOnmaxtranretatmconveniomens ) OR 
                ( vPTsoportatranatminternacional <> vOnsoportatranatminternacional ) OR 
                ( vPTvalidarcvv2 <> vOnvalidarcvv2 ) OR 
                ( vPTlimdiarioqps <> vOnlimdiarioqps ) OR 
                ( vPTlimdiariocat <> vOnlimdiariocat ) OR 
                ( vPTmontomaximotranqps <> vOnmontomaximotranqps ) OR 
                ( vPTmontomaximotrancat <> vOnmontomaximotrancat ) OR 
                ( vPTlimdiarioqpsudis <> vOnlimdiarioqpsudis ) OR 
                ( vPTlimdiariocatudis <> vOnlimdiariocatudis ) OR 
                ( vPTmontomaximotranqpsudis <> vOnmontomaximotranqpsudis ) OR 
                ( vPTmontomaximotrancatudis <> vOnmontomaximotrancatudis ) OR 
                ( vPTlimitediariomotovoz <> vOnlimitediariomotovoz ) OR 
                ( vPTlimitediariomotoint <> vOnlimitediariomotoint ) OR 
                ( vPTlimitemensualmotovoz <> vOnlimitemensualmotovoz ) OR 
                ( vPTlimitemensualmotoint <> vOnlimitemensualmotoint ) OR 
                ( vPTmaxtransmotovozdiario <> vOnmaxtransmotovozdiario ) OR 
                ( vPTmaxtransmotovozmensual <> vOnmaxtransmotovozmensual ) OR 
                ( vPTmaxtransmotointdiario <> vOnmaxtransmotointdiario ) OR 
                ( vPTmaxtransmotointmensual <> vOnmaxtransmotointmensual ) OR 
                ( vPTpermitemotovoz <> vOnpermitemotovoz ) OR 
                ( vPTpermitemotointernet <> vOnpermitemotointernet ) OR 
                ( vPTpermitetranstag <> vOnpermitetranstag ) OR 
                ( vPTlimitediariotag <> vOnlimitediariotag ) OR 
                ( vPTlimitemensualtag <> vOnlimitemensualtag ) OR 
                ( vPTmaxtrandiariotag <> vOnmaxtrandiariotag ) OR 
                ( vPTmaxtranmensualtag <> vOnmaxtranmensualtag ) OR 
                ( vPTpermitedeposito <> vOnpermitedeposito ) OR 
                ( vPTporccomdepositonac <> vOnporccomdepositonac ) OR 
                ( vPTlimdiariodepositoposnac <> vOnlimdiariodepositoposnac ) OR 
                ( vPTlimmensualdepositoposnac <> vOnlimmensualdepositoposnac ) OR 
                ( vPTnumtrandepositolibresmens <> vOnnumtrandepositolibresmens ) OR 
                ( vPTmaxtrandepositodiarias <> vOnmaxtrandepositodiarias ) OR 
                ( vPTmaxtrandepositomensuales <> vOnmaxtrandepositomensuales ) OR 
                ( vPTpermitecontactless_nac_atm <> vOnpermitecontactless_nac_atm ) OR 
                ( vPTpermitecontactless_int_atm <> vOnpermitecontactless_int_atm ) OR 
                ( vPTmtomaxdianac_contless_atm <> vOnmtomaxdianac_contless_atm ) OR 
                ( vPTmtomaxmesnac_contless_atm <> vOnmtomaxmesnac_contless_atm ) OR 
                ( vPTmtomaxdiaint_contless_atm <> vOnmtomaxdiaint_contless_atm ) OR 
                ( vPTmtomaxmesint_contless_atm <> vOnmtomaxmesint_contless_atm ) OR 
                ( vPTcontmaxdianac_contless_atm <> vOncontmaxdianac_contless_atm ) OR 
                ( vPTcontmaxmesnac_contless_atm <> vOncontmaxmesnac_contless_atm ) OR 
                ( vPTcontmaxdiaint_contless_atm <> vOncontmaxdiaint_contless_atm ) OR 
                ( vPTcontmaxmesint_contless_atm <> vOncontmaxmesint_contless_atm ) OR 
                ( vPTmontomaxunicanac_contless_atm <> vOnmontomaxunicanac_contless_atm ) OR 
                ( vPTmontomaxunicanint_contless_atm <> vOnmontomaxunicanint_contless_atm ) OR 
                ( vPTpermitecontactless_nac_pos <> vOnpermitecontactless_nac_pos ) OR 
                ( vPTpermitecontactless_int_pos <> vOnpermitecontactless_int_pos ) OR 
                ( vPTmtomaxdianac_contless_pos <> vOnmtomaxdianac_contless_pos ) OR 
                ( vPTmtomaxmesnac_contless_pos <> vOnmtomaxmesnac_contless_pos ) OR 
                ( vPTmtomaxdiaint_contless_pos <> vOnmtomaxdiaint_contless_pos ) OR 
                ( vPTmtomaxmesint_contless_pos <> vOnmtomaxmesint_contless_pos ) OR 
                ( vPTcontmaxdianac_contless_pos <> vOncontmaxdianac_contless_pos ) OR 
                ( vPTcontmaxmesnac_contless_pos <> vOncontmaxmesnac_contless_pos ) OR 
                ( vPTcontmaxdiaint_contless_pos <> vOncontmaxdiaint_contless_pos ) OR 
                ( vPTcontmaxmesint_contless_pos <> vOncontmaxmesint_contless_pos ) OR 
                ( vPTmontomaxunicanac_contless_pos <> vOnmontomaxunicanac_contless_pos ) OR 
                ( vPTmontomaxunicanint_contless_pos <> vOnmontomaxunicanint_contless_pos ) OR 
                ( vPTpermitemsi <> vOnpermitemsi ) OR 
                ( vPTcontmaxreversosdiariosatminternacional <> vOncontmaxreversosdiariosatminternacional ) OR 
                ( vPTpermite_retiro_sin_tarjeta_atm <> vOnpermite_retiro_sin_tarjeta_atm ) OR 
                ( vPTcampaniaNotif <> vOncampaniaNotif )
            ) THEN
                
                UPDATE intercard:"informix".productotarjeta
                SET                     
                    codproductotarjeta = vPTcodproductotarjeta,
                            descproducto = vPTdescproducto,
                            porccomconsatmnac = vPTporccomconsatmnac,
                            porccomconsatmint = vPTporccomconsatmint,
                            porccomretatmnac = vPTporccomretatmnac,
                            porccomretatmint = vPTporccomretatmint,
                            porccomcompraposnac = vPTporccomcompraposnac,
                            porccomcompraposint = vPTporccomcompraposint,
                            porccomrevatmnac = vPTporccomrevatmnac,
                            porccomrevatmint = vPTporccomrevatmint,
                            porccomrevposnac = vPTporccomrevposnac,
                            porccomrevposint = vPTporccomrevposint,
                            porccomfzdaposnac = vPTporccomfzdaposnac,
                            porccomfzdaposint = vPTporccomfzdaposint,
                            limdiarioretatmnac = vPTlimdiarioretatmnac,
                            limdiarioretatmint = vPTlimdiarioretatmint,
                            limmensretatmnac = vPTlimmensretatmnac,
                            limmensretatmint = vPTlimmensretatmint,
                            limdiariocompraposnac = vPTlimdiariocompraposnac,
                            limdiariocompraposint = vPTlimdiariocompraposint,
                            limmenscompraposnac = vPTlimmenscompraposnac,
                            limmenscompraposint = vPTlimmenscompraposint,
                            limhdretatmnac = vPTlimhdretatmnac,
                            limhdretatmint = vPTlimhdretatmint,
                            limhdcompraposnac = vPTlimhdcompraposnac,
                            limhdcompraposint = vPTlimhdcompraposint,
                            numtranhdretatmnac = vPTnumtranhdretatmnac,
                            numtranhdretatmint = vPTnumtranhdretatmint,
                            numtranhdcompraposnac = vPTnumtranhdcompraposnac,
                            numtranhdcompraposint = vPTnumtranhdcompraposint,
                            numtranconsatmlibresmens = vPTnumtranconsatmlibresmens,
                            numtranretatmlibresmens = vPTnumtranretatmlibresmens,
                            numtrancompraposlibresmens = vPTnumtrancompraposlibresmens,
                            maxtranconsatmdiarias = vPTmaxtranconsatmdiarias,
                            maxtranretatmdiarias = vPTmaxtranretatmdiarias,
                            maxtrancompraposdiarias = vPTmaxtrancompraposdiarias,
                            maxtranconsatmmens = vPTmaxtranconsatmmens,
                            maxtranretatmmens = vPTmaxtranretatmmens,
                            maxtrancompraposmens = vPTmaxtrancompraposmens,
                            saldomaxamostrar = vPTsaldomaxamostrar,
                            porccomconsatmpropio = vPTporccomconsatmpropio,
                            porccomretatmpropio = vPTporccomretatmpropio,
                            porccomrevatmpropio = vPTporccomrevatmpropio,
                            limdiarioretatmpropio = vPTlimdiarioretatmpropio,
                            limmensretatmpropio = vPTlimmensretatmpropio,
                            limhdretatmpropio = vPTlimhdretatmpropio,
                            numtranhdretatmpropio = vPTnumtranhdretatmpropio,
                            numtranconsatmlibresmenspropio = vPTnumtranconsatmlibresmenspropio,
                            numtranretatmlibresmenspropio = vPTnumtranretatmlibresmenspropio,
                            maxtranconsatmdiariaspropio = vPTmaxtranconsatmdiariaspropio,
                            maxtranretatmdiariaspropio = vPTmaxtranretatmdiariaspropio,
                            maxtranconsatmmenspropio = vPTmaxtranconsatmmenspropio,
                            maxtranretatmmenspropio = vPTmaxtranretatmmenspropio,
                            tarjetanorelacionada = vPTtarjetanorelacionada,
                            cuentamaestra = vPTcuentamaestra,
                            saldominimo = vPTsaldominimo,
                            codigoeventoerror = vPTcodigoeventoerror,
                            estatusprocesocargasaldos = vPTestatusprocesocargasaldos,
                            estatusprocesocancelacion = vPTestatusprocesocancelacion,
                            registrostotalcargasaldos = vPTregistrostotalcargasaldos,
                            registrosavancecargasaldos = vPTregistrosavancecargasaldos,
                            registrostotalcancelacion = vPTregistrostotalcancelacion,
                            registrosavancecancelacion = vPTregistrosavancecancelacion,
                            tnrcobracomisiones = vPTtnrcobracomisiones,
                            tnrporccomconsatmnac = vPTtnrporccomconsatmnac,
                            tnrporccomconsatmint = vPTtnrporccomconsatmint,
                            tnrporccomretatmnac = vPTtnrporccomretatmnac,
                            tnrporccomretatmint = vPTtnrporccomretatmint,
                            tnrporccomcompraposnac = vPTtnrporccomcompraposnac,
                            tnrporccomcompraposint = vPTtnrporccomcompraposint,
                            tnrporccomrevatmnac = vPTtnrporccomrevatmnac,
                            tnrporccomrevatmint = vPTtnrporccomrevatmint,
                            tnrporccomrevposnac = vPTtnrporccomrevposnac,
                            tnrporccomrevposint = vPTtnrporccomrevposint,
                            tnrporccomfzdaposnac = vPTtnrporccomfzdaposnac,
                            tnrporccomfzdaposint = vPTtnrporccomfzdaposint,
                            tnrporccomconsatmpropio = vPTtnrporccomconsatmpropio,
                            tnrporccomretatmpropio = vPTtnrporccomretatmpropio,
                            tnrporccomrevatmpropio = vPTtnrporccomrevatmpropio,
                            corporativa = vPTcorporativa,
                            nombreempresa = vPTnombreempresa,
                            comisioncargasaldos = vPTcomisioncargasaldos,
                            tnrgenintervalo = vPTtnrgenintervalo,
                            tnrgentipointervalo = vPTtnrgentipointervalo,
                            tnrgenfechahorainicio = vPTtnrgenfechahorainicio,
                            tnrgenfechahorafinal = vPTtnrgenfechahorafinal,
                            tnrgenrutaarchivo = vPTtnrgenrutaarchivo,
                            cobracomisionesenlinea = vPTcobracomisionesenlinea,
                            permitecomisionespendientes = vPTpermitecomisionespendientes,
                            estatusprocesoasignacionmasiva = vPTestatusprocesoasignacionmasiva,
                            registrostotalasignacionmasiva = vPTregistrostotalasignacionmasiva,
                            registrosavanceasignacionmasiva = vPTregistrosavanceasignacionmasiva,
                            transcom = vPTtranscom,
                            cobracomanualidad = vPTcobracomanualidad,
                            impcomanualidad = vPTimpcomanualidad,
                            fechainicomanualidad = vPTfechainicomanualidad,
                            permitetnrpersonalizadas = vPTpermitetnrpersonalizadas,
                            transcomexpedicion = vPTtranscomexpedicion,
                            cobracomexpedicion = vPTcobracomexpedicion,
                            impcomexpedicion = vPTimpcomexpedicion,
                            transcomrenovacion = vPTtranscomrenovacion,
                            cobracomrenovacion = vPTcobracomrenovacion,
                            impcomrenovacion = vPTimpcomrenovacion,
                            tnrcuentadispersadora = vPTtnrcuentadispersadora,
                            tnrtranscargoctadispersadora = vPTtnrtranscargoctadispersadora,
                            tnrtransabonoctainfraestructura = vPTtnrtransabonoctainfraestructura,
                            tnrtranscargoctainfraestructura = vPTtnrtranscargoctainfraestructura,
                            tnrtransabonoctadispersadora = vPTtnrtransabonoctadispersadora,
                            tnrutilizactainfraestructura = vPTtnrutilizactainfraestructura,
                            tnrhabilitarproteccionsaldosasignados = vPTtnrhabilitarproteccionsaldosasignados,
                            tnrbloquearreversionasignaciones = vPTtnrbloquearreversionasignaciones,
                            tnrlapsoreversion = vPTtnrlapsoreversion,
                            tnrcongelarsaldoindividual = vPTtnrcongelarsaldoindividual,
                            tnrlapsocongelarsaldo = vPTtnrlapsocongelarsaldo,
                            tnrimagenactualizada = vPTtnrimagenactualizada,
                            estatusprocesosolicitudtarjeta = vPTestatusprocesosolicitudtarjeta,
                            registrostotalsolicitudtarjeta = vPTregistrostotalsolicitudtarjeta,
                            registrosavancesolicitudtarjeta = vPTregistrosavancesolicitudtarjeta,
                            tnrlogo = vPTtnrlogo,
                            escredito = vPTescredito,
                            permitecashback = vPTpermitecashback,
                            permitecashadvance = vPTpermitecashadvance,
                            limdiariocashadvanceposnac = vPTlimdiariocashadvanceposnac,
                            limmensualcashadvanceposnac = vPTlimmensualcashadvanceposnac,
                            limdiariocashbackposnac = vPTlimdiariocashbackposnac,
                            limmensualcashbackposnac = vPTlimmensualcashbackposnac,
                            porccomcashbacknac = vPTporccomcashbacknac,
                            porccomcashadvancenac = vPTporccomcashadvancenac,
                            numtrancashbacklibresmens = vPTnumtrancashbacklibresmens,
                            numtrancashadvancelibresmens = vPTnumtrancashadvancelibresmens,
                            maxtrancashbackdiarias = vPTmaxtrancashbackdiarias,
                            maxtrancashbackmensuales = vPTmaxtrancashbackmensuales,
                            maxtrancashadvancediarias = vPTmaxtrancashadvancediarias,
                            maxtrancashadvancemensuales = vPTmaxtrancashadvancemensuales,
                            permitetransdigitadas = vPTpermitetransdigitadas,
                            soportatranatmcajeropropio = vPTsoportatranatmcajeropropio,
                            soportatranatmcajeroconvenio = vPTsoportatranatmcajeroconvenio,
                            soportatranatmcajerored = vPTsoportatranatmcajerored,
                            porccomconsatmconvenio = vPTporccomconsatmconvenio,
                            porccomretatmconvenio = vPTporccomretatmconvenio,
                            porccomrevatmconvenio = vPTporccomrevatmconvenio,
                            limdiarioretatmconvenio = vPTlimdiarioretatmconvenio,
                            limmensretatmconvenio = vPTlimmensretatmconvenio,
                            numtranconsatmconveniolibres = vPTnumtranconsatmconveniolibres,
                            numtranretatmconveniolibres = vPTnumtranretatmconveniolibres,
                            maxtranconsatmconveniodiarias = vPTmaxtranconsatmconveniodiarias,
                            maxtranconsatmconveniomens = vPTmaxtranconsatmconveniomens,
                            maxtranretatmconveniodiarias = vPTmaxtranretatmconveniodiarias,
                            maxtranretatmconveniomens = vPTmaxtranretatmconveniomens,
                            soportatranatminternacional = vPTsoportatranatminternacional,
                            validarcvv2 = vPTvalidarcvv2,
                            limdiarioqps = vPTlimdiarioqps,
                            limdiariocat = vPTlimdiariocat,
                            montomaximotranqps = vPTmontomaximotranqps,
                            montomaximotrancat = vPTmontomaximotrancat,
                            limdiarioqpsudis = vPTlimdiarioqpsudis,
                            limdiariocatudis = vPTlimdiariocatudis,
                            montomaximotranqpsudis = vPTmontomaximotranqpsudis,
                            montomaximotrancatudis = vPTmontomaximotrancatudis,
                            limitediariomotovoz = vPTlimitediariomotovoz,
                            limitediariomotoint = vPTlimitediariomotoint,
                            limitemensualmotovoz = vPTlimitemensualmotovoz,
                            limitemensualmotoint = vPTlimitemensualmotoint,
                            maxtransmotovozdiario = vPTmaxtransmotovozdiario,
                            maxtransmotovozmensual = vPTmaxtransmotovozmensual,
                            maxtransmotointdiario = vPTmaxtransmotointdiario,
                            maxtransmotointmensual = vPTmaxtransmotointmensual,
                            permitemotovoz = vPTpermitemotovoz,
                            permitemotointernet = vPTpermitemotointernet,
                            permitetranstag = vPTpermitetranstag,
                            limitediariotag = vPTlimitediariotag,
                            limitemensualtag = vPTlimitemensualtag,
                            maxtrandiariotag = vPTmaxtrandiariotag,
                            maxtranmensualtag = vPTmaxtranmensualtag,
                            permitedeposito = vPTpermitedeposito,
                            porccomdepositonac = vPTporccomdepositonac,
                            limdiariodepositoposnac = vPTlimdiariodepositoposnac,
                            limmensualdepositoposnac = vPTlimmensualdepositoposnac,
                            numtrandepositolibresmens = vPTnumtrandepositolibresmens,
                            maxtrandepositodiarias = vPTmaxtrandepositodiarias,
                            maxtrandepositomensuales = vPTmaxtrandepositomensuales,
                            permitecontactless_nac_atm = vPTpermitecontactless_nac_atm,
                            permitecontactless_int_atm = vPTpermitecontactless_int_atm,
                            mtomaxdianac_contless_atm = vPTmtomaxdianac_contless_atm,
                            mtomaxmesnac_contless_atm = vPTmtomaxmesnac_contless_atm,
                            mtomaxdiaint_contless_atm = vPTmtomaxdiaint_contless_atm,
                            mtomaxmesint_contless_atm = vPTmtomaxmesint_contless_atm,
                            contmaxdianac_contless_atm = vPTcontmaxdianac_contless_atm,
                            contmaxmesnac_contless_atm = vPTcontmaxmesnac_contless_atm,
                            contmaxdiaint_contless_atm = vPTcontmaxdiaint_contless_atm,
                            contmaxmesint_contless_atm = vPTcontmaxmesint_contless_atm,
                            montomaxunicanac_contless_atm = vPTmontomaxunicanac_contless_atm,
                            montomaxunicanint_contless_atm = vPTmontomaxunicanint_contless_atm,
                            permitecontactless_nac_pos = vPTpermitecontactless_nac_pos,
                            permitecontactless_int_pos = vPTpermitecontactless_int_pos,
                            mtomaxdianac_contless_pos = vPTmtomaxdianac_contless_pos,
                            mtomaxmesnac_contless_pos = vPTmtomaxmesnac_contless_pos,
                            mtomaxdiaint_contless_pos = vPTmtomaxdiaint_contless_pos,
                            mtomaxmesint_contless_pos = vPTmtomaxmesint_contless_pos,
                            contmaxdianac_contless_pos = vPTcontmaxdianac_contless_pos,
                            contmaxmesnac_contless_pos = vPTcontmaxmesnac_contless_pos,
                            contmaxdiaint_contless_pos = vPTcontmaxdiaint_contless_pos,
                            contmaxmesint_contless_pos = vPTcontmaxmesint_contless_pos,
                            montomaxunicanac_contless_pos = vPTmontomaxunicanac_contless_pos,
                            montomaxunicanint_contless_pos = vPTmontomaxunicanint_contless_pos,
                            permitemsi = vPTpermitemsi,
                            contmaxreversosdiariosatminternacional = vPTcontmaxreversosdiariosatminternacional,
                            permite_retiro_sin_tarjeta_atm = vPTpermite_retiro_sin_tarjeta_atm,
                            campanianotif = vPTcampaniaNotif
                        WHERE codproductotarjeta = vPTcodproductotarjeta;
                  
                LET vContadorActualizacion = vContadorActualizacion + dbinfo("sqlca.sqlerrd2");
                IF (  vContadorActualizacion >= 1 ) THEN
                    LET vCodigoRetorno = '00000';
                    LET vMensajeRetorno = 'Registros Actualizados Prod Tarjeta #' ||vContadorActualizacion;
                END IF
            END IF
        END IF 
        

        END FOREACH
                
        
        RETURN vCodigoRetorno, vMensajeRetorno;
    END

END PROCEDURE
DOCUMENT
'Base de datos: intercard',
'Fecha de creacion: 05 de junio del 2021',
'Armando Garcia Ortiz',
'Coordinacion de Tarjetas - Gerencia I',
'Descripcion: Actualizacion del catalogo de producto tarjeta',
'#2',
'Fecha de modificacion: 06 de julio del 2021',
'Se agrega el nuevo campo en el catalogo'
;

CREATE PROCEDURE "informix".sp_trans_movs_pivote_stat06( pFechaBusqInicial DATETIME YEAR to FRACTION(5), pFechaBusqFinal DATETIME YEAR to FRACTION(5) )
    RETURNING CHAR (5) as rCODIGO_RETORNO, CHAR(120) as rMENSAJE_RESPUESTA;
    
    DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80);
    
	DEFINE vCODIGO_RETORNO CHAR(5);
    DEFINE vMENSAJE_RETORNO CHAR(120);
    DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(80);
    DEFINE CONTADOR_TRANSACCIONES SMALLINT;    
    DEFINE NOMBRE_UNL_ARCHIVO VARCHAR(33);
    DEFINE SCRIPT_EJECUCION VARCHAR(34);
    DEFINE SCRIPT_UPD_STS VARCHAR(40);
    DEFINE PREFIJO_ARCHIVO VARCHAR(13);
    DEFINE NOM_ARCH_REG_CNC_PIV VARCHAR(33);
    DEFINE NOM_ARCH_ERR_CNC_PIV VARCHAR(33);    
    DEFINE vExecuteSQL LVARCHAR(5000);    
    DEFINE vIndicadorProceso CHAR(1);        
    DEFINE vAnio VARCHAR(7);
      
    LET vCODIGO_RETORNO = '00000';
    LET vMENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
    LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
    LET SQLERR = '';
	LET ISAM_ERR = '';
	LET ERROR_INFO = '';
    
    LET vExecuteSQL = '';
    LET CONTADOR_TRANSACCIONES = 1000;
    
    LET vAnio = YEAR(pFechaBusqInicial);
    
    LET NOMBRE_UNL_ARCHIVO = '';
    LET NOM_ARCH_REG_CNC_PIV = '';
    LET NOM_ARCH_ERR_CNC_PIV = '';
    LET PREFIJO_ARCHIVO = 'tran_piv_';
    LET vIndicadorProceso = '0';
    
    --SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "debug_sp_trans_movs_pivote_stat06.out";                                                
    --TRACE ON;        
	
    BEGIN 		

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "excep_sp_trans_movs_pivote_stat06.err.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET vCODIGO_RETORNO = SQLERR;
                LET vMENSAJE_RETORNO = ISAM_ERR||' '||ERROR_INFO||' '||current||' '||'vIndicadorProceso =>'||vIndicadorProceso;
                RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION;


        LET NOMBRE_UNL_ARCHIVO = PREFIJO_ARCHIVO||'piv_'||vAnio||'.unl';
        LET SCRIPT_EJECUCION = PREFIJO_ARCHIVO||'ejec_piv_'||vAnio||'.sql';
        LET SCRIPT_UPD_STS = PREFIJO_ARCHIVO||'ejec_upd_sts_piv_'||vAnio||'.sql';
        LET NOM_ARCH_REG_CNC_PIV = PREFIJO_ARCHIVO||'reg_piv_'||vAnio||'.txt';
        LET NOM_ARCH_ERR_CNC_PIV = PREFIJO_ARCHIVO||'err_piv_'||vAnio||'.log';           

        TRUNCATE TABLE intercard:"informix".tbl_cnc_stat_06_pivote DROP STORAGE;
        
        LET vIndicadorProceso = '1';
        
        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||NOMBRE_UNL_ARCHIVO||
        ' SELECT keyx, fechaconciliacion, secuencia, numtarjeta, 0 '  ||
        '    FROM intercard:"informix".conciliacion_atm_stat06_'||vAnio||
        ' WHERE fechaconciliacion  BETWEEN '''||pFechaBusqInicial||''' AND '''||pFechaBusqFinal||''' '||
         '" >'||RUTA_UNLOAD_RESPALDOS||SCRIPT_EJECUCION;            
        SYSTEM vExecuteSQL;        
        
        LET vExecuteSQL   = '';
        LET vExecuteSQL   = 'dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||SCRIPT_EJECUCION;
        SYSTEM vExecuteSQL;

        LET vIndicadorProceso = '2';
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "FILE '"||RUTA_UNLOAD_RESPALDOS||NOMBRE_UNL_ARCHIVO|| "' delimiter '|' "|| '5'||                          
                          "; INSERT INTO tbl_cnc_stat_06_pivote; "||'"'||' > '||RUTA_UNLOAD_RESPALDOS||NOM_ARCH_REG_CNC_PIV;
        SYSTEM vExecuteSQL;        
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||RUTA_UNLOAD_RESPALDOS||NOM_ARCH_REG_CNC_PIV||" -l "||RUTA_UNLOAD_RESPALDOS||NOM_ARCH_ERR_CNC_PIV||" -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
        LET vExecuteSQL = ' echo UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".conciliacion_atm_stat06_'||vAnio||' > '||RUTA_UNLOAD_RESPALDOS||SCRIPT_UPD_STS;
        SYSTEM vExecuteSQL;    
         
        LET vExecuteSQL   = '';
        LET vExecuteSQL   = 'dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||SCRIPT_UPD_STS;
        SYSTEM vExecuteSQL;
        
        LET vIndicadorProceso = '3';
            
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'rm -f ' ||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVO||'*';
        SYSTEM vExecuteSQL;
        
        

        RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;	
		
	END
END PROCEDURE
DOCUMENT
'Base de datos: intercard',
'Fecha de creacion: 15 de abril del 2021',
'Armando Garcia Ortiz',
'Coordinacion de Tarjetas - Gerencia I',
'Descripcion: Componente principal para registrar la informacion a la tabla pivote del stat 06'
;

CREATE PROCEDURE "informix".sp_consultartarjetas_debcred_rep_iccat_exp(pempresa CHAR(3), pnumcte CHAR(9), pNumRegistros SMALLINT)
RETURNING char(9),char(104),char(16), char(1), char(50), char(4), char(20), char(60), char(1), char(3),char(9),char(9);

--@comment: Declaracion variables para responder
DEFINE ccodret char(9);
DEFINE isam_err integer;
DEFINE error_info varchar(104);
DEFINE isql_err integer;
DEFINE cnomcliente char (104);
DEFINE cnumtarjeta char (16);
DEFINE ctipotar char(1);
DEFINE cestatustar char (50);
DEFINE cproductotar char (4);
DEFINE cnumcuenta char (20);
DEFINE cnumcuentaAux char (20);
DEFINE cstatuscuenta char (3);
DeFINE cstatuscuentadesc char (60);
DEFINE ctitular char (1);
DEFINE ccodestatus char (3);
DEFINE cnombre1 char(20);
DEFINE cnombre2 char(20);
DEFINE paterno char(20);
DEFINE materno char(20);
DEFINE cnumCteTitularCuenta char(9);
DEFINE cnumCteTarjeta char(9);
DEFINE iExiste INTEGER;
DEFINE cExisteCta INTEGER;

LET ccodret = "000000000";
LET cnomcliente = "";
LET cnumtarjeta = "";
LET ctipotar = "";
LET cestatustar = "";
LET cproductotar = "";
LET cnumcuenta = "";
LET cnumcuentaAux = "";
LET cstatuscuenta = "";
LET cstatuscuentadesc = "";
LET ctitular = "";
LET ccodestatus = "";
LET cnumCteTitularCuenta="";
LET cnumCteTarjeta="";
LET iExiste = 0;
LET cExisteCta = 0;

BEGIN

	ON EXCEPTION SET isql_err,isam_err, error_info
		IF isql_err <> 0 THEN
			LET ccodret = isql_err;
			LET cnomcliente = error_info;
			
			DROP TABLE IF EXISTS tbl_cuentascliente;
			DROP TABLE IF EXISTS tbl_tarjetascliente;
			
			RETURN ccodret,cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuenta, ctitular, ccodestatus,cnumCteTitularCuenta,cnumCteTarjeta;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	SET DEBUG FILE TO '/tmp/sp_consultartarjetas_debcred_rep_iccat.out';
	TRACE ON;

	DROP TABLE IF EXISTS tbl_cuentascliente;
	CREATE TEMP TABLE tbl_cuentascliente(
		numcte CHAR(20),
		producto CHAR(4),
		statuscta CHAR(3),
		tipotar CHAR(1),
		cuenta CHAR(20)
	) WITH NO LOG;

	DROP TABLE IF EXISTS tbl_tarjetascliente;
	CREATE TEMP TABLE tbl_tarjetascliente(
		numtarjeta CHAR(20),
		cuenta CHAR(20),
		numcte CHAR(20)
	) WITH NO LOG;

	--Se llena tabla de paso con cuentas de debito del cliente
	FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_maechq mae1)}
				cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
			INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta
			FROM bdicheq:'informix'.sc_maechq cta
			WHERE cta.num_cte = pnumcte
			AND cta.producto = '2400'

		INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta);

	END FOREACH;

	--Se llena tabla de paso con cuentas de credito del cliente
	FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_maecreda)}
				cta.numcte, cta.num_producto, cta.status_cred, 'C', cta.num_credito
			INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta
			FROM bdicred:'informix'.sd_maecred cta
			WHERE cta.numcte = pnumcte
			AND cta.num_producto IN ('7000', '8100')

		INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta);

	END FOREACH;

	--Se llena tabla de paso con tarjetas de debito del cliente y de los clientes que tienen cuentas relacionadas al cliente titulares o adicionales
	FOREACH WITH HOLD
	SELECT DISTINCT(cuenta)
	INTO cnumcuenta
	FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'D'
	
		FOREACH WITH HOLD SELECT  {+INDEX(bdicheq:'informix'.sc_tarjeta ix_tarjeta4)}
				trjasig.num_tarjeta, trjasig.numcte
				INTO cnumtarjeta, cnumCteTarjeta
				FROM bdicheq:'informix'.sc_tarjeta trjasig
				WHERE trjasig.cuenta = cnumcuenta
				AND trjasig.numcte != pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de debito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				FOREACH WITH HOLD
				SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq)} cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
				INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicheq:'informix'.sc_maechq cta WHERE cta.cuenta = cnumcuenta AND producto = '2400'
				
					INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
					VALUES( cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux );
					
				END FOREACH;
				
			END IF;

		END FOREACH;
		
	END FOREACH;
	
	FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_tarjeta idx_sd_tarjeta1)}
				trjasig.num_tarjeta, trjasig.numcte, trjasig.cuenta
				INTO cnumtarjeta, cnumCteTarjeta, cnumcuenta
				FROM bdicheq:'informix'.sc_tarjeta trjasig
				WHERE trjasig.numcte = pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')
				

				INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
				VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de debito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				FOREACH WITH HOLD
				SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq)} cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
				INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicheq:'informix'.sc_maechq cta WHERE cta.cuenta = cnumcuenta AND producto = '2400'
				
					INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
					VALUES( cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux );
					
				END FOREACH;
				
			END IF;

	END FOREACH;
	
	
	

	FOREACH WITH HOLD 
	SELECT DISTINCT(cuenta)
	INTO cnumcuenta
	FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'C'
	
		--Se llena tabla de paso con tarjetas de debito del cliente y de los credito que tienen cuentas relacionadas al cliente titulares o adicionales
		FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_tarjeta pry_tarjeta)}
				trjasig.num_tarjeta, trjasig.numcte
				INTO cnumtarjeta, cnumCteTarjeta
				FROM  bdicred:'informix'.sd_tarjeta trjasig
				WHERE trjasig.num_credito = cnumcuenta 
				AND trjasig.numcte != pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de credito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_idx_maecredb)} cta.numcte, cta.num_producto, cta.status_cred, 'C', cta.num_credito
				INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicred:'informix'.sd_maecred cta WHERE empresa = pempresa AND cta.num_credito = cnumcuenta AND num_producto IN ('7000', '8100')
				
				INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
				VALUES(cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
				
				END FOREACH;
				
			END IF;

		END FOREACH;
	END FOREACH;
	
	FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_tarjeta idx_sd_tarjeta1)}
				trjasig.num_tarjeta, trjasig.numcte, trjasig.num_credito
				INTO cnumtarjeta, cnumCteTarjeta, cnumcuenta
				FROM  bdicred:'informix'.sd_tarjeta trjasig
				WHERE trjasig.numcte = pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de credito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_idx_maecredb)} cta.numcte, cta.num_producto, cta.status_cred, 'C', cta.num_credito
				INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicred:'informix'.sd_maecred cta WHERE empresa = pempresa AND cta.num_credito = cnumcuenta AND num_producto IN ('7000', '8100')
				
				INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
				VALUES(cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
				
				END FOREACH;
				
			END IF;

	END FOREACH;
	
	
	--Una vez obtenidos los datos anteriores se recorren tarjeta por tarjeta y se obtienen los datos faltantes para regresarlos en el retorno del SPL
	FOREACH WITH HOLD
			SELECT SKIP pNumRegistros FIRST 10
				trjasig.numtarjeta, trjasig.cuenta, trjasig.numcte, cta.numcte, cta.producto, cta.statuscta, cta.tipotar
			INTO cnumtarjeta, cnumcuenta, cnumCteTarjeta, cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar
			FROM 'informix'.tbl_tarjetascliente trjasig INNER JOIN 'informix'.tbl_cuentascliente cta
			ON cta.cuenta = trjasig.cuenta
			WHERE ((cta.numcte = pnumcte)
			OR (cta.numcte <> pnumcte AND trjasig.numcte = pnumcte))
			ORDER BY cta.tipotar DESC, trjasig.numtarjeta ASC

		SELECT trj.nombre, trj.codstatustarjeta, trj.titular, trj.numtarjeta
		INTO cnomcliente, ccodestatus, ctitular, cnumtarjeta
		FROM 'informix'.tarjeta trj
		WHERE trj.numtarjeta = cnumtarjeta AND trj.codstatusasignada = 'SIA';

		SELECT trjest.codstatustarjeta, trjest.descstatustarjeta
		INTO ccodestatus, cestatustar
		FROM 'informix'.statustarjeta trjest
		WHERE trjest.codstatustarjeta = ccodestatus;

		IF TRIM(ctipotar) = 'D' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicheq:'informix'.sc_mae_estatus ctaest WHERE ctaest.cod_estatus = cstatuscuenta;
		ELIF TRIM(ctipotar) = 'C' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicred:'informix'.sd_tipocartera ctaest WHERE ctaest.status_cred = cstatuscuenta;
		END IF;

		LET cnombre1='';
		LET cnombre2='';
		LET paterno='';
		LET materno='';

		FOREACH
			SELECT FIRST 1 s.nombre1,s.nombre2,s.apaterno,s.amaterno
			INTO cnombre1,cnombre2,paterno,materno
			FROM "informix".solicitudtarjeta s INNER JOIN "informix".detalle_maquila d ON (s.idsolicitud = d.idsolicitud)
			WHERE s.numcuenta = cnumcuenta AND d.numtarjeta = cnumtarjeta
			ORDER BY s.fechasolicitud DESC
		END FOREACH
		--ExtracciÃ³n de nombre de tabla alterna
		IF TRIM(NVL(cnombre1,''))='' AND TRIM(NVL(cnombre2,''))='' THEN
			--SELECT s.nombre1,s.nombre2,s.apaterno,s.amaterno
			--INTO cnombre1,cnombre2,paterno,materno
			SELECT s.nombre1, SUBSTRING( TRIM(s.apaterno) FROM 1 FOR ( 20 - char_length(TRIM(s.nombre1)) ) ) AS apaterno
			INTO cnombre1,paterno
			FROM "informix".solicitudtarjeta s INNER JOIN bdicred:"informix".sd_credito_upgrade cu ON (s.numcliente = cu.numcte AND s.numcuenta = cu.num_credito)
			INNER JOIN intercard:"informix".detalle_maquila de ON (s.idsolicitud = de.idsolicitud AND de.numtarjeta = cnumtarjeta)
			WHERE cu.numero_credito_upgrade = cnumcuenta AND cu.numerotarjeta_upgrade = cnumtarjeta;
			
			IF char_length(TRIM(NVL(cnombre1,'')))<=1 OR char_length(TRIM(NVL(paterno,'')))<=1 THEN
				SELECT nombre1, SUBSTRING( TRIM(apell_paterno) FROM 1 FOR ( 20 - char_length(TRIM(nombre1)) ) ) AS apaterno
				INTO cnombre1,paterno
				FROM bdinteg:si_cliente WHERE numcte=pnumcte;
			END IF;
		END IF;
		
		IF TRIM(NVL(cnombre1,''))='' THEN
			LET cnombre1='-';
		END IF;
		IF TRIM(NVL(cnombre2,''))='' THEN
			LET cnombre2='-';
		END IF;
		IF TRIM(NVL(paterno,''))='' THEN
			LET paterno='-';
		END IF;
		IF TRIM(NVL(materno,''))='' THEN
			LET materno='-';
		END IF;
		LET cnomcliente = cnombre1||'|'||cnombre2||'|'||paterno||'|'||materno;

		IF cnumtarjeta IS NOT NULL THEN -- TARJETA != 'SIA'
			RETURN ccodret, cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta WITH RESUME;
                        --DROP TABLE IF EXISTS tbl_cuentascliente;
                        --DROP TABLE IF EXISTS tbl_tarjetascliente;
		END IF;

		LET iExiste = iExiste + 1;

	END FOREACH
	
	DROP TABLE IF EXISTS tbl_cuentascliente;
    DROP TABLE IF EXISTS tbl_tarjetascliente;

	--En caso de que el cliente no tenga ninguna tarjeta
	IF iExiste = 0 THEN
		RETURN '000000001', 'No tiene tarjetas', cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta;
                --DROP TABLE IF EXISTS tbl_cuentascliente;
                --DROP TABLE IF EXISTS tbl_tarjetascliente;
	END IF;

END
END PROCEDURE
DOCUMENT
'OBJETIVO: 	consultar las tarjetas debito platino, credito oro y platino relacionadas al cliente o su cuenta ',
'AUTOR:		Arturo Astorga',
'FECHA : 	27/07/2018',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica la tabla de donde valida el numero de producto',
'AUTOR:		Arturo Astorga',
'FECHA : 	28/09/2018',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica el sp para que retorne el nombre que se rotulara en la tarjeta',
'AUTOR:		Arturo Astorga',
'FECHA : 	27/11/2018',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica el sp para que retorne el numero de cliente titular de la cuenta',
'AUTOR:		Arturo Astorga',
'FECHA : 	20/02/2019',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica el sp para que retorne el numero de cliente titular de la tarjeta',
'AUTOR:		Arturo Astorga',
'FECHA : 	23/04/2019',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	optimizar las consultas para obtencion de la informacion',
'AUTOR:		Elmer Lopez Valenzuela',
'FECHA : 	27/01/2020',
'SolicitÃ³:  jose luis polanco',
'BD : 		intercard';

CREATE PROCEDURE "informix".sp_consultartarjetas_debcred_rep_iccat(pempresa CHAR(3), pnumcte CHAR(9), pNumRegistros SMALLINT)
RETURNING char(9),char(104),char(16), char(1), char(50), char(4), char(20), char(60), char(1), char(3),char(9),char(9);

--@comment: Declaracion variables para responder
DEFINE ccodret char(9);
DEFINE isam_err integer;
DEFINE error_info varchar(104);
DEFINE isql_err integer;
DEFINE cnomcliente char (104);
DEFINE cnumtarjeta char (16);
DEFINE ctipotar char(1);
DEFINE cestatustar char (50);
DEFINE cproductotar char (4);
DEFINE cnumcuenta char (20);
DEFINE cnumcuentaAux char (20);
DEFINE cstatuscuenta char (3);
DeFINE cstatuscuentadesc char (60);
DEFINE ctitular char (1);
DEFINE ccodestatus char (3);
DEFINE cnombre1 char(20);
DEFINE cnombre2 char(20);
DEFINE paterno char(20);
DEFINE materno char(20);
DEFINE cnumCteTitularCuenta char(9);
DEFINE cnumCteTarjeta char(9);
DEFINE iExiste INTEGER;
DEFINE cExisteCta INTEGER;

LET ccodret = "000000000";
LET cnomcliente = "";
LET cnumtarjeta = "";
LET ctipotar = "";
LET cestatustar = "";
LET cproductotar = "";
LET cnumcuenta = "";
LET cnumcuentaAux = "";
LET cstatuscuenta = "";
LET cstatuscuentadesc = "";
LET ctitular = "";
LET ccodestatus = "";
LET cnumCteTitularCuenta="";
LET cnumCteTarjeta="";
LET iExiste = 0;
LET cExisteCta = 0;

BEGIN

	ON EXCEPTION SET isql_err,isam_err, error_info
		IF isql_err <> 0 THEN
			LET ccodret = isql_err;
			LET cnomcliente = error_info;
			
			DROP TABLE IF EXISTS tbl_cuentascliente;
			DROP TABLE IF EXISTS tbl_tarjetascliente;
			
			RETURN ccodret,cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuenta, ctitular, ccodestatus,cnumCteTitularCuenta,cnumCteTarjeta;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/tmp/sp_consultartarjetas_debcred_rep_iccat.out';
	--TRACE ON;

	DROP TABLE IF EXISTS tbl_cuentascliente;
	CREATE TEMP TABLE tbl_cuentascliente(
		numcte CHAR(20),
		producto CHAR(4),
		statuscta CHAR(3),
		tipotar CHAR(1),
		cuenta CHAR(20)
	) WITH NO LOG;

	DROP TABLE IF EXISTS tbl_tarjetascliente;
	CREATE TEMP TABLE tbl_tarjetascliente(
		numtarjeta CHAR(20),
		cuenta CHAR(20),
		numcte CHAR(20)
	) WITH NO LOG;

	--Se llena tabla de paso con cuentas de debito del cliente
	FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_maechq mae1)}
				cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
			INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta
			FROM bdicheq:'informix'.sc_maechq cta
			WHERE cta.num_cte = pnumcte
			AND cta.producto = '2400'

		INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta);

	END FOREACH;

	--Se llena tabla de paso con cuentas de credito del cliente
	FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_maecreda)}
				cta.numcte, cta.num_producto, cta.status_cred, 'C', cta.num_credito
			INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta
			FROM bdicred:'informix'.sd_maecred cta
			WHERE cta.numcte = pnumcte
			AND cta.num_producto IN ('7000', '8100')

		INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta);

	END FOREACH;

	--Se llena tabla de paso con tarjetas de debito del cliente y de los clientes que tienen cuentas relacionadas al cliente titulares o adicionales
	FOREACH WITH HOLD
	SELECT DISTINCT(cuenta)
	INTO cnumcuenta
	FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'D'
	
		FOREACH WITH HOLD SELECT  {+INDEX(bdicheq:'informix'.sc_tarjeta ix_tarjeta4)}
				trjasig.num_tarjeta, trjasig.numcte
				INTO cnumtarjeta, cnumCteTarjeta
				FROM bdicheq:'informix'.sc_tarjeta trjasig
				WHERE trjasig.cuenta = cnumcuenta
				AND trjasig.numcte != pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de debito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				FOREACH WITH HOLD
				SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq)} cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
				INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicheq:'informix'.sc_maechq cta WHERE cta.cuenta = cnumcuenta AND producto = '2400'
				
					INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
					VALUES( cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux );
					
				END FOREACH;
				
			END IF;

		END FOREACH;
		
	END FOREACH;
	
	FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_tarjeta idx_sd_tarjeta1)}
				trjasig.num_tarjeta, trjasig.numcte, trjasig.cuenta
				INTO cnumtarjeta, cnumCteTarjeta, cnumcuenta
				FROM bdicheq:'informix'.sc_tarjeta trjasig
				WHERE trjasig.numcte = pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')
				

				INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
				VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de debito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				FOREACH WITH HOLD
				SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq)} cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
				INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicheq:'informix'.sc_maechq cta WHERE cta.cuenta = cnumcuenta AND producto = '2400'
				
					INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
					VALUES( cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux );
					
				END FOREACH;
				
			END IF;

	END FOREACH;
	
	
	

	FOREACH WITH HOLD 
	SELECT DISTINCT(cuenta)
	INTO cnumcuenta
	FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'C'
	
		--Se llena tabla de paso con tarjetas de debito del cliente y de los credito que tienen cuentas relacionadas al cliente titulares o adicionales
		FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_tarjeta pry_tarjeta)}
				trjasig.num_tarjeta, trjasig.numcte
				INTO cnumtarjeta, cnumCteTarjeta
				FROM  bdicred:'informix'.sd_tarjeta trjasig
				WHERE trjasig.num_credito = cnumcuenta 
				AND trjasig.numcte != pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de credito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_idx_maecredb)} cta.numcte, cta.num_producto, cta.status_cred, 'C', cta.num_credito
				INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicred:'informix'.sd_maecred cta WHERE empresa = pempresa AND cta.num_credito = cnumcuenta AND num_producto IN ('7000', '8100')
				
				INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
				VALUES(cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
				
				END FOREACH;
				
			END IF;

		END FOREACH;
	END FOREACH;
	
	FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_tarjeta idx_sd_tarjeta1)}
				trjasig.num_tarjeta, trjasig.numcte, trjasig.num_credito
				INTO cnumtarjeta, cnumCteTarjeta, cnumcuenta
				FROM  bdicred:'informix'.sd_tarjeta trjasig
				WHERE trjasig.numcte = pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de credito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_idx_maecredb)} cta.numcte, cta.num_producto, cta.status_cred, 'C', cta.num_credito
				INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicred:'informix'.sd_maecred cta WHERE empresa = pempresa AND cta.num_credito = cnumcuenta AND num_producto IN ('7000', '8100')
				
				INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
				VALUES(cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
				
				END FOREACH;
				
			END IF;

	END FOREACH;
	
	
	--Una vez obtenidos los datos anteriores se recorren tarjeta por tarjeta y se obtienen los datos faltantes para regresarlos en el retorno del SPL
	FOREACH WITH HOLD
			SELECT SKIP pNumRegistros FIRST 10
				trjasig.numtarjeta, trjasig.cuenta, trjasig.numcte, cta.numcte, cta.producto, cta.statuscta, cta.tipotar
			INTO cnumtarjeta, cnumcuenta, cnumCteTarjeta, cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar
			FROM 'informix'.tbl_tarjetascliente trjasig INNER JOIN 'informix'.tbl_cuentascliente cta
			ON cta.cuenta = trjasig.cuenta
			WHERE ((cta.numcte = pnumcte)
			OR (cta.numcte <> pnumcte AND trjasig.numcte = pnumcte))
			ORDER BY cta.tipotar DESC, trjasig.numtarjeta ASC

		SELECT trj.nombre, trj.codstatustarjeta, trj.titular, trj.numtarjeta
		INTO cnomcliente, ccodestatus, ctitular, cnumtarjeta
		FROM 'informix'.tarjeta trj
		WHERE trj.numtarjeta = cnumtarjeta AND trj.codstatusasignada = 'SIA';

		SELECT trjest.codstatustarjeta, trjest.descstatustarjeta
		INTO ccodestatus, cestatustar
		FROM 'informix'.statustarjeta trjest
		WHERE trjest.codstatustarjeta = ccodestatus;

		IF TRIM(ctipotar) = 'D' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicheq:'informix'.sc_mae_estatus ctaest WHERE ctaest.cod_estatus = cstatuscuenta;
		ELIF TRIM(ctipotar) = 'C' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicred:'informix'.sd_tipocartera ctaest WHERE ctaest.status_cred = cstatuscuenta;
		END IF;

		LET cnombre1='';
		LET cnombre2='';
		LET paterno='';
		LET materno='';

		FOREACH
			SELECT FIRST 1 s.nombre1,s.nombre2,s.apaterno,s.amaterno
			INTO cnombre1,cnombre2,paterno,materno
			FROM "informix".solicitudtarjeta s INNER JOIN "informix".detalle_maquila d ON (s.idsolicitud = d.idsolicitud)
			WHERE s.numcuenta = cnumcuenta AND d.numtarjeta = cnumtarjeta
			ORDER BY s.fechasolicitud DESC
		END FOREACH
		--ExtracciÃ³n de nombre de tabla alterna
		IF TRIM(NVL(cnombre1,''))='' AND TRIM(NVL(cnombre2,''))='' THEN
			--SELECT s.nombre1,s.nombre2,s.apaterno,s.amaterno
			--INTO cnombre1,cnombre2,paterno,materno
			SELECT s.nombre1, SUBSTRING( TRIM(s.apaterno) FROM 1 FOR ( 20 - char_length(TRIM(s.nombre1)) ) ) AS apaterno
			INTO cnombre1,paterno
			FROM "informix".solicitudtarjeta s INNER JOIN bdicred:"informix".sd_credito_upgrade cu ON (s.numcliente = cu.numcte AND s.numcuenta = cu.num_credito)
			INNER JOIN intercard:"informix".detalle_maquila de ON (s.idsolicitud = de.idsolicitud AND de.numtarjeta = cnumtarjeta)
			WHERE cu.numero_credito_upgrade = cnumcuenta AND cu.numerotarjeta_upgrade = cnumtarjeta;
			
			--IF char_length(TRIM(NVL(cnombre1,'')))<=1 OR char_length(TRIM(NVL(paterno,'')))<=1 THEN	--Se modifica funcion
			IF LENGTH(TRIM(NVL(cnombre1,'')))<=1 OR LENGTH(TRIM(NVL(paterno,'')))<=1 THEN
				SELECT nombre1, SUBSTRING( TRIM(apell_paterno) FROM 1 FOR ( 20 - char_length(TRIM(nombre1)) ) ) AS apaterno
				INTO cnombre1,paterno
				FROM bdinteg:si_cliente WHERE numcte=pnumcte;
			END IF;
		END IF;
		
		IF TRIM(NVL(cnombre1,''))='' THEN
			LET cnombre1='-';
		END IF;
		IF TRIM(NVL(cnombre2,''))='' THEN
			LET cnombre2='-';
		END IF;
		IF TRIM(NVL(paterno,''))='' THEN
			LET paterno='-';
		END IF;
		IF TRIM(NVL(materno,''))='' THEN
			LET materno='-';
		END IF;
		LET cnomcliente = cnombre1||'|'||cnombre2||'|'||paterno||'|'||materno;

		IF cnumtarjeta IS NOT NULL THEN -- TARJETA != 'SIA'
			RETURN ccodret, cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta WITH RESUME;
                        --DROP TABLE IF EXISTS tbl_cuentascliente;
                        --DROP TABLE IF EXISTS tbl_tarjetascliente;
		END IF;

		LET iExiste = iExiste + 1;

	END FOREACH
	
	DROP TABLE IF EXISTS tbl_cuentascliente;
    DROP TABLE IF EXISTS tbl_tarjetascliente;

	--En caso de que el cliente no tenga ninguna tarjeta
	IF iExiste = 0 THEN
		RETURN '000000001', 'No tiene tarjetas', cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta;
                --DROP TABLE IF EXISTS tbl_cuentascliente;
                --DROP TABLE IF EXISTS tbl_tarjetascliente;
	END IF;

END
END PROCEDURE
DOCUMENT
'OBJETIVO: 	consultar las tarjetas debito platino, credito oro y platino relacionadas al cliente o su cuenta ',
'AUTOR:		Arturo Astorga',
'FECHA : 	27/07/2018',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica la tabla de donde valida el numero de producto',
'AUTOR:		Arturo Astorga',
'FECHA : 	28/09/2018',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica el sp para que retorne el nombre que se rotulara en la tarjeta',
'AUTOR:		Arturo Astorga',
'FECHA : 	27/11/2018',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica el sp para que retorne el numero de cliente titular de la cuenta',
'AUTOR:		Arturo Astorga',
'FECHA : 	20/02/2019',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica el sp para que retorne el numero de cliente titular de la tarjeta',
'AUTOR:		Arturo Astorga',
'FECHA : 	23/04/2019',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	optimizar las consultas para obtencion de la informacion',
'AUTOR:		Elmer Lopez Valenzuela',
'FECHA : 	27/01/2020',
'SolicitÃ³:  jose luis polanco',
'BD : 		intercard';

CREATE PROCEDURE "informix".sp_centinela_rst()
    RETURNING CHAR(5) AS rCodigoRetorno, VARCHAR(160) AS rMensaje, DATETIME YEAR TO FRACTION(3) AS rFechaEjecucion, INTEGER as rTotalTrxs;
    
    DEFINE SQLERR INTEGER;
    DEFINE ISAM_ERR INTEGER;
    DEFINE ERROR_INFO VARCHAR(80);
    DEFINE vCodigoRetorno CHAR(5);
    DEFINE vMensajeRetorno VARCHAR(160);

    DEFINE vTotalTransaccionesMov SMALLINT;
    DEFINE vFechaInicial DATETIME YEAR TO FRACTION(3);
    DEFINE vFechaFinal DATETIME YEAR TO FRACTION(3);
    DEFINE RUTA_UNLOAD VARCHAR(100);
    DEFINE vFecha DATE;
    DEFINE vHora VARCHAR(5);
    DEFINE vTransaccPromedio INTEGER;
    DEFINE vCondBusqHorario VARCHAR(30);
    
    LET vFechaInicial = '';
    LET vFechaFinal = '';
    LET vTotalTransaccionesMov = 0;
    LET vTransaccPromedio = 0;

    LET RUTA_UNLOAD = '/RESPALDOSNEW/';
    LET vCodigoRetorno = '';
    LET vMensajeRetorno = '';
    LET vHora = '';
    LET vFecha = '';
    LET vCondBusqHorario = '';
    
    --SET DEBUG FILE TO RUTA_UNLOAD || "debug_sp_centinela_rst.out";
	--TRACE ON;
    
	BEGIN 

		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO

            SET DEBUG FILE TO RUTA_UNLOAD || "excepcion_sp_centinela_rst.err.out" WITH APPEND;
            TRACE ON;

            IF ( SQLERR <> 0 ) THEN
            LET vCodigoRetorno = SQLERR;
            LET vMensajeRetorno = ERROR_INFO;
            RETURN vCodigoRetorno, vMensajeRetorno, vFechaFinal, vTotalTransaccionesMov;
            END IF;

		END EXCEPTION;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		
		SELECT ( DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND ) - 30 units minute,
                DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
            INTO vFechaInicial, vFechaFinal
        FROM sysmaster:"informix".sysshmvals;

        SELECT LIMIT 1 cr_cobrado_fecha::date as fecha, 
                TO_CHAR( EXTEND(cr_cobrado_fecha, HOUR TO HOUR), '%H:%M') as hora, 
                    COUNT(*) as total_trxs
            INTO vFecha, vHora, vTotalTransaccionesMov
        FROM bdirst:"informix".claves_retiro
            WHERE cr_cobrado_fecha BETWEEN vFechaInicial AND vFechaFinal
                AND cr_status = 'C'
        GROUP BY 1, 2;
        
        LET vCodigoRetorno = '00000';
		LET vMensajeRetorno = 'Transaccionalidad correcta.';
        
        IF ( vHora IN ('00:00','01:00','02:00','03:00','04:00','05:00','06:00','07:00','08:00' ) ) THEN
            LET vCondBusqHorario = 'rst_horario_a';
        END IF

        IF ( vHora IN ('09:00','10:00') ) THEN
            LET vCondBusqHorario = 'rst_horario_b';
        END IF
        
        IF ( vHora IN ('11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00' ) ) THEN
            LET vCondBusqHorario = 'rst_horario_c';
            
        END IF
        
        IF ( vHora IN ('21:00','22:00','23:00') ) THEN
            LET vCondBusqHorario = 'rst_horario_d';
        END IF
        
        SELECT valores 
            INTO vTransaccPromedio
        FROM intercard:"informix".tbl_inter_parametros
            WHERE cond_busqueda = vCondBusqHorario;
            
        IF ( vTotalTransaccionesMov > vTransaccPromedio ) THEN
            LET vCodigoRetorno = '00001';
            LET vMensajeRetorno = 'Promedio mayor a '||vTotalTransaccionesMov || ' transacciones.';
        END IF

        RETURN vCodigoRetorno, vMensajeRetorno, vFechaFinal, NVL(vTotalTransaccionesMov,0);

    END

END PROCEDURE
DOCUMENT
'Armando García Ortiz',
'Gerencia I. Coord. Admón Tarjetas',
'BD...intercard',
'Descripcion: Consulta de OTPs cobradas y validacion de transacciones promedio.',
'Si las transacciones son mayores a los promedios configurables el codigo de retorno es 00001 para enviar un SMS'
;

CREATE PROCEDURE "informix".sp_stock_tjts_sucursales()
---ASIGNACION DE NOMBRE A LAS VARIABLRES DE RETORNO.
RETURNING VARCHAR(5) AS CODIGO_RETORNO, VARCHAR (50) AS MENSAJE_RETORNO;
	
	--Definicion de variables
    DEFINE  codigo_retorno      CHAR(5);				
	DEFINE  mensaje_retorno     CHAR(50);
	DEFINE	rpt_fecha			CHAR(8);
    DEFINE  sfecha_hoy			DATE; 
    DEFINE	TIPO_PLANTILLA 		VARCHAR(20);   
	DEFINE	RUTA_DESTINO 		VARCHAR(80);
	DEFINE	vsql				CHAR(1150);
	DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80);  
	
	DEFINE vclave_sucursal  VARCHAR(5);
	DEFINE vclave_tipotarjeta INTEGER;
	DEFINE vproducto          VARCHAR(7);
	DEFINE vexistentes        INTEGER;
	DEFINE vsolicitadas       INTEGER;
	DEFINE vdescripcion       VARCHAR(28);
	--new
	DEFINE vConteo             INTEGER;
	DEFINE vcommit  varchar(50);
	DEFINE vempresa CHAR(3);
	DEFINE vclave_sucursal1    VARCHAR(5);
	DEFINE vclave_tipotarjeta1 INTEGER;
	DEFINE vtipo         CHAR(1); 
	DEFINE vproducto1    VARCHAR(7);
	DEFINE vestatus      CHAR(10);
	DEFINE vdescripcion1 CHAR(40);
	DEFINE vcodstatustarjeta CHAR(3);
	DEFINE vtotal INTEGER;
	DEFINE vsFlagEnTransaccion VARCHAR(1);
 
    LET RUTA_DESTINO	 = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA	 = 'Inventario_suc';
	--Asignacion de valores a las variables de retorno
    LET rpt_fecha='';
    LET codigo_retorno = '00000';
    LET mensaje_retorno = 'PROCESO EXITOSO';
    LET	vclave_sucursal = '';
	LET vclave_tipotarjeta = 0;
	LET vproducto          = '';
	LET vexistentes  = 0;
	LET vsolicitadas = 0;
	LET vdescripcion = '';
	--new
    LET vConteo  = 0;
	LET vcommit = '';
	LET vempresa  = '';
	LET vclave_sucursal1    = '';
	LET vclave_tipotarjeta1 = 0;
	LET vtipo         = '';
	LET vproducto1    = '';
	LET vestatus     = '';
	LET vdescripcion1 = '';
	LET vcodstatustarjeta = '';
    LET vtotal = 0; 
	LET vsFlagEnTransaccion = 'F';

     --SET DEBUG FILE TO RUTA_DESTINO || "sp_stock_tjts_sucursales.out";
     --TRACE ON;        
	
    BEGIN 
		
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO

            SET DEBUG FILE TO RUTA_DESTINO || "excepcion_sp_stock_tjts_sucursales.out"  WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RETORNO = ERROR_INFO;                
                RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION;
 

	    SET ISOLATION TO DIRTY READ; 
	    SET LOCK MODE TO WAIT 3;
	
	    SELECT valores INTO vcommit FROM "informix".tbl_inter_parametros where cond_busqueda = 'Commits_N1';
	
	
		SELECT fecha_hoy  INTO  sfecha_hoy FROM bdinteg:si_fechas WHERE empresa='001';    
        LET rpt_fecha = LPAD(DAY(sfecha_hoy),2,'0')||LPAD(MONTH(sfecha_hoy),2, '0')||YEAR(sfecha_hoy);
		
		--LET rpt_fecha = substr (sfecha_hoy, 4,2)||substr (sfecha_hoy, 0,2)||substr (sfecha_hoy, 7,4);  
		 
		-- NEW
		   TRUNCATE TABLE "informix".tbl_paso_inventario_suc  DROP STORAGE;   
		   TRUNCATE TABLE "informix".sucursales_base_tmp      DROP STORAGE;   
		   TRUNCATE TABLE "informix".inventario_suc_tmp2      DROP STORAGE;   
		   TRUNCATE TABLE "informix".inventario_suc_tmp_noa   DROP STORAGE;   
		   TRUNCATE TABLE "informix".inventario_suc_tmp_noe   DROP STORAGE;   
		   TRUNCATE TABLE "informix".inventario_suc_final     DROP STORAGE;  
	 
	 foreach cur_F1_main WITH hold for
          ---1) query principal
		 select 
        --'001' as empresa, 
        lot.clave_sucursal as clave_sucursal,
        lot.clave_tipotarjeta,
        tt.tipo as tipo,
        case when tt.tipo = 'C' then 'CREDITO' 
        when tt.tipo ='D' then  'DEBITO' end as producto,
        tjt.codstatusasignada as estatus,
        tt.descripcion,
        tjt.codstatustarjeta as codstatustarjeta
		INTO 
		--vempresa,
		vclave_sucursal1,
		vclave_tipotarjeta1,
		vtipo,
		vproducto1,
		vestatus,
		vdescripcion1,
		vcodstatustarjeta
        from tarjeta tjt 
        inner join lote lot on tjt.numerolote = lot.numerolote 
        inner join tipotarjeta tt on lot.clave_tipotarjeta = tt.clave_tipotarjeta
        where 
		 tt.chip in ('F','V') 
        AND tjt.codstatusasignada in ('NOE','NOA')  
        AND tjt.codstatustarjeta = 'INA'
        AND lot.tipoenvio = 'S'
		ORDER BY clave_sucursal
         
		 
            IF (vsFlagEnTransaccion = 'F') THEN
                 BEGIN WORK;
			   --TRACE 'T0_'|| vConteo;
                 LET vsFlagEnTransaccion = 'V';
             END IF;
			 
			    INSERT INTO "informix".tbl_paso_inventario_suc  
				 values ('001',vclave_sucursal1,vclave_tipotarjeta1,vtipo,vproducto1,vestatus,vdescripcion1,vcodstatustarjeta);

				  LET vConteo = vConteo +1;  
													 
					  IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                   END IF;
			
    end foreach;
        --TRACE 'T2_'|| vConteo;
		
				   IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".tbl_paso_inventario_suc;    
		-----------------------
		
        --2   generacion de sucursales base con las que trabajar
         LET vclave_sucursal = '';
		 LET vproducto = '';
		 LET vclave_tipotarjeta = '';
		 LET vtipo = '';
		 LET vdescripcion = '';
		 LET vConteo = 0; 
		 LET vsFlagEnTransaccion = 'F';
		
		foreach cur_F2_suc WITH hold for
		
		    Select 
			distinct clave_sucursal,
		    producto,
		    clave_tipotarjeta,
			tipo,
			descripcion
            INTO vclave_sucursal,vproducto,vclave_tipotarjeta,vtipo,vdescripcion
			from tbl_paso_inventario_suc
		    where empresa = '001' 
            AND tipo IN ('C', 'D')
			order by clave_sucursal
   
		     IF (vsFlagEnTransaccion = 'F') THEN
                 BEGIN WORK;
			   --TRACE 'T0_'|| vConteo;
                 LET vsFlagEnTransaccion = 'V';
             END IF;
		   
		   	INSERT INTO "informix".sucursales_base_tmp  (clave_sucursal,producto,clave_tipotarjeta,tipo,descripcion)
		    VALUES  (vclave_sucursal,vproducto,vclave_tipotarjeta,vtipo,vdescripcion);
			
				  LET vConteo = vConteo +1;  
													 
				    IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                    END IF;
			
        end foreach; 

				   IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".sucursales_base_tmp;   		
		--------------------------
 
         LET vclave_sucursal = '';
		 LET vproducto = '';
		 LET vestatus = '';
		 LET vclave_tipotarjeta = '';
		 LET vdescripcion = '';
		 LET vtotal = 0; 
 		 LET vConteo = 0; 
		 LET vsFlagEnTransaccion = 'F';
        --3   Agrupacion por sucursal y stock 
		 foreach cur_F3_stock WITH hold for
		 
             select clave_sucursal,producto,estatus, clave_tipotarjeta,descripcion,count(*) as total 
             INTO vclave_sucursal,vproducto,vestatus,vclave_tipotarjeta,vdescripcion,vtotal 
		     from tbl_paso_inventario_suc
              group by 1,2,3,4,5
              order by clave_sucursal
			  
			 IF (vsFlagEnTransaccion = 'F') THEN
                 BEGIN WORK;
			   --TRACE 'T0_'|| vConteo;
                 LET vsFlagEnTransaccion = 'V';
             END IF;
           
		    INSERT INTO "informix".inventario_suc_tmp2  (clave_sucursal,producto,estatus,clave_tipotarjeta,descripcion,total)
		    VALUES  (vclave_sucursal,vproducto,vestatus,vclave_tipotarjeta,vdescripcion,vtotal);
			
			  LET vConteo = vConteo +1;  
													 
			    IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                END IF;
 
         end foreach;  
		 
		 		    IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".inventario_suc_tmp2;   
		-------------------------
	     LET vclave_sucursal = '';
		 LET vproducto = '';
		 LET vclave_tipotarjeta = '';
		 LET vtotal = 0; 
		 LET vConteo = 0; 
		 LET vsFlagEnTransaccion = 'F';
        --4   agrupacion de existentes por sucursal
		foreach cur_F4_noa WITH hold for
                 Select clave_sucursal,producto,clave_tipotarjeta, total as total_noa 
				 INTO  vclave_sucursal,vproducto,vclave_tipotarjeta,vtotal
				 from inventario_suc_tmp2  
                 where estatus = 'NOA'
				 order by clave_sucursal 
			   
			    IF (vsFlagEnTransaccion = 'F') THEN
                    BEGIN WORK;
			        --TRACE 'T0_'|| vConteo;
                     LET vsFlagEnTransaccion = 'V';
                END IF;
 
 		        INSERT INTO "informix".inventario_suc_tmp_noa  ( clave_sucursal,producto,clave_tipotarjeta, total_noa )
		        VALUES  (vclave_sucursal,vproducto,vclave_tipotarjeta,vtotal);
   
   				  LET vConteo = vConteo +1;  
													 
					  IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                   END IF;
  
		 end foreach;  
		 
		 		    IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
           UPDATE STATISTICS MEDIUM FOR TABLE "informix".inventario_suc_tmp_noa;  
			--------------------------
		 LET vclave_sucursal = '';
		 LET vproducto = '';
		 LET vclave_tipotarjeta = '';
		 LET vtotal = 0; 
		 LET vConteo = 0; 
		 LET vsFlagEnTransaccion = 'F';
        --5  agrupacion de solicitadas por sucursal
		    foreach cur_F5_noa WITH hold for 
                      Select clave_sucursal,producto,clave_tipotarjeta, total as total_noe  
		              INTO vclave_sucursal,vproducto,vclave_tipotarjeta,vtotal
					  from inventario_suc_tmp2  
                      where estatus = 'NOE'
					  order by clave_sucursal
                   
				   	   IF (vsFlagEnTransaccion = 'F') THEN
                           BEGIN WORK;
			               --TRACE 'T0_'|| vConteo;
                           LET vsFlagEnTransaccion = 'V';
                        END IF;
 
					  INSERT INTO "informix".inventario_suc_tmp_noe  ( clave_sucursal,producto,clave_tipotarjeta, total_noe )
		              VALUES  (vclave_sucursal,vproducto,vclave_tipotarjeta,vtotal);  
					  
					    LET vConteo = vConteo +1;  
													 
					    IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                        END IF;
					  
		    end foreach; 
 
 		 		    IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
           UPDATE STATISTICS MEDIUM FOR TABLE "informix".inventario_suc_tmp_noe;  
           -------
			LET vclave_sucursal= '';
			LET vclave_tipotarjeta = '';
			LET vproducto = '';
			LET vexistentes = 0;
			LET vsolicitadas = 0;
			LET vdescripcion = '';
		    LET vConteo = 0; 
		    LET vsFlagEnTransaccion = 'F';
			
       --6  concentrado final 
           foreach cur_F6_fin WITH hold for

            Select suc.clave_sucursal, 
            suc.clave_tipotarjeta, 
            suc.producto,
            NVL(total_noa,'0') as existentes, 
            NVL(total_noe,'0') as solicitadas, 
            TRIM(suc.descripcion) 
			INTO  vclave_sucursal,vclave_tipotarjeta,vproducto,vexistentes,vsolicitadas,vdescripcion
            from sucursales_base_tmp as suc
            LEFT JOIN  inventario_suc_tmp_noa as noa ON suc.clave_sucursal = noa.clave_sucursal and suc.clave_tipotarjeta = noa.clave_tipotarjeta
            LEFT JOIN  inventario_suc_tmp_noe as noe ON suc.clave_sucursal = noe.clave_sucursal and suc.clave_tipotarjeta = noe.clave_tipotarjeta
           	order by clave_sucursal  		

  			IF (vsFlagEnTransaccion = 'F') THEN
                  BEGIN WORK;
			      --TRACE 'T0_'|| vConteo;
                  LET vsFlagEnTransaccion = 'V';
            END IF;
					
		    INSERT INTO "informix".inventario_suc_final  (clave_sucursal,clave_tipotarjeta,producto,existentes,solicitadas,descripcion)
		    VALUES  (vclave_sucursal,vclave_tipotarjeta,vproducto,vexistentes,vsolicitadas,vdescripcion);
		   
		     LET vConteo = vConteo +1;  
													 
				IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                END IF;
		   
		    end foreach;  
  
   		 		    IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
           UPDATE STATISTICS MEDIUM FOR TABLE "informix".inventario_suc_final;  
  
            -----------------------------------------------------------------------------------------------------------------
			--Elimina reportes anteriores
	        let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||TIPO_PLANTILLA||'*';
            system vsql;
           ----------------------------------------------------------------------------------------------------------------- 
		    let vsql = ''; 	   
		    let vsql = 'echo "clave_sucursal|clave_tipotarjeta|producto|existentes|solicitadas|descripcion|">'||RUTA_DESTINO||TIPO_PLANTILLA||'_'||rpt_fecha||'.txt';  
		    system vsql;
           -----------------------------------------------------------------------------------------------------------------
            let vsql = '';
            let vsql = ' echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_DESTINO ||'inventario_base_'||rpt_fecha||'.txt '||
                      ' SELECT  * FROM   intercard:inventario_suc_final order by 1,2 asc;">'||RUTA_DESTINO||'script_inventario.sql';  
            system vsql;	
            -----------------------------------------------------------------------------------------------------------------	
			---Asigancion de permisos del archivo .sql
			let vsql ='';			
			let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_inventario.sql';
			system vsql;
		    
		    let vsql = '';
            let vsql = 'dbaccess intercard '||RUTA_DESTINO||'script_inventario.sql';
            system vsql;	
			-----------------------------------------------------------------------------------------------------------------
		    --Resultado del unload se complementa con el encabezado del reporte
			let vsql ='';
            let vsql = "sed 's/|s//g' "||RUTA_DESTINO||'inventario_base_'||rpt_fecha||".txt >> "||RUTA_DESTINO||TIPO_PLANTILLA||'_'||rpt_fecha||".txt";
            system vsql;
 
			-----------------------------------------------------------------------------------------------------------------
			--eliminaciÃ³n de archivos
			let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'script_inventario.sql';
            system vsql;
		 
		    let vsql = '';
			let vsql ='rm -f '||RUTA_DESTINO||'inventario_base_'||rpt_fecha||'.txt';  
			system vsql;
		 		   
          ------------------------------------------------------------------------------------------------------------------------
      
    RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;


END;
END PROCEDURE
---CoordinaciÃ³n de Tarjetas e Interfaces Transaccionales | Gerencia Mantenimiento I
---Autor: Marcos Gerardo Ayala Ponce
---Fecha de creacion: 21 de septiembre del 2021
---Base de datos: intercard
---Este proceso corresponde al job 828
----EXECUTE PROCEDURE "informix".sp_stock_tjts_sucursales();
;

CREATE PROCEDURE "informix".sp_tarj_det_vcas_exp()
    RETURNING VARCHAR(10), VARCHAR(255)

    DEFINE vfecha DATETIME YEAR TO FRACTION(5);
    DEFINE vfechaTime DATETIME YEAR TO FRACTION(5);


    DEFINE vstatus_proc 	CHAR(1);
    DEFINE vcod_ret         VARCHAR(10);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE error_info       CHAR(40);

    DEFINE v_dia         	CHAR(2);
    DEFINE v_mes         	CHAR(2);
    DEFINE v_ano         	CHAR(4);
    DEFINE v_hora 			DATETIME HOUR TO SECOND;
    DEFINE v_hora2 			CHAR(8);
    DEFINE v_sql         	CHAR(250);
    DEFINE cEncabezado   	CHAR(250);

    DEFINE cRuta 			CHAR(250);
    DEFINE cRuta2 			CHAR(250);
    DEFINE cNombreArchivo 	CHAR(250);
    DEFINE cNombreArchivo1 	CHAR(250);
    DEFINE cNombreArchivo2 	CHAR(250);

    DEFINE var_action 		CHAR(6);
    DEFINE var_numtarjeta   VARCHAR(16);
    DEFINE var_telefono     CHAR(13);
    DEFINE var_correo_elec 	CHAR(100);
    DEFINE var_fecha        DATETIME YEAR to SECOND;

    DEFINE iContador_pay    SMALLINT;
    DEFINE vreg_ins INTEGER;

    --MANEJO DEL ERROR.
    ON EXCEPTION SET sql_err, isam_err, error_info
            
        SET DEBUG FILE TO "/RESPALDOSNEW/exc_sp_tarj_det_vcas.err.out" WITH APPEND;
        TRACE ON;
        
        UPDATE intercard:ctrl_info_ctes_vcas
        SET status_proc = '0';

        IF sql_err <> 0 THEN
            LET vcod_ret=sql_err;
            UPDATE intercard:ctrl_info_ctes_vcas
            SET(cod_err, descripcion_err) = (vcod_ret, isam_err||' ' ||error_info);
            RETURN vcod_ret, isam_err||' ' ||error_info;
        END IF;
    END EXCEPTION;

        SET DEBUG FILE TO "/RESPALDOSNEW/sp_tarj_det_vcas.out";
        TRACE ON;

    LET vfecha = TODAY;
    LET vfechaTime = TODAY;
    LET vstatus_proc = '';

    LET vcod_ret = '000';          
    LET sql_err = 0;          
    LET isam_err = 0;        
    LET error_info = '';
    LET iContador_pay = 0;

    LET v_dia           = "";
    LET v_mes           = "";
    LET v_ano           = "";  
    LET v_hora 			= CURRENT;
    LET v_hora2 		= "";
    LET v_sql           = "";

    LET cEncabezado     = "";
    LET cRuta 			= "/tmp/";
    LET cRuta2 			= "/RESPALDOSNEW/VCAS_resultados/";
    LET cNombreArchivo 	= "";
    LET cNombreArchivo1 = "";
    LET cNombreArchivo2 = "";

    LET var_action 		= "";
    LET var_numtarjeta  = "";
    LET var_telefono    = "";
    LET var_correo_elec = "";
    LET var_fecha       = CURRENT;
    LET vreg_ins 		= 0;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
     
    SELECT status_proc
        INTO vstatus_proc
    FROM intercard:ctrl_info_ctes_vcas;

    IF(vstatus_proc = '1') THEN
            UPDATE intercard:ctrl_info_ctes_vcas
            SET(cod_err, descripcion_err) = (vcod_ret, 'DESCARGA EN PROCESO');
        
        RETURN vcod_ret, 'DESCARGA EN PROCESO';
    END IF;
   
    UPDATE intercard:ctrl_info_ctes_vcas SET status_proc = '1';  
 
    SELECT fecha, fecha  - 1 units hour
        INTO vfecha, vfechaTime
    FROM intercard:ctrl_info_ctes_vcas;

-- ELIMINA REGISTROS DE TABLA DE RESULTADOS EN CASO DE QUE HAYA FALLADO EL SP Y HAYA GENERADO INFORMACION.
   
   TRUNCATE TABLE intercard:ctas_vcas;

  -- CREAR TEMPORALES PARA RESULTADO FINAL
    SELECT numtarjeta, fechaasignacion
    FROM intercard:info_tarjeta_pyt
    WHERE codstatustarjeta = 'ACT'
    AND fechaasignacion >= vfecha
    INTO temp tmptarj with no log;

    CREATE INDEX "informix".tmp_tartarj_vcas ON tmptarj(numtarjeta) ONLINE;
    
    /*
	SELECT bin
	FROM intercard:bines WHERE (marca  = 'VS' or bin in (510148, 554948 ,559471)) --
	INTO temp BIN_VISA with no log;
    */
    SELECT bin 
        FROM intercard:bines 
            WHERE bin IN ('400819', '426807', '559471', '554948', '510148', '416916')
    INTO TEMP BIN_VISA WITH NO LOG;

    CREATE INDEX "informix".tmp_bin_visa ON BIN_VISA(bin) ONLINE;
    
    --TARJETAS DE CREDITO
    SELECT numcte,num_tarjeta
    FROM bdicred:sd_tarjeta
    WHERE empresa= '001' AND num_tarjeta IN (SELECT numtarjeta FROM tmptarj GROUP BY numtarjeta)
    INTO temp tmpctestarj with no log;

    CREATE INDEX "informix".tmp_cte_pt ON tmpctestarj(numcte,num_tarjeta) ONLINE;

    -- CREATE INDEX "informix".tmp_tarj_pt ON tmpctestarj(num_tarjeta) ONLINE;

    --TARJETAS DE DEBITO
    INSERT INTO tmpctestarj
    SELECT numcte, num_tarjeta
    FROM bdicheq:sc_tarjeta
    WHERE empresa= '001' AND num_tarjeta IN (SELECT numtarjeta FROM tmptarj GROUP BY numtarjeta);

    -- TABLA TELEONOS TIPO 2
	SELECT telefono, numcte, status_tel, fecha_hora
    FROM bdinteg:si_telefonos_actual
    --WHERE (tipo_tel = 2 and  fecha_hora >=vfecha) or (numcte IN (SELECT numcte FROM tmpctestarj WHERE 1=1))
	WHERE ((fecha_hora >=vfechaTime) or (numcte IN (SELECT numcte FROM tmpctestarj WHERE 1=1))) and tipo_tel = 2
    INTO temp tmptelefono_tipo2 with no log;

    CREATE INDEX "informix".tmptelefono_tipo2_idx1  ON tmptelefono_tipo2(status_tel,fecha_hora) ONLINE;
    --CREATE INDEX "informix".tmptelefono_tipo2_idx2  ON tmptelefono_tipo2(numcte) ONLINE;


    --TEMPORAL DE TELEONOS
	SELECT telefono, numcte
    FROM tmptelefono_tipo2 WHERE status_tel = 'A' and fecha_hora >= vfechaTime
    GROUP BY telefono, numcte
    UNION
    SELECT telefono, numcte
    FROM tmptelefono_tipo2 WHERE numcte IN (SELECT numcte FROM tmpctestarj WHERE 1=1) AND status_tel = 'A'
    GROUP BY telefono, numcte
    INTO temp tmptelefono with no log;

    CREATE INDEX "informix".tmptelefono_idx1 ON tmptelefono(numcte,telefono) ONLINE;
    --CREATE INDEX "informix".tmptelefono_idx2 ON tmptelefono(numcte) ONLINE;


    -- TABLA CORREOS  TIPO 1
	SELECT tipo_correo, status_correo, secuencia, valido, numcte, correo_elec, fecha_hora
    FROM bdinteg:si_correos C
    WHERE C.tipo_correo = 1 AND C.status_correo = 'A' AND C.valido = 1 AND C.fecha_hora >= vfechaTime
	INTO temp tmpsi_correos with no log;

	--CREATE INDEX "informix".tmpsi_correos_idx1 ON tmpsi_correos(tipo_correo,status_correo,fecha_hora, valido);
	CREATE INDEX "informix".tmpsi_correos_idx2 ON tmpsi_correos(numcte,tipo_correo,status_correo,valido);

	--TEMPORAL DE CORREOS

	SELECT correo_elec, numcte
    FROM bdinteg:tmpsi_correos C
    WHERE numcte IN  (SELECT numcte FROM tmpctestarj WHERE 1=1)
	AND C.tipo_correo = 1 AND C.status_correo = 'A' AND C.valido = 1
    GROUP BY correo_elec, numcte
	UNION
	SELECT correo_elec, numcte
    FROM bdinteg:tmpsi_correos C
    WHERE C.tipo_correo = 1 AND C.status_correo = 'A' AND fecha_hora >= vfechaTime AND C.valido = 1
	GROUP BY correo_elec, numcte
	INTO temp tmpcorreo with no log;

    CREATE INDEX "informix".tmp_correlec_vcas ON tmpcorreo(numcte,correo_elec) ONLINE;
    --CREATE INDEX "informix".tmp_numctecorr_vcas ON tmpcorreo(numcte) ONLINE;

   --TARJETAS DE CREDITO CTES
    SELECT numcte,num_tarjeta
    FROM bdicred:sd_tarjeta
    WHERE empresa= '001' AND numcte IN (SELECT numcte FROM tmpcorreo UNION ALL SELECT numcte FROM tmptelefono)
    INTO temp tmpctestarjfin with no log;

    CREATE INDEX "informix".tmp_cte_pts ON tmpctestarjfin(numcte,num_tarjeta) ONLINE;
	--CREATE INDEX "informix".tmp_tarj_pts ON tmpctestarjfin(num_tarjeta) ONLINE;

    --TARJETAS DE DEBITO CTES
    INSERT INTO tmpctestarjfin
    SELECT numcte, num_tarjeta
    FROM bdicheq:sc_tarjeta
    WHERE empresa= '001' AND numcte IN (SELECT numcte FROM tmpcorreo UNION ALL SELECT numcte FROM tmptelefono);

	--CTES CON TARJETAS ACTUALIZADAS
    SELECT numtarjeta, A.fechaasignacion, B.numcte
    FROM intercard:info_tarjeta_pyt A, tmpctestarjfin B
    WHERE A.numtarjeta=B.num_tarjeta AND codstatustarjeta = 'ACT'
    GROUP BY A.numtarjeta, A.fechaasignacion, B.numcte
    INTO temp tmptarjeta with no log;

    CREATE INDEX "informix".tmp_numtarj_vcas ON tmptarjeta(numcte,numtarjeta) ONLINE;
    --CREATE INDEX "informix".tmp_numclient_vcas ON tmptarjeta(numcte) ONLINE;
    CREATE INDEX "informix".tmp_fechasig_vcas ON tmptarjeta(fechaasignacion) ONLINE;
   
-- INFORMACION QUE SE EJECUTARA CADA DETERMINADO TIEMPO.
    BEGIN WORK;
        FOREACH WITH HOLD
            SELECT 
                CASE 
                    WHEN A.fechaasignacion >= vfecha THEN 'ADD' ELSE 'UPDATE' END 
                AS action,
                A.numtarjeta,B.telefono AS telefono,
                C.correo_elec AS correo_elec,
                CURRENT AS fecha
                INTO var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha
            FROM tmptarjeta A
                LEFT JOIN tmptelefono B ON A.numcte=B.numcte
                LEFT JOIN tmpcorreo C ON A.numcte=C.numcte
            WHERE SUBSTR(A.numtarjeta,1,6) IN (SELECT bin FROM BIN_VISA )
            AND((B.telefono IS NOT NULL)OR(C.correo_elec IS NOT NULL))            
            GROUP BY A.numtarjeta, B.telefono, C.correo_elec,fecha,action

            LET iContador_pay = iContador_pay + 1;

            INSERT INTO "informix".ctas_vcas(action, numtarjeta, telefono, correo_elec, fecha)
            VALUES(var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha);
               
            IF iContador_pay = 1000 THEN
                COMMIT;
                LET iContador_pay = 0;
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".ctas_vcas;
                BEGIN WORK;
            END IF;
        END FOREACH;
    COMMIT;

        UPDATE STATISTICS MEDIUM FOR TABLE "informix".ctas_vcas;
    
	-- DESCARGAR ARCHIVO.
	LET v_dia = LPAD(DAY(CURRENT),2,'0');  
	LET v_mes = LPAD(MONTH(CURRENT),2,'0');
	LET v_ano = year(CURRENT);
    LET v_hora2 = v_hora::CHAR(8);
	LET cNombreArchivo = TRIM(cRuta2)||'ISSUERNAME'||v_ano||v_mes||v_dia||SUBSTR(v_hora2,1,2)||SUBSTR(v_hora2,4,2)||SUBSTR(v_hora2,7,2)||'.csv';
	LET cNombreArchivo1 = TRIM(cRuta)||'ISSUERNAME'||v_ano||v_mes||v_dia||'_aux.csv';
    LET cNombreArchivo2 = TRIM(cRuta)||'ISSUERNAME'||v_ano||v_mes||v_dia||'_aux2.csv';
         
	-- DESCARGA DEL ARCHIVO .CSV.
	LET cEncabezado = 'echo "action,pan,mobilenumber,email,segmentationindicator," > /tmp/queryenc.sql';
    System cEncabezado;

	LET v_sql = 'echo "UNLOAD TO ' || TRIM (cNombreArchivo1) || ' DELIMITER '',''" > /tmp/queryhist.sql ';
	System v_sql;

	LET v_sql = 'echo "SELECT action,numtarjeta AS pan, ''+52''||RIGHT(LTRIM(RTRIM(telefono)),10) AS mobilenumber," >> /tmp/queryhist.sql ';
	System v_sql;

    LET v_sql = 'echo "LTRIM(RTRIM(correo_elec)) AS email, ''01'' AS segmentationindicator" >> /tmp/queryhist.sql ';
	System v_sql;

	LET v_sql = 'echo " from intercard:ctas_vcas  where numtarjeta <> ''''" >> /tmp/queryhist.sql';
	System v_sql;

	LET v_sql = "dbaccess intercard /tmp/queryhist.sql";
	System v_sql;

	LET v_sql="";

	--SE AÃ?Â?ADEN LOS ENCABEZADOS Y LOS RESULTADOS EXTRAIDOS AL ARCHIVO AUXILIAR.
	LET v_sql = "sed 's/$//g' "|| TRIM(cRuta) || "queryenc.sql >> " || TRIM (cNombreArchivo2);
    SYSTEM TRIM(v_sql);

    LET v_sql="";

	LET v_sql = "sed 's/$//g' "|| TRIM (cNombreArchivo1) || " >> " || TRIM (cNombreArchivo2);
    SYSTEM TRIM(v_sql);

    --SE PASA LA INFORMACION DESCARGADA AL ARCHIVO FINAL.
    LET v_sql = "";
    LET v_sql = "sed -e 's/.$//' "|| TRIM(cNombreArchivo2) || " >> " || TRIM (cNombreArchivo);
    SYSTEM v_sql;

	--BORRADO DE SCRIPTS GENERADOS EN EL PROCESO.
    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cRuta) || "queryhist.sql";
    SYSTEM TRIM(v_sql);

    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cRuta) || "queryenc.sql";
    SYSTEM TRIM(v_sql);

    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cNombreArchivo1);
    SYSTEM TRIM(v_sql);

    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cNombreArchivo2);
    SYSTEM TRIM(v_sql);

	-- DATOS PARA LA TABLA CONTROL.
	SELECT MAX(fecha::DATETIME YEAR TO SECOND + INTERVAL (01) SECOND(2) TO SECOND )
	INTO vfecha
	FROM intercard:ctas_vcas;

	IF  vfecha  IS NULL THEN
		LET vfecha = CURRENT;
	END IF

	-- CONTEO DE REGISTROS.
	SELECT COUNT(*)
	INTO vreg_ins
	FROM intercard:ctas_vcas;

	-- ELIMINA REGISTROS DE TABLA DE RESULTADOS Y TEMPORALES.
    --TRUNCATE TABLE intercard:ctas_vcas;
    TRUNCATE TABLE intercard:ctas_vcas DROP STORAGE;

	DROP TABLE BIN_VISA;
	DROP TABLE tmpctestarj;
    DROP TABLE tmptelefono;
    DROP TABLE tmpcorreo;
	DROP TABLE tmptarjeta;
    DROP TABLE tmptarj;
    DROP TABLE tmpctestarjfin;

	-- ACTUALIZAR TABLA CONTROL.
	UPDATE intercard:ctrl_info_ctes_vcas
	SET ( fecha, status_proc,cod_err, descripcion_err, reg_insertados) = ( vfecha, '0', vcod_ret, 'DESCARGA EXITOSA', vreg_ins);

 
    RETURN vcod_ret, 'DESCARGA EXITOSA';
END PROCEDURE;