CREATE PROCEDURE "informix".sp_cat_consulta_disponibilidad_cliente(pEmpresa     CHAR(3),
                                                                   pNumCte      CHAR(20),
                                                                   pTipoCob     CHAR(1),
                                                                   pEjecutivo   CHAR(8))
RETURNING   CHAR(6)     AS cod_ret,
            SMALLINT    AS disponible,
            SMALLINT    AS motivo_rechazo;


-- Fecha: Noviembre 2011 - MAHR
-- Modificacion: Se modifica proceso para que tome en cuenta tambien el tipo de cobranza R
-- Fecha de Modificacion: Ene 2012 Se agrega el producto Credinomina al tipo de Cobranza R

-- Declaración de variables
DEFINE cCodRet              CHAR(6);
DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;

DEFINE iDisponible          SMALLINT;
DEFINE cMensajeRet          CHAR(80);
DEFINE cNumCredito          CHAR(20);
DEFINE cNumcliente          CHAR(20);
DEFINE cNomProd             CHAR(40);
DEFINE cNum_tarjeta         CHAR(20);
DEFINE cNomCliente          CHAR(150);
DEFINE dtFechaConvenio      DATE;
DEFINE dtFecha_venc         DATE;
DEFINE dImporte             DECIMAL(14,2);
DEFINE cOrigen              CHAR(3);
DEFINE cSituacion           CHAR(1);
DEFINE iCausa               SMALLINT;
DEFINE cInstruccion         CHAR(1);
DEFINE cStatus              CHAR(2);
DEFINE iExiste              SMALLINT;
DEFINE iMotivoRT            SMALLINT;
DEFINE vcodigo_resultado    SMALLINT;
DEFINE vlMontoFinanciado    DECIMAL(14,2);
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE vproceso				CHAR(30);
DEFINE vlFecha              DATE;
DEFINE vPagosVencidos       SMALLINT;
DEFINE vnumproducto         CHAR (4);
DEFINE vmonto_financiado    DEC(18,2);
DEFINE cMtoVen				DECIMAL(18,2);

-- Inicialización de variables
LET cCodRet                 = 0;
LET iSqlErr                 = 0;
LET iIsamErr                = 0;

LET iDisponible             = 1;
LET cMensajeRet             = "";
LET cNumCredito             = "";
LET cNumcliente             = "";
LET cNomProd                = "";
LET cNum_tarjeta            = "";
LET cNomCliente             = "";
LET dtFechaConvenio         = DATE(1);
LET dtFecha_venc            = DATE(1);
LET dImporte                = 0;
LET cOrigen                 = "";
LET cSituacion              = "";
LET iCausa                  = 0;
LET cInstruccion            = "";
LET cStatus                 = "";
LET iExiste                 = 0;
LET iMotivoRT               = 0;
LET vlMontoFinanciado       = 0;
LET error_info              = "";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0077';
LET vmonto_financiado       = 0;
LET vnumproducto 			= '';
LET cMtoVen				    = 0;


--SET DEBUG FILE TO "/informix/paulq/spls/sp_cat_consulta_disponibilidad_cliente.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, error_info
          LET cCodRet = iSqlErr;
		  LET cMensaje = error_info;
		  --CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vproceso, cCodret, cMensaje, '02');
       
          RETURN  cCodRet, iDisponible,iMotivoRT;
    END EXCEPTION;
	
   --CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vproceso, cCodret, cMensaje, '01');        
   SELECT COUNT(empresa)
     INTO iExiste
     FROM bdinteg:"informix".si_empresas
    WHERE empresa = pEmpresa;

    IF iExiste = 0 THEN
        LET cCodRet = "101001";
        RETURN  cCodRet, iDisponible,iMotivoRT;
    END IF;

    SELECT COUNT(numcte)
      INTO iExiste
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = pNumCte;

    IF iExiste = 0 THEN
        LET cCodRet = "101003";
        RETURN  cCodRet, iDisponible,iMotivoRT;
    END IF;

    select  max(fecha_insert) into vlFecha 
    from bdicobranza:cb_cat_directorio_cte 
     where tipo_cobranza = pTipoCob and  numcte=pNumCte;

    -- Obtiene el número de crédito del cliente
  SELECT limit 1  num_producto  INTO vnumproducto
    FROM bdicobranza:cb_cat_directorio_cte 
        WHERE empresa      = pempresa
        AND  tipo_cobranza = pTipoCob
        AND  numcte        = pNumCte
        AND fecha_insert  =  vlFecha;
	
	IF  NVL(vnumproducto,'') = ''  THEN
		LET vnumproducto = '6001';	
	END IF; 

  /*IF (pTipoCob IN ('R','E')) THEN
		select  limit 1 num_producto into vnumproducto
		  from bdicred:sd_maecredcrd 
		 where empresa = pempresa
           and num_credito = (select  num_credito 
		                        from bdicobranza:cb_cat_directorio_cte 
                               where tipo_cobranza = pTipoCob and  numcte=pNumCte AND fecha_insert  =  vlFecha);
	ELSE
	  select  limit 1 num_producto into vnumproducto
		  from bdicred:sd_maecred
		 where empresa = pempresa        
       and num_credito =  (select  num_credito from bdicobranza:cb_cat_directorio_cte 
                            where tipo_cobranza = pTipoCob and  numcte=pNumCte AND fecha_insert  =  vlFecha);
	
	END IF; --Fin para extraer el producto */

  FOREACH
    EXECUTE PROCEDURE bdicred:"informix".sp_consulta_datos_general(pEmpresa,
                                                          pNumCte,
                                                          "",
                                                          "",
                                                          "",
                                                          "",
                                                          vnumproducto)
                 INTO cCodRet, cMensajeRet,cNumCredito,cNumcliente,
                      cNomProd, cNum_tarjeta, cNomCliente
    IF cCodRet <> "000000" THEN
      LET cCodRet = "101007";  -- Error al consultar los datos general del cliente.
      RETURN  cCodRet, iDisponible,iMotivoRT;
    END IF;

   -- Validar si el cliente tiene compromisos activos
    IF (pTipoCob IN ('A', 'P')) THEN
        EXECUTE PROCEDURE bdicobranza:"informix".sp_compac_consultacompromisosvigente(pEmpresa,cNumCredito)
                     INTO cCodRet,cMensajeRet,dtFechaConvenio,dtFecha_venc,dImporte,cOrigen;  -- Unicamente con A y P llame al sp
    ELSE
        LET cCodRet = '00003';  -- Se forza a que entre a la sig condicion.
    END IF;

    IF TRIM(cCodRet) IN ("00003", "00005", "00004") THEN
      SELECT {+INDEX(bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} FIRST 1 situacion,  causa
                   INTO cSituacion, iCausa
                   FROM bdisitesp:"informix".se_ctessitespcte
                  WHERE numcte = pNumCte;

      SELECT {+INDEX(bdisitesp:se_situacionaccion idx_se_situacionaccion2)} FIRST 1 instruccion
                   INTO cInstruccion
                   FROM bdisitesp:"informix".se_situacionaccion
                  WHERE situacion= cSituacion
                    AND causa= iCausa
                    AND idaccion = 9;
      IF NVL(cInstruccion,"") <> "0" THEN
          -- Validar  si el crédito presenta saldo vencido 
					--valida si el credito se encuentra en maecred o maecredcrd para
					--tarjeta de credito o credito no revolventes.					
        LET cStatus = '';
		LET vPagosVencidos =-1;
			  select {+INDEX(bdicred:sd_maecred idx_idx_maecredb)} status_cred
				  INTO cStatus
				  from bdicred:"informix".sd_maecred
				 where empresa = pEmpresa and num_credito = cNumCredito;
		SELECT COUNT(num_credito)
          INTO vPagosVencidos
          FROM bdicred:"informix".sd_amortiza_credito
         WHERE empresa     = pEmpresa
           AND num_credito = cNumCredito
           AND capital_status IN ('2','7','6');

        SELECT monto_financiado,nvl(monto_vencido + mto_venc_trasp,0)
          INTO vmonto_financiado, cMtoVen
          FROM bdicred:"informix".sd_maesdos
         WHERE empresa     = pEmpresa
           AND num_credito = cNumCredito;
		  
        IF  ( pTipoCob IN ('R','E') )  then
			SELECT {+INDEX(bdicred:sd_maecredcrd idx_maecrd)} status_cred
            INTO cStatus
            FROM bdicred:"informix".sd_maecredcrd
		   WHERE num_credito = cNumCredito
             AND empresa = pEmpresa;			 
		  SELECT COUNT(num_credito)
            INTO vPagosVencidos
            FROM bdicred:"informix".sd_amortiza_creditocrd
           WHERE empresa     = pEmpresa
             AND num_credito = cNumCredito
             AND capital_status IN ('2','7','6');	
          SELECT monto_financiado, nvl(monto_vencido + mto_venc_trasp,0)
            INTO vmonto_financiado, cMtoVen
            FROM bdicred:"informix".sd_maesdoscrd
           WHERE empresa     = pEmpresa
             AND num_credito = cNumCredito;
        END IF;
        IF (vPagosVencidos >0 and vmonto_financiado > 100) THEN 
        --IF NVL(cStatus,"") IN ("BA", "BT", "VP")  THEN
          SELECT {+INDEX(cb_cat_directorio_cte idx_cat_directorio)} status_cliente, codigo_resultado
            INTO cStatus ,vcodigo_resultado
            FROM bdicobranza:"informix".cb_cat_directorio_cte a
           WHERE a.numcte        = pNumcte
             AND a.tipo_cobranza = pTipoCob
             AND a.fecha_insert  = (SELECT {+INDEX(cb_cat_directorio_cte idx_cat_directorio)} MAX(fecha_insert)
                                                FROM bdicobranza:"informix".cb_cat_directorio_cte b
                                               WHERE b.numcte        = a.numcte
                                                 AND b.tipo_cobranza = a.tipo_cobranza
                                                 AND b.fecha_insert  = b.fecha_insert
                                                 AND b.empresa       = a.empresa)
             AND a.empresa       = pEmpresa;
-- /**/
--          IF ((NVL(cStatus,"") IN ("AC", "LD")) OR ((NVL(cStatus,"") ='PR') AND ( nvl(vcodigo_resultado,0) in( 7,8,9,10,11,12,13,18 ) ) ) )  THEN
          IF ((NVL(cStatus,"") IN ("AC", "LD")) OR ((NVL(cStatus,"") ='PR') AND (nvl(vcodigo_resultado,0) != 1)))  THEN
             SELECT {+INDEX(cb_excepcion_cte idx_pk_excepcion_cte2)} COUNT(numcte)
               INTO iExiste
               FROM bdicobranza:"informix".cb_excepcion_cte
              WHERE empresa = pEmpresa
                AND numcte = pNumcte
                AND status_excepcion = "AC";
            IF iExiste = 0 THEN
              LET iDisponible = 0;
            ELSE
              LET iMotivoRT = 6;
            END IF;
          ELSE
            LET iMotivoRT = 5;
          END IF;				
        ELIF (vPagosVencidos >0 and vmonto_financiado <= 100) THEN
             LET iMotivoRT = 7;
        ELIF NVL(cStatus,"") = "CV" THEN -- Si es por venta de cartera
           LET iMotivoRT = 4;					
        ELIF ((( pTipoCob = "P" ) or (pTipoCob ="E" )) AND NVL(cStatus,"") IN ("AA",'E1') AND cMtoVen = 0) THEN -- Si es Preventiva Reestructura o TC
           IF  ( pTipoCob ="P" ) THEN --TC       
					    select  {+INDEX(bdicred:sd_maesdos idx_sd_maesdos)} monto_financiado  INTO vlMontoFinanciado
                from bdicred:"informix".sd_maesdos 
               where empresa = pEmpresa 
                 and num_credito = cNumCredito;
				IF vlMontoFinanciado >0 THEN 
                 LET iMotivoRT = 0;
                 LET iDisponible = 0;
              ELSE
                 LET iMotivoRT = 2;  
              END IF;
           ELSE --Reestructura                  
				select   monto_financiado  INTO vlMontoFinanciado
                 from bdicred:"informix".sd_maesdoscrd
                where empresa = pEmpresa 
                  and num_credito = cNumCredito;					
               IF vlMontoFinanciado >0 THEN 
                  LET iMotivoRT = 0;
                  LET iDisponible = 0;
               ELSE
                 LET iMotivoRT = 2;  
               END IF;
           END IF;
        ELIF ((( pTipoCob ="R" ) or (pTipoCob ="A" )) AND NVL(cStatus,"") IN ("AA",'E1') AND cMtoVen = 0) THEN
          LET iMotivoRT = 2;
        END IF;        
      ELSE
         LET iMotivoRT = 3;
      END IF;		   	   
    ELSE
			LET iMotivoRT = 1;
	END IF;  
  
    IF iDisponible = "0" THEN
      LET cCodRet = "000000";
	  -- Marca registro de cliente actualizandose en cb_cat_directorio_cte
	  UPDATE bdicobranza:"informix". cb_cat_directorio_cte
        SET cobranza_aux_direct = '1'
        WHERE empresa       = pempresa
        AND tipo_cobranza   = pTipoCob
        AND numcte          = pNumCte
        AND fecha_insert    = vlFecha;  
    ELSE
      LET cCodRet = "101012"; -- no disponible
    END IF;
	  --CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vproceso, cCodret, cMensaje, '03');
    RETURN cCodRet, iDisponible,iMotivoRT WITH RESUME;
  END FOREACH;
END
--1	COMPROMISO DE PAGO                                                                                  
--2	YA ABONO                                                                                            
--3	SITUACION ESPECIAL                                                                                  
--4	VENTA DE CARTERA                                                                                    
--5	EL CLIENTE YA NO SE ENCUENTRA ACTIVO EN BANCOPPEL                                                   
--6	CLIENTE EXCEPTUADO POR COBRANZA  
END PROCEDURE  
DOCUMENT
"Descripción: Procedimiento que valida si un cliente se encuentra disponible para aplicarle una",
"cobranza telefónica",
"BD: bdicobranza",
"Autor: Viridiana Osobampo Aguilar",
"Fecha: 29-Sep-2010";

CREATE PROCEDURE "informix".sp_cat_evalua_ctes_cartera(pEmpresa CHAR(3), pTipoCobranza    CHAR(1))
       RETURNING char(6), char(80);

--declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(80);
DEFINE cMensaje 		            CHAR(80);
DEFINE cMensajeBitacora	            CHAR(150);
DEFINE cCod_ret                     CHAR(6);
DEFINE cproceso                     CHAR(30);
DEFINE vnumcte                      CHAR(20);
DEFINE vfecha_insert                DATE;
DEFINE vusuario                     CHAR(8);
DEFINE vsituacion                   CHAR(1);
DEFINE vcausa                       SMALLINT;
DEFINE vinstruccion                 CHAR(1);
DEFINE vstatus_cred                 CHAR(2);
DEFINE vMotivoEx                    SMALLINT;
DEFINE vstatus_cte                  CHAR(2);
DEFINE vNumCredito                  CHAR(20);
DEFINE vcod_ret                     CHAR(6);
DEFINE iExiste                      SMALLINT;
DEFINE vPagosVencidos				SMALLINT;
DEFINE vTipoCobranza       		    CHAR(1);
DEFINE dFecha_hoy                   DATE;
DEFINE vcall 						smallint;
DEFINE vmonto_financiado            DEC(18,2);
DEFINE dMinFechaInsert              DATE;
DEFINE cNumProducto					CHAR(04);
DEFINE sNumVuelta                   SMALLINT;
DEFINE dMontoFinanciado				DEC(18,2);
DEFINE cStatusCred					CHAR(02);
DEFINE sEnProcVenta					SMALLINT;
DEFINE sConConvenio					SMALLINT;
DEFINE sEnAclaracion				SMALLINT;
DEFINE sExcepcion					SMALLINT;
DEFINE iTipoMovto					INTEGER;
DEFINE dFechaHoy					DATE;
DEFINE dPriDiaMes					DATE;
DEFINE iCuentasProcesadas			INTEGER;
DEFINE iCuentasActualizadas			INTEGER;
DEFINE iCuentasExcluidas0			INTEGER;
DEFINE iCuentasExcluidas1			INTEGER;
DEFINE iCuentasExcluidas2			INTEGER;
DEFINE iCuentasExcluidas3			INTEGER;
DEFINE iCuentasExcluidas4			INTEGER;
DEFINE iCuentasExcluidas5			INTEGER;
DEFINE iCuentasExcluidas6			INTEGER;
DEFINE iCuentasExcluidas7			INTEGER;
DEFINE iCuentasExcluidas8			INTEGER;
DEFINE iCuentasSinExcluir			INTEGER;
DEFINE cMtoVen						DECIMAL(18,2);

------------------------------------------------------------

--SET DEBUG FILE TO 'sp_cat_evalua_ctes_cartera.out';
--TRACE ON;

LET cCod_ret        = '000000';
LET sql_err         = 0;
LET isam_err        = 0;
LET error_info      = '';
LET cMensaje        = 'PROCESO EXITOSO';
LET cMensajeBitacora	= '';
LET cproceso        = '0090';
LET vMotivoEx       = 0;
LET vusuario        = 'SYSCOBRA';            
LET vPagosVencidos	= 0;
LET vTipoCobranza	= '';
LET vcall 			= 0;
LET vmonto_financiado = 0;
LET dMinFechaInsert = DATE(1);
LET cNumProducto	= '';
LET sNumVuelta		= 0;
LET dMontoFinanciado	= 0;
LET cStatusCred		= '';
LET sEnProcVenta	= 0;
LET sConConvenio	= 0;
LET sEnAclaracion	= 0;
LET sExcepcion		= 0;
LET iTipoMovto		= 0;
LET dFechaHoy		= DATE(1);
LET dPriDiaMes		= DATE(1);
LET iCuentasProcesadas	 = 0;
LET iCuentasActualizadas = 0;
LET iCuentasExcluidas0	= 0;
LET iCuentasExcluidas1	= 0;
LET iCuentasExcluidas2	= 0;
LET iCuentasExcluidas3	= 0;
LET iCuentasExcluidas4	= 0;
LET iCuentasExcluidas5	= 0;
LET iCuentasExcluidas6	= 0;
LET iCuentasExcluidas7	= 0;
LET iCuentasExcluidas8	= 0;
LET iCuentasSinExcluir	= 0;
LET cMtoVen				= 0;



BEGIN

ON EXCEPTION SET sql_err, isam_err, error_info
	LET cCod_ret = sql_err;
	LET cMensaje = error_info;
            
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensaje, '02')
		RETURNING vCod_ret;       
	RETURN cCod_ret, cMensaje;
END EXCEPTION;

CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '01')
	RETURNING vCod_ret;

------------------------------------------------------------------------------------------------------------------
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
	
-- Obtiene la fecha de hoy
SELECT fecha_hoy, pri_dia_mes INTO dFechaHoy, dPriDiaMes FROM bdicred:sd_fechas WHERE empresa = pEmpresa;

-- Se excluyen cuentas para que no se gestionen
-- Consulta para tomar el tipo campaña 'A', 'E', 'R', 'P' para ser evaluadas
    FOREACH WITH HOLD
        SELECT valor_alfabetico INTO vTipoCobranza
        FROM bdicobranza:cb_param_campania WHERE empresa = pEmpresa AND tipo_campania = 1
        AND grupo_parametro = 'TIPOCOBCAT' AND num_parametro >= 5 AND num_parametro <= 12
        group by valor_alfabetico
		
		IF(vTipoCobranza = "E") OR (vTipoCobranza = "P") THEN
			CONTINUE FOREACH;
		END IF;
		
        SELECT min(fecha_insert) INTO dMinFechaInsert
        FROM bdicobranza:cb_cat_directorio_cte
        WHERE empresa = pEmpresa
        AND tipo_cobranza = vTipoCobranza  
        AND status_cliente in ('AC','PR');
		
		IF DAY(today) = 19 AND vTipoCobranza = 'A' THEN
			SELECT dct.numcte, dct.fecha_insert, dct.num_credito, dct.num_producto, dct.tipo_cobranza, dct.fecha_modificacion
			FROM bdicobranza:cb_cat_directorio_cte dct
			INNER JOIN bdicred:sd_definicion def ON def.empresa = dct.empresa AND def.num_producto = dct.num_producto
			WHERE dct.empresa = pEmpresa
			AND dct.tipo_cobranza = vTipoCobranza
			AND dct.fecha_insert >= dMinFechaInsert
			AND dct.fecha_insert <= today - 1
			AND dct.status_cliente in ('AC','PR')
			AND dct.num_producto NOT IN ('8100','8500')
			AND (dct.fecha_modificacion is null OR dct.fecha_modificacion < today)
			INTO TEMP directorio_cte WITH NO LOG;

		ELIF DAY(today) = 21 AND vTipoCobranza = 'A' THEN
			SELECT dct.numcte, dct.fecha_insert, dct.num_credito, dct.num_producto, dct.tipo_cobranza, dct.fecha_modificacion
			FROM bdicobranza:cb_cat_directorio_cte dct
			INNER JOIN bdicred:sd_definicion def ON def.empresa = dct.empresa AND def.num_producto = dct.num_producto
			WHERE dct.empresa = pEmpresa
			AND dct.tipo_cobranza = vTipoCobranza
			AND dct.fecha_insert >= dMinFechaInsert
			AND dct.fecha_insert <= today - 1
			AND dct.status_cliente in ('AC','PR')
			AND dct.num_producto NOT IN ('6001')
			AND (dct.fecha_modificacion is null OR dct.fecha_modificacion < today)
			INTO TEMP directorio_cte WITH NO LOG;

		ELSE

			SELECT dct.numcte, dct.fecha_insert, dct.num_credito, dct.num_producto, dct.tipo_cobranza, dct.fecha_modificacion
			FROM bdicobranza:cb_cat_directorio_cte dct
			INNER JOIN bdicred:sd_definicion def ON def.empresa = dct.empresa AND def.num_producto = dct.num_producto
			WHERE dct.empresa = pEmpresa
			AND dct.tipo_cobranza = vTipoCobranza
			AND dct.fecha_insert >= dMinFechaInsert
			AND dct.fecha_insert <= today - 1
			AND dct.status_cliente in ('AC','PR')
			AND (dct.fecha_modificacion is null OR dct.fecha_modificacion < today)
			INTO TEMP directorio_cte WITH NO LOG;

		END IF;
		
		CREATE INDEX idx_directorio_cte ON directorio_cte(tipo_cobranza);
		UPDATE statistics medium FOR TABLE directorio_cte;

		SELECT COUNT(*) INTO iCuentasProcesadas
		FROM directorio_cte WHERE tipo_cobranza = vTipoCobranza;

		LET cMensajeBitacora = 'INICIO procesamiento de excluidos TIPO COBRANZA : ' ||vTipoCobranza;
		LET cMensajeBitacora = TRIM(cMensajeBitacora) || '		TOTAL CUENTAS a procesar : ' ||iCuentasProcesadas;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, '000000', cMensajeBitacora,'02' ) RETURNING vCod_ret;
		
--		LET cMensajeBitacora = 'TOTAL EXCLUIDOS A PROCESAR : ' ||iCuentasProcesadas;
--		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, '000000', cMensajeBitacora,'02' ) RETURNING vCod_ret;

		LET iCuentasProcesadas = 0;
		

        FOREACH WITH HOLD
            SELECT numcte, fecha_insert, num_credito, num_producto INTO vnumcte, vfecha_insert, vNumCredito, cNumProducto
            FROM directorio_cte
            WHERE tipo_cobranza = vTipoCobranza
            
			LET vstatus_cte	= '';
            LET vMotivoEx	= 0;
			LET iCuentasProcesadas = iCuentasProcesadas + 1;

			IF vTipoCobranza IN ('A','P') THEN
				SELECT mae.status_cred, mas.monto_financiado, nvl(mas.monto_vencido + mas.mto_venc_trasp,0) INTO cStatusCred, dMontoFinanciado, cMtoVen
				FROM bdicred:sd_maecred mae
				INNER JOIN bdicred:sd_maesdos mas on mas.empresa = mae.empresa AND mas.num_credito = mae.num_credito
				WHERE mae.empresa = pEmpresa
				  AND mae.num_credito = vNumCredito;
			ELIF vTipoCobranza IN ('R','E') THEN
				SELECT mae.status_cred, mas.monto_financiado, nvl(mas.monto_vencido + mas.mto_venc_trasp,0) INTO cStatusCred, dMontoFinanciado, cMtoVen
				FROM bdicred:sd_maecredcrd mae
				INNER JOIN bdicred:sd_maesdoscrd mas on mas.num_credito = mae.num_credito
				WHERE mae.num_credito = vNumCredito;
			ELSE
				CONTINUE FOREACH;
			END IF;


			SELECT COUNT(*) INTO sExcepcion
			FROM bdicobranza:cb_excepcion_cte
			WHERE numcte = vnumcte;

			IF sExcepcion > 0 THEN	-- Las que pertenecen a directores y al grupo con línea mayores a 50,000
                LET vMotivoEx	= 6;
                LET vstatus_cte	= 'IN';
				LET iCuentasExcluidas6 = iCuentasExcluidas6 + 1;
			ELIF cStatusCred = 'TE' THEN	-- Las que sean cuentas testigo
                LET vMotivoEx	= 0;
                LET vstatus_cte	= 'TE';
				LET iCuentasExcluidas0 = iCuentasExcluidas0 + 1;
			ELIF (cStatusCred IN ('AA','VP','E1') AND cMtoVen = 0) THEN	-- Cuentas que recibieron pago y se cubrió la totalidad del pago vencido
                LET vMotivoEx	= 2;
                LET vstatus_cte	= 'EX';
				LET iCuentasExcluidas2 = iCuentasExcluidas2 + 1;
			ELIF cStatusCred = 'CV' THEN	-- Las que están en el proceso de venta de cartera y que se vendan
                LET vMotivoEx	= 4;
                LET vstatus_cte	= 'EX';
				LET iCuentasExcluidas4 = iCuentasExcluidas4 + 1;
			ELIF cStatusCred IN ('FF','FC','FI') THEN	-- Las que están canceladas (independientemente su causa)
                LET vMotivoEx	= 8;
                LET vstatus_cte	= 'EX';
				LET iCuentasExcluidas8 = iCuentasExcluidas8 + 1;
			ELIF dMontoFinanciado <= 100 THEN	-- Las vencidas con monto financiado menor o igual a 100
                LET vMotivoEx	= 7;
                LET vstatus_cte	= 'EX';
				LET iCuentasExcluidas7 = iCuentasExcluidas7 + 1;
			ELSE
                SELECT FIRST 1 situacion,  causa
                    INTO vSituacion, vCausa
                    FROM bdisitesp:"informix".se_ctessitespcte
                    WHERE numcte = vnumcte;

				IF (vSituacion = 'F' AND vCausa IN ('42','43','101','102','107')) OR
					(vSituacion = 'U' AND vCausa = '60') OR
					(vSituacion = 'V' AND vCausa IN ('86','87','88','89','90','91','92','93','94')) THEN	-- Cuentas que fueron bloqueadas por alguna situación y de clientes fallecidos
					LET vMotivoEx = 3;
					LET vstatus_cte = 'EX';
					LET iCuentasExcluidas3 = iCuentasExcluidas3 + 1;
				ELSE	-- Las que están en el proceso de venta de cartera y que se vendan
					SELECT COUNT(*) INTO sEnProcVenta
					FROM bdicobranza:cb_rep_cart_quebrantar
					WHERE num_credito = vNumCredito
					  AND fechareporte BETWEEN dPriDiaMes AND dFechaHoy
					  AND excluido IS NULL;

					IF sEnProcVenta > 0 THEN
						LET vMotivoEx = 4;
						LET vstatus_cte = 'EX';
						LET iCuentasExcluidas4 = iCuentasExcluidas4 + 1;
					ELSE	-- Las que tienen un convenio vigente
						SELECT COUNT(*) INTO sConConvenio
						FROM bdicobranza:cb_compac 
						WHERE empresa = pEmpresa 
						  AND numcuenta = vNumCredito
						  AND importe >= 100;

						IF sConConvenio > 0 THEN
							LET vMotivoEx = 1;
							LET vstatus_cte = 'IN';
							LET iCuentasExcluidas1 = iCuentasExcluidas1 + 1;
						ELSE	-- Las que tienen una aclaración en proceso
							SELECT count(a.numero_cuenta) INTO sEnAclaracion
							FROM bdiaclaracion:acl_producto a
							INNER JOIN bdiaclaracion:acl_aclaracion b ON b.fky_producto=a.pky_producto AND b.fky_estatus_aclaracion= '2' AND today - b.fechacaptura <= 30
							WHERE a.numero_cuenta = vNumCredito;
							
							IF sEnAclaracion > 0 THEN
								LET vMotivoEx = 5;
								LET vstatus_cte = 'IN';
								LET iCuentasExcluidas5 = iCuentasExcluidas5 + 1;
							ELSE 
								LET iCuentasSinExcluir = iCuentasSinExcluir + 1;
								CONTINUE FOREACH;
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
			
			BEGIN;
				UPDATE bdicobranza:cb_cat_directorio_cte
				   SET 	status_cliente= vstatus_cte, 
						tipo_movto= vMotivoEx, 
						fecha_modificacion = TODAY, 
						usuario_modifica= vusuario                
				WHERE empresa		= pEmpresa
				  AND num_credito	= vNumCredito
				  AND fecha_insert	= vfecha_insert
				  AND tipo_cobranza	= vTipoCobranza;
			COMMIT;
			LET iCuentasActualizadas = iCuentasActualizadas + 1;
        END FOREACH;
		DROP TABLE directorio_cte;

		LET cMensajeBitacora = 'TOTAL EXCLUIDOS cuentas procesadas : ' ||iCuentasProcesadas;
		LET cMensajeBitacora = TRIM(cMensajeBitacora) || '		Cuentas sin excluir : ' ||iCuentasSinExcluir;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, '000000', cMensajeBitacora,'02' ) RETURNING vCod_ret;

		LET cMensajeBitacora = 'Cuentas excluidas motivo 0 : ' ||iCuentasExcluidas0;
		LET cMensajeBitacora = TRIM(cMensajeBitacora) || '        Cuentas excluidas motivo 1 : ' ||iCuentasExcluidas1;
		LET cMensajeBitacora = TRIM(cMensajeBitacora) || '        Cuentas excluidas motivo 2 : ' ||iCuentasExcluidas2;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, '000000', cMensajeBitacora,'02' ) RETURNING vCod_ret;

		LET cMensajeBitacora = 'Cuentas excluidas motivo 3 : ' ||iCuentasExcluidas3;
		LET cMensajeBitacora = TRIM(cMensajeBitacora) || '        Cuentas excluidas motivo 4 : ' ||iCuentasExcluidas4;
		LET cMensajeBitacora = TRIM(cMensajeBitacora) || '        Cuentas excluidas motivo 5 : ' ||iCuentasExcluidas5;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, '000000', cMensajeBitacora,'02' ) RETURNING vCod_ret;

		LET cMensajeBitacora = 'Cuentas excluidas motivo 6 : ' ||iCuentasExcluidas6;
		LET cMensajeBitacora = TRIM(cMensajeBitacora) || '        Cuentas excluidas motivo 7 : ' ||iCuentasExcluidas7;
		LET cMensajeBitacora = TRIM(cMensajeBitacora) || '        Cuentas excluidas motivo 8 : ' ||iCuentasExcluidas8;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, '000000', cMensajeBitacora,'02' ) RETURNING vCod_ret;

		LET cMensajeBitacora = 'Cuentas actualizadas : ' ||iCuentasActualizadas;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, '000000', cMensajeBitacora,'02' ) RETURNING vCod_ret;

		LET iCuentasProcesadas	= 0;
		LET iCuentasActualizadas = 0;
		LET iCuentasExcluidas0	= 0;
		LET iCuentasExcluidas1	= 0;
		LET iCuentasExcluidas2	= 0;
		LET iCuentasExcluidas3	= 0;
		LET iCuentasExcluidas4	= 0;
		LET iCuentasExcluidas5	= 0;
		LET iCuentasExcluidas6	= 0;
		LET iCuentasExcluidas7	= 0;
		LET iCuentasExcluidas8	= 0;
		LET iCuentasSinExcluir	= 0;
		LET cMensajeBitacora	= '';
		LET vTipoCobranza		= '';

	END FOREACH;

	LET iCuentasProcesadas	= 0;
	LET iCuentasActualizadas = 0;
	LET iCuentasExcluidas0	= 0;
	LET iCuentasExcluidas1	= 0;
	LET iCuentasExcluidas2	= 0;
	LET iCuentasExcluidas3	= 0;
	LET iCuentasExcluidas4	= 0;
	LET iCuentasExcluidas5	= 0;
	LET iCuentasExcluidas6	= 0;
	LET iCuentasExcluidas7	= 0;
	LET iCuentasExcluidas8	= 0;
	LET iCuentasSinExcluir	= 0;
	LET cMensajeBitacora	= '';
	LET vTipoCobranza		= '';

--	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE INTO dFecha_hoy FROM sysmaster:sysshmvals;
-- Se reactivan cuentas para su gestion
    FOREACH WITH HOLD
        SELECT valor_alfabetico INTO vTipoCobranza
            FROM bdicobranza:cb_param_campania WHERE empresa = pEmpresa AND tipo_campania = 1
            AND grupo_parametro = 'TIPOCOBCAT' AND num_parametro >= 5 AND num_parametro <= 12
            group by valor_alfabetico
		
		IF(vTipoCobranza = "E") OR (vTipoCobranza = "P") THEN
			CONTINUE FOREACH;
		END IF;

        SELECT min(fecha_insert) INTO dMinFechaInsert
        FROM bdicobranza:cb_cat_directorio_cte
        WHERE empresa = pEmpresa
        AND tipo_cobranza = vTipoCobranza  
        AND status_cliente NOT IN ('AC','PR')
        AND tipo_movto =1
        AND fecha_modificacion <> today;

        SELECT min(fecha_insert) INTO dMinFechaInsert
        FROM bdicobranza:cb_cat_directorio_cte
        WHERE empresa = pEmpresa
        AND tipo_cobranza = vTipoCobranza  
        AND status_cliente in ('AC','PR');
		
		IF DAY(today) = 19 AND vTipoCobranza = 'A' THEN
	   
			SELECT dct.numcte, dct.fecha_insert, dct.num_credito, dct.call_c, dct.tipo_movto, dct.tipo_cobranza, dct.fecha_modificacion
			FROM bdicobranza:cb_cat_directorio_cte dct
			INNER JOIN bdicred:sd_definicion def ON def.empresa = dct.empresa AND def.num_producto = dct.num_producto
            WHERE dct.empresa = pEmpresa
            AND dct.tipo_cobranza = vTipoCobranza
            AND dct.fecha_insert >= dMinFechaInsert
            AND dct.fecha_insert <= today - 1
            AND dct.status_cliente IN ('IN','EX')
            AND dct.tipo_movto IN (1,3,4,5)
            AND (dct.fecha_modificacion is null OR dct.fecha_modificacion < today)
			AND dct.num_producto NOT IN ('8100','8500')
			INTO TEMP directorio_cte_reactiva WITH NO LOG;

		ELIF DAY(today) = 21 AND vTipoCobranza = 'A' THEN

			SELECT dct.numcte, dct.fecha_insert, dct.num_credito, dct.call_c, dct.tipo_movto, dct.tipo_cobranza, dct.fecha_modificacion
			FROM bdicobranza:cb_cat_directorio_cte dct
			INNER JOIN bdicred:sd_definicion def ON def.empresa = dct.empresa AND def.num_producto = dct.num_producto
            WHERE dct.empresa = pEmpresa
            AND dct.tipo_cobranza = vTipoCobranza
            AND dct.fecha_insert >= dMinFechaInsert
            AND dct.fecha_insert <= today - 1
            AND dct.status_cliente IN ('IN','EX')
            AND dct.tipo_movto IN (1,3,4,5)
            AND (dct.fecha_modificacion is null OR dct.fecha_modificacion < today)
			AND dct.num_producto NOT IN ('6001')
			INTO TEMP directorio_cte_reactiva WITH NO LOG;

		ELSE

			SELECT dct.numcte, dct.fecha_insert, dct.num_credito, dct.call_c, dct.tipo_movto, dct.tipo_cobranza, dct.fecha_modificacion
			FROM bdicobranza:cb_cat_directorio_cte dct
			INNER JOIN bdicred:sd_definicion def ON def.empresa = dct.empresa AND def.num_producto = dct.num_producto
            WHERE dct.empresa = pEmpresa
            AND dct.tipo_cobranza = vTipoCobranza
            AND dct.fecha_insert >= dMinFechaInsert
            AND dct.fecha_insert <= today - 1
            AND dct.status_cliente IN ('IN','EX')
            AND dct.tipo_movto IN (1,3,4,5)
            AND (dct.fecha_modificacion is null OR dct.fecha_modificacion < today)
			INTO TEMP directorio_cte_reactiva WITH NO LOG;

		END IF;
		
		CREATE INDEX idx_directoriocte ON directorio_cte_reactiva(tipo_cobranza);
		UPDATE statistics medium FOR TABLE directorio_cte_reactiva;

		SELECT COUNT(*) INTO iCuentasProcesadas
		FROM directorio_cte_reactiva WHERE tipo_cobranza = vTipoCobranza;
		
		LET cMensajeBitacora = 'INICIO procesamiento cuentas a reactivar TIPO COBRANZA : ' ||vTipoCobranza;
		LET cMensajeBitacora = TRIM(cMensajeBitacora) || '		TOTAL CUENTAS a procesar : ' ||iCuentasProcesadas;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, '000000', cMensajeBitacora,'02' ) RETURNING vCod_ret;

		LET iCuentasProcesadas = 0;
		
        FOREACH WITH HOLD
            SELECT numcte, fecha_insert, num_credito, tipo_movto
            INTO vnumcte, vfecha_insert, vNumCredito, iTipoMovto
            FROM directorio_cte_reactiva
            WHERE tipo_cobranza = vTipoCobranza

            LET vMotivoEx	= 0;
			LET iCuentasProcesadas = iCuentasProcesadas + 1;

			IF vTipoCobranza IN ('A','P') THEN
				SELECT mae.status_cred, mas.monto_financiado,nvl(mas.monto_vencido + mas.mto_venc_trasp,0) INTO cStatusCred, dMontoFinanciado,cMtoVen
				FROM bdicred:sd_maecred mae
				INNER JOIN bdicred:sd_maesdos mas on mas.empresa = mae.empresa AND mas.num_credito = mae.num_credito
				WHERE mae.empresa = pEmpresa
				  AND mae.num_credito = vNumCredito;
			ELIF vTipoCobranza IN ('R','E') THEN
				SELECT mae.status_cred, mas.monto_financiado,nvl(mas.monto_vencido + mas.mto_venc_trasp,0) INTO cStatusCred, dMontoFinanciado, cMtoVen
				FROM bdicred:sd_maecredcrd mae
				INNER JOIN bdicred:sd_maesdoscrd mas on mas.num_credito = mae.num_credito
				WHERE mae.num_credito = vNumCredito;
			ELSE
				LET iCuentasSinExcluir = iCuentasSinExcluir + 1;
				CONTINUE FOREACH;
			END IF;

			IF (cStatusCred IN ('AA','CV','FF','FC')) OR (cStatusCred IN ('VP','E1') AND cMtoVen = 0) THEN
				LET vMotivoEx = -1;
				LET iCuentasExcluidas0 = iCuentasExcluidas0 + 1;
			ELIF iTipoMovto = 3 THEN
				SELECT FIRST 1 situacion,  causa
				INTO vSituacion, vCausa
				FROM bdisitesp:"informix".se_ctessitespcte
				WHERE numcte = vnumcte;

				IF (vSituacion = 'F' AND vCausa IN ('43','101','102','107')) OR
					(vSituacion = 'U' AND vCausa = '60') OR
					(vSituacion = 'V' AND vCausa IN ('86','87','88','89','90','91','92','93','94')) THEN	-- Cuentas que fueron bloqueadas por alguna situación y de clientes fallecidos
					LET iCuentasSinExcluir = iCuentasSinExcluir + 1;
					CONTINUE FOREACH;
				ELSE
					LET vMotivoEx = 1;
					LET iCuentasExcluidas3 = iCuentasExcluidas3 + 1;
				END IF;
			ELIF iTipoMovto = 4 THEN
				IF cStatusCred IN ('BA','BT','E1','E2','E3') AND cMtoVen > 0 THEN
					SELECT COUNT(*) INTO sEnProcVenta
					FROM bdicobranza:cb_rep_cart_quebrantar
					WHERE num_credito = vNumCredito
					  AND fechareporte BETWEEN dPriDiaMes AND dFechaHoy
					  AND excluido = 'E';

					IF sEnProcVenta > 0 THEN
						LET vMotivoEx = 1;
						LET iCuentasExcluidas4 = iCuentasExcluidas4 + 1;
					ELSE
						LET iCuentasSinExcluir = iCuentasSinExcluir + 1;
						CONTINUE FOREACH;
					END IF;
				ELSE
					LET iCuentasSinExcluir = iCuentasSinExcluir + 1;
					CONTINUE FOREACH;
				END IF;
			ELIF iTipoMovto = 1 THEN
					SELECT COUNT(*) INTO sConConvenio
					FROM bdicobranza:cb_compac 
					WHERE empresa = pEmpresa 
					  AND numcuenta = vNumCredito
					  AND importe >= 100;

					IF sConConvenio > 0 THEN
						LET iCuentasSinExcluir = iCuentasSinExcluir + 1;
						CONTINUE FOREACH;
					ELSE
						LET vMotivoEx = 1;
						LET iCuentasExcluidas1 = iCuentasExcluidas1 + 1;
					END IF;
			ELIF iTipoMovto = 5 THEN
					SELECT count(a.numero_cuenta) INTO sEnAclaracion
					FROM bdiaclaracion:acl_producto a
					INNER JOIN bdiaclaracion:acl_aclaracion b ON b.fky_producto=a.pky_producto AND b.fky_estatus_aclaracion= '2' AND today - b.fechacaptura <= 30
					WHERE a.numero_cuenta = vNumCredito;
							
					IF sEnAclaracion > 0 THEN
						LET iCuentasSinExcluir = iCuentasSinExcluir + 1;
						CONTINUE FOREACH;
					ELSE
						LET vMotivoEx = 1;
						LET iCuentasExcluidas5 = iCuentasExcluidas5 + 1;
					END IF;
			END IF;

			BEGIN;
			IF vMotivoEx = -1 THEN				-- Se excluyen las cuentas para el resto del periodo (termina su gestión)
				UPDATE bdicobranza:cb_cat_directorio_cte
				SET status_cliente	= 'EX', 
					tipo_movto		= 0, 
					fecha_modificacion	= TODAY, 
					usuario_modifica	= vusuario                
				WHERE empresa		= pEmpresa
				  AND num_credito	= vNumCredito
				  AND fecha_insert	= vfecha_insert
				  AND tipo_cobranza	= vTipoCobranza;
				LET iCuentasActualizadas = iCuentasActualizadas + 1;
			ELIF vMotivoEx = 1 THEN				-- Se reactivan las cuentas para su gestión
				UPDATE bdicobranza:cb_cat_directorio_cte
				SET status_cliente	= 'AC', 
					tipo_movto		= 0, 
					fecha_modificacion	= TODAY, 
					usuario_modifica	= vusuario                
				WHERE empresa		= pEmpresa
				  AND num_credito	= vNumCredito
				  AND fecha_insert	= vfecha_insert
				  AND tipo_cobranza	= vTipoCobranza;
				LET iCuentasActualizadas = iCuentasActualizadas + 1;
			END IF;
			COMMIT;
        END FOREACH;
		DROP TABLE directorio_cte_reactiva;

		LET cMensajeBitacora = 'TOTAL REACTIVACIONES cuentas procesadas : ' ||iCuentasProcesadas;
		LET cMensajeBitacora = TRIM(cMensajeBitacora) || '		Cuentas sin movimiento : ' ||iCuentasSinExcluir;
		LET cMensajeBitacora = TRIM(cMensajeBitacora) || '		Cuentas excluidas forma permanente : ' ||iCuentasExcluidas0;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, '000000', cMensajeBitacora,'02' ) RETURNING vCod_ret;

		LET cMensajeBitacora = 'Cuentas reactivadas motivo 1 : ' ||iCuentasExcluidas1;
		LET cMensajeBitacora = TRIM(cMensajeBitacora) || '        Cuentas reactivadas motivo 3 : ' ||iCuentasExcluidas3;
		LET cMensajeBitacora = TRIM(cMensajeBitacora) || '        Cuentas reactivadas motivo 4 : ' ||iCuentasExcluidas4;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, '000000', cMensajeBitacora,'02' ) RETURNING vCod_ret;

		LET cMensajeBitacora = 'Cuentas reactivadas motivo 5 : ' ||iCuentasExcluidas5;
		LET cMensajeBitacora = TRIM(cMensajeBitacora) || '        Cuentas actualizadas : ' ||iCuentasActualizadas;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, '000000', cMensajeBitacora,'02' ) RETURNING vCod_ret;

		LET iCuentasProcesadas	= 0;
		LET iCuentasActualizadas = 0;
		LET iCuentasExcluidas0	= 0;
		LET iCuentasExcluidas1	= 0;
		LET iCuentasExcluidas3	= 0;
		LET iCuentasExcluidas4	= 0;
		LET iCuentasExcluidas5	= 0;
		LET iCuentasSinExcluir	= 0;
		LET cMensajeBitacora	= '';
		LET vTipoCobranza		= '';
		
    END FOREACH;

    -- MAHR Genera archivos de clientes excluidos para todos los productos. (Se elimina con esto el cron actual).
	-- Se ejecutará esta linea hasta liberar reingenieria de campañas CAT.
    --IF cNumProdCob = '6001' AND cTipoCob = 'P' THEN -- Preventiva de Tarjeta de Credito
    --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso,'000000', 'INICIA PROCESO CTES EXCLUIDOS 6001 - P' ,'02' ) RETURNING vCod_ret;
    --CALL bdicobranza:"informix".sp_cat_ivr_gen_arcctesexcluidos(pempresa, today)  RETURNING cCod_ret;
    --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso,cCod_ret, 'FINALIZA PROCESO CTES EXCLUIDOS 6001 - P' ,'02' ) RETURNING vCod_ret;
    --ELIF cNumProdCob = '6001' AND cTipoCob = 'A' THEN  -- Administrativa de Tarjeta de Credito
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso,'000000', 'INICIA PROCESO CTES EXCLUIDOS 6001 - A' ,'02' ) RETURNING vCod_ret;
    CALL bdicobranza:"informix".sp_ctbcpl_gen_arcctesexcluidos(pEmpresa, today, 'A' ) RETURNING cCod_ret;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso,cCod_ret, 'FINALIZA PROCESO CTES EXCLUIDOS 6001 - A' ,'02' ) RETURNING vCod_ret;
    --ELIF cNumProdCob = '6300' AND cTipoCob = 'E' THEN -- Preventiva de Prestamo Personal
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso,'000000', 'INICIA PROCESO CTES EXCLUIDOS 6300 - E' ,'02' ) RETURNING vCod_ret;
    CALL bdicobranza:"informix".sp_cat_gb_pp_genarchex(pempresa, today) RETURNING cCod_ret;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso,cCod_ret, 'FINALIZA PROCESO CTES EXCLUIDOS 6300 - E' ,'02' ) RETURNING vCod_ret;
    --END IF;

    CALL sp_inserta_bitacora_cob(pempresa, cProceso,'', '','03' ) RETURNING vCod_ret;

        RETURN cCod_ret, cMensaje;
	END;
END PROCEDURE;