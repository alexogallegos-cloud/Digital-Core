CREATE PROCEDURE "informix".sp_consultadatos_motor_precal (o_empresa CHAR(3), o_producto CHAR(4), o_num_cliente CHAR(20), o_num_referencia CHAR(20), o_bandera CHAR(1), iCanal INTEGER, pEjecucion CHAR(1))
RETURNING CHAR(5) AS CodRet,
		CHAR(20) AS solicitudBancoppel,
		CHAR(20) AS clienteBancoppel,
		CHAR(20) AS clienteCoppel,
		CHAR(3) AS empresa,
		CHAR(2) AS estatusSolicitud,
		CHAR(3) AS causaRechazo,
		CHAR(4) AS producto,
		CHAR(1) AS grupo,
		CHAR(1) AS tipoSolicitud,
		CHAR(1) AS banderaINE,
		CHAR(2) AS habitaEn,
		CHAR(3) AS puntualidad,
		CHAR(3) AS profesion,
		INTEGER AS numCreditosDigitalesActivos,
		INTEGER AS idActividad,
		CHAR(120) AS descripActividad,
		INTEGER AS idSubActividad,
		CHAR(120) AS descripSubActividad,
		CHAR(1) AS situacionEspecialCoppel,
		INTEGER AS causaSitEspecialCoppel,
		CHAR(1) AS motivoRechazo,
		CHAR(1) AS motivoRechazoBcpl,
		CHAR(1) AS tipoRechazo,
		CHAR(300) AS descripcionMotivo,
		INTEGER AS totalVencido,
		INTEGER AS abonoTotal,
		DECIMAL(14,2) AS abonoVencidoTotal,
		INTEGER AS mesesHistoria,
		CHAR(20) AS clienteCoppelExcepcion,
		INTEGER AS numCuentasStatusCV,
		DECIMAL(18,2) AS maxSdoVencidoBancoppel,
		DECIMAL(5,2) AS eficiencia,
		INTEGER AS numCreditosEstatusFC,
		INTEGER AS numCreditosEstatusFF,
		INTEGER AS sitEspecialRiesgoD_sinCCFF,
		INTEGER AS sitEspecialRiesgoE_sinCCFF,
		INTEGER AS sitEspecialRiesgoC_CCFF,
		DECIMAL(18,2) AS maxMontoReservaRiesgoC_sinCCFF,
		INTEGER AS creditosStatusDiferenteFF,
		DECIMAL(18,2) AS maxsaldovencidoCRD,
		INTEGER AS numCuentasStatusCVsinFF,
		INTEGER AS numEstatusFFproducto6011,
		INTEGER AS sitEspecialRiesgoD_sinFF,
		INTEGER AS sitEspecialRiesgoE_sinFF,
		INTEGER AS sitEspecialRiesgoC_sinFF,
		DECIMAL(18,2) AS maxMontoReservaRiesgoC_sinFF,
		DATE AS minFechaAperturasinFF,
		DATE AS minFechaApertura,
		CHAR(1) AS SitEspecialBancoppel,
		DATE AS maxFechaAperturaDelProducto,
		CHAR(4) AS v_producto,
		DECIMAL(6,2) AS minProcentajeProductoMasReciente,
		INTEGER AS abonoMuebles,
		INTEGER AS abonoPrestamos,
		INTEGER AS abonoRopa,
		INTEGER AS abonoTiempoAire,
		INTEGER AS abonoAfiliados,
		INTEGER AS abonoRestructura,
		INTEGER AS vencidoMuebles,
		INTEGER AS vencidoRopa,
		INTEGER AS vencidoPrestamos,
		INTEGER AS vencidoTiempoAire,
		INTEGER AS vencidoAfiliados,
		INTEGER AS vencidoReestructura,
		CHAR(13) AS fechaUltimoPago,
		CHAR(17) AS flagPrestamos,
		CHAR(1) AS origen,
		CHAR(120) AS cDescripcion,
		CHAR(1) AS cRiesgoViviendaCpl,
		CHAR(1) AS cRiesgoViviendaBcpl,
		CHAR(1) AS cActRiesgoCpl,
		CHAR(1) AS cActRiesgoBCpl,
		CHAR(120) AS cDescpRiesgo,
		CHAR(1) AS pejecucion,
		CHAR(2) AS s_tipper,
		CHAR(20) AS s_referen1,
		CHAR(110) AS s_nomrefer1,
		CHAR(20) AS s_referen2,
		CHAR(110) AS s_nomrefer2,
		CHAR(1) AS s_sexo,
		CHAR(1) AS s_edocivil,
		INTEGER AS s_edad,
		CHAR(3) AS s_puesto,
		INTEGER AS s_creditos,
		CHAR(13) AS s_tel_ref_1,
		CHAR(13) AS s_tel_ref_2,
		CHAR(2) AS s_parentesco1,
		CHAR(2) AS s_parentesco2,
		CHAR(20) AS s_cteref,
		CHAR(300) AS cMensaje;

DEFINE isql_err 					INTEGER; --Error INFORMIX
DEFINE cCodRet  					CHAR(5); --CÃÂÃÂ³digo de Retorno SP
DEFINE cNumCteBanco 				CHAR(20); --Cliente BanCoppel
DEFINE cNumCteCoppel    			CHAR(20); --Cliente Coppel
DEFINE cProducto    				CHAR(4); --Numero de producto
DEFINE cGrupo   					CHAR(1); --Grupo de evaluaciÃÂÃÂ³n al cual pertenece la solicitud
DEFINE cTpSol   					CHAR(1); --Tipo de solicitud
DEFINE cFlagINE 					CHAR(1); --Bandera Validacion INE
DEFINE cHabita_en  					CHAR(2); --Tipo de vivienda del cliente
DEFINE cPuntualidad 				CHAR(3); --ClasicficaciÃÂÃÂ³n asignada al cliente Coppel como resultado de su comportamiento de pago en todas sus cuentas
DEFINE cProfesion  					CHAR(3); --ProfesiÃÂÃÂ³n del Cliente
DEFINE iCreditosDigitales   		INTEGER; --NÃÂÃÂºmero de crÃÂÃÂ©ditos digitales activos
DEFINE iAct 						INTEGER; --Id de actividad
DEFINE cDescpAct    				CHAR(120); --Descripcion de actividad
DEFINE iSubAct  					INTEGER;  --Id Sub Actividad
DEFINE cDescpSubAct    				CHAR(120); --Descripcion de Sub Actividad
DEFINE cSitEspCoppel 				CHAR(1); --SituaciÃÂÃÂ³n especial Coppel
DEFINE iCausaSitEspCpl  			INTEGER; --Causa sitaucion especial Coppel
DEFINE cMotivoRechCpl   			CHAR(1); --Motvo de rechazo Coppel
DEFINE cMotivoRechBcpl  			CHAR(1); --Motivo de rechazo BanCoppel
DEFINE cTipoRechazo 				CHAR(1); --Tipo de Rechazo
DEFINE cDescripcionRechazo  		CHAR(300); --Descripcion del Rechazo
DEFINE iTotalVencido    			INTEGER; --total vencido de las cuentas Coppel
DEFINE iAbonoTotal  				INTEGER; --Abono total de las cuentas Coppel
DEFINE dAbonoVencidototal   		DECIMAL(14,2); --Abono vencido total vencido de las cuentas Coppel
DEFINE iMeses_historia  			INTEGER; --Tiempo que tiene el cliente con experiencia crediticia en Coppel
DEFINE cExcepcionCoppel 			CHAR(20); --Numero de cliente coppel que presenta excepciÃÂÃÂ³n
DEFINE iCuentasCV   				INTEGER; --NÃÂÃÂºmero de cuentas que tienen estatus CV ( crÃÂÃÂ©dito vendido Bancoppel) sin considerar estatus CC,FF
DEFINE dMaxSaldoVencido 			DECIMAL(18,2); --MÃÂÃÂ¡ximo saldo vencido de sus cuentas Bancoppel sin considerar status CC,FF
DEFINE dEficienciaCoppel    		DECIMAL(5,2); --Calculo que realiza el sistema de historial de pagos del cliente Coppel
DEFINE iCredEstatusFC   			INTEGER; --CrÃÂÃÂ©ditos con estatus FC
DEFINE iCredEstatusCCnoFF   		INTEGER; --CrÃÂÃÂ©ditos con estatus FC en maecred y que no tienen  FF en maecredcrd
DEFINE iCredRiesgoD_sinCCFF  		INTEGER; --Creditos con status (AA o E1) Y Saldo vencido = 0 y Grado de riesgo = D
DEFINE iCredRiesgoE_sinCCFF 		INTEGER; --Creditos con status (AA o E1) Y Saldo vencido = 0 y Grado de riesgo = E
DEFINE iCredRiesgoC_CCFF    		INTEGER; --Creditos con status (AA o E1) Y Saldo vencido = 0 y Grado de riesgo = C
DEFINE dMaxMtoResrvRiesgoC_sinCCFF  DECIMAL(18,2); --Max monto reserva para (creditos con status (AA o E1) Y Saldo vencido =0 y Grado de riesgo= C)
DEFINE iCredStatusDifFF 			INTEGER; --CrÃÂÃÂ©ditos con estatus diferente de FF en sd_maecredcrd
DEFINE dMaxSaldoVencidoCRD  		DECIMAL(18,2); --MÃÂÃÂ¡ximo saldo vencido de los creditdos con estatus distinto FF y producto <> 6011 en sd_maecredcrd
DEFINE iCuentasStatusCVsinFF    	INTEGER; --NÃÂÃÂºmero de cuentas que tienen estatus CV ( crÃÂÃÂ©dito vendido Bancoppel) sin considerar estatus FF en sd_maecredcrd
DEFINE iCuentasStatusFF6001 		INTEGER; --NÃÂÃÂºmero de cuentas con estatuus <> FF y producto = 6011 en sd_maecredcrd
DEFINE iCredRiesgoD_sinFF   		INTEGER; --NÃÂÃÂºmero de creditos con status (AA o E1) Y Saldo vencido =0 y Grado de riesgo= D en sd_maecredcrd
DEFINE iCredRiesgoE_sinFF   		INTEGER; --NÃÂÃÂºmero de creditos con status (AA o E1) Y Saldo vencido =0 y Grado de riesgo= E en sd_maecredcrd
DEFINE iCredRiesgoC_sinFF   		INTEGER; --NÃÂÃÂºmero de creditos con status (AA o E1) Y Saldo vencido =0 y Grado de riesgo= C en sd_maecredcrd
DEFINE dMaxMtoResrvRiesgoC_sinFF  	DECIMAL(18,2); --Max monto reserva para (creditos con status (AA o E1) Y Saldo vencido =0 y Grado de riesgo= C) en sd_maecredcrd
DEFINE dtMinFechaAperturasinFF  	DATE; --MÃÂÃÂ­nima fecha de apertura de las cuentas que no son FFen sd_maecredcrd
DEFINE dtMinFechaApertura   		DATE; --MÃÂÃÂ­nima fecha de apertura que tenga el cliente 
DEFINE cSituacion   				CHAR(1); --Situacion del producto de porcentaje mÃÂÃÂ¡s bajo y si existe empate se toma el mÃÂÃÂ¡s reciente 
DEFINE dtFecha_apert    			DATE; --MÃÂÃÂ¡xima fecha de apertura del producto de porcentaje mÃÂÃÂ¡s bajo y si existe empate se toma el mÃÂÃÂ¡s reciente , no son CC, FF
DEFINE dPorcentaje					DECIMAL(6,2); --Porcentaje del producto mÃÂÃÂ¡s reciente 
DEFINE iAbonoMuebles        		INTEGER;
DEFINE iAbonoRopa           		INTEGER;
DEFINE iAbonoPrestamos      		INTEGER;	
DEFINE iAbonoAire         			INTEGER;
DEFINE iAbonoAfiliados      		INTEGER;
DEFINE iAbonoReestructura   		INTEGER;
DEFINE iVencidoMuebles     			INTEGER;
DEFINE iVencidoRopa         		INTEGER;
DEFINE iVencidoPrestamos    		INTEGER;
DEFINE iVencidoAire      			INTEGER;
DEFINE iVencidoAfiliados    		INTEGER;
DEFINE iVencidoReestructura 		INTEGER;
DEFINE cOrigen						CHAR(1);
DEFINE cDescripcion					CHAR(120);
DEFINE cRiesgoViviendaCpl   		CHAR(1);
DEFINE cRiesgoViviendaBcpl  		CHAR(1);
DEFINE cActRiesgoCpl        		CHAR(1);
DEFINE cActRiesgoBCpl				CHAR(1);
DEFINE cDescpRiesgo					CHAR(120);
DEFINE dtFecha               		DATE;
DEFINE cNomcte						CHAR(120);
DEFINE iCteLargo 					INTEGER;
DEFINE cRFC							CHAR(13);
DEFINE cFechaUltimoPago 			CHAR(13); 
DEFINE cCodigoRet 					CHAR(6);
DEFINE cPrestamoAutorizado 			CHAR(1); 
DEFINE iMontoAutorizado 			CHAR(17); 
DEFINE iReprestamo 					CHAR(17); 
DEFINE cSolBanco					CHAR(20);
DEFINE cStatusSol					CHAR(2);
DEFINe cCausaRechSol				CHAR(3);
DEFINE cNumcred						CHAR(20);
DEFINE cStatus_cred					CHAR(2);
DEFINE dtFechaAper         			DATE;
DEFINE dSdo_vencidocrd      		DECIMAL(18,2);
DEFINE dSdo_vencido					DECIMAL(18,2);
DEFINE dtMaxFechaCorte      		DATE;
DEFINE cGrado_riesgo        		CHAR(2);
DEFINE dMto_reserva         		DECIMAL(18,2);
DEFINE cValidaINE					CHAR(20);
DEFINE cCredExterno					CHAR(20);
DEFINE iCredCrd						CHAR(20);

DEFINE s_tipper             		CHAR(2);
DEFINE s_referen1           		CHAR(20);
DEFINE s_nomrefer1          		CHAR(110);
DEFINE s_referen2           		CHAR(20);
DEFINE s_nomrefer2          		CHAR(110);
DEFINE s_sexo               		CHAR(1);
DEFINE s_edocivil           		CHAR(1);
DEFINE s_edad               		INTEGER;
DEFINE s_puesto             		CHAR(3);
DEFINE s_creditos           		INTEGER;
DEFINE s_tel_ref_1          		CHAR(13);
DEFINE s_tel_ref_2          		CHAR(13);
DEFINE s_parentesco1        		CHAR(2);
DEFINE s_parentesco2        		CHAR(2);
DEFINE s_cteref             		CHAR(20);
DEFINE v_paramref           		INTEGER;
DEFINE cMensaje             		CHAR(300);
DEFINE v_nroref             		INTEGER;

LET isql_err    				= 0;
LET cCodRet 					= "00000";
LET cNumCteBanco    			= "";
LET cCredExterno				= "";
LET cNumCteCoppel   			= "";
LET cProducto  					= "";
LET cGrupo  					= "";
LET cTpSol  					= "?";
LET cFlagINE    				= "";
LET cHabita_en  				= "??";
LET cPuntualidad    			= "";
LET cProfesion  				= "";
LET iCreditosDigitales  		= 0;
LET iAct    					= 0;
LET cDescpAct   				= "";
LET iSubAct 					= 0;
LET cDescpSubAct    			= "";
LET cSitEspCoppel   			= "?";
LET iCausaSitEspCpl 			= 0;
LET cMotivoRechCpl  			= "";
LET cMotivoRechBcpl 			= "";
LET cTipoRechazo    			= "";
LET cDescripcionRechazo 		= "";
LET iTotalVencido   			= 0;
LET iAbonoTotal	 				= 0;
LET dAbonoVencidototal  		= 0;
LET iMeses_historia 			= 0;
LET cExcepcionCoppel    		= "";
LET iCuentasCV 					= 0;
LET dMaxSaldoVencido    		= "";
LET dEficienciaCoppel   		= -1;
LET iCredEstatusFC  			= 0;
LET iCredEstatusCCnoFF  		= 0;
LET iCredRiesgoD_sinCCFF    	= 0;
LET iCredRiesgoE_sinCCFF    	= 0;
LET iCredRiesgoC_CCFF   		= 0;
LET dMaxMtoResrvRiesgoC_sinCCFF = 0;
LET iCredStatusDifFF    		= 0;
LET dMaxSaldoVencidoCRD 		= 0;
LET iCuentasStatusCVsinFF   	= 0;
LET iCuentasStatusFF6001    	= 0;
LET iCredRiesgoD_sinFF  		= 0;
LET iCredRiesgoE_sinFF  		= 0;
LET iCredRiesgoC_sinFF  		= 0;
LET dMaxMtoResrvRiesgoC_sinFF = 0;
LET dtMinFechaAperturasinFF 	= DATE(1);
LET dtMinFechaApertura  		= DATE(1);
LET cSituacion  				= "?";
LET dtFecha_apert				= DATE(1);
LET dPorcentaje					= 0;
LET iAbonoMuebles        		= 0;
LET iAbonoRopa           		= 0;
LET iAbonoPrestamos      		= 0;
LET iAbonoAire         			= 0;
LET iAbonoAfiliados      		= 0;
LET iAbonoReestructura   		= 0;
LET iVencidoMuebles      		= 0;
LET iVencidoRopa         		= 0;
LET iVencidoPrestamos    		= 0;
LET iVencidoAire      			= 0;
LET iVencidoAfiliados    		= 0;
LET iVencidoReestructura 		= 0;
LET cOrigen						= "";
LET cDescripcion				= "";
LET cRiesgoViviendaCpl   		= "";
LET cRiesgoViviendaBcpl  		= "";
LET cActRiesgoCpl        		= "";
LET cActRiesgoBCpl				= "";
LET cDescpRiesgo				= "";
LET dtFecha						= DATE(1);
LET cNomcte						= "";
LET iCteLargo					= 0;
LET cRFC						= "";
LET cCodigoRet 					= "";
LET cFechaUltimoPago 			= ""; 
LET cPrestamoAutorizado 		= ""; 
LET iMontoAutorizado 			= "";
LET iReprestamo 				= "";
LET cSolBanco					= "";
LET cStatusSol					= "";
LET cCausaRechSol				= "";

LET cNumcred					= "";
LET cStatus_cred				= "";
LET dtFechaAper         		= DATE(1);
LET dSdo_vencidocrd				= 0;
LET dSdo_vencido				= 0;
LET dtMaxFechaCorte				= DATE(1);
LET cGrado_riesgo				= "";
LET dMto_reserva				= "";
LET cValidaINE					= "";
LET iCredCrd					= 0;

LET s_tipper					= "??";
LET s_referen1          		= "??????????";
LET s_nomrefer1         		= "??????????";
LET s_referen2          		= "??????????";
LET s_nomrefer2         		= "??????????";
LET s_sexo              		= "?";
LET s_edocivil          		= "?";
LET s_edad              		= 0;
LET s_puesto            		= "??";
LET s_creditos          		= 0;
LET s_tel_ref_1         		= " ";
LET s_tel_ref_2        			= " ";
LET s_parentesco1       		= " ";
LET s_parentesco2       		= " ";
LET s_cteref            		= " ";
LET v_paramref          		= 0;
LET cMensaje            		= "";
LET v_nroref					= 0;

BEGIN
    ON EXCEPTION SET isql_err
		IF isql_err <> 0 THEN
			LET cCodRet = isql_err;
			RETURN cCodRet,cSolBanco,cNumCteBanco,cNumCteCoppel,o_empresa,cStatusSol,cCausaRechSol,o_producto,cGrupo,cTpSol,cFlagINE,cHabita_en,
			cPuntualidad,cProfesion,iCreditosDigitales,iAct,cDescpAct,iSubAct,cDescpSubAct,cSitEspCoppel,iCausaSitEspCpl,cMotivoRechCpl,
			cMotivoRechBcpl,cTipoRechazo,NVL(cDescripcionRechazo,""),iTotalVencido,iAbonoTotal,dAbonoVencidototal,iMeses_historia,cExcepcionCoppel,
			iCuentasCV,dMaxSaldoVencido,dEficienciaCoppel,iCredEstatusFC,iCredEstatusCCnoFF,iCredRiesgoD_sinCCFF,iCredRiesgoE_sinCCFF,
			iCredRiesgoC_CCFF,dMaxMtoResrvRiesgoC_sinCCFF, iCredStatusDifFF,dMaxSaldoVencidoCRD,iCuentasStatusCVsinFF,iCuentasStatusFF6001,
			iCredRiesgoD_sinFF,iCredRiesgoE_sinFF,iCredRiesgoC_sinFF,dMaxMtoResrvRiesgoC_sinFF, dtMinFechaAperturasinFF,dtMinFechaApertura,
			cSituacion,dtFecha_apert,cProducto,dPorcentaje,iAbonoMuebles,iAbonoPrestamos,iAbonoRopa,iAbonoAire,iAbonoAfiliados,iAbonoReestructura,
			iVencidoMuebles,iVencidoRopa,iVencidoPrestamos,iVencidoAire,iVencidoAfiliados,iVencidoReestructura,cFechaUltimoPago,iReprestamo,cOrigen,
			cDescripcion,cRiesgoViviendaCpl,cRiesgoViviendaBcpl,cActRiesgoCpl,cActRiesgoBCpl,cDescpRiesgo,pEjecucion, 
			s_tipper,s_referen1,s_nomrefer1,s_referen2 ,s_nomrefer2,s_sexo,s_edocivil,s_edad,s_puesto,s_creditos,s_tel_ref_1,s_tel_ref_2,
			s_parentesco1, s_parentesco2, s_cteref,cMensaje;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/Oscar/Sps_Motor/sp_consultadatos_motor_precal.trc";
    --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(o_empresa,'') = '' OR NVL(o_num_cliente,'') = '' OR NVL(o_bandera,'') = '' OR NVL(o_producto,'') = '' OR NVL(iCanal,0) = 0 OR NVL(pEjecucion,'') = '' THEN
		LET cCodRet = "200";
        LET cMensaje= 'Los parametro de entrada estan vacios';
        RETURN cCodRet,cSolBanco,cNumCteBanco,cNumCteCoppel,o_empresa,cStatusSol,cCausaRechSol,o_producto,cGrupo,cTpSol,cFlagINE,cHabita_en,
			cPuntualidad,cProfesion,iCreditosDigitales,iAct,cDescpAct,iSubAct,cDescpSubAct,cSitEspCoppel,iCausaSitEspCpl,cMotivoRechCpl,
			cMotivoRechBcpl,cTipoRechazo,NVL(cDescripcionRechazo,""),iTotalVencido,iAbonoTotal,dAbonoVencidototal,iMeses_historia,cExcepcionCoppel,
			iCuentasCV,dMaxSaldoVencido,dEficienciaCoppel,iCredEstatusFC,iCredEstatusCCnoFF,iCredRiesgoD_sinCCFF,iCredRiesgoE_sinCCFF,
			iCredRiesgoC_CCFF,dMaxMtoResrvRiesgoC_sinCCFF, iCredStatusDifFF,dMaxSaldoVencidoCRD,iCuentasStatusCVsinFF,iCuentasStatusFF6001,
			iCredRiesgoD_sinFF,iCredRiesgoE_sinFF,iCredRiesgoC_sinFF,dMaxMtoResrvRiesgoC_sinFF, dtMinFechaAperturasinFF,dtMinFechaApertura,
			cSituacion,dtFecha_apert,cProducto,dPorcentaje,iAbonoMuebles,iAbonoPrestamos,iAbonoRopa,iAbonoAire,iAbonoAfiliados,iAbonoReestructura,
			iVencidoMuebles,iVencidoRopa,iVencidoPrestamos,iVencidoAire,iVencidoAfiliados,iVencidoReestructura,cFechaUltimoPago,iReprestamo,cOrigen,
			cDescripcion,cRiesgoViviendaCpl,cRiesgoViviendaBcpl,cActRiesgoCpl,cActRiesgoBCpl,cDescpRiesgo,pEjecucion, 
			s_tipper,s_referen1,s_nomrefer1,s_referen2 ,s_nomrefer2,s_sexo,s_edocivil,s_edad,s_puesto,s_creditos,s_tel_ref_1,s_tel_ref_2,
			s_parentesco1, s_parentesco2, s_cteref,cMensaje;
	END IF 
	
	
	LET cNumCteBanco = o_num_cliente;

	SELECT fecha_hoy 
	INTO dtFecha
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = o_empresa;

	--Variables de retorno necesarias para proceso actual
	SELECT tpo_persona
	INTO s_tipper
	FROM bdinteg:"informix".si_cliente
	WHERE numcte= cNumCteBanco;

	LET cNumCteCoppel = o_num_referencia;
	
	--Trae el numero de cliente coppel
	IF NVL(cNumCteCoppel,'') = '' THEN
		SELECT NVL(numcte_ref, "")
		INTO cNumCteCoppel
		FROM bdinteg:"informix".si_cliente
		WHERE numcte= cNumCteBanco;

		IF NVL(cNumCteCoppel,'') = '' THEN
			LET cNumCteCoppel = cNumCteBanco;
		END IF;
	END IF;
	LET s_cteref = cNumCteCoppel;

	SELECT COUNT(numcte) INTO iCteLargo
	FROM bdisolic:"informix".ss_clienteslargos
	WHERE numcte = cNumCteBanco
	AND fecha_vig_ini<= dtFecha 
	AND fecha_vig_fin >= dtFecha;

	IF NVL(iCteLargo,0) > 0 THEN
		LET cGrupo = "8";
	END IF;	

	SELECT NVL(nro_referencias,0), a.tp_solicitud
    INTO v_paramref, cTpSol
    FROM bdisolic:"informix".ss_tp_solicitud a, bdisolic:"informix".ss_solic_producto b
    WHERE b.empresa = o_empresa
    AND b.num_producto = o_producto
    AND a.tp_solicitud = b.tp_solicitud
	AND a.empresa = o_empresa;

	IF v_paramref = 0 OR v_paramref IS NULL THEN
        LET cCodRet = "100";
        LET cMensaje= 'No existe parametro de referencia para la solicitud';
		
        RETURN cCodRet,cSolBanco,cNumCteBanco,cNumCteCoppel,o_empresa,cStatusSol,cCausaRechSol,o_producto,cGrupo,cTpSol,cFlagINE,cHabita_en,
			cPuntualidad,cProfesion,iCreditosDigitales,iAct,cDescpAct,iSubAct,cDescpSubAct,cSitEspCoppel,iCausaSitEspCpl,cMotivoRechCpl,
			cMotivoRechBcpl,cTipoRechazo,NVL(cDescripcionRechazo,""),iTotalVencido,iAbonoTotal,dAbonoVencidototal,iMeses_historia,cExcepcionCoppel,
			iCuentasCV,dMaxSaldoVencido,dEficienciaCoppel,iCredEstatusFC,iCredEstatusCCnoFF,iCredRiesgoD_sinCCFF,iCredRiesgoE_sinCCFF,
			iCredRiesgoC_CCFF,dMaxMtoResrvRiesgoC_sinCCFF, iCredStatusDifFF,dMaxSaldoVencidoCRD,iCuentasStatusCVsinFF,iCuentasStatusFF6001,
			iCredRiesgoD_sinFF,iCredRiesgoE_sinFF,iCredRiesgoC_sinFF,dMaxMtoResrvRiesgoC_sinFF, dtMinFechaAperturasinFF,dtMinFechaApertura,
			cSituacion,dtFecha_apert,cProducto,dPorcentaje,iAbonoMuebles,iAbonoPrestamos,iAbonoRopa,iAbonoAire,iAbonoAfiliados,iAbonoReestructura,
			iVencidoMuebles,iVencidoRopa,iVencidoPrestamos,iVencidoAire,iVencidoAfiliados,iVencidoReestructura,cFechaUltimoPago,iReprestamo,cOrigen,
			cDescripcion,cRiesgoViviendaCpl,cRiesgoViviendaBcpl,cActRiesgoCpl,cActRiesgoBCpl,cDescpRiesgo,pEjecucion, 
			s_tipper,s_referen1,s_nomrefer1,s_referen2 ,s_nomrefer2,s_sexo,s_edocivil,s_edad,s_puesto,s_creditos,s_tel_ref_1,s_tel_ref_2,
			s_parentesco1, s_parentesco2, s_cteref,cMensaje;
    END IF;
	
    SELECT COUNT(num_solicitud)
	INTO v_nroref 
	FROM bdisolic:"informix".ss_refpersonales
    WHERE empresa = o_empresa
	AND numcte = cNumCteBanco;

    IF v_nroref IS NULL THEN
        LET v_nroref = 0;
    END IF;

	SELECT a.sexo, a.estado_civil, a.habita_en,
            (SELECT YEAR(fecha_hoy) FROM bdinteg:"informix".si_fechas WHERE empresa = o_empresa)-YEAR(a.fecha_nac), NVL(profesion, "")
	INTO s_sexo, s_edocivil, cHabita_en,s_edad, cProfesion
	FROM bdinteg:"informix".si_ctepf a
	WHERE numcte = cNumCteBanco;

	SELECT puesto 
	INTO s_puesto
	FROM bdinteg:"informix".si_ingresos
	WHERE empresa = o_empresa
	AND numcte = cNumCteBanco
	AND sec_ingreso = 1
	AND tipo_ingreso = "T";

    IF s_puesto IS NULL THEN
        LET s_puesto = "09";
    END IF

	IF v_nroref < v_paramref AND o_bandera ="0" THEN
        LET s_referen1 = "";
        LET s_nomrefer1 = "";
        LET s_referen2 = "";
        LET s_nomrefer2 = "";
        LET s_tel_ref_1 = "";
        LET s_tel_ref_2 = "";
    END IF

	SELECT LIMIT 1 NVL(a.numcte_ref, ""), NVL(nombre_ref,""), NVL(telefono_ref, ""), NVL(parentesco, "")
	INTO s_referen1, s_nomrefer1, s_tel_ref_1, s_parentesco1
	FROM bdisolic:"informix".ss_refpersonales a
	WHERE a.empresa = o_empresa
	AND a.numcte = cNumCteBanco
	AND a.numcte_ref ='R1'
	AND NOT a.nombre_ref IS NULL
	AND num_solicitud = 
			(SELECT MAX(num_solicitud)
				FROM bdisolic:"informix".ss_refpersonales a
				WHERE a.empresa = o_empresa
				AND a.numcte = cNumCteBanco
				AND a.numcte_ref ='R1'
				AND NOT a.nombre_ref IS NULL);

	---

	SELECT a.claveopcionpuesto,a.clavesubopcionpuesto
	INTO iAct,iSubAct 
	FROM bdinteg:"informix".si_ingresos a
	WHERE a.numcte = cNumCteBanco
	AND a.tipo_ingreso = 'T'
	AND a.sec_ingreso = (SELECT MAX (sec_ingreso) 
						FROM bdinteg:"informix".si_ingresos b
						WHERE b.numcte=a.numcte
						AND b.tipo_ingreso = 'T');	

	EXECUTE PROCEDURE bdicred:"informix".monthadd(dtFecha,-1) INTO dtMaxFechaCorte;
	LET dtMaxFechaCorte = mdy(MONTH(dtMaxFechaCorte),'20',YEAR(dtMaxFechaCorte));

	SELECT descrip INTO cDescpAct FROM bdinteg:"informix".si_actsubact WHERE  id_subact = 0 AND id_act = iAct;
	SELECT descrip INTO cDescpSubAct FROM bdinteg:"informix".si_actsubact WHERE  id_subact = iSubAct AND id_act = iAct;
	
	FOREACH
		SELECT LIMIT 1 TRIM(NVL(resultado,''))
		INTO cValidaINE
		FROM bdinteg:"informix".si_bitacora_ife 
		WHERE numcte = cNumCteBanco 
		ORDER BY fecha DESC
	END FOREACH;

	LET cValidaINE = UPPER(cValidaINE);

	IF cValidaINE = 'TRUE' THEN
		LET cFlagINE = '1';
	ELSE
		LET cFlagINE = '0';
	END IF;
	
	-- Variables Banco
	SELECT COUNT(numcte) 
	INTO iCredStatusDifFF
	FROM bdicred:"informix".sd_maecredcrd
	WHERE empresa = o_empresa 
	AND numcte = cNumCteBanco 		       
	AND status_cred <> "FF";

	FOREACH
		SELECT LIMIT 1 (SELECT NVL(SUM(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)),0)
		FROM bdicred:"informix".sd_maesdoscrd 
		WHERE empresa = o_empresa
		AND num_credito = crd.num_credito) AS maximo 
		INTO dMaxSaldoVencidoCRD
		FROM bdicred:"informix".sd_maecredcrd crd
		WHERE crd.empresa = o_empresa
		AND crd.numcte = cNumCteBanco           
		AND crd.status_cred <> "FF"
		AND crd.num_producto <> '6011'
		ORDER BY maximo DESC
	END FOREACH;

	SELECT COUNT(num_credito)
	INTO iCuentasStatusCVsinFF 
	FROM bdicred:"informix".sd_maecredcrd
	WHERE empresa = o_empresa
	AND numcte = cNumCteBanco 
	AND status_cred =  "CV"
	AND num_producto <> '6011';

	SELECT COUNT(num_credito) 
	INTO iCuentasStatusFF6001
	FROM bdicred:"informix".sd_maecredcrd
	WHERE empresa = o_empresa
	AND numcte = cNumCteBanco          
	AND status_cred <> "FF"
	AND num_producto = '6011';

	SELECT MIN(fecha_apertura) 
	INTO dtMinFechaAperturasinFF
	FROM bdicred:"informix".sd_maecredcrd
	WHERE empresa = o_empresa
	AND numcte = cNumCteBanco
	AND status_cred <> "FF"
	AND num_producto <> '6011';

	SELECT COUNT(num_credito)
	INTO iCuentasCV
	FROM bdicred:"informix".sd_maecred
	WHERE empresa = o_empresa
	AND numcte = cNumCteBanco
	AND status_cred = "CV";

	SELECT COUNT(num_credito)
	INTO iCredEstatusFC
	FROM bdicred:"informix".sd_maecred
	WHERE empresa = '001'
	AND numcte = cNumCteBanco 
	AND status_cred = "FC";

	LET iCredEstatusCCnoFF = 0;
	LET cCredExterno = "";
	LET iCredCrd = 0;

	FOREACH
		SELECT NVL(credito_externo,'')  
		INTO cCredExterno
		FROM bdicred:"informix".sd_maecred
		WHERE  numcte = cNumCteBanco
		AND empresa = o_empresa
		AND status_cred = "FC" 

		SELECT COUNT(num_credito)
		INTO iCredCrd
		FROM bdicred:"informix".sd_maecredcrd
		WHERE num_credito = cCredExterno
		AND empresa = o_empresa
		AND status_cred = "FF";

		IF iCredCrd = 0 THEN
			LET iCredEstatusCCnoFF = iCredEstatusCCnoFF + 1;
		END IF;
	END FOREACH;
	/*
	SELECT COUNT(a.num_credito) 
	INTO iCredEstatusCCnoFF
	FROM bdicred:"informix".sd_maecred a
	INNER JOIN bdicred:"informix".sd_maecredcrd b 
	ON b.num_credito = a.credito_externo  
	WHERE  a.numcte = cNumCteBanco
	AND a.empresa = o_empresa
	AND a.status_cred = "FC"
	AND b. status_cred <> "FF";*/

	SELECT RFC
	INTO cRFC
	FROM bdinteg:"informix".si_cliente
	WHERE numcte = cNumCteBanco;

	IF cRFC <> "" THEN
		EXECUTE PROCEDURE bdisolic:"informix".sp_valida_cliente_coppel('3','',cRFC,'','','','','','','','','','','','','','','','','','','','','')
		INTO cCodigoRet, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo;		
	ELSE
		LET cFechaUltimoPago = '1900-01-01';
		LET cPrestamoAutorizado = '0';
		LET iMontoAutorizado = '0';
		LET iRePrestamo = '0';
		LET cCodigoRet = '00000';
	END IF;

	SELECT porcentaje, situacion, fecha_apertura, num_producto
	INTO dPorcentaje, cSituacion, dtFecha_apert, cProducto
	FROM bdicred:"informix".sd_situacion_pago a, bdicred:"informix".sd_maecred b
	WHERE b.numcte = cNumCteBanco
	AND b.empresa = o_empresa
	AND a.empresa = b.empresa
	AND a.num_credito = b.num_credito
	AND a.fecha = (SELECT MAX(fecha) 
					FROM bdicred:"informix".sd_situacion_pago s
					WHERE s.empresa = b.empresa
					AND s.num_credito = b.num_credito
					AND s.porcentaje=(SELECT MIN(porcentaje)
										FROM bdicred:"informix".sd_situacion_pago j
										WHERE j.empresa = b.empresa
											AND j.num_credito=b.num_credito));

	IF cSituacion IS NULL THEN
		LET cSituacion = "O";
	END IF;

	SELECT motivo_rechazo_sol
	INTO cMotivoRechBcpl
	FROM bdicred:"informix".sd_situacion_cred
	WHERE empresa = o_empresa
	AND situacion = cSituacion;

	SELECT COUNT(a.num_credito) 
	INTO iCreditosDigitales 
	FROM bdicred:"informix".sd_maecredcrd a 
	JOIN bdicred:"informix".sd_linea_prestamo b ON (a.num_credito = b.num_credito AND a.num_producto = '6800')  
	WHERE a.numcte = cNumCteBanco AND b.fecha_cancela IS NULL;

	SELECT  MIN(fecha_apertura)
	INTO dtMinFechaApertura
	FROM bdicred:"informix".sd_maecred
	WHERE empresa = o_empresa
	AND numcte = cNumCteBanco           
	AND status_cred IN ('AA','E1');	

	EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_act_riesgo( o_empresa,cNumCteBanco)
	INTO  cCodigoRet,cDescripcion,cRiesgoViviendaCpl,cRiesgoViviendaBcpl,cActRiesgoCpl,cActRiesgoBCpl,cDescpRiesgo;	
	
	FOREACH
		SELECT 
		NVL(num_credito,''), status_cred, fecha_apertura
		INTO cNumcred, cStatus_cred, dtFechaAper
		FROM bdicred:"informix".sd_maecredcrd
		WHERE empresa = o_empresa
		AND numcte = cNumCteBanco
		AND num_producto <> '6011'
		AND status_cred <> "FF"			

		IF cNumcred <> '' THEN
			SELECT NVL(SUM(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)),0)
			INTO dSdo_vencidocrd
			FROM bdicred:"informix".sd_maesdoscrd
			WHERE empresa = o_empresa
			AND num_credito = cNumcred;

			IF (TRIM(cStatus_cred) IN ('AA','E1') AND dSdo_vencidocrd = 0) THEN	
				SELECT grado_riesgo_edo_resultados
				INTO cGrado_riesgo
				FROM bdicred:"informix".sd_hist_reserva
				WHERE empresa = o_empresa
				AND num_credito = cNumcred
				AND fecha_corte = dtMaxFechaCorte; 

				IF cGrado_riesgo IS NULL THEN
					LET cGrado_riesgo = "";
				END IF;
				
				IF (cGrado_riesgo = 'D') THEN
					LET iCredRiesgoD_sinFF = iCredRiesgoD_sinFF + 1;
				ELIF (cGrado_riesgo = 'E') THEN
					LET iCredRiesgoE_sinFF = iCredRiesgoE_sinFF + 1;
				ELIF (cGrado_riesgo = 'C') THEN
					LET iCredRiesgoC_sinFF = iCredRiesgoC_sinFF + 1;
				END IF;
			END IF; 
		END IF;  
	END FOREACH;

	LET dSdo_vencidocrd = 0;
	LET cNumcred = "";
	LET dtFechaAper = "";

	FOREACH	--Max monto reserva para (creditos con status (AA o E1) Y Saldo vencido =0 y Grado de riesgo= C)
		SELECT NVL(crd.num_credito,''), MAX(reserva_edo_resultados) AS reserva
		INTO cNumcred, dMaxMtoResrvRiesgoC_sinFF
		FROM bdicred:"informix".sd_maecredcrd crd
		INNER JOIN bdicred:"informix".sd_hist_reserva rsv ON rsv.num_credito = crd.num_credito
		WHERE rsv.fecha_corte = dtMaxFechaCorte
		AND crd.empresa = o_empresa
		AND rsv.empresa = crd.empresa
		AND crd.numcte = cNumCteBanco 
		AND crd.status_cred IN ('AA','E1')
		AND crd.num_producto <> '6011'
		GROUP BY crd.num_credito
		ORDER BY reserva DESC

		IF cNumcred <> '' THEN
				
			SELECT (NVL(SUM(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)),0))
			INTO dSdo_vencidocrd
			FROM bdicred:"informix".sd_maesdoscrd 
			WHERE empresa = o_empresa
			AND num_credito = cNumcred;
			
			SELECT grado_riesgo_edo_resultados
			INTO cGrado_riesgo
			FROM bdicred:"informix".sd_hist_reserva
			WHERE empresa = o_empresa
			AND num_credito = cNumcred
			AND fecha_corte = dtMaxFechaCorte; 

			IF dSdo_vencidocrd = 0 AND cGrado_riesgo = 'C' THEN 
				EXIT FOREACH;
			END IF;	
		END IF;
	END FOREACH;

	LET cNumcred = "";
	
	FOREACH
		SELECT LIMIT 1 (SELECT NVL(SUM(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)),0) 
		FROM bdicred:"informix".sd_maesdos 
		WHERE empresa = o_empresa
		AND num_credito = crd.num_credito) AS maximo 
		INTO dMaxSaldoVencido
		FROM bdicred:"informix".sd_maecred crd
		WHERE crd.empresa = o_empresa
		AND crd.numcte = cNumCteBanco
		AND status_cred NOT IN ("CC","FF")
		ORDER BY maximo DESC
	END FOREACH;

	LET cNumcred = "";
	LET cStatus_cred = "";
	LET dtFechaAper = "";
	LET cGrado_riesgo = "";
	
	FOREACH
		SELECT NVL(num_credito,''), status_cred,fecha_apertura
		INTO cNumcred, cStatus_cred, dtFechaAper
		FROM bdicred:"informix".sd_maecred
		WHERE empresa = o_empresa
		AND numcte = cNumCteBanco
		AND status_cred NOT IN ("CC","FF")   

		IF cNumcred <> '' THEN
			SELECT NVL(SUM(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)),0)
			INTO dSdo_vencido
			FROM bdicred:"informix".sd_maesdos
			WHERE empresa = o_empresa
			AND num_credito = cNumcred;

			IF TRIM(cStatus_cred) IN ('AA','E1') AND dSdo_vencido = 0 THEN							
				SELECT grado_riesgo_edo_resultados
				INTO cGrado_riesgo
				FROM bdicred:"informix".sd_hist_reserva
				WHERE empresa = o_empresa
				AND num_credito = cNumcred
				AND fecha_corte = dtMaxFechaCorte; 
				
				IF cGrado_riesgo IS NULL THEN
					LET cGrado_riesgo = "";
				END IF;
				
				IF cGrado_riesgo = 'D' THEN
					LET iCredRiesgoD_sinCCFF = iCredRiesgoD_sinCCFF + 1;
				ELIF cGrado_riesgo = 'E' THEN
					LET iCredRiesgoE_sinCCFF = iCredRiesgoE_sinCCFF + 1;
				ELIF cGrado_riesgo = 'C' THEN
					LET iCredRiesgoC_CCFF = iCredRiesgoC_CCFF + 1;
				END IF;		
			END IF;
		END IF;      
	END FOREACH;

	LET s_creditos = DBINFO("sqlca.sqlerrd2");

	IF 	s_creditos > 1 THEN
		LET s_creditos = 1; 
	END IF;	

	LET s_creditos = s_creditos + iCredStatusDifFF;

	IF 	s_creditos > 1 THEN
		LET s_creditos = 1; 
	END IF;	

	LET dSdo_vencido = 0;
	LET cGrado_riesgo = "";
	 
	FOREACH
		SELECT NVL(crd.num_credito,''),  MAX(reserva_edo_resultados) AS maximo
		INTO cNumcred, dMaxMtoResrvRiesgoC_sinCCFF
		FROM bdicred:"informix".sd_maecred crd 
		INNER JOIN bdicred:"informix".sd_hist_reserva rsv ON rsv.num_credito = crd.num_credito
		WHERE crd.empresa = o_empresa
		AND rsv.fecha_corte = dtMaxFechaCorte
		AND crd.numcte = cNumCteBanco
		AND crd.status_cred IN ('AA','E1')
		GROUP BY crd.num_credito
		ORDER BY maximo DESC

		IF cNumcred <> '' THEN				
			SELECT (NVL(SUM(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)),0))
			INTO dSdo_vencido
			FROM bdicred:"informix".sd_maesdos 
			WHERE empresa = o_empresa
			AND num_credito = cNumcred;
			
			SELECT grado_riesgo_edo_resultados
			INTO cGrado_riesgo
			FROM bdicred:"informix".sd_hist_reserva
			WHERE empresa = o_empresa
			AND num_credito = cNumcred
			AND fecha_corte = dtMaxFechaCorte;    

			IF dSdo_vencidocrd = 0 AND cGrado_riesgo = 'C' THEN 
				EXIT FOREACH;
			END IF;   	
		END IF;	
	END FOREACH;

	SELECT vencidototalaire,abonomensualaire,vencidototalafiliados,abonomensualafiliados,vencidototalreestructura,abonomensualreestructura,NVL(puntualidad,'')
	INTO iVencidoAire,iAbonoAire,iVencidoAfiliados,iAbonoAfiliados,iVencidoReestructura,iAbonoReestructura,cPuntualidad
	FROM bdisolic:"informix".ss_cliente_coppel_pp
	WHERE empresa = o_empresa
	AND cliente_coppel = cNumCteCoppel;
	
	IF o_num_referencia <> "" THEN

		SELECT valor INTO cExcepcionCoppel
		FROM bdisolic:"informix".ss_param
		WHERE empresa = o_empresa
		AND secuencia = 324;	

		SELECT meses_historia,causa,porcentaje_efic,situacion_especial
		INTO iMeses_historia, iCausaSitEspCpl, dEficienciaCoppel, cSitEspCoppel
		FROM bdisolic:"informix".ss_cliente_coppel_pp
		WHERE empresa = o_empresa
		AND cliente_coppel = cNumCteCoppel;

		SELECT motivo_rechazo_sol, tipo_rechazo,NVL(descripcion,"")
		INTO cMotivoRechCpl, cTipoRechazo, cDescripcionRechazo
		FROM bdicred:"informix".sd_situacion_cred
		WHERE empresa = o_empresa
		AND situacion = cSitEspCoppel;
		
		IF iCanal = 1 THEN --Indica si se envia desde sucursal
			SELECT vencido_total_ropa,vencido_total_muebles, vencido_total_prestamos,abono_mensual_ropa,abono_mensual_muebles, abono_mensual_prestamos
			INTO iVencidoRopa, iVencidoMuebles,
			iVencidoPrestamos, iAbonoRopa,iAbonoMuebles, iAbonoPrestamos 
			FROM bdisolic:"informix".ss_cliente_coppel_pp
			WHERE empresa = o_empresa
			AND cliente_coppel = cNumCteCoppel;
		END IF
		
		LET iTotalVencido = iVencidoMuebles + iVencidoRopa + iVencidoPrestamos + iVencidoAire + iVencidoReestructura;
		LET iAbonoTotal = iAbonoMuebles + iAbonoPrestamos + iAbonoRopa + iAbonoAire + iAbonoAfiliados + iAbonoReestructura;

		IF NVL(iAbonoTotal,0) > 0 THEN
			LET dAbonoVencidototal = iTotalVencido / iAbonoTotal;
		END IF;

	END IF;
	
	RETURN cCodRet,cSolBanco,cNumCteBanco,cNumCteCoppel,o_empresa,cStatusSol,cCausaRechSol,o_producto,cGrupo,cTpSol,cFlagINE,cHabita_en,
			cPuntualidad,cProfesion,iCreditosDigitales,iAct,cDescpAct,iSubAct,cDescpSubAct,cSitEspCoppel,iCausaSitEspCpl,cMotivoRechCpl,
			cMotivoRechBcpl,cTipoRechazo,NVL(cDescripcionRechazo,""),iTotalVencido,iAbonoTotal,dAbonoVencidototal,iMeses_historia,cExcepcionCoppel,
			iCuentasCV,dMaxSaldoVencido,dEficienciaCoppel,iCredEstatusFC,iCredEstatusCCnoFF,iCredRiesgoD_sinCCFF,iCredRiesgoE_sinCCFF,
			iCredRiesgoC_CCFF,dMaxMtoResrvRiesgoC_sinCCFF, iCredStatusDifFF,dMaxSaldoVencidoCRD,iCuentasStatusCVsinFF,iCuentasStatusFF6001,
			iCredRiesgoD_sinFF,iCredRiesgoE_sinFF,iCredRiesgoC_sinFF,dMaxMtoResrvRiesgoC_sinFF, NVL(dtMinFechaAperturasinFF,DATE(1)),NVL(dtMinFechaApertura,DATE(1)),
			cSituacion,NVL(dtFecha_apert,DATE(1)),cProducto,dPorcentaje,iAbonoMuebles,iAbonoPrestamos,iAbonoRopa,iAbonoAire,iAbonoAfiliados,iAbonoReestructura,
			iVencidoMuebles,iVencidoRopa,iVencidoPrestamos,iVencidoAire,iVencidoAfiliados,iVencidoReestructura,NVL(cFechaUltimoPago, DATE(1)),iReprestamo,cOrigen,
			cDescripcion,cRiesgoViviendaCpl,cRiesgoViviendaBcpl,cActRiesgoCpl,cActRiesgoBCpl,cDescpRiesgo,pEjecucion, 
			s_tipper,NVL(s_referen1,""),NVL(s_nomrefer1,""),NVL(s_referen2,"") ,NVL(s_nomrefer2,""),s_sexo,s_edocivil,s_edad,s_puesto,s_creditos,NVL(s_tel_ref_1,""),NVL(s_tel_ref_2,""),
			NVL(s_parentesco1,""), NVL(s_parentesco2,""), NVL(s_cteref,""),cMensaje;
END
END PROCEDURE
DOCUMENT
'----------------------------------------------------------------------------',
'Descripcion : Se genera SP para recabar los datos necesarios para el consumo de Motor de EvaluaciÃÂÃÂ³n en el proceso de precalificaciÃÂÃÂ³n',
'Modifico    : Alberto Leon Favela',
'Fecha       : 06/06/2022',
'BD          : BDICRED';

CREATE PROCEDURE "informix".executaedoctageneral_2x(pempresa CHAR(3),pfechahoy DATE) 
RETURNING CHAR(5);

--------------------------------------------------------
--	VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
DEFINE sql_err          INTEGER;
DEFINE v_cod_ret	    CHAR(5);
DEFINE v_corta_retorno  INTEGER;
--------------------------------------------------------
--	VARIABLES GENERALES
--------------------------------------------------------
DEFINE v_empresa        CHAR(3);
DEFINE v_num_credito    CHAR(20);
DEFINE v_num_producto   CHAR(4);

DEFINE v_id_registro    CHAR(3);
DEFINE v_descripcion 	CHAR(50);

DEFINE v_periodo_anterior   	DATE;			--Fecha Periodo Anterior
DEFINE v_dias_periodo_tc 		INTEGER;		--dias_periodo_tc
DEFINE v_texto		            CHAR(1000);
DEFINE v_clave           		INTEGER;
DEFINE v_secuencia        		INTEGER;
DEFINE v_mensajes				VARCHAR(255);

DEFINE GLOBAL v_cat			    DECIMAL(18,2) DEFAULT 0;
DEFINE GLOBAL v_cat2			DECIMAL(18,2) DEFAULT 0;
DEFINE GLOBAL v_cat3			DECIMAL(18,2) DEFAULT 0;
DEFINE GLOBAL v_linea_auxiliar	DECIMAL(14,2) DEFAULT 0;
DEFINE GLOBAL v_corta_linea_mensaje 	INTEGER  DEFAULT 0;

DEFINE dFechaIni				DATE;
DEFINE dFechaFin				DATE;
DEFINE cNumCredito				CHAR(20);

--------------------------------------------------------
--	INICIALIZACION VARIABLES
--------------------------------------------------------
LET sql_err          = "";
LET v_cod_ret	    = "000";

LET v_empresa        = "";
LET v_num_credito    = "";
LET v_num_producto   = "";

LET v_id_registro    = "";
LET v_descripcion 	= "";

LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc 		= 0;	--dias_periodo_tc
LET v_cat                   = 0; --- CAT
LET v_cat2                   = 0; --- CAT
LET v_cat3                   = 0; --- CAT Oro
LET v_texto                 = "";
LET v_linea_auxiliar        =999999.00;
LET v_mensajes				= "";
LET v_corta_retorno 		= 0;
LET v_corta_linea_mensaje 	= 135;
LET cNumCredito				= "";

---- -SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION COMMITTED READ;

BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;

            RETURN v_cod_ret;
        END IF
   END EXCEPTION;
SET DEBUG FILE TO "/DBA/INC/20221021/executaedoctageneral_muestra_trace.out";
TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--------------------------------------------------------------
	-----EJECUTA PROCESO LLENADO DE TABLA SD_MUESTRA_EDOCTA-------
	--------------------------------------------------------------
	EXECUTE PROCEDURE "informix".executaedoctageneral_muestra('001','01-01-1990')
	INTO v_cod_ret,v_mensajes;
	
	EXECUTE PROCEDURE "informix".sp_edocta_credsol_detalle('001','01-01-1990')
	INTO v_cod_ret;
   -----------------------------------------------------   
   -----------------NUMERO DE PRODUCTO------------------
   -----------------------------------------------------

    SELECT {+ INDEX (bdicred:sd_definicion)} num_producto 
	INTO v_num_producto FROM bdicred:"informix".sd_definicion
    WHERE empresa = pempresa AND nombre_prod = TRIM('TARJETA CREDITO BANCOPPEL VISA');

	-------------------------------------------------------
	--SE INICIALIZA TABLA PARA EDOCTAS
	------------------------------------------------------
	---Truncate sd_movhisedocta;
    --------------------------------------------------------
	--SE OBTIENE FECHA HOY MENOS UN MES
	--------------------------------------------------------
	EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(pfechahoy,-1,DAY(pfechahoy))
	INTO v_cod_ret,v_periodo_anterior,v_dias_periodo_tc;

	LET v_periodo_anterior = v_periodo_anterior + 1 UNITS DAY;


	--------------------------------------------------------
	--	PREPARA LA TABLA  PARA EDOCTAS
	-------------------------------------------------------

	--INSERT INTO sd_movhisedocta
	--	SELECT a.empresa,			a.secuencia,			   a.fecha_mov,
	--		   a.hora_mov,			a.sucursal,                a.num_credito,
	--		   a.plaza,				a.transacc_suc,			   a.usuario,
	--		   a.monto,             a.codigo_fun,			   a.codigo_ref,
	--		   a.divisa,			a.reversado,			   a.folio_suc,
	--		   a.num_producto,      a.nro_tarjeta,			   a.referencia,
	--		   a.tipo_cambio,		a.monto_dls,			   a.suc_origen,
	--	       a.rfc_comer,			a.referencia23
    --    FROM sd_movhis a, sd_transfun b , bdinteg:si_transacc  c
	--	WHERE a.codigo_fun = b.codigo_fun AND a.codigo_ref  = b.codigo_ref
	--	AND c.numero = b.transacc AND c.se_emite_edocta = "S"
	--	AND fecha_mov >= v_periodo_anterior AND fecha_mov <= pfechahoy
	--	AND reversado <> "S";

   ---EXECUTE PROCEDURE carga_movhis_edocta (pfechahoy) INTO v_cod_ret;

   ---IF v_cod_ret<> "000" THEN
         ---RETURN v_cod_ret;
   ---END IF;

	-- Se agrega validacion para indicar que se haya hecho la muestra para la fecha de corte actual antes de generar los estados de cuenta. RQM 06 143
	/*SELECT LIMIT 1 num_credito
	INTO cNumCredito
	FROM bdicred:"informix".sd_muestra_edocta
	WHERE fecha_corte=pfechahoy;*/

	--IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
	--------------------------------------------------------
	    --  SE GENERAN LOS INSERTOS FIJOS PARA CUENTAS CON 1 Y 5 PAGOS VENCIDOS
		-------------------------------------------------------
		/*
		EXECUTE PROCEDURE bdicred:"informix".sp_activa_insertos_fijos
						(
						pempresa,
						pfechahoy
						) INTO v_cod_ret;

	   IF v_cod_ret<> "00000" THEN
	         RETURN v_cod_ret;
	   END IF;
		*/-- FMJ InActiva insertos de Moras para ECTDC
		-------------------------------------------------------
	        --SE CORRE ACTUALIZACION DE ESTADISTICAS
	        ------------------------------------------------------
		--	UPDATE STATISTICS HIGH FOR TABLE sd_movhisedocta;
		--	UPDATE STATISTICS MEDIUM FOR TABLE sd_movhisedocta;
		-------------------------------------------------------
		--SE ARREGLAN TRANSACCIONES
		------------------------------------------------------
		CALL bdicred:"informix".ARR_MOVHIS(pfechahoy);
		----------------------------------------------------------
		--SE ACTULIZAN LOS REGISTROS QUE RESULTEN DE LA CONSULTA
		----------------------------------------------------------
		--SET DEBUG FILE TO "/informix/edocta.out";
		--TRACE ON;
	--------------------------------------------------------
		--	GENERACION ENCABEZADO EDO CUENTA
		--------------------------------------------------------
	  	LET v_id_registro = "000";
		--SET DEBUG FILE TO "/respaldosbd/Malena/procesos.out";
		--TRACE ON;
	  	IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_encabezado_edocta
	  				  WHERE fecha_emision = pfechahoy
	  				  AND num_credito = v_id_registro) THEN

	 		INSERT INTO bdicred:"informix".sd_encabezado_edocta
				(
	     		fecha_emision,		num_credito, 			numcte,
	     		num_tarjeta, 		nombre_cte,				direccion_cn,
				direccion_col,		direccion_del,			edo_cd,
			 	sucursal_nombre,	sucursal_gerente, 	 	sucursal_tel,
			 	fecha_corte,		rfc,			 	 	cl_cobra,
			 	CP,					ruta,					confirmacion,
				num_region, 		num_ciudad_banco, 		num_ciudad_coppel,
				ec_edocta
				)
	  		VALUES
	  			(
				 pfechahoy,			v_id_registro,			"0",
	  		 	 "0",				"0",					"0",
	  			 "0",				"0",					"0",
	  			 "0",				"0",			 		"0",
	  			 pfechahoy,			"0",			 		"0",
	  			 "0",				"0",					"",
				 "0",				"0",					"0",
				 "0"
				);
	  	END IF
	  	LET v_id_registro = "100";
	 	IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_encabezado_edocta
	  		      WHERE fecha_emision = pfechahoy
	  		      AND num_credito = v_id_registro) THEN

	     	 INSERT INTO bdicred:"informix".sd_encabezado_edocta
				(
	     		fecha_emision,		num_credito, 			numcte,
	     		num_tarjeta, 		nombre_cte,				direccion_cn,
			 	direccion_col,		direccion_del,			edo_cd,
		 	 	sucursal_nombre,	sucursal_gerente, 	 	sucursal_tel,
		 	 	fecha_corte,		rfc,	 	 			cl_cobra,
		 	 	CP,					ruta,					confirmacion,
				num_region, 		num_ciudad_banco, 		num_ciudad_coppel,
				ec_edocta
				)
	  		VALUES  (
				 pfechahoy,			v_id_registro,			"0",
	  		 	 "0",				"0",					"0",
	  			 "0",				"0",					"0",
	  			 "0",				"0",			 		"0",
	  			 pfechahoy,			"0",			 		"0",
	  			 "0",				"0",					"",
				 "0",				"0",					"0",
				 "0"
				);
	 	 END IF
		--------------------------------------------------------
		--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
		--------------------------------------------------------
		LET v_id_registro = "200";
	  	IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_encabezado2_edocta
	  		      WHERE fecha_emision = pfechahoy
	  		      AND num_credito = v_id_registro) THEN


			INSERT INTO bdicred:"informix".sd_encabezado2_edocta
				(
				fecha_emision,		num_credito,			capital_tc,
				interes_tc,			iva_interes_tc,			capital_ven_tc,
				interes_ven_tc,		iva_interes_ven_tc,		moratorios_tc,
				iva_moratorios_tc,	sdo_pagar,				interes_pago_total_tc,
				limite_tc,			sdo_disponible,			periodo_tc_ini,
				periodo_tc_fin,		pago_antes_de,			fecha_corte,
				dias_periodo_tc,	usted_debia,			menos_abonos,
				mas_compras,		sus_comisiones,			mas_disp_efectivo,
				mas_intereses,		mas_iva,				mas_rendimientos,
				sdo_debe,			menos_o_abonos,			mas_o_cargos,
				usted_debe,			mensajes,
				comisiones_iva,     intereses_iva,          intereses_pag,
				saldo_menos_pag,    compras_disp,			base_iva,	
				descuento,			subtotal,				total 		
				)
			VALUES (
				pfechahoy,			v_id_registro,			0,
				0,					0,						0,
				0,					0,						0,
				0,					0,						0,
				0,					0,						pfechahoy,
				pfechahoy,			pfechahoy,				pfechahoy,
				0,					0,						0,
				0,					0,						0,
				0,					0,						0,
				0,					0,						0,
				0,					"",
				0,					0,						0,
				0,					0,						0,	
				0,					0,						0	
				); 

		END IF
		--------------------------------------------------------
		--	VARIABLES GENERACION DETALLE EDO CUENTA
		--------------------------------------------------------
		LET v_id_registro = "300";
		IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_detalle_edocta
			      WHERE fecha_emision = pfechahoy
			      AND num_credito = v_id_registro) THEN

			INSERT INTO sd_detalle_edocta
				(
				fecha_emision, 		num_credito, 			secuencia,
				fecha_mov, 			concepto, 				cargos,
				abonos, 			nlinea
				)
			VALUES
	         	(
	         	pfechahoy,			v_id_registro,			"0",
	         	"0", 				"0", 					"0",
				"0", 				"0"
	         	);

		END IF
		--------------------------------------------------------
		--	VARIABLES GENERACION ACLARACIONES EDO CUENTA
		--------------------------------------------------------
		LET v_id_registro = "400";
		IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_aclaraciones_edocta
			      WHERE fecha_emision = pfechahoy
			      AND num_credito = v_id_registro) THEN


			INSERT INTO bdicred:"informix".sd_aclaraciones_edocta
				(
				fecha_emision, 			num_credito, 		secuencia,
				nlinea,					fecha_aclara, 		folio,
	            fecha_movimiento,       descripcion,    	importe
				)
			VALUES
	         	(
	         	pfechahoy,				v_id_registro,		"0",
	         	"0",					pfechahoy, 			"",
	            "",                            "",         	0
	         	);

		END IF
		--------------------------------------------------------
		--	VARIABLES GENERACION MENSAJES EDO CUENTA
		--------------------------------------------------------
		LET v_id_registro = "500";
		IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_mensajes_edocta
			      WHERE fecha_emision = pfechahoy
			      AND num_credito = v_id_registro) THEN

			INSERT INTO bdicred:"informix".sd_mensajes_edocta
				(
				fecha_emision, 			num_credito, 		secuencia,
				nlinea,					si_paga, 			mensajes,
				meses_liq
				)
			VALUES
	         	(
	         	pfechahoy,				v_id_registro,		"0",
	         	"0",					0, 					"",
				0
	         	);

		END IF
		--------------------------------------------------------
		--	VARIABLES GENERACION PIE EDO CUENTA
		--------------------------------------------------------
	  	LET v_id_registro = "600";
		IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_pie_edocta
		  	      WHERE fecha_emision = pfechahoy
		  	      AND num_credito = v_id_registro) THEN

			INSERT INTO bdicred:"informix".sd_pie_edocta
				(
				fecha_emision,			num_credito,		tasa_mensual,
				tasa_anual, 			cat, 				saldo_promedio,
				dias_periodo
				)
			VALUES  (
				pfechahoy, 				v_id_registro, 		"0",
				"0", 					"0", 				"0",
				"0"
				);
		  END IF
      --------------------------------------------------------
			--	GENERA ENCABEZADO DE PAGOS DIFERIDOS
			--------------------------------------------------------
			LET v_id_registro = "900";
			IF NOT EXISTS(SELECT * FROM sd_detalle_dif_edocta
					  WHERE fecha_emision = pfechahoy
					  AND num_credito = v_id_registro) THEN

				INSERT INTO sd_detalle_dif_edocta
					(
					fecha_emision, 			num_credito, 		num_promocion,
					num_cred_credsol,		folio_suc, 			plazo,
					diasmes,				fecha,				tasa,
					saldo_pendiente,		prox_fecha_pago,	concepto,
					monto_prox_pago,		numero_cuotas,		secuencia,
					nlinea
					)
				VALUES
					(
					pfechahoy,				v_id_registro,		"0",
					"0",					0, 					"0",
					0,						pfechahoy,			0,
					0,						pfechahoy,			'',
					0,						'0/0',				0,
					0
					);
			END IF
		--------------------------------------------------------
		--	GENERA VARIABLES GLOBALES
		-------------------------------------------------------
	    ----VALOR DEL CAT
		SELECT valor INTO v_cat
		FROM bdicred:"informix".sd_param
		WHERE empresa = pempresa
		AND cod_param = '035';

		IF v_cat IS NULL THEN
			LET v_cat = 0.0;
		END IF
		
			SELECT valor INTO v_cat2
			FROM sd_param
			WHERE empresa = pempresa
			AND cod_param = '091'; 

			IF v_cat2 IS NULL THEN
				LET v_cat2 = 0.0;
			END IF
			
				--AAME RQM 10 679 Se contempla nuevo parametro para el valor de CAT de TDC ORO
				SELECT valor INTO v_cat3
				FROM sd_param
				WHERE empresa = pempresa
				AND cod_param = '093'; 

				IF v_cat3 IS NULL THEN
					LET v_cat3 = 0.0;
				END IF				
	    -----MENSAJES DEL ESTADO DE CUENTA

	        CREATE TEMP TABLE bdicred:mensajes(
	                clave     serial,
	                secuencia integer,
	                mensaje   char(150));




	        LET v_clave=1;
	            FOREACH
	                    SELECT  REPLACE(mensajes,'{0}',TRIM(v_linea_auxiliar::VARCHAR(21))) INTO v_texto
	                     FROM bdicred:"informix".sd_config_mensaje_edocta WHERE clave < 99 AND num_producto = v_num_producto
	                     order by clave

	                     LET v_secuencia=1;

	                FOREACH
	                     EXECUTE PROCEDURE corta_linea(TRIM(v_texto),v_corta_linea_mensaje) INTO v_mensajes, v_corta_retorno
	                     INSERT INTO bdicred:mensajes VALUES (v_clave,v_secuencia,v_mensajes);
	                     LET v_secuencia=v_secuencia+1;
	                END FOREACH;

	                LET v_clave = v_clave + 1;

	            END FOREACH;


	            DELETE bdicred:"informix".sd_mensajes_mensual_edocta WHERE fecha_emision = pfechahoy;

	            INSERT INTO bdicred:"informix".sd_mensajes_mensual_edocta
	            SELECT pfechahoy, clave, secuencia,mensaje FROM bdicred:mensajes WHERE clave <> '2';

	            DELETE FROM bdicred:mensajes WHERE clave <> '2';

	 	--------------------------------------------------------
		--	INICIA CON LA GENARACION DE MUESTRAS
		-------------------------------------------------------

	 	FOREACH SELECT a.empresa,a.num_credito
	 			INTO v_empresa,v_num_credito
	 			FROM bdicred:"informix".sd_maesdoshist a, bdicred:"informix".sd_muestra_edocta b
	        	WHERE a.fecha = pfechahoy
				AND b.fecha_corte= pfechahoy
				--AND b.flag_generacion=1
	        	AND a.empresa = pempresa
	            AND a.num_credito = b.num_credito
	        	AND a.num_credito NOT IN
	        	(SELECT num_credito FROM bdicred:"informix".sd_encabezado_edocta
	        	WHERE fecha_emision = pfechahoy)


			EXECUTE PROCEDURE bdicred:"informix".generaestadosdecuenta
						(
						v_empresa,
						v_num_credito,
						pfechahoy
						) INTO v_cod_ret;

	      	IF v_cod_ret <> "000" THEN

	      		SELECT descripcion  INTO v_descripcion
	      		FROM bdinteg:"informix".si_codret
	      		WHERE codigo_retorno = v_cod_ret
	      		AND sistema  ="06";

	      		INSERT INTO bdicred:"informix".sd_valedocta
	      			(
	      			empresa,		num_credito,		cod_ret,
	      			descripcion,	fecha_proc,			tipo
	      			)
	      		VALUES
	      			(
	      			v_empresa,		v_num_credito,		v_cod_ret,
	      			v_descripcion,	pfechahoy,			"E"
	      			);            
			END IF            
	 	END FOREACH;
        
        --execute procedure ugenera_layoutedocuenta_muestras( pempresa, pfechahoy ) into v_cod_ret;

		/*IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			DROP TABLE bdicred:mensajes;
			RETURN "002";  --'Aun no se revisan los estados de cuenta'	RQM 06 143
		ELSE*/
		 	--------------------------------------------------------
			--	GENERA UNO A UNO LOS ESTADOS DE CUENTA
			-------------------------------------------------------
			/* ---Se programa dentro de Ctrl M
			FOREACH SELECT empresa,num_credito
		 			INTO v_empresa,v_num_credito
		 			FROM bdicred:"informix".sd_maesdoshist
		        	WHERE fecha = pfechahoy
		        	AND empresa = pempresa
		        	AND num_credito NOT IN
		        	(SELECT num_credito FROM bdicred:"informix".sd_encabezado_edocta
		        	WHERE fecha_emision = pfechahoy)



				EXECUTE PROCEDURE bdicred:"informix".GeneraEstadosdeCuenta
							(
							v_empresa,
							v_num_credito,
							pfechahoy
							) INTO v_cod_ret;

		      	IF v_cod_ret <> "000" THEN

		      		SELECT descripcion  INTO v_descripcion
		      		FROM bdinteg:"informix".si_codret
		      		WHERE codigo_retorno = v_cod_ret
		      		AND sistema  ="06";

		      		INSERT INTO bdicred:"informix".sd_valedocta
		      			(
		      			empresa,		num_credito,		cod_ret,
		      			descripcion,	fecha_proc,			tipo
		      			)
		      		VALUES
		      			(
		      			v_empresa,		v_num_credito,		v_cod_ret,
		      			v_descripcion,	pfechahoy,			"E"
		      			);

				END IF
		 	END FOREACH;

		    DROP TABLE bdicred:mensajes;

			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_encabezado_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_encabezado2_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_detalle_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_aclaraciones_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_mensajes_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_mensajes_mensual_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_pie_edocta;
			*/
			DROP TABLE bdicred:mensajes;
			RETURN "000";

		--END IF;
--	ELSE
--		RETURN "001"; -- Se agrega codigo de retorno que indica que no se ha hecho aun la muestra para la fecha de corte actual RQM 06 143
--	END IF;

END;
END PROCEDURE
DOCUMENT
'CAMBIO: Se modifica procedimiento para agregar validacion para indicar que se haya hecho la muestra para la fecha de corte actual antes de generar los estados de cuenta.',
'MODIFICO : Maria Elena Angulo Aispuro',
'FECHA : 13/JULIO/2011',
'BD: BDICRED',
'VERSION:20110713.1645';

CREATE PROCEDURE "informix".generaestadosdecuenta_repro(pempresa CHAR(3),pnum_credito CHAR(20),pfechahoy DATE)
--EXECUTE PROCEDURE generaestadosdecuenta_repro('001','600000064417',mdy('09','20','2021')); 
RETURNING CHAR(5);

-- 09062013
-- Modificacion PIQV. Se realiza modificacion para incluir en el desgloce de movimientos las compras de las transacciones.
-- 7730 (COMPRA EN COMERCIO (LIB) INTER-RED SALDO A FAVOR) y 7729 (COMPRA EN COMERCIO (LIB) SALDO A FAVOR)
-- 01082013
-- Modificacion AAME. Se realiza modificacion para incluir en el desgloce de movimientos los cargos por concepto "Pago de servicio GDF"
-- 6846 (Pago de servicio GDF) y 7746 (Pago de servicio GDF Saldo a Favor)
-- 30072013
-- Modificacion Se realiza modificacion para incluir en el desgloce de movimientos las compras de las transacciones.
-- 4301,4302,4303,4304,4304,4305,4306,4307,4308,4309,4310,4311,4312,4313,4314,4315 
--------------------------------------------------------
--	VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
DEFINE cod_ret             			CHAR(5);
DEFINE sql_err             			INTEGER;
DEFINE v_cod_ret_otro			    CHAR(5);

DEFINE v_corta_linea_detalle 		INTEGER;
DEFINE v_corta_retorno        		INTEGER;
DEFINE GLOBAL v_corta_linea_mensaje INTEGER  DEFAULT 0;
--------------------------------------------------------
--	VARIABLES GENERALES
--------------------------------------------------------
DEFINE v_sucursal        CHAR(4);	--Sucursal Cliente
DEFINE v_ult_dir_clie	 INTEGER;	--Secuencia Ultima Direccion Cliente
--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
DEFINE v_numcte            CHAR(20);	--Numero de Credito
DEFINE v_num_tarjeta       CHAR(20);	--Numero de Tarjeta
DEFINE v_nombre_cte        CHAR(150);	--Nombre del Cliente
DEFINE v_direccion_cn      CHAR(456);	--Direccion
DEFINE v_direccion_col     CHAR(376);	--Colonia
DEFINE v_direccion_del     CHAR(376);	--Delegacion O Municipio
DEFINE v_edo_cd            CHAR(376);	--Estado
DEFINE v_sucursal_nombre   CHAR(40);	--Nombre de la Sucursal
DEFINE v_sucursal_gerente  CHAR(40);	--Nombre del Gerente del Sucursal
DEFINE v_sucursal_tel      CHAR(14);	--Telefono de la Sucursal
DEFINE v_cod_postal        CHAR(5);		--Codigo Postal Direccion Cliente
DEFINE v_cl_cobra          CHAR(60);	--Clave de Cobranza
DEFINE v_rfc               CHAR(13);	--RFC del Cliente
DEFINE v_ruta          	   CHAR(47);	--Ruta
DEFINE v_entre_calles      CHAR(40);	--Entre Calles
DEFINE v_observaciones     CHAR(80);	--Datos Complementarios
DEFINE v_numerociudad	   SMALLINT;	--Numero Ciudad Direccion Cliente
DEFINE v_numerocolonia 	   INT;   		--Numero Colonia Direccion Cliente
DEFINE v_numerocalle 	   INT;   		--Numero Calle Direccion Cliente
DEFINE v_numeroextcalle	   CHAR(10);	--Numero Exterior Calle Direccion Cliente
DEFINE v_estado 		   CHAR(2);	--Numero Estado
DEFINE v_nombrecalle	   CHAR(30);	--Nombre Calle Catalogo Calles
DEFINE v_centro			   INT;   		--Centro Catalogo de Zonas
DEFINE v_jefegrupozona	   INT;  		--Clave Jefe Grupo Zona
DEFINE v_supervisorzona	   INT;   		--Clave Supervisor Zona
--jom ini catalogos
DEFINE v_numerociudadcoppel  integer;	--Numero Ciudad Direccion Cliente
DEFINE v_numerocoloniacoppel integer;		--Numero Colonia Direccion Cliente
--jom fin catalogos

DEFINE v_status_cred	CHAR(2);

DEFINE v_confirmacion	CHAR(5);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE v_capital_tc   		DECIMAL(18,2);	--capital_tc
DEFINE v_interes_tc   		DECIMAL(18,2);	--interes_tc
DEFINE v_iva_interes_tc   	DECIMAL(18,2);	--iva_interes_tc
DEFINE v_capital_ven_tc   	DECIMAL(18,2);	--capital_ven_tc
DEFINE v_interes_ven_tc   	DECIMAL(18,2);	--interes_ven_tc
DEFINE v_iva_interes_ven_tc DECIMAL(18,2);	--iva_interes_ven_tc
DEFINE v_moratorios_tc   	DECIMAL(18,2);	--moratorios_tc
DEFINE v_iva_moratorios_tc  DECIMAL(18,2);	--iva_moratorios_tc
DEFINE v_pago_minimo_tc   	DECIMAL(18,2);	--sdo_pagar
DEFINE v_interes_pago_total_tc  DECIMAL(18,2);	--interes_pago_total_tc
DEFINE v_limite_tc   		DECIMAL(18,2);	--limite_tc
DEFINE v_disponible_tc   	DECIMAL(18,2);	--sdo_disponible
DEFINE v_periodo_tc_ini   	DATE;	  		--periodo_tc_ini
DEFINE v_periodo_tc_fin   	DATE;	  		--periodo_tc_fin
DEFINE v_fecha_limite_pago_tc   DATE;	  		--pago_antes_de
DEFINE v_fecha_corte_tc   	DATE;		   	--fecha_corte
DEFINE v_dias_periodo_tc 		    INTEGER;		--dias_periodo_tc
DEFINE v_usted_debia, v_deuda_Ant   DECIMAL(18,2);	--usted_debia
DEFINE v_sus_abonos   			    DECIMAL(18,2);	--menos_abonos
DEFINE v_sus_compras   			    DECIMAL(18,2);	--mas_compras
DEFINE v_sus_comisiones 		    DECIMAL(18,2);	--sus_comisiones
DEFINE v_dispocisiones  		    DECIMAL(18,2);	--mas_disp_efectivo
DEFINE v_intereses   		    DECIMAL(18,2);	--mas_intereses
DEFINE v_iva   				    DECIMAL(18,2);	--mas_iva
DEFINE v_rendimientos   	    DECIMAL(18,2);	--mas_rendimientos
--jom ini SBC
DEFINE v_comisiones_sbc         DECIMAL(18,2);	--mas_comisiones_sbc
DEFINE v_iva_comisiones_sbc     DECIMAL(18,2);  --mas_iva_comisiones_sbc
--jom fin SBC
--jom ini repos
DEFINE V_comis_repos           DECIMAL(18,2);  --comision por reposicion
--jom fin repos
DEFINE v_iva_comisiones   	 DECIMAL(18,2);	--mas_iva comisiones
DEFINE v_iva_suc   			 DECIMAL(18,2);	--mas_iva
DEFINE v_sdo_retenido        DECIMAL(18,2);	--SALDO RETENIDO
DEFINE v_fecha_apertura		 DATE;			--fecha de apertura
DEFINE v_periodo_anterior    DATE;			--Fecha Periodo Anterior
DEFINE v_capital_debe 		DECIMAL(14,2);
DEFINE v_interes_debe 		DECIMAL(14,2);
DEFINE v_interes_pagado		DECIMAL(14,2);
DEFINE v_iva_debe 			DECIMAL(14,2);
DEFINE v_iva_pagado 		DECIMAL(14,2);


DEFINE v_mora_sdo_ordi		DECIMAL(14,2);
DEFINE v_mora_sdo_ordi_pag	DECIMAL(14,2);
DEFINE v_mora_sdo_cope_pag	DECIMAL(14,2);
DEFINE v_mora_sdo_cope		DECIMAL(14,2);
DEFINE v_mora_provi_ordi	DECIMAL(14,2);
DEFINE v_mora_provi_cope	DECIMAL(14,2);
DEFINE v_mora_iva_debe		DECIMAL(14,2);
DEFINE v_mora_iva_pagado	DECIMAL(14,2);
DEFINE v_capital_status		CHAR(1);
DEFINE v_fecha_cuota		DATE;
DEFINE v_moratorios_tcA   	DECIMAL(18,2);	--moratorios_tc
DEFINE v_moratorios_tcB   	DECIMAL(18,2);	--moratorios_tc
DEFINE  v_monto_financiado	DECIMAL(18,2);
DEFINE 	v_campo_trabajo1	DECIMAL(14,2);

DEFINE v_base_iva			DECIMAL(14,2); -- CFDI 3.3
DEFINE v_descuento			DECIMAL(14,2); -- CFDI 3.3
DEFINE v_subtotal			DECIMAL(14,2); -- CFDI 3.3
DEFINE v_total				DECIMAL(14,2); -- CFDI 3.3

DEFINE v_monto_surcharge	DECIMAL(14,2); -- Separacion de Comision e Iva
DEFINE v_iva_surcharge		DECIMAL(14,2); -- Separacion de Comision e Iva
DEFINE v_comisiones_surge 	DECIMAL(14,2);
--------------------------------------------------------
--	VARIABLES GENERACION DETALLE EDO CUENTA
--------------------------------------------------------
DEFINE v_dia           		char(2);
DEFINE v_mes           		char(2);
DEFINE v_ano	       		char(4);
DEFINE v_referencia    		char(296);
DEFINE v_referencia23  		char(279);
DEFINE v_rfc_comer     		char(276);
DEFINE v_transacc      		char(4);
DEFINE v_monto         		decimal(18,2);
DEFINE v_concepto      		varchar(255);
DEFINE v_naturaleza    		char(1);
DEFINE v_letra         		char(15);
DEFINE v_fecha_mov     		char(12);

DEFINE v_compra	       		decimal(18,2);
DEFINE v_abono	       		decimal(18,2);

DEFINE v_maximo        		INTEGER;
DEFINE v_contador      		smallint;
--------------------------------------------------------
--	VARIABLES GENERACION ACLARACIONES EDO CUENTA
--------------------------------------------------------
DEFINE v_secuencia_aclara	SMALLINT;
DEFINE v_nlinea_aclara		SMALLINT;
DEFINE v_fecha_aclara		DATE;
DEFINE v_descripcion		VARCHAR(255);
DEFINE v_importe			DECIMAL(18,2);
--------------------------------------------------------
--	VARIABLES GENERACION MENSAJES EDO CUENTA
--------------------------------------------------------
DEFINE v_cuenta_mensajes	SMALLINT;
DEFINE v_secuencia_mensaje	SMALLINT;
DEFINE v_nlinea_mensajes	SMALLINT;
DEFINE v_si_paga		    VARCHAR(255);
DEFINE v_mensajes			VARCHAR(255);

DEFINE v_factor				DECIMAL(14,10);
DEFINE v_aplica_factor		DECIMAL(14,2);
DEFINE v_usted_debe			DECIMAL(18,2);

DEFINE GLOBAL v_linea_auxiliar	DECIMAL(14,2) DEFAULT 0;
--------------------------------------------------------
--	VARIABLES GENERACION PIE EDO CUENTA
--------------------------------------------------------
DEFINE v_tasa_mensual		 DECIMAL(18,2);
DEFINE v_tasa_anual			 DECIMAL(18,2);
DEFINE v_saldo_promedio		 DECIMAL(18,2);
DEFINE v_tasa_mora			 DECIMAL(18,2);
DEFINE v_tasa_mensual_mora	 DECIMAL(18,2);

DEFINE v_sdo_acum_mes_cap  	DECIMAL(18,2);
DEFINE v_dias_acum_cap     	DECIMAL(18,2);

DEFINE GLOBAL v_cat			DECIMAL(18,2) DEFAULT 0;
DEFINE GLOBAL v_cat2		DECIMAL(18,2) DEFAULT 0;
DEFINE GLOBAL v_cat3		DECIMAL(18,2) DEFAULT 0;
DEFINE  v_catAux			DECIMAL(18,2) ;

--------------------------------------------------------
--	VARIABLES GENERACION CLAVE DE COBRANZA
--------------------------------------------------------
DEFINE v_cl_cobranza        CHAR(63);

DEFINE v_tp_cliente         CHAR(2);
DEFINE v_situacion          CHAR(1);
DEFINE v_situacion_esp      char(3); -- Campo Req 09087
DEFINE v_estado_civil       CHAR(1);
DEFINE v_tp_casa            CHAR(1);
DEFINE v_sexo               CHAR(1);
DEFINE v_cantidad           CHAR(2);
DEFINE v_antiguedad         CHAR(2);
DEFINE v_nacimiento         CHAR(2);
DEFINE v_mto_tot_adeudo     CHAR(5);
DEFINE v_adeudo_vencido     CHAR(5);
DEFINE v_fec_ult_pago       CHAR(4);
DEFINE v_fec_ult_pago_month CHAR(2);
DEFINE v_fec_ult_pago_year  CHAR(2);
DEFINE v_cuantos_avisos     INTEGER;
DEFINE v_monto_ult_convenio CHAR(5);
DEFINE v_fecha_ult_convenio CHAR(4);
DEFINE v_est_cumpl_convenio CHAR(1);
DEFINE v_avisos 	    	CHAR(1);
-- INICIO CAH *** RQM 09 117 ***
--DEFINE v_nivel_eficiencia   CHAR(2);
DEFINE v_nivel_eficiencia   CHAR(1);
-- FIN CAH *** RQM 09 117 ***
DEFINE v_fecha_ultimo_pago	DATE;

DEFINE v_salario            DECIMAL(18,2);
DEFINE v_monto_adeudo       DECIMAL(18,2);
DEFINE v_mto_adeudo_venc    DECIMAL(18,2);

DEFINE v_clave1		    	VARCHAR(40);
DEFINE v_clave2		    	VARCHAR(40);
DEFINE v_clave3		    	VARCHAR(40);
DEFINE v_clave4		    	VARCHAR(40);
DEFINE v_clave5             VARCHAR(40);
DEFINE v_clave6             VARCHAR(3);

DEFINE posicion11            CHAR(5);
DEFINE posicion17            CHAR(5);

DEFINE cInserto              CHAR(15);
-- jom ini parametro sal min
DEFINE v_SalarioMinimoCoppel  SMALLINT;
-- jom fin parametro sal min
DEFINE v_numprod              CHAR(4);
--INICIO-----LHM
DEFINE v_comisiones_iva      DECIMAL(18,2);
DEFINE v_intereses_iva       DECIMAL(18,2);
DEFINE v_intereses_pag       DECIMAL(18,2);
DEFINE v_saldos_menos_pag    DECIMAL(18,2);
DEFINE v_compras_disp        DECIMAL(18,2);
--FIN--------LHM
DEFINE vfechacaptura         DATE;
DEFINE vfolio_csuac          CHAR(12);       
DEFINE vfechahora            DATE;
DEFINE vdescripcion          VARCHAR(255);
DEFINE vimportereclamado,v_saldo_diferido     DECIMAL(14,2);
DEFINE vMto_otorg            DECIMAL(18,2); -- inserto de cuadro comparativo
DEFINE vPos_Inserto          SMALLINT;     -- inserto de cuadro comparativo
Define cInsertoAux1     CHAR(15); 
Define cInsertoAux2     CHAR(15); 
DEFINE vciudades smallint;

DEFINE dFHoy_1m, dFHoy_13m, dFHoy_12m, dFech_1erComp, dFech_alta, dFhUltCompAct, dFhUltCompAnt, dFhUltPagoAnt DATE;
DEFINE iMoras, iDiasTrans INTEGER;
DEFINE	vlsecuencia	DECIMAL (18);
DEFINE vlfechaor date;

DEFINE	vlComprasDif	DECIMAL(14,2);
DEFINE	vlsaldo_corte	DECIMAL (14,2);
DEFINE	vfcancelado		DATE;
DEFINE iMesesLiq INTEGER;
DEFINE dMonto_No_Exigible DECIMAL(18,2);
DEFINE cCodRetMeses CHAR(5);
DEFINE cFolioSuc CHAR(16);  
DEFINE vCatFinal            DECIMAL(21,10);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      VARCHAR(80,1);
DEFINE dComisiones      	DECIMAL(18,2);
DEFINE dComs_GastCob		DECIMAL(18,2);
DEFINE dTasaInt      	DECIMAL(18,3);
DEFINE dPagoReq      	DECIMAL(18,2);
DEFINE dIntCredSol      	DECIMAL(18,2);
DEFINE dIntCredSolAux      	DECIMAL(18,2);
DEFINE dSaldoPromCredSol      	DECIMAL(18,2);
DEFINE dSaldoPromCredSolAux      	DECIMAL(18,2);
DEFINE dIntVenc      	DECIMAL(18,2);
DEFINE dSdoPromVen      	DECIMAL(18,2);
DEFINE dSdoPromVenAux      	DECIMAL(18,2);
DEFINE v_cod_ref            INTEGER;
DEFINE dComPend        DECIMAL(18,2);
DEFINE dIvaCom         DECIMAL(18,2);
DEFINE v_im            DECIMAL(21,10);
DEFINE mMntoComApert   DECIMAL(18,2); -- INI RQM 10 993 CAT.- Monto Comision Apertura
DEFINE mMntoComAnual   DECIMAL(18,2); -- Monto Comision Anualidad
DEFINE cCobrComisAnual CHAR(1);
DEFINE dMtoComAnualTit DECIMAL(18,2);
DEFINE dMtoComAnualAdi DECIMAL(18,2);
DEFINE dClvComAnualTit CHAR(4);
DEFINE dClvComAnualAdi CHAR(4);      -- FIN RQM 10 993 CAT
DEFINE cCat_adicional  CHAR(1);
DEFINE iCountExist	   INTEGER;
DEFINE dtasa_prom_pond  	DECIMAL(18,8);
DEFINE dtasa_prom_pond_fin 	DECIMAL(18,2);
DEFINE dClvComApertura CHAR(4);
DEFINE v_Act	INTEGER;

------------------------------------------------------------------
-- DUCM Se agregan variables de catalogo de Centros de Impresion--
DEFINE sNumRegion CHAR(2); --Numero de region (centro de impresion)
DEFINE sNumCiudadB CHAR(4); --Numero de ciudad BanCoppel
DEFINE sNumCiudadC CHAR(3); --Numero de ciudad COPPEL

--SET DEBUG FILE TO "/ifxsif01/joel/Modificados/generaestadosdecuenta_repro.out";
--TRACE ON;

--------------------------------------------------------
--	VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
LET cod_ret = "000";
LET v_cod_ret_otro = "000";

LET sql_err = "";
LET v_corta_linea_detalle 	= 40;
LET v_corta_retorno 		= 0;
--------------------------------------------------------
--	VARIABLES GENERALES
--------------------------------------------------------
LET v_sucursal      = "";
LET v_ult_dir_clie 	= 0;
--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET v_numcte        	  = "";
LET v_num_tarjeta   	  = "";
LET v_nombre_cte    	  = "";
LET v_direccion_cn  	  = "";
LET v_direccion_col	      = "";
LET v_direccion_del 	  = "";
LET v_edo_cd     		  = "";
LET v_sucursal_nombre     = "";
LET v_sucursal_gerente    = "";
LET v_sucursal_tel        = "";
LET v_cod_postal    	  = "";
LET v_cl_cobra      	  = "";
LET v_rfc           	  = "";
LET v_ruta           	  = "";
LET v_entre_calles   	  = "";
LET v_observaciones  	  = "";

LET v_numerociudad 		= 0;
LET v_numerocolonia 	= 0;
LET v_numerocalle 		= 0;
LET v_numeroextcalle 	= "";
LET v_estado 			= "";
LET v_nombrecalle		= "";
LET v_centro			= 0;
LET v_jefegrupozona		= 0;
LET v_supervisorzona	= 0;
LET v_status_cred 		= "";

LET v_confirmacion		= "";

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
LET v_capital_tc   			    = 0;	--capital_tc
LET v_interes_tc   			    = 0;	--interes_tc
LET v_iva_interes_tc   		  = 0;	--iva_interes_tc
LET v_capital_ven_tc   		  = 0;	--capital_ven_tc
LET v_interes_ven_tc   		  = 0;	--interes_ven_tc
LET v_iva_interes_ven_tc   	= 0;	--iva_interes_ven_tc
LET v_moratorios_tc   		  = 0;	--moratorios_tc
LET v_iva_moratorios_tc   	= 0;	--iva_moratorios_tc
LET v_pago_minimo_tc   		  = 0;	--sdo_pagar
LET v_interes_pago_total_tc = 0;	--interes_pago_total_tc
LET v_limite_tc   			    = 0;	--limite_tc
LET v_disponible_tc   		  = 0;	--sdo_disponible
LET v_periodo_tc_ini   		  = " ";	--periodo_tc_ini
LET v_periodo_tc_fin   		  = " ";	--periodo_tc_fin
LET v_fecha_limite_pago_tc  = " ";	--pago_antes_de
LET v_fecha_corte_tc   		  = " ";	--fecha_corte
LET v_dias_periodo_tc 		  = 0;	--dias_periodo_tc
LET v_usted_debia   		    = 0;	--usted_debia
LET v_sus_abonos   			    = 0;	--menos_abonos
LET v_sus_compras   		    = 0;	--mas_compras
LET v_sus_comisiones 		    = 0;	--sus_comisiones
LET v_dispocisiones  		    = 0;	--mas_disp_efectivo
LET v_intereses   			    = 0;	--mas_intereses
LET v_iva   				        = 0;	--mas_iva
LET v_rendimientos   		    = 0;	--mas_rendimientos
--jom ini SBC
LET v_comisiones_sbc        = 0;	--mas_comisiones_sbc
LET v_iva_comisiones_sbc    = 0;  --mas_iva_comisiones_sbc
--jom fin SBC
LET V_comis_repos           = 0; --comision por reposicion
--jom ini catalogos
let v_numerociudadcoppel  = 0;	--Numero Ciudad Direccion Cliente
let v_numerocoloniacoppel = 0;	--Numero Colonia Direccion Cliente
--jom fin catalogos

LET v_iva_comisiones	    = 0;
LET v_iva_suc				      = 0;	--iva sucursal
LET v_sdo_retenido        = 0;
LET v_fecha_apertura	    = " ";	--fecha de apertura
LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior

LET v_capital_debe 			= 0;
LET v_interes_debe 			= 0;
LET v_interes_pagado		= 0;
LET v_iva_debe 				  = 0;
LET v_iva_pagado 			  = 0;

LET v_mora_sdo_ordi			  = 0;
LET v_mora_sdo_ordi_pag		= 0;
LET v_mora_sdo_cope_pag		= 0;
LET v_mora_sdo_cope			  = 0;
LET v_mora_provi_ordi		  = 0;
LET v_mora_provi_cope		  = 0;
LET v_mora_iva_debe			  = 0;
LET v_mora_iva_pagado		  = 0;
LET v_capital_status		  = "";
LET v_fecha_cuota			    = " ";
LET v_moratorios_tcA   		= 0;	--moratorios_tc
LET v_moratorios_tcB   		= 0;	--moratorios_tc

LET v_monto_financiado		= 0;
LET v_campo_trabajo1 	    = 0;

LET v_base_iva				= 0; --CFDI 3.3
LET v_descuento				= 0; --CFDI 3.3
LET v_subtotal				= 0; --CFDI 3.3
LET v_total					= 0; --CFDI 3.3

LET v_monto_surcharge		= 0; -- Separacion de Comision e Iva
LET v_iva_surcharge			= 0; -- Separacion de Comision e Iva
LET v_comisiones_surge		= 0;

--------------------------------------------------------
--	VARIABLES GENERACION DETALLE EDO CUENTA
--------------------------------------------------------
LET v_dia          = "";
LET v_mes          = "";
LET v_ano	   	     = "";
LET v_referencia   = "";
LET v_referencia23 = "";
LET v_rfc_comer    = "";
LET v_transacc     = "";
LET v_monto        = 0;
LET v_concepto     = "";
LET v_naturaleza   = "";
LET v_letra        = "";
LET v_fecha_mov    = "";
LET v_compra       = "";
LET v_abono        = "";
LET v_maximo       = 0;
LET v_contador     = 0;
--------------------------------------------------------
--	VARIABLES GENERACION ACLARACIONES EDO CUENTA
--------------------------------------------------------
LET  v_secuencia_aclara		= 0;
LET  v_nlinea_aclara		  = 0;
LET  v_fecha_aclara			  = " ";
LET  v_descripcion			  = "";
LET  v_importe				    = 0;
--------------------------------------------------------
--	VARIABLES GENERACION MENSAJES EDO CUENTA
--------------------------------------------------------
LET v_cuenta_mensajes 		= 0;
LET  v_secuencia_mensaje	= 0;
LET  v_nlinea_mensajes		= 0;
LET  v_si_paga				    = 0;
LET  v_mensajes				    = "";

LET v_factor		    = 0;
LET v_aplica_factor = 0;
LET v_usted_debe    = 0;
--------------------------------------------------------
--	VARIABLES GENERACION PIE EDO CUENTA
--------------------------------------------------------
LET v_tasa_mensual 		  = 0 ;
LET v_tasa_anual		    = 0 ;
LET v_saldo_promedio	  = 0 ;
LET v_tasa_mora			    = 0 ;
LET v_tasa_mensual_mora	= 0 ;

LET v_sdo_acum_mes_cap = 0;
LET v_dias_acum_cap    = 0;
--------------------------------------------------------
--	VARIABLES GENERACION CLAVE DE COBRANZA
--------------------------------------------------------
LET v_cl_cobranza        = "";

LET v_tp_cliente         = "01";
LET v_situacion          = "";
LET v_situacion_esp      = ""; -- Inizializacion
LET v_estado_civil       = "";
LET v_tp_casa            = "";
LET v_sexo               = "";
LET v_cantidad           = "";
LET v_antiguedad         = "";
LET v_nacimiento         = "";
LET v_mto_tot_adeudo     = "";
LET v_adeudo_vencido     = "";
LET v_fec_ult_pago       = "";
LET v_fec_ult_pago_month = "";
LET v_fec_ult_pago_year  = "";
LET v_cuantos_avisos	   = 0;

LET v_monto_ult_convenio = "";
LET v_fecha_ult_convenio = "";
LET v_est_cumpl_convenio = "";
LET v_avisos 	    	 = "0";
LET v_nivel_eficiencia	 = 0;
LET v_fecha_ultimo_pago  = " ";

LET v_salario            = 0;
LET v_monto_adeudo		   = 0;
LET v_mto_adeudo_venc    = 0;

LET v_clave1		 	= "";
LET v_clave2		 	= "";
LET v_clave3			= "";
LET v_clave4		 	= "";
LET v_clave5            = "";
LET v_clave6            = "";

LET posicion11 = "";
LET posicion17 = "";

LET cInserto  = "";
-- jom ini parametro sal min
LET v_SalarioMinimoCoppel= 0;
-- jom fin parametro sal min
LET v_numprod = "";
LEt vfolio_csuac = '';

--INICIO-----LHM
LET v_comisiones_iva     = 0;
LET v_intereses_iva      = 0;
LET v_intereses_pag      = 0;
LET v_saldos_menos_pag   = 0;
LET v_compras_disp       = 0;
--FIN--------LHM
LET vfechacaptura        = date(1);
LET vfechahora        = date(1);
LET vdescripcion        = '';
LET vimportereclamado   = 0;
LET vMto_otorg          = 0;
LET vPos_Inserto        = 0;
LET cInsertoAux1  = '';
LET cInsertoAux2  = '';
LET vciudades	= 0;
LET v_saldo_diferido=0;
LET vlComprasDif  = 0;
LET	vlsaldo_corte = 0;
LET	v_catAux = 0;
LET iMesesLiq = 0;
LET dMonto_No_Exigible = 0;
LET cCodRetMeses = "";
LET dComPend              = 0;
LET dIvaCom               = 0;
LET cFolioSuc = "";
LET dComisiones      	= 0;
LET dComs_GastCob		= 0;
LET dTasaInt      	= 0;
LET dIntCredSolAux =0;
LET dIntCredSol =0;
LET dSaldoPromCredSolAux =0;
LET dSaldoPromCredSol =0;
LET dPagoReq =0;
LET dIntVenc      =0;
LET dSdoPromVen     =0;
LET dSdoPromVenAux     =0;
LET vCatFinal =0;
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ?ÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³ el cÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ?ÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ¡lculo correctamente";
LET v_cod_ref          = 0;
LET v_im    = 0;
LET mMntoComApert   = 0;    -- INI RQM 10 993 CAT
LET mMntoComAnual   = 0;
LET cCobrComisAnual = 0;
LET dMtoComAnualTit = 0;
LET dMtoComAnualAdi = 0;
LET dClvComAnualTit = '';
LET dClvComAnualAdi = '';
LET cCat_adicional  = '';    -- FIN RQM 10 993 CAT
LET iCountExist		= 0;
LET dtasa_prom_pond	= 0;
LET dtasa_prom_pond_fin = 0;
LET dClvComApertura	= 0;
LET v_Act	= 0;

----------------------------------------------------------------------------------
-- Se limpian variables para los campos de region, ciudad y centro de impresiÃÂÃÂ³n --
LET sNumRegion	= '0';
LET sNumCiudadB = '0';
LET sNumCiudadC = '0';

--set pdqpriority 11;

BEGIN

  ON EXCEPTION SET sql_err
	IF sql_err <> 0 THEN
	    LET cod_ret = sql_err;
        RETURN cod_ret;
	END IF
   END EXCEPTION WITH RESUME ;
   
	set isolation to dirty read;
	set lock mode to wait 3;

--   SET DEBUG FILE TO "/informix/Israel/generaestadosdecuenta_repro.out";
--   TRACE ON;

   	--##############################################################
		--##	SALARIO MINIMO COPPEL           			      ##
   	--##############################################################
       SELECT valor
         INTO v_SalarioMinimoCoppel
         FROM bdisolic:ss_param
        WHERE empresa = pempresa
          AND secuencia = 303;

          IF v_SalarioMinimoCoppel IS NULL THEN
             LET v_SalarioMinimoCoppel= 0;
          END IF;

   	--##############################################################
		--##	GENERACION ENCABEZADO EDO CUENTA				      ##
   	--##############################################################
    -------------------------------------------------------------
    --SD_MAECRED
    -------------------------------------------------------------
	SELECT a.num_producto, a.numcte,	a.sucursal,	a.fecha_apertura,
		   a.tasa_interes,	a.tasa_moratorios,
		   --DECODE(status_cred,'AA','0','BA','1','BT','2','0'),
		   status_cred,  nvl(b.act,-1)
        INTO v_numprod, v_numcte, v_sucursal, v_fecha_apertura,
           v_tasa_anual,	v_tasa_mora,
           --v_avisos, 
		   v_status_cred,v_Act
	FROM sd_maecred a, sd_maesdos b
	WHERE a.empresa = b.empresa
	AND a.num_credito = b.num_credito
	AND a.empresa = pempresa
	AND a.num_credito = pnum_credito;

	LET v_tasa_anual=59.9;
--	LET v_tasa_mora=99.75;

	IF v_status_cred = 'AA' OR (v_Act = 0 AND v_status_cred = 'E1') THEN
		LET v_avisos = '0';
	ELIF v_status_cred = 'BA' OR (v_Act = 1 AND v_status_cred = 'E1') THEN
		LET v_avisos = '1';
	ELIF v_status_cred = 'BT' OR v_status_cred IN('E2','E3') THEN
		LET v_avisos = '2';
	ELSE 
		LET v_avisos = '0';
	END IF;

	IF v_numprod ="7000" THEN--Se cambia el cat para creditos platinum
		LET v_catAux = v_Cat2;
	ELIF v_numprod ="8100" THEN --AAME RQM 10 679 se modifica para cambiar el CAT cuando sea TDC Oro
		LET v_catAux = v_Cat3;		
	ELSE
		LET v_catAux = v_Cat;
	END IF;

-------------------------------------------------------------
-- Solicitud de Resta de Tasa Moratoria - la Tasa Ordinaria
-------------------------------------------------------------
  LET  v_tasa_mora = v_tasa_mora - v_tasa_anual;
  IF v_tasa_mora < 0 THEN
	 LET v_tasa_mora = v_tasa_mora * -1;
  END IF
-------------------------------------------------------------
--SD_TARJETA
-------------------------------------------------------------
SELECT b.num_tarjeta INTO v_num_tarjeta
FROM sd_tarjeta b
WHERE b.empresa = pempresa
	AND b.num_credito = pnum_credito
	AND b.tipo_tarjeta = "T" AND b.status_tar = "A";

IF v_num_tarjeta IS NULL THEN
	-------------------------------------------------------------
	--SD_TARJETA
	-------------------------------------------------------------
	SELECT MAX(secuencia)
		INTO v_ult_dir_clie
	FROM sd_tarjeta
	WHERE empresa = pempresa
		AND num_credito = pnum_credito
		AND tipo_tarjeta="T";

	-------------------------------------------------------------
	--SD_TARJETA
	-------------------------------------------------------------
	SELECT b.num_tarjeta INTO v_num_tarjeta
	FROM sd_tarjeta b
	WHERE b.empresa = pempresa
		AND b.num_credito = pnum_credito
		AND b.secuencia = v_ult_dir_clie;
END IF
-------------------------------------------------------------
--SI_DIRECCIONES
-------------------------------------------------------------
--SI_CLIENTE
-------------------------------------------------------------
SELECT Trim(a.nombre1) || " " ||Trim(a.nombre2) || " " ||
	   Trim(a.apell_paterno) || " " ||Trim(a.apell_materno),
	   NVL(a.rfc, a.rfc_alterno),
	   NVL(SUBSTR(YEAR(a.fecha_alta), 3, 2),'')
INTO 	v_nombre_cte,
		v_rfc,
		v_antiguedad
FROM bdinteg:si_cliente a
WHERE a.numcte = v_numcte;
-------------------------------------------------------------
--SI_DIRECCIONES
-------------------------------------------------------------
SELECT 
	 decode(TRIM(NVL(b.numeroextcalle,'0')),'0','',TRIM(b.numeroextcalle)) || " " || 
	 decode(TRIM(NVL(b.numerointcalle,'0')),'0','',TRIM(b.numerointcalle)) || " " || decode(TRIM(NVL(b.departamento,'0')),'0','',TRIM(b.departamento)),
	   b.cod_postal,			b.entre_calles,
	   b.observaciones,		b.numerociudad,
	   b.numerocolonia,		b.numerocalle,
	   b.numeroextcalle,	b.estado
INTO v_direccion_cn,
	   v_cod_postal,			v_entre_calles,
	   v_observaciones,		v_numerociudad,
	   v_numerocolonia,		v_numerocalle,
	   v_numeroextcalle,	v_estado
FROM bdinteg:si_direcciones_actual b
WHERE b.numcte  = v_numcte AND tipo_dir="1";
-------------------------------------------------------------
--SI_CATCALLES
-------------------------------------------------------------
SELECT Trim(c.nombrecalle)
INTO v_nombrecalle
FROM bdinteg:si_catcalles c
WHERE c.numerocalle = v_numerocalle;
-------------------------------------------------------------
--SI_CATZONAS
-------------------------------------------------------------
SELECT d.nombrezona,			d.centro, d.jefegrupozona,			d.supervisorzona,
	   d.numerociudadcoppel,     d.numerocoloniacoppel
INTO v_direccion_col,			v_centro,v_jefegrupozona,			v_supervisorzona,
	  v_numerociudadcoppel, v_numerocoloniacoppel
FROM bdinteg:si_catzonas d
WHERE  d.numerociudad = v_numerociudad
AND  d.numerocolonia=v_numerocolonia;
-- Jom ini catalogos
if ( v_numerociudadcoppel is null or v_numerociudadcoppel = ''  or  v_numerociudadcoppel = 0) then
	let v_numerociudadcoppel = v_numerociudad;
	let v_numerocoloniacoppel = v_numerocolonia;
end if;
-- Jom fin catalogos
    -------------------------------------------------------------
--SI_CATCIUDADES
-------------------------------------------------------------
SELECT e.nombreciudad
INTO v_direccion_del
FROM bdinteg:si_catciudades e
WHERE e.numerociudad = v_numerociudad;
-------------------------------------------------------------
--SI_ESTADOS
-------------------------------------------------------------
SELECT f.nombre
INTO v_edo_cd
FROM bdinteg:si_estados f
WHERE  f.estado = v_estado;

-----------------------------------------
--------SD_CENTROSIMPRESION_COPPEL-------
SELECT LPAD(num_region,2,0),LPAD(num_ciudad_banco,4,0),LPAD(num_ciudad_coppel,3,0)
INTO sNumRegion,sNumCiudadB,sNumCiudadC
FROM "informix".sd_centrosimpresion_coppel
WHERE num_ciudad_banco = v_numerociudad;
--AND num_ciudad_coppel = v_numerociudadCoppel;

--Valida el numero de region (Centro de impresion) esta en nulo o vacio.
IF nvl(sNumRegion,'') = '' OR sNumRegion IS NULL THEN
	LET sNumRegion 	= '00';
	LET sNumCiudadB = LPAD(v_numerociudad,4,0);
	LET sNumCiudadC = LPAD(v_numerociudadCoppel,3,0);
end if;
-- Valida si la ciudad banco o ciudad coppel son diferentes a las del catalogo centros impresion.
IF sNumCiudadC != v_numerociudadCoppel THEN 
	LET sNumRegion 	= '00';
	LET sNumCiudadC = LPAD(v_numerociudadCoppel,3,0);
ELIF sNumCiudadB != v_numerociudad THEN
	LET sNumRegion 	= '00';
	LET sNumCiudadB = LPAD(v_numerociudad,4,0);
END IF;
--Valida la ciudad banco y ciudad coppel si esta en nulo o vacio.
IF nvl(sNumCiudadC,'') = '' OR sNumCiudadC IS NULL THEN
	LET sNumCiudadC = '000';
END IF;
IF nvl(sNumCiudadB,'') = '' OR sNumCiudadB IS NULL THEN
	LET sNumCiudadB = '0000';
END IF;

-------------------------------------------------------------
--SI_SUCURSALES
-------------------------------------------------------------
SELECT d.nombre, d.gerente, d.iva -- iva de moratorios


	INTO v_sucursal_nombre,	v_sucursal_gerente, v_iva_suc


FROM bdinteg:si_sucursales d
WHERE d.empresa = pempresa
	AND d.sucursal    = v_sucursal;
	
select tel1 
  into v_sucursal_tel
  from bdinteg:si_ptf 
 where id_ptf = v_sucursal
 and tipo = 'S';
	
--------------------------------------------------------
--------------------------------------------------------
LET v_direccion_cn = v_nombrecalle || v_direccion_cn;
-- Jom ini catalogos
IF (v_numerociudadcoppel IS NULL)  THEN LET v_numerociudadcoppel = '0000'; END IF;
IF (v_centro IS NULL)              THEN LET v_centro = '000000'; END IF;
IF (v_jefegrupozona IS NULL)       THEN LET v_jefegrupozona = '00000000'; END IF;
IF (v_supervisorzona IS NULL)      THEN LET v_supervisorzona = '00000000'; END IF;
IF (v_numerocoloniacoppel IS NULL) THEN LET v_numerocoloniacoppel = '0000'; END IF;
IF (v_numerocalle IS NULL)         THEN LET v_numerocalle = '000000'; END IF;
IF (v_numeroextcalle IS NULL)      THEN LET v_numeroextcalle = '00000'; END IF;

LET v_ruta = LPAD(v_numerociudadcoppel,4,'0')||"/"||
			 LPAD(v_centro,6,'0')||"/"||
			 LPAD(v_jefegrupozona,8,'0')||"/"||
			 LPAD(v_supervisorzona,8,'0')||"/"||
--			     LPAD(v_numerocolonia,4,'0')||"/"||
			 LPAD(v_numerocoloniacoppel,4,'0')||"/"||
-- Jom fin catalogos
			 LPAD(v_numerocalle,6,'0')||"/"||
			 LPAD(TRIM(v_numeroextcalle),5,'0');
--------------------------------------------------------
-------------------------------------------------------
--                   Se obtiene el inserto               --
-------------------------------------------------------
SELECT insertos
	INTO cInserto
	FROM bdicred:sd_marcaje
	WHERE empresa=pempresa
	AND num_credito= pnum_credito
	AND fecha_emision = pfechahoy;
IF cInserto IS NULL THEN
	LET cInserto='000000000000000';
END IF;

	LET iCountExist = 0;
	SELECT {AVOID_FULL("informix".sd_cuadro_comp_edocta)} count(empresa) INTO iCountExist 
	  FROM bdicred:sd_cuadro_comp_edocta WHERE mes_envio_cuadro::integer = month(pfechahoy);
	
	-- Se genera el inserto para el cuadro comparativo (CONDUSEF)  MAHR
	--IF ((SELECT count(empresa) FROM bdicred:sd_cuadro_comp_edocta WHERE mes_envio_cuadro::integer = month(pfechahoy)) > 0) THEN
	IF ( iCountExist > 0) THEN

		SELECT monto_otorgado INTO vMto_otorg FROM bdicred:sd_maesdoshist WHERE num_credito = pnum_credito AND fecha = pfechahoy;
		SELECT {AVOID_FULL("informix".sd_cuadro_comp_edocta)} no_inserto INTO vPos_Inserto FROM bdicred:sd_cuadro_comp_edocta WHERE mes_envio_cuadro::integer = month(pfechahoy)
			AND vMto_otorg >= limite_inf AND vMto_otorg <= limite_sup;
		IF vPos_Inserto IS NULL THEN 
			SELECT {AVOID_FULL("informix".sd_cuadro_comp_edocta)} MAX(no_inserto) INTO vPos_Inserto FROM bdicred:sd_cuadro_comp_edocta WHERE mes_envio_cuadro::integer = month(pfechahoy);
		END IF;
		
		LET cInsertoAux1  = SubStr(trim(cInserto), 1, vPos_Inserto - 1 );
		LET cInsertoAux2  = SubStr(trim(cInserto), vPos_Inserto + 1, length(trim(cInserto)));

		LET cInserto = trim(cInsertoAux1) || '1' || trim(cInsertoAux2);
	END IF;
	--Se obtiene inserto Octubre y noviembre
			IF  month(pfechahoy) = 10 OR  month(pfechahoy) = 11 THEN
			
				IF v_status_cred in ('AA','BA','BT','E1','E2','E3')  THEN 
			
				SELECT count(numerociudad) INTO vciudades 
				FROM bdinteg:"informix".si_ciudades_insertos
				WHERE numerociudad =v_numerociudad and estado = v_estado;	   
				  
				  IF vciudades >= 1 THEN 
				  
				  				
				LET cInsertoAux1  = SubStr(trim(cInserto), 1, len(cInserto)); 
				--LET cInsertoAux2  = SubStr(trim(cInserto), vPos_Inserto + 1, length(trim(cInserto))); 

				LET cInserto = '1' || trim(cInsertoAux1  );
				  END IF;
				END IF;

			END IF;

				
		INSERT INTO sd_encabezado_edocta
				(
				fecha_emision,		num_credito,
				num_producto,       numcte,
				num_tarjeta,    	nombre_cte,
				direccion_cn,	    direccion_col,
				direccion_del,	    edo_cd,
				sucursal_nombre,    sucursal_gerente,
				sucursal_tel,	    fecha_corte,
				rfc,			    cl_cobra,
				CP,				    ruta,
				entre_calles,	    observaciones,
				insertos,           sucursal,
				confirmacion,		num_region,
				num_ciudad_banco,	num_ciudad_coppel
				)
		 VALUES(
				pfechahoy,							pnum_credito,
				NVL(TRIM(v_numprod),''),		       	NVL(Trim(v_numcte),''),
				NVL(Trim(v_num_tarjeta),''),       	NVL(Trim(v_nombre_cte),''),
				NVL(Trim(v_direccion_cn),''),      	NVL(Trim(v_direccion_col),''),
				NVL(Trim(v_direccion_del),''),     	NVL(Trim(v_edo_cd),''),
				NVL(Trim(v_sucursal_nombre),''),   	NVL(Trim(v_sucursal_gerente),''),
				NVL(Trim(v_sucursal_tel),''),      	pfechahoy,
				NVL(Trim(v_rfc),''),  		       	NVL(TRIM(v_cl_cobra),''),
				NVL(Trim(v_cod_postal),''),	       	NVL(TRIM(v_ruta),''),
				NVL(TRIM(v_entre_calles),''),       NVL(TRIM(v_observaciones),''),
				cInserto,                           NVL(TRIM(v_sucursal),''),
				NVL(TRIM(v_confirmacion),''),		NVL(sNumRegion,''),
				NVL(sNumCiudadB,''),				NVL(sNumCiudadC,'')
				);
				
				IF v_ruta = '' OR v_ruta is null THEN
					UPDATE sd_encabezado_edocta SET num_region = '00' WHERE num_credito = pnum_credito AND ruta = '';
				END IF;

--##############################################################
--##	GENERACION ENCABEZADO2 EDO CUENTA				      ##
--##############################################################
-------------------------------------------------------------
--SD_AMORTIZA_CREDITO
-------------------------------------------------------------
	 SELECT interes_debe,
			iva_debe,
			campo_trabajo1
	   INTO v_interes_debe,
			v_iva_debe,
			v_campo_trabajo1
	  FROM sd_amortiza_credito
	 WHERE empresa = pempresa
	   AND num_credito = pnum_credito
	   AND fecha_cuota=pfechahoy;

	LET v_interes_tc = v_interes_debe;
	LET v_iva_interes_tc = v_iva_debe;
	LET v_iva_interes_ven_tc = v_campo_trabajo1;


	SELECT 	count(*) INTO v_cuantos_avisos
	FROM sd_amortiza_credito
	WHERE empresa = pempresa
	AND num_credito = pnum_credito
	AND capital_status IN ("2","7","6");
-------------------------------------------------------------
--PERIODO ANTERIOR
-------------------------------------------------------------
EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy,-1,DAY(pfechahoy))
	INTO v_cod_ret_otro,v_periodo_anterior,v_dias_periodo_tc;

IF v_cod_ret_otro <> "000" AND cod_ret = "000" THEN
	LET cod_ret = v_cod_ret_otro;
END IF

--PERIODO
LET v_periodo_tc_ini = v_periodo_anterior + 1 UNITS DAY;
LET v_periodo_tc_fin = pfechahoy;

--DIAS DEL PERIODO
LET v_dias_periodo_tc = (v_dias_periodo_tc * -1) ;
-----------------------GENERA DETALLE EDO CUENTA CREDISOLUCIONES-------------

select  sum(saldo_pendiente)  
  into v_saldo_diferido
  from sd_detalle_dif_edocta
  where fecha_emision = pfechahoy and num_credito = pnum_credito;
  
--  SELECT  {+INDEX(sd_maecredcrd idx_credisol )} sum(a.monto) into vlComprasDif
  SELECT  sum(a.monto) into vlComprasDif
	   FROM sd_movhisedocta a
	  WHERE a.empresa = pempresa AND
		    a.num_credito = pnum_credito
		AND a.codigo_fun  ='061'
		AND a.codigo_ref = '5'; 	
-----------------------------------------------------------
-------------------------------------------------------------
--SD_MAESDOSHIST
-------------------------------------------------------------
		-- CAPITAL VENCIDO,PAGO PARA NO GENERAR INTERESES, LIMITE DE CREDITO
SELECT     monto_vencido + mto_venc_trasp,
		   sdo_cap_insoluto,
	   monto_otorgado,
	   sdo_retenido,
	   sdo_acum_mes_cap,
	   dias_acum_cap,
	   NVL(sdo_cap_insoluto,0),
	   NVL(monto_vencido,0) + NVL(mto_venc_trasp,0),
	   NVL(int_tra_no_exig,0),
	   NVL(sdo_moratorio,0) + NVL(sdo_contab_mora,0),
	   monto_financiado,
	   mto_fin_ven_trasp
	INTO v_capital_ven_tc,
	   v_interes_pago_total_tc,
	   v_limite_tc,
	   v_sdo_retenido,
	   v_sdo_acum_mes_cap,
	   v_dias_acum_cap,
	   v_monto_adeudo,
	   v_mto_adeudo_venc,
	   v_interes_ven_tc,
	   v_moratorios_tc,
	   v_monto_financiado,
	   iMoras
FROM sd_maesdoshist
WHERE fecha =pfechahoy
AND empresa = pempresa
AND num_credito = pnum_credito;
-------------------------------------------------------------
--SD_MAESDOSHIST
-------------------------------------------------------------
		--USTED DEBIA
SELECT sdo_cap_insoluto	INTO v_usted_debia
FROM sd_maesdoshist
WHERE fecha = v_periodo_anterior
AND empresa= pempresa
AND num_credito = pnum_credito;

-------------------------------------------------------------
-- sd_indicador_cred  (para obtener v_clave6 de la clave de cobranza)
-------------------------------------------------------------
EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(pfechahoy, -1, day(pfechahoy))  INTO v_cod_ret_otro, dFHoy_1m, iDiasTrans;
EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(pfechahoy, -13, day(pfechahoy)) INTO v_cod_ret_otro, dFHoy_13m, iDiasTrans;
EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(pfechahoy, -12, day(pfechahoy)) INTO v_cod_ret_otro, dFHoy_12m, iDiasTrans;

SELECT f_primer_compra, fecha_alta, fecha_ultima_compra INTO dFech_1erComp, dFech_alta, dFhUltCompAct FROM bdicred:sd_indicador_cred 
 WHERE empresa = pempresa AND num_credito = pnum_credito; 

SELECT ind.fecha_ultima_compra, ind.fecha_ultimo_pago, dos.sdo_cap_insoluto INTO dFhUltCompAnt, dFhUltPagoAnt, v_deuda_Ant 
  FROM bdicred:sd_indicador_cred_hist ind, bdicred:sd_maesdoshist dos
 WHERE ind.empresa = dos.empresa AND ind.num_credito = dos.num_credito AND ind.fecha = dos.fecha AND ind.empresa = pempresa 
   AND ind.num_credito = pnum_credito AND ind.fecha = dFHoy_1m;

-------------------------------------------------------------
--SD_MAECREDANEXO
-------------------------------------------------------------
		--FECHA LIMITE DE PAGO
SELECT prox_fecha_pago, fecha_proceso INTO v_fecha_limite_pago_tc , vfcancelado
FROM sd_maecredanexo
WHERE empresa = pempresa AND num_credito = pnum_credito;

		--FECHA PAGO INMEDIATA
IF v_capital_ven_tc > 0 THEN
	LET v_fecha_limite_pago_tc =  DATE(1);
END IF
-------------------------------------------------------------
--SD_MOVHISEDOCTA
-------------------------------------------------------------
-- codigo_fun     codigo_ref     transacc     descripcion
-- 002            30             6800         RETIRO EFECTIVO CAJERO
-- 002            40             6871         RETIRO EFECTIVO CAJRED
-- 002            41             6872         RETIRO EFECTIVO CAJCON
-- 002            42             6873         RETIRO EFECTIVO CAJINT
-- codigo_fun     codigo_ref     transacc     descripcion
-- 339            3              6804         COMISION CONSULTA CAJERO 15%
-- 339            24             6874         COMISION CONSULTA CAJRED 15%
-- 339            25             6875         COMISION CONSULTA CAJCON 15%
-- 339            26             6876         COMISION CONSULTA CAJINT 15%
-- codigo_fun     codigo_ref     transacc     descripcion
-- 339            1              6802         COMISION X RETIRO CAJERO 15%
-- 339            17             6857         COMISION X RETIRO CAJERO RED 10%
-- 339            18             6858         COMISION X RETIRO CAJERO CONV 10%
-- 339            19             6859         COMISION X RETIRO CAJERO INTER 10%


--MENOS SUS ABONOS,MAS SUS COMPRAS,MAS COMISIONES,MAS DISPOSICIONES EM EFECTIVO,MAS INTERESES,MAS IVA
--SELECT 	 {+INDEX(sd_maecredcrd idx_credisol )} SUM(CASE WHEN codigo_fun IN (select {AVOID_FULL("informix".sd_conceptospagomanual)} cod_fun from bdicred:sd_conceptospagomanual)  THEN --se agregan aplicacion de pago
SELECT 	SUM(CASE WHEN codigo_fun IN (select {AVOID_FULL("informix".sd_conceptospagomanual)} cod_fun from bdicred:sd_conceptospagomanual)  THEN --se agregan aplicacion de pago
		CASE WHEN codigo_ref = 1  THEN  monto ELSE 0 END
		ELSE  0 END), 	--MENOS SUS ABONOS
		SUM(CASE WHEN codigo_fun   = '002' THEN	CASE WHEN codigo_ref in (37,57,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,113,937,938)  THEN  monto ELSE 0 END ELSE  0 END),	--MAS SUS COMPRAS AAME.--Se anexa nuevo codigo_ref (86,87), correspondientes a la nueva transaccion 6846 y 7746. 
		SUM(CASE WHEN (codigo_fun   = '339' or codigo_fun   = '039') THEN
		CASE WHEN (codigo_ref IN (50,51,1,3,24,25,26,17,18,19,90,91,92,93,94,95,96,100,101,993,994,995,996)  or ( codigo_ref = 28 and codigo_fun = '039'))
		-- 1,3,17,18,19,24,25,26,50,51,90,91,92,93,94,95,96,100,101
		 THEN monto ELSE 0 END -- Se agregan SURCHARGE
		ELSE  0 END),	--MAS COMISIONES--JMAH Se agrega codigo de comision por apertura
		SUM(CASE WHEN codigo_fun   = '002' THEN
		CASE WHEN codigo_ref IN (30,50,40,41,42,60,61,62,63,64,65)  THEN  monto ELSE 0 END
		ELSE  0 END),	--MAS DISPOSICIONES EN EFECTIVO
		SUM(CASE WHEN (codigo_fun   = '605' or codigo_fun   = '061') THEN
		CASE WHEN ( codigo_ref IN(2,125,127) or codigo_ref = 8) THEN  monto ELSE 0 END
		ELSE  0 END),	--MAS INTERESES
		SUM(CASE WHEN (codigo_fun   = '605' or codigo_fun   = '061') THEN
		CASE WHEN (codigo_ref IN(3,126,128) or codigo_ref = 16 )  THEN  monto ELSE 0 END
		ELSE  0 END) , --MAS IVA INTERESES
		SUM(CASE WHEN codigo_fun   = '340'  THEN
		CASE WHEN codigo_ref IN (1,2,27,30,31,901,902,903,904)  THEN  monto ELSE 0 END
		ELSE  0 END),	--MAS IVA COMISONES--JMAH Se agrega codigo de comision por apertura
-- jom ini SBC
		SUM(CASE WHEN codigo_fun   = '336'  THEN
		CASE WHEN codigo_ref = 23  THEN  monto ELSE 0 END
		ELSE  0 END),	--MAS COMISONES SBC
		SUM(CASE WHEN codigo_fun   = '336'  THEN
		CASE WHEN codigo_ref = 24  THEN  monto ELSE 0 END
		ELSE  0 END),	--MAS IVA SBC
-- jom fin SBC
-- JOM REPOS INI
		SUM(CASE WHEN codigo_fun   = '033'  THEN
		CASE WHEN codigo_ref in(6212,6218,6219,6220,6221)  THEN  monto ELSE 0 END --adlm: se agregan codigos_ref faltantes
		ELSE  0 END),	--COMISION REPOSICION
-- JOM REPOS FIN
		MAX(fecha_mov) -- FECHA ULTIMO PAGO
		--SUM(CASE WHEN codigo_fun   = '339'  THEN
		--CASE WHEN codigo_ref = 96  THEN  monto ELSE 0 END
		--ELSE  0 END)	--COMISION POR APERTURA
INTO 	v_sus_abonos,
		v_sus_compras,
		v_sus_comisiones,
		v_dispocisiones,
		v_intereses,
		v_iva,
		v_iva_comisiones,
		v_comisiones_sbc,
		v_iva_comisiones_sbc,
		V_comis_repos,
		v_fecha_ultimo_pago
        --mMntoComApert
FROM   	sd_movhisedocta
WHERE num_credito = pnum_credito;

--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
	SELECT NVL(SUM(decode(tc.comi_o_seg, '1', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0),
		 NVL(SUM(decode(tc.comi_o_seg, '4', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0)
	INTO dComPend,
		 dIvaCom
	FROM bdicred:"informix".sd_detcomi dc,
		 bdicred:"informix".sd_tpcomis tc
   WHERE dc.empresa     = pempresa
	 AND dc.num_credito = pnum_credito
	 AND dc.estado_com  = 'A'
	 AND dc.empresa     = tc.empresa
	 AND dc.cod_comis   = tc.cod_comis
	 AND tc.comi_o_seg IN ('1','4');

	 LET v_intereses_iva = NVL(v_iva,0);

-- jom ini SBC
	LET v_sus_comisiones = NVL(v_sus_comisiones,0) + NVL(v_comisiones_sbc,0) + NVL(V_comis_repos,0);

	LET v_capital_tc = NVL(v_monto_financiado,0) - NVL(v_capital_ven_tc,0);

	--IVA COMISIONES MAS IVA INTERESES
	LET v_iva = NVL(v_iva,0) + NVL(v_iva_comisiones,0) + NVL(v_iva_comisiones_sbc,0) + NVL(v_iva_surcharge,0);
-- jom fin SBC
	--MORATORIOS
	--LET v_moratorios_tc = v_moratorios_tcA + v_moratorios_tcB;

	IF v_moratorios_tc <= 0 then let v_moratorios_tc = 0; end if;

	LET v_iva_moratorios_tc =  (v_moratorios_tc * v_iva_suc) + dIvaCom;

	IF  (v_iva_moratorios_tc  IS NULL) OR (v_iva_moratorios_tc < 0) or (v_iva_moratorios_tc <= 0) THEN
	--IF   (v_iva_moratorios_tc <= 0) THEN

		LET v_iva_moratorios_tc = 0;
	END IF

	--CALCULO DEL INTERES VENCIDO

	IF (v_interes_ven_tc - v_interes_tc >= 0) then
		LET v_interes_ven_tc = v_interes_ven_tc - v_interes_tc;
	END IF

	-- PAGO MINIMO
	LET v_pago_minimo_tc = NVL(v_capital_tc,0)  + NVL(v_capital_ven_tc,0)  +
						   NVL(v_interes_ven_tc ,0) + NVL(v_iva_interes_ven_tc ,0) + NVL(v_moratorios_tc,0)  + NVL(v_iva_moratorios_tc,0) + NVL(dComPend,0) ;

	--USTED DEBE
	LET v_usted_debe = v_interes_pago_total_tc;

	-- CREDITO DISPONIBLE
	IF v_interes_pago_total_tc < 0 THEN
		LET v_disponible_tc  = ((v_interes_pago_total_tc * -1) + v_limite_tc) - v_sdo_retenido;
	ELSE
		LET v_disponible_tc = v_limite_tc - (v_interes_pago_total_tc + v_sdo_retenido);
		IF v_disponible_tc < 0 THEN
			LET v_disponible_tc = 0;
		END IF
	END IF

		--PAGO PARA NO GERERAR INTERES
		LET v_interes_pago_total_tc = v_interes_pago_total_tc +
									NVL(v_interes_ven_tc ,0) + NVL(v_iva_interes_ven_tc ,0) + NVL(v_moratorios_tc,0)  + NVL(v_iva_moratorios_tc,0);
		
		LET vlsaldo_corte = v_interes_pago_total_tc;
		
		IF v_interes_pago_total_tc < 0 THEN
			LET v_interes_pago_total_tc = 0;
		END IF
		--FECHA DE CORTE
		LET v_fecha_corte_tc = pfechahoy;

		--IF (v_fecha_apertura = v_periodo_tc_fin) THEN
			---LET v_iva = 0;
			--LET v_intereses = 0;
		--ELSE
			LET v_iva = NVL(v_iva,0);
			LET v_intereses = NVL(v_intereses,0);
		--END IF
	
--INICIO-----LHM--GRAFICA DE BARRAS
        LET v_comisiones_iva = NVL(v_sus_comisiones,0) + NVL(v_iva_comisiones,0) + NVL(v_iva_comisiones_sbc,0);
       	LET v_intereses_iva = nvl(v_intereses,0) + NVL(v_intereses_iva,0);         
		LET v_saldos_menos_pag = NVL(v_usted_debia,0);
        IF v_saldos_menos_pag < 0 THEN
            LET v_saldos_menos_pag = 0;
        END IF
    LET v_sus_compras = nvl(v_sus_compras,0) + nvl(vlComprasDif,0);    
    LET v_compras_disp = NVL(v_sus_compras,0) + NVL(v_dispocisiones,0);
		LET v_intereses_pag = NVL(v_intereses,0);
--FIN--------LHM
     

-- ADLM separacion de Sourcharge COMISION e IVA
--	SELECT  {+INDEX(sd_maecredcrd idx_credisol )} SUM(CASE WHEN (codigo_fun   = '339') THEN
	SELECT  SUM(CASE WHEN (codigo_fun   = '339') THEN
		CASE WHEN (codigo_ref IN (90,91,92,93,94,95,993,994,995,996))
		 THEN monto ELSE 0 END 
		ELSE  0 END) -- monto total surcharge (comision e iva)	
	INTO v_monto_surcharge 
	FROM  sd_movhisedocta
	WHERE num_credito = pnum_credito;
	
	LET v_comisiones_surge = NVL((NVL(v_monto_surcharge,0)/(1 + v_iva_suc)),0);
	LET v_iva_surcharge =  NVL(v_monto_surcharge,0) - NVL(v_comisiones_surge,0);
	
	LET v_sus_comisiones = NVL(v_sus_comisiones,0) - NVL(v_iva_surcharge,0);
	LET v_iva = NVL(v_iva,0) + NVL(v_iva_surcharge,0);

-- ADLM separacion de Sourcharge COMISION e IVA	 
	 

		--- RQI 12 297: CFDI 3.3 ---	 
		--- Campo base_iva
					LET v_base_iva = nvl(v_iva,0)/nvl(v_iva_suc,0); 
				
		--- Campos descuento y subtotal		
				if nvl(v_intereses,0) > 0 or nvl(v_sus_comisiones,0) > 0 then 
						LET v_descuento = 0.00;
						LET v_subtotal  = nvl(v_intereses,0) + nvl(v_sus_comisiones,0);
					else 
						LET v_descuento = 0.01;
						LET v_subtotal	= 0.01;
				end if 
					LET v_total = nvl(v_sus_comisiones,0) + nvl(v_intereses,0) + nvl(v_iva,0);
		
		--- FIN RQI 12 297: CFDI 3.3 -- 	 

	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
	IF v_fecha_limite_pago_tc IS NULL THEN
	   LET v_fecha_limite_pago_tc = pfechahoy;
	END IF;	
	
	
	INSERT INTO sd_encabezado2_edocta
				(
				fecha_emision,			num_credito,
				capital_tc,				interes_tc,
				iva_interes_tc,			capital_ven_tc,
				interes_ven_tc,			iva_interes_ven_tc,
				moratorios_tc,			iva_moratorios_tc,
				sdo_pagar,				interes_pago_total_tc,
				limite_tc,				sdo_disponible,
				periodo_tc_ini,			periodo_tc_fin,
				pago_antes_de,			fecha_corte,
				dias_periodo_tc,		usted_debia,
				menos_abonos,			mas_compras,
				sus_comisiones,			mas_disp_efectivo,
				mas_intereses,			mas_iva,
				mas_rendimientos,		sdo_debe,
				menos_o_abonos,			mas_o_cargos,
				usted_debe,				mensajes,
                comisiones_iva,         intereses_iva,
                intereses_pag,          saldo_menos_pag,
                compras_disp,			saldo_diferido,
				saldo_total,			saldo_corte,
				comisionxcobrar,		base_iva, 				  
				descuento,				subtotal,			total 
				)
		VALUES (
				pfechahoy,					TRIM(pnum_credito),
				NVL(v_capital_tc,0),		NVL(v_interes_tc,0),
				NVL(v_iva_interes_tc,0),	NVL(v_capital_ven_tc,0),
				NVL(v_interes_ven_tc,0),	NVL(v_iva_interes_ven_tc,0),
				NVL(v_moratorios_tc,0),		NVL(v_iva_moratorios_tc,0),
				NVL(v_pago_minimo_tc,0),	NVL(v_interes_pago_total_tc,0),
				NVL(v_limite_tc,0),			NVL(v_disponible_tc,0),
				v_periodo_tc_ini,			v_periodo_tc_fin,
				v_fecha_limite_pago_tc,		v_fecha_corte_tc,
				NVL(v_dias_periodo_tc,0),	NVL(v_usted_debia,0),
				NVL(v_sus_abonos,0),		NVL(v_sus_compras,0),
				NVL(v_sus_comisiones,0),	NVL(v_dispocisiones,0),
				NVL(v_intereses,0),			NVL(v_iva,0),
				NVL(v_rendimientos,0),		0,
				0,							0,
				0,							"",
                NVL(v_comisiones_iva,0),    NVL(v_intereses_iva,0),
                NVL(v_intereses_pag,0),     NVL(v_saldos_menos_pag,0),
                NVL(v_compras_disp,0),		NVL(v_saldo_diferido,0),
                NVL(v_saldo_diferido,0) + NVL(v_interes_pago_total_tc,0),
				vlsaldo_corte, NVL(dComPend,0), NVL(v_base_iva,0), 
				NVL(v_descuento,0), NVL(v_subtotal,0), NVL(v_total,0)
				);
   	--##############################################################
	--##	GENERACION DETALLE	 EDO CUENTA				          ##
   	--##############################################################

    --------------------------------------------------------
    --      GENERA USTED DEBIA
    --------------------------------------------------------
    LET v_maximo = 1;
	
	INSERT INTO sd_detalle_edocta
			(
			fecha_emision,		num_credito,
			secuencia,			fecha_mov,
			concepto,			cargos,
			nlinea
		    )
		VALUES(
			pfechahoy,			pnum_credito,
			v_maximo,			"",
			"USTED DEBIA",		NVL(v_usted_debia,0),
			1
		    );
    --------------------------------------------------------
    --      GENERA EL DETALLE DE LAS CUENTAS
    --------------------------------------------------------
--	FOREACH SELECT 	 {+INDEX(sd_maecredcrd idx_credisol )} 	a.fecha_mov,secuencia,DAY(a.fecha_mov),			MONTH(a.fecha_mov),
	FOREACH SELECT 	 a.fecha_mov,secuencia,DAY(a.fecha_mov),			MONTH(a.fecha_mov),
					YEAR(a.fecha_mov),			a.referencia,
					a.referencia23,				a.rfc_comer,
					a.transacc_suc,				--a.monto,
					case
						when TRIM(a.descripcion) = 'PAGO MINIMO APOYO 2020'
						    then 0 
						else
						   a.monto
				    end,
--					TRIM(c.descripcion),
					case
                        when usuario = 'crr92579'
                           then 'ABO. CORR. CGO. DUPLI.'
 					    when substr(usuario,1,4) = 'BC05'
                           then 'ABO. CORR. CGO. DUPLI.'
 					    when substr(usuario,1,3) = 'B05'
                           then 'ABO. CORR. CGO. DUPLI.'
						when TRIM(a.descripcion) = 'PAGO MINIMO APOYO 2020'
						    then TRIM(a.descripcion)||'-->'||a.monto 
                        else
                           TRIM(a.descripcion)
                    end,
                    a.naturaleza,
                DECODE( MONTH(a.fecha_mov),
                		"1","ENE","2","FEB","3","MAR",
                		"4","ABR","5","MAY","6","JUN",
                		"7","JUL","8","AGO","9","SEP",
                		"10","OCT","11","NOV","12","DIC"),a.codigo_ref, a.folio_suc

     		INTO    vlfechaor,vlsecuencia,v_dia,					v_mes,
     				v_ano, 					v_referencia,
     				v_referencia23,			v_rfc_comer,
     				v_transacc,				v_monto,
    				v_concepto,				v_naturaleza,
    				v_letra, v_cod_ref, cFolioSuc--RQI 22 268 JMAH


			FROM sd_movhisedocta a
			WHERE a.num_credito = pnum_credito
			  AND a.codigo_fun  <>'061'
			union 
              SELECT  a.fecha_mov, max(secuencia), DAY(a.fecha_mov),			MONTH(a.fecha_mov),
						 YEAR(a.fecha_mov),			'',
						 '',	'', --substr(a.referencia,18,12) || a.referencia23
						 min(a.transacc_suc),				sum(a.monto),		
						 'CARGO POR CREDISOLUCIONES                '|| substr(a.referencia,18,12) || '   '|| a.referencia23 || '  '||  a.rfc_comer ||
     					 (select '  Capital   $'|| lpad(monto, 12) from bdicred:sd_movhisedocta where num_credito = pnum_credito and fecha_mov = a.fecha_mov AND codigo_fun  ='061' and codigo_ref = 5 and referencia like '%'|| substr(a.referencia,18,12) ||'%') ||
						 nvl((select '  Intereses $'|| lpad(monto,12) from bdicred:sd_movhisedocta where num_credito = pnum_credito and fecha_mov = a.fecha_mov AND codigo_fun  ='061' and codigo_ref = 8 and referencia like '%'|| substr(a.referencia,18,12) ||'%'),'') ||
						 nvl((select '  IVA       $'|| lpad(monto,12) from bdicred:sd_movhisedocta where num_credito = pnum_credito and fecha_mov = a.fecha_mov AND codigo_fun  ='061' and codigo_ref = 16 and referencia like '%'|| substr(a.referencia,18,12) ||'%'),'') ,
						a.naturaleza,
						DECODE( MONTH(a.fecha_mov),
								"1","ENE","2","FEB","3","MAR",
								"4","ABR","5","MAY","6","JUN",
								"7","JUL","8","AGO","9","SEP",
								"10","OCT","11","NOV","12","DIC") ,0, a.folio_suc --RQI 22 268 JMAH	

					FROM sd_movhisedocta a
					WHERE a.num_credito = pnum_credito
                      AND a.codigo_fun  ='061'
                      GROUP BY 1,6,7,8,11,12,14,15
					ORDER BY 1,2

			IF v_monto = 0 AND substr(trim(v_concepto),1,22) != 'PAGO MINIMO APOYO 2020' THEN
				CONTINUE FOREACH;
			END IF
		    --------------------------------------------------------
		    --      GENERO LA DESCRIPCION DEL MOVIMIENTO
		    --------------------------------------------------------
			
			IF   ((v_transacc in ('8197')) AND (v_cod_ref = 1)) THEN 
				LET v_concepto = TRIM(SUBSTRING(cFolioSuc FROM 6))||" Abono por remesa de BTS";		
				
			ELIF ((v_transacc in ('7796')) AND (v_cod_ref = 1)) THEN  --- Folio de aclaracion Fallecidos
				LET v_concepto = v_concepto ||" Folio de aclaracion F"||TRIM(SUBSTRING(cFolioSuc FROM 7));
				
			ELIF v_transacc in ('8372') THEN  --- CARGO PROGRAMA DE APOYO 
				LET v_concepto = "CARGO DE INTERES PROGRAMA DE APOYO "||TRIM(SUBSTRING(cFolioSuc FROM 9));	
				
			ELIF v_transacc in ('8373') THEN  --- CARGO PROGRAMA DE APOYO 
				LET v_concepto = "CARGO DE IVA PROGRAMA DE APOYO "||TRIM(SUBSTRING(cFolioSuc FROM 9));						
				
			ELIF ((v_transacc in ('6283')) AND (v_cod_ref = 1)) THEN --- Se agrega transaccion OXXO
				LET v_concepto = v_concepto ||" - "||TRIM(SUBSTR(cFolioSuc,1,6));	
				
			ELIF ((v_transacc in ('6284')) AND (v_cod_ref = 1)) THEN --- Se agrega transaccion 7Eleven
				LET v_concepto = v_concepto ||" - "||TRIM(SUBSTR(cFolioSuc,1,5));	
							
			ELIF   ((v_transacc in ('8275')) AND (v_cod_ref = 1)) THEN 
				LET v_concepto = TRIM(SUBSTRING(cFolioSuc FROM 5))||" Abono por remesa de Appriza";	
	
			ELIF v_referencia IS NULL THEN
--jom ini sbc
                if trim(v_concepto) = "SU PAGO CON CHEQUE" then
                    LET v_concepto = NVL(TRIM(v_concepto),'') || " " || trim(v_referencia23);
                else
						IF (v_transacc in ('4002','4001','5080','5212','5260')) THEN	--RQI 22 268 JMAH
							LET v_concepto = NVL(TRIM(v_concepto),'')|| " Folio de aclaracion " ||TRIM(SUBSTR(cFolioSuc,7,10));
						ELSE
							LET v_concepto = NVL(TRIM(v_concepto),'');
						END IF;
                end if;
--jom fin sbc
			ELSE
							
				IF v_referencia[1,1] = "i" AND (v_transacc not in ('8071','8072')) THEN ----JMAH
                   IF (v_transacc in ('6800','6871','6873')) THEN
                       LET v_concepto = TRIM(SUBSTRING(v_referencia FROM 18))||NVL(TRIM(v_referencia23),'');
				   ELIF (v_transacc = '6901') THEN
                        --IF   (v_referencia23 = 'COMXRET1') THEN 
                        --    LET v_concepto = " Comision por Retiro del dia 26-05-2017 del folio:" || TRIM(SUBSTRING(cFolioSuc FROM 1 FOR  16));
                        --ELIF (v_referencia23 = 'COMXRET2') THEN 
                        --    LET v_concepto = " Comision por Retiro del dia 27-05-2017 del folio:" || TRIM(SUBSTRING(cFolioSuc FROM 1 FOR  16));            
                        --ELIF (v_referencia23 = 'COMXRET3') THEN 
                        --    LET v_concepto = " Comision por Retiro del dia 28-05-2017 del folio:" || TRIM(SUBSTRING(cFolioSuc FROM 1 FOR  16));
                        --ELIF (v_referencia23 = 'COMXRET4') THEN 
                        --    LET v_concepto = " Comision por Retiro del dia 29-05-2017 del folio:" || TRIM(SUBSTRING(cFolioSuc FROM 1 FOR  16));
                        --ELIF (v_referencia23 = 'COMXRET5') THEN 
                        --    LET v_concepto = " Comision por Retiro del dia 30-05-2017 del folio:" || TRIM(SUBSTRING(cFolioSuc FROM 1 FOR  16));
                        --ELIF (v_referencia23 = 'COMXRET6') THEN 
                        --    LET v_concepto = " Comision por Retiro del dia 31-05-2017 del folio:" || TRIM(SUBSTRING(cFolioSuc FROM 1 FOR  16));
                        --ELIF (v_referencia23 = 'COMXRET7') THEN 
                        --    LET v_concepto = " Comision por Retiro del dia 01-06-2017 del folio:" || TRIM(SUBSTRING(cFolioSuc FROM 1 FOR  16));
                        --ELSE
							  LET v_concepto =  NVL(TRIM(v_concepto),'');
                        --END IF    	
                   ELSE
                       LET v_concepto = NVL(TRIM(SUBSTRING(v_referencia FROM 18)),'')
                                        || "  " ||
                                        NVL(TRIM(v_rfc_comer),'')
                                        || "  " ||
                                        NVL(TRIM(v_referencia23),'');
                   END IF

                   IF v_concepto[1,1] = "i" THEN
                        LET v_concepto = TRIM(SUBSTRING(v_concepto FROM 18));				   
                   END IF
					   
				ELSE
                    IF TRIM(v_concepto) = "PAGO CORRESPONSAL COPPEL" THEN
                        LET v_concepto = NVL(TRIM(v_concepto),'')|| "  " ||TRIM(v_referencia);
                    ELSE
                        IF (v_transacc not in ('8071','8072')) THEN	
							IF (v_transacc in ('4002','4001','5080','5212','5260')) THEN	--RQI 22 268 JMAH
								LET v_concepto = NVL(TRIM(v_concepto),'')|| " Folio de aclaracion " ||TRIM(SUBSTR(cFolioSuc,7,10));
							ELSE

								LET v_concepto = NVL(TRIM(v_concepto),'')|| "  " ||TRIM(v_referencia[1,40]);
							END IF
						END IF
                    END IF
				END IF
			END IF
			
			LET v_concepto = replace(TRIM(v_concepto), 'SUR. RETIRO', 'SUR. RETIRO + IVA');
			LET v_concepto = replace(TRIM(v_concepto), 'SUR. CONSULTA', 'SUR. CONSULTA + IVA');

		    --------------------------------------------------------
		    --ARMO LA FECHA DE MOVIMIENTO CON LETRA
		    --------------------------------------------------------
			IF v_mes IS NOT NULL THEN
		     	LET v_fecha_mov = Trim(v_dia)  || "/" ||
		     					  Trim(v_letra)|| "/" ||
		     					  v_ano[3]||v_ano[4];
			END IF
		    --------------------------------------------------------
		    --TRAIGO EL MONTO DEPENDIENDO SI ES UNA ENTRADA O SALIDA
		    --------------------------------------------------------
			IF v_naturaleza IS NOT NULL THEN
				IF v_naturaleza = "A" THEN
					LET v_abono  = v_monto;
				ELSE
					LET v_compra = v_monto;
				END IF;
			ELSE
				LET v_compra = v_monto;
			END IF;
		    --------------------------------------------------------
		    --TRAIGO EL SERIAL CONSECUTIVO DE LA TABLA DETALLE EDOCUENTA
		    --------------------------------------------------------
			LET v_maximo = v_maximo + 1 ;
			LET v_contador = 0;
		    --------------------------------------------------------
		    --DIVIDO EL CONCEPTO DEL MOVIMIENTOS EN VARIAS LINEAS
		    --------------------------------------------------------

				FOREACH EXECUTE PROCEDURE corta_linea(v_concepto,v_corta_linea_detalle)
				INTO v_concepto, v_corta_retorno

					LET v_contador = v_contador + 1;
					IF v_contador = 1 THEN
						
					INSERT INTO sd_detalle_edocta
							(
						 	fecha_emision,		num_credito,
						 	secuencia,			fecha_mov,
						 	concepto,			cargos,
							abonos,				nlinea
							)
						VALUES
							(
							pfechahoy,			pnum_credito,
							v_maximo,			v_fecha_mov,
							Trim(v_concepto),	v_compra,
							v_abono,			v_contador
							);
					ELSE
						 INSERT INTO sd_detalle_edocta
							(
							fecha_emision,		num_credito,
							secuencia,			concepto,
							nlinea
							)
						VALUES(
							pfechahoy,			pnum_credito,
							v_maximo,			Trim(v_concepto),
							v_contador
							);
					END IF;

				END FOREACH;

		    --------------------------------------------------------
		    --INICIALIZA LAS VARIABLES
		    --------------------------------------------------------
			LET v_fecha_mov    = "";
			LET v_concepto     = "";
			LET v_compra       = "";
			LET v_abono        = "";

	END FOREACH;

    --------------------------------------------------------
    --      GENERA USTED DEBE
    --------------------------------------------------------
    LET v_maximo = v_maximo + 1;
	 INSERT INTO sd_detalle_edocta
	 		(
			fecha_emision,		num_credito,
			secuencia,			fecha_mov,
			concepto,			cargos,
			nlinea
			)
			VALUES
			(
			pfechahoy,			pnum_credito,
			v_maximo,		"",
			"USTED DEBE",		NVL(v_usted_debe,0),
			1
			);
	
	IF v_status_cred ='FF' THEN 
			  --LET v_maximo = v_maximo + 1;
			   INSERT INTO sd_detalle_edocta
				(
					fecha_emision,		num_credito,
					secuencia,			fecha_mov,
					concepto,			
					nlinea
					)
					VALUES
					(
					pfechahoy,			pnum_credito,
					0,		day(vfcancelado)||'/'|| 
					DECODE( MONTH(vfcancelado),
								"1","ENE","2","FEB","3","MAR",
								"4","ABR","5","MAY","6","JUN",
								"7","JUL","8","AGO","9","SEP",
								"10","OCT","11","NOV","12","DIC")
					||'/'||substr(year(vfcancelado),3,2),
					"TARJETA DE CREDITO CANCELADA " ,0
					);
	ELSE 
      LET vfcancelado = date(0);
	END IF;

   	--##############################################################
	--##	GENERACION ACLARACIONES	 EDO CUENTA				      ##
   	--##############################################################
        LET v_maximo       = 0;
--        SET ISOLATION TO dirty READ;
        FOREACH SELECT acl.fechacaptura, acl.folio_csuac, mov.fechahora,
                eve.descripcion ,
                acl.importereclamado
          INTO vfechacaptura, vfolio_csuac, vfechahora, vdescripcion, vimportereclamado
          FROM bdiaclaracion:acl_aclaracion  acl , 
                bdiaclaracion:acl_tipo_evento eve  , 
                bdiaclaracion:acl_producto pro ,
                bdiaclaracion:acl_movimiento mov                 
            where acl.fky_tipo_evento = eve.pky_tipo_evento
            AND pro.pky_producto = acl.fky_producto 
            and acl.pky_aclaracion = mov.fky_aclaracion  
            and  acl.fky_estatus_aclaracion = 2 
            AND acl.fechacaptura BETWEEN v_periodo_tc_ini AND v_periodo_tc_fin
            and pro.numero_cuenta  =pnum_credito

            LET v_maximo    = v_maximo + 1 ;
			      LET v_contador  = 0;
            LET v_concepto  = "";


        FOREACH EXECUTE PROCEDURE corta_linea(vdescripcion,v_corta_linea_detalle)
				INTO v_concepto, v_corta_retorno
           LET v_contador = v_contador + 1;
           IF  v_contador <>1  THEN
             LET vfechacaptura =date(1);
             LET vfechahora =date(1);
             LET vimportereclamado =0; 
           END IF;
			
             INSERT INTO bdicred:sd_aclaraciones_edocta
			 		 	(
						 	fecha_emision,		num_credito,
						 	secuencia,			nlinea,
						 	fecha_aclara,   folio,
              fecha_movimiento,   descripcion,
              importe
							)
			VALUES
							(
							pfechahoy,			pnum_credito,
							v_maximo,			v_contador,
							vfechacaptura,      vfolio_csuac, 
              vfechahora,         v_concepto, 
              vimportereclamado
							);						
        END FOREACH;         
			LET v_concepto     = "";			
	END FOREACH;

   	--##############################################################
	--##	GENERACION MENSAJES	 EDO CUENTA				          ##
   	--##############################################################

	/* SELECT valor::DECIMAL(14,10) INTO v_factor
	 FROM bdicred:sd_param WHERE cod_param = '036';

	 IF v_factor IS NULL THEN
	 	LET v_factor = 0.1139417057;
	 END IF

   LET v_secuencia_mensaje  = 0 ;
   LET v_si_paga = v_usted_debe ;


	 IF v_usted_debe <= 0 THEN
	 	LET v_aplica_factor = 0;
	 ELSE
	 	LET v_aplica_factor = v_usted_debe * v_factor;
	 END IF*/
	 
	  --GJEV
			 LET v_secuencia_mensaje  = 0 ;
			 LET v_im = (((v_tasa_anual / 100) * 30.50)*(1 + v_iva_suc))/360;
			 LET v_si_paga = (vlsaldo_corte * v_im)/ (1 - pow( (1 + v_im),-(1 * 12))); 


			 IF v_si_paga <= 0 THEN
				LET v_aplica_factor = 0;
			 ELSE
				LET v_aplica_factor = v_si_paga;
			 END IF	
			 --GJEV
	 ------ PIQV		
	 LET dMonto_No_Exigible = NVL(v_monto_adeudo,0) - NVL(v_capital_ven_tc,0);	
	 IF NVL(v_monto_adeudo,0) = NVL(v_capital_ven_tc,0) AND NVL(v_monto_adeudo,0) > 0 THEN
		 LET iMesesLiq = 1;
	 ELIF NVL(v_monto_adeudo,0) <= 0 THEN
		 LET iMesesLiq = 0;
	 ELSE 
		 EXECUTE PROCEDURE "informix".calcula_meses_fin(pempresa,v_numprod,dMonto_No_Exigible,
									  v_limite_tc, NVL(v_tasa_anual,0)/100,v_iva_suc,pfechahoy)
		 INTO cCodRetMeses,iMesesLiq; 
		 
		 IF cCodRetMeses <> "00000" THEN
			LET iMesesLiq = 44;
		 END IF;
		 
         IF iMesesLiq > 99 THEN
            LET iMesesLiq = 99;
         END IF;		 
		 
	 END IF;
	 ------ PIQV	
	 ----MOD CAS

			
	INSERT INTO sd_mensajes_edocta
	(
	fecha_emision, 		num_credito,
	secuencia,			nlinea,
	si_paga, 			mensajes,
	meses_liq
	)
    SELECT  pfechahoy, TRIM(pnum_credito),
    clave,secuencia,CASE WHEN clave=2 AND secuencia=1
    THEN v_aplica_factor ELSE NULL END ,REPLACE(mensaje,v_linea_auxiliar,TRIM(v_aplica_factor::VARCHAR(21))),
	CASE WHEN clave=2 AND secuencia=1 THEN iMesesLiq ELSE NULL END
    FROM mensajes;
    
   	--##############################################################
	--##	GENERACION   PIE	 EDO CUENTA				          ##
   	--##############################################################
   	LET v_tasa_mensual   = v_tasa_anual / 12;
	LET v_tasa_mensual_mora = v_tasa_mora / 12;

    IF ( v_interes_tc > 0 ) THEN
       LET v_saldo_promedio = round((v_interes_tc*360)/(v_dias_periodo_tc * (v_tasa_anual / 100)),2);
    ELSE
	   LET v_saldo_promedio = 0;
    END IF;
	
	
	--JMAH INI CAT 

			-- Obtiene el movimiento de comision por apertura (Se toma en cuenta para calculo solo el mes del cargo)    --  RQM 10 993 INI
			-- Julio 2019: A peticion de productos: La comision de apertura se considerara en todo momento para el calculo del CAT
			--LET mMntoComApert = nvl(mMntoComApert,0);
			

            -- Comision por anualidad. (Se toma en cuenta para todos los meses). Obtiene montos de anualidad: titular y adicional.
			-- campo: cobro_comision_anual es para cobro de anualidad del producto. El nvo campo: cat_edc_com_anualidad es para tomar la anualidad en el calculo del CAT para x producto.
            --Select cobro_comision_anual, substr(cod_comision_anualidad,1,4), substr(cod_comision_anualidad,5,4), cat_comi_anual_adicional
			Select cat_edc_com_anualidad, substr(cod_comision_anualidad,1,4), substr(cod_comision_anualidad,5,4), cat_comi_anual_adicional, cod_comision_apertura
              Into cCobrComisAnual      , dClvComAnualTit                   , dClvComAnualAdi                   , cCat_adicional          , dClvComApertura     
              From bdicred:sd_definicion Where num_producto = v_numprod;    -- Obtiene clave de comision anualidad.

            Select monto Into dMtoComAnualTit From bdicred:sd_tpcomis Where cod_comis = dClvComAnualTit;    -- Obtiene monto anualidad titular
            Select monto Into dMtoComAnualAdi From bdicred:sd_tpcomis Where cod_comis = dClvComAnualAdi;    -- Obtiene monto anualidad adicional
			Select monto Into mMntoComApert From bdicred:sd_tpcomis Where cod_comis = dClvComApertura;      -- Obtiene monto comision apertura
			
            LET dMtoComAnualTit = nvl(dMtoComAnualTit,0);
            LET dMtoComAnualAdi = nvl(dMtoComAnualAdi,0);
			LET mMntoComApert = nvl(mMntoComApert,0);

            IF cCobrComisAnual = '1' THEN
                /*Select NVL(SUM(monto), 0) INTO mMntoComAnual From bdicred:sd_movhis Where fecha_mov >= v_periodo_tc_ini and fecha_mov <= v_periodo_tc_fin 
                   and codigo_fun = '339' and codigo_ref in (100, 101) and num_credito = pnum_credito and transacc_suc in ('8244','8245') and reversado = 'N';*/
                IF cCat_adicional = '0' THEN Let dMtoComAnualAdi = 0; END IF; -- Si adicional no se agrega al CAT, se asigna valor cero.
                LET mMntoComAnual = dMtoComAnualTit + dMtoComAnualAdi;
            ELSE
			
			
                LET mMntoComAnual = 0;
            END IF;
			/*IF v_numprod =  '6001' THEN
				LET dComisiones = 50;
			ELSE
				LET dComisiones = 0;
			END IF;*/
            --LET dComisiones = mMntoComApert + mMntoComAnual;
			LET dComisiones = mMntoComApert;    -- Si no corresponde comision, variable = 0
			
            --  RQM 10 993 FIN

			select CASE WHEN  num_producto = '6001' THEN 0 ELSE nvl((c.captrans19 + c.capvenexig19),0) END +
			CASE WHEN  num_producto = '6001' THEN 0 ELSE nvl((c.captrans20 + c.capvenexig20),0) END +
			nvl((c.captrans21 + c.capvenexig21),0) +
			nvl((c.captrans22 + c.capvenexig22),0) +
			nvl((c.captrans23 + c.capvenexig23),0) +
			nvl((c.captrans24 + c.capvenexig24),0) +
			nvl((c.captrans25 + c.capvenexig25),0) +
			nvl((c.captrans26 + c.capvenexig26),0) +
			nvl((c.captrans27 + c.capvenexig27),0) +
			nvl((c.captrans28 + c.capvenexig28),0) +
			nvl((c.captrans29 + c.capvenexig29),0) +
			nvl((c.captrans30 + c.capvenexig30),0) +
			nvl((c.captrans31 + c.capvenexig31),0) +
			(b.captrans1 + b.capvenexig1) +
			(b.captrans2 + b.capvenexig2) +
			(b.captrans3 + b.capvenexig3) +
			(b.captrans4 + b.capvenexig4) +
			(b.captrans5 + b.capvenexig5) +
			(b.captrans6 + b.capvenexig6) +
			(b.captrans7 + b.capvenexig7) +
			(b.captrans8 + b.capvenexig8) +
			(b.captrans9 + b.capvenexig9) +
			(b.captrans10 + b.capvenexig10) + 
			(b.captrans11 + b.capvenexig11) +
			(b.captrans12 + b.capvenexig12) +
			(b.captrans13 + b.capvenexig13) +
			(b.captrans14 + b.capvenexig14) +
			(b.captrans15 + b.capvenexig15) +
			(b.captrans16 + b.capvenexig16) +
			(b.captrans17 + b.capvenexig17) +
			(b.captrans18 + b.capvenexig18) +
			CASE WHEN  num_producto  <> '6001' THEN 0 ELSE nvl((b.captrans19 + b.capvenexig19),0) END +
			CASE WHEN  num_producto  <> '6001' THEN 0 ELSE nvl((b.captrans20 + b.capvenexig20),0) END ,
			round((b.captrans1 + b.capvenexig1) * tasa_moratorios / 36000,2) +
			round((b.captrans2 + b.capvenexig2) * tasa_moratorios / 36000,2) +
			round((b.captrans3 + b.capvenexig3) * tasa_moratorios / 36000,2) +
			round((b.captrans4 + b.capvenexig4) * tasa_moratorios / 36000,2) +
			round((b.captrans5 + b.capvenexig5) * tasa_moratorios / 36000,2) +
			round((b.captrans6 + b.capvenexig6) * tasa_moratorios / 36000,2) +
			round((b.captrans7 + b.capvenexig7) * tasa_moratorios / 36000,2) +
			round((b.captrans8 + b.capvenexig8) * tasa_moratorios / 36000,2) +
			round((b.captrans9 + b.capvenexig9) * tasa_moratorios / 36000,2) +
			round((b.captrans10 + b.capvenexig10) * tasa_moratorios / 36000,2) +
			round((b.captrans11 + b.capvenexig11) * tasa_moratorios / 36000,2) +
			round((b.captrans12 + b.capvenexig12) * tasa_moratorios / 36000,2) +
			round((b.captrans13 + b.capvenexig13) * tasa_moratorios / 36000,2) +
			round((b.captrans14 + b.capvenexig14) * tasa_moratorios / 36000,2) +
			round((b.captrans15 + b.capvenexig15) * tasa_moratorios / 36000,2) +
			round((b.captrans16 + b.capvenexig16) * tasa_moratorios / 36000,2) +
			round((b.captrans17 + b.capvenexig17) * tasa_moratorios / 36000,2) +
			round((b.captrans18 + b.capvenexig18) * tasa_moratorios / 36000,2) +
			CASE WHEN  num_producto  <> '6001' THEN 0 ELSE round((b.captrans19 + b.capvenexig19) * tasa_moratorios / 36000,2)  END +
			CASE WHEN  num_producto  <> '6001' THEN 0 ELSE round((b.captrans20 + b.capvenexig20) * tasa_moratorios / 36000,2)  END +
			CASE WHEN  num_producto  ='6001' THEN 0 ELSE round((c.captrans19 + c.capvenexig19) * tasa_moratorios / 36000,2)  END +
			CASE WHEN  num_producto  = '6001' THEN 0 ELSE round((c.captrans20 + c.capvenexig20) * tasa_moratorios / 36000,2)  END +
			nvl(round((c.captrans21 + c.capvenexig21) * tasa_moratorios / 36000,2),0) +
			nvl(round((c.captrans22 + c.capvenexig22) * tasa_moratorios / 36000,2),0) +
			nvl(round((c.captrans23 + c.capvenexig23) * tasa_moratorios / 36000,2),0) +
			nvl(round((c.captrans24 + c.capvenexig24) * tasa_moratorios / 36000,2),0) +
			nvl(round((c.captrans25 + c.capvenexig25) * tasa_moratorios / 36000,2),0) +
			nvl(round((c.captrans26 + c.capvenexig26) * tasa_moratorios / 36000,2),0) +
			nvl(round((c.captrans27 + c.capvenexig27) * tasa_moratorios / 36000,2),0) +
			nvl(round((c.captrans28 + c.capvenexig28) * tasa_moratorios / 36000,2),0) +
			nvl(round((c.captrans29 + c.capvenexig29) * tasa_moratorios / 36000,2),0) +
			nvl(round((c.captrans30 + c.capvenexig30) * tasa_moratorios / 36000,2),0) +
			nvl(round((c.captrans31 + c.capvenexig31) * tasa_moratorios / 36000,2),0) 
			INTO dSdoPromVenAux ,dIntVenc
			 from bdicred:sd_maecred  a
			 join bdicred:sd_sdodiario b on (a.num_credito = b.num_credito and b.fecha = MDY(MONTH(pfechahoy),01,YEAR(pfechahoy)))
			 left outer join bdicred:sd_sdodiario c on (a.num_credito = c.num_credito and c.fecha = monthadd(b.fecha,-1))
			where a.empresa = pempresa
			AND a.num_credito  = pnum_credito;

			IF dSdoPromVenAux > 0 THEN
				LET dSdoPromVen = dSdoPromVenAux / v_dias_periodo_tc ;
			ELSE
				LET dSdoPromVen = dSdoPromVenAux;
			END IF;
			LET dSaldoPromCredSolAux=0;
			LET dIntCredSolAux=0;
			
			IF vlComprasDif > 0 OR v_saldo_diferido > 0 THEN
			
				FOREACH WITH HOLD
					select  nvl((c.capvig21 ),0) +
					nvl((c.capvig22 ),0) +
					nvl((c.capvig23 ),0) +
					nvl((c.capvig24 ),0) +
					nvl((c.capvig25 ),0) +
					nvl((c.capvig26 ),0) +
					nvl((c.capvig27 ),0) +
					nvl((c.capvig28 ),0) +
					nvl((c.capvig29 ),0) +
					nvl((c.capvig30 ),0) +
					nvl((c.capvig31 ),0) +
					(b.capvig1) +
					(b.capvig2 ) +
					(b.capvig3 ) +
					(b.capvig4 ) +
					(b.capvig5 ) +
					(b.capvig6 ) +
					(b.capvig7 ) +
					(b.capvig8 ) +
					(b.capvig9 ) +
					(b.capvig10 ) + 
					(b.capvig11 ) +
					(b.capvig12 ) +
					(b.capvig13 ) +
					(b.capvig14 ) +
					(b.capvig15 ) +
					(b.capvig16 ) +
					(b.capvig17 ) +
					(b.capvig18 ) +
					nvl((b.capvig19 ),0)  +
					nvl((b.capvig20 ),0)  ,
					round((b.capvig1 ) * tasa_interes / 36000,2) +
					round((b.capvig2 ) * tasa_interes / 36000,2) +
					round((b.capvig3 ) * tasa_interes / 36000,2) +
					round((b.capvig4 ) * tasa_interes / 36000,2) +
					round((b.capvig5 ) * tasa_interes / 36000,2) +
					round((b.capvig6 ) * tasa_interes / 36000,2) +
					round((b.capvig7 ) * tasa_interes / 36000,2) +
					round((b.capvig8  ) * tasa_interes / 36000,2) +
					round((b.capvig9 ) * tasa_interes / 36000,2) +
					round((b.capvig10 ) * tasa_interes / 36000,2) +
					round((b.capvig11 ) * tasa_interes / 36000,2) +
					round((b.capvig12 ) * tasa_interes / 36000,2) +
					round((b.capvig13 ) * tasa_interes / 36000,2) +
					round((b.capvig14 ) * tasa_interes / 36000,2) +
					round((b.capvig15 ) * tasa_interes / 36000,2) +
					round((b.capvig16 ) * tasa_interes / 36000,2) +
					round((b.capvig17 ) * tasa_interes / 36000,2) +
					round((b.capvig18 ) * tasa_interes / 36000,2) +
					round((b.capvig19 ) * tasa_interes / 36000,2)   +
					round((b.capvig20 ) * tasa_interes / 36000,2)   +
					nvl(round((c.capvig21 ) * tasa_interes / 36000,2),0) +
					nvl(round((c.capvig22 ) * tasa_interes / 36000,2),0) +
					nvl(round((c.capvig23 ) * tasa_interes / 36000,2),0) +
					nvl(round((c.capvig24 ) * tasa_interes / 36000,2),0) +
					nvl(round((c.capvig25 ) * tasa_interes / 36000,2),0) +
					nvl(round((c.capvig26 ) * tasa_interes / 36000,2),0) +
					nvl(round((c.capvig27 ) * tasa_interes / 36000,2),0) +
					nvl(round((c.capvig28 ) * tasa_interes / 36000,2),0) +
					nvl(round((c.capvig29 ) * tasa_interes / 36000,2),0) +
					nvl(round((c.capvig30 ) * tasa_interes / 36000,2),0) +
					nvl(round((c.capvig31 ) * tasa_interes / 36000,2),0) 
						INTO dSaldoPromCredSol ,dIntCredSol
					 from sd_detalle_dif_edocta   a
					 join bdicred:sd_sdodiariocrd b on (a.num_cred_credsol = b.num_credito and b.fecha = MDY(MONTH(pfechahoy),1,YEAR(pfechahoy)))
					 join bdicred:sd_maecredcrd d on (a.num_cred_credsol = d.num_credito) 
					 left outer join bdicred:sd_sdodiariocrd c on (a.num_cred_credsol = c.num_credito and c.fecha = monthadd(b.fecha,-1))
					where a.num_credito  = pnum_credito
				
					LET dSaldoPromCredSol = dSaldoPromCredSolAux +dSaldoPromCredSolAux;
					LET dIntCredSol = dIntCredSolAux +dIntCredSolAux;
				
				END FOREACH;
			ELSE
					LET dSaldoPromCredSol =0;
					LET dIntCredSol = 0;
			END IF;
			
			IF NVL(dSdoPromVen,0)+NVL(v_saldo_promedio,0)+NVL(dSaldoPromCredSol,0) > 0 THEN			
							
				LET dTasaInt = ((NVL(v_interes_tc,0) +NVL(dIntVenc,0) +NVL(dIntCredSol,0)) / (NVL(v_saldo_promedio,0)+NVL(dSdoPromVen,0)+NVL(dSaldoPromCredSol,0))) / v_dias_periodo_tc * 360;
				
				IF dTasaInt >= 0.995 THEN --RQI CAT 
					LET dTasaInt = 0.995;
				END IF;
				
				LET dPagoReq = v_limite_tc * dTasaInt / 360 * 30 ;
			ELSE
				LET dTasaInt = 0;
				LET dPagoReq = 0;
			END IF;
			
			IF v_interes_tc = 0 AND v_saldo_promedio = 0 AND v_status_cred IN('AA','E1') THEN--indica que liquido todo su adeudo
				LET dTasaInt = 0;
				LET dPagoReq = 0;
			END IF
			
			-- Modificaciones al calculo del CAT
			IF v_saldo_promedio > 0 THEN
				LET dtasa_prom_pond = ((v_interes_tc / v_saldo_promedio)/ v_dias_periodo_tc ) * 360;
				LET dtasa_prom_pond_fin = dtasa_prom_pond * 100;
			ELSE
				LET dtasa_prom_pond_fin = 0;
			END IF;			
			LET dPagoReq = 10; -- Pago requerido 10% (de acuerdo a indicaciones del area de producto. (???)
			
			--  No calcule el CAT cuando los intereses cargados son cero en el periodo.	Pero si calcule CAT si se cobra anualidad al producto.
			-- IF v_limite_tc <=0 THEN    
            -- IF v_capital_tc >= 0 AND v_intereses_pag = 0 AND v_capital_ven_tc = 0 AND cCobrComisAnual = '0' THEN

			--IF v_capital_tc >= 0 AND v_intereses_pag = 0 AND v_capital_ven_tc = 0 AND cCobrComisAnual = '0' AND mMntoComApert = 0 THEN
			IF v_capital_tc >= 0 AND v_interes_tc = 0 AND v_capital_ven_tc = 0 AND cCobrComisAnual = '0' AND mMntoComApert = 0 THEN		-- A peticion de Fco Espinoza Hdz Mayo 2019
                LET vCatFinal = 0;
            ELSE
				--EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(v_limite_tc,dPagoReq,36,36,dComisiones) into cCodRet,cMensajeRet,vCatFinal;
				EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(v_limite_tc, dPagoReq, 36, 36, dComisiones, dComs_GastCob, mMntoComAnual, dtasa_prom_pond_fin) 
				   INTO cCodRet, cMensajeRet, vCatFinal;
				   
			END IF;

			IF vCatFinal <= 0 THEN
				LET vCatFinal = 0 ;				
			END IF;

			IF vCatFinal > 160.1 THEN
				LET vCatFinal = 160.1 ;			
			END IF;
			
			LET v_catAux = vCatFinal;

			--JMAH FIN CAT 
	
	
	--------------------------------------------------------
    --	GENERA EL PIE DEL ESTADO DE CUENTA
    --------------------------------------------------------
		INSERT INTO sd_pie_edocta
			(
			fecha_emision,			num_credito,
			tasa_mensual,			tasa_anual,
			cat,					saldo_promedio,
			tasa_mora,				tasa_mensual_mora,
			dias_periodo
			)
	VALUES
			(
			pfechahoy,				pnum_credito,
			NVL(v_tasa_mensual,0),	NVL(v_tasa_anual,0),
			NVL(v_catAux,0),		NVL(v_saldo_promedio,0),
			NVL(v_tasa_mora,0),		NVL(v_tasa_mensual_mora,0),
			0
			);
   	--##############################################################
	--##	GENERACION  CLAVE DE COBRANZA				          ##
   	--##############################################################
        --	1.--TIPO DE CLIENTE: (2 Numero)
    --	2.--SITUACION ESPECIAL: (1 letra)
    --------------------------------------------------------
    SELECT FIRST 1 situacion,causa
    INTO v_situacion ,v_situacion_esp
    FROM bdisitesp:se_ctessitespcte
    WHERE numcte = v_numcte;

    IF v_situacion IS NULL OR v_situacion = "" THEN
    	LET v_situacion = "-";
    END IF
    ---Cambia 1 por L, RQM 09-124 MAJF AGO,2009
    IF  v_situacion = "G" THEN
      LET v_situacion_esp = replace(v_situacion_esp, 1,'L');
    END IF;

    --------------------------------------------------------
    --	2.1.--SITUACION ESPECIAL: (3 Numero o ---) Req 09087
    --------------------------------------------------------
    IF v_situacion_esp IS NULL OR v_situacion_esp = "" THEN
    	LET v_situacion_esp = "000";
    END IF
-- INICIO CAH *** INC SE ***
      LET v_situacion_esp= lpad( trim(v_situacion_esp), 3,'0');
-- FIN    CAH *** INC SE ***

    --------------------------------------------------------
    --3,4,5,8.--Estado Civil (1 letra),Tipo de Casa (1 letra),Sexo (1 letra),Anio Nacimiento (2 Numeros)
    --------------------------------------------------------
	SELECT 	TRIM(NVL(estado_civil,'')),
			--TRIM(NVL(SUBSTR(habita_en, 2,1),'1')), --usado hasta antes de paso2 de alta unica, catalogo con valores 01, 02, etc
            nvl(substr(TRIM(habita_en),1,1), 'P'),  --Cambio a catalgo, ahora usa letras, paso 02 alta unica, default propia
		  	TRIM(NVL(sexo,'')),
		  	NVL(SUBSTR(YEAR(fecha_nac), 3, 2),'')
	INTO 	v_estado_civil,
			v_tp_casa,
			v_sexo,
			v_nacimiento
    FROM   bdinteg:si_ctepf
	WHERE  numcte = v_numcte;

    --------------------------------------------------------
    --6.--SALARIO (2 NUMEROS):
    --------------------------------------------------------
	SELECT NVL(ingreso_mensual,0) / v_SalarioMinimoCoppel
		INTO   v_salario
	FROM   bdisolic:ss_resum_scor_fin
		WHERE  empresa = pempresa
		AND num_solicitud = pnum_credito ;

		IF v_salario < 0  OR v_salario IS NULL THEN
					LET v_salario = 0;



		ELSE
			IF v_salario >= 22 THEN
				LET v_cantidad = LPAD(22,2,'0');
			ELSE
				LET v_cantidad = LPAD(v_salario::INTEGER::VARCHAR(2),2,'0');
			END IF
		END IF	
    --------------------------------------------------------
    --7.-ANTIGUEDAD: (2 NUMEROS)
    --------------------------------------------------------
  	IF LENGTH(TRIM(v_antiguedad)) <> 2 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "212";
  		END IF
  	END IF
    --------------------------------------------------------
    --9.-TRAIGO EL MONTO TOTAL DE ADEUDO (5 NUMEROS)
    --------------------------------------------------------
	IF v_monto_adeudo >= 100000 THEN
  		--IF cod_ret = "000" THEN
  			--LET cod_ret = "213";
  		--END IF
		LET v_mto_tot_adeudo = "99999";
	ELSE
		IF v_monto_adeudo < 0 THEN
			LET v_mto_tot_adeudo = "00000";
		ELSE
			LET v_mto_tot_adeudo = LPAD(round(v_monto_adeudo),5,'0');
		END IF

	END IF
    --------------------------------------------------------
    --10.-TRAIGO EL ADEUDO VENCIDO (5 NUMEROS)
    --------------------------------------------------------
	IF v_mto_adeudo_venc >= 100000 THEN
  		--IF cod_ret = "000" THEN
  		--	LET cod_ret = "214";
  		--END IF
		LET v_adeudo_vencido = "99999";
	ELSE
            --LET v_mto_adeudo_venc = v_mto_adeudo_venc + v_monto_financiado; -- Solictado 19 Nov 2008 MEL
            LET v_mto_adeudo_venc = v_monto_financiado; -- Solictado 20 Nov 2008 MEL
		--LET v_adeudo_vencido =  LPAD(v_mto_adeudo_venc::INTEGER::VARCHAR(5),5,'0');
	END IF
    --------------------------------------------------------
    --11.-FECHA DE ULT. PAGO: (4 NUMEROS)
    --------------------------------------------------------
	IF v_fecha_ultimo_pago IS NULL THEN
		LET v_fec_ult_pago = "NDND";
	ELSE
		LET v_fec_ult_pago_month = MONTH(v_fecha_ultimo_pago);
		LET v_fec_ult_pago_year =  SUBSTR(YEAR(v_fecha_ultimo_pago),3,2);
		LET v_fec_ult_pago = LPAD(NVL(TRIM(v_fec_ult_pago_month),0),2,'0') ||
							 LPAD(NVL(TRIM(v_fec_ult_pago_year),0),2,'0');
	END IF

    --------------------------------------------------------
    --12.-MONTO DE ULT. CONVENIO: (5 NUMEROS)
    --------------------------------------------------------
    FOREACH SELECT FIRST 1 importe,TO_CHAR(fecha_compac,"%m%y"), 'P'
	    INTO v_monto_ult_convenio , v_fecha_ult_convenio, v_est_cumpl_convenio
	    FROM bdicobranza:cb_compac
	    WHERE empresa = pempresa
	    AND numcliente = v_numcte ORDER BY fecha_compac DESC
            EXIT FOREACH;
    END FOREACH;

    IF v_monto_ult_convenio IS NULL OR v_monto_ult_convenio = "" THEN

        FOREACH SELECT {+INDEX (bdicobranza:cb_compac_his idx_compachis1, idx_compachis2)}
                 FIRST 1 importe,TO_CHAR(fecha_compac,"%m%y"), flag_pago
	    INTO v_monto_ult_convenio , v_fecha_ult_convenio, v_est_cumpl_convenio
	    FROM bdicobranza:cb_compac_his
	    WHERE empresa = pempresa
	    AND numcliente = v_numcte ORDER BY fecha_compac DESC
    	EXIT FOREACH;
    END FOREACH;

    IF v_monto_ult_convenio IS NULL OR v_monto_ult_convenio = "" THEN
			LET v_monto_ult_convenio =  LPAD("0",5,'0');
		END IF;
    END IF;
		--------------------------------------------------------
    --13.-FECHA DE ULT. CONVENIO:	(4 NUMEROS)
    --------------------------------------------------------
    IF v_fecha_ult_convenio IS NULL OR v_fecha_ult_convenio = "" THEN
			LET v_fecha_ult_convenio =  "NDND";
		END IF;

    --------------------------------------------------------
    --14.-ESTADO DE CUMPLIMIENTO DE CONVENIO: (1 LETRA)
    --------------------------------------------------------

    IF v_est_cumpl_convenio IS NULL OR v_est_cumpl_convenio = "" THEN
			LET v_est_cumpl_convenio =  "-";
    ELIF v_est_cumpl_convenio = '1' then
        LET v_est_cumpl_convenio = 'S';
    ELIF v_est_cumpl_convenio = '0' then
        LET v_est_cumpl_convenio = 'N';

    END IF;
    --------------------------------------------------------
    --15.-NUMERO DE AVISOS: (1 LETRA)
    --------------------------------------------------------
	IF v_cuantos_avisos = 1 THEN
		LET v_avisos =  "1";
	ELIF v_cuantos_avisos = 2 THEN
		LET v_avisos =  "2";
	ELIF v_cuantos_avisos = 3 OR v_cuantos_avisos = 4 THEN
		LET v_avisos =  "3";
	ELIF v_cuantos_avisos = 5 THEN
		LET v_avisos =  "4";
	ELIF v_cuantos_avisos >= 6 THEN
		LET v_avisos =  "V";
	END IF;

	IF v_cuantos_avisos = 0 OR v_cuantos_avisos = 1 OR v_cuantos_avisos = 2 THEN
		LET v_nivel_eficiencia = "1";
    ELIF v_cuantos_avisos = 3 THEN
		LET v_nivel_eficiencia = "2";
	ELIF v_cuantos_avisos = 4 THEN
		LET v_nivel_eficiencia = "3";
    ELIF v_cuantos_avisos = 5 OR v_cuantos_avisos = 6 THEN
		LET v_nivel_eficiencia = "4";
	ELIF v_cuantos_avisos > 6 THEN
		LET v_nivel_eficiencia = "5";
	END IF;

----- Modifico para Clave de Cobranza ----- RQM 09 117

LET posicion11= round(v_pago_minimo_tc - v_capital_tc);
LET posicion11= lpad( trim(posicion11), 5,'0');

--- Inicio (Inc. 20 Marzo 2009)
LET v_monto_ult_convenio= round(v_monto_ult_convenio);
LET v_monto_ult_convenio= lpad( trim(v_monto_ult_convenio), 5,'0');
--- Fin

IF LENGTH(TRIM(v_pago_minimo_tc::INTEGER::CHAR(10))) > 5 THEN
	LET posicion17 = 99999;
ELSE
	LET posicion17 = round(v_pago_minimo_tc);
END IF;

LET posicion17= lpad(trim(posicion17), 5,'0');

    --------------------------------------------------------
    --	ARMO LA CLAVE DE COBRANZA:
    --------------------------------------------------------
	-------------------------------------------------------------
	--SD_MAECREDANEXO
	-------------------------------------------------------------
		--DIA LIMITE DE PAGO
		SELECT prox_fecha_pago INTO v_fecha_limite_pago_tc 
		FROM bdicred:sd_maecredanexo
		WHERE empresa = pempresa AND num_credito = pnum_credito;
		
	LET v_clave1 = v_nivel_eficiencia 	||"/"|| v_situacion 	||"/"|| v_situacion_esp 	||"/"|| v_estado_civil;
	LET v_clave2 = v_tp_casa		||"/"|| v_sexo		||"/"|| v_cantidad;
	LET v_clave3 = (DAY(v_fecha_limite_pago_tc))  ||"/"|| v_nacimiento ||"/"|| v_mto_tot_adeudo;
      --LET v_clave4 = v_adeudo_vencido	||"/"|| v_fec_ult_pago||"/"||v_monto_ult_convenio;
	LET v_clave4 =  posicion11 ||"/"|| v_fec_ult_pago||"/"||v_monto_ult_convenio;

	LET v_clave5 = v_fecha_ult_convenio||"/"|| v_est_cumpl_convenio||"/"||v_avisos ||"/"||posicion17;
                                                                                    -- ||"/"||v_pago_minimo_tc

    -- Define clave para tipo de cliente
    IF iMoras = 1 AND ( dFech_1erComp > dFHoy_1m AND dFech_alta >= dFHoy_13m ) THEN LET v_clave6 = '1V';
    ELIF ( dFech_1erComp > dFHoy_1m ) THEN LET v_clave6 = 'CN';
    ELIF ( dFhUltCompAct != dFhUltCompAnt AND dFhUltCompAnt <= dFHoy_12m AND v_deuda_Ant = 0 ) THEN LET v_clave6 = 'NC';
    ELSE LET v_clave6 = '-'; END IF;

	LET v_cl_cobranza = v_clave1 || "/" || v_clave2 || "/" || v_clave3 || "/" || v_clave4 || "/" || v_clave5 || "/" || v_clave6;

    --------------------------------------------------------
    --EJECUTO EL PROCEDURE PARA LA CLAVE DE COBRANZA
    --------------------------------------------------------
	UPDATE sd_encabezado_edocta SET cl_cobra = v_cl_cobranza
	WHERE fecha_emision = pfechahoy
	AND	num_credito = pnum_credito;

  RETURN cod_ret;
END;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".executaedoctageneral_repro(pempresa CHAR(3),pfechahoy DATE) 
RETURNING CHAR(5);

--------------------------------------------------------
--	VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
DEFINE sql_err          INTEGER;
DEFINE v_cod_ret	    CHAR(5);
DEFINE v_corta_retorno  INTEGER;
--------------------------------------------------------
--	VARIABLES GENERALES
--------------------------------------------------------
DEFINE v_empresa        CHAR(3);
DEFINE v_num_credito    CHAR(20);
DEFINE v_num_producto   CHAR(4);

DEFINE v_id_registro    CHAR(3);
DEFINE v_descripcion 	CHAR(50);

DEFINE v_periodo_anterior   	DATE;			--Fecha Periodo Anterior
DEFINE v_dias_periodo_tc 		INTEGER;		--dias_periodo_tc
DEFINE v_texto		            CHAR(1000);
DEFINE v_clave           		INTEGER;
DEFINE v_secuencia        		INTEGER;
DEFINE v_mensajes				VARCHAR(255);

DEFINE GLOBAL v_cat			    DECIMAL(18,2) DEFAULT 0;
DEFINE GLOBAL v_cat2			DECIMAL(18,2) DEFAULT 0;
DEFINE GLOBAL v_cat3			DECIMAL(18,2) DEFAULT 0;
DEFINE GLOBAL v_linea_auxiliar	DECIMAL(14,2) DEFAULT 0;
DEFINE GLOBAL v_corta_linea_mensaje 	INTEGER  DEFAULT 0;

DEFINE dFechaIni				DATE;
DEFINE dFechaFin				DATE;
DEFINE cNumCredito				CHAR(20);

--------------------------------------------------------
--	INICIALIZACION VARIABLES
--------------------------------------------------------
LET sql_err          = "";
LET v_cod_ret	    = "000";

LET v_empresa        = "";
LET v_num_credito    = "";
LET v_num_producto   = "";

LET v_id_registro    = "";
LET v_descripcion 	= "";

LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc 		= 0;	--dias_periodo_tc
LET v_cat                   = 0; --- CAT
LET v_cat2                   = 0; --- CAT
LET v_cat3                   = 0; --- CAT Oro
LET v_texto                 = "";
LET v_linea_auxiliar        =999999.00;
LET v_mensajes				= "";
LET v_corta_retorno 		= 0;
LET v_corta_linea_mensaje 	= 135;
LET cNumCredito				= "";

---- -SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION COMMITTED READ;

BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;

            RETURN v_cod_ret;
        END IF
   END EXCEPTION;


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--------------------------------------------------------------
	-----EJECUTA PROCESO LLENADO DE TABLA SD_MUESTRA_EDOCTA-------
	--------------------------------------------------------------
--temporal rss
/*	EXECUTE PROCEDURE "informix".executaedoctageneral_muestra('001','01-01-1990')
	INTO v_cod_ret,v_mensajes;
	
	EXECUTE PROCEDURE "informix".sp_edocta_credsol_detalle('001','01-01-1990')
	INTO v_cod_ret;*/
--temporal rss

   -----------------------------------------------------   
   -----------------NUMERO DE PRODUCTO------------------
   -----------------------------------------------------

    SELECT {+ INDEX (bdicred:sd_definicion)} num_producto 
	INTO v_num_producto FROM bdicred:"informix".sd_definicion
    WHERE empresa = pempresa AND nombre_prod = TRIM('TARJETA CREDITO BANCOPPEL VISA');

	-------------------------------------------------------
	--SE INICIALIZA TABLA PARA EDOCTAS
	------------------------------------------------------
	---Truncate sd_movhisedocta;
    --------------------------------------------------------
	--SE OBTIENE FECHA HOY MENOS UN MES
	--------------------------------------------------------
--temporal rss
/*	EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(pfechahoy,-1,DAY(pfechahoy))
	INTO v_cod_ret,v_periodo_anterior,v_dias_periodo_tc;*/
/* (expression)     (expression)     (expression)    
 ---------------  ---------------  --------------- 
 000              20/09/2022       -30*/             

let v_cod_ret='000';
let v_periodo_anterior=mdy('09','20','2022');
let v_dias_periodo_tc=-30;
--temporal rss

 

	LET v_periodo_anterior = v_periodo_anterior + 1 UNITS DAY;


	--------------------------------------------------------
	--	PREPARA LA TABLA  PARA EDOCTAS
	-------------------------------------------------------

	--INSERT INTO sd_movhisedocta
	--	SELECT a.empresa,			a.secuencia,			   a.fecha_mov,
	--		   a.hora_mov,			a.sucursal,                a.num_credito,
	--		   a.plaza,				a.transacc_suc,			   a.usuario,
	--		   a.monto,             a.codigo_fun,			   a.codigo_ref,
	--		   a.divisa,			a.reversado,			   a.folio_suc,
	--		   a.num_producto,      a.nro_tarjeta,			   a.referencia,
	--		   a.tipo_cambio,		a.monto_dls,			   a.suc_origen,
	--	       a.rfc_comer,			a.referencia23
    --    FROM sd_movhis a, sd_transfun b , bdinteg:si_transacc  c
	--	WHERE a.codigo_fun = b.codigo_fun AND a.codigo_ref  = b.codigo_ref
	--	AND c.numero = b.transacc AND c.se_emite_edocta = "S"
	--	AND fecha_mov >= v_periodo_anterior AND fecha_mov <= pfechahoy
	--	AND reversado <> "S";

   ---EXECUTE PROCEDURE carga_movhis_edocta (pfechahoy) INTO v_cod_ret;

   ---IF v_cod_ret<> "000" THEN
         ---RETURN v_cod_ret;
   ---END IF;

	-- Se agrega validacion para indicar que se haya hecho la muestra para la fecha de corte actual antes de generar los estados de cuenta. RQM 06 143
	/*SELECT LIMIT 1 num_credito
	INTO cNumCredito
	FROM bdicred:"informix".sd_muestra_edocta
	WHERE fecha_corte=pfechahoy;*/

	--IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
	--------------------------------------------------------
	    --  SE GENERAN LOS INSERTOS FIJOS PARA CUENTAS CON 1 Y 5 PAGOS VENCIDOS
		-------------------------------------------------------
		/*
		EXECUTE PROCEDURE bdicred:"informix".sp_activa_insertos_fijos
						(
						pempresa,
						pfechahoy
						) INTO v_cod_ret;

	   IF v_cod_ret<> "00000" THEN
	         RETURN v_cod_ret;
	   END IF;
		*/-- FMJ InActiva insertos de Moras para ECTDC
		-------------------------------------------------------
	        --SE CORRE ACTUALIZACION DE ESTADISTICAS
	        ------------------------------------------------------
		--	UPDATE STATISTICS HIGH FOR TABLE sd_movhisedocta;
		--	UPDATE STATISTICS MEDIUM FOR TABLE sd_movhisedocta;
		-------------------------------------------------------
		--SE ARREGLAN TRANSACCIONES
		------------------------------------------------------
		CALL bdicred:"informix".ARR_MOVHIS(pfechahoy);
		----------------------------------------------------------
		--SE ACTULIZAN LOS REGISTROS QUE RESULTEN DE LA CONSULTA
		----------------------------------------------------------
		--SET DEBUG FILE TO "/informix/edocta.out";
		--TRACE ON;
	--------------------------------------------------------
		--	GENERACION ENCABEZADO EDO CUENTA
		--------------------------------------------------------
	  	LET v_id_registro = "000";
		--SET DEBUG FILE TO "/respaldosbd/Malena/procesos.out";
		--TRACE ON;
	  	IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_encabezado_edocta
	  				  WHERE fecha_emision = pfechahoy
	  				  AND num_credito = v_id_registro) THEN

	 		INSERT INTO bdicred:"informix".sd_encabezado_edocta
				(
	     		fecha_emision,		num_credito, 			numcte,
	     		num_tarjeta, 		nombre_cte,				direccion_cn,
				direccion_col,		direccion_del,			edo_cd,
			 	sucursal_nombre,	sucursal_gerente, 	 	sucursal_tel,
			 	fecha_corte,		rfc,			 	 	cl_cobra,
			 	CP,					ruta,					confirmacion,
				num_region, 		num_ciudad_banco, 		num_ciudad_coppel,
				ec_edocta
				)
	  		VALUES
	  			(
				 pfechahoy,			v_id_registro,			"0",
	  		 	 "0",				"0",					"0",
	  			 "0",				"0",					"0",
	  			 "0",				"0",			 		"0",
	  			 pfechahoy,			"0",			 		"0",
	  			 "0",				"0",					"",
				 "0",				"0",					"0",
				 "0"
				);
	  	END IF
	  	LET v_id_registro = "100";
	 	IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_encabezado_edocta
	  		      WHERE fecha_emision = pfechahoy
	  		      AND num_credito = v_id_registro) THEN

	     	 INSERT INTO bdicred:"informix".sd_encabezado_edocta
				(
	     		fecha_emision,		num_credito, 			numcte,
	     		num_tarjeta, 		nombre_cte,				direccion_cn,
			 	direccion_col,		direccion_del,			edo_cd,
		 	 	sucursal_nombre,	sucursal_gerente, 	 	sucursal_tel,
		 	 	fecha_corte,		rfc,	 	 			cl_cobra,
		 	 	CP,					ruta,					confirmacion,
				num_region, 		num_ciudad_banco, 		num_ciudad_coppel,
				ec_edocta
				)
	  		VALUES  (
				 pfechahoy,			v_id_registro,			"0",
	  		 	 "0",				"0",					"0",
	  			 "0",				"0",					"0",
	  			 "0",				"0",			 		"0",
	  			 pfechahoy,			"0",			 		"0",
	  			 "0",				"0",					"",
				 "0",				"0",					"0",
				 "0"
				);
	 	 END IF
		--------------------------------------------------------
		--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
		--------------------------------------------------------
		LET v_id_registro = "200";
	  	IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_encabezado2_edocta
	  		      WHERE fecha_emision = pfechahoy
	  		      AND num_credito = v_id_registro) THEN


			INSERT INTO bdicred:"informix".sd_encabezado2_edocta
				(
				fecha_emision,		num_credito,			capital_tc,
				interes_tc,			iva_interes_tc,			capital_ven_tc,
				interes_ven_tc,		iva_interes_ven_tc,		moratorios_tc,
				iva_moratorios_tc,	sdo_pagar,				interes_pago_total_tc,
				limite_tc,			sdo_disponible,			periodo_tc_ini,
				periodo_tc_fin,		pago_antes_de,			fecha_corte,
				dias_periodo_tc,	usted_debia,			menos_abonos,
				mas_compras,		sus_comisiones,			mas_disp_efectivo,
				mas_intereses,		mas_iva,				mas_rendimientos,
				sdo_debe,			menos_o_abonos,			mas_o_cargos,
				usted_debe,			mensajes,
				comisiones_iva,     intereses_iva,          intereses_pag,
				saldo_menos_pag,    compras_disp,			base_iva,	
				descuento,			subtotal,				total 		
				)
			VALUES (
				pfechahoy,			v_id_registro,			0,
				0,					0,						0,
				0,					0,						0,
				0,					0,						0,
				0,					0,						pfechahoy,
				pfechahoy,			pfechahoy,				pfechahoy,
				0,					0,						0,
				0,					0,						0,
				0,					0,						0,
				0,					0,						0,
				0,					"",
				0,					0,						0,
				0,					0,						0,	
				0,					0,						0	
				); 

		END IF
		--------------------------------------------------------
		--	VARIABLES GENERACION DETALLE EDO CUENTA
		--------------------------------------------------------
		LET v_id_registro = "300";
		IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_detalle_edocta
			      WHERE fecha_emision = pfechahoy
			      AND num_credito = v_id_registro) THEN

			INSERT INTO sd_detalle_edocta
				(
				fecha_emision, 		num_credito, 			secuencia,
				fecha_mov, 			concepto, 				cargos,
				abonos, 			nlinea
				)
			VALUES
	         	(
	         	pfechahoy,			v_id_registro,			"0",
	         	"0", 				"0", 					"0",
				"0", 				"0"
	         	);

		END IF
		--------------------------------------------------------
		--	VARIABLES GENERACION ACLARACIONES EDO CUENTA
		--------------------------------------------------------
		LET v_id_registro = "400";
		IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_aclaraciones_edocta
			      WHERE fecha_emision = pfechahoy
			      AND num_credito = v_id_registro) THEN


			INSERT INTO bdicred:"informix".sd_aclaraciones_edocta
				(
				fecha_emision, 			num_credito, 		secuencia,
				nlinea,					fecha_aclara, 		folio,
	            fecha_movimiento,       descripcion,    	importe
				)
			VALUES
	         	(
	         	pfechahoy,				v_id_registro,		"0",
	         	"0",					pfechahoy, 			"",
	            "",                            "",         	0
	         	);

		END IF
		--------------------------------------------------------
		--	VARIABLES GENERACION MENSAJES EDO CUENTA
		--------------------------------------------------------
		LET v_id_registro = "500";
		IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_mensajes_edocta
			      WHERE fecha_emision = pfechahoy
			      AND num_credito = v_id_registro) THEN

			INSERT INTO bdicred:"informix".sd_mensajes_edocta
				(
				fecha_emision, 			num_credito, 		secuencia,
				nlinea,					si_paga, 			mensajes,
				meses_liq
				)
			VALUES
	         	(
	         	pfechahoy,				v_id_registro,		"0",
	         	"0",					0, 					"",
				0
	         	);

		END IF
		--------------------------------------------------------
		--	VARIABLES GENERACION PIE EDO CUENTA
		--------------------------------------------------------
	  	LET v_id_registro = "600";
		IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_pie_edocta
		  	      WHERE fecha_emision = pfechahoy
		  	      AND num_credito = v_id_registro) THEN

			INSERT INTO bdicred:"informix".sd_pie_edocta
				(
				fecha_emision,			num_credito,		tasa_mensual,
				tasa_anual, 			cat, 				saldo_promedio,
				dias_periodo
				)
			VALUES  (
				pfechahoy, 				v_id_registro, 		"0",
				"0", 					"0", 				"0",
				"0"
				);
		  END IF
      --------------------------------------------------------
			--	GENERA ENCABEZADO DE PAGOS DIFERIDOS
			--------------------------------------------------------
			LET v_id_registro = "900";
			IF NOT EXISTS(SELECT * FROM sd_detalle_dif_edocta
					  WHERE fecha_emision = pfechahoy
					  AND num_credito = v_id_registro) THEN

				INSERT INTO sd_detalle_dif_edocta
					(
					fecha_emision, 			num_credito, 		num_promocion,
					num_cred_credsol,		folio_suc, 			plazo,
					diasmes,				fecha,				tasa,
					saldo_pendiente,		prox_fecha_pago,	concepto,
					monto_prox_pago,		numero_cuotas,		secuencia,
					nlinea
					)
				VALUES
					(
					pfechahoy,				v_id_registro,		"0",
					"0",					0, 					"0",
					0,						pfechahoy,			0,
					0,						pfechahoy,			'',
					0,						'0/0',				0,
					0
					);
			END IF
		--------------------------------------------------------
		--	GENERA VARIABLES GLOBALES
		-------------------------------------------------------
	    ----VALOR DEL CAT
		SELECT valor INTO v_cat
		FROM bdicred:"informix".sd_param
		WHERE empresa = pempresa
		AND cod_param = '035';

		IF v_cat IS NULL THEN
			LET v_cat = 0.0;
		END IF
		
			SELECT valor INTO v_cat2
			FROM sd_param
			WHERE empresa = pempresa
			AND cod_param = '091'; 

			IF v_cat2 IS NULL THEN
				LET v_cat2 = 0.0;
			END IF
			
				--AAME RQM 10 679 Se contempla nuevo parametro para el valor de CAT de TDC ORO
				SELECT valor INTO v_cat3
				FROM sd_param
				WHERE empresa = pempresa
				AND cod_param = '093'; 

				IF v_cat3 IS NULL THEN
					LET v_cat3 = 0.0;
				END IF				
	    -----MENSAJES DEL ESTADO DE CUENTA

	        CREATE TEMP TABLE bdicred:mensajes(
	                clave     serial,
	                secuencia integer,
	                mensaje   char(150));




	        LET v_clave=1;
	            FOREACH
	                    SELECT  REPLACE(mensajes,'{0}',TRIM(v_linea_auxiliar::VARCHAR(21))) INTO v_texto
	                     FROM bdicred:"informix".sd_config_mensaje_edocta WHERE clave < 99 AND num_producto = v_num_producto
	                     order by clave

	                     LET v_secuencia=1;

	                FOREACH
	                     EXECUTE PROCEDURE corta_linea(TRIM(v_texto),v_corta_linea_mensaje) INTO v_mensajes, v_corta_retorno
	                     INSERT INTO bdicred:mensajes VALUES (v_clave,v_secuencia,v_mensajes);
	                     LET v_secuencia=v_secuencia+1;
	                END FOREACH;

	                LET v_clave = v_clave + 1;

	            END FOREACH;


	            DELETE bdicred:"informix".sd_mensajes_mensual_edocta WHERE fecha_emision = pfechahoy;

	            INSERT INTO bdicred:"informix".sd_mensajes_mensual_edocta
	            SELECT pfechahoy, clave, secuencia,mensaje FROM bdicred:mensajes WHERE clave <> '2';

	            DELETE FROM bdicred:mensajes WHERE clave <> '2';

	 	--------------------------------------------------------
		--	INICIA CON LA GENARACION DE MUESTRAS
		-------------------------------------------------------

	 	FOREACH SELECT a.empresa,a.num_credito
	 			INTO v_empresa,v_num_credito
	 			FROM bdicred:"informix".sd_maesdoshist a, bdicred:"informix".sd_muestra_edocta b
	        	WHERE a.fecha = pfechahoy
				AND b.fecha_corte= pfechahoy
				--AND b.flag_generacion=1
	        	AND a.empresa = pempresa
	            AND a.num_credito = b.num_credito
	        	AND a.num_credito NOT IN
	        	(SELECT num_credito FROM bdicred:"informix".sd_encabezado_edocta
	        	WHERE fecha_emision = pfechahoy)


			EXECUTE PROCEDURE bdicred:"informix".generaestadosdecuenta_repro
						(
						v_empresa,
						v_num_credito,
						pfechahoy
						) INTO v_cod_ret;

	      	IF v_cod_ret <> "000" THEN

	      		SELECT descripcion  INTO v_descripcion
	      		FROM bdinteg:"informix".si_codret
	      		WHERE codigo_retorno = v_cod_ret
	      		AND sistema  ="06";

	      		INSERT INTO bdicred:"informix".sd_valedocta
	      			(
	      			empresa,		num_credito,		cod_ret,
	      			descripcion,	fecha_proc,			tipo
	      			)
	      		VALUES
	      			(
	      			v_empresa,		v_num_credito,		v_cod_ret,
	      			v_descripcion,	pfechahoy,			"E"
	      			);            
			END IF            
	 	END FOREACH;
        
        --execute procedure ugenera_layoutedocuenta_muestras( pempresa, pfechahoy ) into v_cod_ret;

		/*IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			DROP TABLE bdicred:mensajes;
			RETURN "002";  --'Aun no se revisan los estados de cuenta'	RQM 06 143
		ELSE*/
		 	--------------------------------------------------------
			--	GENERA UNO A UNO LOS ESTADOS DE CUENTA
			-------------------------------------------------------
			/* ---Se programa dentro de Ctrl M
			FOREACH SELECT empresa,num_credito
		 			INTO v_empresa,v_num_credito
		 			FROM bdicred:"informix".sd_maesdoshist
		        	WHERE fecha = pfechahoy
		        	AND empresa = pempresa
		        	AND num_credito NOT IN
		        	(SELECT num_credito FROM bdicred:"informix".sd_encabezado_edocta
		        	WHERE fecha_emision = pfechahoy)



				EXECUTE PROCEDURE bdicred:"informix".GeneraEstadosdeCuenta
							(
							v_empresa,
							v_num_credito,
							pfechahoy
							) INTO v_cod_ret;

		      	IF v_cod_ret <> "000" THEN

		      		SELECT descripcion  INTO v_descripcion
		      		FROM bdinteg:"informix".si_codret
		      		WHERE codigo_retorno = v_cod_ret
		      		AND sistema  ="06";

		      		INSERT INTO bdicred:"informix".sd_valedocta
		      			(
		      			empresa,		num_credito,		cod_ret,
		      			descripcion,	fecha_proc,			tipo
		      			)
		      		VALUES
		      			(
		      			v_empresa,		v_num_credito,		v_cod_ret,
		      			v_descripcion,	pfechahoy,			"E"
		      			);

				END IF
		 	END FOREACH;

		    DROP TABLE bdicred:mensajes;

			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_encabezado_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_encabezado2_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_detalle_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_aclaraciones_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_mensajes_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_mensajes_mensual_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_pie_edocta;
			*/
			DROP TABLE bdicred:mensajes;
			RETURN "000";

		--END IF;
--	ELSE
--		RETURN "001"; -- Se agrega codigo de retorno que indica que no se ha hecho aun la muestra para la fecha de corte actual RQM 06 143
--	END IF;

END;
END PROCEDURE
DOCUMENT
'CAMBIO: Se modifica procedimiento para agregar validacion para indicar que se haya hecho la muestra para la fecha de corte actual antes de generar los estados de cuenta.',
'MODIFICO : Maria Elena Angulo Aispuro',
'FECHA : 13/JULIO/2011',
'BD: BDICRED',
'VERSION:20110713.1645';

CREATE PROCEDURE "informix".sp_msi_consultmovs_bpi(pEmpresa CHAR(3), pNumCredito CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pRegistro INTEGER)
RETURNING CHAR(5),DATE,CHAR(40),CHAR(60),CHAR(1),MONEY(14,2),MONEY(14,2),CHAR(4),CHAR(1);
		 
--Variables auxiliares
DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cErrorInfo      CHAR(80);
DEFINE vcodret         CHAR(6); 
DEFINE cMensajeRet     CHAR(80);


--Definicion de variables
DEFINE vserial       INTEGER;
DEFINE vfecha        DATE;
DEFINE vRefTotal CHAR(100);
DEFINE cDescripcion     CHAR(60);
DEFINE vnaturaleza   CHAR(1);			
DEFINE vmonto        MONEY(14,2);
DEFINE vReferencia23  CHAR(23);
DEFINE vRfcComer     CHAR(15);
DEFINE vTrans     CHAR(4);
DEFINE vTarjeta   CHAR(20);
DEFINE vTipo         CHAR(1);
DEFINE cFolioSuc		CHAR(16);
DEFINE iNumPago			INTEGER;
DEFINE iPlazo       	INTEGER;
DEFINE vComercio    	VARCHAR(40);
DEFINE vReferencia    CHAR(40);
DEFINE vTerminacion CHAR(4);
DEFINE vSdoDeudorMSI    DECIMAL(14,2);
DEFINE vMotivoCancel    	CHAR(80);
DEFINE dtmFechaCancela DATETIME YEAR TO SECOND;


LET vcodret            	= "000";
LET cMensajeRet        	= "Se realizo la consulta correctamente";
LET vserial = 0;
LET vfecha = '01/01/1900';
LET vRefTotal = "";
LET cDescripcion = " ";
LET vnaturaleza = '';
LET vmonto = 0;
LET vReferencia23 = '';
LET vRfcComer = '';
LET vTrans = '';
LET vTarjeta ='';
LET vTipo ='';
LET cFolioSuc =	"";   
LET iNumPago	= 0;
LET iPlazo = 0;
LET vComercio = "";
LET vReferencia = '';
LET vTerminacion ='';
LET vSdoDeudorMSI = 0;
LET vMotivoCancel = "";
LET dtmFechaCancela = '';


 -- *****************************************************************************************************        
   -- Obejtivo:			Consulta de Movimietos MSI
   -- Creado por:		Roque Heras
   -- Solicitado por:	Gabriela Aguilar
   -- Fecha:			29/04/2022
   -- *****************************************************************************************************
BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
		  LET vcodret = iSqlErr;
		  LET cMensajeRet = cErrorInfo;
		  RETURN vcodret, vfecha, vReferencia, cDescripcion, vnaturaleza, vmonto,vSdoDeudorMSI, vTerminacion, vTipo;
	   END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/gaby/ArchivosOut/sp_msi_consultmovs_bpi.out';
	--TRACE ON;
	
	-- Productos permitidos: 
	-- 8900 - MESES SIN INTERESES
	FOREACH
		( 	
			SELECT SKIP pRegistro FIRST 10
				movd.secuencia, movd.fecha_mov, 
				CASE WHEN NVL(TRIM(movd.referencia),'') = '' THEN tfun.transacc ELSE TRIM(movd.referencia) END CASE,
				tfun.descripcion, tcc.naturaleza, movd.monto, movd.referencia23, movd.rfc_comer, tcc.numero, '' as num_tarjeta, 'S' as tipo_tarjeta, movd.folio_suc, 
				ac.num_pago as numpago, mae.plazo, imov.infreceptor, mccm.fecha_cancela, mccm.motivo_de_cancelacion
			INTO vserial,vfecha,vRefTotal,cDescripcion,vnaturaleza,vmonto, vReferencia23, vRfcComer, vTrans, vTarjeta, vTipo, cFolioSuc, 
			iNumPago, iPlazo, vComercio, dtmFechaCancela, vMotivoCancel
			FROM bdicred:sd_promocion_credito pm
			INNER JOIN bdicred:sd_maecredcrd mae ON (pm.num_sol_prestamo = mae.num_credito)
			INNER JOIN bdicred:sd_movdiacrd movd ON (movd.num_credito = pm.num_sol_prestamo)
				--AND ((movd.codigo_fun = '002' AND movd.codigo_ref = 128) OR (movd.codigo_fun = '041' AND movd.codigo_ref = 1))) 
			INNER JOIN bdicred:sd_transfun tfun ON (tfun.codigo_fun = movd.codigo_fun AND tfun.codigo_ref = movd.codigo_ref)
			INNER JOIN bdinteg:si_transacc tcc ON (tcc.numero = tfun.transacc)
			LEFT OUTER JOIN bdicred:sd_msi_cancela_credito_msi mccm ON (mccm.num_credito = pm.num_sol_prestamo)
			LEFT JOIN bdicred:sd_amortiza_creditocrd ac ON (ac.num_credito = pm.num_sol_prestamo AND ac.fecha_cuota = movd.fecha_mov)
			LEFT JOIN intercard:movimiento imov ON (imov.secuenciaextendida = pm.folio_movto)
			WHERE pm.empresa = pEmpresa
			AND pm.num_credito = pNumCredito
			AND pm.num_pro_prestamo = 8900
			AND movd.fecha_mov BETWEEN pFechaInicial AND pFechaFinal
			AND tcc.se_emite_edocta = "S"
			AND movd.reversado = "N"

			UNION ALL
			SELECT 
				movd.secuencia, movd.fecha_mov, 
				CASE WHEN NVL(TRIM(movd.referencia),'') = '' THEN tfun.transacc ELSE TRIM(movd.referencia) END CASE,
				tfun.descripcion, tcc.naturaleza, movd.monto, movd.referencia23, movd.rfc_comer, tcc.numero, '' as num_tarjeta, 'S' as tipo_tarjeta, movd.folio_suc, 
				ac.num_pago as numpago, mae.plazo, imov.infreceptor, mccm.fecha_cancela, mccm.motivo_de_cancelacion
			FROM bdicred:sd_promocion_credito pm
			INNER JOIN bdicred:sd_maecredcrd mae ON (pm.num_sol_prestamo = mae.num_credito)
			INNER JOIN bdicred:sd_movhiscrd movd ON (movd.num_credito = pm.num_sol_prestamo)
			INNER JOIN bdicred:sd_transfun tfun ON (tfun.codigo_fun = movd.codigo_fun AND tfun.codigo_ref = movd.codigo_ref)
			INNER JOIN bdinteg:si_transacc tcc ON (tcc.numero = tfun.transacc)
			LEFT OUTER JOIN bdicred:sd_msi_cancela_credito_msi mccm ON (mccm.num_credito = pm.num_sol_prestamo)
			LEFT JOIN bdicred:sd_amortiza_creditocrd ac ON (ac.num_credito = pm.num_sol_prestamo AND ac.fecha_cuota = movd.fecha_mov)
			LEFT JOIN intercard:movimiento imov ON (imov.secuenciaextendida = pm.folio_movto)
			WHERE pm.empresa = pEmpresa
			AND pm.num_credito = pNumCredito
			AND pm.num_pro_prestamo = 8900
			AND movd.fecha_mov BETWEEN pFechaInicial AND pFechaFinal
			AND tcc.se_emite_edocta = "S"
			AND movd.reversado = "N"
		) ORDER BY tipo_tarjeta DESC, num_tarjeta ASC, fecha_mov DESC, secuencia DESC
		
		LET iNumPago = NVL(iNumPago, 0);
		LET vComercio = TRIM(NVL(vComercio, ''));
		LET vReferencia = vComercio; /*TRIM(vRefTotal);*/
		LET cDescripcion = TRIM(cDescripcion);
		
        IF vnaturaleza = "C" THEN
           LET vmonto = (vmonto*(-1));
        END IF;
		
		CASE vTrans
			WHEN "4265" THEN --Compras MSI
				LET cDescripcion = "COMPRA MESES SIN INTERESES " || iPlazo || " MESES";
			
			WHEN "4250" THEN --Cancelacion: A SOLICITUD DEL CLIENTE
				LET cDescripcion = "Cancela MSI";
				
			WHEN "4260" THEN --Cancelacion: CANCELACION AUTOMATICA
				LET cDescripcion = "Cancel-atraso MSI";
			
			WHEN "4266" THEN --Pagos MSI
				LET cDescripcion = "SU PAGO TDC - MESES SIN INTERESES " || iNumPago || " de " || iPlazo;
			
			ELSE
				--Resto de transacciones a MSI: (4264, 4267, 4253, 4261)
		END CASE;
		

		RETURN vcodret, vfecha, vReferencia, cDescripcion, vnaturaleza, vmonto,vSdoDeudorMSI, vTerminacion, vTipo WITH RESUME;
		 
	END FOREACH;

	IF DBINFO("sqlca.sqlerrd2") <=	0 THEN
	   LET vcodret = "002"; --No existen registros con el filtro de consulta indicado.
	   RETURN vcodret, vfecha, vReferencia, cDescripcion, vnaturaleza, vmonto,vSdoDeudorMSI, vTerminacion, vTipo;
	END IF;

END
END PROCEDURE;