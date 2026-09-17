CREATE PROCEDURE "informix".sp_consultadatos_motor_web(pEmpresa CHAR(4), pNumSol CHAR(20))
RETURNING
	CHAR(6) 	   as cCodRet,
	CHAR(20)	   as cSolBanco,
	CHAR(20)	   as cNumCteBco,
	CHAR(20) 	   as cNumCte,
	CHAR(4)		   as pEmpresa,
	CHAR(2)		   as cStatusSolicitud,
	CHAR(3)		   as cCausa_Sol,
	CHAR(4)		   as cNum_Producto,
	CHAR(2)		   as cTipoGrupo,
	CHAR(1)		   as cTp_solicitud,
	INTEGER	   as cB_INE,
	CHAR(50)	   as cHabita_en,
	CHAR(1)		   as cPuntualidadCoppel,
	CHAR(3)		   as cProfesion,
	INTEGER 	   as iCredDigitalesAct,
	SMALLINT	   as sId_actividad,
	CHAR(60)	   as cDescAct,
	SMALLINT	   as sId_subactividad,
	CHAR(50)	   as vDescSubAct,
	CHAR(1)		   as cSituacionEspecial,
	SMALLINT 	   as sCausaSituacion,
	CHAR(1)		   as cMotivoRech,
	CHAR(1)		   as cMotivoRechBcpl,
	CHAR(1) 	   as cTipoRech,
	CHAR(300) 	   as cDescMvo,
	MONEY 		   as mTotalVencido,
	MONEY  		   as mAbonoTotal,
	MONEY		   as mAbonoVencidoTotal,
	SMALLINT 	   as sHist_meses,
	CHAR(20) 	   as cCteExcep,
	INTEGER 	   as iCtas_StatusCV,
	INTEGER 	   as iMaxSalVencidoBancoppel,
	DECIMAL(5,2)   as dEficienciaCoppel,
	INTEGER		   as iCred_StatusFC,
	INTEGER		   as iCred_StatusFF_restru,
	INTEGER		   as iCredits_riesgoD,
	INTEGER		   as iCredits_riesgoE,
	INTEGER		   as iCredits_riesgoC,
	INTEGER		   as iMaxMontoReserva,
	INTEGER		   as iCred_StatusDif_FF,
	DECIMAL(18,2)  as dMaxSalVencidoCRD,
	INTEGER		   as iCuentasStatusCVsinFF,
	INTEGER		   as iCtas_StatusDif_FF_6011,
	INTEGER		   as iCredRiesgoD_sinFF,
	INTEGER		   as iCredRiesgoE_sinFF,
	INTEGER		   as iCredRiesgoC_sinFF,
	DECIMAL(18,2)  as dmaxMontoReservaRiesgoC_sinFF,
	CHAR(10) 	   as dtMinFechaAperturasinFF,
	CHAR(10) 	   as dtMinFechaApertura,
	CHAR(1)		   as cSituacion,
	CHAR(10) 	   as dtmaxFechaAperturaDelProducto,
	CHAR(4)		   as cProducto,
	DECIMAL(6,2)   as dminProcentajeProductoMasReciente,
	MONEY		   as mAbonoMuebles,
	MONEY		   as mAbonoPrestamos,
	MONEY		   as mAbonoRopa,
	MONEY		   as mAbonoAire,
	MONEY		   as mAbonoAfiliados,
	MONEY		   as mAbonoReestructura,
	MONEY		   as mVencidoMuebles,
	MONEY		   as mVencidoRopa,
	MONEY		   as mVencidoPrestamos,
	MONEY		   as mVencidoAire,
	MONEY		   as mVencidoAfiliados,
	MONEY		   as mVencidoReestructura,
	CHAR(13)	   as cFechaUltimoPago,
	INTEGER 	   as iReprestamos,
	CHAR(1)		   as cOrigenSol,
	CHAR(60)	   as cDescripcion,
	CHAR(1)		   as cRiesgoViviendaCpl,
	CHAR(1)		   as cRiesgoViviendaBcpl,
	CHAR(1)		   as cActRiesgoCpl,
	CHAR(1)		   as cActRiesgoBCpl,
	CHAR(1)	   	   as cDescpRiesgo,
	CHAR(1)		   as cEjecucion,
	VARCHAR(20) 	   as iMax_MOP,
	VARCHAR(30)		   as cInstCta_MayorMOP,
	DECIMAL(14,2)  as dMonto_UDIS_MayorMOP,
	VARCHAR(20)		   as iMax_MOP_Hist_6m,
	CHAR(2)		   as cInstCta_MayorMOP_6m,
	DECIMAL(14,2)  as dMontoUDIS_MM_6m,
	VARCHAR(20)		   as iMM_Histo_12m,
	CHAR(2)		   as cInstCta_MayorMOP_12m,
	DECIMAL(14,2)  as dMontoUDIS_MM_12m,
	INTEGER		   as iNumCtasMOP_4_12m,
	INTEGER		   as iNumCtasMOP_5_12m,
	INTEGER		   as iNumCtasMOP_mayor5_12m,
	INTEGER		   as iMOP4_12mCon1o2,
	INTEGER		   as iMOP5_12mCon1o2,
	INTEGER		   as iMOPmayor5_12mCon1o2,
	CHAR(2)		   as cInstitucionMMOP_provocaRech,
	DECIMAL(14,2)  as dMontoUDIS_MM_Rech,
	INTEGER  	   as iNumCtasMOP_4_30m,
	INTEGER  	   as iNumCtasMOP_5_30m,
	INTEGER  	   as iNumCtasMOP_mayor5_30m,
	INTEGER  	   as iCtasMOP_4_30mCon1o2,
	INTEGER  	   as iCtasMOP_5_30mCon1o2,
	INTEGER  	   as iCtasMOP_mayor5_30mCon1o2,
	VARCHAR(20)  	   as iMM_Histo_30m,
	CHAR(2)  	   as cInstCta_MM_30m_Rech,
	DECIMAL(14,2)  as dMotoUDIS_MM_30m_Rech,
	VARCHAR(20)  	   as iNumCtas_ClvOb,
	DECIMAL(14,2)  as dMontoUdis,
	CHAR(2)  	   as cInstitucion,
	CHAR(2)  	   as cClvObser,
	SMALLINT  	   as sBc_Score,
	INTEGER    as vClvExclusionMasReciente,
	CHAR(2)		   as cInstitucionClvExclusionMasReciente,
	INTEGER  	   as iCtas_SinComServ,
	INTEGER 	   as iCtas_SinComServ_pagar,
	INTEGER  	   as iNumCtas_SHBr,
	INTEGER  	   as iNumCtas_SHBr_pagar,
	INTEGER 	   as BC1,
	INTEGER  	   as BC_101,
	VARCHAR(20)  	   as iMM_act_Bancos,
	VARCHAR(20)  	   as iMM_hist_alto_Bancos,
	VARCHAR(20)  	   as iMM_hist_Bancos,
	INTEGER  	   as BC_117,
	INTEGER  	   as iCtasBancosMOP_tl26,
	INTEGER  	   as iCtasBancosMOP_tl38,
	INTEGER 	   as iCtasBancosMOP_tl27,
	INTEGER  	   as iCtasBancosMOP_act_hist_alto,
	INTEGER 	   as BC_119,
	INTEGER 	   as iCtasComServMOP_tl26,
	INTEGER  	   as iCtasComServMOP_tl38,
	INTEGER 	   as iCtasComServMOP_tl27,
	INTEGER  	   as iCtasCSM_act_hist_alto,
	INTEGER 	   as BC_20,
	INTEGER 	   as iCtasComServMOP_tl26_12m,
	INTEGER 	   as iCtasComServMOP_tl38_12m,
	INTEGER 	   as iCtasComServMOP_tl27_12m,
	INTEGER		   as iCtasCSM_ActHistAlto_12m,
	DECIMAL(18,2)  as BC_421,
	CHAR(10)	   as dtFechaAux,
	VARCHAR(20)		   as BC_85,
	VARCHAR(20)		   as iMaxMOP_actBancos,
	VARCHAR(20)		   as iMaxMOP_histAltBancos,
	VARCHAR(20)		   as iMaxMOP_histBancos,
	VARCHAR(20)		   as BC_93,
	VARCHAR(20)		   as iMaxMOP_actCtas,
	VARCHAR(20)		   as iMaxMOP_histAltCtas,
	VARCHAR(20)		   as iMaxMOP_histCtas,
	CHAR(10)   as dSituacionPagoCoppel,
	MONEY		   as mIngreso_Mensual,
	MONEY		   as mPagoMinimo,
	SMALLINT	   as sCteLargo8,
	INTEGER		   as iMeses_hist_Val,
	CHAR(1)		   as cTipo_Alta_CteProsp,
	MONEY		   as mLinea_tienda,
	MONEY		   as mImporte_hip,
	DECIMAL(9,6)   as dTasa,
	CHAR(1)	   as sFlagHuella,
	CHAR(1)		   as cResultadoOsTel,
	CHAR(1)		   as cTieneOstel,
	CHAR(1)		   as cEnvioCat,
	INTEGER		   as iSolMc,
	INTEGER		   as iSolMcAux,
	CHAR(2)		   as cCod_Ult_Identif,
	CHAR(13)	   as cTelCasa,
	CHAR(13)	   as cTelTrabajo,
	VARCHAR(2)	   as sValida_Cel,
	CHAR(10) 	   as dtUltimaCompra,
	VARCHAR(20)		   as iBanderareferencia,
	CHAR(10)	   as dtFechaCte,
	CHAR(20)	   as cFolioMovil,
	CHAR(1)		   as cFlagGeoMov,
	VARCHAR(2)		   as iFlagGeoSuc,
	CHAR(2)		   as iCanal_Sol,
	CHAR(1)		   as cOrigenCte,
	VARCHAR(20)	   as sFlagForzarEnvioMC,
	VARCHAR(20)		   as iSecuenciaOs,
	CHAR(1)		   as cStatusRespOs,
	CHAR(10)	   as dtFecha_Respuesta,
	CHAR(20)	   as cNumSol_Os,
	CHAR(1)		   as cCompIngresos,
	DECIMAL(14,2)  as dIngresoCac,
	SMALLINT	   as sCompValido,
	CHAR(1)		   as cTipo_movimiento,
	CHAR(4)		   as cSucursal,
	CHAR(1)		   as cTipoSolOS,
	DECIMAL(14,2)  as dCompromisosCac,
	SMALLINT	   as sFlag_oro,
	MONEY		   as mIngreso_Neto,
	CHAR(10)	   as dtFechaNac,
	CHAR(1)		   as cSexo,
	CHAR(50)	   as cEdo_Civil,
	INTEGER	   	   as iTiem_Edo_Civil,
	INTEGER		   as HR0048,
	INTEGER		   as UT0034,
	CHAR(50)	   as cOcupacion,
	INTEGER	       as iTiem_Ocupacion,
	CHAR(50) 	   as cEscolaridad,
	CHAR(50)	   as cTipoResidencia,
	INTEGER	       as iTiem_Residencia,
	VARCHAR(10)    as vClvEdoCob,
	VARCHAR(200)   as vLocalidad,
	CHAR(50)	   as cEntidad,
	VARCHAR(20)	   as sCteLargo,
	SMALLINT	   as sScore_coppel,
	CHAR(20)	   as cCURP,
	CHAR(1)		   as iFlagEmpleado,
	DECIMAL(14,2)  as dValor_3s,
	CHAR(1)		   as cStatusMovil,
	CHAR(20) 	   as cCteProsp,
	CHAR(2)  	   as cStatusSol_CteProsp,
	CHAR(1) 	   as cRTipo3,
	CHAR(1)  	   as cVigSolOS,
	CHAR(30)	   as sBuenPagos,
	DECIMAL(14,2)  as dCompromisos,
	VARCHAR(10)	   as sFlagBuenPago12,
 	VARCHAR(10)	   as sFlagBuenPago30, 
	VARCHAR(10)	   as sEntidad_Localidad,
	CHAR(2)		   as cNuevoStatusOstel,
	CHAR(20)	   as cCteProspVig,
	MONEY		   as mCompro_banco,
	DECIMAL(14,2)  as dComprobanco_TDC,
	DECIMAL(14,2)  as mCompro_bancoPP,
	CHAR(20)	   as cGeoCte,
	VARCHAR(10)		   as iCanalV1,
	VARCHAR(20)		   as HR0050,
	VARCHAR(20)		   as TR0002,
	VARCHAR(20)		   as TR0001,
	VARCHAR(20)		   as IQ0002,
	INTEGER		   as iCtas_StatusFF_6011,
	VARCHAR(30)  as dSaldo_linea_credi,
	VARCHAR(30)  as dSaldo_limit_credi,
	INTEGER	       as iTiem_Edo_Civil_meses,
	DECIMAL(18,4)  as dMontoOtorgado,
	MONEY		   as mCapacidad_pago,
	CHAR(20)	   as cVigenciaBancoppel,
	DECIMAL(14 ,2) as dLineaBanco,
	INTEGER		   as iExisteCliente,
	MONEY 		   as mSaldoRopa,
	MONEY 		   as mSaldoMuebles,
	MONEY 		   as mSaldoPrestamos,
	INTEGER		   as mosSncOldestRevTLOpnd,
	VARCHAR(20)		   as numInq0to2Mos,
	VARCHAR(30)  as pctBankILTL,
	CHAR(10)	   as pctTL30pDaysEverColl,
	CHAR(10) 	   as avgMosInFileTLRptd0To2Mos,
	INTEGER 	   as highestUtilOnBankNatlRevTL,
	VARCHAR(20)		   as lowestRatingIL,
	INTEGER		   as lowestRatingRevOpen,
	CHAR(4)		   as maxDelq0To11Mos,
	INTEGER	   	   as mosSncOldestBankNatlRevOpenTLOpnd,
	CHAR(10)  	   as netFrctTLOpnd0To35Mos,
	VARCHAR(30) 		   as totBalDelqTL,
	VARCHAR(20) 	   as numFinInq0to5Mos,
	VARCHAR(20)	   as maxDelqEver,
	CHAR(10)	   as pctInq0To2MosByInq0To11Mos,
	VARCHAR(20) 	   as numRetTLOpnd0to5Mos,
	VARCHAR(30) 		   as num_sumasaldoscuentasabiertas,
	VARCHAR(30) 		   as num_sumalineascuentasabiertas,
	DECIMAL(18,2)  as pct_usocuentasabiertas,
	INTEGER		   as num_antiguedadpromediocuentas12meses,
	INTEGER 	   as num_consultasfinanciera,
	INTEGER 	   as num_maxplazodias,
	CHAR(2) 	   as clv_tipoproductocrediticio,	
	MONEY 		   as num_montofechamorosamasgravemasreciente,
	INTEGER 	   as num_totalperiodosreportados,
	DECIMAL(18,2)  as num_porcentajecorrientepromedio,
	INTEGER 	   as num_lineacreditopromedio,
	INTEGER 	   as num_arrendamiento,
	INTEGER 	   as num_tiendacomercial,
	INTEGER 	   as clv_worstcurrentmop,	
	INTEGER 	   as num_direcciones,
	MONEY 		   as num_montopeoratrasohistoricomasreciente,	
	INTEGER 	   as num_mesespeoratrasohistoricomasreciente,	
	MONEY 		   as num_sumasaldoscuentasrevolventessintelcos, 	
	MONEY 		   as num_sumalineascuentasrevolventessintelcos, 
	DECIMAL(18,2)  as pct_usocuentasrevolventessintelcos,		 
	INTEGER 	   as num_tarjetacredito,						 
	INTEGER 	   as num_consultas90dias,						 
	INTEGER 	   as num_cuentasMOP3,							 
	INTEGER 	   as num_cuentas,	
	INT8 	   	   as num_consultassic,		
	SMALLINT	   as vgrupoA,		 
	CHAR(20)	   as NumSolMovil,
	SMALLINT	   as iFlag2credito,
	INTEGER		   as NumCuentaPagoMinimo,
	CHAR(10)		   as dtFechaSolicitud,
	SMALLINT	   as sEdadCte,
	SMALLINT as pMeses_historia_grupo,
	DECIMAL(5,2) as pSituacion_pago_grupo,
	DECIMAL(18,2) as dSalariomin,
    DECIMAL(18,2) as dTasa_Ordinaria,
    DECIMAL(18,2) as dTasa_Moratoria,
    DECIMAL(18,2) as diva,
    DECIMAL(18,2) as dDiaspromedio,
    DECIMAL(18,2) as dTope_ingre,
    DECIMAL(18,2) as dcVeces_smb,
    DECIMAL(18,2) as dPorcpermitido,
    DECIMAL(18,2) as dMesespermitido,
    DECIMAL(18,2) as dMinimomesespermitido,
	CHAR(30) 	  as cEstado,
	CHAR(30)      as cMunicipio,
	INTEGER 	  as cBRM_reing;
-------------------------------------------- DEFINICION DE VARIABLES ---------------------------
--DEFINICION DE VARIABLES DATOS DEL CLIENTE
DEFINE cNumCte                  CHAR(20);      --nÃºmero de cliente Coppel
DEFINE cNumCteBco		        CHAR(20);      --nÃºmero de cliente Bancoppel
DEFINE cB_INE		            INTEGER;      --Flag de validaciÃ³n INE B_ife
DEFINE cCurp 					CHAR(20);      --Corresponde al CURP del cliente 
DEFINE dtFechaCte			    CHAR(10);          --Corresponde a la fecha de alta del cliente
DEFINE dtFechaNac 				CHAR(10);          --Corresponde a la Fecha de Nacimiento del cliente 
DEFINE cSexo                    CHAR(1);       --Corresponde al genero del cliente 
DEFINE cEdo_Civil               CHAR(50);      --Correspojde al estado civil del cliente -**
DEFINE iTiem_Edo_Civil          INTEGER;      --Corresponde al tiempo del estado civil 
DEFINE iTiem_Edo_Civil_meses    INTEGER;      --Corresponde al tiempo de estado civil en  meses
DEFINE cEscolaridad             CHAR(50);      --Corresponde al grÃ¡do mÃ¡ximo de estudios del cliente 
DEFINE cHabita_en               CHAR (50);     --Tipo de vivienda del cliente -**
DEFINE cTipoResidencia          CHAR (50);     --Corresponde al tipo de residencia
DEFINE cEntidad                 CHAR(50);      --Corresponde a la entidad de residencia del cliente -**
DEFINE vLocalidad        		VARCHAR(200);  -- Corresponde a la localidad del cliente
DEFINE iTiem_Residencia   		INTEGER;      --Corresponde al tiempo de residencia  
DEFINE cGeoCte		  		    CHAR(20);      --Corresponde a las cordenadas de localizaciÃ³n del cliente 
DEFINE cFlagGeoMov			    CHAR(1);       --Corresponde al flag de geolocalizaciÃ³n 
DEFINE iFlagGeoSuc		        VARCHAR(2);       --Correspode al flag de geolocalizacion diderente a la ubicaciÃ³n de la sucursal
DEFINE cTelCasa                 CHAR(13);      --Corresponde al telÃ©fono de casa del cliente
DEFINE cTelTrabajo              CHAR(13);      --Corresponde al telÃ©fono de trabajo del cliente
DEFINE iBanderaReferencia		VARCHAR(20);       --Corresponde a un flag de coincidencia de las referencias telefÃ³nicas vs las enviadas a supervisiÃ³n
DEFINE sValida_Cel	            VARCHAR(2);      --iValidaCel (nÃºmero de tel celulares activos y validados deberÃ­a ser max=1
DEFINE cOcupacion               CHAR(50);      --Corresponde a la ocupaciÃ³n del cliente
DEFINE iTiem_Ocupacion          INTEGER;      --Corresponde al tiempo que lleva laborando
DEFINE cProfesion             	CHAR(3);       --profesiÃ³n del cliente
DEFINE sId_actividad		    SMALLINT;      --ID de la actividad que realiza el cliente
DEFINE cDescAct 			    CHAR(60);      --descripciÃ³n de la actividad que realiza el cliente
DEFINE sId_subactividad	        SMALLINT;      --ID de la sub- actividad que realiza el cliente
DEFINE vDescSubAct      		VARCHAR (50);  --descripciÃ³n de la actividad que realiza el cliente
DEFINE mIngreso_Mensual			MONEY;         --Corresponde al ingreso mensual reportado por el cliente
DEFINE mIngreso_Neto            MONEY;         --Corresponde al ingreso mensual neto del cliente ** validar si viene de informaciÃ³n de coppel
DEFINE cCompIngresos			CHAR(1);       --Corresponde al flag comprobante de ingresos del cliente
DEFINE dIngresoCac              DECIMAL(14,2); --Corresponde al ingreso del cliente con comprobante de ingresos valido por Mesa de Control
DEFINE sCompValido      		SMALLINT;      --Corresponde al flag de validaciÃ³n por parte de mesa de control del comprobante de ingreso
DEFINE sFlagHuella              CHAR(1);      --corresponde a la coincidencia o no de la hulla del cliente banco vs coppel
DEFINE cCod_Ult_Identif         CHAR(2);       --Corresponde a la Ãºltima identificacion presentada por el cliente ( INE,PASAPORTE....ETC)
DEFINE sEdadCte					SMALLINT;       --Corresponde a la edad del cliente
DEFINE pMeses_historia_grupo 	SMALLINT;       --Corresponde a
DEFINE pSituacion_pago_grupo 	DECIMAL(5,2);   --Corresponde a

--DEFINICION DE VARIABLES DE CUENTA COPPEL
DEFINE dtUltimaCompra           CHAR(10) ;           --Fecha Ãºltima compra
DEFINE cPuntualidadCoppel       CHAR(2);        --clasicficaciÃ³n del cliente Coppel de acuerdo al comportamiento de pago en todas sus cuentas
DEFINE dEficienciaCoppel    	DECIMAL(5,2);   --Calculo que realiza el sistema de historial de pagos del cliente Coppel
DEFINE dSituacionPagoCoppel     CHAR(10);   --calculo que realiza el sistema de historial de pagos del cliente Coppel
DEFINE iCredDigitalesAct        INTEGER;        --cuenta de crÃ©ditos digitales activos
DEFINE cSituacionEspecial       CHAR(1);        --Corresponde a la revisiÃ³n de situaciones especiales que pueda tener el cliente en coppel
DEFINE sCausaSituacion          SMALLINT;       --Causa de la situaciÃ³n especial
DEFINE cMotivoRech            	CHAR(1);        --Motivo del rechazo en Coppel
DEFINE cDescMvo             	CHAR(300);      --descripciÃ³n del motivo del rechazo en Coppel 
DEFINE sHist_meses              SMALLINT;       -- tiempo de experiencia crediticia en Coppel del cliente pendiente -->Preca
DEFINE cCteExcep		      	CHAR(20);       --Cliente coppel que presenta excepciÃ³n
DEFINE dtmaxFechaAperturaDelProducto CHAR(10) ;      --fecha mÃ¡xima de apertura del producto de porcentaje mÃ¡s bajo y si existe empate se toma el mÃ¡s reciente , no son CC, FF
DEFINE cFechaUltimoPago         CHAR(13);       --fecha ultimo pago
DEFINE dtMinFechaAperturasinFF  CHAR(10) ;           --MÃ­nima fecha de apertura de las cuentas que no son FFen sd_maecredcrd
DEFINE dtminFechaApertura       CHAR(10) ;           --fecha minima de apertura que tenga el cliente
DEFINE mAbonoTotal              MONEY(14,2);    --abono total de sus cuentas Coppel
DEFINE mAbonoVencidoTotal       MONEY(14,2);    --Abono vencido total vencido de sus cuentas Coppel
DEFINE mAbonoMuebles         	MONEY(14,2);    --Abono mensual del cliente en muebles
DEFINE mAbonoPrestamos       	MONEY(14,2);    --Abono mensual del cliente en prestamo
DEFINE mAbonoRopa            	MONEY(14,2);    --Abono mensual del cliente en ropa
DEFINE mAbonoAire    		    MONEY(14,2);    --Abono mensual del cliente en tiempo aire
DEFINE mAbonoAfiliados 	        MONEY(14,2);    --Abono mensual del cliente en afiliados
DEFINE mAbonoReestructura 	    MONEY(14,2);    --Abono mensual del cliente en reestructuras
DEFINE mVencidoMuebles 	        MONEY(14,2);    --vencido mensual del cliente en muebles
DEFINE mVencidoRopa 	        MONEY(14,2);    --vencido mensual del cliente en ropa
DEFINE mVencidoPrestamos        MONEY(14,2);    --vencido mensual del cliente en prestamo personal
DEFINE mVencidoAire             MONEY(14,2);    --vencido mensual del cliente en tiempo aire
DEFINE mVencidoAfiliados        MONEY(14,2);    --vencido mensual del cliente en afiliados
DEFINE mVencidoReestructura     MONEY(14,2);    --vencido mensual del cliente en reestructura
DEFINE mTotalVencido            MONEY(14,2);    --total vencido de sus cuentas Coppel
DEFINE mPagoMinimo              MONEY(14,2);    --Corresponde al pago mÃ­nimo del cliente
DEFINE mLinea_tienda            MONEY(14,2);    --Corresponde a la lÃ­nea de crÃ©dito del cliente
DEFINE cTipoSolOS		    	CHAR(1);        --Corresponde al tipo de solicitud ( titular/prospecto) de la Ãºltima OS registrada
DEFINE mSaldoRopa				MONEY;          --Corresponde al saldo pendinete de ropa
DEFINE mSaldoMuebles			MONEY;          --Corresponde al saldo pendinete de muebles
DEFINE mSaldoPrestamos			MONEY;          --Corresponde al saldo pendinete de ropprestamos

--DEFINICION DE VARIABLES DE BANCO
DEFINE mCompro_banco            	MONEY (14,2);   --Corresponde a los compromisos banco del cliente 
DEFINE dComprobanco_TDC         	DECIMAL(14,2);  --Corresponde a los compromisos de tarjeta de crÃ©dito Bancoppel
DEFINE mCompro_bancoPP				DECIMAL(14,2);
DEFINE iMaxSalVencidoBancoppel  	INTEGER;        --MÃ¡ximo saldo vencido de sus cuentas Bancoppel sin considerar status CC,FF
DEFINE iCtas_StatusCV           	INTEGER;        --Corresponde al nÃºmero de cuentas que tienen estatus CV ( crÃ©dito vendido Bancoppel) sin considerar estatus CC,FF
DEFINE iCred_StatusFC           	INTEGER;        --Corresponde al conteo de crÃ©ditos con estatus FC
DEFINE iCred_StatusFF_restru    	INTEGER;        --Corresponde al conteo de crÃ©ditos con estatus FC en maecred y que no tienen FF en maecredcrd
DEFINE iCredits_riesgoD         	INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus CC,FF
DEFINE iCredits_riesgoE        		INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus CC,FF
DEFINE iCredits_riesgoC         	INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus CC,FF
DEFINE iMaxMontoReserva         	INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus CC,FF
DEFINE iCred_StatusDif_FF       	INTEGER;        --Corresponde a los crÃ©ditos con estatus diferente de FF en sd_maecredcrd
DEFINE dMaxSalVencidoCRD        	DECIMAL(18,2);  --Corresponde al mÃ¡ximo saldo vencido de los creditdos con estatus distinto FF y producto <> 6011
DEFINE iCuentasStatusCVsinFF    	INTEGER;        --Corresponde al nÃºmero de cuentas que tienen estatus CV ( crÃ©dito vendido Bancoppel) sin considerar estatus FF
DEFINE iCtas_StatusDif_FF_6011  	INTEGER;        --Corresponde al # de cuentas con estatuus <> FF y producto =6011
DEFINE iCtas_StatusFF_6011      	INTEGER;        --Corresponde al # de cuentas con estatuus = FF y producto =6011
DEFINE iCredRiesgoD_sinFF		 	INTEGER;        --Corresponde a situaciones especiales, no se considderan estatus FF
DEFINE iCredRiesgoE_sinFF			INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus FF
DEFINE iCredRiesgoC_sinFF		 	INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus FF
DEFINE dmaxMontoReservaRiesgoC_sinFF DECIMAL(18,2);  --Corresponde a situaciones especiales,no se considderan estatus FF
DEFINE iReprestamos             	INTEGER;        --correpsonde al flag represtamos
DEFINE cSolBanco					CHAR(20);
DEFINE sFlag_oro					SMALLINT;       --Corresponde al flag de tarjeta Oro
DEFINE vClvEdoCob       			VARCHAR(10);    --Corresponde a la variable Clave Estado Cobranza 
DEFINE cEstado                      CHAR(30);
DEFINE cMunicipio                   CHAR(30);
DEFINE cVigenciaBancoppel       	CHAR(20);       --Vigencia Bancoppel 
DEFINE dLineaBanco              	DECIMAL(14,2);  --LÃ­nea de utilizaciÃ³n  Bancoppel
DEFINE cResultadoOsTel          	CHAR(1);        --Corresponde al resultado de la Orden de SupervisiÃ³n telÃ©fonico
DEFINE cTieneOstel              	CHAR(1);        --Corresponde al flag que identifica si la solicitud tiene o no Orden de supervisiÃ³n telÃ©fonica
DEFINE cEnvioCat                	CHAR(1);        --Corresponde al flag que identifica si  la solicitud se envio al Centro de atenciÃ³n telefÃ³nica CAT
DEFINE iSolMc				    	INTEGER;        --Corresponde al numero de veces que se ha enviado la solicitud a mesa de control
DEFINE iSolMcAux		        	INTEGER;        --Corresponde al numero de veces que se ha enviado la solicitud referencia a mesa de control
DEFINE iSecuenciaOs			    	VARCHAR(20);        --Corresponde a la secuencia de orden de supervisiÃ³n  de la Ãºltima OS registrada
DEFINE cStatusRespOs		    	CHAR(1);        --Corresponde al estatus de la respuesta de orden de supervisiÃ³n  de la Ãºltima OS registrada
DEFINE dtFecha_Respuesta			CHAR(10);           --Corresponde a la fecha de respuesta de la Orden de SupervisiÃ³n  de la Ãºltima OS registrada
DEFINE cMotivoRechBcpl  			CHAR(1); 		--Motivo de rechazo BanCoppel
DEFINE cDescripcion					CHAR(60);
DEFINE cRiesgoViviendaCpl  			CHAR(1);
DEFINE cRiesgoViviendaBcpl  		CHAR(1);
DEFINE cActRiesgoCpl        		CHAR(1);
DEFINE cActRiesgoBCpl				CHAR(1);
DEFINE cDescpRiesgo					CHAR(120);
DEFINE cEjecucion	  				CHAR(1);


--DEFINICION DE VARIABLES DE BURÃ
DEFINE dCompromisos                 DECIMAL(14,2); --Corresponde a los compromisos de todas las cuentas del cliente BC
DEFINE dMontoUdis                   DECIMAL(14,2); --monto en UDIS de la observaciÃ³n mÃ¡s reciente
DEFINE cInstitucion                 CHAR(2);       --nombre de la instituciÃ³n de la observaciÃ³n mÃ¡s reciente
DEFINE cClvObser                    CHAR(2);       --clave de observaciÃ³n mÃ¡s reciente (vStatus) 
DEFINE iNumCtas_ClvOb               VARCHAR(20);       --NÃºmero de cuentas que tienen clave de observaciÃ³n FD,PS,SU,CV,PC,SG,SP,SR,UP,FR en BurÃ³, no considera comunicaciones y servicios
DEFINE iMax_MOP                     VARCHAR(20);       --MÃ¡ximo MOP actual, no considera Comunicaciones y servicios,cuentas Bancoppel con clave de observaciÃ³n RV
DEFINE cInstCta_MayorMOP            VARCHAR(30);       --Nombre de instituciÃ³n de cuenta con mayor MOP
DEFINE dMonto_UDIS_MayorMOP         DECIMAL(14,2); --Monto UDIS de  cuenta con mayor MOP
DEFINE iMax_MOP_Hist_6m             VARCHAR(20);       --MÃ¡ximo_MOP histÃ³rico 6 meses de cuentas con >=100 UDIS
DEFINE cInstCta_MayorMOP_6m         CHAR(2);       --Nombre de instituciÃ³n de cuenta con mayor MOP histÃ³rico 6 meses de cuentas con >=100 UDIS
DEFINE dMontoUDIS_MM_6m             DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP histÃ³rico 6 meses de cuentas con >=100 UDIS
DEFINE iMM_Histo_12m                VARCHAR(20);       --MÃ¡ximo_MOP histÃ³rico 12 meses de cuentas con >=100 UDIS
DEFINE cInstCta_MayorMOP_12m        CHAR(2);       --Nombre de instituciÃ³n de cuenta con mayor MOP histÃ³rico 12 meses de cuentas con >=100 UDIS
DEFINE dMontoUDIS_MM_12m            DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP histÃ³rico 12 meses de cuentas con >=100 UDIS
DEFINE iNumCtasMOP_4_12m            INTEGER;       --NÃºmero de cuentas MOP =4 Ãºltimos 12 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_5_12m            INTEGER;       --NÃºmero de cuentas MOP =5 Ãºltimos 12 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_mayor5_12m       INTEGER;       --NÃºmero de cuentas MOP >5 Ãºltimos 12 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iMOP4_12mCon1o2   			INTEGER;       --NÃºmero de cuentas MOP =4 Ãºltimos 12 meses, UDIS >=100, no considera telecomunicaciones ni servicios, deberÃ¡ considerar los 6 meses mÃ¡s recientes con valores 1 0 2
DEFINE iMOP5_12mCon1o2   			INTEGER;       --NÃºmero de cuentas MOP =5 Ãºltimos 12 meses, UDIS >=100, no considera telecomunicaciones ni servicios, deberÃ¡ considerar los 6 meses mÃ¡s recientes con valores 1 0 2
DEFINE iMOPmayor5_12mCon1o2			INTEGER;       --NÃºmero de cuentas MOP >5 Ãºltimos 12 meses, UDIS >=100, no considera telecomunicaciones ni servicios, deberÃ¡ considerar los 6 meses mÃ¡s recientes con valores 1 0 2
DEFINE cInstCta_MayorMOP_30m        CHAR(2);       --Nombre de instituciÃ³n de cuenta con mayor MOP histÃ³rico 30 meses de cuentas con >=100 UDIS
DEFINE dMontoUDIS_MM_Rech           DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP, de cuenta que provoca el rechazo
DEFINE iNumCtasMOP_4_30m            INTEGER;       --NÃºmero de cuentas MOP =4 Ãºltimos 30 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_5_30m            INTEGER;       --NÃºmero de cuentas MOP =5 Ãºltimos 30 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_mayor5_30m       INTEGER;       --NÃºmero de cuentas MOP >5 Ãºltimos 30 meses, UDIS >=100, sin comunicaciones ni servicios
DEFINE iCtasMOP_4_30mCon1o2         INTEGER;       --NÃºmero de cuentas MOP =4 Ãºltimos 30 meses, UDIS >=100, no considera telecomunicaciones ni servicios, deberÃ¡ considerar los 12 meses mÃ¡s recientes con valores 1 0 2
DEFINE iCtasMOP_5_30mCon1o2         INTEGER;       --NÃºmero de cuentas MOP =4 Ãºltimos 30 meses, UDIS >=100, no considera telecomunicaciones ni servicios, deberÃ¡ considerar los 12 meses mÃ¡s recientes con valores 1 0 2
DEFINE iCtasMOP_mayor5_30mCon1o2    INTEGER;       --NÃºmero de cuentas MOP >5 Ãºltimos 30 meses, UDIS >=100, no considera telecomunicaciones ni servicios, deberÃ¡ considerar los 12 meses mÃ¡s recientes con valores 1 0 2
DEFINE cInstitucionMMOP_provocaRech CHAR(2);       --Nombre de instituciÃ³n de cuenta con mayor MOP (Ãºltimos 30 dÃ­as),de cuenta que provoca el rechazo
DEFINE dMontoUDIS_30d_Rech          DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP (Ãºltimos 30 dÃ­as), de cuenta que provoca el rechazo
DEFINE iMM_Histo_30m                VARCHAR(20);       --MÃ¡ximo_MOP histÃ³rico 30 meses de cuentas con >=100 UDIS (Se jerarquizan por fecha_reporte, " para mns de salida")
DEFINE cInstCta_MM_30m_Rech         CHAR(2);       --Nombre de instituciÃ³n de cuenta con mayor MOP (maximo Mop histrico 30 meses..) de cuenta que provoca el rechazo
DEFINE dMotoUDIS_MM_30m_Rech        DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP (maximo Mop histrico 30 meses..) de la cuenta que provoca el rechazo
DEFINE iMM_act_Bancos               VARCHAR(20);       --MÃ¡ximo_MOP actual de bancos
DEFINE iMM_hist_alto_Bancos         VARCHAR(20);       --MÃ¡ximo_MOP historico mÃ¡s alto bancos
DEFINE iMM_hist_Bancos              VARCHAR(20);       --MÃ¡ximo_MOP historico bancos
DEFINE iCtasBancosMOP_tl26          INTEGER;       --NÃºmero de cuentas del cliente que son "Banco,Bancos,Bancoppel" ,tl06 = R ( revolvente) y con MOP actual (tl26) en  MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasBancosMOP_tl38          INTEGER;       --NÃºmero de cuentas del cliente que son "Banco,Bancos,Bancoppel" ,tl06 = R ( revolvente) y con MOP historico mÃ¡s alto (tl38) en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasBancosMOP_tl27          INTEGER;       --NÃºmero de cuentas del cliente que son "Banco,Bancos,Bancoppel" , tl06 = R ( revolvente) y con MOP historico (tl27) en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasBancosMOP_act_hist_alto INTEGER;       --Numero de cuentas de Bancos con MOP actual, historico e historico mÃ¡s alto ( incluye Bancoppel)
DEFINE iCtasComServMOP_tl26         INTEGER;       --NÃºmero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP actual (tl26) en MOP 3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl38         INTEGER;       --NÃºmero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP historico mÃ¡s alto  (tl38) en MOP 3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl27         INTEGER;       --NÃºmero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP historico  (tl27) en MOP 3,4,5,6,7,96,97,99
DEFINE iCtasCSM_act_hist_alto       INTEGER;       --NÃºmero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP actual o MOP historico o MOP historico mÃ¡s alto en MOP 3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl26_12m     INTEGER;       --NÃºmero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP actual (tl26) y menos de 12 meses en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl38_12m     INTEGER;       --NÃºmero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP historico mÃ¡s alto  (tl38) y menos de 12 meses en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl27_12m     INTEGER;       --NÃºmero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP historico  (tl27)  y menos de 12 meses en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasCSM_ActHistAlto_12m     INTEGER;       --NÃºmero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP actual o MOP historico o MOP historico mÃ¡s alto  y menos de 12 meses en MOP 2,3,4,5,6,7,96,97,99
DEFINE iMaxMOP_actBancos            VARCHAR(20);       --MÃ¡ximo_MOP actual de bancos reportadas el Ãºltimo aÃ±o
DEFINE iMaxMOP_histAltBancos        VARCHAR(20);       --MÃ¡ximo_MOP historico mÃ¡s alto de bancos reportadas el Ãºltimo aÃ±o
DEFINE iMaxMOP_histBancos           VARCHAR(20);       --MÃ¡ximo_MOP historico de bancos reportadas el Ãºltimo aÃ±o
DEFINE iMaxMOP_actCtas              VARCHAR(20);       --Maximo_MOP actual de todas las cuentas
DEFINE iMaxMOP_histAltCtas          VARCHAR(20);       --Maximo_MOP histroico mÃ¡s alto de todas las cuentas
DEFINE iMaxMOP_histCtas             VARCHAR(20);       --Maximo_MOP historico de todas las cuentas
DEFINE iCtas_SinComServ             INTEGER;       --NÃºmero de cuentas sin comunicaciones ni servicios
DEFINE iCtas_SinComServ_pagar       INTEGER;       --NÃºmero de cuentas sin comunicaciones ni servicios con monto a pagar >0
DEFINE iNumCtas_SHBr                INTEGER;       --NÃºmero de cuentas, son de servicios ,hipoteca y bienes raÃ­ces
DEFINE iNumCtas_SHBr_pagar          INTEGER;       --NÃºmero de cuentas con monto a pagar >0, servicios (tl02), hipoteca (tl06=M),bienes raÃ­ces (tl07=RE)



--DEFINICION DE VARIABLES DE SOLICITUD
DEFINE dtFechaSolicitud         CHAR(10);
DEFINE cCteProsp		        CHAR(20);       --numero de cliente prospecto
DEFINE cStatusSol_CteProsp      CHAR(2);        --Corresponde al estatus de la solicitud del cliente prospecto 
DEFINE cTipo_Alta_CteProsp      CHAR(1);        --Tipo de Alta Cte Prospecto
DEFINE cCteProspVig			    CHAR(20);       --Corresponde a la vigencia del cliente  prospecto
DEFINE cSucursal   			    CHAR(4);        --Numero de Sucursal
DEFINE iFlagEmpleado            CHAR(1);       --Corresponde al flag de empleado Coppel y/o Bancoppel
DEFINE sEntidad_Localidad		VARCHAR(10);       --Corresponde a la variable entidad/localidad 
DEFINE iCanal_Sol         	    CHAR(2);        --Corresponde al canal por el cual se originÃ³ la solicitud
DEFINE iCanalV1				    VARCHAR(10);        --Canal de solicitud ingresada por prospectÃ©o
DEFINE cTp_solicitud            CHAR(1);        --tipo de solicitud
DEFINE cNum_Producto            CHAR(4);        --tipo de producto
DEFINE cStatusSolicitud         CHAR(2);        --estatus de la solicitud
DEFINE cCausa_Sol			    CHAR(3);        --causa del rechazo de la solicitud
DEFINE cTipoRech                CHAR(1);        --tipo de rechazo de la solicitud
DEFINE cTipoGrupo 			    CHAR(2);        --grupo de evaluaciÃ³n al cual pertenece la solicitud
DEFINE cSituacion  				CHAR(1); 		--Situacion del producto de porcentaje mÃ¡s bajo y si existe empate se toma el mÃ¡s reciente 
DEFINE cProducto                CHAR(4);        --producto de porcentaje mÃ¡s bajo y si existe empate se toma el mÃ¡s reciente
DEFINE dminProcentajeProductoMasReciente DECIMAL(6,2);   --porcentaje mÃ­nimo del producto mÃ¡s reciente
DEFINE sFlagForzarEnvioMC       VARCHAR(20);       --Etatus de la Ãºltima solicitud que no terminÃ³ en (AN,PC) y que su producto si se envÃ­a a mesa de control (6300,6400,7600,7700,9100,9300,6001,6800)
DEFINE cNumSol_Os			    CHAR(20);       --Corresponde al numero de solicitud de la Orden de supervisiÃ³n  de la Ãºltima OS registrada
DEFINE sScore_coppel            SMALLINT;       --Corresponde a los puntos asignados en la evaluaciÃ³n del score de Coppel
DEFINE dValor_3s                DECIMAL(14,2);  --Corresponde al valor del score  de Circulo de crÃ©dito 
DEFINE cFolioMovil         	    CHAR(20);       --Folio solicitud movil
DEFINE cStatusMovil             CHAR(1);        --Estatus solicitud movil
DEFINE sBc_Score                SMALLINT;  		--valor del score ( Indica la calificaciÃ³n del score solicitado "nÃºmero positivo")
DEFINE cInstitucionClvExclusionMasReciente CHAR(2); -- Corresponde a la INSTITUCION de exclusion mÃ¡s reciente
DEFINE vClvExclusionMasReciente INTEGER;	-- Corresponde a la CALVE de exclusion mÃ¡s reciente



--DEFINICION DE VARIABLES DE PARAMETRICOS
DEFINE HR0048               INTEGER;       --Number of ever satisfactory trades open 12 months or older (NÃºmero de cuenta abiertas con 12 meses o mÃ¡s).
DEFINE HR0050               VARCHAR(20);       --# de cuentas abiertas en los ultimos 6 meses o mas. Grupo 53
DEFINE TR0002               VARCHAR(20);       --NUMERO PROMEDIO DE MESES
DEFINE TR0001               VARCHAR(20);       --EL MES MAXIMO DE LA CUENTA ABIERTA MAS VIEJA
DEFINE IQ0002               VARCHAR(20);       --Numero de consultas al cliente por instituciÃ³n
DEFINE BC_421               DECIMAL(18,2); --Corresponde a la variable que se calcula actualmente
DEFINE BC_85                VARCHAR(20);       --Corresponde a la variable que se calcula actualmente
DEFINE BC_93                VARCHAR(20)	;       --Corresponde a la variable que se calcula actualmente
DEFINE BC1                  INTEGER;       --la mÃ¡xima cantidad de meses entre la fecha y la fecha de apertura de la cuenta
DEFINE BC_101               INTEGER;       --Corresponde a la variable que se calcula actualmente
DEFINE BC_117               INTEGER;       --Corresponde a la variable que se calcula actualmente
DEFINE BC_119               INTEGER;       --Corresponde a la variable que se calcula actualmente
DEFINE BC_20                INTEGER;       --Corresponde a la variable que se calcula actualmente
DEFINE UT0034               INTEGER;       --Utilization percent of bank revolving trades (Porcentaje de utilizaciÃ³n en cuentas revolventes bancarias).
DEFINE dSaldo_linea_credi	VARCHAR(30); --Corresponde a variables para prestamo
DEFINE dSaldo_limit_credi   VARCHAR(30); --Corresponde a variables para prestamo


--DEFINICION DE VARIABLES DE EVALUACIÃN
DEFINE cRTipo3           CHAR(1);       --Corresponde a la clave de envÃ­o a OS ( A,R,D.....)
DEFINE cVigSolOS         CHAR(1);       --Corresponde si la solicitud estÃ¡ vigente o vencida para envÃ­o a OS (vVigente)
DEFINE sBuenPagos        CHAR(30);      --Corresponde al buen pago 
DEFINE sFlagBuenPago12   VARCHAR(10);      --Corresponde al flag de buen pago 12meses
DEFINE sFlagBuenPago30   VARCHAR(10);      --Corresponde al flag de buen pago 30meses
DEFINE cNuevoStatusOstel CHAR(2);       --Corresponde al estatus despuÃ©s de la OS tel*** Oscar solicita tabla **rev
DEFINE dMontoOtorgado    DECIMAL(18,4); --Corresponde al monto otorgado 
DEFINE mCapacidad_pago   MONEY(14,2);   --Corresponde a la capacidad de pago 
DEFINE iExisteCliente    INTEGER;       --Conteo de solicitudes del cliente para producto Coppel con estatus diferente de 'PC','AN','MC'
DEFINE cTipo_movimiento  CHAR(1);       --Correspode al tipo de movimiento ( U,M) unico, mixto 
DEFINE dCompromisosCac   DECIMAL(14,2); --Compromisos registrados en las tabla ss_solicitudes_cac ( aparentemenete son los compromisos validados por Mesa de Control, ya no se usa)
DEFINE dtFechaAux        CHAR(10);          --Fecha de la Ãºltima consulta realizada que no sea de Bancoppel
DEFINE dTasa             DECIMAL(9,6);  --
DEFINE dtasaMora		 DECIMAL(9,6);
DEFINE cOrigenSol        CHAR(1);       --Corresponde al origen ( contiene T,B,vacio)*
DEFINE cOrigenCte        CHAR(1);       --Corresponde al origen del cliente ( prospecto, titular...)
DEFINE mImporte_hip      MONEY;         --Corresponde al monto de la hipoteca del cliente
DEFINE iMeses_hist_Val   INTEGER;      	--NÃºmero de de meses de historia validos del cliente de acuerdo a su edad
DEFINE sCteLargo8        SMALLINT;      --Determina si es grupo 8
DEFINE sCteLargo         VARCHAR(20);      --Corresponde a clientes con cuenta de captaciÃ³n en su primer producto ( solo dÃ©bito)
DEFINE vgrupoA 			 SMALLINT;		--Conteo por empresa y cliente de la tabla sd_grupo_cliente
DEFINE NumSolMovil		 CHAR(20);		--Numero de solicitud movil de la tabla ss_solicitudes_movil
DEFINE iFlag2credito 	 SMALLINT;		--Variable flag sale del procedure sp_valida2Credito


------------------------------------------------------------------------------
------------------  DEFINICION DE VARIABLES DE REINGENIERIA ------------------
------------------------------------------------------------------------------

DEFINE mosSncOldestRevTLOpnd					 INTEGER; ----------------------
DEFINE numInq0to2Mos							 VARCHAR(20);
DEFINE pctBankILTL								 VARCHAR(30);
DEFINE pctTL30pDaysEverColl						 CHAR(10); --fico
DEFINE avgMosInFileTLRptd0To2Mos				 CHAR(10); --fico
DEFINE highestUtilOnBankNatlRevTL				 INTEGER; ----------------------
DEFINE lowestRatingIL							 VARCHAR(20);
DEFINE lowestRatingRevOpen						 CHAR;
DEFINE maxDelq0To11Mos							 CHAR(10); --fico
DEFINE mosSncOldestBankNatlRevOpenTLOpnd		 CHAR;
DEFINE netFrctTLOpnd0To35Mos					 CHAR(10); --fico
DEFINE totBalDelqTL								 VARCHAR(30);
DEFINE numFinInq0to5Mos							 VARCHAR(20);
DEFINE maxDelqEver								 VARCHAR(20);
DEFINE pctInq0To2MosByInq0To11Mos				 CHAR(10); --fico
DEFINE numRetTLOpnd0to5Mos						 VARCHAR(20); --fico
DEFINE num_sumasaldoscuentasabiertas			 VARCHAR(30);
DEFINE num_sumalineascuentasabiertas			 VARCHAR(30);
DEFINE pct_usocuentasabiertas				 	 DECIMAL(18,2);
DEFINE num_antiguedadpromediocuentas12meses		 INTEGER; ----------------------
DEFINE num_consultasfinanciera					 INTEGER;
DEFINE num_maxplazodias							 INT8;
DEFINE clv_tipoproductocrediticio				 CHAR(2);	
DEFINE num_montofechamorosamasgravemasreciente	 DECIMAL(18,2);
DEFINE num_totalperiodosreportados				 INTEGER;
DEFINE num_porcentajecorrientepromedio			 DECIMAL(18,2);
DEFINE num_lineacreditopromedio					 INTEGER;
DEFINE num_arrendamiento						 INTEGER;
DEFINE num_tiendacomercial						 INTEGER;
DEFINE clv_worstcurrentmop						 INTEGER;	
DEFINE num_direcciones							 INTEGER;
DEFINE num_montopeoratrasohistoricomasreciente	 DECIMAL(18,2);
DEFINE num_mesespeoratrasohistoricomasreciente	 INTEGER;
DEFINE num_sumasaldoscuentasrevolventessintelcos DECIMAL(18,2);	
DEFINE num_sumalineascuentasrevolventessintelcos DECIMAL(18,2);
DEFINE pct_usocuentasrevolventessintelcos		 DECIMAL(18,2);
DEFINE num_tarjetacredito						 INTEGER;
DEFINE num_consultas90dias						 INT8;
DEFINE num_cuentasMOP3							 INT8;
DEFINE num_cuentas								 INT8;
DEFINE num_consultassic						 	 INT8;
--------

------------------------
DEFINE NumCuentaPagoMinimo 		INT8;
DEFINE dSalariomin				DECIMAL(18,2);
DEFINE dTasa_Ordinaria 			DECIMAL(18,2);
DEFINE dTasa_Moratoria 			DECIMAL(18,2);
DEFINE diva 					DECIMAL(18,2);
DEFINE dDiaspromedio 			DECIMAL(18,2);
DEFINE dTope_ingre 				DECIMAL(18,2);
DEFINE dcVeces_smb 				DECIMAL(18,2);
DEFINE dPorcpermitido 			DECIMAL(18,2);
DEFINE dMesespermitido 			DECIMAL(18,2);
DEFINE dMinimomesespermitido 	DECIMAL(18,2);
------------------------
--Cambios Olivia
DEFINE cBRM_reing INTEGER;

--DEFINICION DE VARIABLES DE ERROR
DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cCodRet         CHAR(6);
DEFINE cMensaje_ret    VARCHAR(100,1);

--------------------------- DECLARACION DE VARIABLES ---------------------------
	--SET debug file to 'sp_consultadatos_motor_web'||TRIM(pNumSol)||'.out';
    --TRACE ON;
--INICIALIZACION DE VARIABLES DATOS DEL CLIENTE
LET cNumCte               ="";     
LET cNumCteBco		      ="";      
LET cCurp  				  ="";
LET cB_INE                =0;     
       
LET dtFechaCte			  = '01/01/1900';          
LET dtFechaNac 			  = '01/01/1900';
LET cSexo                 ="";       
LET cEdo_Civil            ="";       
LET iTiem_Edo_Civil       = 0;       
LET iTiem_Edo_Civil_meses = 0;      
LET cEscolaridad          ="";
LET cHabita_en            ="??";      
LET cTipoResidencia       = "";      
LET cEntidad              ="";
LET vLocalidad         	  = '';
LET iTiem_Residencia   	  = 0;      
LET cGeoCte		  		  ='';      
LET cFlagGeoMov			  ='';       
LET iFlagGeoSuc		      = '0';     
LET cTelCasa              ="";      
LET cTelTrabajo           ="";     
LET iBanderaReferencia	  = '0';                                           
LET sValida_Cel	          = '0';      
LET COcupacion            = "";      
LET iTiem_Ocupacion       = 0;      
LET cProfesion            ="";
LET sId_actividad		  = 0;      
LET cDescAct              ="";                                        
LET sId_subactividad	  = 0;      
LET vDescSubAct           = "";                                         
LET mIngreso_Mensual	  = 0;         
LET mIngreso_Neto         = 0;         
LET cCompIngresos		  ="";       
LET dIngresoCac           = 0; 
LET sCompValido      	  = 0;       
LET sFlagHuella           = '0';      
LET cCod_Ult_Identif      ="";       
LET sEdadCte			  = 0;
LET pMeses_historia_grupo = 0;
LET pSituacion_pago_grupo = 0;


--INICIALIZACION DE VARIABLES DE CUENTA COPPEL
LET dtUltimaCompra       		 	= '01/01/1900';          
LET cPuntualidadCoppel   		  	='';        
LET dEficienciaCoppel			  	= 0;       
LET dSituacionPagoCoppel		  	= '0.00'; 
LET iCredDigitalesAct    		  	= 0;
LET cSituacionEspecial   		  	="?";
LET sCausaSituacion      		  	= 0;       
LET cMotivoRech          		  	="";   
LET cDescMvo            		  	="Pre-Calificacion Aprobada";
LET sHist_meses               	  	= 0;      
LET cCteExcep           		  	="";
LET dtmaxFechaAperturaDelProducto 	= '01/01/1900';          
LET cFechaUltimoPago     		  	="";
LET dtminFechaAperturasinFF 	  	= '01/01/1900';
LET dtminFechaApertura 			  	= '01/01/1900';
LET mAbonoTotal          			= 0;                
LET mAbonoVencidoTotal   			= 0;    
LET mAbonoMuebles    	 			= 0;        
LET mAbonoPrestamos    				= 0;
LET mAbonoRopa        				= 0;
LET mAbonoAire           			= 0;
LET mAbonoAfiliados     			= 0;
LET mAbonoReestructura   			= 0;
LET mVencidoMuebles 	 			= 0;
LET mVencidoRopa 	     			= 0; 
LET mVencidoPrestamos    			= 0; 
LET mVencidoAire         			= 0; 
LET mVencidoAfiliados    			= 0;
LET mVencidoReestructura 			= 0;  
LET mTotalVencido        			= 0;
LET mPagoMinimo          			= 0;
LET mLinea_tienda        			= 0;    
LET cTipoSolOS		     			="";      
LET mSaldoRopa			 			= 0;
LET mSaldoMuebles		 			= 0;
LET mSaldoPrestamos		 			= 0;

--INICIALIZACION DE VARIABLES DE BANCO
LET mCompro_banco           = 0;    
LET mCompro_bancoPP			= 0;
LET dComprobanco_TDC        = 0;  
LET iMaxSalVencidoBancoppel = 0; 
LET iCtas_StatusCV          = 0;
LET iCred_StatusFC          = 0; 
LET iCred_StatusFF_restru   = 0;
LET iCredits_riesgoD        = 0;
LET iCredits_riesgoE        = 0; 
LET iCredits_riesgoC        = 0; 
LET iMaxMontoReserva        = 0;
LET iCred_StatusDif_FF      = 0;
LET dMaxSalVencidoCRD       = 0;
LET iCuentasStatusCVsinFF   = 0;
LET iCtas_StatusDif_FF_6011 = 0;
LET iCtas_StatusFF_6011     = 0; 
LET iCredRiesgoD_sinFF      = 0;
LET iCredRiesgoE_sinFF      = 0;             
LET iCredRiesgoC_sinFF      = 0; 
LET dmaxMontoReservaRiesgoC_sinFF = 0;
LET iReprestamos           	= 0;
LET cSolBanco				= pNumSol;
LET sFlag_oro		        = 0;       
LET vClvEdoCob              ="";    
LET cEstado 				='';
LET cMunicipio 				='';
LET cVigenciaBancoppel      ="";
LET dLineaBanco		        = 0;
LET cResultadoOsTel         ="";         
LET cTieneOstel             ="";        
LET cEnvioCat               ="";        
LET iSolMc			        = 0;        
LET iSolMcAux		        = 0;        
LET iSecuenciaOs	        = '0';        
LET cStatusRespOs	        ="";        
LET dtFecha_Respuesta       = '01/01/1900';       
LET cMotivoRechBcpl 		= "";
LET cDescripcion			="";
LET cRiesgoViviendaCpl  	=""; 
LET cRiesgoViviendaBcpl 	="";
LET cActRiesgoCpl       	="";
LET cActRiesgoBCpl			="";
LET cDescpRiesgo			= "";
LET cEjecucion	  			= "";
 

--INICIALIZACION DE VARIABLES DE BURÃ
LET dCompromisos              = 0; 
LET dMontoUdis                = 0; 
LET cInstitucion              ="";
LET cClvObser				  ="";
LET iNumCtas_ClvOb            = '0';       
LET iMax_MOP                  = '0';     
LET cInstCta_MayorMOP         ="";       
LET dMonto_UDIS_MayorMOP      = 0; 
LET iMax_MOP_Hist_6m          = '0';       
LET cInstCta_MayorMOP_6m      ="";       
LET dMontoUDIS_MM_6m          = 0; 
LET iMM_Histo_12m             = '0';       
LET cInstCta_MayorMOP_12m     ="";      
LET dMontoUDIS_MM_12m         = 0; 
LET iNumCtasMOP_4_12m         = 0;       
LET iNumCtasMOP_5_12m         = 0;       
LET iNumCtasMOP_mayor5_12m    = 0;       
LET iMOP4_12mCon1o2           = 0;                                  
LET iMOP5_12mCon1o2           = 0;       
LET iMOPmayor5_12mCon1o2      = 0;
LET cInstCta_MayorMOP_30m     ="";       
LET dMontoUDIS_MM_Rech        = 0; 
LET iNumCtasMOP_4_30m         = 0;       
LET iNumCtasMOP_5_30m         = 0;       
LET iNumCtasMOP_mayor5_30m    = 0;
LET iCtasMOP_4_30mCon1o2      = 0;
LET iCtasMOP_5_30mCon1o2      = 0;
LET iCtasMOP_mayor5_30mCon1o2 = 0;    
LET cInstitucionMMOP_provocaRech ="";       
LET dMontoUDIS_30d_Rech          = 0; 
LET iMM_Histo_30m                = '0';        
LET cInstCta_MM_30m_Rech         =""; 
LET dMotoUDIS_MM_30m_Rech        = 0; 
LET iMM_act_Bancos               = '0';        
LET iMM_hist_alto_Bancos         = '0';       
LET iMM_hist_Bancos              ='0';       
LET iCtasBancosMOP_tl26          = 0;       
LET iCtasBancosMOP_tl38          = 0;       
LET iCtasBancosMOP_tl27          = 0;       
LET iCtasBancosMOP_act_hist_alto = 0;      
LET iCtasComServMOP_tl26         = 0;       
LET iCtasComServMOP_tl38         = 0;       
LET iCtasComServMOP_tl27         = 0;       
LET iCtasCSM_act_hist_alto       = 0;        
LET iCtasComServMOP_tl26_12m     = 0;       
LET iCtasComServMOP_tl38_12m     = 0;       
LET iCtasComServMOP_tl27_12m     = 0;        
LET iCtasCSM_ActHistAlto_12m     = 0;       
LET iMaxMOP_actBancos            = '0';       
LET iMaxMOP_histAltBancos        = '0';        
LET iMaxMOP_histBancos           = '0';       
LET iMaxMOP_actCtas              = '0';       
LET iMaxMOP_histAltCtas          = '0';       
LET iMaxMOP_histCtas             = '0';       
LET iCtas_SinComServ             = 0;       
LET iCtas_SinComServ_pagar       = 0;      
LET iNumCtas_SHBr                = 0;       
LET iNumCtas_SHBr_pagar          = 0;       

--INICIALIZACION DE VARIABLES DE SOLICITUD
LET dtFechaSolicitud       = '01-01-1900';
LET cCteProsp		       ="";
LET cStatusSol_CteProsp    ="";
LET cTipo_Alta_CteProsp	   ="";
LET cCteProspVig		   ="";
LET cSucursal   	       ="";
LET iFlagEmpleado          = '0';
LET sEntidad_Localidad     ='0';
LET iCanal_Sol             = '0';
LET iCanalV1		       = '0';
LET cTp_solicitud          ="?";
LET cNum_Producto          ="";
LET cStatusSolicitud       ="";
LET cCausa_Sol		       ="";
LET cTipoRech              ="";  
LET cTipoGrupo 		       ="";
LET cSituacion             = "?";
LET cProducto              ='????';   
LET dminProcentajeProductoMasReciente = 0;
LET sFlagForzarEnvioMC     = '0';
LET cNumSol_Os		       ="";
LET sScore_coppel          = 0;
LET dValor_3s              = 0;
LET cFolioMovil            ="";
LET cStatusMovil           ='';
LET sBc_Score              = 0;  
LET cInstitucionClvExclusionMasReciente = "";
LET vClvExclusionMasReciente = 0;


--INICIALIZACION DE VARIABLES DE PARAMETRICOS
LET HR0048             = 0;
LET HR0050             = '0';
LET TR0002             = '0';
LET TR0001             = '0';
LET IQ0002             = '0';
LET BC_421             = 0;
LET BC_85              = '0';
LET BC_93              = '0';
LET BC1                = 0;
LET BC_101             = 0;
LET BC_117             = 0;
LET BC_119             = 0;
LET BC_20              = 0;
LET UT0034             = 0;
LET dSaldo_linea_credi = '0.00';
LET dSaldo_limit_credi = '0.00';


--INICIALIZACION DE VARIABLES DE EVALUACIÃN
LET cRTipo3           ="";
LET cVigSolOS		  ="";
LET sBuenPagos        = "";
LET sFlagBuenPago12	  = '0';
LET sFlagBuenPago30	  = '0';
LET cNuevoStatusOstel ="";
LET dMontoOtorgado    = 0;
LET mCapacidad_pago   = 0;
LET iExisteCliente    = 0;
LET cTipo_movimiento  ="";
LET dCompromisosCac   = 0;
LET dtFechaAux		  = '01/01/1900';
LET dTasa			  = 0;
LET dtasaMora = 0;
LET cOrigenSol        ='1';
LET cOrigenCte		  ="";
LET mImporte_hip      = 0;
LET iMeses_hist_Val   = 0;
LET sCteLargo8		  = 0;
LET sCteLargo         = '0';
LET vgrupoA 		  = 0;
LET NumSolMovil		  = '';
LET iFlag2credito 	  = 0;



--INICIALIZACION DE VARIABLES DE REINGENIERIA
LET mosSncOldestRevTLOpnd				= 0;
LET numInq0to2Mos						= '0';
LET pctBankILTL							= '0.00';
LET pctTL30pDaysEverColl				= '0';
LET avgMosInFileTLRptd0To2Mos			= '0';
LET highestUtilOnBankNatlRevTL			= -999;
LET lowestRatingIL						= '0';
LET lowestRatingRevOpen					= '0';
LET maxDelq0To11Mos						= '0';
LET mosSncOldestBankNatlRevOpenTLOpnd	= '0';
LET netFrctTLOpnd0To35Mos				= '0';
LET totBalDelqTL						= '0.00';
LET numFinInq0to5Mos					= '0';
LET maxDelqEver							= '0';
LET pctInq0To2MosByInq0To11Mos			= 0;
LET numRetTLOpnd0to5Mos					= '0';
LET num_sumasaldoscuentasabiertas		= '0.00';
LET num_sumalineascuentasabiertas		= '0.00';
LET pct_usocuentasabiertas				= 0;
LET num_antiguedadpromediocuentas12meses 	= 0;
LET num_consultasfinanciera					= 0;
LET num_maxplazodias						= 0;
LET clv_tipoproductocrediticio				= 0;
LET num_montofechamorosamasgravemasreciente		= 0;
LET num_totalperiodosreportados					= 0;
LET num_porcentajecorrientepromedio				= -1;
LET num_lineacreditopromedio					= 0;
LET num_arrendamiento							= 0;
LET num_tiendacomercial							= 0;
LET clv_worstcurrentmop							= 0;
LET num_direcciones								= 0;
LET num_montopeoratrasohistoricomasreciente		= 0;
LET num_mesespeoratrasohistoricomasreciente		= 0;
LET num_sumasaldoscuentasrevolventessintelcos	= 0;	
LET num_sumalineascuentasrevolventessintelcos 	= 0;
LET pct_usocuentasrevolventessintelcos		 	= 0;
LET num_tarjetacredito						 	= 0;
LET num_consultas90dias						 	= 0;
LET num_cuentasMOP3								= 0;
LET num_cuentas								 	= 0;
LET num_consultassic							= 0;
LET NumCuentaPagoMinimo 						= 0;

--parametros tdc visa Olivia
LET dSalariomin 			= 0;
LET dTasa_Ordinaria 		= 0; --
LET dTasa_Moratoria 		= 0; 
LET diva 					= 0;
LET dDiaspromedio 			= 0;
LET dTope_ingre 			= 0;
LET dcVeces_smb 			= 0;
LET dPorcpermitido 			= 0;
LET dMesespermitido 		= 0;
LET dMinimomesespermitido 	= 0;
LET cBRM_reing = 0;

------------------------

--DECLARACION DE VARIABLES DE ERROR
LET iSqlErr  = 0;
LET iIsamErr = 0;
LET cCodRet  ="000000";
LET cMensaje_ret        = '';
--LET cCodRetEstand = '000000';

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensaje_ret = iIsamErr;
            --INSERT INTO bdisolic:"informix".ax_paso values ("bdicred:sp_consultadatos_motor_web", cCodRet, CURRENT ||TRIM(cMensaje_ret)||'|'||TRIM(pNumSol));
			RETURN  NVL(cCodRet,000000), nvl(cSolBanco,''),	nvl(cNumCteBco,''),	nvl(cNumCte,''), nvl(pEmpresa,''), 
			nvl(cStatusSolicitud,''), NVL(cCausa_Sol,""), NVL(cNum_Producto,''), NVL(cTipoGrupo,''), NVL(cTp_solicitud,'?'),
			NVL(cB_INE,0), NVL(cHabita_en,'??'), nvl(cPuntualidadCoppel,''), NVL(cProfesion,''), NVL(iCredDigitalesAct,0),
			NVL(sId_actividad,0), nvl(cDescAct,''), NVL(sId_subactividad,0), nvl(vDescSubAct,''), NVL(cSituacionEspecial,"?"), 
			NVL(sCausaSituacion,-99), nvl(cMotivoRech,''), nvl(cMotivoRechBcpl,''), nvl(cTipoRech,''), nvl(cDescMvo,''), 
			nvl(mTotalVencido,0), nvl(mAbonoTotal,0), nvl(mAbonoVencidoTotal,0), nvl(sHist_meses,0), nvl(cCteExcep,''),
			nvl(iCtas_StatusCV,0), nvl(iMaxSalVencidoBancoppel,0), nvl(dEficienciaCoppel,0), nvl(iCred_StatusFC,0),
			nvl(iCred_StatusFF_restru,0), nvl(iCredits_riesgoD,0), nvl(iCredits_riesgoE,0), nvl(iCredits_riesgoC,0), 
			nvl(iMaxMontoReserva,0), nvl(iCred_StatusDif_FF,0), nvl(dMaxSalVencidoCRD,0), nvl(iCuentasStatusCVsinFF,0), 
			nvl(iCtas_StatusDif_FF_6011,0), nvl(iCredRiesgoD_sinFF,0), nvl(iCredRiesgoE_sinFF,0), nvl(iCredRiesgoC_sinFF,0), 
			nvl(dmaxMontoReservaRiesgoC_sinFF,0), NVL(dtMinFechaAperturasinFF,'01/01/1900'), NVL(dtMinFechaApertura,'01/01/1900'), 
			nvl(cSituacion,''), NVL(dtmaxFechaAperturaDelProducto,'01/01/1900'), NVL(cProducto,""), NVL(dminProcentajeProductoMasReciente,0),
			nvl(mAbonoMuebles,0), nvl(mAbonoPrestamos,0), nvl(mAbonoRopa,0),  nvl(mAbonoAire,0), nvl(mAbonoAfiliados,0),
			nvl(mAbonoReestructura,0), nvl(mVencidoMuebles,0), nvl(mVencidoRopa,0), Nvl(mVencidoPrestamos,0), nvl(mVencidoAire,0), 
			nvl(mVencidoAfiliados,0), nvl(mVencidoReestructura,0), nvl(cFechaUltimoPago,'1900-01-01'), nvl(iReprestamos,0),
			nvl(cOrigenSol,'1'), nvl(cDescripcion,''), NVL(cRiesgoViviendaCpl,""), NVL(cRiesgoViviendaBcpl,""), NVL(cActRiesgoCpl,''),
			nvl(cActRiesgoBCpl,''),	nvl(cDescpRiesgo,''), nvl(cEjecucion,'0'), nvl(iMax_MOP,'0'), Nvl(cInstCta_MayorMOP,''), 
			nvl(dMonto_UDIS_MayorMOP,0), nvl(iMax_MOP_Hist_6m,'0'), NVL(cInstCta_MayorMOP_6m,''), NVL(dMontoUDIS_MM_6m,0), 
			NVL(iMM_Histo_12m,'0'), nvl(cInstCta_MayorMOP_12m,''),  nvl(dMontoUDIS_MM_12m,0), nvl(iNumCtasMOP_4_12m,0),
			nvl(iNumCtasMOP_5_12m,0), nvl(iNumCtasMOP_mayor5_12m,0), nvl(iMOP4_12mCon1o2,0), nvl(iMOP5_12mCon1o2,0),
			nvl(iMOPmayor5_12mCon1o2,0), nvl(cInstitucionMMOP_provocaRech,''), nvl(dMontoUDIS_MM_Rech,0), nvl(iNumCtasMOP_4_30m,0),
			nvl(iNumCtasMOP_5_30m,0), nvl(iNumCtasMOP_mayor5_30m,0), nvl(iCtasMOP_4_30mCon1o2,0), nvl(iCtasMOP_5_30mCon1o2,0),
			nvl(iCtasMOP_mayor5_30mCon1o2,0), nvl(iMM_Histo_30m,'0'), nvl(cInstCta_MM_30m_Rech,''), nvl(dMotoUDIS_MM_30m_Rech,0), 
			nvl(iNumCtas_ClvOb,'0'), nvl(dMontoUdis,0), nvl(cInstitucion,''), nvl(cClvObser,'0'), nvl(sBc_Score,0), 
			nvl(vClvExclusionMasReciente,0), nvl(cInstitucionClvExclusionMasReciente,''), nvl(iCtas_SinComServ,0),
			nvl(iCtas_SinComServ_pagar,0), nvl(iNumCtas_SHBr,0), nvl(iNumCtas_SHBr_pagar,0), nvl(BC1,-1), nvl(BC_101,0), 
			nvl(iMM_act_Bancos,'0'), nvl(iMM_hist_alto_Bancos,'0'), nvl(iMM_hist_Bancos,'0'), nvl(BC_117,0), nvl(iCtasBancosMOP_tl26,0),
			nvl(iCtasBancosMOP_tl38,0), nvl(iCtasBancosMOP_tl27,0), nvl(iCtasBancosMOP_act_hist_alto,0), nvl(BC_119,0), 
			nvl(iCtasComServMOP_tl26,0), nvl(iCtasComServMOP_tl38,0), nvl(iCtasComServMOP_tl27,0), nvl(iCtasCSM_act_hist_alto,0),
			nvl(BC_20,0), nvl(iCtasComServMOP_tl26_12m,0), nvl(iCtasComServMOP_tl38_12m,0), nvl(iCtasComServMOP_tl27_12m,0), 
			nvl(iCtasCSM_ActHistAlto_12m,0), nvl(BC_421,0), nVL(dtFechaAux,'01/01/1900'), nvl(BC_85,'0'),	NVL(iMaxMOP_actBancos,'0'), 
			NVL(iMaxMOP_histAltBancos,'0'), nvl(iMaxMOP_histBancos,'0'), nvl(BC_93,'0'), nvl(iMaxMOP_actCtas,'0'), nvl(iMaxMOP_histAltCtas,'0'),
			nvl(iMaxMOP_histCtas,'0'), nvl(dSituacionPagoCoppel,'0.00'), nvl(mIngreso_Mensual,0), nvl(mPagoMinimo,0), nvl(sCteLargo8,0),
			nvl(iMeses_hist_Val,0), nvl(cTipo_Alta_CteProsp,''), nvl(mLinea_tienda,0), nvl(mImporte_hip,0), nvl(dTasa,0),
			nvl(sFlagHuella,'0'), nvl(cResultadoOsTel,''), nvl(cTieneOstel,''), nvl(cEnvioCat,''), nvl(iSolMc,0),
			nvl(iSolMcAux,0), nvl(cCod_Ult_Identif,0), NVL(cTelCasa,""), NVL(cTelTrabajo,''), NVL(sValida_Cel,'0'), 
			NVL(dtUltimaCompra,'01/01/1900'), nvl(iBanderareferencia,'0'), NVL(dtFechaCte,'01/01/1900'), NVL(cFolioMovil,""),
			NVL(cFlagGeoMov,""), nvl(iFlagGeoSuc,'0'), nvl(iCanal_Sol,'0'), nvl(cOrigenCte,''), nvl(sFlagForzarEnvioMC,'0'), 
			nvl(iSecuenciaOs,'0'), nvl(cStatusRespOs,''), NVL(dtFecha_Respuesta, 01/01/1900), nvl(cNumSol_Os,''), nvl(cCompIngresos,''),
			nvl(dIngresoCac,0), NVL(sCompValido, 0), nvl(cTipo_movimiento,''), NVL(cSucursal,''), NVL(cTipoSolOS,''),  
			NVL(dCompromisosCac,0), NVL(sFlag_oro,0), nvl(mIngreso_Neto,0), NVL(dtFechaNac,'01/01/1900'), NVL(cSexo,''),
			nvl(cEdo_Civil,''), nvl(iTiem_Edo_Civil,-99), nvl(HR0048,-1), nvl(UT0034,-999), nvl(cOcupacion,''),	nvl(iTiem_Ocupacion, -99), 
			nvl(cEscolaridad,''), nvl(cTipoResidencia,''), nvl(iTiem_Residencia, -99), NVL(vClvEdoCob,''), NVL(vLocalidad,''),
			NVL(cEntidad,''), NVL(sCteLargo,'0'), nvl(sScore_coppel,0), NVL(cCURP,''), NVL(iFlagEmpleado,'0'), NVL(dValor_3s,0),
			nvl(cStatusMovil,''), nvl(cCteProsp,''), nvl(cStatusSol_CteProsp,''), nvl(cRTipo3,''), NVL(cVigSolOS,''), nvl(sBuenPagos,''),
			nvl(dCompromisos,0), nvl(sFlagBuenPago12,'0'), NVL(sFlagBuenPago30,'0'), NVL(sEntidad_Localidad,'0'), nvl(cNuevoStatusOstel,''), 
			nvl(cCteProspVig,''), NVL(mCompro_banco,0), nvl(dComprobanco_TDC,0), NVL(mCompro_bancoPP,0), nvl(cGeoCte,''), nvl(iCanalV1,'99'), 
			nvl(HR0050,'-1'), nvl(TR0002,'-999'), nvl(TR0001,'-999'), nvl(IQ0002,'0'), NVL(iCtas_StatusFF_6011,0), NVL(dSaldo_linea_credi,'0.00'), 
			NVL(dSaldo_limit_credi,'0.00'), nvl(iTiem_Edo_Civil_meses, -99), nvl(dMontoOtorgado,0), nvl(mCapacidad_pago,0), 
			nvl(cVigenciaBancoppel,''), nvl(dLineaBanco,0), nvl(iExisteCliente,0), nvl(mSaldoRopa,0), nvl(mSaldoMuebles,0), 
			nvl(mSaldoPrestamos,0), nvl(mosSncOldestRevTLOpnd,-1), nvl(numInq0to2Mos,'0'), nvl(pctBankILTL,'0.00'), nvl(pctTL30pDaysEverColl,'0'), 
			nvl(avgMosInFileTLRptd0To2Mos,'0'), nvl(highestUtilOnBankNatlRevTL,-999), nvl(lowestRatingIL,'0'), nvl(lowestRatingRevOpen,'0'),
			nvl(maxDelq0To11Mos,'99'), nvl(mosSncOldestBankNatlRevOpenTLOpnd,'-1'), nvl(netFrctTLOpnd0To35Mos,'0'), nvl(totBalDelqTL,'0.00'), 
			nvl(numFinInq0to5Mos,'0'), nvl(maxDelqEver,'99'), nvl(pctInq0To2MosByInq0To11Mos,'0'), nvl(numRetTLOpnd0to5Mos,'0'),
			nvl(num_sumasaldoscuentasabiertas,'0.00'), nvl(num_sumalineascuentasabiertas,'0.00'), nvl(pct_usocuentasabiertas,0),
			nvl(num_antiguedadpromediocuentas12meses,0), nvl(num_consultasfinanciera,0), nvl(num_maxplazodias,-1), 
			nvl(clv_tipoproductocrediticio,''),	nvl(num_montofechamorosamasgravemasreciente,-1), nvl(num_totalperiodosreportados,0),
			nvl(num_porcentajecorrientepromedio,-1), nvl(num_lineacreditopromedio,-2), nvl(num_arrendamiento,0),
			nvl(num_tiendacomercial,0), nvl(clv_worstcurrentmop,-2), nvl(num_direcciones,0), nvl(num_montopeoratrasohistoricomasreciente,-1),
			nvl(num_mesespeoratrasohistoricomasreciente,-1), nvl(num_sumasaldoscuentasrevolventessintelcos,0), 	
			nvl(num_sumalineascuentasrevolventessintelcos,0), nvl(pct_usocuentasrevolventessintelcos,0),
			nvl(num_tarjetacredito,0), nvl(num_consultas90dias,0), nvl(num_cuentasMOP3,0), nvl(num_cuentas,0), nvl(num_consultassic,0), 
			nvl(vgrupoA,''), nvl(NumSolMovil,''), nvl(iFlag2credito,0), nvl(NumCuentaPagoMinimo,0),	NVL(dtFechaSolicitud, '01/01/1900'), 
			NVL(sEdadCte,0), nvl(pMeses_historia_grupo,0), nvl(pSituacion_pago_grupo,0), NVL(dSalariomin,0), NVL(dTasa_Ordinaria,0),
			NVL(dTasa_Moratoria,0), NVL(diva,0), NVL(dDiaspromedio,0), NVL(dTope_ingre,0), NVL(dcVeces_smb,0), NVL(dPorcpermitido,0),
			NVL(dMesespermitido,0), NVL(dMinimomesespermitido,0), NVL(cEstado,''), NVL(cMunicipio,''), NVL(cBRM_reing,0);
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
	
	
END
	---------------------------------------------------- VARIABLES DATOS DEL CLIENTE
	IF NVL(pEmpresa,'') = '' OR nvl(pNumSol,'') = '' THEN		
		LET cCodRet = '020202';
		--INSERT INTO bdisolic:"informix".ax_paso values ("bdicred:sp_consultadatos_motor_web", cCodRet, CURRENT ||TRIM(iSqlErr)||'|'||TRIM(pNumSol));
	ELSE
		EXECUTE procedure bdicred:sp_consultadatos_motor(pEmpresa, pNumSol)
		INTO  cCodRet,cSolBanco,cNumCteBco,cNumCte,pEmpresa, 
		cStatusSolicitud,cCausa_Sol, cNum_Producto,cTipoGrupo,cTp_solicitud,
		cB_INE,cHabita_en,cPuntualidadCoppel,cProfesion,iCredDigitalesAct,
		sId_actividad,cDescAct,sId_subactividad,vDescSubAct,cSituacionEspecial, 
		sCausaSituacion,cMotivoRech,cMotivoRechBcpl,cTipoRech,cDescMvo,
		mTotalVencido,mAbonoTotal,mAbonoVencidoTotal,sHist_meses,cCteExcep,
		iCtas_StatusCV,iMaxSalVencidoBancoppel,dEficienciaCoppel,iCred_StatusFC,
		iCred_StatusFF_restru,iCredits_riesgoD,iCredits_riesgoE,iCredits_riesgoC,
		iMaxMontoReserva,iCred_StatusDif_FF,dMaxSalVencidoCRD,iCuentasStatusCVsinFF,
		iCtas_StatusDif_FF_6011,iCredRiesgoD_sinFF,iCredRiesgoE_sinFF,iCredRiesgoC_sinFF,
		dmaxMontoReservaRiesgoC_sinFF,dtMinFechaAperturasinFF,dtMinFechaApertura,
		cSituacion,dtmaxFechaAperturaDelProducto,cProducto,dminProcentajeProductoMasReciente,
		mAbonoMuebles,mAbonoPrestamos,mAbonoRopa,mAbonoAire,mAbonoAfiliados,
		mAbonoReestructura,mVencidoMuebles,mVencidoRopa,mVencidoPrestamos,mVencidoAire,
		mVencidoAfiliados,mVencidoReestructura,cFechaUltimoPago,iReprestamos,
		cOrigenSol,cDescripcion,cRiesgoViviendaCpl,cRiesgoViviendaBcpl,cActRiesgoCpl,
		cActRiesgoBCpl,cDescpRiesgo,cEjecucion,iMax_MOP,cInstCta_MayorMOP,
		dMonto_UDIS_MayorMOP,iMax_MOP_Hist_6m,cInstCta_MayorMOP_6m,dMontoUDIS_MM_6m,
		iMM_Histo_12m,cInstCta_MayorMOP_12m,dMontoUDIS_MM_12m,iNumCtasMOP_4_12m,
		iNumCtasMOP_5_12m,iNumCtasMOP_mayor5_12m,iMOP4_12mCon1o2,iMOP5_12mCon1o2,
		iMOPmayor5_12mCon1o2,cInstitucionMMOP_provocaRech,dMontoUDIS_MM_Rech,iNumCtasMOP_4_30m,
		iNumCtasMOP_5_30m,iNumCtasMOP_mayor5_30m,iCtasMOP_4_30mCon1o2,iCtasMOP_5_30mCon1o2,
		iCtasMOP_mayor5_30mCon1o2,iMM_Histo_30m,cInstCta_MM_30m_Rech,dMotoUDIS_MM_30m_Rech,
		iNumCtas_ClvOb,dMontoUdis,cInstitucion,cClvObser,sBc_Score,
		vClvExclusionMasReciente,cInstitucionClvExclusionMasReciente,iCtas_SinComServ,
		iCtas_SinComServ_pagar,iNumCtas_SHBr,iNumCtas_SHBr_pagar,BC1,BC_101,
		iMM_act_Bancos,iMM_hist_alto_Bancos,iMM_hist_Bancos,BC_117,iCtasBancosMOP_tl26,
		iCtasBancosMOP_tl38,iCtasBancosMOP_tl27,iCtasBancosMOP_act_hist_alto,BC_119,
		iCtasComServMOP_tl26,iCtasComServMOP_tl38,iCtasComServMOP_tl27,iCtasCSM_act_hist_alto,
		BC_20,iCtasComServMOP_tl26_12m,iCtasComServMOP_tl38_12m,iCtasComServMOP_tl27_12m,
		iCtasCSM_ActHistAlto_12m,BC_421,dtFechaAux,BC_85,iMaxMOP_actBancos,
		iMaxMOP_histAltBancos,iMaxMOP_histBancos,BC_93,iMaxMOP_actCtas,iMaxMOP_histAltCtas,
		iMaxMOP_histCtas,dSituacionPagoCoppel,mIngreso_Mensual, mPagoMinimo,  sCteLargo8,
		iMeses_hist_Val,cTipo_Alta_CteProsp,mLinea_tienda,mImporte_hip,dTasa,
		sFlagHuella,cResultadoOsTel,cTieneOstel,cEnvioCat,iSolMc,
		iSolMcAux,cCod_Ult_Identif,cTelCasa,cTelTrabajo,sValida_Cel,
		dtUltimaCompra,iBanderareferencia,dtFechaCte,cFolioMovil,
		cFlagGeoMov,iFlagGeoSuc,iCanal_Sol,cOrigenCte,sFlagForzarEnvioMC,
		iSecuenciaOs,cStatusRespOs,dtFecha_Respuesta, cNumSol_Os,cCompIngresos,
		dIngresoCac,sCompValido,cTipo_movimiento,cSucursal,cTipoSolOS, 
		dCompromisosCac,sFlag_oro,mIngreso_Neto,dtFechaNac,cSexo,
		cEdo_Civil,iTiem_Edo_Civil,HR0048,UT0034,cOcupacion,iTiem_Ocupacion,
		cEscolaridad,cTipoResidencia,iTiem_Residencia,vClvEdoCob,vLocalidad,
		cEntidad,sCteLargo,sScore_coppel,cCURP,iFlagEmpleado,dValor_3s,
		cStatusMovil,cCteProsp,cStatusSol_CteProsp,cRTipo3,cVigSolOS,  sBuenPagos,
		dCompromisos,sFlagBuenPago12,sFlagBuenPago30,sEntidad_Localidad,cNuevoStatusOstel,
		cCteProspVig,mCompro_banco,dComprobanco_TDC,mCompro_bancoPP,cGeoCte,iCanalV1,
		HR0050,TR0002,TR0001, IQ0002,iCtas_StatusFF_6011,dSaldo_linea_credi,
		dSaldo_limit_credi,iTiem_Edo_Civil_meses,dMontoOtorgado,mCapacidad_pago,
		cVigenciaBancoppel,dLineaBanco,iExisteCliente,mSaldoRopa,mSaldoMuebles,
		mSaldoPrestamos,mosSncOldestRevTLOpnd,numInq0to2Mos,pctBankILTL,pctTL30pDaysEverColl,
		avgMosInFileTLRptd0To2Mos,highestUtilOnBankNatlRevTL,lowestRatingIL,lowestRatingRevOpen,
		maxDelq0To11Mos,mosSncOldestBankNatlRevOpenTLOpnd,netFrctTLOpnd0To35Mos,totBalDelqTL,
		numFinInq0to5Mos,maxDelqEver,pctInq0To2MosByInq0To11Mos,numRetTLOpnd0to5Mos,
		num_sumasaldoscuentasabiertas,num_sumalineascuentasabiertas,pct_usocuentasabiertas,
		num_antiguedadpromediocuentas12meses,num_consultasfinanciera,num_maxplazodias,
		clv_tipoproductocrediticio,num_montofechamorosamasgravemasreciente,num_totalperiodosreportados,
		num_porcentajecorrientepromedio,  num_lineacreditopromedio,num_arrendamiento,
		num_tiendacomercial,clv_worstcurrentmop,num_direcciones,num_montopeoratrasohistoricomasreciente,
		num_mesespeoratrasohistoricomasreciente,num_sumasaldoscuentasrevolventessintelcos,
		num_sumalineascuentasrevolventessintelcos,pct_usocuentasrevolventessintelcos,
		num_tarjetacredito,num_consultas90dias,num_cuentasMOP3,num_cuentas,num_consultassic,
		vgrupoA,NumSolMovil,iFlag2credito,NumCuentaPagoMinimo,dtFechaSolicitud,
		sEdadCte,pMeses_historia_grupo,pSituacion_pago_grupo,dSalariomin,dTasa_Ordinaria,
		dTasa_Moratoria,  diva,dDiaspromedio,dTope_ingre,dcVeces_smb,dPorcpermitido,
		dMesespermitido,  dMinimomesespermitido,cEstado,cMunicipio,cBRM_reing;

		IF cCodRet::INTEGER <> 0 THEN
			--INSERT INTO bdisolic:"informix".ax_paso values ("bdicred:sp_consultadatos_motor", cCodRet, CURRENT ||iSqlErr||'|'||TRIM(pNumSol));
				RETURN  NVL(cCodRet,000000), nvl(cSolBanco,''),	nvl(cNumCteBco,''),	nvl(cNumCte,''), nvl(pEmpresa,''), 
			nvl(cStatusSolicitud,''), NVL(cCausa_Sol,""), NVL(cNum_Producto,''), NVL(cTipoGrupo,''), NVL(cTp_solicitud,'?'),
			NVL(cB_INE,''), NVL(cHabita_en,'??'), nvl(cPuntualidadCoppel,''), NVL(cProfesion,''), NVL(iCredDigitalesAct,0),
			NVL(sId_actividad,0), nvl(cDescAct,''), NVL(sId_subactividad,0), nvl(vDescSubAct,''), NVL(cSituacionEspecial,"?"), 
			NVL(sCausaSituacion,-99), nvl(cMotivoRech,''), nvl(cMotivoRechBcpl,''), nvl(cTipoRech,''), nvl(cDescMvo,''), 
			nvl(mTotalVencido,0), nvl(mAbonoTotal,0), nvl(mAbonoVencidoTotal,0), nvl(sHist_meses,0), nvl(cCteExcep,''),
			nvl(iCtas_StatusCV,0), nvl(iMaxSalVencidoBancoppel,0), nvl(dEficienciaCoppel,0), nvl(iCred_StatusFC,0),
			nvl(iCred_StatusFF_restru,0), nvl(iCredits_riesgoD,0), nvl(iCredits_riesgoE,0), nvl(iCredits_riesgoC,0), 
			nvl(iMaxMontoReserva,0), nvl(iCred_StatusDif_FF,0), nvl(dMaxSalVencidoCRD,0), nvl(iCuentasStatusCVsinFF,0), 
			nvl(iCtas_StatusDif_FF_6011,0), nvl(iCredRiesgoD_sinFF,0), nvl(iCredRiesgoE_sinFF,0), nvl(iCredRiesgoC_sinFF,0), 
			nvl(dmaxMontoReservaRiesgoC_sinFF,0), NVL(dtMinFechaAperturasinFF,'01/01/1900'), NVL(dtMinFechaApertura,'01/01/1900'), 
			nvl(cSituacion,''), NVL(dtmaxFechaAperturaDelProducto,'01/01/1900'), NVL(cProducto,""), NVL(dminProcentajeProductoMasReciente,0),
			nvl(mAbonoMuebles,0), nvl(mAbonoPrestamos,0), nvl(mAbonoRopa,0),  nvl(mAbonoAire,0), nvl(mAbonoAfiliados,0),
			nvl(mAbonoReestructura,0), nvl(mVencidoMuebles,0), nvl(mVencidoRopa,0), Nvl(mVencidoPrestamos,0), nvl(mVencidoAire,0), 
			nvl(mVencidoAfiliados,0), nvl(mVencidoReestructura,0), nvl(cFechaUltimoPago,'1900-01-01'), nvl(iReprestamos,0),
			nvl(cOrigenSol,'1'), nvl(cDescripcion,''), NVL(cRiesgoViviendaCpl,""), NVL(cRiesgoViviendaBcpl,""), NVL(cActRiesgoCpl,''),
			nvl(cActRiesgoBCpl,''),	nvl(cDescpRiesgo,''), nvl(cEjecucion,'0'), nvl(iMax_MOP,'0'), Nvl(cInstCta_MayorMOP,''), 
			nvl(dMonto_UDIS_MayorMOP,0), nvl(iMax_MOP_Hist_6m,'0'), NVL(cInstCta_MayorMOP_6m,''), NVL(dMontoUDIS_MM_6m,0), 
			NVL(iMM_Histo_12m,'0'), nvl(cInstCta_MayorMOP_12m,''),  nvl(dMontoUDIS_MM_12m,0), nvl(iNumCtasMOP_4_12m,0),
			nvl(iNumCtasMOP_5_12m,0), nvl(iNumCtasMOP_mayor5_12m,0), nvl(iMOP4_12mCon1o2,0), nvl(iMOP5_12mCon1o2,0),
			nvl(iMOPmayor5_12mCon1o2,0), nvl(cInstitucionMMOP_provocaRech,''), nvl(dMontoUDIS_MM_Rech,0), nvl(iNumCtasMOP_4_30m,0),
			nvl(iNumCtasMOP_5_30m,0), nvl(iNumCtasMOP_mayor5_30m,0), nvl(iCtasMOP_4_30mCon1o2,0), nvl(iCtasMOP_5_30mCon1o2,0),
			nvl(iCtasMOP_mayor5_30mCon1o2,0), nvl(iMM_Histo_30m,'0'), nvl(cInstCta_MM_30m_Rech,''), nvl(dMotoUDIS_MM_30m_Rech,0), 
			nvl(iNumCtas_ClvOb,'0'), nvl(dMontoUdis,0), nvl(cInstitucion,''), nvl(cClvObser,'0'), nvl(sBc_Score,0), 
			nvl(vClvExclusionMasReciente,0), nvl(cInstitucionClvExclusionMasReciente,''), nvl(iCtas_SinComServ,0),
			nvl(iCtas_SinComServ_pagar,0), nvl(iNumCtas_SHBr,0), nvl(iNumCtas_SHBr_pagar,0), nvl(BC1,-1), nvl(BC_101,0), 
			nvl(iMM_act_Bancos,'0'), nvl(iMM_hist_alto_Bancos,'0'), nvl(iMM_hist_Bancos,'0'), nvl(BC_117,0), nvl(iCtasBancosMOP_tl26,0),
			nvl(iCtasBancosMOP_tl38,0), nvl(iCtasBancosMOP_tl27,0), nvl(iCtasBancosMOP_act_hist_alto,0), nvl(BC_119,0), 
			nvl(iCtasComServMOP_tl26,0), nvl(iCtasComServMOP_tl38,0), nvl(iCtasComServMOP_tl27,0), nvl(iCtasCSM_act_hist_alto,0),
			nvl(BC_20,0), nvl(iCtasComServMOP_tl26_12m,0), nvl(iCtasComServMOP_tl38_12m,0), nvl(iCtasComServMOP_tl27_12m,0), 
			nvl(iCtasCSM_ActHistAlto_12m,0), nvl(BC_421,0), nVL(dtFechaAux,'01/01/1900'), nvl(BC_85,'0'),	NVL(iMaxMOP_actBancos,'0'), 
			NVL(iMaxMOP_histAltBancos,'0'), nvl(iMaxMOP_histBancos,'0'), nvl(BC_93,'0'), nvl(iMaxMOP_actCtas,'0'), nvl(iMaxMOP_histAltCtas,'0'),
			nvl(iMaxMOP_histCtas,'0'), nvl(dSituacionPagoCoppel,'0.00'), nvl(mIngreso_Mensual,0), nvl(mPagoMinimo,0), nvl(sCteLargo8,0),
			nvl(iMeses_hist_Val,0), nvl(cTipo_Alta_CteProsp,''), nvl(mLinea_tienda,0), nvl(mImporte_hip,0), nvl(dTasa,0),
			nvl(sFlagHuella,'0'), nvl(cResultadoOsTel,''), nvl(cTieneOstel,''), nvl(cEnvioCat,''), nvl(iSolMc,0),
			nvl(iSolMcAux,0), nvl(cCod_Ult_Identif,0), NVL(cTelCasa,""), NVL(cTelTrabajo,''), NVL(sValida_Cel,'0'), 
			NVL(dtUltimaCompra,'01/01/1900'), nvl(iBanderareferencia,'0'), NVL(dtFechaCte,'01/01/1900'), NVL(cFolioMovil,""),
			NVL(cFlagGeoMov,""), nvl(iFlagGeoSuc,'0'), nvl(iCanal_Sol,'0'), nvl(cOrigenCte,''), nvl(sFlagForzarEnvioMC,'0'), 
			nvl(iSecuenciaOs,'0'), nvl(cStatusRespOs,''), NVL(dtFecha_Respuesta, 01/01/1900), nvl(cNumSol_Os,''), nvl(cCompIngresos,''),
			nvl(dIngresoCac,0), NVL(sCompValido, 0), nvl(cTipo_movimiento,''), NVL(cSucursal,''), NVL(cTipoSolOS,''),  
			NVL(dCompromisosCac,0), NVL(sFlag_oro,0), nvl(mIngreso_Neto,0), NVL(dtFechaNac,'01/01/1900'), NVL(cSexo,''),
			nvl(cEdo_Civil,''), nvl(iTiem_Edo_Civil,-99), nvl(HR0048,-1), nvl(UT0034,-999), nvl(cOcupacion,''),	nvl(iTiem_Ocupacion, -99), 
			nvl(cEscolaridad,''), nvl(cTipoResidencia,''), nvl(iTiem_Residencia, -99), NVL(vClvEdoCob,''), NVL(vLocalidad,''),
			NVL(cEntidad,''), NVL(sCteLargo,'0'), nvl(sScore_coppel,0), NVL(cCURP,''), NVL(iFlagEmpleado,'0'), NVL(dValor_3s,0),
			nvl(cStatusMovil,''), nvl(cCteProsp,''), nvl(cStatusSol_CteProsp,''), nvl(cRTipo3,''), NVL(cVigSolOS,''), nvl(sBuenPagos,''),
			nvl(dCompromisos,0), nvl(sFlagBuenPago12,'0'), NVL(sFlagBuenPago30,'0'), NVL(sEntidad_Localidad,'0'), nvl(cNuevoStatusOstel,''), 
			nvl(cCteProspVig,''), NVL(mCompro_banco,0), nvl(dComprobanco_TDC,0), NVL(mCompro_bancoPP,0), nvl(cGeoCte,''), nvl(iCanalV1,'99'), 
			nvl(HR0050,'-1'), nvl(TR0002,'-999'), nvl(TR0001,'-999'), nvl(IQ0002,'0'), NVL(iCtas_StatusFF_6011,0), NVL(dSaldo_linea_credi,'0.00'), 
			NVL(dSaldo_limit_credi,'0.00'), nvl(iTiem_Edo_Civil_meses, -99), nvl(dMontoOtorgado,0), nvl(mCapacidad_pago,0), 
			nvl(cVigenciaBancoppel,''), nvl(dLineaBanco,0), nvl(iExisteCliente,0), nvl(mSaldoRopa,0), nvl(mSaldoMuebles,0), 
			nvl(mSaldoPrestamos,0), nvl(mosSncOldestRevTLOpnd,-1), nvl(numInq0to2Mos,'0'), nvl(pctBankILTL,'0.00'), nvl(pctTL30pDaysEverColl,'0'), 
			nvl(avgMosInFileTLRptd0To2Mos,'0'), nvl(highestUtilOnBankNatlRevTL,-999), nvl(lowestRatingIL,'0'), nvl(lowestRatingRevOpen,'0'),
			nvl(maxDelq0To11Mos,'99'), nvl(mosSncOldestBankNatlRevOpenTLOpnd,'-1'), nvl(netFrctTLOpnd0To35Mos,'0'), nvl(totBalDelqTL,'0.00'), 
			nvl(numFinInq0to5Mos,'0'), nvl(maxDelqEver,'99'), nvl(pctInq0To2MosByInq0To11Mos,'0'), nvl(numRetTLOpnd0to5Mos,'0'),
			nvl(num_sumasaldoscuentasabiertas,'0.00'), nvl(num_sumalineascuentasabiertas,'0.00'), nvl(pct_usocuentasabiertas,0),
			nvl(num_antiguedadpromediocuentas12meses,0), nvl(num_consultasfinanciera,0), nvl(num_maxplazodias,-1), 
			nvl(clv_tipoproductocrediticio,''),	nvl(num_montofechamorosamasgravemasreciente,-1), nvl(num_totalperiodosreportados,0),
			nvl(num_porcentajecorrientepromedio,-1), nvl(num_lineacreditopromedio,-2), nvl(num_arrendamiento,0),
			nvl(num_tiendacomercial,0), nvl(clv_worstcurrentmop,-2), nvl(num_direcciones,0), nvl(num_montopeoratrasohistoricomasreciente,-1),
			nvl(num_mesespeoratrasohistoricomasreciente,-1), nvl(num_sumasaldoscuentasrevolventessintelcos,0), 	
			nvl(num_sumalineascuentasrevolventessintelcos,0), nvl(pct_usocuentasrevolventessintelcos,0),
			nvl(num_tarjetacredito,0), nvl(num_consultas90dias,0), nvl(num_cuentasMOP3,0), nvl(num_cuentas,0), nvl(num_consultassic,0), 
			nvl(vgrupoA,''), nvl(NumSolMovil,''), nvl(iFlag2credito,0), nvl(NumCuentaPagoMinimo,0),	NVL(dtFechaSolicitud, '01/01/1900'), 
			NVL(sEdadCte,0), nvl(pMeses_historia_grupo,0), nvl(pSituacion_pago_grupo,0), NVL(dSalariomin,0), NVL(dTasa_Ordinaria,0),
			NVL(dTasa_Moratoria,0), NVL(diva,0), NVL(dDiaspromedio,0), NVL(dTope_ingre,0), NVL(dcVeces_smb,0), NVL(dPorcpermitido,0),
			NVL(dMesespermitido,0), NVL(dMinimomesespermitido,0), NVL(cEstado,''), NVL(cMunicipio,''), NVL(cBRM_reing,0);
		ELSE
			LET totBalDelqTL = substr(totBalDelqTL,2);
			LET num_sumasaldoscuentasabiertas = substr(num_sumasaldoscuentasabiertas,2);
			LET num_sumalineascuentasabiertas = substr(num_sumalineascuentasabiertas,2);  
		END IF;
	END IF;

						
	RETURN  NVL(cCodRet,000000), nvl(cSolBanco,''),	nvl(cNumCteBco,''),	nvl(cNumCte,''), nvl(pEmpresa,''), 
			nvl(cStatusSolicitud,''), NVL(cCausa_Sol,""), NVL(cNum_Producto,''), NVL(cTipoGrupo,''), NVL(cTp_solicitud,'?'),
			NVL(cB_INE,''), NVL(cHabita_en,'??'), nvl(cPuntualidadCoppel,''), NVL(cProfesion,''), NVL(iCredDigitalesAct,0),
			NVL(sId_actividad,0), nvl(cDescAct,''), NVL(sId_subactividad,0), nvl(vDescSubAct,''), NVL(cSituacionEspecial,"?"), 
			NVL(sCausaSituacion,-99), nvl(cMotivoRech,''), nvl(cMotivoRechBcpl,''), nvl(cTipoRech,''), nvl(cDescMvo,''), 
			nvl(mTotalVencido,0), nvl(mAbonoTotal,0), nvl(mAbonoVencidoTotal,0), nvl(sHist_meses,0), nvl(cCteExcep,''),
			nvl(iCtas_StatusCV,0), nvl(iMaxSalVencidoBancoppel,0), nvl(dEficienciaCoppel,0), nvl(iCred_StatusFC,0),
			nvl(iCred_StatusFF_restru,0), nvl(iCredits_riesgoD,0), nvl(iCredits_riesgoE,0), nvl(iCredits_riesgoC,0), 
			nvl(iMaxMontoReserva,0), nvl(iCred_StatusDif_FF,0), nvl(dMaxSalVencidoCRD,0), nvl(iCuentasStatusCVsinFF,0), 
			nvl(iCtas_StatusDif_FF_6011,0), nvl(iCredRiesgoD_sinFF,0), nvl(iCredRiesgoE_sinFF,0), nvl(iCredRiesgoC_sinFF,0), 
			nvl(dmaxMontoReservaRiesgoC_sinFF,0), NVL(dtMinFechaAperturasinFF,'01/01/1900'), NVL(dtMinFechaApertura,'01/01/1900'), 
			nvl(cSituacion,''), NVL(dtmaxFechaAperturaDelProducto,'01/01/1900'), NVL(cProducto,""), NVL(dminProcentajeProductoMasReciente,0),
			nvl(mAbonoMuebles,0), nvl(mAbonoPrestamos,0), nvl(mAbonoRopa,0),  nvl(mAbonoAire,0), nvl(mAbonoAfiliados,0),
			nvl(mAbonoReestructura,0), nvl(mVencidoMuebles,0), nvl(mVencidoRopa,0), Nvl(mVencidoPrestamos,0), nvl(mVencidoAire,0), 
			nvl(mVencidoAfiliados,0), nvl(mVencidoReestructura,0), nvl(cFechaUltimoPago,'1900-01-01'), nvl(iReprestamos,0),
			nvl(cOrigenSol,'1'), nvl(cDescripcion,''), NVL(cRiesgoViviendaCpl,""), NVL(cRiesgoViviendaBcpl,""), NVL(cActRiesgoCpl,''),
			nvl(cActRiesgoBCpl,''),	nvl(cDescpRiesgo,''), nvl(cEjecucion,'0'), nvl(iMax_MOP,'0'), Nvl(cInstCta_MayorMOP,''), 
			nvl(dMonto_UDIS_MayorMOP,0), nvl(iMax_MOP_Hist_6m,'0'), NVL(cInstCta_MayorMOP_6m,''), NVL(dMontoUDIS_MM_6m,0), 
			NVL(iMM_Histo_12m,'0'), nvl(cInstCta_MayorMOP_12m,''),  nvl(dMontoUDIS_MM_12m,0), nvl(iNumCtasMOP_4_12m,0),
			nvl(iNumCtasMOP_5_12m,0), nvl(iNumCtasMOP_mayor5_12m,0), nvl(iMOP4_12mCon1o2,0), nvl(iMOP5_12mCon1o2,0),
			nvl(iMOPmayor5_12mCon1o2,0), nvl(cInstitucionMMOP_provocaRech,''), nvl(dMontoUDIS_MM_Rech,0), nvl(iNumCtasMOP_4_30m,0),
			nvl(iNumCtasMOP_5_30m,0), nvl(iNumCtasMOP_mayor5_30m,0), nvl(iCtasMOP_4_30mCon1o2,0), nvl(iCtasMOP_5_30mCon1o2,0),
			nvl(iCtasMOP_mayor5_30mCon1o2,0), nvl(iMM_Histo_30m,'0'), nvl(cInstCta_MM_30m_Rech,''), nvl(dMotoUDIS_MM_30m_Rech,0), 
			nvl(iNumCtas_ClvOb,'0'), nvl(dMontoUdis,0), nvl(cInstitucion,''), nvl(cClvObser,'0'), nvl(sBc_Score,0), 
			nvl(vClvExclusionMasReciente,0), nvl(cInstitucionClvExclusionMasReciente,''), nvl(iCtas_SinComServ,0),
			nvl(iCtas_SinComServ_pagar,0), nvl(iNumCtas_SHBr,0), nvl(iNumCtas_SHBr_pagar,0), nvl(BC1,-1), nvl(BC_101,0), 
			nvl(iMM_act_Bancos,'0'), nvl(iMM_hist_alto_Bancos,'0'), nvl(iMM_hist_Bancos,'0'), nvl(BC_117,0), nvl(iCtasBancosMOP_tl26,0),
			nvl(iCtasBancosMOP_tl38,0), nvl(iCtasBancosMOP_tl27,0), nvl(iCtasBancosMOP_act_hist_alto,0), nvl(BC_119,0), 
			nvl(iCtasComServMOP_tl26,0), nvl(iCtasComServMOP_tl38,0), nvl(iCtasComServMOP_tl27,0), nvl(iCtasCSM_act_hist_alto,0),
			nvl(BC_20,0), nvl(iCtasComServMOP_tl26_12m,0), nvl(iCtasComServMOP_tl38_12m,0), nvl(iCtasComServMOP_tl27_12m,0), 
			nvl(iCtasCSM_ActHistAlto_12m,0), nvl(BC_421,0), nVL(dtFechaAux,'01/01/1900'), nvl(BC_85,'0'),	NVL(iMaxMOP_actBancos,'0'), 
			NVL(iMaxMOP_histAltBancos,'0'), nvl(iMaxMOP_histBancos,'0'), nvl(BC_93,'0'), nvl(iMaxMOP_actCtas,'0'), nvl(iMaxMOP_histAltCtas,'0'),
			nvl(iMaxMOP_histCtas,'0'), nvl(dSituacionPagoCoppel,'0.00'), nvl(mIngreso_Mensual,0), nvl(mPagoMinimo,0), nvl(sCteLargo8,0),
			nvl(iMeses_hist_Val,0), nvl(cTipo_Alta_CteProsp,''), nvl(mLinea_tienda,0), nvl(mImporte_hip,0), nvl(dTasa,0),
			nvl(sFlagHuella,'0'), nvl(cResultadoOsTel,''), nvl(cTieneOstel,''), nvl(cEnvioCat,''), nvl(iSolMc,0),
			nvl(iSolMcAux,0), nvl(cCod_Ult_Identif,0), NVL(cTelCasa,""), NVL(cTelTrabajo,''), NVL(sValida_Cel,'0'), 
			NVL(dtUltimaCompra,'01/01/1900'), nvl(iBanderareferencia,'0'), NVL(dtFechaCte,'01/01/1900'), NVL(cFolioMovil,""),
			NVL(cFlagGeoMov,""), nvl(iFlagGeoSuc,'0'), nvl(iCanal_Sol,'0'), nvl(cOrigenCte,''), nvl(sFlagForzarEnvioMC,'0'), 
			nvl(iSecuenciaOs,'0'), nvl(cStatusRespOs,''), NVL(dtFecha_Respuesta, 01/01/1900), nvl(cNumSol_Os,''), nvl(cCompIngresos,''),
			nvl(dIngresoCac,0), NVL(sCompValido, 0), nvl(cTipo_movimiento,''), NVL(cSucursal,''), NVL(cTipoSolOS,''),  
			NVL(dCompromisosCac,0), NVL(sFlag_oro,0), nvl(mIngreso_Neto,0), NVL(dtFechaNac,'01/01/1900'), NVL(cSexo,''),
			nvl(cEdo_Civil,''), nvl(iTiem_Edo_Civil,-99), nvl(HR0048,-1), nvl(UT0034,-999), nvl(cOcupacion,''),	nvl(iTiem_Ocupacion, -99), 
			nvl(cEscolaridad,''), nvl(cTipoResidencia,''), nvl(iTiem_Residencia, -99), NVL(vClvEdoCob,''), NVL(vLocalidad,''),
			NVL(cEntidad,''), NVL(sCteLargo,'0'), nvl(sScore_coppel,0), NVL(cCURP,''), NVL(iFlagEmpleado,'0'), NVL(dValor_3s,0),
			nvl(cStatusMovil,''), nvl(cCteProsp,''), nvl(cStatusSol_CteProsp,''), nvl(cRTipo3,''), NVL(cVigSolOS,''), nvl(sBuenPagos,''),
			nvl(dCompromisos,0), nvl(sFlagBuenPago12,'0'), NVL(sFlagBuenPago30,'0'), NVL(sEntidad_Localidad,'0'), nvl(cNuevoStatusOstel,''), 
			nvl(cCteProspVig,''), NVL(mCompro_banco,0), nvl(dComprobanco_TDC,0), NVL(mCompro_bancoPP,0), nvl(cGeoCte,''), nvl(iCanalV1,'99'), 
			nvl(HR0050,'-1'), nvl(TR0002,'-999'), nvl(TR0001,'-999'), nvl(IQ0002,'0'), NVL(iCtas_StatusFF_6011,0), NVL(dSaldo_linea_credi,'0.00'), 
			NVL(dSaldo_limit_credi,'0.00'), nvl(iTiem_Edo_Civil_meses, -99), nvl(dMontoOtorgado,0), nvl(mCapacidad_pago,0), 
			nvl(cVigenciaBancoppel,''), nvl(dLineaBanco,0), nvl(iExisteCliente,0), nvl(mSaldoRopa,0), nvl(mSaldoMuebles,0), 
			nvl(mSaldoPrestamos,0), nvl(mosSncOldestRevTLOpnd,-1), nvl(numInq0to2Mos,'0'), nvl(pctBankILTL,'0.00'), nvl(pctTL30pDaysEverColl,'0'), 
			nvl(avgMosInFileTLRptd0To2Mos,'0'), nvl(highestUtilOnBankNatlRevTL,-999), nvl(lowestRatingIL,'0'), nvl(lowestRatingRevOpen,'0'),
			nvl(maxDelq0To11Mos,'99'), nvl(mosSncOldestBankNatlRevOpenTLOpnd,'-1'), nvl(netFrctTLOpnd0To35Mos,'0'), nvl(totBalDelqTL,'0.00'), 
			nvl(numFinInq0to5Mos,'0'), nvl(maxDelqEver,'99'), nvl(pctInq0To2MosByInq0To11Mos,'0'), nvl(numRetTLOpnd0to5Mos,'0'),
			nvl(num_sumasaldoscuentasabiertas,'0.00'), nvl(num_sumalineascuentasabiertas,'0.00'), nvl(pct_usocuentasabiertas,0),
			nvl(num_antiguedadpromediocuentas12meses,0), nvl(num_consultasfinanciera,0), nvl(num_maxplazodias,-1), 
			nvl(clv_tipoproductocrediticio,''),	nvl(num_montofechamorosamasgravemasreciente,-1), nvl(num_totalperiodosreportados,0),
			nvl(num_porcentajecorrientepromedio,-1), nvl(num_lineacreditopromedio,-2), nvl(num_arrendamiento,0),
			nvl(num_tiendacomercial,0), nvl(clv_worstcurrentmop,-2), nvl(num_direcciones,0), nvl(num_montopeoratrasohistoricomasreciente,-1),
			nvl(num_mesespeoratrasohistoricomasreciente,-1), nvl(num_sumasaldoscuentasrevolventessintelcos,0), 	
			nvl(num_sumalineascuentasrevolventessintelcos,0), nvl(pct_usocuentasrevolventessintelcos,0),
			nvl(num_tarjetacredito,0), nvl(num_consultas90dias,0), nvl(num_cuentasMOP3,0), nvl(num_cuentas,0), nvl(num_consultassic,0), 
			nvl(vgrupoA,''), nvl(NumSolMovil,''), nvl(iFlag2credito,0), nvl(NumCuentaPagoMinimo,0),	NVL(dtFechaSolicitud, '01/01/1900'), 
			NVL(sEdadCte,0), nvl(pMeses_historia_grupo,0), nvl(pSituacion_pago_grupo,0), NVL(dSalariomin,0), NVL(dTasa_Ordinaria,0),
			NVL(dTasa_Moratoria,0), NVL(diva,0), NVL(dDiaspromedio,0), NVL(dTope_ingre,0), NVL(dcVeces_smb,0), NVL(dPorcpermitido,0),
			NVL(dMesespermitido,0), NVL(dMinimomesespermitido,0), NVL(cEstado,''), NVL(cMunicipio,''), NVL(cBRM_reing,0);
	
END PROCEDURE
DOCUMENT 
'----------------------------------------------------------------------------',
'Descripcion : Se crea copia del sp para armado de variables necesarias para motor de evaluacion para consumo WEB',
'Modifico    : Vera Mariscal',
'Fecha       : 23/06/2023',
'BD          : BDICRED',
'----------------------------------------------------------------------------',
'FECHA: 12/09/2024',
'MODIFICACION:  Se cambia el valor del parametro iCanal_Sol para mandar el valor de mas de dos caracteres ',
'SOLICITO: Aracely Urena',
'AUTOR : Jesus Isaias Bueno Castro',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_registradatos_motor_web ( pEmpresa CHAR(4), pNumSol CHAR(20), pNumCteBco CHAR(20),cProducto CHAR(4),
                                                    cMensajeMotivoCC CHAR(100), cRespSic CHAR(1), dPago_minimo DECIMAL(14,2),
                                                    dMonto_Hipoteca MONEY, cTipo_sol CHAR(1), cNuevoStatus CHAR(2),
                                                    cCausaSolicitud CHAR(3), vMensajeStatus CHAR(80), vGrupoSol CHAR(1),
                                                    vValorCivil DECIMAL(18,2), dValorBC_1 DECIMAL(18,2), dValorBC_20 DECIMAL(18,2), dValorBC_93 DECIMAL(18,2), 
                                                    dValorMeses_hist DECIMAL(14,2), dValorSituacionPagoCpl DECIMAL(14,2),
                                                    dValorESTADO_CIVIL_VAR_INT DECIMAL(18,2), dValorMESES_CLIENTE DECIMAL(18,2), 
                                                    vgrupo_sol CHAR(01), vVar_Grupo_Sol CHAR(01), dValorHR0048 DECIMAL(18,2), dValorUT0034 DECIMAL(18,2), 
                                                    dValorvVI_Ocup_TmpOcup DECIMAL(14,2), dValorRAT_MONTO_OTORGADO_CP DECIMAL (18,4),
                                                    dMontoOtorgado DECIMAL(18,2), dValorIV_OCUP_ESCOL DECIMAL(18,2), 
                                                    dValor_IngresoMensual MONEY(14,2), dValorVI_Genero_Edad DECIMAL(14,2), 
                                                    dValorVI_Genero_Ocupacion DECIMAL(14,2), dValorVI_EdoCivil_Escolaridad DECIMAL(14,2),
                                                    dValorVI_Edad_Escolaridad DECIMAL(14,2), dValorVI_TpResid_TmpResid DECIMAL(14,2), 
                                                    dValorVI_Entidad_Localidad DECIMAL(14,2), dCapacidad_pago MONEY, v_lineaban DECIMAL(14,2), 
                                                    v_meses DECIMAL(18,2), cSituacionCredito CHAR(1), 
                                                    v_bs_score DECIMAL(14,2), v_valor_2s DECIMAL(14,2), v_valor_3s DECIMAL(14,2), 
                                                    v_linea_tienda MONEY(14,2), v_flujo_libre1 DECIMAL(14,2), v_flujo_libre2 DECIMAL(14,2), 
                                                    pSeccion CHAR(1),  sScore_coppel DECIMAL(14,2), cElementOs DECIMAL(14,2), dValorOs DECIMAL(14,2), 
                                                    v_ingreso CHAR(20), v_porcentaje_compromiso DECIMAL(14,2), v_capacidad MONEY(14,2), 
                                                    v_ingreso_ant MONEY(14,2), v_comprobancoPP DECIMAL(14,2), v_comprobancoTDC DECIMAL(14,2), 
                                                    v_compromisos_sic_lc MONEY(14,2), vcompromiso_coppel MONEY(14,2), v_comprobanco MONEY(14,2), 
                                                    dCompromisosTotal MONEY(14,2), dCRA DECIMAL(14,2), v_factor_vp DECIMAL(14,2), 
                                                    v_tasasiniva DECIMAL(9,6), v_tasa DECIMAL(9,6), v_tasaMens DECIMAL(9,6), v_min_flujo DECIMAL(14,2), 
                                                    v_tope_ingreso DECIMAL(14,2), v_lineasinTopes DECIMAL(14,2), v_limiteInf DECIMAL(14,2),
                                                    v_limiteSup DECIMAL(14,2), v_lineaAnt DECIMAL(14,2), dPorcIncr DECIMAL(14,2), dPorcDecr DECIMAL(14,2), 
                                                    dMontoIncr DECIMAL(14,2), dMontoDecr DECIMAL(14,2), v_linea MONEY(14,2), cBanderaRR CHAR(1), 
                                                    v_lineaRR DECIMAL(14,2), cRevisionMC CHAR(1), dPorHipo DECIMAL(14,2), dPorSic DECIMAL(14,2), 
                                                    dPorOtros DECIMAL(14,2), iIdRiesgo DECIMAL(18,2), iISM DECIMAL(14,2), vlMontoHipoteca_ant DECIMAL(14,2),
                                                    vlMontoHipoteca DECIMAL (14,2), dOtrosComp DECIMAL(14,2), v_score_prop DECIMAL(14,2),
                                                    v_salariomin DECIMAL(14,2), salariomindiaprom DECIMAL(18,2), dlinea_min_prod DECIMAL(18,2), 
                                                    suma_gastos DECIMAL(18,2), monto_solicitado DECIMAL(14,2), v_capacidad_pago MONEY(14,2), iMotivoOs DECIMAL(18,2), 
                                                    iBanderaFaltaOSTEL DECIMAL(18,2), cTipoMovto CHAR(1), v_hereda_status CHAR(2), iFlagForzarEnvioMC DECIMAL(14,2), 
                                                    dtFecha_Respuesta CHAR(10), cStatusRespOs CHAR(1), iSecuenciaOs DECIMAL(18,2), cStatusPr CHAR(2), 
                                                    ptipogrupoAux CHAR(1), ptipogrupo CHAR(2), cTieneOstel CHAR(1), cResultadoOsTel CHAR(1), 
                                                    bandera_grupo5 DECIMAL(18,2), cCanalv1 DECIMAL(18,2), cbanobligadosol DECIMAL(14,2), ccapturaobligsol DECIMAL(14,2), 
                                                    vdiastrans DECIMAL(18,2), cCteProsp CHAR(20), iBanderaProsNoTit DECIMAL(18,2), sBanAuto DECIMAL(14,2), Comprobante_Valido DECIMAL(18,2),
                                                    vflagoro DECIMAL(14,2), vAntiguedad CHAR(1), iMeses DECIMAL(18,2), cEdo_Civil CHAR(1), cTipo_movimiento CHAR(1),
                                                    cCompIngresos CHAR(1), dIngresoCac DECIMAL(14,2), iFlag2credito DECIMAL(14,2), 
                                                    v_compromisos_33 MONEY, v_monto_cap_pago CHAR(20), cSucursal CHAR(4), iProdMC DECIMAL(18,2),
                                                    iSolMc DECIMAL(18,2), iEnviarMC DECIMAL(18,2), cDiaVigencia CHAR(3), cStatusMovil CHAR(1), BC_1 DECIMAL(18,2),
                                                    BC_101 DECIMAL(18,2), BC_117 DECIMAL(18,2), BC_119 DECIMAL(18,2), BC_20 DECIMAL(18,2), BC_421 DECIMAL(14,2), BC_85 DECIMAL(18,2), BC_93 DECIMAL(18,2),
                                                    sHist_meses DECIMAL(14,2), dSituacionPagoCoppel DECIMAL(14,2), 
                                                    dSaldo_limit_credi DECIMAL(18,2), ESTADO_CIVIL_VAR_INT DECIMAL(18,2), iMeses_hist_Val DECIMAL(18,2), 
                                                    vVI_Ocup_TmpOcup DECIMAL(18,2), HR0048 DECIMAL(18,2), UT0034 DECIMAL(18,2), HR0050 DECIMAL(18,2), IV_TRD_OLDEST_AVERAGE_AGE DECIMAL(18,2),
                                                    RAT_MONTO_OTORGADO_CP DECIMAL (18,4), IQ0002 DECIMAL(18,2), IV_OCUP_ESCOL DECIMAL(18,2),
                                                    mIngreso_Mensual MONEY, VI_Genero_Ocupacion DECIMAL(14,2), VI_EdoCivil_Escolaridad DECIMAL(14,2),		
                                                    VI_Edad_Escolaridad DECIMAL(14,2), VI_TpResid_TmpResid DECIMAL(14,2), VI_Entidad_Localidad DECIMAL(14,2), 
                                                    VI_Genero_Edad DECIMAL(14,2), v_valor DECIMAL(14,2), iTotalParametrico DECIMAL(18,2), iFiltroParam DECIMAL(18,2),
                                                    vCompromisosCuenta DECIMAL(14,2), v_valor_4s DECIMAL(14,2), cStatusSolicitud CHAR(2),
                                                    cParametrico CHAR(1), v_comprobancoCRNOM DECIMAL(14,2), cNuevoStatusOstel CHAR(2), v_ingresomensual_lc CHAR(20),
													out_Tiempoedocivilmeses DECIMAL(18,2), out_Grupoant CHAR(1), out_Banderaidentificaciones CHAR(1),
                                                    out_Piloto CHAR(1), out_Generaos CHAR(1),  out_Validaos CHAR(1), out_Antiguedad CHAR(1), out_Banderatel DECIMAL(18,2),
                                                    out_Banderareferencia DECIMAL(18,2), out_Banderas DECIMAL(18,2),  out_Vriesgo DECIMAL(14,2), out_Excluyeos CHAR(1), out_Vpaso CHAR(1),
                                                    out_Grupo_localidad CHAR(3), out_Tasaordinaria DECIMAL(9,6), out_Tasamoratoria DECIMAL(9,6), out_Iva DECIMAL(14,3),
                                                    out_Ism DECIMAL(14,2), out_Topemax DECIMAL(14,2), out_Cta DECIMAL(14,2), out_Plazo DECIMAL(18,2), out_Puntos_grupo_originacion DECIMAL(18,2),
                                                    out_Puntosedad DECIMAL(18,2), out_Puntosgenero DECIMAL(18,2), out_Causasol CHAR(3), out_Origen1 CHAR(20), out_Origen2 CHAR(20), 
                                                    out_Origen3 CHAR(20), out_Origen4 CHAR(20), out_Origen5 CHAR(20), out_Origen6 DECIMAL(18,2), out_Origen7 DECIMAL(18,2),  
                                                    out_Origen8 DECIMAL(18,2), out_Origen9 DECIMAL(18,2), out_Origen10 DECIMAL(18,2), out_Elemedocivil_tmpoedocivil DECIMAL(18,2),
                                                    out_Lineatienda MONEY(14,2), out_SCod_Ret CHAR(5),cHit2 CHAR(1), dPuntos_edo_municipio DECIMAL(9,2), dPuntostporesidencia DECIMAL(9,2),
													dPuntosusoctasabiertas DECIMAL(9,2), dPuntosantigprom12m DECIMAL(9,2), dPuntosconsultasfin DECIMAL(9,2), dPuntos_tipoprod_maxplazo DECIMAL(9,2), 
													dPuntosmontofechamoromasgravemasrec DECIMAL(9,2), dPuntos_porccorrprom_totperiodrepor DECIMAL(9,2), dPuntoslineacredprom DECIMAL(9,2), 
													dPuntos_arrendam_tndacomerc DECIMAL(9,2), dPuntospeortmopactual DECIMAL(9,2), dPuntosdirecciones DECIMAL(9,2), 
													dPuntos_meses_monto_peoratrshistmasrec DECIMAL(9,2), dPuntostarjetascredito DECIMAL(9,2), dPuntosconsultas90dias DECIMAL(9,2),
													dPuntosmaxutilizctasabiertasrevolv DECIMAL(9,2), dPuntosctasmop3 DECIMAL(9,2), dPuntoscuentas DECIMAL(9,2), 
													dPuntosconsultassic DECIMAL(9,2), dPuntosporcusorevolv DECIMAL(9,2), cReing1 CHAR(20), cReing2 CHAR(20), cReing3 CHAR(20), cReing4 CHAR(20), 
													iReing5 DECIMAL(18,2), iReing6 DECIMAL(18,2), iReing7 DECIMAL(18,2), iReing8 DECIMAL(18,2)
                                                    )
	RETURNING
	CHAR(6) 	   as cCodRet;

--DEFINICION DE VARIABLES DE ERROR
DEFINE iSqlErr        INTEGER;
DEFINE iIsamErr       INTEGER;
DEFINE cCodRet         CHAR(6);
DEFINE cMensaje_ret    VARCHAR(100,1);
 
 --VARIABLES DE ERROR
LET iSqlErr  = 0;
LET iIsamErr = 0;
LET cCodRet  ="000000";
LET cMensaje_ret        = '';


BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
            LET cMensaje_ret = iIsamErr;
            INSERT INTO bdisolic:"informix".ax_paso values ("bdicred:sp_registradatos_motor_web", cCodRet, CURRENT ||TRIM(cMensaje_ret)||'|'||TRIM(pNumSol));
			RETURN  cCodRet;
        END IF;
	END EXCEPTION;

    --SET debug file to '/informix/VeraMariscal/sp_registradatos_motor_web.out';
    --TRACE ON;
    
	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;        

        EXECUTE procedure bdicred:sp_registradatos_motor(pEmpresa , pNumSol , pNumCteBco ,cProducto ,
                            cMensajeMotivoCC  , cRespSic  , dPago_minimo  ,
                            dMonto_Hipoteca  , cTipo_sol  , cNuevoStatus  ,
                            cCausaSolicitud , vMensajeStatus  , vGrupoSol  ,
                            vValorCivil::INTEGER  , dValorBC_1::INTEGER  , dValorBC_20::INTEGER  , dValorBC_93::INTEGER  , 
                            dValorMeses_hist::DECIMAL(5,2)  , dValorSituacionPagoCpl::DECIMAL(5,2)  ,
                            dValorESTADO_CIVIL_VAR_INT  , dValorMESES_CLIENTE  , 
                            vgrupo_sol  , vVar_Grupo_Sol  , dValorHR0048::INTEGER  , dValorUT0034::INTEGER  , 
                            dValorvVI_Ocup_TmpOcup::SMALLINT  , dValorRAT_MONTO_OTORGADO_CP  ,
                            dMontoOtorgado  , dValorIV_OCUP_ESCOL::INTEGER  , 
                            dValor_IngresoMensual::MONEY  , dValorVI_Genero_Edad::SMALLINT  , 
                            dValorVI_Genero_Ocupacion::SMALLINT  , dValorVI_EdoCivil_Escolaridad::SMALLINT  ,
                            dValorVI_Edad_Escolaridad::SMALLINT  , dValorVI_TpResid_TmpResid::SMALLINT  , 
                            dValorVI_Entidad_Localidad::SMALLINT  , dCapacidad_pago  , v_lineaban  , 
                            v_meses  , cSituacionCredito  , 
                            v_bs_score  , v_valor_2s  , v_valor_3s  , 
                            v_linea_tienda   , v_flujo_libre1  , v_flujo_libre2  , 
                            pSeccion  ,  sScore_coppel::SMALLINT  , cElementOs::SMALLINT  , dValorOs::DECIMAL(10,4)  , 
                            v_ingreso  , v_porcentaje_compromiso::SMALLINT  , v_capacidad   , 
                            v_ingreso_ant   , v_comprobancoPP  , v_comprobancoTDC  , 
                            v_compromisos_sic_lc   , vcompromiso_coppel::MONEY  , v_comprobanco::MONEY  , 
                            dCompromisosTotal   , dCRA  , v_factor_vp::DECIMAL(21,10)  , 
                            v_tasasiniva  , v_tasa  , v_tasaMens  , v_min_flujo  , 
                            v_tope_ingreso  , v_lineasinTopes  , v_limiteInf  ,
                            v_limiteSup  , v_lineaAnt  , dPorcIncr  , dPorcDecr  , 
                            dMontoIncr  , dMontoDecr  , v_linea   , cBanderaRR  , 
                            v_lineaRR  , cRevisionMC  , dPorHipo  , dPorSic  , 
                            dPorOtros  , iIdRiesgo::INTEGER  , iISM  , vlMontoHipoteca_ant  ,
                            vlMontoHipoteca    , dOtrosComp  , v_score_prop  ,
                            v_salariomin  , salariomindiaprom::INTEGER  , dlinea_min_prod  , 
                            suma_gastos::INTEGER  , monto_solicitado::DECIMAL(14,2)  , v_capacidad_pago   , iMotivoOs::INTEGER  , 
                            iBanderaFaltaOSTEL::INTEGER  , cTipoMovto  , v_hereda_status  , iFlagForzarEnvioMC::SMALLINT  , 
                            dtFecha_Respuesta,   cStatusRespOs  , iSecuenciaOs::INTEGER  , cStatusPr  , 
                            ptipogrupoAux  , ptipogrupo  , cTieneOstel  , cResultadoOsTel  , 
                            bandera_grupo5::INTEGER  , cCanalv1::INTEGER  , cbanobligadosol::SMALLINT  , ccapturaobligsol::SMALLINT  , 
                            vdiastrans::INTEGER  , cCteProsp  , iBanderaProsNoTit::INTEGER  , sBanAuto::SMALLINT  , Comprobante_Valido::INTEGER  ,
                            vflagoro::SMALLINT  , vAntiguedad  , iMeses::INTEGER  , cEdo_Civil  , cTipo_movimiento  ,
                            cCompIngresos  , dIngresoCac  , iFlag2credito::SMALLINT  , 
                            v_compromisos_33  , v_monto_cap_pago  , cSucursal , iProdMC::INTEGER  ,
                            iSolMc::INTEGER  , iEnviarMC::INTEGER  , cDiaVigencia , cStatusMovil  , BC_1::INTEGER  ,
                            BC_101::INTEGER  , BC_117::INTEGER  , BC_119::INTEGER  , BC_20::INTEGER  , BC_421  , BC_85::INTEGER  , BC_93::INTEGER  ,
                            sHist_meses::SMALLINT  , dSituacionPagoCoppel::DECIMAL(5,2)  , 
                            dSaldo_limit_credi  , ESTADO_CIVIL_VAR_INT  , iMeses_hist_Val::INTEGER  , 
                            vVI_Ocup_TmpOcup::SMALLINT  , HR0048::INTEGER  , UT0034::INTEGER  , HR0050::INTEGER  , IV_TRD_OLDEST_AVERAGE_AGE::INTEGER  ,
                            RAT_MONTO_OTORGADO_CP  , IQ0002::INTEGER  , IV_OCUP_ESCOL::INTEGER  ,
                            mIngreso_Mensual  , VI_Genero_Ocupacion::SMALLINT  , VI_EdoCivil_Escolaridad::SMALLINT  ,		
                            VI_Edad_Escolaridad::SMALLINT  , VI_TpResid_TmpResid::SMALLINT  , VI_Entidad_Localidad::SMALLINT  , 
                            VI_Genero_Edad::SMALLINT  , v_valor  , iTotalParametrico::INTEGER  , iFiltroParam::INTEGER  ,
                            vCompromisosCuenta  , v_valor_4s  , cStatusSolicitud  ,
                            cParametrico  , v_comprobancoCRNOM  , cNuevoStatusOstel  , v_ingresomensual_lc  ,
                            out_Tiempoedocivilmeses::INTEGER  , out_Grupoant  , out_Banderaidentificaciones  ,
                            out_Piloto  , out_Generaos  ,  out_Validaos  , out_Antiguedad  , out_Banderatel::INTEGER  ,
                            out_Banderareferencia::INTEGER  , out_Banderas::INTEGER  ,  out_Vriesgo::SMALLINT  , out_Excluyeos  , out_Vpaso  ,
                            out_Grupo_localidad , out_Tasaordinaria  , out_Tasamoratoria  , out_Iva::DECIMAL(5,3)   ,
                            out_Ism  , out_Topemax  , out_Cta  , out_Plazo::INTEGER  , out_Puntos_grupo_originacion::INTEGER ,
                            out_Puntosedad::INTEGER  , out_Puntosgenero::INTEGER  , out_Causasol , out_Origen1  , out_Origen2  , 
                            out_Origen3  , out_Origen4  , out_Origen5  , out_Origen6::INTEGER  , out_Origen7::INTEGER  ,  
                            out_Origen8::INTEGER  , out_Origen9::INTEGER  , out_Origen10::INTEGER  , out_Elemedocivil_tmpoedocivil  ,
                            out_Lineatienda   , out_SCod_Ret ,cHit2  , dPuntos_edo_municipio   , dPuntostporesidencia   ,
                            dPuntosusoctasabiertas   , dPuntosantigprom12m   , dPuntosconsultasfin   , dPuntos_tipoprod_maxplazo   , 
                            dPuntosmontofechamoromasgravemasrec   , dPuntos_porccorrprom_totperiodrepor   , dPuntoslineacredprom   , 
                            dPuntos_arrendam_tndacomerc   , dPuntospeortmopactual   , dPuntosdirecciones   , 
                            dPuntos_meses_monto_peoratrshistmasrec   , dPuntostarjetascredito   , dPuntosconsultas90dias   ,
                            dPuntosmaxutilizctasabiertasrevolv   , dPuntosctasmop3   , dPuntoscuentas   , 
                            dPuntosconsultassic   , dPuntosporcusorevolv   , cReing1  , cReing2  , cReing3  , cReing4  , 
                            iReing5::INTEGER  , iReing6::INTEGER  , iReing7::INTEGER  , iReing8::INTEGER  )
		INTO cCodRet;
		
		IF cNuevoStatus = 'MC' AND cCanalv1 <> 4 THEN
			--Validar el estatus de la solicitud sea MC (insertarlo en la ss_solicitudes_mc) 
			INSERT INTO bdisolic:"informix".ss_solicitudes_mc (empresa,num_solicitud,numcte,sucursal,num_producto,monto_solicitado,status_ini,status_fin,ejecutivo_atiende,ejecutivo_autoriza,observaciones,fecha_insert,hora_insert,fecha_determinacion,revisado,motivo_os,ostel,tipo_alta,status_hereda,prioridad)																																										  
			VALUES (pEmpresa,pNumSol,pNumCteBco,cSucursal,cProducto, '', cNuevoStatus,'','','','Cliente Nuevo',CURRENT,CURRENT,CURRENT,'N',out_Origen1,iBanderaFaltaOSTEL,cTipoMovto,v_hereda_status,iFlagForzarEnvioMC);
		END IF;
		
        IF cCodRet::INTEGER <> 0 THEN
            INSERT INTO bdisolic:"informix".ax_paso values ("bdicred:sp_registradatos_motor", iSqlErr, CURRENT ||cCodRet||'|'||TRIM(pNumSol));
			IF cCodRet::INTEGER = -1226 THEN
				LET cCodRet = '000001';
			ELIF cCodRet::INTEGER = -1207 THEN
				LET cCodRet = '000002';
			ELIF cCodRet::INTEGER = -243 THEN
				LET cCodRet = '000003';
			END IF;
        END IF;

        RETURN  cCodRet;
END

END PROCEDURE
DOCUMENT 
'----------------------------------------------------------------------------',
'Descripcion : Se crea sp para ejecucion de sp_registradatos_motor para consumo por canal web',
'Modifico    : Vera Mariscal',
'Fecha       : 27-06-2023',
'BD          : BDICRED';

CREATE PROCEDURE "informix".sp_consulta_pre_aprobado_listanegra(pNumCte CHAR(9),gen1 CHAR(20), gen2 CHAR(20))
RETURNING   CHAR (5) AS codRet,
            CHAR(40) AS mensaje;

	
	--VALORES DE RETORNO
	DEFINE iSqlErr INTEGER;
	DEFINE vCodRet CHAR (5);
    DEFINE vMensaje CHAR (40);

	--VARIABLES PARA DATOS
	DEFINE vCod_error CHAR (10);
	DEFINE vNombre_comp CHAR (100);
	DEFINE vNum_cte CHAR(9);
	DEFINE vRfc CHAR(13);
	DEFINE vfechaNac DATE;
    DEFINE vNombre1 CHAR (30);
	DEFINE vNombre2 CHAR (30);
	DEFINE vApellidoP CHAR (30);
	DEFINE vApellidoM CHAR (30);
    DEFINE vNum_cta CHAR (15);
    DEFINE vNum_tarj CHAR (20);
    DEFINE vTipo CHAR(5);
	
	
	--EXPRECIONES EXTRAS
	DEFINE vE1 CHAR(20);
	DEFINE vE2 CHAR(20);
	DEFINE vSit1 CHAR(5);
	DEFINE vSit2 CHAR(5);
	DEFINE vMen1 CHAR(25);
	DEFINE vResp CHAR(40);

	DEFINE vSucursal CHAR(20);
	DEFINE vUser CHAR(20);
	
	
	
	
	--DEFINICIONES
    LET vCodRet ='00000';
    LET vMensaje ='CONSULTA EXITOSA';
	LET iSqlErr ='0';
	
	--DEFINICIONES
	LET vCod_error = '';
	LET vNombre_comp = '';
	LET vNum_cte = '';
	LET vRfc = '';
	LET vNombre1 = '';
    LET vNombre2 = '';
    LET vApellidoP = '';
    LET vApellidoM = '';
	LET vNum_cta = '';
    LET vNum_tarj = '';
    LET vTipo = '';
	
	--EXPRECIONES EXTRAS
	LET vE1 = '';
	LET vE2 = '';
	LET vSit1 = '';
	LET vSit2 = '';
	LET vMen1 = '';
	LET vResp = '';
	
	LET vSucursal = gen1;
	LET vUser = 'sys_cred';
	--Ejemplo de ejecucion.
	--EXECUTE PROCEDURE bdicred:"informix".sp_consulta_pre_aprobado_listanegra ('005048221','0318','');

   BEGIN
	  ON EXCEPTION SET iSqlErr
	  	IF iSqlErr <> 0 THEN
              LET vCodRet=iSqlErr;
              LET vMensaje='ERROR AL CONSULTAR CLIENTE';
	  		RETURN vCodRet, vMensaje;
	  	END IF;
	  END EXCEPTION;
	  
	  
	  
	  ---VALIDA LA EXISTENCIA DEL CLIENTE EN LA BDINTEG si_cliente y si_ctepf.
	  FOREACH EXECUTE PROCEDURE bdinteg:"informix".sp_consclientenumcte('001',pNumCte,'','','','','','','','','','',1,0)
	          INTO vCod_error,vNombre_comp,vNum_cte,vRfc,vfechaNac,vNombre1,vNombre2,vApellidoP,vApellidoM,vNum_cta,vNum_tarj,vTipo  
			  LET vNombre_comp = TRIM(vNombre_comp);
	          IF vNombre_comp = '' THEN
	              LET vCodRet='00001';
                  LET vMensaje='CLIENTE NO ENCONTRADO';
	          	RETURN vCodRet, vMensaje;
	          END IF;
	  END FOREACH;
	  
	  
	  --VALIDA LA EXISTENCIA DEL CLIENTE EN LISTA NEGRA, SI REGRESA UN ERROR 00002 EL CLIENTE ESTA EN LA LISTA NEGRA.
	  FOREACH EXECUTE PROCEDURE bdiauditor:"informix".sp_busqueda_cte_listanegra (vNombre1,vNombre2,vApellidoP,vApellidoM,vfechaNac,vSucursal,vUser)
	          INTO vCod_error
			  LET vCod_error = TRIM(vCod_error);
	          IF vCod_error <> '000000' THEN
	              LET vCodRet='00002';
                  LET vMensaje='CLIENTE EN LISTA NEGRA';
	          	RETURN vCodRet, vMensaje;
	          END IF;
	  END FOREACH;
	  
	  /* --VALIDA EL ESTATUS DEL CLIENTE EN LA TABLA DE SITUACIONES ESPECIALES, SU SITUACION Y SU CAUSA.
	  FOREACH EXECUTE PROCEDURE bdisitesp:"informix".sp_consultaclienteseindividual('001',pNumCte,1)
			  INTO vCod_error,vE1,vE2,vSit1,vSit2,vMen1,vfechaNac
			  
			  LET vSit1 = TRIM(vSit1);
			  LET vSit2 = TRIM(vSit2);
			  LET vMen1 = TRIM(vMen1);
			  
			  --VALIDA LA SITUACION DIFERENTE A U65 Y P23.
			  LET vResp = TRIM(vSit1)|| TRIM(vSit2);
			  IF vResp NOT IN ('U65', 'P23', '0')  THEN
	              LET vCodRet = '00003';
				  LET vMensaje = TRIM(vMen1)||' '||TRIM(vSit1)||TRIM(vSit2);
				  RETURN vCodRet, vMensaje;
	          END IF;
	  
	  END FOREACH; */
	  
	  RETURN vCodRet, vMensaje;                                                                            
	
   END;                                                                                         
END PROCEDURE
DOCUMENT
'AUTOR : JORGE MIGUEL REYES REYES',
'DESCRIPCION: SP CONSULTA EL ESTATUS DEL CLIENTE EN LISTA NEGRA Y CASOS ESPECIALES',
'FOLIO: ONECLICK PREAPROBADOS DESARROLLO WEB',
'FECHA : 04/OCT/2022',
'VERSION: 1.2.3',
'BD: bdicred',
'------------------------------------------------------------------------------------',
'AUTOR : Angel De Jesus Anguiano Camacho',
'DESCRIPCION: Se modifica validacion para ofertar situacion especial P23',
'FOLIO: ONECLICK PREAPROBADOS DESARROLLO WEB',
'FECHA : 17/ABR/2024',
'VERSION: 1.2.4',
'BD: bdicred',
'------------------------------------------------------------------------------------',
'AUTOR : Fernando Rodelo Barron',
'DESCRIPCION: Se modifica para quitar la validacion de situacion especial',
'FOLIO : ONECLICK PREAPROBADOS DESARROLLO WEB',
'FECHA : 12/NOV/2024',
'VERSION : 1.2.5',
'BD : bdicred',
'------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_clona_tdc_upgrade_web(pEmpresa CHAR(3),P_EJECUTIVO CHAR(10) , pProducto CHAR(4), pCredito CHAR(20) ,pTarjeta CHAR(20),pTarjetaOro CHAR(20))
RETURNING CHAR(5)         AS codigo_retorno,
          VARCHAR(100,1)  AS mensaje_retorno;

DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(5);
DEFINE cCodRetTDif	 CHAR(6);		-- CODIGO DE RETORNO OBTIENE TASAS DE INTERES DIFERENCIADAS
DEFINE cMensajeRet   VARCHAR(100,1);
DEFINE vCodRet 		 CHAR(5);
DEFINE vMsjRetorno   VARCHAR(100,1);
DEFINE scod_ret		 CHAR(6);
DEFINE cod_ret       CHAR(3);
DEFINE cSolOro       CHAR(20);
DEFINE cEmpresa      CHAR(3);
DEFINE cNumProducto  CHAR(4);
DEFINE cNomProducto  VARCHAR(100,1);
DEFINE CstatusSol    CHAR(2);
DEFINE CstatusSolANT CHAR(2);
-- DEFINICION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO. SP_CONSULTA_SALDOS_GENERAL
DEFINE cCodRetCSG			CHAR(6);
DEFINE cMsjRetCSG			CHAR(80);
DEFINE cNumCreditoCSG		CHAR(20);
DEFINE cCodTCredCSG			CHAR(2);
DEFINE dFechaOrigCSG		DATE;
DEFINE dFechaProxPagCSG 	DATE;
DEFINE dcPagoMinCSG			DECIMAL(18,2);
DEFINE dFechaUltPagCSG		DATE;
DEFINE iPlazoCSG			INTEGER;
DEFINE iPagRealizadosCSG	INTEGER;
DEFINE dcLinOtorgadaCSG		DECIMAL(18,2);
DEFINE dcTasaInteresCSG		DECIMAL(9,6);
DEFINE dcTasaMoratoriosCSG 	DECIMAL(9,6);
DEFINE dcMontoSbsCSG		DECIMAL(14,2);
DEFINE dcCapVigCSG			DECIMAL(18,2);
DEFINE dcCapTransCSG		DECIMAL(18,2);
DEFINE dcCapVdoExigCSG		DECIMAL(18,2);
DEFINE dcCapVdoNoExigCSG	DECIMAL(18,2);
DEFINE dcSdoActTotCapCSG	DECIMAL(18,2);
DEFINE dcIntVigCSG			DECIMAL(18,2);
DEFINE dcIntVdoCSG			DECIMAL(18,2);
DEFINE dcIntMoratorioCSG	DECIMAL(18,2);
DEFINE dcIntMesCSG			DECIMAL(18,2);
DEFINE dcSodActTotIntCSG	DECIMAL(18,2);
DEFINE dcIvaIntVigCSG		DECIMAL(18,2);
DEFINE dcIvaIntVdoCSG		DECIMAL(18,2);
DEFINE dcIvaIntMorCSG		DECIMAL(18,2);
DEFINE dcIvaIntMesCSG		DECIMAL(18,2);
DEFINE dcSdoActTotIvaCSG	DECIMAL(18,2);
DEFINE dcComPendCSG			DECIMAL(18,2);
DEFINE dcIvaComCSG			DECIMAL(18,2);
DEFINE dcSdoRetenidoCSG		DECIMAL(18,2);
DEFINE dcTotalLiqCSG		DECIMAL(18,2);
DEFINE dcIntDevengadoCSG	DECIMAL(18,2);
DEFINE dcIvaIntDevengadoCSG	DECIMAL(18,2);
DEFINE dcLinDispCSG			DECIMAL(18,2);
DEFINE dcPagosVdosCSG		DECIMAL(18,2);
DEFINE cDescStatusCredCSG	CHAR(60);
DEFINE iIdBloqueoCredCSG	INTEGER;
DEFINE cBloqCtaCSG			CHAR(60);
DEFINE cIdCausaBloqCredCSG	CHAR(3);
DEFINE cCausaBloqCtaCSG		CHAR(50);
DEFINE cIdSitEspCteCSG		CHAR(1);
DEFINE iIdCausaEspCteCSG	INTEGER;
DEFINE cSitEspCteCSG		CHAR(75);
DEFINE cIdSitEspCredCSG		CHAR(1);
DEFINE iIdCausaEspCredCSG	INTEGER;
DEFINE cSitEspCredCSG 		CHAR(75);
DEFINE vFolio	            CHAR(16);
--DEFINE vHoy                 DATE;
DEFINE P_ERROR 				CHAR(5);
DEFINE P_MENSAJE			VARCHAR(100,1);
DEFINE V_CATIVA				DECIMAL(9,6);
DEFINE V_MERCADEO			CHAR(1);
---CLONACION DE TDC Oro
DEFINE V_TASA_INTERES        DECIMAL(9,6);
DEFINE V_TASA_MORA           DECIMAL(9,6);
DEFINE V_SOBRETASA           DECIMAL(9,6);
DEFINE V_SOBRETASA_MORA      DECIMAL(9,6);
DEFINE V_TASA_FAVOR          DECIMAL(9,6);
DEFINE V_SOBRETASA_FAV       DECIMAL(9,6);
DEFINE V_FACTOR	             CHAR(1);
DEFINE V_FACTOR_MORA		 CHAR(1);
DEFINE V_FECHA_APERT         DATE;
DEFINE V_FECHA_VENC          DATE;
DEFINE V_FACTOR_FAV          CHAR(1);
DEFINE V_PRODUCTO            CHAR(4);
DEFINE VV_DIVISA             CHAR(2);
DEFINE V_MONTO               DECIMAL(14,2);
DEFINE VV_SUCURSAL           CHAR(4);
DEFINE VV_FOLIO	             CHAR(16);
DEFINE vFechaT               DATE;
DEFINE vDiaCorte             SMALLINT;
DEFINE VDIAPAGO              SMALLINT;
DEFINE i		     		 SMALLINT;
DEFINE cTran				 CHAR(4);
DEFINE vtarjeta				 CHAR(16);
DEFINE cproducto			 CHAR(4);
DEFINE dIntPeriodo        	DECIMAL(14,2);
DEFINE iSecuencia 		  	 INTEGER;
DEFINE cNumtarjadi           CHAR(20);
-- Actualiza producto de la tarjeta nueva en intercard INI
DEFINE Scodproducto          CHAR(03);
-- Actualiza producto de la tarjeta nueva en intercard FIN
-- Se obtiene numcte para identificar si ya cuenta con un producto TDC ORO
DEFINE cNumcte 				CHAR(20);
DEFINE cNumCredUpgrade		CHAR(20);
-- AAME 20180821 INC 25 179 Variables para identificar cte adicional
DEFINE cnumcteadi			CHAR(20);
DEFINE cTarAdicUpgrade		CHAR(20);
DEFINE cidsolicitud			INTEGER;
DEFINE cApell_Paterno		CHAR(26);
DEFINE cApell_Materno		CHAR(26);
DEFINE cNombre1				CHAR(26);
DEFINE cNombre2				CHAR(26);
DEFINE cRfc					CHAR(20);
DEFINE cFechaNacimiento 	DATE;
DEFINE TransaccLibRet		CHAR(20);
DEFINE dMontoRet			DECIMAL(14,2);
DEFINE cFolio				CHAR(20);
DEFINE cUsuario				CHAR(8);
DEFINE cReferencia			CHAR(20);
DEFINE dFecha 				DATE;
DEFINE cSucursal			CHAR(20);
DEFINE cTranlibprot			CHAR(20);
--- Cuenta Clabe
DEFINE vcod_ret				CHAR (6);
DEFINE cta_Clabe			CHAR (18);
--IFRS
DEFINE cACT					INTEGER;
DEFINE cod_ref		     	INTEGER;
DEFINE sExistePromo			SMALLINT;

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '00000';
LET cCodRetTDif	  = '';
LET cMensajeRet   = 'PROCESO EXITOSO';
LET vCodRet       = '';
LET vMsjRetorno	  = '';

LET cEmpresa      = '';
LET cNumProducto  = '';
LET cNomProducto  = '';
LET CstatusSol    = '';
LET CstatusSolANT = '';
-- INICIALIZACION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO. SP_CONSULTA_SALDOS_GENERAL
LET cCodRetCSG				= '000000';
LET cMsjRetCSG				= '';
LET cNumCreditoCSG			= '';
LET cCodTCredCSG			= '';
LET dFechaOrigCSG			= DATE(1);
LET dFechaProxPagCSG 		= DATE(1);
LET dcPagoMinCSG			= 0.00;
LET dFechaUltPagCSG			= DATE(1);
LET iPlazoCSG				= 0;
LET iPagRealizadosCSG		= 0;
LET dcLinOtorgadaCSG		= 0.00;
LET dcTasaInteresCSG		= 0.00;
LET dcTasaMoratoriosCSG 	= 0.00;
LET dcMontoSbsCSG			= 0.00;
LET dcCapVigCSG				= 0.00;
LET dcCapTransCSG			= 0.00;
LET dcCapVdoExigCSG			= 0.00;
LET dcCapVdoNoExigCSG		= 0.00;
LET dcSdoActTotCapCSG		= 0.00;
LET dcIntVigCSG				= 0.00;
LET dcIntVdoCSG				= 0.00;
LET dcIntMoratorioCSG		= 0.00;
LET dcIntMesCSG				= 0.00;
LET dcSodActTotIntCSG		= 0.00;
LET dcIvaIntVigCSG			= 0.00;
LET dcIvaIntVdoCSG			= 0.00;
LET dcIvaIntMorCSG			= 0.00;
LET dcIvaIntMesCSG			= 0.00;
LET dcSdoActTotIvaCSG		= 0.00;
LET dcComPendCSG			= 0.00;
LET dcIvaComCSG				= 0.00;
LET dcSdoRetenidoCSG		= 0.00;
LET dcTotalLiqCSG			= 0.00;
LET dcIntDevengadoCSG		= 0.00;
LET dcIvaIntDevengadoCSG	= 0.00;
LET dcLinDispCSG			= 0.00;
LET dcPagosVdosCSG			= 0.00;
LET cDescStatusCredCSG		= '';
LET iIdBloqueoCredCSG		= 0;
LET cBloqCtaCSG				= '';
LET cIdCausaBloqCredCSG		= '';
LET cCausaBloqCtaCSG		= '';
LET cIdSitEspCteCSG			= '';
LET iIdCausaEspCteCSG		= 0;
LET cSitEspCteCSG			= '';
LET cIdSitEspCredCSG		= '';
LET iIdCausaEspCredCSG		= 0;
LET cSitEspCredCSG 			= '';
--Nueva Solicitud de Crodito Oro
LET scod_ret				= '0';
LET cSolOro     			= '';
LET vFolio                  = '';
--LET vHoy                    = DATE(1);
--
LET P_ERROR 			= '';
LET P_MENSAJE			= '';
LET V_TASA_INTERES 		= 0.0;
LET V_TASA_MORA			= 0.0;
LET V_CATIVA			= 0.0;
LET V_MERCADEO			= '';
LET V_TASA_MORA 		= 0;
LET V_TASA_INTERES 		= 0;
LET V_SOBRETASA   		= 0;
LET V_SOBRETASA_MORA	= 0;
LET V_TASA_FAVOR  		= 0;
LET V_MERCADEO 			= "";
LET V_SOBRETASA_FAV 	= 0;
LET V_FACTOR			= "";
LET V_FACTOR_MORA		= "";
LET V_FECHA_APERT 		= DATE(1);
LET V_FECHA_VENC 		= DATE(1);
LET V_FACTOR_FAV 		= "";
LET V_PRODUCTO  		= "";
LET VV_DIVISA 			= "";
LET V_MONTO  			= 0;
LET VV_SUCURSAL   		= "";
LET VV_FOLIO			= "";
LET vFechaT   			= DATE(1);
LET vDiaCorte 			= 0;
LET VDIAPAGO 			= 0;
LET i		  			= 0;
LET cTran				= "";
LET vtarjeta			= "";
LET cproducto			= "";
LET dIntPeriodo			= 0;
LET iSecuencia 			= 0;
LET cNumtarjadi 		= "";
-- Actualiza producto de la tarjeta nueva en intercard INI
LET Scodproducto        = "";
-- Actualiza producto de la tarjeta nueva en intercard FIN
-- Se obtiene numcte para identificar si ya cuenta con un producto TDC ORO
LET cNumcte 			= "";
LET cNumCredUpgrade		= "";
-- AAME 20180821 INC 25 179 Variables para identificar cte adicional
LET cnumcteadi			= "";
LET cTarAdicUpgrade		= "";
LET cidsolicitud		= 0;
LET cApell_Paterno		= "";
LET cApell_Materno		= "";
LET cNombre1			= "";
LET cNombre2			= "";
LET cRfc				= "";
LET cFechaNacimiento 	= DATE(1);
LET TransaccLibRet		= "";
LET dMontoRet			= 0.00;
LET cFolio				= "";
LET cUsuario			= "";
LET cReferencia			= "";
LET dFecha 				= DATE(1);
LET cSucursal			= "";
LET cTranlibprot			= "";

--- Cuenta Clabe
LET vcod_ret			= '000';
LET cta_Clabe			= '';
-- IFRS
LET cACT				= 0;
LET cod_ref				= 0;
LET sExistePromo		= 0;

--SET DEBUG FILE TO '/informix/keevyn/sp_clona_tdcoro.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

select first 1 codproductotarjeta
into Scodproducto
from intercard:binproducto  
where codprodcta = pProducto
and bin = substr(pTarjetaOro,1,6);

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
		-- Actualizacion de credito en bitacora de upgrade cuando pase un error
		UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
		WHERE num_credito = pCredito;
		--En caso de error se elimina el registro de la nueva tarjeta
		--AAME Se eliminan los datos del nuevo crÃ©dito y se actualizan las tablas al estado anterior
		DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
		DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
		UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
		UPDATE intercard:tarjeta 
		SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
		WHERE numtarjeta = pTarjetaOro;
		FOREACH WITH HOLD 
			SELECT numerotarjeta, numcte 
			INTO cNumtarjadi,cnumcteadi
			FROM bdicred:sd_credito_upgrade
			WHERE num_credito = pCredito
			AND tipotar='ADI'	
			
			SELECT DM.IdSolicitud 
			INTO cidsolicitud
			FROM intercard:SolicitudTarjeta ST 
			INNER JOIN intercard:Detalle_Maquila DM ON ST.IdSolicitud=DM.IdSolicitud 
			WHERE ST.IdSolicitud >= 1 AND ST.NumCuenta= cSolOro AND ST.numcliente = cnumcteadi;		
		
			UPDATE sd_tarjeta  SET status_tar='A' WHERE num_tarjeta = cNumtarjadi;
			UPDATE intercard:tarjeta  SET codstatustarjeta='ACT' WHERE numtarjeta = cNumtarjadi;														
			UPDATE intercard:solicitudtarjeta SET numcuenta=pCredito WHERE idsolicitud =cidsolicitud;
			DELETE FROM sd_adicionalespendientes WHERE empresa='001' AND NumCteTitular = cNumcte AND NumCteAdicional= cnumcteadi AND Credito = cSolOro;					
		END FOREACH;			
		DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
		DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
		DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
		DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
		DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
		DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;
      RETURN cCodRet, cMensajeRet;
    END IF;
END EXCEPTION;


SELECT empresa
INTO cEmpresa
FROM bdinteg:si_empresas
WHERE empresa= pEmpresa;

IF TRIM(NVL(cEmpresa,'')) = '' OR TRIM(NVL(pCredito,''))=''  OR TRIM(NVL(pProducto,''))=''    THEN
  LET cCodRet = '00001';
  LET cMensajeRet = 'El parÃ¡metro no es valido';

	-- Actualizacion de credito en bitacora de upgrade cuando pase un error
	UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
	WHERE num_credito = pCredito;
    --En caso de error se elimina el registro de la nueva tarjeta
    DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
    DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
    UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
    UPDATE intercard:tarjeta 
    SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
    WHERE numtarjeta = pTarjetaOro;

  RETURN cCodRet, cMensajeRet;
END IF;

--SELECT fecha_hoy
--INTO vHoy
--FROM bdicred:sd_fechas;

IF SUBSTR(pTarjeta,1,8) <> SUBSTR(pTarjetaOro,1,8) THEN

	IF EXISTS(SELECT num_tarjeta FROM bdicred:sd_tarjeta WHERE empresa =cEmpresa AND num_tarjeta =pTarjetaOro) THEN

		-- CONSULTAMOS EL SALDO GENERAL DEL CREDITO.
		EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general(TRIM(pEmpresa), TRIM(pCredito))
		INTO cCodRetCSG, cMsjRetCSG, cNumCreditoCSG, cCodTCredCSG, dFechaOrigCSG, dFechaProxPagCSG, dcPagoMinCSG, dFechaUltPagCSG, iPlazoCSG, iPagRealizadosCSG, dcLinOtorgadaCSG, dcTasaInteresCSG, dcTasaMoratoriosCSG, dcMontoSbsCSG,
			 dcCapVigCSG, dcCapTransCSG, dcCapVdoExigCSG, dcCapVdoNoExigCSG, dcSdoActTotCapCSG, dcIntVigCSG, dcIntVdoCSG, dcIntMoratorioCSG, dcIntMesCSG, dcSodActTotIntCSG, dcIvaIntVigCSG, dcIvaIntVdoCSG, dcIvaIntMorCSG, dcIvaIntMesCSG,
			 dcSdoActTotIvaCSG, dcComPendCSG, dcIvaComCSG, dcSdoRetenidoCSG, dcTotalLiqCSG, dcIntDevengadoCSG, dcIvaIntDevengadoCSG, dcLinDispCSG, dcPagosVdosCSG, cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqCtaCSG, cIdCausaBloqCredCSG,
			 cCausaBloqCtaCSG, cIdSitEspCteCSG, iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG;

		IF cCodRetCSG = '000003' THEN -- Numero de crÃ©dito no existe
			LET cCodRet  = '00002';
			LET cMensajeRet = cMsjRetCSG::CHAR(150);
			-- Actualizacion de credito en bitacora de upgrade cuando pase un error
			UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
			WHERE num_credito = pCredito;
			--En caso de error se elimina el registro de la nueva tarjeta
			DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
			DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
			UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
			UPDATE intercard:tarjeta 
			SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
			WHERE numtarjeta = pTarjetaOro;

			RETURN cCodRet, cMensajeRet;
		ELIF cCodRetCSG = '000007' THEN -- Error al obtener el valor del pago minimo
			LET cCodRet  = '00003';
			LET cMensajeRet = cMsjRetCSG::CHAR(150);
			-- Actualizacion de credito en bitacora de upgrade cuando pase un error
			UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
			WHERE num_credito = pCredito;
			--En caso de error se elimina el registro de la nueva tarjeta
			DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
			DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
			UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
			UPDATE intercard:tarjeta 
			SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
			WHERE numtarjeta = pTarjetaOro;

			RETURN cCodRet, cMensajeRet;
		ELIF cCodRetCSG::INTEGER < 0 THEN -- ERROR NO CONTROLADO EN EL BDICRED:SP_CONSULTA_SALDOS_GENERAL
			EXECUTE PROCEDURE bdinteg:sp_desc_ret('06','599')
			INTO vCodRet, vMsjRetorno;

			LET cCodRet  = '00004';
			-- Actualizacion de credito en bitacora de upgrade cuando pase un error
			UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
			WHERE num_credito = pCredito;
			--En caso de error se elimina el registro de la nueva tarjeta
			DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
			DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
			UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
			UPDATE intercard:tarjeta 
			SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
			WHERE numtarjeta = pTarjetaOro;

			LET cMensajeRet = vMsjRetorno::CHAR(150);
			RETURN cCodRet, cMensajeRet;
		END IF
		
	   -- **************************************************
	   -- Extrae informacion del Credito *
	   -- **************************************************
	   SELECT status_cred,numcte
		 INTO  CstatusSol,cNumcte
		 FROM sd_maecred
		WHERE empresa = pEmpresa
		  AND num_credito = pCredito;
	  --***** ACTUALIZA SD_MAECRED
	  --AAME Se Pregunta que no exista antes de insertar en la tabla sd_maecred
		SELECT limit 1 num_credito 
		INTO cNumCredUpgrade
		FROM bdicred:sd_maecred
		WHERE empresa = pEmpresa 
		AND numcte = cNumcte 
		AND credito_externo = pCredito
		AND status_cred IN ('AA','E1');	  
		--MACM RQM 10 1584 TARJETA DE CREDITO INFINITE, SE OMITE LA VALIDACION DE SALDO RETENIDO dcSdoRetenidoCSG = 0
		IF CstatusSol IN ('FF','AA','E1') AND (dcCapTransCSG + dcCapVdoExigCSG) = 0 THEN 
		
			IF NVL(cNumCredUpgrade,'') = '' THEN
				CALL bdisolic:asigna_numsol(pEmpresa, pProducto)
				RETURNING scod_ret, cSolOro;
				IF scod_ret::integer <> 0 THEN
				   LET cCodRet = scod_ret;
				   LET cMensajeRet= 'Error el proceso de asigna_numsol al crear credito upgrade';
					-- Actualizacion de credito en bitacora de upgrade cuando pase un error
					UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
					WHERE num_credito = pCredito;
					--En caso de error se elimina el registro de la nueva tarjeta
					--AAME Se eliminan los datos del nuevo crodito y se actualizan las tablas al estado anterior
					DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
					DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
					UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
					UPDATE intercard:tarjeta 
					SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
					WHERE numtarjeta = pTarjetaOro;
					DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
					DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;

				   RETURN cCodRet, cMensajeRet;
				END IF;				
			ELSE
				LET cSolOro = cNumCredUpgrade;
			END IF;			

			  --clonado de la solicitud
			SELECT fecha_hoy
			  INTO V_FECHA_APERT
			  FROM sd_fechas
			 WHERE empresa = pEmpresa;

			let  V_FECHA_VENC=date(0);

			call monthadd(V_FECHA_APERT,12) returning V_FECHA_VENC;

			  -- ****************************
			  -- Determina Tasas de Interes *
			  -- ****************************
			  
			EXECUTE PROCEDURE bdicred:sp_obtiene_tasa_int_diferenciadas(pEmpresa, pCredito, pProducto) INTO cCodRetTDif, V_TASA_INTERES, V_TASA_MORA;
			IF cCodRetTDif <> '000000' THEN
				LET cCodRet = cCodRetTDif;
				RETURN cCodRet, cMensajeRet;
			END IF;
			  
			--INTERES ORDINARIO
			/*SELECT c.valor, a.factor_sobretasa, a.sobretasa, a.dia_cuota
			  INTO V_TASA_INTERES, V_FACTOR, V_SOBRETASA, vDiaCorte
			  FROM sd_definicion a,  bdinteg:si_fechavalor c
			 WHERE a.empresa = pEmpresa
			   AND a.num_producto = pProducto
			   AND c.empresa = a.empresa
			   AND c.tasa = a.cod_tasa_base
			   AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
					   WHERE r.empresa = pEmpresa
						 AND r.tasa = a.cod_tasa_base);
			*/	-- RQM 10 1224
						 
			SELECT a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.fact_sobret_mora, a.sobretasa_mora
			  INTO V_FACTOR, 		   V_SOBRETASA, vDiaCorte,   V_FACTOR_MORA,      V_SOBRETASA_MORA
			  FROM sd_definicion a
			 WHERE a.empresa = pEmpresa
			   AND a.num_producto = pProducto;							 


			IF v_factor = "+" THEN
				LET V_TASA_INTERES = V_TASA_INTERES + V_SOBRETASA;
			ELIF v_factor = "-" THEN
				LET V_TASA_INTERES = V_TASA_INTERES - V_SOBRETASA;
			ELIF v_factor = "*" THEN
				LET V_TASA_INTERES = V_TASA_INTERES * V_SOBRETASA;
			ELSE
				LET V_TASA_INTERES = V_TASA_INTERES / V_SOBRETASA;
			END IF

			--INTERES MORATORIO
			/*SELECT c.valor, a.fact_sobret_mora, a.sobretasa_mora
			  INTO V_TASA_MORA   , V_FACTOR, V_SOBRETASA
			  FROM sd_definicion a, bdinteg:si_fechavalor c
			 WHERE a.empresa = pEmpresa
			   AND a.num_producto = pProducto
			   AND c.empresa = a.empresa
			   AND c.tasa = a.cod_tasa_mora
			   AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
							   WHERE r.empresa = pEmpresa
								 AND r.tasa = a.cod_tasa_mora);
			*/					-- RQM 10 1224

			IF V_FACTOR_MORA = "+" THEN
					LET V_TASA_MORA = V_TASA_MORA + V_SOBRETASA_MORA;
			ELIF V_FACTOR_MORA = "-" THEN
					LET V_TASA_MORA = V_TASA_MORA - V_SOBRETASA_MORA;
			ELIF V_FACTOR_MORA = "*" THEN
					LET V_TASA_MORA = V_TASA_MORA * V_SOBRETASA_MORA;
			ELSE
					LET V_TASA_MORA = V_TASA_MORA / V_SOBRETASA_MORA;
			END IF

			--INTERES A FAVOR DEL CLIENTE
			SELECT c.valor, a.factor_sobretasa, a.sobretasa
			  INTO V_TASA_FAVOR   , V_FACTOR_FAV, V_SOBRETASA_FAV
			  FROM sd_anexodefinicion a, bdinteg:si_fechavalor c
			 WHERE a.empresa = pEmpresa
			   AND a.num_producto = pProducto
			   AND c.empresa = a.empresa
			   AND c.tasa = a.cod_tasa_base
			   AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
							   WHERE r.empresa = pEmpresa
								 AND r.tasa = a.cod_tasa_base);

			IF V_FACTOR_FAV = "+" THEN
					LET V_TASA_FAVOR = V_TASA_FAVOR + V_SOBRETASA_FAV;
			ELIF V_FACTOR_FAV = "-" THEN
					LET V_TASA_FAVOR = V_TASA_FAVOR - V_SOBRETASA_FAV;
			ELIF V_FACTOR_FAV = "*" THEN
					LET V_TASA_FAVOR = V_TASA_FAVOR * V_SOBRETASA_FAV;
			ELSE
					LET V_TASA_FAVOR = V_TASA_FAVOR / V_SOBRETASA_FAV;
			END IF
		  
			IF NOT EXISTS (SELECT num_credito FROM sd_maecred WHERE empresa = pEmpresa AND num_credito = cSolOro) THEN

				--- Genera cuenta Clabe
				EXECUTE PROCEDURE bdicred:sp_gen_clabe_interbancaria (pEmpresa,cSolOro,pProducto)
					INTO vcod_ret, cta_Clabe;

				SELECT a.num_producto, a.divisa, c.monto_otorgado, b.sucursal, NVL(c.act,-1)
				  INTO V_PRODUCTO, VV_DIVISA, V_MONTO, VV_SUCURSAL, cACT
				  FROM bdicred:sd_maecred b, bdicred:sd_maesdos c, sd_definicion a
				 WHERE b.empresa = pEmpresa
				   AND b.num_credito = pCredito
				   AND c.num_credito= b.num_credito
				   AND a.empresa = b.empresa
				   AND a.num_producto = b.num_producto;	
				   
				LET CstatusSolANT = CstatusSol;

				IF (CstatusSol = 'FF' AND cACT = -1 ) THEN
					LET CstatusSol = 'AA';
				ELIF (CstatusSol = 'FF' AND cACT <> -1) THEN
					LET CstatusSol = 'E1';
				END IF;

				INSERT INTO bdicred:sd_maecred
					   (EMPRESA                ,NUM_CREDITO
					   ,NUM_PRODUCTO           ,EJECUTIVO
					   ,NUMCTE                 ,DIVISA
					   ,SUCURSAL               ,ID_ORIGEN
					   ,ORIGEN                 ,COD_TIPO_LINEA
					   ,COD_LINEA              ,PORC_REC_PROP
					   ,STATUS_CRED            ,BANDERA_RENOVAC
					   ,BANDERA_PRORROGA       ,PERIODO_PLAZO
					   ,PLAZO                  ,FECHA_APERTURA
					   ,FECHA_VENCIM           ,PERIOD_PAGO_CAP
					   ,PERIOD_PAG_INT         ,DIAS_TRASP_CAP
					   ,DIAS_TRASP_INT         ,TASA_FIJA_O_VAR
					   ,COD_TASA_BASE          ,FACTOR_SOBRETASA
					   ,SOBRETASA              ,TASA_INTERES
					   ,COD_TASA_MORA          ,SOBRETASA_MORA
					   ,FACT_SOBRET_MORA       ,TASA_MORATORIOS
					   ,FECHA_PAGO_CAP         ,FECHA_PAGO_INT
					   ,ES_FISICA              ,BANDERA_FI_FO
					   ,CODIGO_PRO             ,SUPERFICIE
					   ,ACTIVIDAD              ,CAL_EDOS_FIN
					   ,TIPO_CALCULO           ,ADMITE_TLP
					   ,REL_GARCRED            ,ID_UNIDAD_PROD
					   ,NUM_APER_ANT           ,REV_TASA_VAR_PER
					   ,DIA_PARA_REVISAR       ,COD_PROD
					   ,BANDERA_MINISTRA       ,NUM_FIDEICOMISO
					   ,CREDITO_EXTERNO        ,GRACIA_CAPITAL
					   ,DIFERIMIENTO_INT       ,FECHA_FIN_PRORRATEO
					   ,CAMPO_TRAB1            ,CAMPO_TRAB2
					   ,CAMPO_TRAB3            ,CAMPO_TRAB4
					   ,CALIFICACION_RIESGO    ,COD_AGRICOLA
					   ,TASA_BASE_PISO         ,SOBRETASA_PISO
					   ,FACTOR_PISO            ,TASA_PISO
					   ,TASA_BASE_TECHO        ,SOBRETASA_TECHO
					   ,FACTOR_TECHO           ,TASA_TECHO
					   ,cuenta_clabe
					   )
				 SELECT SOL.EMPRESA                ,cSolOro
					   ,pProducto           	   ,SOL.EJECUTIVO
					   ,SOL.NUMCTE                 ,DEF.DIVISA
					   ,SOL.SUCURSAL               ,''
					   ,''                         ,''
					   ,''                         ,100
					   ,CstatusSol                 ,'N'
					   ,'N'                        ,DEF.PERIODO_PLAZO
					   ,0                          ,V_FECHA_APERT
					   ,V_FECHA_VENC               ,"3"
					   ,"2"                        ,CTR.DIAS_TRAS_CAP
					   ,CTR.DIAS_TRAS_INT          ,DEF.TASA_FIJA_O_VAR
					   ,DEF.COD_TASA_BASE          ,DEF.FACTOR_SOBRETASA
					   ,DEF.SOBRETASA              ,V_TASA_INTERES
					   ,DEF.COD_TASA_MORA          ,DEF.SOBRETASA_MORA
					   ,DEF.FACT_SOBRET_MORA       ,V_TASA_MORA
					   ,''                         ,''
					   ,TIP.ES_FISICA              ,''
					   ,DEF.COD_PROD               ,0
					   ,''                         ,''
					   ,DEF.TIPO_CALCULO           ,''
					   ,0                          ,''
					   ,''                         ,DEF.REV_TASA_VAR_PER
					   ,DEF.DIA_PARA_REVISAR       ,''
					   ,'M'                        ,''
					   ,pCredito                   ,0
					   ,0                          ,V_FECHA_APERT
					   ,0                          ,0
					   ,''                         ,''
					   ,SOL.CALIFICACION_RIESGO        ,''
					   ,''                         ,''
					   ,''                         ,''
					   ,''                         ,''
					   ,''                         ,''
					   ,cta_Clabe
				 FROM   BDICRED:SD_MAECRED SOL
					  , BDICRED:SD_MAECREDANEXO    ANX
					  , BDINTEG:SI_CLIENTE      CLI
					  , BDINTEG:SI_TIPPER       TIP
					  , SD_CODTRASP             CTR
					  , SD_DEFINICION           DEF
				 WHERE  DEF.EMPRESA         = SOL.EMPRESA
				 AND    DEF.NUM_PRODUCTO    = pProducto
				 AND    CTR.PERIOD_PAG_INT  = "2"
				 AND    CTR.PERIOD_PAGO_CAP = "3"
				 AND 	CTR.NUM_PRODUCTO    = pProducto
				 AND    CTR.EMPRESA         = DEF.EMPRESA
				 AND    TIP.TPO_PERSONA     = CLI.TPO_PERSONA
				 AND    CLI.NUMCTE          = SOL.NUMCTE
				 AND    CLI.EMPRESA         = SOL.EMPRESA
				 AND    ANX.num_credito   = SOL.NUM_CREDITO
				 AND    ANX.EMPRESA         = SOL.EMPRESA
				 AND    SOL.num_credito   = pCredito
				 AND    SOL.EMPRESA         = pEmpresa;
			END IF;

			LET CstatusSol = CstatusSolANT;
			   
			 SELECT (a.dia_cuota - a.gracia_calc_mora)
			  INTO VDIAPAGO
			  FROM sd_definicion a
			 WHERE a.empresa = pEmpresa
			   AND a.num_producto = pProducto;	
			 --AAME Se Pregunta que no exista antes de insertar en la tabla SD_MAESDOS
			 
			IF NOT EXISTS (SELECT num_credito FROM SD_MAESDOS WHERE empresa = pEmpresa AND num_credito = cSolOro) THEN

			  --***** ACTUALIZA SD_MAESDOS

				 INSERT INTO SD_MAESDOS (EMPRESA                ,NUM_CREDITO 
										,FECHA_ULT_MOV          ,SDO_INT_ANTICIP
										,SDO_INT_ANT_DEV        ,SDO_INTERESES
										,SDO_DIA_ANT_INT        ,SDO_MES_ANT_INT
										,SDO_ACUM_MES_INT       ,SDO_RETENIDO
										,SDO_ACUM_CAP_INT       ,SDO_EXIG_INT
										,SDO_NO_EXIG            ,PROVISION_NORMAL
										,DIAS_ACUM_INT          ,SDO_MORATORIO
										,SDO_DIA_ANT_MOR        ,SDO_MES_ANT_MOR
										,SDO_CONTAB_MORA        ,DIAS_ACUM_MORA
										,SDO_CAPITAL            ,SDO_CAP_INSOLUTO
										,SDO_DIA_ANT_CAP        ,SDO_MES_ANT_CAP
										,SDO_ACUM_MES_CAP       ,MTO_CAPITALIZADO
										,MTO_MINISTRA_CAP       ,CARGOS_DIA_CAP
										,ABONOS_DIA_CAP         ,CARGOS_MES_CAP
										,ABONOS_MES_CAP         ,DIAS_ACUM_CAP
										,MONTO_VENCIDO          ,MTO_VENC_TRASP
										,MONTO_FINANCIADO       ,MONTO_RESERVADO
										,SDO_ACUM_VENCIDO       ,DIAS_ACUM_INTPER
										,SDO_GLOBAL_INT         ,SDO_ACUM_INTPER
										,MONTO_OTORGADO         ,PROVI_VENC_NORMAL
										,PROVI_VENC_ANTICIP     ,CAP_TRAS_NO_VENCI
										,MTO_VENC_INT           ,MTO_VENC_TRA_INT
										,MTO_FINAN_VDO          ,MTO_RESER_INT
										,MTO_FIN_VEN_TRASP      ,MTO_FIN_VIG_TRASP
										,INT_TRA_NO_EXIG        ,SDO_TRAB4
										,ACT)
								  SELECT EMPRESA                ,cSolOro
										,FECHA_ULT_MOV          ,SDO_INT_ANTICIP
										,SDO_INT_ANT_DEV        ,SDO_INTERESES
										,SDO_DIA_ANT_INT        ,SDO_MES_ANT_INT
										,SDO_ACUM_MES_INT       ,SDO_RETENIDO
										,SDO_ACUM_CAP_INT       ,SDO_EXIG_INT
										,SDO_NO_EXIG            ,PROVISION_NORMAL
										,DIAS_ACUM_INT          ,SDO_MORATORIO
										,SDO_DIA_ANT_MOR        ,SDO_MES_ANT_MOR
										,SDO_CONTAB_MORA        ,DIAS_ACUM_MORA
										,SDO_CAPITAL            ,SDO_CAP_INSOLUTO
										,SDO_DIA_ANT_CAP        ,SDO_MES_ANT_CAP
										,SDO_ACUM_MES_CAP       ,MTO_CAPITALIZADO
										,MTO_MINISTRA_CAP       ,CARGOS_DIA_CAP
										,ABONOS_DIA_CAP         ,CARGOS_MES_CAP
										,ABONOS_MES_CAP         ,DIAS_ACUM_CAP
										,MONTO_VENCIDO          ,MTO_VENC_TRASP
										,MONTO_FINANCIADO       ,MONTO_RESERVADO
										,SDO_ACUM_VENCIDO       ,DIAS_ACUM_INTPER
										,SDO_GLOBAL_INT         ,SDO_ACUM_INTPER
										,MONTO_OTORGADO         ,PROVI_VENC_NORMAL
										,PROVI_VENC_ANTICIP     ,CAP_TRAS_NO_VENCI
										,MTO_VENC_INT           ,MTO_VENC_TRA_INT
										,MTO_FINAN_VDO          ,MTO_RESER_INT
										,MTO_FIN_VEN_TRASP      ,MTO_FIN_VIG_TRASP
										,INT_TRA_NO_EXIG        ,SDO_TRAB4
										,ACT
								  FROM   BDICRED:SD_MAESDOS SOL
								  WHERE  SOL.NUM_CREDITO = pCredito
								  AND    SOL.EMPRESA   = pEmpresa;
			END IF;

			SELECT USER
				 || REPLACE(REPLACE(CURRENT HOUR TO FRACTION,':',''),'.','') FOLIO
			INTO VV_FOLIO
			FROM SD_FECHAS
			WHERE empresa = pEmpresa;

			-- *********************************************************
			-- INSERTA PRIMEROS 12 MESES DE LA TABLA DE AMORTIZACIONES *
			-- *********************************************************

			select min(fecha_cuota)
			into vFechaT
			from bdicred:sd_amortiza_credito
			where num_credito = pCredito
				  AND fecha_cuota >= monthadd(V_FECHA_APERT,-1);
				
		    IF (DAY(V_FECHA_APERT) > vDiaCorte AND DAY(V_FECHA_APERT) <= DAY(vFechaT)) OR (DAY(V_FECHA_APERT) = vDiaCorte) THEN
				--AAME Se Pregunta que no exista antes de insertar en la tabla SD_AMORTIZA_CREDITO
				IF NOT EXISTS (SELECT num_credito FROM SD_AMORTIZA_CREDITO WHERE empresa = pEmpresa AND num_credito = cSolOro) THEN
		   
			   --Se considera la fecha_cuota que devuelve mas 1 mes, ya que la consulta es fecha_cuota > = a la fecha_hoy menos 1 mes.
					INSERT INTO bdicred:sd_amortiza_credito(empresa,num_credito,fecha_cuota,tipo_cuota,capital_mto_cuota,
					capital_debe,capital_pagado,capital_status,capital_status_ant,capital_fecha_pago,interes_debe    
					,interes_pagado,interes_status,interes_status_ant,interes_fecha_pago,iva_debe,iva_pagado,iva_status    
					,iva_status_ant,iva_fecha_pago,mora_provi_ordi,mora_provi_cope,mora_sdo_ordi,mora_sdo_ordi_pag    
					,mora_sdo_cope,mora_sdo_cope_pag,mora_bonificado,mora_status,mora_iva_debe,mora_iva_pagado    
					,mora_iva_status,mora_iva_fecha_pago,num_pago,campo_trabajo1,campo_trabajo2,campo_trabajo3,
					campo_trabajo4)
					SELECT
					empresa,cSolOro
					,monthadd(mdy(month(fecha_cuota),vDiaCorte,year(fecha_cuota)),1) 
					,tipo_cuota    
					,capital_mto_cuota    
					,capital_debe    
					,capital_pagado    
					,capital_status    
					,capital_status_ant    
					,capital_fecha_pago    
					,interes_debe    
					,interes_pagado    
					,interes_status    
					,interes_status_ant    
					,interes_fecha_pago    
					,iva_debe    
					,iva_pagado    
					,iva_status    
					,iva_status_ant    
					,iva_fecha_pago    
					,mora_provi_ordi    
					,mora_provi_cope    
					,mora_sdo_ordi    
					,mora_sdo_ordi_pag    
					,mora_sdo_cope    
					,mora_sdo_cope_pag    
					,mora_bonificado    
					,mora_status    
					,mora_iva_debe    
					,mora_iva_pagado    
					,mora_iva_status    
					,mora_iva_fecha_pago    
					,num_pago    
					,campo_trabajo1    
					,campo_trabajo2    
					,campo_trabajo3    
					,campo_trabajo4   
					FROM bdicred:sd_amortiza_credito
					WHERE num_credito = pCredito
					  AND fecha_cuota >= monthadd(V_FECHA_APERT,-1);	
				END IF;
					  
				--AAME Se Pregunta que no exista antes de insertar en la tabla sd_maecredanexo
				IF NOT EXISTS (SELECT num_credito FROM sd_maecredanexo WHERE empresa = pEmpresa AND num_credito = cSolOro) THEN

					  --***** ACTUALIZA SD_MAECREDANEXO (DATOS PARA TARJETA DE CREDITO)

					INSERT INTO sd_maecredanexo
						(empresa,               num_credito,
						 dia_corte,             dias_gracia_mora,
						 tp_dias_calc_mora,     dias_fecha_max_pago,
						 tp_dias_fecha_pago,    cod_tasa_base_cte,
						 factor_sobretasa_cte,  sobretasa_cte,
						 tasa_interes_cte,      fecha_proceso,prox_fecha_pago)
					SELECT pEmpresa,               cSolOro,
						   def.dia_cuota,           def.gracia_calc_mora,
						   def.pago_adic_sig_cuo,   def.tipo_cliente,
						   def.maneja_linea,        def.cod_tasa_base,
						   def.factor_sobretasa,    def.sobretasa,
						   V_TASA_FAVOR,            V_FECHA_APERT,
						   monthadd(mdy(month(V_FECHA_APERT),VDIAPAGO,year(V_FECHA_APERT)),1) 
					  FROM sd_definicion def, sd_anexodefinicion b,
						   bdicred:sd_maecred c
					 WHERE c.empresa = pEmpresa
					   AND c.num_credito = pCredito
					   AND def.empresa = c.empresa
					   AND def.num_producto = pProducto
					   AND b.empresa = def.empresa
					   AND b.num_producto = pProducto
					   AND b.cod_prod = def.cod_tipcred;
				END IF;
			  
			ELSE 
				--AAME Se Pregunta que no exista antes de insertar en la tabla SD_AMORTIZA_CREDITO
				IF NOT EXISTS (SELECT num_credito FROM SD_AMORTIZA_CREDITO WHERE empresa = pEmpresa AND num_credito = cSolOro) THEN
			
					INSERT INTO bdicred:sd_amortiza_credito(empresa,num_credito,fecha_cuota,tipo_cuota,capital_mto_cuota,
					capital_debe,capital_pagado,capital_status,capital_status_ant,capital_fecha_pago,interes_debe    
					,interes_pagado,interes_status,interes_status_ant,interes_fecha_pago,iva_debe,iva_pagado,iva_status    
					,iva_status_ant,iva_fecha_pago,mora_provi_ordi,mora_provi_cope,mora_sdo_ordi,mora_sdo_ordi_pag    
					,mora_sdo_cope,mora_sdo_cope_pag,mora_bonificado,mora_status,mora_iva_debe,mora_iva_pagado    
					,mora_iva_status,mora_iva_fecha_pago,num_pago,campo_trabajo1,campo_trabajo2,campo_trabajo3,
					campo_trabajo4)
					SELECT
					empresa    
					,cSolOro
					,mdy(month(fecha_cuota),vDiaCorte,year(fecha_cuota))
					,tipo_cuota    
					,capital_mto_cuota    
					,capital_debe    
					,capital_pagado    
					,capital_status    
					,capital_status_ant    
					,capital_fecha_pago    
					,interes_debe    
					,interes_pagado    
					,interes_status    
					,interes_status_ant    
					,interes_fecha_pago    
					,iva_debe    
					,iva_pagado    
					,iva_status    
					,iva_status_ant    
					,iva_fecha_pago    
					,mora_provi_ordi    
					,mora_provi_cope    
					,mora_sdo_ordi    
					,mora_sdo_ordi_pag    
					,mora_sdo_cope    
					,mora_sdo_cope_pag    
					,mora_bonificado    
					,mora_status    
					,mora_iva_debe    
					,mora_iva_pagado    
					,mora_iva_status    
					,mora_iva_fecha_pago    
					,num_pago    
					,campo_trabajo1    
					,campo_trabajo2    
					,campo_trabajo3    
					,campo_trabajo4   
					FROM bdicred:sd_amortiza_credito
					WHERE num_credito = pCredito
					  AND fecha_cuota >= monthadd(V_FECHA_APERT,-1);	
				END IF;
				--AAME Se Pregunta que no exista antes de insertar en la tabla sd_maecredanexo
				IF NOT EXISTS (SELECT num_credito FROM sd_maecredanexo WHERE empresa = pEmpresa AND num_credito = cSolOro) THEN

					  --***** ACTUALIZA SD_MAECREDANEXO (DATOS PARA TARJETA DE CREDITO)

					INSERT INTO sd_maecredanexo
						(empresa,               num_credito,
						 dia_corte,             dias_gracia_mora,
						 tp_dias_calc_mora,     dias_fecha_max_pago,
						 tp_dias_fecha_pago,    cod_tasa_base_cte,
						 factor_sobretasa_cte,  sobretasa_cte,
						 tasa_interes_cte,      fecha_proceso,prox_fecha_pago)
					SELECT pEmpresa,               cSolOro,
						   def.dia_cuota,           def.gracia_calc_mora,
						   def.pago_adic_sig_cuo,   def.tipo_cliente,
						   def.maneja_linea,        def.cod_tasa_base,
						   def.factor_sobretasa,    def.sobretasa,
						   V_TASA_FAVOR,            V_FECHA_APERT,
						   mdy(month(V_FECHA_APERT),VDIAPAGO,year(V_FECHA_APERT)) 
					  FROM sd_definicion def, sd_anexodefinicion b,
						   bdicred:sd_maecred c
					 WHERE c.empresa = pEmpresa
					   AND c.num_credito = pCredito
					   AND def.empresa = c.empresa
					   AND def.num_producto = pProducto
					   AND b.empresa = def.empresa
					   AND b.num_producto = pProducto
					   AND b.cod_prod = def.cod_tipcred;
				END IF;
				   
			END IF;
			--AAME Se Pregunta que no exista antes de insertar en la tabla sd_indicador_cred
			IF NOT EXISTS (SELECT num_credito FROM sd_indicador_cred WHERE empresa = pEmpresa AND num_credito = cSolOro) THEN

				--Tabla para guardar fecha de ultima compra, ultima disposicion, etc
				INSERT INTO bdicred:sd_indicador_cred
						  (empresa,num_credito, fecha_alta)
					  VALUES(pEmpresa,cSolOro,V_FECHA_APERT );
			END IF;
			--AAME Se Pregunta que no exista antes de insertar en la tabla sd_sdodiario
			IF NOT EXISTS (SELECT num_credito FROM sd_sdodiario WHERE fecha = mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) AND num_credito = cSolOro) THEN

				-- CLONADO DE TABLA SD_SDODIARIO
				INSERT INTO sd_sdodiario(fecha,num_credito,sucursal,capvig1,captrans1,capvencnoexig1,capvenexig1,intvig1,intvenc1,ivaintvig1,ivaintvenc1,capvig2,captrans2,capvencnoexig2,capvenexig2,intvig2,intvenc2,ivaintvig2,ivaintvenc2,capvig3,captrans3,capvencnoexig3,capvenexig3,intvig3,intvenc3,ivaintvig3,ivaintvenc3,capvig4,captrans4,capvencnoexig4,capvenexig4,intvig4,intvenc4,ivaintvig4,ivaintvenc4,capvig5,captrans5,capvencnoexig5,capvenexig5,intvig5,intvenc5,ivaintvig5,ivaintvenc5,capvig6,captrans6,capvencnoexig6,capvenexig6,intvig6,intvenc6,ivaintvig6,ivaintvenc6,capvig7,captrans7,capvencnoexig7,capvenexig7,intvig7,intvenc7,ivaintvig7,ivaintvenc7,capvig8,captrans8,capvencnoexig8,capvenexig8,intvig8,intvenc8,ivaintvig8,ivaintvenc8,capvig9,captrans9,capvencnoexig9,capvenexig9,intvig9,intvenc9,ivaintvig9,ivaintvenc9,capvig10,captrans10,capvencnoexig10,capvenexig10,intvig10,intvenc10,ivaintvig10,ivaintvenc10,capvig11,captrans11,capvencnoexig11,capvenexig11,intvig11,intvenc11,ivaintvig11,ivaintvenc11,capvig12,captrans12,capvencnoexig12,capvenexig12,intvig12,intvenc12,ivaintvig12,ivaintvenc12,capvig13,captrans13,capvencnoexig13,capvenexig13,intvig13,intvenc13,ivaintvig13,ivaintvenc13,capvig14,captrans14,capvencnoexig14,capvenexig14,intvig14,intvenc14,ivaintvig14,ivaintvenc14,capvig15,captrans15,capvencnoexig15,capvenexig15,intvig15,intvenc15,ivaintvig15,ivaintvenc15,capvig16,captrans16,capvencnoexig16,capvenexig16,intvig16,intvenc16,ivaintvig16,ivaintvenc16,capvig17,captrans17,capvencnoexig17,capvenexig17,intvig17,intvenc17,ivaintvig17,ivaintvenc17,capvig18,captrans18,capvencnoexig18,capvenexig18,intvig18,intvenc18,ivaintvig18,ivaintvenc18,capvig19,captrans19,capvencnoexig19,capvenexig19,intvig19,intvenc19,ivaintvig19,ivaintvenc19,capvig20,captrans20,capvencnoexig20,capvenexig20,intvig20,intvenc20,ivaintvig20,ivaintvenc20,capvig21,captrans21,capvencnoexig21,capvenexig21,intvig21,intvenc21,ivaintvig21,ivaintvenc21,capvig22,captrans22,capvencnoexig22,capvenexig22,intvig22,intvenc22,ivaintvig22,ivaintvenc22,capvig23,captrans23,capvencnoexig23,capvenexig23,intvig23,intvenc23,ivaintvig23,ivaintvenc23,capvig24,captrans24,capvencnoexig24,capvenexig24,intvig24,intvenc24,ivaintvig24,ivaintvenc24,capvig25,captrans25,capvencnoexig25,capvenexig25,intvig25,intvenc25,ivaintvig25,ivaintvenc25,capvig26,captrans26,capvencnoexig26,capvenexig26,intvig26,intvenc26,ivaintvig26,ivaintvenc26,capvig27,captrans27,capvencnoexig27,capvenexig27,intvig27,intvenc27,ivaintvig27,ivaintvenc27,capvig28,captrans28,capvencnoexig28,capvenexig28,intvig28,intvenc28,ivaintvig28,ivaintvenc28,capvig29,captrans29,capvencnoexig29,capvenexig29,intvig29,intvenc29,ivaintvig29,ivaintvenc29,capvig30,captrans30,capvencnoexig30,capvenexig30,intvig30,intvenc30,ivaintvig30,ivaintvenc30,capvig31,captrans31,capvencnoexig31,capvenexig31,intvig31,intvenc31,ivaintvig31,ivaintvenc31,diacapvig,acucapvig,diacaptra,acucaptra,diacapvennoexig,acucapvennoexig,diacapvencexig,acucapvencexig,meses_vencidos1,meses_vencidos2,meses_vencidos3,meses_vencidos4,meses_vencidos5,meses_vencidos6,meses_vencidos7,meses_vencidos8,meses_vencidos9,meses_vencidos10,meses_vencidos11,meses_vencidos12,meses_vencidos13,meses_vencidos14,meses_vencidos15,meses_vencidos16,meses_vencidos17,meses_vencidos18,meses_vencidos19,meses_vencidos20,meses_vencidos21,meses_vencidos22,meses_vencidos23,meses_vencidos24,meses_vencidos25,meses_vencidos26,meses_vencidos27,meses_vencidos28,meses_vencidos29,meses_vencidos30,meses_vencidos31,moratorios1,moratorios2,moratorios3,moratorios4,moratorios5,moratorios6,moratorios7,moratorios8,moratorios9,moratorios10,moratorios11,moratorios12,moratorios13,moratorios14,moratorios15,moratorios16,moratorios17,moratorios18,moratorios19,moratorios20,moratorios21,moratorios22,moratorios23,moratorios24,moratorios25,moratorios26,moratorios27,moratorios28,moratorios29,moratorios30,moratorios31)
				SELECT fecha,cSolOro,sucursal,capvig1,captrans1,capvencnoexig1,capvenexig1,intvig1,intvenc1,ivaintvig1,ivaintvenc1,capvig2,captrans2,capvencnoexig2,capvenexig2,intvig2,intvenc2,ivaintvig2,ivaintvenc2,capvig3,captrans3,capvencnoexig3,capvenexig3,intvig3,intvenc3,ivaintvig3,ivaintvenc3,capvig4,captrans4,capvencnoexig4,capvenexig4,intvig4,intvenc4,ivaintvig4,ivaintvenc4,capvig5,captrans5,capvencnoexig5,capvenexig5,intvig5,intvenc5,ivaintvig5,ivaintvenc5,capvig6,captrans6,capvencnoexig6,capvenexig6,intvig6,intvenc6,ivaintvig6,ivaintvenc6,capvig7,captrans7,capvencnoexig7,capvenexig7,intvig7,intvenc7,ivaintvig7,ivaintvenc7,capvig8,captrans8,capvencnoexig8,capvenexig8,intvig8,intvenc8,ivaintvig8,ivaintvenc8,capvig9,captrans9,capvencnoexig9,capvenexig9,intvig9,intvenc9,ivaintvig9,ivaintvenc9,capvig10,captrans10,capvencnoexig10,capvenexig10,intvig10,intvenc10,ivaintvig10,ivaintvenc10,capvig11,captrans11,capvencnoexig11,capvenexig11,intvig11,intvenc11,ivaintvig11,ivaintvenc11,capvig12,captrans12,capvencnoexig12,capvenexig12,intvig12,intvenc12,ivaintvig12,ivaintvenc12,capvig13,captrans13,capvencnoexig13,capvenexig13,intvig13,intvenc13,ivaintvig13,ivaintvenc13,capvig14,captrans14,capvencnoexig14,capvenexig14,intvig14,intvenc14,ivaintvig14,ivaintvenc14,capvig15,captrans15,capvencnoexig15,capvenexig15,intvig15,intvenc15,ivaintvig15,ivaintvenc15,capvig16,captrans16,capvencnoexig16,capvenexig16,intvig16,intvenc16,ivaintvig16,ivaintvenc16,capvig17,captrans17,capvencnoexig17,capvenexig17,intvig17,intvenc17,ivaintvig17,ivaintvenc17,capvig18,captrans18,capvencnoexig18,capvenexig18,intvig18,intvenc18,ivaintvig18,ivaintvenc18,capvig19,captrans19,capvencnoexig19,capvenexig19,intvig19,intvenc19,ivaintvig19,ivaintvenc19,capvig20,captrans20,capvencnoexig20,capvenexig20,intvig20,intvenc20,ivaintvig20,ivaintvenc20,capvig21,captrans21,capvencnoexig21,capvenexig21,intvig21,intvenc21,ivaintvig21,ivaintvenc21,capvig22,captrans22,capvencnoexig22,capvenexig22,intvig22,intvenc22,ivaintvig22,ivaintvenc22,capvig23,captrans23,capvencnoexig23,capvenexig23,intvig23,intvenc23,ivaintvig23,ivaintvenc23,capvig24,captrans24,capvencnoexig24,capvenexig24,intvig24,intvenc24,ivaintvig24,ivaintvenc24,capvig25,captrans25,capvencnoexig25,capvenexig25,intvig25,intvenc25,ivaintvig25,ivaintvenc25,capvig26,captrans26,capvencnoexig26,capvenexig26,intvig26,intvenc26,ivaintvig26,ivaintvenc26,capvig27,captrans27,capvencnoexig27,capvenexig27,intvig27,intvenc27,ivaintvig27,ivaintvenc27,capvig28,captrans28,capvencnoexig28,capvenexig28,intvig28,intvenc28,ivaintvig28,ivaintvenc28,capvig29,captrans29,capvencnoexig29,capvenexig29,intvig29,intvenc29,ivaintvig29,ivaintvenc29,capvig30,captrans30,capvencnoexig30,capvenexig30,intvig30,intvenc30,ivaintvig30,ivaintvenc30,capvig31,captrans31,capvencnoexig31,capvenexig31,intvig31,intvenc31,ivaintvig31,ivaintvenc31,diacapvig,acucapvig,diacaptra,acucaptra,diacapvennoexig,acucapvennoexig,diacapvencexig,acucapvencexig,meses_vencidos1,meses_vencidos2,meses_vencidos3,meses_vencidos4,meses_vencidos5,meses_vencidos6,meses_vencidos7,meses_vencidos8,meses_vencidos9,meses_vencidos10,meses_vencidos11,meses_vencidos12,meses_vencidos13,meses_vencidos14,meses_vencidos15,meses_vencidos16,meses_vencidos17,meses_vencidos18,meses_vencidos19,meses_vencidos20,meses_vencidos21,meses_vencidos22,meses_vencidos23,meses_vencidos24,meses_vencidos25,meses_vencidos26,meses_vencidos27,meses_vencidos28,meses_vencidos29,meses_vencidos30,meses_vencidos31,moratorios1,moratorios2,moratorios3,moratorios4,moratorios5,moratorios6,moratorios7,moratorios8,moratorios9,moratorios10,moratorios11,moratorios12,moratorios13,moratorios14,moratorios15,moratorios16,moratorios17,moratorios18,moratorios19,moratorios20,moratorios21,moratorios22,moratorios23,moratorios24,moratorios25,moratorios26,moratorios27,moratorios28,moratorios29,moratorios30,moratorios31
				FROM sd_sdodiario 
				WHERE  fecha = mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT))		
				and num_credito =pCredito;					  

				-- CLONADO DE TABLA SD_SDODIARIO
				INSERT INTO sd_sdodiario(fecha,num_credito,sucursal,capvig1,captrans1,capvencnoexig1,capvenexig1,intvig1,intvenc1,ivaintvig1,ivaintvenc1,capvig2,captrans2,capvencnoexig2,capvenexig2,intvig2,intvenc2,ivaintvig2,ivaintvenc2,capvig3,captrans3,capvencnoexig3,capvenexig3,intvig3,intvenc3,ivaintvig3,ivaintvenc3,capvig4,captrans4,capvencnoexig4,capvenexig4,intvig4,intvenc4,ivaintvig4,ivaintvenc4,capvig5,captrans5,capvencnoexig5,capvenexig5,intvig5,intvenc5,ivaintvig5,ivaintvenc5,capvig6,captrans6,capvencnoexig6,capvenexig6,intvig6,intvenc6,ivaintvig6,ivaintvenc6,capvig7,captrans7,capvencnoexig7,capvenexig7,intvig7,intvenc7,ivaintvig7,ivaintvenc7,capvig8,captrans8,capvencnoexig8,capvenexig8,intvig8,intvenc8,ivaintvig8,ivaintvenc8,capvig9,captrans9,capvencnoexig9,capvenexig9,intvig9,intvenc9,ivaintvig9,ivaintvenc9,capvig10,captrans10,capvencnoexig10,capvenexig10,intvig10,intvenc10,ivaintvig10,ivaintvenc10,capvig11,captrans11,capvencnoexig11,capvenexig11,intvig11,intvenc11,ivaintvig11,ivaintvenc11,capvig12,captrans12,capvencnoexig12,capvenexig12,intvig12,intvenc12,ivaintvig12,ivaintvenc12,capvig13,captrans13,capvencnoexig13,capvenexig13,intvig13,intvenc13,ivaintvig13,ivaintvenc13,capvig14,captrans14,capvencnoexig14,capvenexig14,intvig14,intvenc14,ivaintvig14,ivaintvenc14,capvig15,captrans15,capvencnoexig15,capvenexig15,intvig15,intvenc15,ivaintvig15,ivaintvenc15,capvig16,captrans16,capvencnoexig16,capvenexig16,intvig16,intvenc16,ivaintvig16,ivaintvenc16,capvig17,captrans17,capvencnoexig17,capvenexig17,intvig17,intvenc17,ivaintvig17,ivaintvenc17,capvig18,captrans18,capvencnoexig18,capvenexig18,intvig18,intvenc18,ivaintvig18,ivaintvenc18,capvig19,captrans19,capvencnoexig19,capvenexig19,intvig19,intvenc19,ivaintvig19,ivaintvenc19,capvig20,captrans20,capvencnoexig20,capvenexig20,intvig20,intvenc20,ivaintvig20,ivaintvenc20,capvig21,captrans21,capvencnoexig21,capvenexig21,intvig21,intvenc21,ivaintvig21,ivaintvenc21,capvig22,captrans22,capvencnoexig22,capvenexig22,intvig22,intvenc22,ivaintvig22,ivaintvenc22,capvig23,captrans23,capvencnoexig23,capvenexig23,intvig23,intvenc23,ivaintvig23,ivaintvenc23,capvig24,captrans24,capvencnoexig24,capvenexig24,intvig24,intvenc24,ivaintvig24,ivaintvenc24,capvig25,captrans25,capvencnoexig25,capvenexig25,intvig25,intvenc25,ivaintvig25,ivaintvenc25,capvig26,captrans26,capvencnoexig26,capvenexig26,intvig26,intvenc26,ivaintvig26,ivaintvenc26,capvig27,captrans27,capvencnoexig27,capvenexig27,intvig27,intvenc27,ivaintvig27,ivaintvenc27,capvig28,captrans28,capvencnoexig28,capvenexig28,intvig28,intvenc28,ivaintvig28,ivaintvenc28,capvig29,captrans29,capvencnoexig29,capvenexig29,intvig29,intvenc29,ivaintvig29,ivaintvenc29,capvig30,captrans30,capvencnoexig30,capvenexig30,intvig30,intvenc30,ivaintvig30,ivaintvenc30,capvig31,captrans31,capvencnoexig31,capvenexig31,intvig31,intvenc31,ivaintvig31,ivaintvenc31,diacapvig,acucapvig,diacaptra,acucaptra,diacapvennoexig,acucapvennoexig,diacapvencexig,acucapvencexig,meses_vencidos1,meses_vencidos2,meses_vencidos3,meses_vencidos4,meses_vencidos5,meses_vencidos6,meses_vencidos7,meses_vencidos8,meses_vencidos9,meses_vencidos10,meses_vencidos11,meses_vencidos12,meses_vencidos13,meses_vencidos14,meses_vencidos15,meses_vencidos16,meses_vencidos17,meses_vencidos18,meses_vencidos19,meses_vencidos20,meses_vencidos21,meses_vencidos22,meses_vencidos23,meses_vencidos24,meses_vencidos25,meses_vencidos26,meses_vencidos27,meses_vencidos28,meses_vencidos29,meses_vencidos30,meses_vencidos31,moratorios1,moratorios2,moratorios3,moratorios4,moratorios5,moratorios6,moratorios7,moratorios8,moratorios9,moratorios10,moratorios11,moratorios12,moratorios13,moratorios14,moratorios15,moratorios16,moratorios17,moratorios18,moratorios19,moratorios20,moratorios21,moratorios22,moratorios23,moratorios24,moratorios25,moratorios26,moratorios27,moratorios28,moratorios29,moratorios30,moratorios31)
				SELECT fecha,cSolOro,sucursal,capvig1,captrans1,capvencnoexig1,capvenexig1,intvig1,intvenc1,ivaintvig1,ivaintvenc1,capvig2,captrans2,capvencnoexig2,capvenexig2,intvig2,intvenc2,ivaintvig2,ivaintvenc2,capvig3,captrans3,capvencnoexig3,capvenexig3,intvig3,intvenc3,ivaintvig3,ivaintvenc3,capvig4,captrans4,capvencnoexig4,capvenexig4,intvig4,intvenc4,ivaintvig4,ivaintvenc4,capvig5,captrans5,capvencnoexig5,capvenexig5,intvig5,intvenc5,ivaintvig5,ivaintvenc5,capvig6,captrans6,capvencnoexig6,capvenexig6,intvig6,intvenc6,ivaintvig6,ivaintvenc6,capvig7,captrans7,capvencnoexig7,capvenexig7,intvig7,intvenc7,ivaintvig7,ivaintvenc7,capvig8,captrans8,capvencnoexig8,capvenexig8,intvig8,intvenc8,ivaintvig8,ivaintvenc8,capvig9,captrans9,capvencnoexig9,capvenexig9,intvig9,intvenc9,ivaintvig9,ivaintvenc9,capvig10,captrans10,capvencnoexig10,capvenexig10,intvig10,intvenc10,ivaintvig10,ivaintvenc10,capvig11,captrans11,capvencnoexig11,capvenexig11,intvig11,intvenc11,ivaintvig11,ivaintvenc11,capvig12,captrans12,capvencnoexig12,capvenexig12,intvig12,intvenc12,ivaintvig12,ivaintvenc12,capvig13,captrans13,capvencnoexig13,capvenexig13,intvig13,intvenc13,ivaintvig13,ivaintvenc13,capvig14,captrans14,capvencnoexig14,capvenexig14,intvig14,intvenc14,ivaintvig14,ivaintvenc14,capvig15,captrans15,capvencnoexig15,capvenexig15,intvig15,intvenc15,ivaintvig15,ivaintvenc15,capvig16,captrans16,capvencnoexig16,capvenexig16,intvig16,intvenc16,ivaintvig16,ivaintvenc16,capvig17,captrans17,capvencnoexig17,capvenexig17,intvig17,intvenc17,ivaintvig17,ivaintvenc17,capvig18,captrans18,capvencnoexig18,capvenexig18,intvig18,intvenc18,ivaintvig18,ivaintvenc18,capvig19,captrans19,capvencnoexig19,capvenexig19,intvig19,intvenc19,ivaintvig19,ivaintvenc19,capvig20,captrans20,capvencnoexig20,capvenexig20,intvig20,intvenc20,ivaintvig20,ivaintvenc20,capvig21,captrans21,capvencnoexig21,capvenexig21,intvig21,intvenc21,ivaintvig21,ivaintvenc21,capvig22,captrans22,capvencnoexig22,capvenexig22,intvig22,intvenc22,ivaintvig22,ivaintvenc22,capvig23,captrans23,capvencnoexig23,capvenexig23,intvig23,intvenc23,ivaintvig23,ivaintvenc23,capvig24,captrans24,capvencnoexig24,capvenexig24,intvig24,intvenc24,ivaintvig24,ivaintvenc24,capvig25,captrans25,capvencnoexig25,capvenexig25,intvig25,intvenc25,ivaintvig25,ivaintvenc25,capvig26,captrans26,capvencnoexig26,capvenexig26,intvig26,intvenc26,ivaintvig26,ivaintvenc26,capvig27,captrans27,capvencnoexig27,capvenexig27,intvig27,intvenc27,ivaintvig27,ivaintvenc27,capvig28,captrans28,capvencnoexig28,capvenexig28,intvig28,intvenc28,ivaintvig28,ivaintvenc28,capvig29,captrans29,capvencnoexig29,capvenexig29,intvig29,intvenc29,ivaintvig29,ivaintvenc29,capvig30,captrans30,capvencnoexig30,capvenexig30,intvig30,intvenc30,ivaintvig30,ivaintvenc30,capvig31,captrans31,capvencnoexig31,capvenexig31,intvig31,intvenc31,ivaintvig31,ivaintvenc31,diacapvig,acucapvig,diacaptra,acucaptra,diacapvennoexig,acucapvennoexig,diacapvencexig,acucapvencexig,meses_vencidos1,meses_vencidos2,meses_vencidos3,meses_vencidos4,meses_vencidos5,meses_vencidos6,meses_vencidos7,meses_vencidos8,meses_vencidos9,meses_vencidos10,meses_vencidos11,meses_vencidos12,meses_vencidos13,meses_vencidos14,meses_vencidos15,meses_vencidos16,meses_vencidos17,meses_vencidos18,meses_vencidos19,meses_vencidos20,meses_vencidos21,meses_vencidos22,meses_vencidos23,meses_vencidos24,meses_vencidos25,meses_vencidos26,meses_vencidos27,meses_vencidos28,meses_vencidos29,meses_vencidos30,meses_vencidos31,moratorios1,moratorios2,moratorios3,moratorios4,moratorios5,moratorios6,moratorios7,moratorios8,moratorios9,moratorios10,moratorios11,moratorios12,moratorios13,moratorios14,moratorios15,moratorios16,moratorios17,moratorios18,moratorios19,moratorios20,moratorios21,moratorios22,moratorios23,moratorios24,moratorios25,moratorios26,moratorios27,moratorios28,moratorios29,moratorios30,moratorios31
				FROM sd_sdodiario 
				WHERE  fecha = mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month
				and num_credito =pCredito;					  
			END IF;

				/* AAME 20160829 RQI 27 122 SE REALIZARoN EN PROCESO NOCTURNO EL CLONADO DE TABLAS
				--CLONADO DE TABLA DE SD_MAECREDCONT
				INSERT INTO bdicred:sd_maecredcont(fecha, empresa, num_credito, num_producto, ejecutivo, numcte, divisa, sucursal, id_origen, origen, 
				cod_tipo_linea, cod_linea, porc_rec_prop, status_cred, bandera_renovac, bandera_prorroga, periodo_plazo, 
				plazo, fecha_apertura, fecha_vencim, period_pago_cap, period_pag_int, dias_trasp_cap, dias_trasp_int, 
				tasa_fija_o_var, cod_tasa_base, factor_sobretasa, sobretasa, tasa_interes, cod_tasa_mora, sobretasa_mora, 
				fact_sobret_mora, tasa_moratorios, fecha_pago_cap, fecha_pago_int, es_fisica, bandera_fi_fo, codigo_pro, 
				superficie, actividad, cal_edos_fin, tipo_calculo, admite_tlp, rel_garcred, id_unidad_prod, num_aper_ant, 
				rev_tasa_var_per, dia_para_revisar, cod_prod, bandera_ministra, num_fideicomiso, credito_externo, 
				gracia_capital, diferimiento_int, fecha_fin_prorrateo, campo_trab1, campo_trab2, campo_trab3, campo_trab4, 
				calificacion_riesgo, cod_agricola, tasa_base_piso, sobretasa_piso, factor_piso, tasa_piso, tasa_base_techo, 
				sobretasa_techo, factor_techo, tasa_techo, cod_caract, cod_caract_2)
				SELECT fecha, empresa, cSolOro, pProducto, ejecutivo, numcte, divisa, sucursal, id_origen, origen, 
				cod_tipo_linea, cod_linea, porc_rec_prop, status_cred, bandera_renovac, bandera_prorroga, periodo_plazo, 
				plazo, fecha_apertura, fecha_vencim, period_pago_cap, period_pag_int, dias_trasp_cap, dias_trasp_int, 
				tasa_fija_o_var, cod_tasa_base, factor_sobretasa, sobretasa, tasa_interes, cod_tasa_mora, sobretasa_mora, 
				fact_sobret_mora, tasa_moratorios, fecha_pago_cap, fecha_pago_int, es_fisica, bandera_fi_fo, codigo_pro, 
				superficie, actividad, cal_edos_fin, tipo_calculo, admite_tlp, rel_garcred, id_unidad_prod, num_aper_ant, 
				rev_tasa_var_per, dia_para_revisar, cod_prod, bandera_ministra, num_fideicomiso, credito_externo, 
				gracia_capital, diferimiento_int, fecha_fin_prorrateo, campo_trab1, campo_trab2, campo_trab3, campo_trab4, 
				calificacion_riesgo, cod_agricola, tasa_base_piso, sobretasa_piso, factor_piso, tasa_piso, tasa_base_techo, 
				sobretasa_techo, factor_techo, tasa_techo, cod_caract, cod_caract_2
				FROM bdicred:sd_maecredcont
				WHERE empresa=pEmpresa 
				AND num_credito = pCredito;   
				
				--CLONADO DE TABLA de SD_MAESDOSCONT
				INSERT INTO sd_maesdoscont(fecha,empresa,num_credito, fecha_ult_mov,sdo_int_anticip,sdo_int_ant_dev,sdo_intereses,
				sdo_dia_ant_int,sdo_mes_ant_int,sdo_acum_mes_int,sdo_retenido,sdo_acum_cap_int,sdo_exig_int,
				sdo_no_exig,provision_normal,dias_acum_int,sdo_moratorio,sdo_dia_ant_mor,sdo_mes_ant_mor,
				sdo_contab_mora,dias_acum_mora,sdo_capital,sdo_cap_insoluto,sdo_dia_ant_cap,sdo_mes_ant_cap,
				sdo_acum_mes_cap,mto_capitalizado,mto_ministra_cap,cargos_dia_cap,abonos_dia_cap,cargos_mes_cap,
				abonos_mes_cap,dias_acum_cap,monto_vencido,mto_venc_trasp,monto_financiado,monto_reservado,
				sdo_acum_vencido,dias_acum_intper,sdo_global_int,sdo_acum_intper,monto_otorgado,provi_venc_normal,
				provi_venc_anticip,cap_tras_no_venci,mto_venc_int,mto_venc_tra_int,mto_finan_vdo,mto_reser_int,
				mto_fin_ven_trasp,mto_fin_vig_trasp,int_tra_no_exig,sdo_trab4)
				SELECT fecha,empresa,cSolOro, fecha_ult_mov,sdo_int_anticip,sdo_int_ant_dev,sdo_intereses,
				sdo_dia_ant_int,sdo_mes_ant_int,sdo_acum_mes_int,sdo_retenido,sdo_acum_cap_int,sdo_exig_int,
				sdo_no_exig,provision_normal,dias_acum_int,sdo_moratorio,sdo_dia_ant_mor,sdo_mes_ant_mor,
				sdo_contab_mora,dias_acum_mora,sdo_capital,sdo_cap_insoluto,sdo_dia_ant_cap,sdo_mes_ant_cap,
				sdo_acum_mes_cap,mto_capitalizado,mto_ministra_cap,cargos_dia_cap,abonos_dia_cap,cargos_mes_cap,
				abonos_mes_cap,dias_acum_cap,monto_vencido,mto_venc_trasp,monto_financiado,monto_reservado,
				sdo_acum_vencido,dias_acum_intper,sdo_global_int,sdo_acum_intper,monto_otorgado,provi_venc_normal,
				provi_venc_anticip,cap_tras_no_venci,mto_venc_int,mto_venc_tra_int,mto_finan_vdo,mto_reser_int,
				mto_fin_ven_trasp,mto_fin_vig_trasp,int_tra_no_exig,sdo_trab4
				FROM sd_maesdoscont WHERE  empresa= pEmpresa and num_credito =pCredito;

				--CLONADO DE TABLA DE SD_MAESDOSHIST
				INSERT INTO sd_maesdoshist(fecha,
				empresa,num_credito, fecha_ult_mov,sdo_int_anticip,sdo_int_ant_dev,sdo_intereses,
				sdo_dia_ant_int,sdo_mes_ant_int,sdo_acum_mes_int,sdo_retenido,sdo_acum_cap_int,sdo_exig_int,
				sdo_no_exig,provision_normal,dias_acum_int,sdo_moratorio,sdo_dia_ant_mor,sdo_mes_ant_mor,
				sdo_contab_mora,dias_acum_mora,sdo_capital,sdo_cap_insoluto,sdo_dia_ant_cap,sdo_mes_ant_cap,
				sdo_acum_mes_cap,mto_capitalizado,mto_ministra_cap,cargos_dia_cap,abonos_dia_cap,cargos_mes_cap,
				abonos_mes_cap,dias_acum_cap,monto_vencido,mto_venc_trasp,monto_financiado,monto_reservado,
				sdo_acum_vencido,dias_acum_intper,sdo_global_int,sdo_acum_intper,monto_otorgado,provi_venc_normal,
				provi_venc_anticip,cap_tras_no_venci,mto_venc_int,mto_venc_tra_int,mto_finan_vdo,mto_reser_int,
				mto_fin_ven_trasp,mto_fin_vig_trasp,int_tra_no_exig,sdo_trab4)
				SELECT mdy(month(fecha),vDiaCorte,year(fecha)),
				empresa,cSolOro, fecha_ult_mov,sdo_int_anticip,sdo_int_ant_dev,sdo_intereses,
				sdo_dia_ant_int,sdo_mes_ant_int,sdo_acum_mes_int,sdo_retenido,sdo_acum_cap_int,sdo_exig_int,
				sdo_no_exig,provision_normal,dias_acum_int,sdo_moratorio,sdo_dia_ant_mor,sdo_mes_ant_mor,
				sdo_contab_mora,dias_acum_mora,sdo_capital,sdo_cap_insoluto,sdo_dia_ant_cap,sdo_mes_ant_cap,
				sdo_acum_mes_cap,mto_capitalizado,mto_ministra_cap,cargos_dia_cap,abonos_dia_cap,cargos_mes_cap,
				abonos_mes_cap,dias_acum_cap,monto_vencido,mto_venc_trasp,monto_financiado,monto_reservado,
				sdo_acum_vencido,dias_acum_intper,sdo_global_int,sdo_acum_intper,monto_otorgado,provi_venc_normal,
				provi_venc_anticip,cap_tras_no_venci,mto_venc_int,mto_venc_tra_int,mto_finan_vdo,mto_reser_int,
				mto_fin_ven_trasp,mto_fin_vig_trasp,int_tra_no_exig,sdo_trab4
				FROM sd_maesdoshist WHERE  empresa= pEmpresa and num_credito =pCredito;

				--CLONADO DE TABLA DE SD_HIST_RESERVA
				INSERT INTO sd_hist_reserva(empresa, fecha_corte,	num_credito, fecha_cierre,grado_riesgo,
				fecha_apertura,antecedente_buro,status_cred,linea_autorizada,limite_credito,interes_cred_ven,saldo_corte,
				saldo_cierre,pago_minimo,pagos_realizados,
				reserva_int_cred_ven,reserva_buro,reserva_calificacion,porcentaje_reserva,meses_antiguedad,
				probabilidad_incumplimiento,severidad_perdida,exposicion_incumplimiento,impagos_consecutivos,
				impagos_historicos,porcentaje_pago,porcentaje_uso,num_periodos,exposicion_inc_gradual,
				grado_riesgo_gradual,reserva_calificacion_gradual,porcentaje_reserva_gradual,reserva_buro_gradual,
				reserva_int_cred_ven_gradual,reserva_calif_mes_anterior,grado_riesgo_bancoppel,
				grado_riesgo_edo_resultados,reserva_edo_resultados,porcentaje_reserva_edo_resultados,numcte,
				cta_credisolucion,status_fin_mes,saldo_corte2,saldo_corte3,saldo_corte4,pagos_realizados1,
				pagos_realizados2,pagos_realizados3,pagos_realizados4,saldo_corte_credisolucion,
				saldo_cierre_credisolucion,monto_pagar_inst,monto_pagar_rep_sic,ant_acreditado_inst,grado_riesgo_alto,
				grado_riesgo_medio,grado_riesgo_bajo,gveces1,gveces2,gveces3,bkatr)
				SELECT 
				empresa, mdy(month(fecha_corte),vDiaCorte,year(fecha_corte)),
				cSolOro, fecha_cierre,grado_riesgo,fecha_apertura,antecedente_buro,status_cred,
				linea_autorizada,limite_credito,interes_cred_ven,saldo_corte,saldo_cierre,pago_minimo,pagos_realizados,
				reserva_int_cred_ven,reserva_buro,reserva_calificacion,porcentaje_reserva,meses_antiguedad,
				probabilidad_incumplimiento,severidad_perdida,exposicion_incumplimiento,impagos_consecutivos,
				impagos_historicos,porcentaje_pago,porcentaje_uso,num_periodos,exposicion_inc_gradual,
				grado_riesgo_gradual,reserva_calificacion_gradual,porcentaje_reserva_gradual,reserva_buro_gradual,
				reserva_int_cred_ven_gradual,reserva_calif_mes_anterior,grado_riesgo_bancoppel,
				grado_riesgo_edo_resultados,reserva_edo_resultados,porcentaje_reserva_edo_resultados,numcte,
				cta_credisolucion,status_fin_mes,saldo_corte2,saldo_corte3,saldo_corte4,pagos_realizados1,
				pagos_realizados2,pagos_realizados3,pagos_realizados4,saldo_corte_credisolucion,
				saldo_cierre_credisolucion,monto_pagar_inst,monto_pagar_rep_sic,ant_acreditado_inst,grado_riesgo_alto,
				grado_riesgo_medio,grado_riesgo_bajo,gveces1,gveces2,gveces3,bkatr    
				FROM   sd_hist_reserva 
				WHERE  empresa= pEmpresa and num_credito =pCredito;*/

			--EJECUCION PARA LIBERAR EL CARGO RETENIDO	MACM RQM 101584 TDC INFINITE
			IF NVL(dcSdoRetenidoCSG,0) >0 THEN

				UPDATE bdicred:sd_maeretenido SET estatus = 'S' WHERE num_credito = pCredito and estatus = 'P';

			END IF

			
			-- SE GENERA EL FOLIO
			CALL bdicheq:sp_generafolionomina(P_EJECUTIVO) RETURNING cCodRet, vFolio;

			IF CstatusSol IN ('AA','E1') THEN
				-----------------------------------------
				--- PROCESO DE LIQUIDACION DE CREDITO CLASICA---
				-----------------------------------------
				CALL bdicred:sp_liquida_cred_upgrade (pEmpresa,pCredito,vFolio, dcTotalLiqCSG) RETURNING vCodRet;

				IF vCodRet::integer <> 0 THEN
				
					--MACM RQM 101584 TDC INFINITE, Se anexa reverso de operacion
					EXECUTE PROCEDURE reversion(pEmpresa,VV_SUCURSAL,P_EJECUTIVO,
					vFolio, "A")
					INTO  P_ERROR;	
					-- Actualizacion de credito en bitacora de upgrade cuando pase un error
					UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
					WHERE num_credito = pCredito;
					--En caso de error se elimina el registro de la nueva tarjeta
					DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
					DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
					UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
					UPDATE intercard:tarjeta 
					SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
					WHERE numtarjeta = pTarjetaOro;
					DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
					DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;

						IF (LENGTH(TRIM(vCodRet)) == 3) THEN
					      LET cCodRet = '00' || vCodRet;
					    ELSE
							LET cCodRet = vCodRet;
					    END IF;

						LET cMensajeRet='Error en proceso de liquida credito upgrade';
					RETURN cCodRet, cMensajeRet;
				END IF;
			END IF;
				
			-- Actualizacion de credito de oro para relacionarlo con el Credito de clasica
			UPDATE sd_maecred SET credito_externo = pCredito WHERE num_credito = cSolOro;

			/*
			IF pProducto = "5400" THEN
				UPDATE bdicred:sd_tarjeta  SET num_credito = cSolOro, prodtarjeta=pProducto, secuencia=1, status_tar = 'A' WHERE num_tarjeta = pTarjetaOro;
				UPDATE intercard:tarjetacuenta  SET numcuenta = cSolOro WHERE numtarjeta = pTarjetaOro;
				
				if (NVL(Scodproducto,'') <> '') then
					UPDATE intercard:tarjeta SET codproductotarjeta = Scodproducto, CodStatusTarjeta='ACT' WHERE numtarjeta = pTarjetaOro;
				ELSE
					UPDATE intercard:tarjeta SET CodStatusTarjeta='ACT' WHERE numtarjeta = pTarjetaOro;
				end if;
			ELSE*/
			
				-- Actualizacion de tarjeta de clasica por la cuenta de credito Oro
				UPDATE bdicred:sd_tarjeta  SET num_credito = cSolOro, prodtarjeta=pProducto, secuencia=1 WHERE num_tarjeta = pTarjetaOro;
				UPDATE intercard:tarjetacuenta  SET numcuenta = cSolOro WHERE numtarjeta = pTarjetaOro;
				-- Actualiza producto de la tarjeta nueva en intercard INI
						
				if (NVL(Scodproducto,'') <> '') then
					UPDATE intercard:tarjeta SET codproductotarjeta = Scodproducto WHERE numtarjeta = pTarjetaOro;
				end if;				
			--END IF;	
					
			-- Actualiza producto de la tarjeta nueva en intercard FIN
			LET iSecuencia = 2;
			--AAME 20160829 RQI 27 122 Se agrega flujo de Adicionales
			FOREACH WITH HOLD 
			-- AAME 20180821 INC 25 179 Se identifican ctes adicionales y su solicitud de plastico se liga al credito upgrade
				SELECT a.numerotarjeta, a.numcte, b.apell_paterno, b.apell_materno, b.nombre1, b.nombre2, b.rfc, c.fecha_nac 
				INTO cNumtarjadi,cnumcteadi, cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento
				FROM bdicred:sd_credito_upgrade a, bdinteg:si_cliente b, bdinteg:si_ctepf c
				WHERE a.empresa = b.empresa 
				AND a.numcte= b.numcte 
				AND b.numcte = c.numcte
				AND num_credito = pCredito
				AND tipotar='ADI'				
				
				SELECT DM.numtarjeta, DM.IdSolicitud 
				INTO cTarAdicUpgrade, cidsolicitud
				FROM intercard:SolicitudTarjeta ST 
				INNER JOIN intercard:Detalle_Maquila DM ON ST.IdSolicitud=DM.IdSolicitud 
				WHERE ST.IdSolicitud >= 1 AND ST.NumCuenta= pCredito AND ST.numcliente = cnumcteadi;				
				
				--MACM RQM 10 1584 TDC INFINITE, Omitir la cancelacion y agregar el adicional con el nuevo credito
				
				UPDATE sd_tarjeta  SET status_tar='C' WHERE num_tarjeta = cNumtarjadi;
				UPDATE intercard:tarjeta  SET codstatustarjeta='CAN' WHERE numtarjeta = cNumtarjadi;														
				UPDATE intercard:solicitudtarjeta SET numcuenta=cSolOro WHERE idsolicitud = cidsolicitud;
				INSERT INTO sd_adicionalespendientes(empresa,NumCteTitular,NumTarjetaTitular,NumCteAdicional,Credito,Apell_Paterno,Apell_Materno,Nombre1,Nombre2,Rfc,FechaNacimiento,ProductoCredito,TarjetaReposicion)
				VALUES (pEmpresa,cNumcte,pTarjetaOro,cnumcteadi,cSolOro,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,pProducto, '');
			
				
				-- Actualizacion de credito de adicional en bitacora de upgrade
				UPDATE bdicred:sd_credito_upgrade  SET numero_credito_upgrade = cSolOro, numerotarjeta_upgrade= cTarAdicUpgrade, Resultado='1'
				WHERE numerotarjeta = cNumtarjadi;		
				
				LET iSecuencia = iSecuencia +1;
				
			END FOREACH;	
			
			-- Actualizacion de credito en bitacora de upgrade
			UPDATE bdicred:sd_credito_upgrade  SET numero_credito_upgrade = cSolOro, numerotarjeta_upgrade= pTarjetaOro, Resultado='1'
			WHERE numerotarjeta = pTarjeta;

			-- Genera el movimiento por la apertura de la lonea de credito Oro
			EXECUTE PROCEDURE GENMOV( pEmpresa         , cSolOro,
									  pProducto        , 1,
										"001"             , V_FECHA_APERT,
										V_MONTO           , vFolio,
										VV_SUCURSAL       ,VV_DIVISA,
										"0000")
			INTO P_ERROR, P_MENSAJE;
			
			IF P_ERROR::integer <> 0 THEN
				--AAME Se anexa reverso de operacion
				EXECUTE PROCEDURE reversion(pEmpresa,VV_SUCURSAL,P_EJECUTIVO,vFolio, "A")
				INTO  P_ERROR;			
				-- Actualizacion de credito en bitacora de upgrade cuando pase un error
				UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
				WHERE num_credito = pCredito;
				--En caso de error se elimina el registro de la nueva tarjeta
				DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
				DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
				UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
				UPDATE intercard:tarjeta 
				SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
				WHERE numtarjeta = pTarjetaOro;
				FOREACH WITH HOLD 
					SELECT numerotarjeta, numcte 
					INTO cNumtarjadi,cnumcteadi
					FROM bdicred:sd_credito_upgrade
					WHERE num_credito = pCredito
					AND tipotar='ADI'	
					
					SELECT DM.IdSolicitud 
					INTO cidsolicitud
					FROM intercard:SolicitudTarjeta ST 
					INNER JOIN intercard:Detalle_Maquila DM ON ST.IdSolicitud=DM.IdSolicitud 
					WHERE ST.IdSolicitud >= 1 AND ST.NumCuenta= cSolOro AND ST.numcliente = cnumcteadi;		
				
					UPDATE sd_tarjeta  SET status_tar='A' WHERE num_tarjeta = cNumtarjadi;
					UPDATE intercard:tarjeta  SET codstatustarjeta='ACT' WHERE numtarjeta = cNumtarjadi;														
					UPDATE intercard:solicitudtarjeta SET numcuenta=pCredito WHERE idsolicitud =cidsolicitud;
					DELETE FROM sd_adicionalespendientes WHERE empresa='001' AND NumCteTitular = cNumcte AND NumCteAdicional= cnumcteadi AND Credito = cSolOro;																		
				END FOREACH;						
				DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
				DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
				DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
				DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
				DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
				DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;

				LET cCodRet = P_ERROR;
				LET cMensajeRet=P_MENSAJE;
				RETURN cCodRet, cMensajeRet;
			END IF;
			
				--Se revisa si se cuenta con saldo a favor
			IF dcSdoActTotCapCSG < 0 THEN -- Se crea codigo fun y codigo _ ref nuevo
			
				--MOVIMIENTO POR APERTURA CON SALDO A FAVOR 
				EXECUTE PROCEDURE GENMOV( pEmpresa         , cSolOro,
						  pProducto        , 1,
							"075"             , V_FECHA_APERT,
							(dcSdoActTotCapCSG *-1)          , vFolio,
							VV_SUCURSAL       ,VV_DIVISA,
							"0000")
				INTO P_ERROR, P_MENSAJE;
			
				IF P_ERROR::integer <> 0 THEN
					--AAME Se anexa reverso de operacion
					EXECUTE PROCEDURE reversion(pEmpresa,VV_SUCURSAL,P_EJECUTIVO,
					vFolio, "A")
					INTO  P_ERROR;					
					-- Actualizacion de credito en bitacora de upgrade cuando pase un error
					UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
					WHERE num_credito = pCredito;
					--En caso de error se elimina el registro de la nueva tarjeta
					DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
					DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
					UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
					UPDATE intercard:tarjeta 
					SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
					WHERE numtarjeta = pTarjetaOro;
					FOREACH WITH HOLD 
						SELECT numerotarjeta, numcte 
						INTO cNumtarjadi,cnumcteadi
						FROM bdicred:sd_credito_upgrade
						WHERE num_credito = pCredito
						AND tipotar='ADI'	
						
						SELECT DM.IdSolicitud 
						INTO cidsolicitud
						FROM intercard:SolicitudTarjeta ST 
						INNER JOIN intercard:Detalle_Maquila DM ON ST.IdSolicitud=DM.IdSolicitud 
						WHERE ST.IdSolicitud >= 1 AND ST.NumCuenta= cSolOro AND ST.numcliente = cnumcteadi;		
					
						UPDATE sd_tarjeta  SET status_tar='A' WHERE num_tarjeta = cNumtarjadi;
						UPDATE intercard:tarjeta  SET codstatustarjeta='ACT' WHERE numtarjeta = cNumtarjadi;														
						UPDATE intercard:solicitudtarjeta SET numcuenta=pCredito WHERE idsolicitud =cidsolicitud;
						DELETE FROM sd_adicionalespendientes WHERE empresa='001' AND NumCteTitular = cNumcte AND NumCteAdicional= cnumcteadi AND Credito = cSolOro;																		
					END FOREACH;								
					DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
					DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;
					

					LET cCodRet = P_ERROR;
					LET cMensajeRet=P_MENSAJE;
					RETURN cCodRet, cMensajeRet;
				END IF;
					/*--movimiento por CANCELACION del saldo a favor del credito anterior
				   EXECUTE PROCEDURE genmov(pEmpresa, pCredito, V_PRODUCTO, 113,
											'002', V_FECHA_APERT, (dcSdoActTotCapCSG *-1), vFolio, VV_SUCURSAL,
											VV_DIVISA, "0000"
											) INTO P_ERROR, P_MENSAJE;


					IF P_ERROR::integer <> 0 THEN
						-- Actualizacion de credito en bitacora de upgrade cuando pase un error
						UPDATE bdicred:sd_credito_upgrade  SET Resultado='2'
						WHERE num_credito = pCredito;
						LET cCodRet = "000" || P_ERROR;
						RETURN cCodRet, cMensajeRet;
					END IF;		*/
			END IF;

			
			IF dcTotalLiqCSG > 0 THEN -- Se crea codigo fun y codigo _ ref nuevo
				--MACM RQM 10 1584 TDC INFINITE, se agregan los codigo ref de los productos 8100 y 7000
				IF V_PRODUCTO = "8100" THEN
					LET cod_ref = 134;
				ELIF V_PRODUCTO = "7000" THEN
					LET cod_ref = 135;
				ELIF V_PRODUCTO = "6001" THEN
					LET cod_ref = 112;
				ELIF V_PRODUCTO = "8500" THEN
					LET cod_ref = 124;
				END IF;
				--RQI Cambio de producto de grupo Coppel a oro/platino 
				--	IF V_PRODUCTO = 8500 THEN   --se evalua el producto en V_PRODUCTO, si corresponde al 8500 se genera el mivimiento  
				--								--con el codigo_ref = 124 si no se genera el movimiento con el codigo_ref =  112.
				--								
				--		-- Se realiza el cargo del movimiento del total del adeudo
						EXECUTE PROCEDURE GENMOV( 
							pEmpresa , cSolOro, pProducto, cod_ref,
								"002", V_FECHA_APERT,(dcTotalLiqCSG *1),
								vFolio,	VV_SUCURSAL, VV_DIVISA,
								"0000")
					INTO P_ERROR, P_MENSAJE;				
				--ELSE
				--
				--	-- Se realiza el cargo del movimiento del total del adeudo
				--		EXECUTE PROCEDURE GENMOV( 
				--			pEmpresa , cSolOro, pProducto, 112,
				--				"002", V_FECHA_APERT,(dcTotalLiqCSG *1),
				--				vFolio,	VV_SUCURSAL, VV_DIVISA,
				--				"0000")
				--	INTO P_ERROR, P_MENSAJE;
				--
				--END IF;

				IF P_ERROR::integer <> 0 THEN
					--AAME Se anexa reverso de operacion
					EXECUTE PROCEDURE reversion(pEmpresa,VV_SUCURSAL,P_EJECUTIVO,
					vFolio, "A")
					INTO  P_ERROR;					
					-- Actualizacion de credito en bitacora de upgrade cuando pase un error
					UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
					WHERE num_credito = pCredito;
					--En caso de error se elimina el registro de la nueva tarjeta
					DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
					DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
					UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
					UPDATE intercard:tarjeta 
					SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
					WHERE numtarjeta = pTarjetaOro;
					FOREACH WITH HOLD 
						SELECT numerotarjeta, numcte 
						INTO cNumtarjadi,cnumcteadi
						FROM bdicred:sd_credito_upgrade
						WHERE num_credito = pCredito
						AND tipotar='ADI'	
						
						SELECT DM.IdSolicitud 
						INTO cidsolicitud
						FROM intercard:SolicitudTarjeta ST 
						INNER JOIN intercard:Detalle_Maquila DM ON ST.IdSolicitud=DM.IdSolicitud 
						WHERE ST.IdSolicitud >= 1 AND ST.NumCuenta= cSolOro AND ST.numcliente = cnumcteadi;		
					
						UPDATE sd_tarjeta  SET status_tar='A' WHERE num_tarjeta = cNumtarjadi;
						UPDATE intercard:tarjeta  SET codstatustarjeta='ACT' WHERE numtarjeta = cNumtarjadi;														
						UPDATE intercard:solicitudtarjeta SET numcuenta=pCredito WHERE idsolicitud =cidsolicitud;
						DELETE FROM sd_adicionalespendientes WHERE empresa='001' AND NumCteTitular = cNumcte AND NumCteAdicional= cnumcteadi AND Credito = cSolOro;																		
					END FOREACH;							
					DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
					DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;
					LET cCodRet = P_ERROR;
					LET cMensajeRet=P_MENSAJE;
					RETURN cCodRet, cMensajeRet;
				END IF;
			END IF;
			
			--EJECUCION PARA APLICAR EL CARGO RETENIDO AL NUEVO CREDITO MACM RQM 101584 TDC INFINITE
			
			IF NVL(dcSdoRetenidoCSG,0) >0 THEN
			
				INSERT INTO bdicred:sd_maeretenido(empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)			
				SELECT empresa,cSolOro,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,'P',referencia,sucursal,dias_ori
				FROM bdicred:sd_maeretenido
				WHERE num_credito = pCredito and estatus = 'S';
				
			END IF
			
			foreach
				select num_tarjeta
				into vtarjeta
				from bdicred:sd_tarjeta
				where empresa=pEmpresa
				and num_credito=pCredito
				and tipo_tarjeta<>'0'
				and status_tar <> 'C'

				select codproductotarjeta
				into cproducto
				from intercard:tarjeta
				where numtarjeta=vtarjeta;

				execute procedure intercard:sp_cancelacion_tarjeta
				(vtarjeta,cproducto,'informix') INTO cCodRet, cMensajeRet;

				if cCodRet='001' or cCodRet='002' then
					LET cCodRet = '00000';
					LET cMensajeRet= "PROCESO EXITOSO";
				end if;
			end foreach;
			
			-- JRVT INC 04/11/2024 VERIFICA QUE EL CREDITO NO TENGA MSI O CREDISOLUCIONES PENDIENTES PARA HACER EL UPGRADE
			--Estatus Credisoluciones: 0  Pendiente                               
			--Estatus Credisoluciones: 1  Estatus de paso sp_compra_promo         
			--Estatus Credisoluciones: 2  Aperturado / Vigente        
			-- *************************************		
			SELECT COUNT(num_credito) INTO sExistePromo FROM sd_promocion_credito WHERE empresa = '001' and status = '0' AND num_credito = pCredito; 
			
			IF NVL(sExistePromo,0) = 0 THEN 
				SELECT COUNT(a.num_credito) INTO sExistePromo 
				FROM sd_promocion_credito a
				INNER JOIN sd_maecredcrd b ON a.empresa = b.empresa AND a.num_sol_prestamo = b.num_credito
				WHERE (a.status IN ('1','2') AND b.status_cred IN ('E1','E2','E3')) AND a.num_credito = pCredito; 
			END IF;
			
			IF NVL(sExistePromo, 0) > 0 THEN
				LET cCodRet='000005';
				LET cMensajeRet = 'La cuenta tiene credisolucion o msi activa,no se permite Mejora de Producto.';
				-- Actualizacion de credito en bitacora de upgrade cuando pase un error
				UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
				WHERE num_credito = pCredito;
				--En caso de error se elimina el registro de la nueva tarjeta
				DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
				DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
				UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
				UPDATE intercard:tarjeta 
				SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
				WHERE numtarjeta = pTarjetaOro;
				DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
				DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
				DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
				DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
				DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
				DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;
	
				RETURN cCodRet, cMensajeRet;
			END IF;

		ELIF CstatusSol='FF' THEN
			LET cCodRet='00007';
			LET cMensajeRet ='La cuenta se encuentra liquidada, por favor verifique';
			-- Actualizacion de credito en bitacora de upgrade cuando pase un error
			UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
			WHERE num_credito = pCredito;
			--En caso de error se elimina el registro de la nueva tarjeta
			DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
			DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
			UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
			UPDATE intercard:tarjeta 
			SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
			WHERE numtarjeta = pTarjetaOro;				
			DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
			DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
			DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
			DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
			DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
			DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;

			RETURN cCodRet, cMensajeRet;
			--MACM RQM 10 1584 TDC INFINITE, SE QUITA VALIDACION DE SALDO RETENIDO
		--/*ELIF NVL(dcSdoRetenidoCSG,0) >0 AND cNumCreditoCSG <> '' THEN
		/*ELIF NVL(sExistePromo, 0) > 0 THEN
			LET cCodRet='000005';
			LET cMensajeRet = 'La cuenta tiene credisolucion o msi activa,no se permite Mejora de Producto.';
			-- Actualizacion de credito en bitacora de upgrade cuando pase un error
			UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
			WHERE num_credito = pCredito;
			--En caso de error se elimina el registro de la nueva tarjeta
			DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
			DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
			UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
			UPDATE intercard:tarjeta 
			SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
			WHERE numtarjeta = pTarjetaOro;
			DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
			DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
			DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
			DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
			DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
			DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;

			RETURN cCodRet, cMensajeRet;*/
		--ELIF CstatusSol <> 'AA' THEN
--		ELIF (CstatusSol <> 'AA' OR (NVL(cAct,-1)>0 and CstatusSol<> 'E1')) THEN
		ELSE
			LET cCodRet='00006';
			LET cMensajeRet ='La cuenta se encuentra con atraso, o no esta vigente';
			-- Actualizacion de credito en bitacora de upgrade cuando pase un error
			UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
			WHERE num_credito = pCredito;
			--En caso de error se elimina el registro de la nueva tarjeta
			DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
			DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
			UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
			UPDATE intercard:tarjeta 
			SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
			WHERE numtarjeta = pTarjetaOro;
			DELETE FROM bdicred:sd_maecred WHERE empresa = '001' AND num_credito = cSolOro;
			DELETE FROM bdicred:sd_maesdos WHERE empresa = '001' AND num_credito = cSolOro;
			DELETE FROM bdicred:sd_maecredanexo WHERE empresa = '001' AND num_credito = cSolOro;
			DELETE FROM bdicred:sd_amortiza_credito WHERE empresa = '001' AND num_credito = cSolOro;
			DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
			DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;

			RETURN cCodRet, cMensajeRet;
		END IF;
	END IF;
ELSE 
	-- Actualizacion de credito en bitacora de upgrade cuando se trata de una reposicion de tarjeta personalizada
		UPDATE bdicred:sd_credito_upgrade SET numerotarjeta_upgrade= pTarjetaOro, Resultado='1'
		WHERE numerotarjeta = pTarjeta;
END IF;

IF (LENGTH(TRIM(cCodRet)) == 3) THEN
	LET cCodRet = '00' || cCodRet;
END IF;

RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para liquidar el credito de TDC clasica y crear el credito para TDC ORO que se ejecutaro',
'desde el de Reposicion de Tarjeta',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 22/02/2016',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consultacuenta(pEmpresa CHAR(3), pNumCuenta CHAR(20))

RETURNING CHAR(6)  AS codigo_error,
          CHAR(80) AS mensaje_error, 
          CHAR(3)  AS empresa, 
          CHAR(20) AS num_cuenta, 
          CHAR(20) AS num_cliente,
          CHAR(50) AS nombre_cliente,          
          CHAR(4)  AS sucursal, 
          CHAR(30) AS bloqueo,
          CHAR(50) AS causa,          
          CHAR(2)  AS status, 
          DATE     AS fecha_apertura;

--31/10/2008
--Abraham Ayala Aguilar
--Busca una cuenta para revisar si la cuenta esta bloqueada o no esta bloqueada.

--05/11/2008
--Rodolfo Tortolero Varela
--Se modifico la consulta para obtener la descripciÃ²n del tipo de bloqueo.

--06/11/2008
--Rodolfo Tortolero Varela
--Se agrego una consulta para checar si el campo id_unidad_prod es nulo
--de ser asi su actualiza con un '0'.

--18/11/2008
--Rodolfo Javier Tortolero Varela
--Se modifico el codigo de la consulta.

--08/01/2009
--Roque Enrique Solis CampaÃ±a
--Se quitÃ³ el update al campo d_unidad_prod y los retornos se hicieron de 6 digitos

-- Fecha: 14/01/2009
-- ModificÃ³: Roque Enrique Solis CampaÃ±a
-- Observaciones/Comentario: Se modifica para realizar la consulta
--en base a la fecha de bloqueo y no a la
--fecha de apertura del credito.

--04/05/2009
-- ModificÃ³: Roque Enrique Solis CampaÃ±a
--Se agrego la causa del bloqueo

--DEFINICION DE VARIABLES--
    DEFINE iSqlErr        INTEGER;
    DEFINE iIsamErr       INTEGER;
    DEFINE cErrorInfo     CHAR(80);
    DEFINE cCodRet        CHAR(6);
    DEFINE vCodRet        CHAR(6);
    DEFINE cMensajeRet    CHAR(80);
    DEFINE vNumCte        CHAR(20);
    DEFINE vSucursal      CHAR(4);
    DEFINE vDescripcion   CHAR(30);
    DEFINE vStatusCredito CHAR(2);
    DEFINE vFechaApertura DATE;
    DEFINE vCodSP         CHAR(6);
    DEFINE cCausa         CHAR(50);
    DEFINE vID            INTEGER;
    DEFINE cCodCausa      CHAR(2);
    DEFINE cNombre        CHAR(50);
    DEFINE cCredBitacora  CHAR(20);
    --Set debug file to '/home/e10000315/bloqueo/sp_consultacuentas.out';
    --trace on;
    
    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
               IF iSqlErr != 0 THEN
                  LET cCodRet= iSqlErr;
                  LET cMensajeRet= cErrorInfo;
                 RETURN vCodRet, cMensajeRet, pEmpresa, pNumCuenta, vNumCte,cNombre, vSucursal, 
                        vDescripcion, cCausa , vStatusCredito, vFechaApertura; 
               END IF;
       END EXCEPTION;
        
    
--INICIALIZACION DE VARIABLES--
        LET vCodRet        = '999999';    --No existe el cliente
        LET vNumCte        = '';
        LET vSucursal      = '';
        LET vDescripcion   = '';
        LET vStatusCredito = '';
        LET vFechaApertura = DATE(1);
        LET vID            = 0;
        LET cCausa         = '';
        LET cCodCausa      = '';
        LET iIsamErr       = 0;
        LET cErrorInfo     = '';
        LET cCodRet        = '';
        LET cmensajeret    = '';
        LET cNombre        = '';
        LET cCredBitacora  = '';

        
        IF pEmpresa IS NULL AND (pNumCuenta IS NULL OR pNumCuenta ='') THEN
        
            LET vCodRet = '000001';    --Faltan valores
            LET cMensajeRet="Faltan valores para ejecutar el proceso";
        ELSE    
        
            EXECUTE PROCEDURE bdicred:sp_validacredito (pEmpresa, pNumCuenta) INTO vCodSP;
            
            IF vCodSP <> '000000' THEN
               LET vCodRet = '000002';    --Faltan valores
               LET cMensajeRet="La cuenta no es valida";
            ELSE
                 LET vCodRet = '000000';    --Cliente encontrado
                SELECT id_unidad_prod, cod_caract_2 
                  INTO vID, cCodCausa
                  FROM "informix".sd_maecred
                 WHERE empresa = pEmpresa 
                   AND num_credito = pNumCuenta;
                   
                IF (vID IS NULL AND cCodCausa IS NOT NULL)  THEN --OR (vID IS NOT NULL AND cCodCausa IS NULL) THEN
                     LET vCodRet= '000003';
                     LET cMensajeRet= 'CrÃ©dito bloqueado manualmente, favor de verificar'; 
                     
                END IF;
                IF vID IS NOT NULL AND (cCodCausa IS NOT NULL OR cCodCausa IS  NULL) THEN
                   LET vCodRet= '000004';
                   LET cMensajeRet= 'El crÃ©dito ya ha sido bloqueado, no sera posible bloquear nuevamente';
                END IF;
                
                SELECT cuenta
                  INTO cCredBitacora
                  FROM "informix".sd_bitacorabloqueocta
                 WHERE cuenta=pNumCuenta
                   AND cve_bloqueo=vID
                   AND nvl(cve_causa,'')=nvl(cCodCausa,'')
                   AND id=(SELECT max(id)
                             FROM "informix".sd_bitacorabloqueocta
                            WHERE cuenta=pNumCuenta
                              AND cve_bloqueo=vID
                              AND nvl(cve_causa,'')=nvl(cCodCausa,''));
                              
                IF cCredBitacora IS NULL AND vID IS NOT NULL THEN  
                    LET vCodRet = '000006';    --La cuenta ya esta desbloqueada.
                    LET cMensajeRet= 'Credito desbloqueado manualmente, favor de verificar';
                END IF;
                
                SELECT cte.numcte, 
                       CASE WHEN NVL(cte.razon_social,'') ='' THEN TRIM(cte.nombre1) || " " || TRIM(cte.nombre2) || " " || TRIM(cte.apell_paterno) || " " || TRIM(cte.apell_materno) ELSE cte.razon_social END,  
                       cte.sucursal, 
                       blo.descripcion,  
                       mae.status_cred, 
                       btc.fecha, 
                       ca.causa_bloq 
                  INTO vNumCte,cNombre, vSucursal, vDescripcion, vStatusCredito, vFechaApertura, cCausa
                  FROM bdicred:sd_maecred mae 
                  LEFT OUTER JOIN bdinteg:si_cliente cte ON (mae.numcte = cte.numcte)
                  LEFT OUTER JOIN bdicred:sd_bloqueoscuenta  blo ON  (mae.id_unidad_prod = blo.clave)
                  LEFT OUTER JOIN bdicred:sd_bitacorabloqueocta btc ON (mae.num_credito= btc.cuenta AND btc.id=(SELECT MAX(b.id) 
                                                                                                                   FROM sd_bitacorabloqueocta b 
                                                                                                                   WHERE b.cuenta=mae.num_credito))
                  LEFT OUTER JOIN bdicred:sd_causa_bloqueo ca ON (ca.cod_causa =mae.cod_caract_2 AND mae.empresa=ca.empresa)
                 WHERE mae.empresa = pEmpresa 
                   AND mae.num_credito = pNumCuenta;                 
                                
            
                IF vNumCte IS NULL THEN
                    let vNumCte = '';
                END IF;

                IF vSucursal IS NULL THEN
                    let vSucursal = '';
                END IF;

                IF vDescripcion IS NULL AND vID IS NOT NULL THEN
                    let vDescripcion = 'Tipo de bloqueo desconocido';
                ELIF vDescripcion IS NULL AND vID IS NULL THEN
                    let vDescripcion = 'No tiene bloqueo';
                END IF
                
                IF cCausa IS NULL AND cCodCausa IS NOT NULL THEN
                   LET cCausa='Motivo de restricciÃ³n desconocido'; --
                ELIF cCausa IS NULL AND cCodCausa IS NULL THEN
                    LET cCausa='No tiene motivo de restricciÃ³n'; 
                END IF;
                
                IF vStatusCredito IS NULL THEN
                    let vStatusCredito = '';
                END IF;

                IF vFechaApertura IS NULL THEN
                    let vFechaApertura = DATE(1);
                END IF;
                
                IF vStatusCredito='CV'    THEN
                    LET vCodRet='000002';
                    LET cMensajeRet = 'CrÃ©dito en cartera vendida';
                    RETURN vCodRet, cMensajeRet, pEmpresa, pNumCuenta, vNumCte,cNombre, vSucursal, 
                           vDescripcion, cCausa , vStatusCredito, vFechaApertura; 
                END IF;
                
                
            END IF;        END IF;        
        RETURN vCodRet, cMensajeRet, pEmpresa, pNumCuenta, vNumCte,cNombre, vSucursal, 
               vDescripcion, cCausa , vStatusCredito, vFechaApertura; 
    END;
END PROCEDURE;