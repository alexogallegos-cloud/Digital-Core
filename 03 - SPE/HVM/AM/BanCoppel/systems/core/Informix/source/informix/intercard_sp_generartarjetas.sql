CREATE PROCEDURE "informix".sp_generartarjetas(v_indicadortipoproceso varchar(1))
returning varchar(6), varchar(80);


define  p_cod_ret                                 varchar(6);
define  p_mensaje                                 varchar(80);
define  p_cod_ret2                                varchar(6);
define  p_mensaje2                                varchar(80);
define  sql_err                                   integer;
define  isam_err                                  integer;
define  error_info                                varchar(80);
define  v_sucursal                                varchar(5);
define v_tipoimagen                               varchar(2);
---------------------------------
define v_icvv                                     varchar(1);
---------------------------------
define v_cantidad                                 integer;
define v_codproducto                              varchar(3);
define v_tipotarjeta                              varchar(3);
define v_clavetipotarjeta                         varchar(3);
define v_fechaexp                                 varchar(4);
define v_consecutivoguia                          integer;
define v_signumlote                               integer;
define v_contarjeta                               integer;
define v_contxguia                                integer;
define v_signumtarjeta                            integer;
define v_bin                                      varchar(6);
define v_resultmod                                integer;
define v_temp                                     integer;
define v_tempstr                                  varchar(50);
define v_suma                                     integer;
define v_digitoverificador                        integer;
define v_numcuentaasociada                        varchar(13);
define v_numtarjetapormaquilar                    varchar(16);
define v_soportacajeropropio                      varchar(1);
define v_soportacajeroconvenio                    varchar(1);
define v_soportacajerored                         varchar(1);
define v_soportainternacional                     varchar(1);
define v_servicecode                              varchar(3);
define v_contadorxguia                            integer;
define i,j                                        integer;
define v_numtarjetasindigver                      varchar(15);
define prueba                                     integer;
define prueba0                                    integer;
define v_signumtarjetacadena                      varchar(30);
define  v_flagindicadorprocesomaq                 char;
define v_consecutivomaquila                       integer;
define  v_leyendatarjeta                          varchar(28);
define v_direccionsucursal                        varchar(150);
define v_fechahorageneracionproceso               datetime day to fraction;
define v_maxtarjxguia                             integer;
define  ld_detallemaq                             varchar(16);
define v_temconsecutivoguia                       integer;
define v_consecutivo_actual                       integer;
define v_secuencia                                integer;
define v_contadorfinal                            integer;
define temp_consecutivoguia                       integer;
define temp_signumlote                            integer;
define temp_consecutivomaquila                    integer;
define v_prefijo                                  varchar(10);
define v_sufijo                                   varchar(10);
define v_claveproductoimagen                      varchar(3);
define v_consecutivo_archivointeger               integer;
define v_consecutivo_archivocadena                varchar(10);
define v_date                                     date;
define v_registros                                integer;
define v_solicitadas                              integer;
define v_encontro                                 varchar(1);
define v_inserto                                  varchar(1);
define v_banderiar                                varchar(50);
define v_consecutivo_archivo                      varchar(10);
define v_consecutivo                      integer;
define v_tipo                                     varchar(1);
define v_nombre									  varchar(21);
define v_loteactual                               integer;
define tarjetaActual							  varchar(8);
define tarjetaPasada							  varchar(8);
define v_fecha_generacion                         date;
define v_solicitadaslote                          integer;
/*JQL-DebitoChip-20110714 Begin*/
define v_chip                      varchar(6);
/*JQL-DebitoChip-20110714 End*/
/*JQL-DebitoChip-20131211 Begin*/
define v_IdProveedor							  integer;
/*JQL-DebitoChip-20131211 End*/
/*20160906.JHAP.Begin*/
define v_idsolicitud integer;
define v_numcliente varchar(13);
define v_numcuenta varchar(13);
define v_existenumcuenta int;
define v_codprodcta varchar(4);
define v_titular varchar(1);
define v_usuario varchar(10);
define v_tipoenvio varchar(1);
define v_codestatusasignada varchar(3);
define v_fechaasignacion varchar(25);
define v_fechanacimiento varchar(19);
define v_numfolioasignacion int;
define v_canal varchar(30);
define v_numtarjetasustituta varchar(16);
define v_descripcion varchar(60);
define v_flagdiseno varchar(1);
define v_id_diseno int;
define v_mensajeerr varchar(100);
/*20160906.JHAP.End*/
/*20180125.JHAP.Begin*/
define v_EsCVV2Dinamico varchar(100);
/*20180125.JHAP.End*/
	--set debug file to "/informix/sp_generartarjetas.out";
	--trace on;
/*JDSO-PINOFFLINE-20190414 Begin*/
define v_TecnologiaTarjeta varchar(1);
/*JDSO-PINOFFLINE-20190414 End*/
	
/*JDSO-CuentaN2-20220103 Begin*/
define v_esVirtual varchar(1);
/*JDSO-CuentaN2-20220103 End*/
	
define v_ultimatarjetalote integer;

define v_proc_ini integer;
define v_proc_ok integer;
define v_str_proc_ok varchar(1);

let v_solicitadaslote=0;
let tarjetaPasada="";
let tarjetaActual="";
let v_loteactual=0;
let v_nombre="";
let v_tipo="";
let v_clavetipotarjeta="";
let  v_sucursal="";
let  v_tipoimagen="";
let  v_cantidad=0;
let  v_codproducto="";
let  v_tipotarjeta="";
let  v_fechaexp="";
let  v_consecutivoguia=0;
let  v_signumlote=0;
let  v_contarjeta=0;
let  v_contxguia=0;
let  v_signumtarjeta=0;
let  v_bin="";
let  v_resultmod=0;
let  v_temp=0;
let  v_tempstr="";
let  v_suma=0;
let  v_digitoverificador=0;
let  v_numcuentaasociada="";
let  v_numtarjetapormaquilar="";
let  v_soportacajeropropio="";
let  v_soportacajeroconvenio="";
let  v_soportacajerored="";
let  v_soportainternacional="";
let  v_servicecode="";
let  v_contadorxguia=0;
let i=1;
let j=1;
let v_numtarjetasindigver="";
let prueba=0;
let prueba0=0;
let v_signumtarjetacadena="";
let v_consecutivomaquila=0;
let  v_leyendatarjeta="";
let v_direccionsucursal="";
let v_fechahorageneracionproceso= current day to fraction;
let v_maxtarjxguia=0;
let  ld_detallemaq="";
let v_temconsecutivoguia=0;
let v_consecutivo_actual=0;
let v_secuencia=0;
let v_contadorfinal=0;
let temp_consecutivoguia=0;
let temp_signumlote=0;
let temp_consecutivomaquila=0;
let v_prefijo="";
let v_sufijo="";
let v_claveproductoimagen="";
let v_consecutivo_archivointeger=0;
let v_consecutivo_archivocadena="";
let v_registros=0;
let v_solicitadas=0;
let v_date= current day to day;
let v_fecha_generacion=current day to day;
let v_encontro= 'F';
let v_inserto= 'F';
let v_banderiar="";
let v_consecutivo_archivo="";
let v_consecutivo="";

/*JQL-DebitoChip-20110714 Begin*/
let v_chip="";
/*JQL-DebitoChip-20110714 End*/
/*JQL-DebitoChip-20131211 Begin*/
let v_IdProveedor=0;
/*JQL-DebitoChip-20131211 End*/
/*20160906.JHAP.Begin*/
let v_idsolicitud=0;
LET v_codestatusasignada = "";
LET v_numcliente = ""; 
LET v_numcuenta = "";
LET v_existenumcuenta = 0;
LET v_codprodcta = "";
LET v_titular = "";
LET v_usuario = "";
LET v_tipoenvio = "";
LET v_fechaasignacion = "";
LET v_fechanacimiento = "";
LET v_canal = "";
LET v_numfolioasignacion=0;
LET v_numtarjetasustituta = "";
LET v_descripcion = "";
LET v_flagdiseno = "";
LET v_id_diseno = 0;
LET v_mensajeerr = "";
/*20160906.JHAP.End*/

/*JDSO-PINOFFLINE-20190414 Begin*/
let v_TecnologiaTarjeta = "";
/*JDSO-PINOFFLINE-20190414 End*/ 
/*JDSO-CuentaN2-20220103 Begin*/
let v_esVirtual = "";
/*JDSO-CuentaN2-20220103 End*/
let v_ultimatarjetalote=0;

/*Proceso No Iniciado*/
let v_proc_ini = 0;
/*Proceso Fallo*/
let v_proc_ok = 0;

let v_str_proc_ok = "";

--set debug file to '/home/sysinven/NIP/sp_generartarjetas.out';
--trace on;
	
begin

  on exception set  sql_err  , isam_err, error_info
        Let  p_cod_ret   = sql_err  ;
        Let  p_mensaje  = error_info ;
		set debug file to '/RESPALDOSNEW/excepcion_sp_generartarjetas2.out';
		trace on;
        ROLLBACK WORK;
        return p_cod_ret, p_mensaje;
  end exception;

  	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
  
  Let  p_cod_ret = '000';
  Let  p_mensaje = 'PROCESO EXITOSO';
  
	SELECT flag_proc_ok INTO v_str_proc_ok FROM "informix".paraminventarios;
	IF v_str_proc_ok = 'F' THEN
		Let  p_cod_ret = '004';
		Let  p_mensaje = 'PROCESO ANTERIOR CON ERRORES';
		ROLLBACK WORK;
	END IF;
  
  /*BEGIN WORK;*/

	foreach WITH HOLD
		SELECT distinct clave_sucursal INTO v_sucursal FROM "informix".solicitud_maquila WHERE flagprocesorealizado='F' order by clave_sucursal
		/*WITH HOLD*/
		foreach WITH HOLD
			SELECT (sm.clave_tipotarjeta), (sm.cantidad),trim(sm.codproductotarjeta),trim(sm.fechaexp),trim (sm.tipomaquila), trim(sm.nom_cliente),(sm.fecha_generacion),sm.consecutivo,st.idsolicitud, NVL(st.tipoenvio,'S'), sm.flagdiseno, sm.id_diseno
			INTO  v_clavetipotarjeta,v_cantidad,v_codproducto, v_fechaexp ,v_tipo, v_nombre, v_fecha_generacion,v_consecutivo, v_idsolicitud, v_tipoenvio, v_flagdiseno, v_id_diseno
			FROM "informix".solicitud_maquila sm 
			LEFT OUTER JOIN "informix".solicitudtarjeta st ON  sm.clave_sucursal=st.sucursal AND sm.fecha_generacion=st.fechasolicitud 
			AND sm.tipomaquila=st.tipomaquila AND sm.clave_tipotarjeta=st.clave_tipotarjeta 
			AND sm.codproductotarjeta=st.codproductotarjeta AND sm.usuario=LEFT(st.usuario,8)
			AND estatusproceso = 'F' 
			WHERE sm.clave_sucursal=v_sucursal AND sm.indicadortipoproceso=v_indicadortipoproceso AND sm.flagprocesorealizado= 'F' 
			ORDER BY sm.clave_tipotarjeta , sm.tipomaquila ASC, st.tipoenvio
			/*WITH HOLD*/
			
			IF v_indicadortipoproceso = 'P' THEN 
				IF v_fecha_generacion = v_date THEN
					CONTINUE FOREACH;						
				END IF;                     
			END IF;
			
			

			SELECT esvirtual, direccion_sucursal INTO v_esVirtual, v_direccionsucursal FROM "informix".sucursal WHERE clave_sucursal=v_sucursal;
			
			IF v_tipoenvio = 'D' THEN
				/*se obtiene el domicilio del cliente*/
				SELECT TRIM(direccion_calle1) || ', ' || TRIM(direccion_calle2) || ', ' || TRIM(direccion_colonia) || ', ' || TRIM(direccion_municipio) || ', ' || TRIM(direccion_estado) || ', ' || TRIM(direccion_cp) 
				INTO v_direccionsucursal 
				FROM "informix".solicitudtarjeta 
				WHERE idsolicitud= v_idsolicitud;
			END IF;
			
			/*
			SELECT max(consecutivo_archivo) INTO v_consecutivo_archivocadena FROM "informix".bitacora_archivo_maq WHERE fecha_generacion=v_date AND provedormaquila = v_IdProveedor;
			IF cast(v_consecutivo_archivocadena as integer) > 0 THEN
				let  v_consecutivo_archivointeger= cast(v_consecutivo_archivocadena as integer)+1;
				let v_consecutivo_archivocadena= cast(v_consecutivo_archivointeger as varchar(10));
				while (length(v_consecutivo_archivocadena) < 2)
					let v_consecutivo_archivocadena= "0" || v_consecutivo_archivocadena;
				end while;
				let v_consecutivo_archivo=v_consecutivo_archivocadena;
			ELSE
				let v_consecutivo_archivo = '01';
			END IF;
			*/

			SELECT tipo, bin, chip, clave, consecutivo, leyendatarjeta, consecutivo_actual, card_type, provedormaquila 
			INTO v_tipotarjeta, v_bin, v_chip, v_claveproductoimagen,v_signumtarjeta, v_leyendatarjeta, v_consecutivo_actual, v_TecnologiaTarjeta, v_IdProveedor 
			FROM "informix".tipotarjeta 
			WHERE clave_tipotarjeta = v_clavetipotarjeta;

			IF v_chip = 'V' THEN
				let v_icvv = 'V';
			ELSE
				let v_icvv = 'F';
			END IF;

			SELECT cast(NVL(MAX(consecutivo_archivo),'0') as integer)+ 1 INTO v_consecutivo_archivocadena FROM "informix".bitacora_archivo_maq WHERE fecha_generacion=current day to day AND provedormaquila = v_IdProveedor;
			while (length(v_consecutivo_archivocadena) < 2)
				let v_consecutivo_archivocadena= "0" || v_consecutivo_archivocadena;
			end while;	
			let v_consecutivo_archivo=v_consecutivo_archivocadena;		
			/*SELECT LPAD(NVL(MAX(consecutivo_archivo),'1'), 2, '0') INTO v_consecutivo_archivo FROM "informix".bitacora_archivo_maq WHERE fecha_generacion=v_date AND provedormaquila = v_IdProveedor; Se comenta por incompatibilidad Se comenta por incompatibilidad 5.1*/

			/*SELECT trim(tt.tipo), trim(tt.bin), trim(tt.chip) INTO v_tipotarjeta, v_bin, v_chip FROM "informix".tipotarjeta tt where tt.clave_tipotarjeta=v_clavetipotarjeta;*/
			
			/*SELECT clave,consecutivo,leyendatarjeta,consecutivo_actual INTO v_claveproductoimagen,v_signumtarjeta, v_leyendatarjeta, v_consecutivo_actual  FROM "informix".tipotarjeta where  clave_tipotarjeta=v_clavetipotarjeta;*/
			
			SELECT soportatranatmcajeropropio,soportatranatmcajeroconvenio,soportatranatmcajerored,soportatranatminternacional
			INTO v_soportacajeropropio, v_soportacajeroconvenio, v_soportacajerored, v_soportainternacional 
			FROM "informix".productotarjeta
			WHERE codproductotarjeta= v_codproducto;
			
			/*SELECT tipo, bin, chip, clave, consecutivo, leyendatarjeta, consecutivo_actual, card_type, provedormaquila 
			INTO v_tipotarjeta, v_bin, v_chip, v_claveproductoimagen,v_signumtarjeta, v_leyendatarjeta, v_consecutivo_actual, v_TecnologiaTarjeta, v_IdProveedor 
			FROM "informix".tipotarjeta 
			WHERE clave_tipotarjeta = v_clavetipotarjeta;
			*/
			SELECT servicecode,prefijo  INTO v_servicecode,v_prefijo FROM "informix".bines where bin=v_bin;
			
			SELECT producto, sufijo INTO v_tipoimagen, v_sufijo FROM "informix".productoimagen where clave=v_claveproductoimagen;
					
            /*se obtiene el consecutivo guia y el siguente numero de lote de la tabla parametros*/
			SELECT maxtarjxguia,consecutivoguia,signumlote INTO v_maxtarjxguia, v_consecutivoguia,v_signumlote  FROM "informix".paraminventarios;
			
			BEGIN WORK;
			IF v_tipo = 'N' THEN
			
				let v_nombre = null;
				
				INSERT INTO "informix".lote(numerolote,fechageneracion,cantidadtarjetassol,clave_tipotarjeta,clave_sucursal,tipomaquila, idProveedor, tipoenvio)
				VALUES(v_signumlote,v_fechahorageneracionproceso,v_cantidad,v_clavetipotarjeta,v_sucursal,v_tipo, v_IdProveedor, v_tipoenvio);
				
				IF v_proc_ini = 0 THEN
					/*Proceso Iniciado*/
					let v_proc_ini = 1;
				END IF;
				
				INSERT INTO "informix".flujolote(numerolote,codflujo,fecha) values (v_signumlote,'GAM',v_fechahorageneracionproceso);

				/*SELECT esvirtual INTO v_esVirtual FROM "informix".sucursal WHERE clave_sucursal=v_sucursal;*/
				IF v_esVirtual <> 'F' THEN
					INSERT INTO "informix".flujolote(numerolote,codflujo,fecha) values (v_signumlote,'RES',v_fechahorageneracionproceso);												
				END IF;
				
				UPDATE "informix".paraminventarios SET signumlote = v_signumlote+1;
				
			ELSE
						
				IF v_tipo = 'E' THEN
					let v_leyendatarjeta = v_nombre;
				ELSE
					let v_nombre = null;
				END IF;
						
				SELECT  MAX(numerolote) INTO v_loteactual FROM "informix".lote WHERE clave_tipotarjeta = v_clavetipotarjeta AND clave_sucursal = v_sucursal and tipomaquila = v_tipo AND tipoenvio = v_tipoenvio AND idProveedor = v_IdProveedor AND fechageneracion >= TODAY;
				
				SELECT cantidadtarjetassol  INTO v_solicitadaslote FROM "informix".lote WHERE numerolote = v_loteactual;
				
				SELECT to_number(substr(max(numtarjeta),9,7)) INTO v_ultimatarjetalote FROM "informix".tarjeta WHERE numerolote = v_loteactual;

				IF  v_loteactual <> 0 AND v_ultimatarjetalote <> 0 AND (v_ultimatarjetalote + 1) = v_signumtarjeta THEN
					
					let v_signumlote = v_loteactual;
					
					UPDATE "informix".lote SET cantidadtarjetassol =  v_solicitadaslote + v_cantidad WHERE numerolote = v_loteactual AND fechageneracion >= TODAY;
					
					IF v_proc_ini = 0 THEN
						/*Proceso Iniciado*/
						let v_proc_ini = 1;
					END IF;
					
				ELSE 
					INSERT INTO "informix".lote(numerolote,fechageneracion,cantidadtarjetassol,clave_tipotarjeta,clave_sucursal,tipomaquila, idProveedor, tipoenvio)
					VALUES(v_signumlote,v_fechahorageneracionproceso,v_cantidad,v_clavetipotarjeta,v_sucursal,v_tipo, v_IdProveedor, v_tipoenvio);
					
					IF v_proc_ini = 0 THEN
						/*Proceso Iniciado*/
						let v_proc_ini = 1;
					END IF;
					
					INSERT INTO "informix".flujolote(numerolote,codflujo,fecha) VALUES (v_signumlote,'GAM',v_fechahorageneracionproceso);
					
					/*SELECT esvirtual INTO v_esVirtual FROM "informix".sucursal WHERE clave_sucursal=v_sucursal;*/
					IF v_esVirtual <> 'F' THEN
						INSERT INTO "informix".flujolote(numerolote,codflujo,fecha) VALUES (v_signumlote,'RES',v_fechahorageneracionproceso);												
					END IF;
					
					UPDATE "informix".paraminventarios SET signumlote = v_signumlote+1 ;
				END IF;
			END IF;
			
			UPDATE "informix".paraminventarios SET flag_proc_ok='F';

			COMMIT WORK;		
			
			FOR i=1 TO v_cantidad
				BEGIN WORK;
				let v_contadorfinal=v_contadorfinal+1;

				/* se realiza una condicion para identificar cuando incrementar la guia ya que por el momento las guias se generaran de 1000 tarjetas
				como maximo */
				IF v_contarjeta < v_maxtarjxguia+1 and v_contxguia < v_maxtarjxguia  THEN
					let v_contarjeta = v_contarjeta +1;
				ELSE
					let v_contarjeta=0;
					let v_contxguia=0;

					UPDATE "informix".paraminventarios SET consecutivoguia=v_consecutivoguia+1;
					/*SELECT consecutivoguia  INTO v_temconsecutivoguia FROM "informix".paraminventarios;
					let v_consecutivoguia=v_temconsecutivoguia;*/
					let v_consecutivoguia = v_consecutivoguia + 1;
				END IF;

				/* se realiza un ciclo para agregarle el 0 a la cadena de bin + el tipo de imagen serian 8 primeros caracteres despues le agrega 0 ceros
				hasta llegar a la longitud de 15 y que solo falte el ultimo digito verificador por concatenar*/
				
				let v_signumtarjetacadena=cast(v_signumtarjeta as varchar(30));

				WHILE length(v_signumtarjetacadena)  <  (15 - length(v_bin||v_tipoimagen))
						let  v_signumtarjetacadena="0" || v_signumtarjetacadena;
				end while;
				
				
				/*SELECT LPAD(v_signumtarjeta,7,'0') INTO v_signumtarjetacadena; Se comenta por incompatibilidad 5.1*/
				
				let v_numtarjetasindigver=v_bin||v_tipoimagen||v_signumtarjetacadena;

				if length(v_numtarjetasindigver) <> 15 then
					Let  p_cod_ret = '001';
					Let  p_mensaje = 'ERROR AL GENERAR LA LONGITUD DE LA TARJETA DE 15 CARACTERES';
					ROLLBACK WORK;
				else
					let v_suma=0;

					/* se realiza un ciclo para generar el digito verificar para el num de tarjeta y al final de este ciclo se graba la concatenacion
					del bin + el tipo de imagen + el siguiente numero de tarjeta a maquilar  + el digito verificador es decir se graba el numero de
					tarjeta por generar de 16 caracteres en la variable v_numtarjetapormaquilar */

					for j=1 to length(v_numtarjetasindigver)
						let  v_resultmod=mod(j,2);
						if v_resultmod=0 then
								let v_temp = cast(substr(v_numtarjetasindigver, j, 1)as integer) * 1;
						else
								let v_temp = cast(substr(v_numtarjetasindigver,j, 1)as integer) * 2;
						END IF;

						if v_temp >= 10 Then
							let v_tempstr = Trim(cast(v_temp as varchar(30)));
							let v_temp = cast(substr(v_tempstr, 1, 1) as integer) + cast(substr(v_tempstr, 2, 1) as integer);
						END IF;
						let v_suma = v_suma + v_temp;
					end for

					if 10 - mod(v_suma,10) = 10 Then
						let v_digitoverificador = 0;
					else
						let v_digitoverificador = 10 - mod(v_suma,10);
					END IF;

					let v_numtarjetapormaquilar=v_bin||v_tipoimagen||v_signumtarjetacadena||v_digitoverificador;

					let v_signumtarjeta=v_signumtarjeta+1;

					if v_soportacajeropropio <> 'null' and  v_soportacajeroconvenio <> 'null' and v_soportacajerored<> 'null'
						and v_soportainternacional<> 'null' then

						let v_numtarjetapormaquilar = v_numtarjetapormaquilar;
													  
						IF v_tipo = 'E' AND v_idsolicitud > 0 THEN
						
							/* SE OBTIENEN DATOS PARA PRESONALIZAR EL REGISTO DE TARJETA */
							SELECT numcliente, numcuenta, titular, usuario, tipoenvio, CURRENT, canal, NVL(numtarjeta,''), codprodcta
							INTO v_numcliente, v_numcuenta, v_titular, v_usuario, v_tipoenvio, v_fechaasignacion, v_canal, v_numtarjetasustituta, v_codprodcta
							FROM "informix".solicitudtarjeta
							WHERE estatusproceso = 'F' AND  idsolicitud= v_idsolicitud;
								
							IF v_tipoenvio = 'D' THEN
								LET v_codestatusasignada = 'SIA';
								LET v_fechanacimiento = '1900-01-01 00:00:00';
								
								SELECT count (*) cuantos
								INTO v_EsCVV2Dinamico
								FROM "informix".tarjeta_indicadores ti, "informix".tarjeta tj
								WHERE tj.numcliente = v_numcliente and ti.cvv2dinamico = 'V' and tj.numtarjeta = ti.numtarjeta;
								IF v_EsCVV2Dinamico <> '0' THEN
									INSERT INTO "informix".tarjeta_indicadores (numtarjeta, enviosmsecommerce, cvv2dinamico) VALUES (v_numtarjetapormaquilar, 'F', 'V');
								END IF;
									
							ELSE
								LET v_codestatusasignada = 'NOE';
								
								/*SELECT esvirtual INTO v_esVirtual FROM "informix".sucursal WHERE clave_sucursal=v_sucursal;*/
								IF v_esVirtual <> 'F' THEN
									LET v_codestatusasignada = 'NOA';												
								END IF;
								
								LET v_usuario = null;
								LET v_fechaasignacion = null;
								LET v_fechanacimiento = '';
							END IF;
								
							IF v_numtarjetasustituta = '' THEN
								LET v_numtarjetasustituta = null;                                      
							
								INSERT INTO "informix".tarjeta (NumTarjeta,CodProductoTarjeta,CodStatusTarjeta,NumCliente,Titular,Nombre,Direccion,ColDeleg,
													Ciudad,Estado,CodPostal,TelCasa,TelOficina, NumeroLote, FechaExp, SeFabricaPlastico, SeImprimeNIP,
													CobraComReexpTrj,CobraComReimpNIP,EnRenovacion,NombreCorto,FechaNacimiento,NombrePromotor,
													CodStatusAsignada, contnipinvalido,acumdiarioretatmnac,acumdiarioretatmint,acummensretatmnac,
													acummensretatmint,acumdiariocompraposnac,acumdiariocompraposint,acummenscompraposnac,
													acummenscompraposint,acumcomconsatmnac,acumcomconsatmint,acumcomretatmnac,acumcomretatmint,
													acumcomcompraposnac,acumcomcompraposint,acumcomrevatmnac,acumcomrevatmint,acumcomrevposnac,
													acumcomrevposint,acumcomfzdaposnac,acumcomfzdaposint,contcomconsatmnac,contcomconsatmint,
													contcomretatmnac,contcomretatmint,contcomcompraposnac,contcomcompraposint,contcomrevatmnac,
													contcomrevatmint,contcomrevposnac,contcomrevposint,contcomfzdaposnac,contcomfzdaposint,
													conttranconsatmlibres,conttranretatmlibres,conttrancompraposlibres,contmaxtranconsatmdiarias,
													contmaxtranretatmdiarias,contmaxtrancompraposdiarias,contmaxtranconsatmmens,contmaxtranretatmmens,
													contmaxtrancompraposmens,acumdiarioretatmpropio,acummensretatmpropio,acumcomconsatmpropio,
													acumcomretatmpropio,acumcomrevatmpropio,contcomconsatmpropio,contcomretatmpropio,
													contcomrevatmpropio,conttranconsatmlibrespropio,conttranretatmlibrespropio,contmaxtranconsatmdiariopropio,
													contmaxtranretatmdiariaspropio,contmaxtranconsatmmenspropio,contmaxtranretatmmenspropio,
													acumdiariocashbacknac,acummenscashbacknac,acumdiariocashadvancenac,acummenscashadvancenac,
													conttrancashbacklibres,conttrancashadvancelibres,contmaxtrancashbackdiarias,contmaxtrancashadvancediarias,
													contmaxtrancashbackmens,contmaxtrancashadvancemens,soportatranatmcajeropropio,soportatranatmcajeroconvenio,
													soportatranatmcajerointernacional,soportetranatmcajerored,acumdiarioretatmconvenio,acummensualretatmconvenio,
													acumcomconsatmconvenio,acumcomretatmconvenio,acumcomrevatmconvenio,contcomconsatmconvenio,
													contcomretatmconvenio, contcomrevatmconvenio,conttranconsatmconveniolibres,conttranretatmconveniolibres,
													contmaxtranconsatmdconveniodiarias, contmaxtranretatmconveniodiarias,contmaxtranconsatmconveniomens,
													contmaxtranretatmconveniomens,limitemenscompraposnac,limitemenscompraposint,numeroguia, usuarioultmodif, fechaultmodif, fechaasignacion, numtarjetasustituta)
								VALUES  (v_numtarjetapormaquilar,v_codproducto,'INA', v_numcliente, v_titular,v_nombre,'','','','','','','',v_signumlote, v_fechaexp,'V','V','F','F','F','',v_fechanacimiento,'',v_codestatusasignada,0,0.0000,
													0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,
													0.0000,0.0000,0.0000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0000,0.0000,0.0000,0.0000,0.0000,0,0,0,0,0,0,0,0,0,
													0.0000,0.0000,0.0000,0.0000,0,0,0,0,0,0,v_soportacajeropropio, v_soportacajeroconvenio,
													v_soportainternacional,
													v_soportacajerored ,0.0000, 0.0000,0.0000,0.0000,0.0000,0,0,0,0,0,0,0,0,0,0,0, v_consecutivoguia, v_usuario, v_fechaasignacion, v_fechaasignacion, v_numtarjetasustituta);
						
								LET v_numtarjetasustituta = '';                                      
							ELSE
								INSERT INTO "informix".tarjeta (NumTarjeta,CodProductoTarjeta,CodStatusTarjeta,NumCliente,Titular,Nombre,Direccion,ColDeleg,
									Ciudad,Estado,CodPostal,TelCasa,TelOficina, NumeroLote, FechaExp, SeFabricaPlastico, SeImprimeNIP,
									CobraComReexpTrj,CobraComReimpNIP,EnRenovacion,NombreCorto,FechaNacimiento,NombrePromotor,
									CodStatusAsignada, contnipinvalido,acumdiarioretatmnac,acumdiarioretatmint,acummensretatmnac,
									acummensretatmint,acumdiariocompraposnac,acumdiariocompraposint,acummenscompraposnac,
									acummenscompraposint,acumcomconsatmnac,acumcomconsatmint,acumcomretatmnac,acumcomretatmint,
									acumcomcompraposnac,acumcomcompraposint,acumcomrevatmnac,acumcomrevatmint,acumcomrevposnac,
									acumcomrevposint,acumcomfzdaposnac,acumcomfzdaposint,contcomconsatmnac,contcomconsatmint,
									contcomretatmnac,contcomretatmint,contcomcompraposnac,contcomcompraposint,contcomrevatmnac,
									contcomrevatmint,contcomrevposnac,contcomrevposint,contcomfzdaposnac,contcomfzdaposint,
									conttranconsatmlibres,conttranretatmlibres,conttrancompraposlibres,contmaxtranconsatmdiarias,
									contmaxtranretatmdiarias,contmaxtrancompraposdiarias,contmaxtranconsatmmens,contmaxtranretatmmens,
									contmaxtrancompraposmens,acumdiarioretatmpropio,acummensretatmpropio,acumcomconsatmpropio,
									acumcomretatmpropio,acumcomrevatmpropio,contcomconsatmpropio,contcomretatmpropio,
									contcomrevatmpropio,conttranconsatmlibrespropio,conttranretatmlibrespropio,contmaxtranconsatmdiariopropio,
									contmaxtranretatmdiariaspropio,contmaxtranconsatmmenspropio,contmaxtranretatmmenspropio,
									acumdiariocashbacknac,acummenscashbacknac,acumdiariocashadvancenac,acummenscashadvancenac,
									conttrancashbacklibres,conttrancashadvancelibres,contmaxtrancashbackdiarias,contmaxtrancashadvancediarias,
									contmaxtrancashbackmens,contmaxtrancashadvancemens,soportatranatmcajeropropio,soportatranatmcajeroconvenio,
									soportatranatmcajerointernacional,soportetranatmcajerored,acumdiarioretatmconvenio,acummensualretatmconvenio,
									acumcomconsatmconvenio,acumcomretatmconvenio,acumcomrevatmconvenio,contcomconsatmconvenio,
									contcomretatmconvenio, contcomrevatmconvenio,conttranconsatmconveniolibres,conttranretatmconveniolibres,
									contmaxtranconsatmdconveniodiarias, contmaxtranretatmconveniodiarias,contmaxtranconsatmconveniomens,
									contmaxtranretatmconveniomens,limitemenscompraposnac,limitemenscompraposint,
									acumdiariomotovoz, acumdiariomotoint, acummensualmotovoz, conttransmotovozdiario, conttransmotointdiario,
									conttransmotovozmensual, conttransmotointmensual, contcvv2invalido, acumdiariotag, acummensualtag, conttransdiariotag, conttransmensualtag,
									numeroguia, usuarioultmodif, fechaultmodif, fechaasignacion, numtarjetasustituta)
								SELECT v_numtarjetapormaquilar,v_codproducto,'INA',v_numcliente, v_titular,v_nombre,'','','','','','','',
									v_signumlote, v_fechaexp,'V','V','F','F','F','',v_fechanacimiento,'',v_codestatusasignada, 
									contnipinvalido,acumdiarioretatmnac,acumdiarioretatmint,acummensretatmnac,
									acummensretatmint,acumdiariocompraposnac,acumdiariocompraposint,acummenscompraposnac,
									acummenscompraposint,acumcomconsatmnac,acumcomconsatmint,acumcomretatmnac,acumcomretatmint,
									acumcomcompraposnac,acumcomcompraposint,acumcomrevatmnac,acumcomrevatmint,acumcomrevposnac,
									acumcomrevposint,acumcomfzdaposnac,acumcomfzdaposint,contcomconsatmnac,contcomconsatmint,
									contcomretatmnac,contcomretatmint,contcomcompraposnac,contcomcompraposint,contcomrevatmnac,
									contcomrevatmint,contcomrevposnac,contcomrevposint,contcomfzdaposnac,contcomfzdaposint,
									conttranconsatmlibres,conttranretatmlibres,conttrancompraposlibres,contmaxtranconsatmdiarias,
									contmaxtranretatmdiarias,contmaxtrancompraposdiarias,contmaxtranconsatmmens,contmaxtranretatmmens,
									contmaxtrancompraposmens,acumdiarioretatmpropio,acummensretatmpropio,acumcomconsatmpropio,
									acumcomretatmpropio,acumcomrevatmpropio,contcomconsatmpropio,contcomretatmpropio,
									contcomrevatmpropio,conttranconsatmlibrespropio,conttranretatmlibrespropio,contmaxtranconsatmdiariopropio,
									contmaxtranretatmdiariaspropio,contmaxtranconsatmmenspropio,contmaxtranretatmmenspropio,
									acumdiariocashbacknac,acummenscashbacknac,acumdiariocashadvancenac,acummenscashadvancenac,
									conttrancashbacklibres,conttrancashadvancelibres,contmaxtrancashbackdiarias,contmaxtrancashadvancediarias,
									contmaxtrancashbackmens,contmaxtrancashadvancemens,soportatranatmcajeropropio,soportatranatmcajeroconvenio,
									soportatranatmcajerointernacional,soportetranatmcajerored,acumdiarioretatmconvenio,acummensualretatmconvenio,
									acumcomconsatmconvenio,acumcomretatmconvenio,acumcomrevatmconvenio,contcomconsatmconvenio,
									contcomretatmconvenio, contcomrevatmconvenio,conttranconsatmconveniolibres,conttranretatmconveniolibres,
									contmaxtranconsatmdconveniodiarias, contmaxtranretatmconveniodiarias,contmaxtranconsatmconveniomens,
									contmaxtranretatmconveniomens,limitemenscompraposnac,limitemenscompraposint, 
									acumdiariomotovoz, acumdiariomotoint, acummensualmotovoz, conttransmotovozdiario, conttransmotointdiario,
									conttransmotovozmensual, conttransmotointmensual, contcvv2invalido, acumdiariotag, acummensualtag, conttransdiariotag, conttransmensualtag,
									v_consecutivoguia, v_usuario, v_fechaasignacion, v_fechaasignacion, v_numtarjetasustituta
									FROM "informix".tarjeta WHERE NumTarjeta = v_numtarjetasustituta;
									  
							END IF;
	 
							IF v_tipoenvio = 'D' THEN

								IF v_numtarjetasustituta = '' THEN
									LET v_descripcion = 'ASIGNACION DE TARJETA A DOMICILIO';
								ELSE
									LET v_descripcion = 'REPOSICION DE TARJETA A DOMICILIO';

									UPDATE "informix".tarjeta SET numtarjetasustituta = v_numtarjetapormaquilar WHERE numtarjeta = v_numtarjetasustituta;
								END IF;
								/*
								SELECT secuencia_folioasignacionactivacion.NEXTVAL INTO v_numfolioasignacion FROM paraminventarios;

								INSERT INTO "informix".bitasignacionactivaciontarjeta (numfolio, numcliente, numcuenta, numtarjeta, descripcion, usuario, canal, sucursal, fecharegistro) 
								VALUES (v_numfolioasignacion, v_numcliente, v_numcuenta, v_numtarjetapormaquilar,v_descripcion, v_usuario,v_canal,v_sucursal,v_fechaasignacion);
								*/

								INSERT INTO "informix".bitasignacionactivaciontarjeta (numfolio,numcliente, numcuenta, numtarjeta, descripcion, usuario, canal, sucursal, fecharegistro) 
								VALUES (secuencia_folioasignacionactivacion.NEXTVAL, v_numcliente, v_numcuenta, v_numtarjetapormaquilar, v_descripcion, v_usuario, v_canal, v_sucursal, v_fechaasignacion);

								SELECT COUNT(numcuenta) INTO v_existenumcuenta FROM "informix".cuenta WHERE numcuenta = v_numcuenta;
								IF v_existenumcuenta = 0 THEN
									INSERT INTO "informix".cuenta (NumCuenta, CodStatusCuenta, CodProdCta, Saldo, SaldoActualizado)
									VALUES (v_numcuenta, 'A', v_codprodcta, 0.00, 'V');
								END IF;

								INSERT INTO "informix".tarjetacuenta (NumCuenta, NumTarjeta) VALUES (v_numcuenta, v_numtarjetapormaquilar);

							END IF;
									 
							LET v_codestatusasignada = "";
							LET v_numcliente = ""; 
							LET v_numcuenta = "";
							LET v_titular = "";
							LET v_usuario = null;
							LET v_tipoenvio = "";
							LET v_fechaasignacion = null;
							LET v_canal = "";
							LET v_codprodcta = "";
							LET v_existenumcuenta = 0;
							LET v_numtarjetasustituta = "";
							LET v_descripcion = "";
									 
						
						ELSE
						
							/*SELECT esvirtual INTO v_esVirtual FROM "informix".sucursal WHERE clave_sucursal=v_sucursal;*/
							LET v_codestatusasignada = 'NOE';	
							IF v_esVirtual <> 'F' THEN
								LET v_codestatusasignada = 'NOA';												
							END IF;
							
							INSERT INTO "informix".tarjeta (NumTarjeta,CodProductoTarjeta,CodStatusTarjeta,NumCliente,Titular,Nombre,Direccion,ColDeleg,
												Ciudad,Estado,CodPostal,TelCasa,TelOficina, NumeroLote, FechaExp, SeFabricaPlastico, SeImprimeNIP,
												CobraComReexpTrj,CobraComReimpNIP,EnRenovacion,NombreCorto,FechaNacimiento,NombrePromotor,
												CodStatusAsignada, contnipinvalido,acumdiarioretatmnac,acumdiarioretatmint,acummensretatmnac,
												acummensretatmint,acumdiariocompraposnac,acumdiariocompraposint,acummenscompraposnac,
												acummenscompraposint,acumcomconsatmnac,acumcomconsatmint,acumcomretatmnac,acumcomretatmint,
												acumcomcompraposnac,acumcomcompraposint,acumcomrevatmnac,acumcomrevatmint,acumcomrevposnac,
												acumcomrevposint,acumcomfzdaposnac,acumcomfzdaposint,contcomconsatmnac,contcomconsatmint,
												contcomretatmnac,contcomretatmint,contcomcompraposnac,contcomcompraposint,contcomrevatmnac,
												contcomrevatmint,contcomrevposnac,contcomrevposint,contcomfzdaposnac,contcomfzdaposint,
												conttranconsatmlibres,conttranretatmlibres,conttrancompraposlibres,contmaxtranconsatmdiarias,
												contmaxtranretatmdiarias,contmaxtrancompraposdiarias,contmaxtranconsatmmens,contmaxtranretatmmens,
												contmaxtrancompraposmens,acumdiarioretatmpropio,acummensretatmpropio,acumcomconsatmpropio,
												acumcomretatmpropio,acumcomrevatmpropio,contcomconsatmpropio,contcomretatmpropio,
												contcomrevatmpropio,conttranconsatmlibrespropio,conttranretatmlibrespropio,contmaxtranconsatmdiariopropio,
												contmaxtranretatmdiariaspropio,contmaxtranconsatmmenspropio,contmaxtranretatmmenspropio,
												acumdiariocashbacknac,acummenscashbacknac,acumdiariocashadvancenac,acummenscashadvancenac,
												conttrancashbacklibres,conttrancashadvancelibres,contmaxtrancashbackdiarias,contmaxtrancashadvancediarias,
												contmaxtrancashbackmens,contmaxtrancashadvancemens,soportatranatmcajeropropio,soportatranatmcajeroconvenio,
												soportatranatmcajerointernacional,soportetranatmcajerored,acumdiarioretatmconvenio,acummensualretatmconvenio,
												acumcomconsatmconvenio,acumcomretatmconvenio,acumcomrevatmconvenio,contcomconsatmconvenio,
												contcomretatmconvenio, contcomrevatmconvenio,conttranconsatmconveniolibres,conttranretatmconveniolibres,
												contmaxtranconsatmdconveniodiarias, contmaxtranretatmconveniodiarias,contmaxtranconsatmconveniomens,
												contmaxtranretatmconveniomens,limitemenscompraposnac,limitemenscompraposint,numeroguia)
							VALUES  (v_numtarjetapormaquilar,v_codproducto,'INA', '','',v_nombre,'','','','','','','',v_signumlote, v_fechaexp,'V','V','F','F','F','','','',v_codestatusasignada,0,0.0000,
												0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,
												0.0000,0.0000,0.0000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0000,0.0000,0.0000,0.0000,0.0000,0,0,0,0,0,0,0,0,0,
												0.0000,0.0000,0.0000,0.0000,0,0,0,0,0,0,v_soportacajeropropio, v_soportacajeroconvenio,
												v_soportainternacional,
												v_soportacajerored ,0.0000, 0.0000,0.0000,0.0000,0.0000,0,0,0,0,0,0,0,0,0,0,0, v_consecutivoguia);
						END IF;

						/*SELECT v_numtarjetapormaquilar || '-' || v_fechaexp || '-' || v_servicecode || '-' || v_icvv  INTO v_mensajeerr FROM "informix".parametros;*/

						/*SELECT card_type INTO v_TecnologiaTarjeta FROM "informix".tipotarjeta WHERE clave_tipotarjeta = v_clavetipotarjeta;*/

						INSERT INTO "informix".hsmcard (card_no,card_offset,expirationdate,service_code,icvv, card_type)
						VALUES (v_numtarjetapormaquilar,'0000FFFFFFFF',v_fechaexp,v_servicecode,v_icvv, v_TecnologiaTarjeta);
						
						INSERT INTO "informix".detalle_maquila_transitorio (prefijo_archivo,sufijo_archivo,secuencia_maquila,clave_sucursal,domicilio_sucursal,numguia,numtarjeta,
									servicecode,leyenda_tarjeta,numlote,fecha_generacion,fecha_expiracion,consecutivo_archivo,
									indicadortipoproceso,flagprocesorealizado,provedormaquila, tipomaquila, idsolicitud, idsolmaquila, flagdiseno, id_diseno)
						VALUES(v_prefijo, v_sufijo, v_consecutivo_actual,v_sucursal, v_direccionsucursal,v_consecutivoguia,v_numtarjetapormaquilar,
									v_servicecode,v_leyendatarjeta,v_signumlote, v_fechahorageneracionproceso,v_fechaexp,v_consecutivo_archivo,v_indicadortipoproceso, 'F',v_IdProveedor,v_tipo,
									v_idsolicitud, v_consecutivo, v_flagdiseno, v_id_diseno);
							   
						let v_contxguia=v_contxguia+1;
						let v_consecutivo_actual=v_consecutivo_actual+1;

					ELSE
						Let  p_cod_ret = '003';
						Let  p_mensaje = 'ERROR AL OBTENER LOS CAJEROS QUE ACEPTARA LA TARJETA GENERADA';
						ROLLBACK WORK;
					END IF;
				END IF;
				COMMIT WORK;
			end for
			
			BEGIN WORK;
			UPDATE "informix".tipotarjeta SET consecutivo=v_signumtarjeta, consecutivo_actual= v_consecutivo_actual where clave_tipotarjeta=v_clavetipotarjeta;
		
			SELECT COUNT(clave_tipotarjeta) INTO v_registros FROM "informix".sucursal_tipotarjeta WHERE clave_sucursal=v_sucursal and clave_tipotarjeta=v_clavetipotarjeta;
			IF v_tipoenvio <> 'D' AND v_esVirtual <> 'V' THEN
				/*SELECT count(*) INTO v_registros FROM "informix".sucursal_tipotarjeta WHERE clave_sucursal=v_sucursal and clave_tipotarjeta=v_clavetipotarjeta;*/
				IF v_registros >0 THEN
					UPDATE "informix".sucursal_tipotarjeta SET solicitadas=solicitadas+v_cantidad WHERE clave_sucursal=v_sucursal and clave_tipotarjeta=v_clavetipotarjeta;
					/*let v_solicitadas=0;*/
				ELSE
					INSERT INTO "informix".sucursal_tipotarjeta(clave_sucursal,clave_tipotarjeta,existencia,solicitadas) VALUES (v_sucursal,v_clavetipotarjeta,0,v_cantidad);
				END IF;
			END IF;
					
			IF v_esVirtual <> 'F' THEN
				/*SELECT count(*) INTO v_registros FROM "informix".sucursal_tipotarjeta WHERE clave_sucursal=v_sucursal and clave_tipotarjeta=v_clavetipotarjeta;*/
				IF v_registros >0 THEN
					UPDATE "informix".sucursal_tipotarjeta SET existencia=existencia+v_cantidad WHERE clave_sucursal=v_sucursal and clave_tipotarjeta=v_clavetipotarjeta;
					/*let v_solicitadas=0;*/
				ELSE
					INSERT INTO "informix".sucursal_tipotarjeta(clave_sucursal,clave_tipotarjeta,existencia,solicitadas) VALUES (v_sucursal,v_clavetipotarjeta,v_cantidad,0);
				END IF;
			END IF;

			UPDATE "informix".solicitud_maquila SET flagprocesorealizado= 'V' WHERE clave_sucursal=v_sucursal AND clave_tipotarjeta=v_clavetipotarjeta
			AND cantidad=v_cantidad AND codproductotarjeta=v_codproducto AND fechaexp=v_fechaexp AND indicadortipoproceso=v_indicadortipoproceso AND consecutivo=v_consecutivo;
			
			IF v_tipo = 'E' AND v_idsolicitud > 0 THEN
			
				UPDATE "informix".solicitudtarjeta SET estatusproceso = 'V' WHERE idsolicitud = v_idsolicitud;
			
			END IF;
            COMMIT WORK;
		end foreach;
		
		BEGIN WORK;		
		UPDATE "informix".paraminventarios SET consecutivoguia=v_consecutivoguia+1;
		COMMIT WORK;
		let v_contarjeta=0;
		let v_contxguia=0;
    end foreach;
	
	BEGIN WORK;
    UPDATE "informix".paraminventarios SET flag_proc_ok = 'V', consecutivoguia=v_consecutivoguia+1, consecutivoarchivomaquila = consecutivoarchivomaquila + v_contadorfinal;

    /*UPDATE "informix".paraminventarios SET consecutivoguia=v_consecutivoguia;*/

    COMMIT WORK;


    return p_cod_ret, p_mensaje;
end;
end procedure;