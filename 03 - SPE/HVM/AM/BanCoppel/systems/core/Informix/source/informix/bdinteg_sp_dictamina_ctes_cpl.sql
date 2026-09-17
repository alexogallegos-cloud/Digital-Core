CREATE PROCEDURE "informix".sp_dictamina_ctes_cpl(pFecha DATE)
	--DATOS A REGRESAR---
	RETURNING
	CHAR(5)   AS CodigoRetorno,
	CHAR(100) AS TramaSalida;

	--DEFINICION DE VARIABLES--
	DEFINE iSql_err	  INTEGER;
	DEFINE cCodRet	  CHAR(5);	
	DEFINE cCadena	  CHAR(100);	
	
	DEFINE cNumCte	  CHAR(20);
	DEFINE cNumCteAct CHAR(20);
	DEFINE iCliente   INTEGER;
	DEFINE iCont   	  INTEGER;
	DEFINE sCont   	  INTEGER;
	DEFINE cNumCteDesm	  CHAR(9);
	DEFINE cNomCteDesm	  CHAR(50);
	DEFINE cSituacionCte		CHAR(1);
	DEFINE sCausaCte		SMALLINT;
	--INICIALIZACION DE VARIABLES--
	LET iSql_err 	= 0;
	LET cCodRet		= '00000';	
	LET cCadena		= '';

	LET cNumCte		= '';	
	LET cNumCteAct	= '';
	LET iCliente	= 0;
	LET iCont	= 0;
	LET sCont	= 0;
	LET cNumCteDesm		= '';
	LET cNomCteDesm		= '';
	LET cSituacionCte = '';
	LET sCausaCte =0;


	--SET DEBUG FILE TO "/informix/jfponce/sp_dictamina_ctes_cpl.out";
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN cCodRet, cCadena;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		--status_alerta 1.- pendiente, 2.- atendiendo, 3.- concluida
		--origen 1.-sucursal 2.-ValidaciÃ³n 3.- MAntenimiento de huellas
		--empresa 1.-Empleado 4.- cliente Coppel 5.- Cliente Bancoppel
			-- Ejecucion especial para limpiar U 61 a solicitud de SOS
			IF pFecha == '01-01-2099' THEN
			
				BEGIN WORK;
				
				FOREACH WITH HOLD
					
					SELECT numcte,nomcte INTO cNumCteDesm,cNomCteDesm FROM tmp_ctes_desmarque WHERE numcte!=''
					
					LET cNomCteDesm=TRIM(cNomCteDesm);
					--Se busca la situacion especial actual del cliente
					IF EXISTS (SELECT * FROM bdisitesp:"informix".se_ctessitespcte WHERE numcte=cNumCteDesm) THEN
						
						SELECT situacion,causa 
						INTO cSituacionCte,sCausaCte
						FROM bdisitesp:"informix".se_ctessitespcte 
						WHERE numcte = cNumCteDesm;
						
						--cambio de situacion especial a U 65
						UPDATE bdisitesp:"informix".se_ctessitespcte SET situacion = 'U',causa = 65,usrmodifica ='informix',fchmodifica= current ,motivo_desmarcaje= 'Por solicitud del area SOS'  
						WHERE numcte = cNumCteDesm;
						
						--Se inserta en bitacora.
						INSERT INTO bdisitesp:"informix".se_btccamsitespcte(numcte,situacionant, causaant,situacionact,causaact,nombresolicito,usrmodifica,fchmodifica,motivo_desmarcaje)
						VALUES(cNumCteDesm, cSituacionCte, sCausaCte, 'U', '65', cNomCteDesm,'informix',current , 'Por solicitud del area SOS');					
						--Si existe alerta pendiente, la marca como atendida.
						IF EXISTS (SELECT * FROM "informix".si_bitacora_comparaciones WHERE numcte=cNumCteDesm AND status_alerta!='3') THEN
							UPDATE "informix".si_bitacora_comparaciones set status_alerta = '3', analista_fraudes='90048480' WHERE numcte = cNumCteDesm;					
						END IF;
						
						LET iCont= iCont + 1;
						LET sCont = sCont + 1;
						
						IF sCont = 1000 THEN
							COMMIT WORK;
							LET sCont = 0;
							BEGIN WORK;
						END IF;
					END IF;		
				END FOREACH;
				COMMIT WORK;
				LET cCodRet  = '00000';
				LET cCadena='Se actualizaron '||iCont||' clientes';
				RETURN cCodRet, cCadena;
			ELSE
				FOREACH
					
					SELECT numcte INTO cNumCte FROM "informix".si_bitacora_comparaciones WHERE 
					fecha_insert::DATE = pFecha AND origen='2' AND status_alerta='1'
					
					
					SELECT limit 1 sit.numcte,res.cliente
					INTO cNumCteAct,iCliente
					FROM bdisitesp:"informix".se_ctessitespcte sit, "informix".si_huella_linea lin,	"informix".si_huella_linea_resultado res
					WHERE sit.numcte=cNumCte and sit.situacion = 'U' AND sit.causa = 62 AND sit.empresa = '001'
					AND lin.numcte = sit.numcte	AND lin.status_consulta = '3' AND lin.ticket = res.ticket and res.empresa='4' and res.num_mensaje='602';
					
					IF (TRIM(cNumCteAct)!='' AND iCliente>0 ) THEN
						--MATCH CON CLIENTE COPPEL PASA A U-65 (CLIENTE REVISADO)
						UPDATE bdisitesp:"informix".se_ctessitespcte set situacion = 'U',causa = '65',usrmodifica ='informix',fchmodifica= current ,motivo_desmarcaje= 'Por solicitud del area SOS'  
						WHERE numcte = cNumCteAct;
						
						INSERT INTO bdisitesp:"informix".se_btccamsitespcte(numcte,situacionant, causaant,situacionact,causaact,nombresolicito,usrmodifica,fchmodifica,motivo_desmarcaje)
						VALUES(TRIM(cNumCteAct), 'U', '62', 'U', '65', 'Maria Guadalupe Armenta Quintero','informix',current , 'Por solicitud del area SOS');
						
						UPDATE "informix".si_bitacora_comparaciones set status_alerta = '3', analista_fraudes='90048480' WHERE fecha_insert::DATE=pFecha AND numcte = cNumCteAct;					
						
						LET iCont=iCont+1;
						
					END IF;
						
					LET cNumCteAct='';
					LET iCliente='';
					
				END FOREACH;
			
			END IF;
	END
	
	LET cCadena='Se actualizaron '||iCont||' Clientes';
	
	RETURN cCodRet, cCadena;

END PROCEDURE

DOCUMENT
'FECHA=20210512',
'Autor:JUAN PONCE',
'Descripcion: Proceso para dictaminar clientes pendiente de revisiÃ³n por hacer match con clientes coppel a solicitud de SOS',
'FECHA=20220505',
'Autor:JUAN PONCE',
'Descripcion: se integra proceso para dictamen masivo a partir de los registros almacenas con la tabla temporal tmp_ctes_desmarque';

CREATE PROCEDURE "informix".sp_obtenerdoctos(pNumeroCliente CHAR(20), inicia  smallint,pnum_regs  smallint)
RETURNING CHAR(5), CHAR(4), CHAR(35), CHAR(20), SMALLINT, CHAR(10),CHAR(50);
--DECLARACION DE VARIABLES
DEFINE vc_CodRet    CHAR(5);
DEFINE vc_CodDocto  CHAR(4);
DEFINE vc_DesDocto  CHAR(35);
DEFINE vc_Cuenta    CHAR(20);
DEFINE vs_Secuencia SMALLINT;
DEFINE vs_Fecha     DATE;
DEFINE vs_descrip   CHAR(50);
DEFINE vi_SqlErr    INTEGER;
DEFINE v_contador        smallint;
--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vc_CodDocto = "";
LET vc_DesDocto = "";
LET vc_Cuenta = "";
LET vi_SqlErr = 0;
LET vs_Secuencia = 0;
LET vs_Fecha=today;
LET vs_descrip="";
LET v_contador= 0;

  --SET DEBUG FILE TO "/tmp/sp_obtenerdoctos.out";
  --TRACE ON;

BEGIN

  ON EXCEPTION SET vi_SqlErr
    IF vi_SqlErr <> 0 THEN
        LET vc_CodRet = vi_SqlErr;
        RETURN vc_CodRet, vc_CodDocto, vc_DesDocto, vc_Cuenta, vs_Secuencia,vs_Fecha,vs_descrip;
    END IF;
  END EXCEPTION;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   FOREACH
        SELECT exp.cod_docto, exp.cuenta, exp.secuencia,docto.descripcion,exp.fecha_alta,exp.descrip2
        INTO vc_CodDocto, vc_Cuenta, vs_Secuencia, vc_DesDocto,vs_Fecha,vs_descrip
        FROM bdidigital@coppelimg_tcp:dg_expediente exp,
        bdidigital@coppelimg_tcp:dg_tipodocumento docto,bdidigital@coppelimg_tcp:dg_grupodocto gd
        WHERE cliente = pNumeroCliente 
        -- WHERE cliente = pNumeroCliente and exp.empresa='001'
        and exp.cod_docto=docto.cod_docto
        and docto.cod_grupo= gd.cod_grupo
		and gd.cod_grupo 
        NOT IN (select MAX(cod_grupo) 
        from bdidigital@coppelimg_tcp:dg_tipodocumento 
        where cod_docto IN ('0133')) 
        and gd.cod_grupo 
        NOT IN (select MAX(cod_grupo) 
        from bdidigital@coppelimg_tcp:dg_tipodocumento 
        where cod_docto IN ('0201')) 
        and gd.cod_grupo 
        NOT IN (select MAX(cod_grupo) 
        from bdidigital@coppelimg_tcp:dg_tipodocumento 
        where cod_docto IN ('0938')) 
		UNION
        SELECT exp.cod_docto, exp.cuenta, exp.secuencia,docto.descripcion,exp.fecha_alta,exp.descrip2
        FROM bdidigital@coppelimg_tcp:dg_expediente exp,
        bdidigital@coppelimg_tcp:dg_tipodocumento docto,bdidigital@coppelimg_tcp:dg_grupodocto gd
        WHERE cliente = pNumeroCliente
        and exp.cod_docto=docto.cod_docto
        and docto.cod_grupo= gd.cod_grupo

        let v_contador = v_contador +1;
        
            IF v_contador > pnum_regs then
                    CONTINUE FOREACH;
            END IF; 
     if v_contador>inicia then      
        RETURN vc_CodRet, vc_CodDocto, vc_DesDocto, vc_Cuenta, vs_Secuencia,vs_Fecha,vs_descrip WITH RESUME;    
     end if
    END FOREACH;
    
    if v_contador=0 then
        LET vc_CodRet = "00100";
        RETURN vc_CodRet, vc_CodDocto, vc_DesDocto, vc_Cuenta, vs_Secuencia,vs_Fecha,vs_descrip;
    END IF;
END;
END PROCEDURE;