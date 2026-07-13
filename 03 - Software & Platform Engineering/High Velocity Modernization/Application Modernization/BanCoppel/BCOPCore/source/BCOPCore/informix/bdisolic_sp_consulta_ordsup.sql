CREATE PROCEDURE "informix".sp_consulta_ordsup(o_empresa       CHAR(3),
                    o_sucursal CHAR(4),o_cantidad smallint, o_num_cte CHAR(20))

RETURNING CHAR(5),CHAR(20),CHAR(50),CHAR(2),date,date,smallint,char(1),char(20);

DEFINE cNumSolic    CHAR(20);
DEFINE cNombre      CHAR(50);
DEFINE cStatusSol   CHAR(2);
DEFINE dFechaSol    DATE;
DEFINE dFechaResp   DATE;
DEFINE iCausaSitEsp SMALLINT;
DEFINE cStatus      CHAR(1);
DEFINE scod_ret     CHAR(6);
DEFINE vsqlerr      INTEGER;
DEFINE v_cuantos    SMALLINT;
DEFINE cSitEsp      CHAR(1);
DEFINE cCliente     char(20);

-- ****************************************************************************
LET cNumSolic  = "";
LET cNombre    = "";
LET cStatusSol = "";
LET dFechaSol  = "";
LET dFechaResp = "";
LET iCausaSitEsp  = 0;
LET scod_ret   = "000000";
LET vsqlerr    = 0;
LET v_cuantos  = 0;
LET cStatus = ' ';
LET cSitEsp = ' ';
LET cCliente   = ' ';


    BEGIN

        ON EXCEPTION SET vsqlerr
            IF vsqlerr != 0 THEN
              LET scod_ret=vsqlerr;
              RETURN scod_ret, cNumSolic,cNombre,cStatusSol,dFechaSol,dFechaResp,iCausaSitEsp,cSitEsp,cCliente;
           END IF;
        END EXCEPTION;

         --SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/credito/Diana/consulta_ordsup.out";
         --TRACE ON;

         IF TRIM(o_num_cte) = '' THEN
            FOREACH
                (
                SELECT a.num_solicitud, b.numcte,(TRIM(c.nombre1)||' '||TRIM(c.nombre2) || ' ' || TRIM(c.apell_paterno) || ' ' || 
                       TRIM(c.apell_materno))  as nombres , b.status_solicitud, NVL(a.fecha_solicitud,'01/01/1900') as FechaSolicitud,
                       NVL(a.fecha_respuesta,'01/01/1900'), NVL(a.causasituacionespecial,0) as Causa, 
                       case a.situacionespecial 
                          when '' THEN f.descripcion 
                          else a.situacionespecial 
                       end case
                 INTO cNumSolic,cCliente,cNombre,cStatusSol, dFechaSol,dFechaResp,iCausaSitEsp,cSitEsp 
                 FROM bdisolic:ss_solicitud_os a INNER JOIN bdisolic:ss_solicitudes b ON a.empresa = b.empresa AND a.num_solicitud = b.num_solicitud
                      INNER JOIN bdinteg:si_cliente c ON c.empresa = b.empresa AND c.numcte = b.numcte,  -- AND a.fecha_solicitud = c.fechasolicitud
                      bdisolic:ss_status_sol f 
                WHERE ( (a.status = 'S' AND b.status_solicitud = 'EE')
                      OR (a.status = 'P' AND b.status_solicitud = 'OS')
                      OR (a.status = 'D' AND b.status_solicitud = 'OA') )
                     AND b.empresa = o_empresa and b.sucursal = o_sucursal
                     AND b.status_solicitud = f.status_solicitud
                     AND a.fecha_solicitud = (
                                              select max(z.fecha_solicitud)
                                                from bdisolic:ss_solicitud_os z
                                               where z.empresa = o_empresa AND z.num_solicitud  = a.num_solicitud
                                              )
                UNION ALL
                SELECT b.num_solicitud, b.numcte, (TRIM(c.nombre1)||' '||TRIM(c.nombre2) || ' ' || TRIM(c.apell_paterno) || ' ' || TRIM(c.apell_materno)) as nombres,
                       b.status_solicitud, NVL(b.fecha_insert,'01/01/1900') as FechaSolicitud, NVL(b.fecha_insert,'01/01/1900'), 0 as Causa,  f.descripcion
                  FROM bdisolic:ss_solicitudes b INNER JOIN bdinteg:si_cliente c ON c.empresa = b.empresa AND c.numcte = b.numcte, 
                       bdisolic:ss_status_sol f    
                 WHERE b.status_solicitud in('CC','BC','CE', 'ST') AND b.empresa = o_empresa and b.sucursal = o_sucursal
                   AND b.status_solicitud = f.status_solicitud
                   )
                  ORDER BY status_solicitud, num_solicitud

            
                LET v_cuantos = v_cuantos + 1;
                IF v_cuantos <= o_cantidad THEN
                        CONTINUE FOREACH;
                END IF;

                RETURN scod_ret, cNumSolic,cNombre,cStatusSol,dFechaSol,dFechaResp,iCausaSitEsp,cSitEsp,cCliente
                WITH RESUME;


            END FOREACH;
         ELSE
            FOREACH
                (
                SELECT a.num_solicitud,b.numcte,(TRIM(c.nombre1)||' '||TRIM(c.nombre2) || ' ' || TRIM(c.apell_paterno) || ' ' || TRIM(c.apell_materno))
                        as nombres, b.status_solicitud,NVL(a.fecha_solicitud,'01/01/1900') as FechaSolicitud,
                        NVL(a.fecha_respuesta,'01/01/1900'),NVL(a.causasituacionespecial,0) as Causa,
                        NVL(a.situacionespecial,' ')
                        INTO cNumSolic,cCliente,cNombre,cStatusSol, dFechaSol,dFechaResp,iCausaSitEsp,cSitEsp
                FROM ss_solicitudes b LEFT JOIN ss_solicitud_os a
                ON a.empresa = b.empresa AND a.num_solicitud = b.num_solicitud
                INNER JOIN bdinteg:si_cliente c 
                ON c.empresa = b.empresa AND c.numcte = b.numcte --AND a.fecha_solicitud = c.fechasolicitud
                WHERE ( (a.status = 'S' AND b.status_solicitud = 'EE') 
                         OR (a.status = 'P' AND b.status_solicitud = 'OS')
                         OR (a.status = 'D' AND b.status_solicitud = 'OA')) AND b.empresa = o_empresa 
                        and  b.numcte = o_num_cte
                        and a.fecha_solicitud = 
                        (
                            select max(fecha_solicitud)
                            from ss_solicitud_os z
                            where z.empresa = o_empresa AND z.num_solicitud  = a.num_solicitud
                        )
                UNION ALL 
                SELECT b.num_solicitud, b.numcte, (TRIM(c.nombre1)||' '||TRIM(c.nombre2) || ' ' || TRIM(c.apell_paterno) || ' ' || TRIM(c.apell_materno)) as nombres,
                        b.status_solicitud, NVL(b.fecha_insert,'01/01/1900') as FechaSolicitud, NVL(b.fecha_insert,'01/01/1900'),0 as Causa,
                        ' '
                FROM bdisolic:ss_solicitudes b INNER JOIN bdinteg:si_cliente c
                ON c.empresa = b.empresa AND c.numcte = b.numcte
                WHERE b.status_solicitud NOT IN ('EE','OS','OA', 'ST') AND b.empresa = o_empresa
                        AND b.numcte = o_num_cte
                )
                ORDER BY status_solicitud,num_solicitud


                LET v_cuantos = v_cuantos + 1;

                IF v_cuantos <= o_cantidad THEN
                        CONTINUE FOREACH;
                END IF;

                RETURN scod_ret, cNumSolic,cNombre,cStatusSol,dFechaSol,dFechaResp,iCausaSitEsp,cSitEsp,cCliente
                WITH RESUME;


            END FOREACH;
            
         END IF;
    END

END PROCEDURE
;