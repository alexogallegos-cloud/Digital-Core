CREATE PROCEDURE "informix".sp_tdcaplazos(pEmpresa CHAR(3),pTipoProceso CHAR(1), pNumCte CHAR(20), pNumTarjetaAct CHAR(20))
	RETURNING   CHAR(6)  AS codigo_retorno,	---cod_ret
				CHAR(20) AS	numCte_ref	; ---Número de referencia del cliente

	-- declara variables 
    DEFINE v_cod_ret            CHAR(6);
	DEFINE cFechaSistema 		DATE;
	DEFINE iSqlErr				INTEGER;
	DEFINE v_numcte_ref 		CHAR(20);
	DEFINE cNumTarCoppelaplazos CHAR(16);
	DEFINE numSolicitud 		CHAR(20);
	DEFINE numCredito	 		CHAR(20);
	DEFINE sNumCteCoppel		CHAR(20);
	DEFINE sSucursal			CHAR(4);
	
	
	-- inicia variables 
	LET v_cod_ret = '000000';
	--LET cFechaSistema = DATE(1);
	LET iSqlErr = 0;
	LET v_numcte_ref = "";
	LET cNumTarCoppelaplazos = "";
	LET numSolicitud = "";
	LET numCredito = "";
	LET sNumCteCoppel = "";
	LET sSucursal = "";

	SET ISOLATION TO DIRTY READ;

	BEGIN
	
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
					LET v_cod_ret = iSqlErr;
			END IF;
			RETURN v_cod_ret,v_numcte_ref;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/informix/JesusR/Sp_tdcaplazos.out";
		--TRACE ON;	
		
		-- SE OBTIENE FECHA HOY
		SELECT fecha_hoy INTO cFechaSistema FROM bdinteg:"informix".si_fechas WHERE empresa =pEmpresa;
		
		IF pEmpresa = '' OR pTipoProceso = '' OR  pNumCte = '' OR (pTipoProceso != '3' AND pNumTarjetaAct = '') THEN
			
			LET v_cod_ret = '000001';
			RETURN v_cod_ret,v_numcte_ref;
			
		END IF;
		
		--pTipoProceso 1 = REPOSICION Y ALTA DE TARJETA TDC A PLAZOS.
		--pTipoProceso 2 = OBTENER REFERENCIA DEL CLIENTE.
		--pTipoProceso 3 = OBTENER REFERENCIA POR NUMERO DE CLIENTE.
		--pTipoProceso 4 = VALIDAR QUE EL CLIENTE TENGA UNA TDCOPPELAPLAZOS.
		IF pTipoProceso = '1' THEN
	
			IF EXISTS (select numcte_banco from bdinteg:"informix".si_relacion_ctebcplcpl where numcte_banco = pNumCte) THEN
			
				SELECT suc_asigna 
				INTO sSucursal 
				FROM bdicred:"informix".bitacora_activacion 
				WHERE empresa = pEmpresa AND numtarjeta = pNumTarjetaAct;
				
				update bdinteg:"informix".si_relacion_ctebcplcpl 
				set num_tar_coppelaplazos = pNumTarjetaAct,
				fecha_asigna_coppelapla = cFechaSistema,   
				sucursal_CoppelAPla = sSucursal,  
				envio_CoppelAPla = 0
				where empresa = pEmpresa
				AND numcte_banco = pNumCte;
				
				LET v_cod_ret = '000000';				
			
			ELSE			
				-- NO EXISTE CLIENTE
				LET v_cod_ret = '000002';
			
			END IF;
	
		ELIF  pTipoProceso = '2' THEN
		
			SELECT FIRST 1 numCte_ref
			INTO v_numcte_ref
			FROM bdinteg: "informix".si_refclientes 
			WHERE empresa = pEmpresa 
			AND numcte = pNumCte;
			
			LET v_cod_ret = '000000';

		ELIF  pTipoProceso = '3' THEN

			--BUSCAMOS EL NUMERO DE REFERENCIA DE si_refclientes
			IF EXISTS (SELECT numCte_ref FROM bdinteg:"informix".si_refclientes WHERE empresa = pEmpresa AND numcte = pNumCte AND numCte_ref != '') THEN
				
				SELECT FIRST 1 NVL(numCte_ref, '')
				INTO v_numcte_ref
				FROM bdinteg:"informix".si_refclientes 
				WHERE empresa = pEmpresa 
				AND numcte = pNumCte 
				AND numCte_ref != '';
			ELSE
			--BUSCAMOS EL NUMERO DE REFERENCIA DE ss_refpersonales
				SELECT FIRST 1 NVL(numCte_ref, '')
				INTO v_numcte_ref
				FROM  bdisolic:"informix".ss_refpersonales 
				WHERE empresa = pEmpresa 
				AND numcte = pNumCte 
				AND numCte_ref != '' 
				AND numCte_ref NOT IN('R1', 'R2');
			END IF;

			LET v_cod_ret = '000000';
			
		ELIF  pTipoProceso = '4' THEN
			SELECT num_tar_coppelaplazos 
			INTO  cNumTarCoppelaplazos
			FROM  bdinteg:"informix".si_relacion_ctebcplcpl 
			WHERE empresa = pEmpresa
			AND numcte_banco = pNumCte;
			
			IF Trim(cNumTarCoppelaplazos) <> "0" THEN
				LET v_cod_ret = '000002';
			END IF;
			
				
		-- ELIF  pTipoProceso = '5' THEN
			-- SELECT LIMIT 1 num_solicitud
			-- INTO numSolicitud
			-- FROM bdisolic: "informix".ss_solicitudes
			-- WHERE numcte = pNumCte AND num_producto= '6500';
			
			
			-- IF TRIM(numSolicitud) <> "" THEN
				-- select num_credito 
				-- INTO numCredito
				-- FROM bdicred:"informix".sd_maecred 
				-- WHERE num_credito = numSolicitud;
				
				-- IF TRIM(numCredito) IS NULL THEN
				
					-- INSERT INTO bdicred:"informix".sd_maecred
						   -- (EMPRESA                ,NUM_CREDITO
						   -- ,NUM_PRODUCTO           ,EJECUTIVO
						   -- ,NUMCTE                 ,DIVISA
						   -- ,SUCURSAL               ,ID_ORIGEN
						   -- ,ORIGEN                 ,COD_TIPO_LINEA
						   -- ,COD_LINEA              ,PORC_REC_PROP
						   -- ,STATUS_CRED            ,BANDERA_RENOVAC
						   -- ,BANDERA_PRORROGA       ,PERIODO_PLAZO
						   -- ,PLAZO                  ,FECHA_APERTURA
						   -- ,FECHA_VENCIM           ,PERIOD_PAGO_CAP
						   -- ,PERIOD_PAG_INT         ,DIAS_TRASP_CAP
						   -- ,DIAS_TRASP_INT         ,TASA_FIJA_O_VAR
						   -- ,COD_TASA_BASE          ,FACTOR_SOBRETASA
						   -- ,SOBRETASA              ,TASA_INTERES
						   -- ,COD_TASA_MORA          ,SOBRETASA_MORA
						   -- ,FACT_SOBRET_MORA       ,TASA_MORATORIOS
						   -- ,FECHA_PAGO_CAP         ,FECHA_PAGO_INT
						   -- ,ES_FISICA              ,BANDERA_FI_FO
						   -- ,CODIGO_PRO             ,SUPERFICIE
						   -- ,ACTIVIDAD              ,CAL_EDOS_FIN
						   -- ,TIPO_CALCULO           ,ADMITE_TLP
						   -- ,REL_GARCRED            ,ID_UNIDAD_PROD
						   -- ,NUM_APER_ANT           ,REV_TASA_VAR_PER
						   -- ,DIA_PARA_REVISAR       ,COD_PROD
						   -- ,BANDERA_MINISTRA       ,NUM_FIDEICOMISO
						   -- ,CREDITO_EXTERNO        ,GRACIA_CAPITAL
						   -- ,DIFERIMIENTO_INT       ,FECHA_FIN_PRORRATEO
						   -- ,CAMPO_TRAB1            ,CAMPO_TRAB2
						   -- ,CAMPO_TRAB3            ,CAMPO_TRAB4
						   -- ,CALIFICACION_RIESGO    ,COD_AGRICOLA
						   -- ,TASA_BASE_PISO         ,SOBRETASA_PISO
						   -- ,FACTOR_PISO            ,TASA_PISO
						   -- ,TASA_BASE_TECHO        ,SOBRETASA_TECHO
						   -- ,FACTOR_TECHO           ,TASA_TECHO
						   -- )
					 -- SELECT SOL.EMPRESA                ,numSolicitud
						   -- ,SOL.NUM_PRODUCTO           ,USER
						   -- ,pNumCte          ,'01'
						   -- ,SOL.SUCURSAL               ,''
						   -- ,''                         ,''
						   -- ,''              ,0
						   -- ,'AA'                       ,'N'
						   -- ,'N'                        ,SOL.PERIODO_PLAZO
						   -- ,1                 ,CURRENT
						   -- ,CURRENT               ,1
						   -- ,1        ,0
						   -- ,0          ,1
						   -- ,1          ,SOL.FACTOR_SOBRETASA
						   -- ,1              ,1
						   -- ,SOL.COD_TASA_MORA          ,SOL.SOBRETASA_MORA
						   -- ,SOL.FACT_SOBRET_MORA       ,1
						   -- ,''                         ,''
						   -- ,TIP.ES_FISICA              ,''
						   -- ,DEF.COD_PROD               ,0
						   -- ,''             				,''
						   -- ,2				           ,''
						   -- ,0                          ,''
						   -- ,''                         ,SOL.REV_TASA_VAR_PER
						   -- ,SOL.DIA_PARA_REVISAR       ,''
						   -- ,'P'                        ,''
						   -- ,''                         ,SOL.GRACIA_CAP
						   -- ,SOL.DIFERIMIENTO_INT       ,CURRENT
						   -- ,0                          ,0
						   -- ,''                         ,''
						   -- ,'A'                        ,''
						   -- ,SOL.TASA_BASE_PISO         ,SOL.SOBRETASA_PISO
						   -- ,SOL.FACTOR_PISO            ,SOL.TASA_PISO
						   -- ,SOL.TASA_BASE_TECHO        ,0
						   -- ,SOL.FACTOR_TECHO           ,0
					 -- FROM   BDISOLIC:"informix".SS_SOLICITUDES SOL
						  -- , BDINTEG:"informix".SI_CLIENTE      CLI
						  -- , BDINTEG:"informix".SI_TIPPER       TIP
						  -- , BDICRED: "informix".SD_DEFINICION           DEF
					 -- WHERE  DEF.EMPRESA         = SOL.EMPRESA
					 -- AND    DEF.NUM_PRODUCTO    = SOL.NUM_PRODUCTO
					 -- AND    TIP.TPO_PERSONA     = CLI.TPO_PERSONA
					 -- AND    CLI.NUMCTE          = SOL.NUMCTE
					 -- AND    CLI.EMPRESA         = SOL.EMPRESA
					 -- AND    SOL.NUM_SOLICITUD   = numSolicitud
					 -- AND    SOL.EMPRESA         = pEmpresa;
					 
				-- END IF;			
			-- END IF;
			
		ELIF  pTipoProceso = '6' THEN
			SELECT cliente 
			INTO sNumCteCoppel
			FROM bdinteg: "informix".si_relacion_ctebcplcpl 
			WHERE numcte_banco = pNumCte;
			LET v_numcte_ref = sNumCteCoppel;
			
			IF TRIM(sNumCteCoppel) = "" THEN
				LET v_cod_ret = '000004';
			END IF;
			
		ELSE
			-- NO SE RECIBE PARAMETRO pTipoProceso VALIDO
			LET v_cod_ret = '000003';
		
		END IF;
	   
		RETURN NVL(v_cod_ret,0),NVL(v_numcte_ref,0);
	END;
END PROCEDURE
DOCUMENT
'MODIFICACION: 99805011 - Efrain Miranda Miranda',
'Folio: ',
'RQM: TDC Coppel Plazos fijos ',
'Descripcion: El procedimiento se encarga de actualizar la tabla si_relacion_ctebcplcpl',
'Fecha: ',
'Solicito: Luis Gil',
'BD: BDINTEG',

'MODIFICACION: 99805029 - Jesús Javier Sánchez Guerrero',
'Folio: ',
'RQM: TDC Coppel Plazos fijos ',
'Descripcion: Se actualiza procedimiento para obtener el numero de referencia del cliente',
'Fecha: 19/01/2022',
'BD: BDINTEG',

'MODIFICACION: 94206041 - Jesús Rosario López Castro',
'Folio: ',
'RQM: TDC Coppel Plazos fijos ',
'Descripcion: Validar que el cliente tenga TDCoppelAPlazos',
'Solicito: Luis Gil',
'Fecha: 07/03/2022',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_ctehuella_prue(pempresa CHAR(3),
                                         psucursal CHAR(4),
                                         pejecutivo CHAR(8),
                                         pautoriza CHAR(8),
                                         pfecha_alta date,
                                         pfuncion CHAR(1),
                                         pnumcte CHAR(20),
                                         pmapad char(942),
                                         pmapai char(942)) 
										 
  RETURNING CHAR(5),smallint;

define vcodret CHAR(5);
define vsigsec smallint;
define vexiste CHAR(1);
define vtp_persona CHAR(2);
define vsqlerr INTEGER;
define visamerr INTEGER;
define vesfisica CHAR(1);



LET vcodret = "000";
LET vsigsec = 0;
LET vexiste = 0;
LET vtp_persona = "";

--SET DEBUG FILE TO '/informix/logspssql/sp_ctehuellaconcambio.sql';
--TRACE ON;


BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vsigsec;
   END IF;
END EXCEPTION;

--- Verifica recepcion correcta de datos
IF pnumcte IS NULL OR Trim(pnumcte) = ""
   OR pmapad IS NULL OR pmapad = ""
   OR pmapai IS NULL OR pmapai = "" then
   LET vcodret = "110";
   RETURN vcodret,vsigsec;
END IF;

SELECT tpo_persona INTO vtp_persona
FROM   si_cliente
WHERE  numcte = pnumcte;

SELECT es_fisica INTO vesfisica
   FROM si_tipper
   WHERE tpo_persona = vtp_persona;
IF UPPER(vesfisica) != "S" THEN
   LET vcodret = "120";
   RETURN vcodret,vsigsec;
END IF;

SELECT 1 INTO vexiste
   FROM si_sucursales
   WHERE sucursal=psucursal;
IF vexiste IS NULL THEN
   LET vcodret="111";
   RETURN vcodret,vsigsec;
END IF;

SELECT 1 INTO vexiste
   FROM si_ejecut
   WHERE ejecutivo=pejecutivo;
IF vexiste IS NULL THEN
   LET vcodret="112";
   RETURN vcodret,vsigsec;
END IF;
if Trim(pautoriza) <> "" then
   SELECT 1 INTO vexiste
     FROM si_ejecut
    WHERE ejecutivo=pautoriza;
   IF vexiste IS NULL THEN
      LET vcodret="112";
      RETURN vcodret,vsigsec;
   END IF;
END IF;

IF pfuncion != "A" and pfuncion != "C" THEN
   let vcodret = "130";
   RETURN vcodret,vsigsec;
END IF
-- ****************** Actualizacion de Parametros *****************
IF pfuncion="A" THEN
   SELECT 1 INTO vexiste FROM si_cte_huella
    WHERE numcte = pnumcte
      AND estado ="A";
   IF vexiste = "1" THEN
      let vcodret = "131";
      RETURN vcodret,vsigsec;
   END IF

   /*SELECT 1 INTO vexiste FROM si_cte_huella
    WHERE numcte = pnumcte; CIB20220428: se comentÃ³ el select debido a que retornaba dos datos*/
	
	SELECT LIMIT 1 1 INTO vexiste FROM si_cte_huella
    WHERE numcte = pnumcte; -- CIB20220428: se agregÃ³ LIMIT 1 esto para limitar el retorno de datos a solo 1  */

   IF vexiste = "1" THEN
      select max(secuencia) + 1 INTO vsigsec
      from   si_cte_huella
      where  numcte = pnumcte;
      /*RETURN vcodret,vsigsec; CIB20220428: se comentÃ³ el return debido a que terminaba el proceso sin agregar los datos en la tabla*/
   ELSE
      LET vsigsec = 1;
   END IF;
   BEGIN
      INSERT INTO si_cte_huella
        (numcte,secuencia,estado,dmapa,imapa,usuario,sucursal,fecha_alta,fech_ult_camb)
      VALUES
         (pnumcte,vsigsec,"A",pmapad,pmapai,pejecutivo,psucursal,pfecha_alta,CURRENT);
   END;
   RETURN vcodret,vsigsec;
ELIF pfuncion = "C" then
     BEGIN
        UPDATE si_cte_huella SET estado = "I",usuario_camb = pautoriza,
               fecha_camb = pfecha_alta,
	       fech_ult_camb = CURRENT
        WHERE  numcte = pnumcte and estado = "A";
        -- Agrega la Nueva Huella
        select max(secuencia) + 1 INTO vsigsec
          from   si_cte_huella
         where  numcte = pnumcte;
         IF vsigsec is null  THEN
            let vsigsec = 1;
         END IF
         INSERT INTO si_cte_huella
           (numcte,secuencia,estado,dmapa,imapa,usuario,sucursal,fecha_alta,fech_ult_camb)
         VALUES
           (pnumcte,vsigsec,"A",pmapad,pmapai,pejecutivo,psucursal,pfecha_alta,CURRENT);
     END;
     RETURN vcodret,vsigsec;
END IF;

RETURN vcodret,vsigsec;
END;
END PROCEDURE
DOCUMENT
"Alta, de Huella de cliente persona fisica ",
"AutOR : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Mario Escobar",
"FECHA : 04/Enero/2007",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"-----------------------------------------------------",
"Autor: 90231110 - Rolando JosuÃ© UrÃ­as GarcÃ­a",
"Fecha: 28/04/2022 - CIB20220428",
"ModificaciÃ³n: Se modificÃ³ el SELECT 1 INTO vexiste FROM si_cte_huella WHERE numcte = pnumcte ya que cuando se ejecutaba retornaba el error 284",
"..............debido a que se retornaban 2 datos y en la validaciÃ³n de IF vexiste = '1' THEN select max(secuencia) + 1 INTO vsigsec from   si_cte_huella",
"..............where numcte = pnumcte RETURN vcodret,vsigsec ELSE LET vsigsec = 1; END IF; a pesar que ya estaba retornando bien, el return terminaba la ejecuciÃ³n",
"..............sin haber agregado los datos a la tabla por lo que se comentÃ³ el RETURN vcodret,vsigsec",
"Sustento: Se definio por correo electronico el dÃ­a miercoles 27 de abril por Jaime Gonzales Prado",
"Solicita: Jaime Gonzales Prado",
"Folio: 1997",
"Proyecto: INC-SPCTEHUELLA284YNOINSERTA",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_guardar_bitacora_rostro_prue(pEmpresa CHAR(3), pSucursal CHAR(4), pNumCliente CHAR(20), pPromotor CHAR(8), pFecha_insert DATETIME YEAR TO SECOND,pTiempo_inicio DATETIME HOUR TO FRACTION(3),pTiempo_fin DATETIME HOUR TO FRACTION(3), tipo_rostro CHAR(2), ptipo_proceso CHAR(1),pcodigo CHAR(6),pintentos INTEGER, ipMaquina CHAR(15))
RETURNING CHAR(5) AS CodigoRetorno;
		
-- *	DEFINICION DE VARIABLES		  
	DEFINE iSqlErr              INTEGER;
	DEFINE cCodRet            CHAR(5);
	
-- *	ASIGNACION DE VARIABLES
	LET	iSqlErr 		= 0;
	LET cCodRet 	= '00001';
	
-- *	CONTROL DE ERRORES
	BEGIN	
	ON EXCEPTION SET iSqlErr
	    IF iSqlErr <> 0 THEN
	        LET cCodRet = iSqlErr;
	        RETURN cCodRet;
	    END IF;
	END EXCEPTION;
	
--	SET DEBUG FILE TO '/home/JA/CoppelFace/sp_guardar_bitacora_rostro.out';
--	TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	LET pEmpresa 		= TRIM(pEmpresa);
	LET pSucursal 		= TRIM(pSucursal);
	LET pNumCliente 	= TRIM(pNumCliente);
	LET pPromotor 		= TRIM(pPromotor);
	LET tipo_rostro 	= TRIM(tipo_rostro);
	LET ptipo_proceso 	= TRIM(ptipo_proceso);
	LET ipMaquina 		= TRIM(ipMaquina);
	
	--VALIDAR PARAMETROS VACIOS O NULOS
	IF NVL(pEmpresa,'') = '' OR NVL(pSucursal,'') = '' OR NVL(pNumCliente,'') = '' OR NVL(pPromotor,'') = '' OR NVL(pFecha_insert,'') = ''
		OR NVL(pTiempo_inicio,'') = '' OR NVL(pTiempo_fin,'') = '' OR NVL(tipo_rostro,'') = '' OR NVL(ptipo_proceso,'') = ''  OR NVL(ipMaquina,'') = '' THEN
		LET cCodRet = '00002';
	ELSE

		INSERT INTO bdinteg:"informix".si_bitacora_rostro(empresa, sucursal, numcte, promotor, fecha_inserta, tiempo_inicio, tiempo_fin, tipo_rostro, tipo_proceso, codigo,hora_inicio_ms, hora_fin_ms, intentos, ip)
		VALUES(pEmpresa, pSucursal, pNumCliente, pPromotor, pFecha_insert, pTiempo_inicio, pTiempo_fin, tipo_rostro, ptipo_proceso, pcodigo,pTiempo_inicio, pTiempo_fin, pintentos, ipMaquina);
	
		LET cCodRet = '00000';
	END IF;
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'Folio.........: 1433-Reconocimiento_Facial',
'Autor.........: 94565457 - Jose Angel Gaxiola Gaxiola',
'Fecha.........: 20/06/2014',
'Descripcion...: Se crea procedimiento para guardar bitacora de tiempos de coppel face en la tabla "si_bitacora_rostro".',
'Solicita......: Daniel Zambada',
'BD............: bdinteg',
'Folio: 1680 - SoporteBiometricoFacial',
'------------------------------------------------------------------------------------------',
'Autor: 95142134 Mario Gallardo',
'Fecha: 27/11/2014',
'Modificació®º Se agrega Parâ®¥tro de entrada y se agregan nuevos campos para la tabla si_bitacora_rostro ',
'Sustento: RQI 23 008 Biometria Facial.pdf',
'Solicita: Rodolfo Gomez',
'------------------------------------------------------------------------------------------',
'Autor: 97915041 RocÃ­o Vidales',
'Fecha: 17/07/2017',
'ModificaciÃ³n: Se agrega Parametro de entrada Ip para insertarlo en la tabla si_bitacora_rostro',
'Sustento: RQI 271.1 - Solicitud de Ip en Bitacora',
'Solicita: Abraham  Narvaez Jacinto',
'------------------------------------------------------------------------------------------',
'Autor: 95281495-Ernesto Aguilera',
'Fecha: 10/10/2018',
'ModificaciÃ³n: Se agrega Parametro de entrada Ip para insertarlo en la tabla si_bitacora_rostro',
'Sustento: Actualmente este procedimeinto existe en produccion, cuando se libero se comento el insert',
'al campo ip, ya que la tabla no estaba lista con ese campo. Se solicita que ya empiece a guardar la ip',
'Solicita: Abraham  Narvaez Jacinto',
'------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_ctanvl2_generadocs_pba( pEmpresa CHAR(3) ) 
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER; 
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cDescErr     CHAR(50);
    DEFINE iAbierto     SMALLINT;
    DEFINE iContador1   INTEGER;
    DEFINE iContador2   INTEGER;
    DEFINE dtFechaHoy   DATE;
    DEFINE cCuenta      CHAR(20);
    DEFINE cNumCte      CHAR(20);
    DEFINE cCodRetPDF   CHAR(5);
    
    LET cCodRet1   = '000';
    LET cCodRet2   = '000';
    LET cCodRet3   = 'PROCESO FINALIZADO CORRECTAMENTE'; 
    LET iSqlErr	   = 0;
    LET iIsamErr   = 0;
    LET cDescErr   = '';
    LET iAbierto   = 0;    
    LET iContador1 = 0;
    LET iContador2 = 0;
    LET dtFechaHoy = '';
    LET cCuenta    = '';
    LET cNumCte    = '';
    LET cCodRetPDF = '';
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ctanvl2_generadocs_pba.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1   = iSqlErr;
            LET cCodRet2   = iIsamErr;
            LET cCodRet3   = cDescErr;
            LET cCuenta    = cCuenta;
            LET cNumCte    = cNumCte;
            LET cCodRetPDF = cCodRetPDF;
            IF iAbierto = 1 THEN
                ROLLBACK WORK;
                LET iAbierto = 0;
            END IF;
            RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;
        END IF;
    END EXCEPTION;
    
    SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ctanvl2_generadocs_pba.out";
    TRACE ON;
    
    SELECT fecha_hoy
      INTO dtFechaHoy
      FROM bdicheq:sc_fechas
     WHERE empresa = pEmpresa;
     
    FOREACH WITH HOLD
        SELECT mae.cuenta, mae.num_cte
          INTO cCuenta, cNumCte
          FROM bdicheq:sc_maechq mae,
               bdicheq:sc_maenoc noc
         WHERE mae.cuenta = noc.cuenta
           AND mae.producto = '2900'
           --- AND noc.fecha_alta = dtFechaHoy
           AND mae.cuenta IN('29000000004','29004742417')
        
        BEGIN WORK;
        LET iAbierto = 1;
        
        LET iContador1 = iContador1 + 1;
        
        EXECUTE PROCEDURE bdinteg:sp_ctanvl2_generapdf(cCuenta, cNumCte)
        INTO cCodRetPDF;
        
        IF cCodRetPDF = '000' THEN
            LET iContador2 = iContador2 + 1;
        END IF;
        
        COMMIT WORK;
        LET iAbierto = 0;
        
        LET cCuenta    = '';
        LET cNumCte    = '';
        LET cCodRetPDF = '';
    END FOREACH;
    
    END; 
    
    RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;
    
END PROCEDURE;