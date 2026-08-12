CREATE PROCEDURE "informix".sp_verificastatusarqueosucaja(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusarqueosucaja.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT {+INDEX (bdicnweb:sw_verificastatusarqueosucaja idx_sw_verificastatusarqueosucaja)} status,total_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM bdicnweb:sw_verificastatusarqueosucaja WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 26/06/2021',
'FUNCIONALIDAD: VERIFICA EL ESTATUS DEL PROCESO ARQUEO SUCURSALES',
'DESCRIPCION: ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_traspasodoctoscorr(pUsuario CHAR(8),pIdFuncion CHAR(10),
pCteTitular CHAR(20),pCteTraspasa CHAR(20),pUsEjecuta CHAR(8),pTipoCte CHAR(1),pBloqueInf CHAR(500),pIteracion CHAR(1))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cInsImg CHAR(100);
	DEFINE cInsImgHis CHAR(100);
	DEFINE cCod_doctoDig CHAR(4);
	DEFINE cDesc_doctoDig CHAR(35);
	DEFINE cCuentaDig CHAR(20);
	DEFINE sSecuenciaDig SMALLINT;
	DEFINE cFechaDig CHAR(10);
	DEFINE cDescripcionDig CHAR(50);
	DEFINE cNumCteDig CHAR(20);
	DEFINE cEmp CHAR(3);
	DEFINE cCliente CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cProducto CHAR(4);
	DEFINE cCod_docto CHAR(4);
	DEFINE sSecuencia SMALLINT;
	DEFINE cProd_nombre CHAR(40);
	DEFINE cDescrip2 CHAR(30);
	DEFINE cUsuario_alta CHAR(8);
	DEFINE dFecha_alta DATE;
	DEFINE cUsuario_modif CHAR(8);
	DEFINE dFecha_modif DATE;
	DEFINE cTabla CHAR(30);
	DEFINE cDetalleMov CHAR(200);
	DEFINE cCuentaDg CHAR(20);
	DEFINE cProductoDg CHAR(4);
	DEFINE cCod_doctoDg CHAR(4);
	DEFINE sSecuenciaDg SMALLINT;
	DEFINE dFecha_altaDg DATE;
	DEFINE iMaxSec SMALLINT;
    DEFINE iMaxSecAux SMALLINT;
	
	DEFINE cIdReg LVARCHAR;
	DEFINE iRecuperacion INTEGER;
	DEFINE iContador INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cInsImg = '';
	LET cInsImgHis = '';
	LET cCod_doctoDig = '';
	LET cDesc_doctoDig = '';
	LET cCuentaDig = '';
	LET sSecuenciaDig = 0;
	LET cFechaDig = '';
	LET cDescripcionDig = '';
	LET cNumCteDig = '';
	LET cEmp = '';
	LET cCliente = '';
	LET cCuenta = '';
	LET cProducto = '';
	LET cCod_docto = '';
	LET sSecuencia = 0;
	LET cProd_nombre = '';
	LET cDescrip2 = '';
	LET cUsuario_alta = '';
	LET dFecha_alta = '';
	LET cUsuario_modif = '';
	LET dFecha_modif = '';
	LET cTabla = '';
	LET cDetalleMov = '';
	LET cCuentaDg = '';
	LET cProductoDg = '';
	LET cCod_doctoDg = '';
	LET sSecuenciaDg = 0;
	LET dFecha_altaDg = '';
	LET iMaxSec = 0;
    LET iMaxSecAux = 0;
	
	LET cIdReg = '';
	LET iRecuperacion = 0;	
	LET iContador = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_traspasodoctoscorr.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCteTitular = '' OR pCteTraspasa = '' OR pUsEjecuta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			EXECUTE PROCEDURE "informix".sp_split_cadena(pBloqueInf, '|')
			INTO cIdReg
			
			SELECT cod_docto,desc_docto,cuenta,secuencia,fecha,descripcion,numcte
			INTO cCod_doctoDig,cDesc_doctoDig,cCuentaDig,sSecuenciaDig,cFechaDig,cDescripcionDig,cNumCteDig
			FROM bdicnweb:"informix".sw_fc_detdocsdigitalizados
			WHERE usuario_insert = pUsuario AND id_registro = cIdReg;
			
			LET iRecuperacion = iRecuperacion + 1;
			LET iMaxSec = sSecuenciaDig;
			
			SELECT empresa,cliente,cuenta,producto,cod_docto,secuencia,prod_nombre,descrip2,usuario_alta,fecha_alta,usuario_modif,fecha_modif
			INTO cEmp,cCliente,cCuenta,cProducto,cCod_docto,sSecuencia,cProd_nombre,cDescrip2,cUsuario_alta,dFecha_alta,cUsuario_modif,dFecha_modif
			FROM bdidigital@coppelimg_tcp:dg_expediente 
			WHERE cliente = pCteTraspasa AND cuenta = cCuentaDig AND cod_docto = cCod_doctoDig AND secuencia = sSecuenciaDig AND empresa = '001';
			
			INSERT INTO bdinteg:"informix".si_fusexpediente(empresa,cliente,cuenta,producto,cod_docto,secuencia,prod_nombre,descrip2,usuario_alta,fecha_alta,usuario_modif,fecha_modif)
			VALUES(cEmp,cCliente,cCuenta,cProducto,cCod_docto,sSecuencia,cProd_nombre,cDescrip2,cUsuario_alta,dFecha_alta,cUsuario_modif,dFecha_modif);
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			END IF;
			
			SELECT MAX(secuencia) INTO iMaxSecAux
            FROM bdidigital@coppelimg_tcp:dg_expediente_img1
            WHERE cliente = pCteTitular AND cod_docto = cCod_doctoDig AND empresa = '001';
            
            IF NVL(iMaxSecAux,0) = 0 THEN
              LET iMaxSecAux = iMaxSec;
            ELSE
              LET iMaxSecAux = iMaxSecAux + 1;
            END IF;
			
			UPDATE bdidigital@coppelimg_tcp:dg_expediente_img1 SET cliente = pCteTitular, secuencia = iMaxSecAux --iMaxSec 
			WHERE cliente = pCteTraspasa AND cod_docto = cCod_doctoDig AND secuencia = sSecuenciaDig AND empresa = '001';
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			END IF;
			
			SELECT MAX(secuencia) INTO iMaxSecAux
            --FROM bdidigital@coppelimg20_tcp:dg_expediente_img
			FROM bdidigital@coppelimghis_tcp:dg_expediente_img
            WHERE cliente = pCteTitular AND cod_docto = cCod_doctoDig AND empresa = '001';
            
            IF NVL(iMaxSecAux,0) = 0 THEN
              LET iMaxSecAux = iMaxSec;
            ELSE
              LET iMaxSecAux = iMaxSecAux + 1;
            END IF;

			--UPDATE bdidigital@coppelimg20_tcp:dg_expediente_img SET cliente = pCteTitular, secuencia = iMaxSecAux 
			UPDATE bdidigital@coppelimghis_tcp:dg_expediente_img SET cliente = pCteTitular, secuencia = iMaxSecAux 
			WHERE cliente = pCteTraspasa AND cod_docto = cCod_doctoDig AND secuencia = sSecuenciaDig AND empresa = '001';
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			END IF;
			
            SELECT MAX(secuencia) INTO iMaxSecAux
            --FROM bdidigital@coppelimg20_tcp:dg_expediente_img_his
            FROM bdidigital@coppelimghis_tcp:dg_expediente_img_his
            WHERE cliente = pCteTitular AND cod_docto = cCod_doctoDig AND empresa = '001';
            
            IF NVL(iMaxSecAux,0) = 0 THEN
              LET iMaxSecAux = iMaxSec;
            ELSE
              LET iMaxSecAux = iMaxSecAux + 1;
            END IF;
      
			--UPDATE bdidigital@coppelimg20_tcp:dg_expediente_img_his SET cliente = pCteTitular, secuencia = iMaxSecAux --iMaxSec 
			UPDATE bdidigital@coppelimghis_tcp:dg_expediente_img_his SET cliente = pCteTitular, secuencia = iMaxSecAux --iMaxSec 
			WHERE cliente = pCteTraspasa AND cod_docto = cCod_doctoDig AND secuencia = sSecuenciaDig AND empresa = '001';
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			END IF;
			
			LET cTabla = 'dg_expediente_img';
			LET cDetalleMov = TRIM(pCteTraspasa)||'|'||cCod_doctoDig||'|'||sSecuenciaDig||'|'||iMaxSec||'|'||'IMAGEN ACTUALIZADA';
			
			SELECT MAX(secuencia) INTO iMaxSecAux
            FROM bdidigital@coppelimg_tcp:dg_expediente
            WHERE cliente = pCteTitular AND cuenta = cCuentaDig AND cod_docto = cCod_doctoDig AND empresa = '001';
            
			IF NVL(iMaxSecAux,0) = 0 THEN
              LET iMaxSecAux = iMaxSec;
            ELSE
              LET iMaxSecAux = iMaxSecAux + 1;
            END IF;
      
			UPDATE bdidigital@coppelimg_tcp:dg_expediente SET cliente  = pCteTitular, secuencia = iMaxSecAux --iMaxSec 
			WHERE cliente = pCteTraspasa AND cuenta = cCuentaDig AND cod_docto = cCod_doctoDig AND secuencia = sSecuenciaDig AND empresa = '001';
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			
			END IF;
			
			LET cTabla = 'dg_expediente';
			LET cDetalleMov = TRIM(pCteTraspasa)||'|'||cCod_doctoDig||'|'||sSecuenciaDig||'|'||iMaxSec||'|'||'IMAGEN ACTUALIZADA';
			
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES ('DG_EXPEDIENTE',cTabla,pCteTitular,pCteTraspasa,cDetalleMov,CURRENT HOUR TO FRACTION(4),pUsEjecuta,CURRENT);
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN				
			END IF;		
			
		END FOREACH;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de realizar el traspaso de documentos.',
'BD: bdicnweb',
'AUTOR: Johnattan Esquivel Sánchez',
'FECHA: 18/05/2020',
'DESCRIPCION: Modificación de SPL para tratamiento de error -268.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rep_sac_reportediario(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicial DATE, pFechaFinal DATE, pRutaDescarga CHAR(100), pTipoR CHAR(1))
    RETURNING CHAR(5) AS codret,
    CHAR(100) AS reporte_generado;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE iProcesados INTEGER;
	DEFINE iReg INTEGER;
	DEFINE iRec INTEGER;
	DEFINE iNumRegistros INTEGER;
	DEFINE dFechaHoy DATE;
	DEFINE cFechaHoraArchivo CHAR(15);
	DEFINE iLineaError_Rep INTEGER;
	DEFINE  cBanDetError CHAR(1);
    DEFINE cFecha1 CHAR(10);
    DEFINE cFecha2 CHAR(10);
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET iProcesados = 0;
    LET cFecha1='';
    LET cFecha2='';
	LET  iReg =0;
	LET  iRec=0;
	LET  iNumRegistros=0;
	LET  dFechaHoy = '';
	LET  cFechaHoraArchivo = '';
	LET iLineaError_Rep=0;
	LET cBanDetError = 'f';

	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet, cNombreArchivo;
        END EXCEPTION;

        ON EXCEPTION IN (-668, -535, -255)
            LET bInTransaction = 't';
           COMMIT WORK;
            BEGIN WORK;
        END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_rep_sac_reportediario.out';
		--TRACE ON;
		
		--SET DEBUG FILE TO '/informix/HMLG/sp_rep_sac_reportedomiciliacion.out';
		--TRACE ON;
		

		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL  OR pRutaDescarga = '' THEN
			LET cCodRet = '00003';			
	       RETURN cCodRet, cNombreArchivo;
    	END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			 RETURN cCodRet, cNombreArchivo;
		END IF;
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		 
		SELECT COUNT(*)
		INTO iNumRegistros
		FROM bdisac:sac_reportediario_seg WHERE fecha_proceso BETWEEN pFechaInicial AND pFechaFinal;


		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNombreArchivo;
		END IF;
        
        LET cFecha1= LPAD(MONTH(pFechaInicial),2,0)||'/'||LPAD(DAY(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial);
        LET cFecha2= LPAD(MONTH(pFechaFinal),2,0)||'/'||LPAD(DAY(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal);
        
		LET cCmd1 ="";
        LET cCmd1 ="SELECT 'FECHA','No. MESES VENT','IMPORTE VENT','No. MESES DOMI','IMPORTE DOMI','NO. MESES','IMPORTE TOTAL','COMISION','IVA','IMPORTE PAGO COPPEL' FROM systables WHERE tabid = 1 ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT  LPAD(DAY(fecha_proceso),2,0)||'/'||LPAD(MONTH(fecha_proceso),2,0)||'/'||YEAR(fecha_proceso),num_mesesvent::CHAR(18), importe_vent::CHAR(18), num_mesesdomi::CHAR(18), importe_domi::CHAR(18),num_meses::CHAR(18), importe_total::CHAR(18), comision::CHAR(18),iva::CHAR(18),importe_pago_coppel::CHAR(18) ";
        LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisac:""informix"".sac_reportediario_seg";
        LET cCmd1 =""||TRIM(cCmd1)||" WHERE reportesoc='1' AND  fecha_proceso BETWEEN '"||cFecha1||"' AND '"||cFecha2||"'" ;
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'TOTALES'::CHAR(18),SUM(num_mesesvent)::CHAR(18),SUM (importe_vent)::CHAR(18), SUM (num_mesesdomi)::CHAR(18), SUM(importe_domi)::CHAR(18) ,SUM(num_meses)::CHAR(18), SUM (importe_total)::CHAR(18),SUM(comision)::CHAR(18), SUM(iva)::CHAR(18),SUM(importe_pago_coppel)::CHAR(18) ";
        LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisac:""informix"".sac_reportediario_seg";
        LET cCmd1 =""||TRIM(cCmd1)||" WHERE reportesoc='1' AND  fecha_proceso BETWEEN '"||cFecha1||"' AND '"||cFecha2||"'" ;

		LET dFechaHoy = CURRENT;
		LET cFechaHoraArchivo = YEAR(dFechaHoy)||LPAD(MONTH(dFechaHoy),2,0)||LPAD(DAY(dFechaHoy),2,0)||TO_CHAR(CURRENT, '%H%M%S');
		
		 
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
		IF (pTipoR=1) THEN 
		LET cNombreArchivo = 'REP_CONCILIACION_CPF_'||TRIM(cFechaHoraArchivo)||'.xls';
		ELSE 
		LET cNombreArchivo = 'REP_CONCILIACION_CPF_'||TRIM(cFechaHoraArchivo)||'.csv';
		END IF;

        LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
        LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);


                BEGIN WORK;
                       LET ven_transacc = 1;

                        LET cSql = '';
                       IF (pTipoR='1') THEN 
                	    LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
                        ELSE
                        LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '','' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
                        END IF;
                          SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        
						-- PreProd SOC v2 
						--LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
						
						-- Prod SOC v2 
						LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
						
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de línea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el archivo original
                        LET cSql = '';
                        LET cSql = "rm -rf "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el caracter delimitador ';' al final de la línea
                        LET cSql = '';
                        LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de línea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);


                       
        LET cBanDetError = 't';


				COMMIT WORK;

               LET ven_transacc = 0;
               IF bInTransaction = 't' THEN
                       BEGIN WORK;
               END IF;
				
		

		RETURN cCodRet, cNombreArchivo;


	END;
END PROCEDURE;