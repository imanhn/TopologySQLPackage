\connect electricity;

Create or Replace function brp_update_non_switch_point() RETURNS trigger AS $$
begin
	perform brp_update_tree_for_record(TG_TABLE_NAME,NEW.smid,NEW.smgeometry,true);
	return new;
End; $$
LANGUAGE 'plpgsql';

Create or Replace function brp_update_switch_point() RETURNS trigger AS $$
begin
	if NEW.connection_status = 'بسته' or new.connection_status = 'در مدار'
	then 
		perform brp_update_tree_for_record(TG_TABLE_NAME,NEW.smid,NEW.smgeometry,true);
	else 
		perform brp_update_tree_for_record(TG_TABLE_NAME,NEW.smid,NEW.smgeometry,false);
	end if;
	return new;
End; $$
LANGUAGE 'plpgsql';


Create or Replace function brp_update_line() RETURNS trigger AS $$
begin
	perform brp_update_tree_for_record(TG_TABLE_NAME,NEW.smid,NEW.smgeometry,true);
	return new;
End; $$
LANGUAGE 'plpgsql';

------------------------ N O N    S W I T C H -------------------
DROP TRIGGER IF EXISTS brp_update_trigger ON mv_feeder;
Create trigger brp_update_trigger AFTER UPDATE on mv_feeder 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_non_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON mv_isolator;
Create trigger brp_update_trigger AFTER UPDATE on mv_isolator 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_non_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON mv_selfstand_terminal;
Create trigger brp_update_trigger AFTER UPDATE on mv_selfstand_terminal 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_non_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON surg_arstr;
Create trigger brp_update_trigger AFTER UPDATE on surg_arstr 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_non_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON dist_tr;
Create trigger brp_update_trigger AFTER UPDATE on dist_tr 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_non_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON mv_c_hd;
Create trigger brp_update_trigger AFTER UPDATE on mv_c_hd 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_non_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON lv_c_hd;
Create trigger brp_update_trigger AFTER UPDATE on lv_c_hd 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_non_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON lv_isolator;
Create trigger brp_update_trigger AFTER UPDATE on lv_isolator 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_non_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON lv_selfstand_terminal;
Create trigger brp_update_trigger AFTER UPDATE on lv_selfstand_terminal 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_non_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON distrb_box;
Create trigger brp_update_trigger AFTER UPDATE on distrb_box
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_non_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON no_subscribers;
Create trigger brp_update_trigger AFTER UPDATE on no_subscribers
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_non_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON subscriber;
Create trigger brp_update_trigger AFTER UPDATE on subscriber
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_non_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON lv_feeder;
Create trigger brp_update_trigger AFTER UPDATE on lv_feeder
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_non_switch_point();


----------------------------------------------------------

------------------------  S W I T C H  -------------------
DROP TRIGGER IF EXISTS brp_update_trigger ON discnt_s;
Create trigger brp_update_trigger AFTER UPDATE on discnt_s 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON discnt_s;
Create trigger brp_update_trigger AFTER UPDATE on discnt_s 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON mv_jumpr;
Create trigger brp_update_trigger AFTER UPDATE on mv_jumpr 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON recloser;
Create trigger brp_update_trigger AFTER UPDATE on recloser 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON cut_out;
Create trigger brp_update_trigger AFTER UPDATE on cut_out 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON auto_switch;
Create trigger brp_update_trigger AFTER UPDATE on auto_switch
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON fuse_switch;
Create trigger brp_update_trigger AFTER UPDATE on fuse_switch
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_switch_point();

DROP TRIGGER IF EXISTS brp_update_trigger ON lv_jumper;
Create trigger brp_update_trigger AFTER UPDATE on lv_jumper
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_switch_point();

----------------------------- L I N E -----------------------

DROP TRIGGER IF EXISTS brp_update_trigger ON oh_mv_line;
Create trigger brp_update_trigger AFTER UPDATE on oh_mv_line
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_line();


DROP TRIGGER IF EXISTS brp_update_trigger ON sp_mv_cable;
Create trigger brp_update_trigger AFTER UPDATE on sp_mv_cable
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_line();

DROP TRIGGER IF EXISTS brp_update_trigger ON ug_mv_line;
Create trigger brp_update_trigger AFTER UPDATE on ug_mv_line
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_line();

DROP TRIGGER IF EXISTS brp_update_trigger ON oh_lv_line;
Create trigger brp_update_trigger AFTER UPDATE on oh_lv_line
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_line();


DROP TRIGGER IF EXISTS brp_update_trigger ON sp_lv_cable;
Create trigger brp_update_trigger AFTER UPDATE on sp_lv_cable
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_line();

DROP TRIGGER IF EXISTS brp_update_trigger ON ug_lv_line;
Create trigger brp_update_trigger AFTER UPDATE on ug_lv_line
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_line();

DROP TRIGGER IF EXISTS brp_update_trigger ON lv_busbar;
Create trigger brp_update_trigger AFTER INSERT on lv_busbar
FOR EACH ROW 
WHEN (pg_trigger_depth() = 0)
EXECUTE PROCEDURE brp_insert_line();

DROP TRIGGER IF EXISTS brp_update_trigger ON busbar;
Create trigger brp_update_trigger AFTER INSERT on busbar
FOR EACH ROW 
WHEN (pg_trigger_depth() = 0)
EXECUTE PROCEDURE brp_insert_line();


DO $$
BEGIN
	raise notice '**************************************************';
	raise notice '*    All Update Triggers defined successfully     *';
	raise notice '**************************************************';
END;
$$
