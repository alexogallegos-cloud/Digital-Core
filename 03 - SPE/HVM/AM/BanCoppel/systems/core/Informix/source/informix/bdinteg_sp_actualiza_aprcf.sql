CREATE PROCEDURE "informix".sp_actualiza_aprcf()
				returning CHAR(5) AS Cod_Retorno,INTEGER as Idreg;


DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
DEFINE sRetCod          CHAR(5);
DEFINE Iid				INTEGER;
DEFINE IidErr			INTEGER;

--SISTEMA DE CUENTA 01 VARIABLES
DEFINE sAP_paterno     CHAR(26);
DEFINE sAP_materno     CHAR(26);
DEFINE sAP_nombre1     CHAR(26);
DEFINE sAP_nombre2     CHAR(26);
DEFINE sAP_fecha_nac   CHAR(10);
DEFINE sAP_rfc         CHAR(13);
DEFINE sAP_dia          CHAR(2);
DEFINE sAP_mes          CHAR(2);
DEFINE sAP_year         CHAR(4);
DEFINE sAP_fecnac       CHAR(10);

LET sAP_paterno        = '';
LET sAP_materno        = '';
LET sAP_nombre1        = '';
LET sAP_nombre2        = '';
LET sAP_fecha_nac      = '';
LET sAP_rfc            = '';
LET sAP_dia            = '';
LET sAP_mes            = '';
LET sAP_year           = '';
LET sAP_fecnac         = '';
LET Iid				   =0;
LET sRetCod          	="99999";
LET cCodRet 			= "00000";
LET IidErr				=0;




BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,IidErr;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/VH/PM/sp_cnsif_consnumcte.out";
	--TRACE ON;
		

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	FOREACH
		SELECT {+INDEX (bdinteg:"informix".si_solicitud_movil idx_status_valua)} id,ap_apell_paterno,ap_apell_materno,ap_nombre1,ap_nombre2,ap_fecha_nac INTO Iid,sAP_paterno,sAP_materno,sAP_nombre1,sAP_nombre2,sAP_fecnac FROM si_solicitud_movil
		WHERE status_valua IS NOT NULL AND ap_rfc IS NULL AND ap_fecha_nac IS NOT NULL and length(ap_fecha_nac)=10

		 LET IidErr=Iid;
		 LET sAP_dia = "";
		 LET sAP_mes = "";
		 LET sAP_year = "";
		 LET sAP_dia = sAP_fecnac[1,2];
		 LET sAP_mes = sAP_fecnac[4,5];
		 LET sAP_year = sAP_fecnac[7,10];

		 IF LENGTH(sAP_year)<=2 THEN
			LET sAP_year="19"||sAP_year;
		 END IF;
		 LET sAP_fecnac ="";
		 LET sAP_rfc="";
		 LET sAP_fecnac = TRIM(sAP_mes)||''||TRIM(sAP_dia)||''||TRIM(sAP_year);

		 CALL sp_calcularrfc(sAP_paterno,sAP_materno,sAP_nombre1||' '||sAP_nombre2,sAP_fecnac)
		 RETURNING sRetCod, sAP_rfc;
		 IF sRetCod = '00000' THEN
			UPDATE "informix".si_solicitud_movil set ap_rfc=sAP_rfc where id=Iid;
		 END IF;
		LET sAP_paterno        = '';
		LET sAP_materno        = '';
		LET sAP_nombre1        = '';
		LET sAP_nombre2        = '';
		LET sAP_fecnac      = '';
	END FOREACH;


	RETURN cCodRet,IidErr;
END
END PROCEDURE;