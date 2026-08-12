CREATE PROCEDURE "informix".sp_cons_estatus_disp(pIdEmp char(3),pCteEmpresa char(9),pArchivo char(20) )
returning char(5),char(50);

	-- Autor: Francisco Rodríguez
	-- Objetivo: Obtiene el código de retorno de la dispersión
	-- Solicitó: Mauricio Leon
	-- Fecha: 01/11/2011

--DECLARACION DE VARIABLES
	DEFINE vCodRet CHAR(5);
	DEFINE sql_err INTEGER ;
	DEFINE vValor INTEGER;
	DEFINE cMensaje CHAR(50);

	--INICIALIZAR VALORES A VARIABLES;
	LET vCodRet='00000';
	LET vValor=0;
	LET cMensaje='';

	--SET debug FILE TO "/home/informix/ivonne/sp_cons_estatus_disp.out";
	--Trace ON;

	BEGIN
	 on exception set sql_err
        if vCodRet <> 0 then
            let vCodRet = sql_err;

			 return vCodRet,'';
        end if;
    	end exception;

	SET LOCK MODE TO WAIT ;
	SET ISOLATION DIRTY READ ;

	SELECT codret,mensaje INTO vCodRet,cMensaje FROM bdibpi:"informix".tmp_disp_err
	WHERE id_empresa=pIdEmp AND num_cte=pCteEmpresa AND nom_arch=pArchivo;

	DELETE FROM bdibpi:"informix".tmp_disp_err  WHERE id_empresa=pIdEmp AND num_cte=pCteEmpresa AND nom_arch=pArchivo;


	RETURN vCodRet,cMensaje;

END;
END PROCEDURE;