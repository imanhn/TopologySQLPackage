\connect electricity;
--
-- Subjective : This function inserts Nodes of a Geometry into BRP_NODES table.
-- If the N ode already exist, then it skips, if not, I will insert a new Node.
-- For Linear geometries like UG_MV_LINE we would have two nodes(start and end nodes) except for busbar.
-- Busbar has also nodes at the middle of it, so there should be some special measure in-place for busbar to handle
-- it's nodes.
-- We also need some special measure for fuse linkline, and automatic switch linkline as well. Cause upon there insertion
-- there might be a pre-drawn busbar that should be connected to fuse_switch/auto_switch.
-- These special cases are handled also here in this function.
--
-- The Algorithm is simple
-- is it a busbar? YES! then search for already drawn fuse_switch's linklines(ULL) and auto_switch's linkline(ULL again) if there are any, insert nodes into the database.
-- is it an auto_switch or a fuse_switch? YES! Then see if there is busbar there and find the nodes and insert them into node table
-- if it is not a busbar or fuse_switch or auto_switch then go for ordinary lines and points.
-- function brp_get_vertices returns start and end point geometry for lines and just one point for points! obviously!!!!
--

--drop function if exists brp_insert_or_update_brp_nodes_and_features;
Create or Replace function  brp_insert_or_update_brp_nodes_and_features(a_table_name text,a_smid integer,a_geom geometry,is_connect boolean)
returns brp_interaction_nodes
LANGUAGE 'plpgsql'
as $$
Declare points geometry[];
		vpoints geometry[];
		a_geom_point geometry;
		new_node_id integer;
		new_node brp_node_type;
		existed_nodes brp_node_type[];
		new_nodes brp_node_type[];
		a_brp_interaction_nodes brp_interaction_nodes;
		update_node_type boolean;
		update_is_connect boolean;
		feature_table_node_id integer;
		new_feature_table_record boolean;
		a_brp_buffer_result brp_buffer_result;
begin	
	raise notice '[brp_insert_or_update_brp_nodes_and_features]  % % ',a_table_name, a_smid;
	if (a_table_name = 'lv_busbar')
	then
		-- we need to check if there was a fuse(-14)/auto_switch(-13) there and add relevent nodes to our loop set (points)							  
		a_brp_interaction_nodes.number_of_points = 2;
		a_brp_buffer_result = brp_find_objects_in_buffer(a_table_name, a_smid, a_geom, ARRAY['ug_lv_line','a_meter','v_meter']);		
		points = a_brp_buffer_result.points;
		raise notice '	1. a_brp_buffer_result : % ,a_table_name : %, a_smid : %',a_brp_buffer_result,a_table_name,a_smid;
		perform brp_insert_busbar_nodes(a_brp_buffer_result,a_table_name,a_smid::integer);
	elsif (a_table_name = 'busbar') --mv_busbar
	then 		
		a_brp_interaction_nodes.number_of_points = 2;
		a_brp_buffer_result = brp_find_objects_in_buffer(a_table_name, a_smid, a_geom, ARRAY['ug_mv_line']);
		points = a_brp_buffer_result.points;		
		raise notice '	2. a_brp_buffer_result : % ,a_table_name : %, a_smid : %',a_brp_buffer_result,a_table_name,a_smid;
		perform brp_insert_busbar_nodes(a_brp_buffer_result,a_table_name,a_smid::integer);		
	elsif (a_table_name = 'ug_lv_line') -- representing fuse_switch
	then 		
		a_brp_interaction_nodes.number_of_points = 2;
		a_brp_buffer_result = brp_find_objects_in_buffer(a_table_name, a_smid, a_geom, ARRAY['lv_busbar']);
		points = a_brp_buffer_result.points;		
		raise notice '	3. a_brp_buffer_result : % ,a_table_name : %, a_smid : %',a_brp_buffer_result,a_brp_buffer_result.busbar_class,a_brp_buffer_result.busbar_smid;
		perform brp_insert_busbar_nodes(a_brp_buffer_result,a_brp_buffer_result.busbar_class,a_brp_buffer_result.busbar_smid::integer);
	elsif (a_table_name = 'a_meter') or (a_table_name = 'v_meter') or (a_table_name = 'modem')
	then 
		a_brp_interaction_nodes.number_of_points = 1;
		a_brp_buffer_result = brp_find_objects_in_buffer(a_table_name, a_smid, a_geom, ARRAY['busbar','lv_busbar']);
		points = a_brp_buffer_result.points;		
		raise notice '	4. a_brp_buffer_result : % ,a_table_name : %, a_smid : %',a_brp_buffer_result,a_brp_buffer_result.busbar_class,a_brp_buffer_result.busbar_smid;
		if (a_brp_buffer_result.busbar_class is not null) and (a_brp_buffer_result.busbar_smid is not null)
		then 
			raise notice '	4.1. busbar found that is connected to a feature of type modem,a_meter or v_meter';
			perform brp_insert_busbar_nodes(a_brp_buffer_result,a_brp_buffer_result.busbar_class,a_brp_buffer_result.busbar_smid::integer);		
		else 
			raise notice '	4.2. busbar not found connected to ug_mv_line';			
			points = brp_get_vertices(a_table_name,a_geom);
		end if;
	elsif (a_table_name = 'ug_mv_line')
	then 
		a_brp_interaction_nodes.number_of_points = 2;
		a_brp_buffer_result = brp_find_objects_in_buffer(a_table_name, a_smid, a_geom, ARRAY['busbar']);				
		raise notice '	5. a_brp_buffer_result : % ,a_table_name : %, a_smid : %',a_brp_buffer_result,a_brp_buffer_result.busbar_class,a_brp_buffer_result.busbar_smid;
		if (a_brp_buffer_result.busbar_class is not null) and (a_brp_buffer_result.busbar_smid is not null)
		then 
			raise notice '	busbar found that is connected to ug_mv_line';			
			perform brp_insert_busbar_nodes(a_brp_buffer_result,a_brp_buffer_result.busbar_class,a_brp_buffer_result.busbar_smid::integer);		
			points = a_brp_buffer_result.points;
			-- also find existed features nodes and add them 
			vpoints = brp_get_vertices(a_table_name,a_geom);
			points = points || vpoints;
		else 
			raise notice '	busbar found that is connected to ug_mv_line';			
			points = brp_get_vertices(a_table_name,a_geom);
		end if;
	else
		-- it is a regular feature (not busbar/fuse/auto_switch)
		IF (ST_GeometryType(a_geom) = 'ST_Point')
		then
			a_brp_interaction_nodes.number_of_points = 1;
		else
			a_brp_interaction_nodes.number_of_points = 2;
		end IF;
		-- returns start/end of lines or single point for points
		points = brp_get_vertices(a_table_name,a_geom);
	end if;
	if points is null or
		array_length(points,1) = 0
	then
		return a_brp_interaction_nodes;
	end if;
	foreach a_geom_point in array (points)
	loop
		-- It queries BRP_NODES table and searches for exact geometry-point in it then returns the a single node(brp_node_type)
		-- or a null (if the nodes is not found)
		-- brp_node_type involves node_id,smgeometry,is_connect,node_type
		new_node = brp_find_node_from_point(a_geom_point);
		
		if new_node is null
		then 
			raise notice '	Creating a new node...';
			new_node_id = nextval('brp_nodes_node_id_seq');
			execute format('insert into brp_nodes (node_id,smgeometry,node_type,is_connect) values(%L,%L,%L,%L);',new_node_id,a_geom_point,a_table_name,is_connect);
			execute format('insert into brp_feature_node (table_name,smid,node_id,is_connect) values(%L,%L,%L,%L);',a_table_name,a_smid,new_node_id,is_connect);
			raise notice '	new node created node_id : %   geometry : %  is_connect : %',new_node_id,ST_AsText(a_geom_point),is_connect;
			new_node = row(new_node_id,a_geom_point,is_connect,a_table_name);
			new_nodes = COALESCE(new_nodes || Array[new_node],Array[new_node]);
		else			
			raise notice '	node already existed %',new_node;
			existed_nodes = COALESCE(existed_nodes || Array[new_node],Array[new_node]);
			if 
				(a_table_name != new_node.node_type) and 	
				( 
					(a_table_name = 'mv_feeder') or 
					(new_node.node_type != 'mv_feeder' and a_table_name=ANY(ARRAY['discnt_s','cut_out','circt_brk','mv_jumpr','sectionalizer','recloser']) )
				)
			then
				update_node_type = true;
			else 
				update_node_type = false;
			end if;
			if new_node.is_connect != is_connect
			then 
				update_is_connect = true;
			else
				update_is_connect = false;
			end if;

			select node_id into feature_table_node_id from brp_feature_node where smid=a_smid and table_name=a_table_name and node_id = new_node.node_id;
			if feature_table_node_id is null 
			then 
				execute format('insert into brp_feature_node (table_name,smid,node_id,is_connect) values(%L,%L,%L,%L);',a_table_name,a_smid,new_node.node_id,is_connect);
				new_feature_table_record = true;
			else
				new_feature_table_record = false;
			end if;

			raise notice '  update_node_type  %    update_is_connect % ******',update_node_type,update_is_connect;
			if update_is_connect is true and update_node_type is false
			then
				execute format('update brp_nodes set is_connect = %L where node_id = %L;',is_connect,new_node.node_id);
				if new_feature_table_record is false
				then 
					execute format('update brp_feature_node set is_connect = %L where node_id = %L;',is_connect,new_node.node_id);
				end if;
			elsif update_is_connect is false and update_node_type is true 
			then 
				execute format('update brp_nodes set node_type = %L where node_id = %L;',a_table_name,new_node.node_id);
			elsif update_is_connect is true and update_node_type is true 
			then
				execute format('update brp_nodes set node_type = %L , is_connect = %L where node_id = %L;',a_table_name,is_connect,new_node.node_id);
				if new_feature_table_record is false
				then 				
					execute format('update brp_feature_node set is_connect = %L where node_id = %L;',is_connect,new_node.node_id);				
				end if;
			end if;
			raise notice '  update_node_type and   update_is_connecte done.';
		end if;
	end loop;
	a_brp_interaction_nodes.new_nodes = new_nodes;
	a_brp_interaction_nodes.existed_nodes = existed_nodes;
	return a_brp_interaction_nodes;
end;
$$