CREATE PROCEDURE "informix".consedadcte(p_empresa     char(3),
                             p_numcte      char(20))
   RETURNING CHAR(5), CHAR(104), smallint;

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   DEFINE v_numcte            CHAR(20);
   DEFINE v_nomcte            CHAR(104);

   DEFINE v_ano_cte           SMALLINT;
   DEFINE v_edad	          SMALLINT;
   DEFINE v_fecha_hoy         DATE; 


	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "VerifCte1.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cod_ret = sql_err;
		RETURN  cod_ret,v_nomcte, v_edad;
	END EXCEPTION;


	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";


	LET v_numcte = '';
	LET v_nomcte = '';
	LET v_ano_cte =0;
	LET v_edad = 0;
	LEt v_fecha_hoy = date(1);
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	select fecha_hoy
	into v_fecha_hoy
	from bdinteg:si_fechas;

	SELECT NVL(trim(cli.apell_paterno),' ') || ' ' ||
          NVL(trim(cli.apell_materno),' ') || ' ' ||
          NVL(trim(cli.nombre1),' ') || ' ' ||
          NVL(trim(cli.nombre2),' ') nomcte,
		 case when month(fecha_nac) < month(v_fecha_hoy)
				then year(v_fecha_hoy) - year(fecha_nac)
				else case when month(fecha_nac) = month(v_fecha_hoy) and day(fecha_nac) <= day(v_fecha_hoy) 
					then year(v_fecha_hoy) - year(fecha_nac)
					else year(v_fecha_hoy) - year(fecha_nac) - 1 
     			end  
		 end edad
	INTO v_nomcte,v_edad
	FROM si_cliente cli,
          si_ctepf pf
    WHERE cli.empresa = p_empresa and
          pf.numcte = cli.numcte  AND
          cli.numcte =p_numcte;

    if v_nomcte is null then
		let cod_ret = "104";
		RETURN  cod_ret,v_nomcte, v_edad;
    end if

    RETURN  cod_ret,v_nomcte, v_edad;

END PROCEDURE

DOCUMENT
'SPL Extrae la Edad del Cliente',
"MODIFICO : Victor Luna",
"FECHA : 12/Febrero/2007",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : ",
"FECHA : 30/Marzo/2012",
"BD    : bdinteg",
"VER   : 1.2";

CREATE PROCEDURE "informix".consdireccionbenef(pEmpresa CHAR(3), pNumCliente CHAR(13), pNumCliBenef CHAR(13))
--DATOS A REGRESAR--
RETURNING CHAR(5),   -- Codigo de Retorno
          CHAR(104), -- Nombre Completo
          INTEGER,   -- Numero Calle
          CHAR(10),  -- Numero Exterior
          INTEGER,   -- Numero Colonia
          CHAR(3),   -- Numero Ciudad 
          SMALLINT,  -- Numero Ciudad
          CHAR(2),   -- Numero Estado
          CHAR(13),  -- Telefono 1
          CHAR(13);  -- Telefono 2
    
    --DEFINICION DE VARIABLES--
    DEFINE cCodRet		CHAR(5);
    DEFINE cTipCte      CHAR(1);
    DEFINE cDirExi      CHAR(2);
    DEFINE iMaxSec      INTEGER;
    DEFINE iNumCall     INTEGER;
    DEFINE cNumExt      CHAR(10);
    DEFINE iNumCol      INTEGER;
    DEFINE sNumCiu      SMALLINT;
    DEFINE cCiudad      CHAR(3);
    DEFINE iNumEdo      CHAR(2);
    DEFINE cTel1        CHAR(13);
    DEFINE cTel2        CHAR(13);
    DEFINE cNomComp     CHAR(104);
    DEFINE cNombre1     CHAR(26);
    DEFINE cNombre2     CHAR(26);
    DEFINE cApellPt     CHAR(26);
    DEFINE cApellMt     CHAR(26);
    DEFINE iSqlErr		INTEGER;
    
    --INICIALIZACIONES
    LET cCodRet = "000";
    LET cNumExt      = "";
    LET iNumCall      = 0;
    LET cNomComp     = "";
    LET iNumCol      = 0;
    LET sNumCiu      = 0;
    LET cCiudad      = "";
    LET iNumEdo      = "";
    LET cTel1        = "";
    LET cTel2        = "";
    LET cNombre1     = "";
    LET cNombre2     = "";
    LET cApellPt     = "";
    LET cApellMt     = "";
    LET iSqlErr      = 0;
    
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
    --- SET DEBUG FILE TO "/home/sysifx/adrianl/ConsDireccionBenef.out";    
    --- TRACE ON; 
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cNomComp, iNumCall, cNumExt, iNumCol, sNumCiu, cCiudad, iNumEdo, cTel1, cTel2;
        END IF;
    END EXCEPTION;

    SELECT tipo_cliente 
      INTO cTipCte 
      FROM bdinteg:si_cliente 
     WHERE numcte = pNumCliBenef;
     
    SELECT COUNT(*) 
      INTO cDirExi 
      FROM bdinteg:si_direcciones_actual 
     WHERE numcte = pNumCliBenef
     AND tipo_dir = '1'; 
    
    IF (cTipCte = "1") AND (cDirExi <> "0") OR (cTipCte = "2") AND (cDirExi <> "0") THEN
        SELECT {+ INDEX (bdinteg:si_direcciones_actual idx_diract_cte )} 
               cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, dir.numeroextcalle, dir.numerocalle, 
               dir.numerocolonia, dir.numerociudad, TRIM(dir.ciudad), dir.estado, nvl(tel1.telefono,''), nvl(tel2.telefono,'')
          INTO cNombre1, cNombre2, cApellPt, cApellMt, cNumExt, iNumCall, iNumCol, sNumCiu, cCiudad, iNumEdo, cTel1, cTel2
          FROM bdinteg:si_direcciones_actual dir 
         INNER JOIN bdinteg:si_cliente cte ON ( cte.numcte = dir.numcte )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
         WHERE dir.numcte = pNumCliBenef 
           and dir.tipo_dir = '1';  
                    
        LET cNomComp = TRIM(cNombre1) || ' ' || TRIM(cNombre2) || ' ' || TRIM(cApellPt) || ' ' || TRIM(cApellMt);

        --- LET cCodRet = "000";
        --- RETURN cCodRet, cNomComp, iNumCall, cNumExt, iNumCol, sNumCiu, cCiudad, iNumEdo, cTel1, cTel2;
    ELSE
        IF cTipCte = 1 OR  cTipCte = 2 THEN
            SELECT nombre1, nombre2, apell_paterno, apell_materno 
              INTO cNombre1, cNombre2, cApellPt, cApellMt
              FROM bdinteg:si_cliente 
             WHERE numcte = pNumCliBenef;

            LET cNomComp = TRIM(cNombre1) || ' ' || TRIM(cNombre2) || ' ' || TRIM(cApellPt) || ' ' || TRIM(cApellMt);

            SELECT {+ INDEX (bdinteg:si_direcciones_actual idx_diract_ctetpo )} 
                   dir.numeroextcalle, dir.numerocalle, dir.numerocolonia, dir.numerociudad, dir.ciudad, dir.estado, nvl(tel1.telefono,''), nvl(tel2.telefono,'')
              INTO cNumExt, iNumCall, iNumCol, sNumCiu, cCiudad, iNumEdo, cTel1, cTel2
              FROM bdinteg:si_direcciones_actual dir
              LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
              LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
             WHERE dir.numcte = pNumCliente 
               AND dir.tipo_dir = '1';

            LET cCodRet = "001";
            --- RETURN cCodRet, cNomComp, iNumCall, cNumExt, iNumCol, sNumCiu, cCiudad, iNumEdo, cTel1, cTel2;

        ELSE   
            SELECT nombre1, nombre2, apell_paterno, apell_materno
              INTO cNombre1, cNombre2, cApellPt, cApellMt
              FROM bdinteg:si_cliente 
             WHERE numcte = pNumCliBenef;

            LET cNomComp = TRIM(cNombre1) || ' ' || TRIM(cNombre2) || ' ' || TRIM(cApellPt) || ' ' || TRIM(cApellMt);

            LET iNumCall = 0;
            LET cNumExt = "";
            LET iNumCol = 0;
            LET sNumCiu = 0;
            LET cCiudad = "";
            LET iNumEdo = "";
            LET cTel1 = "";
            LET cTel2 = "";
            LET cCodRet = "002";
            --- RETURN cCodRet, cNomComp, iNumCall, cNumExt, iNumCol, sNumCiu, cCiudad, iNumEdo, cTel1, cTel2;
        END IF
    END IF
    
    RETURN cCodRet, TRIM(cNomComp), iNumCall, cNumExt, iNumCol, cCiudad, sNumCiu, iNumEdo, cTel1, cTel2;
    
    END
    
END PROCEDURE

DOCUMENT
'Modifico: Adrian Lara',
'Proyecto: BeneficiariosCONDUSEF',
'Solicito: Frank Gaxiola',
'Descripcion: Se crea procedimiento que obtiene las direcciones de los clientes tipo 1 y tipo 2,',
'si es tipo 1 y no tiene direccion se trae la del cliente titular',
'Fecha: 19/08/2010',
'Version: 20100827.0853',
'BD: bdinteg',
'MODIFICO: SERGIO FERNANDEZ',
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO QUE EN VEZ DE CONSULTAR DE SI_DIRECCIONES EL DOMICILIO LA CONSULTE DE SI_DIRECCIONES_ACTUAL',
'FECHA: OCTUBRE 2011',
'Fecha: 15/10/2013',
'MODIFICO: Leslie Rendón',
'DESCRIPCION: Se modifica para que obtenga la direccion del cliente titular', 
'en caso de no tener dirección el beneficiario como cliente tipo 2',
'Fecha: 10/06/2015',
'MODIFICO: Aarón Quiñonez',
'DESCRIPCION: Se modifica la consulta para que obtenga la direccion del cliente titular', 
'en caso de no tener dirección el beneficiario como cliente tipo 2';

CREATE PROCEDURE "informix".sp_actvalidacioncofetel ( cEmpresa CHAR(3),cNumCte CHAR(9), cFlagTelefonoCasa CHAR(1), cFlagTelefonoCelular CHAR(1),
                                                     cflagTelefonoOficina CHAR(1), cTipoDireccion CHAR(1))
    RETURNING CHAR(5);

    -- Definicion de Variables
    DEFINE cCodRet CHAR(5);
    DEFINE iSql_err INT;
    DEFINE iMaxSecuencia INT;

    -- Inicializa variables
     LET cCodRet = "00000";
     LET iSql_err = 0;
     LET iMaxSecuencia = 0;

    --SET debug FILE TO "/tmp/sp_actvalidacioncofetel.out";
    --trace ON;
	 
	-----------------------------------------
	--CREACION: Hector Bojorquez
	--FECHA: 2009-02-18
	--FUNCIONALIDAD: Actualiza un registro en la si_direcciones si el telefono 
	--                            proporcionado por el cliente en alta de la dirección fue 
	--                            validado por la COFETEL
	----------------------------------------
	 
    BEGIN
        ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;

        SET ISOLATION COMMITTED READ;

        SELECT max(secuencia) INTO iMaxSecuencia  from si_direcciones  WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion;

        IF cFlagTelefonoCasa = 1 AND cTipoDireccion = "1" THEN
            UPDATE si_direcciones SET ind_COFETELtel1 = "V" WHERE numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
        END IF;
		
		IF cFlagTelefonoCelular = 1 AND cTipoDireccion = "1" THEN
            UPDATE si_direcciones SET ind_COFETELtel2 = "V" WHERE numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
        END IF;

		IF cFlagTelefonoOficina = 1 AND cTipoDireccion = "2" THEN
            UPDATE si_direcciones SET ind_COFETELtel3 = "V" WHERE numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
        END IF;

        RETURN cCodRet;
    END;
END PROCEDURE;