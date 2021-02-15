\connect electricity;

--drop function if exists brp_insert_busbar_nodes;

Create or Replace function brp_insert_busbar_nodes(a_brp_buffer_result brp_buffer_result,busbar_class text, busbar_smid integer)
RETURNS void
LANGUAGE 'plpgsql'
as $$
Declare 
	counter integer := 1;
	is_connect boolean := true;
	no_of_intersections integer;
	new_node_id integer;
	new_path_id integer;
	new_node brp_node_type;
	a_geom_point geometry;
BEGIN
raise notice '[brp_insert_busbar_nodes] Inserting busbar connection for  %[%]',busbar_class,busbar_smid;
no_of_intersections = array_length(a_brp_buffer_result.points,1);

if no_of_intersections = 0 
then 
	raise notice '	Busbar has no nodes to add.';
	return; 
else 
	raise notice '	Busbar has some nodes to add : %',no_of_intersections;
end if;

counter = 1;
loop
	-- we should check if the node has already inserted cause this could happen with a fuse and automatic_switch connected both at the same point on a busbar!	
	a_geom_point = a_brp_buffer_result.points[counter];
	raise notice '	Looping over points of buffer result counter : % and point : %',counter,a_geom_point;
	--FIXME
	-- Change it to a buffer search
	if a_geom_point is null 
	then		
		raise notice '	a_geom_point is null, exiting...';
		exit;
	end if;
	new_node = brp_find_node_from_point_with_buffer(a_geom_point,0.1);
	
	if new_node is null
	then 				
		new_node_id = nextval('brp_nodes_node_id_seq');
		new_path_id = nextval('brp_network_tree_path_id_seq');
		raise notice '	new_node is null, inserting[%] into brp_nodes...',new_node_id;
		execute format('insert into brp_nodes (node_id,smgeometry,node_type,is_connect) values(%L,%L,%L,%L);',new_node_id,a_brp_buffer_result.points[counter],busbar_class,is_connect);
		execute format('insert into brp_network_tree (path_id,node_id,path,root_type,node_type,is_connect) values(%L,%L,%L,%L,%L,%L);',new_path_id,new_node_id,new_node_id::text::ltree,busbar_class,busbar_class,is_connect);
	else		
		new_node_id = new_node.node_id;
		raise notice '	new_node is not null(existed) : %',new_node_id;
	end if;
	
	begin
		execute format('insert into brp_feature_node (table_name,smid,node_id,is_connect) values(%L,%L,%L,%L);',busbar_class,busbar_smid,new_node_id,is_connect);
	exception when unique_violation then
		raise notice '	brp_feature_node % % % % already exist',busbar_class,busbar_smid,new_node_id,is_connect;
    end;
	exit when counter >= no_of_intersections;
	counter = counter + 1;
end loop;
END; $$ 


--test case inserting a busbar
--INSERT INTO public.busbar(smid, smgeometry, "id") VALUES (10000, ST_GeomFromText('MultiLineString((600000 3400000,600001 3400000))',32639), 10000);
--INSERT INTO public.ug_mv_line(smid, smgeometry, "id") VALUES (10000, ST_GeomFromText('MultiLineString((492907.58,3574710.51,492907.35,3574707.85))',32639), 10000);

--delete from brp_nodes;
--delete from brp_feature_node;
--delete from brp_network_tree;
