CREATE PROCEDURE "informix".sp_cnsif_cons_tarjetas_cte2(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCTE CHAR(20),pNumRegistro INTEGER,pRecuperacion INTEGER)

RETURNING 	    CHAR(5)  AS Cod_Retorno,
				CHAR(1)  AS Chequera,
				CHAR(4)  AS Cve_Producto,
				CHAR(40) AS Producto,
				CHAR(20) AS Numero_Cuenta,
				CHAR(20) AS Numero_Tarjeta,
				CHAR(15) AS Status_Tarjeta,
				DATE     AS Fecha_Expira,
				CHAR(15) AS Tipo_Tarjeta,
				CHAR(2)  AS Sistema_Cuenta,
                DATE     AS Fecha_Status,
				CHAR(10) AS Telefono_Movil;



-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     	CHAR(5);
DEFINE vsqlerr      	INTEGER;
DEFINE cIchequera		CHAR(1);
DEFINE cProducto		CHAR(4);
DEFINE cNombre_producto	CHAR(40);
DEFINE cNumero_cuenta	CHAR(20);
DEFINE cNumero_tarjeta	CHAR(20);
DEFINE cStatus_tarjeta	CHAR(15);
DEFINE dFecha_expiracion DATE;
DEFINE cTipo_tarjeta	CHAR(15);
DEFINE cNTarjeta		CHAR(20);
DEFINE iexiste			INTEGER;
DEFINE iexistente		SMALLINT;
DEFINE iCont            INTEGER;
DEFINE cSistema_cuenta	CHAR(2);
DEFINE sSecuencia       SMALLINT;
DEFINE dFechaStatus     DATE;
DEFINE iTpo_cliente			INT;
DEFINE cNumCtePrincipal CHAR(20);
DEFINE cTelefonoMovil   CHAR(10);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret = "00000";
LET cIchequera	= '';
LET cProducto = '';
LET cNombre_producto = '';
LET cNumero_cuenta	= '';
LET cNumero_tarjeta	= '';
LET cStatus_tarjeta	= '';
LET dFecha_expiracion = '';
LET cTipo_tarjeta	= '';
LET cNTarjeta = '' ;
LET iexiste	 = 0;
LET iCont=0;
LET cSistema_cuenta='';
LET iexistente=0;
LET sSecuencia=0;
LET dFechaStatus='';
LET iTpo_cliente=0;
LET cNumCtePrincipal = "";
LET cTelefonoMovil = "";

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION TO DIRTY READ;

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta,dFechaStatus, cTelefonoMovil;
   END IF;
END EXCEPTION;


	--SET DEBUG FILE TO "/tmp/mfinis/sp_cnsif_cons_tarjetas_cte2.out";
	--TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************g
  -- Valida Parametros de Entrada

      IF cID_USUARIOC = "" OR 
         cID_FUNCIONC = "" OR
         cNUMCTE  = ""  THEN
         LET scod_ret = "00054";
         RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta,dFechaStatus, cTelefonoMovil;
      END IF;

    IF pNumRegistro<0 THEN
        LET scod_ret='00098';
        RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta,dFechaStatus, cTelefonoMovil;
    ELSE
        IF pRecuperacion<=0 THEN
            LET scod_ret='00098';
            RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta,dFechaStatus, cTelefonoMovil;
        END IF;
    END IF;   	  
--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCTE,'01','2')
	INTO
	scod_ret;
	IF (scod_ret != '00000')  THEN
		RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta,dFechaStatus, cTelefonoMovil;
	END IF;
	-- TERMINA VALIDACION	  

--TRANSFER
	EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(cNUMCTE) INTO scod_ret,iTpo_cliente,cNumCtePrincipal;
	IF cNumCtePrincipal IS NOT NULL THEN
		LET cNUMCTE = cNumCtePrincipal;
	END IF;
--TRANSFER	

--TRANSFER	
	 FOREACH
     SELECT LIMIT 1 NVL(COUNT(numcte),0) into iexiste FROM si_cliente  WHERE numcte = cNUMCTE
	 UNION
	 SELECT NVL(COUNT(numcte_tf),0) FROM bditransfer:tf_maecte  WHERE numcte_tf = cNUMCTE
	 ORDER BY 1 DESC
	 END FOREACH;
--TRANSFER	 
     IF iexiste = 0 THEN 
            LET scod_ret = "00055";
            RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta,dFechaStatus, cTelefonoMovil;
      END IF;	

  -- Extrae las Tarjeta de Cheques
    IF pNumRegistro=0 THEN
          DELETE FROM si_tempotarjetas WHERE ejecutivosif= cID_USUARIOC;
          --SET ISOLATION TO dirty READ;
          FOREACH
            SELECT --+AVOID_FULL(bdicheq:sc_tarjeta) 
			num_tarjeta,secuencia  
            INTO  cNTarjeta,sSecuencia 
            FROM bdicheq:sc_tarjeta 
            WHERE numcte = cNUMCTE AND cuenta IS NOT NULL ORDER BY cuenta,secuencia

            SELECT --+AVOID_FULL(bdicheq:sc_tarjeta) 
			DECODE(prodtarjeta,"2200","S","1900","S","N"),prodtarjeta,cuenta,num_tarjeta,expiracion,DECODE(tipo_tarjeta,"T","TITULAR","A","ADICIONAL","DESCONOCIDO")
            INTO 
            cIchequera,cProducto, cNumero_cuenta, cNumero_tarjeta, dFecha_expiracion, cTipo_tarjeta
            FROM bdicheq:sc_tarjeta 
            WHERE  num_tarjeta =  cNTarjeta AND secuencia=sSecuencia;

            SELECT  nombre
            INTO cNombre_producto
            FROM bdicheq:sc_producto 
            WHERE producto = cProducto;

            SELECT LIMIT 1 {+INDEX (intercard:tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),""),A.fechaultmodif INTO cStatus_tarjeta,dFechaStatus FROM intercard:tarjeta A
            LEFT JOIN intercard:statustarjeta B
            ON A.codstatustarjeta = B.codstatustarjeta
            WHERE A.numcliente= cNUMCTE
            AND A.numtarjeta= cNTarjeta;
            
			-- BUSQUEDA DEL NUMERO DE MOVIL DE LA CUENTA
           IF cNombre_producto= trim('CUENTA TRANSFER') THEN
                select telefono 
				INTO cTelefonoMovil 
				FROM bditransfer:"informix".tf_maecte
                where numcte = cNUMCTE
                and cuenta_tf = cNumero_cuenta;
            ELSE 
                SELECT telefono  
				INTO cTelefonoMovil 
				FROM bdicheq:"informix".sc_cuenta_telefono
                WHERE cuenta = cNumero_cuenta AND num_cte = cNUMCTE;
            END IF;

            INSERT INTO si_tempotarjetas (cod_ret,ichequera,producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta,fecha_expiracion, tipo_tarjeta,numcte,sistema,ejecutivosif,fecstatus,numero_movil)
            VALUES (scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cNUMCTE,'01',cID_USUARIOC,dFechaStatus,cTelefonoMovil);
			
            LET iexistente=1;
           END FOREACH;


 

          -- Extrae las Tarjeta de Credito
		 LET cTelefonoMovil = null; 
		  
		  
         --SET ISOLATION TO dirty READ;
          FOREACH
            SELECT num_tarjeta,num_credito,secuencia 
            INTO  cNTarjeta,cNumero_cuenta,sSecuencia  
            FROM bdicred:sd_tarjeta
            WHERE numcte=cNUMCTE ORDER BY num_credito,secuencia

            SELECT DECODE(prodtarjeta,"2200","S","1900","S","N"),num_tarjeta,
                    expiracion,DECODE(tipo_tarjeta,"T","TITULAR","A","ADICIONAL","DESCONOCIDO")
            INTO 
            cIchequera,cNumero_tarjeta, dFecha_expiracion, cTipo_tarjeta
            FROM bdicred:sd_tarjeta      
            WHERE num_tarjeta = cNTarjeta AND secuencia=sSecuencia;


            SELECT LIMIT 1 {+INDEX (intercard:tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),""),A.fechaultmodif INTO cStatus_tarjeta,dFechaStatus FROM intercard:tarjeta A
            LEFT JOIN intercard:statustarjeta B
            ON A.codstatustarjeta = B.codstatustarjeta
            WHERE A.numcliente= cNUMCTE
            AND A.numtarjeta= cNTarjeta;

            FOREACH
                SELECT LIMIT 1 num_producto AS PROD INTO cProducto FROM bdicred:sd_maecred where num_credito=cNumero_cuenta AND empresa='001'
                UNION
                SELECT num_producto as PROD FROM bdicred:sd_maecredcrd where num_credito=cNumero_cuenta AND empresa='001' ORDER BY PROD DESC
            END FOREACH;

            SELECT nombre_prod,num_producto 
            INTO cNombre_producto,cProducto
            FROM bdicred:sd_definicion
            WHERE num_producto = cProducto;


            INSERT INTO si_tempotarjetas (cod_ret,ichequera,producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta,fecha_expiracion, tipo_tarjeta,numcte,sistema,ejecutivosif,fecstatus,numero_movil)
            VALUES (scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cNUMCTE,'06',cID_USUARIOC,dFechaStatus,cTelefonoMovil);

            LET iexistente=1;			
          END FOREACH;
          IF iexistente=0 THEN
            LET scod_ret = '00097'; 
            RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta,dFechaStatus, cTelefonoMovil; --CHVN
          END IF;
     END IF;

     --SET ISOLATION TO dirty READ;
     FOREACH
        SELECT SKIP pNumRegistro FIRST pRecuperacion cod_ret,ichequera,producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta,fecha_expiracion, tipo_tarjeta,sistema,fecstatus,numero_movil
        INTO scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta,dFechaStatus,cTelefonoMovil
        FROM si_tempotarjetas
        WHERE ejecutivosif= cID_USUARIOC ORDER BY numero_cuenta
		LET iCont=iCont+1;
        RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta,dFechaStatus, cTelefonoMovil WITH RESUME;     END FOREACH;
     IF iCont = 0 THEN
        DELETE FROM si_tempotarjetas WHERE ejecutivosif= cID_USUARIOC;
        LET scod_ret = '1001'; 
        RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta,dFechaStatus, cTelefonoMovil;     END IF 
END

END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO:Este sp realizara la busqueda de tarjetas de cheques y credito dependiendo del numero de cliente  que se envie a dicho SP",
"FECHA : 05-01-2012",
"BD    : bdinteg",
"Modifico : Victor Hugo SÃ¡nchez",
"MODIFICACION : Se almacenan los datos de las tarjetas en tabla de paso y se agrega la paginacion",
"VER   : 1.0",
"Modifico : Oscar Flores Conde",
"MODIFICACION : Se agrega el numero de movil por cuenta",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_obt_valoriva(pCodParametro smallint)
        RETURNING char(5), money(14,2);

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener valor de IVA
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 14/12/2009

       DEFINE vcodret   char(5);
       DEFINE valorIVA  money(14,2);
	   DEFINE sql_err   integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, valorIVA;
       END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET vcodret = '000';
LET valorIVA = 0;

BEGIN

		SELECT valor
		INTO valorIVA
		FROM bdinteg:si_param
		WHERE cod_param = pCodParametro;
		

		RETURN vcodret, valorIVA;
END;

END PROCEDURE;