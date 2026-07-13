CREATE PROCEDURE "informix".sp_actnomcterfcalterno(pEmpresa CHAR(3), pNumcte CHAR (20), pRFC CHAR (13), pTipo CHAR(1))
RETURNING CHAR(5) AS retorno;
			
    -- // DEFINICION DE VARIABLES
    DEFINE iSqlErr			INTEGER;
    DEFINE cValRetorno	    CHAR(5);
    DEFINE cNumCte		    CHAR(20);
    DEFINE cApellPaterno	CHAR(26);
    DEFINE cApellMaterno	CHAR(26);
    DEFINE cNombre1		    CHAR(26);
    DEFINE cNombre2			CHAR(26);
    DEFINE cRfc				CHAR(13);
    DEFINE cRfcAlt			CHAR(13);
    DEFINE iRFCCont			INTEGER;
    DEFINE vexiste          INTEGER;

    -- // INICIALIZACION DE VARIABLES
    LET cValRetorno 	= '00001';
    LET cNumCte			= "";
    LET cApellPaterno 	= "";
    LET cApellMaterno	= "";
    LET cNombre1		= "";
    LET cNombre2		= "";
    LET cRfc			= "";
    LET cRfcAlt			= "";
    LET iRFCCont 		= 0;
    LET vexiste         = 0;
    
    --- SET DEBUG FILE TO "/tmp/sp_actnomcterfcalterno.out"; 
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO wait 3;

    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            RETURN iSqlErr;
        END IF;
    END EXCEPTION;

    IF NVL(pEmpresa,'') = '' OR NVL(pNumcte,'') = '' OR NVL(pRFC,'') = '' OR NVL(pTipo,'') = '' THEN

        LET cValRetorno = '00002';
        LET pNumcte = LPAD(TRIM(pNumcte),9,'0');
        LET pRFC = LPAD(TRIM(pRFC),13,'0');

    ELIF pTipo = 1 OR pTipo = 2 THEN

        Update bdinteg:"informix".si_cliente 
           SET rfc_alterno = pRFC
         WHERE numcte = pNumcte;
         
        LET cValRetorno = '00000';

    ElIf pTipo = 3 OR pTipo = 4  THEN

        SELECT COUNT(*)
          INTO vexiste
          FROM bdilide:"informix".sl_consat 
         Where num_cte = pNumcte;
         
        IF vexiste = 0 THEN
        --- IF NOT EXISTS (SELECT num_cte FROM bdilide:"informix".sl_consat Where num_cte = pNumcte) THEN
            SELECT nombre1 
              INTO cNombre1 
              FROM bdinteg:"informix".si_cliente
             WHERE numcte = pNumcte;

            -- // SE ELIMINA ESTE UPDATE A SOLICITUD DE ENRIQUE PEREZ  14-11-2011 MLFLORES
            Update bdinteg:"informix".si_cliente 
               SET rfc_alterno = pRFC 
               --- (nombre1 = TRIM (cNombre1)||'X',) 
             WHERE numcte = pNumcte;
               
            LET cValRetorno = '00000';
        ElSE
            Update bdinteg:"informix".si_cliente 
               SET rfc_alterno = pRFC
             WHERE numcte = pNumcte;
               
            LET cValRetorno = '00000';

        END IF;

    END IF;

    RETURN cValRetorno;

    END
    
END PROCEDURE

DOCUMENT
'Creado: Martin Miranda',
'Fecha: 04/03/2011',
'Descripcion: Se crea para actaulizar el campo rfc_alterno, al igual que el nombre del cliente si existe mas de 1 cliente con el mismo rfc',
'Modifico: Martin Miranda',
'Fecha: 07/06/2011',
'Descripcion: Modifica para tomar pTipo con valor 4 en el Update del Cliente''Modificado: Martin Miranda',
'Fecha: 14/06/2011',
'Descripcion: Se agrega validación para que no añada la letra "X" al campo nombre1 de la tabla si_cliente cuando exista un registro para',
'             ese cliente en la tabla sl_consat de la base de datos bdilide.';

CREATE PROCEDURE "informix".sp_consultanombrerfcalterno(pEmpresa CHAR(3), pNumcte CHAR(20), pRFC CHAR (13))
RETURNING 	CHAR(5) AS retorno,
			CHAR(20) AS numcta, 
			CHAR (20) AS numcte,
			CHAR(26) AS apell_paterno, 
			CHAR(26) AS apell_materno,
			CHAR(26) AS nombre1, 
			CHAR(26) AS nombre2, 
			CHAR(13) AS rfc;
	
    -- DEFINICION DE VARIABLES
    DEFINE iSqlErr			INTEGER;
    DEFINE cValRetorno		CHAR(5);
    DEFINE cNumCte			CHAR(20);
    DEFINE cApellPaterno	CHAR(26);
    DEFINE cApellMaterno	CHAR(26);
    DEFINE cNombre1			CHAR(26);
    DEFINE cNombre2			CHAR(26);
    DEFINE cRfc				CHAR(13);

    --INICIALIZACION DE VARIABLES
    LET cValRetorno     = '00001';
    LET cNumCte			= "";
    LET cApellPaterno 	= "";
    LET cApellMaterno	= "";
    LET cNombre1		= "";
    LET cNombre2		= "";
    LET cRfc			= "";

    --- SET DEBUG FILE TO "/tmp/sp_consultanombrerfcalterno.out"; 
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO wait 3;

    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            RETURN iSqlErr,'','','','','','','';
        END IF;
    END EXCEPTION;

    IF NVL(pEmpresa,'') = '' OR NVL(pNumcte,'') = '' THEN
        LET cValRetorno = '00001';
    ELSE
        LET pNumcte = LPAD(TRIM(pNumcte),9,'0');
        LET pRFC = LPAD(TRIM(pRFC),13,'0');

        IF (Select rfc_alterno FROM bdinteg:"informix".si_cliente WHERE empresa = pEmpresa AND numcte = pNumcte) <> "" THEN
            SELECT numcte, apell_paterno, apell_materno, nombre1, nombre2,  rfc_alterno 
              INTO cNumCte, cApellPaterno, cApellMaterno, cNombre1,cNombre2, cRfc
              FROM bdinteg:"informix".si_cliente
             WHERE empresa = pEmpresa AND numcte = pNumcte;	
        ELSE
            SELECT numcte, apell_paterno, apell_materno, nombre1, nombre2,  rfc
              INTO cNumCte, cApellPaterno, cApellMaterno, cNombre1,cNombre2, cRfc
              FROM bdinteg:"informix".si_cliente
             WHERE empresa = pEmpresa AND numcte = pNumcte;
        END IF;

        LET cValRetorno = '00000';
    END IF;
    
    RETURN cValRetorno,'', cNumCte, cApellPaterno, cApellMaterno, cNombre1,cNombre2, cRfc;	
    
    END
    
END PROCEDURE             
DOCUMENT
'Creado: Martin Miranda',
'Fecha: 04/03/2011',
'Descripcion: Se crea para obtener los datos del cliente seleccionado';

CREATE PROCEDURE "informix".sp_consultacalles(pCalle INTEGER ,pNombre char(30),pRegistros INTEGER)
RETURNING CHAR(6)  AS Codigo_Retorno,
          CHAR(80) AS Mensaje_Retorno,
		  INTEGER  AS Calle,
		  CHAR(30) AS Nombre;          
          
DEFINE cCodRet           CHAR(6); 
DEFINE cMensajeRet       CHAR(80);
DEFINE cComentario       CHAR(80);
DEFINE iSqlErr      	 INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE vCont 			 INTEGER;
DEFINE iValor 			 INTEGER;
DEFINE iCalle   		 INTEGER; 
DEFINE cNombre     		 CHAR(30); 

BEGIN


ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, cMensajeRet,iCalle,NVL(cNombre,'');
   END IF;
END EXCEPTION;

LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = '';
LET cCodRet                  = '000000';
LET cMensajeRet              = 'Se realizó la consulta correctamente';
LET vCont 					 = 0;
LET iValor 					 = 0;
LET iCalle                  = 0;
LET cNombre                  = '';

--Set debug file to '/home/sysifx/Antonio/sp_ConsultaCallesCP.out';
--trace on;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--obtencion del valor  para realizar la paginacion.
	SELECT valor::integer 
		INTO iValor
	FROM bdicobranza:cb_param 
	WHERE empresa = '001' 
	AND cod_param = '32';
--validacion de los parametros.
IF iValor IS NULL OR  iValor = "" THEN
    LET cCodRet                  = '000002';
	LET cMensajeRet              = 'Error al obtener el parámetro del máximo numero de registros';
	RETURN cCodRet, cMensajeRet,iCalle,NVL(cNombre,'');
END IF;
--se obtiene la informacion del numero de calle proporcionado en el parametro de entrada
IF pCalle > 0 THEN
	SELECT numerocalle,nombrecalle
	INTO iCalle,cNombre
	FROM bdinteg:si_catcalles				
	WHERE numerocalle = pCalle;
	
	LET vCont = dbinfo("sqlca.sqlerrd2");
		IF vCont = 0 THEN
			LET cCodRet = '000003';
			LET cMensajeRet = 'No se encontraron registros';
			RETURN cCodRet, cMensajeRet,iCalle,NVL(cNombre,'');
		END IF;
		
	RETURN cCodRet, cMensajeRet,iCalle,NVL(cNombre,'');
END IF;

--se obtienen los registros  indicados en el parametro obtenido con anterioridad que tengan similitud a la consulta
	FOREACH WITH HOLD
	
		SELECT  SKIP pRegistros FIRST iValor numerocalle,nombrecalle
		INTO iCalle,cNombre
		FROM bdinteg:si_catcalles				
		WHERE UPPER(TRIM(nombrecalle)) LIKE CASE when pNombre = '' THEN UPPER(nombrecalle)   ELSE '%'||UPPER(TRIM(pNombre))||'%' END
		ORDER BY nombrecalle	
			
			RETURN cCodRet, cMensajeRet,iCalle,NVL(cNombre,'') WITH RESUME;
	END FOREACH;
	
		LET vCont = dbinfo("sqlca.sqlerrd2");
		IF vCont = 0 THEN
			LET cCodRet = '000003';
			LET cMensajeRet = 'No se encontraron registros';
			RETURN cCodRet, cMensajeRet,iCalle,NVL(cNombre,'');
		END IF;
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para Obtener el listado de calles existentes y/o obtener coincidencias por descripcion de calle ',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 08/SEPTIEMBRE/2010',
'Se elimina el forzado del índice.',
'AUTOR : Jesús Antonio Bastidas López',
'FECHA : 08/02/2011',
'Version: 20110208.1241',
'BD    : BDINTEG',
'MODIFICACION: Cambiar condición en consulta por nombrecalle, quitar por numerocalle para bajar el costeo y eliminar sequential scan.',
'AUTOR: Marco A. Campos  2012-02-21';

CREATE PROCEDURE  "informix".cons_tarjetas_cte_pba(pempresa     CHAR(3),
                                              pnumcte      CHAR(20),
                                              pregistros   SMALLINT)

RETURNING CHAR(5),       -- Codigo de Retorno
          CHAR(20),      -- Nro de Cliente
          CHAR(26),      -- Nombre1
	    CHAR(26),      -- Nombre2
	    CHAR(26),      -- Apellido Paterno
          CHAR(26),      -- Apellido Materno
          DATE,  	       -- Fecha Nacimiento
	    CHAR(13),      -- RFC
	    CHAR(20),      -- CUENTA
	    CHAR(20),      -- TARJETA
	    CHAR(1),       -- STATUS APLICATIVO
	    SMALLINT,      -- SISTEMA
          CHAR(50),      -- PRODUCTO
          CHAR(50),      -- DIVISA
          CHAR (3);    --STATUS DE INTERCARD

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

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret      = "000";
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

--scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa;


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
     LET scod_ret = "110";
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta;
  END IF




  -- Extrae las Tarjeta de Cheques
  FOREACH
     SELECT a.cuenta, a.num_tarjeta, a.numcte, a.status_tar, e.producto || " " || e.nombre,f.divisa || " " || f.descripcion,
            b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno, b.rfc,
            c.fecha_nac, tar.codstatustarjeta
       INTO s_cuenta, s_tarjeta, s_numcte,s_status, s_producto, s_divisa,
            s_nombre1,s_nombre2,s_paterno,s_materno,s_rfc,
            s_fechanac, s_codstatustarjeta
       FROM bdicheq:sc_tarjeta a,
            bdinteg:si_cliente b,
            bdinteg:si_ctepf c,
            bdicheq:sc_maechq d,
            bdicheq:sc_producto e,
            bdinteg:si_divisas f,
            intercard:tarjeta tar
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
            AND (a.num_tarjeta = tar.numtarjeta)

            AND ((a.empresa=pempresa)
--            AND (a.tipo_tarjeta='T')
            AND (d.status_cta = "1")
            AND (a.numcte=pnumcte)) order by a.num_tarjeta

     LET s_sistema = 1;

     LET v_cuantos = v_cuantos + 1;
     IF v_cuantos <= pregistros THEN
        CONTINUE FOREACH;
     END IF

     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta
            WITH RESUME;


  END FOREACH

  -- Extrae las Tarjeta de Credito
  FOREACH
SELECT {+INDEX(bdicred:sd_maecred idx_maecreda), +INDEX(bdicred:sd_tarjeta idx_tarjeta1),  +INDEX(bdinteg:si_cliente idx_si_cliente5)}
            a.num_credito, a.num_tarjeta, a.numcte, a.status_tar,  e.num_producto || " " || e.nombre_prod, f.divisa || " " || f.descripcion,
            b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno, b.rfc,
            c.fecha_nac, tar.codstatustarjeta
       INTO s_cuenta,  s_tarjeta, s_numcte,  s_status, s_producto, s_divisa,
            s_nombre1, s_nombre2, s_paterno, s_materno, s_rfc,
            s_fechanac, s_codstatustarjeta
       FROM bdicred:sd_maecred d,
            bdicred:sd_tarjeta a,
            bdinteg:si_cliente b,
            bdinteg:si_ctepf c,
            bdicred:sd_definicion e,
            bdinteg:si_divisas f,
            intercard:tarjeta tar
      WHERE d.empresa= pempresa
            and d.numcte=pnumcte
            and b.empresa = pempresa
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
"Fecha : 16/Febrero/2011";

CREATE PROCEDURE  "informix".cons_tarjetas_cte_pba17(pempresa     CHAR(3),
                                              pnumcte      CHAR(20),
                                              pregistros   SMALLINT)

RETURNING CHAR(5),       -- Codigo de Retorno
          CHAR(20),      -- Nro de Cliente
          CHAR(26),      -- Nombre1
	    CHAR(26),      -- Nombre2
	    CHAR(26),      -- Apellido Paterno
          CHAR(26),      -- Apellido Materno
          DATE,  	       -- Fecha Nacimiento
	    CHAR(13),      -- RFC
	    CHAR(20),      -- CUENTA
	    CHAR(20),      -- TARJETA
	    CHAR(1),       -- STATUS APLICATIVO
	    SMALLINT,      -- SISTEMA
          CHAR(50),      -- PRODUCTO
          CHAR(50),      -- DIVISA
          CHAR (3);    --STATUS DE INTERCARD

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

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret      = "000";
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

--scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa;


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
     LET scod_ret = "110";
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta;
  END IF




  -- Extrae las Tarjeta de Cheques
  FOREACH
     SELECT a.cuenta, a.num_tarjeta, a.numcte, a.status_tar, e.producto || " " || e.nombre,f.divisa || " " || f.descripcion,
            b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno, b.rfc,
            c.fecha_nac, tar.codstatustarjeta
       INTO s_cuenta, s_tarjeta, s_numcte,s_status, s_producto, s_divisa,
            s_nombre1,s_nombre2,s_paterno,s_materno,s_rfc,
            s_fechanac, s_codstatustarjeta
       FROM bdicheq:sc_tarjeta a,
            bdinteg:si_cliente b,
            bdinteg:si_ctepf c,
            bdicheq:sc_maechq d,
            bdicheq:sc_producto e,
            bdinteg:si_divisas f,
            intercard:tarjeta tar
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
            AND (a.num_tarjeta = tar.numtarjeta)

            AND ((a.empresa=pempresa)
--            AND (a.tipo_tarjeta='T')
            AND (d.status_cta = "1")
            AND (a.numcte=pnumcte)) order by a.num_tarjeta

     LET s_sistema = 1;

     LET v_cuantos = v_cuantos + 1;
     IF v_cuantos <= pregistros THEN
        CONTINUE FOREACH;
     END IF

     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta
            WITH RESUME;


  END FOREACH

  -- Extrae las Tarjeta de Credito
  FOREACH
SELECT {+INDEX(bdicred:sd_maecred idx_maecreda), +INDEX(bdicred:sd_tarjeta idx_tarjeta1),  +INDEX(bdinteg:si_cliente idx_si_cliente5)}
            a.num_credito, a.num_tarjeta, a.numcte, a.status_tar,  e.num_producto || " " || e.nombre_prod, f.divisa || " " || f.descripcion,
            b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno, b.rfc,
            c.fecha_nac, tar.codstatustarjeta
       INTO s_cuenta,  s_tarjeta, s_numcte,  s_status, s_producto, s_divisa,
            s_nombre1, s_nombre2, s_paterno, s_materno, s_rfc,
            s_fechanac, s_codstatustarjeta
       FROM bdicred:sd_maecred d,
            bdicred:sd_tarjeta a,
            bdinteg:si_cliente b,
            bdinteg:si_ctepf c,
            bdicred:sd_definicion e,
            bdinteg:si_divisas f,
            intercard:tarjeta tar
      WHERE d.empresa= pempresa
            and d.numcte=pnumcte
            and b.empresa = pempresa
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
"Fecha : 16/Febrero/2011";

CREATE PROCEDURE  "informix".cons_tarjetas_cte_pba1(pempresa     CHAR(3),
                                              pnumcte      CHAR(20),
                                              pregistros   SMALLINT)

RETURNING CHAR(5),       -- Codigo de Retorno
          CHAR(20),      -- Nro de Cliente
          CHAR(26),      -- Nombre1
	    CHAR(26),      -- Nombre2
	    CHAR(26),      -- Apellido Paterno
          CHAR(26),      -- Apellido Materno
          DATE,  	       -- Fecha Nacimiento
	    CHAR(13),      -- RFC
	    CHAR(20),      -- CUENTA
	    CHAR(20),      -- TARJETA
	    CHAR(1),       -- STATUS APLICATIVO
	    SMALLINT,      -- SISTEMA
          CHAR(50),      -- PRODUCTO
          CHAR(50),      -- DIVISA
          CHAR (3);    --STATUS DE INTERCARD

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

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
SET OPTIMIZATION HIGH;
SET OPTIMIZATION ALL_ROWS;

LET scod_ret      = "000";
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

--scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa;


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
     LET scod_ret = "110";
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta;
  END IF




  -- Extrae las Tarjeta de Cheques
  FOREACH
     SELECT a.cuenta, a.num_tarjeta, a.numcte, a.status_tar, e.producto || " " || e.nombre,f.divisa || " " || f.descripcion,
            b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno, b.rfc,
            c.fecha_nac, tar.codstatustarjeta
       INTO s_cuenta, s_tarjeta, s_numcte,s_status, s_producto, s_divisa,
            s_nombre1,s_nombre2,s_paterno,s_materno,s_rfc,
            s_fechanac, s_codstatustarjeta
       FROM bdicheq:sc_tarjeta a,
            bdinteg:si_cliente b,
            bdinteg:si_ctepf c,
            bdicheq:sc_maechq d,
            bdicheq:sc_producto e,
            bdinteg:si_divisas f,
            intercard:tarjeta tar
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
            AND (a.num_tarjeta = tar.numtarjeta)

            AND ((a.empresa=pempresa)
--            AND (a.tipo_tarjeta='T')
            AND (d.status_cta = "1")
            AND (a.numcte=pnumcte)) order by a.num_tarjeta

     LET s_sistema = 1;

     LET v_cuantos = v_cuantos + 1;
     IF v_cuantos <= pregistros THEN
        CONTINUE FOREACH;
     END IF

     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta
            WITH RESUME;


  END FOREACH

  -- Extrae las Tarjeta de Credito
  FOREACH
SELECT a.num_credito, a.num_tarjeta, a.numcte, a.status_tar,  e.num_producto || " " || e.nombre_prod, f.divisa || " " || f.descripcion,
            b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno, b.rfc,
            c.fecha_nac, tar.codstatustarjeta
       INTO s_cuenta,  s_tarjeta, s_numcte,  s_status, s_producto, s_divisa,
            s_nombre1, s_nombre2, s_paterno, s_materno, s_rfc,
            s_fechanac, s_codstatustarjeta
       FROM bdicred:sd_maecred d,
            bdicred:sd_tarjeta a,
            bdinteg:si_cliente b,
            bdinteg:si_ctepf c,
            bdicred:sd_definicion e,
            bdinteg:si_divisas f,
            intercard:tarjeta tar
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
"Fecha : 16/Febrero/2011";

create procedure "informix".sp_refdirecciones_cjunk_pba(
                                    pempresa char(3),
                                    cTipo CHAR (1),
                                     pfuncion char(1),
                                     pnumcte char(20),
                                     psecuencia integer,
                                     ptipodir char(1),
                                     pcalle char(40),
                                     pcolonia char(60),
                                     pmunicipio char(5),
                                     pentre_calles char(40),
                                     ppais char(3),
                                     pentidad char(2),
                                     plocalidad char(3),
                                     pcodpostal char(5),
                                     ptipotel1 char(1),
                                     ptelefono1 char(13),
                                     ptipotel2 char(1),
                                     ptelefono2 char(13),
                                     ptipotel3 char(1),
                                     ptelefono3 char(13),
                                     pextension char(5),
                                     pestado_inegi char(2),
                                     pmunicipio_inegi char(3),
                                     plocalidad_inegi char(4),
                                     pnociudad smallint,
                                     pnoext char(10),
                                     pnoint char(10),
                                     pdepto char(6),
                                     pnocalle integer,
                                     pnocolonia integer,
                                     ppuntocar char(1),
                                     punihabi char(1),
                                     pmanz smallint,
                                     ppotros smallint,
                                     pandador smallint,
                                     petapa smallint,
                                     plote smallint,
                                     pedIF smallint,
                                     pentrada smallint,
                                     pobserva char(80),
                                     puser_insert char(8),
                                     pfecha_insert date,
                                     numcte_banco char(20))
 RETURNing char(5);

define v_codret char(5);
define v_rowid integer;
define v_tipodir char(1);
define v_calle char(40);
define v_colonia char(60);
define v_delegacion char(20);
define v_entre_calles char(40);
define v_pais char(3);
define v_entidad char(2);
define v_localidad char(3);
define v_codpostal char(5);
define v_telefono1 char(20);
define v_telefono2 char(20);
define v_estado_inegi char(2);
define v_municipio_inegi char(3);
define v_localidad_inegi char(4);
define v_fax char(20);
define v_nombre char(40);
define v_longitud, v_longcte, v_secuencia smallint;
define v_numcte char(20);
define v_existe char(1);
define v_sqlerr, v_isamerr integer;

--DOCUMENTACION:
--Realizó: Martha Aguirre
--Fecha: 31/01/2009
--Funcionalidad: Inserta en la tabla si_refdirecciones las direcciones de las referencias de los clientes solicitantes de Crédito
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Realizó: Rodolfo Tortolero Varela
--Fecha: 28/09/2011
--Funcionalidad: Cuando el cTipo = 0, Validar los campos para que no se inserten nulos.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

   --SET DEBUG FILE TO "/respaldosbd/Daniela/sp_refdirecciones_cjunk.out";
    --TRACE ON;
	
begin
	on exception set v_sqlerr, v_isamerr
		IF v_sqlerr != 0 then
			let v_codret=v_sqlerr;
			RETURN v_codret;
		END IF;
	END exception;

	let v_codret="000";
	let cTipo = cTipo;

	select numcte into v_numcte 
	from bdinteg:"informix".si_cliente
	where numcte = pnumcte;
	IF v_numcte is null then
		let v_codret = "104";
		RETURN v_codret;
	END IF

	IF pfuncion="A" then
	{
		select nombre into v_nombre
		from bdinteg:"informix".si_paises
		where pais = ppais;
		IF v_nombre is null then
			let v_codret="121";
			RETURN v_codret;
		END IF;

		select nombre into v_nombre
		from bdinteg:"informix".si_estados
		where pais=ppais and estado=pentidad;

		IF v_nombre is null then
			let v_codret="122";
			RETURN v_codret;
		END IF;

		select nombre into v_nombre
		from bdinteg:"informix".si_ciudades
		where pais=ppais and estado=pentidad and ciudad=plocalidad;
		IF v_nombre is null then
			let v_codret="123";
			RETURN v_codret;
		END IF;
	}
	 
		IF cTipo = '1' THEN 	
			
			UPDATE {+INDEX (si_refdirecciones idx_si_refdirecciones)} si_refdirecciones SET
				(calle,colonia,entre_calles,
				pais,estado,ciudad,municipio,cod_postal,apart_postal,
				estado_inegi,municipio_inegi,localidad_inegi,
				numerociudad,numeroextcalle,numerointcalle,departamento,
				numerocalle,numerocolonia,puntocardinal,unidadhabitac,
				manzana,otros,andador,etapa,lote,edIFicio,entrada,observaciones,
				user_insert,fecha_insert,numcte_banco) = 
				(NVL(pcalle,''), NVL(pcolonia,''), NVL(pentre_calles,''),
				NVL(ppais,''),NVL(pentidad,''),NVL(plocalidad,''), NVL(pmunicipio,''), NVL(pcodpostal,''),"",
				NVL(pestado_inegi,''),NVL(pmunicipio_inegi,''),NVL(plocalidad_inegi,''),
				NVL(pnociudad,0),NVL(pnoext,''),NVL(pnoint,''),NVL(pdepto,''),
				NVL(pnocalle,0),NVL(pnocolonia,0),NVL(ppuntocar,''),NVL(punihabi,''),
				NVL(pmanz,0),NVL(ppotros,0),NVL(pandador,0),NVL(petapa,0),NVL(plote,0),NVL(pedIF,0),NVL(pentrada,0),NVL(pobserva,''),
				NVL(puser_insert,''),pfecha_insert,NVL(numcte_banco,''))
			WHERE secuencia = psecuencia;
                          ---AND numcte = pnumcte;
			
		ELIF cTipo = '0' THEN 
			IF ptelefono1 <> '' THEN
				LET pTipoTel1 = 'P';
			END IF;

			IF ptelefono2 <> '' THEN
				LET pTipoTel2 = 'C';
			END IF;

			IF ptelefono3 <> '' THEN
				LET pTipoTel3 = 'O';
			END IF;

			--INSERT INTO bdinteg:"informix".si_refdirecciones
			--	(numcte,secuencia,tipo_dir,tipo_telef1,telefono1,tipo_telef2, telefono2,tipo_telef3, telefono3, extension)
			--VALUES
			--	(pnumcte,psecuencia,ptipodir,pTipoTel1,ptelefono1,pTipoTel2,ptelefono2,pTipoTel3,ptelefono3,pextension);

			INSERT INTO bdinteg:"informix".si_refdirecciones
				(numcte, secuencia, tipo_dir, calle, colonia, entre_calles,
				pais, estado, ciudad, municipio, cod_postal, apart_postal,
				tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3,
				extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, 
				numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
				puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, 
				entrada, observaciones, numcte_banco, user_insert, fecha_insert)
			VALUES
				(pnumcte, psecuencia, ptipodir, NVL(pcalle,''), NVL(pcolonia,''), NVL(pentre_calles,''), 
				NVL(ppais,''), NVL(pentidad,''), NVL(plocalidad,''), NVL(pmunicipio,''), NVL(pcodpostal,''), "", 
				pTipoTel1, ptelefono1, pTipoTel2, ptelefono2, pTipoTel3, ptelefono3, 
				pextension, NVL(pestado_inegi,''), NVL(pmunicipio_inegi,''), NVL(plocalidad_inegi,''), NVL(pnociudad,0), 
				NVL(pnoext,''), NVL(pnoint,''), NVL(pdepto,''), NVL(pnocalle,0), NVL(pnocolonia,0), NVL(ppuntocar,''), 
				NVL(punihabi,''), NVL(pmanz,0), NVL(ppotros,0), NVL(pandador,0), NVL(petapa,0), NVL(plote,0), NVL(pedIF,0), 
				NVL(pentrada,0), NVL(pobserva,''), NVL(numcte_banco,''), NVL(puser_insert,''), CURRENT);
			
			END IF;
		RETURN v_codret;
	END IF;
END;
END PROCEDURE;