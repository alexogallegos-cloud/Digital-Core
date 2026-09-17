CREATE PROCEDURE "informix".sp_rep_sem_prospecteo_solicitudes()
RETURNING
    CHAR(6) AS Codigo_retorno;

    DEFINE iSqlErr        INTEGER;
    DEFINE cF_ini         DATE;
    DEFINE cF_fin         DATE;    
    DEFINE cCodRet        CHAR(6);
    DEFINE cRuta          CHAR(100);
    DEFINE cNomArchAux    CHAR(100);
    DEFINE cNomSqlTmp     CHAR(120);
    DEFINE cSql           CHAR(2500);
    DEFINE cConsulta      CHAR(2200);

    LET iSqlErr      = 0;
    LET cCodRet      = '00000';
    LET cF_ini       = '';
    LET cF_fin       = '';
    LET cRuta        = '';
    LET cNomArchAux  = '';
    LET cNomSqlTmp   = '';
    LET cSql         = '';
    LET cConsulta    = '';

BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    SELECT valor
      INTO cRuta
      FROM "informix".si_param  
     WHERE empresa = '001'
       AND cod_param = 482;

    IF dbinfo("sqlca.sqlerrd2") = 0 THEN
        LET cCodRet = '000001';
        RETURN cCodRet;
    END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    LET cF_ini = TODAY - 7;
    LET cF_fin = TODAY - 1;

    -- RQM 1697-2
    LET cConsulta =
        " select b.sucursal as SucSolicitud ,"||
        " d.tipo_cliente as TipoCte ,"|| 
        " b.numcte as NnumCte,"|| 
        " d.fecha_insert as AltaCte,"||
        " e.fecha_alta as fecha_alta_idof,"|| 
        " b.fecha_insert as FecSolProspecto,"|| 
        " b.num_solicitud as NumSolicitud,"|| 
        " b.status_solicitud as Estatus,"||                            
        " c.fecha_hora as FecHora"||  
        " from bdisolic:ss_solicitudes b,"||
        " bdisolic:ss_autorizacion c, bdinteg:si_cliente d,"||
        " outer ( bdidigital@coppelimg_tcp:'informix'.dg_expediente e,"||
        "         bdidigital@coppelimg_tcp:'informix'.dg_grupodocto f,"||
        "         bdidigital@coppelimg_tcp:'informix'.dg_tipodocumento g )"||
        " where c.num_solicitud = (select max(num_solicitud) "||
        "                       from bdisolic:ss_autorizacion "||
        "                      where num_solicitud = b.num_solicitud "||
        "                        and status_solicitud = b.status_solicitud) "||
        " and b.fecha_insert >= '"||cF_ini||"'"||
        " and b.fecha_insert <= '"||cF_fin||"'"||
        " and b.num_solicitud = c.num_solicitud"||
        " and b.status_solicitud = c.status_solicitud"||
        " and b.numcte = d.numcte"||
        " and b.numcte = e.cliente"||
        " and e.fecha_alta = (select min(fecha_alta) "||
        "                     from bdidigital@coppelimg_tcp:'informix'.dg_expediente"||
        "                    where cliente = b.numcte"||
        "                      and producto = b.num_producto)"||
        " and e.secuencia = 1"||
        " and e.cod_docto = g.cod_docto"||
        " and e.cuenta = '99999999999'"||
        " and g.cod_grupo = f.cod_grupo"||
        " and f.cod_grupo = '001'"||
        " order by d.tipo_cliente, b.num_solicitud, c.fecha_hora";
    -- RQM 1697-2

    LET cNomArchAux =
        'RAU_'||TO_CHAR(cF_ini,'%Y%m%d')||'_'||TO_CHAR(cF_fin,'%Y%m%d')||'.txt';

    LET cNomSqlTmp =
        'qryRepPteo_'||TO_CHAR(CURRENT,'%Y%m%d%H%M%S')||'.sql';

    LET cSql =
        'echo "unload to '||TRIM(cRuta)||TRIM(cNomArchAux)||
        ' DELIMITER ''|'' '||TRIM(cConsulta)||'" > '||
        TRIM(cRuta)||TRIM(cNomSqlTmp);
    SYSTEM cSql;

    LET cSql = 'dbaccess bdinteg '||TRIM(cRuta)||TRIM(cNomSqlTmp);
    SYSTEM cSql;

    LET cSql = 'rm -f '||TRIM(cRuta)||TRIM(cNomSqlTmp);
    SYSTEM cSql;

    RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'Folio: RQM 1697-2',
'Autor: 99802161 Narciso IvÃ¡n Cisneros Acosta',
'Fecha: 22/09/2025',
'Modificacion: Se modifica la consulta para quitar la relaciÃ³n con ss_prospecteo que limitaba la cantidad de resultados y no contemplar todas las sucursales',
'Sustento: RQM 1697-2  ActualizaciÃ³n de reportes.',
'Solicita: David GarcÃ­a Jurado LÃ³pez.',
'Base de datos: BDINTEG',
'----------------------------------------------------------------------------',
'Folio: CORIMA 3220482',
'Autor: Eduardo Ãvila PÃ©rez Tagle',
'Fecha: 07/04/2026',
'Modificacion: Se realizan ajustes al procedimiento almacenado para corregir los comandos del sistema operativo ejecutados desde el SP',
'Sustento: AtenciÃ³n al incidente intermitente con error -668 presentado durante la ejecuciÃ³n del Job',
'Solicita: JosÃ© RaÃºl Negrete Llanes',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_bloqueausuariobpi()
RETURNING VARCHAR(6),VARCHAR(80),INTEGER;

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  v_numcte         VARCHAR(20);
define dfecha date;
define cTipo  varchar(5);
define iDias  integer;
define iBloq  integer;
define iEje  integer;
define iNum  integer;
define iCont  integer;
define iCont2 integer;
define iCont3 integer;

--RealizÃÂ³: Manuel Osuna Valencia
--Fecha: 06/07/2010
--SolicitÃÂ³: Ismael Hernandez
--Actividad: Cambia de estatus del perfil a los usuarios que no cumplan las directivas de la tabla de parametros

Begin
	 ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	      LET P_COD_RET    = SQL_ERR;
	      LET P_MENSAJE  = ERROR_INFO;
	      RETURN P_COD_RET, P_MENSAJE,iCont;
	 END EXCEPTION;

    --SET DEBUG FILE TO "/ifxsif01/JuanRivera/traces/sp_bloqueausuariobpi.out";
    --TRACE ON;
	
	  /*
	  Las instruccciones SEt que me dijo Gaby 
	  son para establecer aislamiento en la estabilidad 
	  del cursor   lectura y bloque en espera
      */	  
	  --- SET ISOLATION TO CURSOR STABILITY;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	LET P_COD_RET = '00000';
	LET P_MENSAJE = 'PROCESO EXITOSO';
	LET iCont = 0;

	select limit 1
		case when id_param = '07' and (valor is null or valor = "" ) then 'Falta Parametro 07' 
		     when id_param = '08' and (valor is null or valor = "" ) then 'Falta Parametro 08' 
		     when id_param = '09' and (valor is null or valor = "" ) then 'Falta Parametro 09' 
		     when id_param = '10' and (valor is null or valor = "" ) then 'Falta Parametro 10' 
		     when id_param = '11' and (valor is null or valor = "" ) then 'Falta Parametro 11' 
		     when id_param = '10' and (select count(*) from bdibpi:bpi_auxparam where id_param = id_param) =0 then 'No existen status en bpi_auxparam' 	
	      	     else "0"
		end into  P_MENSAJE
	from bdibpi:bpi_param  where id_param in ('07','08','09','10','11')
	group by 1;

	IF (P_MENSAJE == "0") THEN 

		
		select valor into cTipo  from bdibpi:bpi_param 	where id_param  = "07" and current between f_inicio and f_fin;
		select 
			sum(case when id_param = '08' then valor::int end),
			sum(case when id_param = '09' then valor::int end),			
			sum(case when id_param = '11' and cTipo = "D"  then 1  
				 when id_param = '11' and cTipo = "S"  and (date(current) - date(f_fin) = 7) then 1  
			         when id_param = '11' and cTipo = "M"  and (date(f_fin + Interval(1) month to month) = date(current)) then 1 
			         else 0	
        	            end) into iDias,iBloq,iEje
	       from bdibpi:bpi_param  where id_param in ('08','09','10','11');
		
	       IF (iEje == 1) THEN

				LET P_MENSAJE = 'PROCESO EXITOSO';
			
				select fecha_ant into dfecha from bdinteg:si_fechas;
		
				select count(*) into iCont from  si_bpiusuarios  
				where id_status in (select a.valor from bdibpi:bpi_param p,bdibpi:bpi_auxparam a
									where a.id_param = p.id_param)
				and nvl(f_ultimo_acceso,null) is null						
				and (date(dfecha) - date(f_registro)) >= iDias;

				IF (iCont > 0) THEN
				
				
					update si_bpiusuarios  set id_status = iBloq
					where id_status in (select a.valor from bdibpi:bpi_param p,bdibpi:bpi_auxparam a
											where a.id_param = p.id_param 	 ) 
					and nvl(f_ultimo_acceso,null) is null	
					and (date(dfecha) - date(f_registro)) >= iDias;						

				ELSE
					LET P_MENSAJE = 'NO EXISTIERON REGISTROS POR ACTUALIZAR';
					
				END IF;
			
			
				select count(*) into iCont from  si_bpiusuarios  
				where id_status in (select a.valor from bdibpi:bpi_param p,bdibpi:bpi_auxparam a
									where a.id_param = p.id_param)			
				and (date(dfecha) - date(f_ultimo_acceso)) >= iDias;

				IF (iCont > 0) THEN
				
				
					update si_bpiusuarios  set id_status = iBloq
					where id_status in (select a.valor from bdibpi:bpi_param p,bdibpi:bpi_auxparam a
											where a.id_param = p.id_param 	 ) 
					and (date(dfecha) - date(f_ultimo_acceso)) >= iDias;						

					

				ELSE
					LET P_MENSAJE = 'NO EXISTIERON REGISTROS POR ACTUALIZAR';
					
				END IF;
			
				update bdibpi:bpi_param set f_inicio = current,f_fin = current where id_param = '11';
				
			    select count(*) into iCont2 from  si_bpiusuarios  
				where id_status in ('1','2','3','4')			
				and nvl(f_ultimo_acceso,null) is null						
				and (date(dfecha) - date(f_registro)) >= iDias;

				IF (iCont2 > 0) THEN
				
				
					update si_bpiusuarios  set id_status = '99'
					where id_status in ('1','2','3','4') 
					and nvl(f_ultimo_acceso,null) is null	
					and (date(dfecha) - date(f_registro)) >= iDias;	
                ELSE
                    LET P_MENSAJE = 'NO EXISTIERON REGISTROS POR CANCELAR';	

                End IF;

                -- Contar registros que cumplen con las condiciones
                SELECT COUNT(DISTINCT b.numcte)
                INTO iCont3
                FROM bdinteg:si_bpiusuarios b
                INNER JOIN bdinteg:si_cambiostcte AS c
                     ON c.numcliente = b.numcte 
                WHERE b.id_status IN ('1', '2', '3', '4')
                  AND c.id_statusanterior = '10';	
           
			   -- Verificar si hay registros para procesar
                IF (iCont3 > 0) THEN
                
                    -- Recorrer los registros que cumplen con las condiciones
                    FOREACH SELECT DISTINCT b.numcte 
					        INTO v_numcte
                            FROM bdinteg:si_bpiusuarios b
                            INNER JOIN bdinteg:si_cambiostcte c 
                                 ON c.numcliente = b.numcte 
                                 WHERE b.id_status IN ('1', '2', '3', '4')
                                 AND c.id_statusanterior = '10'
                
                        -- Verificar si existe un registro en si_cambiostcte con las condiciones dadas
                        IF EXISTS (
                            SELECT 1
                            FROM bdinteg:si_cambiostcte c
                                            WHERE c.numcliente = v_numcte
                              AND c.id_statusanterior = '10'
                        ) THEN
                
                            -- Actualizar el estado en si_bpiusuarios
                            UPDATE si_bpiusuarios
                            SET id_status = '10'
                            WHERE numcte = v_numcte;
                
                        END IF;
                
                    END FOREACH;
                
                ELSE
                    -- Mensaje si no hay registros para actualizar
                    LET P_MENSAJE = 'NO EXISTIERON REGISTROS POR ACTUALIZAR';
                END IF;

			ELSE
				LET P_MENSAJE = 'HOY NO TOCA ACTUALIZAR REGISTROS';		

			END IF;				

		
	ELSE
		LET P_COD_RET = '00001';		
	END IF;
	
	RETURN P_COD_RET,P_MENSAJE,iCont;
	
END;
END PROCEDURE;