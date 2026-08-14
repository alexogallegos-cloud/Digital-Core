CREATE PROCEDURE "informix".sp_reverso_promo
(
pNumCredito CHAR(20),
pFolioPromo	CHAR(16),
pTipoEjec	SMALLINT  -- 1-se ejecuta para reversar (se libera el retenido de los intereses y se actualliza el status a 5), 2-se ejecuta desde caja (cancelacion, se se libera el retenido y se borra de la promocion credito)
)
RETURNING
	CHAR(5)		AS cod_ret,
	CHAR(80) 	AS descripcion;

	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(5);
    DEFINE cMensajeRet		CHAR(80);
	DEFINE dIntereseIva		DECIMAL(18,2);
	DEFINE cnum_promo		CHAR(3);


	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '00000';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET dIntereseIva		= 0.00;
	LET cnum_promo			= '';


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/sp_reverso_promo.out';
	--TRACE ON;

	IF pTipoEjec = 1 THEN
		IF NVL(pNumCredito,'') = '' OR NVL(pFolioPromo,'') = '' THEN
			LET cCodRet = '00432';
			LET cMensajeRet = 'FALTAN UNO O MAS PARAMETROS';
			RETURN cCodRet, TRIM(cMensajeRet);
		--ELIF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_tarjeta WHERE num_credito = pNumCredito AND empresa = '001' AND tipo_tarjeta = 'T' AND status_tar = 'A') THEN
		ELIF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_promocion_credito WHERE num_credito = pNumCredito AND folio_movto = pFolioPromo AND status = 0) THEN
			LET cCodRet = '00448';
			LET cMensajeRet = 'NUMERO DE CREDITO NO ES VALIDO';
			RETURN cCodRet, TRIM(cMensajeRet);
		END IF

	END IF

	-- OBTIENE EL MONTO DE LOS INTERESES E IVA DE LA PROMOCION
   SELECT monto_int_iva, num_promo
	 INTO dIntereseIva, cnum_promo
	 FROM bdicred:"informix".sd_promocion_credito
	WHERE num_credito = pNumCredito
	  AND folio_movto = pFolioPromo
	  AND status = 0;
	-- SE VALIDA SI VIENE NULO
	LET dIntereseIva = NVL(dIntereseIva,0.0);
	-- OPCION PARA REVERSAR
	IF pTipoEjec = 1 THEN
	   UPDATE bdicred:"informix".sd_maeretenido
		  SET estatus = "S"
		WHERE empresa = '001'
		  AND num_credito = pNumCredito
		  AND folio_suc = pFolioPromo
		  AND fecha = fecha;
		-- LIBERA EL RETENIDO POR EL MONTO DE LOS INTERESES E IVA DE LA PROMOCION
	   UPDATE bdicred:"informix".sd_maesdos
		  SET sdo_retenido = sdo_retenido - dIntereseIva
		WHERE num_credito = pNumCredito
		  AND empresa = '001';
		-- ACTUALIZA LA PROMOCION CON ESTATUS DE REVERSADO
	   UPDATE bdicred:"informix".sd_promocion_credito
		  SET status = 5
		WHERE num_credito = pNumCredito
		  AND folio_movto = pFolioPromo;
		-- ACTUALIZA EL MOVIMIENTO DEL RETENIDO DE LOS INTERESES COMO REVERSADO
	   UPDATE bdicred:"informix".sd_movdia
		  SET reversado = "S"
		WHERE empresa = '001' 
          AND num_credito = pNumCredito
		  AND folio_suc = pFolioPromo
          AND codigo_fun = '002' AND codigo_ref = 45;       -- reversa movimiento de int e iva

	-- OPCION PARA EJECUTARSE DESDE CAJA Y HACER LA CANCELACION
	ELIF pTipoEjec = 2 THEN
		/*
		UPDATE bdicred:"informix".sd_maeretenido
		   SET estatus = "S"
		 WHERE empresa = '001'
		   AND num_credito = pNumCredito
		   AND folio_suc = pFolioPromo
		   AND fecha = fecha;
		-- LIBERA EL RETENIDO POR EL MONTO DE LOS INTERESES E IVA DE LA PROMOCION
  	   UPDATE bdicred:"informix".sd_maesdos
		  SET sdo_retenido = sdo_retenido - dIntereseIva
		WHERE num_credito = pNumCredito
		  AND empresa = '001';
		-- ACTUALIZA LA PROMOCION CON ESTATUS DE REVERSADO 
		--DELETE bdicred:"informix".sd_promocion_credito  FMV 12MAR14: Se omite codigo de borrado y se ajusta la actualizacion
	    --WHERE num_credito = pNumCredito
		--AND folio_suc = pFolioPromo;
       UPDATE bdicred:"informix".sd_promocion_credito 
          SET status = 5
        WHERE num_credito = pNumCredito
          AND folio_movto = pFolioPromo
          AND status = 0;

		-- ACTUALIZA EL MOVIMIENTO DEL RETENIDO DE LOS INTERESES COMO REVERSADO
		UPDATE bdicred:"informix".sd_movdia
		   SET reversado = "S"
		 WHERE empresa = '001' 
           AND num_credito = pNumCredito
		   AND folio_suc = pFolioPromo
           AND codigo_fun = '002' AND codigo_ref = 45;       -- reversa movimiento de int e iva
		*/
		IF TRIM(pFolioPromo) <> '' THEN
			INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',pNumCredito,'sp_reverso_promo-2',today ,CURRENT,'',cnum_promo, substr(pFolioPromo, 14, 3));
		END IF;

	END IF;

	RETURN cCodRet, TRIM(cMensajeRet);

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que realiza el reverso y la cancelacion de las promociones asi como la liberacion del saldo retenido de los intereses e iva',
'AUTOR: Mohamed Carreón ',
'FECHA DE CREACION: 08 de Febrero del 2012',
'DESCRIPCION MODIFICACION: Se cambia el proceso para agregar la actualización del movimiento del retenido de los intereses como reversado para el caso de promotoria y ventanilla',
'MODIFICO: Mohamed Carreón',
'VERSION: 20120607.1635',
'BD: bdicred';

CREATE PROCEDURE "informix".clientes_edocta_suc_crd_web(pempresa CHAR(3), pnum_credito CHAR(20), pfechahoy DATE)
RETURNING
CHAR(5),        -- Retorno
DATE,           -- Fecha Emision
CHAR(20),       -- Numero de Credito
CHAR(20),       -- Numero de Cliente
CHAR(20),       -- Numero de Tarjeta
CHAR(150),      -- Nombre de Cliente
CHAR(200),      -- Direccion Cliente
CHAR(120),      -- Direccion Colonia
CHAR(120),      -- Direccion
CHAR(120),      -- Estado Ciudad
CHAR(120),      -- Sucursal Nombre
CHAR(150),      -- Sucursal Gerente
CHAR(20),       -- Sucursal Tel
DATE,           -- Fecha Corte
CHAR(5),        -- Codigo Postal
CHAR(60),       -- Clave Cobranza
CHAR(13),       -- RFC
CHAR(47),       -- Clave Ruta
CHAR(40),       -- Entre Calles
CHAR(80),       -- Observaciones
DECIMAL (16,2), -- Saldo
CHAR(15),		--Status 
CHAR(20); 		--folio de cancelacion	

--------------------------------------------------------
--      VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
DEFINE cod_ret                          CHAR(5);
DEFINE sql_err                          INTEGER;
DEFINE v_cod_ret_otro                   CHAR(5);
DEFINE v_corta_linea_detalle            INTEGER;
DEFINE v_corta_linea_mensaje            INTEGER;
DEFINE v_periodo_anterior               DATE;                   --Fecha Periodo Anterior
DEFINE v_dias_periodo_tc                INTEGER;                --dias_periodo_tc
DEFINE v_periodo_tc_ini                 DATE;                   --periodo_tc_ini
DEFINE v_periodo_tc_fin                 DATE;                   --periodo_tc_fin

--------------------------------------------------------
--      VARIABLES GENERALES
--------------------------------------------------------
DEFINE v_sucursal          CHAR(4);         --Sucursal Cliente
DEFINE v_ult_dir_clie      INTEGER;         --Secuencia Ultima Direccion Cliente
--------------------------------------------------------
--      VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
DEFINE v_numcte            CHAR(20);        --Numero de Credito
DEFINE v_num_tarjeta       CHAR(20);        --Numero de Tarjeta
DEFINE v_nombre_cte        CHAR(150);       --Nombre del Cliente
DEFINE v_direccion_cn      CHAR(456);       --Direccion
DEFINE v_direccion_col     CHAR(376);       --Colonia
DEFINE v_direccion_del     CHAR(376);       --Delegacion O Municipio
DEFINE v_edo_cd            CHAR(376);       --Estado
DEFINE v_sucursal_nombre   CHAR(40);        --Nombre de la Sucursal
DEFINE v_sucursal_gerente  CHAR(40);        --Nombre del Gerente del Sucursal
DEFINE v_sucursal_tel      CHAR(14);        --Telefono de la Sucursal
DEFINE v_cod_postal        CHAR(5);         --Codigo Postal Direccion Cliente
DEFINE v_cl_cobra          CHAR(60);        --Clave de Cobranza
DEFINE v_rfc               CHAR(13);        --RFC del Cliente
DEFINE v_ruta              CHAR(47);        --Ruta
DEFINE v_entre_calles      CHAR(40);        --Entre Calles
DEFINE v_observaciones     CHAR(80);        --Datos Complementarios
DEFINE v_saldoactual       DECIMAL (16,2);  --Saldo disponible
DEFINE v_numerociudad      SMALLINT;        --Numero Ciudad Direccion Cliente
DEFINE v_numerocolonia     INT;             --Numero Colonia Direccion Cliente
DEFINE v_numerocalle       INT;             --Numero Calle Direccion Cliente
DEFINE v_numeroextcalle    CHAR(10);        --Numero Exterior Calle Direccion Cliente
DEFINE v_estado            CHAR(2);         --Numero Estado
DEFINE v_nombrecalle       CHAR(30);        --Nombre Calle Catalogo Calles
DEFINE v_centro            INT;             --Centro Catalogo de Zonas
DEFINE v_jefegrupozona     INT;             --Clave Jefe Grupo Zona
DEFINE v_supervisorzona    INT;             --Clave Supervisor Zona
DEFINE v_status_cred       CHAR(15);       --Estado de Credito
DEFINE v_folio_can		   CHAR(20);

--*******************************************************
--*******************************************************
--*******************************************************

--------------------------------------------------------
--      VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
LET cod_ret = "00000";
LET v_cod_ret_otro = "00000";

LET sql_err = "";
LET v_corta_linea_detalle       = 30;
LET v_corta_linea_mensaje       = 100;

LET v_periodo_anterior          = " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc           = 0;    --dias_periodo_tc

LET v_periodo_tc_ini            = " ";  --periodo_tc_ini
LET v_periodo_tc_fin            = " ";  --periodo_tc_fin

--------------------------------------------------------
--      VARIABLES GENERALES
--------------------------------------------------------
LET v_sucursal      = "";
LET v_ult_dir_clie      = 0;
--------------------------------------------------------
--      VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET v_numcte            = "";
LET v_num_tarjeta       = "";
LET v_nombre_cte        = "";
LET v_direccion_cn      = "";
LET v_direccion_col     = "";
LET v_direccion_del     = "";
LET v_edo_cd            = "";
LET v_sucursal_nombre   = "";
LET v_sucursal_gerente  = "";
LET v_sucursal_tel      = "";
LET v_cod_postal        = "";
LET v_cl_cobra          = "";
LET v_rfc               = "";
LET v_ruta              = "";
LET v_entre_calles      = "";
LET v_observaciones     = "";
LET v_saldoactual       = 0;
LET v_numerociudad      = 0;
LET v_numerocolonia     = 0;
LET v_numerocalle       = 0;
LET v_numeroextcalle    = "";
LET v_estado            = "";
LET v_nombrecalle       = "";
LET v_centro            = 0;
LET v_jefegrupozona     = 0;
LET v_supervisorzona    = 0;

LET v_status_cred = "";
LET v_folio_can = "";


BEGIN

        ON EXCEPTION SET sql_err
        LET cod_ret = sql_err;

                RETURN cod_ret, pfechahoy, NVL(pnum_credito,""), NVL(v_numcte,""),
                NVL(v_num_tarjeta,""), NVL(v_nombre_cte,""), NVL(v_direccion_cn,""),
                NVL(v_direccion_col,""), NVL(v_direccion_del,""), NVL(v_edo_cd,""),
                NVL(v_sucursal_nombre,""), NVL(v_sucursal_gerente,""), NVL(v_sucursal_tel,""),
                pfechahoy, NVL(v_cod_postal,""), NVL(v_cl_cobra,""),
                NVL(v_rfc,""), NVL(v_ruta,""), NVL(v_entre_calles,""),
                NVL(v_observaciones,""), v_saldoactual,v_status_cred,v_folio_can;
        END EXCEPTION ;
		
	--SET DEBUG FILE TO "/home/tmp/jairo/sp_consultanombre_serv_edoctaelec.out";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
		
		

 --##############################################################
          --##    GENERACION ENCABEZADO EDO CUENTA  ##
 --##############################################################
    -------------------------------------------------------------
    --SD_MAECRED
    -------------------------------------------------------------
        SELECT a.numcte, a.sucursal
        INTO v_numcte, v_sucursal
        FROM bdicred:"informix".sd_maecredcrd a
        WHERE a.empresa = pempresa
        AND a.num_credito = pnum_credito;
    -------------------------------------------------------------
    --SD_TARJETA
    -------------------------------------------------------------
        SELECT b.num_tarjeta INTO v_num_tarjeta
        FROM bdicred:"informix".sd_tarjeta b
        WHERE b.empresa = pempresa
                AND b.num_credito = pnum_credito
                AND b.tipo_tarjeta = "T" AND b.status_tar = "A";

        IF v_num_tarjeta IS NULL THEN
            -------------------------------------------------------------
                --SD_TARJETA
            -------------------------------------------------------------
                SELECT MAX(secuencia)
                        INTO v_ult_dir_clie
                FROM bdicred:"informix".sd_tarjeta
                WHERE empresa = pempresa
                        AND num_credito = pnum_credito
                        AND tipo_tarjeta="T";

            -------------------------------------------------------------
                --SD_TARJETA
            -------------------------------------------------------------
                SELECT b.num_tarjeta INTO v_num_tarjeta
                FROM bdicred:"informix".sd_tarjeta b
                WHERE b.empresa = pempresa
                    AND b.num_credito = pnum_credito
                    AND b.secuencia = v_ult_dir_clie;

        END IF
    -------------------------------------------------------------
        --SI_DIRECCIONES
    -------------------------------------------------------------
        SELECT MAX(secuencia) INTO v_ult_dir_clie
        FROM bdinteg:"informix".si_direcciones
                WHERE numcte = v_numcte
                AND tipo_dir="1";
    -------------------------------------------------------------
        --SI_CLIENTE
    -------------------------------------------------------------
        SELECT Trim(a.nombre1) || " " ||Trim(a.nombre2) || " " ||
                   Trim(a.apell_paterno) || " " ||Trim(a.apell_materno),
               a.rfc
        INTO    v_nombre_cte,
                        v_rfc
        FROM bdinteg:"informix".si_cliente a
        WHERE a.numcte = v_numcte;
    -------------------------------------------------------------
        --SI_DIRECCIONES
    -------------------------------------------------------------
        SELECT Trim(b.numeroextcalle) || " " || Trim(b.numerointcalle),
               b.cod_postal,                    b.entre_calles,
               b.observaciones,                 b.numerociudad,
               b.numerocolonia,                 b.numerocalle,
               b.numeroextcalle,                b.estado
        INTO v_direccion_cn,
                   v_cod_postal,                v_entre_calles,
                   v_observaciones,             v_numerociudad,
                   v_numerocolonia,             v_numerocalle,
                   v_numeroextcalle,            v_estado
        FROM bdinteg:"informix".si_direcciones b
        WHERE b.numcte  = v_numcte AND secuencia = v_ult_dir_clie;
    -------------------------------------------------------------
        --SI_CATCALLES
    -------------------------------------------------------------
        SELECT Trim(c.nombrecalle)
        INTO v_nombrecalle
        FROM bdinteg:"informix".si_catcalles c
        WHERE c.numerocalle = v_numerocalle;
    -------------------------------------------------------------
        --SI_CATZONAS
    -------------------------------------------------------------
        SELECT  d.nombrezona,                    d.centro,
                d.jefegrupozona,                 d.supervisorzona
        INTO    v_direccion_col,                 v_centro,
                v_jefegrupozona,                 v_supervisorzona
        FROM bdinteg:"informix".si_catzonas d
        WHERE  d.numerociudad = v_numerociudad
        AND  d.numerocolonia=v_numerocolonia;
    -------------------------------------------------------------
        --SI_CATCIUDADES
    -------------------------------------------------------------
        SELECT e.nombreciudad
        INTO v_direccion_del
        FROM bdinteg:"informix".si_catciudades e
        WHERE e.numerociudad = v_numerociudad;
    -------------------------------------------------------------
        --SI_ESTADOS
    -------------------------------------------------------------
        SELECT f.nombre
        INTO v_edo_cd
        FROM bdinteg:"informix".si_estados f
        WHERE  f.estado = v_estado;
    -------------------------------------------------------------
        --SI_SUCURSALES
    -------------------------------------------------------------
        SELECT d.nombre, d.gerente, d.telefono1
        INTO v_sucursal_nombre, v_sucursal_gerente, v_sucursal_tel
        FROM bdinteg:"informix".si_sucursales d
        WHERE d.empresa = pempresa
        AND   d.sucursal    = v_sucursal;
        --------------------------------------------------------
             --SD_MAESDOS
        --------------------------------------------------------
        SELECT sdo_cap_insoluto
        INTO v_saldoactual
        FROM bdicred:"informix".sd_maesdoscrd
        WHERE num_credito = pnum_credito;
        --------------------------------------------------------
			 --SD_MAECRED
		--------------------------------------------------------
		SELECT 
		(CASE status_cred 
		WHEN 'FF'THEN 'CANCELADO'
		WHEN 'FC' THEN 'REESTRUCTURADO'
		WHEN 'CV' THEN 'VENDIDO'
		ELSE 'ACTIVO'
		END) INTO v_status_cred
		FROM bdicred:"informix".sd_maecredcrd
		WHERE num_credito = pnum_credito;
		--------------------------------------------------------
			--SD_CRED_CAN
		--------------------------------------------------------	
		IF v_status_cred ='CANCELADO' THEN 
			
			SELECT limit 1 folio_cancelacion
			INTO v_folio_can 
			FROM bdicred:"informix".sd_cred_can
			WHERE num_credito = pnum_credito
			AND folio_cancelacion <>'';
 			
			END IF;
		--------------------------------------------------------
		
		
		
		--------------------------------------------------------
		LET v_direccion_cn = v_nombrecalle || v_direccion_cn;
        LET v_ruta = LPAD(v_numerociudad,4,'0')||"/"||
                             LPAD(v_centro,6,'0')||"/"||
                             LPAD(v_jefegrupozona,8,'0')||"/"||
                             LPAD(v_supervisorzona,8,'0')||"/"||
                             LPAD(v_numerocolonia,4,'0')||"/"||
                             LPAD(v_numerocalle,6,'0')||"/"||
                             LPAD(TRIM(v_numeroextcalle),5,'0');
        --------------------------------------------------------
        --------------------------------------------------------
        --------------------------------------------------------

          RETURN cod_ret, pfechahoy, NVL(pnum_credito,""), NVL(v_numcte,""),
                NVL(v_num_tarjeta,""), NVL(v_nombre_cte,""), NVL(v_direccion_cn,""),
                NVL(v_direccion_col,""), NVL(v_direccion_del,""), NVL(v_edo_cd,""),
                NVL(v_sucursal_nombre,""), NVL(v_sucursal_gerente,""), NVL(v_sucursal_tel,""),
                pfechahoy, NVL(v_cod_postal,""), NVL(v_cl_cobra,""),
                NVL(v_rfc,""), NVL(v_ruta,""), NVL(v_entre_calles,""),
                NVL(v_observaciones,""), v_saldoactual,v_status_cred,v_folio_can;

END;

END PROCEDURE
DOCUMENT "Version 1.00.000",
"Se crea procedimiento para consulta de movimientos de prestamo personal, credinomina y reestructura",
"Responsable : Jairo Valdez Gonzalez.",
"Fecha : 19-08-2014",
"BD: bdicred";

CREATE PROCEDURE "informix".consctapornomcte_web(pEmpresa CHAR(3),
							 pPatTit CHAR(26), pMatTit CHAR(26), pNom1Tit CHAR(26), pNom2Tit CHAR(26),
							 pPatFir CHAR(26), pMatFir CHAR(26), pNom1Fir CHAR(26), pNom2Fir CHAR(26))

	RETURNING
	CHAR(5),  -- Codigo de retorno
	CHAR(20), -- Numero de cuenta
	CHAR(20); -- Numero de cliene

	DEFINE v_cod_ret char(5);
	DEFINE v_ciclo  smallint;
	DEFINE v_numcte char(20);
	DEFINE v_cuenta char (20);
	DEFINE v_fcuenta char (20);

	LET v_cod_ret  = "00000";
	LET v_ciclo    = 0;
	LET v_numcte   = "";
	LET v_cuenta   = "";
	LET v_fcuenta  = "";


	IF pPatFir = "" AND  pNom1Fir = "" THEN
		FOREACH
			SELECT
				 a.numcte, b.num_credito
			INTO
				v_numcte, v_cuenta
			FROM
				bdinteg:si_cliente a,
				bdicred:sd_maecred b
			WHERE
				a.empresa = pEmpresa AND
				a.apell_paterno = pPatTit AND
				a.apell_materno = pMatTit AND
				a.nombre1 = pNom1Tit AND
				a.nombre2 = pNom2Tit AND
				a.numcte = b.numcte
			ORDER BY
				b.num_credito

			IF NOT v_cuenta IS NULL THEN
				LET v_ciclo = v_ciclo + 1;

				RETURN v_cod_ret, v_cuenta, v_numcte WITH RESUME;
			END IF
		END FOREACH;
	ELSE
		FOREACH
			SELECT
				b.num_credito
			INTO
				v_cuenta
			FROM
				bdinteg:si_cliente a,
				bdicred:sd_maecred b
			WHERE
				a.empresa = pEmpresa AND
				a.apell_paterno = pPatTit AND
				a.apell_materno = pMatTit AND
				a.nombre1 = pNom1Tit AND
				a.nombre2 = pNom2Tit AND
				a.numcte = b.numcte
			ORDER BY
				b.num_credito
      			

			SELECT
				s.numcte, f.num_credito
			INTO
				v_numcte, v_fcuenta
			FROM
				bdinteg:si_cliente s,
				bdicred:sd_tarjeta f
			WHERE
				s.apell_paterno = pPatFir AND
				s.apell_materno = pMatFir AND
				s.nombre1 = pNom1Fir AND
				s.nombre2 = pNom2Fir AND
				s.numcte = f.numcte AND
				f.secuencia in (select max(secuencia) from bdicred:sd_tarjeta  where num_credito = v_cuenta) and
				f.num_credito = v_cuenta;
				

			IF v_fcuenta <> "" THEN
				LET v_ciclo = v_ciclo + 1;

				RETURN v_cod_ret, v_fcuenta, v_numcte WITH RESUME;
			END IF
		END FOREACH;
	END IF

	IF  v_ciclo = 0 THEN
		RETURN "00101", "", "";
	END IF

end procedure
                                                                                                                                                                                                                ;