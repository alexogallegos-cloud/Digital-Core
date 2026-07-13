CREATE PROCEDURE "informix".alta_sol_tc_cjunk(	o_empresa                  CHAR(3),
                                        o_num_cliente              CHAR(20),
                                        o_producto                 CHAR(4),
                                        o_sucursal                 CHAR(4),
                                        o_ejecutivo                CHAR(8),
                                        o_referencia1              CHAR(20),
                                        o_referencia2              CHAR(20),
                                        o_porcentaje               DECIMAL(5,2),
                                        o_situacion                CHAR(1),
                                        o_meses                    SMALLINT,
                                        o_ingreso                  MONEY(14,2),
                                        o_linea                    MONEY(14,2),
                                        o_causa                    SMALLINT,
                                        o_puntualidad              CHAR(2),
                                        o_saldoropa                MONEY(14,2),
                                        o_saldomuebles             MONEY(14,2),
                                        o_saldoprestamos           MONEY(14,2),
                                        o_vencidoropa              MONEY(14,2),
                                        o_vencidomuebles           MONEY(14,2),
                                        o_vencidoprestamos         MONEY(14,2),
                                        o_abonomensualropa         MONEY(14,2),
                                        o_abonomensualmuebles      MONEY(14,2),
                                        o_abonomensualprestamos    MONEY(14,2),
                                        o_ultimacompra             DATE )
RETURNING CHAR(5) AS retorno, 
          CHAR(20) AS solicitud; 
------------------------------------------------------------------------------------
-- Modificado: Viridiana Osobampo
-- Fecha de modificacion: 07/01/2009
-- Descripcion: Se agrega parametro (o_ultimacompra) para usarlo como criterio de 
--              generación de os calle del cliente durante el proceso de solicitud de
--              credito Bancoppel. 
-- Proyecto: Caja Unica.
------------------------------------------------------------------------------------
--Modificó: Viridiana Osobampo
--Fecha de modificación: 09-09-2009
--Descripción: Se modifica para que se realice el alta de solicitud para un préstamo 
--             personal, y no permita realizar un solicitud a un cliente cuando tiene 
--             una en trámite de crédito Bancario (Tarjeta de Crédito o Préstamo Personal).
--Peticion: RQM 10 108 Préstamo Personal
------------------------------------------------------------------------------------
--Modificó: Viridiana Osobampo
--Fecha de modificación: 25-09-2009
--Descripción: Se para reemplazar los parámetros al obtener la edad minima y maxima 
--                   por el cambio a los asignados para el proyecto de caja unica.
--Peticion: RQM 10 108 Préstamo Personal
------------------------------------------------------------------------------------
--Modificó: Viridiana Osobampo
--Fecha de modificación: 03-11-2009
--Descripción: Se modifica para eliminar la obtención de datos por producto,
--             y en su lugar que sean por tipo de solicitud, de modo que esté
--              parametrizado para cualquier producto que tenga un tipo de solicitud
--              existente.
--Peticion: RQM 10 108 Préstamo Personal
------------------------------------------------------------------------------------
--Modificó: Viridiana Osobampo
--Fecha de modificación: 31-12-2009
--Descripción: Se modifica para que en el llamado del procedimiento que
--		genera el folio de solicitud se haga al asigna_numsol y no
--		al asigna_numsol_cjunk como anteriomente se realizaba.
--Peticion: RQM 10 108 Préstamo Personal
------------------------------------------------------------------------------------
--Modificó: Viridiana Osobampo
--Fecha de modificación: 13-04-2010
--Descripción: Se realiza modificación para enviar códigos de error distintos para 
--              cuando la edad del cliente es menor a la permitida y cuando es
--              mayor a ésta.
--Peticion: Alta Única, paso 4
------------------------------------------------------------------------------------
--Modificó: Viridiana Osobampo
--Fecha de modificación: 25-06-2010
--Descripción: Se comenta la validación del teléfono de casa del cliente.
--Peticion: Alta Única, paso 4
------------------------------------------------------------------------------------
--Modificó: Jesús Manuel Aguilar Heredia
--Fecha de modificación: 25-06-2010
--Descripción: se agrega consulta al sp consedadcte de la base de datos bdinteg, para obtener la edad del cliente.
--Peticion: Ajustse Alta Única, paso 4
------------------------------------------------------------------------------------
--Modificó: Carlos Aguirre Vega
--Fecha de modificación: 22-04-2013
--Descripción: Se agrega status EC - "Evaluacion Coppel" en la validacion de alta de solicitud
--Peticion: RQM 18 023 - EstatusSolicitudCoppelEC
-- *********************************************************************************
-- *                        DEFINICION DE VARIABLES                                *
-- *********************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE s_numsol     VARCHAR(20);
DEFINE v_tpsol      CHAR(1);
DEFINE v_tipper     CHAR(2);
DEFINE v_paso1      CHAR(20);
DEFINE v_paso2      CHAR(120);
DEFINE v_paso3      CHAR(20);
DEFINE v_paso4      CHAR(120);
DEFINE v_paso5      CHAR(1);
DEFINE v_paso6      SMALLINT;
DEFINE v_paso7      CHAR(1);
DEFINE v_paso8      CHAR(2);
DEFINE v_paso9      CHAR(3);
DEFINE v_paso10     CHAR(3);
DEFINE v_paso11     CHAR(3);
DEFINE v_paso12     CHAR(13);
DEFINE v_paso13     CHAR(13);
DEFINE v_paso14     CHAR(2);
DEFINE v_paso15     CHAR(2);
DEFINE v_paso16     CHAR(20);
DEFINE v_fuente     CHAR(1);
DEFINE sql_err      SMALLINT;
DEFINE isam_err     SMALLINT;
DEFINE error_info   CHAR(100);
DEFINE vEdadCte     SMALLINT;
DEFINE vEdadMin     SMALLINT;
DEFINE vEdadMax     SMALLINT;
DEFINE vMesesHis    SMALLINT;
DEFINE telefonocasa SMALLINT;
DEFINE v_producto   CHAR(20);
DEFINE v_status     CHAR(2);

DEFINE v_tp_solicitud   CHAR(1);
--  ini jom Parametro referencia coppel
define v_paso_cliente CHAR(20);
--  fin jom Parametro referencia coppel
DEFINE cnomcte          CHAR(104);
DEFINE cCodret          CHAR(3);
DEFINE v_num_solicitud  CHAR(20);
DEFINE v_status_credito char(2);

DEFINE n_clientes_ref   integer;

DEFINE cCRet 				CHAR(6); 
DEFINE ptipogrupo 			CHAR(2); 
DEFINE phit 				CHAR(6);
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET v_fuente     = ""; 
LET v_paso1      = "";
LET v_paso2      = "";
LET v_paso3      = "";
LET v_paso4      = "";
LET v_tpsol      = "";
LET s_numsol     = "??????";

LET telefonocasa = 0;
LET v_producto   = "";
LET v_status     = "";

LET v_tp_solicitud  = "";

--  ini jom Parametro referencia coppel
let v_paso_cliente = "";
--  fin jom Parametro referencia coppel
LET cnomcte        = "";
LET cCodret        = "";
LET v_num_solicitud = "";
LET v_status_credito = "";

LET n_clientes_ref = 0;

let cCRet 	=""; 
let ptipogrupo =""; 
let phit =""; 

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************


BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
   -- SET DEBUG FILE TO "/tmp/alta_sol_tc.err";
   --   TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET scod_ret = sql_err;
      RETURN scod_ret, s_numsol;
   END EXCEPTION;
-- Ini Caja Unica. Viridiana


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    --set debug file to '/pisa/leo/alta_sol_tc_prueba.out';
    --trace on;
--set debug file to '/informix/jesus/alta_sol_tc_prueba.out';
--trace on;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

--INI MOVIL
	SELECT limit 1 num_solicitud
	INTO s_numsol
	FROM bdisolic:"informix".ss_solicitudes_movil 
	WHERE empresa = o_empresa and numcte = o_num_cliente AND status <> '3' and producto =o_producto;

		IF NVL(s_numsol,'')  <> '' THEN 
			RETURN scod_ret, s_numsol;
		END IF;
--FIN MOVIL



-- VALIDA REFERENCIAS DUPLICADAS JOM 20/04/2014 INI

-- Ya existe el cliente con una referencia repetida
    SELECT COUNT(*) 
      INTO n_clientes_ref
      FROM bdinteg:"informix".si_cliente
     WHERE numcte_ref = 
     (SELECT DECODE(numcte_ref,'','NE',numcte_ref)
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = o_num_cliente);

-- No permitio un cliente con la misma referencia
    IF ( n_clientes_ref = 0 ) THEN
        SELECT case when COUNT(*) > 0 then 2 else 0 end
          INTO n_clientes_ref
          FROM bdinteg:"informix".si_bitacora_refcop
         WHERE numcte = o_num_cliente;
    END IF;

-- Limpia datos para tratar como cliente nuevo
    IF ( n_clientes_ref > 1 ) THEN
        LET o_porcentaje               = 0;
        LET o_situacion                = '0';
        LET o_meses                    = 0;
        LET o_ingreso                  = 0;
        LET o_linea                    = 0;
        LET o_causa                    = 0;
        LET o_puntualidad              = '';
        LET o_saldoropa                = 0;
        LET o_saldomuebles             = 0;
        LET o_saldoprestamos           = 0;
        LET o_vencidoropa              = 0;
        LET o_vencidomuebles           = 0;
        LET o_vencidoprestamos         = 0;
        LET o_abonomensualropa         = 0;
        LET o_abonomensualmuebles      = 0;
        LET o_abonomensualprestamos    = 0;
        LET o_ultimacompra             = DATE(1);
    END IF;

-- VALIDA REFERENCIAS DUPLICADAS JOM 20/04/2014 FIN


	-- *************************
	-- Extrae Tipo de Solicitud *
	-- *******************+******
       SELECT a.tp_solicitud 
         INTO v_tpsol
         FROM "informix".ss_tp_solicitud a, "informix".ss_solic_producto b
        WHERE b.empresa = o_empresa
          AND b.num_producto = o_producto
          AND a.tp_solicitud = b.tp_solicitud;

   IF v_tpsol IN('T','P') THEN
       SELECT edad_min, edad_max
         INTO vEdadMin,vEdadMax
         FROM bdicred:"informix".sd_definicion
        WHERE empresa = o_empresa
          AND num_producto = o_producto;

      /* SELECT COUNT(ind_cofeteltel1)
         INTO telefonocasa
         FROM bdinteg:si_direcciones
        WHERE numcte = o_num_cliente
          AND ind_cofeteltel1 = 'V';

        IF telefonocasa = 0 THEN
           LET scod_ret = "103";
           RETURN scod_ret, s_numsol;
        END IF    */
   ELIF v_tpsol = 'C' THEN
       SELECT valor 
         INTO vEdadMin
         FROM "informix".ss_param
        WHERE empresa = o_empresa
          AND secuencia = 342;

       SELECT valor 
         INTO vEdadMax
         FROM "informix".ss_param
        WHERE empresa = o_empresa
          AND secuencia = 345; 
   ELSE
       LET scod_ret= "709"; -- Tipo de solicitud no Valido
       RETURN scod_ret, s_numsol;
   END IF;
   
   	-- Valida Edad Permtida para Otorgamiento
       IF vEdadMin IS NULL OR vEdadMax IS NULL THEN
           LET scod_ret = "100";
           RETURN scod_ret, s_numsol;
       END IF
       
-- Fin Caja Unica. Viridiana
   SELECT valor 
     INTO vMesesHis
     FROM "informix".ss_param
    WHERE empresa = o_empresa
      AND secuencia = 327;

--  ini jom Parametro referencia coppel
   SELECT valor 
     INTO v_paso_cliente
     FROM "informix".ss_param
    WHERE empresa = o_empresa
      AND secuencia = 325;
--  fin jom Parametro referencia coppel

	-- ****************************************************
	--   VERIFICA ANTIGUEDAD EN CLIENTES COPPEL Y NUEVOS  *
	-- ****************************************************
   IF (TRIM(v_paso_cliente) <> TRIM(o_num_cliente)) THEN
       IF NVL(o_meses,0)<vMesesHis THEN
           LET scod_ret = "104";
           RETURN scod_ret, s_numsol;
       END IF
   END IF;

-- Valida que al recibir un porcentaje de eficiencia se trata de un cte con datos de tienda.
   IF o_porcentaje <> 0 THEN
       LET v_fuente = "T";
   END IF;
        -- ***************************************************
        -- Valicacion Generales para el alta de la solicitud *
        -- ***************************************************
	-- Valida Solicitudes en Proceso
       FOREACH

           SELECT num_producto, status_solicitud,tipo_solicitud,num_solicitud
             INTO v_producto, v_status, v_tp_solicitud, v_num_solicitud
             FROM "informix".ss_solicitudes
            WHERE empresa = o_empresa
              AND numcte = o_num_cliente
              AND status_solicitud IN ("EA","EE","AT","AP","CC","OA","OS","BC","ST","CE","MC","EC","PA") --JMAH RQM 09 279

          IF v_num_solicitud IS NOT NULL OR v_num_solicitud <> '' AND (v_tp_solicitud = 'A' OR v_tp_solicitud = 'T') THEN    
             IF v_tp_solicitud = 'T' THEN
                  SELECT status_cred 
                    INTO v_status_credito
                    FROM bdicred:"informix".sd_maecred 
                   WHERE empresa = o_empresa and num_credito =  v_num_solicitud;
             ELSE
                SELECT status_cred 
                  INTO v_status_credito
                  FROM bdicred:"informix".sd_maecredcrd 
                 WHERE empresa = o_empresa and num_credito =  v_num_solicitud; 
              END IF;    
           END IF;   


           IF v_status = "AP" THEN

               IF v_tpsol IN ('T','P') THEN
                   LET v_fuente = "B";
               END IF;
               IF (v_producto = o_producto) AND (v_tpsol = 'C' OR (v_tpsol = 'T' AND v_status_credito <> 'FC' AND v_status_credito <> 'FF')) THEN --Se agrega el status FF a la validación
               LET scod_ret = "710";
               RETURN scod_ret, s_numsol;
          END IF;
           
           ELSE

               IF (v_tp_solicitud IN ('T','P') AND (v_tpsol IN ('T','P'))) OR
                   (v_producto = o_producto) THEN
                   LET scod_ret = "710";
                   RETURN scod_ret, s_numsol;
               END IF;

           END IF;

       END FOREACH;




		--obtiene la edad del cliente
		EXECUTE PROCEDURE bdinteg:"informix".consedadcte(o_empresa, o_num_cliente)
		INTO cCodRet, cnomcte, vEdadCte;
		
		IF NVL(vEdadCte,"") = "" THEN
			LET scod_ret = cCodRet;
			 RETURN scod_ret, s_numsol;
		END IF;
		
       IF vEdadCte < vEdadMin THEN
           LET scod_ret = "711";
      	   RETURN scod_ret, s_numsol;
       END IF  

       IF vEdadCte > vEdadMax THEN
           LET scod_ret = "712";
           RETURN scod_ret, s_numsol;
       END IF;

        -- *****************************************
        -- Determina Numero de Solicitud a Asignar *
        -- *****************************************
       CALL asigna_numsol(o_empresa, o_producto)
       RETURNING scod_ret, s_numsol;
	   
       IF scod_ret <> "000" THEN
           RETURN scod_ret, s_numsol;
       END IF
        -- *************************************
        -- Graba Solicitud como Pre-Calificada *
        -- *************************************
    if length(s_numsol) = 12 and bdinteg:"informix".val_num(s_numsol) then  --- se valida que el número de solicitud sea de 12 y todos sean numericos.
         EXECUTE PROCEDURE graba_sol_precalificada
                         (o_empresa, s_numsol, o_num_cliente, o_sucursal,
                         v_tpsol,  o_producto, o_ejecutivo)
                    INTO scod_ret;
	

       IF scod_ret <> "000" THEN
           RETURN scod_ret, s_numsol;
		    END IF
	else   
	LET scod_ret = "242";	  	  
	RETURN scod_ret, s_numsol;
	END IF		
       INSERT INTO  "informix".ss_resum_scor_fin
                    (empresa, num_solicitud, situacion_pago, situacion_credito,
                    meses_historia, fuente, ingreso_mensual, linea_tienda, causa,
                    puntualidad, saldoropa, saldomuebles, saldoprestamos, vencidoropa,
                    vencidomuebles, vencidoprestamos, abonomensualropa, abonomensualmuebles,
                    abonomensualprestamos,fecha_ultima_compra,origen)
	VALUES
                    (o_empresa, s_numsol, o_porcentaje , o_situacion, o_meses,
                    v_fuente, o_ingreso, o_linea, o_causa, o_puntualidad, o_saldoropa,
                    o_saldomuebles, o_saldoprestamos, o_vencidoropa, o_vencidomuebles,
                    o_vencidoprestamos, o_abonomensualropa, o_abonomensualmuebles,
                    o_abonomensualprestamos,o_ultimacompra,'1');  -- El num. "1" en el campo origen indica que 
                                                                  -- la solicitud nació por caja única
	call bdisolic:"informix".sp_obtienegrupo(s_numsol) RETURNING cCRet,ptipogrupo,phit;	    
    UPDATE bdisolic:"informix".ss_resum_scor_fin
        SET grupo = ptipogrupo
    WHERE empresa = o_empresa AND num_solicitud = s_numsol;	
																  
END
       RETURN scod_ret, s_numsol;
END PROCEDURE document "Version 1.00.000";

CREATE PROCEDURE "informix".sp_obt_datoscte_bpi(pEmpresa char(3), pNumCte char(20), pTipoValidacion integer)
returning char(5),char(20), char(26),char(26),char(26),char(26), smallint, date;

    --------------------------------------------------------------------------------------------
    -- RealizÃ³: Mauricio LeÃ³n
    -- Actividad: Obtiene los datos del cliente
    -- SolicitÃ³: Mauricio LeÃ³n
    -- Fecha de Solicitud: 28/12/2008
    -- ModificÃ³: Javier CalderÃ³n
    -- Fecha de ModificaciÃ³n: 04/03/2009
    ---------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------
    --Modificacion: se modifico para omitir tablas temporales, ya hacer consulta directa., ademas se modifico el LEFT OUTER JOIN por RIGHT OUTER --JOIN
    --Modifico: Francisco Rodriguez Ibarra
    --Fecha:20-07-2010
	---------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------
	--Modificacion: se actualiza para que obtenga todas la cuentas de crÃ©dito del cliente.
    --Modifico: JosÃ© de JesÃºs Nevarez
    --Fecha:29-11-2017
    ---------------------------------------------------------------------------------------------
    -- ***************************************************************************
    -- Define variables
    -- ***************************************************************************
    DEFINE cod_ret char(5);
    DEFINE sql_err integer;
    DEFINE vNumTarjeta char(20);
    DEFINE vNombre1, vNombre2, vApellPaterno, vApellMaterno  char(26);
    DEFINE iCont, vIdStatus, vRegistros SMALLINT;
    DEFINE vCuenta char(11);
    DEFINE vFechaNac date;

    -- ***************************************************************************
    -- Inicializa variables
    -- ***************************************************************************
    LET cod_ret = '000';
    LET vNumTarjeta = ' ';
    LET vNombre1 = ' ';
    LET vNombre2 = ' ';
    LET vApellPaterno = ' ';
    LET vApellMaterno = ' ';
    LET vIdStatus = 0;
    LET vFechaNac = '01-01-1900';
    LET vRegistros = 0;
    LET iCont = 0;
    LET vCuenta = '';

    BEGIN
    
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, vNumTarjeta, vNombre1, vNombre2, vApellPaterno, vApellMaterno, vIdStatus, vFechaNac;
        END IF
    END EXCEPTION;
	
   --SET DEBUG FILE TO '/informix/JoseDeJesus/sp_obt_datoscte_bpi.out';
   --TRACE ON;

    SET ISOLATION DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_cliente WHERE numcte = pNumCte ) THEN
        SELECT a.nombre1, a.nombre2, a.apell_paterno, a.apell_materno, b.fecha_nac, c.id_status
          INTO vNombre1, vNombre2, vApellPaterno, vApellMaterno, vFechaNac, vIdStatus
          FROM bdinteg:"informix".si_cliente a,  bdinteg:"informix".si_ctepf b, bdinteg:"informix".si_bpiusuarios c
         WHERE a.numcte = pNumCte 
           AND a.empresa = pEmpresa
           AND a.numcte = b.numcte 
           AND a.numcte = c.numcte;
		
		
        IF vIdStatus <> 10 AND vIdStatus <> 95 AND vIdStatus <> 21 THEN
            LET cod_ret = '004'; --Estatus incorrecto
        END IF
		
		IF vIdStatus == 21 THEN
			UPDATE bdinteg:"informix".si_bpiusuarios  SET id_status=10 WHERE empresa = pEmpresa AND numcte = pNumCte;
			LET vIdStatus=10;
        END IF
		
    ELSE
        LET cod_ret = '001'; --Cliente no existe
    END IF
	
    IF cod_ret = '000' THEN

        IF pTipoValidacion = 1 THEN
			FOREACH
				SELECT tr.num_tarjeta, mc.num_credito
				INTO vNumTarjeta, vCuenta
				FROM bdicred:"informix".sd_maecred mc
				JOIN bdicred:"informix".sd_tarjeta tr ON ( tr.empresa = pEmpresa AND mc.num_credito = tr.num_credito AND tr.tipo_tarjeta = 'T' AND tr.secuencia = ( SELECT MAX(secuencia) 
					FROM bdicred:"informix".sd_tarjeta WHERE empresa = pEmpresa AND mc.num_credito = num_credito AND tipo_tarjeta = 'T' ) )
					WHERE mc.numcte = pNumCte

                LET vRegistros = vRegistros + 1;

                RETURN cod_ret, vNumTarjeta, vNombre1, vNombre2, vApellPaterno, vApellMaterno, vIdStatus, vFechaNac WITH RESUME;
			END FOREACH;
            
			 IF vRegistros = 0 THEN
                LET cod_ret = '003'; --Cliente no tiene cuentas de crÃ©dito
            END IF
        ELIF pTipoValidacion = 2 THEN
            FOREACH
                SELECT {(+INDEX) bdicheq:"informix".sc_maechq maecheques} nvl(b.num_tarjeta,'0000000000000000')
                  INTO vNumTarjeta
                  FROM bdicheq:"informix".sc_maechq  a
                 RIGHT OUTER JOIN bdicheq:"informix".sc_tarjeta b ON ( b.empresa = pEmpresa AND 
                                                            a.cuenta = b.cuenta  AND 
                                                            b.secuencia <> 0     AND 
                                                            b.status_tar = 'A'   AND 
                                                            b.tipo_tarjeta = 'T' )
                 WHERE a.num_cte = pNumCte
                   AND a.status_cta NOT IN('2')

                LET vRegistros = vRegistros + 1;

                RETURN cod_ret, vNumTarjeta, vNombre1, vNombre2, vApellPaterno, vApellMaterno, vIdStatus, vFechaNac WITH RESUME;
            END FOREACH;

            IF vRegistros = 0 THEN
                LET cod_ret = '002'; --Cliente no tiene cuentas de dÃ©bito
            END IF
		ELSE
			RETURN cod_ret, vNumTarjeta, vNombre1, vNombre2, vApellPaterno, vApellMaterno, vIdStatus, vFechaNac;
        END IF
	ELSE
		RETURN cod_ret, vNumTarjeta, vNombre1, vNombre2, vApellPaterno, vApellMaterno, vIdStatus, vFechaNac;	
    END IF
END    
END PROCEDURE ;