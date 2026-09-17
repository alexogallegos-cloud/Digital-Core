CREATE PROCEDURE "informix".sp_auditortarjeta()
RETURNING varchar(6), varchar(80);
----------Variables-------------------------------
DEFINE  error_info              varchar(80);
DEFINE  isam_err                integer;
DEFINE  vsqlerr                 integer;
DEFINE  vcodret                 varchar(6);
DEFINE  p_mensaje               varchar(80);
DEFINE  vletra                  varchar(1);
DEFINE  vaniomes                char(6);
DEFINE  vfecha_hoy              date;
DEFINE  vsql                    char(1150);
DEFINE  dias                    integer;
DEFINE  vcodstatustarjeta       varchar(3);
DEFINE  vcodstatusasignada      varchar(3);
DEFINE  vbines1                 varchar(6);
DEFINE  vbines2                 varchar(6);
DEFINE  vbines3                 varchar(6);
DEFINE  vcantida4008            integer;
DEFINE  vcantidad4169           integer;
DEFINE  vcantidad4268           integer;
DEFINE  vcantidad2              integer;
DEFINE  vcantidad3              integer;
DEFINE  vnumtarjeta             varchar(16);
DEFINE  vnumcliente             varchar(13);
DEFINE  vnumcuenta              varchar(13);
DEFINE  vclave_sucursal         varchar(1);

 
---------------------------------------------------
DEFINE primer_hora_dia DATE;
DEFINE primer_dia_mes DATE;
DEFINE ultima_hora_dia_hora DATETIME YEAR TO FRACTION(5);
DEFINE FechaAux DATETIME YEAR TO FRACTION(5);

LET vcodstatustarjeta = "";
LET vcodstatusasignada = "";
LET vbines1 = "";
LET vbines3 = "";
LET vbines2 = "";
LET vcantida4008  =  "";
LET vcantidad4169  =  "";
LET vcantidad4268  =  "";
LET vcantidad2 = "";
LET vcantidad3 = "";
LET  vnumtarjeta  = "";           
LET  vnumcliente = "";            
LET  vnumcuenta   = ""; 
LET  vclave_sucursal = "1";


 --SET DEBUG FILE TO "/informix/resplogifx/auditor.out";
 --TRACE ON;
BEGIN
 ------------- control de errores------
    ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr <> 0 and vsqlerr <> -958  then
                let vcodret = vsqlerr;
                let p_mensaje = error_info;
                  RETURN vcodret, p_mensaje;
            END IF;
    END EXCEPTION;
	
	ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr = -958  then	
                   if error_info ='informix.asignadas' or error_info ='asignadas' then
					 drop table asignadas;
				   end if
                   if error_info ='informix.tarjetasasignadasdebito' or error_info ='tarjetasasignadasdebito' then
					 drop table tarjetasasignadasdebito;
				   end if
				   if error_info ='informix.tarjetasasignadascredito' or error_info ='tarjetasasignadascredito' then
					 drop table tarjetasasignadascredito;						  
				   end if
                   if error_info ='informix.tarjetaintercard' or error_info ='tarjetaintercard' then
					 drop table tarjetaintercard;						  
				   end if	
                   if error_info ='informix.pasointercard' or error_info ='pasointercard' then
					 drop table pasointercard;						  
				   end if	
                  if error_info ='informix.pasocheques' or error_info ='pasocheques' then
					 drop table pasocheques;						  
				   end if
                  if error_info ='informix.pasocliente' or error_info ='pasocliente' then
					 drop table pasocliente;						  
				   end if
                  if error_info ='informix.casotres' or error_info ='casotres' then
					 drop table casotres;						  
				   end if
                  if error_info ='informix.casocuatro' or error_info ='casocuatro' then
					 drop table casocuatro;						  
				   end if
                  if error_info ='informix.tarjetabdicheq' or error_info ='tarjetabdicheq' then
					 drop table tarjetabdicheq;						  
				   end if	
                 if error_info ='informix.tarjetacliente' or error_info ='tarjetacliente' then
					 drop table tarjetacliente;						  
				   end if	
                 if error_info ='informix.tarjetabdicred' or error_info ='tarjetabdicred' then
					 drop table tarjetabdicred;						  
				   end if	
                 if error_info ='informix.tarjetaclientecredito' or error_info ='tarjetaclientecredito' then
					 drop table tarjetaclientecredito;						  
				   end if	
				   
		    END IF;    
    END EXCEPTION WITH RESUME; 

-----------***********cuerpo**************-------------------  
SET isolation to dirty read;
SELECT fecha_hoy INTO vfecha_hoy FROM bdinteg:si_fechas;

  ----operaciones de fechas un día anterior Si hoy es 2012-12-12 se realiza la extracción del 2012-12-11
     LET primer_hora_dia = extend(extend(vfecha_hoy  - 1 units DAY));
     LET ultima_hora_dia_hora = extend(extend(vfecha_hoy  - 1 units DAY));
     LET ultima_hora_dia_hora = SUBSTRING(ultima_hora_dia_hora FROM 1 FOR 10) || ' 23:59:59';
 
    let vaniomes =  year(primer_hora_dia) || LPAD (MONTH(primer_hora_dia),2,"0");
	let dias = day(primer_hora_dia);

  /*Creación de tablas de paso */
            CREATE TABLE "informix".asignadas (		
           	codstatustarjeta    varchar(3),
		    codstatusasignada   varchar(3),
			bines               varchar(6),
            cantidad     	    integer     
	        )EXTENT SIZE 120 NEXT SIZE 120 LOCK MODE ROW;
			
			 CREATE TABLE "informix".tarjetasasignadasdebito (		
           	numtarjetaintercard             varchar(16),
		    numclienteintercard              varchar(13),
		    numcuentaintercard              varchar(13),
			numtarjetacheques             varchar(16),
		    numclientecheques             varchar(13),
		    numcuentacheques             varchar(13),
		    numclientecliente              varchar(13),
			clasificacion                  varchar(1)
	        )EXTENT SIZE 120 NEXT SIZE 120 LOCK MODE ROW;
			
			CREATE TABLE "informix".pasointercard (		
            numtarjetaintercard             varchar(16),
		    numclienteintercard              varchar(13),
		    numcuentaintercard              varchar(13)
	        )EXTENT SIZE 120 NEXT SIZE 120 LOCK MODE ROW;
			
		    CREATE TABLE "informix".pasocheques (		
            numtarcheques            varchar(16),
		    numclicheques            varchar(13),
		    numcuentacheques         varchar(13)
	        )EXTENT SIZE 120 NEXT SIZE 120 LOCK MODE ROW;
			
			CREATE TABLE "informix".pasocliente (
            numclicliente           varchar(16)
	        )EXTENT SIZE 120 NEXT SIZE 120 LOCK MODE ROW;
			
			CREATE TABLE "informix".tarjetasasignadascredito (		
           	numtarjetaintercard             varchar(16),
		    numclienteintercard              varchar(13),
		    numcuentaintercard              varchar(13),
			numtarjetacheques             varchar(16),
		    numclientecheques             varchar(13),
		    numcuentacheques             varchar(13),
		    numclientecliente              varchar(13),
			clasificacion                  varchar(1)
	        )EXTENT SIZE 120 NEXT SIZE 120 LOCK MODE ROW;
		
		
		    CREATE TABLE "informix".casotres (		
            numtarjeta                   varchar(16),
		    casotres                     varchar(1),
			descripcion                  varchar(40)
	        )EXTENT SIZE 20 NEXT SIZE 120 LOCK MODE ROW;
			
            CREATE TABLE "informix".casocuatro (		
            numtarjeta                   varchar(16),
		    casocuatro                     varchar(1),
			descripcion                  varchar(40)
	        )EXTENT SIZE 20 NEXT SIZE 120 LOCK MODE ROW;
			
            CREATE TABLE "informix".casocinco (		
            numtarjeta                   varchar(16),
		    casocinco                     varchar(1),
			descripcion                  varchar(40)
	        )EXTENT SIZE 20 NEXT SIZE 120 LOCK MODE ROW;

 
--Cuerpo del SP--
--1) Se realiza la extracción de tarjetas que se asignarón el día anterior tanto de débito,crédito el total de asignaciones y se guarda en la tabla de asignadas.

		SET isolation to dirty read;
		INSERT INTO asignadas (codstatustarjeta,codstatusasignada,bines,cantidad)
		SELECT codstatustarjeta as codstatustarjeta, codstatusasignada as codstatusasignada,SUBSTR (numtarjeta,0,7) as bines,count(*) as cantidad
		FROM intercard:tarjeta
		WHERE fechaasignacion BETWEEN primer_hora_dia AND  ultima_hora_dia_hora
	    GROUP by 1,2,3;

		 --1)Guardar archivo de asignaciones diarias de todos los tipos de tarjetas
            let vsql = ''; 	   
			let vsql = 'echo "Estatus de tarjeta|Estatus de Asignación|Bines|Cantidad">/resplogifx/TarAsig_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/TarAsig_.unl SELECT * FROM asignadas;">/resplogifx/tarasignadas.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard /resplogifx/tarasignadas.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /resplogifx/tarasignadas.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/TarAsig_.unl >>/resplogifx/TarAsig_"|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".unl";
			system vsql;
			let vsql ='rm /resplogifx/TarAsig_.unl';
			system vsql;

			
	/*Se realiza la extracción de tarjetas asignadas por bin */		
		SET isolation to dirty read;
		SELECT codstatustarjeta,codstatusasignada,bines,cantidad
		INTO   vcodstatustarjeta,vcodstatusasignada,vbines1,vcantida4008
		FROM   intercard:asignadas
		WHERE  codstatustarjeta = 'INA'
		AND    codstatusasignada  = 'SIA'
		AND    bines = '400819';
		
			SET isolation to dirty read;
		SELECT codstatustarjeta,codstatusasignada,bines,cantidad
		INTO   vcodstatustarjeta,vcodstatusasignada,vbines2,vcantidad4169
		FROM   intercard:asignadas
		WHERE  codstatustarjeta = 'INA'
		AND    codstatusasignada  = 'SIA'
        AND    bines = '416916';
		
			SET isolation to dirty read;
		SELECT codstatustarjeta,codstatusasignada,bines,cantidad
		INTO   vcodstatustarjeta,vcodstatusasignada,vbines3,vcantidad4268
		FROM   intercard:asignadas
		WHERE  codstatustarjeta = 'INA'
		AND    codstatusasignada  = 'SIA'
        AND    bines = '426807';

		SET isolation to dirty read;
		SELECT  {+INDEX(intercard:tarjeta 144_89 )}
		        tar.numtarjeta,tar.codproductotarjeta,tar.codstatustarjeta,tar.codstatusasignada,tar.numcliente,tc.numcuenta,tc.numtarjeta as numtarjetacuenta
		FROM    intercard:tarjeta tar, intercard:tarjetacuenta tc
		WHERE   tar.numtarjeta = tc.numtarjeta
		and     tar.codstatustarjeta = 'INA'
		and     tar.codstatusasignada = 'SIA'
		and     fechaasignacion BETWEEN primer_hora_dia AND  ultima_hora_dia_hora
		GROUP BY 1,2,3,4,5,6,7
		INTO temp tarjetaintercard WITH NO LOG;
		
		IF ((vbines1 = '400819') OR (vbines2 = '416916') ) THEN


	   /*Se extrea de la tabla tarjeta de Intercard los números de clientes tanto de débito, crédito  y se valida que la tarjeta de Intercard, exista en tarjetacuenta de Intercard.*/
					
					/* Se extrae información de la tabla sc_tarjeta  de la BD bdicheq con los número de cliente que se almacenaron en la tabla temporal tarjetaintercard y la información se almacena en tabla temporal */
                    SET isolation to dirty read;
					SELECT  sct.num_tarjeta,sct.numcte,sct.cuenta
					FROM    bdicheq:sc_tarjeta sct
					WHERE   numcte  IN (SELECT numcliente FROM intercard:tarjetaintercard WHERE codproductotarjeta LIKE '50%')
					GROUP BY 1,2,3
					INTO temp tarjetabdicheq WITH NO LOG;

					/* Se extrae información de la tabla si_cliente de la BD bdinteg con los número de cliente que se alamcenaron en la tabla temporal tarjetaintercard y la información se almacena en la tabla temporal */
					
                    SET isolation to dirty read;
					SELECT  sc.numcte
					FROM    bdinteg:si_cliente sc
					WHERE   numcte  IN (SELECT numcliente FROM intercard:tarjetaintercard WHERE codproductotarjeta LIKE '50%')
					GROUP BY 1
					INTO temp tarjetacliente WITH NO LOG;
					
                             /*se INSERTa datos a tablas temporales para la generación de reporte */
                                INSERT INTO pasointercard (numtarjetaintercard,numclienteintercard,numcuentaintercard)	
								SELECT  tar.numtarjeta,tar.numcliente,tc.numcuenta
								FROM    intercard:tarjetaintercard tar, intercard:tarjetaintercard tc
								WHERE   tar.numcliente IN (SELECT numcliente FROM intercard:tarjetaintercard WHERE codproductotarjeta LIKE '50%')
								AND     tar.numtarjeta = tc.numtarjeta
								GROUP BY 1,2,3;

                                INSERT INTO pasocheques (numtarcheques,numclicheques,numcuentacheques)	
								SELECT  sct.num_tarjeta,sct.numcte,sct.cuenta 
								FROM    intercard:tarjetabdicheq sct,intercard:tarjetaintercard tar
								WHERE   tar.numcliente IN (SELECT numcliente FROM intercard:tarjetaintercard WHERE codproductotarjeta LIKE '50%')
								GROUP BY 1,2,3;

								INSERT INTO pasocliente (numclicliente)	
								SELECT  sc.numcte
								FROM    intercard:tarjetacliente sc,intercard:tarjetaintercard tar
								WHERE   tar.numcliente IN (SELECT numcliente FROM intercard:tarjetaintercard WHERE codproductotarjeta LIKE '50%')
								GROUP BY 1;
					 
					 --TRUNCATE tarjetasasignadasdebito;
					 
					 /* Se realiza la unión de tablas temporales para la generación de reporte de tarjetas de débito*/
					 SET isolation to dirty read;
					INSERT INTO tarjetasasignadasdebito (numtarjetaintercard,numclienteintercard,numcuentaintercard,numtarjetacheques,numclientecheques,numcuentacheques,numclientecliente,clasificacion)
					     SELECT pin.numtarjetaintercard,pin.numclienteintercard,pin.numcuentaintercard,pc.numtarcheques,pc.numclicheques,pc.numcuentacheques,pd.numclicliente,'1' 
					          FROM intercard:pasointercard  pin
                              LEFT OUTER JOIN intercard:pasocheques pc
                                         ON pin.numclienteintercard = pc.numclicheques
                              LEFT OUTER JOIN intercard:pasocliente pd
                                         ON pc.numclicheques = pd.numclicliente;

						--1)Guardar archivo de asignaciones diarias de débito.
						let vsql = ''; 	   
						let vsql = 'echo "|----------INTERCARD------------------| ----------BDICHEQ--------------------------|---BDINTEG---|Clasificación">/resplogifx/EstatusTarjetasDebito_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.unl';
						system vsql;
						let vsql = '';
						let vsql = '';
						let vsql=  'echo "UNLOAD TO /resplogifx/EstatusTarjetasDebito_.unl SELECT * FROM tarjetasasignadasdebito;">/resplogifx/tarasi.sql'; 
						system vsql;
						let vsql ='';
						let vsql= 'dbaccess intercard /resplogifx/tarasi.sql';
						system vsql;
						let vsql = '';
						let vsql ='rm /resplogifx/tarasi.sql';
						system vsql;
						let vsql ='';
						let vsql = "sed 's/|$//g' /resplogifx/EstatusTarjetasDebito_.unl >>/resplogifx/EstatusTarjetasDebito_"|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".unl";
						system vsql;
						let vsql ='rm /resplogifx/EstatusTarjetasDebito_.unl';
						system vsql;
						
						
        END IF;	
						TRUNCATE asignadas;
						TRUNCATE tarjetasasignadasdebito;
						TRUNCATE intercard:pasointercard;
						TRUNCATE intercard:pasocheques;
						TRUNCATE intercard:pasocliente;
						
                   

				    IF (vbines3 = '426807' ) THEN
						
				/* Se extrae información de la tabla sd_tarjeta de la BD bdicred con los número de cliente que se almacenaron en la tabla temporal tarjetaintercard y la información se almacena en tabla temporal */
				
                    SET isolation to dirty read;
					SELECT  sdt.num_tarjeta,sdt.numcte,sdt.num_credito
					FROM    bdicred:sd_tarjeta sdt
					WHERE   numcte  IN (SELECT numcliente FROM intercard:tarjetaintercard WHERE codproductotarjeta LIKE '00%')
					GROUP BY 1,2,3
					INTO temp tarjetabdicred WITH NO LOG;

                    SET isolation to dirty read;
					SELECT  sc.numcte
					FROM    bdinteg:si_cliente sc
					WHERE   numcte  IN (SELECT numcliente FROM intercard:tarjetaintercard WHERE codproductotarjeta LIKE '00%')
					GROUP BY 1
					INTO temp tarjetaclientecredito WITH NO LOG;	
					
	 
					 /* Se realiza la unión de tablas temporales para la generación de reporte de tarjetas de crédito*/
							 INSERT INTO pasointercard (numtarjetaintercard,numclienteintercard,numcuentaintercard)	
								SELECT  tar.numtarjeta,tar.numcliente,tc.numcuenta
								FROM    intercard:tarjetaintercard tar, intercard:tarjetaintercard tc
								WHERE   tar.numcliente IN (SELECT numcliente FROM intercard:tarjetaintercard WHERE codproductotarjeta LIKE '00%')
								AND     tar.numtarjeta = tc.numtarjeta
								GROUP BY 1,2,3;

                                INSERT INTO pasocheques (numtarcheques,numclicheques,numcuentacheques)	
								SELECT  sdt.num_tarjeta,sdt.numcte,sdt.num_credito 
								FROM    intercard:tarjetabdicred sdt,intercard:tarjetaintercard tar
								WHERE   tar.numcliente IN (SELECT numcliente FROM intercard:tarjetaintercard WHERE codproductotarjeta LIKE '00%')
								AND     sdt.num_tarjeta = tar.numtarjeta
								GROUP BY 1,2,3;

								INSERT INTO pasocliente (numclicliente)	
								SELECT  sc.numcte
								FROM    intercard:tarjetaclientecredito sc,intercard:tarjetaintercard tar
								WHERE   tar.numcliente IN (SELECT numcliente FROM intercard:tarjetaintercard WHERE codproductotarjeta LIKE '00%')
								GROUP BY 1;

					 --TRUNCATE tarjetasasignadascredito;
					  /* Se realiza la unión de tablas temporales para la generación de reporte de tarjetas de débito*/
					 SET isolation to dirty read;
					INSERT INTO tarjetasasignadascredito (numtarjetaintercard,numclienteintercard,numcuentaintercard,numtarjetacheques,numclientecheques,numcuentacheques,numclientecliente,clasificacion)
					     SELECT pin.numtarjetaintercard,pin.numclienteintercard,pin.numcuentaintercard,pc.numtarcheques,pc.numclicheques,pc.numcuentacheques,pd.numclicliente,'1' 
					          FROM intercard:pasointercard  pin
                              LEFT OUTER JOIN intercard:pasocheques pc
                                         ON pin.numclienteintercard = pc.numclicheques
                              LEFT OUTER JOIN intercard:pasocliente pd
                                         ON pc.numclicheques = pd.numclicliente;
										 
										 --2)Guardar archivo de asignaciones diarias de crédito.
						let vsql = ''; 	   
						let vsql = 'echo "|----------INTERCARD-------------------| ----------BDICRED--------------------------|---BDINTEG---|Clasificación">/resplogifx/EstatusTarjetasCredito_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.unl';
						system vsql;
						let vsql = '';
						let vsql = '';
						let vsql=  'echo "UNLOAD TO /resplogifx/EstatusTarjetasCredito_.unl SELECT * FROM tarjetasasignadascredito;">/resplogifx/tarasi.sql'; 
						system vsql;
						let vsql ='';
						let vsql= 'dbaccess intercard /resplogifx/tarasi.sql';
						system vsql;
						let vsql = '';
						let vsql ='rm /resplogifx/tarasi.sql';
						system vsql;
						let vsql ='';
						let vsql = "sed 's/|$//g' /resplogifx/EstatusTarjetasCredito_.unl >>/resplogifx/EstatusTarjetasCredito_"|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".unl";
						system vsql;
						let vsql ='rm /resplogifx/EstatusTarjetasCredito_.unl';
						system vsql;
						      			
				    END IF;
				/*CASO 3 Cuando el nombre del Cliente esta vacío */
				        SET isolation to dirty read;
						    INSERT INTO casotres (numtarjeta,casotres,descripcion)	
						    SELECT {+INDEX(intercard:tarjeta idx_nombre )}
							      numtarjeta,'3','Campo Nombre vacio'
							FROM  intercard:tarjeta
							WHERE nombre = '' 
							AND   codstatustarjeta = 'ACT'
							AND   codstatusasignada = 'SIA'
							AND   fechaasignacion BETWEEN primer_hora_dia AND  ultima_hora_dia_hora;
						
				/*CASO 4 Cuando el número de cliente esta vacío */			
						SET isolation to dirty read;	
							INSERT INTO casocuatro (numtarjeta,casocuatro,descripcion)	
							SELECT {+INDEX(intercard:tarjeta idx_numcte )}
							       numtarjeta,'4','Campo Cliente vacio'
							FROM   intercard:tarjeta
							WHERE  numcliente  = ''
							AND    codstatustarjeta = 'ACT'
							AND    codstatusasignada = 'SIA'
							AND    fechaasignacion BETWEEN primer_hora_dia AND  ultima_hora_dia_hora;
										
				/*CASO 5 Cuando el  producto esta vacío */					
                        SET isolation to dirty read;
							INSERT INTO casocinco (numtarjeta,casocinco,descripcion)	
							SELECT numtarjeta,'5','Campo Producto vacio'
							FROM  intercard:tarjeta
							WHERE codproductotarjeta = '' 
							and   codstatustarjeta = 'ACT'
							AND   codstatusasignada = 'SIA'
							AND   fechaasignacion BETWEEN primer_hora_dia AND  ultima_hora_dia_hora;

					 
				    --3)Guardar archivo de asignaciones de los caos tipo 3,4,5 separados por los casos 
						let vsql = ''; 	   
						let vsql = 'echo "|----Tarjetas---|Casos|Descripción|">/resplogifx/EstatusTarjetasCasos_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.unl';
						system vsql;
						let vsql = '';
						let vsql = '';
						let vsql=  'echo "UNLOAD TO /resplogifx/EstatusTarjetasCasos_.unl  SELECT * FROM intercard:casotres UNION ALL SELECT * FROM intercard:casocuatro UNION ALL SELECT * FROM intercard:casocinco;">/resplogifx/tarcasos.sql'; 
						system vsql;
						let vsql ='';
						let vsql= 'dbaccess intercard /resplogifx/tarcasos.sql';
						system vsql;
						let vsql = '';
						let vsql ='rm /resplogifx/tarcasos.sql';
						system vsql;
						let vsql ='';
						let vsql = "sed 's/|$//g' /resplogifx/EstatusTarjetasCasos_.unl >>/resplogifx/EstatusTarjetasCasos_"|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".unl";
						system vsql;
						let vsql ='rm /resplogifx/EstatusTarjetasCasos_.unl';
						system vsql;	


						DROP TABLE casotres;
						DROP TABLE casocuatro;
						DROP TABLE casocinco;		
	                    DROP TABLE asignadas;
						DROP TABLE tarjetasasignadasdebito;
						DROP TABLE tarjetasasignadascredito;
						DROP TABLE tarjetaintercard; 
						DROP TABLE intercard:pasointercard;
						DROP TABLE intercard:pasocheques;
						DROP TABLE intercard:pasocliente;
						DROP TABLE tarjetabdicheq;
		                DROP TABLE tarjetacliente;
		                DROP TABLE tarjetabdicred;
						DROP TABLE tarjetaclientecredito;						
   END;
END PROCEDURE;