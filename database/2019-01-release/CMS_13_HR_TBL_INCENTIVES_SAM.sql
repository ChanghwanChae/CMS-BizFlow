--------------------------------------------------------
--  DDL for altering the tables INCENTIVES_SAM
--------------------------------------------------------
ALTER TABLE INCENTIVES_SAM ADD (
  COC_NAME VARCHAR2(100) NULL,
  COC_EMAIL VARCHAR2(100) NULL,
  COC_ID VARCHAR2(10) NULL,
  COC_TITLE VARCHAR2(100) NULL,
  APPROVAL_SO_ACTING VARCHAR2(10) NULL,
  APPROVAL_DGHO_ACTING VARCHAR2(10) NULL,
  APPROVAL_TABG_ACTING VARCHAR2(10) NULL,
  APPROVAL_OHC_ACTING VARCHAR2(10) NULL
);
/