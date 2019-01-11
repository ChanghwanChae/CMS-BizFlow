CREATE OR REPLACE PROCEDURE SP_UPDATE_INCENTIVES_SAM_TABLE
(
	I_PROCID            IN      NUMBER
)
IS
	l_count	int;
BEGIN
	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN 
		SELECT count(*) INTO l_count FROM VW_INCENTIVES_SAM WHERE PROC_ID = I_PROCID;
		IF 0 < l_count THEN
			MERGE INTO INCENTIVES_SAM t
			USING ( SELECT * FROM VW_INCENTIVES_SAM WHERE PROC_ID = I_PROCID ) v
			ON (t.PROC_ID = v.PROC_ID)
			WHEN MATCHED THEN
				UPDATE 
				SET t.COC_NAME = v.COC_NAME,
					t.COC_EMAIL = v.COC_EMAIL,
					t.COC_ID = v.COC_ID,
					t.COC_TITLE = v.COC_TITLE,
					t.INIT_SALARY_GRADE = v.INIT_SALARY_GRADE,
					t.INIT_SALARY_STEP = v.INIT_SALARY_STEP,
					t.INIT_SALARY_SALARY_PER_ANNUM = v.INIT_SALARY_SALARY_PER_ANNUM,
					t.INIT_SALARY_LOCALITY_PAY_SCALE = v.INIT_SALARY_LOCALITY_PAY_SCALE,
					t.SUPPORT_SAM = v.SUPPORT_SAM,
					t.RCMD_SALARY_GRADE = v.RCMD_SALARY_GRADE,
					t.RCMD_SALARY_STEP = v.RCMD_SALARY_STEP,
					t.RCMD_SALARY_SALARY_PER_ANNUM = v.RCMD_SALARY_SALARY_PER_ANNUM,
					t.RCMD_SALARY_LOCALITY_PAY_SCALE = v.RCMD_SALARY_LOCALITY_PAY_SCALE,
					t.SELECTEE_SALARY_PER_ANNUM = v.SELECTEE_SALARY_PER_ANNUM,
					t.SELECTEE_SALARY_TYPE = v.SELECTEE_SALARY_TYPE,
					t.SELECTEE_BONUS = v.SELECTEE_BONUS,
					t.SELECTEE_BENEFITS = v.SELECTEE_BENEFITS,
					t.SELECTEE_TOTAL_COMPENSATION = v.SELECTEE_TOTAL_COMPENSATION,
					t.SUP_DOC_REQ_DATE = v.SUP_DOC_REQ_DATE,
					t.SUP_DOC_RCV_DATE = v.SUP_DOC_RCV_DATE,
					t.JUSTIFICATION_CRT_NAME = v.JUSTIFICATION_CRT_NAME,
					t.JUSTIFICATION_CRT_ID = v.JUSTIFICATION_CRT_ID,
					t.JUSTIFICATION_MOD_REASON = v.JUSTIFICATION_MOD_REASON,
					t.JUSTIFICATION_MOD_SUMMARY = v.JUSTIFICATION_MOD_SUMMARY,
					t.JUSTIFICATION_MODIFIER_NAME = v.JUSTIFICATION_MODIFIER_NAME,
					t.JUSTIFICATION_MODIFIER_ID = v.JUSTIFICATION_MODIFIER_ID,
					t.JUSTIFICATION_MODIFIED_DATE = v.JUSTIFICATION_MODIFIED_DATE,
					t.JUSTIFICATION_SUPER_QUAL_DESC = v.JUSTIFICATION_SUPER_QUAL_DESC,
					t.JUSTIFICATION_QUAL_COMP_DESC = v.JUSTIFICATION_QUAL_COMP_DESC,
					t.JUSTIFICATION_PAY_EQUITY_DESC = v.JUSTIFICATION_PAY_EQUITY_DESC,
					t.JUSTIFICATION_EXIST_PKG_DESC = v.JUSTIFICATION_EXIST_PKG_DESC,
					t.JUSTIFICATION_EXPLAIN_CONSID = v.JUSTIFICATION_EXPLAIN_CONSID,
					t.SELECT_MEET_ELIGIBILITY = v.SELECT_MEET_ELIGIBILITY,
					t.SELECT_MEET_CRITERIA = v.SELECT_MEET_CRITERIA,
					t.SUPERIOR_QUAL_REASON = v.SUPERIOR_QUAL_REASON,
					t.OTHER_FACTORS = v.OTHER_FACTORS,
					t.SPL_AGENCY_NEED_RSN = v.SPL_AGENCY_NEED_RSN,
					t.SPL_AGENCY_NEED_RSN_ESS = v.SPL_AGENCY_NEED_RSN_ESS,
					t.QUAL_REAPPT = v.QUAL_REAPPT,
					t.OTHER_EXCEPTS = v.OTHER_EXCEPTS,
					t.BASIC_PAY_RATE_FACTOR1 = v.BASIC_PAY_RATE_FACTOR1,
					t.BASIC_PAY_RATE_FACTOR2 = v.BASIC_PAY_RATE_FACTOR2,
					t.BASIC_PAY_RATE_FACTOR3 = v.BASIC_PAY_RATE_FACTOR3,
					t.BASIC_PAY_RATE_FACTOR4 = v.BASIC_PAY_RATE_FACTOR4,
					t.BASIC_PAY_RATE_FACTOR5 = v.BASIC_PAY_RATE_FACTOR5,
					t.BASIC_PAY_RATE_FACTOR6 = v.BASIC_PAY_RATE_FACTOR6,
					t.BASIC_PAY_RATE_FACTOR7 = v.BASIC_PAY_RATE_FACTOR7,
					t.BASIC_PAY_RATE_FACTOR8 = v.BASIC_PAY_RATE_FACTOR8,
					t.BASIC_PAY_RATE_FACTOR9 = v.BASIC_PAY_RATE_FACTOR9,
					t.BASIC_PAY_RATE_FACTOR10 = v.BASIC_PAY_RATE_FACTOR10,
					t.OTHER_RLVNT_FACTOR = v.OTHER_RLVNT_FACTOR,
					t.OTHER_REQ_JUST_APVD = v.OTHER_REQ_JUST_APVD,
					t.OTHER_REQ_SUFF_INFO_PRVD = v.OTHER_REQ_SUFF_INFO_PRVD,
					t.OTHER_REQ_INCEN_REQD = v.OTHER_REQ_INCEN_REQD,
					t.OTHER_REQ_DOC_PRVD = v.OTHER_REQ_DOC_PRVD,
					t.HRS_RVW_CERT = v.HRS_RVW_CERT,
					t.HRS_NOT_SPT_RSN = v.HRS_NOT_SPT_RSN,
					t.RVW_HRS = v.RVW_HRS,
					t.HRS_RVW_DATE = v.HRS_RVW_DATE,
					t.RCMD_GRADE = v.RCMD_GRADE,
					t.RCMD_STEP = v.RCMD_STEP,
					t.RCMD_SALARY_PER_ANNUM = v.RCMD_SALARY_PER_ANNUM,
					t.RCMD_LOCALITY_PAY_SCALE = v.RCMD_LOCALITY_PAY_SCALE,
					t.RCMD_INC_DEC_AMOUNT = v.RCMD_INC_DEC_AMOUNT,
					t.RCMD_PERC_DIFF = v.RCMD_PERC_DIFF,
					t.OHC_APPRO_REQ = v.OHC_APPRO_REQ,
					t.RCMD_APPRO_OHC_NAME = v.RCMD_APPRO_OHC_NAME,
					t.RCMD_APPRO_OHC_EMAIL = v.RCMD_APPRO_OHC_EMAIL,
					t.RCMD_APPRO_OHC_ID = v.RCMD_APPRO_OHC_ID,
					t.RVW_REMARKS = v.RVW_REMARKS,
					t.APPROVAL_SO_VALUE = v.APPROVAL_SO_VALUE,
					t.APPROVAL_SO_ACTING = v.APPROVAL_SO_ACTING,
					t.APPROVAL_SO = v.APPROVAL_SO,
					t.APPROVAL_SO_RESP_DATE = v.APPROVAL_SO_RESP_DATE,
					t.APPROVAL_COC_VALUE = v.APPROVAL_COC_VALUE,
					t.APPROVAL_COC_ACTING = v.APPROVAL_COC_ACTING,
					t.APPROVAL_COC = v.APPROVAL_COC,
					t.APPROVAL_COC_RESP_DATE = v.APPROVAL_COC_RESP_DATE,
					t.APPROVAL_DGHO_VALUE = v.APPROVAL_DGHO_VALUE,
					t.APPROVAL_DGHO_ACTING = v.APPROVAL_DGHO_ACTING,
					t.APPROVAL_DGHO = v.APPROVAL_DGHO,
					t.APPROVAL_DGHO_RESP_DATE = v.APPROVAL_DGHO_RESP_DATE,
					t.APPROVAL_TABG_VALUE = v.APPROVAL_TABG_VALUE,
					t.APPROVAL_TABG_ACTING = v.APPROVAL_TABG_ACTING,
					t.APPROVAL_TABG = v.APPROVAL_TABG,
					t.APPROVAL_TABG_RESP_DATE = v.APPROVAL_TABG_RESP_DATE,
					t.APPROVAL_OHC_VALUE = v.APPROVAL_OHC_VALUE,
					t.APPROVAL_OHC_ACTING = v.APPROVAL_OHC_ACTING,
					t.APPROVAL_OHC = v.APPROVAL_OHC,
					t.APPROVAL_OHC_RESP_DATE = v.APPROVAL_OHC_RESP_DATE,
					t.APPROVER_NOTES = v.APPROVER_NOTES				
			WHEN NOT MATCHED THEN
				INSERT (t.PROC_ID, t.COC_NAME, t.COC_EMAIL, t.COC_ID, t.COC_TITLE, t.INIT_SALARY_GRADE, t.INIT_SALARY_STEP, t.INIT_SALARY_SALARY_PER_ANNUM , t.INIT_SALARY_LOCALITY_PAY_SCALE
					, t.SUPPORT_SAM, t.RCMD_SALARY_GRADE, t.RCMD_SALARY_STEP, t.RCMD_SALARY_SALARY_PER_ANNUM, t.RCMD_SALARY_LOCALITY_PAY_SCALE
					, t.SELECTEE_SALARY_PER_ANNUM, t.SELECTEE_SALARY_TYPE, t.SELECTEE_BONUS, t.SELECTEE_BENEFITS, t.SELECTEE_TOTAL_COMPENSATION
					, t.SUP_DOC_REQ_DATE, t.SUP_DOC_RCV_DATE
					, t.JUSTIFICATION_CRT_NAME, t.JUSTIFICATION_CRT_ID
					, t.JUSTIFICATION_MOD_REASON, t.JUSTIFICATION_MOD_SUMMARY, t.JUSTIFICATION_MODIFIER_NAME, t.JUSTIFICATION_MODIFIER_ID, t.JUSTIFICATION_MODIFIED_DATE
					, t.JUSTIFICATION_SUPER_QUAL_DESC, t.JUSTIFICATION_QUAL_COMP_DESC
					, t.JUSTIFICATION_PAY_EQUITY_DESC, t.JUSTIFICATION_EXIST_PKG_DESC, t.JUSTIFICATION_EXPLAIN_CONSID
					, t.SELECT_MEET_ELIGIBILITY, t.SELECT_MEET_CRITERIA, t.SUPERIOR_QUAL_REASON, t.OTHER_FACTORS, t.SPL_AGENCY_NEED_RSN, t.SPL_AGENCY_NEED_RSN_ESS
					, t.QUAL_REAPPT, t.OTHER_EXCEPTS
					, t.BASIC_PAY_RATE_FACTOR1 , t.BASIC_PAY_RATE_FACTOR2 , t.BASIC_PAY_RATE_FACTOR3 , t.BASIC_PAY_RATE_FACTOR4 , t.BASIC_PAY_RATE_FACTOR5
					, t.BASIC_PAY_RATE_FACTOR6 , t.BASIC_PAY_RATE_FACTOR7 , t.BASIC_PAY_RATE_FACTOR8 , t.BASIC_PAY_RATE_FACTOR9 , t.BASIC_PAY_RATE_FACTOR10
					, t.OTHER_RLVNT_FACTOR, t.OTHER_REQ_JUST_APVD, t.OTHER_REQ_SUFF_INFO_PRVD
					, t.OTHER_REQ_INCEN_REQD, t.OTHER_REQ_DOC_PRVD, t.HRS_RVW_CERT, t.HRS_NOT_SPT_RSN, t.RVW_HRS, t.HRS_RVW_DATE
					, t.RCMD_GRADE, t.RCMD_STEP, t.RCMD_SALARY_PER_ANNUM, t.RCMD_LOCALITY_PAY_SCALE, t.RCMD_INC_DEC_AMOUNT, t.RCMD_PERC_DIFF
					, t.OHC_APPRO_REQ, t.RCMD_APPRO_OHC_NAME, t.RCMD_APPRO_OHC_EMAIL, t.RCMD_APPRO_OHC_ID
					, t.RVW_REMARKS, t.APPROVAL_SO_VALUE, t.APPROVAL_SO_ACTING, t.APPROVAL_SO, t.APPROVAL_SO_RESP_DATE, t.APPROVAL_COC_VALUE, t.APPROVAL_COC_ACTING, t.APPROVAL_COC, t.APPROVAL_COC_RESP_DATE
					, t.APPROVAL_DGHO_VALUE, t.APPROVAL_DGHO_ACTING, t.APPROVAL_DGHO, t.APPROVAL_DGHO_RESP_DATE, t.APPROVAL_TABG_VALUE, t.APPROVAL_TABG_ACTING, t.APPROVAL_TABG, t.APPROVAL_TABG_RESP_DATE
					, t.APPROVAL_OHC_VALUE, t.APPROVAL_OHC_ACTING, t.APPROVAL_OHC, t.APPROVAL_OHC_RESP_DATE, t.APPROVER_NOTES)
					VALUES (v.PROC_ID, v.COC_NAME, v.COC_EMAIL, v.COC_ID, v.COC_TITLE, v.INIT_SALARY_GRADE, v.INIT_SALARY_STEP, v.INIT_SALARY_SALARY_PER_ANNUM , v.INIT_SALARY_LOCALITY_PAY_SCALE
					, v.SUPPORT_SAM, v.RCMD_SALARY_GRADE, v.RCMD_SALARY_STEP, v.RCMD_SALARY_SALARY_PER_ANNUM, v.RCMD_SALARY_LOCALITY_PAY_SCALE
					, v.SELECTEE_SALARY_PER_ANNUM, v.SELECTEE_SALARY_TYPE, v.SELECTEE_BONUS, v.SELECTEE_BENEFITS, v.SELECTEE_TOTAL_COMPENSATION
					, v.SUP_DOC_REQ_DATE, v.SUP_DOC_RCV_DATE
					, v.JUSTIFICATION_CRT_NAME, v.JUSTIFICATION_CRT_ID
					, v.JUSTIFICATION_MOD_REASON, v.JUSTIFICATION_MOD_SUMMARY, v.JUSTIFICATION_MODIFIER_NAME, v.JUSTIFICATION_MODIFIER_ID, v.JUSTIFICATION_MODIFIED_DATE
					, v.JUSTIFICATION_SUPER_QUAL_DESC, v.JUSTIFICATION_QUAL_COMP_DESC
					, v.JUSTIFICATION_PAY_EQUITY_DESC, v.JUSTIFICATION_EXIST_PKG_DESC, v.JUSTIFICATION_EXPLAIN_CONSID
					, v.SELECT_MEET_ELIGIBILITY, v.SELECT_MEET_CRITERIA, v.SUPERIOR_QUAL_REASON, v.OTHER_FACTORS, v.SPL_AGENCY_NEED_RSN, v.SPL_AGENCY_NEED_RSN_ESS
					, v.QUAL_REAPPT, v.OTHER_EXCEPTS
					, v.BASIC_PAY_RATE_FACTOR1 , v.BASIC_PAY_RATE_FACTOR2 , v.BASIC_PAY_RATE_FACTOR3 , v.BASIC_PAY_RATE_FACTOR4 , v.BASIC_PAY_RATE_FACTOR5
					, v.BASIC_PAY_RATE_FACTOR6 , v.BASIC_PAY_RATE_FACTOR7 , v.BASIC_PAY_RATE_FACTOR8 , v.BASIC_PAY_RATE_FACTOR9 , v.BASIC_PAY_RATE_FACTOR10
					, v.OTHER_RLVNT_FACTOR, v.OTHER_REQ_JUST_APVD, v.OTHER_REQ_SUFF_INFO_PRVD
					, v.OTHER_REQ_INCEN_REQD, v.OTHER_REQ_DOC_PRVD, v.HRS_RVW_CERT, v.HRS_NOT_SPT_RSN, v.RVW_HRS, v.HRS_RVW_DATE
					, v.RCMD_GRADE, v.RCMD_STEP, v.RCMD_SALARY_PER_ANNUM, v.RCMD_LOCALITY_PAY_SCALE, v.RCMD_INC_DEC_AMOUNT, v.RCMD_PERC_DIFF
					, v.OHC_APPRO_REQ, v.RCMD_APPRO_OHC_NAME, v.RCMD_APPRO_OHC_EMAIL, v.RCMD_APPRO_OHC_ID
					, v.RVW_REMARKS, v.APPROVAL_SO_VALUE, v.APPROVAL_SO_ACTING, v.APPROVAL_SO, v.APPROVAL_SO_RESP_DATE, v.APPROVAL_COC_VALUE, v.APPROVAL_COC_ACTING, v.APPROVAL_COC, v.APPROVAL_COC_RESP_DATE
					, v.APPROVAL_DGHO_VALUE, v.APPROVAL_DGHO_ACTING, v.APPROVAL_DGHO, v.APPROVAL_DGHO_RESP_DATE, v.APPROVAL_TABG_VALUE, v.APPROVAL_TABG_ACTING, v.APPROVAL_TABG, v.APPROVAL_TABG_RESP_DATE
					, v.APPROVAL_OHC_VALUE, v.APPROVAL_OHC_ACTING, v.APPROVAL_OHC, v.APPROVAL_OHC_RESP_DATE, v.APPROVER_NOTES);
		END IF;
	END IF;

	EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;
/
