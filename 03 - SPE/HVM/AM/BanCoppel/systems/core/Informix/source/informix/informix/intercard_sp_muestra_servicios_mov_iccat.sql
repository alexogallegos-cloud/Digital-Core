CREATE PROCEDURE "informix".sp_muestra_servicios_mov_iccat(pEmpresa CHAR(3),pNumCte CHAR(9),pNumCel CHAR(10))
	RETURNING	CHAR(9) AS CodRet,
				CHAR(100) AS NombreServicio,
				CHAR(10) AS Estatus,
				CHAR(50) AS imei,
				CHAR(50) AS udid;
	

	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetorno		CHAR(9);
	DEFINE cNombreServicio	CHAR(100);
	DEFINE cEstatus		CHAR(10);
	DEFINE cImei		CHAR(50);
	DEFINE cUdid		CHAR(50);
	DEFINE cNumCte		CHAR(9);
	 
	LET iSqlErr				= 0;
	LET cCodRetorno			= '000000000';
	LET cNombreServicio		= '';
	LET cEstatus 			= '';
	LET cImei 				= '';
	LET cUdid 				= '';
	LET cNumCte 			= '';
	
	 
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/informix/tmp/sp_muestra_servicios_mov_iccat.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRetorno = iSqlErr;
				LET cNombreServicio = 'ERROR';
				RETURN cCodRetorno,cNombreServicio,cEstatus,cImei,cUdid;
			END IF;
		END EXCEPTION;	
	
		IF pEmpresa = '' OR pNumCte = '' OR pNumCel = '' THEN
		
			LET cCodRetorno = '000000002';
		
			RETURN cCodRetorno,cNombreServicio,cEstatus,cImei,cUdid;
		
		ELSE
			--Consulta servicio BanCoppel Mpvil
			LET cNombreServicio = 'BanCoppel Movil';
			
			SELECT num_cliente
			INTO cNumCte
			FROM bdibpi:"informix".bpi_reg_dispo_apps 
			WHERE num_cliente = pNumCte AND no_celular = pNumCel AND dispo_act = '1';
			
			IF cNumCte <> '' THEN
				LET cEstatus = 'ACTIVO';
			ELSE
				LET cEstatus = 'INACTIVO';
			END IF;
			LET cNumCte = '';
			RETURN cCodRetorno,cNombreServicio,cEstatus,cImei,cUdid WITH RESUME;
			
			
			--Consulta servicio BanCoppel Express
			LET cNombreServicio = 'BanCoppel Express';
			
			SELECT num_cliente, imei, udid 
			INTO cNumCte, cImei, cUdid
			FROM bdibpi:"informix".bpi_registro_bex 
			WHERE num_cliente = pNumCte 
			AND no_celular = pNumCel AND servicio = 'activo';
			
			IF cNumCte <> '' THEN
				LET cEstatus = 'ACTIVO';
			ELSE
				LET cEstatus = 'INACTIVO';
				LET cImei = '';
				LET cUdid = '';
			END IF;
			RETURN cCodRetorno,cNombreServicio,cEstatus,cImei,cUdid WITH RESUME;
			LET cImei = '';
			LET cUdid = '';
			LET cNumCte = '';
			
			--Consulta servicio Token Digital
			LET cNombreServicio = 'Token Digital';
			
			SELECT num_cliente
			INTO cNumCte
			FROM bdinteg:"informix".si_bpitoken
			WHERE num_cliente = pNumCte  
			AND id_status_token = 140
			AND tipo_token = 2;
			
			IF cNumCte <> '' THEN
				LET cEstatus = 'ACTIVO';
			ELSE
				LET cEstatus = 'INACTIVO';
				LET cImei = '';
				LET cUdid = '';
			END IF;
			RETURN cCodRetorno,cNombreServicio,cEstatus,cImei,cUdid WITH RESUME;
			LET cImei = '';
			LET cUdid = '';
			LET cNumCte = '';
			
			--Consulta servicio CVV2 Dinamico (Compras en Linea)
			LET cNombreServicio = 'CVV2 Dinamico (Compras en Linea)';
			
			SELECT tar.numcliente
			INTO cNumCte
			FROM intercard:"informix".tarjeta tar, intercard:"informix".tarjeta_indicadores tarind
			WHERE tar.numcliente = pNumCte
			AND tar.codstatustarjeta = 'ACT'
			AND tar.titular = 'T'
			AND tarind.cvv2dinamico = 'V'
			AND tar.numtarjeta = tarind.numtarjeta;
			
			IF cNumCte <> '' THEN			
				LET cEstatus = 'ACTIVO';
			ELSE
				LET cEstatus = 'INACTIVO';
			END IF;
			RETURN cCodRetorno,cNombreServicio,cEstatus,cImei,cUdid WITH RESUME;
			
		END IF;
		
	END;
END PROCEDURE
DOCUMENT
'FOLIO: 437 ICCAT - CVV2 DINAMICO - Adendum',
'AUTOR: Juan Pablo Soto',
'FECHA: 11/05/2018',
'SE CREA PROCEDIMIENTO PARA VALIDAR Y MOSTRAR LOS SERVICIOS MÓVILES ACTIVOS DEL CLIENTE.',
'DB: INTERCARD';

CREATE PROCEDURE "informix".sp_inventariotarjetas (pEmpresa CHAR(3), pSucursal CHAR(4),pRegistro INTEGER)
	--DATOS A REGRESAR
	RETURNING  
	CHAR(5) AS cCodRet,
	CHAR(3) AS cEmpresa,
	CHAR(4) AS cSucursal,
	CHAR(16) AS cTarjeta,
	INTEGER AS iLote,
	CHAR(20) AS cStatusTarjeta1,
	INTEGER AS iTipoTarjeta1;
--========== DEFINIR VARIABLES =======
	DEFINE iSqlErr SMALLINT;
	DEFINE iSamErr SMALLINT;
	DEFINE cErrorInfo CHAR(40);
	DEFINE cCodRet CHAR(5);
	DEFINE cEmpresa CHAR(3);
	DEFINE cSucursal CHAR(4);
	DEFINE cTarjeta CHAR(16);
	DEFINE iLote INTEGER;
	DEFINE cStatusTarjeta CHAR(20);
	DEFINE iTipoTarjeta INTEGER;
	DEFINE cSuc VARCHAR(5);
--============= INICIALIZA VARIABLES ============
	LET iSqlErr = 0;
	LET iSamErr = 0;
	LET cErrorInfo = '';
	LET cCodRet = '00000';
	LET cEmpresa = '';
	LET cSucursal = '';
	LET cTarjeta = '';
	LET iLote = 0;
	LET cStatusTarjeta = '';
	LET iTipoTarjeta = 0;	
	LET cSuc = '';
--============= TRAER CLIENTES ===================
BEGIN
	ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
		LET cCodRet = iSqlErr;
		RETURN  cCodRet,cEmpresa,cSucursal,cTarjeta,iLote,cStatusTarjeta,iTipoTarjeta;
	END EXCEPTION;

	-- SET DEBUG FILE TO "/respaldosbd/Judith/sp_inventariotarjetas.out";
	--TRACE ON;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF TRIM(NVL(pEmpresa,'')) = '' Or TRIM(NVL(pSucursal,'')) = '' THEN
			LET cCodRet = '00001';
			RETURN  cCodRet,cEmpresa,cSucursal,cTarjeta,iLote,cStatusTarjeta,iTipoTarjeta;			
	
		ELSE
			LET cSuc = LPAD(pSucursal,5,'0'); 

			FOREACH 
				SELECT SKIP	pRegistro a.tt_empresa,SUBSTR(a.tt_sucursal,2), a.tt_numerotarjeta, a.tt_numerolote,0,CASE WHEN c.tipo = 'D' THEN 1 ELSE 2 END 
				INTO cEmpresa, cSucursal, CTarjeta,iLote, CstatusTarjeta, iTipoTarjeta
				FROM intercard:"informix".control_inventario a
				--INNER JOIN intercard:"informix".tipotarjeta c ON (c.clave_tipotarjeta = a.tt_tipotarjeta)
				INNER JOIN intercard:"informix".lote l ON (l.numerolote =  a.tt_numerolote)
				INNER JOIN intercard:"informix".tipotarjeta c ON (c.clave_tipotarjeta = l.clave_tipotarjeta)
				WHERE a.tt_sucursal = cSuc AND a.tt_numerotarjeta > '' AND a.tt_numerolote > 0 
				AND tt_statustarjeta = 'INA' AND a.tt_empresa = pEmpresa

				RETURN  cCodRet,cEmpresa,cSucursal,cTarjeta,iLote,cStatusTarjeta,iTipoTarjeta WITH RESUME;
			END FOREACH;
		END IF;
END;
END PROCEDURE
DOCUMENT
'Folio: 383 - Control y Registro de Tarjetas en Sucursal',
'Autor: 97893323 - Judith Moreno',
'BD: intercard',
'Solicita:	Abraham Narvaez',
'Fecha: 21/03/2018',
'Descripcion: Se crea procedimiento para obtener los datos de la tabla control_inventario de la base de datos intercard',
'---------------------------------------------------------------------------------------------------------------------------------------',
'Folio: 448 -  Enmascarar el numero de tarjeta para el proyecto Control y registro de tarjetas en sucursal',
'Autor: 97893323 Judith Moreno',
'BD: intercard',
'Solicita:	Abraham Narvaez',
'Fecha: 17/07/2018',
'Descripcion: Se modifica por que el cliente solicito unos cambios para bajar el costo del procedimiento se agrega un LPAD ya que la sucursal en esa',
'tabla es de 5 caracteres, además se modifica el tipo tarjeta para cuando sea D sea 1 y si no un 2';

CREATE PROCEDURE "informix".sp_synmotor_agregar_parametroswsdl(vRegistro INTEGER, vOperacion CHAR(5))
RETURNING CHAR(5) AS CodRet, CHAR(5) As TranIAC, CHAR(100) AS Etiqueta,CHAR(1) AS Tipo, CHAR(250) AS Descripcion1, CHAR(100) AS Campo, INTEGER AS IdParam, INTEGER AS Antecesor, INTEGER AS IdCampo, CHAR (50) AS Descripcion2, INTEGER AS IdSPCampo, CHAR(250) AS ValorDefault;
 
/**************************************************************************/
/* Fecha: 02/Abril/2018                                                   */
/* SPL: "informix".sp_synmotor_agregar_parametros                         */
/* Actividad:                                                             */
/* Realizado por: Francisco Javier Benito Santiago(fbenito@syndein.com.mx)*/
/* @Copyright 2018 Syndein, S.A. de C.V. All rights reserved.             */
/* SYNDEIN PROPIETARY/CONFIDENTIAL.                                       */
/* Use is subject to license terms                                        */
/**************************************************************************/

DEFINE vCodRet  CHAR(5);
DEFINE sql_err INTEGER;
DEFINE vEtiqueta CHAR(100);
DEFINE vTipo     CHAR(1); 
DEFINE vDescripcion1 CHAR(250); 
DEFINE vCampo CHAR(100);
DEFINE vId_Param INTEGER;
DEFINE vAntecesor INTEGER;
DEFINE vId_Campo INTEGER;
DEFINE vDescripcion2 CHAR (50);
DEFINE vId_SPCampo INTEGER;
DEFINE vValorDefault CHAR(250);
DEFINE vTranIAC CHAR(5);

LET vCodRet= '000';
LET vEtiqueta =  ' ';
LET vTipo     = ' '; 
LET vDescripcion1 = ' '; 
LET vCampo = ' ';
LET vId_Param = 0;
LET vAntecesor = 0;
LET vId_Campo = 0;
LET vDescripcion2 = ' ';
LET vId_SPCampo = 0;
LET vValorDefault = ' ';
LET vTranIAC  = ' ';
BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET vCodRet = sql_err;
			RETURN  vCodRet, vTranIAC, vEtiqueta,vTipo,vDescripcion1,vCampo,vId_Param,vAntecesor, vId_Campo, vDescripcion2, vId_SPCampo, vValorDefault;
		END IF;
	END EXCEPTION;
 
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
  
	FOREACH
              
		/*
		SELECT SKIP vRegistro FIRST 12 tia.tran_iac As TranIAC, pa.etiqueta, pa.tipo, pa.descripcion, CASE when cia.campo is null then '' else cia.campo end as campo, pa.id_param, pa.antecesor, CASE when cia.id_campo is null then -1 else cia.id_campo end as id_campo, spc.descripcion as sp, CASE when spc.id_sp_campo is null then -1 else spc.id_sp_campo end as id_sp_campo, CASE when valordefault = 'null' then '' else valordefault end as valordefault
		INTO vTranIAC,vEtiqueta,vTipo,vDescripcion1,vCampo,vId_Param,vAntecesor, vId_Campo, vDescripcion2, vId_SPCampo, vValorDefault
		FROM mc_web_service ws INNER JOIN mc_operaciones op ON ws.id_ws=op.id_ws INNER JOIN mc_parametros pa
		ON pa.id_oper=op.id_oper LEFT JOIN mc_sp_central_campos spc ON spc.id_sp_campo=pa.id_sp_campo
		LEFT JOIN mc_iac_trans_campos cia ON cia.id_campo=pa.id_campo 
		INNER JOIN mc_iac_transaccion tia ON tia.id_tran = op.id_tran
		WHERE tia.tran_iac = vOperacion ORDER BY pa.tipo,pa.id_param ASC
		*/
		
		SELECT SKIP vRegistro FIRST 12 tia.tran_iac As TranIAC, pa.etiqueta, pa.tipo, pa.descripcion, cia.campo,pa.id_param, pa.antecesor, cia.id_campo,spc.descripcion as sp, spc.id_sp_campo,valordefault
		INTO vTranIAC,vEtiqueta,vTipo,vDescripcion1,vCampo,vId_Param,vAntecesor, vId_Campo, vDescripcion2, vId_SPCampo, vValorDefault
		FROM mc_web_service ws INNER JOIN mc_operaciones op ON ws.id_ws=op.id_ws INNER JOIN mc_parametros pa
		ON pa.id_oper=op.id_oper LEFT JOIN mc_sp_central_campos spc ON spc.id_sp_campo=pa.id_sp_campo
		LEFT JOIN mc_iac_trans_campos cia ON cia.id_campo=pa.id_campo 
		INNER JOIN mc_iac_transaccion tia ON tia.id_tran = op.id_tran
		WHERE tia.tran_iac = vOperacion ORDER BY pa.tipo,pa.id_param ASC
		
		LET vCampo =  NVL(vCampo,''); --CASE WHEN vCampo IS NULL THEN '' ELSE vCampo END;
		LET vId_Campo =  NVL(vId_Campo,''); --CASE WHEN vId_Campo IS NULL THEN '' ELSE vId_Campo END;
		LET vId_SPCampo =  NVL(vId_SPCampo,''); --CASE WHEN vId_SPCampo IS NULL THEN '' ELSE vId_SPCampo END;
		LET vValorDefault =  NVL(vValorDefault,''); --CASE WHEN vValorDefault IS NULL THEN '' ELSE vValorDefault END;

		RETURN vCodRet, vTranIAC, vEtiqueta,vTipo,vDescripcion1,vCampo,vId_Param,vAntecesor, vId_Campo, vDescripcion2, vId_SPCampo, vValorDefault WITH RESUME; 
 
	END FOREACH;  
END;
END PROCEDURE;