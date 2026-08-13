CREATE PROCEDURE "informix".sp_adn_disposicion (pEmpresa CHAR (3))	
RETURNING CHAR(5),       -- Codigo de Retorno
		  CHAR(80);      -- Mensaje de Retorno

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cCod_ret      CHAR(6);
DEFINE cMensajeRet CHAR(80);

DEFINE cSql            	CHAR(2500);
DEFINE cNombreArchivo  	CHAR(150);
DEFINE cNombreArchivo1  CHAR(150);
DEFINE cConsulta		CHAR(2200);
DEFINE cEncabezado		CHAR(600);
DEFINE cRuta 			CHAR(80);
DEFINE iContador 		INTEGER;


DEFINE	dtFechaHoy	DATE;
DEFINE	dtFechaFinMes	DATE;
DEFINE	dTFechaSD	DATE;

DEFINE mMontoDisp	DECIMAL(18,2);
DEFINE mMontoDispAux	DECIMAL(18,2);
DEFINE cNumCte  	 CHAR(20);
DEFINE cNumCredito  	 CHAR(20);
DEFINE cFrecuenciaPago     CHAR(20);
DEFINE dLineaCred	DECIMAL(18,2);
DEFINE dMonto	DECIMAL(18,2);
DEFINE dtFechaMov    DATE;
DEFINE dtFechaMovCobro    DATE;
DEFINE cStatus     CHAR(2);
DEFINE cStatusDesc     CHAR(50);
DEFINE cStatusAp     CHAR(10);


LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cCod_ret         = "00000";
LET cMensajeRet     = "Proceso Exitoso";

LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';
LET cRuta	= "";
LET iContador	= 0;


LET dtFechaFinMes   =DATE(1) ;
LET dtFechaHoy   =DATE(1) ;
LET dTFechaSD    =  DATE(1);
LET mMontoDisp = 0;
LET mMontoDispAux = 0;
LET cNumCte			= '';
LET cNumCredito  = '';
LET cFrecuenciaPago  = '';
LET dLineaCred  = 0;
LET dMonto  = 0;
LET dtFechaMov    =  DATE(1);
LET dtFechaMovCobro    =  DATE(1);
LET cStatus			= '';
LET cStatusDesc  = '';
LET cStatusAp	= "APROBADO";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN cCodRet,cErrorInfo ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/jesus/RQM10617/sp_adn_disposicion.out';
	--TRACE ON;

	IF NVL(pEmpresa,'') = ''  THEN
		RETURN  '00001','PARAMETROS DE ENTRADA INVALIDOS' ;
	ELSE
	
	
	  --RUTA PARA GENERAR EL ARCHIVO
	SELECT valor
	INTO cRuta
	FROM bdicred:"informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='081';
	
	--SINO EXISTE LA RUTA DEL ARCHIVO	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		LET cMensajeRet ='NO EXISTE PARAMETRO DE LA RUTA PARA GENERAR EL ARCHIVO';
		RETURN cCodRet,cMensajeRet;
	END IF;	 
	
	SELECT a.fecha_hoy
	INTO dtFechaHoy	
	FROM "informix".sd_fechas a
	WHERE a.empresa = pEmpresa;

	--LET dtFechaHoy = mdy(05,05,2016);
	--LET dtFechaHoy = mdy(06,05,2016);
	--LET dtFechaHoy = mdy(07,05,2016);
			 
	--GENERA EL NOMBRE DEL ARCHIVO
	LET cNombreArchivo = TRIM('Disposición_ADN_xcliente_Mes_')||TO_CHAR(dtFechaHoy,'%m%y')|| '.txt';
	LET cNombreArchivo1 = TRIM('Disposición_ADN_xcliente_Mes_aux')||TO_CHAR(dtFechaHoy,'%m%y')|| '.txt';
	
	LET dtFechaFinMes = mdy(month(dtFechaHoy),01,YEAR(dtFechaHoy)) - 1 units day;
	LET dTFechaSD = bdicred:MONTHADD(mdy(month(dtFechaHoy),01,YEAR(dtFechaHoy)), - 1);
	
--comision por disposicion
	SELECT monto
	INTO mMontoDisp 
	FROM  bdicred:"informix".sd_tpcomis 
	WHERE empresa = '001'  
	AND cod_comis = '8172';
			
		
			
	FOREACH WITH HOLD 	
		SELECT a.numcte,a.num_solicitud, DECODE(frecuencia_pgo,'1','MENSUAL','2','QUINCENAL','3','SEMANAL','MENSUAL'),
		a.linea ,c.monto,c.fecha_mov, b.status_cred
		INTO cNumCte,cNumCredito, cFrecuenciaPago,dLineaCred,dMonto,dtFechaMov,cStatus
		FROM bdisolic:"informix".ss_adn_solicitudcuenta a,	
		"informix".sd_maecred b,"informix".sd_movhis c
		WHERE a.empresa =b.empresa 
		and a.num_solicitud =b.num_credito
		AND a.empresa = c.empresa
		and a.num_solicitud =c.num_credito
		AND b.num_producto  = '7800'
		AND b.fecha_apertura <= dtFechaFinMes
		and c.transacc_suc ='8174' 
		AND c.codigo_fun = '002'
		and c.codigo_ref =111
		AND c.fecha_mov BETWEEN dTFechaSD AND dtFechaFinMes
		
		
		
		LET mMontoDispAux  =  dMonto * (mMontoDisp/100) ;
		
		SELECT first  1 fecha_mov 
			INTO dtFechaMovCobro
		FROM bdicred:sd_movhis 
		WHERE empresa =pEmpresa
		and num_credito = cNumCredito
		and transacc_suc ='8175'
		AND codigo_fun ='074'
		AND codigo_ref = 1
		AND fecha_mov >= dtFechaMov;

		IF NVL(dtFechaMovCobro,DATE(1)) = DATE(1) THEN
		
			SELECT descripcion
			INTO cStatusDesc
			FROM "informix".sd_tipocartera  
			WHERE status_cred = cStatus;
		ELSE
			LET  cStatusDesc = 'PAGADO';
		END IF;	
		
		LET cConsulta = TRIM(NVL(cNumCte,''))||'|'|| TRIM(NVL(cFrecuenciaPago,''))||'|'||  NVL(dLineaCred,0)||'|'|| NVL(dMonto,0)||'|'|| TRIM(NVL(cStatusAp,''))||'|'|| TRIM(NVL(dtFechaMov,''))||'|'|| NVL(mMontoDispAux,0)||'|'|| TRIM(NVL(dtFechaMovCobro,''))||'|'||NVL(cStatusDesc,'');

		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;		
		
	LET iContador	=  1; 
    END FOREACH;

		IF iContador  > 0 THEN 	

		---se ejecuta para ponerle el encabezado 
			LET cEncabezado = 'echo "Número de Cliente BanCoppel'||'|'||'Periodo de pago'||'|'||'Línea de Crédito'||'|'||'Anticipo solicitado en el periodo'||'|'||'Estatus'||'|'||'Fecha de disposición'||'|'||'Comisión Disposición'||'|'||'Fecha de cargo a cuenta de nómina'||'|'||'Estatus'||'|'|| '" > '||TRIM(cruta)|| cNombreArchivo;  
			SYSTEM cEncabezado;

			LET cSql = cSql;
			LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNombreArchivo1) || " >> " || TRIM(cRuta) || TRIM(cNombreArchivo);
			SYSTEM cSql;


			LET cSQL = '' ;
			LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
			SYSTEM cSQL;   	

			RETURN cCodRet,cMensajeRet;

		ELSE
			LET cCodRet			= '00000';
			LET cMensajeRet			= 'No se encontro información';
			RETURN cCodRet,cMensajeRet;
		END IF;			
	END IF;		
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para validacion de los resultados del Anticipo de Nómina de forma general',
'AUTOR :  Jesus Manuel Aguilar',
'FECHA : 24/abril/2016',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_adn_sms (pEmpresa CHAR (3))	
RETURNING CHAR(5),       -- Codigo de Retorno
		  CHAR(80);      -- Mensaje de Retorno

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cCod_ret      CHAR(6);
DEFINE cMensajeRet CHAR(80);


DEFINE cSql            	CHAR(2500);
DEFINE cNombreArchivo  	CHAR(150);
DEFINE cNombreArchivo1  CHAR(150);
DEFINE cConsulta		CHAR(2200);
DEFINE cEncabezado		CHAR(600);
DEFINE cRuta 			CHAR(80);
DEFINE iContador 		INTEGER;

DEFINE	dtFechaHoy	DATE;
DEFINE	dtFechaFinMes	DATE;
DEFINE	dTFechaSD	DATE;
DEFINE	cGrupo	CHAR(20);
DEFINE	cPlant	CHAR(20);
DEFINE	cPlantSub	CHAR(1);
DEFINE	cDescripcion	CHAR(80);
DEFINE	dTotal	INTEGER;
DEFINE	dTotal1	INTEGER;
DEFINE	dTotal2	INTEGER;


LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cCod_ret         = "00000";
LET cMensajeRet     = "Proceso Exitoso";

LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';
LET cRuta	= "";
LET iContador	= 0;

LET	dtFechaHoy	= DATE(1);
LET	dtFechaFinMes	= DATE(1);
LET	dTFechaSD	 =DATE(1);
LET cGrupo    = "";
LET cPlant    =  "";
LET cPlantSub    =  "";
LET cDescripcion    =  "";
LET dTotal    = 0;
LET dTotal1    = 0;
LET dTotal2    = 0;



BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN cCodRet,iIsamErr ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/jesus/RQM10617/sp_adn_sms.out';
	--TRACE ON;

	IF NVL(pEmpresa,'') = ''  THEN
		RETURN  '00001','PARAMETROS DE ENTRADA INVALIDOS' ;
	ELSE
	
	
	
	  --RUTA PARA GENERAR EL ARCHIVO
	SELECT valor
	INTO cRuta
	FROM bdicred:"informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='081';
	
	--SINO EXISTE LA RUTA DEL ARCHIVO	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		LET cMensajeRet ='NO EXISTE PARAMETRO DE LA RUTA PARA GENERAR EL ARCHIVO';
		RETURN cCodRet,cMensajeRet;
	END IF;	 
	
	SELECT a.fecha_hoy
	INTO dtFechaHoy
	FROM "informix".sd_fechas a
	WHERE a.empresa = pEmpresa;
			 
	--LET dtFechaHoy = mdy(05,05,2016);
	--LET dtFechaHoy = mdy(06,05,2016);
	--LET dtFechaHoy = mdy(07,05,2016); 
	
	--GENERA EL NOMBRE DEL ARCHIVO
	LET cNombreArchivo = TRIM('Sol_SMS_ADN_Mes_')||TO_CHAR(dtFechaHoy,'%m%y')|| '.txt';
	LET cNombreArchivo1 = TRIM('Sol_SMS_ADN_Mes_aux_')||TO_CHAR(dtFechaHoy,'%m%y')|| '.txt';
	
	LET dtFechaFinMes = mdy(month(dtFechaHoy),01,YEAR(dtFechaHoy)) - 1 units day;
	LET dTFechaSD = bdicred:MONTHADD(mdy(month(dtFechaHoy),01,YEAR(dtFechaHoy)), - 1);
	
	
	FOREACH WITH HOLD 
		SELECT grupo ,plantillasub ,descripcion  
		INTO cGrupo,cPlantSub, cDescripcion
		FROM "informix".sd_adn_plantillas 
		where plantilla = ''
		
		
		FOREACH WITH HOLD
			SELECT grupo ,plantilla ,descripcion
			INTO cGrupo,cPlant, cDescripcion
			FROM "informix".sd_adn_plantillas 
			where plantillasub = cPlantSub
						
			IF TRIM(cPlant) = ""  AND  TRIM(cPlantSub) <> "2" THEN
				CONTINUE FOREACH;
			END IF
			
				SELECT COUNT(id_plantilla)
				INTO dTotal1 
				FROM bdimnsj:mnsjr_trx_online 
				WHERE tipo_mensaje =1 
				AND id_mensaje ='ADN_SMS' 				
				AND fecha_hora_registro BETWEEN dTFechaSD AND dtFechaFinMes
				AND id_plantilla = cPlant;

				SELECT COUNT(id_plantilla)
				INTO dTotal2 
				FROM bdimnsj:mnsjr_trx_online_his
				WHERE tipo_mensaje =1 
				AND id_mensaje ='ADN_SMS' 				
				AND fecha_hora_registro BETWEEN dTFechaSD AND dtFechaFinMes
				AND id_plantilla = cPlant;

				LET dTotal= dTotal1 +dTotal2;
				
				LET cConsulta = NVL(cGrupo,'')||'|'|| NVL(cDescripcion,'')||'|'||NVL(dTotal,0);

				---se ejecuta para ponerle el encabezado 
				LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
				SYSTEM cEncabezado;	
		
		END FOREACH;
	
		
	LET iContador	=  1; 
    END FOREACH;

		IF iContador  > 0 THEN 	

			---se ejecuta para ponerle el encabezado 
			LET cEncabezado = 'echo "SOLICITUDES SMS DE ANTICIPO DE NOMINA'||'|'||' '||'|'||'TOTAL'||'|'|| '" > '||TRIM(cruta)|| cNombreArchivo;  
			SYSTEM cEncabezado;

			LET cSql = cSql;
			LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNombreArchivo1) || " >> " || TRIM(cRuta) || TRIM(cNombreArchivo);
			SYSTEM cSql;


			LET cSQL = '' ;
			LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
			SYSTEM cSQL;   	

			RETURN cCodRet,cMensajeRet;

		ELSE
			LET cCodRet			= '00000';
			LET cMensajeRet			= 'No se encontro información';
			RETURN cCodRet,cMensajeRet;
		END IF;			
	END IF;		
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para validacion de los resultados del Anticipo de Nómina de forma general',
'AUTOR :  Jesus Manuel Aguilar',
'FECHA : 24/abril/2016',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_validarpermisousuariocac2(p_Ejecutivo CHAR(8))
RETURNING
        CHAR(5); ---cod_ret
        ---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	DEFINE cEmpleado CHAR (20);
        ---INICIALIZACIONES
        LET v_cod_ret = '00000';
		LET cEmpleado = '';
	BEGIN
		ON EXCEPTION
		SET iSqlErr, iSamErr
		IF iSqlErr <> 0 THEN
			LET v_cod_ret = iSqlErr;
		END IF;
				
		RETURN v_cod_ret;
		END EXCEPTION;
        
        ---SET DEBUG FILE TO "/tmp/has/sp_validarpermisousuariocac2.out";
        ---TRACE ON;
        IF p_Ejecutivo = "" OR p_Ejecutivo IS NULL THEN
                LET v_cod_ret = "00001";
                RETURN v_cod_ret;
        END IF
        
        IF NOT EXISTS(SELECT ejecutivo FROM bdinteg: si_perfil_ejecut WHERE ejecutivo = p_Ejecutivo AND sistema = "06")  THEN
                LET v_cod_ret = "00002";
                RETURN v_cod_ret;
        END IF
        
        IF NOT EXISTS(SELECT empleado FROM bdicred: sd_super_cancred WHERE empleado = p_Ejecutivo AND status = 1 AND aplicativo = "CCONCAC.EXE") THEN
			LET v_cod_ret = "00003";
            RETURN v_cod_ret;     			
        END IF
		
        RETURN v_cod_ret;
END;
END PROCEDURE
DOCUMENT
'Descripcion: Se crea procedimiento para validar los permisos de usuarios',
'Fecha:07/ Junio/ 2010',
'BD: bdicred',
'Autor: Mohamed Hassan',
'DESCRIPCION:Se agrega otro tipo de aplicativo para validar los permisos del usuario a la afuncionalidad de credito grupo coppel',
'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 03/05/2016';

CREATE PROCEDURE "informix".sp_cobrocomisionreposicioncredito ( pEmpresa CHAR(3))	
RETURNING CHAR(5);       -- Codigo de Retorno
		  

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cErrorsp   CHAR(1);
DEFINE cCodRet      CHAR(6);
DEFINE cCodRetAux   CHAR(6);
DEFINE cMen_ret CHAR(80);
DEFINE p_cod_ret CHAR(6);
DEFINE pcod_ret CHAR(5);
DEFINE cResultado		CHAR(1);
DEFINE cMensaje		CHAR(250);

DEFINE iSecuencia INTEGER;
DEFINE cNumcred CHAR(20);
DEFINE cMotivo CHAR(2);
DEFINE cNumtarjeta CHAR(20);
DEFINE cNumeroFolio CHAR(16);
DEFINE cEmpresa CHAR(3);
DEFINE cSucursal CHAR(4);
DEFINE cTransacc CHAR(4);
DEFINE cOperador CHAR(10);
DEFINE cMontoCom MONEY(16,2);
DEFINE cIvaCom MONEY(16,2);
DEFINE dtFechaSol DATE;
DEFINE dtfecha_ini DATE;
DEFINE dtfecha_fin DATE;


LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cErrorsp      = "";
LET cCodRet         = "00000";
LET cCodRetAux         = "000000";
LET p_cod_ret     = "00000";
LET pcod_ret     = "00000";
LET cMen_ret     = "Proceso Exitoso";

LET iSecuencia = 0;
LET cNumcred = "";
LET cMotivo = "";
LET cNumeroFolio = "";
LET cEmpresa = "";
LET cTransacc = "";
LET cSucursal = "9290";
LET cOperador = "informix";
LET dtFechaSol = DATE(1);
LET dtfecha_ini = mdy(06,01,2016);
LET dtfecha_fin = mdy(07,19,2016);
LET cMontoCom =0.00;
LET cIvaCom =0.00;
LET cResultado		= '';
LET cMensaje		= '';



BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN iSqlErr ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/Malena/sp_cobrocomisionreposicioncredito.out';
	--TRACE ON;
		
		--Pendientes de cobrar comision de tarjetas de credito por motivo robo,extravio y Maltrato (1,2,3)					  

			SELECT empresa,num_credito,num_tarjeta,motivo
			FROM bdicred:"informix".sd_cobro_comision
			WHERE resultado ='0'
			INTO temp paso_sol2 WITH NO LOG;
			
			update statistics high for table paso_sol2;
	
	FOREACH WITH HOLD
				--Se obtiene la información de los Creditos que Repusieron tarjeta
				SELECT empresa,num_credito,num_tarjeta,motivo
				INTO cEmpresa,cNumcred, cNumtarjeta, cMotivo
				FROM "informix".paso_sol2

				 --SE GENERA EL FOLIO
				 CALL bdicheq:"informix".sp_generafolionomina('informix') 
				 RETURNING cCodRetAux, cNumeroFolio;
				 
				 --6218	COM POR ROBO 15%       				 
				 --6219	COM POR EXTRAVIO 15%            				 
				 --6220	COM POR DAÑO o MALTRATO 15%             
				 
				 IF cMotivo='01' THEN
					LET cTransacc ='6218';
				 ELIF cMotivo ='02' THEN
					LET cTransacc ='6219';
				 ELIF cMotivo ='03' THEN
					LET cTransacc ='6220';
				 END IF;
				 
				EXECUTE PROCEDURE bdinteg:"informix".sp_ComisionReposicion (cEmpresa,cSucursal,'2',cNumcred,cTransacc)				 
				INTO p_cod_ret,cMontoCom,cIvaCom;
				
				IF p_cod_ret::INTEGER = 0 THEN
				 --Si es credito se ejecuta el siguiente procedimiento 
				 EXECUTE Procedure "informix".cargo_cred (cEmpresa,cNumcred,cSucursal,cOperador,cTransacc,cMontoCom ,cNumeroFolio,
				 cNumtarjeta,0,0,TODAY,'Comision por reposicion de tarjeta','Cargo por Cobro No aplicado','')	
				 INTO pcod_ret;

					IF pcod_ret::INTEGER = 0 THEN
						--Se actualiza el resultado del cargo de la comision
						UPDATE bdicred:"informix".sd_tarjeta 
						SET cobro_comision  ='S'
						WHERE num_tarjeta =cNumtarjeta;
						--Se actualiza el resultado del cargo de la comision
						UPDATE bdicred:"informix".sd_cobro_comision 
						SET resultado ='1',mensaje = 'Comision Aplicada con exito'
						WHERE num_tarjeta =cNumtarjeta;					
					ELSE 
						--Se actualiza el resultado del cargo de la comision
						UPDATE bdicred:"informix".sd_cobro_comision 
						SET resultado ='0',mensaje = pcod_ret || ' - Ocurrio un Error al intentar aplicar la comision'
						WHERE num_tarjeta =cNumtarjeta;
						LET cCodRet = '00001';
					END IF;				
				ELIF p_cod_ret::INTEGER = 1 THEN										
					-- "La Cuenta del Cliente tiene un Estatus de Crédito Vencido"
					UPDATE bdicred:"informix".sd_cobro_comision 
					SET resultado ='0',mensaje = p_cod_ret || ' - La Cuenta del Cliente tiene un Estatus de Crédito Vencido'
					WHERE num_tarjeta =cNumtarjeta;					
					LET cCodRet = '00002';				
				ELIF p_cod_ret::INTEGER = 2 THEN
					--"La Cuenta del Cliente Ésta Bloqueada Para la Disposición de Saldo"
					UPDATE bdicred:"informix".sd_cobro_comision 
					SET resultado ='0',mensaje = p_cod_ret || ' - La Cuenta del Cliente Ésta Bloqueada Para la Disposición de Saldo'
					WHERE num_tarjeta =cNumtarjeta;										
					LET cCodRet = '00003';				
				ELSE 
					--"Ocurrio un Error al intentar aplicar la comision"				
					UPDATE bdicred:"informix".sd_cobro_comision 
					SET resultado ='0',mensaje = p_cod_ret || ' - Ocurrio un Error al intentar aplicar la comision'
					WHERE num_tarjeta =cNumtarjeta;					
					LET cCodRet = '00004';	
				END IF;				 
    		
	END FOREACH;		
					
		RETURN cCodRet ;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para aplicar cobros de comisiones que no se aplicarón por Reposición de Tarjeta en el periodo de Junio y Julio ',
'AUTOR :  Maria Elena Angulo Aispuro',
'FECHA : 20/julio/2016',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_depura_cred_his()
RETURNING 
CHAR(6),     -- código de retorno
CHAR(150);    -- mensaje


DEFINE cCodRet      CHAR(6); 
DEFINE cMensaje     CHAR(150); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE Error_Info   VARCHAR(80);
DEFINE dFechaDepura DATE;
--Pruebas IPCB
DEFINE vFecha DATE;
DEFINE dFechaAProcesar DATE;
DEFINE vnum_credito CHAR(20);
DEFINE vfecha_corte DATE;
DEFINE cFechaDepura char(10);
DEFINE iDepura		integer;
DEFINE cHoraInicial		CHAR(8);
DEFINE cHoraFinal		CHAR(8);
DEFINE sHoraInicial		SMALLINT;
DEFINE sHoraFinal		SMALLINT;
DEFINE sMinutoInicial	SMALLINT;
DEFINE sMinutoFinal		SMALLINT;


DEFINE sHorasProceso	SMALLINT;
DEFINE cTerminaProceso	CHAR(1);
DEFINE iCuentasProcesadas			INTEGER;
DEFINE iCount_sd_maesdoshist_old	INTEGER;
DEFINE iCount_sd_maecredcont_old	INTEGER;
DEFINE iCount_sd_maesdoscont_old	INTEGER;
DEFINE iCount_sd_hist_reserva_old	INTEGER;
DEFINE iCount_sd_movhis_calif_old	INTEGER;
DEFINE cProceso		CHAR(04);
DEFINE P_COD_RET    VARCHAR(6);
DEFINE P_MENSAJE    VARCHAR(150);

LET cCodRet      = '000000';
LET cMensaje     = '';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET Error_Info   = '';
LET vNumCred     = '';
LET vNumCredAux  = '';
LET dFechaDepura = DATE(1);
--Pruebas IPCB
LET vFecha 			= date(1);
LET dFechaAProcesar = date(1);
LET vnum_credito	= '';
LET vfecha_corte	= DATE(1);
LET cFechaDepura	= '';
LET iDepura			= 0;
LET cHoraInicial	= '';
LET cHoraFinal		= '';
LET sHoraInicial	= 0;
LET sHoraFinal		= 0;
LET sMinutoInicial	= 0;
LET sMinutoFinal	= 0;

LET sHorasProceso	= 0;
LET cTerminaProceso = '0';
LET iCuentasProcesadas			= 0;
LET iCount_sd_maesdoshist_old	= 0;
LET iCount_sd_maecredcont_old	= 0;
LET iCount_sd_maesdoscont_old	= 0;
LET iCount_sd_hist_reserva_old	= 0;
LET iCount_sd_movhis_calif_old	= 0;
LET cProceso		= '0001';
LET P_COD_RET   	= '000000';
LET P_MENSAJE		= 'El proceso MUEVE A TABLAS HISTORICAS terminó exitosamente. Cuentas procesadas ';


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, Error_Info
        IF iSqlErr != 0 THEN
			LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iCuentasProcesadas;
			LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdoshist_old : ' ||iCount_sd_maesdoshist_old;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
			LET cMensaje = 'Cuentas respaldadas sd_maecredcont_old : ' ||iCount_sd_maecredcont_old;
			LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdoscont_old : ' ||iCount_sd_maesdoscont_old;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
			LET cMensaje = 'Cuentas respaldadas sd_hist_reserva_old : ' ||iCount_sd_hist_reserva_old;
			LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_movhis_calif_old : ' ||iCount_sd_movhis_calif_old;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

		LET cCodRet = iSqlErr;		
            LET cMensaje = 'Error --> '||Error_Info||'	'||vNumCred;

			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '02') RETURNING P_COD_RET;

            RETURN cCodRet,cMensaje;
        END IF;
    END EXCEPTION;

    CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '01') RETURNING P_COD_RET;

    IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;
	
--SET DEBUG FILE TO 'sp_depura_cred_his.out';
--TRACE ON;

    select fecha_hoy into vFecha
    from bdicred:sd_fechas;

--temporal solo para pruebas
--LET vFecha = today; --mdy ('11','10','2013');
--temporal solo para pruebas

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraInicial from sysmaster:sysshmvals;

	LET sHoraInicial = SUBSTR(cHoraInicial,1,2);
	LET sMinutoInicial = SUBSTR(cHoraInicial,4,2);
	
    SELECT num_credito
      INTO vNumCredAux
      FROM "informix".sd_param_movhis_dep
     WHERE proceso = 3;

    IF vNumCredAux IS NULL THEN 
       LET vNumCredAux = ""; 
       INSERT INTO "informix".sd_param_movhis_dep VALUES(3,'');
    END IF;

--Pruebas IPCB

    SELECT valor::date
      INTO dFechaDepura
      FROM bdicred:sd_param
     WHERE cod_param = '048';

    IF dFechaDepura IS NULL THEN 
        LET cCodRet = '100100';
        LET P_MENSAJE = 'No existe parámetro de fecha a depurar.';
        RETURN cCodRet,P_MENSAJE;
    END IF;

	SELECT valor::smallint
      INTO sHorasProceso
      FROM bdicred:sd_param
     WHERE cod_param = '053';

	 IF sHorasProceso IS NULL THEN 
        LET cCodRet = '100200';
        LET P_MENSAJE = 'No existe parámetro de horas a procesar.';
        RETURN cCodRet,P_MENSAJE;
    END IF;
	 
    if vNumCredAux = '' then
        execute PROCEDURE bdicred:monthadd(vFecha, -18) into dFechaDepura;

        let dFechaDepura = mdy(month(dFechaDepura),1,year(dFechaDepura)) - 1;

        UPDATE bdicred:sd_param
           SET valor = dFechaDepura
         WHERE cod_param = '048';

    end if;

    FOREACH WITH HOLD

       SELECT TRIM(num_credito)
           INTO vNumCred 
           FROM bdicred:"informix".sd_maecred
          WHERE empresa     = '001' 
            AND num_credito > vNumCredAux
       ORDER BY num_credito ASC

	   LET iCuentasProcesadas = iCuentasProcesadas + 1;
	   
        BEGIN WORK;
--maesdoshist
            insert into bdicred:sd_maesdoshist_old
            select * from bdicred:sd_maesdoshist
            where empresa = '001'
            and fecha    <= mdy(month(dFechaDepura),20,year(dFechaDepura))
            and num_credito = vNumCred;

            delete from bdicred:sd_maesdoshist
            where empresa = '001'
            and fecha    <= mdy(month(dFechaDepura),20,year(dFechaDepura))
            and num_credito = vNumCred;

			LET iCount_sd_maesdoshist_old	= iCount_sd_maesdoshist_old + 1;
			
--maecredcont
            insert into bdicred:sd_maecredcont_old
            select * from bdicred:sd_maecredcont
            where empresa = '001'
            and fecha    <= dFechaDepura
            and num_credito = vNumCred;

            delete from bdicred:sd_maecredcont
            where empresa = '001'
            and fecha    <= dFechaDepura
            and num_credito = vNumCred;
--            and num_credito <= vNumCred;
			
			LET iCount_sd_maecredcont_old	= iCount_sd_maecredcont_old + 1;
			
--maesdoscont
            insert into bdicred:sd_maesdoscont_old
            select * from bdicred:sd_maesdoscont
            where empresa = '001'
            and fecha    <= dFechaDepura
            and num_credito = vNumCred;

            delete from bdicred:sd_maesdoscont
            where empresa = '001'
            and fecha    <= dFechaDepura
            and num_credito = vNumCred;

			LET iCount_sd_maesdoscont_old	= iCount_sd_maesdoscont_old + 1;

--hist_reserva
--Pruebas IPCB

         insert into bdicred:sd_hist_reserva_old
            select *  
              from bdicred:sd_hist_reserva
             where empresa = '001'
               and fecha_corte <= dFechaDepura
               and fecha_corte not in (mdy('05','20','2011'),mdy('06','20','2011'),mdy('07','20','2011'),mdy('08','20','2011'),mdy('09','20','2011'),mdy('03','20','2012'),mdy('03','31','2012'),mdy('04','20','2012'),mdy('04','30','2012'),mdy('05','20','2012'),mdy('05','31','2012'),mdy('06','20','2012'),mdy('07','20','2012'),mdy('08','20','2012'))
               and num_credito = vNumCred;

             delete from bdicred:sd_hist_reserva
              where empresa = '001'
                and fecha_corte <= dFechaDepura
                and num_credito = vNumCred;

		LET iCount_sd_hist_reserva_old	= iCount_sd_hist_reserva_old + 1;
				
--sd_movhis_calif
            insert into bdicred:sd_movhis_calif_old
--            select {+INDEX(sd_movhis_calif inx_movhis_calif_1)} * from bdicred:sd_movhis_calif
            select * from bdicred:sd_movhis_calif
            where empresa = '001'
             and fecha_mov = dFechaDepura
/*            and fecha_mov in (
                mdy('06','30','2012'),
                mdy('07','31','2012'),
                mdy('08','31','2012'),
                mdy('09','30','2012'),
                mdy('10','31','2012'),
                mdy('11','30','2012'),
                mdy('12','31','2012'))*/
            and num_credito = vNumCred;

            delete from bdicred:sd_movhis_calif
            where empresa = '001'
            and fecha_mov = dFechaDepura
/*            and fecha_mov in (
                mdy('06','30','2012'),
                mdy('07','31','2012'),
                mdy('08','31','2012'),
                mdy('09','30','2012'),
                mdy('10','31','2012'),
                mdy('11','30','2012'),
                mdy('12','31','2012'))*/
            and num_credito = vNumCred;

			LET iCount_sd_movhis_calif_old	= iCount_sd_movhis_calif_old + 1;
			
            UPDATE "informix".sd_param_movhis_dep
               SET num_credito = vNumCred
             WHERE proceso = 3;
        COMMIT WORK;  
        let iDepura = 0;

		SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraFinal from sysmaster:sysshmvals;

		LET	sHoraFinal = SUBSTR(cHoraFinal,1,2);
		LET	sMinutoFinal = SUBSTR(cHoraFinal,4,2);
		LET	sHoraFinal = sHoraFinal - sHoraInicial;

		IF sHoraFinal >= sHorasProceso AND sMinutoFinal > sMinutoInicial THEN
			LET cTerminaProceso = '1';
			EXIT FOREACH;
		END IF;
	END FOREACH;

	IF cTerminaProceso = '0' THEN
		UPDATE "informix".sd_param_movhis_dep
		SET num_credito = ''
		WHERE proceso = 3;
	END IF;

	LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iCuentasProcesadas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdoshist_old : ' ||iCount_sd_maesdoshist_old;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = 'Cuentas respaldadas sd_maecredcont_old : ' ||iCount_sd_maecredcont_old;
	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdoscont_old : ' ||iCount_sd_maesdoscont_old;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = 'Cuentas respaldadas sd_hist_reserva_old : ' ||iCount_sd_hist_reserva_old;
	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_movhis_calif_old : ' ||iCount_sd_movhis_calif_old;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	
    CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;

    IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;

	LET P_MENSAJE = P_MENSAJE || ' ' || iCuentasProcesadas;
	
    RETURN cCodRet,P_MENSAJE;

    END
END PROCEDURE;