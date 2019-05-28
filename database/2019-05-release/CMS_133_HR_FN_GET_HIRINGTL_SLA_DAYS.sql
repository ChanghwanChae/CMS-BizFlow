create or replace FUNCTION            FN_GET_HIRINGTL_SLA_DAYS 
  (
    I_START_DATE IN DATE,
    I_DAYSTYPE IN VARCHAR2, 
    I_REQUESTTYPE IN VARCHAR2,
    I_SLAACTNAME IN VARCHAR2, 
    I_MAJOR_MINOR IN VARCHAR2
  )
RETURN DATE 
IS
V_DAYSTOTARGETCOMPLETION DATE;

  BEGIN

    IF I_MAJOR_MINOR IS NOT NULL THEN 
      IF I_DAYSTYPE = 'Calendar' THEN
          SELECT I_START_DATE + (SELECT TOTAL_CALENDAR_DAY FROM HHS_CMS_HR.SLA_HIRING_TIMELINE SLA 
            INNER JOIN HHS_CMS_HR.TBL_LOOKUP LKUP ON LKUP.TBL_ID = SLA.SG_RT_ID
            WHERE SLA.ACTIVITY_NAME like '%'||I_SLAACTNAME||'%'
            AND LKUP.TBL_LABEL = I_REQUESTTYPE AND SLA.PROCESS_NAME like '%'||I_MAJOR_MINOR||'%') INTO V_DAYSTOTARGETCOMPLETION FROM DUAL;
            
      ELSE 
            SELECT BIZFLOW.HHS_FN_ADD_BUSDAY(I_START_DATE,(SELECT TARGET_BUSINESS_DAY FROM HHS_CMS_HR.SLA_HIRING_TIMELINE SLA 
            INNER JOIN HHS_CMS_HR.TBL_LOOKUP LKUP ON LKUP.TBL_ID = SLA.SG_RT_ID
            WHERE SLA.ACTIVITY_NAME like '%'||I_SLAACTNAME||'%'
            AND LKUP.TBL_LABEL = I_REQUESTTYPE AND SLA.PROCESS_NAME like '%'||I_MAJOR_MINOR||'%')) INTO V_DAYSTOTARGETCOMPLETION FROM DUAL;
      END IF;
    ELSE
          IF I_DAYSTYPE = 'Calendar' THEN
              SELECT I_START_DATE + (SELECT TOTAL_CALENDAR_DAY FROM HHS_CMS_HR.SLA_HIRING_TIMELINE SLA 
            INNER JOIN HHS_CMS_HR.TBL_LOOKUP LKUP ON LKUP.TBL_ID = SLA.SG_RT_ID
                WHERE SLA.ACTIVITY_NAME like '%'||I_SLAACTNAME||'%'
                AND LKUP.TBL_LABEL = I_REQUESTTYPE) INTO V_DAYSTOTARGETCOMPLETION FROM DUAL;
          ELSE
                SELECT BIZFLOW.HHS_FN_ADD_BUSDAY(I_START_DATE,(SELECT TARGET_BUSINESS_DAY FROM HHS_CMS_HR.SLA_HIRING_TIMELINE SLA 
                INNER JOIN HHS_CMS_HR.TBL_LOOKUP LKUP ON LKUP.TBL_ID = SLA.SG_RT_ID WHERE SLA.ACTIVITY_NAME like '%'||I_SLAACTNAME||'%' AND LKUP.TBL_LABEL = I_REQUESTTYPE)) INTO V_DAYSTOTARGETCOMPLETION FROM DUAL;
          END IF;      
    
    END IF;
    RETURN V_DAYSTOTARGETCOMPLETION;
  END;


GRANT EXECUTE ON HHS_CMS_HR.FN_GET_HIRINGTL_SLA_DAYS TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.FN_GET_HIRINGTL_SLA_DAYS TO HHS_CMS_HR_DEV_ROLE;