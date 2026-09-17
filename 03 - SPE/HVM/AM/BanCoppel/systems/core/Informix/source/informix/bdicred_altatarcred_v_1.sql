CREATE PROCEDURE "informix".altatarcred_v_1(pempresa CHAR(3),
											pnum_credito CHAR(20),
											pnumtarjeta	CHAR(20),
											pnumcte	CHAR(20),
											pexpiracion	DATE,
											ptipo_tar CHAR(1),
											pstatus	CHAR(1),
											plimite_aut	money (14,2),
											pprodtarjeta CHAR(3),
											pnombre	CHAR(104),
											pnumproducto	CHAR(4))
----------DATOS QUE REGRESA
RETURNING CHAR(5) AS CodigoRetorno, CHAR(6) AS CodigoProducto;

--DECLARACION DE VARIABLES
DEFINE vcodret		CHAR(5);
DEFINE vsiguiente	INTEGER;
DEFINE vexiste		INTEGER;
DEFINE vsqlerr		INTEGER;
DEFINE vtarjeta     CHAR(20);
DEFINE vlExpiracion DATE;
DEFINE cNumProd		CHAR(3);
DEFINE iCont		INT;
DEFINE iContBin		INT;
--DSB-08/07/2014
DEFINE sNumcte		CHAR(20);
DEFINE sCodstatus	CHAR(3);

--INICIALIZANDO VARIABLES
LET vcodret    = "";
LET vsiguiente = 0;
LET vexiste    = 0;
LET vsqlerr    = 0;
LET vtarjeta   = "";
LET cNumProd   = "";
LET iCont	   = 0;
LET iContBin	   = 0;

LET sNumcte		="";
LET sCodstatus = "";

BEGIN
	ON EXCEPTION SET vsqlerr
		IF vsqlerr <> 0 THEN
			LET vcodret = vsqlerr;
			RETURN vcodret, cNumProd;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/home/sysifx/respaldosbd/JesusRLopez/789/altatarcred_out.sql';
	--TRACE ON;
	
IF pnumproducto = "6500" THEN --TDC PAY
	LET vcodret = "000";
ELSE--TDC PAY
	
	IF pnum_credito IS NULL OR pnum_credito = "" THEN
		LET vcodret = "100";
		RETURN vcodret, cNumProd;
	END IF;

	IF pnumtarjeta IS NULL OR pnumtarjeta = "" THEN
		LET vcodret = "101";
		RETURN vcodret, cNumProd;
	END IF;

	IF pnumcte IS NULL OR pnumcte = "" THEN
		LET vcodret = "102";
		RETURN vcodret, cNumProd;
	END IF;

	SELECT num_tarjeta INTO vtarjeta
	FROM bdicred:"informix".sd_tarjeta
	WHERE empresa = pempresa AND num_tarjeta = pnumtarjeta;

	IF vtarjeta IS NOT NULL THEN
		LET vcodret = "430";
		RETURN vcodret, cNumProd;
	END IF;
	
	--DSB-08/07/2014
	SELECT numcliente, codstatustarjeta
	INTO sNumcte, sCodstatus
	FROM intercard:"informix".tarjeta
	WHERE numtarjeta = pnumtarjeta;
	
	IF NVL(sNumcte, '') <> '' THEN
		IF sNumcte <> pnumcte THEN
			--ENVIAR CODIGO DE RESPUESTA 151
			LET vcodret = "151";			RETURN vcodret, cNumProd;		
		END IF
	END IF;
	
	SELECT COUNT(numtarjeta) INTO iCont
	FROM intercard:"informix".tarjeta 
	WHERE numcliente = pnumcte AND codstatustarjeta IN ('ACT','INA') AND titular = 'T' 
	AND SUBSTR(numtarjeta, 1, 6) IN (SELECT DISTINCT(BIN) FROM intercard:"informix".tipotarjeta WHERE tipo = 'C')
	AND codstatusasignada = 'SIA'
	AND codproductotarjeta <> '007';
	
	IF iCont > 0 THEN
		LET vcodret = '154'; --EL CLIENTE YA CUENTA CON UNA TARJETA DE CREDITO
		RETURN vcodret, cNumProd;
	END IF;

	SELECT COUNT(bin) INTO iContBin
	FROM intercard:"informix".bines 
	WHERE bin = SUBSTR(pnumtarjeta, 1, 6) AND creditodebito = 'C';
	
	--EL BIN DE LA TARJETA NO ES DE CREDITO ES DEBITO.
	IF iContBin <= 0 THEN
		LET vcodret = '1026'; 
		RETURN vcodret, cNumProd;
	END IF;
	
	IF vcodret = '' THEN
		LET vcodret = "000";

		SELECT MAX(secuencia) + 1 INTO vsiguiente
		FROM bdicred:"informix".sd_tarjeta
		WHERE empresa = pempresa AND num_credito = pnum_credito;

		IF vsiguiente IS NULL THEN
			LET vsiguiente = 1;
		END IF;

		--fmj enero 2012, Fecha Expiracion al dia ultimo de mes
		LET vlExpiracion = DATE(mdy(MONTH(pexpiracion), '01', YEAR(pexpiracion)) + 1 units MONTH) - 1; 

		IF pnumproducto = "6001" THEN
			--* La busqueda en la tabla intercard:"informix".segmentoproducto donde el tipo_producto sea igual a C y los limites que anteriormente tenia en el sp
			SELECT LIMIT 1 TRIM(codproductotarjeta) INTO cNumProd
			FROM intercard:"informix".segmentoproducto
			WHERE tipo_producto = "C"
			AND limite_max >= NVL(plimite_aut,0) 
			AND limite_min <= NVL(plimite_aut,0);
			IF NVL(cNumProd,"") = "" THEN
				LET vcodret = "001";
				RETURN vcodret, cNumProd;
			END IF;
		ELSE
			LET cNumProd = pprodtarjeta;
		END IF;
		
		--Se valida que el numero de crédito y tarjeta sean de 12 y 16 digitos respectivamente y solo sean numeros
		IF LENGTH(pnum_credito) = 12 AND LENGTH(pnumtarjeta) = 16 AND bdinteg:"informix".val_num(pnum_credito) AND bdinteg:"informix".val_num(pnumtarjeta) THEN
			INSERT INTO bdicred:"informix".sd_tarjeta
			(empresa,num_credito,secuencia,num_tarjeta,numcte,expiracion,tipo_tarjeta,status_tar,limite_aut,prodtarjeta,nombre)
			--VALUES(pempresa,pnum_credito,vsiguiente,pnumtarjeta,pnumcte,vlExpiracion,ptipo_tar,pstatus,NVL(plimite_aut,0),pprodtarjeta,pnombre);--DSB-17/07/2014
			VALUES(pempresa,pnum_credito,vsiguiente,pnumtarjeta,pnumcte,vlExpiracion,ptipo_tar,pstatus,NVL(plimite_aut,0),cNumProd,pnombre);
		ELSE
			LET vcodret = "242";
			RETURN vcodret, cNumProd;
		END IF;
	
	END IF;
	
END IF --TDC PAY
	
	RETURN vcodret, cNumProd;
END
END PROCEDURE
DOCUMENT
'FOLIO.........: 1417-MTTO-APERTC',
'AUTOR.........: 94565457 - Jose Angel Gaxiola Gaxiola',
'FECHA.........: 29/04/2014 - DSB29042014',
'DESCRIPCIÓN...: PROCEDURE QUE INSERTA EN LA TABLA sd_tarjeta, LOS DATOS PRINCIPALES DE LA TDC, ACTUALIZA LA BD INTERCARD',
'                CON EL PRODUCTO DE LA SD_SEGMENTOS',
'MODIFICACIÓN..: Se comenta UPDATE a intercard:"informix".tarjeta ya que se cambio flujo en bcofi0010701.dll ',
'                Se agrego validacion para que no permita asignar la tarjeta de credito si el cliente ya contiene una. ',
'SUSTENTO......: INC 24 113 Suc_Asignación_incompleta_de_TDC_0001_v1.1',
'SOLICITA......: Cutberto Gonzalez',
'BD............: BDICRED',
'AUTOR.........: 94379114 - Victor Hugo Nuñez',
'FECHA.........: 08/07/2014 - DSB-08/07/2014',
'MODIFICACIÓN..: Se sube la consulta segmentoproducto y se realiza su correcta inserccion en sdtarjeta, se comenta codigo de validacion de existencia en la sdtarjeta',
'SOLICITA......: Cutberto Gonzalez';

CREATE PROCEDURE "informix".altatarcred_v_1_web(pempresa CHAR(3),
											pnum_credito CHAR(20),
											pnumtarjeta	 CHAR(20),
											pnumcte	     CHAR(20),
											pexpiracion	 DATE,
											ptipo_tar    CHAR(1),
											pstatus	     CHAR(1),
											plimite_aut	 MONEY (14,2),
											pprodtarjeta CHAR(3),
											pnombre	     CHAR(104),
											pnumproducto CHAR(4))
----------DATOS QUE REGRESA
RETURNING CHAR(5) AS CodigoRetorno, CHAR(6) AS CodigoProducto;

--DECLARACION DE VARIABLES
DEFINE vcodret		CHAR(5);
DEFINE vsiguiente	INTEGER;
DEFINE vexiste		INTEGER;
DEFINE vsqlerr		INTEGER;
DEFINE vtarjeta     CHAR(20);
DEFINE vlExpiracion DATE;
DEFINE cNumProd		CHAR(3);
DEFINE iCont		INT;
DEFINE iContBin		INT;
--DSB-08/07/2014
DEFINE sNumcte		CHAR(20);
DEFINE sCodstatus	CHAR(3);

--INICIALIZANDO VARIABLES
LET vcodret    = "";
LET vsiguiente = 0;
LET vexiste    = 0;
LET vsqlerr    = 0;
LET vtarjeta   = "";
LET cNumProd   = "";
LET iCont	   = 0;
LET iContBin   = 0;
LET sNumcte	   ="";
LET sCodstatus = "";

BEGIN
	ON EXCEPTION SET vsqlerr
		IF vsqlerr <> 0 THEN
			LET vcodret = vsqlerr;
			RETURN vcodret, cNumProd;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/tmp/altatarcred_out.sql';
	--TRACE ON;
	IF pnumproducto = "6500" THEN --TDC PAY
		LET vcodret = "00000";	ELSE--TDC PAY


		IF pnum_credito IS NULL OR pnum_credito = "" THEN
			LET vcodret = "00100";
			RETURN vcodret, cNumProd;
		END IF;

		IF pnumtarjeta IS NULL OR pnumtarjeta = "" THEN
			LET vcodret = "00101";
			RETURN vcodret, cNumProd;
		END IF;

		IF pnumcte IS NULL OR pnumcte = "" THEN
			LET vcodret = "00102";
			RETURN vcodret, cNumProd;
		END IF;

		SELECT num_tarjeta INTO vtarjeta
		FROM bdicred:"informix".sd_tarjeta
		WHERE empresa = pempresa AND num_tarjeta = pnumtarjeta;

		IF vtarjeta IS NOT NULL THEN
			LET vcodret = "00430";
			RETURN vcodret, cNumProd;
		END IF;
		
		--DSB-08/07/2014
		SELECT numcliente, codstatustarjeta
		INTO sNumcte, sCodstatus
		FROM intercard:"informix".tarjeta
		WHERE numtarjeta = pnumtarjeta;
		
		IF NVL(sNumcte, '') <> '' THEN
			IF sNumcte <> pnumcte THEN
				--ENVIAR CODIGO DE RESPUESTA 151
				LET vcodret = "00151";
				RETURN vcodret, cNumProd;		
			END IF
		END IF;
		
		SELECT COUNT(numtarjeta) INTO iCont
		FROM intercard:"informix".tarjeta 
		WHERE numcliente = pnumcte AND codstatustarjeta IN ('ACT','INA') AND titular = 'T' 
		AND SUBSTR(numtarjeta, 1, 6) IN (SELECT DISTINCT(BIN) FROM intercard:"informix".tipotarjeta WHERE tipo = 'C')
		AND codstatusasignada = 'SIA'
		AND codproductotarjeta <> '007';						   
		
		IF iCont > 0 THEN
			LET vcodret = '00154'; --EL CLIENTE YA CUENTA CON UNA TARJETA DE CREDITO
			RETURN vcodret, cNumProd;
		END IF;

		SELECT COUNT(bin) INTO iContBin
		FROM intercard:"informix".bines 
		WHERE bin = SUBSTR(pnumtarjeta, 1, 6) AND creditodebito = 'C';
		
		--EL BIN DE LA TARJETA NO ES DE CREDITO ES DEBITO.
		IF iContBin <= 0 THEN
			LET vcodret = '01026'; 
			RETURN vcodret, cNumProd;
		END IF;
		
		IF vcodret = '' THEN
			LET vcodret = "00000";

			SELECT MAX(secuencia) + 1 INTO vsiguiente
			FROM bdicred:"informix".sd_tarjeta
			WHERE empresa = pempresa AND num_credito = pnum_credito;

			IF vsiguiente IS NULL THEN
				LET vsiguiente = 1;
			END IF;

			--fmj enero 2012, Fecha Expiracion al dia ultimo de mes
			LET vlExpiracion = DATE(mdy(MONTH(pexpiracion), '01', YEAR(pexpiracion)) + 1 units MONTH) - 1; 

			IF pnumproducto = "6001" THEN
				--* La busqueda en la tabla intercard:"informix".segmentoproducto donde el tipo_producto sea igual a C y los limites que anteriormente tenia en el sp
				SELECT LIMIT 1 TRIM(codproductotarjeta) INTO cNumProd
				FROM intercard:"informix".segmentoproducto
				WHERE tipo_producto = "C"
				AND limite_max >= NVL(plimite_aut,0) 
				AND limite_min <= NVL(plimite_aut,0);
				IF NVL(cNumProd,"") = "" THEN
					LET vcodret = "00001";
					RETURN vcodret, cNumProd;
				END IF;
			ELSE
				LET cNumProd = pprodtarjeta;
			END IF;
			
			--Se valida que el numero de crédito y tarjeta sean de 12 y 16 digitos respectivamente y solo sean numeros
			IF LENGTH(pnum_credito) = 12 AND LENGTH(pnumtarjeta) = 16 AND bdinteg:"informix".val_num(pnum_credito) AND bdinteg:"informix".val_num(pnumtarjeta) THEN
				INSERT INTO bdicred:"informix".sd_tarjeta
				(empresa,num_credito,secuencia,num_tarjeta,numcte,expiracion,tipo_tarjeta,status_tar,limite_aut,prodtarjeta,nombre)
				--VALUES(pempresa,pnum_credito,vsiguiente,pnumtarjeta,pnumcte,vlExpiracion,ptipo_tar,pstatus,NVL(plimite_aut,0),pprodtarjeta,pnombre);--DSB-17/07/2014
				VALUES(pempresa,pnum_credito,vsiguiente,pnumtarjeta,pnumcte,vlExpiracion,ptipo_tar,pstatus,NVL(plimite_aut,0),cNumProd,pnombre);
			ELSE
				LET vcodret = "00242";
				RETURN vcodret, cNumProd;
			END IF;
		
		END IF;
	END IF;	
	RETURN vcodret, cNumProd;
END
END PROCEDURE
DOCUMENT
'FOLIO.........: 1417-MTTO-APERTC',
'AUTOR.........: 94565457 - Jose Angel Gaxiola Gaxiola',
'FECHA.........: 29/04/2014 - DSB29042014',
'DESCRIPCION...: PROCEDURE QUE INSERTA EN LA TABLA sd_tarjeta, LOS DATOS PRINCIPALES DE LA TDC, ACTUALIZA LA BD INTERCARD',
'                CON EL PRODUCTO DE LA SD_SEGMENTOS',
'MODIFICACION..: Se comenta UPDATE a intercard:"informix".tarjeta ya que se cambio flujo en bcofi0010701.dll ',
'                Se agrego validacion para que no permita asignar la tarjeta de credito si el cliente ya contiene una. ',
'SUSTENTO......: INC 24 113 Suc_Asignación_incompleta_de_TDC_0001_v1.1',
'SOLICITA......: Cutberto Gonzalez',
'BD............: BDICRED',
'AUTOR.........: 94379114 - Victor Hugo Nuñez',
'FECHA.........: 08/07/2014 - DSB-08/07/2014',
'MODIFICACION..: Se sube la consulta segmentoproducto y se realiza su correcta inserccion en sdtarjeta, se comenta codigo de validacion de existencia en la sdtarjeta',
'SOLICITA......: Cutberto Gonzalez';

CREATE PROCEDURE "informix".cons_cta_o_tar_per_web(pempresa     CHAR(3),
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
DEFINE vBinTar    	  CHAR(6);
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "00000";
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
LET vBinTar  = '';
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

--SET DEBUG FILE TO "/tmp/cons_cta_o_tar_per.sql";
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
     LET scod_ret = "00110";
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
		
			LET scod_ret = "00858";
			
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
			LET scod_ret = "00002";
			RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
		END IF	
		
        IF s_status IS NULL OR s_status  = "" THEN
           LET scod_ret = "00100"; -- No existe la cuenta
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF

        IF s_status = "2" THEN
           LET scod_ret = "00200"; -- Cuenta Cancelada
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF


        IF s_status = "3" THEN
           LET scod_ret = "00100"; -- Cuenta Bloqueada
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
                  AND prod.producto = mae.producto
                  AND div.empresa = tarj.empresa
                  AND div.divisa = prod.divisa
                  AND tarj.num_tarjeta = tar.numtarjeta
                  AND ((tarj.empresa=pempresa)
               -- AND (tarj.tipo_tarjeta='T')
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
           LET scod_ret = "00100"; -- No existe la cuenta
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF

        IF s_status_cta = "2" THEN
           LET scod_ret = "00200"; -- Cuenta Cancelada
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF


        IF s_status_cta = "3" THEN
           LET scod_ret = "00100"; -- Cuenta Bloqueada
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF

			IF LENGTH(s_cuenta) != cValor  OR bValCuenta  = "F" THEN 
				LET scod_ret = "00002";
			END IF
	
			--dsb 28/05/2012
			IF scod_ret <> "00002" THEN
				SELECT numcuenta INTO s_cuenta FROM intercard:"informix".tarjetacuenta WHERE numtarjeta =  pctatar;
				EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
				INTO bValCuenta;						

				IF LENGTH(s_cuenta) != cValor  OR bValCuenta  = "F" OR s_cuenta IS NULL THEN 
					LET scod_ret = "00002";
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


		--DSB PAY INICIO
		LET vBinTar = SUBSTR(pctatar,1,6);
		
		IF TRIM(vBinTar) = '514014' THEN
		
        FOREACH
		    SELECT tarc.numcuenta, tarc.numtarjeta, tar.numcliente, tar.codstatustarjeta, def.num_producto || " " || def.nombre_prod, div.divisa || " " || div.descripcion,
                  clie.nombre1, clie.nombre2, clie.apell_paterno, clie.apell_materno, cte.fecha_nac, clie.rfc, tar.codstatustarjeta
             INTO s_cuenta, s_tarjeta, s_numcte, s_status, s_producto, s_divisa,
                  s_nombre1, s_nombre2, s_paterno, s_materno, s_fechanac, s_rfc, s_codstatustarjeta
             FROM intercard:"informix".tarjetacuenta tarc,
                  bdinteg:"informix".si_cliente clie,
                  bdinteg:"informix".si_ctepf cte,
                  bdicred:"informix".sd_definicion def,
                  bdinteg:"informix".si_divisas div,
                  intercard:"informix".tarjeta tar
            WHERE clie.numcte = cte.numcte
				  AND tar.numcliente = clie.numcte
                  AND tar.numcliente = cte.numcte
                  AND tarc.numtarjeta = tar.numtarjeta
				  AND div.divisa = '01'
                  AND def.num_producto = '6500'
                  AND ((def.empresa=pempresa)
                  AND (tar.numtarjeta=pctatar))
				  
				  RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta
                  WITH RESUME;
		 END FOREACH
				  
		ELSE

		--DSB PAY FIN

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
                  --AND (tarj.tipo_tarjeta='T')
                  AND (tarj.num_tarjeta=pctatar))



           LET v_cuantos = v_cuantos + 1;
           IF v_cuantos <= pregistros THEN
              CONTINUE FOREACH;
           END IF
           
           
          LET cStatusCred = (SELECT status_cred FROM sd_maecred WHERE num_credito=s_cuenta);
 
          IF cStatusCred NOT IN ("AA","BT","BA","E1","E2","E3") THEN
                LET scod_ret = "00279";
                RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
           END IF

			 --Valida que cuenta sea numerica y longitud de la cuenta DSB 14/03/2012
			EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
			INTO bValCuenta;						

			IF LENGTH(s_cuenta) != cValorCred  OR bValCuenta  = "F" THEN 
				LET scod_ret = "00002";
			END IF
			
			--dsb 28/05/2012
			--Se valida la cuenta en tarjetacuenta 
			IF scod_ret <> "00002" THEN
				SELECT numcuenta INTO s_cuenta FROM intercard:"informix".tarjetacuenta WHERE numtarjeta =  pctatar;
				EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
				INTO bValCuenta;						

				IF LENGTH(s_cuenta) != cValorCred  OR bValCuenta  = "F" OR s_cuenta IS NULL  THEN 
					LET scod_ret = "00002";
				END IF
			END IF
			
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta
                  WITH RESUME;

        END FOREACH
     END IF
  END IF

  END IF;	--DSB PAY
  
END
END PROCEDURE
DOCUMENT
"Especificacion: Se modifico para que consulte el status de la tarjeta en",
"                la tabla intercard:tarjeta y se regrese como codigo de retorno",
"Base de Datos : bdicred",
"AUTOR : Elmer López Valenzuela",
"FECHA : 12/Oct/2016";

CREATE PROCEDURE "informix".sp_buscarctesamigrar_web(pnumcte CHAR(20),iOpcion INTEGER, pSucursal CHAR(4), pNombreEmbozado CHAR(60), pNumEjecutivo CHAR(8))
RETURNING	 CHAR(6), --Codigo Retorno
             CHAR(20), --Numero de Cliente
			 CHAR(20), --Numero de Credito
			 CHAR(60), --Direccion de la sucursal
			 CHAR(4), --Sucursal
			 CHAR(1), -- Bandera Verifica Estatus
			 CHAR(20),--Descripcion Estatus
			 CHAR(20),-- Fecha de solicitud
			 CHAR(10),--MONTO LINEA
			 CHAR(10),--IVA
			 CHAR(10),--INTERES MORATORIO
			 CHAR(10),--INTERES ORDINARIO
			 CHAR(6),--BIN
			 CHAR(8),--CODIGO DEL PRODUCTO
			 CHAR(8); --CLAVE TAJETA
			
             										 
DEFINE iSqlerr				INTEGER;
DEFINE iExiste				INTEGER;
DEFINE cCodret				CHAR(5);
DEFINE cCliente     		CHAR(20);
DEFINE cSucursal    		CHAR(20);
DEFINE iFlagstatus  		CHAR(1);
DEFINE cStatus      		CHAR(20);
DEFINE cFchsoli     		CHAR(20);
DEFINE cNomSuc      		CHAR(60);
DEFINE cLineaCredito 		CHAR(10);
DEFINE cCat          		CHAR(10);
DEFINE cInteresOrdinario 	CHAR(10);
DEFINE cInteresMoratorio 	CHAR(10);
DEFINE cCodBin      		CHAR(6);
DEFINE cCodProd 			CHAR(8);
DEFINE cCodClaveTar 		CHAR(8);
DEFINE cNumCredito 			CHAR(20);
DEFINE cDireccionSucursal 	CHAR(80);
DEFINE cSolOro 				VARCHAR(20);
DEFINE cLineaTeorica 		DECIMAL(18,2);
DEFINE v_valor		 		MONEY(14,2);
DEFINE v_capacidad_pago 	MONEY(14,2);
DEFINE iPlazo 				INTEGER; 
DEFINE sNombreCliente 		CHAR(100);
DEFINE sNumTarjeta			CHAR(16);
DEFINE sMiembro				CHAR(2);
DEFINE sCodRetOro           CHAR(6);
DEFINE sMsjRetOro           VARCHAR(100);

LET sCodRetOro              = '';
LET sMsjRetOro              = '';
--INICIALIZANDO VARIABLES
LET iSqlerr    			= 0;
LET iExiste	   			= 0;
LET cCodret    			= "00000";
LET cCliente  	 		= "";
LET iFlagstatus			= "";
LET cStatus    			= "";
LET cFchsoli   			= "";
LET cSucursal  			= "";
LET cNomSuc    			= "";
LET cLineaCredito		= "";
LET cCat                = "";
LET cInteresOrdinario	= "";
LET cInteresMoratorio	= "";
LET cCodBin				= "";
LET cCodProd			= "";
LET cCodClaveTar		= "";
LET cNumCredito 		= "";
LET cDireccionSucursal 	= "";
LET cSolOro 			= "";
LET cLineaTeorica 		= "";
LET v_valor		  		= 0;
LET v_capacidad_pago 	= 0;
LET iPlazo 		  		= 0;
LET sNombreCliente		= "";
LET sNumTarjeta			= "";
LET sMiembro			= "";


BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/sysifx/Oscar/736/sp_buscarctesamigrar.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pnumcte IS NULL OR pnumcte = '' OR iOpcion is NULL  THEN
		LET cCodret="00100";
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
	

	SELECT numcte,num_credito,nomsuc,sucursal,flagstatussol,status,fchsoli 
	INTO cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli
	FROM bdicred:"informix".sd_ctesamigrar WHERE numcte = TRIM(pnumcte);
   
	IF iOpcion=0  THEN
		IF DBINFO("sqlca.sqlerrd2") = '0' THEN -- No existe el cliente
			LET cCodret="00001";
			RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
		ELSE
			IF (iFlagstatus IS NULL OR iFlagstatus='' OR iFlagstatus=3) THEN
				RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
			END IF;
		END IF;
	END IF;
	
	IF iOpcion=1  THEN -- Solicitud Rechazada
		IF NVL(pSucursal,'') = '' THEN
			LET cCodret="00100";
		ELSE
			SELECT TRIM(suc.nombre), (TRIM(suc.direccion1) || ", " || TRIM(suc.direccion2) || ", " || TRIM(ciu.nombre) || ", " || TRIM(est.nombre)) As Direccion 
			INTO cNomSuc,cDireccionSucursal
			FROM bdinteg: "informix".si_sucursales suc
			INNER JOIN bdinteg: "informix".si_estados est
			ON est.estado = suc.estado
			INNER JOIN bdinteg: "informix".si_ciudades ciu
			ON suc.ciudad = ciu.ciudad and suc.estado = ciu.estado
			WHERE  suc.empresa = '001'
			AND sucursal = pSucursal
			AND suc.tpo_sucursal = 'S';
			
			UPDATE  bdicred:"informix".sd_ctesamigrar SET  flagstatussol='3',status="Rechazada",fchsoli=TO_CHAR(current), sucursal = pSucursal, nomsuc =  cNomSuc, domsuc = TRIM(cDireccionSucursal) WHERE numcte=pnumcte;
		END IF;
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
   
	IF iOpcion=2 THEN -- Solicitud Aceptada
		IF NVL(pSucursal, '') = '' OR NVL(pNombreEmbozado,'') = '' OR NVL(pNumEjecutivo,'') = '' THEN
			LET cCodret="00100";
		ELSE
			SELECT TRIM(suc.nombre), (TRIM(suc.direccion1) || ", " || TRIM(suc.direccion2) || ", " || TRIM(ciu.nombre) || ", " || TRIM(est.nombre)) As Direccion 
			INTO cNomSuc,cDireccionSucursal
			FROM bdinteg: "informix".si_sucursales suc
			INNER JOIN bdinteg: "informix".si_estados est
			ON est.estado = suc.estado
			INNER JOIN bdinteg: "informix".si_ciudades ciu
			ON suc.ciudad = ciu.ciudad and suc.estado = ciu.estado
			WHERE  suc.empresa = '001'
			AND sucursal = pSucursal
			AND suc.tpo_sucursal = 'S';			
			
			SELECT TRIM(apell_paterno) || " " || TRIM(apell_materno) || " " || TRIM(nombre1) || " " || TRIM(nombre2) AS Nombre, b.num_tarjeta , SUBSTR(YEAR(c.fecha_apertura),3,2)
			INTO sNombreCliente, sNumTarjeta, sMiembro
			FROM bdicred:"informix".sd_ctesamigrar a			
			INNER JOIN bdicred:"informix".sd_tarjeta b ON a.num_credito = b.num_credito
			INNER JOIN bdicred:"informix".sd_maecred c ON c.num_credito = a.num_credito
			WHERE a.numcte = pnumcte 
			AND a.num_credito = cNumCredito 
			AND b.numcte = a.numcte
			AND c.numcte = b.numcte
			AND b.status_tar in ('A','C') 
			AND b.secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta b WHERE B.num_credito = cNumCredito);  
			
			UPDATE  bdicred:"informix".sd_ctesamigrar SET  flagstatussol = '1',status = "Aceptada", fchsoli = TO_CHAR(current), sucursal = pSucursal, nomsuc =  cNomSuc, domsuc = TRIM(cDireccionSucursal) 
			WHERE numcte = pnumcte;
			
			LET sNombreCliente = REPLACE(sNombreCliente,"  ", " ");
			
			--INSERT INTO bdicred:"informix".sd_credito_upgrade(empresa, num_credito, numcte, numerotarjeta, numero_credito_upgrade, numerotarjeta_upgrade, num_producto_upgrade, tipotar, nombre, nombre_embosado, bandtarjpersonal, tipo_proceso, nombre_archivo, master, tipo_dom, miembro, resultado, bclonadocompleto, user_insert, fecha_insert, fecha_cancelaupgrade)
			--VALUES('001', cNumCredito, pnumcte, sNumTarjeta, '', '', '8100', 'TIT', TRIM(sNombreCliente), TRIM(pNombreEmbozado), '1', '1', '', '1', '1', sMiembro, '0', '0', pNumEjecutivo,CURRENT,NULL);

            EXECUTE PROCEDURE "informix".sp_graba_prod_upgrade('001', cNumCredito, pnumcte, sNumTarjeta, 'TIT', TRIM(sNombreCliente), 
             TRIM(pNombreEmbozado), '1', '1', pNumEjecutivo, '3', '', '8100') INTO sCodRetOro, sMsjRetOro;
			 LET sCodRetOro = SUBSTR(sCodRetOro, 2,5);
		
		    IF sCodRetOro <> "00000" THEN  -- Error en sp_graba_prod_upgrade
                LET cCodret = sCodRetOro;    
                UPDATE  bdicred:"informix".sd_ctesamigrar SET  flagstatussol = null,status = '', fchsoli = '' 
                WHERE numcte = pnumcte;
                    
                RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
            END IF
			
		END IF;		
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
  
	IF iOpcion=3 THEN
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
  
	IF iOpcion=4 THEN
	  --SE OBTIENE EL VALOR DE LA TASA DE INTERES ORDINARIO
	  SELECT a.valor,b.cat_caratula,b.monto_min_cred INTO cInteresOrdinario,Ccat,cLineaCredito
	  FROM bdinteg:"informix".si_fechavalor AS a,bdicred:"informix".sd_definicion AS b
	  WHERE a.tasa = b.cod_tasa_base AND fecha = (SELECT MAX(fecha)
	  FROM bdinteg:"informix".si_fechavalor
	  WHERE  tasa=b.cod_tasa_base    --
	  AND b.num_producto = '8100');

	--SE OBTIENE EL VALOR DE LA TASA DE INTERES MORATORIO
	  SELECT a.valor INTO cInteresMoratorio
	  FROM bdinteg:"informix".si_fechavalor AS a, bdicred:"informix".sd_definicion AS b
	  WHERE a.tasa = b.cod_tasa_mora AND fecha = (SELECT MAX(fecha)
	  FROM bdinteg:"informix".si_fechavalor 
	  WHERE  tasa=b.cod_tasa_mora AND b.num_producto = '8100');  -- FMV 13-MAY-11 SE OMITE a.tasa para mostrar las tasas en reporte
	  LET cInteresMoratorio = cInteresMoratorio - cInteresOrdinario;
		IF cInteresMoratorio < 0 THEN
				LET cInteresMoratorio= cInteresMoratorio * -1;
		END IF;
	RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
 
	IF iOpcion=5 THEN
		SELECT codproductotarjeta,clave_tipotarjeta,bin  
		INTO cCodProd,cCodClaveTar,cCodBin 
		FROM intercard:"informix".tipotarjeta 
		WHERE codproductotarjeta = '005'
		AND Tipo = 'C'
		AND clave = '007';
		
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
	
	IF iOpcion = 6 THEN
		IF NVL(pnumcte,'') = '' THEN
			LET cCodret="00100";
		ELSE
			DELETE bdicred:"informix".sd_credito_upgrade WHERE numcte = pnumcte AND num_credito = cNumCredito;		
			UPDATE bdicred:"informix".sd_ctesamigrar SET sucursal = '',nomsuc = '',domsuc = '',flagstatussol = null,status = '',fchsoli = '' WHERE numcte = pnumcte;
			RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
		END IF;
	END IF;
	
  
END;
END PROCEDURE
DOCUMENT
'Se crea SP para consultar los  de clientes candidatos a actualizar su Tarjeta de Credito Visa Bancoppel a Tarjeta de Credito Oro Bancoppel',
'asi como actualizar su estatus (Aceptada, Rechazada) e insertar la solicitud.',
'AUTOR : Oscar Marquez 98681011',
'FECHA : 26/03/2021',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_pflex_disposicion_apoyo(pEmpresa VARCHAR(3),cNumCte CHAR(20),cCtaPPF CHAR(20),dtotal_prestamo DECIMAL(18,2),pMontoSol INTEGER,cTransacc VARCHAR(4),pEjecutivo VARCHAR(8))

RETURNING CHAR(5),SMALLINT,MONEY(18,2),CHAR(20);       -- Codigo de Retorno

DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr     		INTEGER;
DEFINE cErrorInfo   		VARCHAR(255,1);
DEFINE cCodRet      		CHAR(6);
DEFINE cMen_ret 			CHAR(80);
DEFINE wBegin             	CHAR(1);

DEFINE cProducto            CHAR(4);		
DEFINE cDivisa              CHAR(2);		
DEFINE cSucursal            CHAR(4);	
DEFINE pNombrePres			CHAR(50);
DEFINE iPlazo				INTEGER;
DEFINE mComisionApertura	MONEY(14,2);
DEFINE iFrecuencia       	INTEGER;
DEFINE dFechaT              DATE;
DEFINE pCuentaCap			CHAR(20);
DEFINE mTasaInteresProd		DECIMAL(18,2);	
DEFINE mTasaInteres         DECIMAL(18,2);	
DEFINE cFactor	            CHAR(1);		
DEFINE mSobreTasa           DECIMAL(18,2);	
DEFINE sDiaCorte            SMALLINT;		
DEFINE cPeriodoPag			CHAR(1);		
DEFINE cCodRet2             CHAR(6);
DEFINE iNum_periodos        INTEGER;
DEFINE dtFecha_cuota        DATE;
DEFINE dSdo_inicial         MONEY(14,2);
DEFINE dPago_mensual        MONEY(14,2);
DEFINE dMto_Interes         MONEY(14,2);
DEFINE dIva_interes         MONEY(14,2);
DEFINE dCapital             MONEY(14,2);
DEFINE dSdo_final           MONEY(14,2);
DEFINE sDias_periodo        SMALLINT;
DEFINE dtFecha_Aper			DATE;
DEFINE dtFechaAp			DATE;
DEFINE dfechavenc			DATE;
DEFINE cNumMesesPagos   	CHAR(3);
DEFINE mTasaMora			DECIMAL(18,2);
DEFINE mTasaMoraProd		DECIMAL(18,2);
DEFINE dIvaSuc              DECIMAL(5,3);
DEFINE mTotalPagar			DECIMAL(18,2);
DEFINE dPagoReq      		DECIMAL(18,2);
DEFINE cMensajeRet     		VARCHAR(80,1);
DEFINE vCatFinal            DECIMAL(21,10);
DEFINE cNumeroFolio 		CHAR(16);		-- FOLIO PARA REGISTRAR EL ABONO
DEFINE cCodRet3				VARCHAR(6);		-- CODIGO DE RETORNO ABONOREF BDICHEQ
DEFINE contproyecta			SMALLINT;
DEFINE pMensualidad			MONEY(18,2);

DEFINE fg_prestamo			SMALLINT;
DEFINE dDisp_pAnterior		DECIMAL(18,2);
DEFINE dCountExists			SMALLINT;
DEFINE cPeriodo_Plazo       CHAR(1);
DEFINE cTp_Dias_Fecha_Pago  CHAR(1);
DEFINE iFrecuencia_Pgo		INTEGER;
DEFINE cManeja_Linea        CHAR(1);
DEFINE cStatusCred			CHAR(2); --RQM 10 1155
-- Programa apoyo 2020
DEFINE wbandera_apoyo 		CHAR(1);
DEFINE dMontoCod089_5		DECIMAL(18,2);
DEFINE dMontoCod089_8		DECIMAL(18,2);
DEFINE dtFechaHoy 			DATE;
DEFINE banderaDispone		SMALLINT;

LET iSqlErr         		= 0;
LET iIsamErr        		= 0;
LET cErrorInfo      		= "";
LET cCodRet         		= "000000";
LET cMen_ret     			= "Proceso Exitoso";

LET cCodRet2             	= "000000";
LET cProducto  				= "";
LET cDivisa    				= "";
LET cSucursal				= "";
LET mComisionApertura      	= 0;
LET pNombrePres 			= "";
LET iPlazo 					= 0;
LET mComisionApertura      	= 0;
LET iFrecuencia 			= 0;
LET dFechaT  				= DATE(1);
LET pCuentaCap  			= "";
LET mTasaInteresProd		= 0;
LET mTasaInteres        	=0;
LET cFactor	  				= "";
LET mSobreTasa   			= 0;
LET sDiaCorte				= 0;
LET cPeriodoPag				= "";
LET iNum_periodos           = 0;
LET dtFecha_cuota      	   	= DATE(1);
LET dSdo_inicial      	   	= 0;
LET dPago_mensual      	   	= 0;
LET dMto_Interes      	   	= 0;
LET dIva_interes      	   	= "";
LET dCapital      	   		= "";
LET dSdo_final      	    = 0;
LET sDias_periodo      	    = 0;
LET dtFecha_Aper      	    =DATE(1);
LET dtFechaAp				=DATE(1);
LET dfechavenc				=DATE(1);
LET cNumMesesPagos  		= "";
LET mTasaMora				=0;
LET mTasaMoraProd			=0;
LET dIvaSuc					=0;
LET mTotalPagar				=0;
LET dPagoReq				=0;
LET cMensajeRet         	= "Se realizo el calculo correctamente";
LET vCatFinal 				=0;
LET cNumeroFolio			= "";
LET cCodRet3				= '000';
LET contproyecta			=0;
LET pMensualidad 			=0;

LET fg_prestamo				=0;
LET dDisp_pAnterior			=0;	
LET dCountExists			=0;
LET cPeriodo_Plazo			=0;
LET cTp_Dias_Fecha_Pago  	= "";
LET iFrecuencia_Pgo			=0;
LET cManeja_Linea        	="";
LET cStatusCred			    ="";      --RQM 10 1155
LET wbandera_apoyo			= "";
LET dtFechaHoy 				= DATE(1);
LET dMontoCod089_5			= 0;
LET dMontoCod089_8			= 0;
LET banderaDispone			= 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
   IF iSqlErr != 0 THEN 
		RETURN iSqlErr,fg_prestamo,pMensualidad ,pCuentaCap;
   END IF;
END EXCEPTION;

ON EXCEPTION IN (-535)
  LET wBegin = "S";
  COMMIT WORK;
  BEGIN WORK;
END EXCEPTION WITH RESUME;

LET wBegin = "N";


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/informix/Rebeca/sp_pflex_disposicion.out';
--TRACE ON;

-- Obtiene las diferentes fechas del sistema
SELECT fecha_hoy INTO dtFechaHoy FROM bdicred:"informix".sd_fechas;



--INTERES ORDINARIO
SELECT a.num_producto, a.divisa, c.sucursal,nombre_prod, c.plazo,cobro_comis_apertura, --CASE WHEN c.periodo_plazo = 'M' THEN 1 ELSE 2 END Frecuencia,
	   c.periodo_plazo Frecuencia, c.tasa_interes, c.factor_sobretasa, c.sobretasa, 
	   a.dia_cuota, c.periodo_plazo,c.status_cred
INTO cProducto, cDivisa, cSucursal,pNombrePres,iplazo,mComisionApertura,cPeriodo_Plazo,
     mTasaInteres, cFactor, mSobreTasa, sDiaCorte, cPeriodoPag, cStatusCred
FROM bdicred:"informix".sd_definicion a
INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.empresa = a.empresa AND b.num_producto = a.num_producto
INNER JOIN bdicred:"informix".sd_maecredcrd c ON c.empresa = a.empresa AND c.num_producto = a.num_producto AND c.num_credito = b.num_solicitud
WHERE b.empresa = pEmpresa AND b.num_solicitud = cCtaPPF;
	

	SELECT fecha_proceso  INTO dtFechaAp --RQM 10 1155
	FROM bdicred:"informix".sd_maecredanexocrd  --Fecha proceso credito
	WHERE empresa = pEmpresa
	AND num_credito = cCtaPPF;


--	Obtiene la fecha habil de proximo pago y fecha vencimiento
CALL bdicred:"informix".monthadd(dtFechaAp,1) RETURNING dFechaT;
CALL bdicred:"informix".monthadd(dtFechaAp,36) RETURNING dFechaVenc;

CALL bdicred:"informix".sp_valfechabil(dFechaT,'+') RETURNING cCodRet, dFechaT;
CALL bdicred:"informix".sp_valfechabil(dFechaVenc,'+') RETURNING cCodRet, dFechaVenc;


SELECT num_cta  INTO pCuentaCap
FROM bdicred:sd_ctascarg 
WHERE naturaleza = 'A' AND num_credito = cCtaPPF;

IF cPeriodo_Plazo = 'M' THEN		--- Frecuencia
	LET iFrecuencia = 1;
ELSE
	LET iFrecuencia = 2;
END IF;

LET mTasaInteresProd = mTasaInteres;

IF cFactor = "+" THEN
	LET mTasaInteres = mTasaInteres + mSobreTasa;
ELIF cFactor = "-" THEN
	LET mTasaInteres = mTasaInteres - mSobreTasa;
ELIF cFactor = "*" THEN
	LET mTasaInteres = mTasaInteres * mSobreTasa;
ELSE
	LET mTasaInteres = mTasaInteres / mSobreTasa;
END IF;

SELECT a.iva
 INTO dIvaSuc
 FROM bdinteg:"informix".si_sucursales a
WHERE a.sucursal = cSucursal
  AND a.empresa  = pEmpresa;
  

-- Programa Apoyo. Consulta si credito pertenece al programa apoyo.
SELECT bandera INTO wbandera_apoyo FROM bdicred:sd_programa_apoyo2020crd
 WHERE num_credito = cCtaPPF;
  
  
IF pMontoSol = 0 THEN
	--LET pMontoSol = dtotal_prestamo;
	LET banderaDispone = 1;
	LET dDisp_pAnterior = dtotal_prestamo;
ELSE
  
-- Se divide disposicion del prestamo flexible en Deuda Anterior y Disposicion Nueva
LET dDisp_pAnterior = dtotal_prestamo - pMontoSol; -- Monto de la disposicion anterior: Deuda vieja  
END IF;
  
FOREACH 
	--SE OBTIENE CON EL PROYECTA PRESTAMO CADA UNA DE LAS MENSUALIDADES PARA SUMARLAS y CALCULAR EL MONTO TOTAL A PAGAR
	EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (dtotal_prestamo,iPlazo,0,cProducto,cSucursal,1,0,cCtaPPF,"",iFrecuencia)
	INTO cCodRet,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
	dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos
	
	--SE VALIDAD PARA VER SI EL PROYECTA PRESTAMO SE EJECUTO CORRECTAMENTE
	IF cCodRet::INTEGER <> 0  THEN				
		LET cCodRet = "000001";  --Error en sp_proyecta_prestamos
		LET fg_prestamo  = 0;	
	END IF;
	--VARIABLE QUE GUARDA LA SUMA DE LAS MENSUALIDADES
	LET mTotalPagar = mTotalPagar + dPago_mensual::DECIMAL(18,2);	
	
	IF contproyecta = 0 THEN
		LET pMensualidad =  dPago_mensual;
	END IF;
	
	LET contproyecta = contproyecta +1;
END FOREACH;

LET dPagoReq = dtotal_prestamo / ((1- pow((1+((mTasaInteres /100)/( iFrecuencia * 12 ))),-iplazo)) / ((mTasaInteres /100)/( iFrecuencia * 12 )) ) ;

EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir_pp(dtotal_prestamo,dPagoReq,iplazo,(12 * iFrecuencia),mComisionApertura) 
INTO cCodRet2,cMensajeRet,vCatFinal;

IF cCodRet2::integer  <> 0 THEN
	LET cCodRet = "000002";  --Error en sp_calculo_tiir_pp
	LET fg_prestamo  = 0;				
ELSE
	BEGIN WORK;

	
	SELECT count(num_credito) INTO dCountExists FROM bdicred:sd_maecredcrd_flex
 	 WHERE num_credito = cCtaPPF AND fecha_insert = dtFechaHoy;
	
	IF dCountExists = 0 THEN
	--IF dDisp_pAnterior = 0 THEN -- Respalda solo cuando sea 1era disposicion. Para 2das disposiciones, respalda antes.

		--Respaldo de info productiva
		INSERT INTO bdicred:"informix".sd_maecredcrd_flex
		SELECT dtFechaHoy,* FROM  bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_Credito = cCtaPPF;	

		INSERT INTO bdicred:"informix".sd_maesdoscrd_flex
		SELECT dtFechaHoy, pMontoSol, * FROM  bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_Credito = cCtaPPF;	

		INSERT INTO bdicred:"informix".sd_maecredanexocrd_flex
		SELECT dtFechaHoy,* FROM  bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_Credito = cCtaPPF;	

		INSERT INTO bdicred:"informix".sd_amortiza_creditocrd_flex
		SELECT dtFechaHoy,* FROM  bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_Credito = cCtaPPF;	
		--Se agrega campos "acepto_incremento y linea_prestamo_anterior" - RQM 10 1543
		INSERT INTO bdicred:"informix".sd_linea_prestamo_flex
		SELECT dtFechaHoy,  empresa , num_credito ,  monto_linea ,fecha_otorga,linea_disponible, sec_credito, fecha_cancela, fecha_ult_mod ,  disposicion_activada, acepto_incremento,linea_prestamo_anterior
		 FROM  bdicred:"informix".sd_linea_prestamo WHERE num_Credito = cCtaPPF;	

	END IF;		

	--Limpia tablas productivas	
	DELETE FROM  bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_Credito = cCtaPPF;	
	
	DELETE FROM  bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_Credito = cCtaPPF;	

	DELETE FROM  bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_Credito = cCtaPPF;

	DELETE FROM  bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_Credito = cCtaPPF;

	--Genera Nuevos registros
	INSERT INTO "informix".sd_maecredcrd(
										empresa,                        num_credito,
										num_producto,                   ejecutivo,
										numcte,                         aval_cte,
										aval_linea,                     divisa,
										sucursal,                       id_origen,
										origen,                         cod_tipo_linea,
										cod_linea,                      status_cred,
										bandera_renovac,                bandera_prorroga,
										periodo_plazo,                  plazo,
										fecha_apertura,                 fecha_vencim,
										period_pago_cap,                period_pag_int,
										dias_trasp_cap,                 dias_trasp_int,
										tasa_fija_o_var,                cod_tasa_base,
										factor_sobretasa,               sobretasa,
										tasa_interes,                   cod_tasa_mora,
										sobretasa_mora,                 fact_sobret_mora,
										tasa_moratorios,                tasa_preferencial,
										sobretasa_preferencial,         factor_preferencial,
										valor_preferencial,             fecha_pago_cap,
										fecha_pago_int,                 es_fisica,
										bandera_fi_fo,                  actividad,
										tipo_calculo,                   num_aper_ant,
										rev_tasa_var_per,               dia_para_revisar,
										cod_prod,                       bandera_ministra,
										credito_externo,                califica_riesgo,
										cod_agricola,                   pagos_sostenidos,
										campo_trab1,                    campo_trab2,
										campo_trab3,                    campo_trab4
										,cuenta_clabe)
								SELECT  {+INDEX (bdicred:sd_cattipopago)}
										sol.empresa                		,cCtaPPF
									   ,sol.num_producto                ,NVL(anx.ejecutivo_sol,'')
									   ,sol.numcte                      ,''
									   ,''                              ,NVL(def.divisa,1)
									   ,NVL(def.sucursal,'')            ,''
									   ,''                              ,''
									   ,''                              ,'AA'
									   ,'S'                             ,'N'
									   ,SUBSTR(tipo_pago,1,1)		   
									   ,iplazo
									   ,dtFechaAp  					    ,dFechaVenc
									   ,NVL(def.period_pago_cap,'')     ,NVL(def.period_pag_int,'')
									   ,NVL(def.dias_trasp_cap,0)    	,NVL(def.dias_trasp_int,0)
									   ,NVL(def.tasa_fija_o_var,'')     ,NVL(def.cod_tasa_base,'')
									   ,NVL(def.factor_sobretasa,'')    ,NVL(def.sobretasa,'')
									   ,mTasaInteresProd                ,NVL(def.cod_tasa_mora,'')
									   ,NVL(def.sobretasa_mora,0)       ,NVL(def.fact_sobret_mora,'')
									   ,NVL(mTasaMoraProd,0)            ,''
									   ,0                               ,''
									   ,0                               ,dFechaT
									   ,dFechaT							,NVL(tip.es_fisica,'')
									   ,''                              ,''
									   ,NVL(def.tipo_calculo,'')        ,dIvaSuc
									   ,''                              ,NVL(def.dia_para_revisar,0)
									   ,''                              ,SUBSTR(tipo_pago,1,1)	--cPeriodoPag
									   ,''                              ,''
									   ,''                              ,0
									   ,0                               ,0
									   ,''                              ,''
									   ,def.cuenta_clabe
									   FROM bdisolic:"informix".ss_solicitudes sol
									   INNER JOIN "informix".sd_maecredcrd_flex def ON def.empresa = sol.empresa AND def.num_Credito = sol.num_solicitud and def.fecha_insert = dtFechaHoy
									   INNER JOIN bdisolic:"informix".ss_anexosol anx ON anx.num_solicitud = sol.num_solicitud AND anx.empresa = sol.empresa
									   INNER JOIN bdinteg:"informix".si_cliente cli ON cli.empresa = sol.empresa AND cli.numcte = sol.numcte
									   INNER JOIN bdinteg:"informix".si_tipper tip ON tip.tpo_persona = cli.tpo_persona
									   INNER JOIN "informix".sd_cattipopago pago ON valor = iFrecuencia
									   WHERE  sol.num_solicitud = cCtaPPF AND sol.empresa = pEmpresa;	

	INSERT INTO "informix".sd_maesdoscrd (
										empresa, 			num_credito,
										fecha_ult_mov, 		sdo_int_anticip,
										sdo_int_ant_dev, 	sdo_intereses,
										sdo_dia_ant_int, 	sdo_mes_ant_int,
										sdo_acum_mes_int, 	sdo_retenido,
										sdo_acum_cap_int, 	sdo_exig_int,
										sdo_no_exig, 		provision_normal,
										dias_acum_int, 		sdo_moratorio,
										sdo_dia_ant_mor, 	sdo_mes_ant_mor,
										sdo_contab_mora, 	dias_acum_mora,
										sdo_capital, 		sdo_cap_insoluto,
										sdo_dia_ant_cap, 	sdo_mes_ant_cap,
										sdo_acum_mes_cap, 	mto_capitalizado,
										mto_ministra_cap, 	cargos_dia_cap,
										abonos_dia_cap, 	cargos_mes_cap,
										abonos_mes_cap, 	dias_acum_cap,
										monto_vencido, 		mto_venc_trasp,
										monto_financiado, 	monto_reservado,
										sdo_acum_vencido, 	dias_acum_intper,
										sdo_global_int, 	sdo_acum_intper,
										monto_otorgado, 	provi_venc_normal,
										provi_venc_anticip, cap_tras_no_venci,
										mto_venc_int, 		mto_venc_tra_int,
										mto_finan_vdo, 		mto_reser_int,
										mto_fin_ven_trasp, 	mto_fin_vig_trasp,
										int_tra_no_exig, 	sdo_trab4)
								SELECT sol.empresa          	,cCtaPPF
										,dtFechaAp           	,0
										,0                      ,dMontoCod089_5
										,0                      ,0
										,0                      ,0
										,0                      ,0
										,0                      ,dMontoCod089_5
										,0                      ,0
										,0                      ,0
										,0                      ,0
										,dtotal_prestamo        ,dtotal_prestamo
										,0                      ,0
										,0                      ,mTotalPagar
										,0                      ,0
										,0                      ,0
										,0                      ,0
										,0                      ,0
										,0                      ,0
										,0                      ,0
										,dMontoCod089_8			,0
					                    ,dtotal_prestamo		,0
										,0                      ,0
										,0                      ,0
										,0                      ,0
										,0                      ,0
										,0                      ,0
										FROM   bdisolic:"informix".ss_solicitudes sol
										WHERE  sol.num_solicitud = cCtaPPF AND sol.empresa = pEmpresa;

	
	SELECT frecuencia_pgo INTO iFrecuencia_Pgo FROM bdisolic:ss_sol_nomina WHERE empresa = pEmpresa AND num_solicitud = cCtaPPF AND numcte = cNumCte;
	LET iFrecuencia_Pgo = NVL(iFrecuencia_Pgo,0);
	SELECT maneja_linea INTO cManeja_Linea FROM bdicred:sd_definicion WHERE num_producto = cProducto;
	LET cManeja_Linea = NVL(cManeja_Linea,'0');
	--(CASE WHEN NVL(nom.Frecuencia_pgo,0) = 0  THEN NVL(def.maneja_linea::INTEGER,0) ELSE  NVL(nom.Frecuencia_pgo,0) END) ,
	
	IF iFrecuencia_Pgo = 0 THEN
		LET cTp_Dias_Fecha_Pago = cManeja_Linea;
	ELSE
		LET cTp_Dias_Fecha_Pago = iFrecuencia_Pgo::CHAR;
	END IF;
	
	INSERT INTO "informix".sd_maecredanexocrd(
										empresa, 				 		
										num_credito,
										localidad,              		
										dia_corte,
										dias_gracia_mora, 		 		
										tp_dias_calc_mora,
										dias_fecha_max_pago,	 		
										tp_dias_fecha_pago,
										cod_tasa_base_cte, 	 			
										factor_sobretasa_cte,
										sobretasa_cte, 		 			
										tasa_interes_cte,
										fecha_vencto, 			 		
										prox_fecha_pago,
										fecha_proceso,			 		
										fecha_ult_pago,
										nombre_pres, 					
										cat)
								SELECT 	pEmpresa,
										cCtaPPF,
										"",
										DAY(dtFechaAp),
										NVL(b.dias_gracia_mora,0),
										'',
										DAY(dtFechaAp),
										--(CASE WHEN NVL(nom.Frecuencia_pgo,0) = 0  THEN NVL(def.maneja_linea::INTEGER,0) ELSE  NVL(nom.Frecuencia_pgo,0) END) ,
										cTp_Dias_Fecha_Pago,
										NVL(b.cod_tasa_base_cte,''),
										NVL(b.factor_sobretasa_cte,''),
										NVL(b.sobretasa_cte,0),
										mTasaInteresProd,
										"",
										dFechaT,
										dtFechaAp,
										"",
										pNombrePres, 
										vCatFinal
								FROM "informix".sd_definicion def
								INNER JOIN bdisolic:"informix".ss_solicitudes c ON c.empresa = def.empresa AND c.num_producto = def.num_producto
								INNER JOIN bdicred:"informix".sd_maecredanexocrd_flex b on b.empresa = def.empresa and b.num_credito = c.num_solicitud and b.fecha_insert = dtFechaHoy
								LEFT JOIN  bdisolic:"informix".ss_sol_nomina nom ON (nom.empresa = c.empresa AND nom.num_solicitud = c.num_solicitud)	
								WHERE c.empresa = pEmpresa AND c.num_solicitud = cCtaPPF;

	INSERT INTO "informix".sd_amortiza_creditocrd (
										empresa, 			num_credito,					
										fecha_cuota, 		tipo_cuota,
										capital_mto_cuota, 	capital_debe,
										capital_pagado, 	capital_status,
										capital_status_ant, capital_fecha_pago,
										interes_debe, 		interes_pagado,
										interes_status, 	interes_status_ant,
										interes_fecha_pago, iva_debe,
										iva_pagado, 		iva_status,				
										iva_status_ant, 	iva_fecha_pago,
										mora_provi_ordi, 	mora_provi_cope,
										mora_sdo_ordi, 		mora_sdo_ordi_pag,
										mora_sdo_cope, 		mora_sdo_cope_pag,
										mora_bonificado, 	mora_status,
										mora_iva_debe, 		mora_iva_pagado,
										mora_iva_status, 	mora_iva_fecha_pago,
										num_pago, 			campo_trabajo1,
										campo_trabajo2, 	campo_trabajo3,		campo_trabajo4)
								VALUES (pEmpresa,			cCtaPPF,
										dFechaT,			"3",
										pMensualidad,		0,
										0,					"3",
										"3",				"",
										dMontoCod089_5, 	0,			
										"1",				"1",
										"",					0,
										0,					"1",
										"1",				"",
										0,					0,
										0,					0,
										0,					0,
										0,					"1",
										0,					0,
										"1",				"",
										1,					0,
										0,					"",		"");
	-- SE GENERA EL FOLIO
	CALL bdicheq:"informix".sp_generafolionomina(pEjecutivo) RETURNING cCodRet2, cNumeroFolio;

	IF cCodRet2::integer  <> 0 THEN
		LET cCodRet = "000003";  --Error en sp_generafolionomina
		LET fg_prestamo  = 0;				  
	ELSE
		--LET cTransacc = "0247";
		
		IF pMontoSol > 0 THEN
		--EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa, cCtaPPF, cProducto, 66, "002", dtFechaAp, dtotal_prestamo, cNumeroFolio,
		EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa, cCtaPPF, cProducto, 66, "002", dtFechaAp, pMontoSol, cNumeroFolio,
								cSucursal, cDivisa, "0000",'DISPOSICION','')
		 INTO cCodRet, cErrorInfo;
		END IF;
		IF cCodRet::integer  <> 0 THEN
			LET cCodRet = "000004"; --Error en genmovcrd
			LET fg_prestamo  = 0;	
			ROLLBACK WORK;	
			IF (wBegin = "S") THEN
			   BEGIN WORK;
			END IF;
		ELSE			
		
			IF dDisp_pAnterior > 0 THEN -- Existe saldo pendiente de disposicion anterior (deuda vieja)
				-- Realiza cargo de la deuda vieja. 
				EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa, cCtaPPF, cProducto, 119, "002", dtFechaAp, dDisp_pAnterior, cNumeroFolio,
									cSucursal, cDivisa, "0000",'DISPOSICION','')
					INTO cCodRet, cErrorInfo;
				
				IF cCodRet::integer  <> 0 THEN
					LET cCodRet = "000004"; --Error en genmovcrd
					LET fg_prestamo  = 0;	
					ROLLBACK WORK;	
					IF (wBegin = "S") THEN
						BEGIN WORK;
					END IF;
				ELSE
					LET cCodRet = "000000";
	 
				END IF;		
			END IF;
			
			IF cCodRet::integer = 0 THEN
			  IF banderaDispone = 0 THEN
				-- SE GENERA EL ABONO 
				CALL bdicheq:"informix".abono_ref (pEmpresa, cSucursal, pEjecutivo, cTransacc, cTransacc, cNumeroFolio, pCuentaCap, 0,
					pMontoSol, pMontoSol, 0, 0, 0, "01", cCtaPPF||" "||pNombrePres, '0', pEjecutivo) RETURNING cCodRet3;
					--dtotal_prestamo, dtotal_prestamo, 0, 0, 0, "01", cCtaPPF||" "||pNombrePres, '0', pEjecutivo) RETURNING cCodRet3;
			  END IF; 
				IF cCodRet3::integer  <> 0 THEN
					LET cCodRet = "000005"; --Error en abono_ref
					LET fg_prestamo  = 0;	
					ROLLBACK WORK;	
					IF (wBegin = "S") THEN
						BEGIN WORK;
					END IF;				
				ELSE	
					UPDATE bdicred:sd_linea_prestamo SET linea_disponible = (linea_disponible - dtotal_prestamo), sec_credito = (sec_credito+1), fecha_ult_mod = current 
								WHERE EMPRESA = '001'
								AND NUM_CREDITO = cCtaPPF;		
					LET fg_prestamo  = 1;	
				END IF;
			END IF;
		END IF;	
	END IF;		

	COMMIT WORK;
	IF (wBegin = "S") THEN
		BEGIN WORK;
	END IF;
END IF;	

IF cCodRet='000' THEN
	LET cCodRet='00000';
END IF;

RETURN cCodRet,fg_prestamo,pMensualidad ,pCuentaCap;
     
END
END PROCEDURE
DOCUMENT
'Autor: NA',
'Folio: RQM 10 1543 - 65670 - Incremento en la linea de credito Prestamo Digital',
'Fecha: 14-08-2023',
'Modificacion: Se agrego campo acepto_incremento y linea_prestamo_anterior en el SELECT de la tabla bdicred:informix.sd_linea_prestamo en la linea 291.',
'Base de datos: bdicred',
'Solicito: ';

CREATE PROCEDURE "informix".sp_pflex_disposicion(pEmpresa VARCHAR(3),cNumCte CHAR(20),cCtaPPF CHAR(20),dtotal_prestamo DECIMAL(18,2),pMontoSol INTEGER,cTransacc VARCHAR(4),
												 pEjecutivo VARCHAR(8), pCanal SMALLINT, pId_atm CHAR(6))

RETURNING CHAR(5),SMALLINT,MONEY(18,2),CHAR(20);       -- Codigo de Retorno

DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr     		INTEGER;
DEFINE cErrorInfo   		VARCHAR(255,1);
DEFINE cCodRet      		CHAR(6);
DEFINE cMen_ret 			CHAR(80);
DEFINE wBegin             	CHAR(1);

DEFINE cProducto            CHAR(4);		
DEFINE cDivisa              CHAR(2);		
DEFINE cSucursal            CHAR(4);	
DEFINE pNombrePres			CHAR(50);
DEFINE iPlazo				INTEGER;
DEFINE mComisionApertura	MONEY(14,2);
DEFINE iFrecuencia       	INTEGER;
DEFINE dFechaT              DATE;
DEFINE pCuentaCap			CHAR(20);
DEFINE mTasaInteresProd		DECIMAL(18,2);	
DEFINE mTasaInteres         DECIMAL(18,2);	
DEFINE cFactor	            CHAR(1);		
DEFINE mSobreTasa           DECIMAL(18,2);	
DEFINE sDiaCorte            SMALLINT;		
DEFINE cPeriodoPag			CHAR(1);		
DEFINE cCodRet2             CHAR(6);
DEFINE iNum_periodos        INTEGER;
DEFINE dtFecha_cuota        DATE;
DEFINE dSdo_inicial         MONEY(14,2);
DEFINE dPago_mensual        MONEY(14,2);
DEFINE dMto_Interes         MONEY(14,2);
DEFINE dIva_interes         MONEY(14,2);
DEFINE dCapital             MONEY(14,2);
DEFINE dSdo_final           MONEY(14,2);
DEFINE sDias_periodo        SMALLINT;
DEFINE dtFecha_Aper			DATE;
DEFINE dtFechaAp			DATE;
DEFINE dfechavenc			DATE;
DEFINE cNumMesesPagos   	CHAR(3);
DEFINE mTasaMora			DECIMAL(18,2);
DEFINE mTasaMoraProd		DECIMAL(18,2);
DEFINE dIvaSuc              DECIMAL(5,3);
DEFINE mTotalPagar			DECIMAL(18,2);
DEFINE dPagoReq      		DECIMAL(18,2);
DEFINE cMensajeRet     		VARCHAR(80,1);
DEFINE vCatFinal            DECIMAL(21,10);
DEFINE cNumeroFolio 		CHAR(16);		-- FOLIO PARA REGISTRAR EL ABONO
DEFINE cCodRet3				VARCHAR(6);		-- CODIGO DE RETORNO ABONOREF BDICHEQ
DEFINE contproyecta			SMALLINT;
DEFINE pMensualidad			MONEY(18,2);

DEFINE fg_prestamo			SMALLINT;
DEFINE dDisp_pAnterior		DECIMAL(18,2);
DEFINE dCountExists			SMALLINT;
DEFINE cPeriodo_Plazo       CHAR(1);
DEFINE cTp_Dias_Fecha_Pago  CHAR(1);
DEFINE iFrecuencia_Pgo		INTEGER;
DEFINE cManeja_Linea        CHAR(1);
DEFINE cStatusCred			CHAR(2); --RQM 10 1155
-- Programa apoyo 2020
DEFINE wbandera_apoyo 		CHAR(1);
DEFINE dMontoCod089_5		DECIMAL(18,2);
DEFINE dMontoCod089_8		DECIMAL(18,2);
DEFINE dtFechaHoy 			DATE;
DEFINE dCanal				SMALLINT;		-- Prestamo Flex Multicanal
DEFINE cCanal				CHAR(2);
DEFINE dCanal_atm			SMALLINT;		
DEFINE dCanal_sms			SMALLINT;
DEFINE dCanal_wtsapp		SMALLINT;
DEFINE dCanal_App			SMALLINT;
DEFINE dCod_ref_Reprs		INTEGER;
DEFINE dCod_ref_Disp 		INTEGER;
DEFINE cCod_Fun_Represt		CHAR(3);
DEFINE cMovimiento 			CHAR(40);
DEFINE sDetalle 			CHAR(23);
DEFINE iPlazo_pago          INTEGER;

-- IFSR variables
DEFINE iAtr  INTEGER;
DEFINE vifrs  char(1);
DEFINE vstat_ap char(2);

LET iSqlErr         		= 0;
LET iIsamErr        		= 0;
LET cErrorInfo      		= "";
LET cCodRet         		= "000000";
LET cMen_ret     			= "Proceso Exitoso";

LET cCodRet2             	= "000000";
LET cProducto  				= "";
LET cDivisa    				= "";
LET cSucursal				= "";
LET mComisionApertura      	= 0;
LET pNombrePres 			= "";
LET iPlazo 					= 0;
LET mComisionApertura      	= 0;
LET iFrecuencia 			= 0;
LET dFechaT  				= DATE(1);
LET pCuentaCap  			= "";
LET mTasaInteresProd		= 0;
LET mTasaInteres        	=0;
LET cFactor	  				= "";
LET mSobreTasa   			= 0;
LET sDiaCorte				= 0;
LET cPeriodoPag				= "";
LET iNum_periodos           = 0;
LET dtFecha_cuota      	   	= DATE(1);
LET dSdo_inicial      	   	= 0;
LET dPago_mensual      	   	= 0;
LET dMto_Interes      	   	= 0;
LET dIva_interes      	   	= "";
LET dCapital      	   		= "";
LET dSdo_final      	    = 0;
LET sDias_periodo      	    = 0;
LET dtFecha_Aper      	    =DATE(1);
LET dtFechaAp				=DATE(1);
LET dfechavenc				=DATE(1);
LET cNumMesesPagos  		= "";
LET mTasaMora				=0;
LET mTasaMoraProd			=0;
LET dIvaSuc					=0;
LET mTotalPagar				=0;
LET dPagoReq				=0;
LET cMensajeRet         	= "Se realizo el calculo correctamente";
LET vCatFinal 				=0;
LET cNumeroFolio			= "";
LET cCodRet3				= '000';
LET contproyecta			=0;
LET pMensualidad 			=0;

LET fg_prestamo				=0;
LET dDisp_pAnterior			=0;	
LET dCountExists			=0;
LET cPeriodo_Plazo			=0;
LET cTp_Dias_Fecha_Pago  	= "";
LET iFrecuencia_Pgo			=0;
LET cManeja_Linea        	="";
LET cStatusCred			    ="";      --RQM 10 1155
LET wbandera_apoyo			= "";
LET dtFechaHoy 				= DATE(1);
LET dMontoCod089_5			= 0;
LET dMontoCod089_8			= 0;
LET dCanal					= 0;
LET cCanal					= '';
LET dCanal_atm				= 0;
LET dCanal_sms				= 0;
LET dCanal_wtsapp			= 0;
LET dCanal_App				= 0;
LET dCod_ref_Reprs			= 0;
LET dCod_ref_Disp 			= 0;
LET cCod_Fun_Represt		= '';
LET cMovimiento 			= '';
LET sDetalle 				= '';
LET iPlazo_pago             = 0;

-- IFSR variables
LET iAtr 			= 0;
LET vifrs  			='';
LET vstat_ap 		='';


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
   IF iSqlErr != 0 THEN 
		RETURN iSqlErr,fg_prestamo,pMensualidad ,pCuentaCap;
   END IF;
END EXCEPTION;

ON EXCEPTION IN (-535)
  LET wBegin = "S";
  COMMIT WORK;
  BEGIN WORK;
END EXCEPTION WITH RESUME;

LET wBegin = "N";


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/informix/Rebeca/sp_pflex_disposicion.out';
--TRACE ON;

-- Obtiene las diferentes fechas del sistema
SELECT fecha_hoy INTO dtFechaHoy FROM bdicred:"informix".sd_fechas;

-- Identifica el canal de origen
LET dCanal = pCanal;
IF NVL(dCanal,0) = 0 THEN			-- Si no se asigno canal previamente, se asigna por default SMS
	SELECT cve_canal INTO dCanal FROM bdinteg:si_canal WHERE nombre_canal = '98000';
END IF;
LET cCanal = NVL(dCanal,0);
							-- Identifica los canales: ATM y SMS, para diferenciar la respuesta a enviar.
SELECT cve_canal INTO dCanal_sms FROM bdinteg:si_canal WHERE nombre_canal = '98000';
SELECT cve_canal INTO dCanal_atm FROM bdinteg:si_canal WHERE nombre_canal = 'ATM';
SELECT cve_canal INTO dCanal_wtsapp FROM bdinteg:si_canal WHERE nombre_canal = 'WHATSAPP';
SELECT cve_canal INTO dCanal_App FROM bdinteg:si_canal WHERE nombre_canal = 'BANCOPPEL MOVIL EN LINEA';

IF dCanal = dCanal_atm THEN			-- Asigna codigos de acuerdo al canal
	LET dCod_ref_Reprs = 121;
	LET dCod_ref_Disp  = 120;
	LET cCod_Fun_Represt = '109';
ELIF dCanal = dCanal_wtsapp THEN
	LET dCod_ref_Disp  = 122;
	LET dCod_ref_Reprs = 123;
	LET cCod_Fun_Represt = '115';
ELIF dCanal = dCanal_App THEN			
	LET dCod_ref_Disp  = 126;
	LET dCod_ref_Reprs = 127;
	LET cCod_Fun_Represt = '116';
ELSE								-- Asigna por default codigos de sms
	LET dCod_ref_Reprs = 119;	-- Represtamo
	LET dCod_ref_Disp  = 66;	-- Disposicion
	LET cCod_Fun_Represt = '089';
END IF;


--INTERES ORDINARIO
SELECT a.num_producto, a.divisa, c.sucursal,nombre_prod, c.plazo,cobro_comis_apertura, --CASE WHEN c.periodo_plazo = 'M' THEN 1 ELSE 2 END Frecuencia,
	   c.periodo_plazo Frecuencia, c.tasa_interes, c.factor_sobretasa, c.sobretasa, 
	   a.dia_cuota, c.periodo_plazo,c.status_cred
INTO cProducto, cDivisa, cSucursal,pNombrePres,iplazo,mComisionApertura,cPeriodo_Plazo,
     mTasaInteres, cFactor, mSobreTasa, sDiaCorte, cPeriodoPag, cStatusCred
FROM bdicred:"informix".sd_definicion a
INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.empresa = a.empresa AND b.num_producto = a.num_producto
INNER JOIN bdicred:"informix".sd_maecredcrd c ON c.empresa = a.empresa AND c.num_producto = a.num_producto AND c.num_credito = b.num_solicitud
WHERE b.empresa = pEmpresa AND b.num_solicitud = cCtaPPF;
	
IF cStatusCred = 'FF' THEN --RQM 10 1155
--IPCB IFRS Se comenta se cambia por la fecha del dia para poner la apertura
/*
    SELECT nvl(a.fecha_proceso,c.fecha_alta)  INTO dtFechaAp --Fecha proceso cheques 
	FROM  bdicheq:"informix".sc_maechq a
	JOIN  bdicred:"informix".sd_ctascarg b ON a.cuenta = b.num_cta
	JOIN  bdicheq:"informix".sc_maenoc c ON a.cuenta = c.cuenta
	WHERE a.empresa = '001'
	AND num_credito = cCtaPPF;
	*/
	SELECT fecha_hoy  INTO dtFechaAp --RQM 10 1155
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = pEmpresa;
ELSE
	SELECT fecha_proceso  INTO dtFechaAp --RQM 10 1155
	FROM bdicred:"informix".sd_maecredanexocrd  --Fecha proceso credito
	WHERE empresa = pEmpresa
	AND num_credito = cCtaPPF;
END IF;

	SELECT TRIM(valor) INTO iPlazo_pago
      FROM bdicred:sd_param                  
     WHERE empresa  = pEmpresa AND cod_param = 'A01';
 
     CALL "informix".monthadd(dtFechaAp,iPlazo_pago) RETURNING dFechaVenc;  --RQM 10 1514  MACF


--	Obtiene la fecha habil de proximo pago y fecha vencimiento
CALL bdicred:"informix".monthadd(dtFechaAp,1) RETURNING dFechaT;
--CALL bdicred:"informix".monthadd(dtFechaAp,36) RETURNING dFechaVenc;  --RQM 10 1514  MACF

CALL bdicred:"informix".sp_valfechabil(dFechaT,'+') RETURNING cCodRet, dFechaT;
CALL bdicred:"informix".sp_valfechabil(dFechaVenc,'+') RETURNING cCodRet, dFechaVenc;


SELECT num_cta  INTO pCuentaCap
FROM bdicred:sd_ctascarg 
WHERE naturaleza = 'A' AND num_credito = cCtaPPF;

IF cPeriodo_Plazo = 'M' THEN		--- Frecuencia
	LET iFrecuencia = 1;
ELSE
	LET iFrecuencia = 2;
END IF;

LET mTasaInteresProd = mTasaInteres;

IF cFactor = "+" THEN
	LET mTasaInteres = mTasaInteres + mSobreTasa;
ELIF cFactor = "-" THEN
	LET mTasaInteres = mTasaInteres - mSobreTasa;
ELIF cFactor = "*" THEN
	LET mTasaInteres = mTasaInteres * mSobreTasa;
ELSE
	LET mTasaInteres = mTasaInteres / mSobreTasa;
END IF;

--INTERES MORATORIO
/*
SELECT c.valor, a.fact_sobret_mora, a.sobretasa_mora
INTO mTasaMora, cFactor, mSobreTasa
FROM "informix".sd_definicion a
	INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.empresa = a.empresa AND b.num_producto = a.num_producto
	INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_mora
WHERE b.empresa = pEmpresa AND num_solicitud = cCtaPPF
	AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.empresa = pEmpresa AND r.tasa = a.cod_tasa_mora);

LET mTasaMoraProd = mTasaMora;

IF cFactor = "+" THEN
		LET mTasaMora = mTasaMora + mSobreTasa;
ELIF cFactor = "-" THEN
		LET mTasaMora = mTasaMora - mSobreTasa;
ELIF cFactor = "*" THEN
		LET mTasaMora = mTasaMora * mSobreTasa;
ELSE
		LET mTasaMora = mTasaMora / mSobreTasa;
END IF;
*/
SELECT a.iva
 INTO dIvaSuc
 FROM bdinteg:"informix".si_sucursales a
WHERE a.sucursal = cSucursal
  AND a.empresa  = pEmpresa;
  
/*
-- Programa Apoyo. Consulta si credito pertenece al programa apoyo.
SELECT bandera INTO wbandera_apoyo FROM bdicred:sd_programa_apoyo2020crd
 WHERE num_credito = cCtaPPF;
  
IF wbandera_apoyo = 'A' THEN -- Obtiene los saldos de los intereses cuando se encuentra en programa apoyo
								-- y arrastre intereses sin capitalizarlos.
									-- IFSR se asigna el valor del ATR
	SELECT nvl(atr,0)
	INTO iAtr
	FROM bdicred:sd_maesdoscrd
	WHERE num_credito = cCtaPPF;
	
  IF (cStatusCred IN ('AA','FF')) OR (cStatusCred = 'E1' AND iAtr = 0) THEN		
																
	SELECT nvl(monto,0) INTO dMontoCod089_8
	  FROM bdicred:sd_movdiacrd 
	 WHERE empresa = pEmpresa AND num_credito = cCtaPPF AND codigo_fun = cCod_Fun_Represt and codigo_ref = 8 AND fecha_mov = dtFechaHoy;
	 
	SELECT nvl(monto,0) INTO dMontoCod089_5
	  FROM bdicred:sd_movdiacrd 
	 WHERE empresa = pEmpresa AND num_credito = cCtaPPF AND codigo_fun = cCod_Fun_Represt and codigo_ref = 5 AND fecha_mov = dtFechaHoy;	 
	 
	UPDATE bdicred:sd_movdiacrd SET reversado = 'S'
	 WHERE empresa = pEmpresa AND num_credito = cCtaPPF AND codigo_fun = cCod_Fun_Represt and codigo_ref IN(5,8) AND fecha_mov = dtFechaHoy;	

	 IF dMontoCod089_5 is null THEN LET dMontoCod089_5 = 0; END IF;
	 IF dMontoCod089_8 is null THEN LET dMontoCod089_8 = 0; END IF;
	 
	 LET dtotal_prestamo = dtotal_prestamo - (dMontoCod089_8 + dMontoCod089_5 );
  END IF;	
ELSE
	LET dMontoCod089_8			= 0; 
	LET dMontoCod089_5			= 0; 

END IF;  
  
*/  
--Valida paremetro IFRS y define estatus IPCB
select NVL(valor,'I') into vifrs
 from bdicred:sd_param
where cod_param = '700';

IF vifrs = 'A' THEN
	LET iAtr = 0;
	LET vstat_ap ='E1';
ELSE
	LET iAtr = null;
	LET vstat_ap ='AA';
END IF
  
-- Se divide disposicion del prestamo flexible en Deuda Anterior y Disposicion Nueva
LET dDisp_pAnterior = dtotal_prestamo - pMontoSol; -- Monto de la disposicion anterior: Deuda vieja  
  
FOREACH 
	--SE OBTIENE CON EL PROYECTA PRESTAMO CADA UNA DE LAS MENSUALIDADES PARA SUMARLAS y CALCULAR EL MONTO TOTAL A PAGAR
	EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (dtotal_prestamo,iPlazo,0,cProducto,cSucursal,1,0,cCtaPPF,"",iFrecuencia)
	INTO cCodRet,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
	dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos
	
	--SE VALIDAD PARA VER SI EL PROYECTA PRESTAMO SE EJECUTO CORRECTAMENTE
	IF cCodRet::INTEGER <> 0  THEN				
		LET cCodRet = "000001";  --Error en sp_proyecta_prestamos
		LET fg_prestamo  = 0;	
	END IF;
	--VARIABLE QUE GUARDA LA SUMA DE LAS MENSUALIDADES
	LET mTotalPagar = mTotalPagar + dPago_mensual::DECIMAL(18,2);	
	
	IF contproyecta = 0 THEN
		LET pMensualidad =  dPago_mensual;
	END IF;
	
	LET contproyecta = contproyecta +1;
END FOREACH;

LET dPagoReq = dtotal_prestamo / ((1- pow((1+((mTasaInteres /100)/( iFrecuencia * 12 ))),-iplazo)) / ((mTasaInteres /100)/( iFrecuencia * 12 )) ) ;

EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir_pp(dtotal_prestamo,dPagoReq,iplazo,(12 * iFrecuencia),mComisionApertura) 
INTO cCodRet2,cMensajeRet,vCatFinal;

IF cCodRet2::integer  <> 0 THEN
	LET cCodRet = "000002";  --Error en sp_calculo_tiir_pp
	LET fg_prestamo  = 0;				
ELSE
	BEGIN WORK;

	
	SELECT count(num_credito) INTO dCountExists FROM bdicred:sd_maecredcrd_flex
 	 WHERE num_credito = cCtaPPF AND fecha_insert = dtFechaHoy;
	
	IF dCountExists = 0 THEN
	--IF dDisp_pAnterior = 0 THEN -- Respalda solo cuando sea 1era disposicion. Para 2das disposiciones, respalda antes.

		--Respaldo de info productiva
		INSERT INTO bdicred:"informix".sd_maecredcrd_flex
		SELECT dtFechaHoy,* FROM  bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_Credito = cCtaPPF;	

		INSERT INTO bdicred:"informix".sd_maesdoscrd_flex
		SELECT dtFechaHoy, pMontoSol, * FROM  bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_Credito = cCtaPPF;	

		INSERT INTO bdicred:"informix".sd_maecredanexocrd_flex
		SELECT dtFechaHoy,* FROM  bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_Credito = cCtaPPF;	

		INSERT INTO bdicred:"informix".sd_amortiza_creditocrd_flex
		SELECT dtFechaHoy,* FROM  bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_Credito = cCtaPPF;	
		--Se agrega campos "acepto_incremento y linea_prestamo_anterior" - RQM 10 1543
		INSERT INTO bdicred:"informix".sd_linea_prestamo_flex
		SELECT dtFechaHoy,  empresa , num_credito ,  monto_linea ,fecha_otorga,linea_disponible, sec_credito, fecha_cancela, fecha_ult_mod ,  disposicion_activada, acepto_incremento, linea_prestamo_anterior
		 FROM  bdicred:"informix".sd_linea_prestamo WHERE num_Credito = cCtaPPF;	

	END IF;		

	--Limpia tablas productivas	
	DELETE FROM  bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_Credito = cCtaPPF;	
	
	DELETE FROM  bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_Credito = cCtaPPF;	

	DELETE FROM  bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_Credito = cCtaPPF;

	DELETE FROM  bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_Credito = cCtaPPF;

	--Genera Nuevos registros
	INSERT INTO "informix".sd_maecredcrd(
										empresa,                        num_credito,
										num_producto,                   ejecutivo,
										numcte,                         aval_cte,
										aval_linea,                     divisa,
										sucursal,                       id_origen,
										origen,                         cod_tipo_linea,
										cod_linea,                      status_cred,
										bandera_renovac,                bandera_prorroga,
										periodo_plazo,                  plazo,
										fecha_apertura,                 fecha_vencim,
										period_pago_cap,                period_pag_int,
										dias_trasp_cap,                 dias_trasp_int,
										tasa_fija_o_var,                cod_tasa_base,
										factor_sobretasa,               sobretasa,
										tasa_interes,                   cod_tasa_mora,
										sobretasa_mora,                 fact_sobret_mora,
										tasa_moratorios,                tasa_preferencial,
										sobretasa_preferencial,         factor_preferencial,
										valor_preferencial,             fecha_pago_cap,
										fecha_pago_int,                 es_fisica,
										bandera_fi_fo,                  actividad,
										tipo_calculo,                   num_aper_ant,
										rev_tasa_var_per,               dia_para_revisar,
										cod_prod,                       bandera_ministra,
										credito_externo,                califica_riesgo,
										cod_agricola,                   pagos_sostenidos,
										campo_trab1,                    campo_trab2,
										campo_trab3,                    campo_trab4
										,cuenta_clabe)
								SELECT  {+INDEX (bdicred:sd_cattipopago)}
										sol.empresa                		,cCtaPPF
									   ,sol.num_producto                ,NVL(anx.ejecutivo_sol,'')
									   ,sol.numcte                      ,''
									   ,''                              ,NVL(def.divisa,1)
									   ,NVL(def.sucursal,'')            ,''
									   ,''                              ,''
									   ,''                              ,vstat_ap
									   ,'S'                             ,'N'
									   ,SUBSTR(tipo_pago,1,1)		   
									   ,iplazo
									   ,dtFechaAp  					    ,dFechaVenc
									   ,NVL(def.period_pago_cap,'')     ,NVL(def.period_pag_int,'')
									   ,NVL(def.dias_trasp_cap,0)    	,NVL(def.dias_trasp_int,0)
									   ,NVL(def.tasa_fija_o_var,'')     ,NVL(def.cod_tasa_base,'')
									   ,NVL(def.factor_sobretasa,'')    ,NVL(def.sobretasa,'')
									   ,mTasaInteresProd                ,NVL(def.cod_tasa_mora,'')
									   ,NVL(def.sobretasa_mora,0)       ,NVL(def.fact_sobret_mora,'')
									   ,NVL(mTasaMoraProd,0)            ,''
									   ,0                               ,''
									   ,0                               ,dFechaT
									   ,dFechaT							,NVL(tip.es_fisica,'')
									   ,cCanal                    		,''
									   ,NVL(def.tipo_calculo,'')        ,dIvaSuc
									   ,''                              ,NVL(def.dia_para_revisar,0)
									   ,''                              ,SUBSTR(tipo_pago,1,1)	--cPeriodoPag
									   ,''                              ,''
									   ,''                              ,0
									   ,0                               ,0
									   ,''                              ,''
									   ,def.cuenta_clabe
									   FROM bdisolic:"informix".ss_solicitudes sol
									   INNER JOIN "informix".sd_maecredcrd_flex def ON def.empresa = sol.empresa AND def.num_Credito = sol.num_solicitud and def.fecha_insert = dtFechaHoy
									   INNER JOIN bdisolic:"informix".ss_anexosol anx ON anx.num_solicitud = sol.num_solicitud AND anx.empresa = sol.empresa
									   INNER JOIN bdinteg:"informix".si_cliente cli ON cli.empresa = sol.empresa AND cli.numcte = sol.numcte
									   INNER JOIN bdinteg:"informix".si_tipper tip ON tip.tpo_persona = cli.tpo_persona
									   INNER JOIN "informix".sd_cattipopago pago ON valor = iFrecuencia
									   WHERE  sol.num_solicitud = cCtaPPF AND sol.empresa = pEmpresa;	

	INSERT INTO "informix".sd_maesdoscrd (
										empresa, 			num_credito,
										fecha_ult_mov, 		sdo_int_anticip,
										sdo_int_ant_dev, 	sdo_intereses,
										sdo_dia_ant_int, 	sdo_mes_ant_int,
										sdo_acum_mes_int, 	sdo_retenido,
										sdo_acum_cap_int, 	sdo_exig_int,
										sdo_no_exig, 		provision_normal,
										dias_acum_int, 		sdo_moratorio,
										sdo_dia_ant_mor, 	sdo_mes_ant_mor,
										sdo_contab_mora, 	dias_acum_mora,
										sdo_capital, 		sdo_cap_insoluto,
										sdo_dia_ant_cap, 	sdo_mes_ant_cap,
										sdo_acum_mes_cap, 	mto_capitalizado,
										mto_ministra_cap, 	cargos_dia_cap,
										abonos_dia_cap, 	cargos_mes_cap,
										abonos_mes_cap, 	dias_acum_cap,
										monto_vencido, 		mto_venc_trasp,
										monto_financiado, 	monto_reservado,
										sdo_acum_vencido, 	dias_acum_intper,
										sdo_global_int, 	sdo_acum_intper,
										monto_otorgado, 	provi_venc_normal,
										provi_venc_anticip, cap_tras_no_venci,
										mto_venc_int, 		mto_venc_tra_int,
										mto_finan_vdo, 		mto_reser_int,
										mto_fin_ven_trasp, 	mto_fin_vig_trasp,
										int_tra_no_exig, 	sdo_trab4,atr)
								SELECT sol.empresa          	,cCtaPPF
										,dtFechaAp           	,0
										,0                      ,dMontoCod089_5
										,0                      ,0
										,0                      ,0
										,0                      ,0
										,0                      ,dMontoCod089_5
										,0                      ,0
										,0                      ,0
										,0                      ,0
										,dtotal_prestamo        ,dtotal_prestamo
										,0                      ,0
										,0                      ,mTotalPagar
										,0                      ,0
										,0                      ,0
										,0                      ,0
										,0                      ,0
										,0                      ,0
										,0                      ,0
										,dMontoCod089_8			,0
					                    ,dtotal_prestamo		,0
										,0                      ,0
										,0                      ,0
										,0                      ,0
										,0                      ,0
										,0                      ,0
										,iAtr
										FROM   bdisolic:"informix".ss_solicitudes sol
										WHERE  sol.num_solicitud = cCtaPPF AND sol.empresa = pEmpresa;

	
	SELECT frecuencia_pgo INTO iFrecuencia_Pgo FROM bdisolic:ss_sol_nomina WHERE empresa = pEmpresa AND num_solicitud = cCtaPPF AND numcte = cNumCte;
	LET iFrecuencia_Pgo = NVL(iFrecuencia_Pgo,0);
	SELECT maneja_linea INTO cManeja_Linea FROM bdicred:sd_definicion WHERE num_producto = cProducto;
	LET cManeja_Linea = NVL(cManeja_Linea,'0');
	--(CASE WHEN NVL(nom.Frecuencia_pgo,0) = 0  THEN NVL(def.maneja_linea::INTEGER,0) ELSE  NVL(nom.Frecuencia_pgo,0) END) ,
	
	IF iFrecuencia_Pgo = 0 THEN
		LET cTp_Dias_Fecha_Pago = cManeja_Linea;
	ELSE
		LET cTp_Dias_Fecha_Pago = iFrecuencia_Pgo::CHAR;
	END IF;
	
	INSERT INTO "informix".sd_maecredanexocrd(
										empresa, 				 		
										num_credito,
										localidad,              		
										dia_corte,
										dias_gracia_mora, 		 		
										tp_dias_calc_mora,
										dias_fecha_max_pago,	 		
										tp_dias_fecha_pago,
										cod_tasa_base_cte, 	 			
										factor_sobretasa_cte,
										sobretasa_cte, 		 			
										tasa_interes_cte,
										fecha_vencto, 			 		
										prox_fecha_pago,
										fecha_proceso,			 		
										fecha_ult_pago,
										nombre_pres, 					
										cat)
								SELECT 	pEmpresa,
										cCtaPPF,
										pId_atm,
										DAY(dtFechaAp),
										NVL(b.dias_gracia_mora,0),
										'',
										DAY(dtFechaAp),
										--(CASE WHEN NVL(nom.Frecuencia_pgo,0) = 0  THEN NVL(def.maneja_linea::INTEGER,0) ELSE  NVL(nom.Frecuencia_pgo,0) END) ,
										cTp_Dias_Fecha_Pago,
										NVL(b.cod_tasa_base_cte,''),
										NVL(b.factor_sobretasa_cte,''),
										NVL(b.sobretasa_cte,0),
										mTasaInteresProd,
										"",
										dFechaT,
										dtFechaAp,
										"",
										pNombrePres, 
										vCatFinal
								FROM "informix".sd_definicion def
								INNER JOIN bdisolic:"informix".ss_solicitudes c ON c.empresa = def.empresa AND c.num_producto = def.num_producto
								INNER JOIN bdicred:"informix".sd_maecredanexocrd_flex b on b.empresa = def.empresa and b.num_credito = c.num_solicitud and b.fecha_insert = dtFechaHoy
								LEFT JOIN  bdisolic:"informix".ss_sol_nomina nom ON (nom.empresa = c.empresa AND nom.num_solicitud = c.num_solicitud)	
								WHERE c.empresa = pEmpresa AND c.num_solicitud = cCtaPPF;

	INSERT INTO "informix".sd_amortiza_creditocrd (
										empresa, 			num_credito,					
										fecha_cuota, 		tipo_cuota,
										capital_mto_cuota, 	capital_debe,
										capital_pagado, 	capital_status,
										capital_status_ant, capital_fecha_pago,
										interes_debe, 		interes_pagado,
										interes_status, 	interes_status_ant,
										interes_fecha_pago, iva_debe,
										iva_pagado, 		iva_status,				
										iva_status_ant, 	iva_fecha_pago,
										mora_provi_ordi, 	mora_provi_cope,
										mora_sdo_ordi, 		mora_sdo_ordi_pag,
										mora_sdo_cope, 		mora_sdo_cope_pag,
										mora_bonificado, 	mora_status,
										mora_iva_debe, 		mora_iva_pagado,
										mora_iva_status, 	mora_iva_fecha_pago,
										num_pago, 			campo_trabajo1,
										campo_trabajo2, 	campo_trabajo3,		campo_trabajo4)
								VALUES (pEmpresa,			cCtaPPF,
										dFechaT,			"3",
										pMensualidad,		0,
										0,					"3",
										"3",				"",
										dMontoCod089_5, 	0,			
										"1",				"1",
										"",					0,
										0,					"1",
										"1",				"",
										0,					0,
										0,					0,
										0,					0,
										0,					"1",
										0,					0,
										"1",				"",
										1,					0,
										0,					"",		"");
	-- SE GENERA EL FOLIO
	CALL bdicheq:"informix".sp_generafolionomina(pEjecutivo) RETURNING cCodRet2, cNumeroFolio;
	
	IF dCanal = dCanal_atm THEN		-- Asigna descripcion de movimiento segun el canal
		LET cMovimiento = 'DISPOSICION - ATM';
		LET sDetalle = cNumeroFolio||' '||pId_atm;	
	ELIF dCanal = dCanal_wtsapp THEN
		LET cMovimiento = 'DISPOSICION - WHATSAPP';
		--LET sDetalle = cNumeroFolio;
		LET sDetalle = '';
	ELIF dCanal = dCanal_App THEN	
		LET cMovimiento = 'DISPOSICION - APP';
		LET sDetalle = '';
	ELSE						-- Asigna por default descripcion desde sms
		LET cMovimiento = 'DISPOSICION';
		LET sDetalle = '';
	END IF;
	
	IF cCodRet2::integer  <> 0 THEN
		LET cCodRet = "000003";  --Error en sp_generafolionomina
		LET fg_prestamo  = 0;				  
	ELSE
		--LET cTransacc = "0247";

		--EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa, cCtaPPF, cProducto, 66, "002", dtFechaAp, dtotal_prestamo, cNumeroFolio,
		EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa, cCtaPPF, cProducto, dCod_ref_Disp, "002", dtFechaAp, pMontoSol, cNumeroFolio,
								cSucursal, cDivisa, "0000",cMovimiento,sDetalle)
		 INTO cCodRet, cErrorInfo;

		IF cCodRet::integer  <> 0 THEN
			LET cCodRet = "000004"; --Error en genmovcrd
			LET fg_prestamo  = 0;	
			ROLLBACK WORK;	
			IF (wBegin = "S") THEN
			   BEGIN WORK;
			END IF;
		ELSE			
																	
			IF dDisp_pAnterior > 0 THEN -- Existe saldo pendiente de disposicion anterior (deuda vieja)
				-- Realiza cargo de la deuda vieja. 
				EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa, cCtaPPF, cProducto, dCod_ref_Reprs, "002", dtFechaAp, dDisp_pAnterior, cNumeroFolio,
									cSucursal, cDivisa, "0000",cMovimiento,sDetalle)
					INTO cCodRet, cErrorInfo;
				
				IF cCodRet::integer  <> 0 THEN
					LET cCodRet = "000004"; --Error en genmovcrd
					LET fg_prestamo  = 0;	
					ROLLBACK WORK;	
					IF (wBegin = "S") THEN
						BEGIN WORK;
					END IF;
				ELSE
					LET cCodRet = "000000";
	 
				END IF;		
			END IF;
			
			IF cCodRet::integer = 0 THEN
		
				-- SE GENERA EL ABONO 
				CALL bdicheq:"informix".abono_ref (pEmpresa, cSucursal, pEjecutivo, cTransacc, cTransacc, cNumeroFolio, pCuentaCap, 0,
					pMontoSol, pMontoSol, 0, 0, 0, "01", cCtaPPF||" "||pNombrePres, '0', pEjecutivo) RETURNING cCodRet3;
					--dtotal_prestamo, dtotal_prestamo, 0, 0, 0, "01", cCtaPPF||" "||pNombrePres, '0', pEjecutivo) RETURNING cCodRet3;
				 
				IF cCodRet3::integer  <> 0 THEN
					LET cCodRet = "000005"; --Error en abono_ref
					LET fg_prestamo  = 0;	
					ROLLBACK WORK;	
					IF (wBegin = "S") THEN
						BEGIN WORK;
					END IF;				
				ELSE	
					UPDATE bdicred:sd_linea_prestamo SET linea_disponible = (linea_disponible - dtotal_prestamo), sec_credito = (sec_credito+1), fecha_ult_mod = current 
								WHERE EMPRESA = '001'
								AND NUM_CREDITO = cCtaPPF;		
					LET fg_prestamo  = 1;	
				END IF;
			END IF;
		END IF;	
	END IF;		

	COMMIT WORK;
	IF (wBegin = "S") THEN
		BEGIN WORK;
	END IF;
END IF;	

IF cCodRet='000' THEN
	LET cCodRet='00000';
END IF;

RETURN cCodRet,fg_prestamo,pMensualidad ,pCuentaCap;
     
END
END PROCEDURE
DOCUMENT
'Autor: NA',
'Folio: RQM 10 1543 - 65670 - Incremento en la linea de credito Prestamo Digital',
'Fecha: 14-08-2023',
'Modificacion: Se agrego campo acepto_incremento y linea_prestamo_anterior en el SELECT de la tabla bdicred:informix.sd_linea_prestamo en la linea 434.',
'Base de datos: bdicred',
'Solicito: ';

CREATE PROCEDURE "informix".sp_prestamoflex_sms_apoyo(popcion INTEGER,pnumcte  CHAR(20),pMontoSol DECIMAL (18,2))	
RETURNING CHAR(5);       -- Codigo de Retorno
 
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr     		INTEGER;
DEFINE cErrorInfo   		VARCHAR(255,1);
DEFINE cCodRet      		CHAR(6);
DEFINE cCod_ret     		CHAR(6);
DEFINE v_codret 			CHAR(6);
DEFINE cMen_ret 			CHAR(80);

DEFINE dtFechaHoy 			DATE;
--DEFINE dFechaValFeriado		DATE;
DEFINE pEjecutivo			CHAR(8);
DEFINE pUsuario             CHAR(8);
DEFINE cNumCte				CHAR(20);
DEFINE cCtaPPF				CHAR(20);
DEFINE cstPPF   			CHAR(2);
DEFINE inumppf				INTEGER;
DEFINE dlinea_ppf			DECIMAL(18,2);

--Return sp_consulta_saldos_general
DEFINE ccodigo_retorno 		CHAR(6);
DEFINE cmensaje_retorno 	CHAR(80);
DEFINE cnumero_credito 		CHAR(20);
DEFINE ctipcred 			CHAR(2);
DEFINE dtfecha_origen 		DATE;
DEFINE dtfecha_prox_pago 	DATE;
DEFINE dpago_minimo 		DECIMAL(18,2);
DEFINE dtfecha_ult_pago 	DATE;
DEFINE iplazo 				INTEGER;
DEFINE ipagos_realizados 	INTEGER;
DEFINE dlinea_otorgada 		DECIMAL(18,2);
DEFINE dtasa_interes 		DECIMAL(9,6);
DEFINE dtasa_moratorios 	DECIMAL(9,6);
DEFINE dmonto_sbc 			DECIMAL(14,2);
DEFINE dcap_vig 			DECIMAL(18,2);
DEFINE dcap_trans 			DECIMAL(18,2);
DEFINE dcap_vdo_exig 		DECIMAL(18,2);
DEFINE dcap_vdo_no_exig 	DECIMAL(18,2);
DEFINE dsdo_act_total_cap 	DECIMAL(18,2);
DEFINE dint_vig 			DECIMAL(18,2);
DEFINE dint_moratorios 		DECIMAL(18,2);
DEFINE dint_mes 			DECIMAL(18,2);
DEFINE dsdo_act_total_int 	DECIMAL(18,2);
DEFINE diva_int_vig 		DECIMAL(18,2);
DEFINE diva_int_moratorios	DECIMAL(18,2);
DEFINE diva_int_mes 		DECIMAL(18,2);
DEFINE dsdo_act_total_iva 	DECIMAL(18,2);
DEFINE dcom_pend 			DECIMAL(18,2);
DEFINE dsdo_retenido 		DECIMAL(18,2);
DEFINE dtotal_liquidacion 	DECIMAL(18,2);
DEFINE dint_devengado		DECIMAL(18,2);
DEFINE diva_int_devengado 	DECIMAL(18,2);
DEFINE dlinea_disponible 	DECIMAL(18,2);
DEFINE dpagos_vdos 			DECIMAL(18,2);
DEFINE cstatus_cred 		CHAR(60);
DEFINE iid_bloqueo_cred 	INTEGER;
DEFINE cbloq_cta 			CHAR(60);
DEFINE cid_causa_bloqcta 	CHAR(3);
DEFINE ccausa_bloqcta 		CHAR(50);
DEFINE cid_sit_espcte 		CHAR(1);
DEFINE iid_causa_espcte 	INTEGER;
DEFINE csit_espcte 			CHAR(75);
DEFINE cid_sit_espcred 		CHAR(1);
DEFINE iid_causa_espcred 	INTEGER;
DEFINE csit_espcred 		CHAR(75);

DEFINE cSucursal            CHAR(4);	

--Return sp_principal_pp
DEFINE cCodRet2 			CHAR(5);
DEFINE cmens_ret 			CHAR(125);
DEFINE dsdo_ant 			DECIMAL(18,2);
DEFINE dcomision 			DECIMAL(18,2);
DEFINE diva_com 			DECIMAL(18,2);
DEFINE dint_mora 			DECIMAL(18,2);
DEFINE diva_int_mora 		DECIMAL(18,2);
DEFINE dint_vdo 			DECIMAL(18,2);
DEFINE diva_int_vdo 		DECIMAL(18,2);
DEFINE dint_ordi 			DECIMAL(18,2);
DEFINE diva_int_ordi 		DECIMAL(18,2);
DEFINE dcapital 			DECIMAL(18,2);
DEFINE dmonto_pago 			DECIMAL(18,2);
DEFINE ccuenta_eje 			CHAR(20);
DEFINE dsdo_act 			DECIMAL(18,2);
DEFINE dpago_min 			DECIMAL(18,2);
DEFINE cfecha_limite_pago 	CHAR(17);

DEFINE dtotal_prestamo		DECIMAL(18,2);

DEFINE fg_prestamo			SMALLINT;
DEFINE cNumeroFolio 		CHAR(16);		-- FOLIO PARA REGISTRAR EL ABONO
DEFINE pNombrePres			CHAR(50);
DEFINE cNom_Cliente 		CHAR(150);

DEFINE Pago_Efectivo 		DECIMAL(18,2);
DEFINE Pago_Cuenta 			DECIMAL(18,2);
DEFINE Monto_Operacion 		DECIMAL(18,2);
DEFINE Saldo_Actual 		DECIMAL(18,2);
DEFINE Status_Actual 		CHAR(60);

DEFINE pMensualidad			MONEY(18,2);
DEFINE pCuentaCap			CHAR(20);
DEFINE fg_liqppf			SMALLINT;
DEFINE dtFechaProxPago		CHAR(10);

DEFINE cDispActiva			CHAR(1);
DEFINE cBandDispActiva		SMALLINT;
DEFINE iRegsAfectados		SMALLINT;

DEFINE vNumCel       		CHAR(13);

LET iSqlErr         		= 0;
LET iIsamErr        		= 0;
LET cErrorInfo      		= "";
LET cCodRet         		= "00000";
LET cCod_ret        		= "00000";
LET v_codret				= "00000";
LET cMen_ret     			= "Proceso Exitoso";

LET dtFechaHoy				= DATE(1);
--LET dFechaValFeriado		= DATE(1);
LET pEjecutivo				= "informix";
LET pUsuario				= "";

LET cNumCte					= "";
LET cCtaPPF					= "";
LET cstPPF 					= "";
LET inumppf					= 0;
LET dlinea_ppf				= 0;

--return sp_consulta_saldos_general
LET ccodigo_retorno 		= '';
LET cmensaje_retorno 		= '';
LET cnumero_credito 		= '';
LET ctipcred 				= '';
LET dtfecha_origen 			= date(0);
LET dtfecha_prox_pago 		= date(0);
LET dpago_minimo 			= 0;
LET dtfecha_ult_pago 		= date(0);
LET iplazo 					= 0;
LET ipagos_realizados 		= 0;
LET dlinea_otorgada 		= 0;
LET dtasa_interes 			= 0;
LET dtasa_moratorios 		= 0;
LET dmonto_sbc 				= 0;
LET dcap_vig 				= 0;
LET dcap_trans 				= 0;
LET dcap_vdo_exig 			= 0;
LET dcap_vdo_no_exig 		= 0;
LET dsdo_act_total_cap 		= 0;
LET dint_vig 				= 0;
LET dint_moratorios 		= 0;
LET dint_mes 				= 0;
LET dsdo_act_total_int 		= 0;
LET diva_int_vig 			= 0;
LET diva_int_moratorios 	= 0;
LET diva_int_mes 			= 0;
LET dsdo_act_total_iva 		= 0;
LET dcom_pend 				= 0;
LET dsdo_retenido 			= 0;
LET dtotal_liquidacion 		= 0;
LET dint_devengado 			= 0;
LET diva_int_devengado 		= 0;
LET dlinea_disponible 		= 0;
LET dpagos_vdos 			= 0;
LET cstatus_cred 			= '';
LET iid_bloqueo_cred 		= 0;
LET cbloq_cta 				= '';
LET cid_causa_bloqcta		= '';
LET ccausa_bloqcta 			= '';
LET cid_sit_espcte 			= '';
LET iid_causa_espcte		= 0;
LET csit_espcte 			= '';
LET cid_sit_espcred 		= '';
LET iid_causa_espcred 		= 0;
LET csit_espcred 			= '';
LET cSucursal				= "";
--Return sp_principal_pp
LET cCodRet2 				='00000';
LET cmens_ret				='';
LET dsdo_ant 				=0;
LET dcomision 				=0;
LET diva_com 				=0;
LET dint_mora 				=0;
LET diva_int_mora 			=0;
LET dint_vdo 				=0;
LET diva_int_vdo 			=0;
LET dint_ordi 				=0;
LET diva_int_ordi 			=0;
LET dcapital 				=0;
LET dmonto_pago 			=0;
LET ccuenta_eje				='';
LET dsdo_act 				=0;
LET dpago_min 				=0;
LET cfecha_limite_pago 		='';
LET dtotal_prestamo			=0;
LET fg_prestamo             = 0;
LET cNumeroFolio			= "";
LET pNombrePres 			= "";
LET Pago_Efectivo = 0;
LET Pago_Cuenta = 0;
LET Monto_Operacion = 0;
LET Saldo_Actual = 0;
LET Status_Actual = "";
LET pMensualidad 			= 0;
LET pCuentaCap  			= "";
LET fg_liqppf				= 0;
LET dtFechaProxPago			= "";
LET cDispActiva				= '';
LET cBandDispActiva			= 0;
LET iRegsAfectados			= 0;
LET vNumCel					= '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo

	IF cBandDispActiva = 1 THEN
		ROLLBACK WORK;
		BEGIN WORK;
			-- Se marca como disposicion libre. Ya concluyo validacion y procesamiento de disposicion.
			UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
		COMMIT WORK;
		BEGIN WORK;
	ELSE
		-- Se marca como disposicion libre. Ya concluyo validacion y procesamiento de disposicion.
		UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
	END IF;	
	
	IF iSqlErr != 0 THEN
		--RETURN cCodRet ;
		RETURN iSqlErr;
	END IF;
	
END EXCEPTION;

ON EXCEPTION IN (-535) -- Error de transaccion.
	COMMIT WORK;
	LET cBandDispActiva = 1;	-- Marca bandera de transaccion abierta.
	BEGIN WORK;
END EXCEPTION WITH RESUME; 
   

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- SET DEBUG FILE TO '/ifxsif01/Israel/sp_pflex_sms.out';
-- TRACE ON; 


--Traer parametros de horarios y vencidos

SELECT valor
INTO pUsuario --FLEX_SMS
FROM bdisolic:"informix".ss_param
WHERE empresa = '001'
AND secuencia= 392;

-----
-- Obtiene las diferentes fechas del sistema		RQM 10 1155
SELECT fecha_hoy INTO dtFechaHoy FROM bdicred:"informix".sd_fechas;
  
LET pMontoSol = pMontoSol;
  
	SELECT b.numcte,b.num_credito,b.status_cred,sec_credito,monto_linea,b.sucursal, nvl(c.disposicion_activada,"1")
	INTO cNumCte,cCtaPPF,cstPPF,inumppf,dlinea_ppf,cSucursal, cDispActiva
	FROM  bdicred:sd_maecredcrd b
	INNER JOIN bdicred:sd_linea_prestamo c on b.empresa = '001' AND b.num_credito = c.num_credito 
	WHERE num_producto = '6800'
	and fecha_apertura = (	select max(fecha_apertura) 
								from bdicred:sd_maecredcrd 
								where empresa = '001' 
								and numcte = b.numcte
								AND NUM_PRODUCTO = '6800')
	AND numcte = pnumcte;
	

	EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general('001',cCtaPPF) 
	INTO ccodigo_retorno,cmensaje_retorno,cnumero_credito,ctipcred,dtfecha_origen,dtfecha_prox_pago,dpago_minimo,dtfecha_ult_pago,
	iplazo,ipagos_realizados,dlinea_otorgada,dtasa_interes,dtasa_moratorios,dmonto_sbc,dcap_vig,dcap_trans,dcap_vdo_exig,dcap_vdo_no_exig,
	dsdo_act_total_cap,dint_vig,dint_vdo,dint_moratorios,dint_mes,dsdo_act_total_int,diva_int_vig,diva_int_vdo,diva_int_moratorios,diva_int_mes,
	dsdo_act_total_iva,dcom_pend,diva_com,dsdo_retenido,dtotal_liquidacion,dint_devengado,diva_int_devengado,dlinea_disponible,dpagos_vdos,
	cstatus_cred,iid_bloqueo_cred,cbloq_cta,cid_causa_bloqcta,ccausa_bloqcta,cid_sit_espcte,iid_causa_espcte,csit_espcte,cid_sit_espcred,iid_causa_espcred,
	csit_espcred;
	
	LET dlinea_disponible = (dlinea_ppf - dtotal_liquidacion);		

	IF popcion = 2 THEN --FLEXIBLE + Monto (Solicitud de prestamo y Represtamo)	

		IF cDispActiva = '1' THEN	-- Disposicion de Prestamo Digital libre de realizarse. No existe disposicion en proceso 
			BEGIN WORK; 
			-- Se marca como disposicion en proceso.
			UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '3' WHERE num_credito = cCtaPPF AND NVL(disposicion_activada, '') <> '3';									
			COMMIT WORK;
				IF cBandDispActiva = 1 THEN
					BEGIN WORK; 
				END IF;
			LET iRegsAfectados = dbinfo("sqlca.sqlerrd2");
		END IF;

		IF dlinea_ppf <> dlinea_disponible THEN 

			LET fg_liqppf =1;
			-- SE GENERA EL FOLIO
			CALL bdicheq:"informix".sp_generafolionomina(pUsuario) RETURNING cCodRet2, cNumeroFolio;

			IF cCodRet2::integer  <> 0 THEN
				LET cCodRet = "000003";  --Error en sp_generafolionomina
				LET fg_prestamo  = 0;				  
			ELSE
				BEGIN;
					-- Respaldo de informacion productiva, previo a hacer pago temporal.
					INSERT INTO bdicred:"informix".sd_maecredcrd_flex
					SELECT dtFechaHoy, * FROM  bdicred:"informix".sd_maecredcrd WHERE empresa = '001' AND num_Credito = cCtaPPF;	

					INSERT INTO bdicred:"informix".sd_maesdoscrd_flex
					SELECT dtFechaHoy, dtotal_liquidacion, * FROM  bdicred:"informix".sd_maesdoscrd WHERE empresa = '001' AND num_Credito = cCtaPPF;	

					INSERT INTO bdicred:"informix".sd_maecredanexocrd_flex
					SELECT dtFechaHoy, * FROM  bdicred:"informix".sd_maecredanexocrd WHERE empresa = '001' AND num_Credito = cCtaPPF;	

					INSERT INTO bdicred:"informix".sd_amortiza_creditocrd_flex
					SELECT dtFechaHoy, * FROM  bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = '001' AND num_Credito = cCtaPPF;	
                    --Se agrega campos "acepto_incremento y linea_prestamo_anterior" - RQM 10 1543
					INSERT INTO bdicred:"informix".sd_linea_prestamo_flex
					SELECT dtFechaHoy,  empresa , num_credito ,  monto_linea ,fecha_otorga,linea_disponible, sec_credito, fecha_cancela, fecha_ult_mod ,  disposicion_activada, acepto_incremento, linea_prestamo_anterior 
					FROM  bdicred:"informix".sd_linea_prestamo WHERE num_Credito = cCtaPPF;	
				COMMIT;										
				IF cBandDispActiva = 1 THEN
					BEGIN WORK; 
				END IF;
				
				UPDATE bdicred:Sd_diferir SET canal_baja = '21' WHERE numcte = cNumCte;

				-- Realiza pago temporal de deuda anterior										-- '620')
				EXECUTE PROCEDURE bdicred:"informix".sp_principal_suc_rr('001',cCtaPPF,'6800',0,dtotal_liquidacion,pEjecutivo,cSucursal,cNumeroFolio,'8317')
					INTO cCodRet2,cmens_ret,cCtaPPF,ccuenta_eje,pNombrePres,cNumCte,cNom_Cliente,Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual;

				IF Status_Actual = 'SALDADA NORMAL' THEN
					LET Status_Actual = 'FF';
				END IF;	
				IF  cCodRet2::integer  <> 0 OR  Status_Actual <>'FF' THEN	
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd('001',cSucursal,pEjecutivo,cNumeroFolio,'A') INTO cCodRet2;
					IF cCodRet2::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET fg_prestamo  = 0;
						BEGIN WORK; 	-- Se marca como disposicion libre para solicitarse
							UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
						COMMIT WORK;
						IF cBandDispActiva = 1 THEN
							BEGIN WORK; 
						END IF;
						RETURN cCodRet ;
					END IF;
					-- Elimina respaldo realizado, por error en el pago temporal.
					DELETE FROM bdicred:"informix".sd_maecredcrd_flex WHERE empresa = '001' AND num_Credito = cCtaPPF AND fecha_insert = dtFechaHoy;	
					DELETE FROM bdicred:"informix".sd_maesdoscrd_flex WHERE empresa = '001' AND num_Credito = cCtaPPF AND fecha_insert = dtFechaHoy;	
					DELETE FROM bdicred:"informix".sd_maecredanexocrd_flex WHERE empresa = '001' AND num_Credito = cCtaPPF AND fecha_insert = dtFechaHoy;	
					DELETE FROM bdicred:"informix".sd_amortiza_creditocrd_flex WHERE empresa = '001' AND num_Credito = cCtaPPF AND fecha_insert = dtFechaHoy;		
					DELETE FROM bdicred:"informix".sd_linea_prestamo_flex WHERE empresa = '001' AND num_Credito = cCtaPPF AND fecha_insert = dtFechaHoy;	  

					BEGIN WORK; 	-- Se marca como disposicion libre para solicitarse
						UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
					COMMIT WORK;
					IF cBandDispActiva = 1 THEN
						BEGIN WORK; 
					END IF;
					RETURN cCodRet;
				END IF;
			END IF;	
		END IF;	
		
		UPDATE bdicred:Sd_diferir SET canal_baja = '20' WHERE numcte = cNumCte;

		IF cstPPF = 'FF' OR Status_Actual = 'FF' OR inumppf = 0 THEN

			LET dtotal_prestamo = dtotal_liquidacion + pMontoSol;
			--Validar el proceso de sp_pflex_disposicion pasar el monto
			EXECUTE PROCEDURE bdicred:"informix".sp_pflex_disposicion_apoyo ('001',cNumCte,cCtaPPF,dtotal_prestamo,pMontoSol,"0247",pEjecutivo)
				INTO cCodRet,fg_prestamo,pMensualidad ,pCuentaCap;	

			IF cCodRet::integer  <> 0 THEN
				LET cCodRet = "000003";
				LET fg_prestamo  = 0;	
				IF fg_liqppf =1 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd('001',cSucursal,pEjecutivo,cNumeroFolio,'A') INTO cCodRet2;
					IF cCodRet2::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET fg_prestamo  = 0;
						BEGIN WORK; 	-- Se marca como disposicion libre para solicitarse
						UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
						COMMIT WORK;
						IF cBandDispActiva = 1 THEN
							BEGIN WORK; 
						END IF;
						RETURN cCodRet ;
					END IF;
				END IF;

				BEGIN WORK; 	-- Se marca como disposicion libre para solicitarse
				UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
				COMMIT WORK;
				IF cBandDispActiva = 1 THEN
					BEGIN WORK; 
				END IF;								
				RETURN cCodRet;
			END IF;							

			IF fg_prestamo = 1 THEN
				--select to_char((dtFechaCrd + 1 UNITS MONTH), '%d/%m/%y') into dtFechaProxPago  from bdicred:"informix".sd_fechas; --RQM 10 1155
				select to_char((fecha_hoy + 1 UNITS MONTH), '%d/%m/%y') into dtFechaProxPago  from bdicred:"informix".sd_fechas;
				BEGIN WORK; 	-- Se marca como disposicion libre para solicitarse
					UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
				COMMIT WORK;
				
				select limit 1 to_char(fecha_cuota, '%d/%m/%y'),capital_mto_cuota 
					INTO dtFechaProxPago,pMensualidad
				FROM bdicred:sd_amortiza_creditocrd  where num_credito = cCtaPPF and capital_status = '3';

				SELECT NVL(telefono,'') INTO vNumCel
				FROM bdinteg:si_telefonos 
				WHERE tipo_tel = 2 AND verificado = 'V' AND status_tel = 'A' AND numcte = pnumcte; 
				IF vNumCel <> '' OR vNumCel IS NOT NULL THEN
				---  Tu inscripcion al plan de apoyo ha finalizado, a partir del ${string1} tus proximos 12 pagos mensuales son $${string2} con cargo a la cuenta terminacion ${string3}
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','SMS_97000','INS_PLAN_APO','000000000','','','2',trim(dtFechaProxPago),pMensualidad,right(trim(pCuentaCap),4),'','','','','','','','',vNumCel,1,'','','','','','')
						INTO cCodRet;
				END IF;
	
				IF cBandDispActiva = 1 THEN
					BEGIN WORK; 
				END IF;
				RETURN cCodRet ;
			ELSE 
				BEGIN WORK; 	-- Se marca como disposicion libre para solicitarse
				UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
				COMMIT WORK;
					IF cBandDispActiva = 1 THEN
						BEGIN WORK; 
					END IF;
				RETURN cCodRet ;
			END IF;	

		END IF;	
		
		BEGIN WORK; 	-- Se marca como disposicion libre para solicitarse
		UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
		COMMIT WORK;
		IF cBandDispActiva = 1 THEN
			BEGIN WORK; 
		END IF;
	
	END IF;

	IF cCodRet='000' THEN
		LET cCodRet='00000';
	END IF;

RETURN cCodRet;
     
END;
END PROCEDURE
DOCUMENT
'Autor: NA',
'Folio: RQM 10 1543 - 65670 - Incremento en la linea de credito Prestamo Digital',
'Fecha: 14-08-2023',
'Modificacion: Se agrego campo acepto_incremento y linea_prestamo_anterior en el SELECT de la tabla bdicred:informix.sd_linea_prestamo en la linea 334.',
'Base de datos: bdicred',
'Solicito: ';

CREATE PROCEDURE "informix".sp_actsdodiario(eNumCredito    CHAR(20),
											eSucursal      CHAR(4),
											eSdoCapital    MONEY(14,2),
											eMontoVencido  MONEY(14,2),
											eCapTrasNo     MONEY(14,2),
											eMtoVencTrasp  MONEY(14,2),
											eSdoIntereses  MONEY(14,2),
											eSdoExigInt    MONEY(14,2),
											eIvaIntVig     MONEY(14,2),
											eIvaIntVenc    MONEY(14,2),
											eMesesVdos     INTEGER,
											eMoratorios    MONEY(14,2),
											eMontoFinanciado MONEY(14,2),
											eFecha         DATE,
											eEtapa 		   CHAR(2),
											eFechaEtapa         DATE,
											iAct		   INTEGER)
RETURNING CHAR(3);


 DEFINE vsqlerr             INTEGER;
 DEFINE vCodRet             CHAR(3);
 DEFINE vFecha_mesant       DATE;
 DEFINE vFecha_primes       DATE;
 DEFINE eDia                INTEGER;
-- DEFINE vDiaCapital         INTEGER;
-- DEFINE vDiaVencido         INTEGER;
-- DEFINE vDiaNoExig          INTEGER;
-- DEFINE vDiaExig            INTEGER;

 define vexiste             integer;
 

 LET vCodRet = '000';
 LET vsqlerr = 0;
 let vexiste = 0;

 -- CONTROL DE ERRORES
BEGIN
 ON EXCEPTION SET vsqlerr
    IF vsqlerr != 0 THEN
       LET vCodRet=vsqlerr;
       RETURN vCodRet;
    END IF;
 END EXCEPTION;

 SET LOCK MODE TO WAIT 3; 
 SET ISOLATION TO DIRTY READ;
 
--SET DEBUG FILE TO  '/RESPALDOS/PruebasIFSR/actsdodiario_14p.out';
--TRACE ON;

--    IF eSdoCapital<=0 THEN LET eSdoCapital=0; LET vDiaCapital=0; ELSE LET vDiaCapital=1; END IF;
--    IF eMontoVencido<=0 THEN LET eMontoVencido=0; LET vDiaVencido=0; ELSE LET vDiaVencido=1; END IF;
--    IF eCapTrasNo<=0 THEN LET eCapTrasNo=0; LET vDiaNoExig=0; ELSE LET vDiaNoExig=1; END IF;
--    IF eMtoVencTrasp<=0 THEN LET eMtoVencTrasp=0; LET vDiaExig=0; ELSE LET vDiaExig=1; END IF;
--    IF eSdoIntereses<=0 THEN LET eSdoIntereses=0; END IF;
--    IF eSdoExigInt<=0 THEN LET eSdoExigInt=0; END IF;
--    IF eIvaIntVig<=0 THEN LET eIvaIntVig=0; END IF;
--    IF eIvaIntVenc<=0 THEN LET eIvaIntVenc=0; END IF;

--    IF eSdoCapital<=0 THEN LET vDiaCapital=0; ELSE LET vDiaCapital=1; END IF;
--    IF eMontoVencido<=0 THEN LET vDiaVencido=0; ELSE LET vDiaVencido=1; END IF;
--    IF eCapTrasNo<=0 THEN LET vDiaNoExig=0; ELSE LET vDiaNoExig=1; END IF;
--    IF eMtoVencTrasp<=0 THEN LET vDiaExig=0; ELSE LET vDiaExig=1; END IF;

/*KSOV*/ -- RQI 25 265 SE CAMBIA AL INICIO LAS SIGUIENTES ASIGNACIONES.
LET eFecha = eFecha;
LET vFecha_primes=MDY(MONTH(eFecha),'01',YEAR(eFecha));
LET eDia=day(eFecha);
/*KSOV*/


IF DAY(eFecha)=1 
	OR (MONTH(eFecha) = 1 AND DAY(eFecha)=2)    --KSOV --RQI 25 265 SE AGREG VALIDACION PARA QUE SE ACTUALICE LE REGISTRO EN EL MES DE ENERO.
		THEN

        LET vFecha_mesant=DATE(eFecha- 2 UNITS MONTH);
		
		IF --KSOV -- RQI 25 265 SE AGREG VALIDACION PARA QUE SE ACTUALICE LE REGISTRO EN EL MES DE ENERO.
		   MONTH(eFecha) = 1 THEN
		       LET eFecha=MDY(MONTH(eFecha),'01',YEAR(eFecha));
			   LET vFecha_mesant = DATE(eFecha- 2 UNITS MONTH); 
		END IF; --KSOV

             UPDATE sd_sdodiario SET capvig1        =  0,captrans1      =  0,capvencnoexig1 =  0,capvenexig1    =  0,
                                     intvig1        =  0,intvenc1       =  0,ivaintvig1     =  0,ivaintvenc1    =  0,
                                     capvig2        =  0,captrans2      =  0,capvencnoexig2 =  0,capvenexig2    =  0,
                                     intvig2        =  0,intvenc2       =  0,ivaintvig2     =  0,ivaintvenc2    =  0,
                                     capvig3        =  0,captrans3      =  0,capvencnoexig3 =  0,capvenexig3    =  0,
                                     intvig3        =  0,intvenc3       =  0,ivaintvig3     =  0,ivaintvenc3    =  0,
                                     capvig4        =  0,captrans4      =  0,capvencnoexig4 =  0,capvenexig4    =  0,
                                     intvig4        =  0,intvenc4       =  0,ivaintvig4     =  0,ivaintvenc4    =  0,
                                     capvig5        =  0,captrans5      =  0,capvencnoexig5 =  0,capvenexig5    =  0,
                                     intvig5        =  0,intvenc5       =  0,ivaintvig5     =  0,ivaintvenc5    =  0,
                                     capvig6        =  0,captrans6      =  0,capvencnoexig6 =  0,capvenexig6    =  0,
                                     intvig6        =  0,intvenc6       =  0,ivaintvig6     =  0,ivaintvenc6    =  0,
                                     capvig7        =  0,captrans7      =  0,capvencnoexig7 =  0,capvenexig7    =  0,
                                     intvig7        =  0,intvenc7       =  0,ivaintvig7     =  0,ivaintvenc7    =  0,
                                     capvig8        =  0,captrans8      =  0,capvencnoexig8 =  0,capvenexig8    =  0,
                                     intvig8        =  0,intvenc8       =  0,ivaintvig8     =  0,ivaintvenc8    =  0,
                                     capvig9        =  0,captrans9      =  0,capvencnoexig9 =  0,capvenexig9    =  0,
                                     intvig9        =  0,intvenc9       =  0,ivaintvig9     =  0,ivaintvenc9    =  0,
                                     capvig10       =  0,captrans10     =  0,capvencnoexig10=  0,capvenexig10   =  0,
                                     intvig10       =  0,intvenc10      =  0,ivaintvig10    =  0,ivaintvenc10   =  0,
                                     capvig11       =  0,captrans11     =  0,capvencnoexig11=  0,capvenexig11   =  0,
                                     intvig11       =  0,intvenc11      =  0,ivaintvig11    =  0,ivaintvenc11   =  0,
                                     capvig12       =  0,captrans12     =  0,capvencnoexig12=  0,capvenexig12   =  0,
                                     intvig12       =  0,intvenc12      =  0,ivaintvig12    =  0,ivaintvenc12   =  0,
                                     capvig13       =  0,captrans13     =  0,capvencnoexig13=  0,capvenexig13   =  0,
                                     intvig13       =  0,intvenc13      =  0,ivaintvig13    =  0,ivaintvenc13   =  0,
                                     capvig14       =  0,captrans14     =  0,capvencnoexig14=  0,capvenexig14   =  0,
                                     intvig14       =  0,intvenc14      =  0,ivaintvig14    =  0,ivaintvenc14   =  0,
                                     capvig15       =  0,captrans15     =  0,capvencnoexig15=  0,capvenexig15   =  0,
                                     intvig15       =  0,intvenc15      =  0,ivaintvig15    =  0,ivaintvenc15   =  0,
                                     capvig16       =  0,captrans16     =  0,capvencnoexig16=  0,capvenexig16   =  0,
                                     intvig16       =  0,intvenc16      =  0,ivaintvig16    =  0,ivaintvenc16   =  0,
                                     capvig17       =  0,captrans17     =  0,capvencnoexig17=  0,capvenexig17   =  0,
                                     intvig17       =  0,intvenc17      =  0,ivaintvig17    =  0,ivaintvenc17   =  0,
                                     capvig18       =  0,captrans18     =  0,capvencnoexig18=  0,capvenexig18   =  0,
                                     intvig18       =  0,intvenc18      =  0,ivaintvig18    =  0,ivaintvenc18   =  0,
                                     capvig19       =  0,captrans19     =  0,capvencnoexig19=  0,capvenexig19   =  0,
                                     intvig19       =  0,intvenc19      =  0,ivaintvig19    =  0,ivaintvenc19   =  0,
                                     capvig20       =  0,captrans20     =  0,capvencnoexig20=  0,capvenexig20   =  0,
                                     intvig20       =  0,intvenc20      =  0,ivaintvig20    =  0,ivaintvenc20   =  0,
                                     capvig21       =  0,captrans21     =  0,capvencnoexig21=  0,capvenexig21   =  0,
                                     intvig21       =  0,intvenc21      =  0,ivaintvig21    =  0,ivaintvenc21   =  0,
                                     capvig22       =  0,captrans22     =  0,capvencnoexig22=  0,capvenexig22   =  0,
                                     intvig22       =  0,intvenc22      =  0,ivaintvig22    =  0,ivaintvenc22   =  0,
                                     capvig23       =  0,captrans23     =  0,capvencnoexig23=  0,capvenexig23   =  0,
                                     intvig23       =  0,intvenc23      =  0,ivaintvig23    =  0,ivaintvenc23   =  0,
                                     capvig24       =  0,captrans24     =  0,capvencnoexig24=  0,capvenexig24   =  0,
                                     intvig24       =  0,intvenc24      =  0,ivaintvig24    =  0,ivaintvenc24   =  0,
                                     capvig25       =  0,captrans25     =  0,capvencnoexig25=  0,capvenexig25   =  0,
                                     intvig25       =  0,intvenc25      =  0,ivaintvig25    =  0,ivaintvenc25   =  0,
                                     capvig26       =  0,captrans26     =  0,capvencnoexig26=  0,capvenexig26   =  0,
                                     intvig26       =  0,intvenc26      =  0,ivaintvig26    =  0,ivaintvenc26   =  0,
                                     capvig27       =  0,captrans27     =  0,capvencnoexig27=  0,capvenexig27   =  0,
                                     intvig27       =  0,intvenc27      =  0,ivaintvig27    =  0,ivaintvenc27   =  0,
                                     capvig28       =  0,captrans28     =  0,capvencnoexig28=  0,capvenexig28   =  0,
                                     intvig28       =  0,intvenc28      =  0,ivaintvig28    =  0,ivaintvenc28   =  0,
                                     capvig29       =  0,captrans29     =  0,capvencnoexig29=  0,capvenexig29   =  0,
                                     intvig29       =  0,intvenc29      =  0,ivaintvig29    =  0,ivaintvenc29   =  0,
                                     capvig30       =  0,captrans30     =  0,capvencnoexig30=  0,capvenexig30   =  0,
                                     intvig30       =  0,intvenc30      =  0,ivaintvig30    =  0,ivaintvenc30   =  0,
                                     capvig31       =  0,captrans31     =  0,capvencnoexig31=  0,capvenexig31   =  0,
                                     intvig31       =  0,intvenc31      =  0,ivaintvig31    =  0,ivaintvenc31   =  0,
                                     diacapvig      = 0,acucapvig      = 0,diacaptra      = 0,acucaptra      = 0,
                                     diacapvennoexig  = 0, acucapvennoexig  = 0, diacapvencexig   = 0, acucapvencexig   = 0,
									 meses_vencidos1  = 0, meses_vencidos2  = 0, meses_vencidos3  = 0, meses_vencidos4  = 0,
									 meses_vencidos5  = 0, meses_vencidos6  = 0, meses_vencidos7  = 0, meses_vencidos8  = 0,
									 meses_vencidos9  = 0, meses_vencidos10 = 0, meses_vencidos11 = 0, meses_vencidos12 = 0,
									 meses_vencidos13 = 0, meses_vencidos14 = 0, meses_vencidos15 = 0, meses_vencidos16 = 0,
									 meses_vencidos17 = 0, meses_vencidos18 = 0, meses_vencidos19 = 0, meses_vencidos20 = 0,
									 meses_vencidos21 = 0, meses_vencidos22 = 0, meses_vencidos23 = 0, meses_vencidos24 = 0,
									 meses_vencidos25 = 0, meses_vencidos26 = 0, meses_vencidos27 = 0, meses_vencidos28 = 0,
									 meses_vencidos29 = 0, meses_vencidos30 = 0, meses_vencidos31 = 0,
 									 moratorios1  = 0, moratorios2  = 0, moratorios3  = 0, moratorios4  = 0, moratorios5  = 0,
									 moratorios6  = 0, moratorios7  = 0, moratorios8  = 0, moratorios9  = 0, moratorios10 = 0,
									 moratorios11 = 0, moratorios12 = 0, moratorios13 = 0, moratorios14 = 0, moratorios15 = 0,
									 moratorios16 = 0, moratorios17 = 0, moratorios18 = 0, moratorios19 = 0, moratorios20 = 0,
									 moratorios21 = 0, moratorios22 = 0, moratorios23 = 0, moratorios24 = 0, moratorios25 = 0,
									 moratorios26 = 0, moratorios27 = 0, moratorios28 = 0, moratorios29 = 0, moratorios30 = 0,
									 moratorios31 = 0, monto_financiado1 = 0, monto_financiado2 = 0, monto_financiado3 = 0,
									 monto_financiado4 = 0, monto_financiado5 = 0, monto_financiado6 = 0, monto_financiado7 = 0,
									 monto_financiado8 = 0, monto_financiado9 = 0, monto_financiado10 = 0, monto_financiado11 =0,
									 monto_financiado12 = 0, monto_financiado13 = 0, monto_financiado14 = 0, monto_financiado15 = 0,
									 monto_financiado16 = 0, monto_financiado17 = 0, monto_financiado18 = 0, monto_financiado19 = 0,
									 monto_financiado20 = 0, monto_financiado21 = 0, monto_financiado22 = 0, monto_financiado23 = 0,
									 monto_financiado24 = 0, monto_financiado25 = 0, monto_financiado26 = 0, monto_financiado27 = 0,
									 monto_financiado28 = 0, monto_financiado29 = 0, monto_financiado30 = 0, monto_financiado31 = 0,
									 fecha=eFecha, 
									-- IFSR se agrega actualizaciÃ³n para cuando sea dÃ­a uno
									status_cred_1 = '', fecha_venc_1 = null,act1 = null,
									status_cred_2 = '', fecha_venc_2 = null,act2 = null,
									status_cred_3 = '', fecha_venc_3 = null,act3 = null,
									status_cred_4 = '', fecha_venc_4 = null,act4 = null,
									status_cred_5 = '', fecha_venc_5 = null,act5 = null,
									status_cred_6 = '', fecha_venc_6 = null,act6 = null,
									status_cred_7 = '', fecha_venc_7 = null,act7 = null,
									status_cred_8 = '', fecha_venc_8 = null,act8 = null,
									status_cred_9 = '', fecha_venc_9 = null,act9 = null,
									status_cred_10 = '', fecha_venc_10 = null,act10 = null,
									status_cred_11 = '', fecha_venc_11 = null,act11 = null,
									status_cred_12 = '', fecha_venc_12 = null,act12 = null,
									status_cred_13 = '', fecha_venc_13 = null,act13 = null,
									status_cred_14 = '', fecha_venc_14 = null,act14 = null,
									status_cred_15 = '', fecha_venc_15 = null,act15 = null,
									status_cred_16 = '', fecha_venc_16 = null,act16 = null,
									status_cred_17 = '', fecha_venc_17 = null,act17 = null,
									status_cred_18 = '', fecha_venc_18 = null,act18 = null,
									status_cred_19 = '', fecha_venc_19 = null,act19 = null,
									status_cred_20 = '', fecha_venc_20 = null,act20 = null,
									status_cred_21 = '', fecha_venc_21 = null,act21 = null,
									status_cred_22 = '', fecha_venc_22 = null,act22 = null,
									status_cred_23 = '', fecha_venc_23 = null,act23 = null,
									status_cred_24 = '', fecha_venc_24 = null,act24 = null,
									status_cred_25 = '', fecha_venc_25 = null,act25 = null,
									status_cred_26 = '', fecha_venc_26 = null,act26 = null,
									status_cred_27 = '', fecha_venc_27 = null,act27 = null,
									status_cred_28 = '', fecha_venc_28 = null,act28 = null,
									status_cred_29 = '', fecha_venc_29 = null,act29 = null,
									status_cred_30 = '', fecha_venc_30 = null,act30 = null,
									status_cred_31 = '', fecha_venc_31 = null,act31 = null
									
             WHERE fecha=vFecha_mesant
               AND num_credito = eNumCredito;
    END IF;
	
	
	--KSOV RQI 25 265 SE COMENTAN ASIGNACIONES DE VARIABLES Y SE MUEVEN AL INICIO
    --LET vFecha_primes=MDY(MONTH(eFecha),'01',YEAR(eFecha));
    --let eDia=day(eFecha);
	
      Select count(*)
        into vexiste
        from sd_sdodiario
       where fecha=vFecha_primes
        and num_credito = eNumCredito;

    If (vexiste = 0) 
		--AND MONTH(eFecha) <> 1 -- KSOV RQI 25 265
	    Then
             INSERT INTO sd_sdodiario
             VALUES(vFecha_primes,eNumCredito, eSucursal,--3
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,--48
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,--48
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,--48
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,--48
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,--48
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,--16
					0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,--31
					0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,--31
					0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,--31
					--IFSR se actualiza para que en el primer registro que se tenga, se guarde la fecha vencimiento, status y act en el primer dÃ­a del mes
					null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,--31
					null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,--31
					null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);    end if;
	
	--SALDO VENCIDO + SALDOEXIGINT + IVA + MORATORIOS
    if (eSdoCapital + eMontoVencido + eCapTrasNo + eMtoVencTrasp + eSdoExigInt + eIvaIntVenc + eMoratorios) <> 0 then
        if (eDia <=15) then
            if (eDia <= 7) then
                if  (eDia = 1) then
                     UPDATE sd_sdodiario SET capvig1         = eSdoCapital,
                                             captrans1       = eMontoVencido,
                                             capvencnoexig1  = eCapTrasNo,
                                             capvenexig1     = eMtoVencTrasp,
                                             intvig1         = eSdoIntereses,
                                             intvenc1        = eSdoExigInt,
                                             ivaintvig1      = eIvaIntVig,
                                             ivaintvenc1     = eIvaIntVenc,
											 meses_vencidos1 = eMesesVdos,
											 moratorios1     = eMoratorios,
											 monto_financiado1 = eMontoFinanciado,
											 status_cred_1 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
											 fecha_venc_1 = eFechaEtapa,
											 act1 = iAct
                     WHERE fecha=vFecha_primes
                       AND num_credito = eNumCredito;

                 elif (eDia = 2) then				 
                     UPDATE sd_sdodiario SET capvig2        =  eSdoCapital,
                                             captrans2      =  eMontoVencido,
                                             capvencnoexig2 =  eCapTrasNo,
                                             capvenexig2    =  eMtoVencTrasp,
                                             intvig2        =  eSdoIntereses,
                                             intvenc2       =  eSdoExigInt,
                                             ivaintvig2     =  eIvaIntVig,
                                             ivaintvenc2    =  eIvaIntVenc,
                                             meses_vencidos2 = eMesesVdos,
											 moratorios2     = eMoratorios,
											 monto_financiado2 = eMontoFinanciado,
											 status_cred_2 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
											 fecha_venc_2 = eFechaEtapa,
											 act2 = iAct
                     WHERE fecha=vFecha_primes
                       AND num_credito = eNumCredito;

                 elif (eDia = 3) then
                             UPDATE sd_sdodiario SET capvig3        =  eSdoCapital,
                                                     captrans3      =  eMontoVencido,
                                                     capvencnoexig3 =  eCapTrasNo,
                                                     capvenexig3    =  eMtoVencTrasp,
                                                     intvig3        =  eSdoIntereses,
                                                     intvenc3       =  eSdoExigInt,
                                                     ivaintvig3     =  eIvaIntVig,
                                                     ivaintvenc3    =  eIvaIntVenc,
											         meses_vencidos3 = eMesesVdos,
											         moratorios3     = eMoratorios,
													 monto_financiado3 = eMontoFinanciado,
													 status_cred_3 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_3 = eFechaEtapa,
													 act3 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 4) then
                             UPDATE sd_sdodiario SET capvig4         =  eSdoCapital,
                                                     captrans4       =  eMontoVencido,
                                                     capvencnoexig4  =  eCapTrasNo,
                                                     capvenexig4     =  eMtoVencTrasp,
                                                     intvig4         =  eSdoIntereses,
                                                     intvenc4        =  eSdoExigInt,
                                                     ivaintvig4      =  eIvaIntVig,
                                                     ivaintvenc4     =  eIvaIntVenc,
													 meses_vencidos4 = eMesesVdos,
											         moratorios4     = eMoratorios,
													 monto_financiado4 = eMontoFinanciado,
													 status_cred_4 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_4 = eFechaEtapa,
													 act4 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 5) then
                             UPDATE sd_sdodiario SET capvig5        =  eSdoCapital,
                                                     captrans5      =  eMontoVencido,
                                                     capvencnoexig5 =  eCapTrasNo,
                                                     capvenexig5    =  eMtoVencTrasp,
                                                     intvig5        =  eSdoIntereses,
                                                     intvenc5       =  eSdoExigInt,
                                                     ivaintvig5     =  eIvaIntVig,
                                                     ivaintvenc5    =  eIvaIntVenc,
													 meses_vencidos5 = eMesesVdos,
											         moratorios5     = eMoratorios,
													 monto_financiado5 = eMontoFinanciado,
													 status_cred_5 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_5 = eFechaEtapa,
													 act5 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 6) then
                             UPDATE sd_sdodiario SET capvig6         = eSdoCapital,
                                                     captrans6       = eMontoVencido,
                                                     capvencnoexig6  = eCapTrasNo,
                                                     capvenexig6     = eMtoVencTrasp,
                                                     intvig6         = eSdoIntereses,
                                                     intvenc6        = eSdoExigInt,
                                                     ivaintvig6      = eIvaIntVig,
                                                     ivaintvenc6     = eIvaIntVenc,
													 meses_vencidos6 = eMesesVdos,
											         moratorios6     = eMoratorios,
													 monto_financiado6 = eMontoFinanciado,
													 status_cred_6 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_6 = eFechaEtapa,
													 act6 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 else
                             UPDATE sd_sdodiario SET capvig7         = eSdoCapital,
                                                     captrans7       = eMontoVencido,
                                                     capvencnoexig7  = eCapTrasNo,
                                                     capvenexig7     = eMtoVencTrasp,
                                                     intvig7         = eSdoIntereses,
                                                     intvenc7        = eSdoExigInt,
                                                     ivaintvig7      = eIvaIntVig,
                                                     ivaintvenc7     = eIvaIntVenc,
													 meses_vencidos7 = eMesesVdos,
											         moratorios7     = eMoratorios,
													 monto_financiado7 = eMontoFinanciado,
													 status_cred_7 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_7 = eFechaEtapa,
													 act7 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;
                 end if; -- 1-7
             else
                 if (eDia = 8) then
                             UPDATE sd_sdodiario SET capvig8         = eSdoCapital,
                                                     captrans8       = eMontoVencido,
                                                     capvencnoexig8  = eCapTrasNo,
                                                     capvenexig8     = eMtoVencTrasp,
                                                     intvig8         = eSdoIntereses,
                                                     intvenc8        = eSdoExigInt,
                                                     ivaintvig8      = eIvaIntVig,
                                                     ivaintvenc8     = eIvaIntVenc,
                                                     meses_vencidos8 = eMesesVdos,
											         moratorios8     = eMoratorios,
													 monto_financiado8 = eMontoFinanciado,
													 status_cred_8 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_8 = eFechaEtapa,
													 act8 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 9) then
                             UPDATE sd_sdodiario SET capvig9         = eSdoCapital,
                                                     captrans9       = eMontoVencido,
                                                     capvencnoexig9  = eCapTrasNo,
                                                     capvenexig9     = eMtoVencTrasp,
                                                     intvig9         = eSdoIntereses,
                                                     intvenc9        = eSdoExigInt,
                                                     ivaintvig9      = eIvaIntVig,
                                                     ivaintvenc9     = eIvaIntVenc,
													 meses_vencidos9 = eMesesVdos,
											         moratorios9     = eMoratorios,
													 monto_financiado9 = eMontoFinanciado,
													 status_cred_9 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_9 = eFechaEtapa,
													 act9 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 10) then
                             UPDATE sd_sdodiario SET capvig10         = eSdoCapital,
                                                     captrans10       = eMontoVencido,
                                                     capvencnoexig10  = eCapTrasNo,
                                                     capvenexig10     = eMtoVencTrasp,
                                                     intvig10         = eSdoIntereses,
                                                     intvenc10        = eSdoExigInt,
                                                     ivaintvig10      = eIvaIntVig,
                                                     ivaintvenc10     = eIvaIntVenc,
                                                     meses_vencidos10 = eMesesVdos,
											         moratorios10     = eMoratorios,
													 monto_financiado10 = eMontoFinanciado,
													 status_cred_10 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_10 = eFechaEtapa,
													 act10 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 11) then
                             UPDATE sd_sdodiario SET capvig11         = eSdoCapital,
                                                     captrans11       = eMontoVencido,
                                                     capvencnoexig11  = eCapTrasNo,
                                                     capvenexig11     = eMtoVencTrasp,
                                                     intvig11         = eSdoIntereses,
                                                     intvenc11        = eSdoExigInt,
                                                     ivaintvig11      = eIvaIntVig,
                                                     ivaintvenc11     = eIvaIntVenc,
													 meses_vencidos11 = eMesesVdos,
											         moratorios11     = eMoratorios,
													 monto_financiado11 = eMontoFinanciado,
													 status_cred_11 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_11 = eFechaEtapa,
													 act11 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 12) then
                             UPDATE sd_sdodiario SET capvig12         = eSdoCapital,
                                                     captrans12       = eMontoVencido,
                                                     capvencnoexig12  = eCapTrasNo,
                                                     capvenexig12     = eMtoVencTrasp,
                                                     intvig12         = eSdoIntereses,
                                                     intvenc12        = eSdoExigInt,
                                                     ivaintvig12      = eIvaIntVig,
                                                     ivaintvenc12     = eIvaIntVenc,
													 meses_vencidos12 = eMesesVdos,
											         moratorios12     = eMoratorios,
													 monto_financiado12 = eMontoFinanciado,
													 status_cred_12 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_12 = eFechaEtapa,
													 act12 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 13) then
                             UPDATE sd_sdodiario SET capvig13         = eSdoCapital,
                                                     captrans13       = eMontoVencido,
                                                     capvencnoexig13  = eCapTrasNo,
                                                     capvenexig13     = eMtoVencTrasp,
                                                     intvig13         = eSdoIntereses,
                                                     intvenc13        = eSdoExigInt,
                                                     ivaintvig13      = eIvaIntVig,
                                                     ivaintvenc13     = eIvaIntVenc,
													 meses_vencidos13 = eMesesVdos,
											         moratorios13     = eMoratorios,
													 monto_financiado13 = eMontoFinanciado,
													 status_cred_13 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_13 = eFechaEtapa,
													 act13 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 14) then
                             UPDATE sd_sdodiario SET capvig14         = eSdoCapital,
                                                     captrans14       = eMontoVencido,
                                                     capvencnoexig14  = eCapTrasNo,
                                                     capvenexig14     = eMtoVencTrasp,
                                                     intvig14         = eSdoIntereses,
                                                     intvenc14        = eSdoExigInt,
                                                     ivaintvig14      = eIvaIntVig,
                                                     ivaintvenc14     = eIvaIntVenc,
													 meses_vencidos14 = eMesesVdos,
											         moratorios14     = eMoratorios,
													 monto_financiado14 = eMontoFinanciado,
													 status_cred_14 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_14 = eFechaEtapa,
													 act14 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 else
                             UPDATE sd_sdodiario SET capvig15         = eSdoCapital,
                                                     captrans15       = eMontoVencido,
                                                     capvencnoexig15  = eCapTrasNo,
                                                     capvenexig15     = eMtoVencTrasp,
                                                     intvig15         = eSdoIntereses,
                                                     intvenc15        = eSdoExigInt,
                                                     ivaintvig15      = eIvaIntVig,
                                                     ivaintvenc15     = eIvaIntVenc,
													 meses_vencidos15 = eMesesVdos,
											         moratorios15     = eMoratorios,
													 monto_financiado15 = eMontoFinanciado,
													 status_cred_15 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_15 = eFechaEtapa,
													 act15 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;
                 end if; -- if 8-15
             end if; -- if 7
         else
             if (eDia <= 23) then
                 if (eDia = 16) then
                             UPDATE sd_sdodiario SET capvig16         = eSdoCapital,
                                                     captrans16       = eMontoVencido,
                                                     capvencnoexig16  = eCapTrasNo,
                                                     capvenexig16     = eMtoVencTrasp,
                                                     intvig16         = eSdoIntereses,
                                                     intvenc16        = eSdoExigInt,
                                                     ivaintvig16      = eIvaIntVig,
                                                     ivaintvenc16     = eIvaIntVenc,
													 meses_vencidos16 = eMesesVdos,
											         moratorios16     = eMoratorios,
													 monto_financiado16 = eMontoFinanciado,
													 status_cred_16 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_16 = eFechaEtapa,
													 act16 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 17) then
                             UPDATE sd_sdodiario SET capvig17         = eSdoCapital,
                                                     captrans17       = eMontoVencido,
                                                     capvencnoexig17  = eCapTrasNo,
                                                     capvenexig17     = eMtoVencTrasp,
                                                     intvig17         = eSdoIntereses,
                                                     intvenc17        = eSdoExigInt,
                                                     ivaintvig17      = eIvaIntVig,
                                                     ivaintvenc17     = eIvaIntVenc,
													 meses_vencidos17 = eMesesVdos,
											         moratorios17     = eMoratorios,
													 monto_financiado17 = eMontoFinanciado,
													 status_cred_17 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_17 = eFechaEtapa,
													 act17 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 18) then
                             UPDATE sd_sdodiario SET capvig18         = eSdoCapital,
                                                     captrans18       = eMontoVencido,
                                                     capvencnoexig18  = eCapTrasNo,
                                                     capvenexig18     = eMtoVencTrasp,
                                                     intvig18         = eSdoIntereses,
                                                     intvenc18        = eSdoExigInt,
                                                     ivaintvig18      = eIvaIntVig,
                                                     ivaintvenc18     = eIvaIntVenc,
													 meses_vencidos18 = eMesesVdos,
											         moratorios18     = eMoratorios,
													 monto_financiado18 = eMontoFinanciado,
													 status_cred_18 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_18 = eFechaEtapa,
													 act18 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 19) then
                             UPDATE sd_sdodiario SET capvig19         = eSdoCapital,
                                                     captrans19       = eMontoVencido,
                                                     capvencnoexig19  = eCapTrasNo,
                                                     capvenexig19     = eMtoVencTrasp,
                                                     intvig19         = eSdoIntereses,
                                                     intvenc19        = eSdoExigInt,
                                                     ivaintvig19      = eIvaIntVig,
                                                     ivaintvenc19     = eIvaIntVenc,
													 meses_vencidos19 = eMesesVdos,
											         moratorios19     = eMoratorios,
													 monto_financiado19 = eMontoFinanciado,
													 status_cred_19 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_19 = eFechaEtapa,
													 act19 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 20) then
                             UPDATE sd_sdodiario SET capvig20         = eSdoCapital,
                                                     captrans20       = eMontoVencido,
                                                     capvencnoexig20  = eCapTrasNo,
                                                     capvenexig20     = eMtoVencTrasp,
                                                     intvig20         = eSdoIntereses,
                                                     intvenc20        = eSdoExigInt,
                                                     ivaintvig20      = eIvaIntVig,
                                                     ivaintvenc20     = eIvaIntVenc,
													 meses_vencidos20 = eMesesVdos,
											         moratorios20     = eMoratorios,
													 monto_financiado20 = eMontoFinanciado,
													 status_cred_20 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_20 = eFechaEtapa,
													 act20 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 21) then
                             UPDATE sd_sdodiario SET capvig21         = eSdoCapital,
                                                     captrans21       = eMontoVencido,
                                                     capvencnoexig21  = eCapTrasNo,
                                                     capvenexig21     = eMtoVencTrasp,
                                                     intvig21         = eSdoIntereses,
                                                     intvenc21        = eSdoExigInt,
                                                     ivaintvig21      = eIvaIntVig,
                                                     ivaintvenc21     = eIvaIntVenc,
													 meses_vencidos21 = eMesesVdos,
											         moratorios21     = eMoratorios,
													 monto_financiado21 = eMontoFinanciado,
													 status_cred_21 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_21 = eFechaEtapa,
													 act21 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 22) then
                             UPDATE sd_sdodiario SET capvig22         = eSdoCapital,
                                                     captrans22       = eMontoVencido,
                                                     capvencnoexig22  = eCapTrasNo,
                                                     capvenexig22     = eMtoVencTrasp,
                                                     intvig22         = eSdoIntereses,
                                                     intvenc22        = eSdoExigInt,
                                                     ivaintvig22      = eIvaIntVig,
                                                     ivaintvenc22     = eIvaIntVenc,
													 meses_vencidos22 = eMesesVdos,
											         moratorios22     = eMoratorios,
													 monto_financiado22 = eMontoFinanciado,
													 status_cred_22 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_22 = eFechaEtapa,
													 act22 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 else
                             UPDATE sd_sdodiario SET capvig23         = eSdoCapital,
                                                     captrans23       = eMontoVencido,
                                                     capvencnoexig23  = eCapTrasNo,
                                                     capvenexig23     = eMtoVencTrasp,
                                                     intvig23         = eSdoIntereses,
                                                     intvenc23        = eSdoExigInt,
                                                     ivaintvig23      = eIvaIntVig,
                                                     ivaintvenc23     = eIvaIntVenc,
													 meses_vencidos23 = eMesesVdos,
											         moratorios23     = eMoratorios,
													 monto_financiado23 = eMontoFinanciado,
													 status_cred_23 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_23 = eFechaEtapa,
													 act23 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;
                 end if; --if 16-23
             else
                 if (eDia = 24) then
                             UPDATE sd_sdodiario SET capvig24         = eSdoCapital,
                                                     captrans24       = eMontoVencido,
                                                     capvencnoexig24  = eCapTrasNo,
                                                     capvenexig24     = eMtoVencTrasp,
                                                     intvig24         = eSdoIntereses,
                                                     intvenc24        = eSdoExigInt,
                                                     ivaintvig24      = eIvaIntVig,
                                                     ivaintvenc24     = eIvaIntVenc,
													 meses_vencidos24 = eMesesVdos,
											         moratorios24     = eMoratorios,
													 monto_financiado24 = eMontoFinanciado,
													 status_cred_24 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_24 = eFechaEtapa,
													 act24 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 25) then
                             UPDATE sd_sdodiario SET capvig25         = eSdoCapital,
                                                     captrans25       = eMontoVencido,
                                                     capvencnoexig25  = eCapTrasNo,
                                                     capvenexig25     = eMtoVencTrasp,
                                                     intvig25         = eSdoIntereses,
                                                     intvenc25        = eSdoExigInt,
                                                     ivaintvig25      = eIvaIntVig,
                                                     ivaintvenc25     = eIvaIntVenc,
													 meses_vencidos25 = eMesesVdos,
											         moratorios25     = eMoratorios,
													 monto_financiado25 = eMontoFinanciado,
													 status_cred_25 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_25 = eFechaEtapa,
													 act25 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 26) then
                             UPDATE sd_sdodiario SET capvig26         = eSdoCapital,
                                                     captrans26       = eMontoVencido,
                                                     capvencnoexig26  = eCapTrasNo,
                                                     capvenexig26     = eMtoVencTrasp,
                                                     intvig26         = eSdoIntereses,
                                                     intvenc26        = eSdoExigInt,
                                                     ivaintvig26      = eIvaIntVig,
                                                     ivaintvenc26     = eIvaIntVenc,
													 meses_vencidos26 = eMesesVdos,
											         moratorios26     = eMoratorios,
													 monto_financiado26 = eMontoFinanciado,
													 status_cred_26 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_26 = eFechaEtapa,
													 act26 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 27) then
                             UPDATE sd_sdodiario SET capvig27         = eSdoCapital,
                                                     captrans27       = eMontoVencido,
                                                     capvencnoexig27  = eCapTrasNo,
                                                     capvenexig27     = eMtoVencTrasp,
                                                     intvig27         = eSdoIntereses,
                                                     intvenc27        = eSdoExigInt,
                                                     ivaintvig27      = eIvaIntVig,
                                                     ivaintvenc27     = eIvaIntVenc,
													 meses_vencidos27 = eMesesVdos,
											         moratorios27     = eMoratorios,
													 monto_financiado27 = eMontoFinanciado,
													 status_cred_27 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_27 = eFechaEtapa,
													 act27 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 28) then
                             UPDATE sd_sdodiario SET capvig28         = eSdoCapital,
                                                     captrans28       = eMontoVencido,
                                                     capvencnoexig28  = eCapTrasNo,
                                                     capvenexig28     = eMtoVencTrasp,
                                                     intvig28         = eSdoIntereses,
                                                     intvenc28        = eSdoExigInt,
                                                     ivaintvig28      = eIvaIntVig,
                                                     ivaintvenc28     = eIvaIntVenc,
													 meses_vencidos28 = eMesesVdos,
											         moratorios28     = eMoratorios,
													 monto_financiado28 = eMontoFinanciado,
													 status_cred_28 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_28 = eFechaEtapa,
													 act28 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 29) then
                             UPDATE sd_sdodiario SET capvig29         = eSdoCapital,
                                                     captrans29       = eMontoVencido,
                                                     capvencnoexig29  = eCapTrasNo,
                                                     capvenexig29     = eMtoVencTrasp,
                                                     intvig29         = eSdoIntereses,
                                                     intvenc29        = eSdoExigInt,
                                                     ivaintvig29      = eIvaIntVig,
                                                     ivaintvenc29     = eIvaIntVenc,
													 meses_vencidos29 = eMesesVdos,
											         moratorios29     = eMoratorios,
													 monto_financiado29 = eMontoFinanciado,
													 status_cred_29 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_29 = eFechaEtapa,
													 act29 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 30) then
                             UPDATE sd_sdodiario SET capvig30         = eSdoCapital,
                                                     captrans30       = eMontoVencido,
                                                     capvencnoexig30  = eCapTrasNo,
                                                     capvenexig30     = eMtoVencTrasp,
                                                     intvig30         = eSdoIntereses,
                                                     intvenc30        = eSdoExigInt,
                                                     ivaintvig30      = eIvaIntVig,
                                                     ivaintvenc30     = eIvaIntVenc,
													 meses_vencidos30 = eMesesVdos,
											         moratorios30     = eMoratorios,
													 monto_financiado30 = eMontoFinanciado,
													 status_cred_30 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_30 = eFechaEtapa,
													 act30 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 else
                             UPDATE sd_sdodiario SET capvig31        =  eSdoCapital,
                                                     captrans31      =  eMontoVencido,
                                                     capvencnoexig31 =  eCapTrasNo,
                                                     capvenexig31    =  eMtoVencTrasp,
                                                     intvig31        =  eSdoIntereses,
                                                     intvenc31       =  eSdoExigInt,
                                                     ivaintvig31     =  eIvaIntVig,
                                                     ivaintvenc31    =  eIvaIntVenc,
													 meses_vencidos31 = eMesesVdos,
											         moratorios31     = eMoratorios,
													 monto_financiado31 = eMontoFinanciado,
													 status_cred_31 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
													 fecha_venc_31 = eFechaEtapa,
													 act31 = iAct
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;
                 end if; --if 24-31
            end if; -- if 23
       end if; -- if 15
    --END IF;
	ELSE -- IFSR se agrega validaciÃ³n para actualizar la etapa dependiendo el dÃ­a
		if  (eDia = 1) then
			UPDATE sd_sdodiario SET
				status_cred_1 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_1 = eFechaEtapa,
				act1 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 2) then
			UPDATE sd_sdodiario SET
				status_cred_2 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_2 = eFechaEtapa,
				act2 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 3) then
			UPDATE sd_sdodiario SET
				status_cred_3 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_3 = eFechaEtapa,
				act3 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 4) then
			UPDATE sd_sdodiario SET
				status_cred_4 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_4 = eFechaEtapa,
				act4 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 5) then
			UPDATE sd_sdodiario SET
				status_cred_5 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_5 = eFechaEtapa,
				act5 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 6) then
			UPDATE sd_sdodiario SET
				status_cred_6 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_6 = eFechaEtapa,
				act6 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 7) then
			UPDATE sd_sdodiario SET
				status_cred_7 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_7 = eFechaEtapa,
				act7 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 8) then
			UPDATE sd_sdodiario SET
				status_cred_8 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_8 = eFechaEtapa,
				act8 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 9) then
			UPDATE sd_sdodiario SET
				status_cred_9 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_9 = eFechaEtapa,
				act9 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 10) then
			UPDATE sd_sdodiario SET
				status_cred_10 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_10 = eFechaEtapa,
				act10 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 11) then
			UPDATE sd_sdodiario SET
				status_cred_11 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_11 = eFechaEtapa,
				act11 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 12) then
			UPDATE sd_sdodiario SET
				status_cred_12 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_12 = eFechaEtapa,
				act12 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 13) then
			UPDATE sd_sdodiario SET
				status_cred_13 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_13 = eFechaEtapa,
				act13 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 14) then
			UPDATE sd_sdodiario SET
				status_cred_14 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_14 = eFechaEtapa,
				act14 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 15) then
			UPDATE sd_sdodiario SET
				status_cred_15 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_15 = eFechaEtapa,
				act15 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 16) then
			UPDATE sd_sdodiario SET
				status_cred_16 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_16 = eFechaEtapa,
				act16 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 17) then
			UPDATE sd_sdodiario SET
				status_cred_17 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_17 = eFechaEtapa,
				act17 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 18) then
			UPDATE sd_sdodiario SET
				status_cred_18 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_18 = eFechaEtapa,
				act18 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 19) then
			UPDATE sd_sdodiario SET
				status_cred_19 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_19 = eFechaEtapa,
				act19 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 20) then
			UPDATE sd_sdodiario SET
				status_cred_20 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_20 = eFechaEtapa,
				act20 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 21) then
			UPDATE sd_sdodiario SET
				status_cred_21 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_21 = eFechaEtapa,
				act21 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 22) then
			UPDATE sd_sdodiario SET
				status_cred_22 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_22 = eFechaEtapa,
				act22 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 23) then
			UPDATE sd_sdodiario SET
				status_cred_23 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_23 = eFechaEtapa,
				act23 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 24) then
			UPDATE sd_sdodiario SET
				status_cred_24 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_24 = eFechaEtapa,
				act24 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 25) then
			UPDATE sd_sdodiario SET
				status_cred_25 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_25 = eFechaEtapa,
				act25 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 26) then
			UPDATE sd_sdodiario SET
				status_cred_26 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_26 = eFechaEtapa,
				act26 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 27) then
			UPDATE sd_sdodiario SET
				status_cred_27 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_27 = eFechaEtapa,
				act27 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 28) then
			UPDATE sd_sdodiario SET
				status_cred_28 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_28 = eFechaEtapa,
				act28 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 29) then
			UPDATE sd_sdodiario SET
				status_cred_29 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_29 = eFechaEtapa,
				act29 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 30) then
			UPDATE sd_sdodiario SET
				status_cred_30 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_30 = eFechaEtapa,
				act30 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 31) then
			UPDATE sd_sdodiario SET
				status_cred_31 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃ­a en que se encuentre la fecha
				fecha_venc_31 = eFechaEtapa,
				act31 = iAct
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
		
		END IF;
	END IF;
END
	RETURN vCodRet;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_actsdodiariocrd(eNumCredito CHAR(20),
													 eSucursal      CHAR(4),
													 eSdoCapital    MONEY(14,2),
													 eMontoVencido  MONEY(14,2),
													 eCapTrasNo     MONEY(14,2),
													 eMtoVencTrasp  MONEY(14,2),
													 eSdoIntereses  MONEY(14,2),
													 eSdoExigInt    MONEY(14,2),
													 eIvaIntVig     MONEY(14,2),
													 eIvaIntVenc    MONEY(14,2),
													 eIntVenBal     MONEY(14,2),
													 eIvaIntVenBal  MONEY(14,2),
													 eMontoFinanciado MONEY(14,2),
													 eFecha         DATE,
													 eEtapa 		   CHAR(2),
													 iAtr			INTEGER)
RETURNING CHAR(3);


 DEFINE vsqlerr             INTEGER;
 DEFINE vCodRet             CHAR(3);
 DEFINE vFecha_mesant       DATE;
 DEFINE vFecha_primes       DATE;
 DEFINE eDia                INTEGER;
 DEFINE vDiaCapital         INTEGER;
 DEFINE vDiaVencido         INTEGER;
 DEFINE vDiaNoExig          INTEGER;
 DEFINE vDiaExig            INTEGER;
 

 LET vCodRet = '000';
 LET vsqlerr = 0;

 -- CONTROL DE ERRORES
BEGIN
 ON EXCEPTION SET vsqlerr
    IF vsqlerr != 0 THEN
       LET vCodRet=vsqlerr;
       RETURN vCodRet;
    END IF;
 END EXCEPTION;
 
 SET LOCK MODE TO WAIT 3; 
 SET ISOLATION TO DIRTY READ; 
 
 
--SET DEBUG FILE TO  '/RESPALDOS/INFOSAT/RIESGOS/RQM07134/SDOSCRD/actsdodiariocrd_14crd.out';
--TRACE ON;
   
 --   IF eSdoCapital<=0 THEN LET eSdoCapital=0; LET vDiaCapital=0; ELSE LET vDiaCapital=1; END IF; 
 --   IF eMontoVencido<=0 THEN LET eMontoVencido=0; LET vDiaVencido=0; ELSE LET vDiaVencido=1; END IF; 
 --   IF eCapTrasNo<=0 THEN LET eCapTrasNo=0; LET vDiaNoExig=0; ELSE LET vDiaNoExig=1; END IF; 
 --   IF eMtoVencTrasp<=0 THEN LET eMtoVencTrasp=0; LET vDiaExig=0; ELSE LET vDiaExig=1; END IF; 
 --   IF eSdoIntereses<=0 THEN LET eSdoIntereses=0; END IF; 
 --   IF eSdoExigInt<=0 THEN LET eSdoExigInt=0; END IF; 
 --   IF eIvaIntVig<=0 THEN LET eIvaIntVig=0; END IF; 
 --   IF eIvaIntVenc<=0 THEN LET eIvaIntVenc=0; END IF; 

    IF eSdoCapital<=0 THEN LET vDiaCapital=0; ELSE LET vDiaCapital=1; END IF; 
    IF eMontoVencido<=0 THEN LET vDiaVencido=0; ELSE LET vDiaVencido=1; END IF; 
    IF eCapTrasNo<=0 THEN LET vDiaNoExig=0; ELSE LET vDiaNoExig=1; END IF; 
    IF eMtoVencTrasp<=0 THEN LET vDiaExig=0; ELSE LET vDiaExig=1; END IF; 
	
	--KSOV -- RQI 25 265 SE CAMBIA AL INICIO LAS SIGUIENTES ASIGNACIONES.
    LET vFecha_primes=MDY(MONTH(eFecha),'01',YEAR(eFecha));
    let eDia=day(eFecha);
	--KSOV

IF DAY(eFecha)=1  
	   OR (MONTH(eFecha) = 1 AND DAY(eFecha)= 2) --KSOV --RQI 25 265 SE AGREG VALIDACION PARA QUE SE ACTUALICE LE REGISTRO EN EL MES DE ENERO.
			 THEN			 
			 LET vFecha_mesant=DATE(eFecha- 3 UNITS MONTH);
			 
		IF --KSOV -- RQI 25 265 SE AGREG VALIDACION PARA QUE SE ACTUALICE LE REGISTRO EN EL MES DE ENERO.
		   MONTH(eFecha) = 1 THEN
		       LET eFecha=MDY(MONTH(eFecha),'01',YEAR(eFecha));
			   LET vFecha_mesant=DATE(eFecha- 3 UNITS MONTH);
		END IF; --KSOV


             UPDATE sd_sdodiariocrd SET capvig1        =  0,captrans1      =  0,capvencnoexig1 =  0,capvenexig1    =  0, ivaint_venc_bal1=  0, 
                                     intvig1        =  0,intvenc1       =  0,ivaintvig1     =  0,ivaintvenc1    =  0, int_venc_bal1=  0,
                                     capvig2        =  0,captrans2      =  0,capvencnoexig2 =  0,capvenexig2    =  0, ivaint_venc_bal2=  0,
                                     intvig2        =  0,intvenc2       =  0,ivaintvig2     =  0,ivaintvenc2    =  0, int_venc_bal2=  0,
                                     capvig3        =  0,captrans3      =  0,capvencnoexig3 =  0,capvenexig3    =  0, ivaint_venc_bal3=  0,
                                     intvig3        =  0,intvenc3       =  0,ivaintvig3     =  0,ivaintvenc3    =  0, int_venc_bal3=  0,
                                     capvig4        =  0,captrans4      =  0,capvencnoexig4 =  0,capvenexig4    =  0, ivaint_venc_bal4=  0,
                                     intvig4        =  0,intvenc4       =  0,ivaintvig4     =  0,ivaintvenc4    =  0, int_venc_bal4=  0,
                                     capvig5        =  0,captrans5      =  0,capvencnoexig5 =  0,capvenexig5    =  0, ivaint_venc_bal5=  0,
                                     intvig5        =  0,intvenc5       =  0,ivaintvig5     =  0,ivaintvenc5    =  0, int_venc_bal5=  0,
                                     capvig6        =  0,captrans6      =  0,capvencnoexig6 =  0,capvenexig6    =  0, ivaint_venc_bal6=  0,
                                     intvig6        =  0,intvenc6       =  0,ivaintvig6     =  0,ivaintvenc6    =  0, int_venc_bal6=  0,
                                     capvig7        =  0,captrans7      =  0,capvencnoexig7 =  0,capvenexig7    =  0, ivaint_venc_bal7=  0,
                                     intvig7        =  0,intvenc7       =  0,ivaintvig7     =  0,ivaintvenc7    =  0, int_venc_bal7=  0,
                                     capvig8        =  0,captrans8      =  0,capvencnoexig8 =  0,capvenexig8    =  0, ivaint_venc_bal8=  0,
                                     intvig8        =  0,intvenc8       =  0,ivaintvig8     =  0,ivaintvenc8    =  0, int_venc_bal8=  0,
                                     capvig9        =  0,captrans9      =  0,capvencnoexig9 =  0,capvenexig9    =  0, ivaint_venc_bal9=  0,
                                     intvig9        =  0,intvenc9       =  0,ivaintvig9     =  0,ivaintvenc9    =  0, int_venc_bal9=  0,
                                     capvig10       =  0,captrans10     =  0,capvencnoexig10=  0,capvenexig10   =  0, ivaint_venc_bal10= 0,
                                     intvig10       =  0,intvenc10      =  0,ivaintvig10    =  0,ivaintvenc10   =  0, int_venc_bal10=  0,
                                     capvig11       =  0,captrans11     =  0,capvencnoexig11=  0,capvenexig11   =  0, ivaint_venc_bal11=  0,
                                     intvig11       =  0,intvenc11      =  0,ivaintvig11    =  0,ivaintvenc11   =  0, int_venc_bal11=  0,
                                     capvig12       =  0,captrans12     =  0,capvencnoexig12=  0,capvenexig12   =  0, ivaint_venc_bal12=  0,
                                     intvig12       =  0,intvenc12      =  0,ivaintvig12    =  0,ivaintvenc12   =  0, int_venc_bal12=  0,
                                     capvig13       =  0,captrans13     =  0,capvencnoexig13=  0,capvenexig13   =  0, ivaint_venc_bal13=  0,
                                     intvig13       =  0,intvenc13      =  0,ivaintvig13    =  0,ivaintvenc13   =  0, int_venc_bal13=  0,
                                     capvig14       =  0,captrans14     =  0,capvencnoexig14=  0,capvenexig14   =  0, ivaint_venc_bal14=  0,
                                     intvig14       =  0,intvenc14      =  0,ivaintvig14    =  0,ivaintvenc14   =  0, int_venc_bal14=  0,
                                     capvig15       =  0,captrans15     =  0,capvencnoexig15=  0,capvenexig15   =  0, ivaint_venc_bal15=  0,
                                     intvig15       =  0,intvenc15      =  0,ivaintvig15    =  0,ivaintvenc15   =  0, int_venc_bal15=  0,
                                     capvig16       =  0,captrans16     =  0,capvencnoexig16=  0,capvenexig16   =  0, ivaint_venc_bal16=  0,
                                     intvig16       =  0,intvenc16      =  0,ivaintvig16    =  0,ivaintvenc16   =  0, int_venc_bal16=  0,
                                     capvig17       =  0,captrans17     =  0,capvencnoexig17=  0,capvenexig17   =  0, ivaint_venc_bal17=  0,
                                     intvig17       =  0,intvenc17      =  0,ivaintvig17    =  0,ivaintvenc17   =  0, int_venc_bal17=  0,
                                     capvig18       =  0,captrans18     =  0,capvencnoexig18=  0,capvenexig18   =  0, ivaint_venc_bal18=  0,
                                     intvig18       =  0,intvenc18      =  0,ivaintvig18    =  0,ivaintvenc18   =  0, int_venc_bal18=  0, 
                                     capvig19       =  0,captrans19     =  0,capvencnoexig19=  0,capvenexig19   =  0, ivaint_venc_bal19=  0,
                                     intvig19       =  0,intvenc19      =  0,ivaintvig19    =  0,ivaintvenc19   =  0, int_venc_bal19=  0,
                                     capvig20       =  0,captrans20     =  0,capvencnoexig20=  0,capvenexig20   =  0, ivaint_venc_bal20=  0,
                                     intvig20       =  0,intvenc20      =  0,ivaintvig20    =  0,ivaintvenc20   =  0, int_venc_bal20=  0,
                                     capvig21       =  0,captrans21     =  0,capvencnoexig21=  0,capvenexig21   =  0, ivaint_venc_bal21=  0,
                                     intvig21       =  0,intvenc21      =  0,ivaintvig21    =  0,ivaintvenc21   =  0, int_venc_bal21=  0,
                                     capvig22       =  0,captrans22     =  0,capvencnoexig22=  0,capvenexig22   =  0, ivaint_venc_bal22=  0,
                                     intvig22       =  0,intvenc22      =  0,ivaintvig22    =  0,ivaintvenc22   =  0, int_venc_bal22=  0,
                                     capvig23       =  0,captrans23     =  0,capvencnoexig23=  0,capvenexig23   =  0, ivaint_venc_bal23=  0,
                                     intvig23       =  0,intvenc23      =  0,ivaintvig23    =  0,ivaintvenc23   =  0, int_venc_bal23=  0,
                                     capvig24       =  0,captrans24     =  0,capvencnoexig24=  0,capvenexig24   =  0, ivaint_venc_bal24=  0,
                                     intvig24       =  0,intvenc24      =  0,ivaintvig24    =  0,ivaintvenc24   =  0, int_venc_bal24=  0,
                                     capvig25       =  0,captrans25     =  0,capvencnoexig25=  0,capvenexig25   =  0, ivaint_venc_bal25=  0,
                                     intvig25       =  0,intvenc25      =  0,ivaintvig25    =  0,ivaintvenc25   =  0, int_venc_bal25=  0,
                                     capvig26       =  0,captrans26     =  0,capvencnoexig26=  0,capvenexig26   =  0, ivaint_venc_bal26=  0,
                                     intvig26       =  0,intvenc26      =  0,ivaintvig26    =  0,ivaintvenc26   =  0, int_venc_bal26=  0,
                                     capvig27       =  0,captrans27     =  0,capvencnoexig27=  0,capvenexig27   =  0, ivaint_venc_bal27=  0,
                                     intvig27       =  0,intvenc27      =  0,ivaintvig27    =  0,ivaintvenc27   =  0, int_venc_bal27=  0,
                                     capvig28       =  0,captrans28     =  0,capvencnoexig28=  0,capvenexig28   =  0, ivaint_venc_bal28=  0,
                                     intvig28       =  0,intvenc28      =  0,ivaintvig28    =  0,ivaintvenc28   =  0, int_venc_bal28=  0,
                                     capvig29       =  0,captrans29     =  0,capvencnoexig29=  0,capvenexig29   =  0, ivaint_venc_bal29=  0,
                                     intvig29       =  0,intvenc29      =  0,ivaintvig29    =  0,ivaintvenc29   =  0, int_venc_bal29=  0,
                                     capvig30       =  0,captrans30     =  0,capvencnoexig30=  0,capvenexig30   =  0, ivaint_venc_bal30=  0,
                                     intvig30       =  0,intvenc30      =  0,ivaintvig30    =  0,ivaintvenc30   =  0, int_venc_bal30=  0,
                                     capvig31       =  0,captrans31     =  0,capvencnoexig31=  0,capvenexig31   =  0, ivaint_venc_bal31=  0,
                                     intvig31       =  0,intvenc31      =  0,ivaintvig31    =  0,ivaintvenc31   =  0, int_venc_bal31=  0,
                                     diacapvig      = 0,acucapvig      = 0,diacaptra      = 0,acucaptra      = 0,
                                     diacapvennoexig= 0,acucapvennoexig= 0,diacapvencexig = 0,acucapvencexig = 0,fecha=eFecha,
									 monto_financiado1 = 0, monto_financiado2 = 0, monto_financiado3 = 0,
									 monto_financiado4 = 0, monto_financiado5 = 0, monto_financiado6 = 0, monto_financiado7 = 0,
									 monto_financiado8 = 0, monto_financiado9 = 0, monto_financiado10 = 0, monto_financiado11 =0,
									 monto_financiado12 = 0, monto_financiado13 = 0, monto_financiado14 = 0, monto_financiado15 = 0,
									 monto_financiado16 = 0, monto_financiado17 = 0, monto_financiado18 = 0, monto_financiado19 = 0,
									 monto_financiado20 = 0, monto_financiado21 = 0, monto_financiado22 = 0, monto_financiado23 = 0,
									 monto_financiado24 = 0, monto_financiado25 = 0, monto_financiado26 = 0, monto_financiado27 = 0,
									 monto_financiado28 = 0, monto_financiado29 = 0, monto_financiado30 = 0, monto_financiado31 = 0,
									 --status_cred_1 = NVL(eEtapa,''), fecha_venc_1 = eFechaEtapa -- IFSR se agrega actualizaciÃÂ³n para cuando sea dÃÂ­a uno
									 --IFSR se actualiza para que en el primer registro que se tenga, se guarde la fecha vencimiento y el status en el primer dÃÂ­a del mes
									 --fecha_venc_1 = eFechaEtapa,fecha_venc_2 = null,fecha_venc_3 = null,fecha_venc_4 = null,fecha_venc_5 = null,fecha_venc_6 = null,
									 --fecha_venc_7 = null,fecha_venc_8 = null,fecha_venc_9 = null,fecha_venc_10 = null,fecha_venc_11 = null,fecha_venc_12 = null,
									 --fecha_venc_13 = null,fecha_venc_14 = null,fecha_venc_15 = null,fecha_venc_16 = null,fecha_venc_17 = null,fecha_venc_18 = null,
									 --fecha_venc_19 = null,fecha_venc_20 = null,fecha_venc_21 = null,fecha_venc_22 = null,fecha_venc_23 = null,fecha_venc_24 = null,
									 --fecha_venc_25 = null,fecha_venc_26 = null,fecha_venc_27 = null,fecha_venc_28 = null,fecha_venc_29 = null,fecha_venc_30 = null,fecha_venc_31 = null,
									 status_cred_1 = NVL(eEtapa,''),status_cred_2 = null,status_cred_3 = null,status_cred_4 = null,status_cred_5 = null,status_cred_6 = null,
									 status_cred_7 = null,status_cred_8 = null,status_cred_9 = null,status_cred_10 = null,status_cred_11 = null,status_cred_12 = null,
									 status_cred_13 = null,status_cred_14 = null,status_cred_15 = null,status_cred_16 = null,status_cred_17 = null,status_cred_18 = null,
									 status_cred_19 = null,status_cred_20 = null,status_cred_21 = null,status_cred_22 = null,status_cred_23 = null,status_cred_24 = null,
									 status_cred_25 = null,status_cred_26 = null,status_cred_27 = null,status_cred_28 = null,status_cred_29 = null,status_cred_30 = null,status_cred_31 = null,
									 atr1 = iAtr,atr2 = null,atr3 = null,atr4 = null,atr5 = null,atr6 = null,
									 atr7 = null,atr8 = null,atr9 = null,atr10 = null,atr11 = null,atr12 = null,
									 atr13 = null,atr14 = null,atr15 = null,atr16 = null,atr17 = null,atr18 = null,
									 atr19 = null,atr20 = null,atr21 = null,atr22 = null,atr23 = null,atr24 = null,
									 atr25 = null,atr26 = null,atr27 = null,atr28 = null,atr29 = null,atr30 = null,atr31 = null
             WHERE fecha=vFecha_mesant
               AND num_credito = eNumCredito;
    END IF;

	--KSOV RQI 25 265 SE COMENTAN ASIGNACIONES DE VARIABLES Y SE MUEVEN AL INICIO
	/*
    LET vFecha_primes=MDY(MONTH(eFecha),'01',YEAR(eFecha));
    let eDia=day(eFecha);
	*/
    --KSOV     
        
IF  exists (Select num_credito from sd_sdodiariocrd where fecha=vFecha_primes and num_credito = eNumCredito) 
    OR exists (Select num_credito from sd_sdodiariocrd where fecha=vFecha_primes and num_credito = eNumCredito)  And MONTH(eFecha) = 1  --KSOV RQI 25 265 SE AGREGA VALIDACION
			THEN
             UPDATE sd_sdodiariocrd SET capvig1     =  DECODE(eDia,1,eSdoCapital,capvig1),
                                     captrans1      =  DECODE(eDia,1,eMontoVencido,captrans1),
                                     capvencnoexig1 =  DECODE(eDia,1,eCapTrasNo,capvencnoexig1),
                                     capvenexig1    =  DECODE(eDia,1,eMtoVencTrasp,capvenexig1),
                                     intvig1        =  DECODE(eDia,1,eSdoIntereses,intvig1),
                                     intvenc1       =  DECODE(eDia,1,eSdoExigInt,intvenc1),
                                     ivaintvig1     =  DECODE(eDia,1,eIvaIntVig,ivaintvig1),
                                     ivaintvenc1    =  DECODE(eDia,1,eIvaIntVenc,ivaintvenc1),
                                     int_venc_bal1  =  DECODE(eDia,1,eIntVenBal,int_venc_bal1),
                                     ivaint_venc_bal1  =  DECODE(eDia,1,eIvaIntVenBal,ivaint_venc_bal1),
									 monto_financiado1  =  DECODE(eDia,1,eMontoFinanciado,monto_financiado1),

                                     capvig2        =  DECODE(eDia,2,eSdoCapital,capvig2),
                                     captrans2      =  DECODE(eDia,2,eMontoVencido,captrans2),
                                     capvencnoexig2 =  DECODE(eDia,2,eCapTrasNo,capvencnoexig2),
                                     capvenexig2    =  DECODE(eDia,2,eMtoVencTrasp,capvenexig2),
                                     intvig2        =  DECODE(eDia,2,eSdoIntereses,intvig2),
                                     intvenc2       =  DECODE(eDia,2,eSdoExigInt,intvenc2),
                                     ivaintvig2     =  DECODE(eDia,2,eIvaIntVig,ivaintvig2),
                                     ivaintvenc2    =  DECODE(eDia,2,eIvaIntVenc,ivaintvenc2), 
                                     int_venc_bal2  =  DECODE(eDia,2,eIntVenBal,int_venc_bal2),
                                     ivaint_venc_bal2  =  DECODE(eDia,2,eIvaIntVenBal,ivaint_venc_bal2),
									 monto_financiado2  =  DECODE(eDia,2,eMontoFinanciado,monto_financiado2),

                                     capvig3        =  DECODE(eDia,3,eSdoCapital,capvig3),
                                     captrans3      =  DECODE(eDia,3,eMontoVencido,captrans3),
                                     capvencnoexig3 =  DECODE(eDia,3,eCapTrasNo,capvencnoexig3),
                                     capvenexig3    =  DECODE(eDia,3,eMtoVencTrasp,capvenexig3),
                                     intvig3        =  DECODE(eDia,3,eSdoIntereses,intvig3),
                                     intvenc3       =  DECODE(eDia,3,eSdoExigInt,intvenc3),
                                     ivaintvig3     =  DECODE(eDia,3,eIvaIntVig,ivaintvig3),
                                     ivaintvenc3    =  DECODE(eDia,3,eIvaIntVenc,ivaintvenc3),
                                     int_venc_bal3  =  DECODE(eDia,3,eIntVenBal,int_venc_bal3),
                                     ivaint_venc_bal3  =  DECODE(eDia,3,eIvaIntVenBal,ivaint_venc_bal3),
									 monto_financiado3  =  DECODE(eDia,3,eMontoFinanciado,monto_financiado3),

                                     capvig4        =  DECODE(eDia,4,eSdoCapital,capvig4),
                                     captrans4      =  DECODE(eDia,4,eMontoVencido,captrans4),
                                     capvencnoexig4 =  DECODE(eDia,4,eCapTrasNo,capvencnoexig4),
                                     capvenexig4    =  DECODE(eDia,4,eMtoVencTrasp,capvenexig4),
                                     intvig4        =  DECODE(eDia,4,eSdoIntereses,intvig4),
                                     intvenc4       =  DECODE(eDia,4,eSdoExigInt,intvenc4),
                                     ivaintvig4     =  DECODE(eDia,4,eIvaIntVig,ivaintvig4),
                                     ivaintvenc4    =  DECODE(eDia,4,eIvaIntVenc,ivaintvenc4),
                                     int_venc_bal4  =  DECODE(eDia,4,eIntVenBal,int_venc_bal4),
                                     ivaint_venc_bal4  =  DECODE(eDia,4,eIvaIntVenBal,ivaint_venc_bal4),
									 monto_financiado4  =  DECODE(eDia,4,eMontoFinanciado,monto_financiado4),

                                     capvig5        =  DECODE(eDia,5,eSdoCapital,capvig5),
                                     captrans5      =  DECODE(eDia,5,eMontoVencido,captrans5),
                                     capvencnoexig5 =  DECODE(eDia,5,eCapTrasNo,capvencnoexig5),
                                     capvenexig5    =  DECODE(eDia,5,eMtoVencTrasp,capvenexig5),
                                     intvig5        =  DECODE(eDia,5,eSdoIntereses,intvig5),
                                     intvenc5       =  DECODE(eDia,5,eSdoExigInt,intvenc5),
                                     ivaintvig5     =  DECODE(eDia,5,eIvaIntVig,ivaintvig5),
                                     ivaintvenc5    =  DECODE(eDia,5,eIvaIntVenc,ivaintvenc5),
                                     int_venc_bal5  =  DECODE(eDia,5,eIntVenBal,int_venc_bal5),
                                     ivaint_venc_bal5  =  DECODE(eDia,5,eIvaIntVenBal,ivaint_venc_bal5),
									 monto_financiado5  =  DECODE(eDia,5,eMontoFinanciado,monto_financiado5),

                                     capvig6        =  DECODE(eDia,6,eSdoCapital,capvig6),
                                     captrans6      =  DECODE(eDia,6,eMontoVencido,captrans6),
                                     capvencnoexig6 =  DECODE(eDia,6,eCapTrasNo,capvencnoexig6),
                                     capvenexig6    =  DECODE(eDia,6,eMtoVencTrasp,capvenexig6),
                                     intvig6        =  DECODE(eDia,6,eSdoIntereses,intvig6),
                                     intvenc6       =  DECODE(eDia,6,eSdoExigInt,intvenc6),
                                     ivaintvig6     =  DECODE(eDia,6,eIvaIntVig,ivaintvig6),
                                     ivaintvenc6    =  DECODE(eDia,6,eIvaIntVenc,ivaintvenc6),
                                     int_venc_bal6  =  DECODE(eDia,6,eIntVenBal,int_venc_bal6),
                                     ivaint_venc_bal6  =  DECODE(eDia,6,eIvaIntVenBal,ivaint_venc_bal6),
									 monto_financiado6  =  DECODE(eDia,6,eMontoFinanciado,monto_financiado6),

                                     capvig7        =  DECODE(eDia,7,eSdoCapital,capvig7),
                                     captrans7      =  DECODE(eDia,7,eMontoVencido,captrans7),
                                     capvencnoexig7 =  DECODE(eDia,7,eCapTrasNo,capvencnoexig7),
                                     capvenexig7    =  DECODE(eDia,7,eMtoVencTrasp,capvenexig7),
                                     intvig7        =  DECODE(eDia,7,eSdoIntereses,intvig7),
                                     intvenc7       =  DECODE(eDia,7,eSdoExigInt,intvenc7),
                                     ivaintvig7     =  DECODE(eDia,7,eIvaIntVig,ivaintvig7),
                                     ivaintvenc7    =  DECODE(eDia,7,eIvaIntVenc,ivaintvenc7),
                                     int_venc_bal7  =  DECODE(eDia,7,eIntVenBal,int_venc_bal7),
                                     ivaint_venc_bal7  =  DECODE(eDia,7,eIvaIntVenBal,ivaint_venc_bal7),
									 monto_financiado7  =  DECODE(eDia,7,eMontoFinanciado,monto_financiado7),

                                     capvig8        =  DECODE(eDia,8,eSdoCapital,capvig8),
                                     captrans8      =  DECODE(eDia,8,eMontoVencido,captrans8),
                                     capvencnoexig8 =  DECODE(eDia,8,eCapTrasNo,capvencnoexig8),
                                     capvenexig8    =  DECODE(eDia,8,eMtoVencTrasp,capvenexig8),
                                     intvig8        =  DECODE(eDia,8,eSdoIntereses,intvig8),
                                     intvenc8       =  DECODE(eDia,8,eSdoExigInt,intvenc8),
                                     ivaintvig8     =  DECODE(eDia,8,eIvaIntVig,ivaintvig8),
                                     ivaintvenc8    =  DECODE(eDia,8,eIvaIntVenc,ivaintvenc8),
                                     int_venc_bal8  =  DECODE(eDia,8,eIntVenBal,int_venc_bal8),
                                     ivaint_venc_bal8  =  DECODE(eDia,8,eIvaIntVenBal,ivaint_venc_bal8),
									 monto_financiado8  =  DECODE(eDia,8,eMontoFinanciado,monto_financiado8),

                                     capvig9        =  DECODE(eDia,9,eSdoCapital,capvig9),
                                     captrans9      =  DECODE(eDia,9,eMontoVencido,captrans9),
                                     capvencnoexig9 =  DECODE(eDia,9,eCapTrasNo,capvencnoexig9),
                                     capvenexig9    =  DECODE(eDia,9,eMtoVencTrasp,capvenexig9),
                                     intvig9        =  DECODE(eDia,9,eSdoIntereses,intvig9),
                                     intvenc9       =  DECODE(eDia,9,eSdoExigInt,intvenc9),
                                     ivaintvig9     =  DECODE(eDia,9,eIvaIntVig,ivaintvig9),
                                     ivaintvenc9    =  DECODE(eDia,9,eIvaIntVenc,ivaintvenc9),
                                     int_venc_bal9  =  DECODE(eDia,9,eIntVenBal,int_venc_bal9),
                                     ivaint_venc_bal9  =  DECODE(eDia,9,eIvaIntVenBal,ivaint_venc_bal9),
									 monto_financiado9  =  DECODE(eDia,9,eMontoFinanciado,monto_financiado9),

                                     capvig10       =  DECODE(eDia,10,eSdoCapital,capvig10),
                                     captrans10     =  DECODE(eDia,10,eMontoVencido,captrans10),
                                     capvencnoexig10=  DECODE(eDia,10,eCapTrasNo,capvencnoexig10),
                                     capvenexig10   =  DECODE(eDia,10,eMtoVencTrasp,capvenexig10),
                                     intvig10       =  DECODE(eDia,10,eSdoIntereses,intvig10),
                                     intvenc10      =  DECODE(eDia,10,eSdoExigInt,intvenc10),
                                     ivaintvig10    =  DECODE(eDia,10,eIvaIntVig,ivaintvig10),
                                     ivaintvenc10   =  DECODE(eDia,10,eIvaIntVenc,ivaintvenc10),
                                     int_venc_bal10 =  DECODE(eDia,10,eIntVenBal,int_venc_bal10),
                                     ivaint_venc_bal10 =  DECODE(eDia,10,eIvaIntVenBal,ivaint_venc_bal10),
									 monto_financiado10  =  DECODE(eDia,10,eMontoFinanciado,monto_financiado10),

                                     capvig11       =  DECODE(eDia,11,eSdoCapital,capvig11),
                                     captrans11     =  DECODE(eDia,11,eMontoVencido,captrans11),
                                     capvencnoexig11=  DECODE(eDia,11,eCapTrasNo,capvencnoexig11),
                                     capvenexig11   =  DECODE(eDia,11,eMtoVencTrasp,capvenexig11),
                                     intvig11       =  DECODE(eDia,11,eSdoIntereses,intvig11),
                                     intvenc11      =  DECODE(eDia,11,eSdoExigInt,intvenc11),
                                     ivaintvig11    =  DECODE(eDia,11,eIvaIntVig,ivaintvig11),
                                     ivaintvenc11   =  DECODE(eDia,11,eIvaIntVenc,ivaintvenc11),
                                     int_venc_bal11 =  DECODE(eDia,11,eIntVenBal,int_venc_bal11),
                                     ivaint_venc_bal11  =  DECODE(eDia,11,eIvaIntVenBal,ivaint_venc_bal11),
									 monto_financiado11  =  DECODE(eDia,11,eMontoFinanciado,monto_financiado11),

                                     capvig12       =  DECODE(eDia,12,eSdoCapital,capvig12),
                                     captrans12     =  DECODE(eDia,12,eMontoVencido,captrans12),
                                     capvencnoexig12=  DECODE(eDia,12,eCapTrasNo,capvencnoexig12),
                                     capvenexig12   =  DECODE(eDia,12,eMtoVencTrasp,capvenexig12),
                                     intvig12       =  DECODE(eDia,12,eSdoIntereses,intvig12),
                                     intvenc12      =  DECODE(eDia,12,eSdoExigInt,intvenc12),
                                     ivaintvig12    =  DECODE(eDia,12,eIvaIntVig,ivaintvig12),
                                     ivaintvenc12   =  DECODE(eDia,12,eIvaIntVenc,ivaintvenc12),
                                     int_venc_bal12 =  DECODE(eDia,12,eIntVenBal,int_venc_bal12),
                                     ivaint_venc_bal12  =  DECODE(eDia,12,eIvaIntVenBal,ivaint_venc_bal12),
									 monto_financiado12  =  DECODE(eDia,12,eMontoFinanciado,monto_financiado12),

                                     capvig13       =  DECODE(eDia,13,eSdoCapital,capvig13),
                                     captrans13     =  DECODE(eDia,13,eMontoVencido,captrans13),
                                     capvencnoexig13=  DECODE(eDia,13,eCapTrasNo,capvencnoexig13),
                                     capvenexig13   =  DECODE(eDia,13,eMtoVencTrasp,capvenexig13),
                                     intvig13       =  DECODE(eDia,13,eSdoIntereses,intvig13),
                                     intvenc13      =  DECODE(eDia,13,eSdoExigInt,intvenc13),
                                     ivaintvig13    =  DECODE(eDia,13,eIvaIntVig,ivaintvig13),
                                     ivaintvenc13   =  DECODE(eDia,13,eIvaIntVenc,ivaintvenc13),
                                     int_venc_bal13 =  DECODE(eDia,13,eIntVenBal,int_venc_bal13),
                                     ivaint_venc_bal13  =  DECODE(eDia,13,eIvaIntVenBal,ivaint_venc_bal13),
									 monto_financiado13  =  DECODE(eDia,13,eMontoFinanciado,monto_financiado13),

                                     capvig14       =  DECODE(eDia,14,eSdoCapital,capvig14),
                                     captrans14     =  DECODE(eDia,14,eMontoVencido,captrans14),
                                     capvencnoexig14=  DECODE(eDia,14,eCapTrasNo,capvencnoexig14),
                                     capvenexig14   =  DECODE(eDia,14,eMtoVencTrasp,capvenexig14),
                                     intvig14       =  DECODE(eDia,14,eSdoIntereses,intvig14),
                                     intvenc14      =  DECODE(eDia,14,eSdoExigInt,intvenc14),
                                     ivaintvig14    =  DECODE(eDia,14,eIvaIntVig,ivaintvig14),
                                     ivaintvenc14   =  DECODE(eDia,14,eIvaIntVenc,ivaintvenc14),
                                     int_venc_bal14 =  DECODE(eDia,14,eIntVenBal,int_venc_bal14),
                                     ivaint_venc_bal14  =  DECODE(eDia,14,eIvaIntVenBal,ivaint_venc_bal14),
									 monto_financiado14  =  DECODE(eDia,14,eMontoFinanciado,monto_financiado14),

                                     capvig15       =  DECODE(eDia,15,eSdoCapital,capvig15),
                                     captrans15     =  DECODE(eDia,15,eMontoVencido,captrans15),
                                     capvencnoexig15=  DECODE(eDia,15,eCapTrasNo,capvencnoexig15),
                                     capvenexig15   =  DECODE(eDia,15,eMtoVencTrasp,capvenexig15),
                                     intvig15       =  DECODE(eDia,15,eSdoIntereses,intvig15),
                                     intvenc15      =  DECODE(eDia,15,eSdoExigInt,intvenc15),
                                     ivaintvig15    =  DECODE(eDia,15,eIvaIntVig,ivaintvig15),
                                     ivaintvenc15   =  DECODE(eDia,15,eIvaIntVenc,ivaintvenc15),
                                     int_venc_bal15 =  DECODE(eDia,15,eIntVenBal,int_venc_bal15),
                                     ivaint_venc_bal15  =  DECODE(eDia,15,eIvaIntVenBal,ivaint_venc_bal15),
									 monto_financiado15  =  DECODE(eDia,15,eMontoFinanciado,monto_financiado15),

                                     capvig16       =  DECODE(eDia,16,eSdoCapital,capvig16),
                                     captrans16     =  DECODE(eDia,16,eMontoVencido,captrans16),
                                     capvencnoexig16=  DECODE(eDia,16,eCapTrasNo,capvencnoexig16),
                                     capvenexig16   =  DECODE(eDia,16,eMtoVencTrasp,capvenexig16),
                                     intvig16       =  DECODE(eDia,16,eSdoIntereses,intvig16),
                                     intvenc16      =  DECODE(eDia,16,eSdoExigInt,intvenc16),
                                     ivaintvig16    =  DECODE(eDia,16,eIvaIntVig,ivaintvig16),
                                     ivaintvenc16   =  DECODE(eDia,16,eIvaIntVenc,ivaintvenc16),
                                     int_venc_bal16 =  DECODE(eDia,16,eIntVenBal,int_venc_bal16),
                                     ivaint_venc_bal16  =  DECODE(eDia,16,eIvaIntVenBal,ivaint_venc_bal16),
									 monto_financiado16  =  DECODE(eDia,16,eMontoFinanciado,monto_financiado16),

                                     capvig17       =  DECODE(eDia,17,eSdoCapital,capvig17),
                                     captrans17     =  DECODE(eDia,17,eMontoVencido,captrans17),
                                     capvencnoexig17=  DECODE(eDia,17,eCapTrasNo,capvencnoexig17),
                                     capvenexig17   =  DECODE(eDia,17,eMtoVencTrasp,capvenexig17),
                                     intvig17       =  DECODE(eDia,17,eSdoIntereses,intvig17),
                                     intvenc17      =  DECODE(eDia,17,eSdoExigInt,intvenc17),
                                     ivaintvig17    =  DECODE(eDia,17,eIvaIntVig,ivaintvig17),
                                     ivaintvenc17   =  DECODE(eDia,17,eIvaIntVenc,ivaintvenc17),
                                     int_venc_bal17 =  DECODE(eDia,17,eIntVenBal,int_venc_bal17),
                                     ivaint_venc_bal17  =  DECODE(eDia,17,eIvaIntVenBal,ivaint_venc_bal17),
									 monto_financiado17  =  DECODE(eDia,17,eMontoFinanciado,monto_financiado17),

                                     capvig18       =  DECODE(eDia,18,eSdoCapital,capvig18),
                                     captrans18     =  DECODE(eDia,18,eMontoVencido,captrans18),
                                     capvencnoexig18=  DECODE(eDia,18,eCapTrasNo,capvencnoexig18),
                                     capvenexig18   =  DECODE(eDia,18,eMtoVencTrasp,capvenexig18),
                                     intvig18       =  DECODE(eDia,18,eSdoIntereses,intvig18),
                                     intvenc18      =  DECODE(eDia,18,eSdoExigInt,intvenc18),
                                     ivaintvig18    =  DECODE(eDia,18,eIvaIntVig,ivaintvig18),
                                     ivaintvenc18   =  DECODE(eDia,18,eIvaIntVenc,ivaintvenc18),
                                     int_venc_bal18 =  DECODE(eDia,18,eIntVenBal,int_venc_bal18),
                                     ivaint_venc_bal18  =  DECODE(eDia,18,eIvaIntVenBal,ivaint_venc_bal18),
									 monto_financiado18  =  DECODE(eDia,18,eMontoFinanciado,monto_financiado18),

                                     capvig19       =  DECODE(eDia,19,eSdoCapital,capvig19),
                                     captrans19     =  DECODE(eDia,19,eMontoVencido,captrans19),
                                     capvencnoexig19=  DECODE(eDia,19,eCapTrasNo,capvencnoexig19),
                                     capvenexig19   =  DECODE(eDia,19,eMtoVencTrasp,capvenexig19),
                                     intvig19       =  DECODE(eDia,19,eSdoIntereses,intvig19),
                                     intvenc19      =  DECODE(eDia,19,eSdoExigInt,intvenc19),
                                     ivaintvig19    =  DECODE(eDia,19,eIvaIntVig,ivaintvig19),
                                     ivaintvenc19   =  DECODE(eDia,19,eIvaIntVenc,ivaintvenc19),
                                     int_venc_bal19 =  DECODE(eDia,19,eIntVenBal,int_venc_bal19),
                                     ivaint_venc_bal19  =  DECODE(eDia,19,eIvaIntVenBal,ivaint_venc_bal19),
									 monto_financiado19  =  DECODE(eDia,19,eMontoFinanciado,monto_financiado19),
									
                                     capvig20       =  DECODE(eDia,20,eSdoCapital,capvig20),
                                     captrans20     =  DECODE(eDia,20,eMontoVencido,captrans20),
                                     capvencnoexig20=  DECODE(eDia,20,eCapTrasNo,capvencnoexig20),
                                     capvenexig20   =  DECODE(eDia,20,eMtoVencTrasp,capvenexig20),
                                     intvig20       =  DECODE(eDia,20,eSdoIntereses,intvig20),
                                     intvenc20      =  DECODE(eDia,20,eSdoExigInt,intvenc20),
                                     ivaintvig20    =  DECODE(eDia,20,eIvaIntVig,ivaintvig20),
                                     ivaintvenc20   =  DECODE(eDia,20,eIvaIntVenc,ivaintvenc20),
                                     int_venc_bal20 =  DECODE(eDia,20,eIntVenBal,int_venc_bal20),
                                     ivaint_venc_bal20  =  DECODE(eDia,20,eIvaIntVenBal,ivaint_venc_bal20),
									 monto_financiado20  =  DECODE(eDia,20,eMontoFinanciado,monto_financiado20),

                                     capvig21       =  DECODE(eDia,21,eSdoCapital,capvig21),
                                     captrans21     =  DECODE(eDia,21,eMontoVencido,captrans21),
                                     capvencnoexig21=  DECODE(eDia,21,eCapTrasNo,capvencnoexig21),
                                     capvenexig21   =  DECODE(eDia,21,eMtoVencTrasp,capvenexig21),
                                     intvig21       =  DECODE(eDia,21,eSdoIntereses,intvig21),
                                     intvenc21      =  DECODE(eDia,21,eSdoExigInt,intvenc21),
                                     ivaintvig21    =  DECODE(eDia,21,eIvaIntVig,ivaintvig21),
                                     ivaintvenc21   =  DECODE(eDia,21,eIvaIntVenc,ivaintvenc21),
                                     int_venc_bal21 =  DECODE(eDia,21,eIntVenBal,int_venc_bal21),
                                     ivaint_venc_bal21  =  DECODE(eDia,21,eIvaIntVenBal,ivaint_venc_bal21),
									 monto_financiado21  =  DECODE(eDia,21,eMontoFinanciado,monto_financiado21),

                                     capvig22       =  DECODE(eDia,22,eSdoCapital,capvig22),
                                     captrans22     =  DECODE(eDia,22,eMontoVencido,captrans22),
                                     capvencnoexig22=  DECODE(eDia,22,eCapTrasNo,capvencnoexig22),
                                     capvenexig22   =  DECODE(eDia,22,eMtoVencTrasp,capvenexig22),
                                     intvig22       =  DECODE(eDia,22,eSdoIntereses,intvig22),
                                     intvenc22      =  DECODE(eDia,22,eSdoExigInt,intvenc22),
                                     ivaintvig22    =  DECODE(eDia,22,eIvaIntVig,ivaintvig22),
                                     ivaintvenc22   =  DECODE(eDia,22,eIvaIntVenc,ivaintvenc22),
                                     int_venc_bal22 =  DECODE(eDia,22,eIntVenBal,int_venc_bal22),
                                     ivaint_venc_bal22  =  DECODE(eDia,22,eIvaIntVenBal,ivaint_venc_bal22),
									 monto_financiado22  =  DECODE(eDia,22,eMontoFinanciado,monto_financiado22),

                                     capvig23       =  DECODE(eDia,23,eSdoCapital,capvig23),
                                     captrans23     =  DECODE(eDia,23,eMontoVencido,captrans23),
                                     capvencnoexig23=  DECODE(eDia,23,eCapTrasNo,capvencnoexig23),
                                     capvenexig23   =  DECODE(eDia,23,eMtoVencTrasp,capvenexig23),
                                     intvig23       =  DECODE(eDia,23,eSdoIntereses,intvig23),
                                     intvenc23      =  DECODE(eDia,23,eSdoExigInt,intvenc23),
                                     ivaintvig23    =  DECODE(eDia,23,eIvaIntVig,ivaintvig23),
                                     ivaintvenc23   =  DECODE(eDia,23,eIvaIntVenc,ivaintvenc23),
                                     int_venc_bal23 =  DECODE(eDia,23,eIntVenBal,int_venc_bal23),
                                     ivaint_venc_bal23  =  DECODE(eDia,23,eIvaIntVenBal,ivaint_venc_bal23),
									 monto_financiado23  =  DECODE(eDia,23,eMontoFinanciado,monto_financiado23),

                                     capvig24       =  DECODE(eDia,24,eSdoCapital,capvig24),
                                     captrans24     =  DECODE(eDia,24,eMontoVencido,captrans24),
                                     capvencnoexig24=  DECODE(eDia,24,eCapTrasNo,capvencnoexig24),
                                     capvenexig24   =  DECODE(eDia,24,eMtoVencTrasp,capvenexig24),
                                     intvig24       =  DECODE(eDia,24,eSdoIntereses,intvig24),
                                     intvenc24      =  DECODE(eDia,24,eSdoExigInt,intvenc24),
                                     ivaintvig24    =  DECODE(eDia,24,eIvaIntVig,ivaintvig24),
                                     ivaintvenc24   =  DECODE(eDia,24,eIvaIntVenc,ivaintvenc24),
                                     int_venc_bal24 =  DECODE(eDia,24,eIntVenBal,int_venc_bal24),
                                     ivaint_venc_bal24  =  DECODE(eDia,24,eIvaIntVenBal,ivaint_venc_bal24),
									 monto_financiado24  =  DECODE(eDia,24,eMontoFinanciado,monto_financiado24),

                                     capvig25       =  DECODE(eDia,25,eSdoCapital,capvig25),
                                     captrans25     =  DECODE(eDia,25,eMontoVencido,captrans25),
                                     capvencnoexig25=  DECODE(eDia,25,eCapTrasNo,capvencnoexig25),
                                     capvenexig25   =  DECODE(eDia,25,eMtoVencTrasp,capvenexig25),
                                     intvig25       =  DECODE(eDia,25,eSdoIntereses,intvig25),
                                     intvenc25      =  DECODE(eDia,25,eSdoExigInt,intvenc25),
                                     ivaintvig25    =  DECODE(eDia,25,eIvaIntVig,ivaintvig25),
                                     ivaintvenc25   =  DECODE(eDia,25,eIvaIntVenc,ivaintvenc25),
                                     int_venc_bal25 =  DECODE(eDia,25,eIntVenBal,int_venc_bal25),
                                     ivaint_venc_bal25  =  DECODE(eDia,25,eIvaIntVenBal,ivaint_venc_bal25),
									 monto_financiado25  =  DECODE(eDia,25,eMontoFinanciado,monto_financiado25),

                                     capvig26       =  DECODE(eDia,26,eSdoCapital,capvig26),
                                     captrans26     =  DECODE(eDia,26,eMontoVencido,captrans26),
                                     capvencnoexig26=  DECODE(eDia,26,eCapTrasNo,capvencnoexig26),
                                     capvenexig26   =  DECODE(eDia,26,eMtoVencTrasp,capvenexig26),
                                     intvig26       =  DECODE(eDia,26,eSdoIntereses,intvig26),
                                     intvenc26      =  DECODE(eDia,26,eSdoExigInt,intvenc26),
                                     ivaintvig26    =  DECODE(eDia,26,eIvaIntVig,ivaintvig26),
                                     ivaintvenc26   =  DECODE(eDia,26,eIvaIntVenc,ivaintvenc26),
                                     int_venc_bal26 =  DECODE(eDia,26,eIntVenBal,int_venc_bal26),
                                     ivaint_venc_bal26  =  DECODE(eDia,26,eIvaIntVenBal,ivaint_venc_bal26),
									 monto_financiado26  =  DECODE(eDia,26,eMontoFinanciado,monto_financiado26),

                                     capvig27       =  DECODE(eDia,27,eSdoCapital,capvig27),
                                     captrans27     =  DECODE(eDia,27,eMontoVencido,captrans27),
                                     capvencnoexig27=  DECODE(eDia,27,eCapTrasNo,capvencnoexig27),
                                     capvenexig27   =  DECODE(eDia,27,eMtoVencTrasp,capvenexig27),
                                     intvig27       =  DECODE(eDia,27,eSdoIntereses,intvig27),
                                     intvenc27      =  DECODE(eDia,27,eSdoExigInt,intvenc27),
                                     ivaintvig27    =  DECODE(eDia,27,eIvaIntVig,ivaintvig27),
                                     ivaintvenc27   =  DECODE(eDia,27,eIvaIntVenc,ivaintvenc27),
                                     int_venc_bal27 =  DECODE(eDia,27,eIntVenBal,int_venc_bal27),
                                     ivaint_venc_bal27  =  DECODE(eDia,27,eIvaIntVenBal,ivaint_venc_bal27),
									 monto_financiado27  =  DECODE(eDia,27,eMontoFinanciado,monto_financiado27),

                                     capvig28       =  DECODE(eDia,28,eSdoCapital,capvig28),
                                     captrans28     =  DECODE(eDia,28,eMontoVencido,captrans28),
                                     capvencnoexig28=  DECODE(eDia,28,eCapTrasNo,capvencnoexig28),
                                     capvenexig28   =  DECODE(eDia,28,eMtoVencTrasp,capvenexig28),
                                     intvig28       =  DECODE(eDia,28,eSdoIntereses,intvig28),
                                     intvenc28      =  DECODE(eDia,28,eSdoExigInt,intvenc28),
                                     ivaintvig28    =  DECODE(eDia,28,eIvaIntVig,ivaintvig28),
                                     ivaintvenc28   =  DECODE(eDia,28,eIvaIntVenc,ivaintvenc28),
                                     int_venc_bal28 =  DECODE(eDia,28,eIntVenBal,int_venc_bal28),
                                     ivaint_venc_bal28  =  DECODE(eDia,28,eIvaIntVenBal,ivaint_venc_bal28),
									 monto_financiado28  =  DECODE(eDia,28,eMontoFinanciado,monto_financiado28),

                                     capvig29       =  DECODE(eDia,29,eSdoCapital,capvig29),
                                     captrans29     =  DECODE(eDia,29,eMontoVencido,captrans29),
                                     capvencnoexig29=  DECODE(eDia,29,eCapTrasNo,capvencnoexig29),
                                     capvenexig29   =  DECODE(eDia,29,eMtoVencTrasp,capvenexig29),
                                     intvig29       =  DECODE(eDia,29,eSdoIntereses,intvig29),
                                     intvenc29      =  DECODE(eDia,29,eSdoExigInt,intvenc29),
                                     ivaintvig29    =  DECODE(eDia,29,eIvaIntVig,ivaintvig29),
                                     ivaintvenc29   =  DECODE(eDia,29,eIvaIntVenc,ivaintvenc29),
                                     int_venc_bal29 =  DECODE(eDia,29,eIntVenBal,int_venc_bal29),
                                     ivaint_venc_bal29  =  DECODE(eDia,29,eIvaIntVenBal,ivaint_venc_bal29),
									 monto_financiado29  =  DECODE(eDia,29,eMontoFinanciado,monto_financiado29),	

                                     capvig30       =  DECODE(eDia,30,eSdoCapital,capvig30),
                                     captrans30     =  DECODE(eDia,30,eMontoVencido,captrans30),
                                     capvencnoexig30=  DECODE(eDia,30,eCapTrasNo,capvencnoexig30),
                                     capvenexig30   =  DECODE(eDia,30,eMtoVencTrasp,capvenexig30),
                                     intvig30       =  DECODE(eDia,30,eSdoIntereses,intvig30),
                                     intvenc30      =  DECODE(eDia,30,eSdoExigInt,intvenc30),
                                     ivaintvig30    =  DECODE(eDia,30,eIvaIntVig,ivaintvig30),
                                     ivaintvenc30   =  DECODE(eDia,30,eIvaIntVenc,ivaintvenc30),
                                     int_venc_bal30 =  DECODE(eDia,30,eIntVenBal,int_venc_bal30),
                                     ivaint_venc_bal30  =  DECODE(eDia,30,eIvaIntVenBal,ivaint_venc_bal30),
									 monto_financiado30  =  DECODE(eDia,30,eMontoFinanciado,monto_financiado30),

                                     capvig31       =  DECODE(eDia,31,eSdoCapital,capvig31),
                                     captrans31     =  DECODE(eDia,31,eMontoVencido,captrans31),
                                     capvencnoexig31=  DECODE(eDia,31,eCapTrasNo,capvencnoexig31),
                                     capvenexig31   =  DECODE(eDia,31,eMtoVencTrasp,capvenexig31),
                                     intvig31       =  DECODE(eDia,31,eSdoIntereses,intvig31),
                                     intvenc31      =  DECODE(eDia,31,eSdoExigInt,intvenc31),
                                     ivaintvig31    =  DECODE(eDia,31,eIvaIntVig,ivaintvig31),
                                     ivaintvenc31   =  DECODE(eDia,31,eIvaIntVenc,ivaintvenc31),
                                     int_venc_bal31 =  DECODE(eDia,31,eIntVenBal,int_venc_bal31),
                                     ivaint_venc_bal31  =  DECODE(eDia,31,eIvaIntVenBal,ivaint_venc_bal31),
									 monto_financiado31  =  DECODE(eDia,31,eMontoFinanciado,monto_financiado31),

                                     diacapvig      = diacapvig + vDiaCapital,
                                     acucapvig      = acucapvig + eSdoCapital,
                                     diacaptra      = diacaptra + vDiaVencido,
                                     acucaptra      = acucaptra + eMontoVencido,
                                     diacapvennoexig= diacapvennoexig + vDiaNoExig,
                                     acucapvennoexig= acucapvennoexig + eCapTrasNo,
                                     diacapvencexig = diacapvencexig + vDiaExig,
                                     acucapvencexig = acucapvencexig + eMtoVencTrasp

             WHERE fecha=vFecha_primes
               AND num_credito = eNumCredito;
			   
			   -- IFSR se agrega validaciÃÂ³n para actualizar la etapa dependiendo el dÃÂ­a
		if  (eDia = 1) then
			UPDATE sd_sdodiariocrd SET
				status_cred_1 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_1 = eFechaEtapa,
				atr1 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 2) then
			UPDATE sd_sdodiariocrd SET
				status_cred_2 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_2 = eFechaEtapa,
				atr2 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 3) then
			UPDATE sd_sdodiariocrd SET
				status_cred_3 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_3 = eFechaEtapa,
				atr3 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 4) then
			UPDATE sd_sdodiariocrd SET
				status_cred_4 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_4 = eFechaEtapa,
				atr4 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 5) then
			UPDATE sd_sdodiariocrd SET
				status_cred_5 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_5 = eFechaEtapa,
				atr5 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 6) then
			UPDATE sd_sdodiariocrd SET
				status_cred_6 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_6 = eFechaEtapa,
				atr6 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 7) then
			UPDATE sd_sdodiariocrd SET
				status_cred_7 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_7 = eFechaEtapa,
				atr7 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 8) then
			UPDATE sd_sdodiariocrd SET
				status_cred_8 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_8 = eFechaEtapa,
				atr8 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 9) then
			UPDATE sd_sdodiariocrd SET
				status_cred_9 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_9 = eFechaEtapa,
				atr9 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 10) then
			UPDATE sd_sdodiariocrd SET
				status_cred_10 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_10 = eFechaEtapa,
				atr10 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 11) then
			UPDATE sd_sdodiariocrd SET
				status_cred_11 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_11 = eFechaEtapa,
				atr11 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 12) then
			UPDATE sd_sdodiariocrd SET
				status_cred_12 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_12 = eFechaEtapa,
				atr12 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 13) then
			UPDATE sd_sdodiariocrd SET
				status_cred_13 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_13 = eFechaEtapa,
				atr13 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 14) then
			UPDATE sd_sdodiariocrd SET
				status_cred_14 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_14 = eFechaEtapa,
				atr14 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 15) then
			UPDATE sd_sdodiariocrd SET
				status_cred_15 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_15 = eFechaEtapa,
				atr15 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 16) then
			UPDATE sd_sdodiariocrd SET
				status_cred_16 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_16 = eFechaEtapa,
				atr16 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 17) then
			UPDATE sd_sdodiariocrd SET
				status_cred_17 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_17 = eFechaEtapa,
				atr17 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 18) then
			UPDATE sd_sdodiariocrd SET
				status_cred_18 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_18 = eFechaEtapa,
				atr18 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 19) then
			UPDATE sd_sdodiariocrd SET
				status_cred_19 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_19 = eFechaEtapa,
				atr19 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 20) then
			UPDATE sd_sdodiariocrd SET
				status_cred_20 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_20 = eFechaEtapa,
				atr20 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 21) then
			UPDATE sd_sdodiariocrd SET
				status_cred_21 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_21 = eFechaEtapa,
				atr21 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 22) then
			UPDATE sd_sdodiariocrd SET
				status_cred_22 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_22 = eFechaEtapa,
				atr22 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 23) then
			UPDATE sd_sdodiariocrd SET
				status_cred_23 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_23 = eFechaEtapa,
				atr23 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 24) then
			UPDATE sd_sdodiariocrd SET
				status_cred_24 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_24 = eFechaEtapa,
				atr24 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 25) then
			UPDATE sd_sdodiariocrd SET
				status_cred_25 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_25 = eFechaEtapa,
				atr25 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 26) then
			UPDATE sd_sdodiariocrd SET
				status_cred_26 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_26 = eFechaEtapa,
				atr26 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 27) then
			UPDATE sd_sdodiariocrd SET
				status_cred_27 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_27 = eFechaEtapa,
				atr27 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 28) then
			UPDATE sd_sdodiariocrd SET
				status_cred_28 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_28 = eFechaEtapa,
				atr28 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 29) then
			UPDATE sd_sdodiariocrd SET
				status_cred_29 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_29 = eFechaEtapa,
				atr29 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 30) then
			UPDATE sd_sdodiariocrd SET
				status_cred_30 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_30 = eFechaEtapa,
				atr30 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 31) then
			UPDATE sd_sdodiariocrd SET
				status_cred_31 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_31 = eFechaEtapa,
				atr31 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
		
		end if;
      ELSE
	  
	    
             INSERT INTO sd_sdodiariocrd
             VALUES(vFecha_primes,eNumCredito, eSucursal,
                                 DECODE(eDia,1,eSdoCapital,0),
                                 DECODE(eDia,1,eMontoVencido,0),
                                 DECODE(eDia,1,eCapTrasNo,0),
                                 DECODE(eDia,1,eMtoVencTrasp,0),
                                 DECODE(eDia,1,eSdoIntereses,0),
                                 DECODE(eDia,1,eSdoExigInt,0),
                                 DECODE(eDia,1,eIvaIntVig,0),
                                 DECODE(eDia,1,eIvaIntVenc,0),
                                

                                 DECODE(eDia,2,eSdoCapital,0),
                                 DECODE(eDia,2,eMontoVencido,0),
                                 DECODE(eDia,2,eCapTrasNo,0),
                                 DECODE(eDia,2,eMtoVencTrasp,0),
                                 DECODE(eDia,2,eSdoIntereses,0),
                                 DECODE(eDia,2,eSdoExigInt,0),
                                 DECODE(eDia,2,eIvaIntVig,0),
                                 DECODE(eDia,2,eIvaIntVenc,0),
								 

                                 DECODE(eDia,3,eSdoCapital,0),
                                 DECODE(eDia,3,eMontoVencido,0),
                                 DECODE(eDia,3,eCapTrasNo,0),
                                 DECODE(eDia,3,eMtoVencTrasp,0),
                                 DECODE(eDia,3,eSdoIntereses,0),
                                 DECODE(eDia,3,eSdoExigInt,0),
                                 DECODE(eDia,3,eIvaIntVig,0),
                                 DECODE(eDia,3,eIvaIntVenc,0),
								 

                                 DECODE(eDia,4,eSdoCapital,0),
                                 DECODE(eDia,4,eMontoVencido,0),
                                 DECODE(eDia,4,eCapTrasNo,0),
                                 DECODE(eDia,4,eMtoVencTrasp,0),
                                 DECODE(eDia,4,eSdoIntereses,0),
                                 DECODE(eDia,4,eSdoExigInt,0),
                                 DECODE(eDia,4,eIvaIntVig,0),
                                 DECODE(eDia,4,eIvaIntVenc,0),
								 

                                 DECODE(eDia,5,eSdoCapital,0),
                                 DECODE(eDia,5,eMontoVencido,0),
                                 DECODE(eDia,5,eCapTrasNo,0),
                                 DECODE(eDia,5,eMtoVencTrasp,0),
                                 DECODE(eDia,5,eSdoIntereses,0),
                                 DECODE(eDia,5,eSdoExigInt,0),
                                 DECODE(eDia,5,eIvaIntVig,0),
                                 DECODE(eDia,5,eIvaIntVenc,0),
								 

                                 DECODE(eDia,6,eSdoCapital,0),
                                 DECODE(eDia,6,eMontoVencido,0),
                                 DECODE(eDia,6,eCapTrasNo,0),
                                 DECODE(eDia,6,eMtoVencTrasp,0),
                                 DECODE(eDia,6,eSdoIntereses,0),
                                 DECODE(eDia,6,eSdoExigInt,0),
                                 DECODE(eDia,6,eIvaIntVig,0),
                                 DECODE(eDia,6,eIvaIntVenc,0),
								 

                                 DECODE(eDia,7,eSdoCapital,0),
                                 DECODE(eDia,7,eMontoVencido,0),
                                 DECODE(eDia,7,eCapTrasNo,0),
                                 DECODE(eDia,7,eMtoVencTrasp,0),
                                 DECODE(eDia,7,eSdoIntereses,0),
                                 DECODE(eDia,7,eSdoExigInt,0),
                                 DECODE(eDia,7,eIvaIntVig,0),
                                 DECODE(eDia,7,eIvaIntVenc,0),
								 

                                 DECODE(eDia,8,eSdoCapital,0),
                                 DECODE(eDia,8,eMontoVencido,0),
                                 DECODE(eDia,8,eCapTrasNo,0),
                                 DECODE(eDia,8,eMtoVencTrasp,0),
                                 DECODE(eDia,8,eSdoIntereses,0),
                                 DECODE(eDia,8,eSdoExigInt,0),
                                 DECODE(eDia,8,eIvaIntVig,0),
                                 DECODE(eDia,8,eIvaIntVenc,0),
								 

                                 DECODE(eDia,9,eSdoCapital,0),
                                 DECODE(eDia,9,eMontoVencido,0),
                                 DECODE(eDia,9,eCapTrasNo,0),
                                 DECODE(eDia,9,eMtoVencTrasp,0),
                                 DECODE(eDia,9,eSdoIntereses,0),
                                 DECODE(eDia,9,eSdoExigInt,0),
                                 DECODE(eDia,9,eIvaIntVig,0),
                                 DECODE(eDia,9,eIvaIntVenc,0),
								 

                                 DECODE(eDia,10,eSdoCapital,0),
                                 DECODE(eDia,10,eMontoVencido,0),
                                 DECODE(eDia,10,eCapTrasNo,0),
                                 DECODE(eDia,10,eMtoVencTrasp,0),
                                 DECODE(eDia,10,eSdoIntereses,0),
                                 DECODE(eDia,10,eSdoExigInt,0),
                                 DECODE(eDia,10,eIvaIntVig,0),
                                 DECODE(eDia,10,eIvaIntVenc,0),
								 
								 
                                 DECODE(eDia,11,eSdoCapital,0),
                                 DECODE(eDia,11,eMontoVencido,0),
                                 DECODE(eDia,11,eCapTrasNo,0),
                                 DECODE(eDia,11,eMtoVencTrasp,0),
                                 DECODE(eDia,11,eSdoIntereses,0),
                                 DECODE(eDia,11,eSdoExigInt,0),
                                 DECODE(eDia,11,eIvaIntVig,0),
                                 DECODE(eDia,11,eIvaIntVenc,0),
								 

                                 DECODE(eDia,12,eSdoCapital,0),
                                 DECODE(eDia,12,eMontoVencido,0),
                                 DECODE(eDia,12,eCapTrasNo,0),
                                 DECODE(eDia,12,eMtoVencTrasp,0),
                                 DECODE(eDia,12,eSdoIntereses,0),
                                 DECODE(eDia,12,eSdoExigInt,0),
                                 DECODE(eDia,12,eIvaIntVig,0),
                                 DECODE(eDia,12,eIvaIntVenc,0),
								 

                                 DECODE(eDia,13,eSdoCapital,0),
                                 DECODE(eDia,13,eMontoVencido,0),
                                 DECODE(eDia,13,eCapTrasNo,0),
                                 DECODE(eDia,13,eMtoVencTrasp,0),
                                 DECODE(eDia,13,eSdoIntereses,0),
                                 DECODE(eDia,13,eSdoExigInt,0),
                                 DECODE(eDia,13,eIvaIntVig,0),
                                 DECODE(eDia,13,eIvaIntVenc,0),
								 

                                 DECODE(eDia,14,eSdoCapital,0),
                                 DECODE(eDia,14,eMontoVencido,0),
                                 DECODE(eDia,14,eCapTrasNo,0),
                                 DECODE(eDia,14,eMtoVencTrasp,0),
                                 DECODE(eDia,14,eSdoIntereses,0),
                                 DECODE(eDia,14,eSdoExigInt,0),
                                 DECODE(eDia,14,eIvaIntVig,0),
                                 DECODE(eDia,14,eIvaIntVenc,0),
								 

                                 DECODE(eDia,15,eSdoCapital,0),
                                 DECODE(eDia,15,eMontoVencido,0),
                                 DECODE(eDia,15,eCapTrasNo,0),
                                 DECODE(eDia,15,eMtoVencTrasp,0),
                                 DECODE(eDia,15,eSdoIntereses,0),
                                 DECODE(eDia,15,eSdoExigInt,0),
                                 DECODE(eDia,15,eIvaIntVig,0),
                                 DECODE(eDia,15,eIvaIntVenc,0),
								 

                                 DECODE(eDia,16,eSdoCapital,0),
                                 DECODE(eDia,16,eMontoVencido,0),
                                 DECODE(eDia,16,eCapTrasNo,0),
                                 DECODE(eDia,16,eMtoVencTrasp,0),
                                 DECODE(eDia,16,eSdoIntereses,0),
                                 DECODE(eDia,16,eSdoExigInt,0),
                                 DECODE(eDia,16,eIvaIntVig,0),
                                 DECODE(eDia,16,eIvaIntVenc,0),
								

                                 DECODE(eDia,17,eSdoCapital,0),
                                 DECODE(eDia,17,eMontoVencido,0),
                                 DECODE(eDia,17,eCapTrasNo,0),
                                 DECODE(eDia,17,eMtoVencTrasp,0),
                                 DECODE(eDia,17,eSdoIntereses,0),
                                 DECODE(eDia,17,eSdoExigInt,0),
                                 DECODE(eDia,17,eIvaIntVig,0),
                                 DECODE(eDia,17,eIvaIntVenc,0),
								 

                                 DECODE(eDia,18,eSdoCapital,0),
                                 DECODE(eDia,18,eMontoVencido,0),
                                 DECODE(eDia,18,eCapTrasNo,0),
                                 DECODE(eDia,18,eMtoVencTrasp,0),
                                 DECODE(eDia,18,eSdoIntereses,0),
                                 DECODE(eDia,18,eSdoExigInt,0),
                                 DECODE(eDia,18,eIvaIntVig,0),
                                 DECODE(eDia,18,eIvaIntVenc,0),
								 

                                 DECODE(eDia,19,eSdoCapital,0),
                                 DECODE(eDia,19,eMontoVencido,0),
                                 DECODE(eDia,19,eCapTrasNo,0),
                                 DECODE(eDia,19,eMtoVencTrasp,0),
                                 DECODE(eDia,19,eSdoIntereses,0),
                                 DECODE(eDia,19,eSdoExigInt,0),
                                 DECODE(eDia,19,eIvaIntVig,0),
                                 DECODE(eDia,19,eIvaIntVenc,0),
								 

                                 DECODE(eDia,20,eSdoCapital,0),
                                 DECODE(eDia,20,eMontoVencido,0),
                                 DECODE(eDia,20,eCapTrasNo,0),
                                 DECODE(eDia,20,eMtoVencTrasp,0),
                                 DECODE(eDia,20,eSdoIntereses,0),
                                 DECODE(eDia,20,eSdoExigInt,0),
                                 DECODE(eDia,20,eIvaIntVig,0),
                                 DECODE(eDia,20,eIvaIntVenc,0),
								 

                                 DECODE(eDia,21,eSdoCapital,0),
                                 DECODE(eDia,21,eMontoVencido,0),
                                 DECODE(eDia,21,eCapTrasNo,0),
                                 DECODE(eDia,21,eMtoVencTrasp,0),
                                 DECODE(eDia,21,eSdoIntereses,0),
                                 DECODE(eDia,21,eSdoExigInt,0),
                                 DECODE(eDia,21,eIvaIntVig,0),
                                 DECODE(eDia,21,eIvaIntVenc,0),
								 

                                 DECODE(eDia,22,eSdoCapital,0),
                                 DECODE(eDia,22,eMontoVencido,0),
                                 DECODE(eDia,22,eCapTrasNo,0),
                                 DECODE(eDia,22,eMtoVencTrasp,0),
                                 DECODE(eDia,22,eSdoIntereses,0),
                                 DECODE(eDia,22,eSdoExigInt,0),
                                 DECODE(eDia,22,eIvaIntVig,0),
                                 DECODE(eDia,22,eIvaIntVenc,0),
								

                                 DECODE(eDia,23,eSdoCapital,0),
                                 DECODE(eDia,23,eMontoVencido,0),
                                 DECODE(eDia,23,eCapTrasNo,0),
                                 DECODE(eDia,23,eMtoVencTrasp,0),
                                 DECODE(eDia,23,eSdoIntereses,0),
                                 DECODE(eDia,23,eSdoExigInt,0),
                                 DECODE(eDia,23,eIvaIntVig,0),
                                 DECODE(eDia,23,eIvaIntVenc,0),
								 

                                 DECODE(eDia,24,eSdoCapital,0),
                                 DECODE(eDia,24,eMontoVencido,0),
                                 DECODE(eDia,24,eCapTrasNo,0),
                                 DECODE(eDia,24,eMtoVencTrasp,0),
                                 DECODE(eDia,24,eSdoIntereses,0),
                                 DECODE(eDia,24,eSdoExigInt,0),
                                 DECODE(eDia,24,eIvaIntVig,0),
                                 DECODE(eDia,24,eIvaIntVenc,0),
								 

                                 DECODE(eDia,25,eSdoCapital,0),
                                 DECODE(eDia,25,eMontoVencido,0),
                                 DECODE(eDia,25,eCapTrasNo,0),
                                 DECODE(eDia,25,eMtoVencTrasp,0),
                                 DECODE(eDia,25,eSdoIntereses,0),
                                 DECODE(eDia,25,eSdoExigInt,0),
                                 DECODE(eDia,25,eIvaIntVig,0),
                                 DECODE(eDia,25,eIvaIntVenc,0),
								

                                 DECODE(eDia,26,eSdoCapital,0),
                                 DECODE(eDia,26,eMontoVencido,0),
                                 DECODE(eDia,26,eCapTrasNo,0),
                                 DECODE(eDia,26,eMtoVencTrasp,0),
                                 DECODE(eDia,26,eSdoIntereses,0),
                                 DECODE(eDia,26,eSdoExigInt,0),
                                 DECODE(eDia,26,eIvaIntVig,0),
                                 DECODE(eDia,26,eIvaIntVenc,0),
								 

                                 DECODE(eDia,27,eSdoCapital,0),
                                 DECODE(eDia,27,eMontoVencido,0),
                                 DECODE(eDia,27,eCapTrasNo,0),
                                 DECODE(eDia,27,eMtoVencTrasp,0),
                                 DECODE(eDia,27,eSdoIntereses,0),
                                 DECODE(eDia,27,eSdoExigInt,0),
                                 DECODE(eDia,27,eIvaIntVig,0),
                                 DECODE(eDia,27,eIvaIntVenc,0),
								

                                 DECODE(eDia,28,eSdoCapital,0),
                                 DECODE(eDia,28,eMontoVencido,0),
                                 DECODE(eDia,28,eCapTrasNo,0),
                                 DECODE(eDia,28,eMtoVencTrasp,0),
                                 DECODE(eDia,28,eSdoIntereses,0),
                                 DECODE(eDia,28,eSdoExigInt,0),
                                 DECODE(eDia,28,eIvaIntVig,0),
                                 DECODE(eDia,28,eIvaIntVenc,0),
								 
                                 DECODE(eDia,29,eSdoCapital,0),
                                 DECODE(eDia,29,eMontoVencido,0),
                                 DECODE(eDia,29,eCapTrasNo,0),
                                 DECODE(eDia,29,eMtoVencTrasp,0),
                                 DECODE(eDia,29,eSdoIntereses,0),
                                 DECODE(eDia,29,eSdoExigInt,0),
                                 DECODE(eDia,29,eIvaIntVig,0),
                                 DECODE(eDia,29,eIvaIntVenc,0),

                                 DECODE(eDia,30,eSdoCapital,0),
                                 DECODE(eDia,30,eMontoVencido,0),
                                 DECODE(eDia,30,eCapTrasNo,0),
                                 DECODE(eDia,30,eMtoVencTrasp,0),
                                 DECODE(eDia,30,eSdoIntereses,0),
                                 DECODE(eDia,30,eSdoExigInt,0),
                                 DECODE(eDia,30,eIvaIntVig,0),
                                 DECODE(eDia,30,eIvaIntVenc,0),
								 

                                 DECODE(eDia,31,eSdoCapital,0),
                                 DECODE(eDia,31,eMontoVencido,0),
                                 DECODE(eDia,31,eCapTrasNo,0),
                                 DECODE(eDia,31,eMtoVencTrasp,0),
                                 DECODE(eDia,31,eSdoIntereses,0),
                                 DECODE(eDia,31,eSdoExigInt,0),
                                 DECODE(eDia,31,eIvaIntVig,0),
                                 DECODE(eDia,31,eIvaIntVenc,0),
								 
								 
                                 vDiaCapital,eSdoCapital,vDiaVencido,
                                 eMontoVencido,vDiaNoExig,eCapTrasNo,
                                 vDiaExig,eMtoVencTrasp,
                                 DECODE(eDia,1,eIntVenBal,0),
                                 DECODE(eDia,1,eIvaIntVenBal,0),  
                                 DECODE(eDia,2,eIntVenBal,0),
                                 DECODE(eDia,2,eIvaIntVenBal,0),  
                                 DECODE(eDia,3,eIntVenBal,0),
                                 DECODE(eDia,3,eIvaIntVenBal,0),  
                                 DECODE(eDia,4,eIntVenBal,0),
                                 DECODE(eDia,4,eIvaIntVenBal,0),  
                                 DECODE(eDia,5,eIntVenBal,0),
                                 DECODE(eDia,5,eIvaIntVenBal,0),  
                                 DECODE(eDia,6,eIntVenBal,0),
                                 DECODE(eDia,6,eIvaIntVenBal,0),  
                                 DECODE(eDia,7,eIntVenBal,0),
                                 DECODE(eDia,7,eIvaIntVenBal,0),  
                                 DECODE(eDia,8,eIntVenBal,0),
                                 DECODE(eDia,8,eIvaIntVenBal,0),  
                                 DECODE(eDia,9,eIntVenBal,0),
                                 DECODE(eDia,9,eIvaIntVenBal,0),  
                                 DECODE(eDia,10,eIntVenBal,0),
                                 DECODE(eDia,10,eIvaIntVenBal,0),  
                                 DECODE(eDia,11,eIntVenBal,0),
                                 DECODE(eDia,11,eIvaIntVenBal,0),  
                                 DECODE(eDia,12,eIntVenBal,0),
                                 DECODE(eDia,12,eIvaIntVenBal,0),  
                                 DECODE(eDia,13,eIntVenBal,0),
                                 DECODE(eDia,13,eIvaIntVenBal,0),  
                                 DECODE(eDia,14,eIntVenBal,0),
                                 DECODE(eDia,14,eIvaIntVenBal,0),  
                                 DECODE(eDia,15,eIntVenBal,0),
                                 DECODE(eDia,15,eIvaIntVenBal,0),  
                                 DECODE(eDia,16,eIntVenBal,0),
                                 DECODE(eDia,16,eIvaIntVenBal,0),  
                                 DECODE(eDia,17,eIntVenBal,0),
                                 DECODE(eDia,17,eIvaIntVenBal,0),  
                                 DECODE(eDia,18,eIntVenBal,0),
                                 DECODE(eDia,18,eIvaIntVenBal,0),  
                                 DECODE(eDia,19,eIntVenBal,0),
                                 DECODE(eDia,19,eIvaIntVenBal,0),  
                                 DECODE(eDia,20,eIntVenBal,0),
                                 DECODE(eDia,20,eIvaIntVenBal,0),  
                                 DECODE(eDia,21,eIntVenBal,0),
                                 DECODE(eDia,21,eIvaIntVenBal,0),  
                                 DECODE(eDia,22,eIntVenBal,0),
                                 DECODE(eDia,22,eIvaIntVenBal,0),  
                                 DECODE(eDia,23,eIntVenBal,0),
                                 DECODE(eDia,23,eIvaIntVenBal,0),  
                                 DECODE(eDia,24,eIntVenBal,0),
                                 DECODE(eDia,24,eIvaIntVenBal,0),  
                                 DECODE(eDia,25,eIntVenBal,0),
                                 DECODE(eDia,25,eIvaIntVenBal,0),  
                                 DECODE(eDia,26,eIntVenBal,0),
                                 DECODE(eDia,26,eIvaIntVenBal,0),  
                                 DECODE(eDia,27,eIntVenBal,0),
                                 DECODE(eDia,27,eIvaIntVenBal,0),  
                                 DECODE(eDia,28,eIntVenBal,0),
                                 DECODE(eDia,28,eIvaIntVenBal,0),  
                                 DECODE(eDia,29,eIntVenBal,0),
                                 DECODE(eDia,29,eIvaIntVenBal,0),  
                                 DECODE(eDia,30,eIntVenBal,0),
                                 DECODE(eDia,30,eIvaIntVenBal,0),  
                                 DECODE(eDia,31,eIntVenBal,0),
                                 DECODE(eDia,31,eIvaIntVenBal,0),
								 
								 								 
								 DECODE(eDia,1,eMontoFinanciado,0),
								 DECODE(eDia,2,eMontoFinanciado,0),
								 DECODE(eDia,3,eMontoFinanciado,0),
								 DECODE(eDia,4,eMontoFinanciado,0),
								 DECODE(eDia,5,eMontoFinanciado,0),
								 DECODE(eDia,6,eMontoFinanciado,0),
								 DECODE(eDia,7,eMontoFinanciado,0),
								 DECODE(eDia,8,eMontoFinanciado,0),
								 DECODE(eDia,9,eMontoFinanciado,0),
								 DECODE(eDia,10,eMontoFinanciado,0),
								 DECODE(eDia,11,eMontoFinanciado,0),
								 DECODE(eDia,12,eMontoFinanciado,0),
								 DECODE(eDia,13,eMontoFinanciado,0),
								 DECODE(eDia,14,eMontoFinanciado,0),
								 DECODE(eDia,15,eMontoFinanciado,0),
								 DECODE(eDia,16,eMontoFinanciado,0),
								 DECODE(eDia,17,eMontoFinanciado,0),
								 DECODE(eDia,18,eMontoFinanciado,0),
								 DECODE(eDia,19,eMontoFinanciado,0),
								 DECODE(eDia,20,eMontoFinanciado,0),
								 DECODE(eDia,21,eMontoFinanciado,0),
								 DECODE(eDia,22,eMontoFinanciado,0),
								 DECODE(eDia,23,eMontoFinanciado,0),
								 DECODE(eDia,24,eMontoFinanciado,0),
								 DECODE(eDia,25,eMontoFinanciado,0),
								 DECODE(eDia,26,eMontoFinanciado,0),
								 DECODE(eDia,27,eMontoFinanciado,0),
								 DECODE(eDia,28,eMontoFinanciado,0),
								 DECODE(eDia,29,eMontoFinanciado,0),
								 DECODE(eDia,30,eMontoFinanciado,0),
								 DECODE(eDia,31,eMontoFinanciado,0),
								 
								 DECODE(eDia,1,eEtapa,''),
								 DECODE(eDia,2,eEtapa,''),
								 DECODE(eDia,3,eEtapa,''),
								 DECODE(eDia,4,eEtapa,''),
								 DECODE(eDia,5,eEtapa,''),
								 DECODE(eDia,6,eEtapa,''),
								 DECODE(eDia,7,eEtapa,''),
								 DECODE(eDia,8,eEtapa,''),
								 DECODE(eDia,9,eEtapa,''),
								 DECODE(eDia,10,eEtapa,''),
								 DECODE(eDia,11,eEtapa,''),
								 DECODE(eDia,12,eEtapa,''),
								 DECODE(eDia,13,eEtapa,''),
								 DECODE(eDia,14,eEtapa,''),
								 DECODE(eDia,15,eEtapa,''),
								 DECODE(eDia,16,eEtapa,''),
								 DECODE(eDia,17,eEtapa,''),
								 DECODE(eDia,18,eEtapa,''),
								 DECODE(eDia,19,eEtapa,''),
								 DECODE(eDia,20,eEtapa,''),
								 DECODE(eDia,21,eEtapa,''),
								 DECODE(eDia,22,eEtapa,''),
								 DECODE(eDia,23,eEtapa,''),
								 DECODE(eDia,24,eEtapa,''),
								 DECODE(eDia,25,eEtapa,''),
								 DECODE(eDia,26,eEtapa,''),
								 DECODE(eDia,27,eEtapa,''),
								 DECODE(eDia,28,eEtapa,''),
								 DECODE(eDia,29,eEtapa,''),
								 DECODE(eDia,30,eEtapa,''),
								 DECODE(eDia,31,eEtapa,''),

								 DECODE(eDia,1,iAtr,0),
								 DECODE(eDia,2,iAtr,0),
								 DECODE(eDia,3,iAtr,0),
								 DECODE(eDia,4,iAtr,0),
								 DECODE(eDia,5,iAtr,0),
								 DECODE(eDia,6,iAtr,0),
								 DECODE(eDia,7,iAtr,0),
								 DECODE(eDia,8,iAtr,0),
								 DECODE(eDia,9,iAtr,0),
								 DECODE(eDia,10,iAtr,0),
								 DECODE(eDia,11,iAtr,0),
								 DECODE(eDia,12,iAtr,0),
								 DECODE(eDia,13,iAtr,0),
								 DECODE(eDia,14,iAtr,0),
								 DECODE(eDia,15,iAtr,0),
								 DECODE(eDia,16,iAtr,0),
								 DECODE(eDia,17,iAtr,0),
								 DECODE(eDia,18,iAtr,0),
								 DECODE(eDia,19,iAtr,0),
								 DECODE(eDia,20,iAtr,0),
								 DECODE(eDia,21,iAtr,0),
								 DECODE(eDia,22,iAtr,0),
								 DECODE(eDia,23,iAtr,0),
								 DECODE(eDia,24,iAtr,0),
								 DECODE(eDia,25,iAtr,0),
								 DECODE(eDia,26,iAtr,0),
								 DECODE(eDia,27,iAtr,0),
								 DECODE(eDia,28,iAtr,0),
								 DECODE(eDia,29,iAtr,0),
								 DECODE(eDia,30,iAtr,0),
								 DECODE(eDia,31,iAtr,0)
								 );
       END IF;
END
	RETURN vCodRet;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_reporte_oa()

RETURNING CHAR(5);       -- Codigo de Retorno

--*************************************************************************
--                         DEFINICION DE VARIABLES
--*************************************************************************
DEFINE scod_ret        CHAR(5);
DEFINE vsqlerr         INTEGER;
DEFINE s_numsol        CHAR(12);
DEFINE s_sucursal      CHAR(4);
DEFINE s_status        CHAR(2);
DEFINE s_nombrecte     CHAR(50);
DEFINE s_nombre1       CHAR(20);
DEFINE s_nombre2       CHAR(20);
DEFINE s_apell_paterno CHAR(20);
DEFINE s_apell_materno CHAR(20);
DEFINE s_fecha_sol     DATE;
DEFINE s_fecha_entrada DATE;
DEFINE pfechaini       DATE;
DEFINE pfechafin       DATE;
DEFINE s_numcte        CHAR(20);
DEFINE vfecha_hoy      DATE;
DEFINE s_consulta      SMALLINT;
DEFINE pempresa        CHAR(3);
DEFINE pstatus         CHAR(2);
DEFINE psucursal       CHAR(5);
DEFINE s_situacion     CHAR(2);
DEFINE s_causa         CHAR(2);
DEFINE s_num_producto  CHAR(4);

DEFINE s_prod          CHAR(10);
DEFINE s_prod2         CHAR(4);
DEFINE s_prod3         CHAR(4);
DEFINE cRuta           CHAR (50);
DEFINE cReporteOA      CHAR (50);
DEFINE cCadena         CHAR (500);
DEFINE cfec_arch       CHAR(8);
DEFINE s_cont_cte      INTEGER;
DEFINE num_prod1       CHAR(4);
DEFINE num_prod2       CHAR(4);
-- *************************************************************************
-- *                        ASIGNACION DE VARIABLES
-- **************************************************************************
LET scod_ret        = "000";
LET vsqlerr         = 0;
LET s_numcte        = "";
LET s_numsol        = "";
LET s_sucursal      = "";
LET s_status        = "";
LET s_nombrecte     = "";
LET s_nombre1       = "";
LET s_nombre2       = "";
LET s_apell_paterno = "";
LET s_apell_materno = "";
LET s_fecha_sol     = "";
LET s_fecha_entrada = "";
LET s_consulta      = 0;
LET pempresa	    = '001';
LET pstatus         = 'OA';
LET psucursal       = '';
LET s_consulta      = 0;
LET s_situacion     = '';
LET s_causa         = '';
LET s_num_producto  = '';
LET s_prod          = '';
LET s_prod2         = '';
LET s_prod3         = '';
LET cCadena         = '';
LET cReporteOA      = '';
LET cfec_arch       = '';
LET s_cont_cte      = 0;
LET num_prod1       = '';
LET num_prod2       = '';
LET pfechaini       = '';
LET pfechafin       = '';

-- **********************************************************************
-- *                        CONTROL DE ERRORES
-- ***********************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

		--SET DEBUG FILE TO "/informix/sp_reporte_OA.out";
		--TRACE ON;

-- **********************************************************************
-- *                        PROGRAMA PRINCIPAL
-- **********************************************************************
    SELECT year(fecha_hoy)||lpad(month(fecha_hoy),2,0)||lpad(day(fecha_hoy),2,0),today - 6 UNITS MONTH,today
    INTO cfec_arch,pfechaini,pfechafin
    FROM bdicred:sd_fechas WHERE empresa=pempresa;
    
	SELECT valor
	INTO cRuta
    FROM "informix".sd_param WHERE cod_param = '49' AND empresa = '001';

   LET cReporteOA = "ReporteOA_"||cfec_arch||'.txt';

   LET pempresa = pempresa;
   LET psucursal = psucursal;
   LET pfechaini  = pfechaini;
   LET pfechafin = pfechafin;
   LET pstatus = pstatus;

   -- Reporte para todas las sucursales
    If nvl(psucursal, '') = '' then
        Let psucursal = null;
    End if;
	
	--Se crea tabla temporal
	 DROP INDEX IF EXISTS 'informix'.inx1_sd_repOA_tmp;
	 DROP INDEX IF EXISTS 'informix'.inx2_sd_repOA_tmp;
	 DROP TABLE IF EXISTS 'informix'.sd_reporte_oa;
	 CREATE TABLE 'informix'.sd_reporte_oa (
	           num_solicitud varchar(12),
	           num_sucursal  varchar(10),
	           nom_cliente   varchar(80),
	           producto      varchar(20),
			   num_producto  varchar(10),
			   numcte        varchar(20),
	           f_ini_vig     date,
	           f_fin_vig     date,
	           situacion_esp varchar(2),
	           causa_sit     varchar(2));
			   
     CREATE INDEX 'informix'.inx1_sd_repOA_tmp on 'informix'.sd_reporte_oa(numcte,num_solicitud,num_producto);
	 CREATE INDEX 'informix'.inx2_sd_repOA_tmp on 'informix'.sd_reporte_oa(numcte);

     LET s_consulta = 1;

     IF s_consulta = 1 THEN
        FOREACH
        	--Se obtienen las solicitudes con estatus OA	
			 SELECT a.num_solicitud, a.sucursal, a.num_producto, a.numcte, NVL(a.fecha_insert,date(1))
               INTO
                 s_numsol,s_sucursal,s_num_producto,s_numcte,s_fecha_sol		
             FROM (bdisolic:ss_solicitudes a 
             INNER JOIN bdinteg:si_sucursales b ON a.sucursal = b.sucursal )
             WHERE a.status_solicitud = pstatus AND (a.fecha_insert >= pfechaini AND a.fecha_insert <= pfechafin)  
             AND a.empresa = pempresa
             ORDER BY a.numcte,a.num_solicitud,a.sucursal,a.num_producto ASC
			 
			 --Se obtiene la informaciÃ²n de cuando se guardo el estatus OA en la bitacora de estatus
			 SELECT NVL(d.fecha_entrada,date(1))
               INTO
                 s_fecha_entrada		
             FROM bdisolic:ss_autorizacion d WHERE d.num_solicitud = s_numsol AND d.empresa = pempresa AND status_solicitud = pstatus
             AND d.fecha_entrada = (SELECT NVL(MAX(fecha_entrada),today) FROM bdisolic:ss_autorizacion
             WHERE  num_solicitud = s_numsol AND status_solicitud = pstatus AND empresa = pempresa);
			 
			 --Se obtiene el nombre del cliente
			 SELECT g.nombre1, g.nombre2, g.apell_paterno, g.apell_materno
			   INTO s_nombre1,s_nombre2, s_apell_paterno, s_apell_materno
			 FROM bdinteg:si_cliente g WHERE g.numcte = s_numcte;		 
             
			 --Se obtiene la situacion y causa
			 SELECT FIRST 1 c.situacionespecial, c.causasituacionespecial
               INTO s_situacion,s_causa
             FROM bdisolic:"informix".ss_solicitud_os a
             LEFT JOIN bdisolic:"informix".ss_osclientesupervisar c ON (c.empresa=a.empresa AND c.num_solicitud =a.num_solicitud AND c.fechasolicitud=a.fecha_solicitud)
             WHERE a.num_solicitud = s_numsol
             AND a.fecha_solicitud =(
             SELECT MAX(fecha_solicitud)
             FROM bdisolic:"informix".ss_solicitud_os b
             WHERE b.num_solicitud = a.num_solicitud ) AND a.empresa = pempresa;
             
			   --Se valida el tipo de producto	 
               IF s_num_producto = '6001' THEN
                  LET  s_prod = '4.-TDC';
               ELIF s_num_producto = '6500' THEN
                  LET  s_prod = '2.-CP';
               ELIF s_num_producto = '6800' THEN
                  LET  s_prod = '3.-PD';
			   ELIF s_num_producto = '6300' THEN
			      LET  s_prod = '3.-PP12';
			   ELIF s_num_producto = '7600' THEN
			      LET  s_prod = '3.-PP18';
			   ELIF s_num_producto = '7700' THEN
			      LET  s_prod = '3.-PP24';
               END IF;

             --Se concatena el nombre del cliente
             LET s_nombrecte=trim(s_nombre1) || ' ' || trim(s_nombre2) || ' ' || trim(s_apell_paterno) || ' ' || trim(s_apell_materno);
			 
			 --Se inserta la informacion a la tabla temporal
             INSERT INTO sd_reporte_oa VALUES (s_numsol,s_sucursal,s_nombrecte,s_prod,s_num_producto,s_numcte,s_fecha_sol,s_fecha_entrada,s_situacion,s_causa);
             	
             --Solicitudes mixtas
			   SELECT count(numcte) INTO s_cont_cte FROM bdicred:sd_reporte_oa where numcte = s_numcte AND f_ini_vig = s_fecha_sol;
			 
			   IF s_cont_cte = 2 THEN
			   
				   SELECT num_producto INTO num_prod1 FROM bdicred:sd_reporte_oa where numcte = s_numcte 
				   AND num_producto = (SELECT MIN(num_producto) FROM bdicred:sd_reporte_oa where numcte = s_numcte ) AND f_ini_vig = s_fecha_sol;
				   
				   SELECT num_producto INTO num_prod2 FROM bdicred:sd_reporte_oa where numcte = s_numcte 
				   AND num_producto = (SELECT MAX(num_producto) FROM bdicred:sd_reporte_oa where numcte = s_numcte ) AND f_ini_vig = s_fecha_sol;
			       
                  IF num_prod1 = '6001' THEN
                     LET  s_prod2 = 'TDC';
                  ELIF num_prod1 = '6500' THEN
                     LET  s_prod2 = 'CP';
                  ELIF num_prod1 = '6800' THEN
                     LET  s_prod2 = 'PD';
                  ELIF num_prod1 = '6300' THEN
			         LET  s_prod2 = 'PP12';
                  ELIF num_prod1 = '7600' THEN
                     LET  s_prod2 = 'PP18';
                  ELIF num_prod1 = '7700' THEN
                     LET  s_prod2 = 'PP24';
                  END IF;
				  
				  IF num_prod2 = '6001' THEN
                     LET  s_prod3 = 'TDC';
                  ELIF num_prod2 = '6500' THEN
                     LET  s_prod3 = 'CP';
                  ELIF num_prod2 = '6800' THEN
                     LET  s_prod3 = 'PD';
                  ELIF num_prod2 = '6300' THEN
			         LET  s_prod3 = 'PP12';
                  ELIF num_prod2 = '7600' THEN
                     LET  s_prod3 = 'PP18';
                  ELIF num_prod2 = '7700' THEN
                     LET  s_prod3 = 'PP24';
                  END IF;
				  
				  UPDATE "informix".sd_reporte_oa SET producto = '1.-'||TRIM(s_prod2) || ' Y ' || TRIM(s_prod3) WHERE numcte = s_numcte;
			   END IF;				
			 
        END FOREACH;
				
    END IF;

        LET cCadena = '';
        LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO ' || TRIM(cRuta) || TRIM(cReporteOA) ||' delimiter ''|'' SELECT num_solicitud,num_sucursal,TRIM(numcte),nom_cliente,TRIM(producto),f_ini_vig,f_fin_vig,situacion_esp,causa_sit FROM bdicred:sd_reporte_oa ORDER BY producto,f_ini_vig,numcte,nom_cliente,num_solicitud;" >'||TRIM(cRuta)||'Reporte_OA.sql';
        SYSTEM cCadena;
        LET cCadena='chmod 777 '|| TRIM(cRuta)||'Reporte_OA.sql';
        SYSTEM cCadena;
        LET cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'Reporte_OA.sql';
        SYSTEM cCadena;
        LET cCadena = '' ;
        --LET cCadena = 'rm ' || TRIM(cRuta) || 'Reporte_OA.sql';
        SYSTEM cCadena;


    RETURN scod_ret;

END;

END PROCEDURE;