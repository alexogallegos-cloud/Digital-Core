CREATE PROCEDURE "informix".sp_obt_razonsocial(pEmpresa CHAR(3), pNumCte CHAR(9))
	returning CHAR(5), CHAR(60);

	--Elaboro: Roberto Castro
	--Actividad: devuelve la razon social del cliente
	--Solicito: Gabriela Aguilar (BanCoppel)
	--Fecha: 21/07/2015
	---*********************************************

	--DEFINE VARIABLES
	DEFINE vRazonSocial CHAR (60);
	DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER; 

	--Inicializa
	LET cod_ret ='000';
	LET vRazonSocial= "";

 BEGIN
	ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vRazonSocial;
      END IF ;
	END EXCEPTION ;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF(pNumCte <> '') THEN

		SELECT razon_social INTO vRazonSocial FROM bdinteg:"informix".si_cliente WHERE numcte = pNumCte and empresa = pEmpresa;

		IF (vRazonSocial = '' OR vRazonSocial IS NULL) THEN
			LET cod_ret = '002';
		END IF;

	ELSE
		LET cod_ret = '001';
	END IF;

	RETURN cod_ret, vRazonSocial;
 END;
END PROCEDURE;