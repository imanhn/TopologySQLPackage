-- This will also deletes all functions and so triggers attached to this type.
\connect electricity;

DO $$ BEGIN
	drop type if exists brp_interaction_nodes CASCADE;
	drop type if exists brp_tree_node_type CASCADE;
	drop type if exists brp_feature_node_type CASCADE;
	drop type if exists brp_node_type CASCADE;
	drop type if exists brp_buffer_result CASCADE;
	
END $$;

DO $$ BEGIN
	create type brp_node_type as (
		node_id bigint,
		smgeometry geometry,
		is_connect boolean,
		node_type text
	);
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;


DO $$ BEGIN
	create type brp_feature_node_type as (
		table_name text,
		smid bigint,
		node_id bigint,
		is_connect boolean
	);
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;

DO $$ BEGIN
	create type brp_tree_node_type as (
		path_id bigint,
		node_id bigint,
		path ltree,
		root_type text,
		node_type text,
		is_connect boolean
	);
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;

DO $$ BEGIN
	create type brp_buffer_result as (
		points geometry[],
		smids integer[],
		table_names text[],
		busbar_geom geometry,
		busbar_class text,
		busbar_smid bigint
	);
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;


-- This is the type of data that brp_insert_or_update_brp_nodes returns
DO $$ BEGIN
	create type brp_interaction_nodes as (
		number_of_points  integer,
		new_nodes brp_node_type[],
		existed_nodes brp_node_type[]
	);
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;
