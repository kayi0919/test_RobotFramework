DECLARE 
	-- cluster id
	v_cid nvarchar2(32) := '{{CLUSTER_ID}}';
BEGIN

-- 刪除通報單異動紀錄
DELETE FROM CLUSTER_REPORT_FIELD_DIFF WHERE LOG_ID IN (SELECT LOG_ID FROM CLUSTER_REPORT_FIELD_DIFF_SUMMARY WHERE CLUSTER_REPORT_ID = v_cid);
DELETE FROM CLUSTER_REPORT_FIELD_DIFF_SUMMARY WHERE CLUSTER_REPORT_ID = v_cid;

-- 個案症狀
DELETE FROM CLUSTER_IDV_REPORT_SYMPTOMS WHERE CLUSTER_IDV_REPORT_ID IN (SELECT ID FROM CLUSTER_IDV_REPORT WHERE CLUSTER_REPORT_ID = v_cid);

-- 個案送驗
DELETE FROM CLUSTER_IDV_REPORT_SAMPLE WHERE IDV_REPORT_ID IN (SELECT ID FROM CLUSTER_IDV_REPORT WHERE CLUSTER_REPORT_ID = v_cid);

-- 個案聯絡
DELETE FROM CLUSTER_IDV_RPT_CONTACT_INFO WHERE CLUSTER_IDV_REPORT_ID IN (SELECT ID FROM CLUSTER_IDV_REPORT WHERE CLUSTER_REPORT_ID = v_cid);

-- 個案
DELETE FROM CLUSTER_IDV_REPORT WHERE CLUSTER_REPORT_ID = v_cid;

-- 通報單
DELETE FROM CLUSTER_REPORT WHERE ID = v_cid;

-- 研判結果
DELETE FROM CLUSTER_REPORT_DETERMINED WHERE CLUSTER_REPORT_ID = v_cid;

-- 待成案
DELETE FROM CLUSTER_REPORT_TOBE WHERE CLUSTER_REPORT_ID = v_cid;

END;
