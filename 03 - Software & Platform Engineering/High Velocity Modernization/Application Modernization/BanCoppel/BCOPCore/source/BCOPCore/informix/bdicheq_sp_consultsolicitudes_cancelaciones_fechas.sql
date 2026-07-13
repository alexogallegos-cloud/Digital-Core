CREATE PROCEDURE "informix".sp_consultsolicitudes_cancelaciones_fechas( pfecha_reg date, dtfecant date ,cod_oper integer, no_pag integer, pregistros integer)
RETURNING CHAR(5),
 integer,
 CHAR(30),
 CHAR(10),
 CHAR(20),
 CHAR(30),
 integer;
 
 
 --#####################################################
 ----  DEFICIÓN DE VARIABLES  GENERALES---
 --#####################################################
 
 --- VARIABLES PARA CACHAR ERROR ---
 DEFINE cSqlerr           INTEGER;
 DEFINE cCodret           CHAR(5);
 DEFINE Cod_ret           CHAR(3);
 
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
 DEFINE iRegistros         INTEGER;

 --- VARIABLE PARA GUARDAR LAS FECHAS UTILIZADAS---
 DEFINE dtFechaHoy        DATE;
 DEFINE dtFechaIni        DATE;
 DEFINE vfecant           CHAR(8);
 DEFINE vfecha_reg        CHAR(8);
 
--########################################################
 ----  INICIALIZAR  VARIABLES  GENERALES ---
--########################################################
 
  --- VARIABLES PARA CACHAR ERROR ---
 LET cSqlerr             = 0;
 LET cCodret             = '';
 LET Cod_ret            = '';
 
 
  --- VARIABLES QUE RETORNA EL STORE ---
 LET isolicitudes        = 0;
 LET cfolio_sol_can          = '';
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
 LET iRegistros             = 0;
    

 --- VARIABLE PARA GUARDAR LAS FECHAS UTILIZADAS---   
 LET dtFechaHoy  = DATE(1);   
 LET dtFechaIni  = DATE(1); 
 LET vfecant             = '';   
 LET vfecha_reg          = '';    
   
    BEGIN
   
    ------  Control de Errores no Controlados
        ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;   
            RETURN cCodret, isolicitudes, cfolio_sol_can,cNumcte,cnombco_orden,cEstatus, iRegistros;
        END IF;
        END EXCEPTION;
       
       
        --SET DEBUG FILE TO "/informix/VILLELA/sp_consultsolicitudes_cancelaciones_fechas.out";
        --TRACE ON;
       
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
 
    -- //  ENVIA CODIGO DE ERROR SI EXISTE UN PARAMETRO NULO
 
        IF NVL(pfecha_reg, "") = "" OR NVL(cod_oper,"") = "" OR NVL(no_pag,"") = "" OR NVL(pregistros,"") = ""  THEN
            LET cCodRet = "00002";   
            RETURN cCodret, isolicitudes, cfolio_sol_can,cNumcte,cnombco_orden,cEstatus, iRegistros;
        END IF;
       
       
 
            --// PONE EN VARIABLES LA FECHA SOLICITADA Y EL DIA ANTERIOR DE LA MISMA
   
            LET vfecha_reg = YEAR(pfecha_reg)||LPAD(MONTH(pfecha_reg),2,0)||LPAD(DAY(pfecha_reg),2,0);
                       
                
            LET vfecant=   YEAR(dtfecant)||LPAD(MONTH(dtfecant),2,0)||LPAD(DAY(dtfecant),2,0);
           
       
        IF cod_oper=22  THEN
       
           
            IF no_pag =0  THEN
       
                -- //LIMPIAR LAS TABLAS TEMPORALES
                    DELETE FROM sc_portacec_archivotemp_cancelaciones;
                    CREATE sequence myseq;
                       
                    INSERT into  sc_portacec_archivotemp_cancelaciones (secuencia,folio_cancelacion,fecha_solca_portabilidad,nombre_cte,rfc_cte,cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,fecha_nacimiento,rfc_empresa,estatus_respuesta,fecha_respuesta,curp_cte,folio_solicitud)                      
                    SELECT myseq.nextval, folio_cancelacion,fecha_solca_portabilidad,
                    (SELECT trim (apell_paterno)||' '||trim(apell_materno)||' '||trim(nombre1)||' '||trim(nombre2)
                    FROM bdinteg:si_cliente cte
                    where cte.numcte =  ps.num_cte) as nombre_cte,
                    (SELECT rfc
                    FROM bdinteg:si_cliente cte
                    where cte.numcte =  ps.num_cte) as rfc_cte,    
                    cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,
                    (select YEAR(fecha_nac)||LPAD(MONTH(fecha_nac),2,0)||LPAD(DAY(fecha_nac),2,0)
                    from bdinteg:si_ctepf cte
                   where cte.numcte =  ps.num_cte) as fecha_nacimiento,
                   rfc_empresa,'00' as estatus_respuesta, '00000000' as fecha_respuesta,
                   (select curp
                   from bdinteg:si_ctepf cte
                   where cte.numcte =  ps.num_cte) as curp_cte,
                   folio_solicitud
                   from sc_portacec_solicitud ps
                   WHERE fecha_solca_portabilidad    BETWEEN vfecant and vfecha_reg             
                   	and  clave_origen in ('1','2')
					and  clave_sentido='0'
					and estatus_portabilidad='4'
					and bco_ordenante='40137'
					and cod_operacion='21'
                   and folio_cancelacion not in (SELECT folio_cancelacion
                   FROM sc_portacec_bitacora_cancelaciones);
       
                   
                      SELECT COUNT(*)
                      INTO iRegistros
                      FROM sc_portacec_archivotemp_cancelaciones;   

                     
                     DROP sequence myseq;
               
                       
                     foreach
               
               
                     SELECT  SKIP no_pag FIRST pregistros folio_cancelacion,fecha_solca_portabilidad,
                    (SELECT trim (apell_paterno)||' '||trim(apell_materno)||' '||trim(nombre1)||' '||trim(nombre2)
                    FROM bdinteg:si_cliente cte
                    where cte.numcte =  ps.num_cte) as nombre_cte,
                    (SELECT rfc
                    FROM bdinteg:si_cliente cte
                    where cte.numcte =  ps.num_cte) as rfc_cte,
                    num_cte,           
                    cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,
                    (select vchrnombrecorto
                    from bdinteg:si_bancos
                    where cvecesif= bco_ordenante) as bco_ordenante,
                    (select YEAR(fecha_nac)||LPAD(MONTH(fecha_nac),2,0)||LPAD(DAY(fecha_nac),2,0)
                    from bdinteg:si_ctepf cte
                    where cte.numcte =  ps.num_cte) as fecha_nacimiento,
                    rfc_empresa,
                    (select curp
                    from bdinteg:si_ctepf cte
                    where cte.numcte =  ps.num_cte) as curp_cte,
                    folio_solicitud
                    into cfolio_sol_can,cfech_sol_can,cnomb_cte,crfc_cte,cNumcte,ccta_recept,ctipo_cta_rec,cbco_receptor,ccta_ordenante, ctipo_cta_orden, cbco_orden, cnombco_orden,cfecha_nac, crfc_emp,ccurp_cte,cfolio_solic                       
                    from sc_portacec_solicitud ps
                    WHERE fecha_solca_portabilidad    BETWEEN vfecant and vfecha_reg             
                    and  clave_origen in ('1','2')
					and  clave_sentido='0'
					and estatus_portabilidad='4'
					and bco_ordenante='40137'
					and cod_operacion='21'
                    and folio_cancelacion not in (SELECT folio_cancelacion
                    FROM sc_portacec_bitacora_cancelaciones)
               
                       
                      LET isolicitudes= isolicitudes+1;
                        if isolicitudes <>0 then
                            LET cCodret='00000';   
                        end if   
                       
                    RETURN cCodret, isolicitudes, cfolio_sol_can,cNumcte,cnombco_orden,cEstatus, iRegistros WITH RESUME;
                    end  foreach
           
            ELSE
           
           
                      SELECT COUNT(*)
                      INTO iRegistros
                      FROM sc_portacec_archivotemp_cancelaciones;   
           
                 foreach
                   
                   
                     SELECT SKIP no_pag FIRST pregistros folio_cancelacion,fecha_solca_portabilidad,
                    (SELECT trim (apell_paterno)||' '||trim(apell_materno)||' '||trim(nombre1)||' '||trim(nombre2)
                    FROM bdinteg:si_cliente cte
                    where cte.numcte =  ps.num_cte) as nombre_cte,
                    (SELECT rfc
                    FROM bdinteg:si_cliente cte
                    where cte.numcte =  ps.num_cte) as rfc_cte,
                    num_cte,           
                    cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,
                    (select vchrnombrecorto
                    from bdinteg:si_bancos
                    where cvecesif= bco_ordenante) as bco_ordenante,
                    (select YEAR(fecha_nac)||LPAD(MONTH(fecha_nac),2,0)||LPAD(DAY(fecha_nac),2,0)
                    from bdinteg:si_ctepf cte
                    where cte.numcte =  ps.num_cte) as fecha_nacimiento,
                    rfc_empresa,
                    (select curp
                    from bdinteg:si_ctepf cte
                    where cte.numcte =  ps.num_cte) as curp_cte,
                    folio_solicitud
                    into cfolio_sol_can,cfech_sol_can,cnomb_cte,crfc_cte,cNumcte,ccta_recept,ctipo_cta_rec,cbco_receptor,ccta_ordenante, ctipo_cta_orden, cbco_orden, cnombco_orden,cfecha_nac, crfc_emp,ccurp_cte,cfolio_solic                       
                    from sc_portacec_solicitud ps
                    WHERE fecha_solca_portabilidad    BETWEEN vfecant and vfecha_reg                                
					and  clave_origen in ('1','2')
					and  clave_sentido='0'
					and estatus_portabilidad='4'
					and bco_ordenante='40137'
					and cod_operacion='21'					
                    and folio_cancelacion not in (SELECT folio_cancelacion
                    FROM sc_portacec_bitacora_cancelaciones)
               
           
                    LET isolicitudes= isolicitudes+1;
                       if isolicitudes <>0 then
                            LET cCodret='00000';   
                        end if   
           
                        RETURN cCodret, isolicitudes, cfolio_sol_can,cNumcte,cnombco_orden,cEstatus, iRegistros WITH RESUME;
                end foreach
           
           
                       
            END IF -- NO DE PAGINAS


       
        ELSE
                LET cCodRet = '00004';    --CODIGO DE OPERACION INVALIDO

                RETURN cCodret, isolicitudes, cfolio_sol_can,cNumcte,cnombco_orden,cEstatus, iRegistros;
                                       
        END IF -- VERIFICA SI EL CODIGO ES CORRECTO (22)

       
       
                --// NO EXISTEN DATOS
                IF isolicitudes = 0 THEN
                    LET cCodRet = '00001';
                RETURN cCodret, isolicitudes,cfolio_sol_can,cNumcte,cnombco_orden,cEstatus, iRegistros;
                END IF
   
    END
    END PROCEDURE;