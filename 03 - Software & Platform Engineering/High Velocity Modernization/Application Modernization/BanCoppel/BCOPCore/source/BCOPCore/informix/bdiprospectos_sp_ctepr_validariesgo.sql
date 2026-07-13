CREATE PROCEDURE "informix".sp_ctepr_validariesgo(pEmpresa CHAR(3), pNumCtePros CHAR(20))
RETURNING CHAR(6), CHAR(1), CHAR(3);      -- CODIGO DE RETORNO


    DEFINE viSqlErr         		INTEGER;
    DEFINE viIsamErr        		INTEGER;
    DEFINE vcCodRet         		CHAR(6);
	
	DEFINE vcHabita_en				CHAR(1);
	DEFINE vcClaveopcionpuesto		INTEGER;
	DEFINE vcClavesubopcionpuesto	INTEGER;
	DEFINE vcSitEsp					CHAR(1);
	DEFINE vcCausa					CHAR(3);
	
	LET viSqlErr       = 0;
    LET viIsamErr      = 0;
    LET vcCodRet       = '000000'; --Proceso Exitoso
		
	LET	vcHabita_en			   		= '';
	LET vcClaveopcionpuesto 		= 0;
	LET vcClavesubopcionpuesto		= 0;
	LET vcSitEsp	   				= '';
	LET vcCausa		   				= '';
	
	--- SET DEBUG FILE TO "/tmp/sp_ctepr_validariesgo.out";
    --- TRACE ON;
	
BEGIN
    
    ON EXCEPTION SET viSqlErr
        IF viSqlErr <> 0 THEN
            LET vcCodRet  = viSqlErr;
            RETURN vcCodRet, vcSitEsp,vcCausa;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF ( pEmpresa is null OR pEmpresa = '' ) OR ( pNumCtePros  is null OR pNumCtePros = '' ) THEN
		LET vcCodRet = '00001'; --Se Recibieron Parámetros Incompletos
        RETURN vcCodRet, vcSitEsp,vcCausa;
	END IF;

	SELECT claveopcionpuesto, clavesubopcionpuesto
	INTO vcClaveopcionpuesto, vcClavesubopcionpuesto
	from "informix".pr_ingresos
	WHERE numcte_pros = pNumCtePros AND 
	sec_ingreso = (SELECT max(sec_ingreso) FROM "informix".pr_ingresos WHERE numcte_pros = pNumCtePros);
	
	IF EXISTS(select * from bdinteg:"informix".si_actsubact where id_act = vcClaveopcionpuesto AND id_subact = vcClavesubopcionpuesto AND altoriesgocredcp = 1) THEN
		LET vcCodRet = '00003'; --Actividad Riesgosa
		LET vcSitEsp = 'P';
		LET vcCausa	= '24';
	ELIF EXISTS(SELECT habita_en from "informix".pr_ctepf where numcte_pros = pNumCtePros AND habita_en = 'H') THEN
		LET vcCodRet = '00002'; --Domicilio de Riesgo por ser Huésped
		LET vcSitEsp = 'P';
		LET vcCausa	= '28';
	END IF;
	
	RETURN vcCodRet, vcSitEsp,vcCausa;
END

END PROCEDURE
