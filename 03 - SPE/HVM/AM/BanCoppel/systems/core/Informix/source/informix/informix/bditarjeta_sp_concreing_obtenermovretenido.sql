CREATE PROCEDURE "informix".sp_concreing_obtenermovretenido ( )
RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta;

--****************************************************************************************************
-- DESCRIPCION:  OBTIENE MOVIMIENTOS RETENIDOS PENDIENTES POR LIBERAR
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 02/10/2011
-- BD: BdiTarjeta
-- SISTEMA : Reingenieria Conciliacion -- OBTENER MOVIMIENTOS RETENIDOS
-- MODIFICADO : 
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsSQL VARCHAR (200) ;
DEFINE viSQLerr INTEGER ;

DEFINE vsCodRet VARCHAR(5);
DEFINE vsMensaje_Respuesta VARCHAR(250);
DEFINE dtFecha_Hoy_Cheques DATE;
DEFINE dtFecha_Hoy_Credito DATE;


/* INICIALIZACION DE VARIABLES */
LET vsSQL = '' ;
LET viSQLerr = 0;    
  
LET vsCodRet = '00000';
LET vsMensaje_Respuesta = '';
LET dtFecha_Hoy_Cheques = CURRENT::DATE;
LET dtFecha_Hoy_Credito = CURRENT::DATE;

BEGIN

ON EXCEPTION SET viSQLerr
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--LIMPIA LA TABLA
	DELETE FROM BdiTarjeta:"informix".Td_Carga_Archivo;
	LET vsCodRet = '03801';
	RETURN vsCodRet, ('[' || vsCodRet ||  '] ERROR NO CONTROLADO (' || viSQLerr || '). ' || TRIM(vsMensaje_Respuesta) );
	
END EXCEPTION;
	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	LET vsMensaje_Respuesta = 'OBTENER FECHA CHEQUES.';
	SELECT LIMIT 1 Fecha_Hoy INTO dtFecha_Hoy_Cheques FROM BdiCheq:"informix".Sc_Fechas;
	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	LET vsMensaje_Respuesta = 'OBTENER FECHA CREDITO.';
	SELECT LIMIT 1 Fecha_Hoy INTO dtFecha_Hoy_Credito FROM BdiCred:"informix".Sd_Fechas;
	
	
	LET vsMensaje_Respuesta = 'LIMPIAR TABLA DE TRABAJO.';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--LIMPIA LA TABLA
	--DELETE FROM BdiTarjeta:"informix".Td_Retenidos;
		IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'td_retenidos' AND dbsname= 'bditarjeta') THEN
			DROP TABLE bditarjeta:td_retenidos;
		END IF;
	
	create table "informix".td_retenidos
		(
			tipo char(1) default '' not null,
			cuenta_credito char(20) default '' not null,
			fecha_retencion date default '01/01/1900' not null,
			folio_retencion char(16) default '' not null,
			cve_usuario char(10) default '' not null,
			monto_retenido money default 0.0 not null,
			dias_restantes_lib integer default 0 not null,
			primary key(tipo, cuenta_credito, fecha_retencion, folio_retencion)
		)extent size 4192 next size 32 lock mode row;
	
	LET vsMensaje_Respuesta = 'LLENA LA TABLA DE TRABAJO.';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--GUARDA LOS MOVIMIENTOS PENDIENTES
	INSERT INTO BdiTarjeta:"informix".Td_Retenidos (Tipo, Cuenta_Credito, Fecha_Retencion, Folio_Retencion, Monto_Retenido, Dias_Restantes_Lib) 
		SELECT Tipo, Cuenta_Credito, Fecha_Retencion, Folio_Retencion, Monto_Retenido, Dias_Restantes_Lib 
		FROM TABLE ( 
			MULTISET 	(
				--OBTIENE MOVIMEINTOS DE CHEQUES
				SELECT "D" AS Tipo, Cuenta::VARCHAR(20) AS Cuenta_Credito, Fecha_Alta AS Fecha_Retencion, Folio_Suc::VARCHAR(16) AS Folio_Retencion, Monto AS Monto_Retenido, (fecha_alta-(dtFecha_Hoy_Cheques - Dias_Ret)) AS Dias_Restantes_Lib 
				FROM BdiCheq:"informix".Sc_DocRet 
				WHERE siglas in ('SD', 'SC')
					and Fecha_Alta between (dtFecha_Hoy_Cheques - 9) and (dtFecha_Hoy_Cheques - 2)
					and	Cancelado = 'P'
				UNION
				--OBTIENE MOVIMIENTOS DE CREDITO
				SELECT "C" AS Tipo, Num_Credito::VARCHAR(20) AS Cuenta_Credito, Fecha AS Fecha_Retencion, Folio_Suc::VARCHAR(16) AS Folio_Retencion, Monto AS Monto_Retenido, (fecha-(dtFecha_Hoy_Credito-Dias_Ret)) AS Dias_Restantes_Lib 
				FROM BdiCred:"informix".Sd_MaeRetenido
				WHERE 	Empresa = '001'
						and Estatus = 'P'
						and Fecha between (dtFecha_Hoy_Credito - 9) and(dtFecha_Hoy_Credito - 2)
						)
					);

	RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta);
	
END
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: OBTIENE MOVIMIENTOS RETENIDOS PENDIENTES POR LIBERAR.',
'Fecha: 2011/11/02',
'Version: 20111102.11043',
'BD: BdiTarjeta',
'Modifico: Ricardo Resendiz Martinez',
'Proyecto: Reingenieria de la conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: Se optimizaron consultas y de delimitaron periodos',
'Fecha: 2012/10/12',
'BD: Bditarjeta';

CREATE PROCEDURE "informix".sp_tras_bitacorahis_con(cNumEmpl varchar(9))
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_COD_RET2        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE  iValor           INTEGER;
	DEFINE  dFechaFin        DATE;	
	DEFINE  iNumReg          INTEGER;
	
	--SET DEBUG FILE TO "/tmp/manuel/tras.out";
	--TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
	  
	  EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('46','Error en sp_tras_bitacorahis_con ' || SQL_ERR || ' ' || P_MENSAJE,cNumEmpl) INTO P_COD_RET2;
	  
      RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

--************************************************************
-- Creado por Manuel Osuna Valencia 
-- fecha : 19/10/2011
-- Funcion: Traspaso de Informacion de bitacora a historico 
--************************************************************

   LET P_COD_RET = '00000';
   LET P_COD_RET2 = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO TRASNFERENCIA DE BITACORA A HISTORICOS';
   LET iValor = 0;
   LET iNumReg = 0;
   
   	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	SELECT valor INTO iValor FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '402';
	
		
	IF (iValor == 0) THEN
	   LET P_COD_RET = '00000';
	   LET P_MENSAJE = 'NO EXISTEN DIAS A SUBSTRAER.. ';	
	ELSE
		
		SELECT fecha_hoy - iValor units day INTO dFechaFin   FROM bdinteg:"informix".si_fechas;				
		
		INSERT INTO bditarjeta:"informix".td_bitacora_conciliacion_his(consecutivo,elemento,fecha_hora,actividad,cve_usuario)
		SELECT consecutivo,elemento,fecha_hora,actividad,cve_usuario
		FROM bditarjeta:"informix".td_bitacora_conciliacion
		WHERE date(fecha_hora) <= dFechaFin;
						
		LET iNumReg =dbinfo("sqlca.sqlerrd2");
		
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('46','Exito en Traspaso de  Bitacora a Historico (sp_tras_bitacorahis_con) ' || iNumReg  || ' ' || 'Registros Transferidos',cNumEmpl) INTO P_COD_RET;
				
		DELETE FROM bditarjeta:"informix".td_bitacora_conciliacion	WHERE date(fecha_hora) <= dFechaFin;	   

	
	END IF;
     
	RETURN P_COD_RET,P_MENSAJE;
  
END;
END PROCEDURE;