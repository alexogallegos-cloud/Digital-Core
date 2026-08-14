create procedure "informix".sp_generaredoctaejetxt(pempresa char(3),pFechaEmision date)
RETURNING char(5),char(80);

-- Realizo   : Jose Luis Pulido Zepeda
-- Proyecto : Generacion de Estado de Cuenta Eje
-- Actividad : Genera archivo de texto para las tablas que contienen informacion del estado de cuenta eje
-- Fecha     : 03-06-2009

--Modificó: Lorenzo Ibarra Garcia
--Fecha: 10-07-2009
--Se corrigió el armado de las fechas, ya que se estaba haciendo YYYYMMDD cuando debe de ser MMDDYYYY
--Modificó: Lorenzo Ibarra Garcia
--Fecha: 14-07-2009
--Se cambió la parte donde se hace el control del proceso para que lo hiciera por medio de System ya que la hora de inicio y fin de proceso era la misma.

--Modificó: Jose Luis Pulido
--Fecha: 31-07-2009
--Se cambio la consulta para llenar el archivo de texto con el Unload, se llenan tablas temporales y de ahi se toman los datos

--Modificó: Jose Luis Pulido
--Fecha: 05-08-2009
--Se agrego que se mande a los archivos de texto la fecha de emison del dia del corte y no la que tiene la tabla

--Modificó: Jose Luis Pulido
--Fecha: 07-08-2009
--Se quito el manejo de tablas temporales, se agrego la fecha de emision como un nuevo parametro del SP y se utiliza para validar que las consultas regresen la informacion en base a esa fecha de emision.

DEFINE vcSql 				CHAR(1000); 	-- COMANDO QUE SE EJECUTA EN EL ARCHIVO.SQL
DEFINE vcStmt 				CHAR(100); 	 	-- EJECUCION DE ARCHIVO SQL
DEFINE vcodRet 				char(5); 	 	-- CODIGO DE RETORNO
DEFINE sfecha 				char(8); 		-- FECHA CON FORMATO PARA EL NOMBRE DEL ARCHIVO DE TEXTO
DEFINE dfechaactual 		date; 	 		-- CONTIENE LA FECHA DEL DIA DE HOY
DEFINE dfechaini 			date;   	 	-- CONTIENE A FECHA INICIAL DEL RANGO DE FECHAS CON EL FORMATO PARA EL COMANDO QUE SE VA A EJECUTAR MEDIANTE LA CONSOLA
DEFINE dfechafin 			date;  	 		-- CONTIENE A FECHA FINAL DEL RANGO DE FECHAS CON EL FORMATO PARA EL COMANDO QUE SE VA A EJECUTAR MEDIANTE LA CONSOLA
DEFINE idia 				smallint; 		-- DIA EN QUE SE DEBE EJECUTAR LA CREACION DEL ARCHIVO DE TEXTO CADA MES
DEFINE idiahoy 				smallint; 	 	-- DIA DE HOY
DEFINE vsqlerr 				integer;		-- VARIABLE PARA CACHAR EL CODIGO DE ERRORDEFINE vsqlerr integer
DEFINE iIsamErr 			smallint;	 	-- VARIABLE PARA CACHAR EL CODIGO DE ERROR
DEFINE cErrorInfo 			char(80);  		-- VARIABLE PARA CACHAR LA DESCRIPCION DEL ERROR
DEFINE vErrorInfo 			char(80);	 	-- VARIABLE PARA RETORNAR EL MENSAJE DE ERROR O MENSAJE DE EXITO
DEFINE dfechaUltImp 		date;	 		-- ULTIMA FECHA DE IMPRESION
DEFINE sProceso 			char(20);	 	-- PROCESO QUE S EMANDA A LA TABLA
DEFINE dfechainiAux 		date;	 		-- AUXILIAR PARA LA FECHA DE INICIO
DEFINE dfechafinAux 		date;	 		-- AUXILIAR PARA LA FECHA FINAL
DEFINE dfechaMesAntAux 		date; 			-- AUXILIAR PARA LA FECHA DE INICIO DEL CORTE

DEFINE Auxsql 				varchar(255,1);

let vcodRet 			= '000';
LET vcStmt 				= "";
LET vcSql 				= "";
LET sFecha				= "";
LET dfechaactual		= '01/01/1900';
LET dfechaini			= '01/01/1900';
LET dfechafin			= '01/01/1900';
LET idia				= 0;
LET idiahoy				= 0;
LET vsqlerr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= "";
LET vErrorInfo			= "PROCESO EXITOSO";
LET dfechaUltImp		= '01/01/1900';
LET sProceso			= 'GENERA ARCH CTA EJE';

 --set debug file to "/tmp/sp_GenerarEdoCtaEjeTXT.out";
 --trace on;

begin

	ON EXCEPTION  SET vsqlerr, iIsamErr, cErrorInfo
		IF vsqlerr <> 0  THEN
			LET  vCodRet  = vsqlerr;
			LET vErrorInfo = cErrorInfo;
			
			--SE ACTUALIZA EL REGISTRO PARA MARCAR QUE NO SE COMPLETO LA EJECUCION PORQUE HUBO ALGUN ERROR
            let vcSql = 'echo "UPDATE bdicheq:sc_contproc_edocta '||
                'SET status_proc = '''||'C'||''','||
                'cod_ret = '''||vcodret||''','||
                'mensaje = '''||vErrorInfo||''','||
                'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||''') '||
                'WHERE fecha = '''||dfechaactual||''' '||
                'AND  status_proc = '''||'I'||''' '||
                'AND tipo_proc  = '''||'I'||''';" > /tmp/contproc_edocta.sql';
            SYSTEM vcSql;                    
                        
            LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';        
            SYSTEM vcStmt;    

            RETURN vCodRet, vErrorInfo;
            
		END IF;
	END  EXCEPTION

	--PRIMERO SE OBTIENE LA FECHA DEL HOY Y EL DIA
	select {+INDEX(sc_fechas idx_fechas1)} 
	       fecha_hoy,day(fecha_hoy) 
	  into dfechaactual,idiahoy 
	  from bdicheq:sc_fechas
	 where empresa = pempresa;

	--SE OBTIENE EL DIA DE LA TABLA DE CONFIGURACIONES PARA SABER SI ES EL DIA QUE TENEMOS QUE EJECUTAR EL PROCESO PARA LA CREACION DEL ARCHIVO DE TEXTO
	select {+INDEX(sc_configuracion_edocta idx_diamesiv)}
	       dia_mesiversario 
	  into idia 
	  from bdicheq:sc_configuracion_edocta
	 where dia_mesiversario IS NOT NULL;

	--PREGUNTAMOS SI EL DIA DE HOY ES IGUAL AL DIA QUE ESTA EN LA TABLA DE CONFIGURACION PARA MANDAR CREAR LOS ARCHIVOS DE TEXTO
	if idiahoy=idia then
		-- PRIMERO SE CHECA SI YA EXISTE UN REGISTRO DE IMPRESION PREVIO EN LA TABLA bdicheq:sc_contproc_edocta PARA CHECAR LA FECHA DE INICIO
		-- SI NO EXISTE REGISTRO EL DIA DE HOY CON ESTATUS DE FINALIZADO ENTONCES SE COMIENZA CON EL PROCESO DE GENERACION DE ARCHIVO DE TEXTO
		if not exists (select {+INDEX(sc_contproc_edocta idx_contproc_edocta)} status_proc 
				 from bdicheq:sc_contproc_edocta 
				where proceso = 'GENERA EDO CTA EJE' 
				  and tipo_proc='I' 
				  and status_proc='F' 
				  and fecha=dfechaactual) then
			-- SI NO EXISTE REGISTRO PREVIO DE CONTROL DE GENERACION DE ARCHIVO DE TEXTO O SI EXISTE UN REGISTRO CON LA MISMA FECHA Y NO ESTE FINALIZADO SE PREPARAN LOS RANGOS DE FECHAS
			if not exists (select {+INDEX(sc_contproc_edocta idx_contproc_edocta)} fecha 
					 from bdicheq:sc_contproc_edocta 
					where proceso = 'GENERA EDO CTA EJE' and tipo_proc='I') or
				         nvl((select {+INDEX(sc_contproc_edocta idx_contproc_edocta)} max(fecha) 
					 from bdicheq:sc_contproc_edocta  
					where proceso = 'GENERA EDO CTA EJE' 
					  and tipo_proc='I'  
					  and (status_proc='I' or status_proc='C')),'01/01/1900')=dfechaactual then

				LET dfechainiAux=dfechaactual-1 units month;
				LET dfechafinAux=dfechaactual;
				LET dfechaMesAntAux=dfechaactual-1 units month;
			else
				-- SI EXISTE REGISTRO DE IMPRESION PREVIO SE OBTIENE LA ULTIMA FECHA DE GENERACION DEL ARCHIVO DE TEXTO DE LA TABLA DE CONFIGURACION
				select {+INDEX(sc_contproc_edocta idx_contproc_edocta)} max(fecha) 
				  into dfechaUltImp 
				  from bdicheq:sc_contproc_edocta 
				 where proceso = 'GENERA EDO CTA EJE'
				   and tipo_proc='I';

				LET dfechainiAux=dfechaUltImp;
				LET dfechafinAux=dfechaactual;
				LET dfechaMesAntAux=dfechaUltImp;
			end if;
			--SE VALIDA QUE EL CAMPO FECHA_HOY DE LA TABLA bdicheq:sc_fechas SEA IGUAL O MAYOR QUE LA FECHA INICIAL DEL RANGO DE FECHAS
			if dfechaactual >= dfechainiAux then

				--ARMAMOS LA FECHA INICIAL
				let dfechaini = mdy(month(dfechainiAux),day(dfechainiAux),year(dfechainiAux));
				--LET dfechaini = dfechainiAux;
				

				-- ESTA CONDICION SOLO APLICA SI LA FECHA DE CORTE CONFIGURADA ES EL 1 DE CADA MES Y SI ES PRIMERO DE ENERO PARA QUE NOS REGRESE EL AÑO ANTERIOR
				if day(dfechafinAux)=1 and month(dfechafinAux)=1 then
					LET dfechafinAux=dfechafinAux-1 units year;
				end if;

				--ARMAMOS LA FECHA FINAL
				LET dfechafin = mdy(month(dfechafinAux),day(dfechafinAux -1 units day),year(dfechafinAux));

				-- SI NO EXISTE REGISTRO DE GENERACION EL DIA DE HOY YA SEA CON ESTATUS I=INICIA PROCESO O C=ESTADOS DE CUENTA SIN GENERAR SE INSERTA UN NUEVO
				-- REGISTRO EN LA TABLA bdicheq:sc_contproc_edocta CON ESTATUS IGUAL A I
				if not exists (select {+INDEX(sc_contproc_edocta idx_contproc_edocta)} status_proc 
						 from bdicheq:sc_contproc_edocta 
					  	where proceso = 'GENERA EDO CTA EJE'
						  and tipo_proc='I' 
						  and (status_proc='I' or status_proc='C') 
						  and fecha=dfechaactual) then
					
                    let vcSql = 'echo " INSERT INTO BDICHEQ:sc_contproc_edocta (empresa, proceso, fecha, tipo_proc, status_proc, ejecutivo, hora_inicio) '||
                        'VALUES('''||pempresa||''', '''||sProceso||''', '''||dfechaactual||''', '''||'I'||''', '''||'I'||''', USER,'||
                            '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||'''));" > /tmp/contproc_edocta.sql';     
                    SYSTEM vcSql;                    
                                
                    LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';        
                    SYSTEM vcStmt;
                    
				else
					--SI EXISTE EL REGISTRO ACTUALIZAMOS SU ESTATUS, LA FECHA DE INICIO Y RESETEAMOS EL CODIGO DE ERROR Y EL MENSAJE
					let Auxsql = 'echo "update bdicheq:sc_contproc_edocta set status_proc='''||'I'||''','||
						'hora_inicio=(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||'''),'||
						'cod_ret='''||'00000'||''', mensaje='''||''' '||
                        'where fecha='''||dfechaactual||''' and tipo_proc='''||'I'||''';" > /tmp/contproc_edocta.sql';
                    LET vcSql = Auxsql;    
                    SYSTEM vcSql;                    
                                
                    LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';        
                    SYSTEM vcStmt;
                    
				end if;
				
				-- SE OBTIENE LA FECHA CON EL FORMATO YYYYMMDD PARA EL NOMBRE DEL ARCHIVO DE TEXTO
				SELECT {+INDEX(sc_fechas idx_fechas1)} 
				       to_char(fecha_hoy ,'%Y%m%d') 
				  into sFecha 
				  from sc_fechas
				 where empresa = pempresa;
				
				-- DE AQUI EN ADELANTE SE COMIENZA CON LA CREACION DE LOS ARCHIVOS DE TEXTO
				-- 1.- SE CREA EL ARCHIVO DE TEXTO CON LOS DATOS DE LA TABLA TEMPORAL bdicheq:sc_encabezado_edocta
				-- SE GENERA EL ARCHIVO SQL CON EL CODIGO NECESARIO PARA CREAR EL ARCHIVO DE TEXTO CON LOS RESULTADOS DE LA CONSULTA
				--fecha_emision
				let vcSql = 'echo "UNLOAD TO ' || '''/tmp/sc_encabezado_edocta' || sFecha ||  '.txt''' || ' DELIMITER ' || '''|''' ||
                    ' select idreg,fecha_emision,num_cuenta,nvl(num_cte,''''),nvl(num_tarjeta,''''),nvl(nombre_cte,''''),nvl(direccion_cte,''''), ' || 
					'nvl(direccion_col,''''),nvl(direccion_del,''''),nvl(edo_cd,''''),nvl(cve_ruta,''''),nvl(sucursal_nombre,''''),nvl(rfc,''''),nvl(cp,''''), ' ||
                    'nvl(cve_ahorro,''''),nvl(clabe,''''),nvl(curp,''''),nvl(fechaalta,''01/01/1900''::date),nvl(fechainicio,''01/01/1900''::date), ' ||
					'nvl(mensajeproducto,''''),nvl(inserto,''''),nvl(fechafinal,''01/01/1900''::date),nvl(sucursal,'''') ' || 
					'from bdicheq:sc_encabezado_edocta where fecha_emision = ''' || pfechaEmision || ''' order by idreg" > /tmp/EdoCta.sql';
				SYSTEM vcSql;
				
				-- SE EJECUTA EL ARCHIVO SQL PARA QUE SE GENERE EL ARCHIVO DE TEXTO
				LET vcStmt = 'dbaccess bdicheq /tmp/EdoCta.sql';
                
				SYSTEM vcStmt;
				
				-- 2.- SE CREA EL ARCHIVO DE TEXTO CON LOS DATOS DE LA TABLA TEMPORAL bdicheq:sc_encabezado2_edocta
				-- SE GENERA EL ARCHIVO SQL CON EL CODIGO NECESARIO PARA CREAR EL ARCHIVO DE TEXTO CON LOS RESULTADOS DE LA CONSULTA
				let vcSql = 'echo "UNLOAD TO ' || '''/tmp/sc_encabezado2_edocta' || sFecha ||  '.txt''' || ' DELIMITER ' || '''|''' ||
					' select idreg,fecha_emision,num_cuenta,nvl(saldoanterior,0),nvl(depositos,0),nvl(interesespagados,0),nvl(retiros,0), ' ||
					'nvl(otroscargos,0),nvl(ivaotroscargos,0),nvl(saldocorte,0),nvl(saldopromedio,0),nvl(retencionisr,0),nvl(interesesnetos,0), ' ||
					'nvl(dias,0),nvl(tasabruta,0) from bdicheq:sc_encabezado2_edocta where fecha_emision = ''' || pfechaEmision ||
					''' order by idreg;" > /tmp/EdoCta2.sql';
				SYSTEM vcSql;
				
				-- SE EJECUTA EL ARCHIVO SQL PARA QUE SE GENERE EL ARCHIVO DE TEXTO
				LET vcStmt = 'dbaccess bdicheq /tmp/EdoCta2.sql';
				SYSTEM vcStmt;

				-- 3.- SE CREA EL ARCHIVO DE TEXTO CON LOS DATOS DE LA TABLA TEMPORAL bdicheq:sc_detalle_edoctaTemp
				-- SE GENERA EL ARCHIVO SQL CON EL CODIGO NECESARIO PARA CREAR EL ARCHIVO DE TEXTO CON LOS RESULTADOS DE LA CONSULTA
				let vcSql = 'echo "UNLOAD TO ' || '''/tmp/sc_detalle_edocta' || sFecha ||  '.txt''' || ' DELIMITER ' || '''|''' ||
					' select idreg,(case when retiro = "0" and deposito = "0" then ''01/01/1900''::date else fecha_emision end),num_cuenta, ' ||
					'nvl(secuencia,0),nvl(nlinea,0),' ||
					'(case when  retiro = ''0'' and deposito = ''0'' then '' '' else  '||
					' lpad(trim(day(fechamov)::char(2)),2,''0'') ' ||  ' || ' || '''/''' || ' || ' || ' DECODE( MONTH(fechamov),' ||
																											' ''1'',''ENE'',''2'',''FEB'',''3'',''MAR'',' ||
																					                		' ''4'',''ABR'',''5'',''MAY'',''6'',''JUN'',' ||
																					                		' ''7'',''JUL'',''8'',''AGO'',''9'',''SEP'',' ||
																					                		' ''10'',''OCT'',''11'',''NOV'',''12'',''DIC'') ' ||
					' end), '||
					'nvl(descripcion,''''),nvl(retiro,0),nvl(deposito,0),nvl(saldo,0) from bdicheq:sc_detalle_edocta where fecha_emision = ''' || pfechaEmision || 
					''' order by idreg;" > /tmp/EdoCtaD.sql';
				SYSTEM vcSql;

				-- SE EJECUTA EL ARCHIVO SQL PARA QUE SE GENERE EL ARCHIVO DE TEXTO
				LET vcStmt = 'dbaccess bdicheq /tmp/EdoCtaD.sql';
				SYSTEM vcStmt;

				-- 4.- SE CREA EL ARCHIVO DE TEXTO CON LOS DATOS DE LA TABLA TEMPORAL bdicheq:sc_aclaraciones_edoctaTemp
				-- SE GENERA EL ARCHIVO SQL CON EL CODIGO NECESARIO PARA CREAR EL ARCHIVO DE TEXTO CON LOS RESULTADOS DE LA CONSULTA
				let vcSql = 'echo "UNLOAD TO ' || '''/tmp/sc_aclaraciones_edocta' || sFecha ||  '.txt''' || ' DELIMITER ' || '''|''' ||
					' select idreg,fecha_emision,num_cuenta,nvl(secuencia,0),nvl(nlinea,0),nvl(fecha_aclara,''01/01/1900''::date), ' ||
					'nvl(descripcion,''''),nvl(importe,0),nvl(naturaleza,'''') ' ||
					'from bdicheq:sc_aclaraciones_edocta where fecha_emision = ''' || pfechaEmision || ''' order by idreg;" > /tmp/EdoCtaA.sql';
				SYSTEM vcSql;

				-- SE EJECUTA EL ARCHIVO SQL PARA QUE SE GENERE EL ARCHIVO DE TEXTO
				LET vcStmt = 'dbaccess bdicheq /tmp/EdoCtaA.sql';
				SYSTEM vcStmt;

				-- 5.- SE CREA EL ARCHIVO DE TEXTO CON LOS DATOS DE LA TABLA TEMPORAL bdicheq:sc_mensajes_edoctaTemp
				-- SE GENERA EL ARCHIVO SQL CON EL CODIGO NECESARIO PARA CREAR EL ARCHIVO DE TEXTO CON LOS RESULTADOS DE LA CONSULTA
				let vcSql = 'echo "UNLOAD TO ' || '''/tmp/sc_mensajes_edocta' || sFecha ||  '.txt''' || ' DELIMITER ' || '''|''' ||
					' select idreg,fecha_emision,num_cuenta,nvl(secuencia,0),nvl(nlinea,0),nvl(mensaje,'''') from bdicheq:sc_mensajes_edocta ' || 
					' where fecha_emision = ''' || pfechaEmision || ''' order by idreg;" > /tmp/EdoCtaM.sql';
				SYSTEM vcSql;

				-- SE EJECUTA EL ARCHIVO SQL PARA QUE SE GENERE EL ARCHIVO DE TEXTO
				LET vcStmt = 'dbaccess bdicheq /tmp/EdoCtaM.sql';
				SYSTEM vcStmt;

				-- 6.- SE CREA EL ARCHIVO DE TEXTO CON LOS DATOS DE LA TABLA TEMPORAL bdicheq:sc_piepagina_edoctaTemp
				-- SE GENERA EL ARCHIVO SQL CON EL CODIGO NECESARIO PARA CREAR EL ARCHIVO DE TEXTO CON LOS RESULTADOS DE LA CONSULTA
				let vcSql = 'echo "UNLOAD TO ' || '''/tmp/sc_piepagina_edocta' || sFecha ||  '.txt''' || ' DELIMITER ' || '''|''' ||
					' select idreg,fecha_emision,num_cuenta,nvl(secuencia,0),nvl(nlinea,0),nvl(mensaje,'''') from bdicheq:sc_piepagina_edocta ' ||
					' where fecha_emision = ''' || pfechaEmision || ''' order by idreg;" > /tmp/EdoCtaP.sql';
				SYSTEM vcSql;

				-- SE EJECUTA EL ARCHIVO SQL PARA QUE SE GENERE EL ARCHIVO DE TEXTO
				LET vcStmt = 'dbaccess bdicheq /tmp/EdoCtaP.sql';
				SYSTEM vcStmt;

				--POR ULTIMO SI TODO SE GENERO SIN ERROR SE ACTUALIZAN LOS CAMPOS DE status_proc,hora_fin,doc_ret y mensaje EN LA TABLA bdicheq:sc_contproc_edocta
				let vcSql = 'echo "update bdicheq:sc_contproc_edocta set status_proc='''||'F'||''','||
					'hora_fin=(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||'''),cod_ret='''||vcodRet||''','||
                    'mensaje='''||vErrorInfo||''' where fecha='''||dfechaactual||''';" > /tmp/contproc_edocta.sql';
                SYSTEM vcSql;                    
                            
                LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';        
                SYSTEM vcStmt;
                
			else
				LET vcodRet='001';
				LET vErrorInfo='LA FECHA ES MENOR QUE LA FECHA DE LA ULTIMA GENERACION DE LOS ARCHIVOS DE TEXTO; NO SE GENERARON LOS ARCHIVOS DE TEXTO';
			end if;
		else
			LET vcodRet='002';
			LET vErrorInfo='YA SE ENCUENTRAN GENERADOS LOS ARCHIVOS DE TEXTO PARA ESTE MES';
		end if;
	else
		LET vcodRet='003';
		LET vErrorInfo='NO ES EL DIA DE CORTE; NO SE GENERARON LOS ARCHIVOS DE TEXTO';
	end if;

	Return vcodRet, vErrorInfo;
end;
end procedure;