CREATE PROCEDURE "informix".sp_conciliacion_baja()


RETURNING CHAR(5) AS Cod_Retorno;
	
---DECLARACION DE VARIABLES
DEFINE iSqlErr      	 INTEGER;
DEFINE cCodRet      	 CHAR(5);
DEFINE cCuenta_Tf 		 CHAR(20);
DEFINE cTelefono 		 CHAR(13);
DEFINE dFec_Cancelac     DATE;
DEFINE dFec_Cancelada    DATE;
DEFINE cNo_Cuenta        CHAR(11);
DEFINE cNo_Cel           CHAR(13);
DEFINE dFec_Can    		 DATE;
DEFINE dFec_C    		 CHAR(11);
DEFINE cDia	   		     CHAR(2);
DEFINE cMes			     CHAR(2);
DEFINE cAnio		     CHAR(4);
DEFINE cNombreArc        CHAR(50);
DEFINE dFechaAnt         DATE;

--DEFINICION DE VARIABLES REPORTE
DEFINE vsSQL 		CHAR(2204);
DEFINE vsSQL1 		CHAR(100);
DEFINE vsSQL2 		CHAR(2004);
DEFINE vsSQL3 		CHAR(100);
DEFINE vsArch   	CHAR(50);
DEFINE vsArchTemp    CHAR(50);
DEFINE vsRepositorio CHAR(100);	
 
---INICIALIZACION DE VARIABLES
LET iSqlErr       	  = 0;
LET cCodRet       	  = '00000';
LET cCuenta_Tf 		  = '';
LET cTelefono 		  = '';
LET dFec_Cancelac     = DATE(1);
LET dFec_Cancelada    = DATE(1);
LET cNo_Cuenta        = '';
LET cNo_Cel           = '';
LET dFec_Can    	  = DATE(1);
LET dFec_C    	      = '';
LET cDia              = '';
LET cMes              = '';
LET cAnio             = '';
LET cNombreArc        = '';
LET dFechaAnt         = DATE(1);
LET vsArch          	 = 'diferenciabajatransfer';
LET vsArchTemp          	 = 'diferenciabajatransfer.sql';
--LET vsRepositorio        = '/informix/mijail/';
LET vsRepositorio        = '/RESPALDOS/';

--SET DEBUG FILE TO '/informix/mijail/sp_conciliacion_baja.out';
--TRACE ON;
	
BEGIN
    ON EXCEPTION 
	SET iSqlErr
	IF 	iSqlErr <> 0 THEN
		LET cCodRet = iSqlErr;
		RETURN cCodRet;
	END IF
END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	SELECT fecha_ant INTO dFechaAnt FROM bdinteg:"informix".si_fechas;
	
	FOREACH 
		
		SELECT fec_cancelac,cuenta_tf,telefono
		INTO dFec_Cancelac,cCuenta_Tf,cTelefono
		FROM bditransfer:"informix".tf_maecte
		WHERE status_cta = '2' and fec_cancelac = dFechaAnt
		
		/*
		SELECT a.fec_cancelac,a.cuenta_tf,a.telefono
		INTO dFec_Cancelac,cCuenta_Tf,cTelefono
		FROM bditransfer:"informix".tf_maecte a 
         join bditransfer:"informix".tf_canc_cta_transfer b on  a.cuenta_tf = b.cuenta_tf
		WHERE a.status_cta = '2' and b.saldo_ret = 0
		*/
		
		SELECT fecha_cancela,cuenta,telefono,nombrearchivo
		INTO dFec_Cancelada,cNo_Cuenta,cNo_Cel,cNombreArc
		FROM bditransfer:"informix".tf_retire_customer
		WHERE cuenta   = cCuenta_Tf;
		
		LET cMes  = SUBSTRING(dFec_Cancelada FROM 1 FOR 2);
		LET cDia  = SUBSTRING(SUBSTRING(dFec_Cancelada FROM 4 FOR 4) FROM 1 FOR 2);
		LET cAnio = SUBSTRING(dFec_Cancelada FROM 7 FOR 10);
		LET dFec_Can = DATE(cMes||'-'||cDia||'-'||cAnio);
		
		IF TRIM(cCuenta_Tf) = TRIM(cNo_Cuenta) AND cTelefono = cNo_Cel AND dFec_Cancelac = dFec_Can THEN
		
			UPDATE bditransfer:"informix".tf_maecte 
			SET status_cta = '3' 
			WHERE cuenta_tf = cCuenta_Tf;
		ELIF NVL(cNombreArc,'') = '' THEN
			INSERT INTO bditransfer:"informix".tf_concilia_difer(nombrearchivo,cuenta,descripcion) VALUES ('RETIRECUSTOMER', cCuenta_Tf, 'NO EXISTE REGISTRO DEL ARCHIVO');
			LET  cCodRet = '00000';
			
		ELSE 	
			INSERT INTO bditransfer:"informix".tf_concilia_difer(nombrearchivo,cuenta,descripcion) VALUES ('RETIRECUSTOMER', cCuenta_Tf, 'LA CUENTA NO EXISTE EN EL ARCHIVO');
			LET  cCodRet = '00000';
			
		END IF;
		
		--delete 	from bditransfer:"informix".tf_canc_cta_transfer 
		--WHERE cuenta_tf = cCuenta_Tf  and saldo_ret= 0;
		
	END FOREACH;
	
	LET cMes  = SUBSTRING(dFechaAnt FROM 1 FOR 2);
	LET cDia  = SUBSTRING(SUBSTRING(dFechaAnt FROM 4 FOR 4) FROM 1 FOR 2);
	LET cAnio = SUBSTRING(dFechaAnt FROM 7 FOR 10);
	LET dFec_Can = DATE(cMes||'-'||cDia||'-'||cAnio);
	
	INSERT INTO tf_concilia_difer(nombrearchivo,cuenta,descripcion)
	SELECT nombrearchivo,cuenta,'LA CUENTA NO EXISTE EN LA TABLA MAESTRA'
	FROM bditransfer:"informix".tf_retire_customer 
	WHERE fecha_cancela = dFec_Can AND cuenta NOT IN (
		SELECT cuenta_tf
		FROM bditransfer:"informix".tf_maecte
		WHERE status_cta = '3' and fec_cancelac = dFechaAnt);

		
	--SE DESCARGA LA INFORMACION DE REPORTE DE SP_CONCILIACION_BAJA
	
		LET dFec_C = YEAR(TODAY)||LPAD(MONTH(TODAY),2,'0')||LPAD(DAY(TODAY),2,'0');
	
		LET vsSQL1 = 'echo "UNLOAD TO  '||TRIM(vsRepositorio)||TRIM(vsArch)||TRIM(dFec_C)||'.txt DELIMITER ' || ''',''';
		LET vsSQL2 =" SELECT 'consecutivo','nombrearchivo','cuenta','descripcion','fecha_insert' FROM 'informix'.tf_concilia_difer UNION SELECT  {INDEX (bditransfer:'informix'.tf_concilia_difer idx_bconcilia)}  consecutivo::CHAR(20),nombrearchivo,cuenta,descripcion,fecha_insert::CHAR(22)"
						||" FROM 'informix'.tf_concilia_difer"
						||" WHERE  fecha_insert::DATE = TODAY"
						||" AND nombrearchivo LIKE '%RETIRECUSTOMER%' "
						||" ORDER BY 1 DESC;";		
						
		LET vsSQL3 = ' " > '|| TRIM(vsRepositorio)||TRIM(vsArchTemp);

		LET vsSQL = TRIM(vsSQL1) ||' ' ||TRIM(vsSQL2)||TRIM(vsSQL3);
			
			--Verifica que no este vacia la consulta.
			IF ( vsSQL <> '' ) THEN
				SYSTEM vsSQL;
               --Permiso para la creacion de archivo.
				LET vsSQL = '' ;
				LET vsSQL = 'chmod 666 '|| TRIM(vsRepositorio)||TRIM(vsArchTemp);
				SYSTEM vsSQL ;

				LET vsSQL = '' ;
				LET vsSQL = 'dbaccess bditransfer < '|| TRIM(vsRepositorio)||TRIM(vsArchTemp);
				SYSTEM vsSQL ;
				--Borra el archivo de control.
				LET vsSQL = '' ;
				LET vsSQL = 'rm  '|| TRIM(vsRepositorio)||TRIM(vsArchTemp);
				SYSTEM vsSQL;				
			ELSE
				--No fue posible generar el archivo.
				LET cCodRet = '00002';
				--LET cDescripcion = 'No fue posible generar el archivo';	
			END IF;	

			
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'Fecha:03-Febrero-2015',
'ModificaciÃ³n: Se modifica procedimiento para evitar insercion de valores nulos',
'cuando no se realizo la carga de archivos de conciliacion transfer',
'Sustento: RQI 63 096 Transfer Cancela Cliente Batch',
'Solicita: Manuel Osuna',
'BD: bditransfer';

create procedure "informix".sp_transfer_valida_cta (
					psvalida                char (2),
					psid_cuenta_valida      char (20) 			
					)
returning 	
				varchar (5) as codret, char(20) as Cuenta; 

define visqlerr integer ;
define vscodret varchar(5);
define vsmensaje_respuesta varchar(250);
		
define vsid_cuenta_valida	 char(20);	
define vscuenta char(20);
define vstatus_tar char(1); -- NEW	
define vicontador  integer;

begin
	on exception set visqlerr
		let vscodret = '00001';
		return 	vscodret,vscuenta;
	
	end exception;
	on exception in (-535)
			commit work; --termina la transaccion actual y continua
	end exception with resume;
	on exception in (-255)
			begin work; --termina la transaccion actual y continua
	end exception with resume;
	
	
--set debug file to "/informix/HomeInformix/mgap/sp_transfer_valida_cta.out";
--trace on;	

				
let visqlerr  = 0;
let vscodret  = '00000';
let vsmensaje_respuesta = 'Iniciando proceso de validación de Cuentas Transfer.';						

LET vsid_cuenta_valida = psid_cuenta_valida;
let vscuenta = '';	
let vstatus_tar = ''; -- NEW	
let vicontador = 0;

 if exists ( select dbsname, tabname from sysmaster:systabnames  where tabname = 'tf_maecte_1' and dbsname= 'bditransfer') then
		drop table bditransfer:"informix".tf_maecte_1;
 end if;




	        IF (psvalida = '01' OR psvalida = '00') then   --- Valida Telefono 
			
			       	  set isolation to dirty read;
					  select cuenta_tf from Bditransfer:"informix".tf_maecte
					  where telefono = substr(TRIM(vsid_cuenta_valida),-10) and  empresa = '001' and  status_cta in (1,2) order by cuenta_tf desc into temp tf_maecte_1 with no log;
		 
					  set isolation to dirty read;
					  select limit 1 cuenta_tf into vscuenta from Bditransfer:"informix".tf_maecte_1;
						
					  drop table bditransfer:"informix".tf_maecte_1;
		 
					   if (vscuenta = '' or vscuenta is null) then 
						  let vscodret = '00001';
						  return 	vscodret,vscuenta;
						end if; 
						
					  return 	vscodret,vscuenta;	
				
					
            elif (psvalida = '02') then   -- Valida Cuenta Clabe
		
		          set isolation to dirty read;
		          select cuenta_tf into vscuenta from Bditransfer:"informix".tf_maecte
			      where cta_clabe = substr(TRIM(vsid_cuenta_valida),-18) and empresa = '001' and status_cta in (1,2);
   
                   if (vscuenta = '' or vscuenta is null) then 
		              let vscodret = '00001';
                      return 	vscodret,vscuenta;
                    end if;
   
                return 	vscodret,vscuenta;
   
            elif (psvalida = '03') then ---  Valida Tarjeta 

			     /*set isolation to dirty read;   -- Tipo de Origen es Numero de tarjeta
				 select cuenta_tf into vscuenta from Bditransfer:"informix".tf_maecte
			     where num_tarjeta = substr(TRIM(vsid_cuenta_valida),-16) and empresa = '001' and status_cta in (1,2);
				 
				  if (vscuenta = '' or vscuenta is null) then 
		              let vscodret = '00001';
                      return 	vscodret,vscuenta;
                   end if; */
    
	            if  (vsid_cuenta_valida <> '000000000000000000' and vsid_cuenta_valida is not null and vsid_cuenta_valida <> '')  then
                    
					set isolation to dirty read;  
                    select limit 1 cuenta,status_tar into vscuenta,vstatus_tar from bdicheq:"informix".sc_tarjeta where empresa = '001' 
                    and num_tarjeta = substr(TRIM(vsid_cuenta_valida),-16);
  
                    if (vscuenta = '' or vscuenta is null) then 
		              let vscodret = '00001';
                      return 	vscodret,vscuenta;
                    end if; 				   
                  
                    if vstatus_tar != 'A' then
                       let vscodret = '00002';
					   return 	vscodret,vscuenta;
					end if;
					
				 else                 
                       let vscodret = '00003';
					   return 	vscodret,vscuenta;
				
				end if;
					 			 					
                return 	vscodret,vscuenta;
			   
            elif (psvalida = '04') then	--- Valida Cta. Transfer 
			
		          set isolation to dirty read;  
				  select cuenta_tf into vscuenta from Bditransfer:"informix".tf_maecte
                  where cuenta_tf = substr(TRIM(vsid_cuenta_valida),-11) and empresa = '001' and status_cta in (1,2);
          
				  
				    if (vscuenta = '' or vscuenta is null) then 
		              let vscodret = '00001';
                      return 	vscodret,vscuenta;
                    end if; 
					                  
 			       return 	vscodret,vscuenta;
			END IF;
 	
		 	 
--########################################################################################################### 

let vsmensaje_respuesta = 'Finaliza proceso de validación de ctas. Transfer.';
return 	vscodret,vscuenta;

end
end procedure
DOCUMENT
'AUTOR: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto: RQM  06 459 Cancelación de Cta. Transfer cuando tiene saldo retenido ',
'Solicito: Ana Laura Alverdi Morfin',
'Descripcion: Se considera en la integración y validación las cuentas con estatus de pre-canceladas.',
'Fecha: 2016/02/02',
'Version: 20160202.1500',
'BD: BdiTransfer', 
'',
'MODIFICO: L.I.A Ricardo Reséndiz Martinez',
'Proyecto: RQM 10 616 Incorporar pago de servicios Transfer ',
'Solicito: Jose Luis Puebla Salinas',
'Descripcion: Se trata tema de telefono a varias cuentas ',
'Fecha: 2016/06/09',
'Version: 20160609.1800',
'BD: BdiTransfer', 
'',
'MODIFICO: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto: RQM 06 573 Conciliación Administrativa Transfer',
'Solicito: Ana Laura Alverdi Morfin',
'Descripcion: Cambiar la validación de tarjetas a la base de datos de Captación',
'Fecha: 2017/04/05',
'Version: 20170405.1700',
'BD: BdiTransfer', 
'';

CREATE PROCEDURE "informix".sp_campana_cta_efec_dig()
RETURNING CHAR(6) AS cCodRet, CHAR(100) AS cMensCodRet


--DEFINICION DE VARIABLES
DEFINE cCodRet 		CHAR(6);
DEFINE cMensCodRet	CHAR(100);
DEFINE iSQLerr		INTEGER;
DEFINE cProceso		CHAR(100);
DEFINE iNumCelular	CHAR(10);
DEFINE cCodretreg	CHAR(5);

--ASIGNACION DE VARIABLES
LET cCodRet 	 = '000000';
LET cMensCodRet  = 'PROCESO EXITOSO';
LET cProceso	 = '';
LET iNumCelular  = '';
LET cCodretreg   = '00000';



--SET DEBUG FILE TO "/informix/tmp/ingrid/sp_campaña_cta_efec_dig.out";
--TRACE ON;


	BEGIN
		--Manejo del error
		ON EXCEPTION SET iSQLerr
			IF iSQLerr <> 0 THEN
				LET cCodRet = iSQLerr;
				LET cMensCodRet = 'ERROR AL EJECUTAR EL PROCESO';
				RETURN cCodRet, cMensCodRet;
			END IF;
		END EXCEPTION;
			
					
					--OBTENCION DE CELULARES A LOS QUE SE LES ENVIARÁ SMS
					FOREACH 
						
						SELECT DISTINCT telefono 
						INTO iNumCelular
						FROM bditransfer:tf_user_transfer 
						WHERE fecha_corte = TODAY -1
							
							
						--SE ENVIA SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CED_BIEN','CED_BIEN','000000000','','','2','','','','','','','','','','','',iNumCelular,1,0,0,0,0,'','')	
						INTO cCodretreg;
		
					END FOREACH;
					
					IF NVL (iNumCelular,'') = '' THEN
						LET cCodRet = '000001';
						LET cMensCodRet = 'NO SE ENCONTRARON REGISTROS DE ALTAS';
					END IF;
			
			--SE ENVIA SMS PARA NUMERO ESPECÍFICO
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CED_BIEN','CED_BIEN','000000000','','','2','','','','','','','','','','','','5567031817',1,0,0,0,0,'','')
			INTO cCodretreg;
			
			RETURN cCodRet, cMensCodRet;
	END
END PROCEDURE
DOCUMENT
'REALIZA: Envío de SMS a clientes de campaña cuenta efectiva digital',
'EQUIPO:Análisis y diseño de Mannto.4',
'FECHA:19/04/2017',
'VERSION:0.0.1',
'MODIFICO: Ingrid Pamela Cázarez Villegas';

CREATE PROCEDURE "informix".sp_archivo_opm()
RETURNING VARCHAR(5) AS CodRetorno, 
		  VARCHAR(200) AS Mensaje;


/*DEFINICION DE VARIABLES */
DEFINE viSqlError 		  INTEGER;
DEFINE vsCodRetorno       VARCHAR (5);
DEFINE vsMensaje          VARCHAR(200);
DEFINE dFechaAnt          DATE;
DEFINE cDia               CHAR(2);
DEFINE cMes 		      CHAR(10);
DEFINE cAnio 		      CHAR(4);
DEFINE vsStmt2			  CHAR(1000);
DEFINE vsStmt3			  CHAR(1000);
DEFINE vsStmt4			  CHAR(1000);
DEFINE vsStmt5			  CHAR(1000);
DEFINE vsStmt6			  CHAR(1000);
DEFINE vsStmt7			  CHAR(1000);
DEFINE vsStmt8			  CHAR(1000);
DEFINE vsStmt9			  CHAR(1000);
DEFINE viRegistros 		  INTEGER;
DEFINE vArch  			  INTEGER;
DEFINE vsNombreArchivo    VARCHAR(50);
DEFINE visam_error		  INTEGER;
DEFINE isam_error      	  INTEGER;
DEFINE mSaldoDiario		  MONEY;
DEFINE iTransacciones	  INTEGER;
DEFINE iTotalAltas		  INTEGER;
DEFINE iTotalBajas		  INTEGER;
DEFINE cCelulares		  CHAR(10);
DEFINE cSQL1			  CHAR(500);
DEFINE cSQL				  CHAR(500);
DEFINE vsRutaArchRep	  CHAR(150);

/*DEFINICION DE VARIABLES*/
LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsMensaje = '';
LET dFechaAnt = '';
LET cDia = '';
LET cMes = '';
LET cAnio = '';
LET vsStmt2 = '';
LET vsStmt3 = '';
LET vsStmt4 = '';
LET vsStmt5 = '';
LET vsStmt6 = '';
LET vsStmt7 = '';
LET vsStmt8 = '';
LET vsStmt9 = '';
LET viRegistros = 0;
LET vArch =0;
LET vsNombreArchivo = '';
LET visam_error = 0;
LET isam_error = 0;
LET mSaldoDiario = 0;
LET iTransacciones = 0;
LET iTotalAltas = 0;
LET iTotalBajas = 0;
LET cCelulares = '';
LET cSQL1 = ' ';
LET cSQL = ' ';
LET vsRutaArchRep = ' ';

--SET DEBUG FILE TO "/tmp/ALAN/transfer/sp_archivo_opm.out";
--TRACE ON;


BEGIN


	ON EXCEPTION SET viSqlError
		IF (viSqlError != 0) THEN
			LET vsCodRetorno = viSqlError;
			RETURN vsCodRetorno, vsMensaje;
		END IF;
	END EXCEPTION;
	
	--Obtiene fecha dia anterior
	
			SELECT fecha_ant
			INTO dFechaAnt
			FROM bdinteg:"informix".si_fechas;
			
			LET cDia = LPAD(DAY(dFechaAnt::DATE), 2, '0');
			LET cMes = LPAD(MONTH(dFechaAnt::DATE), 2, '0');
			LET cAnio = YEAR(dFechaAnt ::DATE);
			
			
			IF cMes = '01' THEN LET cMes = 'ENERO';
				ELIF cMes = '02' THEN LET cMes = 'FEBRERO';
				ELIF cMes = '03' THEN LET cMes = 'MARZO';
				ELIF cMes = '04' THEN LET cMes = 'ABRIL';
				ELIF cMes = '05' THEN LET cMes = 'MAYO';
				ELIF cMes = '06' THEN LET cMes = 'JUNIO';
				ELIF cMes = '07' THEN LET cMes = 'JULIO';
				ELIF cMes = '08' THEN LET cMes = 'AGOSTO';
				ELIF cMes = '09' THEN LET cMes = 'SEPTIEMBRE';
				ELIF cMes = '10' THEN LET cMes = 'OCTUBRE';
				ELIF cMes = '11' THEN LET cMes = 'NOVIEMBRE';
				ELIF cMes = '12' THEN LET cMes = 'DICIEMBRE';
			END IF;
	
		IF (vsCodRetorno='00000') THEN
		
			TRUNCATE TABLE bditransfer:"informix".arch_opm_paso;
			UPDATE statistics medium FOR TABLE bditransfer:"informix".arch_opm_paso;

			--Nombre del archivo
			LET vsNombreArchivo = 'CED_Reporte_Diario'||'.csv';
			
			SET LOCK MODE TO WAIT 3;
		
			
				SELECT SUM(sdo_cta)
				INTO mSaldoDiario
				FROM tf_account_balance_customer
				WHERE fecha_proceso = dFechaAnt;
				
				SELECT COUNT(consecutivo)
				INTO iTransacciones
				FROM tf_success_transac
				WHERE fecha_alt = dFechaAnt;
				
				SELECT {+INDEX (bditransfer:"informix".tf_user_transfer 204_631 )} COUNT(consecutivo)
				INTO iTotalAltas
				FROM tf_user_transfer;
				
				SELECT {+INDEX (bditransfer:"informix".tf_retire_customer 139_279 )} COUNT(consecutivo)
				INTO iTotalBajas
				FROM tf_retire_customer;
				
				
				LET vsStmt2 =  'INFORMACIÓN '||cDia||' '||cMes;
					INSERT INTO arch_opm_paso (linea)
					VALUES (vsStmt2);
					
				LET vsStmt3 =  'Saldo diario'||' '||TRIM(NVL(mSaldoDiario,'00'));	
					INSERT INTO arch_opm_paso (linea)
					VALUES (vsStmt3);
					
				LET vsStmt4 =  'Total de transacciones'||' '||TRIM(NVL(iTransacciones,'00'));
					INSERT INTO arch_opm_paso (linea)
					VALUES (vsStmt4);
				
				LET vsStmt5 =  'Total de altas'||' '||TRIM(NVL(iTotalAltas,'00'));
					INSERT INTO arch_opm_paso (linea)
					VALUES (vsStmt5);
				
				LET vsStmt6 =  'Total de bajas'||' '||TRIM(NVL(iTotalBajas,'00'));
					INSERT INTO arch_opm_paso (linea)
					VALUES (vsStmt6);
					
				LET vsStmt7 = ' ';
					INSERT INTO arch_opm_paso (linea)
					VALUES (vsStmt7);
				
				LET vsStmt8 =  'Detalle de altas';
					INSERT INTO arch_opm_paso (linea)
					VALUES (vsStmt8);

			FOREACH	
					SELECT telefono
					INTO cCelulares
					FROM tf_user_transfer
					WHERE fecha_alta = dFechaAnt
				
				LET vsStmt9 =  TRIM(NVL(cCelulares,''));
					INSERT INTO arch_opm_paso (linea)
					VALUES (vsStmt9);
			
			END FOREACH;
			
			
			LET vsRutaArchRep = '/ifxsif01/Control-M/';
			
			LET vsCodRetorno  = '00020';
			LET vsMensaje  = 'ERROR AL GENERAR EL ARCHIVO';
		
			LET cSQL1 = 'echo "UNLOAD TO '||TRIM(vsRutaArchRep)||TRIM(vsNombreArchivo)||' delimiter '||' SELECT linea FROM bditransfer:"informix".arch_opm_paso ORDER BY secuencial" >'||TRIM(vsRutaArchRep)||'Ejecuta_archivo.sql';
			SYSTEM cSQL1;

			LET cSQL='dbaccess bditransfer '||TRIM(vsRutaArchRep)||'Ejecuta_archivo.sql';
			System cSQL;
			
			LET cSQL = '' ;
			LET cSQL = 'zip /'||TRIM(vsRutaArchRep)||TRIM(vsNombreArchivo)||'.zip '||'-P bancoppel /'||TRIM(vsRutaArchRep)||TRIM(vsNombreArchivo);
			SYSTEM cSQL ;
			
			LET vsCodRetorno  = '00000';
			
			IF vsCodRetorno = '00000' THEN
				LET vsMensaje  = 'REPORTE GENERADO CORRECTAMENTE';
			END IF;
				
				
		END IF;
	RETURN vsCodRetorno, vsMensaje;
END;
END PROCEDURE;