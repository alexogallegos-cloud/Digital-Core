CREATE FUNCTION "informix".fn_formateo_chqcajas(pcadena lvarchar)
RETURNING lvarchar AS cadena;
  DEFINE cadena lvarchar;
  LET cadena = UPPER(TRIM(pcadena));
  
  LET cadena =  REPLACE(cadena, 'Á', 'A');
  LET cadena =  REPLACE(cadena, 'É', 'E');
  LET cadena =  REPLACE(cadena, 'Í', 'I');
  LET cadena =  REPLACE(cadena, 'Ó', 'O');
  LET cadena =  REPLACE(cadena, 'Ú', 'U');
  LET cadena =  REPLACE(cadena, 'Ñ', 'N');
  LET cadena =  REPLACE(cadena, 'À', 'A');
  LET cadena =  REPLACE(cadena, 'È', 'E');
  LET cadena =  REPLACE(cadena, 'Ì', 'I');
  LET cadena =  REPLACE(cadena, 'Ò', 'O');
  LET cadena =  REPLACE(cadena, 'Ù', 'U');
  LET cadena =  REPLACE(cadena, 'Ç', 'C');

  LET cadena =  REPLACE(cadena, 'á', 'A');
  LET cadena =  REPLACE(cadena, 'é', 'E');
  LET cadena =  REPLACE(cadena, 'í', 'I');
  LET cadena =  REPLACE(cadena, 'ó', 'O');
  LET cadena =  REPLACE(cadena, 'ú', 'U');
  LET cadena =  REPLACE(cadena, 'ñ', 'N');
  LET cadena =  REPLACE(cadena, 'à', 'A');
  LET cadena =  REPLACE(cadena, 'è', 'E');
  LET cadena =  REPLACE(cadena, 'ì', 'I');
  LET cadena =  REPLACE(cadena, 'ò', 'O');
  LET cadena =  REPLACE(cadena, 'ù', 'U');
  LET cadena =  REPLACE(cadena, 'ç', 'C');

  LET cadena =  REPLACE(cadena, '&', '');
  LET cadena =  REPLACE(cadena, ',', '');
  LET cadena =  REPLACE(cadena, '"', '');
  LET cadena =  REPLACE(cadena, "'", '');
  LET cadena =  REPLACE(cadena, '/', '');
  LET cadena =  REPLACE(cadena, '(', '');
  LET cadena =  REPLACE(cadena, ')', '');
  LET cadena =  REPLACE(cadena, ';', '');
  LET cadena =  REPLACE(cadena, '=', '');
  LET cadena =  REPLACE(cadena, '$', '');
  LET cadena =  REPLACE(cadena, '#', '');
 
  RETURN cadena;
END FUNCTION;