create procedure "informix".sp_generartarjetas_pba(v_indicadortipoproceso varchar(1))
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


--set debug file to "/informix/resplogifx/sp_storegeneratarjetas.out";
--trace on;
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
--set debug file to '/tmp/sp_storegeneratarjetas.out';
--trace on;

begin

  on exception set  sql_err  , isam_err, error_info
        Let  p_cod_ret   = sql_err  ;
        Let  p_mensaje  = error_info ;
        ROLLBACK WORK;
        return p_cod_ret, p_mensaje;
  end exception;

  Let  p_cod_ret = '000';
  Let  p_mensaje = 'PROCESO EXITOSO';


BEGIN WORK;

        -- SELECT max(consecutivo_archivo) INTO v_consecutivo_archivocadena FROM bitacora_archivo_maq where fecha_generacion=v_date;

        -- if cast(v_consecutivo_archivocadena as integer) > 0 then
            -- let  v_consecutivo_archivointeger= cast(v_consecutivo_archivocadena as integer)+1;
            -- let v_consecutivo_archivocadena= cast(v_consecutivo_archivointeger as varchar(10));

            -- while (length(v_consecutivo_archivocadena) < 2)
                -- let v_consecutivo_archivocadena= "0" || v_consecutivo_archivocadena;
            -- end while;
            -- let v_consecutivo_archivo=v_consecutivo_archivocadena;
        -- else
            -- let v_consecutivo_archivo = '01';
        -- end if;


	foreach
        SELECT {+INDEX(solicitud_maquila idx_solicitud_maquila)} distinct clave_sucursal INTO v_sucursal FROM solicitud_maquila order by clave_sucursal
            foreach
                    /*se obtiene los valores de la tabla solicitud maquila, los valores son la clave de la sucursal, tipo de imagen (00,01,02), la cantidad de tarjetas a
                    generar, el producto de las tarjetas (001,501),el tipo de tarjeta (c,d),y por ultimo fechaexp mismas que se guardan en las siguientes variables: v_sucursal, v_tipoimagen,
                    v_cantidad, v_codproducto, v_tipotarjeta y  v_fechaexp */
                    SELECT (sm.clave_tipotarjeta), (sm.cantidad),trim(sm.codproductotarjeta),trim(sm.fechaexp),trim (sm.tipomaquila), trim(sm.nom_cliente),(sm.fecha_generacion),consecutivo
                    INTO  v_clavetipotarjeta,v_cantidad,v_codproducto, v_fechaexp ,v_tipo, v_nombre, v_fecha_generacion,v_consecutivo
                    FROM solicitud_maquila sm where sm.clave_sucursal=v_sucursal and sm.indicadortipoproceso=v_indicadortipoproceso and sm.flagprocesorealizado= 'F'
                    ORDER BY clave_tipotarjeta , tipomaquila ASC
					
					IF v_indicadortipoproceso = 'P' THEN 
						IF v_fecha_generacion = v_date THEN
							CONTINUE FOREACH;						
						END IF;                         
                    END IF ;
					
		   /* IF v_indicadortipoproceso = 'A' THEN 
			 let v_tipo = "A"  ;                 
                    END IF ;*/
					
                    SELECT count(*) INTO v_registros FROM sucursal_tipotarjeta where clave_sucursal=v_sucursal and clave_tipotarjeta=v_clavetipotarjeta;
                    if v_registros >0 then
                        /*SELECT solicitadas INTO v_solicitadas FROM sucursal_tipotarjeta where clave_sucursal=v_sucursal and clave_tipotarjeta=v_clavetipotarjeta;*/
                        update sucursal_tipotarjeta set solicitadas=solicitadas+v_cantidad where clave_sucursal=v_sucursal and clave_tipotarjeta=v_clavetipotarjeta;
                        let v_solicitadas=0;
                    else
                        insert INTO sucursal_tipotarjeta(clave_sucursal,clave_tipotarjeta,existencia,solicitadas) values (v_sucursal,v_clavetipotarjeta,0,v_cantidad);
                    end if;

                    /*se obtiene el consecutivo guia y el siguente numero de lote de la tabla parametros*/
                    /*SELECT consecutivoguia,signumlote,consecutivoarchivomaquila INTO v_consecutivoguia,v_signumlote,v_consecutivomaquila  FROM parametros;*/
                    SELECT maxtarjxguia,consecutivoguia,signumlote INTO v_maxtarjxguia, v_consecutivoguia,v_signumlote  FROM paraminventarios;
					
					SELECT provedormaquila INTO v_IdProveedor FROM tipotarjeta WHERE clave_tipotarjeta = v_clavetipotarjeta;
					
					SELECT max(consecutivo_archivo) INTO v_consecutivo_archivocadena FROM bitacora_archivo_maq WHERE fecha_generacion=v_date AND provedormaquila = v_IdProveedor;
					if cast(v_consecutivo_archivocadena as integer) > 0 then
						let  v_consecutivo_archivointeger= cast(v_consecutivo_archivocadena as integer)+1;
						let v_consecutivo_archivocadena= cast(v_consecutivo_archivointeger as varchar(10));
						while (length(v_consecutivo_archivocadena) < 2)
							let v_consecutivo_archivocadena= "0" || v_consecutivo_archivocadena;
						end while;
						let v_consecutivo_archivo=v_consecutivo_archivocadena;
					else
						let v_consecutivo_archivo = '01';
					end if;
					
                    /*JQL-DebitoChip-20110714 Begin*/
                    /*SELECT trim(tt.tipo) INTO v_tipotarjeta FROM tipotarjeta tt where tt.clave_tipotarjeta=v_clavetipotarjeta;*/
                    SELECT trim(tt.tipo), trim(tt.bin), trim(tt.chip) INTO v_tipotarjeta, v_bin, v_chip FROM tipotarjeta tt where tt.clave_tipotarjeta=v_clavetipotarjeta;
                    /*JQL-DebitoChip-20110714 End*/

                    /* se obtiene el maximo de tarjetas por guia para la sucursal*/
                    /*SELECT maxtarjxguia INTO v_maxtarjxguia FROM paraminventarios;*/

                    /* se obtiene el consecutivo con el cual iniciara la generacion de las tarjetas dependiendo de su bin y su tipo de imagen en la tabla
                        consecutivoproductoimagen*/
                    /* se obtiene el servicecode correspondiente de la tarjeta generada y se guarda el valor en la variable v_servicecode*/
                    
                    /*JQL-DebitoChip-20110714 Begin*/
                    SELECT servicecode,prefijo  INTO v_servicecode,v_prefijo FROM bines where bin=v_bin;
                    /*JQL-DebitoChip-20110714 End*/
                    
                    SELECT clave,consecutivo,leyendatarjeta,consecutivo_actual INTO v_claveproductoimagen,v_signumtarjeta, v_leyendatarjeta, v_consecutivo_actual  FROM tipotarjeta where  clave_tipotarjeta=v_clavetipotarjeta;
                    SELECT producto, sufijo INTO v_tipoimagen, v_sufijo FROM productoimagen where clave=v_claveproductoimagen;
					
					if v_tipo <> 'E' then  
					
					/*Entra a Maquilas SIN Enbozar*/
					
						let v_nombre = null;
						
						INSERT INTO lote(numerolote,fechageneracion,cantidadtarjetassol,clave_tipotarjeta,clave_sucursal,tipomaquila)
						VALUES(v_signumlote,v_fechahorageneracionproceso,v_cantidad,v_clavetipotarjeta,v_sucursal,v_tipo);
									
						INSERT INTO flujolote(numerolote,codflujo,fecha) values (v_signumlote,'GAM',v_fechahorageneracionproceso);
						
						UPDATE paraminventarios SET signumlote = v_signumlote+1;

						/*Entra a Maquilas Enbozadas*/ 
						
					else
						let v_leyendatarjeta = v_nombre;
						
						SELECT numerolote , cantidadtarjetassol INTO v_loteactual , v_solicitadaslote FROM lote WHERE clave_tipotarjeta = v_clavetipotarjeta AND clave_sucursal = v_sucursal AND fechageneracion >= TODAY;
						
							if  v_loteactual <> 0  then
								
								let v_signumlote = v_loteactual;
								
								UPDATE lote SET cantidadtarjetassol =  v_solicitadaslote + 1 WHERE numerolote = v_loteactual AND fechageneracion >= TODAY;
								
							else 
								INSERT INTO lote(numerolote,fechageneracion,cantidadtarjetassol,clave_tipotarjeta,clave_sucursal,tipomaquila)
								VALUES(v_signumlote,v_fechahorageneracionproceso,v_cantidad,v_clavetipotarjeta,v_sucursal,v_tipo);
									
								INSERT INTO flujolote(numerolote,codflujo,fecha) values (v_signumlote,'GAM',v_fechahorageneracionproceso);
								
								UPDATE paraminventarios SET signumlote = v_signumlote+1 ;
								
								
							end if 
					end if 
					
                    /*SELECT max(consecutivo_archivo) INTO v_consecutivo_archivocadena FROM bitacora_archivo_maq where prefijo_archivo=v_prefijo and sufijo_archivo=v_sufijo and fecha_generacion= v_date;*/

                    /* if cast(v_consecutivo_archivocadena as integer) > 0 then
                    if  v_inserto= 'F' then
                        let  v_consecutivo_archivointeger= cast(v_consecutivo_archivocadena as integer)+1;
                        let v_consecutivo_archivocadena= cast(v_consecutivo_archivointeger as varchar(10));
                        while (length(v_consecutivo_archivocadena) < 2)
                                                let  v_consecutivo_archivocadena= "0" || v_consecutivo_archivocadena;
                        end while;
                        insert INTO bitacora_archivo_maq(prefijo_archivo,sufijo_archivo,fecha_generacion,consecutivo_archivo,cantregistros_archivo,
                                                                                        cantsucursales_archivo, cantguias_archivo, indicadortipoproceso,flagprocesorealizado)
                        values (v_prefijo,v_sufijo,v_fechahorageneracionproceso,v_consecutivo_archivocadena,0,0,0,v_indicadortipoproceso,'F');
                        let  v_inserto= 'V';
                        let v_banderiar= 'por aqui paso';
                    end if;
                            let v_banderiar= 'aqui va';
                            let v_inserto= 'F';
                    else
                            let v_banderiar= 'aqui entro';
                            let v_consecutivo_archivocadena= '01';
                            insert INTO bitacora_archivo_maq(prefijo_archivo,sufijo_archivo,fecha_generacion,consecutivo_archivo,cantregistros_archivo,
                                                                                        cantsucursales_archivo, cantguias_archivo, indicadortipoproceso,flagprocesorealizado)
                            values (v_prefijo,v_sufijo,v_fechahorageneracionproceso,v_consecutivo_archivocadena,0,0,0,v_indicadortipoproceso,'F');
                            let v_inserto= 'V';
                    end if;*/

                    /*se obtiene los parametros de soporta cajero propio, soporta cajero convenio , soporta cajero red y
                    por ultimo si soporta cajero internacional  de la tabla producto tarjeta indicandole que tipo de producto (001,501)
                    es la tarjeta que generamos  y se guardan en las siguiente variables:  v_soportcajeropropio,
                    v_soportcajeroconvenio, v_soportcajerored, v_soportinternacional*/
                    SELECT soportatranatmcajeropropio,soportatranatmcajeroconvenio,soportatranatmcajerored,soportatranatminternacional
                    INTO v_soportacajeropropio, v_soportacajeroconvenio, v_soportacajerored, v_soportainternacional FROM productotarjeta
                    where codproductotarjeta= v_codproducto;

                    /*se obtiene el domicilio de la sucursal*/
                    SELECT direccion_sucursal INTO v_direccionsucursal FROM sucursal where clave_sucursal= v_sucursal;

                    /*inicia el proceso por cada SELECTe obtiene los datos anteriores y genera las tarjetas insertandolas en la tabla tarjetas, y hsmcard */
                    /*let v_contarjeta=0;*/
                    /*let v_contxguia=0;*/
---------------------------------
                    /*JQL-DebitoChip-20110714 Begin*/
                    /*if v_tipotarjeta = 'C' then
					let v_icvv = 'V';
					else
					 let v_icvv = 'F';
					end if;*/
							if v_chip = 'V' then
					 let v_icvv = 'V';
					else
					 let v_icvv = 'F';
					end if;
                    /*JQL-DebitoChip-20110714 End*/
---------------------------------
                    for i=1 to v_cantidad

                        let v_contadorfinal=v_contadorfinal+1;

                        /* se realiza una condicióara identificar cuando incrementar la guia ya que por el momento las guias se generaran de 1000 tarjetas
                        como maximo */
                        /*if v_contarjeta < v_maxtarjxguia+1 and v_contxguia < v_maxtarjxguia  then*/
                        if v_contarjeta < v_maxtarjxguia+1 and v_contxguia < v_maxtarjxguia  then
                            let v_contarjeta = v_contarjeta +1;
                        else
                            let v_contarjeta=0;
                            let v_contxguia=0;

                            UPDATE paraminventarios SET consecutivoguia=v_consecutivoguia+1;
                            SELECT consecutivoguia  INTO v_temconsecutivoguia FROM paraminventarios;
                            /*update parametros set consecutivoguia=v_consecutivoguia+1;
                            SELECT consecutivoguia  INTO v_temconsecutivoguia FROM parametros;*/
                            let v_consecutivoguia=v_temconsecutivoguia;
                        end if;

                        /* se realiza un ciclo para agregarle el 0 a la cadena de bin + el tipo de imagen serian 8 primeros caracteres despues le agrega 0 ceros
                        hasta llegar a la longitud de 15 y que solo falte el ultimo digito verificador por concatenar*/
                        let v_signumtarjetacadena=cast(v_signumtarjeta as varchar(30));

                        /* let prueba0=15 - length(v_bin||v_tipoimagen);
                        let prueba = length(trim(cast(v_signumtarjeta as varchar(30))));*/

                        while length(v_signumtarjetacadena)  <  (15 - length(v_bin||v_tipoimagen))
                                let  v_signumtarjetacadena="0" || v_signumtarjetacadena;
                        end while;

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
                                    /*SELECT mod(j,2) INTO v_resultmod FROM parametros;*/
                                    let  v_resultmod=mod(j,2);
                                    if v_resultmod=0 then
                                            let v_temp = cast(substr(v_numtarjetasindigver, j, 1)as integer) * 1;
                                    else
                                            let v_temp = cast(substr(v_numtarjetasindigver,j, 1)as integer) * 2;
                                    end if;

                                    if v_temp >= 10 Then
                                        let v_tempstr = Trim(cast(v_temp as varchar(30)));
                                        let v_temp = cast(substr(v_tempstr, 1, 1) as integer) + cast(substr(v_tempstr, 2, 1) as integer);
                                    end if;
                                    let v_suma = v_suma + v_temp;
                            end for

                            if 10 - mod(v_suma,10) = 10 Then
                                            let v_digitoverificador = 0;
                            else
                                            let v_digitoverificador = 10 - mod(v_suma,10);
                            end if;

                            let v_numtarjetapormaquilar=v_bin||v_tipoimagen||v_signumtarjetacadena||v_digitoverificador;

                            /* se verifica si hay alguna cuenta asociada a ese num de tarjeta generado realizando una consulta a la tabla tarjetacuenta*/

                            /*   SELECT NumCuenta INTO v_numcuentaasociada FROM tarjetacuenta where NumTarjeta =v_numtarjetapormaquilar;

                            if  length(v_numcuentaasociada ) >= 9 and  length(v_numcuentaasociada ) <= 13 then
                                        let v_signumtarjeta = cast(v_signumtarjeta as integer) + 1;
                            else

                            end if; */
                            let v_signumtarjeta=v_signumtarjeta+1;

                            if v_soportacajeropropio <> 'null' and  v_soportacajeroconvenio <> 'null' and v_soportacajerored<> 'null'
                                and v_soportainternacional<> 'null' then

                                let v_numtarjetapormaquilar = v_numtarjetapormaquilar;

                                /*al verificar que los campos o parametros que nos indica que tipo de cajero soporta esta tarjeta son diferentes de null
                                , es decir tienen un F o un V entonces insertamos la tarjeta generada, con sus datos correspondientes en la tabla tarjeta */
                                INSERT INTO  Tarjeta    (NumTarjeta,CodProductoTarjeta,CodStatusTarjeta,NumCliente,Titular,Nombre,Direccion,ColDeleg,
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
                                                VALUES  (v_numtarjetapormaquilar,v_codproducto,'INA', '','',v_nombre,'','','','','','','',v_signumlote, v_fechaexp,'V','V','F','F','F','','','','NOE',0,0.0000,
                                                            0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,
                                                            0.0000,0.0000,0.0000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0000,0.0000,0.0000,0.0000,0.0000,0,0,0,0,0,0,0,0,0,
                                                            0.0000,0.0000,0.0000,0.0000,0,0,0,0,0,0,v_soportacajeropropio, v_soportacajeroconvenio,
                                                            v_soportainternacional,
                                                            v_soportacajerored ,0.0000, 0.0000,0.0000,0.0000,0.0000,0,0,0,0,0,0,0,0,0,0,0, v_consecutivoguia);

                                                        /* se inserta la tarjeta generada, el codigo defaul de offset ('0000FFFFFFFF''), la fecha de expiracion de la tarjeta y finalmente
                                                    el servicecode obtenio anteriormente, en la tabla hsmcard*/
---------------------------------
                                INSERT INTO hsmcard (card_no,card_offset,expirationdate,service_code,icvv)
                                VALUES (v_numtarjetapormaquilar,'0000FFFFFFFF',v_fechaexp,v_servicecode,v_icvv);
---------------------------------

                                /* se inserta en flujo tarjeta*/
                                /*insert INTO flujotarjeta (fecha,numtarjeta,codflujo)
                                values (v_fechahorageneracionproceso,v_numtarjetapormaquilar,'GAM');*/

                                /*Se inserta la informacióecesaria en la tabla detalle_maquila para la generacion de los archivos para gemalto*/

                                INSERT INTO detalle_maquila_transitorio (prefijo_archivo,sufijo_archivo,secuencia_maquila,clave_sucursal,domicilio_sucursal,numguia,numtarjeta,
                                            servicecode,leyenda_tarjeta,numlote,fecha_generacion,fecha_expiracion,consecutivo_archivo,
                                            indicadortipoproceso,flagprocesorealizado,provedormaquila, tipomaquila)
                                    VALUES(v_prefijo, v_sufijo, v_consecutivo_actual,v_sucursal, v_direccionsucursal,v_consecutivoguia,v_numtarjetapormaquilar,
                                            v_servicecode,v_leyendatarjeta,v_signumlote, v_fechahorageneracionproceso,v_fechaexp,v_consecutivo_archivo,v_indicadortipoproceso, 'F',v_IdProveedor,v_tipo);

                                /* se guarda la cantidad de tarjetas que hemos generado en la variable v_contadorxguia y se iguala a la variable
                                v_contxguia para saber cuando hemos llegado a las 1000 y es necesario actualizar el consecutivoguia */
                                /*SELECT count(*) valor INTO v_contadorxguia FROM tarjeta where numeroguia=v_consecutivoguia;*/

                                /* let v_consecutivomaquila= v_consecutivomaquila+1;*/
                                let v_contxguia=v_contxguia+1;
                                let v_consecutivo_actual=v_consecutivo_actual+1;

                            else
                                    Let  p_cod_ret = '003';
                                    Let  p_mensaje = 'ERROR AL OBTENER LOS CAJEROS QUE ACEPTARA LA TARJETA GENERADA';
                                    ROLLBACK WORK;
                            end if;

                       end if;

                    end for

                    /*actualiza cada bloque de insert*/

                    UPDATE tipotarjeta SET consecutivo=v_signumtarjeta, consecutivo_actual= v_consecutivo_actual where clave_tipotarjeta=v_clavetipotarjeta;

                    /* se actualiza el consecutivo de la imagen y bin que generamos en la tabla consecutivoproductoimagen para saber cual sera
                    el siguiente num de tarjeta a maquilar*/
                    /*update consecutivoproductoimagen set consecutivo = v_signumtarjeta where tipo =v_tipotarjeta And producto =v_tipoimagen;*/

                    /* se realiza una insercion a la tabla lotes nuevos de los lotes generados por cada lote generado */
                    /*insert INTO  LotesNuevos (CodProductoTarjeta, NumeroLote,clave_sucursal)
                    values (v_codproducto,v_signumlote, v_sucursal);*/
                    /*INSERT INTO lote(numerolote,fechageneracion,cantidadtarjetassol,fecharecpsuc,cantidadtarjetasrecsuc,clave_tipotarjeta,clave_sucursal)
                    VALUES(v_signumlote,v_fechahorageneracionproceso,v_cantidad,null,0,v_clavetipotarjeta,v_sucursal);*/

			
					/*UPDATE paraminventarios SET  consecutivoarchivomaquila=v_consecutivomaquila ;*/
					
						
				
					

                    /* update parametros set signumlote = v_signumlote+1,consecutivoarchivomaquila=v_consecutivomaquila, flagprocesomaq=0;*/
					
                    /* se actualiza la bandera para identificar que el proceso ya se realizo con un 1 */

                    UPDATE solicitud_maquila SET flagprocesorealizado= 'V' where clave_sucursal=v_sucursal AND clave_tipotarjeta=v_clavetipotarjeta
                    AND cantidad=v_cantidad AND codproductotarjeta=v_codproducto AND fechaexp=v_fechaexp AND indicadortipoproceso=v_indicadortipoproceso AND consecutivo=v_consecutivo;
            end foreach;
				
				
				
			/*update parametros set consecutivoguia=v_consecutivoguia+1;*/
			UPDATE paraminventarios SET consecutivoguia=v_consecutivoguia+1;
			let v_contarjeta=0;
			let v_contxguia=0;
    end foreach;
        /*update parametros set consecutivoarchivomaquila=v_consecutivomaquila+v_contadorfinal;*/
        /*update paraminventarios set consecutivoarchivomaquila=v_consecutivomaquila+v_contadorfinal;*/
    UPDATE paraminventarios SET consecutivoarchivomaquila=consecutivoarchivomaquila+v_contadorfinal;
	
	/*SELECT solicitadas INTO v_solicitadas FROM sucursal_tipotarjeta where clave_sucursal=v_sucursal and clave_tipotarjeta=v_clavetipotarjeta;*/
	
    /*JAGA-20120704 Begin*/

    /*
    else
           let  p_cod_ret = '004';
           let  p_mensaje = 'ACTUALMENTE SE ESTA EJECUTANDO EL PROCESO, REINTENTAR MAS TARDE ';
           ROLLBACK WORK;
    end if; */
    /*JAGA-20120704 end*/

    UPDATE paraminventarios SET consecutivoguia=v_consecutivoguia;

    COMMIT WORK;
	
 
	
	
	
    /*update paraminventarios set consecutivoguia=temp_consecutivoguia;*/
    /*update paraminventarios set consecutivoguia=v_consecutivoguia+1;*/

    /*BEGIN WORK;

--    set debug file to '/tmp/sp_generatarjetasxmaquilar.out';
--    trace on;

        Execute Procedure intercard:sp_generasecuencia() INTO p_cod_ret2,p_mensaje2;

    COMMIT WORK;*/

                                   /* delete FROM resumen_maquila;*/
    -- if p_cod_ret= "000" then
     --   update paraminventarios set flagprocesomaq= 'F';
    -- end if;

    return p_cod_ret, p_mensaje;
end;
end procedure;