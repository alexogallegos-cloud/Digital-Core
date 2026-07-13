CREATE PROCEDURE "informix".sp_consultatarjeta(pEmpresa CHAR(3), pNumTarjeta CHAR(20))

--DATOS A REGRESAR--
RETURNING
CHAR(5),	--Codigo de Retorno
CHAR(20),	--Numero Cliente
CHAR(20),	--Numero Cuenta
CHAR(4),	--Numero de Producto
CHAR(26),	--Apellido Paterno
CHAR(26),	--Apellido Materno
CHAR(26),	--Nombre1
CHAR(26),	--Nombre2
DATE,		--Expiracion
CHAR(1),	--Tipo Tarjeta
CHAR(1),	--Estatus Tarjeta
MONEY(14,2), --Limite Autorizado
MONEY(14,2), --Disponible Mes
CHAR(2),	--Motivo
CHAR(1),	--Tipo Asignacion
CHAR(1),	--Cobro Comision
CHAR(8);	--Gerente Autoriza

--DEFINICION DE VARIABLES--
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumCte CHAR(20);
DEFINE cNumCta CHAR(20);
DEFINE cNumProd CHAR(4);
DEFINE cApellPaterno CHAR(26);
DEFINE cApellMaterno CHAR(26);
DEFINE cNombre1 CHAR(26);
DEFINE cNombre2 CHAR(26);
DEFINE dExpiracion DATE;
DEFINE cTipoTarjeta CHAR(1);
DEFINE cEstatusTarjeta CHAR(1);
DEFINE mLimiteAut MONEY(14,2);
DEFINE mDispMes MONEY(14,2);
DEFINE cMotivo CHAR(2);
DEFINE cTipoAsignacion CHAR(1);
DEFINE cCobroComision CHAR(1);
DEFINE cGerenteAut CHAR(1);

--INICIALIZACION DE VARIABLES--
LET iSqlErr = 0;
LET cCodRet = '000';
LET cNumCte = '';
LET cNumCta = '';
LET cNumProd = '';
LET cApellPaterno = '';
LET cApellMaterno = '';
LET cNombre1 = '';
LET cNombre2 = '';
LET dExpiracion = '';
LET cTipoTarjeta = '';
LET cEstatusTarjeta = '';
LET mLimiteAut = 0;
LET mDispMes = 0;
LET cMotivo = '';
LET cTipoAsignacion = '';
LET cCobroComision = '';
LET cGerenteAut = '';

--SET DEBUG FILE TO "sp_consultatarjeta.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCte, cNumCta, cNumProd, cApellPaterno, cApellMaterno, cNombre1, cNombre2, 
				dExpiracion, cTipoTarjeta, cEstatusTarjeta, mLimiteAut, mDispMes, cMotivo, cTipoAsignacion, 
				cCobroComision, cGerenteAut;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	SELECT numcte, cuenta, expiracion, tipo_tarjeta, status_tar, limite_aut, disp_mes, motivo, 
		tipo_asignacion, cobro_comision, gerente_autoriza
	INTO cNumCte, cNumCta, dExpiracion, cTipoTarjeta, cEstatusTarjeta, mLimiteAut, mDispMes, cMotivo, 
		cTipoAsignacion, cCobroComision, cGerenteAut
	FROM "informix".sc_tarjeta
	WHERE empresa = pEmpresa AND num_tarjeta = pNumTarjeta; 

	IF NVL(cNumCta,'') <> "" THEN
		SELECT producto INTO cNumProd
		FROM "informix".sc_maechq
		WHERE empresa = pEmpresa AND cuenta = cNumCta; 

		SELECT apell_paterno, apell_materno, nombre1, nombre2
		INTO cApellPaterno, cApellMaterno, cNombre1, cNombre2
		FROM bdinteg:"informix".si_cliente
		WHERE empresa = pEmpresa AND numcte = cNumCte; 
	ELSE
        LET cCodRet = '252';
	END IF
	RETURN cCodRet, cNumCte, cNumCta, cNumProd, cApellPaterno, cApellMaterno, cNombre1, cNombre2, 
		dExpiracion, cTipoTarjeta, cEstatusTarjeta, mLimiteAut, mDispMes, cMotivo, cTipoAsignacion, 
		cCobroComision, cGerenteAut;
END
END PROCEDURE;