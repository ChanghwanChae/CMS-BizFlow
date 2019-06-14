SELECT
--PD.PD_PROCID AS PROCID, R.REQ_ID,
 
R.REQ_JOB_REQ_NUMBER AS REQUEST_NUMBER, 
 
CS.CS_ADMIN_CD AS ADMIN_CODE, 
 
(SELECT TBL_LABEL
FROM TBL_LOOKUP WHERE TBL_ID = SG.SG_RT_ID
AND ROWNUM =
1) AS REQUEST_TYPE, 
 
(SELECT M.NAME
FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = CS.CS_ID
AND ROWNUM =
1) AS CLASSIFICATION_SPECIALIST
 
--,PD.PD_SCOPE AS COMPONENT_WIDE
 
FROM PD_COVERSHEET PD
 
INNER JOIN REQUEST R
ON PD.PD_REQ_ID = R.REQ_ID
 
INNER JOIN CLASSIF_STRATCON CS
ON CS.CS_REQ_ID = PD.PD_REQ_ID
 
INNER JOIN STRATCON_GEN SG
ON PD.PD_REQ_ID = SG.SG_REQ_ID
 
WHERE PD.PD_PROCID
IN (SELECT PROCID
FROM BIZFLOW.PROCS WHERE
NAME = 'Classification'
AND STATE =
'R')
 
AND PD.PD_SCOPE =
'Yes'