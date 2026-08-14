CREATE FUNCTION "informix".getdistance(deg_lat1 FLOAT, deg_lng1 FLOAT, deg_lat2 FLOAT, deg_lng2 FLOAT)  RETURNING INTEGER;
	DEFINE distance FLOAT;
	DEFINE delta_lat FLOAT; 
	DEFINE delta_lng FLOAT; 
	DEFINE lat1 FLOAT; 
	DEFINE lat2 FLOAT;
	DEFINE a FLOAT;
  
	LET distance = 0;
	/*Convert degrees to radians and get the variables I need.*/
	LET delta_lat = radians(deg_lat2 - deg_lat1); 
	LET delta_lng = radians(deg_lng2 - deg_lng1); 
	LET lat1 = radians(deg_lat1); 
	LET lat2 = radians(deg_lat2); 
	/*Formula found here: http://www.movable-type.co.uk/scripts/latlong.html*/
	LET a = sin(delta_lat/2.0) * sin(delta_lat/2.0) + sin(delta_lng/2.0) * sin(delta_lng/2.0) * cos(lat1) * cos(lat2); 
	LET distance = 3956.6 * 2 * atan2(sqrt(a),  sqrt(1-a)); 
	 
  RETURN distance;
END FUNCTION;