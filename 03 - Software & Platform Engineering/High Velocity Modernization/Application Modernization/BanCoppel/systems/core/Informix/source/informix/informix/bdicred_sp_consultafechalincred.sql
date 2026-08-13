CREATE PROCEDURE "informix".sp_consultafechalincred (pfecini date,pfecfin date,pTipo char(1), pStat1 char(1),pStat2 char(1))
RETURNING  CHAR(6) AS codigo_retorno,
		   CHAR(20) AS Num_credito,
		   DECIMAL(18,2) AS Monto_anterior,
		   DECIMAL(18,2) AS Monto_nuevo,
		   DECIMAL(18,2) AS MontoIncremento,
		   CHAR (20) AS Numcte,
		   CHAR (100) AS Nombre_cliente,
		   DATE AS Fecha_alta,
		   DATETIME HOUR TO SECOND AS Hora_alta,
		   CHAR(1) AS tipo_ejecucion,
		   CHAR(1) AS status_cred;
		   
DEFINE cCodret CHAR(6);
DEFINE cNum_credito CHAR(20);
DEFINE mMontoanterior DECIMAL(18,2) ;
DEFINE mMonto_nuevo DECIMAL(18,2) ; 
DEFINE mMonto_mov DECIMAL(18,2) ; 
DEFINE cNombre_cte CHAR(100) ;
DEFINE cNum_cte CHAR(20) ;
DEFINE dFecha_insert DATE;
DEFINE dHora_insert DATETIME HOUR TO SECOND;
DEFINE cTipo_ejec CHAR(1);
DEFINE cStatus_cred CHAR(1);
DEFINE cSQL_ERR INTEGER;

LET cNum_credito 	= "";
LET mMontoanterior 	= 0;
LET mMonto_nuevo 	= 0;
LET mMonto_mov 		= 0;
LET cNombre_cte		= "";
LET cNum_cte		= "";
LET cTipo_ejec 		= "";
LET dFecha_insert	= DATE(1);
LET cSQL_ERR 		= "000001" ;
LET cCodret  		= "000000";
LET cStatus_cred	= "" ;
LET dHora_insert	= '' ;

-- Se genera archivo DEBUG!
--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_consultafechalincred.out';
--TRACE ON;
   	
BEGIN
	ON EXCEPTION SET cSQL_ERR
	LET cCodret = cSQL_ERR;
	RETURN cCodret,cNum_credito,mMontoanterior, mMonto_nuevo , mMonto_mov, cNum_cte,cNombre_cte,
			dFecha_insert, dHora_insert, cTipo_ejec ,cStatus_cred;
	END EXCEPTION;

	FOREACH
		SELECT a.num_solicitud,a.lincred_actual,a.lincred_sugerida,a.numcte,
			TRIM(NVL(cte.nombre1, ""))||' '||TRIM(NVL(cte.nombre2,""))||' '||TRIM(NVL(cte.apell_paterno, ""))||' '||TRIM(NVL(cte.apell_materno, "")) AS nombre,
			a.fecha_status,a.hora_status,a.mensaje
			INTO cNum_credito,mMontoanterior, mMonto_nuevo , cNum_cte,cNombre_cte,dFecha_insert, dHora_insert, cTipo_ejec
		FROM "informix".sd_bitacora_aumlincred a
		INNER JOIN bdinteg:"informix".si_cliente cte ON (cte.empresa = a.empresa and cte.numcte = a.numcte)
		WHERE a.fecha_status >= pfecini
		AND a.fecha_status <= pfecfin
		AND a.mensaje = pTipo	

		LET mMonto_mov = mMonto_nuevo - mMontoanterior;		
			
		RETURN cCodret,cNum_credito,mMontoanterior, mMonto_nuevo , mMonto_mov, cNum_cte, cNombre_cte, 
		dFecha_insert, dHora_insert, cTipo_ejec ,cStatus_cred WITH resume ;
	END FOREACH;
END ;
END PROCEDURE
DOCUMENT
'AUTOR :Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se creo el sp para el llenado del reporte por periodo de fechas según su modificación de la linea de crédito.',
'Captacion',
'FECHA : Diciembre de 2008',
'VERSION: 200812',
'BD    : BDICRED',
'AUTOR :Jesús Manuel Aguilar Heredia',
'DESCRIPCION: Se modifica para que consulte a la tabla sd_bitacora_aumlincred, para obtener los datos del cliente, y se homologan ',
'los tipos de datos del sp con los de la tabla sd_bitacora_aumlincred',
'Captacion',
'FECHA : 28 de Junio de 2011',
'VERSION: 20110628.1725',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_obtentardeb_limitaut(pEmpresa CHAR(3), pNumcte CHAR(20), pCuenta CHAR(20), pNumcred CHAR(20))

RETURNING CHAR(6)  AS codret,
          CHAR(20) AS tarjetadeb,
          DECIMAL(14,2)  AS lineaaut;



DEFINE vCodret char(6);
DEFINE vNumtar CHAR(20);
DEFINE vLimaut DECIMAL(14,2);
DEFINE vsqlerr INTEGER;

LET vCodret = '000000';
LET vNumtar = '';  
LET vLimaut = 0;
LET vsqlerr = 0;

BEGIN
                ON EXCEPTION SET vsqlerr
                        IF vsqlerr <> 0 THEN
                            LET vCodret= vsqlerr;

                                RETURN vCodret,vNumtar,vLimaut;
                        END IF;
                END EXCEPTION;

        --SET DEBUG FILE TO '/tmp/sp_obtentardeb_limitaut.out';
        --TRACE ON;
        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

         IF pEmpresa is null or pEmpresa = '' then 
             LET  vCodret= '00110';  --parametros incompletos
             RETURN vCodret,vNumtar,vLimaut;
         END IF;

     --   SELECT num_tarjeta 
      --  INTO vNumtar 
       -- FROM bdicheq:sc_tarjeta
       -- WHERE numcte=pNumcte 
       -- AND p

         SELECT num_tarjeta
         INTO vNumtar 
         FROM bdicheq:sc_tarjeta 
         WHERE numcte = pNumcte --'000001042' 
         AND cuenta= pCuenta --'10000005237' 
        AND tipo_tarjeta='T' 
        AND status_tar= 'A';
 
         SELECT limite_aut
         INTO vLimaut 
         FROM bdicred:sd_tarjeta 
         WHERE  numcte= pNumcte --'057197440' 
         AND num_credito= pNumcred--'600458762249'
         AND status_tar ='A';

        RETURN vCodret,NVL(vNumtar,0),NVL(vLimaut,0);

END ;
END PROCEDURE;