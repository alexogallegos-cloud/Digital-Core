CREATE PROCEDURE "informix".sp_obtieneparaminv_pba(pEmpresa CHAR(3),pNumEmpleado CHAR(8))
	RETURNING CHAR(5),CHAR(2),CHAR(2),CHAR(100),CHAR(45),CHAR(30),DATE,CHAR(2),CHAR(11),DATE,DATE,DATE,DATE,DATE,DATE;

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
	DEFINE cLongCta             CHAR(11);
	DEFINE dFecha_ant           DATE;
	DEFINE dProx_fecha           DATE;
	DEFINE dPri_dia_mes          DATE;
	DEFINE dPri_hab_mes          DATE;
	DEFINE dUlt_dia_mes          DATE;
	DEFINE dUlt_hab_mes          DATE;

	--Crea el archivo de monitoreo del proceso
	--SET DEBUG FILE TO "/tmp/sp_ObtieneParamInv.out";
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
				RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema,
					   cLongCta,dFecha_ant,dProx_fecha,dPri_dia_mes,dPri_hab_mes,dUlt_dia_mes,dUlt_hab_mes;
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
		SELECT Trim(valor) 
		INTO cPathRep
		FROM bdinvers:sv_param
		WHERE empresa = pEmpresa AND codparam = ('path_rpt');

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
		
		--Obtiene  la longitud de la cuenta de inversiones
		SELECT valor 
		INTO cLongCta
		FROM bdinvers:sv_param 
		WHERE codparam = 'longcta';
		
		-- Obtengo Fecha de integral para la Captura de Parametros
		SELECT fecha_hoy,fecha_ant,prox_fecha,pri_dia_mes,pri_hab_mes,ult_dia_mes,ult_hab_mes  
		INTO dFecha_Hoy,dFecha_ant,dProx_fecha,dPri_dia_mes,dPri_hab_mes,dUlt_dia_mes,dUlt_hab_mes
		FROM bdinvers:sv_fechas;

		--Obtengo codigo del sistema
		SELECT sistema
		INTO cSistema
		FROM bdinteg:si_sistema 
		WHERE siglas = 'SV';
		
		RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema,
					   cLongCta,dFecha_ant,dProx_fecha,dPri_dia_mes,dPri_hab_mes,dUlt_dia_mes,dUlt_hab_mes;
		
	END
	END PROCEDURE
	