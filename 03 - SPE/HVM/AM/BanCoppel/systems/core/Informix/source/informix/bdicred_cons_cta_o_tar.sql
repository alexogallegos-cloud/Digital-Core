CREATE PROCEDURE "informix".cons_cta_o_tar(pempresa     CHAR(3),
			    		                   psistema     SMALLINT,
										   ptipoctatar  CHAR(1),
					                       pctatar      CHAR(20),
                                           pregistros   SMALLINT)

RETURNING CHAR(5),       -- Codigo de Retorno
          CHAR(20),      -- Nro de Cliente
          CHAR(26),      -- Nombre1
	      CHAR(26),      -- Nombre2
	      CHAR(26),      -- Apellido Paterno
          CHAR(26),      -- Apellido Materno
		  DATE,  	     -- Fecha Nacimiento
		  CHAR(13),      -- RFC
		  CHAR(20),      -- CUENTA
		  CHAR(20),      -- TARJETA
		  CHAR(1),       -- STATUS APLICATIVOS
          CHAR(50),      -- PRODUCTO
          CHAR(50),      -- DIVISA
          CHAR(3);       --STATUS INTERCARD


-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret        CHAR(5);
DEFINE vsqlerr         INTEGER;
DEFINE s_numcte        CHAR(20);
DEFINE s_nombre1       CHAR(26);
DEFINE s_nombre2       CHAR(26);
DEFINE s_paterno       CHAR(26);
DEFINE s_materno       CHAR(26);
DEFINE s_fechanac      DATE;
DEFINE s_rfc           CHAR(13);
DEFINE s_cuenta        CHAR(20);
DEFINE s_tarjeta       CHAR(20);
DEFINE v_cuantos       SMALLINT;
DEFINE s_status        CHAR(1);
DEFINE s_status_cta	   CHAR(1);
DEFINE s_producto      CHAR(50);
DEFINE s_divisa        CHAR(50);
DEFINE s_codstatustarjeta CHAR(3);
DEFINE bValCuenta       BOOLEAN;
DEFINE cValor           CHAR(2);
DEFINE cValorCred       CHAR(2);
DEFINE cStatusCred       CHAR(2);
DEFINE cProdTransfer   CHAR(4);
DEFINE cProdTarjeta    CHAR(4);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET v_cuantos    = 0;
LET s_numcte     = "";
LET s_nombre1	= "";
LET s_nombre2	= "";
LET s_paterno	= "";
LET s_materno	= "";
LET s_fechanac	= "";
LET s_rfc	= "";
LET s_cuenta	= "";
LET s_tarjeta	= "";
LET s_status    = "";
LET s_status_cta ="";
LET s_producto    = "";
LET s_divisa      = "";
LET s_codstatustarjeta =  "";
LET bValCuenta    = "T";
LET cValor        = "";
LET cValorCred    = "";
LET cStatusCred   = "";
LET cProdTransfer = '';
LET cProdTarjeta  = '';

--scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa;


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/tmp/cons_cta_o_tar.sql";
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************


   LET pempresa = pempresa;
   LET psistema = psistema;
   LET ptipoctatar = ptipoctatar;
   LET pctatar = pctatar;


  -- Valida Parametros de Entrada

  IF pempresa = "" OR
     psistema = "" OR
     ptipoctatar = "" OR
     pctatar = "" THEN
     LET scod_ret = "110";
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
  END IF
  
		-----------------------------------VALIDA SI LA TARJETA ES PRODUCTO TRANSFER 8000------------------------------ 
		SELECT valor
		INTO cProdTransfer
		FROM bditransfer:"informix".tf_param
		WHERE empresa = pempresa AND cod_param = 4;

		SELECT prodtarjeta 
		INTO cProdTarjeta
		FROM bdicheq:"informix".sc_tarjeta
		WHERE empresa = pempresa AND num_tarjeta = pctatar;


		IF TRIM(cProdTransfer) = TRIM(cProdTarjeta) THEN
		
			LET scod_ret = "858";
			
			RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
			
		END IF
---------------------------TERMINA VALIDA SI LA TARJETA ES PRODUCTO TRANSFER 8000-------------------------------- 

  IF psistema = 1 THEN -- Sistema de Cheques
  
                SELECT valor  INTO cValor
				FROM bdicheq:"informix".sc_param WHERE codparam = 'longcta';

     IF ptipoctatar = "C" THEN

        --Valida que la cuenta exista en cheques

        SELECT mae.status_cta, mae.num_cte, mae.cuenta, prod.producto || " " || prod.nombre, div.divisa || " " || div.descripcion,
               clie.nombre1, clie.nombre2, clie.apell_paterno, clie.apell_materno, cte.fecha_nac, clie.rfc
          INTO s_status, s_numcte, s_cuenta, s_producto, s_divisa,
               s_nombre1, s_nombre2, s_paterno, s_materno, s_fechanac, s_rfc
          FROM bdicheq:"informix".sc_maechq mae,
               bdinteg:"informix".si_cliente clie,
               bdinteg:"informix".si_ctepf cte,
               bdinteg:"informix".si_divisas div,
               bdicheq:"informix".sc_producto prod
         WHERE mae.empresa = clie.empresa
               AND mae.empresa = cte.empresa
               AND mae.num_cte = clie.numcte
               AND mae.num_cte = cte.numcte
               AND prod.empresa = mae.empresa
               AND prod.producto = mae.producto
               AND div.empresa = mae.empresa
               AND div.divisa = prod.divisa
               AND ((mae.empresa= pempresa) AND (mae.cuenta= pctatar));

		 --Valida que cuenta sea numerica y longitud de la cuenta DSB 14/03/2012
		EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
		INTO bValCuenta;						

		IF LENGTH(s_cuenta) != cValor  OR bValCuenta  = "F" THEN 
			LET scod_ret = "002";
			RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
		END IF	
		
        IF s_status IS NULL OR s_status  = "" THEN
           LET scod_ret = "100"; -- No existe la cuenta
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF

        IF s_status = "2" THEN
           LET scod_ret = "200"; -- Cuenta Cancelada
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF


        IF s_status = "3" THEN
           LET scod_ret = "100"; -- Cuenta Bloqueada
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF

        -- Busca las Tarjetas Relacionadas a las Cuentas
		-- Se agrega la validacion a la sc_firmantes para solo buscar tarjetas autorizadas
		-- CGP 10032015
        FOREACH
            SELECT tardeb.num_tarjeta, tardeb.cuenta, tardeb.status_tar, tar.codstatustarjeta
            INTO s_tarjeta, s_cuenta, s_status, s_codstatustarjeta
            FROM bdicheq:"informix".sc_tarjeta tardeb, intercard:"informix".tarjeta tar, bdicheq:"informix".sc_firmantes as firm
			WHERE (tardeb.empresa= pempresa)
            AND (tardeb.cuenta= pctatar)
            AND(tardeb.num_tarjeta = tar.numtarjeta )
			and (firm.cuenta = tardeb.cuenta)
			and (firm.numcte = tardeb.numcte)
            ORDER BY num_tarjeta ASC

           LET v_cuantos = v_cuantos + 1;
           IF v_cuantos <= pregistros THEN
              CONTINUE FOREACH;
           END IF

           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta
                  WITH RESUME;


        END FOREACH
     END IF

     IF ptipoctatar = "T" THEN

        FOREACH
           SELECT tarj.cuenta, tarj.numcte, tarj.num_tarjeta, tarj.status_tar, prod.producto || " " || prod.nombre, div.divisa || " " || div.descripcion,
                  clie.nombre1, clie.nombre2, clie.apell_paterno, clie.apell_materno, cte.fecha_nac, clie.rfc, tar.codstatustarjeta, mae.status_cta
             INTO s_cuenta, s_numcte, s_tarjeta, s_status, s_producto, s_divisa,
                  s_nombre1, s_nombre2, s_paterno, s_materno, s_fechanac, s_rfc, s_codstatustarjeta, s_status_cta
             FROM bdicheq:"informix".sc_tarjeta tarj,
				  bdicheq:"informix".sc_maechq mae, --se agrega la tabla maechq para validar el estatus de la cuenta de la tarjeta que se desliza	
                  bdinteg:"informix".si_cliente clie,
                  bdinteg:"informix".si_ctepf cte,
                  bdinteg:"informix".si_divisas div,
                  bdicheq:"informix".sc_producto prod,
                  intercard:"informix".tarjeta tar
            WHERE tarj.empresa = clie.empresa
                  AND tarj.numcte = clie.numcte
                  AND tarj.empresa = cte.empresa
                  AND tarj.numcte = cte.numcte
				  AND tarj.cuenta = mae.cuenta
                  AND prod.empresa = tarj.empresa
                  AND prod.producto = tarj.prodtarjeta
                  AND div.empresa = tarj.empresa
                  AND div.divisa = prod.divisa
                  AND tarj.num_tarjeta = tar.numtarjeta
                  AND ((tarj.empresa=pempresa)
                  AND (tarj.tipo_tarjeta='T')
               -- AND (tarj.status_tar='A')
                  AND (tarj.num_tarjeta=pctatar))
            ORDER BY tarj.num_tarjeta ASC

           LET v_cuantos = v_cuantos + 1;
           IF v_cuantos <= pregistros THEN
              CONTINUE FOREACH;
           END IF
		   
		   	   
			--Valida que cuenta sea numerica y longitud de la cuenta DSB 14/03/2012
			EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
			INTO bValCuenta;	
		--se valida el estatus de la cuenta de la tarjeta que se esta deslizando
			IF s_status_cta IS NULL OR s_status_cta  = "" THEN
           LET scod_ret = "100"; -- No existe la cuenta
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF

        IF s_status_cta = "2" THEN
           LET scod_ret = "200"; -- Cuenta Cancelada
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF


        IF s_status_cta = "3" THEN
           LET scod_ret = "100"; -- Cuenta Bloqueada
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF

			IF LENGTH(s_cuenta) != cValor  OR bValCuenta  = "F" THEN 
				LET scod_ret = "002";
			END IF
	
			--dsb 28/05/2012
			IF scod_ret <> "002" THEN
				SELECT numcuenta INTO s_cuenta FROM intercard:"informix".tarjetacuenta WHERE numtarjeta =  pctatar;
				EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
				INTO bValCuenta;						

				IF LENGTH(s_cuenta) != cValor  OR bValCuenta  = "F" OR s_cuenta IS NULL THEN 
					LET scod_ret = "002";
				END IF
			END IF
			
			
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta
                  WITH RESUME;

			
        END FOREACH
     END IF
  END IF

  IF psistema = 6 THEN -- Sistema de Credito

                SELECT valor INTO cValorCred
				FROM bdicred:"informix".sd_param WHERE cod_param = '8';
				
     IF ptipoctatar = "T" THEN

        FOREACH
           SELECT tarj.num_credito, tarj.num_tarjeta, tarj.numcte, tarj.status_tar, def.num_producto || " " || def.nombre_prod, div.divisa || " " || div.descripcion,
                  clie.nombre1, clie.nombre2, clie.apell_paterno, clie.apell_materno, cte.fecha_nac, clie.rfc, tar.codstatustarjeta
             INTO s_cuenta, s_tarjeta, s_numcte, s_status, s_producto, s_divisa,
                  s_nombre1, s_nombre2, s_paterno, s_materno, s_fechanac, s_rfc, s_codstatustarjeta
             FROM bdicred:"informix".sd_tarjeta tarj,
                  bdinteg:"informix".si_cliente clie,
                  bdinteg:"informix".si_ctepf cte,
                  bdicred:"informix".sd_maecred mae,
                  bdicred:"informix".sd_definicion def,
                  bdinteg:"informix".si_divisas div,
                  intercard:"informix".tarjeta tar
            WHERE tarj.empresa = clie.empresa
                  AND tarj.numcte = clie.numcte
                  AND tarj.empresa = cte.empresa
                  AND tarj.numcte = cte.numcte
                  AND mae.empresa = tarj.empresa
                  AND mae.num_credito = tarj.num_credito
                  AND def.empresa = tarj.empresa
                  AND def.num_producto = mae.num_producto
                  AND div.empresa = mae.empresa
                  AND div.divisa = mae.divisa
                  AND tarj.num_tarjeta = tar.numtarjeta
                  AND ((tarj.empresa=pempresa)
                  AND (tarj.tipo_tarjeta='T')
                  AND (tarj.num_tarjeta=pctatar))

           LET v_cuantos = v_cuantos + 1;
           IF v_cuantos <= pregistros THEN
              CONTINUE FOREACH;
           END IF
           
           
          LET cStatusCred = (SELECT status_cred FROM sd_maecred WHERE num_credito=s_cuenta);

          IF cStatusCred NOT IN ("AA","BT","BA","E1","E2","E3") THEN                
		        LET scod_ret = "279";
                RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
           END IF

			 --Valida que cuenta sea numerica y longitud de la cuenta DSB 14/03/2012
			EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
			INTO bValCuenta;						

			IF LENGTH(s_cuenta) != cValorCred  OR bValCuenta  = "F" THEN 
				LET scod_ret = "002";
			END IF
			
			--dsb 28/05/2012
			--Se valida la cuenta en tarjetacuenta 
			IF scod_ret <> "002" THEN
				SELECT numcuenta INTO s_cuenta FROM intercard:"informix".tarjetacuenta WHERE numtarjeta =  pctatar;
				EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
				INTO bValCuenta;						

				IF LENGTH(s_cuenta) != cValorCred  OR bValCuenta  = "F" OR s_cuenta IS NULL  THEN 
					LET scod_ret = "002";
				END IF
			END IF
			
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta
                  WITH RESUME;

        END FOREACH
     END IF
  END IF
END
END PROCEDURE
DOCUMENT
"Especificacion: Se modifico para que consulte el status de la tarjeta en",
"                la tabla intercard:tarjeta y se regrese como codigo de retorno",
"Base de Datos : bdicred",
"AUTOR : Jesus Manuel Perea Heredia",
"FECHA : 19/Nov/2010",
"Descripcion: Se actualiza a la nueva version de reglas.", 
"Base de Datos : bdinteg",
"Autor : Marcos Cuevas",
"Fecha : 16/Febrero/2011",
"Autor : Josue Zepeda",
"Descripcion: Valida que cuenta sea numerica y longitud de la cuenta, en caso que no regresa codigo de error",
"Base de Datos : bdicred",
"Fecha : 14/Marzo/2012",
"Autor : Victor Hugo NuÃ±ez",
"Descripcion: Valida la cuenta en la tabla intercard:tarjetacuenta",
"Base de Datos : bdicred",
"Fecha : 28/May/2012",
"Autor : Jairo Valdez Gonzalez",
"Descripcion: Se modifica sp para que valide el producto 8000 de transfer y retorne 858",
"Base de Datos : bdicred",
"Fecha : 29/Ago/2014";

CREATE PROCEDURE "informix".cons_saldo(pNumCredito CHAR(20))
   RETURNING CHAR(5), MONEY(16,2), CHAR(1);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nrows               SMALLINT;

   DEFINE NumProducto         CHAR(4);
   DEFINE StatusCred          CHAR(2);
   DEFINE Saldo               MONEY(16,2);
   DEFINE ManejaLinea         CHAR(1);
   DEFINE wStatus             CHAR(1);
   DEFINE cMtoVen      	      DECIMAL(18,2);



   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "Cons_Saldo.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET saldo = 0;
      LET wStatus = " ";
      RETURN cod_ret, Saldo, wStatus;
   END EXCEPTION;


   LET cod_ret = "000";
   LET saldo = 0;
   LET wStatus = " ";
   LET cMtoVen = 0;
   

   SELECT
      a.num_producto,
      a.status_cred,
      b.monto_otorgado - b.sdo_cap_insoluto,
      c.maneja_linea,
	  NVL(b.monto_vencido + b.mto_venc_trasp,0)
   INTO
      NumProducto,
      StatusCred,
      Saldo,
      ManejaLinea,
	  cMtoVen
   FROM
      sd_maecred a,
      sd_maesdos b,
      sd_definicion c
   WHERE
      a.num_credito = pNumCredito
   AND
      b.num_credito = a.num_credito
   AND
      c.num_producto = a.num_producto;

   LET nrows = dbinfo("sqlca.sqlerrd2");
   IF(nrows = 0) THEN
      LET Saldo = 0;
      LET cod_ret = "008";
      RETURN cod_ret, Saldo, wStatus;
   END IF;

   LET wStatus = StatusCred[1,1];

   IF(ManejaLinea <> "S") THEN
      LET cod_ret = "206";
      RETURN cod_ret, Saldo, wStatus;
   END IF;

   IF (Saldo = 0) THEN
      LET cod_ret = "202";
      RETURN cod_ret, Saldo, wStatus;
   END IF;

   IF (StatusCred("BA","BT","E1","E2","E3") AND cMtoVen  > 0 ) THEN
      LET cod_ret = "204";
      RETURN cod_ret, Saldo, wStatus;
   END IF;



   RETURN cod_ret, Saldo, wStatus;
END PROCEDURE
DOCUMENT
'Esta funcion realiza la consulta de saldo disponible para ',
'un credito Inta - Cash',
'AUTOR : Raul Mendoza',
'FECHA : 8/10/2003',
'BD : bdicred ',
'CLIENTE : CACSI';

CREATE PROCEDURE "informix".cons_saldo_cel
	      (pTarjeta       CHAR(16),
         pNumCredito    CHAR(20),
         pComSucursal   CHAR(4),
         pComUsuario    CHAR(8),
         pComNumTran    CHAR(4),
         pComNumTranS   CHAR(4),
         pComFolio      CHAR(16),
         pComNumCredito CHAR(20),
         pComDocumento  INTEGER,
         pComMonto      MONEY(16,2),
         pComDivisa     CHAR(2),
         pComReferencia CHAR(40),
	       pComBandera    CHAR(1),
         pSurcharge     CHAR (1)) -- jom Se agrega para identificar el tipo de comision   (F=No aplica,V=Aplica)


   RETURNING CHAR(5),      -- Codigo de Retorno
             MONEY(16,2),  -- Saldo adeudo total
	         CHAR(1),	   -- Status del Credito
             CHAR(5),      -- Codigo de Retorno Comision
             DATE,         -- Fecha Aplicacion Comision
             MONEY(16,2);  -- Saldo Disponible

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE cod_ret2            CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nrows               SMALLINT;
   DEFINE Mensaje             CHAR(80);

   DEFINE NumProducto         CHAR(4);
   DEFINE StatusCred          CHAR(2);
   DEFINE Saldo               MONEY(16,2);
   DEFINE SaldoCom            MONEY(16,2);
   DEFINE ManejaLinea         CHAR(1);
   DEFINE MontoOtorgado       MONEY(16,2);
   DEFINE CodigoRef           INTEGER;
   DEFINE CodigoFun           CHAR(3);
   DEFINE wEmpresa            CHAR(3);
   DEFINE wSucursal           CHAR(4);
   DEFINE wDivisa             CHAR(2);
   DEFINE FechaHoy            DATE;
   DEFINE pForzado            CHAR(1);
   DEFINE wBegin              CHAR(1);
   DEFINE vusuario            char(8);
   DEFINE VStatus             CHAR(1);
   DEFINE Iva		      DECIMAL(14,2);
   DEFINE TasaIva	      DECIMAL(5,3);
   DEFINE TipoCredito         CHAR(2);
   DEFINE v_valor	      SMALLINT;
   DEFINE v_mn                CHAR(2);
   DEFINE v_dv                CHAR(2);
   DEFINE v_tipocambio        DECIMAL(14,6);
   DEFINE v_com1_dlls         MONEY(16,2);
   DEFINE v_mensaje	      VARCHAR(100);
   DEFINE TotComision         DECIMAL(14,2);
-- Jom INI Bloqueo de cuentas
   DEFINE vBloqueo	     integer;
-- Jom FIN Bloqueo de cuentas
   DEFINE v_bloqprod            INTEGER;   
   
   DEFINE cCodRet              CHAR(6);
   DEFINE cMensajeRet          CHAR(80); 
   DEFINE cNumCredito          CHAR(20);
   DEFINE cCodTip              CHAR(2);	
   DEFINE dtFechaOrigen        DATE;
   DEFINE dtFechaProxPago      DATE;	
   DEFINE dPagoMin             DECIMAL(18,2);
   DEFINE dtFechaUltPago       DATE;
   DEFINE iPlazo               INTEGER; 
   DEFINE iPagoRealizados      INTEGER;
   DEFINE dLineaOtorgada       DECIMAL(18,2);
   DEFINE dTasaInteres         DECIMAL(9,6);
   DEFINE dTasaMora            DECIMAL(9,6);
   DEFINE dMontoSBC            DECIMAL(14,2);
   DEFINE dCapVig              DECIMAL(18,2);
   DEFINE dCapTrans            DECIMAL(18,2);
   DEFINE dCapVdoExig          DECIMAL(18,2);
   DEFINE dCapVdoNoExig        DECIMAL(18,2);
   DEFINE dSdoActTotal         DECIMAL(18,2);
   DEFINE dIntVig              DECIMAL(18,2);
   DEFINE dIntVdo              DECIMAL(18,2);
   DEFINE dIntMoratorio        DECIMAL(18,2);
   DEFINE dIntMes              DECIMAL(18,2);
   DEFINE dSdoActTotalInt      DECIMAL(18,2);
   DEFINE dIvaIntVig           DECIMAL(18,2);
   DEFINE dIvaIntVdo           DECIMAL(18,2);  
   DEFINE dIvaIntMora          DECIMAL(18,2);
   DEFINE dIvaIntMes           DECIMAL(18,2);
   DEFINE dSdoActTotalIva      DECIMAL(18,2);
   DEFINE dComPend             DECIMAL(18,2);
   DEFINE dIvaCom              DECIMAL(18,2);
   DEFINE dSdoRetenido         DECIMAL(18,2);
   DEFINE dTotalLiq            DECIMAL(18,2);
   DEFINE dIntDevengado        DECIMAL(18,2);
   DEFINE dIvaIntDevengado     DECIMAL(18,2);
   DEFINE dLinDisponible       DECIMAL(18,2);
   DEFINE dPagosVdo            DECIMAL(18,2);
   DEFINE cDescStatusCred      CHAR(60);
   DEFINE iBloqueoCred         INTEGER;
   DEFINE cBloqueoCta          CHAR(60);
   DEFINE cIdCausaBloqueoCred  CHAR(3);
   DEFINE cCausaBloqueoCta     CHAR(50);
   DEFINE cIdSitEspCte         CHAR(1);
   DEFINE iIdCausaEspCte       INTEGER;
   DEFINE cSitEspCte           CHAR(75);         
   DEFINE cIdSitEspCred        CHAR(1);
   DEFINE iCausaEspCred        INTEGER;
   DEFINE cSitEspCred          CHAR(75);   
   DEFINE desc_bex             CHAR(100); --bex
   
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "Cons_Sdo_TC.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET Saldo = 0;
      LET FechaHoy = NULL;
      RETURN cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo;
   END EXCEPTION;

   --SET DEBUG FILE TO "/informix/moha/Cons_Sdo_TC.out";
   --TRACE ON;

  SET LOCK MODE TO WAIT 3;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
   LET wBegin        = "N";
   LET vusuario      = USER;

   LET cod_ret       = "000";
   LET cod_ret2      = "000";
   LET VStatus       ="1";
   LET MontoOtorgado = 0;
   LET Saldo         = 0;
   LET SaldoCom      = 0;
   LET FechaHoy      = NULL;
   LET v_tipocambio  = 0;
   LET v_com1_dlls   = 0;
   LET TasaIva       = 0;
-- Jom INI Bloqueo de cuentas
   LET vBloqueo	     = 0;
-- Jom FIN Bloqueo de cuentas
   let v_bloqprod       = 0;

   LET pComSucursal = "9" || TRIM(pComSucursal);
 --  SELECT fecha_hoy
 --    INTO FechaHoy
 --    FROM bdicred:sd_fechas;

	LET cCodRet              = "";
	LET cMensajeRet          = "";
	LET cNumCredito          = "";
	LET cCodTip              = "";
	LET dtFechaOrigen        = DATE(1);
	LET dtFechaProxPago      = DATE(1);
	LET dPagoMin             = 0;
	LET dtFechaUltPago       = DATE(1);
	LET iPlazo               = 0;
	LET iPagoRealizados      = 0;
	LET dLineaOtorgada       = 0;
	LET dTasaInteres         = 0;
	LET dTasaMora            = 0;
	LET dMontoSBC            = 0;
	LET dCapVig              = 0;
	LET dCapTrans            = 0;
	LET dCapVdoExig          = 0;
	LET dCapVdoNoExig        = 0;
	LET dSdoActTotal         = 0;
	LET dIntVig              = 0;
	LET dIntVdo              = 0;
	LET dIntMoratorio        = 0;
	LET dIntMes              = 0;
	LET dSdoActTotalInt      = 0;
	LET dIvaIntVig           = 0;
	LET dIvaIntVdo           = 0;
	LET dIvaIntMora          = 0;
	LET dIvaIntMes           = 0;
	LET dSdoActTotalIva      = 0;
	LET dComPend             = 0;
	LET dIvaCom              = 0;
	LET dSdoRetenido         = 0;
	LET dTotalLiq            = 0;
	LET dIntDevengado        = 0;
	LET dIvaIntDevengado     = 0;
	LET dLinDisponible       = 0;
	LET dPagosVdo            = 0;
	LET cDescStatusCred      = "";
	LET iBloqueoCred         = 0;
	LET cBloqueoCta          = "";
	LET cIdCausaBloqueoCred  = "";
	LET cCausaBloqueoCta     = "";
	LET cIdSitEspCte         = "";
	LET iIdCausaEspCte       = 0;
	LET cSitEspCte           = "";
	LET cIdSitEspCred        = "";
	LET iCausaEspCred        = 0;
	LET cSitEspCred          = "";
	LET desc_bex             = '';  --bex 

   SELECT valor INTO v_mn FROM bdinteg:si_param WHERE cod_param = 15;
   SELECT valor INTO v_dv FROM bdinteg:si_param WHERE cod_param = 17;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

   -- ************************
   -- Busca Datos del Credito*
   -- ************************
   SELECT a.empresa, a.sucursal, a.divisa, a.num_producto, 
          CASE WHEN a.status_cred IN ('AA','E1') and NVL(b.monto_vencido + b.mto_venc_trasp,0) = 0 THEN '1' ELSE '0' END,
          b.monto_otorgado - (b.sdo_cap_insoluto + sdo_retenido), 
	  c.cod_tipcred, a.id_unidad_prod,e.fecha_proceso
     INTO wEmpresa, wSucursal, wDivisa, NumProducto, StatusCred,
          Saldo, TipoCredito, vBloqueo,FechaHoy
     FROM sd_maecred a, sd_maesdos b, sd_definicion c,sd_maecredanexo e
    WHERE a.num_credito = pNumCredito
      AND a.empresa = "001"
      AND b.num_credito = a.num_credito
      AND a.empresa = b.empresa
      AND c.num_producto = a.num_producto
      AND a.empresa=e.empresa
      AND a.num_credito = e.num_credito;

   LET nrows = dbinfo("sqlca.sqlerrd2");
   IF(nrows = 0) THEN
      LET Saldo = 0;
      IF pComNumTranS = "9999" then
        LET cod_ret = "100";
      ELSE
        LET cod_ret = "008";
      END IF
      LET Saldo = 0;
      RETURN cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo;
   END IF;
          
   IF(TipoCredito <> "03") THEN -- Credito no es tarjeta
	  LET Saldo = 0;
      LET cod_ret = "206";
      RETURN cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo;
   END IF;

-- ini -- Se agrega bloqueo de cuentas
-- Bloqueo de cuentas operaciones
-- id_unidad_prod = 2 = bloqueo pago
-- id_unidad_prod = 3 = bloqueo disposicion
-- id_unidad_prod = 4 = bloqueo pago y disposicion

--Jom ini Bloqueo de creditos
   IF (vBloqueo = 3 or vBloqueo = 4) THEN -- Bloqueado
      LET Saldo = 0;
      LET cod_ret = "207";
      RETURN cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo;
   END IF
--Jom Fin Bloqueo de creditos

   IF StatusCred <>  "1" THEN -- Cancelado o Bloqueado
      LET Saldo = 0;
      LET cod_ret = "207";
      RETURN cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo;
   END IF;

    SELECT count(*) 
      INTO v_bloqprod
      FROM bdicred:sd_bloqueoprod 
     WHERE num_producto=NumProducto 
       AND transac_bloq IN (pComNumTran,pComNumTranS);

   IF v_bloqprod > 0  THEN -- bloqueo por producto
	  LET Saldo = 0;
      LET cod_ret = "199";
      RETURN cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo;
   END IF;

   -- **************************** 
   -- Valida Datos del Plasticos *
   -- ****************************

   SELECT COUNT(*) INTO v_valor
     FROM sd_tarjeta
    WHERE empresa = wEmpresa
      AND num_tarjeta = pTarjeta
      AND status_tar = "A";
--      AND expiracion >= FechaHoy;

   IF v_valor IS NULL OR v_valor = 0 THEN -- No hay Plasticos Asignados
      LET Saldo = 0;
      LET cod_ret = "208";
      RETURN cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo;
   END IF
   
     --- OBTIENE LOS SALDOS ACTUALES DEL CREDITO
   EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(wEmpresa,pNumCredito)
				INTO cCodRet,cMensajeRet,cNumCredito,cCodTip,dtFechaOrigen,dtFechaProxPago,dPagoMin,dtFechaUltPago,
					 iPlazo,iPagoRealizados,dLineaOtorgada,dTasaInteres,dTasaMora,dMontoSBC,dCapVig,dCapTrans,
					 dCapVdoExig,dCapVdoNoExig,dSdoActTotal,dIntVig,dIntVdo,dIntMoratorio,dIntMes,dSdoActTotalInt,
					 dIvaIntVig,dIvaIntVdo,dIvaIntMora,dIvaIntMes,dSdoActTotalIva,dComPend,dIvaCom,dSdoRetenido,
					 dTotalLiq,dIntDevengado,dIvaIntDevengado,dLinDisponible,dPagosVdo,cDescStatusCred,iBloqueoCred,
					 cBloqueoCta,cIdCausaBloqueoCred,cCausaBloqueoCta,cIdSitEspCte,iIdCausaEspCte,cSitEspCte,cIdSitEspCred,
					 iCausaEspCred,cSitEspCred;

		IF cCodRet::INTEGER <> 0 THEN
			LET Saldo = 0;
			LET dTotalLiq = 0;
			LET cod_ret = "209";
			RETURN cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo;
		ELSE
			IF NVL(dTotalLiq,0) = 0 AND NVL(dSdoActTotal,0) < 0 THEN
				LET dTotalLiq = dSdoActTotal;
			END IF
		END IF
		
		   	--inicio validacion BEX
           Select limit 1 valor into desc_bex FROM bdinteg:si_param where cod_param='495';
	    IF  trim(desc_bex) = 'V' then
	        EXECUTE PROCEDURE bdinteg:sp_actbex ('2','','',pTarjeta,'8','','','')
	        INTO  cod_ret,desc_bex;
	    END IF;
	     --fin validacion BEX	
   -- *****************************
   -- Valida si se cobra comision *
   -- *****************************
   IF pComMonto = 0 THEN
	  LET Saldo = 0;
      RETURN cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo;
   END IF 

-- jon ini mod surcharge
    if (pSurcharge = 'V') then
        if (pComNumTrans = '0874') then     -- red
            let pComNumTrans = '0893';
        elif (pComNumTrans = '0875') then -- convenio
            let pComNumTrans = '0894';
        elif (pComNumTrans = '0876') then -- internacional
            let pComNumTrans = '0895';
        end if;
    end if;
-- jon fin mod surcharge

   -- ********************************************************
   -- Extrae Tipo de Cambio si se requiere para la operacion *
   -- ********************************************************
   SELECT a.iva INTO TasaIva 
     FROM bdinteg:si_sucursales a
    WHERE a.empresa = wEmpresa
      AND a.sucursal = pComSucursal;

   IF pComDivisa <> v_mn THEN
          SELECT previo_venta INTO v_tipocambio
            FROM bdinteg:si_tpcambio
           WHERE empresa = "001"
             AND divisa = v_dc
             AND clase_tpcambio = "O"
             AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
                                     FROM bdinteg:si_tpcambio
                                    WHERE empresa = "001"
                                       AND divisa = v_dc);
   END IF

   -- *******************************************************
   -- Valoriza Movimientos en Moneda Diferente a 01 (Pesos) *
   -- *******************************************************
   IF pComDivisa <> v_mn THEN
        LET v_com1_dlls = pComMonto;
        LET pComMonto = v_com1_dlls * v_tipocambio;
   END IF

   -- ************************************************
   -- Calcula Iva por Comision, solo para validacion *
   -- ************************************************

   LET Iva = pComMonto * TasaIva;

   -- ***************************************
   -- Valida Disponible vs Monto Movimiento *
   -- ***************************************
   IF Saldo < pComMonto + Iva THEN
     LET Saldo = 0;
	 LET dTotalLiq = 0;
     LET cod_ret = "005";
     RETURN cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo;
   END IF

   -- ***********************************
   -- Determina Total de la Transaccion *
   -- ***********************************
   LET TotComision = pComMonto + Iva;

   -- ***********************************************
   -- Afecta Movimiento(s) de Comision por Disposicion *
   -- ***********************************************
   LET SaldoCom = Saldo;

   IF pComMonto > 0 THEN
        EXECUTE PROCEDURE cargo_cred(wEmpresa, pNumCredito, pComSucursal,
                                     pComUsuario,pComNumTrans,pComMonto, 
				     pComFolio, pTarjeta, v_com1_dlls, 
				     v_tipocambio, FechaHoy, pComReferencia,
				     "", "")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
           LET cod_ret2 = cod_ret;
           LET TotComision = 0;
           LET Saldo = 0;
		   LET dTotalLiq = 0;
   	   RETURN cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo;
      END IF

   END IF

   --LET Saldo = Saldo - TotComision;
   LET Saldo = 0;
   LET dTotalLiq = dTotalLiq + TotComision;


   
   RETURN cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo;

END PROCEDURE
DOCUMENT
'Esta funcion realiza la consulta del Saldo Disponible de la T.C.',
'AUTOR : Antonio Ruiz Mtz ',
'FECHA : 29/12/2006',
'BD : bdicred ',
'CLIENTE : COPPEL';

CREATE PROCEDURE "informix".cons_saldo_cel_pago
	     (pTarjeta       CHAR(16),
         pNumCredito    CHAR(20),
         pComSucursal   CHAR(4),
         pComUsuario    CHAR(8),
         pComNumTran    CHAR(4),
         pComNumTranS   CHAR(4),
         pComFolio      CHAR(16),
         pComNumCredito CHAR(20),
         pComDocumento  INTEGER,
         pComMonto      MONEY(16,2),
         pComDivisa     CHAR(2),
         pComReferencia CHAR(40),
	     pComBandera    CHAR(1),
         pSurcharge     CHAR (1)) -- jom Se agrega para identificar el tipo de comision   (F=No aplica,V=Aplica)


   RETURNING CHAR(5),      -- Codigo de Retorno
             MONEY(16,2),  -- Saldo adeudo total
	         CHAR(1),	   -- Status del Credito
             CHAR(5),      -- Codigo de Retorno Comision
             DATE,         -- Fecha Aplicacion Comision,
             MONEY(16,2),  -- Saldo Disponible
             MONEY(16,2),  -- Pago minimo
             MONEY(16,2),  -- Pago para no generar intereses
             DATE;         -- Fecha limite de pago (Cuando se regersa '1900-01-01' la leyenda es "INMEDIATO"


   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE CodRet2             CHAR(5);
   DEFINE cod_ret2            CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE pNumCre             CHAR(20);

   DEFINE Saldo               MONEY(16,2);
   DEFINE FechaHoy            DATE;
   DEFINE VStatus             CHAR(1);
   DEFINE dTotalLiq           DECIMAL(18,2);
   DEFINE mPgomin             DECIMAL(18,2);
   DEFINE mPagonoint          DECIMAL(18,2);
   DEFINE dFechalimite        DATE;

   
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "Cons_Sdo_TC.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET Saldo = 0;
      LET FechaHoy = NULL;
      RETURN cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo, mPgomin, mPagonoint, dFechalimite;
   END EXCEPTION;

 --SET DEBUG FILE TO "/respaldos/IPCB/Cons_Sdo_TC_pago_JOM.out";
 --TRACE ON;

  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

    LET cod_ret       = "000";
    LET CodRet2      = "00000";
    LET VStatus       ="1";
    LET Saldo         = 0;
    LET FechaHoy      = NULL;
	LET mPgomin       = 0;
	LET dTotalLiq     = 0;
    LET mPagonoint    = 0;
    LET dFechalimite  = null;
    LET pNumCre       = '';
    LET cod_ret2      = "000";
    LET pNumCre       = pNumCredito;

    EXECUTE PROCEDURE "informix".cons_saldo_cel(pTarjeta,pNumCre,pComSucursal,pComUsuario,pComNumTran,pComNumTranS,pComFolio,pComNumCredito,pComDocumento,pComMonto,pComDivisa,pComReferencia,pComBandera,pSurcharge)
            INTO cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo;

    IF (cod_ret = '000') THEN
        EXECUTE PROCEDURE "informix".sp_consulta_saldocortemin('001',pNumCre,0) -- Pago para no generar intereses actualizado con pagos
               INTO CodRet2, mPagonoint;
        IF (CodRet2 = '00000') THEN
            EXECUTE PROCEDURE "informix".sp_consulta_saldocortemin('001',pNumCre,4) -- pago minimo al corte actualizado con pagos
                   INTO CodRet2, mPgomin;
            IF (CodRet2 = '00000') THEN
                Select NVL(prox_fecha_pago,DATE(1))
                  into dFechalimite 
                  from "informix".sd_maecred a,
                       "informix".sd_maecredanexo b
                  where a.num_credito = pNumCre
                    and a.empresa = b.empresa
                    and a.num_credito = b.num_credito;
            ELSE
               LET cod_ret = "209";
            END IF;
        ELSE
            LET cod_ret = "209";
        END IF;
    END IF;

    IF (nvl(mPagonoint,0) <= 0) THEN LET mPagonoint = 0; END IF;
    IF (nvl(mPgomin,0) <= 0)    THEN LET mPgomin = 0;    END IF;


    RETURN cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo, mPgomin, mPagonoint, dFechalimite;

END PROCEDURE;