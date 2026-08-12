CREATE PROCEDURE "informix".sp_generainformacionreportesespeciales(dFecha_Hoy DATE)
RETURNING CHAR(5);
   /**************DEFINICION DE VARIABLES****************/

   DEFINE cCodret           CHAR(5);
   DEFINE cInfoErr          CHAR(100);
   DEFINE iSqlErr,iIsamErr  INTEGER;

   DEFINE cIdConvenio       CHAR(5);
   DEFINE cNumCategoria     CHAR(2);
   DEFINE cNumConvenio      CHAR(3);

   DEFINE cNomRutina        CHAR(30);
   DEFINE cSqlStmt          CHAR(150);

    /***********INICIALIZACION DE VARIABLES**************/
   --SET DEBUG FILE TO "/tmp/rep.out";
   --TRACE ON;
   LET cCodret = '00000';

   BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_GeneraInformacionReportesEspeciales");
                    RETURN cCodRet;
                END IF;
        END EXCEPTION;
   END;

   FOREACH

        SELECT {+AVOID_FULL("informix".sac_convenios)} numcategoria||numconvenio, TRIM(nomreporte) -- Se crea índice para eliminar busqueda secuencial
        INTO cIdConvenio, cNomRutina
        FROM sac_convenios
        WHERE flgreporte = 1
		
		--If de prueba Army
		IF TRIM(cNomRutina) = '' OR cNomRutina IS Null THEN
			CONTINUE FOREACH;
		END IF;
		--

        LET cNumCategoria = SUBSTRING(cIdConvenio FROM 1 FOR 2);
        LET cNumConvenio = SUBSTRING(cIdConvenio FROM 3 FOR 3);

        LET cSqlStmt = 'echo "EXECUTE PROCEDURE bdisac:'|| TRIM(cNomRutina) || '('''|| cIdConvenio ||''')" > /tmp/rpt.sql';
        SYSTEM cSqlStmt;
        LET cSqlStmt = 'dbaccess bdisac /tmp/rpt.sql';
        SYSTEM cSqlStmt;

        SELECT retorno
        INTO cCodRet
        FROM sac_controlreportesespeciales
        WHERE numcategoria = cNumCategoria
        AND numconvenio = cNumConvenio;

        IF CAST(cCodRet AS INTEGER) <> 0 THEN
            RETURN cCodRet;
        END IF;


   END FOREACH;
   LET cSqlStmt = 'rm -f /tmp/rpt.sql';
   SYSTEM cSqlStmt;
   RETURN cCodRet;
END PROCEDURE
DOCUMENT
'AUTOR : José Angel López Adams',
'DESCRIPCION: Se encarga de ejecutar las rutinas de reportes especiales de los convenios que asi lo requieran.',
'MODIFICO: Jesus Armando Mercado',
'MODIFICO: Se incluye el flag para la ejecucion de los reportes especiales.',
'FECHA : 14 de Mayo de 2010',
'VERSION: 20100514.1520',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_actualizafechassac()

    RETURNING
    CHAR(5);

    -- Definicion de Variables
    DEFINE cCodRet           CHAR(5);
    DEFINE cInfoErr          CHAR(100);
    DEFINE iIsamErr          INTEGER;
    DEFINE iSqlErr           INTEGER;
    DEFINE dFechaAct         DATE;
    DEFINE dFechaAnt         DATE;
    DEFINE cEsFeriado        CHAR(1);
    DEFINE cAnio             CHAR(4);
    DEFINE cFlag             CHAR(1);
    DEFINE cMes              CHAR(2);
    DEFINE cMesAnt           CHAR(2);
	DEFINE cDia              CHAR(2);
    DEFINE dPriDia_Mes       DATE;
    DEFINE dUltDia_Mes       DATE;
    DEFINE dUltHabMes        DATE;

    --SET DEBUG FILE TO '/tmp/sp_ActulizaFechas.out';
    --TRACE ON;
    -- Inicializa variables
     LET cCodRet = "00000";
     LET iSqlErr = 0;
     LET cEsFeriado = "0";

    BEGIN
        ON EXCEPTION SET iSqlErr, iISamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                EXECUTE PROCEDURE bdisac:sp_sac_guardamensajeerror(iSqlErr, iISamErr, cInfoErr,"sp_ActulizaFechas");
                LET cCodRet = iSqlErr;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;
		
        UPDATE {+AVOID_FULL("informix".sac_fechas)}bdisac:sac_fechas -- Se crea índice para eliminar busqueda secuencial
        SET fecha_ant = fecha_hoy, fecha_hoy = prox_fecha, prox_fecha = prox_fecha + 1;
        SELECT {+AVOID_FULL("informix".sac_fechas)} fecha_ant, fecha_hoy INTO dFechaAnt, dFechaAct FROM bdisac:sac_fechas; -- Se crea índice para eliminar busqueda secuencial

        LET cAnio = LPAD(YEAR(dFechaAct::DATE) , 4, '0');
        LET cMes = LPAD(MONTH(dFechaAct::DATE), 2, '0');
        LET cMesAnt = LPAD(MONTH(dFechaAnt::DATE), 2, '0');
		LET cDia = LPAD(DAY(dFechaAct::DATE), 2, '0');

		IF (cDia = '25' AND cMes = '12') OR (cDia = '01' AND cMes = '01')   THEN
             UPDATE {+AVOID_FULL("informix".sac_fechas)} bdisac:sac_fechas -- Se crea índice para eliminar busqueda secuencial
                SET fecha_ant = fecha_hoy, fecha_hoy = prox_fecha, prox_fecha = prox_fecha + 1;
		END IF;

        IF cMes <> cMesAnt THEN
                EXECUTE PROCEDURE bdinteg:sp_diaprimeroultimomesanio(cMes, cAnio) INTO cCodRet, dPriDia_Mes, dUltDia_Mes;

                UPDATE {+AVOID_FULL("informix".sac_fechas)} bdisac:sac_fechas -- Se crea índice para eliminar busqueda secuencial
                SET pri_dia_mes = dPriDia_mes, ult_dia_mes = dUltDia_Mes;

                LET cFlag = "0";

                WHILE cFlag = "0"
                        -- validar si la fecha del primer dia del mes es feriado
                        SELECT "1"
                        INTO cEsFeriado
                        FROM bdinteg:si_feriado
                        WHERE fecha = dPriDia_mes;

                        IF cEsFeriado is null THEN
                                LET cEsFeriado = "0";
                        END IF;
                        IF cEsFeriado <> "1" and TO_CHAR(dPriDia_mes,"%A") <> "Saturday" and TO_CHAR(dPriDia_mes,"%A") <> "Sunday" THEN
                                -- salir
                                LET cFlag = "1";
                        ELSE
                                LET dPriDia_mes = dPriDia_mes + 1;
                        END IF;
                END WHILE;

                UPDATE {+AVOID_FULL("informix".sac_fechas)} bdisac:sac_fechas -- Se crea índice para eliminar busqueda secuencial
                SET pri_hab_mes = dPriDia_mes;

                LET cFlag = "0";

                WHILE cFlag = "0"
                       -- validar si la nueva fecha es feriado
                        SELECT "1"
                        INTO cEsFeriado
                        FROM bdinteg:si_feriado
                        WHERE fecha = dUltDia_Mes;

                        IF cEsFeriado is null THEN
                                LET cEsFeriado = "0";
                        END IF;
                        IF cEsFeriado <> "1" and TO_CHAR(dUltDia_Mes,"%A") <> "Saturday" and TO_CHAR(dUltDia_Mes,"%A") <> "Sunday" THEN
                                -- salir
                                LET cFlag = "1";
                        ELSE
                                LET dUltDia_Mes = dUltDia_Mes - 1;
                        END IF;
                END WHILE;
                UPDATE {+AVOID_FULL("informix".sac_fechas)} bdisac:sac_fechas -- Se crea índice para eliminar busqueda secuencial
                SET ult_hab_mes = dUltDia_Mes;
        END IF;
--	2013.11.01 FRG i
	UPDATE {+AVOID_FULL("informix".sac_fechas)} bdisac:sac_fechas -- Se crea índice para eliminar busqueda secuencial
        SET ind_cierre = '1';
--	2013.11.01 FRG f		
        RETURN cCodRet;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Hector Bojorquez',
'DESCRIPCION: Se encarga de actualizar las fechas del Sistema de Administracion de COnvenios al final del dia',
'EJECUTADO O LLAMADO POR:',
'sp_ProcesoCierreDiarioSAC()',
'FECHA : Octubre de 2008',
'VERSION: 20081022',
'AUTOR : FRG',
'DESCRIPCION: Se agrega actualización de campo ind_cierre en sac_fechas por Proy. Indep. Sistemas',
'EJECUTADO O LLAMADO POR: bdisac: sp_procesocierresac',
'Ejecutor de Procesos de Central',
'FECHA : Nov. 2013',
'VERSION: 20131101',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_consultadatoswu(pFolioSuc CHAR(16), pNumCta CHAR(11))

RETURNING
CHAR(5)  AS CodRet,
CHAR(48) AS NomTitCta,
CHAR(48) AS Beneficiario,
CHAR(48) AS Remitente,
CHAR(24) AS Identificacion,
CHAR(1)	 AS FormaPago,
CHAR(10) AS Referencia;

DEFINE cCodRet 			CHAR(5);
DEFINE iSqlErr 			INTEGER;
DEFINE cNomTitCta1 		CHAR(26);
DEFINE cNomTitCta2 		CHAR(26);
DEFINE cApTitCta 		CHAR(26);
DEFINE cAmTitCta 		CHAR(26);
DEFINE cNomBenef1 		CHAR(20);
DEFINE cNomBenef2 		CHAR(20);
DEFINE cApBenef	  		CHAR(20);
DEFINE cAmBenef 		CHAR(20);
DEFINE cNomRemitente1 	CHAR(20);
DEFINE cNomRemitente2 	CHAR(20);
DEFINE cApRemitente 	CHAR(20);
DEFINE cAmRemitente 	CHAR(20);
DEFINE cIdentificacion 	CHAR(30);
DEFINE cNombreTitular 	CHAR(48);
DEFINE cNombreBeneficiario CHAR(40);
DEFINE cNombreRemitente CHAR(40);
DEFINE cFormaPago		CHAR(1);
DEFINE cReferencia		CHAR(11);
DEFINE cMoneyTransferKey CHAR(10);
DEFINE cNumberIdenti	CHAR(20);
DEFINE cIdBenef			CHAR(1);
DEFINE cDescIdenti		CHAR(3);

	-- SET DEBUG FILE TO '/informix/tmp/sp_consultadatoswu.out';
	-- TRACE ON;	

LET cCodRet				='00000';
LET iSqlErr				=0;
LET cNomTitCta1			='';
LET cNomTitCta2			='';
LET cApTitCta 			='';
LET cAmTitCta			='';
LET cNomBenef1			='';
LET cNomBenef2 			='';
LET cApBenef			='';
LET cAmBenef			='';
LET cNomRemitente1 		='';
LET cNomRemitente2		='';
LET cApRemitente 		='';
LET cAmRemitente 		='';
LET cIdentificacion 	='';
LET cNombreTitular 		='';
LET cNombreBeneficiario	='';
LET cNombreRemitente 	='';
LET cFormaPago 			='';
LET cReferencia			='';
LET cMoneyTransferKey   ='';
LET cNumberIdenti		='';
LET cIdBenef 			='';
LET cDescIdenti			='';

BEGIN
	ON EXCEPTION SET iSqlErr

		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, '', '', '', '','','';
		END IF;

	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	

	IF (pFolioSuc IS NULL OR pFolioSuc = '')  THEN 
		LET cCodRet= '00001';		
	ELSE 	
		--Obtenemos el nombre del titular de la cuenta
		IF pNumCta <> '0' THEN 
			SELECT nombre1,nombre2,apell_paterno,apell_materno 
			INTO cNomTitCta1,cNomTitCta2,cApTitCta,cAmTitCta
			FROM bdicheq:"informix".sc_maechq  sc,
			bdinteg:"informix".si_cliente si
			WHERE sc.cuenta= pNumCta
			AND si.numcte = sc.num_cte
			AND sc.status_cta='1';
		END IF;
		--Verificamos que exista el folio_suc en la tabla WU
		IF EXISTS(SELECT referencia1 FROM bdisac:"informix".sac_movimientos WHERE folio_suc = pFolioSuc AND status_cancelado = "N"
				AND numcategoria = '07' AND numconvenio = '006'	) THEN 
			
			SELECT  NVL(forma_pago,''),NVL(referencia1,'')
			INTO cFormaPago, cReferencia
			FROM bdisac:"informix".sac_movimientos 
			WHERE folio_suc = pFolioSuc
			AND numcategoria = '07' 
			AND numconvenio = '006'
			AND status_cancelado = "N";			
		--Verificamos que exista el folio_suc en la tabla OV
		ELSE 
			IF EXISTS(SELECT referencia1 FROM bdisac:"informix".sac_movimientos WHERE folio_suc = pFolioSuc AND status_cancelado = "N"
				AND numcategoria = '07' AND numconvenio = '007') THEN 
			
				SELECT  NVL(forma_pago,''),NVL(referencia1,'')
				INTO cFormaPago, cReferencia
				FROM bdisac:"informix".sac_movimientos 
				WHERE folio_suc = pFolioSuc
				AND numcategoria = '07' 
				AND numconvenio = '007'
				AND status_cancelado = "N";
			ELSE 
				--Verificamos que exista el folio_suc en la tabla VG
				IF EXISTS(SELECT referencia1 FROM bdisac:"informix".sac_movimientos WHERE folio_suc = pFolioSuc AND status_cancelado = "N"
				AND numcategoria = '07' AND numconvenio = '008') THEN 
			
					SELECT  NVL(forma_pago,''),NVL(referencia1,'')
					INTO cFormaPago, cReferencia
					FROM bdisac:"informix".sac_movimientos 
					WHERE folio_suc = pFolioSuc
					AND numcategoria = '07' 
					AND numconvenio = '008'
					AND status_cancelado = "N";	
				END IF ;	
			END IF;	
		END IF;
		
		IF cFormaPago = '' OR  cReferencia ='' THEN 
			LET cCodRet= '00002';
		ELSE
		
			IF EXISTS(SELECT mtcn FROM bdisac:"informix".sac_wu_pay 
					WHERE mtcn = cReferencia AND foreign_rs_refnum_rp = pFolioSuc 
--  2014.09.25 frg-i    Se agregan condiciones para un solo registro en la respuesta:
                          and txn_status = 'A' and retcode = '00000' and conf_pago = 'P'  
                          --and txn_status = 'A' and retcode = '00000'
--  2014.09.25 frg-f
                      )	THEN 
				--falta una condicion mas que nos indique que ya esta pagada la remesa 
				SELECT money_transfer_key 
				INTO cMoneyTransferKey
				FROM bdisac:"informix".sac_wu_pay
				WHERE mtcn = cReferencia
				AND foreign_rs_refnum_rp = pFolioSuc
--  2014.09.25 frg-i    Se agregan condiciones para un solo registro en la respuesta:
                and txn_status = 'A' and retcode = '00000';
--  2014.09.25 frg-f         
                
-- 2013.10.15 -I.				
/*
				IF EXISTS (SELECT mtcn FROM bdisac:"informix".sac_wu_search 
						WHERE mtcn = cReferencia AND money_transfer_key = cMoneyTransferKey) THEN 
					

  					SELECT p.benef_nombre1,p.benef_nombre2,p.benef_appaterno,p.benef_apmaterno,p.benef_id_number,
					s.emisor_nombre1,s.emisor_nombre2,s.emisor_appaterno,s.emisor_apmaterno,p.benef_id_type
					INTO cNomBenef1, cNomBenef2, cApBenef, cAmBenef,cNumberIdenti,
					cNomRemitente1, cNomRemitente2, cApRemitente, cAmRemitente,cIdBenef
					FROM bdisac:"informix".sac_wu_pay p,
					bdisac:"informix".sac_wu_search s
					WHERE p.mtcn = cReferencia
					AND s.mtcn = cReferencia
					AND s.money_transfer_key = cMoneyTransferKey
					AND p.foreign_rs_refnum_rq = pFolioSuc
					AND s.foreign_rs_refnum_rq = pFolioSuc
					AND p.conf_pago = 'P'
					AND p.txn_status = 'A'
					AND s.txn_status = 'A';
*/
					SELECT p.benef_nombre1,p.benef_nombre2,p.benef_appaterno,p.benef_apmaterno,p.benef_id_number,
					s.emisor_nombre1,s.emisor_nombre2,s.emisor_appaterno,s.emisor_apmaterno,p.benef_id_type
					INTO cNomBenef1, cNomBenef2, cApBenef, cAmBenef,cNumberIdenti,
					cNomRemitente1, cNomRemitente2, cApRemitente, cAmRemitente,cIdBenef
					FROM bdisac:"informix".sac_wu_pay p,
					bdisac:"informix".sac_wu_search s
					WHERE p.mtcn = cReferencia
					AND s.mtcn = cReferencia
					AND p.foreign_rs_refnum_rp = pFolioSuc
					--AND s.foreign_rs_refnum_rp = pFolioSuc
					AND replace(s.monto_total_destino,".","") = p.monto_destino
					AND p.conf_pago = 'P'
					AND p.txn_status = 'A'
					AND s.txn_status = 'A'
					AND s.fecha_insert = (select max(fecha_insert) from sac_wu_search where mtcn = cReferencia);

					SELECT id_type_cd 
					INTO cDescIdenti 
					FROM bdisac:"informix".sac_identificacion					
					WHERE id_type_wu = cIdBenef
					AND flg_wu = 1 ;
					
				--	ELSE 
					--	LET cCodRet= '00004';
				--	END IF;
-- 2013.10.15 -F.
			ELSE 
				LET cCodRet= '00003';
			END IF;	
				
				IF cNomTitCta2= '' THEN 
					LET cNombreTitular = TRIM(cNomTitCta1) ||' '|| TRIM(cApTitCta) ||' '|| TRIM(cAmTitCta);
				ELSE 
					LET cNombreTitular = TRIM(cNomTitCta1) ||' '|| TRIM(cNomTitCta2) ||' '|| TRIM(cApTitCta) ||' '|| TRIM(cAmTitCta);
				END IF;
				
				IF cNomRemitente2= '' THEN 
					LET cNombreRemitente = TRIM(cNomRemitente1) ||' '|| TRIM(cApRemitente) ||' '|| TRIM(cAmRemitente);
				ELSE 
					LET cNombreRemitente = TRIM(cNomRemitente1) ||' '|| TRIM(cNomRemitente2) ||' '|| TRIM(cApRemitente) ||' '|| TRIM(cAmRemitente);
				END IF;
				
				IF cNomBenef2= '' THEN 
					LET cNombreBeneficiario = TRIM(cNomBenef1) ||' '||  TRIM(cApBenef) ||' '|| TRIM(cAmBenef);
				ELSE 
					LET cNombreBeneficiario = TRIM(cNomBenef1) ||' '|| TRIM(cNomBenef2) ||' '|| TRIM(cApBenef) ||' '|| TRIM(cAmBenef);
				END IF;
				
				LET cIdentificacion = TRIM(cDescIdenti)||' '||TRIM(cNumberIdenti) ;
		END IF ;	
	END IF;
	RETURN cCodRet, cNombreTitular, cNombreBeneficiario, cNombreRemitente, cIdentificacion,cFormaPago,cReferencia;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION:Se crea sp para obtener los datos para la reimpresion de ticket para WU/OV/VG',
'AUTOR : Eduardo Lopez',
'FECHA : 18/07/2013',
'Ver.  : 20130718.1206',
'DESCRIPCION:Se modifica SP para poder reimprimir tickets de MTCNs Select',
'AUTOR : FRG',
'FECHA : 15/10/2013',
'Ver.  : 201301015.0000',
'DESCRIPCION:Se modifica SP para obtener sÃ³lo 1 registro en las consultas sac_wu_search y sac_wu_pay',
'AUTOR : FRG',
'FECHA : 25/09/2014',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_inicializatablasmovimientosdiarios()
RETURNING CHAR(5);
    DEFINE iSqlErr, iIsamErr  INTEGER;
    DEFINE cCodRet            CHAR(5);
    DEFINE cInfoErr           CHAR(100);
    DEFINE dFecha_hoy         DATE;

    LET cCodRet = '00000';
	
	--SET DEBUG FILE TO "/informix/luisBeltran/BDISAC/sp_inicializatablasmovimientosdiarios.out";
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_InicializaTablasMovimientosDiarios");
                RETURN cCodRet;
            END IF;
        END EXCEPTION;
--se  cambia la consulta para evitar una busqueda--
     SELECT MIN(fecha_hoy) 
     INTO dFecha_hoy
     FROM bdisac:sac_fechas;




        DELETE{+AVOID_FULL("informix".sac_movimientos)} FROM bdisac:sac_movimientos WHERE fecha_pago = dFecha_hoy;
        DELETE {+AVOID_FULL("c92357113".sac_movimientosdetalle)}  FROM bdisac:sac_movimientosdetalle WHERE fecha = dFecha_hoy;
        UPDATE STATISTICS MEDIUM FOR TABLE bdisac:sac_movimientos;
        UPDATE STATISTICS MEDIUM FOR TABLE bdisac:sac_movimientosdetalle;
		UPDATE STATISTICS MEDIUM FOR TABLE sac_movimientoshistorial distributions ONLY;
		UPDATE STATISTICS MEDIUM FOR TABLE bdisac:sac_movimientoshistorial;
		--ABONOS OMNICANAL 
		DELETE {+AVOID_FULL("informix".sac_movimientos_detalle_td)}  FROM bdisac:sac_movimientos_detalle_td WHERE fecha_abono = dFecha_hoy;
		UPDATE STATISTICS MEDIUM FOR TABLE bdisac:sac_movimientos_detalle_td;
        RETURN cCodRet;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Jos?ngel L?? Adams',
'DESCRIPCION: Se encarga de limpiar las tablas de movimientos diarios',
'EJECUTADO O LLAMADO POR:',
'sp_CierreSACl()',
'FECHA : Septiembre de 2008',
'VERSION: 20080930',
'BD    : bdisac',
'==========================================================================',
'AUTOR : Luis Alberto Beltran Rodriguez',
'DESCRIPCION: Genera el archivo de cobranza Coppel de acuerdo a Layout proporcionado por carteras y los nuevos servicios omnicanales',
'EJECUTADO O LLAMADO POR:',
'sp_procesocierresac(''Empresa'')',
'FECHA : Marzo de 2022',
'VERSION: 202203',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_reverso_remesas_cpl
(
	pempresa  	CHAR(3),
	psucursal 	CHAR(4),
	pusuario  	CHAR(8),
	pfolio    	CHAR(16)
)
RETURNING
CHAR(5)     AS CodErr,
CHAR(2)     AS IdentificadorProceso,
CHAR(80) 	AS descripcion;

	-- Definicion de variables --
	DEFINE cCodErr 						CHAR(5);
	DEFINE cIdentificadorProceso 		CHAR(2);
	DEFINE cDescripcion					CHAR(80);
	DEFINE iSqlErr                     	INTEGER;
	DEFINE vtransaccion					SMALLINT;
	DEFINE cont_exist					INTEGER;

	-- Inicializacion de variables --
	LET cCodErr 					= '00000';
	LET cIdentificadorProceso 		= '00';
	LET cDescripcion 				= '';
	LET	cont_exist					= 0;
	LET pempresa = NVL(pempresa,'');
	LET pSucursal = NVL(pSucursal,'');
	LET pusuario = NVL(pusuario,'');
	LET pfolio = NVL(pfolio,'');
	LET vtransaccion = 0;

	--SET DEBUG FILE TO "/informix/BDHS/homologacionCPL/logs/sp_reverso_remesas_cpl.log";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
            IF iSqlErr <> 0 THEN
				LET cCodErr = iSqlErr;
				RETURN cCodErr, cIdentificadorProceso, cDescripcion;
			END IF;
        END EXCEPTION;

		ON EXCEPTION IN (-535)
			let vtransaccion = 1;
		END EXCEPTION WITH resume;
		IF vtransaccion = 1 THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			BEGIN WORK;
		END IF;

		--Validar que los parametros de entrada no vengan vacios o nulos
		IF pempresa = '' OR  psucursal = '' OR pusuario = '' OR pfolio = '' THEN
			LET cCodErr = '00001';
			LET cIdentificadorProceso = '01';
		END IF;

		IF cCodErr = '00000' THEN

			SELECT COUNT (referencia1)
            INTO cont_exist
            FROM bdisac:sac_movimientos
            WHERE folio_suc = pfolio
            AND status_cancelado <> 'S';

			IF cont_exist > 0 THEN

				UPDATE {+INDEX (bdisac:sac_movimientos idxsac_mov114)} bdisac:sac_movimientos
				SET status_cancelado = 'S'
				WHERE folio_suc = pfolio;

				UPDATE bdisac:sac_remesas_estadistica
				SET    status_cancelado = 'S'
				WHERE  folio_suc = pfolio;

			ELSE
				LET cCodErr = '00002';
				LET cIdentificadorProceso = '02';
			END IF;



		END IF;
    RETURN cCodErr, cIdentificadorProceso, cDescripcion;
END
END PROCEDURE
DOCUMENT
'FOLIO.........: HOMOLOGACION COPPEL',
'AUTOR.........: Bryan Daniel Hernandez Santos - Abraham Gonzalez PeÃ±a',
'FECHA.........: 02/11/2023',
'MODIFICACION..: Procedimiento para reversar remesas desde cajas de abono coppel',
'SUSTENTO......: ',
'SOLICITA......: EDGAR NAVARRO',
'BD............: BDISAC';

CREATE PROCEDURE "informix".sp_sac_pldlim_teldom_cpl(
	pTipo_remesa 		VARCHAR(3),
	pDireccion 			VARCHAR(200),
	pMunicipio 			VARCHAR(100),
	pEstado 			VARCHAR(30),
	pCodigo_postal 		VARCHAR(50),
	pPeriodo 			VARCHAR(6),
	pUsuario_insert 	VARCHAR(8),
	pTelefono 			VARCHAR(10),
	pCelular  			VARCHAR(10),
	pFolsuc    			VARCHAR (16),
	pSucursal  			VARCHAR (4),
	pRefUno    			VARCHAR (20),
	pOpcion	   			VARCHAR (10))

	--RETURNING CHAR(5), CHAR(80);
	RETURNING CHAR(5);

	--Definicion de Variables
	DEFINE cCodRet				CHAR(5);
    DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr 			INTEGER;
    DEFINE cInfoErr				CHAR(100);
	DEFINE cMensaje				CHAR(80);
	DEFINE cConteo 	  			INTEGER;
	DEFINE cConteo2 	 		INTEGER;
	DEFINE cValor 	  			INTEGER;
	DEFINE cValorD 	  			INTEGER;
	DEFINE cValorT 	  			INTEGER;
	DEFINE cFolio 	    		VARCHAR(16);
	DEFINE cValida				INTEGER;
	DEFINE cValidaBTST			INTEGER;
	DEFINE cValidaInsert        INTEGER;
	
	--SET DEBUG FILE TO '/informix/BDHS/homologacionCPL/logs/sp_sac_pldlim_teldom_cpl.log';
	--TRACE ON;

	-- Inicializa variables
	LET cCodRet            	= "00000";
	LET cMensaje			= 'PROCESO EXITOSO';
	LET cConteo 			= 0;
	LET cConteo2 			= 0;
	LET cValor 				= 0;
	LET cValorD				= 0;
	LET cValorT 			= 0;
	LET cValida 			= 0;
	LET cValidaInsert 		= 0;
	LET cValidaBTST 		= 0;


    BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			--Manejo de errores, en caso de error, envï¿½o codigo de error y guarda evidencia
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sac_pldlim_teldom");

				LET cMensaje = "ERROR EN LA EJECUCION DEL SP";
                RETURN cCodRet;
            END IF;
        END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

	IF pOpcion = 'NORMAL' THEN
		SELECT valor -- Obtiene el lÃ­mite de 32
			INTO cValorD
			FROM "informix".sac_param
			WHERE empresa = '001'
			AND cod_param = 130;

		SELECT valor -- Obtiene el lÃ­mite de 32
			INTO cValorT
			FROM "informix".sac_param
			WHERE empresa = '001'
			AND cod_param = 131;

		--INICIA Validacion de Direcciones.
		LET cValida 			= 0;

		SELECT conteo --Conteo de operaciones por domicilio
		INTO cConteo
		FROM "informix".sac_pldlimite_domicilios
		WHERE periodo = pPeriodo
			AND tipo_remesa = pTipo_remesa
			AND codigo_postal = pCodigo_postal
			AND direccion = pDireccion
			AND municipio = pMunicipio
			AND estado = pEstado;

		IF cConteo > 0  THEN

			IF cConteo >= cValorD THEN --Conteo mayor a limite permitido por domicilios
				LET cValida = 1;
			END IF;

		ELIF cConteo is null then --No encuentra registro en sac_pldlimite_domicilios, entonces inserta el primero
			LET cConteo = 1;

			INSERT INTO "informix".sac_pldlimite_domicilios (tipo_remesa,direccion,municipio,estado,codigo_postal,periodo,conteo,usuario_insert,fecha_insert)
				VALUES (pTipo_remesa,pDireccion,pMunicipio,pEstado,pCodigo_postal,pPeriodo,cConteo,pUsuario_insert,CURRENT);

			LET cValidaInsert = 1;

		END IF;

		/*INICIA Validacion de numeros telefonicos ingresados*/
		--SOLO APPRIZA--

		SELECT conteo
		INTO cConteo2
		FROM "informix".sac_pldlimite_telefonos
		WHERE periodo = pPeriodo
		AND tipo_remesa = pTipo_remesa
		AND telefono = pTelefono
		AND celular = pCelular;

		IF cConteo2 > 0  THEN

			IF pTipo_remesa = 'BTS' THEN
				IF pTelefono = '' AND pCelular = '' THEN
					LET cValidaBTST = 1;
				END IF;
			END IF;

			IF cValidaBTST = 0 THEN
				IF cConteo2 >= cValorT THEN
					IF cValida = 1 THEN
						LET cValida = 3;
					ELSE
						LET cValida = 2;
					END IF;
				END IF;
			END IF;

		ELIF cConteo2 IS NULL THEN
			LET cConteo2 = 1;

			INSERT INTO "informix".sac_pldlimite_telefonos (tipo_remesa,telefono,celular,periodo,conteo,usuario_insert,fecha_insert)
				VALUES (pTipo_remesa,pTelefono,pCelular,pPeriodo,cConteo2,pUsuario_insert,CURRENT);

			IF cValidaInsert = 0 THEN
				LET cValidaInsert = 2;
			ELIF cValidaInsert = 1 THEN
				LET cValidaInsert = 3;
			END IF;

		END IF;

		/*
		cValida =
			0 - Parametros de Domicilio y Telefono Validos
			1 - Domicilio Excede Limite
			2 - Telefonos Excede Limite
			3 - Domicilio y Telefono Excede Limites
		*/


		IF cValida = 1 THEN
			LET cCodRet            	= "00001";
			LET cMensaje			= 'Direccion Excede Limite';

			LET cConteo = cConteo + 1;
			UPDATE "informix".sac_pldlimite_domicilios SET conteo = cConteo
					WHERE periodo = pPeriodo
					AND tipo_remesa = pTipo_remesa
					AND codigo_postal = pCodigo_postal
					AND direccion = pDireccion
					AND municipio = pMunicipio
					AND estado = pEstado;

			INSERT INTO "informix".sac_pldlimite_teldom_rechazos (tipo_remesa,id_sucursal,direccion,municipio,estado,codigo_postal,periodo,conteodom,limitedom,telefono,celular,conteotel,limitetel,tiporechazo,motivorechazo,numremesa,folio_suc,usuario_insert,fecha_insert)
				VALUES (pTipo_remesa,pSucursal,pDireccion,pMunicipio,pEstado,pCodigo_postal,pPeriodo,cConteo,cValorD,pTelefono,pCelular,cConteo2,cValorT,cValida,'Direccion Excede Limite',pRefUno,pFolsuc,pUsuario_insert,current);

		ELIF cValida = 2 THEN
			LET cCodRet            	= "00002";
			LET cMensaje			= 'Telefono Excede Limite';
			LET cConteo2 = cConteo2 + 1;
			UPDATE "informix".sac_pldlimite_telefonos SET conteo = cConteo2
					WHERE periodo = pPeriodo
					AND tipo_remesa = pTipo_remesa
					AND telefono = pTelefono
					AND celular = pCelular;

			INSERT INTO "informix".sac_pldlimite_teldom_rechazos (tipo_remesa,id_sucursal,direccion,municipio,estado,codigo_postal,periodo,conteodom,limitedom,telefono,celular,conteotel,limitetel,tiporechazo,motivorechazo,numremesa,folio_suc,usuario_insert,fecha_insert)
				VALUES (pTipo_remesa,pSucursal,pDireccion,pMunicipio,pEstado,pCodigo_postal,pPeriodo,cConteo,cValorD,pTelefono,pCelular,cConteo2,cValorT,cValida,'Telefono Excede Limite',pRefUno,pFolsuc,pUsuario_insert,current);

		ELIF cValida = 3 THEN
			LET cCodRet            	= "00003";
			LET cMensaje			= 'Direccion y Telefono Excede Limite';
			LET cConteo = cConteo + 1;
			LET cConteo2 = cConteo2 + 1;
			UPDATE "informix".sac_pldlimite_domicilios SET conteo = cConteo
					WHERE periodo = pPeriodo
					AND tipo_remesa = pTipo_remesa
					AND codigo_postal = pCodigo_postal
					AND direccion = pDireccion
					AND municipio = pMunicipio
					AND estado = pEstado;

			UPDATE "informix".sac_pldlimite_telefonos SET conteo = cConteo2
					WHERE periodo = pPeriodo
					AND tipo_remesa = pTipo_remesa
					AND telefono = pTelefono
					AND celular = pCelular;

			INSERT INTO "informix".sac_pldlimite_teldom_rechazos (tipo_remesa,id_sucursal,direccion,municipio,estado,codigo_postal,periodo,conteodom,limitedom,telefono,celular,conteotel,limitetel,tiporechazo,motivorechazo,numremesa,folio_suc,usuario_insert,fecha_insert)
				VALUES (pTipo_remesa,pSucursal,pDireccion,pMunicipio,pEstado,pCodigo_postal,pPeriodo,cConteo,cValorD,pTelefono,pCelular,cConteo2,cValorT,cValida,'Direccion y Telefono Exceden Limite',pRefUno,pFolsuc,pUsuario_insert,current);
		ELSE

			IF cValidaInsert = 0 THEN

				LET cConteo = cConteo + 1;
				LET cConteo2 = cConteo2 + 1;
				UPDATE "informix".sac_pldlimite_domicilios SET conteo = cConteo
						WHERE periodo = pPeriodo
						AND tipo_remesa = pTipo_remesa
						AND codigo_postal = pCodigo_postal
						AND direccion = pDireccion
						AND municipio = pMunicipio
						AND estado = pEstado;

				UPDATE "informix".sac_pldlimite_telefonos SET conteo = cConteo2
						WHERE periodo = pPeriodo
						AND tipo_remesa = pTipo_remesa
						AND telefono = pTelefono
						AND celular = pCelular;

			ELIF  cValidaInsert = 1 THEN
				LET cConteo2 = cConteo2 + 1;
				UPDATE "informix".sac_pldlimite_telefonos SET conteo = cConteo2
						WHERE periodo = pPeriodo
						AND tipo_remesa = pTipo_remesa
						AND telefono = pTelefono
						AND celular = pCelular;

			ELIF  cValidaInsert = 2 THEN
				LET cConteo = cConteo + 1;
					UPDATE "informix".sac_pldlimite_domicilios SET conteo = cConteo
						WHERE periodo = pPeriodo
						AND tipo_remesa = pTipo_remesa
						AND codigo_postal = pCodigo_postal
						AND direccion = pDireccion
						AND municipio = pMunicipio
						AND estado = pEstado;

			END IF;

		END IF;

		COMMIT WORK;
		BEGIN WORK;

	ELIF pOpcion = 'REVERSO' THEN

		SELECT conteo
		INTO cConteo
		FROM "informix".sac_pldlimite_domicilios
		WHERE periodo = pPeriodo
			AND tipo_remesa = pTipo_remesa
			AND codigo_postal = pCodigo_postal
			AND direccion = pDireccion
			AND municipio = pMunicipio
			AND estado = pEstado;

		SELECT conteo
			INTO cConteo2
			FROM "informix".sac_pldlimite_telefonos
			WHERE periodo = pPeriodo
			AND tipo_remesa = pTipo_remesa
			AND telefono = pTelefono
			AND celular = pCelular;

		LET cConteo = cConteo - 1;
		LET cConteo2 = cConteo2 - 1;

		UPDATE "informix".sac_pldlimite_domicilios SET conteo = cConteo
				WHERE periodo = pPeriodo
				AND tipo_remesa = pTipo_remesa
				AND codigo_postal = pCodigo_postal
				AND direccion = pDireccion
				AND municipio = pMunicipio
				AND estado = pEstado;

		UPDATE "informix".sac_pldlimite_telefonos SET conteo = cConteo2
				WHERE periodo = pPeriodo
				AND tipo_remesa = pTipo_remesa
				AND telefono = pTelefono
				AND celular = pCelular;


		COMMIT WORK;
		BEGIN WORK;
	END IF;

		RETURN cCodRet;

    END;
END PROCEDURE;