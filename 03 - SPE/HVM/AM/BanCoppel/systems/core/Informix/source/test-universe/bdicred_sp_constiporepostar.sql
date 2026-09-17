CREATE PROCEDURE "informix".sp_constiporepostar(pNumTarjeta CHAR(20),pCodstatus_tar CHAR(1))
	--DATOS A REGRESAR---
	RETURNING
			CHAR(5) As Cod_Ret, CHAR(2) As cIdMotivo;

	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr  		INTEGER;
    DEFINE vCodRet          CHAR(5);
	DEFINE cIdMotivo        CHAR(2);
	DEFINE P_Cod_Ret    	VARCHAR(3);
    DEFINE P_Resultado      VARCHAR(100);
    DEFINE P_Usu_Can        VARCHAR(10);
    DEFINE P_Num_Emp        VARCHAR(8);
    DEFINE P_Nombre         VARCHAR(45);
    DEFINE P_Deptto         CHAR (3);
    DEFINE P_Desc_Deptto CHAR (30);
    DEFINE P_Suc_AREA CHAR (4);
    DEFINE P_Desc_Suc_Area CHAR (40);
    DEFINE V_Fecha_can DATETIME YEAR TO FRACTION(5);
    DEFINE P_Ultimo_Usu VARCHAR(8);

	--INICIALIZACION DE VARIABLES--
	LET iSqlErr = 0;
	LET vCodRet  = "00000";
	LET cIdMotivo = "";
	LET P_Cod_Ret ="";
    LET P_Resultado="";
    LET P_Usu_Can="";
    LET P_Num_Emp="";
    LET P_Nombre="";
    LET P_Deptto="";
    LET P_Desc_Deptto="";
    LET P_Suc_AREA ="";
    LET P_Desc_Suc_Area ="";
    LET V_Fecha_can ='1900-01-01 00:00:00';
    LET P_Ultimo_Usu ="";

--SET DEBUG FILE TO '/informix/Malena/sp_constiporepostar.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET vCodRet = iSqlErr;
			RETURN vCodRet,cIdMotivo;
		END IF;
	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;


	IF pCodstatus_tar = 'C' THEN

		--Mandar Llamar componente sp_verifica_cancelacion
		EXECUTE PROCEDURE intercard:"informix".sp_verifica_cancelacion(pNumTarjeta)
		INTO P_Cod_Ret,P_Resultado,P_Usu_Can,P_Num_Emp,P_Nombre,P_Deptto,P_Desc_Deptto,P_Suc_AREA,P_Desc_Suc_Area,V_Fecha_can,P_Ultimo_Usu;
		--Se valida si la cancelación de la tarjeta fue por el area de aclaración o  Prevención de Fraude
		IF P_Cod_Ret = '000' AND (P_Suc_AREA = '9767' OR P_Suc_AREA ='9768')  THEN
			LET vCodRet = "00499";
			LET cIdMotivo = '04';
		ELSE
		--Se valida si la cancelación es de otra área u otro motivo (robo,extraviada,Daño o maltrato)
			IF P_Cod_Ret ='000' AND P_Resultado='La Tarjeta esta CANCELADA por el usuario de SUCURSAL:' THEN
                LET cIdMotivo = '05';
            ELIF P_Cod_Ret ='010' THEN
				LET cIdMotivo = '01';
			ELIF P_Cod_Ret ='006' THEN
				LET cIdMotivo = '02';
			ELIF P_Cod_Ret IN ('004','005','007') THEN
				LET cIdMotivo = '03';
			END IF;

		END IF;
	END IF;

RETURN vCodRet, cIdMotivo;
END;
--*************************************************************************
--| Procedimiento   : "informix".sp_constiporepostar
--| Version         : 1.0
--| Creado por      : Maria Elena Angulo.
--| Fecha creación  : Junio de 2014
--| Fecha modificó  : Octubre de 2014
--| Descripcion 	: Se consulta si la reposicion fue por Aclaración o Fraude, si es asi devuelve el codigo de parametro del Mensaje
--| " Tarjeta Cancelada en Central, La Reposición no tendrá Costo".
--*************************************************************************
END PROCEDURE;