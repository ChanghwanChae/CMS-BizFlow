

--=============================================================================
-- Grant privileges on objects under CMS schema to roles
-------------------------------------------------------------------------------

-- privilege for BIZFLOW;

GRANT SELECT, UPDATE ON HHS_CMS_HR.UG_MAPPING TO BIZFLOW;
GRANT EXECUTE ON HHS_CMS_HR.FN_GET_USER_GROUP_NAME TO BIZFLOW;
GRANT EXECUTE ON HHS_CMS_HR.FN_GET_USER_GROUP_KEY TO BIZFLOW;





-- privilege for HHS_CMS_HR_RW_ROLE;

GRANT SELECT, INSERT, UPDATE, DELETE ON HHS_CMS_HR.ERROR_LOG TO HHS_CMS_HR_RW_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON HHS_CMS_HR.TBL_FORM_DTL TO HHS_CMS_HR_RW_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON HHS_CMS_HR.TBL_FORM_DTL_AUDIT TO HHS_CMS_HR_RW_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON HHS_CMS_HR.TBL_LOOKUP TO HHS_CMS_HR_RW_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON HHS_CMS_HR.UG_MAPPING TO HHS_CMS_HR_RW_ROLE;

GRANT EXECUTE ON HHS_CMS_HR.SP_ERROR_LOG TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_FORM_DATA TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_STRATCON TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_STRATCON_DATA TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_STRATCONHIST_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_STRATCON_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_CLSF TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_CLSF_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_FILL_STRATCON_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_FILL_CLSF_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.FN_INIT_CLASSIFICATION TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INIT_CLSF TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_ELIGQUAL TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.FN_INIT_ELIGQUAL TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INIT_ELIGQUAL TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_ELIGQUAL_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_ERLR TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_INCENTIVES TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.FN_GET_USER_GROUP_NAME TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.FN_GET_USER_GROUP_KEY TO HHS_CMS_HR_RW_ROLE;


-- privilege for HHS_CMS_HR_DEV_ROLE;

GRANT SELECT, INSERT, UPDATE, DELETE ON HHS_CMS_HR.ERROR_LOG TO HHS_CMS_HR_DEV_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON HHS_CMS_HR.TBL_FORM_DTL TO HHS_CMS_HR_DEV_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON HHS_CMS_HR.TBL_FORM_DTL_AUDIT TO HHS_CMS_HR_DEV_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON HHS_CMS_HR.TBL_LOOKUP TO HHS_CMS_HR_DEV_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON HHS_CMS_HR.UG_MAPPING TO HHS_CMS_HR_DEV_ROLE;

GRANT EXECUTE ON HHS_CMS_HR.SP_ERROR_LOG TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_FORM_DATA TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_STRATCON TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_STRATCON_DATA TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_STRATCONHIST_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_STRATCON_TABLE TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_CLSF TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_CLSF_TABLE TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_FILL_STRATCON_TABLE TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_FILL_CLSF_TABLE TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.FN_INIT_CLASSIFICATION TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INIT_CLSF TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_ELIGQUAL TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.FN_INIT_ELIGQUAL TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INIT_ELIGQUAL TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_ELIGQUAL_TABLE TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_ERLR TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_INCENTIVES TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.FN_GET_USER_GROUP_NAME TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.FN_GET_USER_GROUP_KEY TO HHS_CMS_HR_DEV_ROLE;
