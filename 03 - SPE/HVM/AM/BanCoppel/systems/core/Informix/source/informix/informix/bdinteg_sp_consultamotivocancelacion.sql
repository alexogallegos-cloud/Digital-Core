CREATE PROCEDURE "informix".sp_consultamotivocancelacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistemaCuenta CHAR(2), pCliente CHAR(20), pCuenta CHAR(20))
	RETURNING 
		CHAR(5) AS codret,
		CHAR(40) AS motivo_cancelacion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cMotivoCancelacion CHAR(40);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET cMotivoCancelacion = '';
	LET iSqlErr = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN				
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cMotivoCancelacion;			
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/mfinis/sp_consultamotivocancelacion.out";
	    --TRACE ON;
		
		IF pCliente = '' OR pCuenta = '' OR pSistemaCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMotivoCancelacion;
		END IF;
		
		IF pSistemaCuenta NOT IN ('01', '03', '06') THEN
			LET cCodRet = '00037';
			RETURN cCodRet, cMotivoCancelacion;
		END IF;
		
		
		
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(pUsuario,pIdFuncion, pCliente, pSistemaCuenta,'2')INTO cCodRet;
		
		IF (cCodRet != '00000')  THEN
			RETURN cCodRet, cMotivoCancelacion;
		END IF;
		
		IF pSistemaCuenta = '01' THEN
			
			SET ISOLATION TO DIRTY READ;
			
			SELECT descripcion
				INTO cMotivoCancelacion 
			FROM bdicheq:"informix".sc_maechq ma
			LEFT JOIN bdicheq:"informix".sc_motivocancel mb 
				ON ma.empresa = mb.empresa
				AND ma.motivo = mb.clave
			WHERE ma.empresa = '001' 
				AND ma.num_cte = pCliente
				AND ma.cuenta = pCuenta;		
			
		END IF;
		
		RETURN cCodRet, cMotivoCancelacion;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 21/04/2017',
'MODULO: Consultas ',
'FUNCIONALIDAD: Cintilla Cuentas CaptaciÃ³n',
'DESCRIPCION: Spl quee realiza la consulta del motivo de cancelaciÃ³n',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_consultacta_club_pba1(pEmpresa CHAR(3), pCliente CHAR(20), pPoliza CHAR(20),pCteCoppel CHAR(20))
RETURNING CHAR(6) as CodRet, CHAR(1) AS Domiciliada, CHAR(20) AS NumCta, CHAR(20) AS NumTarjeta, CHAR(4) AS SucOperante, CHAR(8) AS NumPromotor, CHAR(16) AS FolioOperacion, CHAR(1) AS Respuesta;

--DEFINICION DE VARIABLES
DEFINE cCodret CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE cDomiciliada CHAR(1);
DEFINE cNumCta CHAR(20);
DEFINE cNumTarjeta CHAR(20);
DEFINE cSucOperante CHAR(4);
DEFINE cNumPromotor CHAR(8);
DEFINE cFolioOperacion CHAR(16);
DEFINE cTipoPago CHAR(1);
DEFINE dFecha DATETIME YEAR TO SECOND;
DEFINE cRespuesta CHAR(1);
--INICIALIZACION DE VARIABLES 
LET cCodret	= "000000";
LET iSqlErr = 0;
LET cDomiciliada = '';
LET cNumCta='';
LET cNumTarjeta='';
LET cSucOperante='';
LET cNumPromotor='';
LET cFolioOperacion='';
LET cRespuesta='';

--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultacta_club.out';
    --TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN cCodret, cDomiciliada, cNumCta, cNumTarjeta, cSucOperante,cNumPromotor,cFolioOperacion,cRespuesta;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pCliente,''))='' OR TRIM(NVL(pPoliza,''))='' THEN
			LET cCodret	= "000001";
		ELSE
			SELECT  MAX(fecha)
			INTO dFecha
			FROM "informix".si_club_bitacora 
			WHERE numcte=pCliente 
			AND numcte_coppel=pCteCoppel 
			AND empresa=pEmpresa;
			
			SELECT respuesta
			INTO cRespuesta
			FROM "informix".si_club_bitacora 
			WHERE numcte=pCliente 
			AND numcte_coppel=pCteCoppel 
			AND empresa=pEmpresa
			AND fecha=dFecha;
		
			SELECT suc_alta, ejecutivo, tipo_pago, num_tarjeta, num_cta,foliooperacion
			INTO cSucOperante,cNumPromotor,cTipoPago,cNumTarjeta,cNumCta,cFolioOperacion
			FROM  "informix".si_club_proteccion
			WHERE empresa= pEmpresa AND numcte=pCliente;
			--AND num_poliza= pPoliza;
		
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodret	= "000002";
			ELSE
				IF TRIM(NVL(cTipoPago,''))='1' THEN
					LET cDomiciliada = 'S';
				ELSE 
					LET cDomiciliada = 'N';
					LET cNumCta='';
					LET cNumTarjeta='';
				END IF
			END IF
		END IF
		
RETURN cCodret, cDomiciliada, cNumCta, cNumTarjeta, cSucOperante,cNumPromotor,cFolioOperacion,cRespuesta;
END
END PROCEDURE

DOCUMENT
"Descripción: Retorna la cuenta domiciliada para el Club de protección.",
"Autor : Leslie Rendón",
"FECHA : 07/07/2014",
"BD    : bdinteg",

'Descripción: Se comenta filtro num_poliza = pPoliza para que no se realice la comparacion en la tabla si_club_proteccion',
'Autor : Bryan Limon',
'FECHA : 16/05/2017',
'BD    : bdinteg'
;

CREATE PROCEDURE "informix".sp_actualiza_rep_ctas_tel_mail()
RETURNING 
CHAR(5) AS CodRet,
CHAR(50) AS Mensaje;

----------------DEFINE VARIABLES----------------------
DEFINE cCodRet        	  CHAR(5);
DEFINE iSqlErr	       	  INTEGER;
DEFINE cDesc          	  CHAR(50);
DEFINE cNumcte            CHAR(20);
DEFINE cCorreo            CHAR(100);
DEFINE cTelefono          CHAR(10);
DEFINE sCommit            SMALLINT;
DEFINE iContador          INTEGER;
DEFINE cCuenta		      CHAR(20);

----------------INICIALIZA VARIABLES------------------
LET cCodRet             ='00000';
LET iSqlErr	            = 0;
LET cDesc               ='';
LET cNumcte             ='';
LET cCorreo             ='';
LET cTelefono           ='';
LET sCommit             = 0;
LET iContador           = 0;
LET cCuenta             ='';

BEGIN

    ----------ERRORES DE INFORMIX-------------------------
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cDesc='Error no controlado';
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    FOREACH WITH HOLD
    SELECT {+INDEX ("informix".si_rep_ctas_tel_mail idx_rep_ctas_tel_mail)} cuenta
	INTO cCuenta
	FROM si_rep_ctas_tel_mail
		
        SELECT LIMIT 1 num_cte INTO cNumcte FROM bdicheq:sc_maechq WHERE cuenta = cCuenta;        
        SELECT LIMIT 1 correo_elec INTO cCorreo FROM si_correos WHERE status_correo = 'A' AND numcte = cNumcte AND secuencia = (select max(secuencia) from si_correos where  numcte = cNumcte); 
        SELECT LIMIT 1 telefono INTO cTelefono FROM si_telefonos_actual WHERE status_tel='A' AND tipo_tel=2 AND numcte = cNumcte;               

        IF (sCommit = 0) THEN
            BEGIN WORK;
            LET iContador = 0;
            LET sCommit = -1;
        END IF;			        

        UPDATE si_rep_ctas_tel_mail SET numcte = NVL(cNumcte,''), correo = NVL(cCorreo,''), celular = NVL(cTelefono,'')
        WHERE cuenta = cCuenta;

        --Ejecutar un commit cada 1000 registros.
        IF (iContador >= 5000) THEN
            COMMIT WORK;	
            LET iContador = 0;            
            BEGIN WORK;
        END IF;	

    END FOREACH;
	
	IF sCommit = -1 THEN
        COMMIT WORK;        
        END IF;
	LET sCommit = 0;

	LET cDesc = 'Proceso Correcto';
    RETURN cCodRet, cDesc;

END;
END PROCEDURE;