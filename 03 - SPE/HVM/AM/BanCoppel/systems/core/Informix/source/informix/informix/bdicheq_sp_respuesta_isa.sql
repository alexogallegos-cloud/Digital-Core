CREATE PROCEDURE "informix".sp_respuesta_isa( pEmpresa char(3) )
RETURNING CHAR(6), CHAR(4);
       
    DEFINE sql_err 			            INTEGER;
	DEFINE isam_err 		            INTEGER;
	DEFINE error_info		            CHAR(150);
	DEFINE cMensaje 		            CHAR(80);
	DEFINE cCod_ret                     CHAR(6);
    DEFINE vComienza            INTEGER;
    DEFINE vEnTransacc          SMALLINT;
    DEFINE vContador1           INTEGER;
    DEFINE vContador2           INTEGER;
    DEFINE vFechaHoy            DATE;
	DEFINE vFechadia			date;
	DEFINE vFechadiault			date;
	DEFINE vFechaAct			char(10);
    DEFINE vfecha_ant           DATE;
    DEFINE vsql                 CHAR(1200);
    DEFINE vstmt                CHAR(250);
    DEFINE vfecha               char(10);
    DEFINE vSucursal            CHAR(4);
	DEFINE vSucursalres			CHAR(4);
	DEFINE vtotal_enc			INTEGER;
	DEFINE vcte_satisf			INTEGER;
	DEFINE vind_satisfac		DECIMAL(18,2);
	DEFINE vind_satisfac_hist		DECIMAL(18,2);
	DEFINE vmeta				DECIMAL(18,2);
	DEFINE vmeta_hist			DECIMAL(18,2);
	DEFINE vpor_cumpli			DECIMAL(18,2);
	DEFINE vpor_cumpli_hist		DECIMAL(18,2);
	DEFINE dtHoraFin     		DATETIME HOUR TO SECOND;
	DEFINE vhora				char(4);

      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
	
    LET vComienza         = -1;
    LET vEnTransacc       = 0;
    LET vContador1        = 0;
    LET vContador2        = 0;
    LET vFechaHoy         = '';
	LET vfecha_ant		  = '';
	LET vFechadia		  = '';
	LET vFechadiault	  = '';
	LET vFechaAct		  = '';
    LET vsql              = '';
    LET vstmt             = '';
    LET vfecha            = '';
    LET vSucursal         = '';
	LET vSucursalres	  = '';
	LET vtotal_enc		  = 0;
	LET vcte_satisf		  = 0;
	LET vind_satisfac	  = 0;
	LET vind_satisfac_hist  = 0;
	LET vmeta			  = 0;
	LET vpor_cumpli		  = 0;
	LET vhora			  = '';
    
	
	BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		RETURN cCod_ret,vsucursal;
	END EXCEPTION;
    
	    
	--SET DEBUG FILE TO "/ifxsif01/ilopez/830_ARCHI_RESPUESTA_ISA_PRO/sp_respuesta_isa.out";
    --TRACE ON;
	
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy , fecha_ant, pri_dia_mes -1
      INTO vFechaHoy, vfecha_ant, vFechadiault
      FROM sc_fechas
     WHERE empresa = pEmpresa;
     
	TRUNCATE TABLE sc_seguimiento_isa;
	
        FOREACH WITH HOLD
            SELECT unique sucursal
              INTO vSucursal
              FROM bdinteg:si_sucursales --sc_respuestas_bco
			  WHERE empresa = pEmpresa
			  AND tipo = 'S'
			
			--obtener dia reporte
			SELECT fecha_hoy
			  INTO vFechadia
			  FROM sc_fechas
			 WHERE empresa = pEmpresa;
			 
			--para el caso que no tengamos Indice de satisfaccion este mes
			SELECT  his.real_mes, his.meta, his.cumplimiento
			  INTO vind_satisfac_hist,vmeta_hist,vpor_cumpli_hist
			  FROM sc_seguimiento_isa_hist his
			 WHERE his.fecha = vFechadiault 
			   AND his.sucursal = vSucursal;
			 
			--LET vSucursal = replace(vSucursal,'0','');
		    
			--Para el caso que no tengamos clientes d ela sucursal
			select unique sucursal 
			into vSucursalres
			from bdicheq:sc_respuestas_bco
			--where lpad(sucursal::integer,4,'0') = vSucursal;
			where lpad(sucursal,4,'0') = vSucursal;
			
			--Obtener Meta 
				select TO_NUMBER(valor)
				into vmeta
				from bdicheq:sc_param
				where empresa = '001'
				and codparam = 'metaisa';
			
			LET vmeta = vmeta ;
			
			
			IF vSucursalres IS NOT NULL OR vSucursalres <> '' THEN
			
				--Obtener total encuentas
				select count(*) total_enc
				into vtotal_enc
				from bdicheq:sc_respuestas_bco
				--where lpad(sucursal::integer,4,'0') = vSucursal;
				where lpad(sucursal,4,'0') = vSucursal;
				
				--Obtener clientes satisfechos
				select count(*) cte_satisf
				into vcte_satisf
				from bdicheq:sc_respuestas_bco
				--where lpad(sucursal::integer,4,'0') = vSucursal
				where lpad(sucursal,4,'0') = vSucursal
				and satisf_general in (9,10);
				
				
				--Obtener Indice de Satisfaccion
				LET vind_satisfac = (vcte_satisf/vtotal_enc)*100;		
					
				--Obtener %cumplimiento
				LET vpor_cumpli = (vind_satisfac/vmeta)*100;
				
				if vpor_cumpli > 100 then
					LET vpor_cumpli = 100;
				end if;
			ELSE
				LET vind_satisfac = vind_satisfac_hist;
				--LET vmeta = vmeta_hist;
				LET vpor_cumpli = vpor_cumpli_hist;
				
				IF vind_satisfac_hist is null OR vind_satisfac_hist = '' THEN
					LET vind_satisfac = 100;
					--LET vmeta = vmeta;
					LET vpor_cumpli = 100; 
				END IF;
			END IF;		
		
			--LET vFechaAct = TO_CHAR(vFechadia, '%d/%m/%Y');
			--LET vSucursal = lpad(vSucursal::integer,4,'0');
			LET vSucursal = lpad(vSucursal,4,'0');
			--LET vind_satisfac = REPLACE(round(vind_satisfac,0)::integer,'.0','');
			--LET vmeta = REPLACE(round(vmeta,0)::integer,'.0','');
            
           -- IF ( vSucursal is not null AND vSucursal <> '' AND LENGTH(vSucursal) = 4 ) THEN
                INSERT INTO sc_seguimiento_isa
                ( fecha, sucursal, real_mes, meta, cumplimiento )
                VALUES
                ( vFechadia, vSucursal, vind_satisfac, vmeta, vpor_cumpli );
            --END IF;
               
            LET vContador2 = vContador2 + 1;
            
            /*IF vContador2 >= 500 THEN
                LET vContador2 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;*/
        END FOREACH;
    
    -- LET vFechaAct = TO_CHAR(vFechadia, '%d/%m/%Y');
    LET vfecha = TO_CHAR(vFechaHoy, '%d_%m_%Y');
	
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
		INTO dtHoraFin 
	FROM sysmaster:"informix".sysshmvals;
	
	LET vhora = substr(dtHoraFin,1,2)||substr(dtHoraFin,4,5);
    
    LET vsql = '';
    LET vsql = 'echo "FECHA|SUCURSAL|REAL_MES|META|'||
					'CUMPLIMIENTO|" > /resplogifx/conciliachq/ArchivosRespuestaIsa/KPI_Seguimiento_ISA_'||vfecha||'_'||vhora||'.txt.enc';
    SYSTEM vsql;
    LET vsql = '';
 
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/ArchivosRespuestaIsa/KPI_Seguimiento_ISA_'||vfecha||'_'||vhora||'.txt.det '||
               'SELECT distinct TO_CHAR(b.fecha, ''%d/%m/%Y''), a.sucursal, b.real_mes, REPLACE(round(b.meta,0)::integer,''.0'',''''), b.cumplimiento '||
               'FROM bdinteg:si_sucursales a left outer join sc_seguimiento_isa b on (a.sucursal = b.sucursal) '||
			   'where a.empresa = ''001'' and a.tipo = ''S'' order by sucursal;" > /resplogifx/conciliachq/ArchivosRespuestaIsa/respuesta_isa.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ArchivosRespuestaIsa/respuesta_isa.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
    
    LET vsql = '';
    LET vsql = 'cat /resplogifx/conciliachq/ArchivosRespuestaIsa/KPI_Seguimiento_ISA_'||vfecha||'_'||vhora||'.txt.enc /resplogifx/conciliachq/ArchivosRespuestaIsa/KPI_Seguimiento_ISA_'||vfecha||'_'||vhora||'.txt.det > /resplogifx/conciliachq/ArchivosRespuestaIsa/KPI_Seguimiento_ISA_'||vfecha||'_'||vhora||'.txt';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vsql = '';
    LET vsql = 'rm /resplogifx/conciliachq/ArchivosRespuestaIsa/KPI_Seguimiento_ISA_'||vfecha||'_'||vhora||'.txt.enc';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vsql = '';
    LET vsql = 'rm /resplogifx/conciliachq/ArchivosRespuestaIsa/KPI_Seguimiento_ISA_'||vfecha||'_'||vhora||'.txt.det';
    SYSTEM vsql;
    LET vsql = '';
 
    END; 
    
    RETURN cCod_ret, vsucursal;
    
END PROCEDURE;