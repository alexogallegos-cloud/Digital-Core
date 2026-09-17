CREATE PROCEDURE "informix".sp_calculaprorrateodecomisiones(dFecha_Hoy DATE)
RETURNING CHAR(5);

    --DEFINICION DE VARIABLES
    DEFINE cCodRet          CHAR(5);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE mImporte         MONEY(16,2);
    DEFINE mIva             MONEY(16,2);
    DEFINE cNumCategoria    CHAR(2);
    DEFINE cNumConvenio     CHAR(3);
    DEFINE cInfoErr         CHAR(100);
    DEFINE iExiste          INTEGER;

      --	SET DEBUG FILE TO "/informix/VH/sac/exi.out";
      --	TRACE ON;

    --INICIALIACION DE VARIABLES
    LET cCodRet = '00000';
    LET cNumCategoria='0';
    LET cNumConvenio='0';
    LET mImporte=0;
    LET mIva=0;
    LET iExiste =0;


    BEGIN

        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_SACCalculaProrrateoDeComisiones");
                    RETURN cCodRet;
                END IF;
        END EXCEPTION;

        FOREACH
        SELECT /*{+INDEX (bdisac:sac_convenios idxsac_conv3)}*/ 
				numcategoria,
				numconvenio,
				imp_com_trans_conv,
				iva_convenio 
			INTO 
				cNumCategoria,
				cNumConvenio,
				mImporte,
				mIva 
		   FROM 
				sac_convenios 
			WHERE 
				nomconvenio NOT IN ('PAGO DE REMESAS BTS') 
				AND imp_com_trans_conv <> 0 
				ORDER BY 
				/* Utiliza el Ã­ndice en la clÃ¡usula ORDER BY para mejorar el rendimiento */
				numcategoria, numconvenio
    
  --          SELECT /*{+INDEX (bdisac:sac_convenios idxsac_conv3)}*/ numcategoria,numconvenio,imp_com_trans_conv,iva_convenio INTO cNumCategoria,cNumConvenio,mImporte,mIva FROM sac_convenios WHERE nomconvenio NOT IN ('PAGO DE REMESAS--- BTS') AND imp_com_trans_conv<>0 

            SELECT COUNT(*) INTO iExiste FROM sac_movimientos 
            WHERE fecha_pago = dFecha_Hoy AND numcategoria = cNumCategoria and numconvenio = cNumConvenio AND importe_comision_convenio<>mImporte;

            IF iExiste>0 THEN
                UPDATE sac_movimientos SET importe_comision_convenio = mImporte, iva_comision_convenio = mImporte * (mIva/100)
                WHERE fecha_pago = dFecha_Hoy AND numcategoria = cNumCategoria AND numconvenio = cNumConvenio AND importe_comision_convenio<>mImporte;
            END IF;

        END FOREACH;
        RETURN cCodRet;
    END;
 END PROCEDURE
 DOCUMENT
'AUTOR : Jose Angel Lopez Adams',
'DESCRIPCION: Se encarga de calcular un prorrateo de las comisiones de aquellos convenios, a los cuales se les cobra comision por el total de la cobranza',
'EJECUTADO O LLAMADO POR: sp_ProcesoCierreDiarioSAC',
'BD: bdisac',
'FECHA : Septiembre de 2008',
'VERSION: 20080905';

CREATE PROCEDURE "informix".sp_generaarchivoscobranzacentral(dFecha_Hoy DATE)
RETURNING CHAR(5);  --CÃÂ³digo de retorno

   -- DEFINICION DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
    DEFINE iSqlErr                  INTEGER;
    DEFINE iIsamErr                 INTEGER;
    DEFINE cInfoErr                 CHAR(100);

    DEFINE cStatusConvenio          CHAR(1);
    DEFINE cNumCategoria            CHAR(2);
    DEFINE cNumConvenio             CHAR(3);
    DEFINE cId_convenio             CHAR(5);
    DEFINE cNom_rutina              CHAR(100);
    DEFINE cSqlStmt                 CHAR(200);

    DEFINE iFrecuencia              INTEGER;
    DEFINE iDiferencia              INTEGER;
    DEFINE iTransacciones           INTEGER;

    DEFINE dFechaUltimoArchivo      DATE;

    DEFINE bFlag                    BOOLEAN;

    DEFINE antadActivo              INTEGER;
    DEFINE actualActivo             char(5);
    DEFINE actualRegistrado         char(5);
    DEFINE cuentaRegistrados        INTEGER;


    --SET DEBUG FILE TO "/tmp/Cent.out";
    --TRACE ON;

    --INICIALIZACION DE VARIABLES--
    LET cCodRet = "00000";
    LET iSqlErr = 0;
    LET cInfoErr = '';

    LET cStatusConvenio = '';
    LET cSqlStmt = '';
    LET cNom_rutina = '';
    LET cId_convenio = '';
    LET iFrecuencia = 0;
    LET iTransacciones = 0;
    LET iDiferencia = 0;
    LET bFlag = 'f';

    LET antadActivo = 0;
    LET actualActivo = '';
    LET actualRegistrado = '';
    LET cuentaRegistrados = 0;





    BEGIN

        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_genera_ArchivosCobranzaCentral");
                RETURN cCodRet;
            END IF;
        END EXCEPTION;
        --SET DEBUG FILE TO "/tmp/exi.out";
        --TRACE ON;



 --ANTAD  mofificacion RQM 10 954 Alta de ConexiÃÂ³n a Red de Plataforma ElectrÃÂ³nica ANTAD.
            --esta secciÃÂ³n mantiene el registro de un solo convenio de antad en la tabla 'sac_controlarchivoscobranza'

            LET antadActivo = (SELECT count(*) FROM sac_convenios WHERE nomconvenio like '%ANTAD)' and statusconvenio='A');

            IF antadActivo > 0 THEN
                
                LET actualActivo = (SELECT FIRST 1 numcategoria || numconvenio FROM sac_convenios WHERE nomconvenio like '%ANTAD)' and statusconvenio='A');
                LET cuentaRegistrados = (SELECT count(*) FROM sac_controlarchivoscobranza WHERE nom_rutina ='sp_generaarchivocobranzaantad');

                IF cuentaRegistrados = 0 THEN 
                        INSERT INTO "informix".sac_controlarchivoscobranza(numcategoria, numconvenio, nom_rutina, retorno, fecha_ultimo_archivo)
                        VALUES(substr(actualActivo,1,2), substr(actualActivo,3,3), 'sp_generaarchivocobranzaantad', '00000', today-1);
                ELSE
                    LET actualRegistrado= (SELECT numcategoria || numconvenio FROM sac_controlarchivoscobranza WHERE nom_rutina = 'sp_generaarchivocobranzaantad');

                    IF actualActivo <> actualRegistrado THEN
                        UPDATE "informix".sac_controlarchivoscobranza set numcategoria = substr(actualActivo,1,2), numconvenio =substr(actualActivo,3,3)
                        WHERE numcategoria = substr(actualRegistrado,1,2) and numconvenio =substr(actualRegistrado,3,3);
                    END IF;
                END IF;
            END IF;
 --/ANTAD---------------------------------------------------



            FOREACH
                --SELECT  a.numcategoria, a.numconvenio, a.statusconvenio, a.frecnotificacion, b.nom_rutina, b.fecha_ultimo_archivo
                --FROM bdisac:sac_convenios a
                --INNER JOIN bdisac:sac_controlarchivoscobranza b
                --INTO cNumCategoria, cNumConvenio, cStatusConvenio, iFrecuencia, cNom_rutina, dFechaUltimoArchivo
                --ON a.numcategoria = b.numcategoria
                --AND a.numconvenio = b.numconvenio;

            --se cambia la consulta para quitar la busqueda secuencial ---
SELECT 
    a.numcategoria, 
    a.numconvenio, 
    a.statusconvenio, 
    a.frecnotificacion, 
    TRIM(b.nom_rutina), 
    b.fecha_ultimo_archivo
INTO 
    cNumCategoria, 
    cNumConvenio, 
    cStatusConvenio, 
    iFrecuencia, 
    cNom_rutina, 
    dFechaUltimoArchivo
FROM 
    bdisac:sac_convenios a
JOIN 
    bdisac:sac_controlarchivoscobranza b
    ON a.numcategoria = b.numcategoria
    AND a.numconvenio = b.numconvenio
WHERE
    a.numcategoria IN (SELECT numcategoria FROM bdisac:sac_controlarchivoscobranza)
                
                
/*

                SELECT  a.numcategoria, a.numconvenio, a.statusconvenio, a.frecnotificacion, TRIM(b.nom_rutina), b.fecha_ultimo_archivo
                INTO cNumCategoria, cNumConvenio, cStatusConvenio, iFrecuencia, cNom_rutina, dFechaUltimoArchivo
                FROM bdisac:sac_convenios a, bdisac:sac_controlarchivoscobranza b
                WHERE  a.numcategoria = b.numcategoria
                AND a.numconvenio = b.numconvenio

*/

           


                LET cId_convenio = cNumCategoria || cNumConvenio ;
                LET iDiferencia = ((dFecha_Hoy::DATE) - (dFechaUltimoArchivo::DATE));

                IF iDiferencia >= iFrecuencia THEN
                    IF cStatusConvenio = 'I' THEN

                      SELECT COUNT(*)
INTO iTransacciones
FROM sac_movimientoshistorial
WHERE numcategoria = cNumCategoria
  AND numconvenio = cNumConvenio
    AND fecha_pago > dFechaUltimoArchivo
LIMIT 1;


                        IF iTransacciones > 0 THEN
                                LET bFlag = 't';
                        END IF;
                    END IF;

                    IF cStatusConvenio = 'A' OR bFlag = 't' THEN

                        --LET cSqlStmt = 'echo "EXECUTE PROCEDURE bdisac:'||TRIM(cNom_rutina)||"('"||cId_convenio||''''||','''||dFechaUltimoArchivo||''', ''' || dFecha_Hoy || ''');"> /tmp/tmp.sql';
                        LET cSqlStmt = 'echo "EXECUTE PROCEDURE bdisac:'||TRIM(cNom_rutina)||"('"||cId_convenio||''');" > /tmp/cob.sql';
                        SYSTEM cSqlStmt;
                        LET cSqlStmt  = 'dbaccess bdisac /tmp/cob.sql';
                        SYSTEM cSqlStmt;

                        SELECT retorno
                        INTO cCodRet
                        FROM sac_controlarchivoscobranza
                        WHERE numcategoria = cNumCategoria
                        AND numconvenio = cNumConvenio;

                        IF CAST(cCodRet AS INTEGER) <> 0 THEN
                            RETURN cCodRet;
                        END IF;


                    END IF;
                END IF;

                LET bFlag = 'f';

            END FOREACH;
            LET cSqlStmt = 'rm -f /tmp/cob.sql';
            SYSTEM cSqlStmt;

            RETURN cCodRet;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : JosÃÂ© Angel LÃÂ³pez Adams',
'DESCRIPCION: Se encarga de validar si es tiempo de generar el archivo de cobranza de un convenio, de ser asi ejecuta el SP correspondiente',
'Sucursales',
'EJECUTADO O LLAMADO POR:',
'sp_genera_ArchivosCobranzaCentral()',
'FECHA : Agosto de 2008',
'VERSION: 200808',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_tramapago_dish(pNumCategoria CHAR (2), pNumConvenio CHAR (3), pFolioSucursal CHAR (16), pRef1 CHAR (40), pId_Sucursal CHAR (4), pFecha_Pago DATE, pNumTrama INTEGER,pTimeStamp CHAR (10))
RETURNING CHAR (5) AS cCodRet, CHAR (35) AS cTrama;

--Variables
DEFINE cCodRet CHAR(5);
DEFINE cTrama CHAR(35);
DEFINE iSqlErr INTEGER;
DEFINE cTrans_MotorS CHAR(5); -- Trans_Motors
DEFINE cTrans_Suc CHAR(4);
DEFINE cTrans_Central CHAR(5);
DEFINE cTrans_Interact CHAR(5);
DEFINE cNum_Sucursal CHAR (4);
DEFINE cReferencia CHAR(14);
DEFINE cUser_Insert CHAR(10);
DEFINE cFolioConsultaDish CHAR(10);
DEFINE cImportePago CHAR(10);
DEFINE cClienteDish CHAR(10);

LET cCodRet		= '00000';
LET iSqlErr		= 0;
LET cTrama		= '';
LET cTrans_MotorS	= '';	
LET cTrans_Suc = '';
LET cTrans_Central = '';
LET cTrans_Interact = '';
LET cClienteDish = '';
LET cFolioConsultaDish = '';
LET cImportePago = '';
LET cNum_Sucursal = pId_Sucursal;
LET cReferencia = TRIM(pRef1);
LET cUser_Insert = 'Informix';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/RESPALDOSNEW/meg/sp_tramapagodish.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, NVL(cTrama, '');
		END IF;
	END EXCEPTION;

	IF NVL(pFecha_Pago, '') = '' OR NVL(pNumCategoria, '') = '' OR NVL (pNumConvenio, '') = '' OR NVL(pFolioSucursal, '') = '' OR NVL (pRef1, '') = '' OR NVL(pId_Sucursal, '') = '' OR NVL(pNumTrama, '') = '' THEN
		LET cCodRet = '00002'; --DATOS VACIOS, ERROR.
		RETURN cCodRet, NVL(cTrama, '');
	END IF;
		
	--Obtenemos la codigo del interac requeridos  de bdisac:"informix".sac_intrfz_serv
	SELECT trans_interact, trans_servicio INTO  cTrans_Interact, cTrans_MotorS FROM   bdisac: "informix".sac_intrfz_serv WHERE  numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND num_trama = pNumTrama;
	IF DBINFO("sqlca.sqlerrd2") = 0 Or cTrans_Interact= '' Or cTrans_MotorS= '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet, NVL(cTrama, '');
	END IF;
		
	--Obtenemos los parametros de la sac_msw_respuesta para la generacion de la trama
	SELECT campo2, campo7 INTO cClienteDish, cFolioConsultaDish FROM  bdisac:"informix".sac_msw_respuesta  WHERE numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND folio_suc = pFolioSucursal AND num_trama = 1;
	IF DBINFO("sqlca.sqlerrd2") = 0 Or cClienteDish = '' OR cFolioConsultaDish = '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet, NVL(cTrama, '');
	END IF;				
		
	--Obtenemos el monto a pagar
	SELECT REPLACE(importe_pago,'$', '') INTO cImportePago FROM bdisac:"informix".sac_movimientos WHERE numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND folio_suc = pFolioSucursal;

	--Agrupa los datos para la generacion de la trama
	LET cTrama = cTrans_MotorS||cFolioConsultaDish||cImportePago||cClienteDish;
	
	SELECT trans_suc_efectivo, trans_cen_efectivo_cliente INTO cTrans_Suc, cTrans_Central FROM   bdisac: "informix".sac_convenios WHERE  numcategoria = pNumCategoria AND numconvenio = pNumConvenio;
	IF DBINFO("sqlca.sqlerrd2") = 0 Or cTrans_Suc= '' Or  cTrans_Central=''THEN
		LET cCodRet = '00001';
		RETURN cCodRet, NVL(cTrama, '0');
	END IF;
	
/*	
	INSERT INTO bdisac: "informix".sac_msw_solicitud(
		numcategoria,
		numconvenio, 
		id_sucursal, 
		trans_suc, 
		trans_central, 
		trans_interact, 
		folio_suc, 
		fecha_pago, 
		num_trama, 
		campo1, 
		campo2, 
		campo3, 
		campo4,
		campo5,campo6,campo7,campo8,campo9,campo10,campo11,campo12,campo13,campo14,
		campo15,campo16,campo17,campo18,campo19,campo20,campo21,campo22,campo23,campo24,
		campo25,campo26,campo27,campo28,campo29,campo30,campo31,campo32,campo33,campo34,
		campo35,campo36,campo37,campo38,campo39,campo40,
		user_insert,
		fecha_insert) 
		VALUES (
		pNumCategoria, 
		pNumConvenio, 
		pId_Sucursal, 
		cTrans_Suc, 
		cTrans_Central, 
		cTrans_Interact, 
		pFolioSucursal, 
		pFecha_Pago,
		pNumTrama,
		cTrans_MotorS,
		cNum_Sucursal,
		cReferencia,
		cClienteDish,
		cImportePago,
		cFolioConsultaDish,
		pTimeStamp,
		'','','','','','','','','',
		'','','','', '', '', '', '', '',
		'', '', '', '', '', '', '', '', '',
		'', '', '', '', '', '',
		cUser_Insert,
		current);		*/
	  
	RETURN cCodRet, NVL(cTrama, '');
END;
END PROCEDURE
;