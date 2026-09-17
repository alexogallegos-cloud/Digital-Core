CREATE PROCEDURE "informix".sp_nominadispersiondetalle_bei(pIdEmp CHAR(3), pFecDisp date, pTipoOpe char(1),psNombreArchivo CHAR(17),pRegistro smallint)
--valores a regresar
RETURNING   CHAR(5), CHAR(10), CHAR(30), CHAR(20), CHAR(30), CHAR (20), MONEY(16,2), CHAR(20), CHAR(4),
            CHAR(4), CHAR (50), CHAR(30),  INTEGER, INTEGER, CHAR(4);


	--****************************************************************************************************
	-- DESCRIPCION:  Obtiene los registros procesados y no procesados de nomina
	-- AUTOR : Francisco Rodriguez Ibarra
	-- FECHA : 26/08/2011
	-- BD: bdicheq
	-- SOLICITO :Mauricio Leon
	--
	-- DESCRIPCION:  Se agrego el filtrado por nombre de archivo y orden por numero de empleado
	-- AUTOR : Alfonso Antonio Cruz Alvarez
	-- FECHA : 07/01/2013
	-- BD: bdicheq
	-- SOLICITO :	Jose de Jesus Nevarez

	-- MODIFICACION: Cambio para que no busque por id de empresa en la tabla "sc_nominatransacciones"
    --                ya que esta tabla sufrio cambios en su estructuras y ya no se maneja por empresa sino por tipo de empresa.
	-- AUTOR : Berenice Noriega Guevara
	-- FECHA : 27/May/2014
	-- BD: bdicheq

	--***************************************************************************************************


	--Declaracion de variables
	DEFINE v_cNomArchivo	 CHAR(17);
	DEFINE  v_cCodRet        CHAR(5);
	DEFINE v_cNumEmp         CHAR(10);
	DEFINE v_cApellPaterno   CHAR(30);
	DEFINE v_cApellMaterno   CHAR(20);
	DEFINE v_cNombres        CHAR(30);
	DEFINE v_cCuentaAbono    CHAR(20);
	DEFINE v_mImporte        MONEY;
	DEFINE v_cConcepto       CHAR(30);
	DEFINE v_cStatus         CHAR(1);
	DEFINE v_cDescStatus     CHAR(30);
	DEFINE v_cNumCte         CHAR(20);
	DEFINE  v_cProducto      CHAR(4);
	DEFINE v_cTransaccion    CHAR(4);
	DEFINE v_cDesTransacc    CHAR(50);
	DEFINE v_iPagadas        INTEGER;
	DEFINE v_iNoPagadas      INTEGER;
	DEFINE v_iSqlErr         INTEGER;
	Define cEmpresa          Char(3);
	DEFINE v_cSucursal       CHAR(4);
	DEFINE cConcepto         CHAR(1);
	DEFINE  iCont  			 INTEGER;
	DEFINE  iContReg  		 INTEGER;
	DEFINE VTipEmpresa      SMALLINT; --para guardar el tipo de empresa


	
	---Inicializacion de variables
	LET v_cCodRet = "00000";
	LET v_cNomArchivo="";
	LET v_cNumEmp = "";
	LET v_cApellPaterno = "";
	LET v_cApellMaterno = "";
	LET v_cNombres = "";
	LET v_cCuentaAbono = "";
	LET  v_mImporte  = 0;
	LET  v_cConcepto  = "";
	LET  v_cStatus  = "";
	LET v_cDescStatus = "";
	LET v_cNumCte = "";
	LET  v_cProducto = "";
	LET v_cDesTransacc = "";
	LET  v_iPagadas  = 0;
	LET v_iNoPagadas = 0;
	LET  v_iSqlErr = 0;
	Let cEmpresa = '';
	LET v_cSucursal='';
	LET cConcepto = '';
	LET v_cTransaccion='';
	LET iCont=0;
	LET iContReg=0;
	LET VTipEmpresa=0;  --Para guardar el tipo de empresa


	BEGIN
    ON EXCEPTION SET v_iSqlErr
        IF v_iSqlErr <> 0 THEN
            LET v_cCodRet  = v_iSqlErr;
            RETURN  v_cCodRet, v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cNumCte,  v_cTransaccion,
                    v_cProducto, v_cDesTransacc,  v_cDescStatus, v_iPagadas, v_iNoPagadas, v_cSucursal;
        END IF;
    END EXCEPTION;
	
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ ;

	   IF (TRIM(NVL(pIdEmp,"")) = "") OR (TRIM(NVL(pTipoOpe,"")) = "") OR (TRIM(NVL(psNombreArchivo,"")) = "") THEN
	        LET  v_cCodRet  = "00001";
	        RETURN  v_cCodRet, v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cNumCte,  v_cTransaccion,
	                v_cProducto, v_cDesTransacc,  v_cDescStatus, v_iPagadas, v_iNoPagadas, v_cSucursal;
	   END IF;
	   
        --********************************************************************
        ---Sacar el tipo de empresa de la tabla sc_nominaempresas
            SELECT tipo_empresa 
            INTO VTipEmpresa
            FROM bdicheq:"informix".sc_nominaempresas
            WHERE codigo=pIdEmp;
       --*********************************************************************


	  		 IF pTipoOpe = '1' THEN --Nominas Procesadas

			  FOREACH

					SELECT SKIP pRegistro FIRST 10 
                    nommov.num_empleado, 
                    nommov.apell_paterno, 
                    nommov.apell_materno, 
                    nommov.nombres, 
                    nommov.cuenta_abono, 
                    nommov.importe,
                    NVL(nom.descripcion, ''), 
                    NVL(mae.num_cte, ''), 
                    NVL(mae.producto,'0'), 
                    NVL(transacc.descripcion, ''),
                    NVL(mae.sucursal,'0'), 
                    transacc.numero

					INTO  v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cDescStatus,  v_cNumCte, 
						  v_cProducto, v_cDesTransacc, v_cSucursal,v_cTransaccion

					FROM bdicheq:"informix".sc_nominamovimientoshist nommov,
						Outer bdicheq:"informix".sc_nominaestatus nom,
						Outer bdicheq:"informix".sc_maechq mae,
						bdinteg:"informix".si_transacc transacc,
						bdibpi:"informix".bpi_dispersarchivo dispersa


					WHERE  nom.cod_status  = nommov.status
					   AND nommov.cuenta_abono=mae.cuenta
					   AND transacc.numero = ( SELECT transacc FROM bdicheq:"informix".sc_nominatransacciones 
							WHERE tipo_transaccion = '001'  --Identificador del Abono		
							AND tipo_codigo = nommov.concepto
							AND tipo_empresa =VTipEmpresa )  ---SE CAMBIA DE IDEMPRESA A TIPO DE EMPRESA.-----
					   AND nom.tpo_status = 2   --Es el status de los movimientos
					   AND nommov.status = '1'

					   AND nommov.nombre_archivo =dispersa.nombre_archivo
                       AND  dispersa.f_dispersion = pFecDisp
					   AND dispersa.id_empresa = pIdEmp
					   AND  nommov.nombre_archivo = psNombreArchivo    --Filtrado por nombre de archivo
					   ORDER BY nommov.num_empleado
					--LET iContReg = iContReg + 1;

					LET iCont=1;
					RETURN  v_cCodRet, v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cNumCte,  v_cTransaccion,
							v_cProducto, v_cDesTransacc,  v_cDescStatus, v_iPagadas, v_iNoPagadas, v_cSucursal WITH RESUME;

			  END FOREACH;



		   ELIF pTipoOpe = '2' THEN --Nominas no procesadas

			  FOREACH

					   SELECT SKIP pRegistro FIRST 10 
                        nommov.num_empleado, 
                        nommov.apell_paterno, 
                        nommov.apell_materno, 
                        nommov.nombres, 
                        nommov.cuenta_abono, 
                        nommov.importe,

                        NVL(nom.descripcion, ''), 
                        NVL(mae.num_cte, ''), 
                        NVL(mae.producto,'0'), 
                        NVL(transacc.descripcion, ''),
                        NVL(mae.sucursal,'0'),
                        transacc.numero


						INTO  v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cDescStatus,  v_cNumCte,
						  v_cProducto, v_cDesTransacc, v_cSucursal,v_cTransaccion

					   FROM bdicheq:"informix".sc_nominamovimientoshist nommov,
						Outer bdicheq:"informix".sc_nominaestatus nom,
						Outer bdicheq:"informix".sc_maechq mae,
						bdinteg:"informix".si_transacc transacc,
						bdibpi:"informix".bpi_dispersarchivo dispersa

					   WHERE  nom.cod_status  = nommov.status
					   AND nommov.cuenta_abono=mae.cuenta
					   AND transacc.numero = ( SELECT transacc FROM bdicheq:"informix".sc_nominatransacciones 
							WHERE tipo_transaccion = '001'  --Identificador del Abono		
							AND tipo_codigo = nommov.concepto
							AND tipo_empresa =VTipEmpresa) ---SE CAMBIA DE IDEMPRESA A TIPO DE EMPRESA.-----
					   AND nom.tpo_status = 2   --Es el status de los movimientos
					   AND nommov.status > '1'
					   AND nommov.nombre_archivo =dispersa.nombre_archivo
                       AND  dispersa.f_dispersion = pFecDisp
					   AND dispersa.id_empresa = pIdEmp
					   AND  nommov.nombre_archivo = psNombreArchivo 	--Filtrado por nombre de archivo
						ORDER BY nommov.num_empleado
						
						LET iCont=1;
						RETURN  v_cCodRet, v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cNumCte,  v_cTransaccion,
							v_cProducto, v_cDesTransacc,  v_cDescStatus, v_iPagadas, v_iNoPagadas, v_cSucursal WITH RESUME;

			  END FOREACH;



		   ELIF pTipoOpe = '3' THEN --Nominas por procesar

			  FOREACH

                        SELECT SKIP pRegistro FIRST 10 
                        nommov.num_empleado, 
                        nommov.apell_paterno, 
                        nommov.apell_materno, 
                        nommov.nombres, 
                        nommov.cuenta_abono, 
                        nommov.importe,

                        NVL(nom.descripcion, ''), 
                        NVL(mae.num_cte, ''), 
                        NVL(mae.producto,'0'), 
                        NVL(transacc.descripcion, ''),
                        NVL(mae.sucursal,'0'),
                        transacc.numero
						
					   FROM bdicheq:"informix".sc_nominamovimientoshist nommov,
						Outer bdicheq:"informix".sc_nominaestatus nom,
						Outer bdicheq:"informix".sc_maechq mae,
						bdinteg:"informix".si_transacc transacc,
						bdibpi:"informix".bpi_dispersarchivo dispersa

					   WHERE  nom.cod_status  = nommov.status
					   AND nommov.cuenta_abono=mae.cuenta
					   AND transacc.numero = ( SELECT transacc FROM bdicheq:"informix".sc_nominatransacciones 
							WHERE tipo_transaccion = '001'  --Identificador del Abono		
							AND tipo_codigo = nommov.concepto
							AND tipo_empresa =VTipEmpresa) ---SE CAMBIA DE IDEMPRESA A TIPO DE EMPRESA.-----
					   AND nom.tpo_status = 2   --Es el status de los movimientos
					   AND nommov.status = '0'
					   AND nommov.nombre_archivo =dispersa.nombre_archivo
                       AND  dispersa.f_dispersion = pFecDisp
					   AND dispersa.id_empresa = pIdEmp
					   AND  nommov.nombre_archivo = psNombreArchivo 	--Filtrado por nombre de archivo

                       UNION

					   SELECT 
                        nommov.num_empleado, 
                        nommov.apell_paterno, 
                        nommov.apell_materno, 
                        nommov.nombres, 
                        nommov.cuenta_abono, 
                        nommov.importe,

                        NVL(nom.descripcion, ''), 
                        NVL(mae.num_cte, ''), 
                        NVL(mae.producto,'0'), 
                        NVL(transacc.descripcion, ''),
                        NVL(mae.sucursal,'0'),
                        transacc.numero


						INTO  v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cDescStatus,  v_cNumCte,
						  v_cProducto, v_cDesTransacc, v_cSucursal,v_cTransaccion

					   FROM bdicheq:"informix".sc_nominamovimientos_bpi nommov,
						Outer bdicheq:"informix".sc_nominaestatus nom,
						Outer bdicheq:"informix".sc_maechq mae,
						bdinteg:"informix".si_transacc transacc,
						bdibpi:"informix".bpi_dispersarchivo dispersa,
						bdicheq:"informix".sc_nominatransacciones nomtrans

					   WHERE  nom.cod_status  = nommov.status
					   AND nommov.cuenta_abono=mae.cuenta
					   AND transacc.numero = ( SELECT transacc FROM bdicheq:"informix".sc_nominatransacciones 
							WHERE tipo_transaccion = '001'  --Identificador del Abono		
							AND tipo_codigo = nommov.concepto
							AND tipo_empresa =VTipEmpresa) ---SE CAMBIA DE IDEMPRESA A TIPO DE EMPRESA.-----
					   AND nom.tpo_status = 2   --Es el status de los movimientos
					   AND nommov.status = '0'
					   AND nommov.nombre_archivo =dispersa.nombre_archivo
                       AND  dispersa.f_dispersion = pFecDisp
					   AND dispersa.id_empresa = pIdEmp
					   AND  nommov.nombre_archivo = psNombreArchivo 	--Filtrado por nombre de archivo
						ORDER BY nommov.num_empleado
						
						LET iCont=1;
						RETURN  v_cCodRet, v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cNumCte,  v_cTransaccion,
							v_cProducto, v_cDesTransacc,  v_cDescStatus, v_iPagadas, v_iNoPagadas, v_cSucursal WITH RESUME;

			  END FOREACH;
              
           ELIF pTipoOpe = '5' THEN --Canceladas

			  FOREACH

					   SELECT SKIP pRegistro FIRST 10 
                        nommov.num_empleado, 
                        nommov.apell_paterno, 
                        nommov.apell_materno, 
                        nommov.nombres, 
                        nommov.cuenta_abono, 
                        nommov.importe,

                        NVL(nom.descripcion, ''), 
                        NVL(mae.num_cte, ''), 
                        NVL(mae.producto,'0'), 
                        NVL(transacc.descripcion, ''),
                        NVL(mae.sucursal,'0'),
                        transacc.numero


						INTO  v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cDescStatus,  v_cNumCte,
						  v_cProducto, v_cDesTransacc, v_cSucursal,v_cTransaccion

					   FROM bdicheq:"informix".sc_nominamovimientoshist nommov,
						Outer bdicheq:"informix".sc_nominaestatus nom,
						Outer bdicheq:"informix".sc_maechq mae,
						bdinteg:"informix".si_transacc transacc,
						bdibpi:"informix".bpi_dispersarchivo dispersa,
                        bdicheq:"informix".sc_referencia_cancelacion cancelacion

					   WHERE  nom.cod_status  = nommov.status
					   AND nommov.cuenta_abono=mae.cuenta
					   AND transacc.numero = ( SELECT transacc FROM bdicheq:"informix".sc_nominatransacciones 
							WHERE tipo_transaccion = '001'  --Identificador del Abono		
							AND tipo_codigo = nommov.concepto
							AND tipo_empresa =VTipEmpresa) ---SE CAMBIA DE IDEMPRESA A TIPO DE EMPRESA.-----
					   AND nom.tpo_status = 2   --Es el status de los movimientos
					   AND nommov.status = '5'--Estatus Canceladas
					   AND nommov.nombre_archivo =dispersa.nombre_archivo
                       AND cancelacion.nombre_archivo = dispersa.nombre_archivo
                       AND cancelacion.fecha_cancelacion = pFecDisp					   
                       AND dispersa.id_empresa = pIdEmp
					   AND  nommov.nombre_archivo = psNombreArchivo 	--Filtrado por nombre de archivo
						ORDER BY nommov.num_empleado
						
						LET iCont=1;
						RETURN  v_cCodRet, v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cNumCte,  v_cTransaccion,
							v_cProducto, v_cDesTransacc,  v_cDescStatus, v_iPagadas, v_iNoPagadas, v_cSucursal WITH RESUME;

			  END FOREACH;
              
              
		   END IF;

		IF(iCont = 0) THEN
				LET v_cCodRet='00002';
				 RETURN  v_cCodRet, v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cNumCte,  v_cTransaccion,
	                v_cProducto, v_cDesTransacc,  v_cDescStatus, v_iPagadas, v_iNoPagadas, v_cSucursal;
		END IF;

	END;
END PROCEDURE;