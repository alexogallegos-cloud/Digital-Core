CREATE PROCEDURE "informix".sp_archivo_coppcnc(vpFecha_archivo DATE)

RETURNING CHAR(5) AS Respuesta; 

--****************************************************************************************************
-- DESCRIPCION: Genera dos archivos con información de conciliación Corresponsales y Transferencias de Prestamos Coppel, para su entrega a Coppel.
-- AUTOR : Javier Chávez García
-- FECHA : Agosto/2011
-- BD: Intercard
-- SISTEMA : Conciliacion 
--***************************************************************************************************

DEFINE vsCodRetorno            CHAR(5);
DEFINE vsCodIsam             CHAR(5);
DEFINE iSqlErr              INTEGER;
DEFINE iSamErr              INTEGER;
DEFINE vsMensajeError CHAR(30);

DEFINE vTipo CHAR(1);
DEFINE vTipo2 CHAR(1);
DEFINE vNomarchivo CHAR(20);
DEFINE vFecha DATE;
DEFINE vTipomov CHAR(1);
DEFINE vTransacc CHAR(4);
DEFINE vFolio CHAR(16);
DEFINE vMonto MONEY (16,6);
DEFINE vBandera CHAR(1);

DEFINE vsTransacc CHAR(4);
DEFINE vsFoliosif CHAR(16);
DEFINE vMontosif MONEY(16,6);

DEFINE  v_iAnio          INTEGER;
DEFINE  v_iMes           INTEGER;
DEFINE  v_idia           INTEGER;
DEFINE  v_iMesc          char(2);
DEFINE  v_idiac           char(2);
DEFINE  dFechafto        char(10);

DEFINE vsql CHAR(1000);

LET vsCodRetorno  = '000';
LET vsCodIsam  = '000';
LET iSqlErr = 0;
LET iSamErr = 0;
LET vsMensajeError = 'Proceso Existoso';

LET vTipo = '';
LET vTipo2 = '';
LET vNomarchivo = '';
LET vFecha = vpFecha_archivo;
LET vTipomov = '';
LET vTransacc  = '';
LET vFolio  = '';
LET vMonto = 0.0;
LET vBandera  = '';

LET vsTransacc ='';
LET vsFoliosif ='';
LET vMontosif = 0.0;

LET vsql ='';

--SET DEBUG FILE TO "/home/informix/sp_archivo_coppcnc.out";
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr, iSamErr
		IF iSqlErr <> 0 and iSqlErr <> -958 and iSqlErr <> -206 THEN
			LET vsCodRetorno = iSqlErr;
			LET vsCodIsam = iSamErr;
			LET vsMensajeError = 'ERROR NO CONTROLADO INFORMIX';
			
			IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'corrpres' AND dbsname= 'intercard') THEN
				DROP TABLE Intercard:corrpres;
			END IF;
		END IF;
		RETURN vsCodRetorno;
	END EXCEPTION;

--- CREA TABLAS DE TRABAJO

	IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'corrpres' AND dbsname= 'intercard') THEN
		DROP TABLE corrpres;
	END IF;
	
	CREATE TABLE corrpres(
		keyx SERIAL,
		tipo CHAR(1),
		NomArchivo325 CHAR(20),
		fecha DATE,
		TipoMov CHAR(1),
		Tran_Central CHAR(4),
		Folio325 CHAR(16),
		Monto325  MONEY(16,6),
		bandera_proceso CHAR(1),
		transacc CHAR(4),
		folio_suc CHAR(16),
		monto_tot MONEY(16,6),
		primary key (keyx)
	);

    IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'tmp_corresponsales' AND dbsname= 'intercard') THEN
		DROP TABLE tmp_corresponsales;
	END IF;
	
	CREATE TABLE tmp_corresponsales(
		keyx SERIAL,
		tipo CHAR(1),
		NomArchivo325 CHAR(20),
		fecha DATE,
		TipoMov CHAR(1),
		Tran_Central CHAR(4),
		Folio325 CHAR(16),
		Monto325  MONEY(16,6),
		bandera_proceso CHAR(1),
		primary key (keyx)
	 );

    IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'tmp_prestamos' AND dbsname= 'intercard') THEN
		DROP TABLE tmp_prestamos;
	END IF;
	
	CREATE TABLE tmp_prestamos(
		keyx SERIAL,
		tipo CHAR(1),
		NomArchivo325 CHAR(20),
		fecha DATE,
		TipoMov CHAR(1),
		Tran_Central CHAR(4),
		Folio325 CHAR(16),
		Monto325  MONEY(16,6),
		bandera_proceso CHAR(1),
		primary key (keyx)
	 );

        LET v_iAnio = YEAR(vpFecha_archivo);
        LET v_iMes =  LPAD(MONTH(vpFecha_archivo),2,0);
        LET v_idia =  day(vpFecha_archivo);

        if v_idia < 10 then
            LET v_idiac = 0||v_idia;
        else
            LET v_idiac= v_idia;
        end if;

        if v_iMes < 10 then
            LET v_iMesc= 0||v_iMes;
        else
            LET v_iMesc= v_iMes;
        end if;

        LET dFechafto = v_idiac||v_iMesc||v_iAnio;
        LET dFechafto = dFechafto;

	--- GRABA REGISTROS DE CORRESPONSALES EN TABLA TEMPORAL DE CORRESPONSALES
	set isolation to dirty read;
    LET vNomarchivo = 'BCPLCCD_'||TRIM(dFechafto)||'.txt';
    insert into tmp_corresponsales
	select 
	0,'D' as tipo,a.nombrearchivo as NomArchivo325,a.fechaconciliacion as fecha, a.tipomov as TipoMov, b.tran_central as Tran_Central,
	b.folio_mov as Folio325, b.monto as Monto325 , b.bandera_proceso 
	from intercard:central a, bditarjeta:td_concorrd b where a.nombrearchivo = vNomarchivo
	and b.empresa = '001'
	and b.archivo = a.idarchivocental
	and b.folio_mov = a.foliosucursal;
	 
    LET vNomarchivo = 'BCPLCCP_'||TRIM(dFechafto)||'.txt';
    insert into tmp_corresponsales
	select 
	0,'C' as tipo,a.nombrearchivo as NomArchivo325,a.fechaconciliacion as fecha, a.tipomov as TipoMov, b.tran_central as Tran_Central,
	b.folio_mov as Folio325, b.monto as Monto325 , b.bandera_proceso 
	from intercard:central a, bditarjeta:td_concorrp b where a.nombrearchivo = vNomarchivo
	and b.empresa = '001'
	and b.archivo = a.idarchivocental
	and b.folio_mov = a.foliosucursal;    
		
	--let vsql = 'BCPLCCD_'||REPLACE(vpFecha_archivo,"/", "")||'.txt';

	--- GRABA REGISTROS DE PRESTAMOS EN TABLA TEMPORAL DE PRESTAMOS
    LET vNomarchivo = 'BCPLTPD_'||TRIM(dFechafto)||'.txt'; 
    insert into tmp_prestamos
	select 
	0,'P' as tipo,a.nombrearchivo as NomArchivo325,a.fechaconciliacion as fecha, a.tipomov as TipoMov, b.tran_central as Tran_Central,
	b.folio_mov as Folio325, b.monto as Monto325 , b.bandera_proceso 
	from intercard:central a, bditarjeta:td_contpd b where a.nombrearchivo= vNomarchivo
	and b.empresa = '001'
	and b.archivo = a.idarchivocental
	and b.folio_mov = a.foliosucursal;    
	
	---- BUSCA REGISTROS DE CORRESPONSALES EN MOVIMIENTO HISTORICO Y LOS GUARDA EN TABLA DE TRABAJO CORRPRES

	set isolation to dirty read;
	foreach --with hold
			
			select  tipo,NomArchivo325,fecha,  TipoMov, Tran_Central,Folio325, Monto325 ,bandera_proceso 
			into vTipo,vNomarchivo,vFecha,vTipomov,vTransacc,vFolio,vMonto,vBandera
			from tmp_corresponsales
			
			if (vTipo = 'D') then
					select  first 1  transacc, folio_suc, monto_tot
					into vsTransacc, vsFoliosif, vMontosif
					from bdicheq:sc_movhis
					where fech_alt = vpFecha_archivo -1
					and folio_suc = vFolio
					and sucursal = '5005'
					and cancelad <> 'S';
			end if;
			
			if (vTipo = 'C') then
					select  first 1  transacc_suc, folio_suc, monto
					into vsTransacc, vsFoliosif, vMontosif
					from bdicred:sd_movhis
					where codigo_fun='700'
					and codigo_ref=1
					and fecha_mov = vpFecha_archivo -1
					and folio_suc = vFolio
					and sucursal = '5005'
					and reversado <> 'S';
			end if;
			
			insert into corrpres
			values (0,vTipo,vNomarchivo,vFecha,vTipomov,vTransacc,vFolio,vMonto,vBandera,vsTransacc, vsFoliosif, vMontosif);
	
	end foreach;
			
	
	--- BUSCA REGISTROS APLICADOS NO INCLUIDOS EN LOS ARCHIVOS DE CORRESPONSALES
	
	set lock mode to wait 3;
	insert into corrpres (keyx,tipo,NomArchivo325,fecha,  TipoMov, Tran_Central,Folio325, Monto325 ,bandera_proceso,transacc, folio_suc, monto_tot)
	select 0,'D','','','','','',0.0,'',transacc, folio_suc, monto_tot
	from bdicheq:sc_movhis
	where fech_alt = vpFecha_archivo -1
	and folio_suc  not in (select Folio325 from tmp_corresponsales where tipo='D')
	and sucursal = '5005'
	and cancelad <> 'S';
		
	insert into corrpres (keyx,tipo,NomArchivo325,fecha,  TipoMov, Tran_Central,Folio325, Monto325 ,bandera_proceso,transacc, folio_suc, monto_tot)
	select 0,'C','','','','','',0.0,'',transacc_suc, folio_suc, monto
	from bdicred:sd_movhis
	where codigo_fun='700'
	and codigo_ref=1
	and fecha_mov = vpFecha_archivo -1
	and folio_suc not in (select Folio325 from tmp_corresponsales where tipo='C')
	and sucursal = '5005'
	and reversado <> 'S';
		
	---- BUSCA REGISTROS DE PRESTAMOS COPPEL EN MOVIMIENTO HISTORICO Y LOS GUARDA EN TABLA DE TRABAJO CORRPRES

	set isolation to dirty read;
	foreach with hold

			select  tipo,NomArchivo325,fecha,  TipoMov, Tran_Central,Folio325, Monto325 ,bandera_proceso 
			into vTipo,vNomarchivo,vFecha,vTipomov,vTransacc,vFolio,vMonto,vBandera
			from tmp_prestamos
			
			select  first 1  transacc, folio_suc, monto_tot
			into vsTransacc, vsFoliosif, vMontosif
			from bdicheq:sc_movhis
			where fech_alt = vpFecha_archivo -1
			and folio_suc = vFolio
			and sucursal = '5006'
			and cancelad <> 'S';
		
			insert into corrpres
			values (0,vTipo,vNomarchivo,vFecha,vTipomov,vTransacc,vFolio,vMonto,vBandera,vsTransacc, vsFoliosif, vMontosif);
	
	end foreach;
			
	
	--- BUSCA REGISTROS APLICADOS NO INCLUIDOS EN LOS ARCHIVOS DE PRESTAMOS COPPEL
	
	insert into corrpres (keyx,tipo,NomArchivo325,fecha,  TipoMov, Tran_Central,Folio325, Monto325 ,bandera_proceso,transacc, folio_suc, monto_tot)
	select 0,'P','','','','','',0.0,'',transacc, folio_suc, monto_tot
	from bdicheq:sc_movhis
	where fech_alt = vpFecha_archivo -1
	and folio_suc  not in (select Folio325 from tmp_prestamos where tipo='P')
	and sucursal = '5006'
	and cancelad <> 'S';
	
	--/home/sysconau/conciliacion/tcoppel
	--- DESCARGA LA INFORMACION EN ARCHIVOS FISICOS PARA INTERCAMBIO
	let vTipo2 ="P";
	--CORRESPONSALES
	let vsql = '';
	let vsql=  'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/corresponsales.unl select tipo,NomArchivo325,fecha,  TipoMov, Tran_Central,Folio325, Monto325 ,bandera_proceso,transacc, folio_suc, monto_tot from corrpres where tipo <>  '''
               ||vTipo2||''';"> /resplogifx/corresponsales.sql'; 
	system vsql;
	let vsql = '';
	let vsql= 'chmod 777 /resplogifx/corresponsales.sql';
	system vsql;
	let vsql = '';
	let vsql= 'dbaccess intercard /resplogifx/corresponsales.sql';
	system vsql;
	let vsql ='';
	let vsql ='rm /resplogifx/corresponsales.sql';
	system vsql;
	let vsql ='';			
	let vsql = "sed 's/|$//g' /resplogifx/corresponsales.unl >>corresponsales_"||REPLACE(vpFecha_archivo,"/", "")||".unl";
	system vsql;
	let vsql ='';
	let vsql ='rm  /resplogifx/corresponsales.unl';
	system vsql;
	
	--PRESTAMOS COPPEL
	let vsql = '';
	let vsql=  'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/prestamos.unl select tipo,NomArchivo325,fecha,  TipoMov, Tran_Central,Folio325, Monto325 ,bandera_proceso,transacc, folio_suc, monto_tot from corrpres where tipo = '''
          ||vTipo2||''';"> /resplogifx/prestamos.sql'; 
	system vsql;
	let vsql = '';
	let vsql= 'chmod 777 /resplogifx/prestamos.sql';
	system vsql;
	let vsql = '';
	let vsql= 'dbaccess intercard /resplogifx/prestamos.sql';
	system vsql;
	let vsql ='';
	let vsql ='rm /resplogifx/prestamos.sql';
	system vsql;
	let vsql ='';			
	let vsql = "sed 's/|$//g' /resplogifx/prestamos.unl >>prestamos_"||REPLACE(vpFecha_archivo,"/", "")||".unl";
	system vsql;
	let vsql ='';
	let vsql ='rm  /resplogifx/prestamos.unl';
	system vsql;
	
RETURN vsCodRetorno;

END
END PROCEDURE;