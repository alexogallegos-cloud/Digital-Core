CREATE PROCEDURE "informix".sp_reporteupgrade (empresa varchar (3))
returning VARCHAR (5), VARCHAR(50);

    DEFINE iSqlErr          		INTEGER;
    DEFINE iIsamErr         		INTEGER;
    DEFINE cInfoErr					VARCHAR(100);
    DEFINE cCodret          		VARCHAR(5);
    DEFINE cMensRet         		VARCHAR(50);
    DEFINE cempresa					VARCHAR(3);
    DEFINE vfechainicio				VARCHAR(20);
    DEFINE vfechafin				VARCHAR(20);
    DEFINE vdiaactual				CHAR(6);
    DEFINE vTotalRegistros		    INTEGER;
    DEFINE vExecuteSQL LVARCHAR(8000);
    DEFINE RUTA_ORIGEN VARCHAR(80);

    LET iSqlErr					= 0;
    LET iIsamErr				= 0;
    LET cInfoErr 				= '';
    LET cCodret 				= '00000';
    LET cMensRet 				= 'Ejecucion sp_reporteupgrade exitosa.';
    LET vfechainicio			='';
    LET vfechaFIN   			='';
    LET vdiaactual				= '';
    LET vTotalRegistros		    = 0;
    LET vExecuteSQL = '';
    LET RUTA_ORIGEN = '/resplogifx/';
    
    --SET DEBUG FILE TO RUTA_ORIGEN || "sp_reporteupgrade.out";
    --TRACE ON;
    /*-----------------------------------------------------------------------------------------------------------------
			CALCULO DE FECHAS (MES ANTERIOR):
-----------------------------------------------------------------------------------------------------------------*/
		SET ISOLATION TO DIRTY READ;
        SELECT (extend(today, year to month) -1 units month)::date AS FECHAINICIO, --1
				(extend(today, year to month) -0 units month)::date -1 AS FECHA_FIN, --0
                TO_CHAR(today, '%Y%m') as dia_actual
		INTO vfechainicio,vfechafin, vdiaactual
		FROM systables 
		WHERE tabid = 1;

/*-----------------------------------------------------------------------------------------------------------------
			CONSTRUCCIÃN DE REPORTE
-----------------------------------------------------------------------------------------------------------------*/		    
        
        /*SELECT COUNT(*) 
            INTO vTotalRegistros
        FROM bdicred:sd_credito_upgrade up  
        WHERE up.fecha_insert::date  BETWEEN vfechainicio AND vfechafin
            AND up.numero_credito_upgrade <> '' 
            AND up.numerotarjeta_upgrade <> '' ;
        
        
        IF ( vTotalRegistros = 0 ) THEN
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'echo "Num_Credito(anterior)|Num_Tarjeta(anterior)|LineaCredito_Anterior|Num_Credito(nuevo)|Num_Tarjeta(nueva)|LineaCredito_Nueva|CodProdSegmento_Anterior|CodProdSegmento_Actual|">'||RUTA_ORIGEN||'creditos_'||vdiaactual||'.txt';            
            SYSTEM vExecuteSQL;            

            LET vExecuteSQL = '';
            LET vExecuteSQL = ' echo "UNLOAD TO '|| RUTA_ORIGEN ||'creditos_'||vdiaactual||'.unl '||
                   ' SELECT up.num_credito,up.numerotarjeta,'||
				   ' (SELECT ma.monto_otorgado FROM bdicred:sd_maesdos ma WHERE ma.num_credito=up.num_credito ) as LineaCredAnterior, '|| 
				   ' up.numero_credito_upgrade,up.numerotarjeta_upgrade, '||
                   ' (SELECT ma.monto_otorgado FROM bdicred:sd_maesdos ma WHERE ma.num_credito=up.numero_credito_upgrade ) as LineaCredNuevo, '||
                   ' (SELECT t.codproductotarjeta FROM intercard:tarjeta t WHERE t.numtarjeta=up.numerotarjeta) as CodProdAnt, '||
                   ' (SELECT t.codproductotarjeta FROM intercard:tarjeta t WHERE t.numtarjeta=up.numerotarjeta_upgrade) as CodProdNuevo '||
                   ' FROM bdicred:sd_credito_upgrade up  ' ||
                   ' WHERE up.fecha_insert::date BETWEEN '||"'"||vfechainicio||"'" || ' AND ' ||"'"||vfechafin||"'" ||                   
                   ' AND up.numero_credito_upgrade <> ' || "''" ||
                   ' AND up.numerotarjeta_upgrade <> '|| "''" ||' ;">'||RUTA_ORIGEN||'script_credito_upgrade.sql';                   
            SYSTEM vExecuteSQL;            
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'dbaccess intercard '||RUTA_ORIGEN||'script_credito_upgrade.sql';
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL = '';
            LET vExecuteSQL ='rm '||RUTA_ORIGEN||'script_credito_upgrade.sql';
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL ='';
            LET vExecuteSQL = "sed 's/|s//g' "||RUTA_ORIGEN||'creditos_'||vdiaactual||".unl >> "||RUTA_ORIGEN||'creditos_'||vdiaactual||'.txt';
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL ='rm '||RUTA_ORIGEN||'creditos_'||vdiaactual||'.unl';
            SYSTEM vExecuteSQL;
            
            RETURN cCodret,cMensRet;
        END IF;
        
        IF (vTotalRegistros >  0) THEN */
        
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'echo "Num_Credito(anterior)|Num_Tarjeta(anterior)|LineaCredito_Anterior|Num_Credito(nuevo)|Num_Tarjeta(nueva)|LineaCredito_Nueva|CodProdSegmento_Anterior|CodProdSegmento_Actual|">'||RUTA_ORIGEN||'Upgrade_'||vdiaactual||'.unl';            
            SYSTEM vExecuteSQL;            

            LET vExecuteSQL = '';
            LET vExecuteSQL = ' echo "UNLOAD TO '|| RUTA_ORIGEN ||'creditos_'||vdiaactual||'.unl '||
                   ' SELECT {+AVOID_FULL (bdicred:sd_credito_upgrade)} up.num_credito,up.numerotarjeta,'||
				   ' (SELECT ma.monto_otorgado FROM bdicred:sd_maesdos ma WHERE ma.num_credito=up.num_credito ) as LineaCredAnterior, '|| 
				   ' up.numero_credito_upgrade,up.numerotarjeta_upgrade, '||
                   ' (SELECT ma.monto_otorgado FROM bdicred:sd_maesdos ma WHERE ma.num_credito=up.numero_credito_upgrade ) as LineaCredNuevo, '||
                   ' (SELECT t.codproductotarjeta FROM intercard:tarjeta t WHERE t.numtarjeta=up.numerotarjeta) as CodProdAnt, '||
                   ' (SELECT t.codproductotarjeta FROM intercard:tarjeta t WHERE t.numtarjeta=up.numerotarjeta_upgrade) as CodProdNuevo '||
                   ' FROM bdicred:sd_credito_upgrade up  ' ||
                   ' WHERE up.fecha_insert::date BETWEEN '||"'"||vfechainicio||"'" || ' AND ' ||"'"||vfechafin||"'" ||                   
                   ' AND up.numero_credito_upgrade <> ' || "''" ||
                   ' AND up.numerotarjeta_upgrade <> '|| "''" ||' ;">'||RUTA_ORIGEN||'script_credito_upgrade.sql';                   
            SYSTEM vExecuteSQL;            
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'dbaccess intercard '||RUTA_ORIGEN||'script_credito_upgrade.sql';
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL = '';
            LET vExecuteSQL ='rm '||RUTA_ORIGEN||'script_credito_upgrade.sql';
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL ='';
            LET vExecuteSQL = "sed 's/|s//g' "||RUTA_ORIGEN||'creditos_'||vdiaactual||".unl >> "||RUTA_ORIGEN||'Upgrade_'||vdiaactual||'.unl';
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL ='rm '||RUTA_ORIGEN||'creditos_'||vdiaactual||'.unl';
            SYSTEM vExecuteSQL;
            
            RETURN cCodret,cMensRet;
        
      --  END IF;
        
END PROCEDURE;