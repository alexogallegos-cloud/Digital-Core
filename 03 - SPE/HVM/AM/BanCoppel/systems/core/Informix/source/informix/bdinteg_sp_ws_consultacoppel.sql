CREATE PROCEDURE "informix".sp_ws_consultacoppel (pTipo CHAR(1), -- 1 Consulta todos, 2 Grabar Datos
														  pNumcte CHAR(20),
														  pNombre CHAR(104),
														  pFechaNac CHAR(10),
														  pSituacion CHAR(1),
														  pCausa SMALLINT,
														  pTicket CHAR(20))

RETURNING 	CHAR(5)  AS cCodRet, CHAR(20) AS cNumCte, CHAR(1) AS cEmpresa, CHAR(4) AS cSucursal, CHAR(8) AS cEmpleado, CHAR(20) AS cTicket;


--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cNumCte 		CHAR(20);
DEFINE cEmpresa		CHAR(1);
DEFINE cSucursal	CHAR(4);
DEFINE cTicket		CHAR(20);
DEFINE cEmpleado	CHAR(8);


--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cNumCte 		= '';
LET cEmpresa 		= '';
LET cSucursal 		= '0002';
LET cTicket 		= '';
LET cEmpleado		= '';

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, '','','','','';
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/informix/cristo/sp_ws_empctes_coppel.out';
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;


	IF 	pTipo = '1' THEN-- Obtener los clientes o empleados a consultar en coppel
		FOREACH WITH HOLD

			SELECT {+AVOID_FULL("informix".si_huella_linea_resultado)} distinct(cliente),empresa, ticket
			INTO cNumCte,cEmpresa,cTicket
			FROM "informix".si_huella_linea_resultado
			where fecha=today
			and empresa = '4'
			and num_mensaje = '602'
			and nombre=''
			order by 1 asc


			SELECT {+AVOID("informix".si_huella_linea)} empleado INTO cEmpleado 
			FROM "informix".si_huella_linea WHERE ticket=cTicket AND status_consulta='3';

			RETURN cCodret , TRIM(cNumCte), TRIM(cEmpresa), TRIM(cSucursal),TRIM(cEmpleado),TRIM(cTicket) WITH RESUME;

		END FOREACH;

	ELIF pTipo = '2' THEN  -- Actualizar registro del cliente 
		IF ((pNumcte IS NULL OR pNumcte = '') OR (pNombre IS NULL OR pNombre = '')) THEN
			LET cCodRet = '00001'; --Valor de parametros nulos o no valido
		ELSE
			
			LET pNombre = replace(pNombre,'  ',' ');
			
			UPDATE "informix".si_huella_linea_resultado
			SET nombre = TRIM(pNombre), fecha_nac = TRIM(pFechaNac), situacion = TRIM(pSituacion), causa = pCausa
			WHERE ticket=pTicket and cliente=pNumcte and num_mensaje = '602' and fecha=today;

		END IF;

		RETURN cCodRet, '','','','','';
	ELSE
		LET cCodRet = '00002';	--Valor de parametro pTipo no valido
		RETURN cCodRet, '','','','','';
	END IF;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Obtiene los clientes coppel para ser evaluados por webservice wsBanCoppServ',
'permite registrar datos como son nombre, fecha de nacimiento y situacion especial del cliente',
'dentro de la tabla si_huella_linea_resultado, Se aplica replace de doble espacio',
'AUTOR : Cristo Lugo',
'FECHA : 30-04-2015',
'VERSION: 20150330',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_act_dirmovil(pCP CHAR(5), sNumCte CHAR(9))
RETURNING CHAR(5) AS CodRet, CHAR(3)as sPais, CHAR(2)as sEdo, CHAR(5)as sCiudad, CHAR (5) as sCP, CHAR(6)as sNumCiudad, CHAR(6)as sColonia, CHAR(5)as sMpo;
DEFINE iSqlErr 	    INTEGER;
DEFINE cCodRet 	    CHAR(5);
DEFINE sPais        CHAR(3);
DEFINE sEdo         CHAR(2);
DEFINE sCiudad      CHAR(5);
DEFINE sCP          CHAR(5);
DEFINE sNumCiudad   CHAR(6);
DEFINE sColonia     CHAR(6);
DEFINE sMpo         CHAR(5);
LET cCodRet 	 ='00000';
LET sPais        ='';
LET sEdo         ='';
LET sCiudad      ='';
LET sCP          ='';
LET sNumCiudad   ='';
LET sColonia     ='';
LET sMpo         ='00000';
BEGIN
-- ERRORES DE INFORMIX
ON EXCEPTION SET iSqlErr
	IF iSqlErr <> 0 THEN
		LET cCodRet = iSqlErr;
		RETURN cCodRet, sPais, sEdo, sCiudad, sCP, sNumCiudad, sColonia, sMpo;
	END IF;
END EXCEPTION;
 FOREACH
    SELECT limit 1 {+INDEX (bdinteg:si_ciudades ix_2363)}{+INDEX (bdinteg:si_catzonas idx_zona)}
           {+INDEX (bdinteg:si_estados inx_estado)} 
    b.pais, b.estado, b.ciudad, codigopostalzona, numerociudad, numerocolonia
    INTO sPais, sEdo, sCiudad, sCP, sNumCiudad, sColonia
    FROM bdinteg:si_catzonas a inner join bdinteg:si_ciudades b 
      on a.numerociudad=b.ciudad_coppel and a.numerociudad<>0 
    inner join bdinteg:si_estados c on b.estado=c.estado 
    WHERE codigopostalzona=pCP
 END FOREACH;
IF sEdo='09' THEN
    LET sMpo='00'||sCiudad;
END IF;

RETURN cCodRet, sPais, sEdo, sCiudad, sCP, sNumCiudad, sColonia, sMpo;
END 
END PROCEDURE;