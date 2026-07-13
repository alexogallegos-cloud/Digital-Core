CREATE PROCEDURE "informix".sp_altaclientehuellaadicional(p_empresa CHAR(3), p_NumCteTitular VARCHAR(20), p_NumCteAdicional VARCHAR(20), p_FlagAdic CHAR(1))
RETURNING
	CHAR(5), ---cod_ret
	INTEGER, ---Seguridad
	SMALLINT, ---Secuencia
	CHAR(1), ---Estado
	CHAR(942), ---DMapa
	CHAR(942), ---IMapa
	CHAR(8), ---Usuario
	CHAR(4), ---Sucursal
	CHAR(8), ---FechaA_lta
	CHAR(8), ---Usuario_Camb
	CHAR(8), ---Fecha_Camb
	INTEGER, ---# Cliente Coppell
	CHAR(1), ---FlagAdicional
	CHAR(1), ---Sexo
	INTEGER; ---TipoSensor

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
	DEFINE v_Seguridad			INTEGER;
	DEFINE v_Secuencia 			SMALLINT;
	DEFINE v_Estado 			CHAR(1);
	DEFINE v_DMapa 				CHAR(942);
	DEFINE v_IMapa 				CHAR(942);
	DEFINE v_Usuario 			CHAR(8);
	DEFINE v_Sucursal 			CHAR(4);
	DEFINE v_Fecha_Alta 		CHAR(8);
	DEFINE v_Usuario_Camb 		CHAR(8);
	DEFINE v_Fecha_Camb 		CHAR(8);
	DEFINE v_Cliente_Coppel 	INTEGER;
	DEFINE v_FlagAdicional 		CHAR(1);
	DEFINE v_Sexo 				CHAR(1);
	DEFINE v_TipoSensor 		INTEGER;
	
	SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
        RETURN v_cod_ret, v_Seguridad, v_Secuencia, v_Estado, v_DMapa, v_IMapa, v_Usuario, v_Sucursal, v_Fecha_Alta, v_Usuario_Camb, v_Fecha_Camb, v_Cliente_Coppel, v_FlagAdicional, v_Sexo, v_TipoSensor;
    END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_AltaClienteHuellaAdicional.out";
    --TRACE ON;

	LET v_cod_ret = '00000';
	LET v_Seguridad			= 0;
	LET v_Secuencia 		= 0;
	LET v_Estado 			= "";
	LET v_DMapa 			= "";
	LET v_IMapa 			= "";
	LET v_Usuario 			= "";
	LET v_Sucursal 			= "";
	LET v_Fecha_Alta 		= "";
	LET v_Usuario_Camb 		= "INFORMIX";
	LET v_Fecha_Camb 		= "19000101";
	LET v_Cliente_Coppel 	= 0;
	LET v_FlagAdicional 	= "";
	LET v_Sexo 				= "";
	LET v_TipoSensor 		= 0;

	IF (p_Empresa IS NULL OR p_Empresa = '')  OR  (p_NumCteTitular IS NULL OR p_NumCteTitular = '') OR  (p_NumCteAdicional IS NULL OR p_NumCteAdicional = '') THEN
		LET v_cod_ret = '001';
	ELSE
		SELECT numctecoppel
		INTO v_Cliente_Coppel
		FROM bdinteg:"informix".si_adiccoppel
		WHERE  numcte = p_NumCteTitular
		AND secuencia = 1;

		SELECT sexo
		INTO v_Sexo
		FROM bdinteg:"informix".si_ctepf
		WHERE  numcte = p_NumCteAdicional;

		SELECT estado, dmapa, imapa, usuario, sucursal, YEAR(fecha_alta) || LPAD(MONTH(fecha_alta),2,'0') || LPAD(DAY(fecha_alta),2,'0')
				, usuario_camb, YEAR(fecha_camb) || LPAD(MONTH(fecha_camb),2,'0') || LPAD(DAY(fecha_camb),2,'0'), 2
		INTO  v_Estado, v_DMapa, v_IMapa, v_Usuario, v_Sucursal, v_Fecha_Alta, v_Usuario_Camb, v_Fecha_Camb, v_TipoSensor
		FROM bdinteg:"informix".si_cte_huella
		WHERE  numcte = p_NumCteAdicional
		AND secuencia IN (SELECT MAX(secuencia) FROM bdinteg:"informix".si_cte_huella WHERE numcte = p_NumCteAdicional);
		
		SELECT MAX(secuencia +1)
		INTO v_Secuencia
		FROM bdinteg:"informix".si_adiccoppel
		WHERE  numctecoppel = v_Cliente_Coppel
		AND secuencia = 1;

		LET v_FlagAdicional = p_FlagAdic;
		LET v_Seguridad			= NVL(v_Seguridad,0);
		LET v_Secuencia 		= NVL(v_Secuencia,0);
		LET v_Estado 			= NVL(v_Estado,"");
		LET v_DMapa 			= NVL(v_DMapa,"");
		LET v_IMapa 			= NVL(v_IMapa,"");
		LET v_Usuario 			= NVL(v_Usuario,"");
		LET v_Sucursal 			= NVL(v_Sucursal,"");
		LET v_Fecha_Alta 		= NVL(v_Fecha_Alta,"");
		LET v_Usuario_Camb 		= NVL(v_Usuario_Camb,"INFORMIX");
		LET v_Fecha_Camb 		= NVL(v_Fecha_Camb,"19000101");
		LET v_Cliente_Coppel 	= NVL(v_Cliente_Coppel,0);
		LET v_FlagAdicional 	= NVL(v_FlagAdicional,"");
		LET v_Sexo 				= NVL(v_Sexo,"");
		LET v_TipoSensor 		= NVL(v_TipoSensor,0);
	END IF;

	RETURN v_cod_ret, v_Seguridad, v_Secuencia, v_Estado, v_DMapa, v_IMapa, v_Usuario, v_Sucursal, v_Fecha_Alta, v_Usuario_Camb, v_Fecha_Camb, v_Cliente_Coppel, v_FlagAdicional, v_Sexo, v_TipoSensor WITH RESUME;

END;
--##############################################################################
--## Procedimiento   : sp_AltaClienteHuellaAdicional
--## Base de Datos   : bdinteg
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Febrero de 2009
--##Descripcion :  Envia las huellas de los adicionales a Tiendas Coppel de clientes Coppel
--##############################################################################
END PROCEDURE;