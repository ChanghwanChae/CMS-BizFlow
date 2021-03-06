SET DEFINE OFF ;




--------------------------------------------------------
--  DDL for Function FN_GET_LOCATION_DSCR
--------------------------------------------------------

/**
 * Gets LOCATION descriptions.
 *
 * @param I_LOCATION_IDS - Selected item IDs, semicolon separated.
 *
 * @return NVARCHAR2 - Description of the selected items, comma separated.
 */
CREATE OR REPLACE FUNCTION FN_GET_LOCATION_DSCR
(
	I_LOCATION_IDS              IN      NVARCHAR2
)
RETURN NVARCHAR2
IS
	V_INPUT_VAL                 NVARCHAR2(3000);
	V_RETURN_VAL                NVARCHAR2(4000);
	V_SQL                       VARCHAR2(4000);
	V_IDX                       NUMBER(10);
	V_LOCATION_CNT              NUMBER(10);
	TYPE LOCATION_TYPE IS REF CURSOR;
	CUR_LOCATION                LOCATION_TYPE;
	REC_LOCATION                LOCATION%ROWTYPE;
BEGIN
	--DBMS_OUTPUT.PUT_LINE('------- START: FN_GET_LOCATION_DSCR -------');
	--DBMS_OUTPUT.PUT_LINE('-- PARAMETERS --');
	--DBMS_OUTPUT.PUT_LINE('    I_LOCATION_IDS = ' || I_LOCATION_IDS );

	-- input validation
	IF I_LOCATION_IDS IS NULL OR LENGTH(TRIM(I_LOCATION_IDS)) <= 0
	THEN
		RETURN NULL;
	ELSE
		-- prepare input value to be used in IN clause
		V_INPUT_VAL := TRIM(I_LOCATION_IDS);
		V_INPUT_VAL := REPLACE(V_INPUT_VAL, ',', ''',''');
		V_INPUT_VAL := CONCAT('''', V_INPUT_VAL);
		V_INPUT_VAL := CONCAT(V_INPUT_VAL, '''');
	END IF;

	V_RETURN_VAL := '';
	V_SQL := 'SELECT * FROM LOCATION WHERE LOC_ID IN (' || V_INPUT_VAL || ') ';
	--DBMS_OUTPUT.PUT_LINE('    V_SQL = ' || V_SQL );

	-- Loop through to look up description of each
	-- and concatenate descriptions delimitted by semicolon.
	--DBMS_OUTPUT.PUT_LINE('Before open cursor for LOCATION');
	OPEN CUR_LOCATION FOR V_SQL;
	--DBMS_OUTPUT.PUT_LINE('After open cursor for LOCATION');

	V_LOCATION_CNT := 0;
	LOOP
		FETCH CUR_LOCATION INTO REC_LOCATION;
		EXIT WHEN CUR_LOCATION%NOTFOUND;
		V_LOCATION_CNT := V_LOCATION_CNT + 1;
		V_RETURN_VAL := V_RETURN_VAL || REC_LOCATION.LOC_CITY || ', ' || REC_LOCATION.LOC_STATE || '; ';
		--DBMS_OUTPUT.PUT_LINE('Fetched record, loop count = ' || TO_CHAR(V_LOCATION_CNT) || ' V_RETURN_VAL = ' || V_RETURN_VAL);
	END LOOP;
	CLOSE CUR_LOCATION;

	-- clear trailing comma if exists
	IF V_RETURN_VAL IS NOT NULL AND LENGTH(V_RETURN_VAL) > 0
	THEN
		V_IDX := INSTR(V_RETURN_VAL, '; ', -1);
		IF V_IDX > 0 AND V_IDX = (LENGTH(V_RETURN_VAL) - 1)
		THEN
			V_RETURN_VAL := SUBSTR(V_RETURN_VAL, 0, (LENGTH(V_RETURN_VAL) - 2));
		END IF;
	END IF;

	--DBMS_OUTPUT.PUT_LINE('    V_RETURN_VAL = ' || V_RETURN_VAL);
	--DBMS_OUTPUT.PUT_LINE('------- END: FN_GET_LOCATION_DSCR -------');
	RETURN V_RETURN_VAL;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing FN_GET_LOCATION_DSCR -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || SQLCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || SQLERRM);
		RETURN NULL;
END;

/








SET DEFINE OFF;

--------------------------------------------------------
--  DDL for VW_STRATCON
--------------------------------------------------------
CREATE OR REPLACE VIEW VW_STRATCON
AS
SELECT
	R.REQ_ID
	, R.REQ_JOB_REQ_NUMBER
	, R.REQ_JOB_REQ_CREATE_DT
	, R.REQ_STATUS_ID
	, R.REQ_CANCEL_DT
	, R.REQ_CANCEL_REASON

	, SG.SG_PROCID
	, SG.SG_AC_ID
	--, LU_AC.AC_ADMIN_CD AS SG_AC_CD
	--, LU_AC.AC_ADMIN_CD_DESCR AS SG_AC_DSCR
	, SG.SG_ADMIN_CD AS SG_ADMIN_CD
	--, LU_AC.AC_ADMIN_CD_DESCR AS SG_ADMIN_CD_DSCR
	--, LU_SO_1.AC_ADMIN_CD AS SUB_ORG_1_CD
	--, LU_SO_1.AC_ADMIN_CD_DESCR AS SUB_ORG_1_DSCR
	--, LU_SO_2.AC_ADMIN_CD AS SUB_ORG_2_CD
	--, LU_SO_2.AC_ADMIN_CD_DESCR AS SUB_ORG_2_DSCR
	--, LU_SO_3.AC_ADMIN_CD AS SUB_ORG_3_CD
	--, LU_SO_3.AC_ADMIN_CD_DESCR AS SUB_ORG_3_DSCR
	--, LU_SO_4.AC_ADMIN_CD AS SUB_ORG_4_CD
	--, LU_SO_4.AC_ADMIN_CD_DESCR AS SUB_ORG_4_DSCR
	--, LU_SO_5.AC_ADMIN_CD AS SUB_ORG_5_CD
	--, LU_SO_5.AC_ADMIN_CD_DESCR AS SUB_ORG_5_DSCR
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = SG.SG_ADMIN_CD AND ROWNUM = 1) AS SG_ADMIN_CD_DSCR
	, FN_GET_SUBORG_CD(SG.SG_ADMIN_CD, 1) AS SUB_ORG_1_CD
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = FN_GET_SUBORG_CD(SG.SG_ADMIN_CD, 1) AND ROWNUM = 1) AS SUB_ORG_1_DSCR
	, FN_GET_SUBORG_CD(SG.SG_ADMIN_CD, 2) AS SUB_ORG_2_CD
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = FN_GET_SUBORG_CD(SG.SG_ADMIN_CD, 2) AND ROWNUM = 1) AS SUB_ORG_2_DSCR
	, FN_GET_SUBORG_CD(SG.SG_ADMIN_CD, 3) AS SUB_ORG_3_CD
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = FN_GET_SUBORG_CD(SG.SG_ADMIN_CD, 3) AND ROWNUM = 1) AS SUB_ORG_3_DSCR
	, FN_GET_SUBORG_CD(SG.SG_ADMIN_CD, 4) AS SUB_ORG_4_CD
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = FN_GET_SUBORG_CD(SG.SG_ADMIN_CD, 4) AND ROWNUM = 1) AS SUB_ORG_4_DSCR
	, FN_GET_SUBORG_CD(SG.SG_ADMIN_CD, 5) AS SUB_ORG_5_CD
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = FN_GET_SUBORG_CD(SG.SG_ADMIN_CD, 5) AND ROWNUM = 1) AS SUB_ORG_5_DSCR
	, SG.SG_RT_ID
	--, LU_RT.TBL_LABEL AS SG_RT_DSCR
	, (SELECT LU_RT.TBL_LABEL FROM TBL_LOOKUP LU_RT WHERE LU_RT.TBL_ID = SG.SG_RT_ID AND ROWNUM = 1) AS SG_RT_DSCR
	, SG.SG_CT_ID
	--, LU_CT.TBL_LABEL AS SG_CT_DSCR
	, (SELECT LU_CT.TBL_LABEL FROM TBL_LOOKUP LU_CT WHERE LU_CT.TBL_ID = SG.SG_CT_ID AND ROWNUM = 1) AS SG_CT_DSCR
	, SG.SG_AT_ID
	--, LU_AT.TBL_LABEL AS SG_AT_DSCR
	, (SELECT LU_AT.TBL_LABEL FROM TBL_LOOKUP LU_AT WHERE LU_AT.TBL_ID = SG.SG_AT_ID AND ROWNUM = 1) AS SG_AT_DSCR
	, SG.SG_VT_ID
	--, LU_VT.TBL_LABEL AS SG_VT_DSCR
	, (SELECT LU_VT.TBL_LABEL FROM TBL_LOOKUP LU_VT WHERE LU_VT.TBL_ID = SG.SG_VT_ID AND ROWNUM = 1) AS SG_VT_DSCR
	, SG.SG_SAT_ID
	--, LU_SAT.TBL_LABEL AS SG_SAT_DSCR
	, (SELECT LU_SAT.TBL_LABEL FROM TBL_LOOKUP LU_SAT WHERE LU_SAT.TBL_ID = SG.SG_SAT_ID AND ROWNUM = 1) AS SG_SAT_DSCR
	, SG.SG_SO_ID
	--, LU_MEMSO.NAME AS SG_SO_NAME
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = SG.SG_SO_ID AND ROWNUM = 1)  AS SG_SO_NAME
	, SG.SG_SO_TITLE
	, SG.SG_SO_ORG
	, SG.SG_XO_ID
	--, LU_MEMXO.NAME AS SG_XO_NAME
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = SG.SG_XO_ID AND ROWNUM = 1)  AS SG_XO_NAME
	, SG.SG_XO_TITLE
	, SG.SG_XO_ORG
	, SG.SG_HRL_ID
	--, LU_MEMHL.NAME AS SG_HL_NAME
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = SG.SG_HRL_ID AND ROWNUM = 1)  AS SG_HL_NAME
	, SG.SG_HRL_TITLE
	, SG.SG_HRL_ORG
	, SG.SG_SS_ID
	--, LU_MEMSS.NAME AS SG_SS_NAME
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = SG.SG_SS_ID AND ROWNUM = 1)  AS SG_SS_NAME
	, SG.SG_CS_ID
	--, LU_MEMCS.NAME AS SG_CS_NAME
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = SG.SG_CS_ID AND ROWNUM = 1)  AS SG_CS_NAME
	, CASE WHEN SG.SG_SO_AGREE = '1' THEN 'Yes' ELSE 'No' END AS SG_SO_AGREE
	, SG.SG_OTHER_CERT
	, FN_GET_MEMBER_DSCR(SG.SG_OTHER_CERT) AS SG_OTHER_CERT_DSCR

	, POS.POS_CNDT_LAST_NM
	, POS.POS_CNDT_FIRST_NM
	, POS.POS_CNDT_MIDDLE_NM
	, CASE WHEN POS.POS_BGT_APR_OFM = '1' THEN 'Yes' WHEN POS.POS_BGT_APR_OFM = '0' THEN 'No' ELSE 'N/A' END AS POS_BGT_APR_OFM
	, POS.POS_SPNSR_ORG_NM
	, POS.POS_SPNSR_ORG_FUND_PC
	, POS.POS_TITLE
	, POS.POS_PAY_PLAN_ID
	--, LU_PYPL.TBL_NAME AS POS_PAY_PLAN_DSCR
	, (SELECT LU_PYPL.TBL_NAME FROM TBL_LOOKUP LU_PYPL WHERE LU_PYPL.TBL_ID = POS.POS_PAY_PLAN_ID AND ROWNUM = 1) AS POS_PAY_PLAN_DSCR
	, POS.POS_SERIES
	, POS.POS_DESC_NUMBER_1
	, POS.POS_CLASSIFICATION_DT_1
	, POS.POS_GRADE_1
	, POS.POS_DESC_NUMBER_2
	, POS.POS_CLASSIFICATION_DT_2
	, POS.POS_GRADE_2
	, POS.POS_DESC_NUMBER_3
	, POS.POS_CLASSIFICATION_DT_3
	, POS.POS_GRADE_3
	, POS.POS_DESC_NUMBER_4
	, POS.POS_CLASSIFICATION_DT_4
	, POS.POS_GRADE_4
	, POS.POS_DESC_NUMBER_5
	, POS.POS_CLASSIFICATION_DT_5
	, POS.POS_GRADE_5
	, POS.POS_MED_OFFICERS_ID
	--, LU_MO.TBL_LABEL AS POS_MED_OFFICERS_DSCR
	, (SELECT LU_MO.TBL_LABEL FROM TBL_LOOKUP LU_MO WHERE LU_MO.TBL_ID = POS.POS_MED_OFFICERS_ID AND ROWNUM = 1) AS POS_MED_OFFICERS_DSCR
	, POS.POS_PERFORMANCE_LEVEL
	, POS.POS_SUPERVISORY
	--, LU_SUP.TBL_LABEL AS POS_SUPERVISORY_DSCR
	, (SELECT LU_SUP.TBL_LABEL FROM TBL_LOOKUP LU_SUP WHERE LU_SUP.TBL_ID = TO_NUMBER(POS.POS_SUPERVISORY) AND ROWNUM = 1) AS POS_SUPERVISORY_DSCR
	, POS.POS_SKILL
	, POS.POS_LOCATION
	--, LU_LOC.LOC_CITY || ', ' || LU_LOC.LOC_STATE AS POS_LOCATION_DSCR
	, FN_GET_LOCATION_DSCR(POS.POS_LOCATION) AS POS_LOCATION_DSCR
	, POS.POS_VACANCIES
	, POS.POS_REPORT_SUPERVISOR
	--, LU_MEMRS.NAME AS POS_REPORT_SUPERVISOR_NAME
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = POS.POS_REPORT_SUPERVISOR AND ROWNUM = 1)  AS POS_REPORT_SUPERVISOR_NAME
	, POS.POS_CAN
	, CASE WHEN POS.POS_VICE = '1' THEN 'Yes' ELSE 'No' END AS POS_VICE
	, POS.POS_VICE_NAME
	, POS.POS_DAYS_ADVERTISED
	, POS.POS_AT_ID
	--, LU_ADT.TBL_LABEL AS POS_AT_DSCR
	, (SELECT LU_ADT.TBL_LABEL FROM TBL_LOOKUP LU_ADT WHERE LU_ADT.TBL_ID = POS.POS_AT_ID AND ROWNUM = 1) AS POS_AT_DSCR
	, POS.POS_NTE
	, POS.POS_WORK_SCHED_ID
	--, LU_WSCHD.TBL_LABEL AS POS_WORK_SCHED_DSCR
	, (SELECT LU_WSCHD.TBL_LABEL FROM TBL_LOOKUP LU_WSCHD WHERE LU_WSCHD.TBL_ID = POS.POS_WORK_SCHED_ID AND ROWNUM = 1) AS POS_WORK_SCHED_DSCR
	, POS.POS_HOURS_PER_WEEK
	, CASE WHEN POS.POS_DUAL_EMPLMT = '1' THEN 'Yes' WHEN POS.POS_DUAL_EMPLMT = '0' THEN 'No' ELSE NULL END AS POS_DUAL_EMPLMT
	, POS.POS_SEC_ID
	--, LU_SEC.TBL_LABEL AS POS_SEC_DSCR
	, (SELECT LU_SEC.TBL_LABEL FROM TBL_LOOKUP LU_SEC WHERE LU_SEC.TBL_ID = POS.POS_SEC_ID AND ROWNUM = 1) AS POS_SEC_DSCR
	, CASE WHEN POS.POS_CE_FINANCIAL_DISC = '1' THEN 'Yes' ELSE 'No' END AS POS_CE_FINANCIAL_DISC
	, POS.POS_CE_FINANCIAL_TYPE_ID
	--, LU_FNTP.TBL_LABEL AS POS_CE_FINANCIAL_TYPE_DSCR
	, (SELECT LU_FNTP.TBL_LABEL FROM TBL_LOOKUP LU_FNTP WHERE LU_FNTP.TBL_ID = POS.POS_CE_FINANCIAL_TYPE_ID AND ROWNUM = 1) AS POS_CE_FINANCIAL_TYPE_DSCR
	, CASE WHEN POS.POS_CE_PE_PHYSICAL = '1' THEN 'Yes' ELSE 'No' END AS POS_CE_PE_PHYSICAL
	, CASE WHEN POS.POS_CE_DRUG_TEST = '1' THEN 'Yes' ELSE 'No' END AS POS_CE_DRUG_TEST
	, CASE WHEN POS.POS_CE_IMMUN = '1' THEN 'Yes' ELSE 'No' END AS POS_CE_IMMUN
	, CASE WHEN POS.POS_CE_TRAVEL = '1' THEN 'Yes' ELSE 'No' END AS POS_CE_TRAVEL
	, POS.POS_CE_TRAVEL_PER
	, CASE WHEN POS.POS_CE_LIC = '1' THEN 'Yes' ELSE 'No' END AS POS_CE_LIC
	, POS.POS_CE_LIC_INFO
	, POS.POS_REMARKS
	, POS.POS_PROC_REQ_TYPE
	, POS.POS_RECRUIT_OFFICE_ID
	--, POS.POS_REQ_CREATE_NOTIFY_DT
	, POS.POS_SO_ID
	, POS.POS_ASSOC_DESCR_NUMBERS
	, POS.POS_PROMOTE_POTENTIAL
	, POS.POS_VICE_EMPL_ID
	, POS.POS_SR_ID
	, POS.POS_GR_ID
	, POS.POS_AC_ID
	, CASE WHEN POS.POS_GA_1  = '1' THEN 'Yes' ELSE 'No' END AS POS_GA_1
	, CASE WHEN POS.POS_GA_2  = '1' THEN 'Yes' ELSE 'No' END AS POS_GA_2
	, CASE WHEN POS.POS_GA_3  = '1' THEN 'Yes' ELSE 'No' END AS POS_GA_3
	, CASE WHEN POS.POS_GA_4  = '1' THEN 'Yes' ELSE 'No' END AS POS_GA_4
	, CASE WHEN POS.POS_GA_5  = '1' THEN 'Yes' ELSE 'No' END AS POS_GA_5
	, CASE WHEN POS.POS_GA_6  = '1' THEN 'Yes' ELSE 'No' END AS POS_GA_6
	, CASE WHEN POS.POS_GA_7  = '1' THEN 'Yes' ELSE 'No' END AS POS_GA_7
	, CASE WHEN POS.POS_GA_8  = '1' THEN 'Yes' ELSE 'No' END AS POS_GA_8
	, CASE WHEN POS.POS_GA_9  = '1' THEN 'Yes' ELSE 'No' END AS POS_GA_9
	, CASE WHEN POS.POS_GA_10 = '1' THEN 'Yes' ELSE 'No' END AS POS_GA_10
	, CASE WHEN POS.POS_GA_11 = '1' THEN 'Yes' ELSE 'No' END AS POS_GA_11
	, CASE WHEN POS.POS_GA_12 = '1' THEN 'Yes' ELSE 'No' END AS POS_GA_12
	, CASE WHEN POS.POS_GA_13 = '1' THEN 'Yes' ELSE 'No' END AS POS_GA_13
	, CASE WHEN POS.POS_GA_14 = '1' THEN 'Yes' ELSE 'No' END AS POS_GA_14
	, CASE WHEN POS.POS_GA_15 = '1' THEN 'Yes' ELSE 'No' END AS POS_GA_15

	, FN_GET_GRADE_ADVRT(POS.POS_GA_1, POS.POS_GA_2, POS.POS_GA_3, POS.POS_GA_4, POS.POS_GA_5
		 , POS.POS_GA_6, POS.POS_GA_7, POS.POS_GA_8, POS.POS_GA_9, POS.POS_GA_10
		 , POS.POS_GA_11, POS.POS_GA_12, POS.POS_GA_13, POS.POS_GA_14, POS.POS_GA_15)
	AS POS_GA

	, CASE WHEN AOC.AOC_30PCT_DISABLED_VETS = '1' THEN 'Yes' ELSE 'No' END AS AOC_30PCT_DISABLED_VETS
	, CASE WHEN AOC.AOC_EXPERT_CONS = '1'         THEN 'Yes' ELSE 'No' END AS AOC_EXPERT_CONS
	, CASE WHEN AOC.AOC_IPA = '1'                 THEN 'Yes' ELSE 'No' END AS AOC_IPA
	, CASE WHEN AOC.AOC_OPER_WARFIGHTER = '1'     THEN 'Yes' ELSE 'No' END AS AOC_OPER_WARFIGHTER
	, CASE WHEN AOC.AOC_DISABILITIES = '1'        THEN 'Yes' ELSE 'No' END AS AOC_DISABILITIES
	, CASE WHEN AOC.AOC_STUDENT_VOL = '1'         THEN 'Yes' ELSE 'No' END AS AOC_STUDENT_VOL
	, CASE WHEN AOC.AOC_VETS_RECRUIT_APPT = '1'   THEN 'Yes' ELSE 'No' END AS AOC_VETS_RECRUIT_APPT
	, CASE WHEN AOC.AOC_VOC_REHAB_EMPL = '1'      THEN 'Yes' ELSE 'No' END AS AOC_VOC_REHAB_EMPL
	, CASE WHEN AOC.AOC_WORKFORCE_RECRUIT = '1'   THEN 'Yes' ELSE 'No' END AS AOC_WORKFORCE_RECRUIT
	, AOC.AOC_NON_COMP_APPL
	, CASE WHEN AOC.AOC_MIL_SPOUSES = '1'         THEN 'Yes' ELSE 'No' END AS AOC_MIL_SPOUSES
	, CASE WHEN AOC.AOC_DIRECT_HIRE = '1'         THEN 'Yes' ELSE 'No' END AS AOC_DIRECT_HIRE
	, CASE WHEN AOC.AOC_RE_EMPLOYMENT = '1'       THEN 'Yes' ELSE 'No' END AS AOC_RE_EMPLOYMENT
	, CASE WHEN AOC.AOC_PATHWAYS = '1'            THEN 'Yes' ELSE 'No' END AS AOC_PATHWAYS
	, CASE WHEN AOC.AOC_PEACE_CORPS_VOL = '1'     THEN 'Yes' ELSE 'No' END AS AOC_PEACE_CORPS_VOL
	, CASE WHEN AOC.AOC_REINSTATEMENT = '1'       THEN 'Yes' ELSE 'No' END AS AOC_REINSTATEMENT
	, CASE WHEN AOC.AOC_SHARED_CERT = '1'         THEN 'Yes' ELSE 'No' END AS AOC_SHARED_CERT
	, CASE WHEN AOC.AOC_DELEGATE_EXAM = '1'       THEN 'Yes' ELSE 'No' END AS AOC_DELEGATE_EXAM
	, CASE WHEN AOC.AOC_DH_US_CITIZENS = '1'      THEN 'Yes' ELSE 'No' END AS AOC_DH_US_CITIZENS
	, CASE WHEN AOC.AOC_MP_GOV_WIDE = '1'         THEN 'Yes' ELSE 'No' END AS AOC_MP_GOV_WIDE
	, CASE WHEN AOC.AOC_MP_HHS_ONLY = '1'         THEN 'Yes' ELSE 'No' END AS AOC_MP_HHS_ONLY
	, CASE WHEN AOC.AOC_MP_CMS_ONLY = '1'         THEN 'Yes' ELSE 'No' END AS AOC_MP_CMS_ONLY
	, CASE WHEN AOC.AOC_MP_COMP_CONS_ONLY = '1'   THEN 'Yes' ELSE 'No' END AS AOC_MP_COMP_CONS_ONLY
	, CASE WHEN AOC.AOC_MP_I_CTAP_VEGA = '1'      THEN 'Yes' ELSE 'No' END AS AOC_MP_I_CTAP_VEGA
	, AOC.AOC_NON_BARGAIN_DOC_RATIONALE

	, FN_GET_ANNOUNCE_NOT_REQ(AOC.AOC_30PCT_DISABLED_VETS
		, AOC.AOC_EXPERT_CONS
		, AOC.AOC_IPA
		, AOC.AOC_OPER_WARFIGHTER
		, AOC.AOC_DISABILITIES
		, AOC.AOC_STUDENT_VOL
		, AOC.AOC_VETS_RECRUIT_APPT
		, AOC.AOC_VOC_REHAB_EMPL
		, AOC.AOC_WORKFORCE_RECRUIT)
	AS AOC_ANNOUNCE_NOT_REQ
	, FN_GET_ANNOUNCE_REQ(AOC.AOC_MIL_SPOUSES
		, AOC.AOC_DIRECT_HIRE
		, AOC.AOC_RE_EMPLOYMENT
		, AOC.AOC_PATHWAYS
		, AOC.AOC_PEACE_CORPS_VOL
		, AOC.AOC_REINSTATEMENT
		, AOC.AOC_SHARED_CERT)
	AS AOC_ANNOUNCE_REQ
	, FN_GET_ANNOUNCE_TYPE(AOC.AOC_DELEGATE_EXAM
		, AOC.AOC_DH_US_CITIZENS
		, AOC.AOC_MP_GOV_WIDE
		, AOC.AOC_MP_HHS_ONLY
		, AOC.AOC_MP_CMS_ONLY
		, AOC.AOC_MP_COMP_CONS_ONLY
		, AOC.AOC_MP_I_CTAP_VEGA)
	AS AOC_ANNOUNCE_TYPE

	, CASE WHEN SME.SME_FOR_JOB_ANALYSIS = '1'  THEN 'Yes' ELSE 'No' END AS SME_FOR_JOB_ANALYSIS
	, SME.SME_NAME_JA
	, SME.SME_EMAIL_JA
	, CASE WHEN SME.SME_FOR_QUALIFICATION = '1' THEN 'Yes' ELSE 'No' END AS SME_FOR_QUALIFICATION
	, SME.SME_NAME_QUAL_1
	, SME.SME_EMAIL_QUAL_1
	, SME.SME_NAME_QUAL_2
	, SME.SME_EMAIL_QUAL_2

	, CASE WHEN JA.JA_SEL_FACTOR_REQ = '1'   THEN 'Yes' ELSE 'No' END AS JA_SEL_FACTOR_REQ
	, JA.JA_SEL_FACTOR_JUST
	, CASE WHEN JA.JA_QUAL_RANK_REQ = '1'    THEN 'Yes' ELSE 'No' END AS JA_QUAL_RANK_REQ
	, JA.JA_QUAL_RANK_JUST
	, CASE WHEN JA.JA_RESPONSES_REQ = '1'    THEN 'Yes' ELSE 'No' END AS JA_RESPONSES_REQ
	, CASE WHEN JA.JA_TYPE_YES_NO = '1'      THEN 'Yes' ELSE 'No' END AS JA_TYPE_YES_NO
	, CASE WHEN JA.JA_TYPE_REQ_DEFAULT = '1' THEN 'Yes' ELSE 'No' END AS JA_TYPE_REQ_DEFAULT
	, CASE WHEN JA.JA_TYPE_KNOWL_SCALE = '1' THEN 'Yes' ELSE 'No' END AS JA_TYPE_KNOWL_SCALE

	, FN_GET_ASSESS_TYPE(JA.JA_TYPE_YES_NO
		, JA.JA_TYPE_REQ_DEFAULT
		, JA.JA_TYPE_KNOWL_SCALE)
	AS JA_ASSESS_TYPE

	, RI.RI_OA_APRV_ITEM
	, CASE
		WHEN RI.RI_OA_APRV_ITEM = 'C' THEN 'Recruitment'
		WHEN RI.RI_OA_APRV_ITEM = 'L' THEN 'Relocation'
		ELSE 'N/A'
	END AS RI_OA_APRV_ITEM_DSCR
	, CASE WHEN RI.RI_MOVING_EXP_AUTH = '1' THEN 'Yes' ELSE 'No' END AS RI_MOVING_EXP_AUTH

	, CASE WHEN TR.TR_PAID_AD = '1' THEN 'Yes' ELSE 'No' END AS TR_PAID_AD
	, TR.TR_PAID_AD_SPEC
	, FN_GET_LOOKUP_DSCR(TR.TR_PAID_AD_SPEC) AS TR_PAID_AD_SPEC_DSCR
	, TR.TR_PAID_AD_SPEC_OTHR
	, CASE WHEN TR.TR_SCHL_PSTG = '1' THEN 'Yes' ELSE 'No' END AS TR_SCHL_PSTG
	, TR.TR_SCHL_PSTG_SPEC
	, FN_GET_LOOKUP_DSCR(TR.TR_SCHL_PSTG_SPEC) AS TR_SCHL_PSTG_SPEC_DSCR
	, TR.TR_SCHL_PSTG_SPEC_OTHR
	, CASE WHEN TR.TR_SOCIAL_MEDIA = '1' THEN 'Yes' ELSE 'No' END AS TR_SOCIAL_MEDIA
	, TR.TR_SOCIAL_MEDIA_SPEC
	, FN_GET_LOOKUP_DSCR(TR.TR_SOCIAL_MEDIA_SPEC) AS TR_SOCIAL_MEDIA_SPEC_DSCR
	, TR.TR_SOCIAL_MEDIA_SPEC_OTHR
	, CASE WHEN TR.TR_OTHER = '1' THEN 'Yes' ELSE 'No' END AS TR_OTHER
	, TR.TR_OTHER_SPEC

	, SCA.SCA_SO_SIG
	, SCA.SCA_SO_SIG_DT
	, SCA.SCA_CLASS_SPEC_SIG
	, SCA.SCA_CLASS_SPEC_SIG_DT
	, SCA.SCA_STAFF_SIG
	, SCA.SCA_STAFF_SIG_DT

FROM
	REQUEST R
	LEFT OUTER JOIN STRATCON_GEN SG ON SG.SG_REQ_ID = R.REQ_ID
	LEFT OUTER JOIN POSITION POS ON POS.POS_REQ_ID = R.REQ_ID
	--LEFT OUTER JOIN STRATCON_SCHED_HIST SSH ON SSH.SSH_REQ_ID = R.REQ_ID
	LEFT OUTER JOIN AREAS_OF_CONS AOC ON AOC.AOC_REQ_ID = R.REQ_ID
	LEFT OUTER JOIN SME_INFO SME ON SME.SME_REQ_ID = R.REQ_ID
	LEFT OUTER JOIN JOB_ANALYSIS JA ON JA.JA_REQ_ID = R.REQ_ID
	LEFT OUTER JOIN RECRUIT_INCENTIVES RI ON RI.RI_REQ_ID = R.REQ_ID
	LEFT OUTER JOIN TARGET_RECRUIT TR ON TR.TR_REQ_ID = R.REQ_ID
	LEFT OUTER JOIN APPROVALS SCA ON SCA.SCA_REQ_ID = R.REQ_ID

	--LEFT OUTER JOIN ADMIN_CODES LU_AC ON LU_AC.AC_ID = SG.SG_AC_ID
	--LEFT OUTER JOIN ADMIN_CODES LU_AC ON LU_AC.AC_ADMIN_CD = SG.SG_ADMIN_CD
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_1 ON LU_SO_1.AC_ADMIN_CD = FN_GET_SUBORG_CD(SG.SG_ADMIN_CD, 1)
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_2 ON LU_SO_2.AC_ADMIN_CD = FN_GET_SUBORG_CD(SG.SG_ADMIN_CD, 2)
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_3 ON LU_SO_3.AC_ADMIN_CD = FN_GET_SUBORG_CD(SG.SG_ADMIN_CD, 3)
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_4 ON LU_SO_4.AC_ADMIN_CD = FN_GET_SUBORG_CD(SG.SG_ADMIN_CD, 4)
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_5 ON LU_SO_5.AC_ADMIN_CD = FN_GET_SUBORG_CD(SG.SG_ADMIN_CD, 5)
    
	--LEFT OUTER JOIN TBL_LOOKUP LU_RT ON LU_RT.TBL_ID = SG.SG_RT_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_CT ON LU_CT.TBL_ID = SG.SG_CT_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_AT ON LU_AT.TBL_ID = SG.SG_AT_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_VT ON LU_VT.TBL_ID = SG.SG_VT_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_SAT ON LU_SAT.TBL_ID = SG.SG_SAT_ID
    
	--LEFT OUTER JOIN BIZFLOW.MEMBER LU_MEMSO ON LU_MEMSO.MEMBERID = SG.SG_SO_ID
	--LEFT OUTER JOIN BIZFLOW.MEMBER LU_MEMXO ON LU_MEMXO.MEMBERID = SG.SG_XO_ID
	--LEFT OUTER JOIN BIZFLOW.MEMBER LU_MEMHL ON LU_MEMHL.MEMBERID = SG.SG_HRL_ID
	--LEFT OUTER JOIN BIZFLOW.MEMBER LU_MEMSS ON LU_MEMSS.MEMBERID = SG.SG_SS_ID
	--LEFT OUTER JOIN BIZFLOW.MEMBER LU_MEMCS ON LU_MEMCS.MEMBERID = SG.SG_CS_ID

	--LEFT OUTER JOIN TBL_LOOKUP LU_PYPL ON LU_PYPL.TBL_ID = POS.POS_PAY_PLAN_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_MO ON LU_MO.TBL_ID = POS.POS_MED_OFFICERS_ID
--TODO: Remove TO_NUMBER call once the data type of POS_SUPERVISORY is fixed to NUMBER(20)
	--LEFT OUTER JOIN TBL_LOOKUP LU_SUP ON LU_SUP.TBL_ID = TO_NUMBER(POS.POS_SUPERVISORY)
	--LEFT OUTER JOIN LOCATION LU_LOC ON LU_LOC.LOC_ID = POS.POS_LOCATION
	--LEFT OUTER JOIN BIZFLOW.MEMBER LU_MEMRS ON LU_MEMRS.MEMBERID = POS.POS_REPORT_SUPERVISOR
	--LEFT OUTER JOIN TBL_LOOKUP LU_ADT ON LU_ADT.TBL_ID = POS.POS_AT_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_WSCHD ON LU_WSCHD.TBL_ID = POS.POS_WORK_SCHED_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_SEC ON LU_SEC.TBL_ID = POS.POS_SEC_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_FNTP ON LU_FNTP.TBL_ID = POS.POS_CE_FINANCIAL_TYPE_ID
;

/




--------------------------------------------------------
--  DDL for VW_CLASSIFICATION
--------------------------------------------------------
CREATE OR REPLACE VIEW VW_CLASSIFICATION
AS
SELECT
	R.REQ_ID
	, R.REQ_JOB_REQ_NUMBER
	, R.REQ_JOB_REQ_CREATE_DT
	, R.REQ_STATUS_ID
	, R.REQ_CANCEL_DT
	, R.REQ_CANCEL_REASON

	, CS.CS_TITLE
	, CS.CS_PAY_PLAN_ID
	--, LU_PYPL.TBL_NAME AS CS_PAY_PLAN_DSCR
	, (SELECT LU_PYPL.TBL_NAME FROM TBL_LOOKUP LU_PYPL WHERE LU_PYPL.TBL_ID = CS.CS_PAY_PLAN_ID AND ROWNUM = 1) AS CS_PAY_PLAN_DSCR
	, CS.CS_SR_ID
	--, LU_SR.TBL_LABEL AS CS_SR_DSCR
	, (SELECT LU_SR.TBL_LABEL FROM TBL_LOOKUP LU_SR WHERE LU_SR.TBL_ID = CS.CS_SR_ID AND ROWNUM = 1) AS CS_SR_DSCR
	, CS.CS_PD_NUMBER_JOBCD_1
	, CS.CS_CLASSIFICATION_DT_1
	, CS.CS_GR_ID_1
	, CS.CS_FLSA_DETERM_ID_1
	--, LU_FLSA_1.TBL_LABEL AS CS_FLSA_DETERM_DSCR_1
	, (SELECT LU_FLSA.TBL_LABEL FROM TBL_LOOKUP LU_FLSA WHERE LU_FLSA.TBL_ID = CS.CS_FLSA_DETERM_ID_1 AND ROWNUM = 1) AS CS_FLSA_DETERM_DSCR_1
	, CS.CS_PD_NUMBER_JOBCD_2
	, CS.CS_CLASSIFICATION_DT_2
	, CS.CS_GR_ID_2
	, CS.CS_FLSA_DETERM_ID_2
	--, LU_FLSA_2.TBL_LABEL AS CS_FLSA_DETERM_DSCR_2
	, (SELECT LU_FLSA.TBL_LABEL FROM TBL_LOOKUP LU_FLSA WHERE LU_FLSA.TBL_ID = CS.CS_FLSA_DETERM_ID_2 AND ROWNUM = 1) AS CS_FLSA_DETERM_DSCR_2
	, CS.CS_PD_NUMBER_JOBCD_3
	, CS.CS_CLASSIFICATION_DT_3
	, CS.CS_GR_ID_3
	, CS.CS_FLSA_DETERM_ID_3
	--, LU_FLSA_3.TBL_LABEL AS CS_FLSA_DETERM_DSCR_3
	, (SELECT LU_FLSA.TBL_LABEL FROM TBL_LOOKUP LU_FLSA WHERE LU_FLSA.TBL_ID = CS.CS_FLSA_DETERM_ID_3 AND ROWNUM = 1) AS CS_FLSA_DETERM_DSCR_3
	, CS.CS_PD_NUMBER_JOBCD_4
	, CS.CS_CLASSIFICATION_DT_4
	, CS.CS_GR_ID_4
	, CS.CS_FLSA_DETERM_ID_4
	--, LU_FLSA_4.TBL_LABEL AS CS_FLSA_DETERM_DSCR_4
	, (SELECT LU_FLSA.TBL_LABEL FROM TBL_LOOKUP LU_FLSA WHERE LU_FLSA.TBL_ID = CS.CS_FLSA_DETERM_ID_4 AND ROWNUM = 1) AS CS_FLSA_DETERM_DSCR_4
	, CS.CS_PD_NUMBER_JOBCD_5
	, CS.CS_CLASSIFICATION_DT_5
	, CS.CS_GR_ID_5
	, CS.CS_FLSA_DETERM_ID_5
	--, LU_FLSA_5.TBL_LABEL AS CS_FLSA_DETERM_DSCR_5
	, (SELECT LU_FLSA.TBL_LABEL FROM TBL_LOOKUP LU_FLSA WHERE LU_FLSA.TBL_ID = CS.CS_FLSA_DETERM_ID_5 AND ROWNUM = 1) AS CS_FLSA_DETERM_DSCR_5
	, CS.CS_PERFORMANCE_LEVEL
	, CS.CS_SUPERVISORY
	--, LU_SUP.TBL_LABEL AS CS_SUPERVISORY_DSCR
	, (SELECT LU_SUP.TBL_LABEL FROM TBL_LOOKUP LU_SUP WHERE LU_SUP.TBL_ID = CS.CS_SUPERVISORY AND ROWNUM = 1) AS CS_SUPERVISORY_DSCR
	, CS.CS_AC_ID
	--, LU_AC.AC_ADMIN_CD AS CS_AC_CD
	--, LU_AC.AC_ADMIN_CD_DESCR AS CS_AC_DSCR
	, CS.CS_ADMIN_CD AS CS_ADMIN_CD
	--, LU_AC.AC_ADMIN_CD_DESCR AS CS_ADMIN_CD_DSCR
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = CS_ADMIN_CD AND ROWNUM = 1) AS CS_ADMIN_CD_DSCR
	, CS.CS_FIN_STMT_REQ_ID
	--, LU_FNTP.TBL_LABEL AS CS_FIN_STMT_REQ_DSCR
	, (SELECT LU_FNTP.TBL_LABEL FROM TBL_LOOKUP LU_FNTP WHERE LU_FNTP.TBL_ID = CS.CS_FIN_STMT_REQ_ID AND ROWNUM = 1) AS CS_FIN_STMT_REQ_DSCR
	, CS.CS_SEC_ID
	--, LU_SEC.TBL_LABEL AS CS_SEC_DSCR
	, (SELECT LU_SEC.TBL_LABEL FROM TBL_LOOKUP LU_SEC WHERE LU_SEC.TBL_ID = CS.CS_SEC_ID AND ROWNUM = 1) AS CS_SEC_DSCR
	, PD.PD_ID
	, PD.PD_PROCID
	, PD.PD_ORG_POS_TITLE
	, PD.PD_EMPLOYING_OFFICE
	--, LU_EO.TBL_LABEL AS PD_EMPLOYING_OFFICE_DSCR
	, (SELECT LU_EO.TBL_LABEL FROM TBL_LOOKUP LU_EO WHERE LU_EO.TBL_ID = PD.PD_EMPLOYING_OFFICE AND ROWNUM = 1) AS PD_EMPLOYING_OFFICE_DSCR
	, CASE WHEN PD.PD_SUBJECT_IA = '1' THEN 'Yes' ELSE 'No' END AS PD_SUBJECT_IA
	, PD.PD_ORGANIZATION
	, PD.PD_SUB_ORG_1
	--, LU_SO_1.AC_ADMIN_CD_DESCR AS PD_SUB_ORG_DSCR_1
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = PD_SUB_ORG_1 AND ROWNUM = 1) AS PD_SUB_ORG_DSCR_1
	, PD.PD_SUB_ORG_2
	--, LU_SO_2.AC_ADMIN_CD_DESCR AS PD_SUB_ORG_DSCR_2
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = PD_SUB_ORG_2 AND ROWNUM = 1) AS PD_SUB_ORG_DSCR_2
	, PD.PD_SUB_ORG_3
	--, LU_SO_3.AC_ADMIN_CD_DESCR AS PD_SUB_ORG_DSCR_3
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = PD_SUB_ORG_3 AND ROWNUM = 1) AS PD_SUB_ORG_DSCR_3
	, PD.PD_SUB_ORG_4
	--, LU_SO_4.AC_ADMIN_CD_DESCR AS PD_SUB_ORG_DSCR_4
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = PD_SUB_ORG_4 AND ROWNUM = 1) AS PD_SUB_ORG_DSCR_4
	, PD.PD_SUB_ORG_5
	--, LU_SO_5.AC_ADMIN_CD_DESCR AS PD_SUB_ORG_DSCR_5
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = PD_SUB_ORG_5 AND ROWNUM = 1) AS PD_SUB_ORG_DSCR_5
	, PD.PD_SCOPE
	, CASE WHEN PD.PD_PCA = '1'        THEN 'Yes' ELSE 'No' END AS PD_PCA
	, CASE WHEN PD.PD_PDP = '1'        THEN 'Yes' ELSE 'No' END AS PD_PDP
	, CASE WHEN PD.PD_FTT = '1'        THEN 'Yes' ELSE 'No' END AS PD_FTT
	, CASE WHEN PD.PD_OUTSTATION = '1' THEN 'Yes' ELSE 'No' END AS PD_OUTSTATION
	, CASE WHEN PD.PD_INCUMBENCY = '1' THEN 'Yes' ELSE 'No' END AS PD_INCUMBENCY
	, PD.PD_REMARKS
	, PD.PD_CLS_STANDARDS
	, FN_GET_LOOKUP_DSCR(PD.PD_CLS_STANDARDS) AS PD_CLS_STANDARDS_DSCR
	, PD.PD_ACQ_CODE
	--, LU_ACQ.TBL_NAME AS PD_ACQ_CODE_DSCR
	, (SELECT LU_ACQ.TBL_NAME FROM TBL_LOOKUP LU_ACQ WHERE LU_ACQ.TBL_ID = PD.PD_ACQ_CODE AND ROWNUM = 1) AS PD_ACQ_CODE_DSCR
	, PD.PD_CYB_SEC_CD
	--, LU_CSEC.TBL_LABEL AS PD_CYB_SEC_CD_DSCR
	, (SELECT LU_CSEC.TBL_LABEL FROM TBL_LOOKUP LU_CSEC WHERE LU_CSEC.TBL_ID = PD.PD_CYB_SEC_CD AND ROWNUM = 1) AS PD_CYB_SEC_CD_DSCR
	, PD.PD_COMPET_LVL_CD
	, PD.PD_BUS_CD
	--, LU_BUS.TBL_LABEL AS PD_BUS_CD_DSCR
	, (SELECT LU_BUS.TBL_LABEL FROM TBL_LOOKUP LU_BUS WHERE LU_BUS.TBL_ID = PD.PD_BUS_CD AND ROWNUM = 1) AS PD_BUS_CD_DSCR
	, PD.BYPASS_DWC_FL

	, CASE WHEN PD.PD_SUPV_CERT = '1' THEN 'Yes' ELSE 'No' END AS PD_SUPV_CERT
	, PD.PD_SUPV_NAME
	, PD.PD_SUPV_TITLE
	, PD.PD_SUPV_SIG
	, PD.PD_SUPV_SIG_DT
	, CASE WHEN PD.PD_CLS_SPEC_CERT = '1' THEN 'Yes' ELSE 'No' END AS PD_CLS_SPEC_CERT
	, PD.PD_CLS_SPEC_NAME
	, PD.PD_CLS_SPEC_TITLE
	, PD.PD_CLS_SPEC_SIG
	, PD.PD_CLS_SPEC_DT

	, CASE WHEN FLSA.FLSA_EX_EXEC = '1'            THEN 'Yes' ELSE 'No' END AS FLSA_EX_EXEC
	, CASE WHEN FLSA.FLSA_EX_ADMIN = '1'           THEN 'Yes' ELSE 'No' END AS FLSA_EX_ADMIN
	, CASE WHEN FLSA.FLSA_EX_PROF_LEARNED = '1'    THEN 'Yes' ELSE 'No' END AS FLSA_EX_PROF_LEARNED
	, CASE WHEN FLSA.FLSA_EX_PROF_CREATIVE = '1'   THEN 'Yes' ELSE 'No' END AS FLSA_EX_PROF_CREATIVE
	, CASE WHEN FLSA.FLSA_EX_PROF_COMPUTER = '1'   THEN 'Yes' ELSE 'No' END AS FLSA_EX_PROF_COMPUTER
	, CASE WHEN FLSA.FLSA_EX_LAW_ENFORC = '1'      THEN 'Yes' ELSE 'No' END AS FLSA_EX_LAW_ENFORC
	, CASE WHEN FLSA.FLSA_EX_FOREIGN = '1'         THEN 'Yes' ELSE 'No' END AS FLSA_EX_FOREIGN
	, FLSA.FLSA_EX_REMARKS
	, CASE WHEN FLSA.FLSA_NONEX_SALARY = '1'       THEN 'Yes' ELSE 'No' END AS FLSA_NONEX_SALARY
	, CASE WHEN FLSA.FLSA_NONEX_EQUIP_OPER = '1'   THEN 'Yes' ELSE 'No' END AS FLSA_NONEX_EQUIP_OPER
	, CASE WHEN FLSA.FLSA_NONEX_TECHN = '1'        THEN 'Yes' ELSE 'No' END AS FLSA_NONEX_TECHN
	, CASE WHEN FLSA.FLSA_NONEX_FED_WAGE_SYS = '1' THEN 'Yes' ELSE 'No' END AS FLSA_NONEX_FED_WAGE_SYS
	, FLSA.FLSA_NONEX_REMARKS

FROM
	REQUEST R
	LEFT OUTER JOIN CLASSIF_STRATCON CS ON CS.CS_REQ_ID = R.REQ_ID
	LEFT OUTER JOIN PD_COVERSHEET PD ON PD.PD_REQ_ID = R.REQ_ID
	LEFT OUTER JOIN FLSA FLSA ON FLSA.FLSA_PD_ID = PD.PD_ID

	--LEFT OUTER JOIN TBL_LOOKUP LU_PYPL ON LU_PYPL.TBL_ID = CS.CS_PAY_PLAN_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_SR ON LU_SR.TBL_ID = CS.CS_SR_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_FLSA_1 ON LU_FLSA_1.TBL_ID = CS.CS_FLSA_DETERM_ID_1
	--LEFT OUTER JOIN TBL_LOOKUP LU_FLSA_2 ON LU_FLSA_2.TBL_ID = CS.CS_FLSA_DETERM_ID_2
	--LEFT OUTER JOIN TBL_LOOKUP LU_FLSA_3 ON LU_FLSA_3.TBL_ID = CS.CS_FLSA_DETERM_ID_3
	--LEFT OUTER JOIN TBL_LOOKUP LU_FLSA_4 ON LU_FLSA_4.TBL_ID = CS.CS_FLSA_DETERM_ID_4
	--LEFT OUTER JOIN TBL_LOOKUP LU_FLSA_5 ON LU_FLSA_5.TBL_ID = CS.CS_FLSA_DETERM_ID_5
	--LEFT OUTER JOIN TBL_LOOKUP LU_SUP ON LU_SUP.TBL_ID = CS.CS_SUPERVISORY
	--LEFT OUTER JOIN ADMIN_CODES LU_AC ON LU_AC.AC_ID = CS.CS_AC_ID
	--LEFT OUTER JOIN ADMIN_CODES LU_AC ON LU_AC.AC_ADMIN_CD = CS.CS_ADMIN_CD
	--LEFT OUTER JOIN TBL_LOOKUP LU_FNTP ON LU_FNTP.TBL_ID = CS.CS_FIN_STMT_REQ_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_SEC ON LU_SEC.TBL_ID = CS.CS_SEC_ID

	--LEFT OUTER JOIN TBL_LOOKUP LU_EO ON LU_EO.TBL_ID = PD.PD_EMPLOYING_OFFICE
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_1 ON LU_SO_1.AC_ADMIN_CD = PD.PD_SUB_ORG_1
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_2 ON LU_SO_2.AC_ADMIN_CD = PD.PD_SUB_ORG_2
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_3 ON LU_SO_3.AC_ADMIN_CD = PD.PD_SUB_ORG_3
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_4 ON LU_SO_4.AC_ADMIN_CD = PD.PD_SUB_ORG_4
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_5 ON LU_SO_5.AC_ADMIN_CD = PD.PD_SUB_ORG_5
	--LEFT OUTER JOIN TBL_LOOKUP LU_ACQ ON LU_ACQ.TBL_ID = PD.PD_ACQ_CODE
	--LEFT OUTER JOIN TBL_LOOKUP LU_CSEC ON LU_CSEC.TBL_ID = PD.PD_CYB_SEC_CD
	--LEFT OUTER JOIN TBL_LOOKUP LU_BUS ON LU_BUS.TBL_ID = PD.PD_BUS_CD

;

/




--------------------------------------------------------
--  DDL for VW_ELIGQUAL
--------------------------------------------------------
CREATE OR REPLACE VIEW VW_ELIGQUAL
AS
SELECT
	R.REQ_ID
	, R.REQ_JOB_REQ_NUMBER
	, R.REQ_JOB_REQ_CREATE_DT
	, R.REQ_STATUS_ID
	, R.REQ_CANCEL_DT
	, R.REQ_CANCEL_REASON

	, EQ.ELIGQUAL_ID
	, EQ.PROCID
	, EQ.ADMIN_CD AS ADMIN_CD
	--, LU_AC.AC_ADMIN_CD_DESCR AS ADMIN_CD_DSCR
	--, LU_SO_1.AC_ADMIN_CD AS SUB_ORG_1_CD
	--, LU_SO_1.AC_ADMIN_CD_DESCR AS SUB_ORG_1_DSCR
	--, LU_SO_2.AC_ADMIN_CD AS SUB_ORG_2_CD
	--, LU_SO_2.AC_ADMIN_CD_DESCR AS SUB_ORG_2_DSCR
	--, LU_SO_3.AC_ADMIN_CD AS SUB_ORG_3_CD
	--, LU_SO_3.AC_ADMIN_CD_DESCR AS SUB_ORG_3_DSCR
	--, LU_SO_4.AC_ADMIN_CD AS SUB_ORG_4_CD
	--, LU_SO_4.AC_ADMIN_CD_DESCR AS SUB_ORG_4_DSCR
	--, LU_SO_5.AC_ADMIN_CD AS SUB_ORG_5_CD
	--, LU_SO_5.AC_ADMIN_CD_DESCR AS SUB_ORG_5_DSCR
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = EQ.ADMIN_CD AND ROWNUM = 1) AS ADMIN_CD_DSCR
	, FN_GET_SUBORG_CD(EQ.ADMIN_CD, 1) AS SUB_ORG_1_CD
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = FN_GET_SUBORG_CD(EQ.ADMIN_CD, 1) AND ROWNUM = 1) AS SUB_ORG_1_DSCR
	, FN_GET_SUBORG_CD(EQ.ADMIN_CD, 2) AS SUB_ORG_2_CD
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = FN_GET_SUBORG_CD(EQ.ADMIN_CD, 2) AND ROWNUM = 1) AS SUB_ORG_2_DSCR
	, FN_GET_SUBORG_CD(EQ.ADMIN_CD, 3) AS SUB_ORG_3_CD
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = FN_GET_SUBORG_CD(EQ.ADMIN_CD, 3) AND ROWNUM = 1) AS SUB_ORG_3_DSCR
	, FN_GET_SUBORG_CD(EQ.ADMIN_CD, 4) AS SUB_ORG_4_CD
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = FN_GET_SUBORG_CD(EQ.ADMIN_CD, 4) AND ROWNUM = 1) AS SUB_ORG_4_DSCR
	, FN_GET_SUBORG_CD(EQ.ADMIN_CD, 5) AS SUB_ORG_5_CD
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = FN_GET_SUBORG_CD(EQ.ADMIN_CD, 5) AND ROWNUM = 1) AS SUB_ORG_5_DSCR
	, EQ.RT_ID
	--, LU_RT.TBL_LABEL AS RT_DSCR
	, (SELECT LU_RT.TBL_LABEL FROM TBL_LOOKUP LU_RT WHERE LU_RT.TBL_ID = EQ.RT_ID AND ROWNUM = 1) AS RT_DSCR
	, EQ.AT_ID
	--, LU_AT.TBL_LABEL AS AT_DSCR
	, (SELECT LU_AT.TBL_LABEL FROM TBL_LOOKUP LU_AT WHERE LU_AT.TBL_ID = EQ.AT_ID AND ROWNUM = 1) AS AT_DSCR
	, EQ.VT_ID
	--, LU_VT.TBL_LABEL AS VT_DSCR
	, (SELECT LU_VT.TBL_LABEL FROM TBL_LOOKUP LU_VT WHERE LU_VT.TBL_ID = EQ.VT_ID AND ROWNUM = 1) AS VT_DSCR
	, EQ.SAT_ID
	--, LU_SAT.TBL_LABEL AS SAT_DSCR
	, (SELECT LU_SAT.TBL_LABEL FROM TBL_LOOKUP LU_SAT WHERE LU_SAT.TBL_ID = EQ.SAT_ID AND ROWNUM = 1)  AS SAT_DSCR
	, EQ.CT_ID
	--, LU_CT.TBL_LABEL AS CT_DSCR
	, (SELECT LU_CT.TBL_LABEL FROM TBL_LOOKUP LU_CT WHERE LU_CT.TBL_ID = EQ.CT_ID AND ROWNUM = 1)  AS CT_DSCR
	, EQ.SO_ID
	--, LU_MEMSO.NAME AS SO_NAME
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = EQ.SO_ID AND ROWNUM = 1)  AS SO_NAME
	, EQ.SO_TITLE
	, EQ.SO_ORG
	, EQ.XO_ID
	--, LU_MEMXO.NAME AS XO_NAME
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = EQ.XO_ID AND ROWNUM = 1)  AS XO_NAME
	, EQ.XO_TITLE
	, EQ.XO_ORG
	, EQ.HRL_ID
	--, LU_MEMHL.NAME AS HL_NAME
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = EQ.HRL_ID AND ROWNUM = 1)  AS HL_NAME
	, EQ.HRL_TITLE
	, EQ.HRL_ORG
	, EQ.SS_ID
	--, LU_MEMSS.NAME AS SS_NAME
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = EQ.SS_ID AND ROWNUM = 1)  AS SS_NAME
	, EQ.CS_ID
	--, LU_MEMCS.NAME AS CS_NAME
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = EQ.CS_ID AND ROWNUM = 1)  AS CS_NAME
	, CASE WHEN EQ.SO_AGREE = '1' THEN 'Yes' ELSE 'No' END AS SO_AGREE
	, EQ.OTHER_CERT
	, FN_GET_MEMBER_DSCR(EQ.OTHER_CERT) AS OTHER_CERT_DSCR

	, EQ.CNDT_LAST_NM
	, EQ.CNDT_FIRST_NM
	, EQ.CNDT_MIDDLE_NM
	, CASE WHEN EQ.BGT_APR_OFM = '1' THEN 'Yes' WHEN EQ.BGT_APR_OFM = '0' THEN 'No' ELSE 'N/A' END AS BGT_APR_OFM
	, EQ.SPNSR_ORG_NM
	, EQ.SPNSR_ORG_FUND_PC
	, EQ.POS_TITLE
	, EQ.PAY_PLAN_ID
	--, LU_PYPL.TBL_NAME AS PAY_PLAN_DSCR
	, (SELECT LU_PYPL.TBL_NAME FROM TBL_LOOKUP LU_PYPL WHERE LU_PYPL.TBL_ID = EQ.PAY_PLAN_ID AND ROWNUM = 1)  AS PAY_PLAN_DSCR
	, EQ.SERIES
	, EQ.POS_DESC_NUMBER_1
	, EQ.CLASSIFICATION_DT_1
	, EQ.GRADE_1
	, EQ.POS_DESC_NUMBER_2
	, EQ.CLASSIFICATION_DT_2
	, EQ.GRADE_2
	, EQ.POS_DESC_NUMBER_3
	, EQ.CLASSIFICATION_DT_3
	, EQ.GRADE_3
	, EQ.POS_DESC_NUMBER_4
	, EQ.CLASSIFICATION_DT_4
	, EQ.GRADE_4
	, EQ.POS_DESC_NUMBER_5
	, EQ.CLASSIFICATION_DT_5
	, EQ.GRADE_5
	, EQ.MED_OFFICERS_ID
	--, LU_MO.TBL_LABEL AS MED_OFFICERS_DSCR
	, (SELECT  LU_MO.TBL_LABEL FROM TBL_LOOKUP LU_MO WHERE LU_MO.TBL_ID = EQ.MED_OFFICERS_ID AND ROWNUM = 1)  AS MED_OFFICERS_DSCR
	, EQ.PERFORMANCE_LEVEL
	, EQ.SUPERVISORY
	--, LU_SUP.TBL_LABEL AS SUPERVISORY_DSCR
	, (SELECT LU_SUP.TBL_LABEL FROM TBL_LOOKUP LU_SUP WHERE LU_SUP.TBL_ID = EQ.SUPERVISORY AND ROWNUM = 1)  AS SUPERVISORY_DSCR
	, EQ.SKILL
	, EQ.LOCATION
	--, LU_LOC.LOC_CITY || ', ' || LU_LOC.LOC_STATE AS LOCATION_DSCR
	, FN_GET_LOCATION_DSCR(EQ.LOCATION) AS LOCATION_DSCR
	, EQ.VACANCIES
	, EQ.REPORT_SUPERVISOR
	--, LU_MEMRS.NAME AS REPORT_SUPERVISOR_NAME
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = EQ.REPORT_SUPERVISOR AND ROWNUM = 1)  AS REPORT_SUPERVISOR_NAME
	, EQ.CAN
	, CASE WHEN EQ.VICE = '1' THEN 'Yes' ELSE 'No' END AS VICE
	, EQ.VICE_NAME
	, EQ.DAYS_ADVERTISED
	, EQ.TA_ID
	--, LU_ADT.TBL_LABEL AS TA_DSCR
	, (SELECT LU_ADT.TBL_LABEL FROM TBL_LOOKUP LU_ADT WHERE LU_ADT.TBL_ID = EQ.TA_ID AND ROWNUM = 1)  AS TA_DSCR
	, EQ.NTE
	, EQ.WORK_SCHED_ID
	--, LU_WSCHD.TBL_LABEL AS WORK_SCHED_DSCR
	, (SELECT LU_WSCHD.TBL_LABEL FROM TBL_LOOKUP LU_WSCHD WHERE LU_WSCHD.TBL_ID = EQ.WORK_SCHED_ID AND ROWNUM = 1)  AS WORK_SCHED_DSCR
	, EQ.HOURS_PER_WEEK
	, CASE WHEN EQ.DUAL_EMPLMT = '1' THEN 'Yes' WHEN EQ.DUAL_EMPLMT = '0' THEN 'No' ELSE NULL END AS DUAL_EMPLMT
	, EQ.SEC_ID
	--, LU_SEC.TBL_LABEL AS SEC_DSCR
	, (SELECT LU_SEC.TBL_LABEL FROM TBL_LOOKUP LU_SEC WHERE LU_SEC.TBL_ID = EQ.SEC_ID AND ROWNUM = 1)  AS SEC_DSCR
	, CASE WHEN EQ.CE_FINANCIAL_DISC = '1' THEN 'Yes' ELSE 'No' END AS CE_FINANCIAL_DISC
	, EQ.CE_FINANCIAL_TYPE_ID
	--, LU_FNTP.TBL_LABEL AS CE_FINANCIAL_TYPE_DSCR
	, (SELECT LU_FNTP.TBL_LABEL FROM TBL_LOOKUP LU_FNTP WHERE LU_FNTP.TBL_ID = EQ.CE_FINANCIAL_TYPE_ID AND ROWNUM = 1)  AS CE_FINANCIAL_TYPE_DSCR
	, CASE WHEN EQ.CE_PE_PHYSICAL = '1' THEN 'Yes' ELSE 'No' END AS CE_PE_PHYSICAL
	, CASE WHEN EQ.CE_DRUG_TEST = '1' THEN 'Yes' ELSE 'No' END AS CE_DRUG_TEST
	, CASE WHEN EQ.CE_IMMUN = '1' THEN 'Yes' ELSE 'No' END AS CE_IMMUN
	, CASE WHEN EQ.CE_TRAVEL = '1' THEN 'Yes' ELSE 'No' END AS CE_TRAVEL
	, EQ.CE_TRAVEL_PER
	, CASE WHEN EQ.CE_LIC = '1' THEN 'Yes' ELSE 'No' END AS CE_LIC
	, EQ.CE_LIC_INFO
	, EQ.REMARKS
	, EQ.PROC_REQ_TYPE
	, EQ.RECRUIT_OFFICE_ID
	, EQ.ASSOC_DESCR_NUMBERS
	, EQ.PROMOTE_POTENTIAL
	, EQ.VICE_EMPL_ID
	, EQ.SR_ID
	, EQ.GR_ID
	, CASE WHEN EQ.GA_1  = '1' THEN 'Yes' ELSE 'No' END AS GA_1
	, CASE WHEN EQ.GA_2  = '1' THEN 'Yes' ELSE 'No' END AS GA_2
	, CASE WHEN EQ.GA_3  = '1' THEN 'Yes' ELSE 'No' END AS GA_3
	, CASE WHEN EQ.GA_4  = '1' THEN 'Yes' ELSE 'No' END AS GA_4
	, CASE WHEN EQ.GA_5  = '1' THEN 'Yes' ELSE 'No' END AS GA_5
	, CASE WHEN EQ.GA_6  = '1' THEN 'Yes' ELSE 'No' END AS GA_6
	, CASE WHEN EQ.GA_7  = '1' THEN 'Yes' ELSE 'No' END AS GA_7
	, CASE WHEN EQ.GA_8  = '1' THEN 'Yes' ELSE 'No' END AS GA_8
	, CASE WHEN EQ.GA_9  = '1' THEN 'Yes' ELSE 'No' END AS GA_9
	, CASE WHEN EQ.GA_10 = '1' THEN 'Yes' ELSE 'No' END AS GA_10
	, CASE WHEN EQ.GA_11 = '1' THEN 'Yes' ELSE 'No' END AS GA_11
	, CASE WHEN EQ.GA_12 = '1' THEN 'Yes' ELSE 'No' END AS GA_12
	, CASE WHEN EQ.GA_13 = '1' THEN 'Yes' ELSE 'No' END AS GA_13
	, CASE WHEN EQ.GA_14 = '1' THEN 'Yes' ELSE 'No' END AS GA_14
	, CASE WHEN EQ.GA_15 = '1' THEN 'Yes' ELSE 'No' END AS GA_15

	, FN_GET_GRADE_ADVRT(EQ.GA_1, EQ.GA_2, EQ.GA_3, EQ.GA_4, EQ.GA_5
		 , EQ.GA_6, EQ.GA_7, EQ.GA_8, EQ.GA_9, EQ.GA_10
		 , EQ.GA_11, EQ.GA_12, EQ.GA_13, EQ.GA_14, EQ.GA_15)
	AS GA

	, EQ.CNDT_ELIGIBLE
	, EQ.INELIG_REASON
	--, LU_IER.TBL_LABEL AS INELIG_REASON_DSCR
	, (SELECT LU_IER.TBL_LABEL FROM TBL_LOOKUP LU_IER WHERE LU_IER.TBL_ID = EQ.INELIG_REASON AND ROWNUM = 1)  AS INELIG_REASON_DSCR
	, EQ.CNDT_QUALIFIED
	, EQ.DISQUAL_REASON
	--, LU_DQR.TBL_LABEL AS DISQUAL_REASON_DSCR
	, (SELECT LU_DQR.TBL_LABEL FROM TBL_LOOKUP LU_DQR WHERE LU_DQR.TBL_ID = EQ.DISQUAL_REASON AND ROWNUM = 1)  AS DISQUAL_REASON_DSCR
	, EQ.SEL_DETERM
	--, LU_SD.TBL_LABEL AS SEL_DETERM_DSCR
	, (SELECT LU_SD.TBL_LABEL FROM TBL_LOOKUP LU_SD WHERE LU_SD.TBL_ID = EQ.SEL_DETERM AND ROWNUM = 1)  AS SEL_DETERM_DSCR
	, EQ.DCO_CERT
	, EQ.DCO_NAME
	, EQ.DCO_SIG
	, EQ.DCO_SIG_DT

FROM
	REQUEST R
	LEFT OUTER JOIN ELIG_QUAL EQ ON EQ.REQ_ID = R.REQ_ID

	--LEFT OUTER JOIN ADMIN_CODES LU_AC ON LU_AC.AC_ADMIN_CD = EQ.ADMIN_CD
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_1 ON LU_SO_1.AC_ADMIN_CD = FN_GET_SUBORG_CD(EQ.ADMIN_CD, 1)
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_2 ON LU_SO_2.AC_ADMIN_CD = FN_GET_SUBORG_CD(EQ.ADMIN_CD, 2)
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_3 ON LU_SO_3.AC_ADMIN_CD = FN_GET_SUBORG_CD(EQ.ADMIN_CD, 3)
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_4 ON LU_SO_4.AC_ADMIN_CD = FN_GET_SUBORG_CD(EQ.ADMIN_CD, 4)
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_5 ON LU_SO_5.AC_ADMIN_CD = FN_GET_SUBORG_CD(EQ.ADMIN_CD, 5)
    
	--LEFT OUTER JOIN TBL_LOOKUP LU_RT ON LU_RT.TBL_ID = EQ.RT_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_CT ON LU_CT.TBL_ID = EQ.CT_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_AT ON LU_AT.TBL_ID = EQ.AT_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_VT ON LU_VT.TBL_ID = EQ.VT_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_SAT ON LU_SAT.TBL_ID = EQ.SAT_ID
    
	--LEFT OUTER JOIN BIZFLOW.MEMBER LU_MEMSO ON LU_MEMSO.MEMBERID = EQ.SO_ID
	--LEFT OUTER JOIN BIZFLOW.MEMBER LU_MEMXO ON LU_MEMXO.MEMBERID = EQ.XO_ID
	--LEFT OUTER JOIN BIZFLOW.MEMBER LU_MEMHL ON LU_MEMHL.MEMBERID = EQ.HRL_ID
	--LEFT OUTER JOIN BIZFLOW.MEMBER LU_MEMSS ON LU_MEMSS.MEMBERID = EQ.SS_ID
	--LEFT OUTER JOIN BIZFLOW.MEMBER LU_MEMCS ON LU_MEMCS.MEMBERID = EQ.CS_ID

	--LEFT OUTER JOIN TBL_LOOKUP LU_PYPL ON LU_PYPL.TBL_ID = EQ.PAY_PLAN_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_MO ON LU_MO.TBL_ID = EQ.MED_OFFICERS_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_SUP ON LU_SUP.TBL_ID = EQ.SUPERVISORY
	--LEFT OUTER JOIN LOCATION LU_LOC ON LU_LOC.LOC_ID = EQ.LOCATION
	--LEFT OUTER JOIN BIZFLOW.MEMBER LU_MEMRS ON LU_MEMRS.MEMBERID = EQ.REPORT_SUPERVISOR
	--LEFT OUTER JOIN TBL_LOOKUP LU_ADT ON LU_ADT.TBL_ID = EQ.TA_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_WSCHD ON LU_WSCHD.TBL_ID = EQ.WORK_SCHED_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_SEC ON LU_SEC.TBL_ID = EQ.SEC_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_FNTP ON LU_FNTP.TBL_ID = EQ.CE_FINANCIAL_TYPE_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_SD ON LU_SD.TBL_ID = EQ.SEL_DETERM
	--LEFT OUTER JOIN TBL_LOOKUP LU_IER ON LU_IER.TBL_ID = EQ.INELIG_REASON
	--LEFT OUTER JOIN TBL_LOOKUP LU_DQR ON LU_DQR.TBL_ID = EQ.DISQUAL_REASON
;

/
