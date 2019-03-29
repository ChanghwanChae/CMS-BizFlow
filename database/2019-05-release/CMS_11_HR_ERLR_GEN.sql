ALTER TABLE ERLR_GEN MODIFY GEN_CASE_DESC NVARCHAR2(1000);
ALTER TABLE ERLR_GEN ADD GEN_CASE_CATEGORY_NAME NVARCHAR2(1000);
ALTER TABLE ERLR_GEN ADD GEN_CASE_TYPE_NAME NVARCHAR2(150);
ALTER TABLE ERLR_GEN ADD GEN_CLASS NVARCHAR2(10);
ALTER TABLE ERLR_GEN ADD GEN_PRIMARY_SPECIALIST_NAME NVARCHAR2(150);
ALTER TABLE ERLR_GEN ADD GEN_SECONDARY_SPECIALIST_NAME NVARCHAR2(150);
ALTER TABLE ERLR_GEN ADD GEN_EMPLOYEE_2ND_SUB_ORG NVARCHAR2(255);
ALTER TABLE ERLR_GEN ADD MOD_DT DATE DEFAULT SYSDATE;

CREATE UNIQUE INDEX ERLR_GEN_UK2 ON ERLR_GEN (PROCID);
DROP INDEX ERLR_CASE_UK1;
CREATE UNIQUE INDEX ERLR_CASE_UK1 ON ERLR_CASE (ERLR_CASE_NUMBER, PROCID);
CREATE UNIQUE INDEX ERLR_CASE_UK2 ON ERLR_CASE (PROCID, ERLR_CASE_NUMBER);