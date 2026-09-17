CREATE PROCEDURE "informix".sp_consultsolicitudes_cancelaciones_llenainfo(pUsuario CHAR(8), pIdFuncion CHAR(10), pfecha_reg DATE, cod_oper INTEGER)
	RETURNING CHAR(5) AS cCodRet,
			  INTEGER AS iTotSolicitudes;
	 
 --- VARIABLES PARA CACHAR ERROR ---
 DEFINE cSqlerr          INTEGER;
 DEFINE cCodret          CHAR(5);
 DEFINE Cod_ret          CHAR(3);
 
--- VARIABLES QUE RETORNA EL STORE ---
 DEFINE isolicitudes      INTEGER;
 DEFINE cfolio_sol_can    CHAR(30); 
 DEFINE cfech_sol_can     CHAR(8);
 DEFINE cnomb_cte         CHAR(60);
 DEFINE crfc_cte          CHAR(13);
 DEFINE cNumcte           CHAR(10);
 DEFINE ccta_recept       CHAR(20);
 DEFINE ctipo_cta_rec     CHAR(2);
 DEFINE cbco_receptor     CHAR(5);
 DEFINE ccta_ordenante    CHAR(20);
 DEFINE ctipo_cta_orden   CHAR(2);
 DEFINE cbco_orden        CHAR(5);
 DEFINE cnombco_orden     CHAR(20);
 DEFINE cfecha_nac        CHAR(8);
 DEFINE cfolio_solic      CHAR(30); 	 
 DEFINE crfc_emp          CHAR(12);
 DEFINE ccurp_cte         CHAR(18);	 
 DEFINE cEstatus          CHAR(30);
 DEFINE iRegistros        INTEGER;

 --- VARIABLE PARA GUARDAR LAS FECHAS UTILIZADAS---
 DEFINE dtFechaHoy        DATE;
 DEFINE dtFechaFin        DATE;
 DEFINE dtFechaIni        DATE;
 DEFINE dtfecant          DATE;
 DEFINE vfecant           CHAR(8);
 DEFINE vfecha_reg        CHAR(8);
 DEFINE ven_transacc 	  SMALLINT;
 DEFINE iCont 			  INTEGER;
 DEFINE iNumRegistros 	  INTEGER;
 DEFINE bInTransaction    BOOLEAN;
 DEFINE v_FechaultDiaHab  DATE;
 
 --- VARIABLES PARA CACHAR ERROR ---
 LET cSqlerr             = 0;
 LET cCodret             = '00000';
 LET Cod_ret             = '00000';	 
 
 --- VARIABLES QUE RETORNA EL STORE ---
 LET isolicitudes        = 0;
 LET cfolio_sol_can      = '';
 LET cfech_sol_can       = '';
 LET cnomb_cte           = '';
 LET crfc_cte            = '';
 LET cNumcte             = '';  
 LET ccta_recept         = '';
 LET ctipo_cta_rec       = '';
 LET cbco_receptor       = '';
 LET ccta_ordenante      = '';
 LET ctipo_cta_orden     = '';
 LET cbco_orden          = '';
 LET cnombco_orden       = '';
 LET cfecha_nac          = '';
 LET crfc_emp            = '';
 LET ccurp_cte           = '';
 LET cfolio_solic        = '';
 
 LET cEstatus            = '';
 LET iRegistros          = 0;
 LET ven_transacc 		 = 0;
 LET iCont				 = 0;
 LET iNumRegistros 		 = 0;
 LET bInTransaction      = 'f';

 --- VARIABLE PARA GUARDAR LAS FECHAS UTILIZADAS---   
 LET dtFechaHoy  		 = DATE(1);   
 LET dtFechaIni          = DATE(1);
 LET dtfecant            = DATE(1);   
 LET vfecant             = '';   
 LET vfecha_reg          = '';    

BEGIN

		-- Control de Errores no Controlados
        ON EXCEPTION SET cSqlerr
			IF cSqlerr <> 0 THEN
				Let cCodret = cSqlerr;
				
				IF ven_transacc = 1 THEN
					ROLLBACK WORK;		
				END IF;
				
				UPDATE bdicnweb:"informix".status_consulportanomcancelaciones
			    SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
				RETURN cCodret, isolicitudes;
			END IF;
        END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
        --SET DEBUG FILE TO "/RESPALDOSNEW/rsv/portabilidad/TASF/bdicheq/V2/sp_consultsolicitudes_cancelaciones_llenainfo.out";
		--SET DEBUG FILE TO "/resplogifx/conciliachq/portabilidad/22E/sp_consultsolicitudes_cancelaciones_llenainfo.out";
        --TRACE ON;
		
		DELETE FROM bdicnweb:"informix".status_consulportanomcancelaciones WHERE usuario_insert = pUsuario;
		INSERT INTO bdicnweb:"informix".status_consulportanomcancelaciones(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		
        -- //  ENVIA CODIGO DE ERROR SI EXISTE UN PARAMETRO NULO
        IF pUsuario = '' OR pIdFuncion = '' OR NVL(pfecha_reg, "") = "" OR NVL(cod_oper,"") = ""  THEN
            --LET cCodRet = "00002";
			LET cCodRet = "00003";   
			UPDATE bdicnweb:"informix".status_consulportanomcancelaciones
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
            RETURN cCodret, isolicitudes;
        END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE bdicnweb:"informix".status_consulportanomcancelaciones
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,isolicitudes;
		END IF;
       
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		-- // OBTIENE PARAMETRO DE LA FECHA DE HOY
		SELECT fecha_hoy  , ult_dia_mes
		INTO   dtFechaHoy , dtFechaFin
		FROM  "informix".sc_fechas
		WHERE  empresa = '001';
		
		--OBTIENE EL ULTIMO DIA HABIL DEL MES PARA CECOBAN
		EXECUTE PROCEDURE bdicheq:sp_porta_cal_ult_dia_hab('001',dtFechaFin)
		INTO cCodret,v_FechaultDiaHab;  
		
		  
	    -- // ENVIA CODIGO DE ERROR SI LA FECHA ESTA MAS DE 5 DIAS ATRAS O ES UNA FECHA  FUTURA
		LET dtFechaIni = dtFechaHoy - 5 UNITS DAY;    --  La consulta se realiza 5 dias atras.         
		IF pfecha_reg < dtFechaIni OR pfecha_reg > dtFechaHoy THEN
			--LET cCodRet = "00003";
			LET cCodRet = '00232';
			UPDATE bdicnweb:"informix".status_consulportanomcancelaciones
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodret, isolicitudes;
		END IF;   
   
		--// PONE EN VARIABLES LA FECHA SOLICITADA Y EL DIA ANTERIOR DE LA MISMA
		LET vfecha_reg = YEAR(pfecha_reg)||LPAD(MONTH(pfecha_reg),2,0)||LPAD(DAY(pfecha_reg),2,0);
		LET dtfecant = pfecha_reg - 5 UNITS DAY;       
		LET vfecant=   YEAR(dtfecant)||LPAD(MONTH(dtfecant),2,0)||LPAD(DAY(dtfecant),2,0);
	   
		
		IF dtFechaHoy = v_FechaultDiaHab THEN -- SI ES FIN DE MES CONSULTA LAS CANCELACIONES NORMALES MAS LAS DE LA NUEVA FUNCIONALIDAD
		    
			--IDENTIFICA LAS PORTABILIDADES QUE SE VAN A CANCELAR DE FORMA AUTOMATICA
		    EXECUTE PROCEDURE "informix".sp_porta_identifica_can_auto('001') INTO cCodret; 
		    IF cCodRet <> '000' THEN
				RETURN cCodRet, isolicitudes;
		    END IF;
		   
		   	IF cod_oper = 22  THEN
       
					BEGIN;
						TRUNCATE TABLE "informix".sc_portacec_archivotemp_cancelaciones;
					COMMIT;
					
					BEGIN WORK;
					LET ven_transacc = 1;
 					
					FOREACH WITH HOLD
					
						SELECT folio_cancelacion,fecha_solca_portabilidad,num_cte,cta_receptora,tipo_cta_receptora,
							   bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,rfc_empresa,folio_solicitud
						INTO cfolio_sol_can, cfech_sol_can, cNumcte, ccta_recept, ctipo_cta_rec,
						     cbco_receptor, ccta_ordenante, ctipo_cta_orden, cbco_orden,crfc_emp, cfolio_solic
					    FROM (
							SELECT ps.folio_cancelacion,ps.fecha_solca_portabilidad,ps.num_cte,ps.cta_receptora,ps.tipo_cta_receptora,
								   ps.bco_receptor,ps.cta_ordenante,ps.tipo_cta_ordenante,ps.bco_ordenante,ps.rfc_empresa,ps.folio_solicitud   
							FROM "informix".sc_portacec_solicitud ps
							LEFT JOIN "informix".sc_portacec_bitacora_cancelaciones psc ON ps.folio_cancelacion = psc.folio_cancelacion
							WHERE ps.fecha_solca_portabilidad BETWEEN vfecant AND vfecha_reg             
							AND ps.clave_origen IN ('1','2')
							AND ps.clave_sentido = '0'
							AND ps.estatus_portabilidad = '4'
							AND ps.bco_ordenante = '40137'
							AND ps.cod_operacion = '21'
							AND psc.folio_cancelacion IS NULL
							AND ps.folio_cancelacion IS NOT NULL
							
							UNION ALL
					
							SELECT psc.folio_cancela,psc.fecha_cancela,num_cte,cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,
							       tipo_cta_ordenante,bco_ordenante,rfc_empresa,folio_solicitud   
							FROM   "informix".sc_portacec_solicitud ps
							INNER JOIN "informix".sc_porta_cancel_auto psc ON ps.cta_ordenante = psc.porta_cuenta_clabe
							WHERE ps.estatus_portabilidad = '1'
							AND ps.bco_ordenante = '40137'         
							AND ps.clave_origen IN ('1','2','3') 
							AND ps.clave_sentido = '1'             
							AND ps.cod_operacion IN ('20','21')
							AND ps.folio_solicitud  NOT IN (SELECT folio_solicitud FROM sc_portacec_bitacora_cancelaciones)
							)
						
						SELECT TRIM (apell_paterno)||' '||TRIM(apell_materno)||' '||TRIM(nombre1)||' '||TRIM(nombre2) AS nombre_cte, rfc
						INTO cnomb_cte, crfc_cte
                        FROM bdinteg:"informix".si_cliente cte
                        WHERE cte.empresa = '001'
						AND cte.numcte = cNumcte;
						
						SELECT YEAR(fecha_nac)||LPAD(MONTH(fecha_nac),2,0)||LPAD(DAY(fecha_nac),2,0) AS fecha_nacimiento, curp
						INTO cfecha_nac, ccurp_cte
						FROM bdinteg:"informix".si_ctepf cte
						WHERE cte.numcte = cNumcte;
						
						--->
						SELECT {+INDEX (bdinteg:"informix".si_bancos idx_banco)} vchrnombrecorto
						INTO cnombco_orden
						FROM bdinteg:"informix".si_bancos
						WHERE cvecesif = cbco_orden;
						---<
						
						LET iNumRegistros = iNumRegistros + 1;
						
						INSERT INTO "informix".sc_portacec_archivotemp_cancelaciones (secuencia,folio_cancelacion,fecha_solca_portabilidad,nombre_cte,rfc_cte,cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,fecha_nacimiento,rfc_empresa,estatus_respuesta,fecha_respuesta,curp_cte,folio_solicitud,numcte,nombre_bco_ordenante)                      
						VALUES (iNumRegistros, cfolio_sol_can, cfech_sol_can, cnomb_cte, crfc_cte, ccta_recept, ctipo_cta_rec, cbco_receptor, ccta_ordenante, ctipo_cta_orden, cbco_orden, cfecha_nac, crfc_emp, '00', '00000000', ccurp_cte, cfolio_solic, cNumcte, cnombco_orden );
						
						
						LET iCont = iCont + 1;
						
						IF iCont >= 5000 THEN
							LET iCont = 0;
							COMMIT WORK;
							BEGIN WORK;
						END IF;
						
					END FOREACH;
					
					COMMIT WORK;

			ELSE

				LET cCodRet = '00371';
				UPDATE bdicnweb:"informix".status_consulportanomcancelaciones
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodret, isolicitudes;
				
			END IF 
		 
		ELSE -- SI NO ES FIN DE MES, ENTONCES PROCESA  SOLO LAS PORTABILIDADES NORMALES 
		   
		   IF cod_oper = 22  THEN 
					BEGIN;
						TRUNCATE TABLE "informix".sc_portacec_archivotemp_cancelaciones;
					COMMIT;
					
					BEGIN WORK;
					LET ven_transacc = 1;
 					
					FOREACH WITH HOLD

							SELECT ps.folio_cancelacion,ps.fecha_solca_portabilidad,ps.num_cte,ps.cta_receptora,ps.tipo_cta_receptora,
								   ps.bco_receptor,ps.cta_ordenante,ps.tipo_cta_ordenante,ps.bco_ordenante,ps.rfc_empresa,ps.folio_solicitud   
							INTO   cfolio_sol_can, cfech_sol_can, cNumcte, ccta_recept, ctipo_cta_rec,
						           cbco_receptor, ccta_ordenante, ctipo_cta_orden, cbco_orden,crfc_emp, cfolio_solic
							FROM "informix".sc_portacec_solicitud ps
							LEFT JOIN "informix".sc_portacec_bitacora_cancelaciones psc ON ps.folio_cancelacion = psc.folio_cancelacion
							WHERE ps.fecha_solca_portabilidad BETWEEN vfecant AND vfecha_reg             
							AND ps.clave_origen IN ('1','2')
							AND ps.clave_sentido = '0'
							AND ps.estatus_portabilidad = '4'
							AND ps.bco_ordenante = '40137'
							AND ps.cod_operacion = '21'
							AND psc.folio_cancelacion IS NULL
							AND ps.folio_cancelacion IS NOT NULL
						
						SELECT TRIM (apell_paterno)||' '||TRIM(apell_materno)||' '||TRIM(nombre1)||' '||TRIM(nombre2) AS nombre_cte, rfc
						INTO cnomb_cte, crfc_cte
                        FROM bdinteg:"informix".si_cliente cte
                        WHERE cte.empresa = '001'
						AND cte.numcte = cNumcte;
						
						SELECT YEAR(fecha_nac)||LPAD(MONTH(fecha_nac),2,0)||LPAD(DAY(fecha_nac),2,0) AS fecha_nacimiento, curp
						INTO cfecha_nac, ccurp_cte
						FROM bdinteg:"informix".si_ctepf cte
						WHERE cte.numcte = cNumcte;
						
						--->
						SELECT {+INDEX (bdinteg:"informix".si_bancos idx_banco)} vchrnombrecorto
						INTO cnombco_orden
						FROM bdinteg:"informix".si_bancos
						WHERE cvecesif = cbco_orden;
						---<
						
						LET iNumRegistros = iNumRegistros + 1;
						
						INSERT INTO "informix".sc_portacec_archivotemp_cancelaciones (secuencia,folio_cancelacion,fecha_solca_portabilidad,nombre_cte,rfc_cte,cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,fecha_nacimiento,rfc_empresa,estatus_respuesta,fecha_respuesta,curp_cte,folio_solicitud, numcte, nombre_bco_ordenante)                      
						VALUES (iNumRegistros, cfolio_sol_can, cfech_sol_can, cnomb_cte, crfc_cte, ccta_recept, ctipo_cta_rec, cbco_receptor, ccta_ordenante, ctipo_cta_orden, cbco_orden, cfecha_nac, crfc_emp, '00', '00000000', ccurp_cte, cfolio_solic, cNumcte, cnombco_orden );
						
						LET iCont = iCont + 1;
						
						IF iCont >= 5000 THEN
							LET iCont = 0;
							COMMIT WORK;
							BEGIN WORK;
						END IF;
						
					END FOREACH;
					
					COMMIT WORK;

			ELSE
			
                --CODIGO DE OPERACION INVALIDO
				LET cCodRet = '00371';
				UPDATE bdicnweb:"informix".status_consulportanomcancelaciones
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodret, isolicitudes;
										   
			END IF -- VERIFICA SI EL CODIGO ES CORRECTO (22)

        END IF;   
       
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00021';
			LET ven_transacc = 0;
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
			
			UPDATE bdicnweb:"informix".status_consulportanomcancelaciones
		    SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
			RETURN cCodret, isolicitudes;
		END IF
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		UPDATE bdicnweb:"informix".status_consulportanomcancelaciones
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario;
		
		RETURN cCodret, iNumRegistros;
   
END
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃÂ³n Amador',
'FECHA: 09/10/2019',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: SOLICITUDES PORTABILIDAD', 
'DESCRIPCION: Se modifica SPL para implementar mejoras en querys ya existentes.',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 03/12/2019',
'DESCRIPCION: Se modifica SPL para agregar columnas de numero de cliente y banco ordenante para mostrar en grid',
'BD: bdicheq';

create procedure "informix".liberasalret(pempresa char(3), pejecutivo char(10))
returning char(5);
    
    -- **********************************************************
    -- *        Programa que libera los cheques retenidos       *
    -- *            Autor : Cristian Campos diaz                *
    -- *            Fecha : 06/Septiembre/2007                  *
    -- *            Ver.  : 1.0                                 *
    -- **********************************************************

    define vdias_ret            integer;
    define vdia_res             integer;
    define vmonto               money(14,2);
    define vfecha_alta          date;
    define vnum_chq             integer;
    define vtransacc            char(4);
    define vmonto_ori           money(14,2);
    define vnumero              char(4);
    define vsistema             char(2);
    define vfecha_hoy           date;
    define vfecha_ant           date;
    define vfechab_ant          date;
    define vcuenta              char(20);
    define vcancelado           char(1);
    --- define vrowid               integer;
    define vcodret              char(5);
    define vcodret2             char(5);
    define vcodret3             char(50);
    define vsqlerr              integer;
    define visamerr             integer;
    define vdescerr             char(50);
    define vconproc             integer;
    define vproceso             char(20);
    define vexiste              integer;
    define vexistefin           integer;
    define vRetenido            DECIMAL(14,2);
    define vabierto             CHAR(1);
    define vcomienza            INTEGER;
    define vsql                 char(600);
    define vstmt                char(250);
    define vmincta              char(20);
    define vmaxcta              char(20);
    define vexisteproc          char(12);
    define vcodretsbg1          char(5);
    define vcodretsbg2          char(5);
    define vcontsbg1            integer;
    define vcontsbg2            integer;
    define vcodret_libinterpza  char(5);
    define vcodret_pasamovsret  char(5);
    define vfolio_suc           char(16);
    define vcodret_libspei      char(5);

    let vcodret   = "000";
    let vcodret2  = "000";
    let vcodret3  = "";
    let vsqlerr   = 0;
    let visamerr  = 0;
    let vdescerr  = "";
    let vconproc  = 0;
    let vproceso  = "libsalretchq";
    let vsistema  = "01";
    let vRetenido = 0;
    let vabierto  = "0";
    let vcomienza = -1;
    let vsql      = '';
    let vstmt     = '';
    let vcodretsbg1 = '';
    let vcodretsbg2 = '';
    let vcontsbg1   = 0;
    let vcontsbg2   = 0;
    let vcodret_libinterpza = '';
    let vcodret_pasamovsret = '';
    let vfolio_suc = '';
    let vcodret_libspei = '';

    --- set debug file to "/DBA/INC/20220610/liberatranret.out";
    --- trace on;
    
    BEGIN

    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "liberatranret.err";
        trace on;
        if vsqlerr <> 0  then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||pejecutivo||''', '||
                       'status_proc   = '''||'C'||''', '||
                       'codret        = '''||vcodret||''', '||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaslibsalret.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
            SYSTEM vstmt;
            
            if vabierto = "1" then
                ROLLBACK WORK;
            end if;
            return vcodret;
        end if;
    end exception;
    
    set isolation to dirty read;
    set lock mode to wait 3;
    
    select fecha_hoy, fecha_ant
      into vfecha_hoy, vfecha_ant 
      from sc_fechas  
     where empresa = pempresa;
     
    -- // VALIDA HAYA FINALIZADO CIERRE DE CAPTACION
    select proceso
      into vexisteproc
      from sc_contproc
     where empresa = pempresa
       and proceso = 'cierre'
       and fecha = vfecha_ant;
    
    if vexisteproc is null or vexisteproc = '' then
        let vcodret = "962";       
        return vcodret;
    END IF
    
    -- // VERIFICA CONTROL DE PROCESOS EN INTEGRAL
    select count(*)   
      into vexiste
      from bdinteg:sx_contproc  
     where empresa = pempresa  
       and proceso = vproceso
       and fecha   = vfecha_hoy
       and sistema = vsistema;

    if vexiste = 0 then
        let vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||pejecutivo||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horaslibsalret.sql';
        SYSTEM vsql;
        
        let vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
        SYSTEM vstmt;
    else
        select count(*)   
          into vexistefin
          from bdinteg:sx_contproc  
         where empresa     = pempresa  
           and proceso     = vproceso
           and fecha       = vfecha_hoy
           and sistema     = vsistema
           and status_proc = "F"; 

        if vexistefin = 0 then
            let vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||pejecutivo||''', '||
                       'status_proc   = '''||'I'||''', '||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaslibsalret.sql';
            SYSTEM vsql;
            
            let vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
            SYSTEM vstmt;
        else
            let vcodret = "971";
            
            -- // VERIFICA CONTROL DE PROCESOS EN CHEQUES
            select count(*) 
              into vconproc
              from sc_contproc
             where empresa = pempresa
               and proceso = vproceso
               and fecha = vfecha_hoy;

            if vconproc > 0 then
                if vabierto = 1 then
                    ROLLBACK WORK;  
                end if;
                
                return vcodret;
            end if;     
        end if
    end if; 
    
    execute procedure cal_habil_ant(vfecha_hoy) 
    into vcodret, vfechab_ant;

    if vcodret <> "000" then
        if vabierto = 1 then
            ROLLBACK WORK;  
        end if;
        
        let vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||pejecutivo||''', '||
                   'status_proc   = '''||'C'||''', '||
                   'codret        = '''||vcodret||''', '||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horaslibsalret.sql';
        SYSTEM vsql;
        
        let vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
        SYSTEM vstmt;
        
        return vcodret;
    end if;  

    select min(cuenta), max(cuenta)
      into vmincta, vmaxcta
      from sc_docret;
	  
	select numero from bdinteg:si_transacc
	where empresa = "001"
	and sistema = "01"
	and numero like "08%"
	and tipo_tran in ("20","21","22")
	and naturaleza = "C"
	into temp tmp_tran_pos with no log;

	create index indx_temp_tran_pos on tmp_tran_pos(numero);
    
    foreach principal with hold for

        select numero
          into vnumero
          from tmp_tran_pos
		order by numero
        
        foreach with hold
            select {+INDEX(sc_docret idx_docret2)}
                   /*rowid,*/ cuenta, transacc, dias_ret, monto, fecha_alta, cancelado, num_chq, monto_ori, folio_suc
              into /*vrowid,*/ vcuenta, vtransacc, vdias_ret, vmonto, vfecha_alta, vcancelado, vnum_chq, vmonto_ori, vfolio_suc
              from sc_docret
             where cuenta between vmincta and vmaxcta
               and transacc = vnumero
               and cancelado = 'P'
               and (vfecha_hoy - fecha_alta) >= dias_ret 
               
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                BEGIN WORK;
                LET vabierto = "1";
            END IF;
            
            SELECT sdo_retenido
              INTO vRetenido
              FROM sc_maechq
             where empresa = pempresa
               and cuenta = vcuenta;

            LET vRetenido = vRetenido - vmonto;	

            IF vRetenido >= 0 THEN
                update sc_maechq
                   set sdo_retenido = sdo_retenido - vmonto
                 where empresa = pempresa
                   and cuenta = vcuenta;
            ELSE
                update sc_maechq
                   set sdo_retenido = 0
                 where empresa = pempresa
                   and cuenta = vcuenta;
            END IF
            
            update sc_docret
               set cancelado = "L",
                   dias_ret = 0
             where cuenta = vcuenta
               and transacc = vtransacc
               and cancelado = 'P'
               and fecha_alta = vfecha_alta
               and num_chq = vnum_chq
               and monto_ori = vmonto_ori
               and folio_suc = vfolio_suc;
               --- and rowid = vrowid;
               
            IF vabierto = 1 THEN
                COMMIT WORK;
                BEGIN WORK;
            END IF;

        end foreach;

    end foreach;
    
    IF vabierto = 1 THEN
        COMMIT WORK;
    END IF;
    
    -- // REALIZA LIBERACION DE RETENIDOS INTERPLAZA
    --execute procedure "informix".sp_liberaretinterpza(pempresa)
    --into vcodret_libinterpza;
    
    -- // REALIZA LIBERACION DE RETENIDOS SPEI
    --execute procedure "informix".sp_liberaretspei(pempresa)
    --into vcodret_libspei;
    
    -- // REALIZA COBRO DE SOBREGIROS
    --execute procedure "informix".sp_cobrosbg(pempresa)
    --into vcodretsbg1, vcodretsbg2, vcontsbg1, vcontsbg2;
    
    -- // REALIZA DEPURACION DE MOVS POS 
    --execute procedure "informix".sp_pasamovsret(pempresa)
    --into vcodret_pasamovsret;

    -- // REGISTRA FINALIZACION DEL PROCESO
    update sc_contproc
       set fecha = vfecha_hoy
     where empresa = pempresa
       and proceso = vproceso;

    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET ejecutivo = '''||pejecutivo||''', '||
               'status_proc   = '''||'F'||''', '||
               'codret        = '''||vcodret||''', '||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horaslibsalret.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
    SYSTEM vstmt;
    
    return vcodret;

    END;

end procedure;