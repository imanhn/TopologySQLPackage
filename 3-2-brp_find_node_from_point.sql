--drop function brp_find_node_from_point;
\connect electricity;

Create or Replace function  brp_find_node_from_point(a_point_geom geometry)
returns brp_node_type
LANGUAGE 'plpgsql'
as $$
DECLARE a_node brp_node_type;
BEGIN
	for a_node in execute format('select * from %I where smgeometry = %L LIMIT 1','brp_nodes',a_point_geom)
	loop
		return a_node;
	end loop;
	return a_node;
END;
$$;

Create or Replace function  brp_find_node_from_point_with_buffer(a_point_geom geometry,a_buffer real)
returns brp_node_type
LANGUAGE 'plpgsql'
as $$
DECLARE a_node brp_node_type;
BEGIN
	--select * from brp_node_type nt where ST_Contains(ST_Buffer(a_point_geom,a_buffer),nt.smgeometry)
	for a_node in execute format('select * from %I nt where ST_Contains(ST_Buffer(%L,%L),nt.smgeometry) LIMIT 1','brp_nodes',a_point_geom,a_buffer)
	loop
		return a_node;
	end loop;
	return a_node;
END;
$$;


--DO $$
--declare 
--	ageom geometry;
--	anode brp_node_type;
--BEGIN
	
--	for ageom in execute format('select smgeometry from %I limit 1','brp_nodes')
--	loop
--		anode = brp_find_node_from_point_with_buffer(ageom,0.1);
--		raise notice 'Node : %',anode;
--	end loop;
--END;
--$$;

