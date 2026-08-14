CREATE PROCEDURE "informix".sp_cau_inserta_st_cp_ifx(pSecuencia integer,
	pResultadoTelefonoCasa char(2), 
	pCausaTelefonoCasa char(1), 
	pResultadoTelefonoRef char(2), 
	pCausaTelefonoRef char(1), 
	pResultadoTelefonoTrab char(2),
	pCausaTelefonotrab char(1), 
	pResultadoTelefonoCelular char(2), 
	pCausaTelefonoCelular char(1),
	pFechaHoraInicio date )
RETURNING CHAR(5) as codret;
	/*
	DESCRIPCION:  CONSULTA PARA EL ARCHIVO ST_CP_aammdd.txt Donde se respaldan el total de llamadas
			gestionadas en la supervisión telefónica en línea de alta única
	AUTOR: 	Ing. Alfonso Cruz
	FECHA: 	22/01/2013
	BD: 	BDISOLIC
	SISTEMA:GenArchivosConcCoppel
	*/

DEFINE cod_ret			CHAR(5);
DEFINE sql_err			INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info		CHAR(40);

LET cod_ret				='00000';
LET sql_err				=0;
LET isam_err			=0;
LET error_info			='';

BEGIN 

ON EXCEPTION SET sql_err, isam_err, error_info
   LET cod_ret = sql_err;
	
   RETURN NVL(cod_ret,'');
   
END EXCEPTION;

--SET DEBUG FILE TO '/home/sysifx/soporte/altaunica/genarchivos/SP_CAU_Consulta_ST_CP_IFX.sql';
--TRACE ON;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;


	IF NOT EXISTS(SELECT 1 FROM bdisolic:"informix".ss_cau_resultado_paso where secuencia = pSecuencia) THEN
		INSERT INTO bdisolic:"informix".ss_cau_resultado_paso
			(Secuencia ,
			ResultadoTelefonoCasa ,
			CausaTelefonoCasa ,
			ResultadoTelefonoRef ,
			CausaTelefonoRef ,
			ResultadoTelefonoTrab ,
			CausaTelefonotrab ,
			ResultadoTelefonoCelular,
			CausaTelefonoCelular,
			FechaHoraInicio )
		VALUES (pSecuencia ,
			pResultadoTelefonoCasa ,
			pCausaTelefonoCasa ,
			pResultadoTelefonoRef ,
			pCausaTelefonoRef ,
			pResultadoTelefonoTrab ,
			pCausaTelefonotrab ,
			pResultadoTelefonoCelular,
			pCausaTelefonoCelular,
			pFechaHoraInicio);
	ELSE
		LET cod_ret = "00001";
	END IF;



	RETURN NVL(cod_ret,'');
END

END PROCEDURE;