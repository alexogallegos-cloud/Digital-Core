CREATE PROCEDURE "informix".sp_consultabanco( 
											pintcvebanco   VARCHAR(5)      -- clave de banco
											)
	RETURNING CHAR(5), CHAR(5), CHAR(60), CHAR(20), CHAR(10), CHAR(1), CHAR(1), CHAR(1), CHAR(1), CHAR(1), CHAR(1), CHAR(1);
	
	DEFINE vCodRet  CHAR(5);
	DEFINE vCodRet2	CHAR(5);
	DEFINE vSqlErr  INTEGER;
	DEFINE vIsamErr	INTEGER;
	DEFINE vclave	CHAR(5);
	DEFINE vnombre1	CHAR(60);
	DEFINE vnombre2 CHAR(20);
	DEFINE vfecha	DATE;
	DEFINE vspei	CHAR(1);
	DEFINE vcheques	CHAR(1);
	DEFINE vnomina	CHAR(1);
	DEFINE vtefr	CHAR(1);
	DEFINE vtefp	CHAR(1);
	DEFINE vdomir	CHAR(1);
	DEFINE vdomip	CHAR(1);
	
	LET vCodRet='000';
	LET vSqlErr=0;
	LET vIsamErr=0;
	LET vclave=TRIM(pintcvebanco);
	LET vnombre1='';
	LET vnombre2='';
	--LET vfecha='';
	LET vspei='0';
	LET vcheques='0';
	LET vnomina='0';
	LET vtefr='0';
	LET vtefp='0';
	LET vdomir='0';
	LET vdomip='0';
	
	--SET DEBUG FILE TO "/informix/Jess/sp_consultabanco.out";
    --TRACE ON;
	
	BEGIN
	   
	    ON EXCEPTION SET vSqlErr, vIsamErr
			--SET DEBUG FILE TO "/informix/Jess/sp_consultabanco.out";
			--TRACE ON;
			IF vSqlErr != 0 THEN
				LET vCodRet = vSqlErr;
				LET vCodRet2 = vIsamErr;
            RETURN vCodRet, vclave, vnombre1, vnombre2, vfecha, vspei, vcheques, vnomina, vtefr, vtefp, vdomir, vdomip; 
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF LENGTH(vclave)>0 THEN 
		
			SELECT descripcion, vchrnombrecorto, fecha_opera, flg_spei, flg_cheq, flg_nomi, flg_tef_r, flg_tef_p, flg_domi_r, flg_domi_p
			INTO vnombre1, vnombre2, vfecha, vspei, vcheques, vnomina, vtefr, vtefp, vdomir, vdomip
			FROM si_bancos
			WHERE cvecesif=vclave;

		ELSE
		
		    LET vCodRet='001';   -- No existe la clave
		
		END IF
	END;
	RETURN vCodRet, vclave, vnombre1, vnombre2, vfecha, vspei, vcheques, vnomina, vtefr, vtefp, vdomir, vdomip;
END PROCEDURE;