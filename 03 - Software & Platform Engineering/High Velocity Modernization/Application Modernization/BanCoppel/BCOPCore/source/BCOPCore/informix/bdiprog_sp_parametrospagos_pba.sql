CREATE PROCEDURE "informix".sp_parametrospagos_pba (pEmpresa CHAR(3),pNumEmpleado CHAR(9))
	RETURNING CHAR(5),CHAR(2),CHAR(2),CHAR(100),CHAR(45),CHAR(30),DATE,CHAR(2);

	--Declaracion de variables
	DEFINE iSqlErr              INTEGER;
	DEFINE cCodRet              CHAR(5);
	DEFINE cLongitudCliente     CHAR(2);
	DEFINE cCodMonNac           CHAR(2);
	DEFINE cPathRep             CHAR(100);
	DEFINE cNombreUsuario       CHAR(45);
	DEFINE cNombreEmpresa       CHAR(30);
	DEFINE dFecha_Hoy           DATE;
	DEFINE cSistema             CHAR(2);

	--Crea el archivo de monitoreo del proceso
	--SET DEBUG FILE TO "/tmp/sp_ParametrosCheques.out";
	--TRACE ON;

	--inicializacion de  variables
	LET cCodRet= '00000';
	LET cLongitudCliente= '';
	LET cCodMonNac= '';
	LET cPathRep= '';
	LET cNombreUsuario= '';
	LET cNombreEmpresa = '';
	LET dFecha_Hoy = '';
	LET cSistema = '';

	BEGIN
	--Crea el control de errores
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;
			END IF;
		END EXCEPTION;

		--Obtengo el valor longitud del numero de cliente
		SELECT Trim(valor)
		INTO cLongitudCliente
		FROM bdinteg:si_param
		WHERE empresa = pEmpresa AND descripcion = ('longitud cliente');

		--Obtengo el valor codigo de la moneda nacional
		SELECT Trim(valor)
		INTO cCodMonNac
		FROM bdinteg:si_param
		WHERE empresa = pEmpresa AND descripcion = ('codigo mn');

		 --Obtengo el valor path de reportes
		SELECT Trim(desc_valor)
		INTO cPathRep
		FROM bdiprog:pp_parametros
		WHERE cve_param = ('104');

		--Obtengo el nombre del usuario o ejecutivo
		SELECT nombre
		INTO cNombreUsuario
		FROM bdinteg:si_ejecut
		WHERE ejecutivo = pNumEmpleado;

		-- Obtengo el nombre de la empresa
		SELECT razon_social
		INTO cNombreEmpresa
		FROM bdinteg:si_empresas
		WHERE empresa = pEmpresa;

		-- Obtengo Fecha de integral para la Captura de Parametros
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM bdicheq:sc_fechas;

		--Obtengo codigo del sistema
		SELECT sistema
		INTO cSistema
		FROM bdinteg:si_sistema
		WHERE siglas = 'PP';

		RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;

	END
	END PROCEDURE
	DOCUMENT
	'DESCRIPCION: Genera una consulta en las tablas si_param, si_ejecut,si_empresas,sc_fechas,si_sistema,pp_parametros',
	'tomando como parametro o dato de entrada, la empresa y el numero de empleado para obtener datos del empleado',
	'Solicito : Armando Mercado F.',
	'AUTOR: Armando Mercado F. ',
	'FECHA: Mayo 2009',
	'VERSION: 20090529',
	'BD: BDIPROG';

CREATE PROCEDURE "informix".sp_borrarcuentasfrecuentescad()
RETURNING VARCHAR(6),VARCHAR(80);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  v_dFecha_hoy     DATE;
DEFINE  v_dFecha_mas1    DATE;
DEFINE  v_dFecha_menos1  DATE;
DEFINE  v_cve_caducidad  VARCHAR(1);
DEFINE  v_fecha_movtos   DATE;
DEFINE  v_iCont1            INTEGER;
DEFINE  v_iCont2            INTEGER;
DEFINE  v_iCont3            INTEGER;
DEFINE  v_iCont4            INTEGER;
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;	  
	  INSERT INTO bdibpi:bpidocsbitacora VALUES('1006',current,P_COD_RET || " " || P_MENSAJE );
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

--***************************************************************************************************
--FECHA: 30/01/2013
--SOLICITO: ISMAEL HERNANDEZ
--MODIFICO: MANUEL OSUNA V.
--OBJETIVO: DAR DE BAJA LAS CUENTAS FRECUENTES QUE NO HAN REGISTRADO MOVIMIENTOS EN UN 
--          DETERMINADO PERIODO DE TIEMPO
--***************************************************************************************************		

   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';

   
   LET v_dFecha_hoy = date(current);   
   LET v_dFecha_mas1 = v_dFecha_hoy +  INTERVAL(1) YEAR TO YEAR;
   LET v_dFecha_menos1 = v_dFecha_hoy -  INTERVAL(1) YEAR TO YEAR; 
   LET v_iCont1 = 0;
   LET v_iCont2 = 0;
   LET v_iCont3 = 0;
   LET v_iCont4 = 0;
   
   
   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_borrarcuentasfrecuentescad.out";
	--TRACE ON;
	
   INSERT INTO bdibpi:bpidocsbitacora VALUES('1006',current,"INICIA PROCESO BAJA DE CUENTAS FRECUENTES");
  
  
	FOREACH frec_cursor WITH HOLD FOR
		SELECT cve_caducidad,fecha_movtos
		INTO v_cve_caducidad,v_fecha_movtos
		FROM bdiprog:"informix".pp_ctasterceros
		WHERE canal_alta = '03' AND cve_estado = '01' AND fecha_caducidad = v_dFecha_hoy and cve_caducidad in ('1','2','3','4')
		
		IF (v_fecha_movtos IS NOT NULL) THEN
		
			IF (v_cve_caducidad = '3' AND (v_fecha_movtos > v_dFecha_menos1 and v_fecha_movtos <= v_dFecha_hoy ))  THEN
				UPDATE bdiprog:"informix".pp_ctasterceros SET fecha_caducidad = v_dFecha_mas1 WHERE  CURRENT OF frec_cursor;
			ELSE			
				UPDATE bdiprog:"informix".pp_ctasterceros SET cve_estado = '02',canal_baja = '03',fecha_estado = v_dFecha_hoy WHERE  CURRENT OF frec_cursor;					
			
				IF   (v_cve_caducidad = '1' ) THEN LET v_iCont1 = v_iCont1 + 1;
				ELIF (v_cve_caducidad = '2' ) THEN LET v_iCont2 = v_iCont2 + 1;
				ELIF (v_cve_caducidad = '3' ) THEN LET v_iCont3 = v_iCont3 + 1;
				ELIF (v_cve_caducidad = '4' ) THEN LET v_iCont4 = v_iCont4 + 1;
				END IF
			
			END IF;
		
		END IF;
				
	END FOREACH;

  
   INSERT INTO bdibpi:"informix".bpidocsbitacora(id_operacion,fecha,descripcion) VALUES('1006',CURRENT, "TIPO 1 ELIMINADAS " ||  v_iCont1 || " CUENTAS FRECUENTES");
   INSERT INTO bdibpi:"informix".bpidocsbitacora(id_operacion,fecha,descripcion) VALUES('1006',CURRENT, "TIPO 2 ELIMINADAS " ||  v_iCont2 || " CUENTAS FRECUENTES");
   INSERT INTO bdibpi:"informix".bpidocsbitacora(id_operacion,fecha,descripcion) VALUES('1006',CURRENT, "TIPO 3 ELIMINADAS " ||  v_iCont3 || " CUENTAS FRECUENTES");
   INSERT INTO bdibpi:"informix".bpidocsbitacora(id_operacion,fecha,descripcion) VALUES('1006',CURRENT, "TIPO 4 ELIMINADAS " ||  v_iCont4 || " CUENTAS FRECUENTES");  
  
   
   INSERT INTO bdibpi:"informix".bpidocsbitacora VALUES('1006',current,"FINALIZA PROCESO BAJA DE CUENTAS FRECUENTES");

   RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;