CREATE PROCEDURE "informix".sp_archivoconsultafolioafore(pFechaDia DATE)

RETURNING
	CHAR(6)	 AS 	Codigo_retorno;

	--DECLARA VARIABLES
	DEFINE	iSqlErr			INTEGER;
	DEFINE	cCodRet			CHAR(6);
	DEFINE 	cFecha			CHAR(8);
	DEFINE cFecha2			CHAR(10);
	DEFINE 	cRuta			CHAR(100);
	DEFINE	cNombreArchivo	CHAR(100);
	DEFINE	cNomArchAux		CHAR(100);
	DEFINE	cSql			CHAR(2500);
	DEFINE 	cConsulta		CHAR(2200);
	
	DEFINE cFecha_Tran char(8);
	DEFINE vCurp char(18);
	DEFINE vPlastico char(4);
	DEFINE vApellidopaterno char(26);
	DEFINE vApellidomaterno char(26);
	DEFINE vNombres char(52);
	DEFINE vFechanacimiento char(8);
	DEFINE vNumtarjeta char(16);
	DEFINE vSexo char(1);
	DEFINE vRfc CHAR(13);
	DEFINE vclvEstado char(2);
	DEFINE vMunicipio char(27);
	DEFINE vCiudad char(60);
	DEFINE vColonia char(32);
	DEFINE vCalle char(30);
	DEFINE vNumExt char(10);
	DEFINE vNumInt char(10);
	DEFINE vTcasa char(1);
	DEFINE vtelefonocasa char(13);
	DEFINE vcompaniatelcasa char(30);
	DEFINE vTcel char(1);
	DEFINE vtelefonoper char(13);
	DEFINE vcompaniatelper char(30);
	DEFINE vToficina char(1);
	DEFINE vtelefonooficina char(13);
	DEFINE vcompaniateloficina char(30);
	DEFINE vPuesto char(60);
	DEFINE vCorreo CHAR(100); 
	DEFINE vNacionalidad CHAR(15);
	DEFINE vPais CHAR(3);
	DEFINE Vnumcte CHAR(20);
	DEFINE vCod_postal CHAR(5);
	DEFINE Vproductoligado CHAR(4);
	DEFINE cvegiroempresa CHAR(3);
	DEFINE dFechaApertcta char(8);
	DEFINE vCod_resp CHAR(3);
	DEFINE vfolioafore CHAR(2);
	--IDB20190620	{
	DEFINE dFechaIni DATETIME YEAR TO SECOND;
	DEFINE dFechaFin DATETIME YEAR TO SECOND;
	--				}


	--INICIALIZA VARIABLES
	LET		iSqlErr			=0;
	LET		cCodRet			='000000';
	LET		cFecha			='';
	LET   	cRuta			='';
	LET   	cNombreArchivo	='';
	LET 	cNomArchAux		='';
	LET   	cSql			='';
	LET     cConsulta		='';
	LET		cvegiroempresa	='';
	--IDB20190620	{
	LET dFechaIni = CURRENT;
	LET dFechaFin = CURRENT;
	--				}
	
	
	

	--INICIO
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;	
		
--	SET DEBUG FILE TO '/informix/c92962301/afore/respuestaAFORE.out';
--		TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
					
						
		IF EXISTS( SELECT dbsname, tabname FROM sysmASter:systabnames  WHERE tabname = 'paso_folioafore' ) THEN
				
				DROP TABLE bdinteg:"informix".paso_folioafore;
				
		END IF;
				
		CREATE TABLE  bdinteg:"informix".paso_folioafore
		( fecha_consulta char(8),
		curp char(18),
		plastico char(4),
		apell_parterno char(26),
		apell_materno char(26),
		nombres char(52),
		fecha_nacimiento char(8),
		sexo char(1),
		rfc char(13),
		cveerror char(3),
		cveestado char(2),
		municipio_delegacion char(27),
		ciudad char(60),
		colonia char(32),
		calle char(30),
		numexterior CHAR(10) ,
		numinterior CHAR(10) ,
		tel_casa char(1) DEFAULT '' NOT NULL,
		num_tel_casa char(13) DEFAULT '' NOT NULL,
		compania_tel_casa CHAR(30) DEFAULT '' NOT NULL,
		tel_oficina char(1) DEFAULT '' NOT NULL,
		num_tel_oficina char(13) DEFAULT '' NOT NULL,
		compania_tel_oficina CHAR(30) DEFAULT '' NOT NULL,
		tel_celular char(1) DEFAULT '' NOT NULL,
		num_tel_cel char(13) DEFAULT '' NOT NULL,
		compania_tel_cel CHAR(30) DEFAULT '' NOT NULL,
		ocupacion char(60),
		email CHAR(100),
		nacionalidad char(15),
		cvepais char(3),
		numcte char(20),
		codigopostal char(5),
		cveproductoligado char(4),
		cvegiroempresa CHAR(3),
		fecha_apercta char(8),
		folio_operacion char(2)
		);								
						
					
					
					
					
		LET cFecha2 = SUBSTR(pFechaDia,1,2)||'-'||SUBSTR(pFechaDia,4,2)||'-'||SUBSTR(pFechaDia,7,4);
		LET cFecha = SUBSTR(pFechaDia,7,4)||SUBSTR(pFechaDia,1,2)||SUBSTR(pFechaDia,4,2);
		
		--IDB20190620 	{
		LET dFechaIni = TO_DATE(cFecha || '00:00:00', "%Y%m%d %H:%M:%S");
		LET dFechaFin= TO_DATE(cFecha || '23:59:59', "%Y%m%d %H:%M:%S");
		--				}
		
		--CONSULTA LA INFORMACION
		FOREACH WITH HOLD
		
		--Datos de la tabla si_folioafore
		SELECT TRIM(fecha_transac),curp_resp,num_tarjeta,SUBSTR(num_tarjeta,13,4),codigo_resp, nvl(numcliente,''),folio_resp
		INTO cFecha_Tran,vCurp,vNumtarjeta,vPlastico,vCod_resp,Vnumcte,vfolioafore
		FROM 	"informix".si_folioafore as A
		INNER JOIN intercard:"informix".tarjeta as B on (a.num_tarjeta = b.numtarjeta)
		--WHERE	TO_CHAR(fecha_insert,'%Y%m%d') = cFecha --IDB20190620 Se modifica el filtro de fecha_insert
		WHERE  a.num_tarjeta not in('4008190000000821') 
		and a.fecha_insert between dFechaIni and dFechaFin
        AND a.codigo_resp='01'
		
		IF Vnumcte <>'' THEN
		
				--Datos	del cliente	
				SELECT apell_paterno ,apell_materno ,nombre1||''||nombre2,rfc,TO_CHAR(fecha_nac,'%Y%m%d')  ,sexo,c.descripcion 
				INTO vApellidopaterno, vApellidomaterno,vNombres,vRfc,vFechanacimiento,vSexo,vNacionalidad
				FROM bdinteg:"informix".si_cliente a
				INNER JOIN bdinteg:"informix".si_ctepf b on a.numcte = b.numcte
				INNER JOIN bdinteg:"informix".si_nacion c on b.nacionalidad = c.nacion
				WHERE a.numcte = Vnumcte;
				
				--DirecciÃ³n del cliente
				SELECT nvl(b.estado,''),nvl(e.municipiozona,''),nvl(d.nombre,''),nvl(e.nombrezona,''),nvl(f.nombrecalle,''),
				nvl(numeroextcalle,''),nvl(numerointcalle,''),nvl(cod_postal,''),nvl(b.pais,'')
				INTO vclvEstado,vMunicipio,vCiudad,vColonia,vCalle,vNumExt,vNumInt,vCod_postal,vPais
				FROM "informix".si_cliente a
				INNER JOIN "informix".si_direcciones_actual b ON a.numcte = b.numcte
				LEFT JOIN "informix".si_estados c on  b.estado = c.estado
				LEFT JOIN "informix".si_ciudades d on b.estado = d.estado AND b.ciudad = d.ciudad
				LEFT JOIN "informix".si_catzonas e on e.numerocolonia =b.numerocolonia AND e.numerociudad = b.numerociudad
				LEFT JOIN "informix".si_catcalles f on b.numerocalle = f.numerocalle
				WHERE a.numcte = Vnumcte
				AND b.tipo_dir = '1';
				
				--Telefonos del cliente
					--telefono de casa del cliente
				SELECT nvl(tipo_tel,''),nvl(telefono,''),nvl(nombre_carrier,'')
				INTO  vTcasa , vtelefonocasa, vcompaniatelcasa 
				FROM si_cliente a
				INNER JOIN "informix".si_telefonos b ON a.numcte = b.numcte
				LEFT JOIN "informix".si_carriers c ON b.carrier = c.cve_carrier
				WHERE a.numcte =Vnumcte
				AND status_tel='A'
				AND tipo_tel ='1'
				AND secuencia in(select max(secuencia) from bdinteg:si_telefonos where numcte =Vnumcte AND status_tel='A'
				AND tipo_tel ='1');
				
				IF vTcasa IS NULL THEN
				LET vTcasa ='';
				LET vtelefonocasa ='';
				LET vcompaniatelcasa='';
				END IF;
				
					--telefono de casa del personal
				SELECT nvl(tipo_tel,''),nvl(telefono,''),nvl(nombre_carrier,'')
				INTO  vTcel , vtelefonoper, vcompaniatelper
				FROM "informix".si_cliente a
				INNER JOIN "informix".si_telefonos b ON a.numcte = b.numcte
				LEFT JOIN "informix".si_carriers c ON b.carrier = c.cve_carrier
				WHERE a.numcte =Vnumcte
				AND status_tel='A'
				AND tipo_tel ='3'
				AND secuencia in(select max(secuencia) from bdinteg:si_telefonos where numcte =Vnumcte AND status_tel='A'
				AND tipo_tel ='3');
				
				IF vTcel IS NULL THEN
				LET vTcel ='';
				LET vtelefonoper ='';
				LET vcompaniatelper='';
				END IF;
				
				
					--telefono de casa del oficina
				SELECT nvl(tipo_tel,''),nvl(telefono,''),nvl(nombre_carrier,'')
				INTO  vToficina , vtelefonooficina, vcompaniateloficina
				FROM "informix".si_cliente a
				INNER JOIN "informix".si_telefonos b ON a.numcte = b.numcte
				LEFT JOIN "informix".si_carriers c ON b.carrier = c.cve_carrier
				WHERE a.numcte =Vnumcte
				AND status_tel='A'
				AND tipo_tel ='2'
				AND secuencia in(select max(secuencia) from bdinteg:si_telefonos where numcte =Vnumcte AND status_tel='A'
				AND tipo_tel ='2');
				
				IF vToficina IS NULL THEN
				LET vToficina ='';
				LET vtelefonooficina ='';
				LET vcompaniateloficina='';
				END IF;
				
					--puesto del cliente
				SELECT UNIQUE nvl(b.descrip,'')
				INTO vPuesto
				FROM "informix".si_bitacoraapertura a
				INNER JOIN "informix".si_actsubact b on  b.id_act =a.id_act and  b.id_subact =a.id_subact
				WHERE numcte = Vnumcte AND id_secuencia IN(SELECT MAX(id_secuencia) FROM si_bitacoraapertura WHERE numcte =Vnumcte AND id_pregunta ='6');
				
				IF vPuesto IS NULL THEN
				LET vPuesto ='';
			
				END IF;
				
			
				--Correo del cliente
				
				SELECT nvl(correo_elec,'') 
				INTO vCorreo
				FROM si_correos
				WHERE numcte =Vnumcte AND status_correo ='A' 
				AND secuencia in (SELECT MAX(secuencia) FROM  si_correos
				WHERE numcte =Vnumcte AND status_correo ='A');
				IF vCorreo is null THEN
				
				LET vCorreo ='';
				END IF;
				-- Datos de la cuenta
						--CaptaciÃ³n
				SELECT producto, TO_CHAR(fecha_alta,'%Y%m%d')
				INTO Vproductoligado,dFechaApertcta 
				FROM bdicheq:"informix".sc_maechq a
				INNER JOIN bdicheq:sc_maenoc b ON a.cuenta = b.cuenta  
				WHERE a.cuenta IN(select  numcuenta FROM intercard:tarjetacuenta WHERE numtarjeta = vNumtarjeta);
						--Credito
				IF Vproductoligado is null THEN
				
				SELECT num_producto , TO_CHAR(fecha_apertura,'%Y%m%d') 
				INTO Vproductoligado,dFechaApertcta 
				from bdicred:"informix".sd_maecred
				WHERE num_credito IN(SELECT  numcuenta from intercard:tarjetacuenta WHERE numtarjeta = vNumtarjeta);		
				
				END IF;
			
			--IDB20190528 { Se agregan NVL a todas las variables para que ninguna se inserte en NULL
			 INSERT INTO "informix".paso_folioafore(fecha_consulta,curp,plastico,apell_parterno,apell_materno,nombres,fecha_nacimiento,sexo,rfc,cveerror,
			cveestado,municipio_delegacion,ciudad,colonia,calle,numexterior,numinterior,tel_casa,num_tel_casa ,compania_tel_casa ,tel_oficina,num_tel_oficina ,compania_tel_oficina ,
			tel_celular,num_tel_cel,compania_tel_cel ,ocupacion ,email ,nacionalidad,cvepais ,numcte,codigopostal,cveproductoligado,cvegiroempresa ,fecha_apercta,
			folio_operacion) VALUES(NVL(cFecha_Tran,''), 		NVL(vCurp,''), 				NVL(vPlastico,''),
									NVL(vApellidopaterno,''),	NVL(vApellidomaterno,''),	NVL(vNombres,''),
									NVL(vFechanacimiento,''),	NVL(vSexo,''),				NVL(vRfc,''),
									NVL(vCod_resp,''),			NVL(vclvEstado,''),			NVL(vMunicipio,''),
									NVL(vCiudad,''),			NVL(vColonia,''),			NVL(vCalle,''),
									NVL(vNumExt,''),			NVL(vNumInt,''),			NVL(vTcasa,''),
									NVL(vtelefonocasa,''),		NVL(vcompaniatelcasa,''),	NVL(vToficina,''),
									NVL(vtelefonooficina,''),	NVL(vcompaniateloficina,''),NVL(vTcel,''),
									NVL(vtelefonoper,''),		NVL(vcompaniatelper,''),	NVL(vPuesto,''),
									NVL(vCorreo,''),			NVL(vNacionalidad,''),		NVL(vPais,''),
									NVL(Vnumcte,''),			NVL(vCod_postal,''),		NVL(Vproductoligado,''),
									NVL(cvegiroempresa,''),		NVL(dFechaApertcta,''),		NVL(vfolioafore,'')
									); 
			--IDB20190528
		END IF;	 
			 
		END foreach;
--		LET cConsulta =	"select * from bdinteg:paso_folioafore;";
		--IDB20190528 { Se agregan RPAD y TRIM a los campos que no lo tenian, ademas se agrega REPLACE en los numero de casa int y ext
		LET cConsulta =	"select RPAD(TRIM(fecha_consulta),8,' '),	RPAD(TRIM(curp),18,' '),				RPAD(TRIM(plastico),4,' '), " ||
								"RPAD(trim(apell_parterno),26,' '),	RPAD(trim(apell_materno),26,' '),		RPAD(trim(nombres),52,' '), " ||
								"RPAD(TRIM(fecha_nacimiento),8,' '),RPAD(TRIM(sexo), 1, ' '),				RPAD(trim(rfc),13,' ')," ||
								"RPAD(trim(cveestado),2,' '),		RPAD(trim(municipio_delegacion),27,' '),RPAD(trim(ciudad),60,' ')," ||
								"RPAD(trim(colonia),32,' '),		RPAD(trim(calle),30,' ')," ||
								"RPAD(REPLACE(trim(numexterior),'\',''),10,' ')," ||
								"RPAD(REPLACE(trim(numinterior),'\',''),10,' ')," ||
								"RPAD(trim(tel_casa),1,' '),		RPAD(trim(num_tel_casa),13,' '),	 RPAD(trim(compania_tel_casa),30,' ')," ||
								"RPAD(trim(tel_oficina),1,' '),		RPAD(trim(num_tel_oficina),13,' '),	 RPAD(trim(compania_tel_oficina),30,' '),"||
								"RPAD(trim(tel_celular),1,' '),		RPAD(trim(num_tel_cel),13,' '),		 RPAD(trim(compania_tel_cel),30,' ')," ||
								"RPAD(trim(ocupacion),60,' '),		RPAD(trim(email),100,' '),			 RPAD(trim(nacionalidad),15,' ')," ||
								"RPAD(trim(cvepais),3,' '),			RPAD(trim(numcte),20,' '),			 RPAD(trim(codigopostal),5,' ')," ||
								"RPAD(trim(cveproductoligado),4,' '),RPAD(trim(cvegiroempresa),3,' '),	 RPAD(TRIM(fecha_apercta),8,' ')," ||
								"RPAD(TRIM(folio_operacion),2,' ') " ||
						"from bdinteg:paso_folioafore;"; 
		--IDB20190528 }
		
--		LET cConsulta =	"select TRIM(fecha_consulta)||TRIM(curp)||TRIM(plastico)||TRIM(apell_parterno)||TRIM(apell_materno)||nombres||TRIM(fecha_nacimiento)||TRIM(sexo)||TRIM(rfc)||TRIM(cveerror)||TRIM(cveestado)||TRIM(municipio_delegacion)||TRIM(ciudad)||TRIM(colonia)||TRIM(calle)||TRIM(numexterior)||TRIM(numinterior)||TRIM(tel_casa)||TRIM(num_tel_casa)||TRIM(compania_tel_casa)||TRIM(tel_oficina)||TRIM(num_tel_oficina)||TRIM(compania_tel_oficina)||TRIM(tel_celular)||TRIM(num_tel_cel)||TRIM(compania_tel_cel)||TRIM(ocupacion)||TRIM(email)||TRIM(nacionalidad)||TRIM(cvepais)||TRIM(numcte)||TRIM(codigopostal)||TRIM(cveproductoligado)||TRIM(cvegiroempresa)||TRIM(fecha_apercta)||TRIM(folio_operacion) AS descripcion from bdinteg:paso_folioafore;";		
		--CREACION DE REPORTE EN ARCHIVO .TXT	
		--RUTA PARA GENERAR EL ARCHIVO
				
		SELECT valor
		INTO cRuta
		FROM "informix".si_param  
		WHERE empresa = '001' 
		AND cod_param=250;
		
		--SINO EXISTE LA RUTA DEL ARCHIVO	
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000001';
			RETURN cCodRet;
		END IF;	
			
		--GENERA EL NOMBRE DEL ARCHIVO
		LET cNombreArchivo = TRIM('AFO_DATOS')||'_'||TRIM(cFecha)||'.log';
		LET cNomArchAux = TRIM('AFO_DATOS_CONCILIAX')||'_'||TRIM(cFecha)||'.log';
			
		--CREACION DE TEMPORALESS USADOS PARA LA CREACION DE ARCHIVO
		LET cSql = 'echo "unload to ' || TRIM(cRuta) ||   TRIM(cNomArchAux) ||  ' DELIMITER ' || '''|''' ||' '|| TRIM(cConsulta)||'" >' || TRIM(cRuta) || 'query1.sql';
		SYSTEM cSql;

		LET cSql = 'dbaccess bdinteg ' || TRIM(cRuta) || 'query1.sql';
		SYSTEM TRIM(cSql);
		
		-- ELIMINAR EL PIPE "|" DEL ARCHIVO DE TRABAJO
		LET cSql = "sed 's/|//g' "|| TRIM(cRuta) || TRIM(cNomArchAux) || " >> " ||  TRIM(cRuta) || TRIM(cNombreArchivo);
		SYSTEM cSql;
		
		

		--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
		LET cSql = 'rm ' || TRIM(cRuta) || 'query1.sql';
		SYSTEM cSql;   

		LET cSql = 'rm ' || TRIM(cRuta) || TRIM(cNomArchAux );
		SYSTEM cSql; 
		DROP TABLE bdinteg:"informix".paso_folioafore;
		--RETURN PRINCIPAL
		RETURN cCodRet;
	END
END PROCEDURE
DOCUMENT
'AUTOR: Jesus Ernesto Aguilera Inda.',
'DESCRIPCIÃN: SP que genera un archivo .txt donde se guardan las consultas efectivas de folio afore.',
'FOLIO:1420',
'FECHA:27/03/2014',
'VERSIÃN: 20140327.1606',
'BASE DE DATOS: bdinteg',
'Folio.........: 1920-INC_DESFASE_ARCHIVOAFORE',
'Autor.........: 95526749 - JesÃºs Horacio LÃ³pez GonzÃ¡lez',
'Fecha.........: 28/05/2019 - IDB20190528',
'..............: 20/06/2019 - IDB20190620',
'ModificaciÃ³n..: IDB20190528: Se modifica para que no se guarden valores en NULL y remplazar el caracter \ en los num de casa para que no haya desfase.',
'..............: IDB20190620: Se modifica para bajar los costos de la consulta principal',
'Sustento......: IDB20190528: Se definiÃ³ por correo, el dÃ­a 21/05/2019, correo enviado por Jose Angel Gaxiola Gaxiola.',
'..............: IDB20190620: Se definiÃ³ por correo, el dia 18/06/2019, correo enviado por Cutberto Gonzalez Perez.',
'Solicita......: Cutberto Gonzalez',
'BD............: bdinteg';

CREATE PROCEDURE "informix".sp_obtieneinfprod(Tipot CHAR(1), pBin CHAR(6),pSubBin CHAR(2), pCodProdCta CHAR(4), pClavetp CHAR(3))
   RETURNING CHAR(5), CHAR(2), CHAR(6), CHAR(2), CHAR(3), CHAR(4), CHAR(3);
      
   DEFINE cCodRet             CHAR(5);
   DEFINE iSqlErr             INTEGER;
   DEFINE cIdBin              CHAR(2);
   DEFINE cCodBin             CHAR(6);
   DEFINE cProd               CHAR(2);
   DEFINE cCodProd            CHAR(3);
   DEFINE cCodProdCta		  CHAR(4);
   DEFINE cClavetp            CHAR(3);
     
   LET cCodRet        ='00000';   
   LET cIdBin		  ='00';
   LET cCodBin        ='000000';
   LET cProd		  ='00';
   LET cCodProd       ='000';
   LET cCodProdCta    ='0000';
   LET cClavetp       ='000';
         
BEGIN
                  ON EXCEPTION SET iSqlErr
                      IF iSqlErr <> 0 THEN
                         LET cCodRet = iSqlErr;
                                                               
                         RETURN cCodRet, cIdBin, cCodBin, cProd, cCodProd, cCodProdCta, cClavetp;
                      END IF;
                  END EXCEPTION;
                
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;

           /*SELECT DISTINCT idbinproducto, a.bin, producto, a.codproductotarjeta, codprodcta, clave
		   INTO cIdBin, cCodBin, cProd, cCodProd, cCodProdCta, cClavetp
		   FROM intercard:binproducto a, intercard:tipotarjeta b
		   WHERE a.codproductotarjeta = b.codproductotarjeta 
           AND producto = pSubBin
           AND codprodcta = pCodProdCta
		   AND Tipo = Tipot 
		   AND a.bin = pBin
           AND clave = pClavetp;    */
            
           IF EXISTS (SELECT DISTINCT codprodcta 
                     FROM intercard:binproducto a INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
                     WHERE a.bin= pBin AND codprodcta = pCodProdCta) THEN 

                SELECT DISTINCT idbinproducto, a.bin, producto, a.codproductotarjeta, codprodcta, clave 
                INTO cIdBin, cCodBin, cProd, cCodProd, cCodProdCta, cClavetp
                FROM intercard:binproducto a
                INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
                WHERE a.bin = pBin 
                AND a.producto= pSubBin 
                AND b.clave = pClavetp
                AND a.codprodcta = pCodProdCta;
           ELSE
				--RETURN '00002';
                 LET  cCodRet = '00001';
		   END IF;         

           IF cCodBin IS NULL or cCodProd IS NULL THEN
                      LET  cCodRet = '00001';
           END IF;

           RETURN cCodRet, cIdBin, cCodBin, cProd, cCodProd, cCodProdCta, cClavetp;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Dr. Rorro Mendoza',
'FECHA: 20/10/2017',
'BD: Intercard',
'Objetivo: Se crea procedimiento para obtener información del producto de la cuenta.';

CREATE PROCEDURE "informix".sp_dicta_modificaciondictamen(pNumcte CHAR(20), pSituacion CHAR(4), pCausa SMALLINT, pUsuario CHAR (20))


	--RETORNOS -
	RETURNING
	CHAR(6) AS codret;


	--DECLARACION DE LAS VARIABLES--
	DEFINE iSql_err		    INTEGER; 
	DEFINE cCodret		    CHAR(6);



	--INICIALIZACION DE VARIABLES--
	LET iSql_err		     = 0;
	LET cCodret		         = '000000';


	--INICIO--
	BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err 
	IF iSql_err <> 0 THEN
		LET cCodret = iSql_err;
		RETURN TRIM(cCodret);
	END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/LuisMadrid/sp_consultaempleadowu.out';
	--TRACE ON;	 
	
	SET ISOLATION TO DIRTY READ;		
	SET LOCK MODE TO WAIT 3;

	--SE VALIDA QUE SE MANDEN TODOS LOS PARAMETROS (NO NULOS NI VACIOS) YA QUE SON NECESARIOS TODOS
	IF NVL(pNumcte,'') = '' OR NVL(pSituacion,'')  = '' OR NVL(pCausa,'') = '' OR NVL(pUsuario,'') = '' THEN
	    LET cCodret = '000001'; 
	RETURN TRIM(cCodret);

	END IF;		  

	--************************************************************************************
	---------------****************BLOQUE DE CONSULTA*************************************
	--************************************************************************************
	UPDATE bdisitesp: "informix".se_ctessitespcte
			SET situacion = pSituacion, causa = pCausa, usrmodifica = pUsuario, fchmodifica = CURRENT
			WHERE numcte = pNumcte;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '000002'; 
	RETURN TRIM(cCodret);
	END IF;

	DELETE FROM "informix".si_bitacora_dictamenes  WHERE numcte = pNumcte;

	
	RETURN TRIM(cCodret);					
			
END;
END PROCEDURE
DOCUMENT
'AUTOR: 97122114, Luis Alberto Madrid Castro',
'FOLIO: 230142 - 1530  - EvaluaciÃ³n de Resultados de ComparaciÃ³n de Huellas en LÃ­nea en Alta de Cliente ',
'DESCRIPCION: creacion de sp_dicta_ModificacionDictamen para poder modificar dictamines.',
'FECHA: 01/01/2015',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_desfusion_ctesdigital(pCteTit CHAR(20), pTramaDetalle CHAR(200), pIdentificador CHAR(1))
--RETORNOS-
RETURNING
CHAR(6) AS codret,
CHAR (30) AS Descripcion,
CHAR (30) AS Tabla1,
CHAR (30) AS Tabla2,
CHAR (30) AS Tabla3;

--DECLARACION DE VARIABLES--
DEFINE iSql_err		INTEGER;
DEFINE cDescErr		CHAR(30);
DEFINE cCodret		CHAR(6);
DEFINE cBandVal		CHAR(1);
DEFINE iFin			INTEGER;
DEFINE iIni			INTEGER;
DEFINE cNumcteInco	CHAR(20);
DEFINE cCodigoDig	CHAR(5);
DEFINE cSecuencia	CHAR(5);
DEFINE cSecActual	CHAR(5);
DEFINE cCuenta 		CHAR(20);
DEFINE cProducto	CHAR(5);
DEFINE cTabla		CHAR(25);
DEFINE cTabla1		CHAR(25);
DEFINE cTabla2		CHAR(25);
DEFINE iExiste		INTEGER;

DEFINE v_ruta       CHAR(50);
DEFINE v_nomarch    CHAR(20);
DEFINE vc_CodRet    CHAR(5);
DEFINE isam_err  	INT;

--INICIALIZACION DE VARIABLES--
LET iSql_err		= 0;
LET cDescErr    	= '';
LET cCodret			= '000000';
LET cBandVal		 = '';
LET iFin			= 0;
LET iIni			= 0;
LET cNumcteInco 		= '';
LET cCodigoDig		= '';
LET cSecuencia		= '';
LET cSecActual		= '';
LET cCuenta			= '';
LET cProducto		= '';
LET cTabla			= '';
LET cTabla1			= '';
LET cTabla2			= '';
LET iExiste			= 0;

LET v_ruta			= "";
LET v_nomarch		= "";
LET vc_CodRet 		= "00000";
--LET isam_err="0"; es cCodret

--INICIO--
BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN NVL(TRIM(cCodret),''), cDescErr, cTabla, cTabla1, cTabla2;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/josea/sp_desfusion_ctesdigital.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF pIdentificador = '1' THEN

		LET cBandVal = '1';
		LET iIni = 1;

		LET cNumcteInco = '';
		LET cCodigoDig = '';
		LET cSecuencia = '';
		LET cSecActual = '';
		LET iFin = 0;

		SELECT TRIM(valor) INTO v_ruta FROM bdinteg@coppel_tcp:si_param WHERE cod_param=122;
		--SE EXTRAE EL NUMERO DE CTE INCORRECTO DE LA TRAMA
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cNumcteInco = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - 1));
				LET iIni = iFin + 1;
			END IF;
		END WHILE

		LET cBandVal = '1';
		--SE EXTRAE EL CODIGO DE DIGITALIZACION
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cCodigoDig = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - iIni));
				LET iIni = iFin + 1 ;
			END IF;
		END WHILE

		LET cBandVal = '1';
		--SE EXTRAE LA SECUENCIA QUE CONTABA CTE ANTES DE LA FUSION
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cSecuencia = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - iIni));
				LET iIni = iFin + 1;
			END IF;
		END WHILE

		LET cBandVal = '1';
		--SE EXTRAE LA SECUENCIA ACTUAL
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cSecActual = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - iIni));
				LET iIni = iFin + 1;
			END IF;
		END WHILE

		--DG_EXPEDIENTE
		SELECT NVL(COUNT(*),0) INTO iExiste FROM bdidigital@coppelimg_tcp:"informix".dg_expediente WHERE cliente = TRIM(pCteTit);
		IF iExiste > 0 THEN
			LET cDescErr = 'dg_expediente';
			LET cTabla = 'dg_expediente';
			UPDATE bdidigital@coppelimg_tcp:"informix".dg_expediente SET cliente = TRIM(cNumcteInco), secuencia = TRIM(cSecuencia)
			WHERE cliente = TRIM(pCteTit)
			AND cod_docto = cCodigoDig
			AND secuencia = cSecActual;
		END IF;


		--dg_expediente_img1
		SELECT NVL(COUNT(*),0) INTO iExiste FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img1 WHERE cliente = TRIM(pCteTit);
		IF iExiste > 0 THEN
			LET cDescErr = 'dg_expediente_img1';
			LET cTabla1 = 'dg_expediente_img1';
			UPDATE bdidigital@coppelimg_tcp:"informix".dg_expediente_img1 SET cliente = TRIM(cNumcteInco), secuencia = TRIM(cSecuencia)
			WHERE cliente = TRIM(pCteTit)
			AND cod_docto = cCodigoDig
			AND secuencia = cSecActual;
		END IF;

        --DG_EXPEDIENTE_IMG
		SELECT NVL(COUNT(*),0) INTO iExiste FROM bdidigital@coppelimghis_tcp:"informix".dg_expediente_img WHERE cliente = TRIM(pCteTit);
		IF iExiste > 0 THEN
			LET cDescErr = 'dg_expediente_img';
			LET cTabla2 = 'dg_expediente_img';
			UPDATE bdidigital@coppelimghis_tcp:"informix".dg_expediente_img SET cliente = TRIM(cNumcteInco), secuencia = TRIM(cSecuencia)
			WHERE cliente = TRIM(pCteTit)
			AND cod_docto = cCodigoDig
			AND secuencia = cSecActual;
		END IF;

		--DG_EXPEDIENTE_IMG_HIS
		--SELECT NVL(COUNT(*),0) INTO iExiste FROM "informix".dg_expediente_img_his WHERE cliente = TRIM(pCteTit);
		SELECT NVL(COUNT(*),0) INTO iExiste FROM bdidigital@coppelimghis_tcp:"informix".dg_expediente_img_his WHERE cliente = TRIM(pCteTit);
		IF iExiste > 0 THEN
			LET cDescErr = 'dg_expediente_img_his';
			LET cTabla2 = 'dg_expediente_img_his';
			--UPDATE "informix".dg_expediente_img_his SET cliente = TRIM(cNumcteInco), secuencia = TRIM(cSecuencia)
			UPDATE bdidigital@coppelimghis_tcp:"informix".dg_expediente_img_his SET cliente = TRIM(cNumcteInco), secuencia = TRIM(cSecuencia)
			WHERE cliente = TRIM(pCteTit)
			AND cod_docto = cCodigoDig
			AND secuencia = cSecActual;
		END IF;


	ELIF pIdentificador = '2' THEN

		LET cBandVal = '1';
		LET iIni = 1;

		LET cNumcteInco = '';
		LET cCuenta = '';
		LET cProducto = '';
		LET cCodigoDig = '';
		LET cSecuencia = '';
		LET iFin = 0;

		--SE EXTRAE EL NUMERO DE CLIENTE INCORRECTO DE LA TRAMA.
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cNumcteInco = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - 1));
				LET iIni = iFin + 1;
			END IF;
		END WHILE

		LET cBandVal = '1';

		--SE EXTRAE EL NUMERO DE CUENTA DE LA TRAMA.
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cCuenta = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - iIni));
				LET iIni = iFin + 1 ;
			END IF;
		END WHILE

		LET cBandVal = '1';

		--SE EXTRAE EL PRODUCTO DE LA TRAMA.
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cProducto = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - iIni));
				LET iIni = iFin + 1;
			END IF;
		END WHILE

		LET cBandVal = '1';

		--SE EXTRAE EL CODIGO DE DIGITALIZACION.
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cCodigoDig = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - iIni));
				LET iIni = iFin + 1;
			END IF;
		END WHILE

		LET cBandVal = '1';

		--SE EXTRAE SECUENCIA  DE LA TRAMA
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cSecuencia = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - iIni));
				LET iIni = iFin + 1;
			END IF;
		END WHILE

		---DG_EXPEDIENTE
		SELECT NVL(COUNT(*),0) INTO iExiste FROM bdidigital@coppelimg_tcp:"informix".dg_expediente WHERE cliente = TRIM(pCteTit);
		IF iExiste > 0 THEN
			LET cDescErr = 'dg_expediente';
			LET cTabla = 'dg_expediente';
			INSERT INTO bdidigital@coppelimg_tcp:"informix".dg_expediente (empresa, cliente, cuenta, producto, cod_docto, secuencia, prod_nombre, descrip2, usuario_alta, fecha_alta, usuario_modif, fecha_modif)
			SELECT empresa, cliente, cuenta, producto, cod_docto, secuencia, prod_nombre, descrip2, usuario_alta, fecha_alta, usuario_modif, fecha_modif 
			FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_fus
			WHERE cliente = TRIM(cNumcteInco)
			AND cod_docto = cCodigoDig
			AND secuencia = cSecuencia;
		END IF;

		----dg_expediente_img1
		SELECT NVL(COUNT(*),0) INTO iExiste FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img1 WHERE cliente = TRIM(pCteTit);
		IF iExiste > 0 THEN
			LET cDescErr = 'dg_expediente_img1';
			LET cTabla1 = 'dg_expediente_img1';
			INSERT INTO bdidigital@coppelimg_tcp:"informix".dg_expediente_img1 (empresa, cliente, cod_docto, secuencia, imagen,	imagen_formato, observaciones, usuario_alta, fecha_alta, usuario_modif, fecha_modif)
			SELECT {+INDEX ("informix".dg_expediente_img1_fus idx_expediente_img_fus)} empresa, cliente, cod_docto, secuencia, imagen, imagen_formato, observaciones, usuario_alta, fecha_alta, usuario_modif, fecha_modif 
			FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img1_fus
			WHERE cliente = TRIM(cNumcteInco)
			AND cod_docto = cCodigoDig
			AND secuencia = cSecuencia;
		END IF;
		
		--DG_EXPEDIENTE_IMG
		SELECT NVL(COUNT(*),0) INTO iExiste FROM bdidigital@coppelimghis_tcp:"informix".dg_expediente_img WHERE cliente = TRIM(pCteTit);
		IF iExiste > 0 THEN
		
			SELECT COUNT (*)
			INTO iExiste 
			FROM bdidigital@coppelimg_tcp:dg_expediente_img_fus WHERE cliente = cNumcteInco; 
			
			IF iExiste >= 1 THEN
				LET cDescErr = 'dg_expediente_img';
				LET cTabla2 = 'dg_expediente_img';
				LET v_nomarch=TRIM(cNumcteInco)||'.unl';
				CALL bdidigital@coppelimg_tcp:sp_respalda_imgfus(cNumcteInco,v_nomarch,v_ruta) RETURNING vc_CodRet,cCodret,cDescErr;
				IF vc_CodRet="00000" THEN
					CALL bdidigital@coppelimghis_tcp:sp_carga_imgfus(cNumcteInco,v_nomarch,v_ruta) RETURNING vc_CodRet,cCodret,cDescErr;
				END IF;
			END IF;
		END IF;
		
		
		----DG_EXPEDIENTE_IMG_HIS
		--SELECT NVL(COUNT(*),0) INTO iExiste FROM "informix".dg_expediente_img_his WHERE cliente = TRIM(pCteTit);
		SELECT NVL(COUNT(*),0) INTO iExiste FROM bdidigital@coppelimghis_tcp:"informix".dg_expediente_img_his WHERE cliente = TRIM(pCteTit);
		IF iExiste > 0 THEN
		
			SELECT COUNT (*)
			INTO iExiste 
			FROM bdidigital@coppelimg_tcp:dg_expediente_img_fus_his WHERE cliente = cNumcteInco; 
		
			IF iExiste >= 1 THEN
				LET cDescErr = 'dg_expediente_img_his';
				LET cTabla2 = 'dg_expediente_img_his';
				LET v_nomarch=TRIM(cNumcteInco)||'.unl';
				CALL bdidigital@coppelimg_tcp:sp_respalda_imgfus_his(cNumcteInco,v_nomarch,v_ruta) RETURNING vc_CodRet,cCodret,cDescErr;
				IF vc_CodRet="00000" THEN
					CALL bdidigital@coppelimghis_tcp:sp_carga_imgfus_his(cNumcteInco,v_nomarch,v_ruta) RETURNING vc_CodRet,cCodret,cDescErr;
				END IF;
			END IF;
		END IF;

	END IF

	RETURN NVL(TRIM(cCodret),''), cDescErr, cTabla, cTabla1, cTabla2;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: ',
'FECHA: 16/01/2014',
'BASE DE DATOS: bdinteg OLTP',
'Sustento: Desfusion de Clientes v1.4.doc',
'CREADOR:Vazquez Herrera Hugo ',
'VERSION:1043 ',
'RQI64093',
'FECHA: 20/05/2015',
'Se agrega filtro por campo secuencia al realizar las consultas por las tablas dg_expediente_fus, dg_expediente_img_fus y dg_expediente_img_fus_his',
'para que inserte la informaciÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³n en las tablas dg_expediente, dg_expediente_img1 y dg_expediente_img_his',
'Autor: Rocio MÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ¡rquez',
'---------------------',
'SUSTENTA: RQI 64 127',
'FECHA: 09/11/2015',
'MODIFICACIÃÂÃÂÃÂÃÂ?N: Se modifica para especificar instancia de imagenes correcta de acuerdo al tipo de imagen (historica o actual)',
'NOTA: Este SP se debe instalar en la instancia PRIMARIA de imagenes',
'----------------------------------------------',
'SUSTENTA: RQI 64 132',
'FECHA: 08/12/2015',
'AUTOR: Brenda Kareli Camargo Preciado',
'MODIFICACION: La modificacion consiste en tomar en cuenta la tabla: dg_expediente_img';

CREATE PROCEDURE "informix".sp_altas_idbox2_totales_exp3(
                                        pFechIni DATE, 
                                        pFechFin DATE,
                                        pUsuario CHAR(8))
        
		RETURNING  INTEGER as CodErr, 
		INTEGER as total_registros;
        
        DEFINE iSqlErr 			INTEGER;
        DEFINE  i_NoRegistros   INTEGER;
        
        LEt iSqlErr          = 0;
        LET i_NoRegistros    = 0;

        BEGIN
			ON EXCEPTION SET iSqlErr
				IF iSqlErr <> 0 THEN
					RETURN iSqlErr, i_NoRegistros;          
				END IF;
			END EXCEPTION;                                                                         
			
			-- TOTAL DE ALTAS CON IDBOX
			SET ISOLATION TO DIRTY READ;
			INSERT INTO bdicnweb:"informix".sw_tmp_idbx 
			SELECT {+INDEX (bdinteg:"informix".si_sucursales idx_sucursal2)} 0, a.sucursal, nvl(c.total,0) as Altas_Total, nvl(b.total,0) as Tot_Idb, pUsuario as usuario
			FROM "informix".si_sucursales a
			LEFT JOIN(  --OBTENIENDO TODOS LOS CLIENTES TITULARES DE LA TABLA DE SI_CLIENTE EN UN RANGO DE FECHAS
						SELECT clientes.sucursal AS sucursal, count(DISTINCT(clientes.numcte)) AS total FROM 
								(SELECT distinct (si_cliente.numcte), sucursal 
								FROM "informix".si_cliente   
                                    INNER JOIN "informix".si_ctepf si_ctepf 
                                            ON si_cliente.numcte = si_ctepf.numcte  
								WHERE tipo_cliente='1' AND si_cliente.fecha_insert BETWEEN pFechIni AND pFechFin ) clientes
						INNER JOIN
						-- OBTENIENDO LOS DATOS DE LA BITACORA DE IDBOX
								(SELECT numcte, sucursal 
								FROM "informix".si_bitacora_ife
								WHERE date(fecha) BETWEEN pFechIni AND pFechFin AND modelo_ife<>'') bitacora
						ON clientes.numcte=bitacora.numcte AND clientes.sucursal=bitacora.sucursal
						GROUP BY clientes.sucursal
					) b ON a.sucursal=b.sucursal
			LEFT JOIN ( --OBTENIENDO ALTAS POR SUCURSAL
						SELECT sucursal, COUNT(DISTINCT (si_cliente.numcte)) AS total
						FROM "informix".si_cliente
                        INNER JOIN "informix".si_ctepf si_ctepf 
                                ON si_cliente.numcte = si_ctepf.numcte  
						WHERE tipo_cliente='1' AND si_cliente.fecha_insert BETWEEN pFechIni AND pFechFin
						GROUP BY sucursal
					)C ON a.sucursal=C.sucursal
			WHERE a.empresa ='001'
			AND a.sucursal IN (SELECT DISTINCT(sucursal) FROM "informix".si_bitacora_ife);                                

			SET ISOLATION TO DIRTY READ;
			
			SELECT COUNT(*) 
			INTO i_NoRegistros
			FROM bdicnweb:"informix".sw_tmp_idbx 
			WHERE usuario=pUsuario;                                                                  
	
			RETURN iSqlErr, i_NoRegistros;                                          
		END
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 20/10/2016',
'DESCRIPCION: Se realizo la modificacion para insertar datos a tabla fisica',
'BD: bdinteg',
'AUTOR: Luis Ignacio PÃ©rez Cano',
'FECHA: 13/07/2017',
'DESCRIPCION: Se ajusta la consulta agregando INNER JOIN con la tabla si_ctepf y la condiciÃ³n modelo_ife<>''',
'se elimina ademas la condiciÃ³n sucursal=S',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_sorteobancoppel(p_canal INT,
												p_tpoper INT,
												p_producto INT,
												p_numcte CHAR(9),
												p_sucursal CHAR(4),
												p_foliosuc CHAR(16),
												p_importe MONEY(16,2),
												p_fecha DATE)
RETURNING CHAR(6) AS cod_Ret,CHAR(80) AS mensaje,INTEGER AS rango_ini,INTEGER AS rango_fin;

DEFINE  SQL_ERR			INTEGER;
DEFINE  ISAM_ERR		INTEGER;
DEFINE  ERROR_INFO		VARCHAR(80);
DEFINE  P_COD_RET		VARCHAR(6);
DEFINE  P_MENSAJE		VARCHAR(80);
DEFINE  v_RangoIni		INTEGER;
DEFINE  v_RangoFin		INTEGER;
DEFINE  v_cvesorteo		VARCHAR(6);
DEFINE  v_part1			INTEGER;
DEFINE  v_part2			INTEGER;
DEFINE  v_part3			INTEGER;
DEFINE  v_part4			INTEGER;
DEFINE  v_numbol		INTEGER;
DEFINE  v_persona		INTEGER;
DEFINE  ciclo			INTEGER;
DEFINE  boleto			INTEGER;
DEFINE  boleto_ini		INTEGER;  	 --FMV 24-AGO-10
DEFINE  boleto_fin		INTEGER;
DEFINE v_cltemoral		VARCHAR(10); --FMV 25-AGO-10
DEFINE v_param			CHAR(5);  	 --BGM 14-Sep: se incorpora uso de parÃ¡metro para traer clave de sorteo normal 2010.
DEFINE Vnumcte			CHAR(10);    --RRG
DEFINE Vtpo_persona		CHAR(2);     --RRG
--dsb-10/10/2012
DEFINE cFolio			CHAR(16);
DEFINE cFolio_cupon		CHAR(20);
DEFINE cTicket			CHAR(2);
DEFINE cFecha			CHAR(19);
DEFINE vNumcteParticipa	INTEGER;     --IREB 26-JUL-19 CAMBIO DE TIPO DE CHAR(20) A INTEGER PARA EL CAMBIO DE LA CONSULTA
DEFINE vProd 			INTEGER;

--*********************************************************--

-- Modificado por: Francisco Martinez Viveros	
-- Fecha Modifica: 24/SEPTIEMBRE/2010 
-- Objetivo: Asignacion del Rango de boletos por transaccion mayor a $650
-- MODIFICADO POR: RaÃºl RamÃ­rez Galindo
-- Fecha ModificaciÃ³n: 05/Diciembre/2011
-- Objetivo:Agilizar la Consulta en Corresponsales.

--*********************************************************--

LET P_COD_RET 		 = '00000';
LET P_MENSAJE 		 = 'PROCESO EXITOSO';
LET v_RangoIni 		 = 0;
LET v_RangoFin 		 = 0;
LET v_part1 		 = 0;
LET v_part2			 = 0;
LET v_part3			 = 0;
LET v_part4			 = 0;
LET v_persona		 = 1;  --FMV 18-AGO-10: Todas los clientes son fisicos 01, se controla a los morales en si_cltenoparticipa
LET v_cvesorteo		 = '';
LET SQL_ERR          = 0;
LET ISAM_ERR         = 0;
LET ERROR_INFO       = '';
LET v_numbol         = 0;
LET ciclo            = 1;
LET boleto           = 0;
LET boleto_ini       = 0;  	--FMV 24-AGO-10
LET boleto_fin       = 0;
LET v_cltemoral      = ''; 	--FMV 25-AGO-10
LET Vnumcte          = '';  --RRG
LET Vtpo_persona     = '';  --RRG
--dsb-10/10/2012
LET cFolio			 = '';
LET cFolio_cupon	 = '';
LET cTicket			 = '';
LET cFecha			 = YEAR(p_fecha)||'-'||MONTH(p_fecha)||"-"||DAY(p_fecha)||" "||CURRENT HOUR TO SECOND;
LET vNumcteParticipa = 0;
LET vProd			 = 0;


BEGIN

	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		LET P_COD_RET    = SQL_ERR;
		LET P_MENSAJE  = ERROR_INFO;
		RETURN P_COD_RET, P_MENSAJE,v_RangoIni,v_RangoFin;
	END EXCEPTION;

  --SET DEBUG FILE TO "/home/JA/JA-Sorteo-Clases-2013/sorteobancoppel.out";
  --TRACE ON;   

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

	-- BGM 14-Sep: se incorpora uso de parÃ¡metro para traer clave de sorteo normal 2010.
	SELECT valor INTO v_param 
	FROM bdinteg:"informix".si_param
	WHERE cod_param = 118;

-- jom	FOREACH
	SELECT {+INDEX (si_sorteo idx_si_sorteo)}
	cve_sorteo
	INTO v_cvesorteo
	FROM bdinteg:"informix".si_sorteo
	WHERE  p_fecha  BETWEEN f_ini AND f_fin
	AND cve_sorteo = v_param; 	-- BGM 14-Sep: se incorpora uso de parÃ¡metro para traer clave de sorteo normal 2010.

	IF v_cvesorteo = '' OR v_cvesorteo IS NULL THEN
		LET P_COD_RET = '116';   -- FMV 24sep10 Se adiciona codigo
		LET P_MENSAJE = 'NO EXISTE SORTEOS ACTIVOS EN ESTA FECHA';
	ELSE                
		IF p_tpoper = 12 THEN  
			LET v_persona = 1;
			LET p_producto = 9999;
		ELSE
				----- SE MODIFICA PARA AGILIZAR LA CONSULTA EN CORRESPONSALES
			   SELECT {+INDEX (si_cltenoparticipa idx_si_cltenoparticipa)}numcte, tpo_persona
				 INTO Vnumcte, Vtpo_persona
				 FROM bdinteg:"informix".si_cltenoparticipa 
				WHERE numcte = p_numcte;
					
				IF Vnumcte <> '' THEN
				   IF Vnumcte IS NOT NULL THEN						
					  LET v_persona  = 0;                      
					  LET v_cltemoral = p_numcte;
				   END IF;
			   END IF;
		END IF;
		
		IF (p_tpoper = 10 OR  p_tpoper = 11) AND v_cltemoral = p_numcte
										  THEN -- FMV 19-AGO-10: SE ADICIONA CANDADO
			LET v_persona = 0;                                     
		END IF;
		IF (p_tpoper = 10 OR  p_tpoper = 11) AND v_cltemoral <> p_numcte
										  THEN -- FMV 19-AGO-10: SE ADICIONA CANDADO
			LET v_persona = 1;                                     
		END IF;
		
		SELECT {+INDEX (si_participa idx_si_participa)}
		SUM(CASE WHEN tipo_participa = '1' AND id_elemento = p_producto THEN 1 ELSE 0 END) prod,
		SUM(CASE WHEN tipo_participa = '2' AND id_elemento = p_tpoper THEN 1 ELSE 0 END) trans,
		SUM(CASE WHEN tipo_participa = '3' AND id_elemento = p_canal THEN 1 ELSE 0 END) canal,
		SUM(CASE WHEN tipo_participa = '4' AND id_elemento = v_persona THEN 1 ELSE 0 END) tpo_per,
		SUM(CASE WHEN tipo_participa = '2' AND id_elemento = p_tpoper  THEN (p_importe / val_min)::INT  ELSE 0 END) numbol
		--SUM(CASE WHEN tipo_participa = '2' AND id_elemento = p_tpoper AND p_importe  >= val_min THEN 1 ELSE 0 END) numbol --cumple con el minimo para entregarle boleto
		INTO v_part1,v_part2,v_part3,v_part4,v_numbol
		FROM bdinteg:"informix".si_participa
		WHERE cve_sorteo = v_cvesorteo;

		IF v_part1 = 1 AND v_part2 = 1 AND v_part3 = 1 AND v_part4 = 1 AND v_numbol > 0 THEN
			
			----- SE AGREGA PARA CONSULTAR EN TABLA DE CLIENTES Y EMPLEADOS.
			
			
			--SELECT {+INDEX (bdinteg:"informix".si_empleado_cliente_coppel idx_cte_emp2)} numcte
			--INTO vNumcteParticipa
			--FROM bdinteg:"informix".si_empleado_cliente_coppel
			--WHERE numcte = p_numcte
			--AND status = '1';
			
			--IF vNumcteParticipa <> '' OR vNumcteParticipa IS NOT NULL THEN
			
			
			SELECT COUNT(numcte)
			INTO vNumcteParticipa
			FROM bdinteg:"informix".si_empleado_cliente_coppel
			WHERE numcte = p_numcte
			AND status = '1';
			
			IF vNumcteParticipa > '0' THEN
				LET P_MENSAJE  = 'CLIENTE NO PARTICIPA';
			ELSE			
				-- SORTEO DF 
				
				
				SELECT COUNT(producto)
				INTO vProd
				FROM bdicheq:"informix".sc_maechq 
				WHERE num_cte = p_numcte AND producto = '1300' AND empresa = '001';
				
				IF vProd > 0 THEN 
				--IF EXISTS(SELECT producto FROM bdicheq:"informix".sc_maechq WHERE num_cte = p_numcte AND producto = '1300' AND empresa = '001') THEN
					--'ES EMPLEADO';
				ELSE
					--PIDE BOLETOS
					EXECUTE PROCEDURE bdinteg:"informix".sp_asigna_boletos(v_cvesorteo, v_numbol, p_fecha)
					INTO P_COD_RET,P_MENSAJE, v_RangoIni, v_RangoFin;

					/*--INSERTA BOLETOS*/
					IF P_COD_RET = '00000' THEN
						--LET boleto_ini = v_RangoIni;
						--LET boleto_fin = v_RangoFin;
						--for   FMV: 24-AGO-10
							LET boleto_ini = v_RangoIni;  
							LET boleto_fin = v_RangoFin;
						INSERT INTO {+INDEX (si_boleto idx_si_boleto_cte)}
						bdinteg:"informix".si_boleto VALUES(v_cvesorteo,boleto_ini, boleto_fin, CURRENT,p_numcte,'2',p_sucursal,'B','1',p_tpoper,
						p_foliosuc,p_importe,'','','','','',p_fecha,'0200000',ciclo, '');
						  --  LET ciclo = ciclo + 1; FMV:31-AGO-10
						--END for; FMV: 24-AGO-10

						--dsb-10/10/2012
						--Se manda a llamar sp_premios_instantaneos en caso de canal = 4
						IF p_canal = 4 THEN
							--MARCAR LOS BOLETOS EN CASO DE QUE HAYA
							EXECUTE PROCEDURE bdinteg:"informix".sp_premios_instantaneos(p_canal, p_tpoper, p_producto,p_numcte,p_sucursal, p_foliosuc, p_importe, cFecha,boleto_ini,boleto_fin)
							INTO P_COD_RET, cFolio, cFolio_cupon, cTicket;
							LET P_COD_RET = '00000';
						END IF
					ELSE
						LET v_RangoIni = 0;
						LET v_RangoFin = 0;
						LET ciclo = 1;
						LET P_COD_RET = '00000';
					END IF;
				END IF;
			END IF;
		ELSE
			LET v_RangoIni = 0;
			LET v_RangoFin = 0;
			LET P_COD_RET = '117';  -- FMV 24sep10 Se adiciona codigo
			LET P_MENSAJE = 'NO CUMPLE CON PARAMETROS';
		END IF;
	END IF;
	
		RETURN P_COD_RET, P_MENSAJE, v_RangoIni, v_RangoFin;
	
--jom	END FOREACH;

END;
END PROCEDURE
DOCUMENT
'Modifico: Victor Hugo NuÃ±ez',
'FECHA: 10/10/2012',
'Modificacion: Se agrega llamado a sp_premios_instantaneos para marcar los boletos si viene desde corresponsales',
'Objetivo: Sorteo Instantaneo Navidad Millonaria',
'MODIFICO: JOSE ANGEL GAXIOLA GAXIOLA',
'FECHA: 10/07/2013',
'Modificacion: Se agraga condicion para que valide y solo entregue un boleto del sorteo si el importe de la transaccion es mayor o igual a 650.',
'BD: bdinteg',
'Autor: 94565457',
'Fecha: 03/10/2013',
'ModificaciÃ³n: Se adecua sp agregando condicion para que se entreguen rangos de boletos por cada 650 pesos, tambien se agrego validacion para verificar  ', 
'              si el cliente es empleado(Que se encuentre en la tabla:si_empleado_cliente_coppel).',
'              si se cumple dicha condicion no se le asigna boleto para el sorteo. ',
'Sustento:    ',
'Solicita: Israel Flores GonzÃ¡lez',
'Autor: IREB',
'Fecha: 26/07/2019',
'ModificaciÃ³n: Se realiza el ajuste de la consulta de la tabla de empleados',
'BD: BDINTEG';

CREATE PROCEDURE "informix".valor_divisa_pesos(pEmpresa CHAR(3), pFecha   DATE, tipo_div char(2), vClaseDiv CHAR(1),vTipoCons CHAR(1))
RETURNING CHAR(5), DECIMAL(14,6);


   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret       CHAR(5);
   DEFINE sql_err       SMALLINT;
   DEFINE isam_err      SMALLINT;
   DEFINE error_info    CHAR(40);
   DEFINE vValor1	    DECIMAL(14,6);
   DEFINE vDivisaCorr   INTEGER;
   DEFINE vMaxFecha     DATE;
 
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret, vValor1;
   END EXCEPTION;

-- SET DEBUG FILE TO "valor_udi.out";
-- TRACE ON;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET cod_ret    = "00000";
   LET vValor1	  = 0;
   LET vDivisaCorr= 0;



-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

      -- ******************************************
      --   Valida Parametro de Codigo de Divisa   *
      -- ******************************************
      SELECT count(*) 
        INTO vDivisaCorr
	    FROM bdinteg:si_divisas
       WHERE empresa = pEmpresa
	     AND divisa = tipo_div;

        IF vDivisaCorr=0 THEN
           LET cod_ret = "901";
           RETURN cod_ret, vValor1;
        END IF;

      -- *****************************************
      --      Valida Clase de Tipo de Cmabio     *
      -- *****************************************

      SELECT count(*) 
        INTO vDivisaCorr
	    FROM bdinteg:si_clase_tc
       WHERE clase_tpcambio = vClaseDiv;

        IF vDivisaCorr=0 THEN
           LET cod_ret = "902";
           RETURN cod_ret, vValor1;
        END IF;


      -- **************
      -- Precio Inicio*
      -- **************

      
      SELECT precio_compra INTO vValor1
       	FROM bdinteg:si_tpcambio
        WHERE empresa = pEmpresa
       	 AND divisa = tipo_div
       	 AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
               	                 FROM bdinteg:si_tpcambio
                       	        WHERE empresa = pEmpresa
                       	   	      AND divisa = tipo_div
                                  AND fecha_tpcambio = pFecha
								  AND clase_tpcambio = vClaseDiv)
         AND hora_tpcambio=(SELECT MAX(hora_tpcambio)
               	                 FROM bdinteg:si_tpcambio
                       	        WHERE empresa = pEmpresa
                       	   	  AND divisa = tipo_div
                              AND fecha_tpcambio = pFecha
							  AND clase_tpcambio = vClaseDiv)
         AND clase_tpcambio = vClaseDiv;

	  IF vValor1 IS NULL and vTipoCons<>'1' THEN
		SELECT precio_compra INTO vValor1
		  FROM bdinteg:si_histdiv
		 WHERE empresa = pEmpresa
		   AND divisa = tipo_div
		   AND fecha_tc = pFecha
		   AND hora_tc =(SELECT MAX(hora_tc)
					       FROM bdinteg:si_histdiv
						  WHERE empresa = pEmpresa
							AND divisa = tipo_div
							AND fecha_tc = pFecha
							AND clase_tpcambio = vClaseDiv)                 
		AND clase_tpcambio = vClaseDiv;

		IF vValor1 IS NULL THEN
			LET cod_ret = "900";
			RETURN cod_ret, vValor1;
		END IF;
      END IF;

      IF vValor1 IS NULL and vTipoCons='1' THEN
		SELECT MAX(fecha_tc)
		  INTO vMaxFecha
		  FROM bdinteg:si_histdiv
		 WHERE empresa = pEmpresa
		   AND divisa = tipo_div
		   AND fecha_tc <= pFecha
		   AND clase_tpcambio = vClaseDiv;

	    SELECT precio_compra INTO vValor1
		  FROM bdinteg:si_histdiv
		 WHERE empresa = pEmpresa
		   AND divisa = tipo_div
		   AND fecha_tc = vMaxFecha
		   AND hora_tc=(SELECT MAX(hora_tc)
			   		      FROM bdinteg:si_histdiv
					     WHERE empresa = pEmpresa
					       AND divisa = tipo_div
					       AND fecha_tc = vMaxFecha
					       AND clase_tpcambio = vClaseDiv)                 
		   AND clase_tpcambio = vClaseDiv;

		 IF vValor1 IS NULL THEN
			LET cod_ret = "900";
			RETURN cod_ret, vValor1;
		 END IF;
      END IF;
END
RETURN cod_ret, vValor1;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_cifra_archivo_chq_2( pCodigo CHAR(20) ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3	        CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr	        CHAR(150);
    DEFINE vUsuario         CHAR(20);
    DEFINE vLLave           CHAR(200);
    DEFINE vNomarch         CHAR(100);
    DEFINE vRutaOrigen      CHAR(100);
    DEFINE vRutaDestino     CHAR(100);
    DEFINE vNomarchSalida   CHAR(100);
    DEFINE vRutaOriginales  CHAR(100);
    DEFINE vNomarch_salida  CHAR(100);
    
    
    LET cCodRet         = '';
    LET cCodRet2        = 0;
    LET cCodRet3        = '';
    LET iSqlErr         = 0;
    LET iSamErr         = 0;
    LET cDesErr         = '';
    LET vUsuario        = '';
    LET vLLave          = '';
    LET vNomarch        = '';
    LET vRutaOrigen     = '';
    LET vRutaDestino    = '';
    LET vNomarchSalida  = '';
    LET vRutaOriginales = '';
    LET vNomarch_salida = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cifra_archivo_chq.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cifra_archivo_chq.out";
    TRACE ON;
    
    FOREACH
        SELECT TRIM(usuario), TRIM(llave), TRIM(nomarch), TRIM(ruta_origen), TRIM(nomarch_salida), TRIM(ruta_destino), TRIM(ruta_originales)
          INTO vUsuario, vLLave, vNomarch, vRutaOrigen, vNomarch_salida, vRutaDestino, vRutaOriginales    
          FROM bdinteg:si_configura_pgp_chq
         WHERE codigo = pCodigo
         ORDER BY secuencia
        
        IF vUsuario <> user THEN
            LET cCodRet = '200';
            RETURN cCodRet;
        END IF;
        
        SYSTEM 'echo "export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/'||TRIM(vUsuario)||'/bin:/usr/bin/X11:/sbin:.:/opt/pgp/bin:/informix/bin" > '||TRIM(vRutaOrigen)||'blinda_archivo.sh';
        SYSTEM 'echo "export HOME=/home/'||TRIM(vUsuario)||'" >> '||TRIM(vRutaOrigen)||'blinda_archivo.sh';
        SYSTEM 'echo "/opt/pgp/bin/pgp --encrypt -i '||TRIM(vRutaOrigen)||TRIM(vNomarch)||' -r '||''''||TRIM(vLLave)||''''||" --armor --compression --output "||TRIM(vRutaDestino)||TRIM(vNomarch_salida)||'" >> '||TRIM(vRutaOrigen)||'blinda_archivo.sh';
        SYSTEM '/usr/bin/chmod 777 '||TRIM(vRutaOrigen)||'blinda_archivo.sh';   
        SYSTEM '/usr/bin/sh '||TRIM(vRutaOrigen)||'blinda_archivo.sh';
        SYSTEM '/usr/bin/mv '||TRIM(vRutaOrigen)||TRIM(vNomarch)||' '||vRutaOriginales; 
    END FOREACH;
    
    LET cCodRet = '000';
    
    RETURN cCodRet;
    
    END;
    
END PROCEDURE;