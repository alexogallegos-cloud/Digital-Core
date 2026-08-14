CREATE PROCEDURE  "informix".cons_tarjetas_cte_web(pempresa     CHAR(3),
                                              pnumcte      CHAR(20),
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
	      CHAR(1),       -- STATUS APLICATIVO
	      SMALLINT,      -- SISTEMA
          CHAR(50),      -- PRODUCTO
          CHAR(50),      -- DIVISA
          CHAR (3);      -- STATUS DE INTERCARD

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
DEFINE s_sistema       SMALLINT;
DEFINE s_status_cta    CHAR(1);
DEFINE s_producto      CHAR(50);
DEFINE s_divisa        CHAR(50);
DEFINE s_codstatustarjeta CHAR(3);
DEFINE s_rfc_alterno   CHAR(13);
DEFINE cProdTransfer   CHAR(4);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
SET OPTIMIZATION HIGH;
SET OPTIMIZATION ALL_ROWS;
LET scod_ret      = "00000";
LET vsqlerr       = 0;
LET v_cuantos     = 0;
LET s_numcte      = "";
LET s_nombre1	= "";
LET s_nombre2	= "";
LET s_paterno	= "";
LET s_materno	= "";
LET s_fechanac	= "";
LET s_rfc	      = "";
LET s_cuenta	= "";
LET s_tarjeta	= "";
LET s_status      = "";
LET s_sistema     = 0;
LET s_status_cta  = "";
LET s_producto    = "";
LET s_divisa      = "";
LET s_codstatustarjeta = "";
LET s_rfc_alterno = "";
LET cProdTransfer	= "";
--scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO dirty READ;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/integral/cons_tarjetas_cte.out";
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

   LET pempresa = pempresa;
   LET pnumcte = pnumcte;


  -- Valida Parametros de Entrada

  IF pempresa = "" or
     pnumcte = ""  then
     LET scod_ret = "00110";
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta;
  END IF


	SELECT valor 
	INTO cProdTransfer
	FROM bditransfer:"informix".tf_param 
	WHERE empresa = pempresa 
	AND	cod_param = 4;

  -- Extrae las Tarjeta de Cheques
	-- Se agrega la validaciÃ³n a la sc_firmantes para solo buscar tarjetas autorizadas
	-- CGP 10032015
  FOREACH
     SELECT a.cuenta, a.num_tarjeta, a.numcte, a.status_tar, e.producto || " " || e.nombre,f.divisa || " " || f.descripcion,
            b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno, b.rfc,
            c.fecha_nac, tar.codstatustarjeta, b.rfc_alterno  
       INTO s_cuenta, s_tarjeta, s_numcte,s_status, s_producto, s_divisa,
            s_nombre1,s_nombre2,s_paterno,s_materno,s_rfc,
            s_fechanac, s_codstatustarjeta, s_rfc_alterno
       FROM bdicheq:"informix".sc_tarjeta a,
            bdinteg:"informix".si_cliente b,
            bdinteg:"informix".si_ctepf c,
            bdicheq:"informix".sc_maechq d,
            bdicheq:"informix".sc_producto e,
            bdinteg:"informix".si_divisas f,
            intercard:"informix".tarjeta tar,
			bdicheq:"informix".sc_firmantes as firm
      WHERE a.empresa = b.empresa
            AND a.numcte = b.numcte
            AND a.empresa = c.empresa
            AND a.numcte = c.numcte
            AND a.empresa = d.empresa
            AND a.cuenta = d.cuenta
            AND e.empresa = a.empresa
            AND e.producto = a.prodtarjeta
            AND f.empresa = a.empresa
            AND f.divisa = e.divisa
			and (firm.cuenta = a.cuenta)
			and (firm.numcte = a.numcte)
            AND (a.num_tarjeta = tar.numtarjeta)

            AND ((a.empresa=pempresa)
--            AND (a.tipo_tarjeta='T')
            AND (d.status_cta = "1")
            AND (a.numcte=pnumcte))
			AND a.prodtarjeta <> cProdTransfer  order by a.num_tarjeta

     LET s_sistema = 1;

     LET v_cuantos = v_cuantos + 1;
     IF v_cuantos <= pregistros THEN
        CONTINUE FOREACH;
     END IF;

	 IF s_rfc_alterno is not null and s_rfc_alterno <> "" THEN
        LET s_rfc = s_rfc_alterno;
     END IF;	
	 
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta
            WITH RESUME;


  END FOREACH

  -- Extrae las Tarjeta de Credito
  FOREACH
SELECT a.num_credito, a.num_tarjeta, a.numcte, a.status_tar,  e.num_producto || " " || e.nombre_prod, f.divisa || " " || f.descripcion,
            b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno, b.rfc,
            c.fecha_nac, tar.codstatustarjeta, b.rfc_alterno 
       INTO s_cuenta,  s_tarjeta, s_numcte,  s_status, s_producto, s_divisa,
            s_nombre1, s_nombre2, s_paterno, s_materno, s_rfc,
            s_fechanac, s_codstatustarjeta, s_rfc_alterno
       FROM bdicred:"informix".sd_maecred d,
            bdicred:"informix".sd_tarjeta a,
            bdinteg:"informix".si_cliente b,
            bdinteg:"informix".si_ctepf c,
            bdicred:"informix".sd_definicion e,
            bdinteg:"informix".si_divisas f,
            intercard:"informix".tarjeta tar
      WHERE d.numcte=pnumcte
            and d.numcte = b.numcte
            AND d.numcte = c.numcte
            and a.empresa = d.empresa
            and a.num_credito = d.num_credito  
            AND e.empresa = d.empresa
            AND e.num_producto = d.num_producto
            and f.empresa=pempresa
            AND f.divisa = d.divisa
            AND a.num_tarjeta = tar.numtarjeta
            AND d.status_cred <> "FF"
	ORDER BY a.num_tarjeta    

     LET s_sistema = 6;

     LET v_cuantos = v_cuantos + 1;
     IF v_cuantos <= pregistros THEN
        CONTINUE FOREACH;
     END IF

	 IF s_rfc_alterno is not null or s_rfc_alterno <> "" THEN
        LET s_rfc = s_rfc_alterno;
     END IF;	
	 
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta
            WITH RESUME;


  END FOREACH

END

END PROCEDURE

DOCUMENT
"Especificacion: Se modifico para que consulte el status de la",
"                tarjeta en la tabla intercard:tarjeta y se regrese como retorno",
"Base de Datos : bdinteg",
"AUTOR : Jesus Manuel Perea Heredia",
"FECHA : 19/Nov/2010",
"Descripcion: Se actualiza a la nueva version de reglas.", 
"Base de Datos : bdinteg",
"Autor : Marcos Cuevas",
"Fecha : 16/Febrero/2011",
'',
'FOLIO: 1611',
'FECHA : 26/06/2014',
'MODIFICO : 94972834',
'MODIFICACION: se modifica para excluir las tarjetas que pertenecen a un producto transfer',
'SUSTENTO: modificaciones_promotoria.pdf',
'SOLICITA: Rodolfo Gomez',
'BD: bdinteg',
--------------REINGENIERIA-----------
'Descripcion: Se genera un clon del sp "sp_clona_tdc_upgrade" para que este tenga un cod ret de 5 caracteres',
'AUTOR : Efrain MIranda Miranda',
'FECHA : 15/08/2019',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_valida_sms_cte_web( pNumCte CHAR(9))
 RETURNING CHAR(5) as CodRet ,
		   SMALLINT  as valido,
		   CHAR(13) as telefono;

DEFINE cCodret   CHAR(5);
DEFINE iSql_err  INTEGER;
DEFINE iValido   INTEGER;
DEFINE cTel      CHAR(13);

LET cCodret     = '00000';
LET iSql_err    = 0;
LET iValido     = 0;
LET cTel        = '';

BEGIN
	ON EXCEPTION SET iSql_err
		--LET cCodret = CAST(iSql_err AS CHAR);
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN cCodret,iValido,cTel;
		END IF;
	END EXCEPTION;	
	
	--SET DEBUG FILE TO '/informix/jesus/sp_valida_sms_cte.sql';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    
	IF (SELECT COUNT(b.numcte)
		FROM bdinteg:"informix".si_telefonos_actual a
		LEFT JOIN bdinteg:"informix".si_bitsmstels b ON a.numcte=b.numcte AND a.telefono=b.telefono AND  b.bandera='t' AND  b.fecha::DATE = TODAY		
		WHERE a.numcte=pNumCte
		AND a.tipo_tel=2 AND a.status_tel='A'
		and fecha = (SELECT max(fecha) from bdinteg:"informix".si_bitsmstels c 
                        where c.numcte=a.numcte AND a.telefono=a.telefono 
                        AND  c.fecha::DATE = TODAY)
		) 
 > 0 THEN		
			LET iValido =1;
		
	END IF 
    
    SELECT  LIMIT 1 telefono
    INTO cTel
    FROM bdinteg:"informix".si_telefonos_actual a
    WHERE a.numcte=pNumCte
    AND a.tipo_tel=2 AND a.status_tel='A';
		
	RETURN cCodret,iValido, cTel;

END;
END PROCEDURE
DOCUMENT
'Autor:	JESUS MANUEL AGUILAR HEREDIA',
'FECHA:	30/SEP/2016',
'DESCRIPCION: se crea procedimiento para ser usado en el flujo de 2 credito.',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_valida_confirmacion_movil_web(pNumCte CHAR(9), pUsuario CHAR(8),pTelefono CHAR(10))
RETURNING CHAR(5) As cCodRet;

--Definicion de Variables 
DEFINE cCodRet			CHAR (5);
DEFINE cBandera         BOOLEAN;
DEFINE iSqlErr          INTEGER;
--Inicializacion de Variables

LET cCodRet      = '00000';
LET cBandera     = 'F';
LET iSqlErr      = 0;

BEGIN	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			let cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/respaldosbd/Braulio/sp_valida_confirmacion_movil.out";
	--TRACE ON; 
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pNumCte,'') <> '' AND NVL(pUsuario,'') <> '' AND NVL(pTelefono,'') <> '' THEN

			SELECT bandera 
			INTO cBandera
			FROM bdinteg:"informix".si_bitsmstels
			WHERE numcte = pNumCte 
			AND telefono = pTelefono 
			AND ejecutivo = pUsuario
			AND fecha IN (SELECT MAX(FECHA) FROM bdinteg:"informix".si_bitsmstels 
						  WHERE numcte = pNumCte
						  AND telefono = pTelefono
						  AND ejecutivo = pUsuario);

			IF dbinfo ("sqlca.sqlerrd2") = 0 then-- No hay informacion
				LET cCodRet = '01289';
				RETURN cCodRet;
			END IF;

			IF cBandera = 'F' THEN
				LET cCodRet = '01386';
			ELIF cBandera = 'T' THEN
				LET cCodRet = '00000';
			END IF;
	ELSE
		LET cCodRet = '00001';
	END IF; 

RETURN cCodRet;
END;
END PROCEDURE;