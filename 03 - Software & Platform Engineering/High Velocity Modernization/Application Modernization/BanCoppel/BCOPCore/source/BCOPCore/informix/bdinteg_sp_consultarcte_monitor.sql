CREATE PROCEDURE "informix".sp_consultarcte_monitor(pEmpresa char (3), pNumero char(16), pTipo integer)
	returning char (5), char (9), char (26), char (26), char (26), char (26),char (16), char (16);

   --Elaboró: Javier A. Chávez T.
   --Actividad: consulta los datos de un cliente
   --Solicito: Mauricio León
   --Fecha: 25-03-09
   --BD:bdinteg
   ---------------------------------------------
   --Modificado: Manuel Osuna Valencia
   --Actividad: Presentar la ultima tarjeta del Titular
   --Solicito: Ismael Hernandez
   --Fecha: 15-07-2009
   --BD:bdinteg
   ---------------------------------------------
   --Modificado: Jose Ruben Lopez
   --Actividad: Buscar por num credito que no tenga tarjeta
   --Solicito: Jose de Jesus Nevarez
   --Fecha:24-09-2013
   --BD:bdinteg
   ---------------------------------------------
   --Modificado: José de Jesús Nevarez
   --Actividad: Se agrega búsqueda por número de cliente para los créditos que no tienen tarjeta.
   --Solicito: Abrham Lopez.
   --Fecha:17-02-2014
   --BD:bdinteg
   
   --DEFINE
    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
	DEFINE vNomCte1 char (26);
	DEFINE vNomCte2 char (26);
	DEFINE vApe_pat char (26);
	DEFINE vApe_mat char (26);
	DEFINE vNumCte char(9);
	DEFINE vNumTarjeta char (16);
	DEFINE vNumCredito char (16);

	--Inicializa
	LET cod_ret  = "004";
	LET vNomCte1 = "";
	LET vNumCte = "0";
	LET vNumTarjeta = "0";
	LET vNumCredito = "0";
	LET vNomCte2 = "";
	LET vApe_pat = "";
	LET vApe_mat = "";

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vNumcte, vNomCte1, vNomCte2, vApe_pat, vApe_mat, vNumCredito, vNumTarjeta;
      END IF ;
   END EXCEPTION ;
   
   --SET DEBUG FILE TO "/tmp/sp_consultarcte_monitor.out";                      --*
   --TRACE ON;       

    SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ ;

	IF (TRIM(pNumero) <> "" and pTipo = 1) THEN  --Por Número de Cliente
			IF EXISTS (SELECT numcte FROM bdinteg:"informix".si_cliente WHERE numcte = pNumero and empresa = pEmpresa)THEN
				SELECT a.nombre1, a.nombre2, a.apell_paterno, a.apell_materno, ta.num_credito, ta.num_tarjeta	
				INTO vNomCte1, vNomCte2, vApe_pat, vApe_mat,vNumCredito,vNumTarjeta
				FROM bdinteg:"informix".si_cliente a,
					 table( multiset( select num_tarjeta,num_credito from bdicred:"informix".sd_tarjeta where  numcte = pNumero and empresa = pEmpresa 
									  and  tipo_tarjeta = 'T' and secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta  
						              where numcte = pNumero and  tipo_tarjeta = 'T' and empresa = pEmpresa )
					               )) as  ta
                WHERE a.numcte = pNumero AND a.empresa = pEmpresa;

				
				IF(vNomCte1 <> "") THEN
					LET vNumCte = pNumero;
					LET cod_ret = "000";

				ELIF EXISTS (SELECT num_credito FROM bdicred:"informix".sd_maecredcrd WHERE numcte=pNumero)THEN
						SELECT a.nombre1, a.nombre2, a.apell_paterno, a.apell_materno, ta.num_credito,ta.numcte	
						INTO vNomCte1, vNomCte2, vApe_pat, vApe_mat,vNumCredito,vNumCte				
						FROM bdinteg:"informix".si_cliente a INNER JOIN bdicred:"informix".sd_maecredcrd ta ON a.numcte = ta.numcte
						WHERE ta.numcte =pNumero AND a.empresa = pEmpresa;
						
						IF(vNomCte1 <> "") THEN
							LET vNumCte = pNumero;
							LET cod_ret = "000";
						ELSE
							LET cod_ret = '004';
						END IF;
				END IF;
			
			ELSE
				LET cod_ret = "001"; -- No existe el cliente

			END IF;

	ELIF (TRIM(pNumero) <> "" AND pTipo = 2) THEN --Por Número de Crédito
			IF EXISTS (SELECT num_credito FROM bdicred:"informix".sd_tarjeta WHERE num_credito = pNumero and empresa = pEmpresa) THEN				
				SELECT a.nombre1, a.nombre2, a.apell_paterno, a.apell_materno, ta.num_credito, ta.num_tarjeta,ta.numcte	
				INTO vNomCte1, vNomCte2, vApe_pat, vApe_mat,vNumCredito,vNumTarjeta,vNumCte				
				FROM bdinteg:"informix".si_cliente a,
					table( multiset( select num_tarjeta,num_credito,numcte  from bdicred:"informix".sd_tarjeta where  num_credito =  pNumero 
									 and empresa = pEmpresa and  tipo_tarjeta = 'T'
			                         and secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta  where num_credito =  pNumero 
									 and  tipo_tarjeta = 'T' and empresa = pEmpresa )
								   )) as  ta
			    WHERE a.numcte = ta.numcte AND a.empresa = '001';

				IF(vNomCte1 <> "") THEN
					LET vNumCredito = pNumero;
					LET cod_ret = "000";
				ELSE
					LET cod_ret = '004';
				END IF;

			ELSE
				IF EXISTS (SELECT num_credito FROM bdicred:"informix".sd_maecredcrd WHERE num_credito=pNumero)THEN
					SELECT a.nombre1, a.nombre2, a.apell_paterno, a.apell_materno, ta.num_credito,ta.numcte	
					INTO vNomCte1, vNomCte2, vApe_pat, vApe_mat,vNumCredito,vNumCte				
					FROM bdinteg:"informix".si_cliente a INNER JOIN bdicred:"informix".sd_maecredcrd ta ON a.numcte = ta.numcte
					WHERE ta.num_credito =pNumero AND a.empresa = '001';
					
					IF(vNomCte1 <> "") THEN
						LET vNumCredito = pNumero;
						LET cod_ret = "000";
					ELSE
						LET cod_ret = '004';
					END IF;
				ELSE
					LET cod_ret = "002";	
				END IF;
			END IF;
	ELIF (TRIM(pNumero) <> "" AND pTipo = 3) THEN --  --Por Número de Tarjeta
			IF EXISTS (SELECT num_tarjeta FROM bdicred:"informix".sd_tarjeta WHERE num_tarjeta = pNumero and empresa = pEmpresa) THEN
				SELECT numcte,num_credito INTO vNumCte, vNumCredito FROM bdicred:"informix".sd_tarjeta where num_tarjeta = pNumero and empresa = pEmpresa;
				select nombre1, nombre2, apell_paterno, apell_materno INTO vNomCte1, vNomCte2, vApe_pat, vApe_mat
				from  bdinteg:"informix".si_cliente where numcte = vNumCte and empresa = pEmpresa;

				IF(vNomCte1 <> "") THEN
					LET vNumTarjeta = pNumero;
					LET cod_ret = "000";
				ELSE
					LET cod_ret = '004';
				END IF

			ELSE
				LET cod_ret = "003";
			END IF
	ELIF (TRIM(pNumero) == "")THEN
				LET cod_ret = "005";
	END IF;
  
   RETURN cod_ret, vNumcte, vNomCte1, vNomCte2, vApe_pat, vApe_mat, vNumCredito, vNumTarjeta;
   
END

END PROCEDURE;