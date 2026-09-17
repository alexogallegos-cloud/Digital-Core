CREATE PROCEDURE "informix".sp_biobex_rostro
(
    pnum_serial        	INTEGER,
    pempresa           	VARCHAR(3),
    psucursal          	VARCHAR(4),
    pnumcte            	VARCHAR(20),
    psecuencia         	INTEGER,
    pestado            	VARCHAR(1),
    prmapa             	CHAR(9000),
    prmapa2            	CHAR(9000),
    prmapa3            	CHAR(9000),
    pusuario           	VARCHAR(8),
    ptemplate_procesado	VARCHAR(1),
    pmac               	VARCHAR(17),
    pip                	VARCHAR(15),
    pfecha_alta        	VARCHAR(20),
    pusuario_camb      	VARCHAR(8),
    pfecha_camb        	VARCHAR(20),
    pfech_ult_camb     	VARCHAR(60),
	pOp1				VARCHAR(20),
	pOp2				VARCHAR(20),
	pOp3				VARCHAR(20)
)

	RETURNING CHAR(5), VARCHAR(200), VARCHAR(20), VARCHAR(4), VARCHAR(200),VARCHAR(200), VARCHAR(200);

	
	--SP BIOMETRIAS ROSTROS BEX BDINTEG
	
	-- Definicion de variables --
	
	DEFINE cCodRet          	CHAR(5);
    DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr 			INTEGER;
    DEFINE cInfoErr         	CHAR(100);
	DEFINE cMensaje				VARCHAR(200); 
	DEFINE cOp1					VARCHAR(200); 
	DEFINE cOp2					VARCHAR(200); 
	DEFINE cOp3					VARCHAR(200);
	
	DEFINE cConteo  			INTEGER;	
	
    DEFINE cnum_serial        	INTEGER;
    DEFINE cempresa           	VARCHAR(3);
    DEFINE csucursal          	VARCHAR(4);
    DEFINE cnumcte            	VARCHAR(20);
    DEFINE csecuencia         	INTEGER;
    DEFINE cestado            	VARCHAR(1);
    DEFINE crmapa             	CHAR(9000);
    DEFINE crmapa2            	CHAR(9000);
    DEFINE crmapa3            	CHAR(9000);
    DEFINE cusuario           	VARCHAR(8);
    DEFINE ctemplate_procesado	VARCHAR(1);
    DEFINE cmac               	VARCHAR(17);
    DEFINE cip                	VARCHAR(15);
    DEFINE cfecha_alta        	DATE;
    DEFINE cusuario_camb      	VARCHAR(8);
    DEFINE cfecha_camb        	DATE;
    DEFINE cfech_ult_camb     	DATETIME YEAR to SECOND;
	
	--SET DEBUG FILE TO '/informix/HMLG/sp_biobex_rostro.out';
	--TRACE ON; 
	--SET DEBUG FILE TO '/INFORMIXTMP/HMLG/sp_biobex_rostro.out';
	--TRACE ON;
	
	
	LET cCodRet='00009';
    LET iSqlErr='';
	LET iIsamErr=0;
    LET cInfoErr='';
	LET cMensaje=''; 
	LET cOp1=''; 
	LET cOp2=''; 
	LET cOp3='';
	
	LET cConteo = 0;
	
    LET cnum_serial = 0;
    LET cempresa='';
    LET csucursal='';
    LET cnumcte='';
    LET csecuencia= 0;
    LET cestado='';
    LET crmapa='';
    LET crmapa2='';
    LET crmapa3 ='';
    LET cusuario='';
    LET ctemplate_procesado='';
    LET cmac='';
    LET cip='';
    LET cfecha_alta= MDY('01','01','1900');
    LET cusuario_camb='';
    LET cfecha_camb= MDY('01','01','1900');
    LET cfech_ult_camb = MDY('01','01','1900');
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			--Manejo de errores, en caso de error, envÃ­o codigo de error y guarda evidencia
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_biobex_rostro_sitesp");
								
				LET cMensaje = "ERROR EN LA EJECUCION DEL SP BDD "||cCodRet||"|"||cnumcte||"|"||csucursal;

                RETURN cCodRet, cMensaje, cnumcte, csucursal, cOp1,cOp2, cOp3;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		-- CAMPOS REQUERIDOS TABLA bdinteg:si_cte_rostro --> empresa,estado,num_serial,numcte,secuencia, sucursal
		
		--IF (pempresa <> '' OR pempresa IS NOT NULL) AND (pnumcte <> '' OR pnumcte IS NOT NULL) AND (psucursal <> '' OR psucursal IS NOT NULL) THEN
		
		
		IF  (pnumcte IS NULL OR pnumcte = '') OR (psucursal IS NULL OR psucursal = '') OR (pempresa IS NULL OR pempresa = '') OR (pusuario IS NULL OR pusuario = '') THEN 
			
			LET cCodRet = "00010";
			LET cMensaje = "Datos Obligatorios no Ingresados";
				
		ELSE
			LET cnum_serial = pnum_serial;
			LET cempresa = pempresa;
			LET csucursal = psucursal;
			LET cnumcte = pnumcte;
			LET csecuencia = psecuencia;
			LET cestado = pestado;
			LET crmapa= prmapa;
			LET crmapa2 = prmapa2;
			LET crmapa3 = prmapa3;
			LET cusuario = pusuario;
			LET ctemplate_procesado = ptemplate_procesado;
			LET cmac = pmac;
			LET cip = pip;
			--LET cfecha_alta = pfecha_alta;
			LET cusuario_camb = pusuario_camb;
			--LET cfecha_camb = pfecha_camb;
			--LET cfech_ult_camb = pfech_ult_camb;
			
			LET cMensaje = cusuario||psucursal;
			
			
			EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(1,cempresa,cnumcte,'P',115,'1','S',csucursal,cusuario,cMensaje,NULL,NULL) INTO cCodRet,cOp1,cOp2,cOp3;
			
			-- sp_insertasitesp RETURN cCodRet, sPonderacion,cSituacionCte,sCausaCte;
			
			IF  cCodRet = "00000" THEN
				LET cMensaje = "Ejecucion Exitosa";
		
			ELSE
				LET cMensaje = "Error de sp_insertasitesp";
			END IF;
				
		END IF;
			
		--LET cCodRet = "00000";
		--LET cMensaje = "Ejecucion Exitosa_D";
	
		RETURN cCodRet, cMensaje, cnumcte, csucursal, cOp1,cOp2, cOp3;
	END;
END PROCEDURE;