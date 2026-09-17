CREATE PROCEDURE "informix".sp_mod_elim_empleados_bei(pCteEmpresa char(9),
														pNumEmp char(30),
														pNomEmp char(30),
														pApePat char(30),
														pApeMat char(20),
														pNumCta char(18),
														pTipoEjecucion smallint,
														pCveBanco CHAR(3))

returning char(5);
	--****************************************************************************************************
	-- DESCRIPCION: MODIFICA O ELIMINA LOS DATOS DEL EMPLEADO
	-- AUTOR : Francisco Rodríguez Ibarra
	-- FECHA : 26/08/2011
	-- BD: bdibpi
	-- SOLICITO :Mauricio León
	--***************************************************************************************************
	--Declaración de variabled
	DEFINE vCodRet char(5);
	DEFINE sql_err integer;
	DEFINE vEmpresa CHAR(20);
	DEFINE vIdEmpresa CHAR(3);

    --asigacion de valores a variables
    LET vCodRet='00000';
	LET vEmpresa='';
	LET	vIdEmpresa='';



  BEGIN


   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let vCodRet = sql_err;
            RETURN vCodRet;
      END IF ;
   END EXCEPTION ;

    SET LOCK MODE TO WAIT ;
	SET ISOLATION DIRTY READ ;

    IF (pTipoEjecucion is null or pTipoEjecucion ='' or pCteEmpresa is null or pCteEmpresa='') THEN
		LET vCodRet='00001';
	ELSE
		SELECT codigo,nombre INTO vIdEmpresa,vEmpresa FROM bdicheq:"informix".sc_nominaempresas WHERE numcte=TRIM(pCteEmpresa);

		IF (vIdEmpresa<>'' OR vIdEmpresa IS NOT NULL) THEN

			IF(pTipoEjecucion=1) THEN

				update bdibpi:"informix".bpi_empleadospm set nombre_empleado=trim(pNomEmp) , apell_pat=trim(pApePat) ,apell_Mat=trim(pApeMat) ,
                    cta_empleado=trim(pNumCta),cve_banco=pCveBanco,f_modifica=today
				where id_empresa=trim(vIdEmpresa) and num_empleado=trim(pNumEmp);


			ELIF(pTipoEjecucion=2) THEN
				delete bdibpi:"informix".bpi_empleadospm where id_empresa=trim(vIdEmpresa) and num_empleado=trim(pNumEmp);
			ELSE
				LET vCodRet='00002';
			END IF;
		ELSE
			LET vCodRet ='00003';
		END IF
	END IF;

	RETURN vCodRet;
	END;
END PROCEDURE
;