-- CMS_HR_DB_UPD_03_report_view.sql

--------------------------------------------------------
--  DDL for VW_UNIFIED_REQUESTS_RANK
--------------------------------------------------------
CREATE OR REPLACE VIEW VW_UNIFIED_REQUESTS_RANK
AS

    SELECT REQ.*, RANK() OVER (PARTITION BY REQ.REQ_JOB_REQ_NUMBER ORDER BY REQ.CREATIONDTIME DESC) REQ_RANK FROM (
        SELECT UNION_REQ.*, TO_CHAR(UNION_REQ.REQ_JOB_REQ_CREATE_DT, 'MM-DD-YYYY HH24:MI:SS') AS REQ_DATE_STRING
            , P.CREATIONDTIME, TO_CHAR(P.CREATIONDTIME, 'MM-DD-YYYY HH24:MI:SS') AS CREATION_DATE_STRING
            , P.STATE AS PROC_STATE
        FROM (
             SELECT REQ_ID, REQ_JOB_REQ_NUMBER, REQ_JOB_REQ_CREATE_DT, REQ_STATUS_ID, REQ_CANCEL_DT, REQ_CANCEL_REASON, PD_PROCID AS PROC_ID, 'CLASSIFICATION' AS PROC_TYPE  FROM VW_CLASSIFICATION
             UNION
             SELECT REQ_ID, REQ_JOB_REQ_NUMBER, REQ_JOB_REQ_CREATE_DT, REQ_STATUS_ID, REQ_CANCEL_DT, REQ_CANCEL_REASON, PROCID AS PROC_ID, 'ELIGQUAL' AS PROC_TYPE FROM VW_ELIGQUAL
             UNION
             SELECT REQ_ID, REQ_JOB_REQ_NUMBER, REQ_JOB_REQ_CREATE_DT, REQ_STATUS_ID, REQ_CANCEL_DT, REQ_CANCEL_REASON, SG_PROCID AS PROC_ID, 'STRATCON' AS PROC_TYPE FROM VW_STRATCON
             ) UNION_REQ
               INNER JOIN BIZFLOW.PROCS P ON P.PROCID = UNION_REQ.PROC_ID
        WHERE UNION_REQ.PROC_ID IS NOT NULL
        ) REQ

;
/

-- CMS_HR_DB_UPD_06_permission_report.sql
GRANT SELECT ON HHS_CMS_HR.VW_UNIFIED_REQUESTS_RANK TO HHS_CMS_HR_RW_ROLE;
GRANT SELECT ON HHS_CMS_HR.VW_UNIFIED_REQUESTS_RANK TO HHS_CMS_HR_DEV_ROLE;