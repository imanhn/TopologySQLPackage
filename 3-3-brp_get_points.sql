--drop function brp_get_points;
\connect electricity;

--
-- This function brp_get_points is not being used by the NetworkAnalysis package.
-- It returns all of the points in a geometry array.
--
Create or Replace function brp_get_points(a_geometry geometry)
returns geometry[]
LANGUAGE 'plpgsql'
as $$
DECLARE points geometry[];
DECLARE a_point_geom geometry;
BEGIN
	FOR a_point_geom in (select (ST_DumpPoints(a_geometry)).geom)
	loop
		--raise notice 'adding %',st_asText(a_point_geom);
		points := points || a_point_geom;
	end loop;
	--raise notice 'no of points : %',array_length(points,1);
	return points;
END;
$$;

-- This function brp_get_points is not being used by the NetworkAnalysis package.
-- It returns all of the points in a geometry array, considers Merging Lines!.

Create or Replace function brp_get_points_array(a_geom Geometry) 
returns Geometry[]
LANGUAGE 'plpgsql'
as $$
DECLARE start_line_point Geometry;
DECLARE end_line_point Geometry;
BEGIN
	IF (ST_GeometryType(a_geom) = 'ST_Point')
	THEN
		raise notice 'Point detected ';
		return array[a_geom];
	END IF;
	a_geom := ST_LineMerge(a_geom);
	start_line_point := ST_PointN(a_geom,1);	
	start_line_point = ST_SetSRID(start_line_point,ST_SRID(a_geom));
	end_line_point := ST_PointN(a_geom,-1);
	end_line_point = ST_SetSRID(end_line_point,ST_SRID(a_geom));
	raise notice 'Line detected ';
	return array[start_line_point] || array[end_line_point];
END;
$$;

Create or Replace function brp_get_vertices(a_table_name text, ageom geometry)
returns geometry[]
LANGUAGE 'plpgsql'
as $$
DECLARE points geometry[];
DECLARE all_points geometry[];
DECLARE no_of_points integer;
DECLARE end_point geometry;
DECLARE start_point geometry;
BEGIN

	if ageom is null 
	then
		raise notice 'Geometry does not have any point.';
	end if;
	if 'ST_MultiLineString' = ST_GeometryType(ageom) or 'ST_LineString' = ST_GeometryType(ageom)
	then
		all_points = brp_get_points( ageom );
		no_of_points = array_length(all_points,1);
		--raise notice 'No of Points % ',no_of_points;		
		points = array_append(points,all_points[1]);
		points = array_append(points,all_points[no_of_points]);
		--raise notice 'Line % ',points;		
	elsif 'ST_Point' = ST_GeometryType(ageom) or 'ST_MultiPoint' = ST_GeometryType(ageom)
	then		
		points = array_append(points,ageom);
		--raise notice 'Point % ',ST_GeometryType(ageom);
	else
		raise notice 'ERROR : Geometry type is not handled, add it to 3-3 in NetworkAnalysis Package % ',ST_GeometryType(ageom);
	end if;
	--raise notice 'points : %',points;
	return points;
END $$;


--DO $$ 
--DECLARE ageom geometry;
--BEGIN
--	select smgeometry into ageom from ug_mv_line limit 1;
--	perform brp_get_vertices('mv_pole',ageom);
--end $$;
