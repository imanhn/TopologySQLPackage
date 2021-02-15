\connect electricity;

Create or Replace function brp_delete_non_switch_point() RETURNS trigger AS $$
begin
	perform brp_delete_tree_for_non_switch_point(TG_TABLE_NAME,OLD.smid);
	return new;
End; $$
LANGUAGE 'plpgsql';

Create or Replace function brp_delete_switch_point() RETURNS trigger AS $$
DECLARE a_node_id bigint;
begin
	perform brp_delete_tree_for_non_switch_point(TG_TABLE_NAME,OLD.smid);
	
	if OLD.connection_status = 'بسته' or OLD.connection_status = 'در مدار'
	then 
		raise notice '*** Switch deleted but No need to change tree.';
		
	else 
		--Now we should connect downstreams
		raise notice '*** Switch deleted connecting subpaths...';
		select node_id into a_node_id from brp_feature_node where smid = OLD.smid and table_name = TG_TABLE_NAME limit 1;
		perform closed_an_open_switch(a_node_id);
	end if;

	return new;
End; $$
LANGUAGE 'plpgsql';


Create or Replace function brp_delete_line() RETURNS trigger AS $$
begin
	perform brp_delete_tree_for_line(TG_TABLE_NAME,OLD.smid);
	return new;
End; $$
LANGUAGE 'plpgsql';

------------------------ N O N    S W I T C H -------------------
DROP TRIGGER IF EXISTS brp_delete_trigger ON mv_feeder;
Create trigger brp_delete_trigger AFTER DELETE on mv_feeder 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_non_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON mv_isolator;
Create trigger brp_delete_trigger AFTER DELETE on mv_isolator 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_non_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON mv_selfstand_terminal;
Create trigger brp_delete_trigger AFTER DELETE on mv_selfstand_terminal 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_non_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON surg_arstr;
Create trigger brp_delete_trigger AFTER DELETE on surg_arstr 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_non_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON dist_tr;
Create trigger brp_delete_trigger AFTER DELETE on dist_tr 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_non_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON mv_c_hd;
Create trigger brp_delete_trigger AFTER DELETE on mv_c_hd 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_non_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON lv_c_hd;
Create trigger brp_delete_trigger AFTER DELETE on lv_c_hd 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_non_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON lv_isolator;
Create trigger brp_delete_trigger AFTER DELETE on lv_isolator 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_non_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON lv_selfstand_terminal;
Create trigger brp_delete_trigger AFTER DELETE on lv_selfstand_terminal 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_non_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON distrb_box;
Create trigger brp_delete_trigger AFTER DELETE on distrb_box
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_non_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON no_subscribers;
Create trigger brp_delete_trigger AFTER DELETE on no_subscribers
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_non_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON subscriber;
Create trigger brp_delete_trigger AFTER DELETE on subscriber
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_non_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON lv_feeder;
Create trigger brp_delete_trigger AFTER DELETE on lv_feeder
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_non_switch_point();


----------------------------------------------------------

------------------------  S W I T C H  -------------------
DROP TRIGGER IF EXISTS brp_delete_trigger ON discnt_s;
Create trigger brp_delete_trigger AFTER DELETE on discnt_s 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON discnt_s;
Create trigger brp_delete_trigger AFTER DELETE on discnt_s 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON mv_jumpr;
Create trigger brp_delete_trigger AFTER DELETE on mv_jumpr 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON recloser;
Create trigger brp_delete_trigger AFTER DELETE on recloser 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON cut_out;
Create trigger brp_delete_trigger AFTER DELETE on cut_out 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON auto_switch;
Create trigger brp_delete_trigger AFTER DELETE on auto_switch
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON fuse_switch;
Create trigger brp_delete_trigger AFTER DELETE on fuse_switch
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_switch_point();

DROP TRIGGER IF EXISTS brp_delete_trigger ON lv_jumper;
Create trigger brp_delete_trigger AFTER DELETE on lv_jumper
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_switch_point();

----------------------------- L I N E -----------------------

DROP TRIGGER IF EXISTS brp_delete_trigger ON oh_mv_line;
Create trigger brp_delete_trigger AFTER DELETE on oh_mv_line
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_line();


DROP TRIGGER IF EXISTS brp_delete_trigger ON sp_mv_cable;
Create trigger brp_delete_trigger AFTER DELETE on sp_mv_cable
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_line();

DROP TRIGGER IF EXISTS brp_delete_trigger ON ug_mv_line;
Create trigger brp_delete_trigger AFTER DELETE on ug_mv_line
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_line();

DROP TRIGGER IF EXISTS brp_delete_trigger ON oh_lv_line;
Create trigger brp_delete_trigger AFTER DELETE on oh_lv_line
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_line();


DROP TRIGGER IF EXISTS brp_delete_trigger ON sp_lv_cable;
Create trigger brp_delete_trigger AFTER DELETE on sp_lv_cable
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_line();

DROP TRIGGER IF EXISTS brp_delete_trigger ON ug_lv_line;
Create trigger brp_delete_trigger AFTER DELETE on ug_lv_line
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_delete_line();

DROP TRIGGER IF EXISTS brp_delete_trigger ON lv_busbar;
Create trigger brp_delete_trigger AFTER INSERT on lv_busbar
FOR EACH ROW 
WHEN (pg_trigger_depth() = 0)
EXECUTE PROCEDURE brp_insert_line();

DROP TRIGGER IF EXISTS brp_delete_trigger ON busbar;
Create trigger brp_delete_trigger AFTER INSERT on busbar
FOR EACH ROW 
WHEN (pg_trigger_depth() = 0)
EXECUTE PROCEDURE brp_insert_line();

DO $$
BEGIN
	raise notice '**************************************************';
	raise notice '*    All Delete Triggers defined successfully     *';
	raise notice '**************************************************';
END;
$$
