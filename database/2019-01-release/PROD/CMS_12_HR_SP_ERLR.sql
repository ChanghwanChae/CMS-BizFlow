-- CMS_19_HR_SP_UPDATE_PV_ERLR.sql
-- CMS_20_HR_SP_INIT_ERLR.sql
-- CMS_21_HR_SP_FINALIZE_ERLR.sql
-- CMS_38_HR_SP_ERLR_EMPLOYEE_CASE_ADD.sql
-- CMS_39_HR_SP_ERLR_EMPLOYEE_CASE_DEL.sql
-- CMS_45_HR_SP_UPDATE_ERLR_FORM_DATA.sql
-- CMS_48_HR_SP_UPDATE_ERLR_TABLE.sql
-- CMS_51_SP_ERLR_CLEAN_PROC_DATA.sql

SET DEFINE OFF;


create or replace PROCEDURE SP_UPDATE_PV_ERLR
  (
      I_PROCID            IN      NUMBER
    , I_FIELD_DATA      IN      XMLTYPE
  )
IS
  V_RLVNTDATANAME        VARCHAR2(100);
  V_VALUE                NVARCHAR2(2000);
  V_VALUE_LOOKUP         NVARCHAR2(2000);
  V_CURRENTDATE          DATE;
  V_CURRENTDATESTR       NVARCHAR2(30);
  V_VALUE_DATE           DATE;
  V_VALUE_DATESTR        NVARCHAR2(30);
  V_XMLVALUE             XMLTYPE;
  V_REQUEST_NUMBER       VARCHAR2(20);
  BEGIN
    --DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
    --DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
    --DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
    --DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA       = ' || I_FIELD_DATA.GETCLOBVAL());
    --DBMS_OUTPUT.PUT_LINE(' ----------------');

    IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
      --DBMS_OUTPUT.PUT_LINE('Starting PV update ----------');

      --SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'caseCategory', '/formData/items/item[id=''CASE_CATEGORY'']/value/text()');
      V_RLVNTDATANAME := 'caseCategory';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id=''GEN_CASE_CATEGORY'']/value/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          -- Case Category is multi-select value, thus multi-value concatenation required
          --SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          --FROM TBL_LOOKUP
          --WHERE TBL_ID = TO_NUMBER(V_VALUE);
          SELECT FN_GET_LOOKUP_DSCR(V_VALUE) INTO V_VALUE_LOOKUP
          FROM DUAL;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      --SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'caseStatus', '/formData/items/item[id=''CASE_STATUS'']/value/text()');
      V_RLVNTDATANAME := 'caseStatus';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id=''GEN_CASE_STATUS'']/value/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      --SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'caseType', '/formData/items/item[id=''CASE_TYPE'']/value/text()');
      V_RLVNTDATANAME := 'caseType';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id=''GEN_CASE_TYPE'']/value/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          WHERE TBL_ID = TO_NUMBER(V_VALUE);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
        
        --- set requestNum ------
        SELECT VALUE INTO V_REQUEST_NUMBER 
          FROM BIZFLOW.RLVNTDATA 
         WHERE RLVNTDATANAME = 'requestNum' 
           AND PROCID = I_PROCID;
        IF V_REQUEST_NUMBER IS NULL THEN
            GET_REQUEST_NUM (V_REQUEST_NUMBER);
            UPDATE BIZFLOW.RLVNTDATA 
               SET VALUE = V_REQUEST_NUMBER
             WHERE RLVNTDATANAME = 'requestNum' 
               AND PROCID = I_PROCID;
        END IF;        
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'contactName', '/formData/items/item[id=''GEN_CUSTOMER_NAME'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'employeeName', '/formData/items/item[id=''GEN_EMPLOYEE_NAME'']/value/text()');


      --SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'initialContactDate', '/formData/items/item[id=''CUSTOMER_CONTACT_DT'']/value/text()');
      V_RLVNTDATANAME := 'initialContactDate';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id=''GEN_CUST_INIT_CONTACT_DT'']/value/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        -------------------------------------
        -- date format and GMT conversion
        -------------------------------------
        V_VALUE := TO_CHAR(SYS_EXTRACT_UTC(TO_DATE(V_VALUE, 'MM/DD/YYYY')), 'YYYY/MM/DD HH24:MI:SS');
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      UPDATE BIZFLOW.RLVNTDATA SET VALUE = TO_CHAR((sys_extract_utc(systimestamp)), 'YYYY/MM/DD HH24:MI:SS') WHERE RLVNTDATANAME = 'lastModifiedDate' AND PROCID = I_PROCID;


      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'organization',           '/formData/items/item[id=''GEN_EMPLOYEE_ADMIN_CD'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'primaryDWCSpecialist',   '/formData/items/item[id=''GEN_PRIMARY_SPECIALIST'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'reassign',               '/formData/items/item[id=''reassign'']/value/text()');      
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requestStatusDate',      '/formData/items/item[id=''REQ_STATUS_DT'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'secondaryDWCSpecialist', '/formData/items/item[id=''GEN_SECONDARY_SPECIALIST'']/value/text()');

      --DBMS_OUTPUT.PUT_LINE('End PV update  -------------------');

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_ERLR -------------------');
  END;
  /
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_ERLR TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_ERLR TO HHS_CMS_HR_DEV_ROLE;
/

create or replace PROCEDURE SP_ERLR_EMPLOYEE_CASE_ADD
(
	I_HHSID IN VARCHAR2,
	I_CASEID IN NUMBER,
    I_CASE_TYPE_ID IN NUMBER,
	I_FROM_CASEID IN NUMBER,
	I_MEMBER_ID IN VARCHAR2 -- MANUALLY ENTERED CASE IF THIS VALUE IS NOT NULL
)
IS
    V_CNT NUMBER;
    V_CASE_TYPE_NAME VARCHAR2(100);
    V_FIRST_NAME VARCHAR2(50);
    V_LAST_NAME VARCHAR2(50);
BEGIN
    SELECT COUNT(*)
      INTO V_CNT
      FROM ERLR_EMPLOYEE_CASE
     WHERE HHSID = I_HHSID
       AND CASEID = I_CASEID;

    IF 0=V_CNT THEN
        SELECT TBL_LABEL
          INTO V_CASE_TYPE_NAME
          FROM TBL_LOOKUP
         WHERE TBL_ID = I_CASE_TYPE_ID;
         
        SELECT FIRST_NAME, LAST_NAME 
          INTO V_FIRST_NAME, V_LAST_NAME 
        FROM HHS_HR.EMPLOYEE_LOOKUP           
        WHERE HHSID = (SELECT XMLQUERY('/formData/items/item[id="GEN_EMPLOYEE_ID"]/value/text()' PASSING FIELD_DATA RETURNING CONTENT).GETSTRINGVAL() 
          FROM TBL_FORM_DTL F JOIN BIZFLOW.RLVNTDATA P ON F.PROCID = P.PROCID AND P.RLVNTDATANAME='caseNumber'
         WHERE P.VALUE = TO_CHAR(I_CASEID));
    
        IF I_MEMBER_ID IS NULL THEN
            INSERT INTO ERLR_EMPLOYEE_CASE(HHSID, CASEID, FROM_CASEID, CASE_TYPE_ID, CASE_TYPE_NAME, EMP_LAST_NAME, EMP_FIRST_NAME)
                                    VALUES(I_HHSID, I_CASEID, I_FROM_CASEID, I_CASE_TYPE_ID, V_CASE_TYPE_NAME, V_LAST_NAME, V_FIRST_NAME);
        ELSE
            INSERT INTO ERLR_EMPLOYEE_CASE(HHSID, CASEID, FROM_CASEID, CASE_TYPE_ID, CASE_TYPE_NAME, EMP_LAST_NAME, EMP_FIRST_NAME, M_DT, M_MEMBER_ID, M_MEMBER_NAME)
            SELECT I_HHSID, I_CASEID, I_FROM_CASEID, I_CASE_TYPE_ID, V_CASE_TYPE_NAME, V_LAST_NAME, V_FIRST_NAME, CAST(SYS_EXTRACT_UTC(SYSTIMESTAMP) AS DATE), I_MEMBER_ID, M.NAME
              FROM BIZFLOW.MEMBER M
             WHERE M.MEMBERID = I_MEMBER_ID;
        END IF;
    END IF;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;
/

GRANT EXECUTE ON HHS_CMS_HR.SP_ERLR_EMPLOYEE_CASE_ADD TO HHS_CMS_HR_RW_ROLE;
/

create or replace PROCEDURE SP_ERLR_EMPLOYEE_CASE_DEL
(
	I_HHSID IN VARCHAR2,
    I_CASEID IN NUMBER
)
IS
    V_CNT NUMBER;
BEGIN

    -- DELETE ONLY MANUALLY ENTERED CASE
    DELETE ERLR_EMPLOYEE_CASE
     WHERE HHSID = I_HHSID
       AND CASEID = I_CASEID
       AND M_DT IS NOT NULL; 
    
EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;
/

GRANT EXECUTE ON HHS_CMS_HR.SP_ERLR_EMPLOYEE_CASE_DEL TO HHS_CMS_HR_RW_ROLE;
/

create or replace PROCEDURE SP_INIT_ERLR
(
	I_PROCID               IN  NUMBER
)
IS
    V_CNT                   INT;    
    V_FROM_PROCID           NUMBER(10);
    V_XMLDOC                XMLTYPE;    
    V_ORG_CASE_NUMBER       NUMBER(10);
    V_CASE_NUMBER           NUMBER(10);    
    V_GEN_EMP_HHSID         VARCHAR2(64);
    V_NEW_CASE_TYPE_ID	    NUMBER(38);
    V_NEW_CASE_TYPE_NAME    VARCHAR2(100);
BEGIN
    SELECT COUNT(1) INTO V_CNT
      FROM TBL_FORM_DTL
     WHERE PROCID = I_PROCID;

    IF V_CNT = 0 THEN
        V_CASE_NUMBER :=  ERLR_CASE_NUMBER_SEQ.NEXTVAL;
        UPDATE BIZFLOW.RLVNTDATA 
           SET VALUE = V_CASE_NUMBER
         WHERE RLVNTDATANAME = 'caseNumber' 
           AND PROCID = I_PROCID;
        
        -- CHECK: TRIGGERED FROM OTHER CASE
        BEGIN
            SELECT TO_NUMBER(VALUE)
              INTO V_FROM_PROCID
              FROM BIZFLOW.RLVNTDATA 
             WHERE RLVNTDATANAME = 'fromProcID' 
               AND PROCID = I_PROCID;
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            V_FROM_PROCID := NULL;
        END;
        
        IF V_FROM_PROCID IS NOT NULL THEN
            SELECT FIELD_DATA
              INTO V_XMLDOC
              FROM TBL_FORM_DTL
             WHERE PROCID = V_FROM_PROCID;

            SELECT TO_NUMBER(VALUE)
              INTO V_NEW_CASE_TYPE_ID
              FROM BIZFLOW.RLVNTDATA 
             WHERE RLVNTDATANAME = 'caseTypeID' 
               AND PROCID = I_PROCID;

            SELECT TO_NUMBER(VALUE)
              INTO V_ORG_CASE_NUMBER
              FROM BIZFLOW.RLVNTDATA 
             WHERE RLVNTDATANAME = 'caseNumber' 
               AND PROCID = V_FROM_PROCID;

            BEGIN
              SELECT TBL_LABEL
                INTO V_NEW_CASE_TYPE_NAME
                FROM TBL_LOOKUP
               WHERE TBL_ID = V_NEW_CASE_TYPE_ID;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
              V_NEW_CASE_TYPE_NAME := TO_CHAR(V_NEW_CASE_TYPE_ID);
              WHEN OTHERS THEN
              V_NEW_CASE_TYPE_NAME := TO_CHAR(V_NEW_CASE_TYPE_ID);
            END;

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='employeeName' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='employeeName';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='contactName' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='contactName';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='initialContactDate' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='initialContactDate';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='organization' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='organization';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='primaryDWCSpecialist' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='primaryDWCSpecialist';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='secondaryDWCSpecialist' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='secondaryDWCSpecialist';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = V_NEW_CASE_TYPE_NAME
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='caseType';

            SELECT XMLQUERY('/formData/items/item[id="GEN_EMPLOYEE_ID"]/value/text()' PASSING V_XMLDOC RETURNING CONTENT).GETSTRINGVAL() INTO V_GEN_EMP_HHSID FROM DUAL;
            SELECT DELETEXML(V_XMLDOC,'/formData/items/item/id[not(contains(text(),"GEN_"))]/..') INTO V_XMLDOC FROM DUAL;
            SELECT DELETEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_CATEGORY"]') INTO V_XMLDOC FROM DUAL;
            SELECT DELETEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_DESC"]') INTO V_XMLDOC FROM DUAL;
            SELECT DELETEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_STATUS"]') INTO V_XMLDOC FROM DUAL;
            SELECT DELETEXML(V_XMLDOC,'/formData/items/item[id="GEN_CUST_INIT_CONTACT_DT"]') INTO V_XMLDOC FROM DUAL;
            
            IF V_NEW_CASE_TYPE_ID IS NOT NULL AND V_NEW_CASE_TYPE_NAME IS NOT NULL THEN
                SELECT UPDATEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_TYPE"]/value/text()', V_NEW_CASE_TYPE_ID) INTO V_XMLDOC FROM DUAL;
                SELECT UPDATEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_TYPE"]/text/text()',  V_NEW_CASE_TYPE_NAME) INTO V_XMLDOC FROM DUAL;                
            END IF;
        END IF;        
        
        IF V_XMLDOC IS NULL THEN
            V_XMLDOC := XMLTYPE('<formData xmlns=""><items><item><id>CASE_NUMBER</id><etype>variable</etype><value>'|| V_CASE_NUMBER ||'</value></item></items><history><item /></history></formData>');
        ELSE
            SP_ERLR_EMPLOYEE_CASE_ADD(V_GEN_EMP_HHSID, V_CASE_NUMBER, TO_NUMBER(V_NEW_CASE_TYPE_ID), V_ORG_CASE_NUMBER, NULL);            
            SELECT APPENDCHILDXML(V_XMLDOC, '/formData/items', XMLTYPE('<item><id>CASE_NUMBER</id><etype>variable</etype><value>'|| V_CASE_NUMBER ||'</value></item>')) INTO V_XMLDOC FROM DUAL;            
        END IF;
        
        INSERT INTO TBL_FORM_DTL (PROCID, ACTSEQ, WITEMSEQ, FORM_TYPE, FIELD_DATA, CRT_DT, CRT_USR)
                          VALUES (I_PROCID, 0, 0, 'CMSERLR', V_XMLDOC, SYSDATE, 'System');
    END IF;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;
/

GRANT EXECUTE ON HHS_CMS_HR.SP_INIT_ERLR TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_INIT_ERLR TO HHS_CMS_HR_RW_ROLE;
/

create or replace PROCEDURE SP_FINALIZE_ERLR
(
	I_PROCID               IN  NUMBER
)
IS
    V_CNT                   INT;
    V_XMLDOC                XMLTYPE;
    V_XMLVALUE              XMLTYPE;
    V_CASE_TYPE_ID          VARCHAR2(10);
    V_VALUE                 VARCHAR2(100);
    V_NEW_CASE_TYPE_ID      VARCHAR2(10);
    V_NEW_CASE_TYPE_NAME    VARCHAR2(100);
    V_GEN_EMP_ID            VARCHAR2(64);
    V_CASE_NUMBER           NUMBER(10);
    V_TRIGGER_NEW_CASE      BOOLEAN := FALSE;
    YES                     CONSTANT VARCHAR2(3) := 'Yes';
    CONDUCT_ISSUE_ID		CONSTANT VARCHAR2(10) :='743';
    CONDUCT_ISSUE			CONSTANT VARCHAR2(50) :='Conduct Issue';
    GRIEVANCE_ID			CONSTANT VARCHAR2(10) :='745';
    GRIEVANCE			    CONSTANT VARCHAR2(50) :='Grievance';
    INVESTIGATION_ID		CONSTANT VARCHAR2(10) :='744';
    INVESTIGATION			CONSTANT VARCHAR2(50) :='Investigation';
    LABOR_NEGOTIATION_ID	CONSTANT VARCHAR2(10) :='748';
    LABOR_NEGOTIATION		CONSTANT VARCHAR2(50) :='Labor Negotiation';
    MEDICAL_DOCUMENTATION_ID CONSTANT VARCHAR2(10) :='746';
    MEDICAL_DOCUMENTATION	CONSTANT VARCHAR2(50) :='Medical Documentation';
    PERFORMANCE_ISSUE_ID	CONSTANT VARCHAR2(10) :='750';
    PERFORMANCE_ISSUE		CONSTANT VARCHAR2(50) :='Performance Issue';
    PROBATIONARY_PERIOD_ID	CONSTANT VARCHAR2(10) :='751';
    PROBATIONARY_PERIOD		CONSTANT VARCHAR2(50) :='Probationary Period Action';
    UNFAIR_LABOR_PRACTICES_ID	CONSTANT VARCHAR2(10) :='754';
    UNFAIR_LABOR_PRACTICES	CONSTANT VARCHAR2(50) :='Unfair Labor Practices';
    WGI_DENIAL_ID			CONSTANT VARCHAR2(10) :='809';
    WGI_DENIAL			    CONSTANT VARCHAR2(50) :='Within Grade Increase Denial/Reconsideration';    
    INFORMATION_REQUEST_ID  CONSTANT VARCHAR2(10) := '747';    
    THIRD_PARTY_HEARING_ID  CONSTANT VARCHAR2(10) := '753';    
    THIRD_PARTY_HEARING     CONSTANT VARCHAR2(50) := 'Third Party Hearing';
    ACTION_TYPE_COUNSELING_ID CONSTANT VARCHAR2(10) := '785';
    ACTION_TYPE_PIP_ID      CONSTANT VARCHAR2(10) := '787';
    ACTION_TYPE_WNR_ID      CONSTANT VARCHAR2(10) := '790';    
    REASON_FMLA_ID          CONSTANT VARCHAR2(10) := '1650';
BEGIN
    SELECT FIELD_DATA
      INTO V_XMLDOC
      FROM TBL_FORM_DTL
     WHERE PROCID = I_PROCID;

    V_CASE_TYPE_ID := V_XMLDOC.EXTRACT('/formData/items/item[id="GEN_CASE_TYPE"]/value/text()').getStringVal();    
    V_GEN_EMP_ID   := V_XMLDOC.EXTRACT('/formData/items/item[id="GEN_EMPLOYEE_ID"]/value/text()').getStringVal();    
    V_CASE_NUMBER  := TO_NUMBER(V_XMLDOC.EXTRACT('/formData/items/item[id="CASE_NUMBER"]/value/text()').getStringVal());    
    SP_ERLR_EMPLOYEE_CASE_ADD(V_GEN_EMP_ID, V_CASE_NUMBER, TO_NUMBER(V_CASE_TYPE_ID), NULL, NULL);
    
    IF V_CASE_TYPE_ID = INFORMATION_REQUEST_ID THEN -- Information Request
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="IR_APPEAL_DENIAL"]/value/text()'); -- Did Requester Appeal Denial?
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = YES THEN
            V_NEW_CASE_TYPE_ID   := THIRD_PARTY_HEARING_ID;
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
        END IF;
    ELSIF V_CASE_TYPE_ID = INVESTIGATION_ID THEN -- Investigation
        -- Triggering Conduct Case
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="I_MISCONDUCT_FOUND"]/value/text()'); --Was Misconduct Found?
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = YES THEN
            V_NEW_CASE_TYPE_ID   := CONDUCT_ISSUE_ID;
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
        END IF;
    ELSIF V_CASE_TYPE_ID = MEDICAL_DOCUMENTATION_ID THEN -- Medical Documentation
        -- Triggering Grievance Case
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="MD_REQUEST_REASON"]/value/text()'); -- Reason for Request
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = REASON_FMLA_ID THEN  -- FMLA      
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="MD_FMLA_GRIEVANCE"]/value/text()'); -- Did Employee File a Grievance?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := GRIEVANCE_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;
        END IF;
    ELSIF V_CASE_TYPE_ID = LABOR_NEGOTIATION_ID THEN -- Labor Negotiation
        -- Triggering Unfair Labor Practices Case
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="LN_FILE_ULP"]/value/text()');--Did Union File ULP?
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = YES THEN        
            V_NEW_CASE_TYPE_ID   := UNFAIR_LABOR_PRACTICES_ID;
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
        END IF;        
    ELSIF V_CASE_TYPE_ID = PERFORMANCE_ISSUE_ID THEN -- Performance Issue
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_ACTION_TYPE"]/value/text()');
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = ACTION_TYPE_COUNSELING_ID THEN -- Action Type: Counseling
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_CNSL_GRV_DECISION"]/value/text()'); -- Did Employee File a Grievance?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := GRIEVANCE_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;
        ELSIF V_VALUE = ACTION_TYPE_PIP_ID THEN -- Action Type: PIP
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_PIP_EMPL_GRIEVANCE"]/value/text()'); -- Did Employee File a Grievance?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := GRIEVANCE_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;
            
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_PIP_WGI_WTHLD"]/value/text()'); --Was WGI Withheld?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := WGI_DENIAL_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID2' AND PROCID = I_PROCID;
            END IF;
        ELSIF V_VALUE = ACTION_TYPE_WNR_ID THEN -- Action Type: Written Narrative Review
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_WNR_WGI_WTHLD"]/value/text()'); -- Was WGI Withheld?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := WGI_DENIAL_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;        
        END IF;
    END IF;
    
EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;
/
GRANT EXECUTE ON HHS_CMS_HR.SP_FINALIZE_ERLR TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_FINALIZE_ERLR TO HHS_CMS_HR_DEV_ROLE;
/

create or replace PROCEDURE SP_UPDATE_ERLR_FORM_DATA 
   (I_WIH_ACTION IN VARCHAR2, -- SAVE, SUBMIT
    I_FIELD_DATA IN CLOB, 
    I_USER       IN VARCHAR2, 
    I_PROCID     IN NUMBER, 
    I_ACTSEQ     IN NUMBER, 
    I_WITEMSEQ   IN NUMBER) 
IS 
  V_XMLDOC               XMLTYPE;
  V_FORM_TYPE            VARCHAR2(20) := 'CMSERLR';
  V_CNT                  INT;
  COMPLATE_CASE_ACTIVITY CONSTANT VARCHAR2(50) := 'Complete Case';
  DWC_SUPERVISOR         CONSTANT VARCHAR2(50) := 'DWC Supervisor';
BEGIN 
    -- sanity check: ignore and exit if form data xml is null or empty 
    IF I_FIELD_DATA IS NULL OR LENGTH(I_FIELD_DATA) <= 0 OR I_PROCID IS NULL OR I_USER IS NULL OR I_ACTSEQ IS NULL THEN 
      RETURN; 
    END IF;
    
    -- TODO: I_USER should be member of work item checked out
    --

    V_XMLDOC := XMLTYPE(I_FIELD_DATA); 

    MERGE INTO TBL_FORM_DTL A
    USING (SELECT * FROM TBL_FORM_DTL WHERE PROCID=I_PROCID) B
       ON (A.PROCID = B.PROCID)
     WHEN MATCHED THEN
          UPDATE 
             SET A.FIELD_DATA = V_XMLDOC, 
                 A.MOD_DT = SYS_EXTRACT_UTC(SYSTIMESTAMP), 
                 A.MOD_USR = I_USER 
     WHEN NOT MATCHED THEN     
          INSERT (A.PROCID, A.ACTSEQ, A.WITEMSEQ, A.FORM_TYPE, A.FIELD_DATA, A.CRT_DT, A.CRT_USR) 
          VALUES (I_PROCID, NVL(I_ACTSEQ, 0), NVL(I_WITEMSEQ, 0), V_FORM_TYPE, V_XMLDOC, SYS_EXTRACT_UTC(SYSTIMESTAMP), I_USER); 

    -- Update process variable and transition xml into individual tables 
    -- for respective process definition 
    SP_UPDATE_PV_ERLR(I_PROCID, V_XMLDOC); 
    SP_UPDATE_ERLR_TABLE(I_PROCID); 

EXCEPTION 
  WHEN OTHERS THEN 
             SP_ERROR_LOG(); 
END; 
/

GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_ERLR_FORM_DATA TO HHS_CMS_HR_RW_ROLE;
/

create or replace PROCEDURE SP_UPDATE_ERLR_TABLE
(
	I_PROCID            IN      NUMBER
)
IS
	V_CASE_NUMBER                NUMBER(20);
	V_JOB_REQ_NUM               NVARCHAR2(50);
    V_CASE_CREATION_DT          DATE;	
	V_VALUE                     NVARCHAR2(4000);
	V_VALUE_LOOKUP              NVARCHAR2(2000);
	V_REC_CNT                   NUMBER(10);
	V_XMLDOC                    XMLTYPE;
	V_XMLVALUE                  XMLTYPE;	
	V_ERRCODE                   NUMBER(10);
	V_ERRMSG                    VARCHAR2(512);
	E_INVALID_PROCID            EXCEPTION;
	E_INVALID_JOB_REQ_ID        EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_INVALID_JOB_REQ_ID, -20902);
	E_INVALID_STRATCON_DATA     EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_INVALID_STRATCON_DATA, -20905);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('SP_UPDATE_ERLR_TABLE - BEGIN ============================');
	--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
	--DBMS_OUTPUT.PUT_LINE(' ----------------');



	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
		------------------------------------------------------
		-- Transfer XML data into operational table
		--
		-- 1. Get Case number and Job Request Number
		-- 1.1 Select it from data xml from TBL_FORM_DTL table.
		-- 1.2 If not found, select it from BIZFLOW.RLVNTDATA table.
		-- 2. If Case number /Job Request Number not found, issue error.
		-- 3. For each target table,
		-- 3.1. If record found for the CASE_NUMBER, update record.
		-- 3.2. If record not found for the CASE_NUMBER, insert record.
		------------------------------------------------------
		--DBMS_OUTPUT.PUT_LINE('Starting xml data retrieval and table update ----------');

		--------------------------------
		-- get Case number
		--------------------------------
		--DBMS_OUTPUT.PUT_LINE('    REQUEST table');
        BEGIN
			SELECT VALUE
			INTO V_CASE_NUMBER
			FROM BIZFLOW.RLVNTDATA
			WHERE PROCID = I_PROCID AND RLVNTDATANAME = 'caseNumber';
		EXCEPTION
			WHEN NO_DATA_FOUND THEN V_CASE_NUMBER := NULL;
		END;

		--DBMS_OUTPUT.PUT_LINE('    V_CASE_NUMBER = ' || V_CASE_NUMBER);
		IF V_CASE_NUMBER IS NULL THEN
			RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_ERLR_TABLE: Case Number is invalid.  I_PROCID = '
				|| TO_CHAR(I_PROCID) || ' V_CASE_NUMBER = ' || V_CASE_NUMBER || '  V_CASE_NUMBER = ' || TO_CHAR(V_CASE_NUMBER));
		END IF;

        --------------------------------
		-- get Request number 
		--------------------------------
		BEGIN
			SELECT VALUE
			INTO V_JOB_REQ_NUM
			FROM BIZFLOW.RLVNTDATA
			WHERE PROCID = I_PROCID AND RLVNTDATANAME = 'requestNum';
		EXCEPTION
			WHEN NO_DATA_FOUND THEN V_JOB_REQ_NUM := NULL;
		END;

		--DBMS_OUTPUT.PUT_LINE('    V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM);
		--IF V_JOB_REQ_NUM IS NULL THEN
		--	RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_ERLR_TABLE: Request Number is invalid.  I_PROCID = '
		--		|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_NUM = ' || TO_CHAR(V_JOB_REQ_NUM));
		--END IF;

        --------------------------------
		-- get Case Creation Date
		--------------------------------
		--DBMS_OUTPUT.PUT_LINE('    Case Creation Date'');
        BEGIN
			SELECT CREATIONDTIME
			INTO V_CASE_CREATION_DT
			FROM BIZFLOW.PROCS
			WHERE PROCID = I_PROCID;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN V_CASE_CREATION_DT := NULL;
		END;
		--------------------------------
		-- ERLR_CASE table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_CASE TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
                    , V_JOB_REQ_NUM AS ERLR_JOB_REQ_NUMBER
                    , I_PROCID AS PROCID
                    , X.GEN_CASE_STATUS AS ERLR_CASE_STATUS_ID
                    , V_CASE_CREATION_DT AS ERLR_CASE_CREATE_DT
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS
                            GEN_CASE_STATUS NVARCHAR2(200) PATH './item[id="GEN_CASE_STATUS"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
                TRG.ERLR_CASE_STATUS_ID = SRC.ERLR_CASE_STATUS_ID
				,TRG.ERLR_JOB_REQ_NUMBER = SRC.ERLR_JOB_REQ_NUMBER     
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
                , TRG.ERLR_JOB_REQ_NUMBER
	            , TRG.PROCID 
	            , TRG.ERLR_CASE_STATUS_ID
	            , TRG.ERLR_CASE_CREATE_DT
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
                , SRC.ERLR_JOB_REQ_NUMBER
	            , SRC.PROCID 
	            , SRC.ERLR_CASE_STATUS_ID
	            , SRC.ERLR_CASE_CREATE_DT
            );

		END;



		--------------------------------
		-- ERLR_GEN table
		--------------------------------
		BEGIN
			--DBMS_OUTPUT.PUT_LINE('    ERLR_GEN table');
			MERGE INTO ERLR_GEN TRG
			USING
			(
				SELECT
					V_CASE_NUMBER AS ERLR_CASE_NUMBER
					--X.ERLR_CASE_NUMBER
					, SUBSTR(X.GEN_PRIMARY_SPECIALIST, 4, 10) AS GEN_PRIMARY_SPECIALIST
                    , SUBSTR(X.GEN_SECONDARY_SPECIALIST, 4, 10) AS GEN_SECONDARY_SPECIALIST
                    , X.GEN_CUSTOMER_NAME
                    , X.GEN_CUSTOMER_PHONE
                    , X.GEN_CUSTOMER_ADMIN_CD
                    , X.GEN_CUSTOMER_ADMIN_CD_DESC
                    , X.GEN_EMPLOYEE_NAME
                    , X.GEN_EMPLOYEE_PHONE
                    , X.GEN_EMPLOYEE_ADMIN_CD
                    , X.GEN_EMPLOYEE_ADMIN_CD_DESC
                    , X.GEN_CASE_DESC
	                , X.GEN_CASE_STATUS
					, TO_DATE(X.GEN_CUST_INIT_CONTACT_DT,'MM/DD/YYYY HH24:MI:SS') AS GEN_CUST_INIT_CONTACT_DT            
	                , X.GEN_PRIMARY_REP_AFFILIATION
	                , X.GEN_CMS_PRIMARY_REP_ID
	                , X.GEN_CMS_PRIMARY_REP_PHONE
	                , X.GEN_NON_CMS_PRIMARY_FNAME
	                , X.GEN_NON_CMS_PRIMARY_MNAME
	                , X.GEN_NON_CMS_PRIMARY_LNAME
	                , X.GEN_NON_CMS_PRIMARY_EMAIL
	                , X.GEN_NON_CMS_PRIMARY_PHONE
	                , X.GEN_NON_CMS_PRIMARY_ORG
	                , X.GEN_NON_CMS_PRIMARY_ADDR
	                , X.GEN_CASE_TYPE
	                , X.GEN_CASE_CATEGORY
	                , X.GEN_INVESTIGATION
	                , X.GEN_INVESTIGATE_START_DT
	                , X.GEN_INVESTIGATE_END_DT
	                , X.GEN_STD_CONDUCT
	                , X.GEN_STD_CONDUCT_TYPE	                
                    , TO_DATE(X.CC_CASE_COMPLETE_DT,'MM/DD/YYYY HH24:MI:SS') AS CC_CASE_COMPLETE_DT
					, FN_GET_FINAL_ACTIONS(I_PROCID) AS CC_FINAL_ACTION
	                          
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/formData/items' PASSING FD.FIELD_DATA
						COLUMNS
							ERLR_CASE_NUMBER	NUMBER(20,0)	PATH './item[id="CASE_NUMBER"]/value'
							, GEN_PRIMARY_SPECIALIST VARCHAR2(13) PATH './item[id="GEN_PRIMARY_SPECIALIST"]/value'
                            , GEN_SECONDARY_SPECIALIST	VARCHAR2(13)   PATH './item[id="GEN_SECONDARY_SPECIALIST"]/value'
	                        , GEN_CUSTOMER_NAME 	NVARCHAR2(150)  PATH './item[id="GEN_CUSTOMER_NAME"]/value'
	                        , GEN_CUSTOMER_PHONE	NVARCHAR2(50)   PATH './item[id="GEN_CUSTOMER_PHONE"]/value'
	                        , GEN_CUSTOMER_ADMIN_CD	NVARCHAR2(8)    PATH './item[id="GEN_CUSTOMER_ADMIN_CD"]/value'
	                        , GEN_CUSTOMER_ADMIN_CD_DESC	NVARCHAR2(50)   PATH './item[id="GEN_CUSTOMER_ADMIN_CD_DESC"]/value'
	                        , GEN_EMPLOYEE_NAME	NVARCHAR2(150)  PATH './item[id="GEN_EMPLOYEE_NAME"]/value'
	                        , GEN_EMPLOYEE_PHONE	NVARCHAR2(50)   PATH './item[id="GEN_EMPLOYEE_PHONE"]/value'
	                        , GEN_EMPLOYEE_ADMIN_CD	NVARCHAR2(8)    PATH './item[id="GEN_EMPLOYEE_ADMIN_CD"]/value'
	                        , GEN_EMPLOYEE_ADMIN_CD_DESC	NVARCHAR2(50)   PATH './item[id="GEN_EMPLOYEE_ADMIN_CD_DESC"]/value'
	                        , GEN_CASE_DESC	NVARCHAR2(500)  PATH './item[id="GEN_CASE_DESC"]/value'
	                        , GEN_CASE_STATUS	 NVARCHAR2(200)   PATH './item[id="GEN_CASE_STATUS"]/value'
	                        , GEN_CUST_INIT_CONTACT_DT	VARCHAR2(10)    PATH './item[id="GEN_CUST_INIT_CONTACT_DT"]/value'
	                        , GEN_PRIMARY_REP_AFFILIATION	 NVARCHAR2(20)  PATH './item[id="GEN_PRIMARY_REP"]/value'
	                        , GEN_CMS_PRIMARY_REP_ID VARCHAR2(255)  PATH './item[id="GEN_CMS_PRIMARY_REP"]/value/name'
	                        , GEN_CMS_PRIMARY_REP_PHONE	NVARCHAR2(50)   PATH './item[id="GEN_CMS_PRIMARY_REP_PHONE"]/value'
	                        , GEN_NON_CMS_PRIMARY_FNAME	NVARCHAR2(50)   PATH './item[id="GEN_NON_CMS_PRIMARY_FNAME"]/value'
	                        , GEN_NON_CMS_PRIMARY_MNAME	NVARCHAR2(50)   PATH './item[id="GEN_NON_CMS_PRIMARY_MNAME"]/value'
	                        , GEN_NON_CMS_PRIMARY_LNAME	NVARCHAR2(50)   PATH './item[id="GEN_NON_CMS_PRIMARY_LNAME"]/value'
	                        , GEN_NON_CMS_PRIMARY_EMAIL	NVARCHAR2(100)  PATH './item[id="GEN_NON_CMS_PRIMARY_EMAIL"]/value'
	                        , GEN_NON_CMS_PRIMARY_PHONE	NVARCHAR2(50)   PATH './item[id="GEN_NON_CMS_PRIMARY_PHONE"]/value'
	                        , GEN_NON_CMS_PRIMARY_ORG	NVARCHAR2(100)  PATH './item[id="GEN_NON_CMS_PRIMARY_ORG"]/value'
	                        , GEN_NON_CMS_PRIMARY_ADDR	NVARCHAR2(250)  PATH './item[id="GEN_NON_CMS_PRIMARY_ADDR"]/value'
	                        , GEN_CASE_TYPE	 NUMBER(20,0)   PATH './item[id="GEN_CASE_TYPE"]/value'
	                        , GEN_CASE_CATEGORY	NVARCHAR2(200)  PATH './item[id="GEN_CASE_CATEGORY"]/value'
	                        , GEN_INVESTIGATION	NVARCHAR2(3)    PATH './item[id="GEN_INVESTIGATION"]/value'
	                        , GEN_INVESTIGATE_START_DT	DATE    PATH './item[id="GEN_INVESTIGATE_START_DT"]/value'
	                        , GEN_INVESTIGATE_END_DT	DATE    PATH './item[id="GEN_INVESTIGATE_END_DT"]/value'
	                        , GEN_STD_CONDUCT	NVARCHAR2(3)    PATH './item[id="GEN_STD_CONDUCT"]/value'
	                        , GEN_STD_CONDUCT_TYPE	 NVARCHAR2(200) PATH './item[id="GEN_STD_CONDUCT_TYPE"]/value'
	                        , CC_FINAL_ACTION	NVARCHAR2(200)  PATH './item[id="CC_FINAL_ACTION"]/value'
	                        , CC_CASE_COMPLETE_DT	VARCHAR2(10)    PATH './item[id="CC_CASE_COMPLETE_DT"]/value'
					) X					
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
			WHEN MATCHED THEN UPDATE SET
				TRG.GEN_PRIMARY_SPECIALIST                    = SRC.GEN_PRIMARY_SPECIALIST
				, TRG.GEN_SECONDARY_SPECIALIST            = SRC.GEN_SECONDARY_SPECIALIST
				, TRG.GEN_CUSTOMER_NAME                  = SRC.GEN_CUSTOMER_NAME
				, TRG.GEN_CUSTOMER_PHONE      = SRC.GEN_CUSTOMER_PHONE
				, TRG.GEN_CUSTOMER_ADMIN_CD    = SRC.GEN_CUSTOMER_ADMIN_CD
				, TRG.GEN_CUSTOMER_ADMIN_CD_DESC                = SRC.GEN_CUSTOMER_ADMIN_CD_DESC
				, TRG.GEN_EMPLOYEE_NAME       = SRC.GEN_EMPLOYEE_NAME
				, TRG.GEN_EMPLOYEE_PHONE      = SRC.GEN_EMPLOYEE_PHONE
				, TRG.GEN_EMPLOYEE_ADMIN_CD    = SRC.GEN_EMPLOYEE_ADMIN_CD
				, TRG.GEN_EMPLOYEE_ADMIN_CD_DESC                = SRC.GEN_EMPLOYEE_ADMIN_CD_DESC
				, TRG.GEN_CASE_DESC       = SRC.GEN_CASE_DESC
				, TRG.GEN_CASE_STATUS      = SRC.GEN_CASE_STATUS
				, TRG.GEN_CUST_INIT_CONTACT_DT    = SRC.GEN_CUST_INIT_CONTACT_DT
				, TRG.GEN_PRIMARY_REP_AFFILIATION                = SRC.GEN_PRIMARY_REP_AFFILIATION
				, TRG.GEN_CMS_PRIMARY_REP_ID       = SRC.GEN_CMS_PRIMARY_REP_ID
				, TRG.GEN_CMS_PRIMARY_REP_PHONE      = SRC.GEN_CMS_PRIMARY_REP_PHONE
				, TRG.GEN_NON_CMS_PRIMARY_FNAME    = SRC.GEN_NON_CMS_PRIMARY_FNAME
				, TRG.GEN_NON_CMS_PRIMARY_MNAME                = SRC.GEN_NON_CMS_PRIMARY_MNAME
				, TRG.GEN_NON_CMS_PRIMARY_LNAME       = SRC.GEN_NON_CMS_PRIMARY_LNAME
				, TRG.GEN_NON_CMS_PRIMARY_EMAIL      = SRC.GEN_NON_CMS_PRIMARY_EMAIL
				, TRG.GEN_NON_CMS_PRIMARY_PHONE    = SRC.GEN_NON_CMS_PRIMARY_PHONE
				, TRG.GEN_NON_CMS_PRIMARY_ORG                = SRC.GEN_NON_CMS_PRIMARY_ORG
				, TRG.GEN_NON_CMS_PRIMARY_ADDR       = SRC.GEN_NON_CMS_PRIMARY_ADDR
				, TRG.GEN_CASE_TYPE      = SRC.GEN_CASE_TYPE
				, TRG.GEN_CASE_CATEGORY            = SRC.GEN_CASE_CATEGORY
				, TRG.GEN_INVESTIGATION                  = SRC.GEN_INVESTIGATION
				, TRG.GEN_INVESTIGATE_START_DT               = SRC.GEN_INVESTIGATE_START_DT
				, TRG.GEN_INVESTIGATE_END_DT                     = SRC.GEN_INVESTIGATE_END_DT
				, TRG.GEN_STD_CONDUCT                  = SRC.GEN_STD_CONDUCT
				, TRG.GEN_STD_CONDUCT_TYPE                    = SRC.GEN_STD_CONDUCT_TYPE
				, TRG.CC_FINAL_ACTION                     = SRC.CC_FINAL_ACTION
				, TRG.CC_CASE_COMPLETE_DT                  = SRC.CC_CASE_COMPLETE_DT				
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.ERLR_CASE_NUMBER
				, TRG.GEN_PRIMARY_SPECIALIST
				, TRG.GEN_SECONDARY_SPECIALIST
				, TRG.GEN_CUSTOMER_NAME     
				, TRG.GEN_CUSTOMER_PHONE  
				, TRG.GEN_CUSTOMER_ADMIN_CD
				, TRG.GEN_CUSTOMER_ADMIN_CD_DESC
				, TRG.GEN_EMPLOYEE_NAME
				, TRG.GEN_EMPLOYEE_PHONE
				, TRG.GEN_EMPLOYEE_ADMIN_CD
				, TRG.GEN_EMPLOYEE_ADMIN_CD_DESC
				, TRG.GEN_CASE_DESC
				, TRG.GEN_CASE_STATUS
				, TRG.GEN_CUST_INIT_CONTACT_DT
				, TRG.GEN_PRIMARY_REP_AFFILIATION
				, TRG.GEN_CMS_PRIMARY_REP_ID
				, TRG.GEN_CMS_PRIMARY_REP_PHONE
				, TRG.GEN_NON_CMS_PRIMARY_FNAME
				, TRG.GEN_NON_CMS_PRIMARY_MNAME
				, TRG.GEN_NON_CMS_PRIMARY_LNAME
				, TRG.GEN_NON_CMS_PRIMARY_EMAIL
				, TRG.GEN_NON_CMS_PRIMARY_PHONE
				, TRG.GEN_NON_CMS_PRIMARY_ORG
				, TRG.GEN_NON_CMS_PRIMARY_ADDR
				, TRG.GEN_CASE_TYPE
				, TRG.GEN_CASE_CATEGORY
				, TRG.GEN_INVESTIGATION
				, TRG.GEN_INVESTIGATE_START_DT
				, TRG.GEN_INVESTIGATE_END_DT
				, TRG.GEN_STD_CONDUCT
				, TRG.GEN_STD_CONDUCT_TYPE
				, TRG.CC_FINAL_ACTION
				, TRG.CC_CASE_COMPLETE_DT
			)
			VALUES
			(
				SRC.ERLR_CASE_NUMBER
				, SRC.GEN_PRIMARY_SPECIALIST
				, SRC.GEN_SECONDARY_SPECIALIST
				, SRC.GEN_CUSTOMER_NAME     
				, SRC.GEN_CUSTOMER_PHONE  
				, SRC.GEN_CUSTOMER_ADMIN_CD
				, SRC.GEN_CUSTOMER_ADMIN_CD_DESC
				, SRC.GEN_EMPLOYEE_NAME
				, SRC.GEN_EMPLOYEE_PHONE
				, SRC.GEN_EMPLOYEE_ADMIN_CD
				, SRC.GEN_EMPLOYEE_ADMIN_CD_DESC
				, SRC.GEN_CASE_DESC
				, SRC.GEN_CASE_STATUS
				, SRC.GEN_CUST_INIT_CONTACT_DT
				, SRC.GEN_PRIMARY_REP_AFFILIATION
				, SRC.GEN_CMS_PRIMARY_REP_ID
				, SRC.GEN_CMS_PRIMARY_REP_PHONE
				, SRC.GEN_NON_CMS_PRIMARY_FNAME
				, SRC.GEN_NON_CMS_PRIMARY_MNAME
				, SRC.GEN_NON_CMS_PRIMARY_LNAME
				, SRC.GEN_NON_CMS_PRIMARY_EMAIL
				, SRC.GEN_NON_CMS_PRIMARY_PHONE
				, SRC.GEN_NON_CMS_PRIMARY_ORG
				, SRC.GEN_NON_CMS_PRIMARY_ADDR
				, SRC.GEN_CASE_TYPE
				, SRC.GEN_CASE_CATEGORY
				, SRC.GEN_INVESTIGATION
				, SRC.GEN_INVESTIGATE_START_DT
				, SRC.GEN_INVESTIGATE_END_DT
				, SRC.GEN_STD_CONDUCT
				, SRC.GEN_STD_CONDUCT_TYPE
				, SRC.CC_FINAL_ACTION
				, SRC.CC_CASE_COMPLETE_DT
			)
			;
		END;

		--------------------------------
		-- ERLR_CNDT_ISSUE table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_CNDT_ISSUE TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, X.CI_ACTION_TYPE
					, CASE WHEN X.CI_ADMIN_INVESTIGATORY_LEAVE = 'true'  THEN '1' ELSE '0' END AS CI_ADMIN_INVESTIGATORY_LEAVE
					, CASE WHEN X.CI_ADMIN_NOTICE_LEAVE = 'true'  THEN '1' ELSE '0' END AS CI_ADMIN_NOTICE_LEAVE
					, TO_DATE(X.CI_LEAVE_START_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_LEAVE_START_DT
					, TO_DATE(X.CI_LEAVE_END_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_LEAVE_END_DT
					, X.CI_APPROVAL_NAME
					, TO_DATE(X.CI_LEAVE_START_DT_2,'MM/DD/YYYY HH24:MI:SS') AS CI_LEAVE_START_DT_2
					, TO_DATE(X.CI_LEAVE_END_DT_2,'MM/DD/YYYY HH24:MI:SS') AS CI_LEAVE_END_DT_2
					, X.CI_APPROVAL_NAME_2
					, TO_DATE(X.CI_PROP_ACTION_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_PROP_ACTION_ISSUED_DT
					, X.CI_ORAL_PREZ_REQUESTED
					, TO_DATE(X.CI_ORAL_PREZ_DT,'MM/DD/YYYY HH24:MI:SS') AS  CI_ORAL_PREZ_DT
					, X.CI_ORAL_RESPONSE_SUBMITTED
					, TO_DATE(X.CI_RESPONSE_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_RESPONSE_DUE_DT
					, TO_DATE(X.CI_WRITTEN_RESPONSE_SBMT_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_WRITTEN_RESPONSE_SBMT_DT
					, X.CI_POS_TITLE
					, X.CI_PPLAN
					, X.CI_SERIES
					, X.CI_CURRENT_INFO_GRADE
					, X.CI_CURRENT_INFO_STEP
					, X.CI_PROPOSED_POS_TITLE
					, X.CI_PROPOSED_PPLAN
					, X.CI_PROPOSED_SERIES
					, X.CI_PROPOSED_INFO_GRADE
					, X.CI_PROPOSED_INFO_STEP
					, X.CI_FINAL_POS_TITLE
					, X.CI_FINAL_PPLAN
					, X.CI_FINAL_SERIES
					, X.CI_FINAL_INFO_GRADE
					, X.CI_FINAL_INFO_STEP
					, X.CI_DEMO_FINAL_AGNCY_DCSN
					, X.CI_DECIDING_OFFCL
					, TO_DATE(X.CI_DECISION_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_DECISION_ISSUED_DT
					, TO_DATE(X.CI_DEMO_FINAL_AGENCY_EFF_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_DEMO_FINAL_AGENCY_EFF_DT
					, X.CI_NUMB_DAYS
					, X.CI_COUNSEL_TYPE
					, TO_DATE(X.CI_COUNSEL_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_COUNSEL_ISSUED_DT
					, TO_DATE(X.CI_SICK_LEAVE_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_SICK_LEAVE_ISSUED_DT
					, TO_DATE(X.CI_RESTRICTION_ISSED_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_RESTRICTION_ISSED_DT
					, X.CI_SL_REVIEWED_DT_LIST
					, X.CI_SL_WARNING_DISCUSS_DT_LIST
					, TO_DATE(X.CI_SL_WARN_ISSUE,'MM/DD/YYYY HH24:MI:SS') AS CI_SL_WARN_ISSUE
					, TO_DATE(X.CI_NOTICE_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_NOTICE_ISSUED_DT
					, TO_DATE(X.CI_EFFECTIVE_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_EFFECTIVE_DT
					, X.CI_CURRENT_ADMIN_CODE
					, X.CI_RE_ASSIGNMENT_CURR_ORG
					, X.CI_FINAL_ADMIN_CODE
					, X.CI_RE_ASSIGNMENT_FINAL_ORG
					, TO_DATE(X.CI_REMOVAL_PROP_ACTION_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_REMOVAL_PROP_ACTION_DT
					, X.CI_EMP_NOTICE_LEAVE_PLACED
					, TO_DATE(X.CI_REMOVAL_NOTICE_START_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_REMOVAL_NOTICE_START_DT
					, TO_DATE(X.CI_REMOVAL_NOTICE_END_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_REMOVAL_NOTICE_END_DT
					, X.CI_RMVL_ORAL_PREZ_RQSTED
					, TO_DATE(X.CI_REMOVAL_ORAL_PREZ_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_REMOVAL_ORAL_PREZ_DT
					, X.CI_RMVL_WRTN_RESPONSE
					, TO_DATE(X.CI_WRITTEN_RESPONSE_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_WRITTEN_RESPONSE_DUE_DT
					, TO_DATE(X.CI_WRITTEN_SUBMITTED_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_WRITTEN_SUBMITTED_DT
					, X.CI_RMVL_FINAL_AGNCY_DCSN
					, X.CI_DECIDING_OFFCL_NAME
					, TO_DATE(X.CI_RMVL_DATE_DCSN_ISSUED,'MM/DD/YYYY HH24:MI:SS') AS CI_RMVL_DATE_DCSN_ISSUED
					, TO_DATE(X.CI_REMOVAL_EFFECTIVE_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_REMOVAL_EFFECTIVE_DT
					, X.CI_RMVL_NUMB_DAYS
					, X.CI_SUSPENTION_TYPE
					, TO_DATE(X.CI_SUSP_PROP_ACTION_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_SUSP_PROP_ACTION_DT
					, X.CI_SUSP_ORAL_PREZ_REQUESTED
					, TO_DATE(X.CI_SUSP_ORAL_PREZ_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_SUSP_ORAL_PREZ_DT
					, X.CI_SUSP_WRITTEN_RESP
					, TO_DATE(X.CI_SUSP_WRITTEN_RESP_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_SUSP_WRITTEN_RESP_DUE_DT
					, TO_DATE(X.CI_SUSP_WRITTEN_RESP_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_SUSP_WRITTEN_RESP_DT
					, X.CI_SUSP_FINAL_AGNCY_DCSN
					, X.CI_SUSP_DECIDING_OFFCL_NAME
					, TO_DATE(X.CI_SUSP_DECISION_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_SUSP_DECISION_ISSUED_DT
					, TO_DATE(X.CI_SUSP_EFFECTIVE_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_SUSP_EFFECTIVE_DECISION_DT
					, X.CI_SUS_NUMB_DAYS
					, TO_DATE(X.CI_REPRIMAND_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_REPRIMAND_ISSUE_DT
					, X.CI_EMP_APPEAL_DECISION                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS
                            CI_ACTION_TYPE	NVARCHAR2(200)	PATH './item[id="CI_ACTION_TYPE"]/value'
							, CI_ADMIN_INVESTIGATORY_LEAVE	NVARCHAR2(5)	PATH './item[id="CI_ADMIN_INVESTIGATORY_LEAVE"]/value'
							, CI_ADMIN_NOTICE_LEAVE	NVARCHAR2(5)	PATH './item[id="CI_ADMIN_NOTICE_LEAVE"]/value'
							, CI_LEAVE_START_DT	NVARCHAR2(10)	PATH './item[id="CI_LEAVE_START_DT"]/value'
							, CI_LEAVE_END_DT	NVARCHAR2(10)	PATH './item[id="CI_LEAVE_END_DT"]/value'
							, CI_APPROVAL_NAME	NVARCHAR2(255)	PATH './item[id="CI_APPROVAL_NAME"]/value/name'
							, CI_LEAVE_START_DT_2	NVARCHAR2(10)	PATH './item[id="CI_LEAVE_START_DT_2"]/value'
							, CI_LEAVE_END_DT_2	NVARCHAR2(10)	PATH './item[id="CI_LEAVE_END_DT_2"]/value'
							, CI_APPROVAL_NAME_2	NVARCHAR2(255)	PATH './item[id="CI_APPROVAL_NAME_2"]/value/name'
							, CI_PROP_ACTION_ISSUED_DT	NVARCHAR2(10)	PATH './item[id="CI_PROP_ACTION_ISSUED_DT"]/value'
							, CI_ORAL_PREZ_REQUESTED	NVARCHAR2(3)	PATH './item[id="CI_ORAL_PREZ_REQUESTED"]/value'
							, CI_ORAL_PREZ_DT	NVARCHAR2(10)	PATH './item[id="CI_ORAL_PREZ_DT"]/value'
							, CI_ORAL_RESPONSE_SUBMITTED	NVARCHAR2(3)	PATH './item[id="CI_ORAL_RESPONSE_SUBMITTED"]/value'
							, CI_RESPONSE_DUE_DT	NVARCHAR2(10)	PATH './item[id="CI_RESPONSE_DUE_DT"]/value'
							, CI_WRITTEN_RESPONSE_SBMT_DT	NVARCHAR2(10)	PATH './item[id="CI_WRITTEN_RESPONSE_SUBMITTED_DT"]/value'
							, CI_POS_TITLE	NVARCHAR2(50)	PATH './item[id="CI_POS_TITLE"]/value'
							, CI_PPLAN	NVARCHAR2(50)	PATH './item[id="CI_PPLAN"]/value'
							, CI_SERIES	NVARCHAR2(50)	PATH './item[id="CI_SERIES"]/value'
							, CI_CURRENT_INFO_GRADE	NVARCHAR2(50)	PATH './item[id="CI_CURRENT_INFO_GRADE"]/value'
							, CI_CURRENT_INFO_STEP	NVARCHAR2(50)	PATH './item[id="CI_CURRENT_INFO_STEP"]/value'
							, CI_PROPOSED_POS_TITLE	NVARCHAR2(50)	PATH './item[id="CI_PROPOSED_POS_TITLE"]/value'
							, CI_PROPOSED_PPLAN	NVARCHAR2(50)	PATH './item[id="CI_PROPOSED_PPLAN"]/value'
							, CI_PROPOSED_SERIES	NVARCHAR2(50)	PATH './item[id="CI_PROPOSED_SERIES"]/value'
							, CI_PROPOSED_INFO_GRADE	NVARCHAR2(50)	PATH './item[id="CI_PROPOSED_INFO_GRADE"]/value'
							, CI_PROPOSED_INFO_STEP	NVARCHAR2(50)	PATH './item[id="CI_PROPOSED_INFO_STEP"]/value'
							, CI_FINAL_POS_TITLE	NVARCHAR2(50)	PATH './item[id="CI_FINAL_POS_TITLE"]/value'
							, CI_FINAL_PPLAN	NVARCHAR2(50)	PATH './item[id="CI_FINAL_PPLAN"]/value'
							, CI_FINAL_SERIES	NVARCHAR2(50)	PATH './item[id="CI_FINAL_SERIES"]/value'
							, CI_FINAL_INFO_GRADE	NVARCHAR2(50)	PATH './item[id="CI_FINAL_INFO_GRADE"]/value'
							, CI_FINAL_INFO_STEP	NVARCHAR2(50)	PATH './item[id="CI_FINAL_INFO_STEP"]/value'
							, CI_DEMO_FINAL_AGNCY_DCSN	NVARCHAR2(200)	PATH './item[id="CI_DEMO_FINAL_AGENCY_DECISION"]/value'
							, CI_DECIDING_OFFCL	NVARCHAR2(255)	PATH './item[id="CI_DECIDING_OFFCL"]/value/name'
							, CI_DECISION_ISSUED_DT	NVARCHAR2(10)	PATH './item[id="CI_DECISION_ISSUED_DT"]/value'
							, CI_DEMO_FINAL_AGENCY_EFF_DT	NVARCHAR2(10)	PATH './item[id="CI_DEMO_FINAL_AGENCY_EFF_DT"]/value'
							, CI_NUMB_DAYS	NUMBER(20,0)	PATH './item[id="CI_NUMB_DAYS"]/value'
							, CI_COUNSEL_TYPE	NVARCHAR2(200)	PATH './item[id="CI_COUNSEL_TYPE"]/value'
							, CI_COUNSEL_ISSUED_DT	NVARCHAR2(10)	PATH './item[id="CI_COUNSEL_ISSUED_DT"]/value'
							, CI_SICK_LEAVE_ISSUED_DT	NVARCHAR2(10)	PATH './item[id="CI_SICK_LEAVE_ISSUED_DT"]/value'
							, CI_RESTRICTION_ISSED_DT	NVARCHAR2(10)	PATH './item[id="CI_RESTRICTION_ISSED_DT"]/value'
							, CI_SL_REVIEWED_DT_LIST	VARCHAR2(4000)	PATH './item[id="CI_SICK_LEAVE_REVIEWED_DT_LIST"]/value'
							, CI_SL_WARNING_DISCUSS_DT_LIST	VARCHAR2(4000)	PATH './item[id="CI_SL_WARNING_DISCUSSION_DT_LIST"]/value'
							, CI_SL_WARN_ISSUE	NVARCHAR2(10)	PATH './item[id="CI_SL_WARN_ISSUE"]/value'
							, CI_NOTICE_ISSUED_DT	NVARCHAR2(10)	PATH './item[id="CI_NOTICE_ISSUED_DT"]/value'
							, CI_EFFECTIVE_DT	NVARCHAR2(10)	PATH './item[id="CI_EFFECTIVE_DT"]/value'
							, CI_CURRENT_ADMIN_CODE	NVARCHAR2(8)	PATH './item[id="CI_CURRENT_ADMIN_CODE"]/value'
							, CI_RE_ASSIGNMENT_CURR_ORG	NVARCHAR2(50)	PATH './item[id="CI_RE_ASSIGNMENT_CURR_ORG"]/value'
							, CI_FINAL_ADMIN_CODE	NVARCHAR2(8)	PATH './item[id="CI_FINAL_ADMIN_CODE"]/value'
							, CI_RE_ASSIGNMENT_FINAL_ORG	NVARCHAR2(50)	PATH './item[id="CI_RE_ASSIGNMENT_FINAL_ORG"]/value'
							, CI_REMOVAL_PROP_ACTION_DT	NVARCHAR2(10)	PATH './item[id="CI_REMOVAL_PROP_ACTION_DT"]/value'
							, CI_EMP_NOTICE_LEAVE_PLACED	NVARCHAR2(3)	PATH './item[id="CI_EMP_NOTICE_LEAVE_PLACED"]/value'
							, CI_REMOVAL_NOTICE_START_DT	NVARCHAR2(10)	PATH './item[id="CI_REMOVAL_NOTICE_START_DT"]/value'
							, CI_REMOVAL_NOTICE_END_DT	NVARCHAR2(10)	PATH './item[id="CI_REMOVAL_NOTICE_END_DT"]/value'
							, CI_RMVL_ORAL_PREZ_RQSTED	NVARCHAR2(3)	PATH './item[id="CI_REMOVAL_ORAL_PREZ_REQUESTED"]/value'
							, CI_REMOVAL_ORAL_PREZ_DT	NVARCHAR2(10)	PATH './item[id="CI_REMOVAL_ORAL_PREZ_DT"]/value'
							, CI_RMVL_WRTN_RESPONSE	NVARCHAR2(3)	PATH './item[id="CI_REMOVAL_WRITTEN_RESPONSE"]/value'
							, CI_WRITTEN_RESPONSE_DUE_DT	NVARCHAR2(10)	PATH './item[id="CI_WRITTEN_RESPONSE_DUE_DT"]/value'
							, CI_WRITTEN_SUBMITTED_DT	NVARCHAR2(10)	PATH './item[id="CI_WRITTEN_SUBMITTED_DT"]/value'
							, CI_RMVL_FINAL_AGNCY_DCSN	NVARCHAR2(200)	PATH './item[id="CI_RMVL_FINAL_AGENCY_DECISION"]/value'
							, CI_DECIDING_OFFCL_NAME	NVARCHAR2(255)	PATH './item[id="CI_DECIDING_OFFCL_NAME"]/value/name'
							, CI_RMVL_DATE_DCSN_ISSUED	NVARCHAR2(10)	PATH './item[id="CI_REMOVAL_DATE_DECISION_ISSUED"]/value'
							, CI_REMOVAL_EFFECTIVE_DT	NVARCHAR2(10)	PATH './item[id="CI_REMOVAL_EFFECTIVE_DT"]/value'
							, CI_RMVL_NUMB_DAYS	NUMBER(20,0)	PATH './item[id="CI_RMVL_NUMB_DAYS"]/value'
							, CI_SUSPENTION_TYPE	NUMBER(20,0)	PATH './item[id="CI_SUSPENTION_TYPE"]/value'
							, CI_SUSP_PROP_ACTION_DT	NVARCHAR2(10)	PATH './item[id="CI_SUSP_PROP_ACTION_DT"]/value'
							, CI_SUSP_ORAL_PREZ_REQUESTED	NVARCHAR2(3)	PATH './item[id="CI_SUSP_ORAL_PREZ_REQUESTED"]/value'
							, CI_SUSP_ORAL_PREZ_DT	NVARCHAR2(10)	PATH './item[id="CI_SUSP_ORAL_PREZ_DT"]/value'
							, CI_SUSP_WRITTEN_RESP	NVARCHAR2(3)	PATH './item[id="CI_SUSP_WRITTEN_RESP"]/value'
							, CI_SUSP_WRITTEN_RESP_DUE_DT	NVARCHAR2(10)	PATH './item[id="CI_SUSP_WRITTEN_RESP_DUE_DT"]/value'
							, CI_SUSP_WRITTEN_RESP_DT	NVARCHAR2(10)	PATH './item[id="CI_SUSP_WRITTEN_RESP_DT"]/value'
							, CI_SUSP_FINAL_AGNCY_DCSN	NVARCHAR2(200)	PATH './item[id="CI_SUSP_FINAL_AGENCY_DECISION"]/value'
							, CI_SUSP_DECIDING_OFFCL_NAME	NVARCHAR2(255)	PATH './item[id="CI_SUSP_DECIDING_OFFCL_NAME"]/value/name'
							, CI_SUSP_DECISION_ISSUED_DT	NVARCHAR2(10)	PATH './item[id="CI_SUSP_DECISION_ISSUED_DT"]/value'
							, CI_SUSP_EFFECTIVE_DECISION_DT	NVARCHAR2(10)	PATH './item[id="CI_SUSP_EFFECTIVE_DECISION_DT"]/value'
							, CI_SUS_NUMB_DAYS	NUMBER(20,0)	PATH './item[id="CI_SUS_NUMB_DAYS"]/value'
							, CI_REPRIMAND_ISSUE_DT	NVARCHAR2(10)	PATH './item[id="CI_REPRIMAND_ISSUE_DT"]/value'
							, CI_EMP_APPEAL_DECISION	NVARCHAR2(3)	PATH './item[id="CI_EMP_APPEAL_DECISION"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
				--TRG.ERLR_CASE_NUMBER = SRC.ERLR_CASE_NUMBER
				TRG.CI_ACTION_TYPE = SRC.CI_ACTION_TYPE
                , TRG.CI_ADMIN_INVESTIGATORY_LEAVE = SRC.CI_ADMIN_INVESTIGATORY_LEAVE
                , TRG.CI_ADMIN_NOTICE_LEAVE = SRC.CI_ADMIN_NOTICE_LEAVE				
				, TRG.CI_LEAVE_START_DT = SRC.CI_LEAVE_START_DT
				, TRG.CI_LEAVE_END_DT = SRC.CI_LEAVE_END_DT
				, TRG.CI_APPROVAL_NAME = SRC.CI_APPROVAL_NAME
				, TRG.CI_LEAVE_START_DT_2 = SRC.CI_LEAVE_START_DT_2
				, TRG.CI_LEAVE_END_DT_2 = SRC.CI_LEAVE_END_DT_2
				, TRG.CI_APPROVAL_NAME_2 = SRC.CI_APPROVAL_NAME_2
				, TRG.CI_PROP_ACTION_ISSUED_DT = SRC.CI_PROP_ACTION_ISSUED_DT
				, TRG.CI_ORAL_PREZ_REQUESTED = SRC.CI_ORAL_PREZ_REQUESTED
				, TRG.CI_ORAL_PREZ_DT = SRC.CI_ORAL_PREZ_DT
				, TRG.CI_ORAL_RESPONSE_SUBMITTED = SRC.CI_ORAL_RESPONSE_SUBMITTED
				, TRG.CI_RESPONSE_DUE_DT = SRC.CI_RESPONSE_DUE_DT
				, TRG.CI_WRITTEN_RESPONSE_SBMT_DT = SRC.CI_WRITTEN_RESPONSE_SBMT_DT
				, TRG.CI_POS_TITLE = SRC.CI_POS_TITLE
				, TRG.CI_PPLAN = SRC.CI_PPLAN
				, TRG.CI_SERIES = SRC.CI_SERIES
				, TRG.CI_CURRENT_INFO_GRADE = SRC.CI_CURRENT_INFO_GRADE
				, TRG.CI_CURRENT_INFO_STEP = SRC.CI_CURRENT_INFO_STEP
				, TRG.CI_PROPOSED_POS_TITLE = SRC.CI_PROPOSED_POS_TITLE
				, TRG.CI_PROPOSED_PPLAN = SRC.CI_PROPOSED_PPLAN
				, TRG.CI_PROPOSED_SERIES = SRC.CI_PROPOSED_SERIES
				, TRG.CI_PROPOSED_INFO_GRADE = SRC.CI_PROPOSED_INFO_GRADE
				, TRG.CI_PROPOSED_INFO_STEP = SRC.CI_PROPOSED_INFO_STEP
				, TRG.CI_FINAL_POS_TITLE = SRC.CI_FINAL_POS_TITLE
				, TRG.CI_FINAL_PPLAN = SRC.CI_FINAL_PPLAN
				, TRG.CI_FINAL_SERIES = SRC.CI_FINAL_SERIES
				, TRG.CI_FINAL_INFO_GRADE = SRC.CI_FINAL_INFO_GRADE
				, TRG.CI_FINAL_INFO_STEP = SRC.CI_FINAL_INFO_STEP
				, TRG.CI_DEMO_FINAL_AGNCY_DCSN = SRC.CI_DEMO_FINAL_AGNCY_DCSN
				, TRG.CI_DECIDING_OFFCL = SRC.CI_DECIDING_OFFCL
				, TRG.CI_DECISION_ISSUED_DT = SRC.CI_DECISION_ISSUED_DT
				, TRG.CI_DEMO_FINAL_AGENCY_EFF_DT = SRC.CI_DEMO_FINAL_AGENCY_EFF_DT
				, TRG.CI_NUMB_DAYS = SRC.CI_NUMB_DAYS
				, TRG.CI_COUNSEL_TYPE = SRC.CI_COUNSEL_TYPE
				, TRG.CI_COUNSEL_ISSUED_DT = SRC.CI_COUNSEL_ISSUED_DT
				, TRG.CI_SICK_LEAVE_ISSUED_DT = SRC.CI_SICK_LEAVE_ISSUED_DT
				, TRG.CI_RESTRICTION_ISSED_DT = SRC.CI_RESTRICTION_ISSED_DT
				, TRG.CI_SL_REVIEWED_DT_LIST = SRC.CI_SL_REVIEWED_DT_LIST
				, TRG.CI_SL_WARNING_DISCUSS_DT_LIST = SRC.CI_SL_WARNING_DISCUSS_DT_LIST
				, TRG.CI_SL_WARN_ISSUE = SRC.CI_SL_WARN_ISSUE
				, TRG.CI_NOTICE_ISSUED_DT = SRC.CI_NOTICE_ISSUED_DT
				, TRG.CI_EFFECTIVE_DT = SRC.CI_EFFECTIVE_DT
				, TRG.CI_CURRENT_ADMIN_CODE = SRC.CI_CURRENT_ADMIN_CODE
				, TRG.CI_RE_ASSIGNMENT_CURR_ORG = SRC.CI_RE_ASSIGNMENT_CURR_ORG
				, TRG.CI_FINAL_ADMIN_CODE = SRC.CI_FINAL_ADMIN_CODE
				, TRG.CI_RE_ASSIGNMENT_FINAL_ORG = SRC.CI_RE_ASSIGNMENT_FINAL_ORG
				, TRG.CI_REMOVAL_PROP_ACTION_DT = SRC.CI_REMOVAL_PROP_ACTION_DT
				, TRG.CI_EMP_NOTICE_LEAVE_PLACED = SRC.CI_EMP_NOTICE_LEAVE_PLACED
				, TRG.CI_REMOVAL_NOTICE_START_DT = SRC.CI_REMOVAL_NOTICE_START_DT
				, TRG.CI_REMOVAL_NOTICE_END_DT = SRC.CI_REMOVAL_NOTICE_END_DT
				, TRG.CI_RMVL_ORAL_PREZ_RQSTED = SRC.CI_RMVL_ORAL_PREZ_RQSTED
				, TRG.CI_REMOVAL_ORAL_PREZ_DT = SRC.CI_REMOVAL_ORAL_PREZ_DT
				, TRG.CI_RMVL_WRTN_RESPONSE = SRC.CI_RMVL_WRTN_RESPONSE
				, TRG.CI_WRITTEN_RESPONSE_DUE_DT = SRC.CI_WRITTEN_RESPONSE_DUE_DT
				, TRG.CI_WRITTEN_SUBMITTED_DT = SRC.CI_WRITTEN_SUBMITTED_DT
				, TRG.CI_RMVL_FINAL_AGNCY_DCSN = SRC.CI_RMVL_FINAL_AGNCY_DCSN
				, TRG.CI_DECIDING_OFFCL_NAME = SRC.CI_DECIDING_OFFCL_NAME
				, TRG.CI_RMVL_DATE_DCSN_ISSUED = SRC.CI_RMVL_DATE_DCSN_ISSUED
				, TRG.CI_REMOVAL_EFFECTIVE_DT = SRC.CI_REMOVAL_EFFECTIVE_DT
				, TRG.CI_RMVL_NUMB_DAYS = SRC.CI_RMVL_NUMB_DAYS
				, TRG.CI_SUSPENTION_TYPE = SRC.CI_SUSPENTION_TYPE
				, TRG.CI_SUSP_PROP_ACTION_DT = SRC.CI_SUSP_PROP_ACTION_DT
				, TRG.CI_SUSP_ORAL_PREZ_REQUESTED = SRC.CI_SUSP_ORAL_PREZ_REQUESTED
				, TRG.CI_SUSP_ORAL_PREZ_DT = SRC.CI_SUSP_ORAL_PREZ_DT
				, TRG.CI_SUSP_WRITTEN_RESP = SRC.CI_SUSP_WRITTEN_RESP
				, TRG.CI_SUSP_WRITTEN_RESP_DUE_DT = SRC.CI_SUSP_WRITTEN_RESP_DUE_DT
				, TRG.CI_SUSP_WRITTEN_RESP_DT = SRC.CI_SUSP_WRITTEN_RESP_DT
				, TRG.CI_SUSP_FINAL_AGNCY_DCSN = SRC.CI_SUSP_FINAL_AGNCY_DCSN
				, TRG.CI_SUSP_DECIDING_OFFCL_NAME = SRC.CI_SUSP_DECIDING_OFFCL_NAME
				, TRG.CI_SUSP_DECISION_ISSUED_DT = SRC.CI_SUSP_DECISION_ISSUED_DT
				, TRG.CI_SUSP_EFFECTIVE_DECISION_DT = SRC.CI_SUSP_EFFECTIVE_DECISION_DT
				, TRG.CI_SUS_NUMB_DAYS = SRC.CI_SUS_NUMB_DAYS
				, TRG.CI_REPRIMAND_ISSUE_DT = SRC.CI_REPRIMAND_ISSUE_DT
				, TRG.CI_EMP_APPEAL_DECISION = SRC.CI_EMP_APPEAL_DECISION                    
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.CI_ACTION_TYPE
                , TRG.CI_ADMIN_INVESTIGATORY_LEAVE
                , TRG.CI_ADMIN_NOTICE_LEAVE			
				, TRG.CI_LEAVE_START_DT
				, TRG.CI_LEAVE_END_DT
				, TRG.CI_APPROVAL_NAME
				, TRG.CI_LEAVE_START_DT_2
				, TRG.CI_LEAVE_END_DT_2
				, TRG.CI_APPROVAL_NAME_2
				, TRG.CI_PROP_ACTION_ISSUED_DT
				, TRG.CI_ORAL_PREZ_REQUESTED
				, TRG.CI_ORAL_PREZ_DT
				, TRG.CI_ORAL_RESPONSE_SUBMITTED
				, TRG.CI_RESPONSE_DUE_DT
				, TRG.CI_WRITTEN_RESPONSE_SBMT_DT
				, TRG.CI_POS_TITLE
				, TRG.CI_PPLAN
				, TRG.CI_SERIES
				, TRG.CI_CURRENT_INFO_GRADE
				, TRG.CI_CURRENT_INFO_STEP
				, TRG.CI_PROPOSED_POS_TITLE
				, TRG.CI_PROPOSED_PPLAN
				, TRG.CI_PROPOSED_SERIES
				, TRG.CI_PROPOSED_INFO_GRADE
				, TRG.CI_PROPOSED_INFO_STEP
				, TRG.CI_FINAL_POS_TITLE
				, TRG.CI_FINAL_PPLAN
				, TRG.CI_FINAL_SERIES
				, TRG.CI_FINAL_INFO_GRADE
				, TRG.CI_FINAL_INFO_STEP
				, TRG.CI_DEMO_FINAL_AGNCY_DCSN
				, TRG.CI_DECIDING_OFFCL
				, TRG.CI_DECISION_ISSUED_DT
				, TRG.CI_DEMO_FINAL_AGENCY_EFF_DT
				, TRG.CI_NUMB_DAYS
				, TRG.CI_COUNSEL_TYPE
				, TRG.CI_COUNSEL_ISSUED_DT
				, TRG.CI_SICK_LEAVE_ISSUED_DT
				, TRG.CI_RESTRICTION_ISSED_DT
				, TRG.CI_SL_REVIEWED_DT_LIST
				, TRG.CI_SL_WARNING_DISCUSS_DT_LIST
				, TRG.CI_SL_WARN_ISSUE
				, TRG.CI_NOTICE_ISSUED_DT
				, TRG.CI_EFFECTIVE_DT
				, TRG.CI_CURRENT_ADMIN_CODE
				, TRG.CI_RE_ASSIGNMENT_CURR_ORG
				, TRG.CI_FINAL_ADMIN_CODE
				, TRG.CI_RE_ASSIGNMENT_FINAL_ORG
				, TRG.CI_REMOVAL_PROP_ACTION_DT
				, TRG.CI_EMP_NOTICE_LEAVE_PLACED
				, TRG.CI_REMOVAL_NOTICE_START_DT
				, TRG.CI_REMOVAL_NOTICE_END_DT
				, TRG.CI_RMVL_ORAL_PREZ_RQSTED
				, TRG.CI_REMOVAL_ORAL_PREZ_DT
				, TRG.CI_RMVL_WRTN_RESPONSE
				, TRG.CI_WRITTEN_RESPONSE_DUE_DT
				, TRG.CI_WRITTEN_SUBMITTED_DT
				, TRG.CI_RMVL_FINAL_AGNCY_DCSN
				, TRG.CI_DECIDING_OFFCL_NAME
				, TRG.CI_RMVL_DATE_DCSN_ISSUED
				, TRG.CI_REMOVAL_EFFECTIVE_DT
				, TRG.CI_RMVL_NUMB_DAYS
				, TRG.CI_SUSPENTION_TYPE
				, TRG.CI_SUSP_PROP_ACTION_DT
				, TRG.CI_SUSP_ORAL_PREZ_REQUESTED
				, TRG.CI_SUSP_ORAL_PREZ_DT
				, TRG.CI_SUSP_WRITTEN_RESP
				, TRG.CI_SUSP_WRITTEN_RESP_DUE_DT
				, TRG.CI_SUSP_WRITTEN_RESP_DT
				, TRG.CI_SUSP_FINAL_AGNCY_DCSN
				, TRG.CI_SUSP_DECIDING_OFFCL_NAME
				, TRG.CI_SUSP_DECISION_ISSUED_DT
				, TRG.CI_SUSP_EFFECTIVE_DECISION_DT
				, TRG.CI_SUS_NUMB_DAYS
				, TRG.CI_REPRIMAND_ISSUE_DT
				, TRG.CI_EMP_APPEAL_DECISION               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.CI_ACTION_TYPE
                , SRC.CI_ADMIN_INVESTIGATORY_LEAVE
                , SRC.CI_ADMIN_NOTICE_LEAVE				
				, SRC.CI_LEAVE_START_DT
				, SRC.CI_LEAVE_END_DT
				, SRC.CI_APPROVAL_NAME
				, SRC.CI_LEAVE_START_DT_2
				, SRC.CI_LEAVE_END_DT_2
				, SRC.CI_APPROVAL_NAME_2
				, SRC.CI_PROP_ACTION_ISSUED_DT
				, SRC.CI_ORAL_PREZ_REQUESTED
				, SRC.CI_ORAL_PREZ_DT
				, SRC.CI_ORAL_RESPONSE_SUBMITTED
				, SRC.CI_RESPONSE_DUE_DT
				, SRC.CI_WRITTEN_RESPONSE_SBMT_DT
				, SRC.CI_POS_TITLE
				, SRC.CI_PPLAN
				, SRC.CI_SERIES
				, SRC.CI_CURRENT_INFO_GRADE
				, SRC.CI_CURRENT_INFO_STEP
				, SRC.CI_PROPOSED_POS_TITLE
				, SRC.CI_PROPOSED_PPLAN
				, SRC.CI_PROPOSED_SERIES
				, SRC.CI_PROPOSED_INFO_GRADE
				, SRC.CI_PROPOSED_INFO_STEP
				, SRC.CI_FINAL_POS_TITLE
				, SRC.CI_FINAL_PPLAN
				, SRC.CI_FINAL_SERIES
				, SRC.CI_FINAL_INFO_GRADE
				, SRC.CI_FINAL_INFO_STEP
				, SRC.CI_DEMO_FINAL_AGNCY_DCSN
				, SRC.CI_DECIDING_OFFCL
				, SRC.CI_DECISION_ISSUED_DT
				, SRC.CI_DEMO_FINAL_AGENCY_EFF_DT
				, SRC.CI_NUMB_DAYS
				, SRC.CI_COUNSEL_TYPE
				, SRC.CI_COUNSEL_ISSUED_DT
				, SRC.CI_SICK_LEAVE_ISSUED_DT
				, SRC.CI_RESTRICTION_ISSED_DT
				, SRC.CI_SL_REVIEWED_DT_LIST
				, SRC.CI_SL_WARNING_DISCUSS_DT_LIST
				, SRC.CI_SL_WARN_ISSUE
				, SRC.CI_NOTICE_ISSUED_DT
				, SRC.CI_EFFECTIVE_DT
				, SRC.CI_CURRENT_ADMIN_CODE
				, SRC.CI_RE_ASSIGNMENT_CURR_ORG
				, SRC.CI_FINAL_ADMIN_CODE
				, SRC.CI_RE_ASSIGNMENT_FINAL_ORG
				, SRC.CI_REMOVAL_PROP_ACTION_DT
				, SRC.CI_EMP_NOTICE_LEAVE_PLACED
				, SRC.CI_REMOVAL_NOTICE_START_DT
				, SRC.CI_REMOVAL_NOTICE_END_DT
				, SRC.CI_RMVL_ORAL_PREZ_RQSTED
				, SRC.CI_REMOVAL_ORAL_PREZ_DT
				, SRC.CI_RMVL_WRTN_RESPONSE
				, SRC.CI_WRITTEN_RESPONSE_DUE_DT
				, SRC.CI_WRITTEN_SUBMITTED_DT
				, SRC.CI_RMVL_FINAL_AGNCY_DCSN
				, SRC.CI_DECIDING_OFFCL_NAME
				, SRC.CI_RMVL_DATE_DCSN_ISSUED
				, SRC.CI_REMOVAL_EFFECTIVE_DT
				, SRC.CI_RMVL_NUMB_DAYS
				, SRC.CI_SUSPENTION_TYPE
				, SRC.CI_SUSP_PROP_ACTION_DT
				, SRC.CI_SUSP_ORAL_PREZ_REQUESTED
				, SRC.CI_SUSP_ORAL_PREZ_DT
				, SRC.CI_SUSP_WRITTEN_RESP
				, SRC.CI_SUSP_WRITTEN_RESP_DUE_DT
				, SRC.CI_SUSP_WRITTEN_RESP_DT
				, SRC.CI_SUSP_FINAL_AGNCY_DCSN
				, SRC.CI_SUSP_DECIDING_OFFCL_NAME
				, SRC.CI_SUSP_DECISION_ISSUED_DT
				, SRC.CI_SUSP_EFFECTIVE_DECISION_DT
				, SRC.CI_SUS_NUMB_DAYS
				, SRC.CI_REPRIMAND_ISSUE_DT
				, SRC.CI_EMP_APPEAL_DECISION               
            );

		END;

        --------------------------------
		-- ERLR_PERF_ISSUE table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_PERF_ISSUE TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
                    , X.PI_ACTION_TYPE
					, TO_DATE(X.PI_NEXT_WGI_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_NEXT_WGI_DUE_DT	
					, TO_DATE(X.PI_PERF_COUNSEL_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PERF_COUNSEL_ISSUE_DT	
					, X.PI_CNSL_GRV_DECISION
					, TO_DATE(X.PI_DMTN_PRPS_ACTN_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_DMTN_PRPS_ACTN_ISSUE_DT	
					, X.PI_DMTN_ORAL_PRSNT_REQ
					, TO_DATE(X.PI_DMTN_ORAL_PRSNT_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_DMTN_ORAL_PRSNT_DT	
					, X.PI_DMTN_WRTN_RESP_SBMT
					, TO_DATE(X.PI_DMTN_WRTN_RESP_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_DMTN_WRTN_RESP_DUE_DT	
					, TO_DATE(X.PI_DMTN_WRTN_RESP_SBMT_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_DMTN_WRTN_RESP_SBMT_DT	
					, X.PI_DMTN_CUR_POS_TITLE
					, X.PI_DMTN_CUR_PAY_PLAN
					, X.PI_DMTN_CUR_JOB_SERIES
					, X.PI_DMTN_CUR_GRADE
					, X.PI_DMTN_CUR_STEP
					, X.PI_DMTN_PRPS_POS_TITLE
					, X.PI_DMTN_PRPS_PAY_PLAN
					, X.PI_DMTN_PRPS_JOB_SERIES
					, X.PI_DMTN_PRPS_GRADE
					, X.PI_DMTN_PRP_STEP
					, X.PI_DMTN_FIN_POS_TITLE
					, X.PI_DMTN_FIN_PAY_PLAN
					, X.PI_DMTN_FIN_JOB_SERIES
					, X.PI_DMTN_FIN_GRADE
					, X.PI_DMTN_FIN_STEP
					, X.PI_DMTN_FIN_AGCY_DECISION
					, X.PI_DMTN_FIN_DECIDING_OFC
					, TO_DATE(X.PI_DMTN_FIN_DECISION_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_DMTN_FIN_DECISION_ISSUE_DT	
					, TO_DATE(X.PI_DMTN_DECISION_EFF_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_DMTN_DECISION_EFF_DT	
					, X.PI_DMTN_APPEAL_DECISION
					, X.PI_PIP_RSNBL_ACMDTN
					, X.PI_PIP_EMPL_SBMT_MEDDOC
					, X.PI_PIP_DOC_SBMT_FOH_RVW
					, X.PI_PIP_WGI_WTHLD
					, TO_DATE(X.PI_PIP_WGI_RVW_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_WGI_RVW_DT	
					, X.PI_PIP_MEDDOC_RVW_OUTCOME
					, TO_DATE(X.PI_PIP_START_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_START_DT
					, TO_DATE(X.PI_PIP_END_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_END_DT	
					, TO_DATE(X.PI_PIP_EXT_END_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_EXT_END_DT	
					, X.PI_PIP_EXT_END_REASON
					, TO_DATE(X.PI_PIP_EXT_END_NOTIFY_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_EXT_END_NOTIFY_DT	
					, X.PI_PIP_EXT_DT_LIST	
					, TO_DATE(X.PI_PIP_ACTUAL_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_ACTUAL_DT	
					, X.PI_PIP_END_PRIOR_TO_PLAN
					, X.PI_PIP_END_PRIOR_TO_PLAN_RSN
					, X.PI_PIP_SUCCESS_CMPLT
					, TO_DATE(X.PI_PIP_PMAP_RTNG_SIGN_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_PMAP_RTNG_SIGN_DT	
					, TO_DATE(X.PI_PIP_PMAP_RVW_SIGN_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_PMAP_RVW_SIGN_DT	
					, X.PI_PIP_PRPS_ACTN	
					, TO_DATE(X.PI_PIP_PRPS_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_PRPS_ISSUE_DT	
					, X.PI_PIP_ORAL_PRSNT_REQ	
					, TO_DATE(X.PI_PIP_ORAL_PRSNT_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_ORAL_PRSNT_DT	
					, X.PI_PIP_WRTN_RESP_SBMT	
					, TO_DATE(X.PI_PIP_WRTN_RESP_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_WRTN_RESP_DUE_DT	
					, TO_DATE(X.PI_PIP_WRTN_SBMT_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_WRTN_SBMT_DT	
					, X.PI_PIP_FIN_AGCY_DECISION
					, X.PI_PIP_DECIDING_OFFICAL
					, TO_DATE(X.PI_PIP_FIN_AGCY_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_FIN_AGCY_DECISION_DT	
					, TO_DATE(X.PI_PIP_DECISION_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_DECISION_ISSUE_DT	
					, TO_DATE(X.PI_PIP_EFF_ACTN_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_EFF_ACTN_DT	
					, X.PI_PIP_EMPL_GRIEVANCE	
					, X.PI_PIP_APPEAL_DECISION
					, TO_DATE(X.PI_REASGN_NOTICE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_REASGN_NOTICE_DT	
					, TO_DATE(X.PI_REASGN_EFF_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_REASGN_EFF_DT	
					, X.PI_REASGN_CUR_ADMIN_CD
					, X.PI_REASGN_CUR_ORG_NM	
					, X.PI_REASGN_FIN_ADMIN_CD
					, X.PI_REASGN_FIN_ORG_NM	
					, TO_DATE(X.PI_RMV_PRPS_ACTN_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_RMV_PRPS_ACTN_ISSUE_DT	
					, X.PI_RMV_EMPL_NOTC_LEV	
					, TO_DATE(X.PI_RMV_NOTC_LEV_START_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_RMV_NOTC_LEV_START_DT	
					, TO_DATE(X.PI_RMV_NOTC_LEV_END_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_RMV_NOTC_LEV_END_DT	
					, X.PI_RMV_ORAL_PRSNT_REQ	
					, TO_DATE(X.PI_RMV_ORAL_PRSNT_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_RMV_ORAL_PRSNT_DT	
					, TO_DATE(X.PI_RMV_WRTN_RESP_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_RMV_WRTN_RESP_DUE_DT	
					, TO_DATE(X.PI_RMV_WRTN_RESP_SBMT_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_RMV_WRTN_RESP_SBMT_DT	
					, X.PI_RMV_FIN_AGCY_DECISION	
					, X.PI_RMV_FIN_DECIDING_OFC	
					, TO_DATE(X.PI_RMV_DECISION_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_RMV_DECISION_ISSUE_DT	
					, TO_DATE(X.PI_RMV_EFF_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_RMV_EFF_DT	
					, X.PI_RMV_NUM_DAYS	
					, X.PI_RMV_APPEAL_DECISION	
					, X.PI_WRTN_NRTV_RVW_TYPE	
					, TO_DATE(X.PI_WNR_SPCLST_RVW_CMPLT_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_WNR_SPCLST_RVW_CMPLT_DT	
					, TO_DATE(X.PI_WNR_MGR_RVW_RTNG_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_WNR_MGR_RVW_RTNG_DT	
					, X.PI_WNR_CRITICAL_ELM	
					, X.PI_WNR_FIN_RATING
					, TO_DATE(X.PI_WNR_RVW_OFC_CONCUR_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_WNR_RVW_OFC_CONCUR_DT	
					, X.PI_WNR_WGI_WTHLD
					, TO_DATE(X.PI_WNR_WGI_RVW_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_WNR_WGI_RVW_DT	
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS
                            PI_ACTION_TYPE	NUMBER(20,0)	PATH './item[id="PI_ACTION_TYPE"]/value'
							, PI_NEXT_WGI_DUE_DT	VARCHAR2(10)	PATH './item[id="PI_NEXT_WGI_DUE_DT"]/value'
							, PI_PERF_COUNSEL_ISSUE_DT	VARCHAR2(10)	PATH './item[id="PI_PERF_COUNSEL_ISSUE_DT"]/value'
							, PI_CNSL_GRV_DECISION	VARCHAR2(3)	PATH './item[id="PI_CNSL_GRV_DECISION"]/value'
							, PI_DMTN_PRPS_ACTN_ISSUE_DT	VARCHAR2(10)	PATH './item[id="PI_DMTN_PRPS_ACTN_ISSUE_DT"]/value'
							, PI_DMTN_ORAL_PRSNT_REQ	VARCHAR2(3)	PATH './item[id="PI_DMTN_ORAL_PRSNT_REQ"]/value'
							, PI_DMTN_ORAL_PRSNT_DT	VARCHAR2(10)	PATH './item[id="PI_DMTN_ORAL_PRSNT_DT"]/value'
							, PI_DMTN_WRTN_RESP_SBMT	VARCHAR2(3)	PATH './item[id="PI_DMTN_WRTN_RESP_SBMT"]/value'
							, PI_DMTN_WRTN_RESP_DUE_DT	VARCHAR2(10)	PATH './item[id="PI_DMTN_WRTN_RESP_DUE_DT"]/value'
							, PI_DMTN_WRTN_RESP_SBMT_DT	VARCHAR2(10)	PATH './item[id="PI_DMTN_WRTN_RESP_SBMT_DT"]/value'
							, PI_DMTN_CUR_POS_TITLE	NVARCHAR2(50)	PATH './item[id="PI_DMTN_CUR_POS_TITLE"]/value'
							, PI_DMTN_CUR_PAY_PLAN	NVARCHAR2(50)	PATH './item[id="PI_DMTN_CUR_PAY_PLAN"]/value'
							, PI_DMTN_CUR_JOB_SERIES	NVARCHAR2(50)	PATH './item[id="PI_DMTN_CUR_JOB_SERIES"]/value'
							, PI_DMTN_CUR_GRADE	NVARCHAR2(50)	PATH './item[id="PI_DMTN_CUR_GRADE"]/value'
							, PI_DMTN_CUR_STEP	NVARCHAR2(50)	PATH './item[id="PI_DMTN_CUR_STEP"]/value'
							, PI_DMTN_PRPS_POS_TITLE	NVARCHAR2(50)	PATH './item[id="PI_DMTN_PRPS_POS_TITLE"]/value'
							, PI_DMTN_PRPS_PAY_PLAN	NVARCHAR2(50)	PATH './item[id="PI_DMTN_PRPS_PAY_PLAN"]/value'
							, PI_DMTN_PRPS_JOB_SERIES	NVARCHAR2(50)	PATH './item[id="PI_DMTN_PRPS_JOB_SERIES"]/value'
							, PI_DMTN_PRPS_GRADE	NVARCHAR2(50)	PATH './item[id="PI_DMTN_PRPS_GRADE"]/value'
							, PI_DMTN_PRP_STEP	NVARCHAR2(50)	PATH './item[id="PI_DMTN_PRP_STEP"]/value'
							, PI_DMTN_FIN_POS_TITLE	NVARCHAR2(50)	PATH './item[id="PI_DMTN_FIN_POS_TITLE"]/value'
							, PI_DMTN_FIN_PAY_PLAN	NVARCHAR2(50)	PATH './item[id="PI_DMTN_FIN_PAY_PLAN"]/value'
							, PI_DMTN_FIN_JOB_SERIES	NVARCHAR2(50)	PATH './item[id="PI_DMTN_FIN_JOB_SERIES"]/value'
							, PI_DMTN_FIN_GRADE	NVARCHAR2(50)	PATH './item[id="PI_DMTN_FIN_GRADE"]/value'
							, PI_DMTN_FIN_STEP	NVARCHAR2(50)	PATH './item[id="PI_DMTN_FIN_STEP"]/value'
							, PI_DMTN_FIN_AGCY_DECISION	NUMBER(20,0)	PATH './item[id="PI_DMTN_FIN_AGCY_DECISION"]/value'
							, PI_DMTN_FIN_DECIDING_OFC NVARCHAR2(255)	PATH './item[id="PI_DMTN_FIN_DECIDING_OFC_NM"]/value/name'
							, PI_DMTN_FIN_DECISION_ISSUE_DT	VARCHAR2(10)	PATH './item[id="PI_DMTN_FIN_DECISION_ISSUE_DT"]/value'
							, PI_DMTN_DECISION_EFF_DT	VARCHAR2(10)	PATH './item[id="PI_DMTN_DECISION_EFF_DT"]/value'
							, PI_DMTN_APPEAL_DECISION	VARCHAR2(3)	PATH './item[id="PI_DMTN_APPEAL_DECISION"]/value'
							, PI_PIP_RSNBL_ACMDTN	VARCHAR2(3)	PATH './item[id="PI_PIP_RSNBL_ACMDTN"]/value'
							, PI_PIP_EMPL_SBMT_MEDDOC	VARCHAR2(3)	PATH './item[id="PI_PIP_EMPL_SBMT_MEDDOC"]/value'
							, PI_PIP_DOC_SBMT_FOH_RVW	VARCHAR2(3)	PATH './item[id="PI_PIP_DOC_SBMT_FOH_RVW"]/value'
							, PI_PIP_WGI_WTHLD	VARCHAR2(3)	PATH './item[id="PI_PIP_WGI_WTHLD"]/value'
							, PI_PIP_WGI_RVW_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_WGI_RVW_DT"]/value'
							, PI_PIP_MEDDOC_RVW_OUTCOME	NVARCHAR2(140)	PATH './item[id="PI_PIP_MEDDOC_RVW_OUTCOME"]/value'
							, PI_PIP_START_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_START_DT"]/value'
							, PI_PIP_END_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_END_DT"]/value'
							, PI_PIP_EXT_END_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_EXT_END_DT"]/value'
							, PI_PIP_EXT_END_REASON	NVARCHAR2(200)	PATH './item[id="PI_PIP_EXT_END_REASON"]/value'
							, PI_PIP_EXT_END_NOTIFY_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_EXT_END_NOTIFY_DT"]/value'
							, PI_PIP_EXT_DT_LIST	VARCHAR2(4000)	PATH './item[id="PI_PIP_EXT_DT_LIST"]/value'
							, PI_PIP_ACTUAL_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_ACTUAL_DT"]/value'
							, PI_PIP_END_PRIOR_TO_PLAN	VARCHAR2(3)	PATH './item[id="PI_PIP_END_PRIOR_TO_PLAN"]/value'
							, PI_PIP_END_PRIOR_TO_PLAN_RSN	NUMBER(20,0)	PATH './item[id="PI_PIP_END_PRIOR_TO_PLAN_RSN"]/value'
							, PI_PIP_SUCCESS_CMPLT	VARCHAR2(3)	PATH './item[id="PI_PIP_SUCCESS_CMPLT"]/value'
							, PI_PIP_PMAP_RTNG_SIGN_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_PMAP_RTNG_SIGN_DT"]/value'
							, PI_PIP_PMAP_RVW_SIGN_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_PMAP_RVW_SIGN_DT"]/value'
							, PI_PIP_PRPS_ACTN	NUMBER(20,0)	PATH './item[id="PI_PIP_PRPS_ACTN"]/value'
							, PI_PIP_PRPS_ISSUE_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_PRPS_ISSUE_DT"]/value'
							, PI_PIP_ORAL_PRSNT_REQ	VARCHAR2(3)	PATH './item[id="PI_PIP_ORAL_PRSNT_REQ"]/value'
							, PI_PIP_ORAL_PRSNT_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_ORAL_PRSNT_DT"]/value'
							, PI_PIP_WRTN_RESP_SBMT	VARCHAR2(3)	PATH './item[id="PI_PIP_WRTN_RESP_SBMT"]/value'
							, PI_PIP_WRTN_RESP_DUE_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_WRTN_RESP_DUE_DT"]/value'
							, PI_PIP_WRTN_SBMT_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_WRTN_SBMT_DT"]/value'
							, PI_PIP_FIN_AGCY_DECISION	NUMBER(20,0)	PATH './item[id="PI_PIP_FIN_AGCY_DECISION"]/value'
							, PI_PIP_DECIDING_OFFICAL	NVARCHAR2(255)	PATH './item[id="PI_PIP_DECIDING_OFFICAL_NM"]/value/name'
							, PI_PIP_FIN_AGCY_DECISION_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_FIN_AGCY_DECISION_DT"]/value'
							, PI_PIP_DECISION_ISSUE_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_DECISION_ISSUE_DT"]/value'
							, PI_PIP_EFF_ACTN_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_EFF_ACTN_DT"]/value'
							, PI_PIP_EMPL_GRIEVANCE	VARCHAR2(3)	PATH './item[id="PI_PIP_EMPL_GRIEVANCE"]/value'
							, PI_PIP_APPEAL_DECISION	VARCHAR2(3)	PATH './item[id="PI_PIP_APPEAL_DECISION"]/value'
							, PI_REASGN_NOTICE_DT	VARCHAR2(10)	PATH './item[id="PI_REASGN_NOTICE_DT"]/value'
							, PI_REASGN_EFF_DT	VARCHAR2(10)	PATH './item[id="PI_REASGN_EFF_DT"]/value'
							, PI_REASGN_CUR_ADMIN_CD	NVARCHAR2(8)	PATH './item[id="PI_REASGN_CUR_ADMIN_CD"]/value'
							, PI_REASGN_CUR_ORG_NM	NVARCHAR2(50)	PATH './item[id="PI_REASGN_CUR_ORG_NM"]/value'
							, PI_REASGN_FIN_ADMIN_CD	NVARCHAR2(8)	PATH './item[id="PI_REASGN_FIN_ADMIN_CD"]/value'
							, PI_REASGN_FIN_ORG_NM	NVARCHAR2(50)	PATH './item[id="PI_REASGN_FIN_ORG_NM"]/value'
							, PI_RMV_PRPS_ACTN_ISSUE_DT	VARCHAR2(10)	PATH './item[id="PI_RMV_PRPS_ACTN_ISSUE_DT"]/value'
							, PI_RMV_EMPL_NOTC_LEV	VARCHAR2(3)	PATH './item[id="PI_RMV_EMPL_NOTC_LEV"]/value'
							, PI_RMV_NOTC_LEV_START_DT	VARCHAR2(10)	PATH './item[id="PI_RMV_NOTC_LEV_START_DT"]/value'
							, PI_RMV_NOTC_LEV_END_DT	VARCHAR2(10)	PATH './item[id="PI_RMV_NOTC_LEV_END_DT"]/value'
							, PI_RMV_ORAL_PRSNT_REQ	VARCHAR2(3)	PATH './item[id="PI_RMV_ORAL_PRSNT_REQ"]/value'
							, PI_RMV_ORAL_PRSNT_DT	VARCHAR2(10)	PATH './item[id="PI_RMV_ORAL_PRSNT_DT"]/value'
							, PI_RMV_WRTN_RESP_DUE_DT	VARCHAR2(10)	PATH './item[id="PI_RMV_WRTN_RESP_DUE_DT"]/value'
							, PI_RMV_WRTN_RESP_SBMT_DT	VARCHAR2(10)	PATH './item[id="PI_RMV_WRTN_RESP_SBMT_DT"]/value'
							, PI_RMV_FIN_AGCY_DECISION	NUMBER(20,0)	PATH './item[id="PI_RMV_FIN_AGCY_DECISION"]/value'
							, PI_RMV_FIN_DECIDING_OFC	NVARCHAR2(255)	PATH './item[id="PI_RMV_FIN_DECIDING_OFC_NM"]/value/name'
							, PI_RMV_DECISION_ISSUE_DT	VARCHAR2(10)	PATH './item[id="PI_RMV_DECISION_ISSUE_DT"]/value'
							, PI_RMV_EFF_DT	VARCHAR2(10)	PATH './item[id="PI_RMV_EFF_DT"]/value'
							, PI_RMV_NUM_DAYS	NUMBER(20,0)	PATH './item[id="PI_RMV_NUM_DAYS"]/value'
							, PI_RMV_APPEAL_DECISION	VARCHAR2(3)	PATH './item[id="PI_RMV_APPEAL_DECISION"]/value'
							, PI_WRTN_NRTV_RVW_TYPE	NUMBER(20,0)	PATH './item[id="PI_WRTN_NRTV_RVW_TYPE"]/value'
							, PI_WNR_SPCLST_RVW_CMPLT_DT	VARCHAR2(10)	PATH './item[id="PI_WNR_SPCLST_RVW_CMPLT_DT"]/value'
							, PI_WNR_MGR_RVW_RTNG_DT VARCHAR2(10)	PATH './item[id="PI_WNR_MGR_RVW_RTNG_DT"]/value'
							, PI_WNR_CRITICAL_ELM	NVARCHAR2(250)	PATH './item[id="PI_WNR_CRITICAL_ELM"]/value'
							, PI_WNR_FIN_RATING	NVARCHAR2(200)	PATH './item[id="PI_WNR_FIN_RATING"]/value'
							, PI_WNR_RVW_OFC_CONCUR_DT	VARCHAR2(10)	PATH './item[id="PI_WNR_RVW_OFC_CONCUR_DT"]/value'
							, PI_WNR_WGI_WTHLD	VARCHAR2(3)	PATH './item[id="PI_WNR_WGI_WTHLD"]/value'
							, PI_WNR_WGI_RVW_DT	VARCHAR2(10)	PATH './item[id="PI_WNR_WGI_RVW_DT"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
				TRG.PI_ACTION_TYPE = SRC.PI_ACTION_TYPE
				, TRG.PI_NEXT_WGI_DUE_DT = SRC.PI_NEXT_WGI_DUE_DT 	
				, TRG.PI_PERF_COUNSEL_ISSUE_DT	= SRC.PI_PERF_COUNSEL_ISSUE_DT
				, TRG.PI_CNSL_GRV_DECISION = SRC.PI_CNSL_GRV_DECISION
				, TRG.PI_DMTN_PRPS_ACTN_ISSUE_DT = SRC.PI_DMTN_PRPS_ACTN_ISSUE_DT	
				, TRG.PI_DMTN_ORAL_PRSNT_REQ = SRC.PI_DMTN_ORAL_PRSNT_REQ
				, TRG.PI_DMTN_ORAL_PRSNT_DT	= SRC.PI_DMTN_ORAL_PRSNT_DT
				, TRG.PI_DMTN_WRTN_RESP_SBMT = SRC.PI_DMTN_WRTN_RESP_SBMT
				, TRG.PI_DMTN_WRTN_RESP_DUE_DT	= SRC.PI_DMTN_WRTN_RESP_DUE_DT
				, TRG.PI_DMTN_WRTN_RESP_SBMT_DT	= SRC.PI_DMTN_WRTN_RESP_SBMT_DT
				, TRG.PI_DMTN_CUR_POS_TITLE = SRC.PI_DMTN_CUR_POS_TITLE
				, TRG.PI_DMTN_CUR_PAY_PLAN = SRC.PI_DMTN_CUR_PAY_PLAN
				, TRG.PI_DMTN_CUR_JOB_SERIES = SRC.PI_DMTN_CUR_JOB_SERIES
				, TRG.PI_DMTN_CUR_GRADE = SRC.PI_DMTN_CUR_GRADE
				, TRG.PI_DMTN_CUR_STEP = SRC.PI_DMTN_CUR_STEP
				, TRG.PI_DMTN_PRPS_POS_TITLE = SRC.PI_DMTN_PRPS_POS_TITLE
				, TRG.PI_DMTN_PRPS_PAY_PLAN = SRC.PI_DMTN_PRPS_PAY_PLAN
				, TRG.PI_DMTN_PRPS_JOB_SERIES = SRC.PI_DMTN_PRPS_JOB_SERIES
				, TRG.PI_DMTN_PRPS_GRADE = SRC.PI_DMTN_PRPS_GRADE
				, TRG.PI_DMTN_PRP_STEP = SRC.PI_DMTN_PRP_STEP
				, TRG.PI_DMTN_FIN_POS_TITLE = SRC.PI_DMTN_FIN_POS_TITLE
				, TRG.PI_DMTN_FIN_PAY_PLAN = SRC.PI_DMTN_FIN_PAY_PLAN
				, TRG.PI_DMTN_FIN_JOB_SERIES = SRC.PI_DMTN_FIN_JOB_SERIES
				, TRG.PI_DMTN_FIN_GRADE = SRC.PI_DMTN_FIN_GRADE
				, TRG.PI_DMTN_FIN_STEP = SRC.PI_DMTN_FIN_STEP
				, TRG.PI_DMTN_FIN_AGCY_DECISION = SRC.PI_DMTN_FIN_AGCY_DECISION
				, TRG.PI_DMTN_FIN_DECIDING_OFC = SRC.PI_DMTN_FIN_DECIDING_OFC
				, TRG.PI_DMTN_FIN_DECISION_ISSUE_DT = SRC.PI_DMTN_FIN_DECISION_ISSUE_DT		
				, TRG.PI_DMTN_DECISION_EFF_DT = SRC.PI_DMTN_DECISION_EFF_DT	
				, TRG.PI_DMTN_APPEAL_DECISION = SRC.PI_DMTN_APPEAL_DECISION
				, TRG.PI_PIP_RSNBL_ACMDTN = SRC.PI_PIP_RSNBL_ACMDTN
				, TRG.PI_PIP_EMPL_SBMT_MEDDOC = SRC.PI_PIP_EMPL_SBMT_MEDDOC
				, TRG.PI_PIP_DOC_SBMT_FOH_RVW = SRC.PI_PIP_DOC_SBMT_FOH_RVW
				, TRG.PI_PIP_WGI_WTHLD = SRC.PI_PIP_WGI_WTHLD
				, TRG.PI_PIP_WGI_RVW_DT	= SRC.PI_PIP_WGI_RVW_DT
				, TRG.PI_PIP_MEDDOC_RVW_OUTCOME = SRC.PI_PIP_MEDDOC_RVW_OUTCOME
				, TRG.PI_PIP_START_DT = SRC.PI_PIP_START_DT	
				, TRG.PI_PIP_END_DT = SRC.PI_PIP_END_DT	
				, TRG.PI_PIP_EXT_END_DT = SRC.PI_PIP_EXT_END_DT	
				, TRG.PI_PIP_EXT_END_REASON = SRC.PI_PIP_EXT_END_REASON				 
				, TRG.PI_PIP_EXT_END_NOTIFY_DT = SRC.PI_PIP_EXT_END_NOTIFY_DT	
				, TRG.PI_PIP_EXT_DT_LIST = SRC.PI_PIP_EXT_DT_LIST	
				, TRG.PI_PIP_ACTUAL_DT = SRC.PI_PIP_ACTUAL_DT	
				, TRG.PI_PIP_END_PRIOR_TO_PLAN = SRC.PI_PIP_END_PRIOR_TO_PLAN
				, TRG.PI_PIP_END_PRIOR_TO_PLAN_RSN = SRC.PI_PIP_END_PRIOR_TO_PLAN_RSN
				, TRG.PI_PIP_SUCCESS_CMPLT = SRC.PI_PIP_SUCCESS_CMPLT
				, TRG.PI_PIP_PMAP_RTNG_SIGN_DT = SRC.PI_PIP_PMAP_RTNG_SIGN_DT	
				, TRG.PI_PIP_PMAP_RVW_SIGN_DT = SRC.PI_PIP_PMAP_RVW_SIGN_DT	
				, TRG.PI_PIP_PRPS_ACTN = SRC.PI_PIP_PRPS_ACTN	
				, TRG.PI_PIP_PRPS_ISSUE_DT = SRC.PI_PIP_PRPS_ISSUE_DT	
				, TRG.PI_PIP_ORAL_PRSNT_REQ	= SRC.PI_PIP_ORAL_PRSNT_REQ
				, TRG.PI_PIP_ORAL_PRSNT_DT = SRC.PI_PIP_ORAL_PRSNT_DT	
				, TRG.PI_PIP_WRTN_RESP_SBMT = SRC.PI_PIP_WRTN_RESP_SBMT	
				, TRG.PI_PIP_WRTN_RESP_DUE_DT = SRC.PI_PIP_WRTN_RESP_DUE_DT	
				, TRG.PI_PIP_WRTN_SBMT_DT = SRC.PI_PIP_WRTN_SBMT_DT	
				, TRG.PI_PIP_FIN_AGCY_DECISION = SRC.PI_PIP_FIN_AGCY_DECISION
				, TRG.PI_PIP_DECIDING_OFFICAL = SRC.PI_PIP_DECIDING_OFFICAL
				, TRG.PI_PIP_FIN_AGCY_DECISION_DT = SRC.PI_PIP_FIN_AGCY_DECISION_DT	
				, TRG.PI_PIP_DECISION_ISSUE_DT = SRC.PI_PIP_DECISION_ISSUE_DT	
				, TRG.PI_PIP_EFF_ACTN_DT = SRC.PI_PIP_EFF_ACTN_DT	
				, TRG.PI_PIP_EMPL_GRIEVANCE = SRC.PI_PIP_EMPL_GRIEVANCE	
				, TRG.PI_PIP_APPEAL_DECISION = SRC.PI_PIP_APPEAL_DECISION
				, TRG.PI_REASGN_NOTICE_DT = SRC.PI_REASGN_NOTICE_DT	
				, TRG.PI_REASGN_EFF_DT = SRC.PI_REASGN_EFF_DT	
				, TRG.PI_REASGN_CUR_ADMIN_CD = SRC.PI_REASGN_CUR_ADMIN_CD
				, TRG.PI_REASGN_CUR_ORG_NM = SRC.PI_REASGN_CUR_ORG_NM	
				, TRG.PI_REASGN_FIN_ADMIN_CD = SRC.PI_REASGN_FIN_ADMIN_CD
				, TRG.PI_REASGN_FIN_ORG_NM = SRC.PI_REASGN_FIN_ORG_NM	
				, TRG.PI_RMV_PRPS_ACTN_ISSUE_DT	= SRC.PI_RMV_PRPS_ACTN_ISSUE_DT
				, TRG.PI_RMV_EMPL_NOTC_LEV	= SRC.PI_RMV_EMPL_NOTC_LEV
				, TRG.PI_RMV_NOTC_LEV_START_DT = SRC.PI_RMV_NOTC_LEV_START_DT	
				, TRG.PI_RMV_NOTC_LEV_END_DT = SRC.PI_RMV_NOTC_LEV_END_DT	
				, TRG.PI_RMV_ORAL_PRSNT_REQ	= SRC.PI_RMV_ORAL_PRSNT_REQ
				, TRG.PI_RMV_ORAL_PRSNT_DT	= SRC.PI_RMV_ORAL_PRSNT_DT
				, TRG.PI_RMV_WRTN_RESP_DUE_DT	= SRC.PI_RMV_WRTN_RESP_DUE_DT
				, TRG.PI_RMV_WRTN_RESP_SBMT_DT	= SRC.PI_RMV_WRTN_RESP_SBMT_DT
				, TRG.PI_RMV_FIN_AGCY_DECISION	= SRC.PI_RMV_FIN_AGCY_DECISION
				, TRG.PI_RMV_FIN_DECIDING_OFC	= SRC.PI_RMV_FIN_DECIDING_OFC
				, TRG.PI_RMV_DECISION_ISSUE_DT	= SRC.PI_RMV_DECISION_ISSUE_DT
				, TRG.PI_RMV_EFF_DT	= SRC.PI_RMV_EFF_DT
				, TRG.PI_RMV_NUM_DAYS	= SRC.PI_RMV_NUM_DAYS
				, TRG.PI_RMV_APPEAL_DECISION = SRC.PI_RMV_APPEAL_DECISION	
				, TRG.PI_WRTN_NRTV_RVW_TYPE	= SRC.PI_WRTN_NRTV_RVW_TYPE
				, TRG.PI_WNR_SPCLST_RVW_CMPLT_DT = SRC.PI_WNR_SPCLST_RVW_CMPLT_DT	
				, TRG.PI_WNR_MGR_RVW_RTNG_DT	= SRC.PI_WNR_MGR_RVW_RTNG_DT
				, TRG.PI_WNR_CRITICAL_ELM	= SRC.PI_WNR_CRITICAL_ELM
				, TRG.PI_WNR_FIN_RATING = SRC.PI_WNR_FIN_RATING
				, TRG.PI_WNR_RVW_OFC_CONCUR_DT	= SRC.PI_WNR_RVW_OFC_CONCUR_DT
				, TRG.PI_WNR_WGI_WTHLD = SRC.PI_WNR_WGI_WTHLD
				, TRG.PI_WNR_WGI_RVW_DT	= SRC.PI_WNR_WGI_RVW_DT
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.PI_ACTION_TYPE
				, TRG.PI_NEXT_WGI_DUE_DT	
				, TRG.PI_PERF_COUNSEL_ISSUE_DT	
				, TRG.PI_CNSL_GRV_DECISION
				, TRG.PI_DMTN_PRPS_ACTN_ISSUE_DT	
				, TRG.PI_DMTN_ORAL_PRSNT_REQ
				, TRG.PI_DMTN_ORAL_PRSNT_DT	
				, TRG.PI_DMTN_WRTN_RESP_SBMT
				, TRG.PI_DMTN_WRTN_RESP_DUE_DT	
				, TRG.PI_DMTN_WRTN_RESP_SBMT_DT	
				, TRG.PI_DMTN_CUR_POS_TITLE
				, TRG.PI_DMTN_CUR_PAY_PLAN
				, TRG.PI_DMTN_CUR_JOB_SERIES
				, TRG.PI_DMTN_CUR_GRADE
				, TRG.PI_DMTN_CUR_STEP
				, TRG.PI_DMTN_PRPS_POS_TITLE
				, TRG.PI_DMTN_PRPS_PAY_PLAN
				, TRG.PI_DMTN_PRPS_JOB_SERIES
				, TRG.PI_DMTN_PRPS_GRADE
				, TRG.PI_DMTN_PRP_STEP
				, TRG.PI_DMTN_FIN_POS_TITLE
				, TRG.PI_DMTN_FIN_PAY_PLAN
				, TRG.PI_DMTN_FIN_JOB_SERIES
				, TRG.PI_DMTN_FIN_GRADE
				, TRG.PI_DMTN_FIN_STEP
				, TRG.PI_DMTN_FIN_AGCY_DECISION
				, TRG.PI_DMTN_FIN_DECIDING_OFC
				, TRG.PI_DMTN_FIN_DECISION_ISSUE_DT	
				, TRG.PI_DMTN_DECISION_EFF_DT	
				, TRG.PI_DMTN_APPEAL_DECISION
				, TRG.PI_PIP_RSNBL_ACMDTN
				, TRG.PI_PIP_EMPL_SBMT_MEDDOC
				, TRG.PI_PIP_DOC_SBMT_FOH_RVW
				, TRG.PI_PIP_WGI_WTHLD
				, TRG.PI_PIP_WGI_RVW_DT	
				, TRG.PI_PIP_MEDDOC_RVW_OUTCOME
				, TRG.PI_PIP_START_DT	
				, TRG.PI_PIP_END_DT	
				, TRG.PI_PIP_EXT_END_DT	
				, TRG.PI_PIP_EXT_END_REASON
				, TRG.PI_PIP_EXT_END_NOTIFY_DT	
				, TRG.PI_PIP_EXT_DT_LIST	
				, TRG.PI_PIP_ACTUAL_DT	
				, TRG.PI_PIP_END_PRIOR_TO_PLAN
				, TRG.PI_PIP_END_PRIOR_TO_PLAN_RSN
				, TRG.PI_PIP_SUCCESS_CMPLT
				, TRG.PI_PIP_PMAP_RTNG_SIGN_DT	
				, TRG.PI_PIP_PMAP_RVW_SIGN_DT	
				, TRG.PI_PIP_PRPS_ACTN	
				, TRG.PI_PIP_PRPS_ISSUE_DT	
				, TRG.PI_PIP_ORAL_PRSNT_REQ	
				, TRG.PI_PIP_ORAL_PRSNT_DT	
				, TRG.PI_PIP_WRTN_RESP_SBMT	
				, TRG.PI_PIP_WRTN_RESP_DUE_DT	
				, TRG.PI_PIP_WRTN_SBMT_DT	
				, TRG.PI_PIP_FIN_AGCY_DECISION
				, TRG.PI_PIP_DECIDING_OFFICAL
				, TRG.PI_PIP_FIN_AGCY_DECISION_DT	
				, TRG.PI_PIP_DECISION_ISSUE_DT	
				, TRG.PI_PIP_EFF_ACTN_DT	
				, TRG.PI_PIP_EMPL_GRIEVANCE	
				, TRG.PI_PIP_APPEAL_DECISION
				, TRG.PI_REASGN_NOTICE_DT	
				, TRG.PI_REASGN_EFF_DT	
				, TRG.PI_REASGN_CUR_ADMIN_CD
				, TRG.PI_REASGN_CUR_ORG_NM	
				, TRG.PI_REASGN_FIN_ADMIN_CD
				, TRG.PI_REASGN_FIN_ORG_NM	
				, TRG.PI_RMV_PRPS_ACTN_ISSUE_DT	
				, TRG.PI_RMV_EMPL_NOTC_LEV	
				, TRG.PI_RMV_NOTC_LEV_START_DT	
				, TRG.PI_RMV_NOTC_LEV_END_DT	
				, TRG.PI_RMV_ORAL_PRSNT_REQ	
				, TRG.PI_RMV_ORAL_PRSNT_DT	
				, TRG.PI_RMV_WRTN_RESP_DUE_DT	
				, TRG.PI_RMV_WRTN_RESP_SBMT_DT	
				, TRG.PI_RMV_FIN_AGCY_DECISION	
				, TRG.PI_RMV_FIN_DECIDING_OFC	
				, TRG.PI_RMV_DECISION_ISSUE_DT	
				, TRG.PI_RMV_EFF_DT	
				, TRG.PI_RMV_NUM_DAYS	
				, TRG.PI_RMV_APPEAL_DECISION	
				, TRG.PI_WRTN_NRTV_RVW_TYPE	
				, TRG.PI_WNR_SPCLST_RVW_CMPLT_DT	
				, TRG.PI_WNR_MGR_RVW_RTNG_DT	
				, TRG.PI_WNR_CRITICAL_ELM	
				, TRG.PI_WNR_FIN_RATING
				, TRG.PI_WNR_RVW_OFC_CONCUR_DT	
				, TRG.PI_WNR_WGI_WTHLD
				, TRG.PI_WNR_WGI_RVW_DT	               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.PI_ACTION_TYPE
				, SRC.PI_NEXT_WGI_DUE_DT	
				, SRC.PI_PERF_COUNSEL_ISSUE_DT	
				, SRC.PI_CNSL_GRV_DECISION
				, SRC.PI_DMTN_PRPS_ACTN_ISSUE_DT	
				, SRC.PI_DMTN_ORAL_PRSNT_REQ
				, SRC.PI_DMTN_ORAL_PRSNT_DT	
				, SRC.PI_DMTN_WRTN_RESP_SBMT
				, SRC.PI_DMTN_WRTN_RESP_DUE_DT	
				, SRC.PI_DMTN_WRTN_RESP_SBMT_DT	
				, SRC.PI_DMTN_CUR_POS_TITLE
				, SRC.PI_DMTN_CUR_PAY_PLAN
				, SRC.PI_DMTN_CUR_JOB_SERIES
				, SRC.PI_DMTN_CUR_GRADE
				, SRC.PI_DMTN_CUR_STEP
				, SRC.PI_DMTN_PRPS_POS_TITLE
				, SRC.PI_DMTN_PRPS_PAY_PLAN
				, SRC.PI_DMTN_PRPS_JOB_SERIES
				, SRC.PI_DMTN_PRPS_GRADE
				, SRC.PI_DMTN_PRP_STEP
				, SRC.PI_DMTN_FIN_POS_TITLE
				, SRC.PI_DMTN_FIN_PAY_PLAN
				, SRC.PI_DMTN_FIN_JOB_SERIES
				, SRC.PI_DMTN_FIN_GRADE
				, SRC.PI_DMTN_FIN_STEP
				, SRC.PI_DMTN_FIN_AGCY_DECISION
				, SRC.PI_DMTN_FIN_DECIDING_OFC
				, SRC.PI_DMTN_FIN_DECISION_ISSUE_DT	
				, SRC.PI_DMTN_DECISION_EFF_DT	
				, SRC.PI_DMTN_APPEAL_DECISION
				, SRC.PI_PIP_RSNBL_ACMDTN
				, SRC.PI_PIP_EMPL_SBMT_MEDDOC
				, SRC.PI_PIP_DOC_SBMT_FOH_RVW
				, SRC.PI_PIP_WGI_WTHLD
				, SRC.PI_PIP_WGI_RVW_DT	
				, SRC.PI_PIP_MEDDOC_RVW_OUTCOME
				, SRC.PI_PIP_START_DT	
				, SRC.PI_PIP_END_DT	
				, SRC.PI_PIP_EXT_END_DT	
				, SRC.PI_PIP_EXT_END_REASON
				, SRC.PI_PIP_EXT_END_NOTIFY_DT	
				, SRC.PI_PIP_EXT_DT_LIST	
				, SRC.PI_PIP_ACTUAL_DT	
				, SRC.PI_PIP_END_PRIOR_TO_PLAN
				, SRC.PI_PIP_END_PRIOR_TO_PLAN_RSN
				, SRC.PI_PIP_SUCCESS_CMPLT
				, SRC.PI_PIP_PMAP_RTNG_SIGN_DT	
				, SRC.PI_PIP_PMAP_RVW_SIGN_DT	
				, SRC.PI_PIP_PRPS_ACTN	
				, SRC.PI_PIP_PRPS_ISSUE_DT	
				, SRC.PI_PIP_ORAL_PRSNT_REQ	
				, SRC.PI_PIP_ORAL_PRSNT_DT	
				, SRC.PI_PIP_WRTN_RESP_SBMT	
				, SRC.PI_PIP_WRTN_RESP_DUE_DT	
				, SRC.PI_PIP_WRTN_SBMT_DT	
				, SRC.PI_PIP_FIN_AGCY_DECISION
				, SRC.PI_PIP_DECIDING_OFFICAL
				, SRC.PI_PIP_FIN_AGCY_DECISION_DT	
				, SRC.PI_PIP_DECISION_ISSUE_DT	
				, SRC.PI_PIP_EFF_ACTN_DT	
				, SRC.PI_PIP_EMPL_GRIEVANCE	
				, SRC.PI_PIP_APPEAL_DECISION
				, SRC.PI_REASGN_NOTICE_DT	
				, SRC.PI_REASGN_EFF_DT	
				, SRC.PI_REASGN_CUR_ADMIN_CD
				, SRC.PI_REASGN_CUR_ORG_NM	
				, SRC.PI_REASGN_FIN_ADMIN_CD
				, SRC.PI_REASGN_FIN_ORG_NM	
				, SRC.PI_RMV_PRPS_ACTN_ISSUE_DT	
				, SRC.PI_RMV_EMPL_NOTC_LEV	
				, SRC.PI_RMV_NOTC_LEV_START_DT	
				, SRC.PI_RMV_NOTC_LEV_END_DT	
				, SRC.PI_RMV_ORAL_PRSNT_REQ	
				, SRC.PI_RMV_ORAL_PRSNT_DT	
				, SRC.PI_RMV_WRTN_RESP_DUE_DT	
				, SRC.PI_RMV_WRTN_RESP_SBMT_DT	
				, SRC.PI_RMV_FIN_AGCY_DECISION	
				, SRC.PI_RMV_FIN_DECIDING_OFC	
				, SRC.PI_RMV_DECISION_ISSUE_DT	
				, SRC.PI_RMV_EFF_DT	
				, SRC.PI_RMV_NUM_DAYS	
				, SRC.PI_RMV_APPEAL_DECISION	
				, SRC.PI_WRTN_NRTV_RVW_TYPE	
				, SRC.PI_WNR_SPCLST_RVW_CMPLT_DT	
				, SRC.PI_WNR_MGR_RVW_RTNG_DT	
				, SRC.PI_WNR_CRITICAL_ELM	
				, SRC.PI_WNR_FIN_RATING
				, SRC.PI_WNR_RVW_OFC_CONCUR_DT	
				, SRC.PI_WNR_WGI_WTHLD
				, SRC.PI_WNR_WGI_RVW_DT	               
            );

		END;

		--------------------------------
		-- ERLR_GRIEVANCE table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_GRIEVANCE TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, X.GI_TYPE
					, X.GI_NEGOTIATED_GRIEVANCE_TYPE
					, X.GI_TIMELY_FILING_2
					, X.GI_IND_MANAGER
					, TO_DATE(X.GI_FILING_DT_2,'MM/DD/YYYY HH24:MI:SS') AS GI_FILING_DT_2
					, X.GI_TIMELY_FILING
					, TO_DATE(X.GI_FILING_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_FILING_DT
					, TO_DATE(X.GI_IND_MEETING_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_MEETING_DT
					, TO_DATE(X.GI_IND_STEP_1_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_STEP_1_DECISION_DT
					, TO_DATE(X.GI_IND_DECISION_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_DECISION_ISSUE_DT
					, X.GI_IND_STEP_1_DEADLINE
					, TO_DATE(X.GI_IND_STEP_1_EXT_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_STEP_1_EXT_DUE_DT
					, X.GI_IND_STEP_1_EXT_DUE_REASON
					, X.GI_STEP_2_REQUEST
					, TO_DATE(X.GI_IND_STEP_2_MTG_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_STEP_2_MTG_DT
					, TO_DATE(X.GI_IND_STEP_2_DECISION_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_STEP_2_DECISION_DUE_DT
					, TO_DATE(X.GI_IND_STEP_2_DCSN_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_STEP_2_DCSN_ISSUE_DT
					, X.GI_IND_STEP_2_DEADLINE
					, TO_DATE(X.GI_IND_EXT_2_EXT_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_EXT_2_EXT_DUE_DT
					, X.GI_IND_STEP_2_EXT_DUE_REASON
					, TO_DATE(X.GI_IND_THIRD_PARTY_APPEAL_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_THIRD_PARTY_APPEAL_DT
					, X.GI_IND_THIRD_APPEAL_REQUEST
					, X.GI_UM_GRIEVABILITY
					, TO_DATE(X.GI_MEETING_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_MEETING_DT
					, X.GI_GRIEVANCE_STATUS
					, TO_DATE(X.GI_ARBITRATION_DEADLINE_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_ARBITRATION_DEADLINE_DT
					, X.GI_ARBITRATION_REQUEST
					, X.GI_ADMIN_OFFCL_1
					, TO_DATE(X.GI_ADMIN_STG_1_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_ADMIN_STG_1_DECISION_DT
					, TO_DATE(X.GI_ADMIN_STG_1_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_ADMIN_STG_1_ISSUE_DT
					, X.GI_ADMIN_STG_2_RESP
					, X.GI_ADMIN_OFFCL_2
					, TO_DATE(X.GI_ADMIN_STG_2_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_ADMIN_STG_2_DECISION_DT
					, TO_DATE(X.GI_ADMIN_STG_2_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_ADMIN_STG_2_ISSUE_DT
                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS
                            GI_TYPE	NVARCHAR2(200) PATH './item[id="GI_TYPE"]/value'
							, GI_NEGOTIATED_GRIEVANCE_TYPE	NVARCHAR2(200) PATH './item[id="GI_NEGOTIATED_GRIEVANCE_TYPE"]/value'
							, GI_TIMELY_FILING_2	VARCHAR2(10) PATH './item[id="GI_TIMELY_FILING_2"]/value'	
							, GI_IND_MANAGER	NVARCHAR2(255) PATH './item[id="GI_IND_MANAGER"]/value/name'
							, GI_FILING_DT_2	VARCHAR2(10) PATH './item[id="GI_FILING_DT_2"]/value'
							, GI_TIMELY_FILING	VARCHAR2(10) PATH './item[id="GI_TIMELY_FILING"]/value'
							, GI_FILING_DT	VARCHAR2(10) PATH './item[id="GI_FILING_DT"]/value'
							, GI_IND_MEETING_DT	VARCHAR2(10) PATH './item[id="GI_IND_MEETING_DT"]/value'
							, GI_IND_STEP_1_DECISION_DT	VARCHAR2(10) PATH './item[id="GI_IND_STEP_1_DECISION_DT"]/value'
							, GI_IND_DECISION_ISSUE_DT	VARCHAR2(10) PATH './item[id="GI_IND_DECISION_ISSUE_DT"]/value'
							, GI_IND_STEP_1_DEADLINE	VARCHAR2(10) PATH './item[id="GI_IND_STEP_1_DEADLINE"]/value'
							, GI_IND_STEP_1_EXT_DUE_DT	VARCHAR2(10) PATH './item[id="GI_IND_STEP_1_EXT_DUE_DT"]/value'
							, GI_IND_STEP_1_EXT_DUE_REASON	NVARCHAR2(500) PATH './item[id="GI_IND_STEP_1_EXT_DUE_REASON"]/value'
							, GI_STEP_2_REQUEST	VARCHAR2(10) PATH './item[id="GI_STEP_2_REQUEST"]/value'
							, GI_IND_STEP_2_MTG_DT	VARCHAR2(10) PATH './item[id="GI_IND_STEP_2_MTG_DT"]/value'
							, GI_IND_STEP_2_DECISION_DUE_DT	VARCHAR2(10) PATH './item[id="GI_IND_STEP_2_DECISION_DUE_DT"]/value'
							, GI_IND_STEP_2_DCSN_ISSUE_DT	VARCHAR2(10) PATH './item[id="GI_IND_STEP_2_DECISION_ISSUE_DT"]/value'
							, GI_IND_STEP_2_DEADLINE	VARCHAR2(10) PATH './item[id="GI_IND_STEP_2_DEADLINE"]/value'
							, GI_IND_EXT_2_EXT_DUE_DT	VARCHAR2(10) PATH './item[id="GI_IND_EXT_2_EXT_DUE_DT"]/value'
							, GI_IND_STEP_2_EXT_DUE_REASON	NVARCHAR2(500) PATH './item[id="GI_IND_STEP_2_EXT_DUE_REASON"]/value'
							, GI_IND_THIRD_PARTY_APPEAL_DT	VARCHAR2(10) PATH './item[id="GI_IND_THIRD_PARTY_APPEAL_DT"]/value'
							, GI_IND_THIRD_APPEAL_REQUEST	VARCHAR2(10) PATH './item[id="GI_IND_THIRD_APPEAL_REQUEST"]/value'
							, GI_UM_GRIEVABILITY	NVARCHAR2(200) PATH './item[id="GI_UM_GRIEVABILITY"]/value'
							, GI_MEETING_DT	VARCHAR2(10) PATH './item[id="GI_MEETING_DT"]/value'
							, GI_GRIEVANCE_STATUS	NVARCHAR2(200) PATH './item[id="GI_GRIEVANCE_STATUS"]/value'
							, GI_ARBITRATION_DEADLINE_DT	VARCHAR2(10) PATH './item[id="GI_ARBITRATION_DEADLINE_DT"]/value'
							, GI_ARBITRATION_REQUEST	VARCHAR2(10) PATH './item[id="GI_ARBITRATION_REQUEST"]/value'
							, GI_ADMIN_OFFCL_1	NVARCHAR2(255) PATH './item[id="GI_ADMIN_OFFCL_1"]/value/name'
							, GI_ADMIN_STG_1_DECISION_DT	VARCHAR2(10) PATH './item[id="GI_ADMIN_STG_1_DECISION_DT"]/value'
							, GI_ADMIN_STG_1_ISSUE_DT	VARCHAR2(10) PATH './item[id="GI_ADMIN_STG_1_ISSUE_DT"]/value'
							, GI_ADMIN_STG_2_RESP	VARCHAR2(10) PATH './item[id="GI_ADMIN_STG_2_RESP"]/value'
							, GI_ADMIN_OFFCL_2	NVARCHAR2(255) PATH './item[id="GI_ADMIN_OFFCL_2"]/value/name'
							, GI_ADMIN_STG_2_DECISION_DT	VARCHAR2(10) PATH './item[id="GI_ADMIN_STG_2_DECISION_DT"]/value'
							, GI_ADMIN_STG_2_ISSUE_DT	VARCHAR2(10) PATH './item[id="GI_ADMIN_STG_2_ISSUE_DT"]/value'
							
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
                TRG.GI_TYPE = SRC.GI_TYPE
				, TRG.GI_NEGOTIATED_GRIEVANCE_TYPE = SRC.GI_NEGOTIATED_GRIEVANCE_TYPE
				, TRG.GI_TIMELY_FILING_2 = SRC.GI_TIMELY_FILING_2
				, TRG.GI_IND_MANAGER = SRC.GI_IND_MANAGER
				, TRG.GI_FILING_DT_2 = SRC.GI_FILING_DT_2
				, TRG.GI_TIMELY_FILING = SRC.GI_TIMELY_FILING
				, TRG.GI_FILING_DT = SRC.GI_FILING_DT
				, TRG.GI_IND_MEETING_DT = SRC.GI_IND_MEETING_DT
				, TRG.GI_IND_STEP_1_DECISION_DT = SRC.GI_IND_STEP_1_DECISION_DT
				, TRG.GI_IND_DECISION_ISSUE_DT = SRC.GI_IND_DECISION_ISSUE_DT
				, TRG.GI_IND_STEP_1_DEADLINE = SRC.GI_IND_STEP_1_DEADLINE
				, TRG.GI_IND_STEP_1_EXT_DUE_DT = SRC.GI_IND_STEP_1_EXT_DUE_DT
				, TRG.GI_IND_STEP_1_EXT_DUE_REASON = SRC.GI_IND_STEP_1_EXT_DUE_REASON
				, TRG.GI_STEP_2_REQUEST = SRC.GI_STEP_2_REQUEST
				, TRG.GI_IND_STEP_2_MTG_DT = SRC.GI_IND_STEP_2_MTG_DT
				, TRG.GI_IND_STEP_2_DECISION_DUE_DT = SRC.GI_IND_STEP_2_DECISION_DUE_DT
				, TRG.GI_IND_STEP_2_DCSN_ISSUE_DT = SRC.GI_IND_STEP_2_DCSN_ISSUE_DT	
				, TRG.GI_IND_STEP_2_DEADLINE = SRC.GI_IND_STEP_2_DEADLINE
				, TRG.GI_IND_EXT_2_EXT_DUE_DT = SRC.GI_IND_EXT_2_EXT_DUE_DT
				, TRG.GI_IND_STEP_2_EXT_DUE_REASON = SRC.GI_IND_STEP_2_EXT_DUE_REASON
				, TRG.GI_IND_THIRD_PARTY_APPEAL_DT = SRC.GI_IND_THIRD_PARTY_APPEAL_DT
				, TRG.GI_IND_THIRD_APPEAL_REQUEST = SRC.GI_IND_THIRD_APPEAL_REQUEST
				, TRG.GI_UM_GRIEVABILITY = SRC.GI_UM_GRIEVABILITY
				, TRG.GI_MEETING_DT = SRC.GI_MEETING_DT
				, TRG.GI_GRIEVANCE_STATUS = SRC.GI_GRIEVANCE_STATUS
				, TRG.GI_ARBITRATION_DEADLINE_DT = SRC.GI_ARBITRATION_DEADLINE_DT
				, TRG.GI_ARBITRATION_REQUEST = SRC.GI_ARBITRATION_REQUEST
				, TRG.GI_ADMIN_OFFCL_1 = SRC.GI_ADMIN_OFFCL_1
				, TRG.GI_ADMIN_STG_1_DECISION_DT = SRC.GI_ADMIN_STG_1_DECISION_DT
				, TRG.GI_ADMIN_STG_1_ISSUE_DT = SRC.GI_ADMIN_STG_1_ISSUE_DT
				, TRG.GI_ADMIN_STG_2_RESP = SRC.GI_ADMIN_STG_2_RESP
				, TRG.GI_ADMIN_OFFCL_2 = SRC.GI_ADMIN_OFFCL_2
				, TRG.GI_ADMIN_STG_2_DECISION_DT = SRC.GI_ADMIN_STG_2_DECISION_DT
				, TRG.GI_ADMIN_STG_2_ISSUE_DT = SRC.GI_ADMIN_STG_2_ISSUE_DT
				
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.GI_TYPE				
				, TRG.GI_NEGOTIATED_GRIEVANCE_TYPE				
				, TRG.GI_TIMELY_FILING_2
				, TRG.GI_IND_MANAGER
				, TRG.GI_FILING_DT_2
				, TRG.GI_TIMELY_FILING
				, TRG.GI_FILING_DT
				, TRG.GI_IND_MEETING_DT
				, TRG.GI_IND_STEP_1_DECISION_DT
				, TRG.GI_IND_DECISION_ISSUE_DT
				, TRG.GI_IND_STEP_1_DEADLINE
				, TRG.GI_IND_STEP_1_EXT_DUE_DT
				, TRG.GI_IND_STEP_1_EXT_DUE_REASON
				, TRG.GI_STEP_2_REQUEST
				, TRG.GI_IND_STEP_2_MTG_DT
				, TRG.GI_IND_STEP_2_DECISION_DUE_DT
				, TRG.GI_IND_STEP_2_DCSN_ISSUE_DT	
				, TRG.GI_IND_STEP_2_DEADLINE
				, TRG.GI_IND_EXT_2_EXT_DUE_DT
				, TRG.GI_IND_STEP_2_EXT_DUE_REASON
				, TRG.GI_IND_THIRD_PARTY_APPEAL_DT
				, TRG.GI_IND_THIRD_APPEAL_REQUEST
				, TRG.GI_UM_GRIEVABILITY
				, TRG.GI_MEETING_DT
				, TRG.GI_GRIEVANCE_STATUS
				, TRG.GI_ARBITRATION_DEADLINE_DT
				, TRG.GI_ARBITRATION_REQUEST
				, TRG.GI_ADMIN_OFFCL_1
				, TRG.GI_ADMIN_STG_1_DECISION_DT
				, TRG.GI_ADMIN_STG_1_ISSUE_DT	
				, TRG.GI_ADMIN_STG_2_RESP
				, TRG.GI_ADMIN_OFFCL_2
				, TRG.GI_ADMIN_STG_2_DECISION_DT
				, TRG.GI_ADMIN_STG_2_ISSUE_DT
               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.GI_TYPE				
				, SRC.GI_NEGOTIATED_GRIEVANCE_TYPE				
				, SRC.GI_TIMELY_FILING_2
				, SRC.GI_IND_MANAGER
				, SRC.GI_FILING_DT_2
				, SRC.GI_TIMELY_FILING
				, SRC.GI_FILING_DT
				, SRC.GI_IND_MEETING_DT
				, SRC.GI_IND_STEP_1_DECISION_DT
				, SRC.GI_IND_DECISION_ISSUE_DT
				, SRC.GI_IND_STEP_1_DEADLINE
				, SRC.GI_IND_STEP_1_EXT_DUE_DT
				, SRC.GI_IND_STEP_1_EXT_DUE_REASON
				, SRC.GI_STEP_2_REQUEST
				, SRC.GI_IND_STEP_2_MTG_DT
				, SRC.GI_IND_STEP_2_DECISION_DUE_DT
				, SRC.GI_IND_STEP_2_DCSN_ISSUE_DT	
				, SRC.GI_IND_STEP_2_DEADLINE
				, SRC.GI_IND_EXT_2_EXT_DUE_DT
				, SRC.GI_IND_STEP_2_EXT_DUE_REASON
				, SRC.GI_IND_THIRD_PARTY_APPEAL_DT
				, SRC.GI_IND_THIRD_APPEAL_REQUEST
				, SRC.GI_UM_GRIEVABILITY
				, SRC.GI_MEETING_DT
				, SRC.GI_GRIEVANCE_STATUS
				, SRC.GI_ARBITRATION_DEADLINE_DT
				, SRC.GI_ARBITRATION_REQUEST
				, SRC.GI_ADMIN_OFFCL_1
				, SRC.GI_ADMIN_STG_1_DECISION_DT
				, SRC.GI_ADMIN_STG_1_ISSUE_DT	
				, SRC.GI_ADMIN_STG_2_RESP
				, SRC.GI_ADMIN_OFFCL_2
				, SRC.GI_ADMIN_STG_2_DECISION_DT
				, SRC.GI_ADMIN_STG_2_ISSUE_DT   
				            
            );

		END;

		--------------------------------
		-- ERLR_INVESTIGATION table
		--------------------------------
		BEGIN
            MERGE INTO ERLR_INVESTIGATION TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, X.INVESTIGATION_TYPE
					, X.I_MISCONDUCT_FOUND                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS
                            INVESTIGATION_TYPE	NVARCHAR2(200)	PATH './item[id="INVESTIGATION_TYPE"]/value'
							, I_MISCONDUCT_FOUND	NVARCHAR2(3)	PATH './item[id="I_MISCONDUCT_FOUND"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET                
				TRG.INVESTIGATION_TYPE = SRC.INVESTIGATION_TYPE
				, TRG.I_MISCONDUCT_FOUND = SRC.I_MISCONDUCT_FOUND
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.INVESTIGATION_TYPE
				, TRG.I_MISCONDUCT_FOUND   
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.INVESTIGATION_TYPE
				, SRC.I_MISCONDUCT_FOUND               
            );

		END;
		
		--------------------------------
		-- ERLR_APPEAL table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_APPEAL TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, X.AP_ERLR_APPEAL_TYPE
					, TO_DATE(X.AP_ERLR_APPEAL_FILE_DT,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_APPEAL_FILE_DT
					, X.AP_ERLR_APPEAL_TIMING
					, X.AP_APPEAL_HEARING_REQUESTED
					, X.AP_ARBITRATOR_LAST_NAME
					, X.AP_ARBITRATOR_FIRST_NAME
					, X.AP_ARBITRATOR_MIDDLE_NAME
					, X.AP_ARBITRATOR_EMAIL
					, X.AP_ARBITRATOR_PHONE_NUM
					, X.AP_ARBITRATOR_ORG_AFFIL
					, X.AP_ARBITRATOR_MAILING_ADDR
					, TO_DATE(X.AP_ERLR_PREHEARING_DT,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_PREHEARING_DT
					, TO_DATE(X.AP_ERLR_HEARING_DT,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_HEARING_DT	
					, TO_DATE(X.AP_POSTHEARING_BRIEF_DUE,'MM/DD/YYYY HH24:MI:SS') AS AP_POSTHEARING_BRIEF_DUE
					, TO_DATE(X.AP_FINAL_ARBITRATOR_DCSN_DT,'MM/DD/YYYY HH24:MI:SS') AS AP_FINAL_ARBITRATOR_DCSN_DT
					, X.AP_ERLR_EXCEPTION_FILED
					, TO_DATE(X.AP_ERLR_EXCEPTION_FILE_DT,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_EXCEPTION_FILE_DT
					, TO_DATE(X.AP_RESPON_TO_EXCEPT_DUE,'MM/DD/YYYY HH24:MI:SS') AS AP_RESPON_TO_EXCEPT_DUE
					, TO_DATE(X.AP_FINAL_FLRA_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS AP_FINAL_FLRA_DECISION_DT
					, TO_DATE(X.AP_ERLR_STEP_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_STEP_DECISION_DT
					, X.AP_ERLR_ARBITRATION_INVOKED
					, X.AP_ARBITRATOR_LAST_NAME_3
					, X.AP_ARBITRATOR_FIRST_NAME_3
					, X.AP_ARBITRATOR_MIDDLE_NAME_3
					, X.AP_ARBITRATOR_EMAIL_3
					, X.AP_ARBITRATOR_PHONE_NUM_3
					, X.AP_ARBITRATOR_ORG_AFFIL_3
					, X.AP_ARBITRATION_MAILING_ADDR_3
					, TO_DATE(X.AP_ERLR_PREHEARING_DT_2,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_PREHEARING_DT_2
					, TO_DATE(X.AP_ERLR_HEARING_DT_2,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_HEARING_DT_2
					, TO_DATE(X.AP_POSTHEARING_BRIEF_DUE_2,'MM/DD/YYYY HH24:MI:SS') AS AP_POSTHEARING_BRIEF_DUE_2
					, TO_DATE(X.AP_FINAL_ARBITRATOR_DCSN_DT_2,'MM/DD/YYYY HH24:MI:SS') AS AP_FINAL_ARBITRATOR_DCSN_DT_2
					, X.AP_ERLR_EXCEPTION_FILED_2
					, TO_DATE(X.AP_ERLR_EXCEPTION_FILE_DT_2,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_EXCEPTION_FILE_DT_2
					, TO_DATE(X.AP_RESPON_TO_EXCEPT_DUE_2,'MM/DD/YYYY HH24:MI:SS') AS AP_RESPON_TO_EXCEPT_DUE_2
					, TO_DATE(X.AP_FINAL_FLRA_DECISION_DT_2,'MM/DD/YYYY HH24:MI:SS') AS AP_FINAL_FLRA_DECISION_DT_2
					, X.AP_ARBITRATOR_LAST_NAME_2
					, X.AP_ARBITRATOR_FIRST_NAME_2
					, X.AP_ARBITRATOR_MIDDLE_NAME_2
					, X.AP_ARBITRATOR_EMAIL_2
					, X.AP_ARBITRATOR_PHONE_NUM_2
					, X.AP_ARBITRATOR_ORG_AFFIL_2
					, X.AP_ARBITRATION_MAILING_ADDR_2
					, TO_DATE(X.AP_ERLR_PREHEARING_DT_SC,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_PREHEARING_DT_SC
					, TO_DATE(X.AP_ERLR_HEARING_DT_SC,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_HEARING_DT_SC
					, X.AP_ARBITRATOR_LAST_NAME_4
					, X.AP_ARBITRATOR_FIRST_NAME_4
					, X.AP_ARBITRATOR_MIDDLE_NAME_4
					, X.AP_ARBITRATOR_EMAIL_4
					, X.AP_ARBITRATOR_PHONE_NUM_4
					, X.AP_ARBITRATOR_ORG_AFFIL_4
					, X.AP_ARBITRATOR_MAILING_ADDR_4
					, TO_DATE(X.AP_DT_SETTLEMENT_DISCUSSION,'MM/DD/YYYY HH24:MI:SS') AS AP_DT_SETTLEMENT_DISCUSSION
					, TO_DATE(X.AP_DT_PREHEARING_DISCLOSURE,'MM/DD/YYYY HH24:MI:SS') AS AP_DT_PREHEARING_DISCLOSURE
					, TO_DATE(X.AP_DT_AGNCY_FILE_RESPON_DUE,'MM/DD/YYYY HH24:MI:SS') AS AP_DT_AGNCY_FILE_RESPON_DUE  
					, TO_DATE(X.AP_ERLR_PREHEARING_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_PREHEARING_DT_MSPB   
					, X.AP_WAS_DISCOVERY_INITIATED
					, TO_DATE(X.AP_ERLR_DT_DISCOVERY_DUE,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_DT_DISCOVERY_DUE
					, TO_DATE(X.AP_ERLR_HEARING_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_HEARING_DT_MSPB
					, TO_DATE(X.AP_PETITION_FILE_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS AP_PETITION_FILE_DT_MSPB
					, X.AP_WAS_PETITION_FILED_MSPB
					, TO_DATE(X.AP_INITIAL_DECISION_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS AP_INITIAL_DECISION_DT_MSPB
					, TO_DATE(X.AP_FINAL_BOARD_DCSN_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS AP_FINAL_BOARD_DCSN_DT_MSPB
					, TO_DATE(X.AP_DT_SETTLEMENT_DISCUSSION_2,'MM/DD/YYYY HH24:MI:SS') AS AP_DT_SETTLEMENT_DISCUSSION_2
					, TO_DATE(X.AP_DT_PREHEARING_DISCLOSURE_2,'MM/DD/YYYY HH24:MI:SS') AS AP_DT_PREHEARING_DISCLOSURE_2
					, TO_DATE(X.AP_DT_AGNCY_FILE_RESPON_DUE_2,'MM/DD/YYYY HH24:MI:SS') AS AP_DT_AGNCY_FILE_RESPON_DUE_2
					, TO_DATE(X.AP_ERLR_PREHEARING_DT_FLRA,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_PREHEARING_DT_FLRA
					, TO_DATE(X.AP_ERLR_HEARING_DT_FLRA,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_HEARING_DT_FLRA
					, TO_DATE(X.AP_INITIAL_DECISION_DT_FLRA,'MM/DD/YYYY HH24:MI:SS') AS AP_INITIAL_DECISION_DT_FLRA
					, X.AP_WAS_PETITION_FILED_FLRA
					, TO_DATE(X.AP_PETITION_FILE_DT_FLRA,'MM/DD/YYYY HH24:MI:SS') AS AP_PETITION_FILE_DT_FLRA
					, TO_DATE(X.AP_FINAL_BOARD_DCSN_DT_FLRA,'MM/DD/YYYY HH24:MI:SS') AS AP_FINAL_BOARD_DCSN_DT_FLRA

                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS                            
							AP_ERLR_APPEAL_TYPE	NVARCHAR2(200)	PATH './item[id="AP_ERLR_APPEAL_TYPE"]/value'
							, AP_ERLR_APPEAL_FILE_DT	VARCHAR2(10)	PATH './item[id="AP_ERLR_APPEAL_FILE_DT"]/value'
							, AP_ERLR_APPEAL_TIMING	NVARCHAR2(3)	PATH './item[id="AP_ERLR_APPEAL_TIMING"]/value'
							, AP_APPEAL_HEARING_REQUESTED	NVARCHAR2(3)	PATH './item[id="AP_ERLR_APPEAL_HEARING_REQUESTED"]/value'
							, AP_ARBITRATOR_LAST_NAME	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_LAST_NAME"]/value'
							, AP_ARBITRATOR_FIRST_NAME	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_FIRST_NAME"]/value'
							, AP_ARBITRATOR_MIDDLE_NAME	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_MIDDLE_NAME"]/value'
							, AP_ARBITRATOR_EMAIL	NVARCHAR2(100)	PATH './item[id="AP_ERLR_ARBITRATOR_EMAIL"]/value'
							, AP_ARBITRATOR_PHONE_NUM	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_PHONE_NUMBER"]/value'
							, AP_ARBITRATOR_ORG_AFFIL	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_ORGANIZATION_AFFILIATION"]/value'
							, AP_ARBITRATOR_MAILING_ADDR	NVARCHAR2(250)	PATH './item[id="AP_ERLR_ARBITRATION_MAILING_ADDR"]/value'
							, AP_ERLR_PREHEARING_DT	VARCHAR2(10)	PATH './item[id="AP_ERLR_PREHEARING_DT"]/value'
							, AP_ERLR_HEARING_DT	VARCHAR2(10)	PATH './item[id="AP_ERLR_HEARING_DT"]/value'
							, AP_POSTHEARING_BRIEF_DUE	VARCHAR2(10)	PATH './item[id="AP_ERLR_POSTHEARING_BRIEF_DUE"]/value'
							, AP_FINAL_ARBITRATOR_DCSN_DT	VARCHAR2(10)	PATH './item[id="AP_ERLR_FINAL_ARBITRATOR_DECISION_DT"]/value'
							, AP_ERLR_EXCEPTION_FILED	NVARCHAR2(3)	PATH './item[id="AP_ERLR_EXCEPTION_FILED"]/value'
							, AP_ERLR_EXCEPTION_FILE_DT	VARCHAR2(10)	PATH './item[id="AP_ERLR_EXCEPTION_FILE_DT"]/value'
							, AP_RESPON_TO_EXCEPT_DUE	VARCHAR2(10)	PATH './item[id="AP_ERLR_RESPONSE_TO_EXCEPTIONS_DUE"]/value'
							, AP_FINAL_FLRA_DECISION_DT	VARCHAR2(10)	PATH './item[id="AP_ERLR_FINAL_FLRA_DECISION_DT"]/value'
							, AP_ERLR_STEP_DECISION_DT	VARCHAR2(10)	PATH './item[id="AP_ERLR_STEP_DECISION_DT"]/value'
							, AP_ERLR_ARBITRATION_INVOKED	NVARCHAR2(3)	PATH './item[id="AP_ERLR_ARBITRATION_INVOKED"]/value'
							, AP_ARBITRATOR_LAST_NAME_3	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_LAST_NAME_3"]/value'
							, AP_ARBITRATOR_FIRST_NAME_3	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_FIRST_NAME_3"]/value'
							, AP_ARBITRATOR_MIDDLE_NAME_3	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_MIDDLE_NAME_3"]/value'
							, AP_ARBITRATOR_EMAIL_3	NVARCHAR2(100)	PATH './item[id="AP_ERLR_ARBITRATOR_EMAIL_3"]/value'
							, AP_ARBITRATOR_PHONE_NUM_3	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_PHONE_NUMBER_3"]/value'
							, AP_ARBITRATOR_ORG_AFFIL_3	NVARCHAR2(100)	PATH './item[id="AP_ERLR_ARBITRATOR_ORGANIZATION_AFFILIATION_3"]/value'
							, AP_ARBITRATION_MAILING_ADDR_3	NVARCHAR2(250)	PATH './item[id="AP_ERLR_ARBITRATION_MAILING_ADDR_3"]/value'
							, AP_ERLR_PREHEARING_DT_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_PREHEARING_DT_2"]/value'
							, AP_ERLR_HEARING_DT_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_HEARING_DT_2"]/value'
							, AP_POSTHEARING_BRIEF_DUE_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_POSTHEARING_BRIEF_DUE_2"]/value'
							, AP_FINAL_ARBITRATOR_DCSN_DT_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_FINAL_ARBITRATOR_DECISION_DT_2"]/value'
							, AP_ERLR_EXCEPTION_FILED_2	NVARCHAR2(3)	PATH './item[id="AP_ERLR_EXCEPTION_FILED_2"]/value'
							, AP_ERLR_EXCEPTION_FILE_DT_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_EXCEPTION_FILE_DT_2"]/value'
							, AP_RESPON_TO_EXCEPT_DUE_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_RESPONSE_TO_EXCEPTIONS_DUE_2"]/value'
							, AP_FINAL_FLRA_DECISION_DT_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_FINAL_FLRA_DECISION_DT_2"]/value'
							, AP_ARBITRATOR_LAST_NAME_2	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_LAST_NAME_2"]/value'
							, AP_ARBITRATOR_FIRST_NAME_2	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_FIRST_NAME_2"]/value'
							, AP_ARBITRATOR_MIDDLE_NAME_2	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_MIDDLE_NAME_2"]/value'
							, AP_ARBITRATOR_EMAIL_2	NVARCHAR2(100)	PATH './item[id="AP_ERLR_ARBITRATOR_EMAIL_2"]/value'
							, AP_ARBITRATOR_PHONE_NUM_2	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_PHONE_NUMBER_2"]/value'
							, AP_ARBITRATOR_ORG_AFFIL_2	NVARCHAR2(100)	PATH './item[id="AP_ERLR_ARBITRATOR_ORGANIZATION_AFFILIATION_2"]/value'
							, AP_ARBITRATION_MAILING_ADDR_2	NVARCHAR2(250)	PATH './item[id="AP_ERLR_ARBITRATION_MAILING_ADDR_2"]/value'
							, AP_ERLR_PREHEARING_DT_SC	VARCHAR2(10)	PATH './item[id="AP_ERLR_PREHEARING_DT_SC"]/value'
							, AP_ERLR_HEARING_DT_SC	VARCHAR2(10)	PATH './item[id="AP_ERLR_HEARING_DT_SC"]/value'
							, AP_ARBITRATOR_LAST_NAME_4	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_LAST_NAME_4"]/value'
							, AP_ARBITRATOR_FIRST_NAME_4	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_FIRST_NAME_4"]/value'
							, AP_ARBITRATOR_MIDDLE_NAME_4	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_MIDDLE_NAME_4"]/value'
							, AP_ARBITRATOR_EMAIL_4	NVARCHAR2(100)	PATH './item[id="AP_ERLR_ARBITRATOR_EMAIL_4"]/value'
							, AP_ARBITRATOR_PHONE_NUM_4	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_PHONE_NUMBER_4"]/value'
							, AP_ARBITRATOR_ORG_AFFIL_4	NVARCHAR2(100)	PATH './item[id="AP_ERLR_ARBITRATOR_ORGANIZATION_AFFILIATION_4"]/value'
							, AP_ARBITRATOR_MAILING_ADDR_4	NVARCHAR2(250)	PATH './item[id="AP_ERLR_ARBITRATION_MAILING_ADDR"]/value'
							, AP_DT_SETTLEMENT_DISCUSSION	VARCHAR2(10)	PATH './item[id="AP_ERLR_DT_SETTLEMENT_DISCUSSION"]/value'
							, AP_DT_PREHEARING_DISCLOSURE	VARCHAR2(10)	PATH './item[id="AP_ERLR_DT_PREHEARING_DISCLOSURE"]/value'
							, AP_DT_AGNCY_FILE_RESPON_DUE   VARCHAR2(10)	PATH './item[id="AP_ERLR_DT_AGENCY_FILE_RESPONSE_DUE"]/value'
							, AP_ERLR_PREHEARING_DT_MSPB    VARCHAR2(10)	PATH './item[id="AP_ERLR_PREHEARING_DT_MSPB"]/value'
							, AP_WAS_DISCOVERY_INITIATED	NVARCHAR2(3)	PATH './item[id="AP_ERLR_WAS_DISCOVERY_INITIATED"]/value'
							, AP_ERLR_DT_DISCOVERY_DUE	VARCHAR2(10)	PATH './item[id="AP_ERLR_DT_DISCOVERY_DUE"]/value'
							, AP_ERLR_HEARING_DT_MSPB	VARCHAR2(10)	PATH './item[id="AP_ERLR_HEARING_DT_MSPB"]/value'
							, AP_PETITION_FILE_DT_MSPB	VARCHAR2(10)	PATH './item[id="AP_ERLR_PETITION_4REVIEW_DT"]/value'
							, AP_WAS_PETITION_FILED_MSPB	NVARCHAR2(3)	PATH './item[id="AP_ERLR_WAS_PETITION_4REVIEW_MSPB"]/value'
							, AP_INITIAL_DECISION_DT_MSPB	VARCHAR2(10)	PATH './item[id="AP_ERLR_initial_decision_MSPB_DT"]/value'
							, AP_FINAL_BOARD_DCSN_DT_MSPB	VARCHAR2(10)	PATH './item[id="AP_ERLR_FINAL_DECISION_MSPB_DT"]/value'
							, AP_DT_SETTLEMENT_DISCUSSION_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_DT_SETTLEMENT_DISCUSSION_FLRA"]/value'
							, AP_DT_PREHEARING_DISCLOSURE_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_DT_PREHEARING_DISCLOSURE_FLRA"]/value'
							, AP_DT_AGNCY_FILE_RESPON_DUE_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_DT_AGENCY_FILE_RESPONSE_DUE_FLRA"]/value'
							, AP_ERLR_PREHEARING_DT_FLRA	VARCHAR2(10)	PATH './item[id="AP_ERLR_PREHEARING_DT_FLRA"]/value'
							, AP_ERLR_HEARING_DT_FLRA	VARCHAR2(10)	PATH './item[id="AP_ERLR_HEARING_DT_FLRA"]/value'
							, AP_INITIAL_DECISION_DT_FLRA	VARCHAR2(10)	PATH './item[id="AP_ERLR_DECISION_DT_FLRA"]/value'
							, AP_WAS_PETITION_FILED_FLRA	NVARCHAR2(3)	PATH './item[id="AP_ERLR_WAS_DECISION_APPEALED_FLRA"]/value'
							, AP_PETITION_FILE_DT_FLRA	VARCHAR2(10)	PATH './item[id="AP_ERLR_APPEAL_FILE_DT_FLRA"]/value'
							, AP_FINAL_BOARD_DCSN_DT_FLRA	VARCHAR2(10)	PATH './item[id="AP_ERLR_FINAL_DECISION_FLRA_DT"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET				
				TRG.AP_ERLR_APPEAL_TYPE = SRC.AP_ERLR_APPEAL_TYPE
				, TRG.AP_ERLR_APPEAL_FILE_DT = SRC.AP_ERLR_APPEAL_FILE_DT
				, TRG.AP_ERLR_APPEAL_TIMING = SRC.AP_ERLR_APPEAL_TIMING
				, TRG.AP_APPEAL_HEARING_REQUESTED = SRC.AP_APPEAL_HEARING_REQUESTED
				, TRG.AP_ARBITRATOR_LAST_NAME = SRC.AP_ARBITRATOR_LAST_NAME
				, TRG.AP_ARBITRATOR_FIRST_NAME = SRC.AP_ARBITRATOR_FIRST_NAME
				, TRG.AP_ARBITRATOR_MIDDLE_NAME = SRC.AP_ARBITRATOR_MIDDLE_NAME
				, TRG.AP_ARBITRATOR_EMAIL = SRC.AP_ARBITRATOR_EMAIL
				, TRG.AP_ARBITRATOR_PHONE_NUM = SRC.AP_ARBITRATOR_PHONE_NUM
				, TRG.AP_ARBITRATOR_ORG_AFFIL = SRC.AP_ARBITRATOR_ORG_AFFIL
				, TRG.AP_ARBITRATOR_MAILING_ADDR = SRC.AP_ARBITRATOR_MAILING_ADDR
				, TRG.AP_ERLR_PREHEARING_DT = SRC.AP_ERLR_PREHEARING_DT
				, TRG.AP_ERLR_HEARING_DT = SRC.AP_ERLR_HEARING_DT
				, TRG.AP_POSTHEARING_BRIEF_DUE = SRC.AP_POSTHEARING_BRIEF_DUE
				, TRG.AP_FINAL_ARBITRATOR_DCSN_DT = SRC.AP_FINAL_ARBITRATOR_DCSN_DT
				, TRG.AP_ERLR_EXCEPTION_FILED = SRC.AP_ERLR_EXCEPTION_FILED
				, TRG.AP_ERLR_EXCEPTION_FILE_DT = SRC.AP_ERLR_EXCEPTION_FILE_DT
				, TRG.AP_RESPON_TO_EXCEPT_DUE = SRC.AP_RESPON_TO_EXCEPT_DUE
				, TRG.AP_FINAL_FLRA_DECISION_DT = SRC.AP_FINAL_FLRA_DECISION_DT
				, TRG.AP_ERLR_STEP_DECISION_DT = SRC.AP_ERLR_STEP_DECISION_DT
				, TRG.AP_ERLR_ARBITRATION_INVOKED = SRC.AP_ERLR_ARBITRATION_INVOKED
				, TRG.AP_ARBITRATOR_LAST_NAME_3 = SRC.AP_ARBITRATOR_LAST_NAME_3
				, TRG.AP_ARBITRATOR_FIRST_NAME_3 = SRC.AP_ARBITRATOR_FIRST_NAME_3
				, TRG.AP_ARBITRATOR_MIDDLE_NAME_3 = SRC.AP_ARBITRATOR_MIDDLE_NAME_3
				, TRG.AP_ARBITRATOR_EMAIL_3 = SRC.AP_ARBITRATOR_EMAIL_3
				, TRG.AP_ARBITRATOR_PHONE_NUM_3 = SRC.AP_ARBITRATOR_PHONE_NUM_3
				, TRG.AP_ARBITRATOR_ORG_AFFIL_3 = SRC.AP_ARBITRATOR_ORG_AFFIL_3
				, TRG.AP_ARBITRATION_MAILING_ADDR_3 = SRC.AP_ARBITRATION_MAILING_ADDR_3
				, TRG.AP_ERLR_PREHEARING_DT_2 = SRC.AP_ERLR_PREHEARING_DT_2
				, TRG.AP_ERLR_HEARING_DT_2 = SRC.AP_ERLR_HEARING_DT_2
				, TRG.AP_POSTHEARING_BRIEF_DUE_2 = SRC.AP_POSTHEARING_BRIEF_DUE_2
				, TRG.AP_FINAL_ARBITRATOR_DCSN_DT_2 = SRC.AP_FINAL_ARBITRATOR_DCSN_DT_2
				, TRG.AP_ERLR_EXCEPTION_FILED_2 = SRC.AP_ERLR_EXCEPTION_FILED_2
				, TRG.AP_ERLR_EXCEPTION_FILE_DT_2 = SRC.AP_ERLR_EXCEPTION_FILE_DT_2
				, TRG.AP_RESPON_TO_EXCEPT_DUE_2 = SRC.AP_RESPON_TO_EXCEPT_DUE_2
				, TRG.AP_FINAL_FLRA_DECISION_DT_2 = SRC.AP_FINAL_FLRA_DECISION_DT_2
				, TRG.AP_ARBITRATOR_LAST_NAME_2 = SRC.AP_ARBITRATOR_LAST_NAME_2
				, TRG.AP_ARBITRATOR_FIRST_NAME_2 = SRC.AP_ARBITRATOR_FIRST_NAME_2
				, TRG.AP_ARBITRATOR_MIDDLE_NAME_2 = SRC.AP_ARBITRATOR_MIDDLE_NAME_2
				, TRG.AP_ARBITRATOR_EMAIL_2 = SRC.AP_ARBITRATOR_EMAIL_2
				, TRG.AP_ARBITRATOR_PHONE_NUM_2 = SRC.AP_ARBITRATOR_PHONE_NUM_2
				, TRG.AP_ARBITRATOR_ORG_AFFIL_2 = SRC.AP_ARBITRATOR_ORG_AFFIL_2
				, TRG.AP_ARBITRATION_MAILING_ADDR_2 = SRC.AP_ARBITRATION_MAILING_ADDR_2
				, TRG.AP_ERLR_PREHEARING_DT_SC = SRC.AP_ERLR_PREHEARING_DT_SC
				, TRG.AP_ERLR_HEARING_DT_SC = SRC.AP_ERLR_HEARING_DT_SC
				, TRG.AP_ARBITRATOR_LAST_NAME_4 = SRC.AP_ARBITRATOR_LAST_NAME_4
				, TRG.AP_ARBITRATOR_FIRST_NAME_4 = SRC.AP_ARBITRATOR_FIRST_NAME_4
				, TRG.AP_ARBITRATOR_MIDDLE_NAME_4 = SRC.AP_ARBITRATOR_MIDDLE_NAME_4
				, TRG.AP_ARBITRATOR_EMAIL_4 = SRC.AP_ARBITRATOR_EMAIL_4
				, TRG.AP_ARBITRATOR_PHONE_NUM_4 = SRC.AP_ARBITRATOR_PHONE_NUM_4
				, TRG.AP_ARBITRATOR_ORG_AFFIL_4 = SRC.AP_ARBITRATOR_ORG_AFFIL_4
				, TRG.AP_ARBITRATOR_MAILING_ADDR_4 = SRC.AP_ARBITRATOR_MAILING_ADDR_4
				, TRG.AP_DT_SETTLEMENT_DISCUSSION = SRC.AP_DT_SETTLEMENT_DISCUSSION
				, TRG.AP_DT_PREHEARING_DISCLOSURE = SRC.AP_DT_PREHEARING_DISCLOSURE
				, TRG.AP_DT_AGNCY_FILE_RESPON_DUE = SRC.AP_DT_AGNCY_FILE_RESPON_DUE
				, TRG.AP_ERLR_PREHEARING_DT_MSPB = SRC.AP_ERLR_PREHEARING_DT_MSPB
				, TRG.AP_WAS_DISCOVERY_INITIATED = SRC.AP_WAS_DISCOVERY_INITIATED
				, TRG.AP_ERLR_DT_DISCOVERY_DUE = SRC.AP_ERLR_DT_DISCOVERY_DUE
				, TRG.AP_ERLR_HEARING_DT_MSPB = SRC.AP_ERLR_HEARING_DT_MSPB
				, TRG.AP_PETITION_FILE_DT_MSPB = SRC.AP_PETITION_FILE_DT_MSPB
				, TRG.AP_WAS_PETITION_FILED_MSPB = SRC.AP_WAS_PETITION_FILED_MSPB
				, TRG.AP_INITIAL_DECISION_DT_MSPB = SRC.AP_INITIAL_DECISION_DT_MSPB
				, TRG.AP_FINAL_BOARD_DCSN_DT_MSPB = SRC.AP_FINAL_BOARD_DCSN_DT_MSPB
				, TRG.AP_DT_SETTLEMENT_DISCUSSION_2 = SRC.AP_DT_SETTLEMENT_DISCUSSION_2
				, TRG.AP_DT_PREHEARING_DISCLOSURE_2 = SRC.AP_DT_PREHEARING_DISCLOSURE_2
				, TRG.AP_DT_AGNCY_FILE_RESPON_DUE_2 = SRC.AP_DT_AGNCY_FILE_RESPON_DUE_2
				, TRG.AP_ERLR_PREHEARING_DT_FLRA = SRC.AP_ERLR_PREHEARING_DT_FLRA
				, TRG.AP_ERLR_HEARING_DT_FLRA = SRC.AP_ERLR_HEARING_DT_FLRA
				, TRG.AP_INITIAL_DECISION_DT_FLRA = SRC.AP_INITIAL_DECISION_DT_FLRA
				, TRG.AP_WAS_PETITION_FILED_FLRA = SRC.AP_WAS_PETITION_FILED_FLRA
				, TRG.AP_PETITION_FILE_DT_FLRA = SRC.AP_PETITION_FILE_DT_FLRA
				, TRG.AP_FINAL_BOARD_DCSN_DT_FLRA = SRC.AP_FINAL_BOARD_DCSN_DT_FLRA
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.AP_ERLR_APPEAL_TYPE
				, TRG.AP_ERLR_APPEAL_FILE_DT
				, TRG.AP_ERLR_APPEAL_TIMING
				, TRG.AP_APPEAL_HEARING_REQUESTED
				, TRG.AP_ARBITRATOR_LAST_NAME
				, TRG.AP_ARBITRATOR_FIRST_NAME
				, TRG.AP_ARBITRATOR_MIDDLE_NAME
				, TRG.AP_ARBITRATOR_EMAIL
				, TRG.AP_ARBITRATOR_PHONE_NUM
				, TRG.AP_ARBITRATOR_ORG_AFFIL
				, TRG.AP_ARBITRATOR_MAILING_ADDR
				, TRG.AP_ERLR_PREHEARING_DT
				, TRG.AP_ERLR_HEARING_DT	
				, TRG.AP_POSTHEARING_BRIEF_DUE
				, TRG.AP_FINAL_ARBITRATOR_DCSN_DT
				, TRG.AP_ERLR_EXCEPTION_FILED
				, TRG.AP_ERLR_EXCEPTION_FILE_DT
				, TRG.AP_RESPON_TO_EXCEPT_DUE
				, TRG.AP_FINAL_FLRA_DECISION_DT
				, TRG.AP_ERLR_STEP_DECISION_DT
				, TRG.AP_ERLR_ARBITRATION_INVOKED
				, TRG.AP_ARBITRATOR_LAST_NAME_3
				, TRG.AP_ARBITRATOR_FIRST_NAME_3
				, TRG.AP_ARBITRATOR_MIDDLE_NAME_3
				, TRG.AP_ARBITRATOR_EMAIL_3
				, TRG.AP_ARBITRATOR_PHONE_NUM_3
				, TRG.AP_ARBITRATOR_ORG_AFFIL_3
				, TRG.AP_ARBITRATION_MAILING_ADDR_3
				, TRG.AP_ERLR_PREHEARING_DT_2
				, TRG.AP_ERLR_HEARING_DT_2
				, TRG.AP_POSTHEARING_BRIEF_DUE_2
				, TRG.AP_FINAL_ARBITRATOR_DCSN_DT_2
				, TRG.AP_ERLR_EXCEPTION_FILED_2
				, TRG.AP_ERLR_EXCEPTION_FILE_DT_2
				, TRG.AP_RESPON_TO_EXCEPT_DUE_2
				, TRG.AP_FINAL_FLRA_DECISION_DT_2
				, TRG.AP_ARBITRATOR_LAST_NAME_2
				, TRG.AP_ARBITRATOR_FIRST_NAME_2
				, TRG.AP_ARBITRATOR_MIDDLE_NAME_2
				, TRG.AP_ARBITRATOR_EMAIL_2
				, TRG.AP_ARBITRATOR_PHONE_NUM_2
				, TRG.AP_ARBITRATOR_ORG_AFFIL_2
				, TRG.AP_ARBITRATION_MAILING_ADDR_2
				, TRG.AP_ERLR_PREHEARING_DT_SC
				, TRG.AP_ERLR_HEARING_DT_SC
				, TRG.AP_ARBITRATOR_LAST_NAME_4
				, TRG.AP_ARBITRATOR_FIRST_NAME_4
				, TRG.AP_ARBITRATOR_MIDDLE_NAME_4
				, TRG.AP_ARBITRATOR_EMAIL_4
				, TRG.AP_ARBITRATOR_PHONE_NUM_4
				, TRG.AP_ARBITRATOR_ORG_AFFIL_4
				, TRG.AP_ARBITRATOR_MAILING_ADDR_4
				, TRG.AP_DT_SETTLEMENT_DISCUSSION
				, TRG.AP_DT_PREHEARING_DISCLOSURE
				, TRG.AP_DT_AGNCY_FILE_RESPON_DUE
				, TRG.AP_ERLR_PREHEARING_DT_MSPB
				, TRG.AP_WAS_DISCOVERY_INITIATED
				, TRG.AP_ERLR_DT_DISCOVERY_DUE
				, TRG.AP_ERLR_HEARING_DT_MSPB
				, TRG.AP_PETITION_FILE_DT_MSPB
				, TRG.AP_WAS_PETITION_FILED_MSPB
				, TRG.AP_INITIAL_DECISION_DT_MSPB
				, TRG.AP_FINAL_BOARD_DCSN_DT_MSPB
				, TRG.AP_DT_SETTLEMENT_DISCUSSION_2
				, TRG.AP_DT_PREHEARING_DISCLOSURE_2
				, TRG.AP_DT_AGNCY_FILE_RESPON_DUE_2
				, TRG.AP_ERLR_PREHEARING_DT_FLRA
				, TRG.AP_ERLR_HEARING_DT_FLRA
				, TRG.AP_INITIAL_DECISION_DT_FLRA
				, TRG.AP_WAS_PETITION_FILED_FLRA
				, TRG.AP_PETITION_FILE_DT_FLRA
				, TRG.AP_FINAL_BOARD_DCSN_DT_FLRA
               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.AP_ERLR_APPEAL_TYPE
				, SRC.AP_ERLR_APPEAL_FILE_DT
				, SRC.AP_ERLR_APPEAL_TIMING
				, SRC.AP_APPEAL_HEARING_REQUESTED
				, SRC.AP_ARBITRATOR_LAST_NAME
				, SRC.AP_ARBITRATOR_FIRST_NAME
				, SRC.AP_ARBITRATOR_MIDDLE_NAME
				, SRC.AP_ARBITRATOR_EMAIL
				, SRC.AP_ARBITRATOR_PHONE_NUM
				, SRC.AP_ARBITRATOR_ORG_AFFIL
				, SRC.AP_ARBITRATOR_MAILING_ADDR
				, SRC.AP_ERLR_PREHEARING_DT
				, SRC.AP_ERLR_HEARING_DT	
				, SRC.AP_POSTHEARING_BRIEF_DUE
				, SRC.AP_FINAL_ARBITRATOR_DCSN_DT
				, SRC.AP_ERLR_EXCEPTION_FILED
				, SRC.AP_ERLR_EXCEPTION_FILE_DT
				, SRC.AP_RESPON_TO_EXCEPT_DUE
				, SRC.AP_FINAL_FLRA_DECISION_DT
				, SRC.AP_ERLR_STEP_DECISION_DT
				, SRC.AP_ERLR_ARBITRATION_INVOKED
				, SRC.AP_ARBITRATOR_LAST_NAME_3
				, SRC.AP_ARBITRATOR_FIRST_NAME_3
				, SRC.AP_ARBITRATOR_MIDDLE_NAME_3
				, SRC.AP_ARBITRATOR_EMAIL_3
				, SRC.AP_ARBITRATOR_PHONE_NUM_3
				, SRC.AP_ARBITRATOR_ORG_AFFIL_3
				, SRC.AP_ARBITRATION_MAILING_ADDR_3
				, SRC.AP_ERLR_PREHEARING_DT_2
				, SRC.AP_ERLR_HEARING_DT_2
				, SRC.AP_POSTHEARING_BRIEF_DUE_2
				, SRC.AP_FINAL_ARBITRATOR_DCSN_DT_2
				, SRC.AP_ERLR_EXCEPTION_FILED_2
				, SRC.AP_ERLR_EXCEPTION_FILE_DT_2
				, SRC.AP_RESPON_TO_EXCEPT_DUE_2
				, SRC.AP_FINAL_FLRA_DECISION_DT_2
				, SRC.AP_ARBITRATOR_LAST_NAME_2
				, SRC.AP_ARBITRATOR_FIRST_NAME_2
				, SRC.AP_ARBITRATOR_MIDDLE_NAME_2
				, SRC.AP_ARBITRATOR_EMAIL_2
				, SRC.AP_ARBITRATOR_PHONE_NUM_2
				, SRC.AP_ARBITRATOR_ORG_AFFIL_2
				, SRC.AP_ARBITRATION_MAILING_ADDR_2
				, SRC.AP_ERLR_PREHEARING_DT_SC
				, SRC.AP_ERLR_HEARING_DT_SC
				, SRC.AP_ARBITRATOR_LAST_NAME_4
				, SRC.AP_ARBITRATOR_FIRST_NAME_4
				, SRC.AP_ARBITRATOR_MIDDLE_NAME_4
				, SRC.AP_ARBITRATOR_EMAIL_4
				, SRC.AP_ARBITRATOR_PHONE_NUM_4
				, SRC.AP_ARBITRATOR_ORG_AFFIL_4
				, SRC.AP_ARBITRATOR_MAILING_ADDR_4
				, SRC.AP_DT_SETTLEMENT_DISCUSSION
				, SRC.AP_DT_PREHEARING_DISCLOSURE
				, SRC.AP_DT_AGNCY_FILE_RESPON_DUE
				, SRC.AP_ERLR_PREHEARING_DT_MSPB
				, SRC.AP_WAS_DISCOVERY_INITIATED
				, SRC.AP_ERLR_DT_DISCOVERY_DUE
				, SRC.AP_ERLR_HEARING_DT_MSPB
				, SRC.AP_PETITION_FILE_DT_MSPB
				, SRC.AP_WAS_PETITION_FILED_MSPB
				, SRC.AP_INITIAL_DECISION_DT_MSPB
				, SRC.AP_FINAL_BOARD_DCSN_DT_MSPB
				, SRC.AP_DT_SETTLEMENT_DISCUSSION_2
				, SRC.AP_DT_PREHEARING_DISCLOSURE_2
				, SRC.AP_DT_AGNCY_FILE_RESPON_DUE_2
				, SRC.AP_ERLR_PREHEARING_DT_FLRA
				, SRC.AP_ERLR_HEARING_DT_FLRA
				, SRC.AP_INITIAL_DECISION_DT_FLRA
				, SRC.AP_WAS_PETITION_FILED_FLRA
				, SRC.AP_PETITION_FILE_DT_FLRA
				, SRC.AP_FINAL_BOARD_DCSN_DT_FLRA
               
            );

		END;

		--------------------------------
		-- ERLR_WGI_DNL table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_WGI_DNL TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, TO_DATE(X.WGI_DTR_DENIAL_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS WGI_DTR_DENIAL_ISSUED_DT
					, WGI_DTR_EMP_REQ_RECON
					, TO_DATE(X.WGI_DTR_RECON_REQ_DT,'MM/DD/YYYY HH24:MI:SS') AS WGI_DTR_RECON_REQ_DT
					, TO_DATE(X.WGI_DTR_RECON_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS WGI_DTR_RECON_ISSUE_DT
					, WGI_DTR_DENIED
					, TO_DATE(X.WGI_DTR_DENIAL_ISSUE_TO_EMP_DT,'MM/DD/YYYY HH24:MI:SS') AS WGI_DTR_DENIAL_ISSUE_TO_EMP_DT
					, TO_DATE(X.WGI_RVW_REDTR_NOTI_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS WGI_RVW_REDTR_NOTI_ISSUED_DT
					, WGI_REVIEW_DTR_FAVORABLE
					, WGI_REVIEW_EMP_REQ_RECON
					, TO_DATE(X.WGI_REVIEW_RECON_REQ_DT,'MM/DD/YYYY HH24:MI:SS') AS WGI_REVIEW_RECON_REQ_DT
					, TO_DATE(X.WGI_REVIEW_RECON_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS WGI_REVIEW_RECON_ISSUE_DT
					, WGI_REVIEW_DENIED
					, WGI_EMP_APPEAL_DECISION
                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS                            
							WGI_DTR_DENIAL_ISSUED_DT	VARCHAR2(10) PATH './item[id="WGI_DTR_DENIAL_ISSUED_DT"]/value'
							, WGI_DTR_EMP_REQ_RECON	NVARCHAR2(3) PATH './item[id="WGI_DTR_EMP_REQ_RECON"]/value'
							, WGI_DTR_RECON_REQ_DT	VARCHAR2(10) PATH './item[id="WGI_DTR_RECON_REQ_DT"]/value'
							, WGI_DTR_RECON_ISSUE_DT	VARCHAR2(10) PATH './item[id="WGI_DTR_RECON_ISSUE_DT"]/value'
							, WGI_DTR_DENIED	NVARCHAR2(3) PATH './item[id="WGI_DTR_DENIED"]/value'
							, WGI_DTR_DENIAL_ISSUE_TO_EMP_DT	VARCHAR2(10) PATH './item[id="WGI_DTR_DENIAL_ISSUE_TO_EMP_DT"]/value'							
							, WGI_RVW_REDTR_NOTI_ISSUED_DT	VARCHAR2(10) PATH './item[id="WGI_REVIEW_DTR_NOTICE_ISSUED_DT"]/value'
							, WGI_REVIEW_DTR_FAVORABLE	NVARCHAR2(3) PATH './item[id="WGI_REVIEW_DTR_FAVORABLE"]/value'
							, WGI_REVIEW_EMP_REQ_RECON	NVARCHAR2(3) PATH './item[id="WGI_REVIEW_EMP_REQ_RECON"]/value'
							, WGI_REVIEW_RECON_REQ_DT	VARCHAR2(10) PATH './item[id="WGI_REVIEW_RECON_REQ_DT"]/value'
							, WGI_REVIEW_RECON_ISSUE_DT	VARCHAR2(10) PATH './item[id="WGI_REVIEW_RECON_ISSUE_DT"]/value'
							, WGI_REVIEW_DENIED	NVARCHAR2(3) PATH './item[id="WGI_REVIEW_DENIED"]/value'
							, WGI_EMP_APPEAL_DECISION	NVARCHAR2(3) PATH './item[id="WGI_EMP_APPEAL_DECISION"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
            	TRG.WGI_DTR_DENIAL_ISSUED_DT = SRC.WGI_DTR_DENIAL_ISSUED_DT
				, TRG.WGI_DTR_EMP_REQ_RECON = SRC.WGI_DTR_EMP_REQ_RECON
				, TRG.WGI_DTR_RECON_REQ_DT = SRC.WGI_DTR_RECON_REQ_DT
				, TRG.WGI_DTR_RECON_ISSUE_DT = SRC.WGI_DTR_RECON_ISSUE_DT
				, TRG.WGI_DTR_DENIED = SRC.WGI_DTR_DENIED
				, TRG.WGI_DTR_DENIAL_ISSUE_TO_EMP_DT = SRC.WGI_DTR_DENIAL_ISSUE_TO_EMP_DT
				, TRG.WGI_RVW_REDTR_NOTI_ISSUED_DT = SRC.WGI_RVW_REDTR_NOTI_ISSUED_DT
				, TRG.WGI_REVIEW_DTR_FAVORABLE = SRC.WGI_REVIEW_DTR_FAVORABLE
				, TRG.WGI_REVIEW_EMP_REQ_RECON = SRC.WGI_REVIEW_EMP_REQ_RECON
				, TRG.WGI_REVIEW_RECON_REQ_DT = SRC.WGI_REVIEW_RECON_REQ_DT
				, TRG.WGI_REVIEW_RECON_ISSUE_DT = SRC.WGI_REVIEW_RECON_ISSUE_DT
				, TRG.WGI_REVIEW_DENIED = SRC.WGI_REVIEW_DENIED
				, TRG.WGI_EMP_APPEAL_DECISION = SRC.WGI_EMP_APPEAL_DECISION
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.WGI_DTR_DENIAL_ISSUED_DT
				, TRG.WGI_DTR_EMP_REQ_RECON
				, TRG.WGI_DTR_RECON_REQ_DT
				, TRG.WGI_DTR_RECON_ISSUE_DT
				, TRG.WGI_DTR_DENIED
				, TRG.WGI_DTR_DENIAL_ISSUE_TO_EMP_DT
				, TRG.WGI_RVW_REDTR_NOTI_ISSUED_DT
				, TRG.WGI_REVIEW_DTR_FAVORABLE
				, TRG.WGI_REVIEW_EMP_REQ_RECON
				, TRG.WGI_REVIEW_RECON_REQ_DT
				, TRG.WGI_REVIEW_RECON_ISSUE_DT
				, TRG.WGI_REVIEW_DENIED
				, TRG.WGI_EMP_APPEAL_DECISION
               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.WGI_DTR_DENIAL_ISSUED_DT
				, SRC.WGI_DTR_EMP_REQ_RECON
				, SRC.WGI_DTR_RECON_REQ_DT
				, SRC.WGI_DTR_RECON_ISSUE_DT
				, SRC.WGI_DTR_DENIED
				, SRC.WGI_DTR_DENIAL_ISSUE_TO_EMP_DT
				, SRC.WGI_RVW_REDTR_NOTI_ISSUED_DT
				, SRC.WGI_REVIEW_DTR_FAVORABLE
				, SRC.WGI_REVIEW_EMP_REQ_RECON
				, SRC.WGI_REVIEW_RECON_REQ_DT
				, SRC.WGI_REVIEW_RECON_ISSUE_DT
				, SRC.WGI_REVIEW_DENIED
				, SRC.WGI_EMP_APPEAL_DECISION
               
            );

		END;

		--------------------------------
		-- ERLR_MEDDOC table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_MEDDOC TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, X.MD_REQUEST_REASON
					, TO_DATE(X.MD_MED_DOC_SBMT_DEADLINE_DT,'MM/DD/YYYY HH24:MI:SS') AS MD_MED_DOC_SBMT_DEADLINE_DT
					, TO_DATE(X.MD_FMLA_DOC_SBMT_DT,'MM/DD/YYYY HH24:MI:SS') AS MD_FMLA_DOC_SBMT_DT
					, TO_DATE(X.MD_FMLA_BEGIN_DT,'MM/DD/YYYY HH24:MI:SS') AS MD_FMLA_BEGIN_DT
					, X.MD_FMLA_APROVED
					, X.MD_FMLA_DISAPRV_REASON
					, X.MD_FMLA_GRIEVANCE
					, X.MD_MEDEXAM_EXTENDED
					, X.MD_MEDEXAM_ACCEPTED
					, TO_DATE(X.MD_MEDEXAM_RECEIVED_DT,'MM/DD/YYYY HH24:MI:SS') AS MD_MEDEXAM_RECEIVED_DT
					, X.MD_DOC_SUBMITTED
					, TO_DATE(X.MD_DOC_SBMT_DT,'MM/DD/YYYY HH24:MI:SS') AS MD_DOC_SBMT_DT
					, X.MD_DOC_SBMT_FOH
					, X.MD_DOC_REVIEW_OUTCOME
					, X.MD_DOC_ADMTV_ACCEPTABLE
					, X.MD_DOC_ADMTV_REJECT_REASON
                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS                            
							MD_REQUEST_REASON	NUMBER(20,0) PATH './item[id="MD_REQUEST_REASON"]/value'
							, MD_MED_DOC_SBMT_DEADLINE_DT	NVARCHAR2(10) PATH './item[id="MD_MED_DOC_SBMT_DEADLINE_DT"]/value'
							, MD_FMLA_DOC_SBMT_DT	NVARCHAR2(10) PATH './item[id="MD_FMLA_DOC_SBMT_DT"]/value'
							, MD_FMLA_BEGIN_DT	NVARCHAR2(10) PATH './item[id="MD_FMLA_BEGIN_DT"]/value'
							, MD_FMLA_APROVED	NVARCHAR2(3) PATH './item[id="MD_FMLA_APROVED"]/value'
							, MD_FMLA_DISAPRV_REASON	NUMBER(20,0) PATH './item[id="MD_FMLA_DISAPRV_REASON"]/value'
							, MD_FMLA_GRIEVANCE	NVARCHAR2(3) PATH './item[id="MD_FMLA_GRIEVANCE"]/value'
							, MD_MEDEXAM_EXTENDED	NVARCHAR2(3) PATH './item[id="MD_MEDEXAM_EXTENDED"]/value'
							, MD_MEDEXAM_ACCEPTED	NVARCHAR2(3) PATH './item[id="MD_MEDEXAM_ACCEPTED"]/value'
							, MD_MEDEXAM_RECEIVED_DT	NVARCHAR2(10) PATH './item[id="MD_MEDEXAM_RECEIVED_DT"]/value'
							, MD_DOC_SUBMITTED	NVARCHAR2(3) PATH './item[id="MD_DOC_SUBMITTED"]/value'
							, MD_DOC_SBMT_DT	NVARCHAR2(10) PATH './item[id="MD_DOC_SBMT_DT"]/value'
							, MD_DOC_SBMT_FOH	NVARCHAR2(3) PATH './item[id="MD_DOC_SBMT_FOH"]/value'
							, MD_DOC_REVIEW_OUTCOME	NVARCHAR2(140) PATH './item[id="MD_DOC_REVIEW_OUTCOME"]/value'
							, MD_DOC_ADMTV_ACCEPTABLE	NVARCHAR2(3) PATH './item[id="MD_DOC_ADMTV_ACCEPTABLE"]/value'
							, MD_DOC_ADMTV_REJECT_REASON	NUMBER(20,0) PATH './item[id="MD_DOC_ADMTV_REJECT_REASON"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
				TRG.MD_REQUEST_REASON = SRC.MD_REQUEST_REASON
				, TRG.MD_MED_DOC_SBMT_DEADLINE_DT = SRC.MD_MED_DOC_SBMT_DEADLINE_DT
				, TRG.MD_FMLA_DOC_SBMT_DT = SRC.MD_FMLA_DOC_SBMT_DT
				, TRG.MD_FMLA_BEGIN_DT = SRC.MD_FMLA_BEGIN_DT
				, TRG.MD_FMLA_APROVED = SRC.MD_FMLA_APROVED
				, TRG.MD_FMLA_DISAPRV_REASON = SRC.MD_FMLA_DISAPRV_REASON
				, TRG.MD_FMLA_GRIEVANCE = SRC.MD_FMLA_GRIEVANCE
				, TRG.MD_MEDEXAM_EXTENDED = SRC.MD_MEDEXAM_EXTENDED
				, TRG.MD_MEDEXAM_ACCEPTED = SRC.MD_MEDEXAM_ACCEPTED
				, TRG.MD_MEDEXAM_RECEIVED_DT = SRC.MD_MEDEXAM_RECEIVED_DT
				, TRG.MD_DOC_SUBMITTED = SRC.MD_DOC_SUBMITTED
				, TRG.MD_DOC_SBMT_DT = SRC.MD_DOC_SBMT_DT
				, TRG.MD_DOC_SBMT_FOH = SRC.MD_DOC_SBMT_FOH
				, TRG.MD_DOC_REVIEW_OUTCOME = SRC.MD_DOC_REVIEW_OUTCOME
				, TRG.MD_DOC_ADMTV_ACCEPTABLE = SRC.MD_DOC_ADMTV_ACCEPTABLE
				, TRG.MD_DOC_ADMTV_REJECT_REASON = SRC.MD_DOC_ADMTV_REJECT_REASON
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.MD_REQUEST_REASON
				, TRG.MD_MED_DOC_SBMT_DEADLINE_DT
				, TRG.MD_FMLA_DOC_SBMT_DT
				, TRG.MD_FMLA_BEGIN_DT
				, TRG.MD_FMLA_APROVED
				, TRG.MD_FMLA_DISAPRV_REASON
				, TRG.MD_FMLA_GRIEVANCE
				, TRG.MD_MEDEXAM_EXTENDED
				, TRG.MD_MEDEXAM_ACCEPTED
				, TRG.MD_MEDEXAM_RECEIVED_DT
				, TRG.MD_DOC_SUBMITTED
				, TRG.MD_DOC_SBMT_DT
				, TRG.MD_DOC_SBMT_FOH
				, TRG.MD_DOC_REVIEW_OUTCOME
				, TRG.MD_DOC_ADMTV_ACCEPTABLE
				, TRG.MD_DOC_ADMTV_REJECT_REASON
               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.MD_REQUEST_REASON
				, SRC.MD_MED_DOC_SBMT_DEADLINE_DT
				, SRC.MD_FMLA_DOC_SBMT_DT
				, SRC.MD_FMLA_BEGIN_DT
				, SRC.MD_FMLA_APROVED
				, SRC.MD_FMLA_DISAPRV_REASON
				, SRC.MD_FMLA_GRIEVANCE
				, SRC.MD_MEDEXAM_EXTENDED
				, SRC.MD_MEDEXAM_ACCEPTED
				, SRC.MD_MEDEXAM_RECEIVED_DT
				, SRC.MD_DOC_SUBMITTED
				, SRC.MD_DOC_SBMT_DT
				, SRC.MD_DOC_SBMT_FOH
				, SRC.MD_DOC_REVIEW_OUTCOME
				, SRC.MD_DOC_ADMTV_ACCEPTABLE
				, SRC.MD_DOC_ADMTV_REJECT_REASON
               
            );

		END;

		--------------------------------
		-- ERLR_INFO_REQUEST table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_INFO_REQUEST TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, X.IR_REQUESTER	
					, X.IR_CMS_REQUESTER_NAME	
					, X.IR_CMS_REQUESTER_PHONE	
					, X.IR_NCMS_REQUESTER_LAST_NAME	
					, X.IR_NCMS_REQUESTER_FIRST_NAME
					, X.IR_NCMS_REQUESTER_MN	
					, X.IR_NON_CMS_REQUESTER_PHONE	
					, X.IR_NON_CMS_REQUESTER_EMAIL	
					, X.IR_NCMS_REQUESTER_ORG_AFFIL	
					, TO_DATE(X.IR_SUBMIT_DT,'MM/DD/YYYY HH24:MI:SS') AS IR_SUBMIT_DT
					, X.IR_MEET_PTCLRIZED_NEED_STND
					, X.IR_RSNABLY_AVAIL_N_NECESSARY
					, X.IR_PRTCT_DISCLOSURE_BY_LAW
					, X.IR_MAINTAINED_BY_AGENCY
					, X.IR_COLLECTIVE_BARGAINING_UNIT
					, X.IR_APPROVE
					, TO_DATE(X.IR_PROVIDE_DT,'MM/DD/YYYY HH24:MI:SS') AS IR_PROVIDE_DT
					, X.IR_DENIAL_NOTICE_DT_LIST
					, X.IR_APPEAL_DENIAL
                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS
                            IR_REQUESTER	NVARCHAR2(20)	 PATH './item[id="IR_REQUESTER"]/value'
							, IR_CMS_REQUESTER_NAME	NVARCHAR2(200)	PATH './item[id="IR_CMS_REQUESTER_NAME"]/value/value'
							, IR_CMS_REQUESTER_PHONE	NVARCHAR2(50)	PATH './item[id="IR_CMS_REQUESTER_PHONE"]/value'
							, IR_NCMS_REQUESTER_LAST_NAME	NVARCHAR2(50)	PATH './item[id="IR_NON_CMS_REQUESTER_LAST_NAME"]/value'
							, IR_NCMS_REQUESTER_FIRST_NAME	NVARCHAR2(50)	PATH './item[id="IR_NON_CMS_REQUESTER_FIRST_NAME"]/value'
							, IR_NCMS_REQUESTER_MN	NVARCHAR2(50)	PATH './item[id="IR_NON_CMS_REQUESTER_MIDDLE_NAME"]/value'
							, IR_NON_CMS_REQUESTER_PHONE	NVARCHAR2(50)	PATH './item[id="IR_NON_CMS_REQUESTER_PHONE"]/value'
							, IR_NON_CMS_REQUESTER_EMAIL	NVARCHAR2(100)	PATH './item[id="IR_NON_CMS_REQUESTER_EMAIL"]/value'
							, IR_NCMS_REQUESTER_ORG_AFFIL	NVARCHAR2(50)	PATH './item[id="IR_NON_CMS_REQUESTER_ORGANIZATION_AFFILIATION"]/value'
							, IR_SUBMIT_DT	NVARCHAR2(10)	PATH './item[id="IR_SUBMIT_DT"]/value'
							, IR_MEET_PTCLRIZED_NEED_STND	VARCHAR2(3)	PATH './item[id="IR_MEET_PARTICULARIZED_NEED_STANDARD"]/value'
							, IR_RSNABLY_AVAIL_N_NECESSARY	VARCHAR2(3)	PATH './item[id="IR_REASONABLY_AVAILABLE_AND_NECESSARY"]/value'
							, IR_PRTCT_DISCLOSURE_BY_LAW	VARCHAR2(3)	PATH './item[id="IR_PROTECTED_FROM_DISCLOSURE_BY_LAW"]/value'
							, IR_MAINTAINED_BY_AGENCY	VARCHAR2(3)	PATH './item[id="IR_MAINTAINED_BY_AGENCY"]/value'
							, IR_COLLECTIVE_BARGAINING_UNIT	VARCHAR2(3)	PATH './item[id="IR_COLLECTIVE_BARGAINING_UNIT"]/value'
							, IR_APPROVE	VARCHAR2(3)	PATH './item[id="IR_APPROVE"]/value'
							, IR_PROVIDE_DT	VARCHAR2(10)	PATH './item[id="IR_PROVIDE_DT"]/value'
							, IR_DENIAL_NOTICE_DT_LIST	VARCHAR2(4000)	PATH './item[id="IR_PROVIDE_DT_LIST"]/value'
							, IR_APPEAL_DENIAL	VARCHAR2(3)	PATH './item[id="IR_APPEAL_DENIAL"]/value'
							
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
                TRG.IR_REQUESTER = SRC.IR_REQUESTER
				, TRG.IR_CMS_REQUESTER_NAME = SRC.IR_CMS_REQUESTER_NAME
				, TRG.IR_CMS_REQUESTER_PHONE = SRC.IR_CMS_REQUESTER_PHONE
				, TRG.IR_NCMS_REQUESTER_LAST_NAME = SRC.IR_NCMS_REQUESTER_LAST_NAME
				, TRG.IR_NCMS_REQUESTER_FIRST_NAME = SRC.IR_NCMS_REQUESTER_FIRST_NAME				
				, TRG.IR_NCMS_REQUESTER_MN = SRC.IR_NCMS_REQUESTER_MN
				, TRG.IR_NON_CMS_REQUESTER_PHONE = SRC.IR_NON_CMS_REQUESTER_PHONE
				, TRG.IR_NON_CMS_REQUESTER_EMAIL = 	SRC.IR_NON_CMS_REQUESTER_EMAIL
				, TRG.IR_NCMS_REQUESTER_ORG_AFFIL = SRC.IR_NCMS_REQUESTER_ORG_AFFIL
				, TRG.IR_SUBMIT_DT = SRC.IR_SUBMIT_DT
				, TRG.IR_MEET_PTCLRIZED_NEED_STND = SRC.IR_MEET_PTCLRIZED_NEED_STND
				, TRG.IR_RSNABLY_AVAIL_N_NECESSARY = SRC.IR_RSNABLY_AVAIL_N_NECESSARY
				, TRG.IR_PRTCT_DISCLOSURE_BY_LAW = SRC.IR_PRTCT_DISCLOSURE_BY_LAW
				, TRG.IR_MAINTAINED_BY_AGENCY = SRC.IR_MAINTAINED_BY_AGENCY
				, TRG.IR_COLLECTIVE_BARGAINING_UNIT = SRC.IR_COLLECTIVE_BARGAINING_UNIT
				, TRG.IR_APPROVE = SRC.IR_APPROVE
				, TRG.IR_PROVIDE_DT = SRC.IR_PROVIDE_DT
				, TRG.IR_DENIAL_NOTICE_DT_LIST = SRC.IR_DENIAL_NOTICE_DT_LIST
				, TRG.IR_APPEAL_DENIAL = SRC.IR_APPEAL_DENIAL
				
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.IR_REQUESTER	
				, TRG.IR_CMS_REQUESTER_NAME	
				, TRG.IR_CMS_REQUESTER_PHONE	
				, TRG.IR_NCMS_REQUESTER_LAST_NAME	
				, TRG.IR_NCMS_REQUESTER_FIRST_NAME
				, TRG.IR_NCMS_REQUESTER_MN	
				, TRG.IR_NON_CMS_REQUESTER_PHONE	
				, TRG.IR_NON_CMS_REQUESTER_EMAIL	
				, TRG.IR_NCMS_REQUESTER_ORG_AFFIL	
				, TRG.IR_SUBMIT_DT
				, TRG.IR_MEET_PTCLRIZED_NEED_STND
				, TRG.IR_RSNABLY_AVAIL_N_NECESSARY
				, TRG.IR_PRTCT_DISCLOSURE_BY_LAW
				, TRG.IR_MAINTAINED_BY_AGENCY
				, TRG.IR_COLLECTIVE_BARGAINING_UNIT
				, TRG.IR_APPROVE
				, TRG.IR_PROVIDE_DT
				, TRG.IR_DENIAL_NOTICE_DT_LIST
				, TRG.IR_APPEAL_DENIAL
              
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.IR_REQUESTER	
				, SRC.IR_CMS_REQUESTER_NAME	
				, SRC.IR_CMS_REQUESTER_PHONE	
				, SRC.IR_NCMS_REQUESTER_LAST_NAME	
				, SRC.IR_NCMS_REQUESTER_FIRST_NAME
				, SRC.IR_NCMS_REQUESTER_MN	
				, SRC.IR_NON_CMS_REQUESTER_PHONE	
				, SRC.IR_NON_CMS_REQUESTER_EMAIL	
				, SRC.IR_NCMS_REQUESTER_ORG_AFFIL	
				, SRC.IR_SUBMIT_DT
				, SRC.IR_MEET_PTCLRIZED_NEED_STND
				, SRC.IR_RSNABLY_AVAIL_N_NECESSARY
				, SRC.IR_PRTCT_DISCLOSURE_BY_LAW
				, SRC.IR_MAINTAINED_BY_AGENCY
				, SRC.IR_COLLECTIVE_BARGAINING_UNIT
				, SRC.IR_APPROVE
				, SRC.IR_PROVIDE_DT
				, SRC.IR_DENIAL_NOTICE_DT_LIST
				, SRC.IR_APPEAL_DENIAL
              
            );

		END;

		--------------------------------
		-- ERLR_3RDPARTY_HEAR table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_3RDPARTY_HEAR TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, THRD_PRTY_APPEAL_TYPE
					, TO_DATE(X.THRD_PRTY_APPEAL_FILE_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_APPEAL_FILE_DT
					, TO_DATE(X.THRD_PRTY_ASSISTANCE_REQ_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_ASSISTANCE_REQ_DT	
					, THRD_PRTY_HEARING_TIMING
					, THRD_PRTY_HEARING_REQUESTED
					, TO_DATE(X.THRD_PRTY_STEP_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_STEP_DECISION_DT	
					, THRD_PRTY_ARBITRATION_INVOKED
					, THRD_PRTY_ARBIT_LNM_3
					, THRD_PRTY_ARBIT_FNM_3
					, THRD_PRTY_ARBIT_MNM_3
					, THRD_PRTY_ARBIT_EMAIL_3
					, THRD_ERLR_ARBIT_PHONE_NUM_3
					, THRD_PRTY_ARBIT_ORG_AFFIL_3
					, THRD_PRTY_ARBIT_MAILING_ADDR_3
					, TO_DATE(X.THRD_PRTY_PREHEARING_DT_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_PREHEARING_DT_2	
					, TO_DATE(X.THRD_PRTY_HEARING_DT_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_HEARING_DT_2	
					, TO_DATE(X.THRD_PRTY_POSTHEAR_BRIEF_DUE_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_POSTHEAR_BRIEF_DUE_2	
					, TO_DATE(X.THRD_PRTY_FNL_ARBIT_DCSN_DT_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_FNL_ARBIT_DCSN_DT_2	
					, THRD_PRTY_EXCEPTION_FILED_2
					, TO_DATE(X.THRD_PRTY_EXCEPTION_FILE_DT_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_EXCEPTION_FILE_DT_2	
					, TO_DATE(X.THRD_PRTY_RSPS_TO_EXCPT_DUE_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_RSPS_TO_EXCPT_DUE_2	
					, TO_DATE(X.THRD_PRTY_FNL_FLRA_DCSN_DT_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_FNL_FLRA_DCSN_DT_2	
					, THRD_PRTY_ARBIT_LNM
					, THRD_PRTY_ARBIT_FNM
					, THRD_PRTY_ARBIT_MNM
					, THRD_PRTY_ARBIT_EMAIL
					, THRD_ERLR_ARBIT_PHONE_NUM
					, THRD_PRTY_ARBIT_ORG_AFFIL
					, THRD_PRTY_ARBIT_MAILING_ADDR
					, TO_DATE(X.THRD_PRTY_PREHEARING_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_PREHEARING_DT	
					, TO_DATE(X.THRD_PRTY_HEARING_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_HEARING_DT	
					, TO_DATE(X.THRD_PRTY_POSTHEAR_BRIEF_DUE,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_POSTHEAR_BRIEF_DUE	
					, TO_DATE(X.THRD_PRTY_FNL_ARBIT_DCSN_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_FNL_ARBIT_DCSN_DT	
					, THRD_PRTY_EXCEPTION_FILED
					, TO_DATE(X.THRD_PRTY_EXCEPTION_FILE_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_EXCEPTION_FILE_DT	
					, TO_DATE(X.THRD_PRTY_RSPS_TO_EXCPT_DUE,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_RSPS_TO_EXCPT_DUE	
					, TO_DATE(X.THRD_PRTY_FNL_FLRA_DCSN_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_FNL_FLRA_DCSN_DT	
					, THRD_PRTY_ARBIT_LNM_4
					, THRD_PRTY_ARBIT_FNM_4
					, THRD_PRTY_ARBIT_MNM_4
					, THRD_PRTY_ARBIT_EMAIL_4
					, THRD_ERLR_ARBIT_PHONE_NUM_4
					, THRD_PRTY_ARBIT_ORG_AFFIL_4
					, THRD_PRTY_ARBIT_MAILING_ADDR_4
					, TO_DATE(X.THRD_PRTY_DT_STLMNT_DSCUSN,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_DT_STLMNT_DSCUSN	
					, TO_DATE(X.THRD_PRTY_DT_PREHEAR_DSCLS,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_DT_PREHEAR_DSCLS	
					, TO_DATE(X.THRD_PRTY_DT_AGNCY_RSP_DUE,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_DT_AGNCY_RSP_DUE	
					, TO_DATE(X.THRD_PRTY_PREHEARING_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_PREHEARING_DT_MSPB	
					, THRD_PRTY_WAS_DSCVRY_INIT
					, TO_DATE(X.THRD_PRTY_DT_DISCOVERY_DUE,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_DT_DISCOVERY_DUE	
					, TO_DATE(X.THRD_PRTY_HEARING_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_HEARING_DT_MSPB	
					, TO_DATE(X.THRD_PRTY_INIT_DCSN_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_INIT_DCSN_DT_MSPB	
					, THRD_PRTY_WAS_PETI_FILED_MSPB
					, TO_DATE(X.THRD_PRTY_PETITION_RV_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_PETITION_RV_DT	
					, TO_DATE(X.THRD_PRTY_FNL_BRD_DCSN_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_FNL_BRD_DCSN_DT_MSPB	
					, TO_DATE(X.THRD_PRTY_DT_STLMNT_DSCUSN_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_DT_STLMNT_DSCUSN_2	
					, TO_DATE(X.THRD_PRTY_DT_PREHEAR_DSCLS_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_DT_PREHEAR_DSCLS_2	
					, TO_DATE(X.THRD_PRTY_PREHEARING_CONF,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_PREHEARING_CONF	
					, TO_DATE(X.THRD_PRTY_HEARING_DT_FLRA,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_HEARING_DT_FLRA	
					, TO_DATE(X.THRD_PRTY_DECISION_DT_FLRA,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_DECISION_DT_FLRA	
					, THRD_PRTY_TIMELY_REQ
					, THRD_PRTY_PROC_ORDER
					, THRD_PRTY_PANEL_MEMBER_LNAME
					, THRD_PRTY_PANEL_MEMBER_FNAME
					, THRD_PRTY_PANEL_MEMBER_MNAME
					, THRD_PRTY_PANEL_MEMBER_EMAIL
					, THRD_PRTY_PANEL_MEMBER_PHONE
					, THRD_PRTY_PANEL_MEMBER_ORG
					, THRD_PRTY_PANEL_MEMBER_MAILING
					, THRD_PRTY_PANEL_DESCR
                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS
                            THRD_PRTY_APPEAL_TYPE	NVARCHAR2(200)	PATH './item[id="THRD_PRTY_APPEAL_TYPE"]/value'
							, THRD_PRTY_APPEAL_FILE_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_APPEAL_FILE_DT"]/value'
							, THRD_PRTY_ASSISTANCE_REQ_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_ASSISTANCE_REQ_DT"]/value'
							, THRD_PRTY_HEARING_TIMING	VARCHAR2(3)	PATH './item[id="THRD_PRTY_HEARING_TIMING"]/value'
							, THRD_PRTY_HEARING_REQUESTED	VARCHAR2(3)	PATH './item[id="THRD_PRTY_HEARING_REQUESTED"]/value'
							, THRD_PRTY_STEP_DECISION_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_STEP_DECISION_DT"]/value'
							, THRD_PRTY_ARBITRATION_INVOKED	VARCHAR2(3)	PATH './item[id="THRD_PRTY_ARBITRATION_INVOKED"]/value'
							, THRD_PRTY_ARBIT_LNM_3	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_LAST_NAME_3"]/value'
							, THRD_PRTY_ARBIT_FNM_3	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_FIRST_NAME_3"]/value'
							, THRD_PRTY_ARBIT_MNM_3	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_MIDDLE_NAME_3"]/value'
							, THRD_PRTY_ARBIT_EMAIL_3	NVARCHAR2(100)	PATH './item[id="THRD_PRTY_ARBITRATOR_EMAIL_3"]/value'
							, THRD_ERLR_ARBIT_PHONE_NUM_3	NVARCHAR2(50)	PATH './item[id="THRD_ERLR_ARBITRATOR_PHONE_NUMBER_3"]/value'
							, THRD_PRTY_ARBIT_ORG_AFFIL_3	NVARCHAR2(100)	PATH './item[id="THRD_PRTY_ARBITRATION_ORGANIZATION_AFFILIATION_3"]/value'
							, THRD_PRTY_ARBIT_MAILING_ADDR_3	NVARCHAR2(250)	PATH './item[id="THRD_PRTY_ARBITRATION_MAILING_ADDR_3"]/value'
							, THRD_PRTY_PREHEARING_DT_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_PREHEARING_DT_2"]/value'
							, THRD_PRTY_HEARING_DT_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_HEARING_DT_2"]/value'
							, THRD_PRTY_POSTHEAR_BRIEF_DUE_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_POSTHEARING_BRIEF_DUE_2"]/value'
							, THRD_PRTY_FNL_ARBIT_DCSN_DT_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_FINAL_ARBITRATOR_DECISION_DT_2"]/value'
							, THRD_PRTY_EXCEPTION_FILED_2	VARCHAR2(3)	PATH './item[id="THRD_PRTY_EXCEPTION_FILED_2"]/value'
							, THRD_PRTY_EXCEPTION_FILE_DT_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_EXCEPTION_FILE_DT_2"]/value'
							, THRD_PRTY_RSPS_TO_EXCPT_DUE_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_RESPONSE_TO_EXCEPTIONS_DUE_2"]/value'
							, THRD_PRTY_FNL_FLRA_DCSN_DT_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_FINAL_FLRA_DECISION_DT_2"]/value'
							, THRD_PRTY_ARBIT_LNM	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_LAST_NAME"]/value'
							, THRD_PRTY_ARBIT_FNM	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_FIRST_NAME"]/value'
							, THRD_PRTY_ARBIT_MNM	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_MIDDLE_NAME"]/value'
							, THRD_PRTY_ARBIT_EMAIL	NVARCHAR2(100)	PATH './item[id="THRD_PRTY_ARBITRATOR_EMAIL"]/value'
							, THRD_ERLR_ARBIT_PHONE_NUM	NVARCHAR2(50)	PATH './item[id="THRD_ERLR_ARBITRATOR_PHONE_NUMBER"]/value'
							, THRD_PRTY_ARBIT_ORG_AFFIL	NVARCHAR2(100)	PATH './item[id="THRD_PRTY_ARBITRATION_ORGANIZATION_AFFILIATION"]/value'
							, THRD_PRTY_ARBIT_MAILING_ADDR	NVARCHAR2(250)	PATH './item[id="THRD_PRTY_ARBITRATION_MAILING_ADDR"]/value'
							, THRD_PRTY_PREHEARING_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_PREHEARING_DT"]/value'
							, THRD_PRTY_HEARING_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_HEARING_DT"]/value'
							, THRD_PRTY_POSTHEAR_BRIEF_DUE	VARCHAR2(10)	PATH './item[id="THRD_PRTY_POSTHEARING_BRIEF_DUE"]/value'
							, THRD_PRTY_FNL_ARBIT_DCSN_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_FINAL_ARBITRATOR_DECISION_DT"]/value'
							, THRD_PRTY_EXCEPTION_FILED	VARCHAR2(3)	PATH './item[id="THRD_PRTY_EXCEPTION_FILED"]/value'
							, THRD_PRTY_EXCEPTION_FILE_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_EXCEPTION_FILE_DT"]/value'
							, THRD_PRTY_RSPS_TO_EXCPT_DUE	VARCHAR2(10)	PATH './item[id="THRD_PRTY_RESPONSE_TO_EXCEPTIONS_DUE"]/value'
							, THRD_PRTY_FNL_FLRA_DCSN_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_FINAL_FLRA_DECISION_DT"]/value'
							, THRD_PRTY_ARBIT_LNM_4	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_LAST_NAME_4"]/value'
							, THRD_PRTY_ARBIT_FNM_4	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_FIRST_NAME_4"]/value'
							, THRD_PRTY_ARBIT_MNM_4	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_MIDDLE_NAME_4"]/value'
							, THRD_PRTY_ARBIT_EMAIL_4	NVARCHAR2(100)	PATH './item[id="THRD_PRTY_ARBITRATOR_EMAIL_4"]/value'
							, THRD_ERLR_ARBIT_PHONE_NUM_4	NVARCHAR2(50)	PATH './item[id="THRD_ERLR_ARBITRATOR_PHONE_NUMBER_4"]/value'
							, THRD_PRTY_ARBIT_ORG_AFFIL_4	NVARCHAR2(100)	PATH './item[id="THRD_PRTY_ARBITRATION_ORGANIZATION_AFFILIATION_4"]/value'
							, THRD_PRTY_ARBIT_MAILING_ADDR_4	NVARCHAR2(250)	PATH './item[id="THRD_PRTY_ARBITRATION_MAILING_ADDR_4"]/value'
							, THRD_PRTY_DT_STLMNT_DSCUSN	VARCHAR2(10)	PATH './item[id="THRD_PRTY_DT_SETTLEMENT_DISCUSSION"]/value'
							, THRD_PRTY_DT_PREHEAR_DSCLS	VARCHAR2(10)	PATH './item[id="THRD_PRTY_DT_PREHEARING_DISCLOSURE"]/value'
							, THRD_PRTY_DT_AGNCY_RSP_DUE	VARCHAR2(10)	PATH './item[id="THRD_PRTY_DT_AGENCY_FILE_RESPONSE_DUE"]/value'
							, THRD_PRTY_PREHEARING_DT_MSPB	VARCHAR2(10)	PATH './item[id="THRD_PRTY_PREHEARING_DT_MSPB"]/value'
							, THRD_PRTY_WAS_DSCVRY_INIT	VARCHAR2(3)	PATH './item[id="THRD_PRTY_WAS_DISCOVERY_INITIATED"]/value'
							, THRD_PRTY_DT_DISCOVERY_DUE	VARCHAR2(10)	PATH './item[id="THRD_PRTY_DT_DISCOVERY_DUE"]/value'
							, THRD_PRTY_HEARING_DT_MSPB	VARCHAR2(10)	PATH './item[id="THRD_PRTY_HEARING_DT_MSPB"]/value'
							, THRD_PRTY_INIT_DCSN_DT_MSPB	VARCHAR2(10)	PATH './item[id="THRD_PRTY_INITIAL_DECISION_DT_MSPB"]/value'
							, THRD_PRTY_WAS_PETI_FILED_MSPB	VARCHAR2(3)	PATH './item[id="THRD_PRTY_WAS_PETITION_FILED_MSPB"]/value'
							, THRD_PRTY_PETITION_RV_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_PETITION_RV_DT"]/value'
							, THRD_PRTY_FNL_BRD_DCSN_DT_MSPB	VARCHAR2(10)	PATH './item[id="THRD_PRTY_FINAL_BOARD_DECISION_DT_MSPB"]/value'
							, THRD_PRTY_DT_STLMNT_DSCUSN_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_DT_SETTLEMENT_DISCUSSION_2"]/value'
							, THRD_PRTY_DT_PREHEAR_DSCLS_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_DT_PREHEARING_DISCLOSURE_2"]/value'
							, THRD_PRTY_PREHEARING_CONF	VARCHAR2(10)	PATH './item[id="THRD_PRTY_PREHEARING_CONF"]/value'
							, THRD_PRTY_HEARING_DT_FLRA	VARCHAR2(10)	PATH './item[id="THRD_PRTY_HEARING_DT_FLRA"]/value'
							, THRD_PRTY_DECISION_DT_FLRA	VARCHAR2(10)	PATH './item[id="THRD_PRTY_DECISION_DT_FLRA"]/value'
							, THRD_PRTY_TIMELY_REQ	VARCHAR2(3)	PATH './item[id="THRD_PRTY_TIMELY_REQ"]/value'
							, THRD_PRTY_PROC_ORDER	NVARCHAR2(2000)	PATH './item[id="THRD_PRTY_PROC_ORDER"]/value'
							, THRD_PRTY_PANEL_MEMBER_LNAME	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_PANEL_MEMBER_LNAME"]/value'
							, THRD_PRTY_PANEL_MEMBER_FNAME	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_PANEL_MEMBER_FNAME"]/value'
							, THRD_PRTY_PANEL_MEMBER_MNAME	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_PANEL_MEMBER_MNAME"]/value'
							, THRD_PRTY_PANEL_MEMBER_EMAIL	NVARCHAR2(100)	PATH './item[id="THRD_PRTY_PANEL_MEMBER_EMAIL"]/value'
							, THRD_PRTY_PANEL_MEMBER_PHONE	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_PANEL_MEMBER_PHONE"]/value'
							, THRD_PRTY_PANEL_MEMBER_ORG	NVARCHAR2(100)	PATH './item[id="THRD_PRTY_PANEL_MEMBER_ORG"]/value'
							, THRD_PRTY_PANEL_MEMBER_MAILING	NVARCHAR2(250)	PATH './item[id="THRD_PRTY_PANEL_MEMBER_MAILING"]/value'
							, THRD_PRTY_PANEL_DESCR	NVARCHAR2(500)	PATH './item[id="THRD_PRTY_PANEL_DESCR"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET                
				TRG.THRD_PRTY_APPEAL_TYPE = SRC.THRD_PRTY_APPEAL_TYPE
				, TRG.THRD_PRTY_APPEAL_FILE_DT = SRC.THRD_PRTY_APPEAL_FILE_DT
				, TRG.THRD_PRTY_ASSISTANCE_REQ_DT = SRC.THRD_PRTY_ASSISTANCE_REQ_DT
				, TRG.THRD_PRTY_HEARING_TIMING = SRC.THRD_PRTY_HEARING_TIMING
				, TRG.THRD_PRTY_HEARING_REQUESTED = SRC.THRD_PRTY_HEARING_REQUESTED
				, TRG.THRD_PRTY_STEP_DECISION_DT = SRC.THRD_PRTY_STEP_DECISION_DT
				, TRG.THRD_PRTY_ARBITRATION_INVOKED = SRC.THRD_PRTY_ARBITRATION_INVOKED
				, TRG.THRD_PRTY_ARBIT_LNM_3 = SRC.THRD_PRTY_ARBIT_LNM_3
				, TRG.THRD_PRTY_ARBIT_FNM_3 = SRC.THRD_PRTY_ARBIT_FNM_3
				, TRG.THRD_PRTY_ARBIT_MNM_3 = SRC.THRD_PRTY_ARBIT_MNM_3
				, TRG.THRD_PRTY_ARBIT_EMAIL_3 = SRC.THRD_PRTY_ARBIT_EMAIL_3
				, TRG.THRD_ERLR_ARBIT_PHONE_NUM_3 = SRC.THRD_ERLR_ARBIT_PHONE_NUM_3
				, TRG.THRD_PRTY_ARBIT_ORG_AFFIL_3 = SRC.THRD_PRTY_ARBIT_ORG_AFFIL_3
				, TRG.THRD_PRTY_ARBIT_MAILING_ADDR_3 = SRC.THRD_PRTY_ARBIT_MAILING_ADDR_3
				, TRG.THRD_PRTY_PREHEARING_DT_2 = SRC.THRD_PRTY_PREHEARING_DT_2
				, TRG.THRD_PRTY_HEARING_DT_2 = SRC.THRD_PRTY_HEARING_DT_2
				, TRG.THRD_PRTY_POSTHEAR_BRIEF_DUE_2 = SRC.THRD_PRTY_POSTHEAR_BRIEF_DUE_2
				, TRG.THRD_PRTY_FNL_ARBIT_DCSN_DT_2 = SRC.THRD_PRTY_FNL_ARBIT_DCSN_DT_2
				, TRG.THRD_PRTY_EXCEPTION_FILED_2 = SRC.THRD_PRTY_EXCEPTION_FILED_2
				, TRG.THRD_PRTY_EXCEPTION_FILE_DT_2 = SRC.THRD_PRTY_EXCEPTION_FILE_DT_2
				, TRG.THRD_PRTY_RSPS_TO_EXCPT_DUE_2 = SRC.THRD_PRTY_RSPS_TO_EXCPT_DUE_2
				, TRG.THRD_PRTY_FNL_FLRA_DCSN_DT_2 = SRC.THRD_PRTY_FNL_FLRA_DCSN_DT_2
				, TRG.THRD_PRTY_ARBIT_LNM = SRC.THRD_PRTY_ARBIT_LNM
				, TRG.THRD_PRTY_ARBIT_FNM = SRC.THRD_PRTY_ARBIT_FNM
				, TRG.THRD_PRTY_ARBIT_MNM = SRC.THRD_PRTY_ARBIT_MNM
				, TRG.THRD_PRTY_ARBIT_EMAIL = SRC.THRD_PRTY_ARBIT_EMAIL
				, TRG.THRD_ERLR_ARBIT_PHONE_NUM = SRC.THRD_ERLR_ARBIT_PHONE_NUM
				, TRG.THRD_PRTY_ARBIT_ORG_AFFIL = SRC.THRD_PRTY_ARBIT_ORG_AFFIL
				, TRG.THRD_PRTY_ARBIT_MAILING_ADDR = SRC.THRD_PRTY_ARBIT_MAILING_ADDR
				, TRG.THRD_PRTY_PREHEARING_DT = SRC.THRD_PRTY_PREHEARING_DT
				, TRG.THRD_PRTY_HEARING_DT = SRC.THRD_PRTY_HEARING_DT
				, TRG.THRD_PRTY_POSTHEAR_BRIEF_DUE = SRC.THRD_PRTY_POSTHEAR_BRIEF_DUE
				, TRG.THRD_PRTY_FNL_ARBIT_DCSN_DT = SRC.THRD_PRTY_FNL_ARBIT_DCSN_DT
				, TRG.THRD_PRTY_EXCEPTION_FILED = SRC.THRD_PRTY_EXCEPTION_FILED
				, TRG.THRD_PRTY_EXCEPTION_FILE_DT = SRC.THRD_PRTY_EXCEPTION_FILE_DT
				, TRG.THRD_PRTY_RSPS_TO_EXCPT_DUE = SRC.THRD_PRTY_RSPS_TO_EXCPT_DUE
				, TRG.THRD_PRTY_FNL_FLRA_DCSN_DT = SRC.THRD_PRTY_FNL_FLRA_DCSN_DT
				, TRG.THRD_PRTY_ARBIT_LNM_4 = SRC.THRD_PRTY_ARBIT_LNM_4
				, TRG.THRD_PRTY_ARBIT_FNM_4 = SRC.THRD_PRTY_ARBIT_FNM_4
				, TRG.THRD_PRTY_ARBIT_MNM_4 = SRC.THRD_PRTY_ARBIT_MNM_4
				, TRG.THRD_PRTY_ARBIT_EMAIL_4 = SRC.THRD_PRTY_ARBIT_EMAIL_4
				, TRG.THRD_ERLR_ARBIT_PHONE_NUM_4 = SRC.THRD_ERLR_ARBIT_PHONE_NUM_4
				, TRG.THRD_PRTY_ARBIT_ORG_AFFIL_4 = SRC.THRD_PRTY_ARBIT_ORG_AFFIL_4
				, TRG.THRD_PRTY_ARBIT_MAILING_ADDR_4 = SRC.THRD_PRTY_ARBIT_MAILING_ADDR_4
				, TRG.THRD_PRTY_DT_STLMNT_DSCUSN = SRC.THRD_PRTY_DT_STLMNT_DSCUSN
				, TRG.THRD_PRTY_DT_PREHEAR_DSCLS = SRC.THRD_PRTY_DT_PREHEAR_DSCLS
				, TRG.THRD_PRTY_DT_AGNCY_RSP_DUE = SRC.THRD_PRTY_DT_AGNCY_RSP_DUE
				, TRG.THRD_PRTY_PREHEARING_DT_MSPB = SRC.THRD_PRTY_PREHEARING_DT_MSPB
				, TRG.THRD_PRTY_WAS_DSCVRY_INIT = SRC.THRD_PRTY_WAS_DSCVRY_INIT
				, TRG.THRD_PRTY_DT_DISCOVERY_DUE = SRC.THRD_PRTY_DT_DISCOVERY_DUE
				, TRG.THRD_PRTY_HEARING_DT_MSPB = SRC.THRD_PRTY_HEARING_DT_MSPB
				, TRG.THRD_PRTY_INIT_DCSN_DT_MSPB = SRC.THRD_PRTY_INIT_DCSN_DT_MSPB
				, TRG.THRD_PRTY_WAS_PETI_FILED_MSPB = SRC.THRD_PRTY_WAS_PETI_FILED_MSPB
				, TRG.THRD_PRTY_PETITION_RV_DT = SRC.THRD_PRTY_PETITION_RV_DT
				, TRG.THRD_PRTY_FNL_BRD_DCSN_DT_MSPB = SRC.THRD_PRTY_FNL_BRD_DCSN_DT_MSPB
				, TRG.THRD_PRTY_DT_STLMNT_DSCUSN_2 = SRC.THRD_PRTY_DT_STLMNT_DSCUSN_2
				, TRG.THRD_PRTY_DT_PREHEAR_DSCLS_2 = SRC.THRD_PRTY_DT_PREHEAR_DSCLS_2
				, TRG.THRD_PRTY_PREHEARING_CONF = SRC.THRD_PRTY_PREHEARING_CONF
				, TRG.THRD_PRTY_HEARING_DT_FLRA = SRC.THRD_PRTY_HEARING_DT_FLRA
				, TRG.THRD_PRTY_DECISION_DT_FLRA = SRC.THRD_PRTY_DECISION_DT_FLRA
				, TRG.THRD_PRTY_TIMELY_REQ = SRC.THRD_PRTY_TIMELY_REQ
				, TRG.THRD_PRTY_PROC_ORDER = SRC.THRD_PRTY_PROC_ORDER
				, TRG.THRD_PRTY_PANEL_MEMBER_LNAME = SRC.THRD_PRTY_PANEL_MEMBER_LNAME
				, TRG.THRD_PRTY_PANEL_MEMBER_FNAME = SRC.THRD_PRTY_PANEL_MEMBER_FNAME
				, TRG.THRD_PRTY_PANEL_MEMBER_MNAME = SRC.THRD_PRTY_PANEL_MEMBER_MNAME
				, TRG.THRD_PRTY_PANEL_MEMBER_EMAIL = SRC.THRD_PRTY_PANEL_MEMBER_EMAIL
				, TRG.THRD_PRTY_PANEL_MEMBER_PHONE = SRC.THRD_PRTY_PANEL_MEMBER_PHONE
				, TRG.THRD_PRTY_PANEL_MEMBER_ORG = SRC.THRD_PRTY_PANEL_MEMBER_ORG
				, TRG.THRD_PRTY_PANEL_MEMBER_MAILING = SRC.THRD_PRTY_PANEL_MEMBER_MAILING
				, TRG.THRD_PRTY_PANEL_DESCR = SRC.THRD_PRTY_PANEL_DESCR
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.THRD_PRTY_APPEAL_TYPE
				, TRG.THRD_PRTY_APPEAL_FILE_DT
				, TRG.THRD_PRTY_ASSISTANCE_REQ_DT
				, TRG.THRD_PRTY_HEARING_TIMING
				, TRG.THRD_PRTY_HEARING_REQUESTED
				, TRG.THRD_PRTY_STEP_DECISION_DT
				, TRG.THRD_PRTY_ARBITRATION_INVOKED
				, TRG.THRD_PRTY_ARBIT_LNM_3
				, TRG.THRD_PRTY_ARBIT_FNM_3
				, TRG.THRD_PRTY_ARBIT_MNM_3
				, TRG.THRD_PRTY_ARBIT_EMAIL_3
				, TRG.THRD_ERLR_ARBIT_PHONE_NUM_3
				, TRG.THRD_PRTY_ARBIT_ORG_AFFIL_3
				, TRG.THRD_PRTY_ARBIT_MAILING_ADDR_3
				, TRG.THRD_PRTY_PREHEARING_DT_2
				, TRG.THRD_PRTY_HEARING_DT_2
				, TRG.THRD_PRTY_POSTHEAR_BRIEF_DUE_2
				, TRG.THRD_PRTY_FNL_ARBIT_DCSN_DT_2
				, TRG.THRD_PRTY_EXCEPTION_FILED_2
				, TRG.THRD_PRTY_EXCEPTION_FILE_DT_2
				, TRG.THRD_PRTY_RSPS_TO_EXCPT_DUE_2
				, TRG.THRD_PRTY_FNL_FLRA_DCSN_DT_2
				, TRG.THRD_PRTY_ARBIT_LNM
				, TRG.THRD_PRTY_ARBIT_FNM
				, TRG.THRD_PRTY_ARBIT_MNM
				, TRG.THRD_PRTY_ARBIT_EMAIL
				, TRG.THRD_ERLR_ARBIT_PHONE_NUM
				, TRG.THRD_PRTY_ARBIT_ORG_AFFIL
				, TRG.THRD_PRTY_ARBIT_MAILING_ADDR
				, TRG.THRD_PRTY_PREHEARING_DT
				, TRG.THRD_PRTY_HEARING_DT
				, TRG.THRD_PRTY_POSTHEAR_BRIEF_DUE
				, TRG.THRD_PRTY_FNL_ARBIT_DCSN_DT
				, TRG.THRD_PRTY_EXCEPTION_FILED
				, TRG.THRD_PRTY_EXCEPTION_FILE_DT
				, TRG.THRD_PRTY_RSPS_TO_EXCPT_DUE
				, TRG.THRD_PRTY_FNL_FLRA_DCSN_DT
				, TRG.THRD_PRTY_ARBIT_LNM_4
				, TRG.THRD_PRTY_ARBIT_FNM_4
				, TRG.THRD_PRTY_ARBIT_MNM_4
				, TRG.THRD_PRTY_ARBIT_EMAIL_4
				, TRG.THRD_ERLR_ARBIT_PHONE_NUM_4
				, TRG.THRD_PRTY_ARBIT_ORG_AFFIL_4
				, TRG.THRD_PRTY_ARBIT_MAILING_ADDR_4
				, TRG.THRD_PRTY_DT_STLMNT_DSCUSN
				, TRG.THRD_PRTY_DT_PREHEAR_DSCLS
				, TRG.THRD_PRTY_DT_AGNCY_RSP_DUE
				, TRG.THRD_PRTY_PREHEARING_DT_MSPB
				, TRG.THRD_PRTY_WAS_DSCVRY_INIT
				, TRG.THRD_PRTY_DT_DISCOVERY_DUE
				, TRG.THRD_PRTY_HEARING_DT_MSPB
				, TRG.THRD_PRTY_INIT_DCSN_DT_MSPB
				, TRG.THRD_PRTY_WAS_PETI_FILED_MSPB
				, TRG.THRD_PRTY_PETITION_RV_DT
				, TRG.THRD_PRTY_FNL_BRD_DCSN_DT_MSPB
				, TRG.THRD_PRTY_DT_STLMNT_DSCUSN_2
				, TRG.THRD_PRTY_DT_PREHEAR_DSCLS_2
				, TRG.THRD_PRTY_PREHEARING_CONF
				, TRG.THRD_PRTY_HEARING_DT_FLRA
				, TRG.THRD_PRTY_DECISION_DT_FLRA
				, TRG.THRD_PRTY_TIMELY_REQ
				, TRG.THRD_PRTY_PROC_ORDER
				, TRG.THRD_PRTY_PANEL_MEMBER_LNAME
				, TRG.THRD_PRTY_PANEL_MEMBER_FNAME
				, TRG.THRD_PRTY_PANEL_MEMBER_MNAME
				, TRG.THRD_PRTY_PANEL_MEMBER_EMAIL
				, TRG.THRD_PRTY_PANEL_MEMBER_PHONE
				, TRG.THRD_PRTY_PANEL_MEMBER_ORG
				, TRG.THRD_PRTY_PANEL_MEMBER_MAILING
				, TRG.THRD_PRTY_PANEL_DESCR               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.THRD_PRTY_APPEAL_TYPE
				, SRC.THRD_PRTY_APPEAL_FILE_DT
				, SRC.THRD_PRTY_ASSISTANCE_REQ_DT
				, SRC.THRD_PRTY_HEARING_TIMING
				, SRC.THRD_PRTY_HEARING_REQUESTED
				, SRC.THRD_PRTY_STEP_DECISION_DT
				, SRC.THRD_PRTY_ARBITRATION_INVOKED
				, SRC.THRD_PRTY_ARBIT_LNM_3
				, SRC.THRD_PRTY_ARBIT_FNM_3
				, SRC.THRD_PRTY_ARBIT_MNM_3
				, SRC.THRD_PRTY_ARBIT_EMAIL_3
				, SRC.THRD_ERLR_ARBIT_PHONE_NUM_3
				, SRC.THRD_PRTY_ARBIT_ORG_AFFIL_3
				, SRC.THRD_PRTY_ARBIT_MAILING_ADDR_3
				, SRC.THRD_PRTY_PREHEARING_DT_2
				, SRC.THRD_PRTY_HEARING_DT_2
				, SRC.THRD_PRTY_POSTHEAR_BRIEF_DUE_2
				, SRC.THRD_PRTY_FNL_ARBIT_DCSN_DT_2
				, SRC.THRD_PRTY_EXCEPTION_FILED_2
				, SRC.THRD_PRTY_EXCEPTION_FILE_DT_2
				, SRC.THRD_PRTY_RSPS_TO_EXCPT_DUE_2
				, SRC.THRD_PRTY_FNL_FLRA_DCSN_DT_2
				, SRC.THRD_PRTY_ARBIT_LNM
				, SRC.THRD_PRTY_ARBIT_FNM
				, SRC.THRD_PRTY_ARBIT_MNM
				, SRC.THRD_PRTY_ARBIT_EMAIL
				, SRC.THRD_ERLR_ARBIT_PHONE_NUM
				, SRC.THRD_PRTY_ARBIT_ORG_AFFIL
				, SRC.THRD_PRTY_ARBIT_MAILING_ADDR
				, SRC.THRD_PRTY_PREHEARING_DT
				, SRC.THRD_PRTY_HEARING_DT
				, SRC.THRD_PRTY_POSTHEAR_BRIEF_DUE
				, SRC.THRD_PRTY_FNL_ARBIT_DCSN_DT
				, SRC.THRD_PRTY_EXCEPTION_FILED
				, SRC.THRD_PRTY_EXCEPTION_FILE_DT
				, SRC.THRD_PRTY_RSPS_TO_EXCPT_DUE
				, SRC.THRD_PRTY_FNL_FLRA_DCSN_DT
				, SRC.THRD_PRTY_ARBIT_LNM_4
				, SRC.THRD_PRTY_ARBIT_FNM_4
				, SRC.THRD_PRTY_ARBIT_MNM_4
				, SRC.THRD_PRTY_ARBIT_EMAIL_4
				, SRC.THRD_ERLR_ARBIT_PHONE_NUM_4
				, SRC.THRD_PRTY_ARBIT_ORG_AFFIL_4
				, SRC.THRD_PRTY_ARBIT_MAILING_ADDR_4
				, SRC.THRD_PRTY_DT_STLMNT_DSCUSN
				, SRC.THRD_PRTY_DT_PREHEAR_DSCLS
				, SRC.THRD_PRTY_DT_AGNCY_RSP_DUE
				, SRC.THRD_PRTY_PREHEARING_DT_MSPB
				, SRC.THRD_PRTY_WAS_DSCVRY_INIT
				, SRC.THRD_PRTY_DT_DISCOVERY_DUE
				, SRC.THRD_PRTY_HEARING_DT_MSPB
				, SRC.THRD_PRTY_INIT_DCSN_DT_MSPB
				, SRC.THRD_PRTY_WAS_PETI_FILED_MSPB
				, SRC.THRD_PRTY_PETITION_RV_DT
				, SRC.THRD_PRTY_FNL_BRD_DCSN_DT_MSPB
				, SRC.THRD_PRTY_DT_STLMNT_DSCUSN_2
				, SRC.THRD_PRTY_DT_PREHEAR_DSCLS_2
				, SRC.THRD_PRTY_PREHEARING_CONF
				, SRC.THRD_PRTY_HEARING_DT_FLRA
				, SRC.THRD_PRTY_DECISION_DT_FLRA
				, SRC.THRD_PRTY_TIMELY_REQ
				, SRC.THRD_PRTY_PROC_ORDER
				, SRC.THRD_PRTY_PANEL_MEMBER_LNAME
				, SRC.THRD_PRTY_PANEL_MEMBER_FNAME
				, SRC.THRD_PRTY_PANEL_MEMBER_MNAME
				, SRC.THRD_PRTY_PANEL_MEMBER_EMAIL
				, SRC.THRD_PRTY_PANEL_MEMBER_PHONE
				, SRC.THRD_PRTY_PANEL_MEMBER_ORG
				, SRC.THRD_PRTY_PANEL_MEMBER_MAILING
				, SRC.THRD_PRTY_PANEL_DESCR
               
            );

		END;

		--------------------------------
		-- ERLE_PROB_ACTION table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_PROB_ACTION TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, X.PPA_ACTION_TYPE
					, X.PPA_TERMINATION_TYPE
					, TO_DATE(X.PPA_TERM_PROP_ACTION_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_TERM_PROP_ACTION_DT	
					, X.PPA_TERM_ORAL_PREZ_REQUESTED
					, TO_DATE(X.PPA_TERM_ORAL_PREZ_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_TERM_ORAL_PREZ_DT	
					, X.PPA_TERM_WRITTEN_RESP
					, TO_DATE(X.PPA_TERM_WRITTEN_RESP_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_TERM_WRITTEN_RESP_DUE_DT	
					, TO_DATE(X.PPA_TERM_WRITTEN_RESP_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_TERM_WRITTEN_RESP_DT	
					, X.PPA_TERM_AGENCY_DECISION
					, X.PPA_TERM_DECIDING_OFFCL_NAME
					, TO_DATE(X.PPA_TERM_DECISION_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_TERM_DECISION_ISSUED_DT	
					, TO_DATE(X.PPA_TERM_EFFECTIVE_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_TERM_EFFECTIVE_DECISION_DT	
					, TO_DATE(X.PPA_PROB_TERM_DCSN_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_PROB_TERM_DCSN_ISSUED_DT	
					, X.PPA_PROBATION_CONDUCT
					, X.PPA_PROBATION_PERFORMANCE
					, TO_DATE(X.PPA_APPEAL_GRIEVANCE_DEADLINE,'MM/DD/YYYY HH24:MI:SS') AS PPA_APPEAL_GRIEVANCE_DEADLINE	
					, X.PPA_EMP_APPEAL_DECISION
					, TO_DATE(X.PPA_PROP_ACTION_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_PROP_ACTION_ISSUED_DT	
					, X.PPA_ORAL_PREZ_REQUESTED
					, TO_DATE(X.PPA_ORAL_PREZ_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_ORAL_PREZ_DT	
					, X.PPA_ORAL_RESPONSE_SUBMITTED
					, TO_DATE(X.PPA_RESPONSE_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_RESPONSE_DUE_DT	
					, TO_DATE(X.PPA_WRITTEN_RESPONSE_SBMT_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_WRITTEN_RESPONSE_SBMT_DT	
					, X.PPA_POS_TITLE
					, X.PPA_PPLAN
					, X.PPA_SERIES
					, X.PPA_CURRENT_INFO_GRADE
					, X.PPA_CURRENT_INFO_STEP
					, X.PPA_PROPOSED_POS_TITLE
					, X.PPA_PROPOSED_PPLAN
					, X.PPA_PROPOSED_SERIES
					, X.PPA_PROPOSED_INFO_GRADE
					, X.PPA_PROPOSED_INFO_STEP
					, X.PPA_FINAL_POS_TITLE
					, X.PPA_FINAL_PPLAN
					, X.PPA_FINAL_SERIES
					, X.PPA_FINAL_INFO_GRADE
					, X.PPA_FINAL_INFO_STEP
					, TO_DATE(X.PPA_NOTICE_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_NOTICE_ISSUED_DT	
					, X.PPA_DEMO_FINAL_AGENCY_DECISION
					, X.PPA_DECIDING_OFFCL
					, TO_DATE(X.PPA_DECISION_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_DECISION_ISSUED_DT	
					, TO_DATE(X.PPA_DEMO_FINAL_AGENCY_EFF_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_DEMO_FINAL_AGENCY_EFF_DT	
					, X.PPA_NUMB_DAYS
					, TO_DATE(X.PPA_EFFECTIVE_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_EFFECTIVE_DT	
					, X.PPA_CURRENT_ADMIN_CODE
					, X.PPA_RE_ASSIGNMENT_CURR_ORG
					, X.PPA_FINAL_ADMIN_CODE
					, X.PPA_FINAL_ADMIN_CODE_FINAL_ORG
                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS                            
							PPA_ACTION_TYPE	NVARCHAR2(200)	PATH './item[id="PPA_ACTION_TYPE"]/value'
							, PPA_TERMINATION_TYPE	NVARCHAR2(200)	PATH './item[id="PPA_TERMINATION_TYPE"]/value'
							, PPA_TERM_PROP_ACTION_DT	VARCHAR2(10)	PATH './item[id="PPA_TERM_PROP_ACTION_DT"]/value'
							, PPA_TERM_ORAL_PREZ_REQUESTED	VARCHAR2(3)	PATH './item[id="PPA_TERM_ORAL_PREZ_REQUESTED"]/value'
							, PPA_TERM_ORAL_PREZ_DT	VARCHAR2(10)	PATH './item[id="PPA_TERM_ORAL_PREZ_DT"]/value'
							, PPA_TERM_WRITTEN_RESP	VARCHAR2(3)	PATH './item[id="PPA_TERM_WRITTEN_RESP"]/value'
							, PPA_TERM_WRITTEN_RESP_DUE_DT	VARCHAR2(10)	PATH './item[id="PPA_TERM_WRITTEN_RESP_DUE_DT"]/value'
							, PPA_TERM_WRITTEN_RESP_DT	VARCHAR2(10)	PATH './item[id="PPA_TERM_WRITTEN_RESP_DT"]/value'
							, PPA_TERM_AGENCY_DECISION	NVARCHAR2(200)	PATH './item[id="PPA_TERM_AGENCY_DECISION"]/value'
							, PPA_TERM_DECIDING_OFFCL_NAME	NVARCHAR2(255)	PATH './item[id="PPA_TERM_DECIDING_OFFCL_NAME"]/value/name'
							, PPA_TERM_DECISION_ISSUED_DT	VARCHAR2(10)	PATH './item[id="PPA_TERM_DECISION_ISSUED_DT"]/value'
							, PPA_TERM_EFFECTIVE_DECISION_DT	VARCHAR2(10)	PATH './item[id="PPA_TERM_EFFECTIVE_DECISION_DT"]/value'
							, PPA_PROB_TERM_DCSN_ISSUED_DT	VARCHAR2(10)	PATH './item[id="PPA_PROBATION_TERMINATION_DECISION_ISSUED_DT"]/value'
							, PPA_PROBATION_CONDUCT	VARCHAR2(3)	PATH './item[id="PPA_PROBATION_CONDUCT"]/value'
							, PPA_PROBATION_PERFORMANCE	VARCHAR2(3)	PATH './item[id="PPA_PROBATION_PERFORMANCE"]/value'
							, PPA_APPEAL_GRIEVANCE_DEADLINE	VARCHAR2(10)	PATH './item[id="PPA_APPEAL_GRIEVANCE_DEADLINE"]/value'
							, PPA_EMP_APPEAL_DECISION	VARCHAR2(3)	PATH './item[id="PPA_EMP_APPEAL_DECISION"]/value'
							, PPA_PROP_ACTION_ISSUED_DT	VARCHAR2(10)	PATH './item[id="PPA_PROP_ACTION_ISSUED_DT"]/value'
							, PPA_ORAL_PREZ_REQUESTED	VARCHAR2(3)	PATH './item[id="PPA_ORAL_PREZ_REQUESTED"]/value'
							, PPA_ORAL_PREZ_DT	VARCHAR2(10)	PATH './item[id="PPA_ORAL_PREZ_DT"]/value'
							, PPA_ORAL_RESPONSE_SUBMITTED	VARCHAR2(3)	PATH './item[id="PPA_ORAL_RESPONSE_SUBMITTED"]/value'
							, PPA_RESPONSE_DUE_DT	VARCHAR2(10)	PATH './item[id="PPA_RESPONSE_DUE_DT"]/value'
							, PPA_WRITTEN_RESPONSE_SBMT_DT	VARCHAR2(10)	PATH './item[id="PPA_WRITTEN_RESPONSE_SUBMITTED_DT"]/value'
							, PPA_POS_TITLE	NVARCHAR2(50)	PATH './item[id="PPA_POS_TITLE"]/value'
							, PPA_PPLAN	NVARCHAR2(50)	PATH './item[id="PPA_PPLAN"]/value'
							, PPA_SERIES	NVARCHAR2(50)	PATH './item[id="PPA_SERIES"]/value'
							, PPA_CURRENT_INFO_GRADE	NVARCHAR2(50)	PATH './item[id="PPA_CURRENT_INFO_GRADE"]/value'
							, PPA_CURRENT_INFO_STEP	NVARCHAR2(50)	PATH './item[id="PPA_CURRENT_INFO_STEP"]/value'
							, PPA_PROPOSED_POS_TITLE	NVARCHAR2(50)	PATH './item[id="PPA_PROPOSED_POS_TITLE"]/value'
							, PPA_PROPOSED_PPLAN	NVARCHAR2(50)	PATH './item[id="PPA_PROPOSED_PPLAN"]/value'
							, PPA_PROPOSED_SERIES	NVARCHAR2(50)	PATH './item[id="PPA_PROPOSED_SERIES"]/value'
							, PPA_PROPOSED_INFO_GRADE	NVARCHAR2(50)	PATH './item[id="PPA_PROPOSED_INFO_GRADE"]/value'
							, PPA_PROPOSED_INFO_STEP	NVARCHAR2(50)	PATH './item[id="PPA_PROPOSED_INFO_STEP"]/value'
							, PPA_FINAL_POS_TITLE	NVARCHAR2(50)	PATH './item[id="PPA_FINAL_POS_TITLE"]/value'
							, PPA_FINAL_PPLAN	NVARCHAR2(50)	PATH './item[id="PPA_FINAL_PPLAN"]/value'
							, PPA_FINAL_SERIES	NVARCHAR2(50)	PATH './item[id="PPA_FINAL_SERIES"]/value'
							, PPA_FINAL_INFO_GRADE	NVARCHAR2(50)	PATH './item[id="PPA_FINAL_INFO_GRADE"]/value'
							, PPA_FINAL_INFO_STEP	NVARCHAR2(50)	PATH './item[id="PPA_FINAL_INFO_STEP"]/value'
							, PPA_NOTICE_ISSUED_DT	VARCHAR2(10)	PATH './item[id="PPA_NOTICE_ISSUED_DT"]/value'
							, PPA_DEMO_FINAL_AGENCY_DECISION	NVARCHAR2(200)	PATH './item[id="PPA_DEMO_FINAL_AGENCY_DECISION"]/value'
							, PPA_DECIDING_OFFCL	NVARCHAR2(255)	PATH './item[id="PPA_DECIDING_OFFCL"]/value/name'
							, PPA_DECISION_ISSUED_DT	VARCHAR2(10)	PATH './item[id="PPA_DECISION_ISSUED_DT"]/value'
							, PPA_DEMO_FINAL_AGENCY_EFF_DT	VARCHAR2(10)	PATH './item[id="PPA_DEMO_FINAL_AGENCY_EFF_DT"]/value'
							, PPA_NUMB_DAYS	NUMBER(20,0)	PATH './item[id="PPA_NUMB_DAYS"]/value'
							, PPA_EFFECTIVE_DT	VARCHAR2(10)	PATH './item[id="GEN_CPPA_EFFECTIVE_DTASE_STATUS"]/value'
							, PPA_CURRENT_ADMIN_CODE	NVARCHAR2(8)	PATH './item[id="PPA_CURRENT_ADMIN_CODE"]/value'
							, PPA_RE_ASSIGNMENT_CURR_ORG	NVARCHAR2(50)	PATH './item[id="PPA_RE_ASSIGNMENT_CURR_ORG"]/value'
							, PPA_FINAL_ADMIN_CODE	NVARCHAR2(8)	PATH './item[id="PPA_FINAL_ADMIN_CODE"]/value'
							, PPA_FINAL_ADMIN_CODE_FINAL_ORG	NVARCHAR2(50)	PATH './item[id="PPA_FINAL_ADMIN_CODE_FINAL_ORG"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
				TRG.PPA_ACTION_TYPE = SRC.PPA_ACTION_TYPE
				, TRG.PPA_TERMINATION_TYPE = SRC.PPA_TERMINATION_TYPE
				, TRG.PPA_TERM_PROP_ACTION_DT = SRC.PPA_TERM_PROP_ACTION_DT
				, TRG.PPA_TERM_ORAL_PREZ_REQUESTED = SRC.PPA_TERM_ORAL_PREZ_REQUESTED
				, TRG.PPA_TERM_ORAL_PREZ_DT = SRC.PPA_TERM_ORAL_PREZ_DT
				, TRG.PPA_TERM_WRITTEN_RESP = SRC.PPA_TERM_WRITTEN_RESP
				, TRG.PPA_TERM_WRITTEN_RESP_DUE_DT = SRC.PPA_TERM_WRITTEN_RESP_DUE_DT
				, TRG.PPA_TERM_WRITTEN_RESP_DT = SRC.PPA_TERM_WRITTEN_RESP_DT
				, TRG.PPA_TERM_AGENCY_DECISION = SRC.PPA_TERM_AGENCY_DECISION
				, TRG.PPA_TERM_DECIDING_OFFCL_NAME = SRC.PPA_TERM_DECIDING_OFFCL_NAME
				, TRG.PPA_TERM_DECISION_ISSUED_DT = SRC.PPA_TERM_DECISION_ISSUED_DT	
				, TRG.PPA_TERM_EFFECTIVE_DECISION_DT = 	SRC.PPA_TERM_EFFECTIVE_DECISION_DT
				, TRG.PPA_PROB_TERM_DCSN_ISSUED_DT = SRC.PPA_PROB_TERM_DCSN_ISSUED_DT	
				, TRG.PPA_PROBATION_CONDUCT = SRC.PPA_PROBATION_CONDUCT
				, TRG.PPA_PROBATION_PERFORMANCE = SRC.PPA_PROBATION_PERFORMANCE
				, TRG.PPA_APPEAL_GRIEVANCE_DEADLINE = SRC.PPA_APPEAL_GRIEVANCE_DEADLINE	
				, TRG.PPA_EMP_APPEAL_DECISION = SRC.PPA_EMP_APPEAL_DECISION
				, TRG.PPA_PROP_ACTION_ISSUED_DT = SRC.PPA_PROP_ACTION_ISSUED_DT
				, TRG.PPA_ORAL_PREZ_REQUESTED = SRC.PPA_ORAL_PREZ_REQUESTED
				, TRG.PPA_ORAL_PREZ_DT = SRC.PPA_ORAL_PREZ_DT	
				, TRG.PPA_ORAL_RESPONSE_SUBMITTED = SRC.PPA_ORAL_RESPONSE_SUBMITTED
				, TRG.PPA_RESPONSE_DUE_DT = SRC.PPA_RESPONSE_DUE_DT	
				, TRG.PPA_WRITTEN_RESPONSE_SBMT_DT	 = SRC.PPA_WRITTEN_RESPONSE_SBMT_DT
				, TRG.PPA_POS_TITLE = SRC.PPA_POS_TITLE
				, TRG.PPA_PPLAN = SRC.PPA_PPLAN
				, TRG.PPA_SERIES = SRC.PPA_SERIES
				, TRG.PPA_CURRENT_INFO_GRADE = SRC.PPA_CURRENT_INFO_GRADE
				, TRG.PPA_CURRENT_INFO_STEP = SRC.PPA_CURRENT_INFO_STEP
				, TRG.PPA_PROPOSED_POS_TITLE = SRC.PPA_PROPOSED_POS_TITLE
				, TRG.PPA_PROPOSED_PPLAN = SRC.PPA_PROPOSED_PPLAN
				, TRG.PPA_PROPOSED_SERIES = SRC.PPA_PROPOSED_SERIES
				, TRG.PPA_PROPOSED_INFO_GRADE = SRC.PPA_PROPOSED_INFO_GRADE
				, TRG.PPA_PROPOSED_INFO_STEP = SRC.PPA_PROPOSED_INFO_STEP
				, TRG.PPA_FINAL_POS_TITLE = SRC.PPA_FINAL_POS_TITLE
				, TRG.PPA_FINAL_PPLAN = SRC.PPA_FINAL_PPLAN
				, TRG.PPA_FINAL_SERIES = SRC.PPA_FINAL_SERIES
				, TRG.PPA_FINAL_INFO_GRADE = SRC.PPA_FINAL_INFO_GRADE
				, TRG.PPA_FINAL_INFO_STEP = SRC.PPA_FINAL_INFO_STEP
				, TRG.PPA_NOTICE_ISSUED_DT = SRC.PPA_NOTICE_ISSUED_DT
				, TRG.PPA_DEMO_FINAL_AGENCY_DECISION = SRC.PPA_DEMO_FINAL_AGENCY_DECISION
				, TRG.PPA_DECIDING_OFFCL = SRC.PPA_DECIDING_OFFCL
				, TRG.PPA_DECISION_ISSUED_DT = 	SRC.PPA_DECISION_ISSUED_DT
				, TRG.PPA_DEMO_FINAL_AGENCY_EFF_DT = SRC.PPA_DEMO_FINAL_AGENCY_EFF_DT
				, TRG.PPA_NUMB_DAYS = SRC.PPA_NUMB_DAYS
				, TRG.PPA_EFFECTIVE_DT = SRC.PPA_EFFECTIVE_DT	
				, TRG.PPA_CURRENT_ADMIN_CODE = SRC.PPA_CURRENT_ADMIN_CODE
				, TRG.PPA_RE_ASSIGNMENT_CURR_ORG = SRC.PPA_RE_ASSIGNMENT_CURR_ORG
				, TRG.PPA_FINAL_ADMIN_CODE = SRC.PPA_FINAL_ADMIN_CODE
				, TRG.PPA_FINAL_ADMIN_CODE_FINAL_ORG = SRC.PPA_FINAL_ADMIN_CODE_FINAL_ORG
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.PPA_ACTION_TYPE
				, TRG.PPA_TERMINATION_TYPE
				, TRG.PPA_TERM_PROP_ACTION_DT
				, TRG.PPA_TERM_ORAL_PREZ_REQUESTED
				, TRG.PPA_TERM_ORAL_PREZ_DT	
				, TRG.PPA_TERM_WRITTEN_RESP
				, TRG.PPA_TERM_WRITTEN_RESP_DUE_DT	
				, TRG.PPA_TERM_WRITTEN_RESP_DT	
				, TRG.PPA_TERM_AGENCY_DECISION
				, TRG.PPA_TERM_DECIDING_OFFCL_NAME
				, TRG.PPA_TERM_DECISION_ISSUED_DT	
				, TRG.PPA_TERM_EFFECTIVE_DECISION_DT	
				, TRG.PPA_PROB_TERM_DCSN_ISSUED_DT	
				, TRG.PPA_PROBATION_CONDUCT
				, TRG.PPA_PROBATION_PERFORMANCE
				, TRG.PPA_APPEAL_GRIEVANCE_DEADLINE	
				, TRG.PPA_EMP_APPEAL_DECISION
				, TRG.PPA_PROP_ACTION_ISSUED_DT	
				, TRG.PPA_ORAL_PREZ_REQUESTED
				, TRG.PPA_ORAL_PREZ_DT	
				, TRG.PPA_ORAL_RESPONSE_SUBMITTED
				, TRG.PPA_RESPONSE_DUE_DT	
				, TRG.PPA_WRITTEN_RESPONSE_SBMT_DT	
				, TRG.PPA_POS_TITLE
				, TRG.PPA_PPLAN
				, TRG.PPA_SERIES
				, TRG.PPA_CURRENT_INFO_GRADE
				, TRG.PPA_CURRENT_INFO_STEP
				, TRG.PPA_PROPOSED_POS_TITLE
				, TRG.PPA_PROPOSED_PPLAN
				, TRG.PPA_PROPOSED_SERIES
				, TRG.PPA_PROPOSED_INFO_GRADE
				, TRG.PPA_PROPOSED_INFO_STEP
				, TRG.PPA_FINAL_POS_TITLE
				, TRG.PPA_FINAL_PPLAN
				, TRG.PPA_FINAL_SERIES
				, TRG.PPA_FINAL_INFO_GRADE
				, TRG.PPA_FINAL_INFO_STEP
				, TRG.PPA_NOTICE_ISSUED_DT	
				, TRG.PPA_DEMO_FINAL_AGENCY_DECISION
				, TRG.PPA_DECIDING_OFFCL
				, TRG.PPA_DECISION_ISSUED_DT	
				, TRG.PPA_DEMO_FINAL_AGENCY_EFF_DT	
				, TRG.PPA_NUMB_DAYS
				, TRG.PPA_EFFECTIVE_DT	
				, TRG.PPA_CURRENT_ADMIN_CODE
				, TRG.PPA_RE_ASSIGNMENT_CURR_ORG
				, TRG.PPA_FINAL_ADMIN_CODE
				, TRG.PPA_FINAL_ADMIN_CODE_FINAL_ORG
               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.PPA_ACTION_TYPE
				, SRC.PPA_TERMINATION_TYPE
				, SRC.PPA_TERM_PROP_ACTION_DT
				, SRC.PPA_TERM_ORAL_PREZ_REQUESTED
				, SRC.PPA_TERM_ORAL_PREZ_DT	
				, SRC.PPA_TERM_WRITTEN_RESP
				, SRC.PPA_TERM_WRITTEN_RESP_DUE_DT	
				, SRC.PPA_TERM_WRITTEN_RESP_DT	
				, SRC.PPA_TERM_AGENCY_DECISION
				, SRC.PPA_TERM_DECIDING_OFFCL_NAME
				, SRC.PPA_TERM_DECISION_ISSUED_DT	
				, SRC.PPA_TERM_EFFECTIVE_DECISION_DT	
				, SRC.PPA_PROB_TERM_DCSN_ISSUED_DT	
				, SRC.PPA_PROBATION_CONDUCT
				, SRC.PPA_PROBATION_PERFORMANCE
				, SRC.PPA_APPEAL_GRIEVANCE_DEADLINE	
				, SRC.PPA_EMP_APPEAL_DECISION
				, SRC.PPA_PROP_ACTION_ISSUED_DT	
				, SRC.PPA_ORAL_PREZ_REQUESTED
				, SRC.PPA_ORAL_PREZ_DT	
				, SRC.PPA_ORAL_RESPONSE_SUBMITTED
				, SRC.PPA_RESPONSE_DUE_DT	
				, SRC.PPA_WRITTEN_RESPONSE_SBMT_DT	
				, SRC.PPA_POS_TITLE
				, SRC.PPA_PPLAN
				, SRC.PPA_SERIES
				, SRC.PPA_CURRENT_INFO_GRADE
				, SRC.PPA_CURRENT_INFO_STEP
				, SRC.PPA_PROPOSED_POS_TITLE
				, SRC.PPA_PROPOSED_PPLAN
				, SRC.PPA_PROPOSED_SERIES
				, SRC.PPA_PROPOSED_INFO_GRADE
				, SRC.PPA_PROPOSED_INFO_STEP
				, SRC.PPA_FINAL_POS_TITLE
				, SRC.PPA_FINAL_PPLAN
				, SRC.PPA_FINAL_SERIES
				, SRC.PPA_FINAL_INFO_GRADE
				, SRC.PPA_FINAL_INFO_STEP
				, SRC.PPA_NOTICE_ISSUED_DT	
				, SRC.PPA_DEMO_FINAL_AGENCY_DECISION
				, SRC.PPA_DECIDING_OFFCL
				, SRC.PPA_DECISION_ISSUED_DT	
				, SRC.PPA_DEMO_FINAL_AGENCY_EFF_DT	
				, SRC.PPA_NUMB_DAYS
				, SRC.PPA_EFFECTIVE_DT	
				, SRC.PPA_CURRENT_ADMIN_CODE
				, SRC.PPA_RE_ASSIGNMENT_CURR_ORG
				, SRC.PPA_FINAL_ADMIN_CODE
				, SRC.PPA_FINAL_ADMIN_CODE_FINAL_ORG
            );

		END;

		--------------------------------
		-- ERLR_ULP table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_ULP TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, TO_DATE(X.ULP_RECEIPT_CHARGE_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_RECEIPT_CHARGE_DT	
					, X.ULP_CHARGE_FILED_TIMELY
					, TO_DATE(X.ULP_AGENCY_RESPONSE_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_AGENCY_RESPONSE_DT	
					, X.ULP_FLRA_DOCUMENT_REUQESTED
					, TO_DATE(X.ULP_DOC_SUBMISSION_FLRA_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_DOC_SUBMISSION_FLRA_DT
					, X.ULP_DOCUMENT_DESCRIPTION
					, TO_DATE(X.ULP_DISPOSITION_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_DISPOSITION_DT
					, X.ULP_DISPOSITION_TYPE
					, TO_DATE(X.ULP_COMPLAINT_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_COMPLAINT_DT	
					, TO_DATE(X.ULP_AGENCY_ANSWER_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_AGENCY_ANSWER_DT	
					, TO_DATE(X.ULP_AGENCY_ANSWER_FILED_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_AGENCY_ANSWER_FILED_DT	
					, TO_DATE(X.ULP_SETTLEMENT_DISCUSSION_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_SETTLEMENT_DISCUSSION_DT	
					, TO_DATE(X.ULP_PREHEARING_DISCLOSURE_DUE,'MM/DD/YYYY HH24:MI:SS') AS ULP_PREHEARING_DISCLOSURE_DUE	
					, TO_DATE(X.ULP_PREHEARING_DISCLOSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_PREHEARING_DISCLOSUE_DT	
					, TO_DATE(X.ULP_PREHEARING_CONFERENCE_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_PREHEARING_CONFERENCE_DT
					, TO_DATE(X.ULP_HEARING_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_HEARING_DT
					, TO_DATE(X.ULP_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_DECISION_DT
					, X.ULP_EXCEPTION_FILED
					, TO_DATE(X.ULP_EXCEPTION_FILED_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_EXCEPTION_FILED_DT
                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS                            
							ULP_RECEIPT_CHARGE_DT	VARCHAR2(10)	PATH './item[id="ULP_RECEIPT_CHARGE_DT"]/value'
							, ULP_CHARGE_FILED_TIMELY	VARCHAR2(3)	PATH './item[id="ULP_CHARGE_FILED_TIMELY"]/value'
							, ULP_AGENCY_RESPONSE_DT	VARCHAR2(10)	PATH './item[id="ULP_AGENCY_RESPONSE_DT"]/value'
							, ULP_FLRA_DOCUMENT_REUQESTED	VARCHAR2(3)	PATH './item[id="ULP_FLRA_DOCUMENT_REUQESTED"]/value'
							, ULP_DOC_SUBMISSION_FLRA_DT	VARCHAR2(10)	PATH './item[id="ULP_DOCUMENT_SUBMISSION_FLRA_DT"]/value'
							, ULP_DOCUMENT_DESCRIPTION	NVARCHAR2(140)	PATH './item[id="ULP_DOCUMENT_DESCRIPTION"]/value'
							, ULP_DISPOSITION_DT	VARCHAR2(10)	PATH './item[id="ULP_DISPOSITION_DT"]/value'
							, ULP_DISPOSITION_TYPE	NVARCHAR2(200)	PATH './item[id="ULP_DISPOSITION_TYPE"]/value'
							, ULP_COMPLAINT_DT	VARCHAR2(10)	PATH './item[id="ULP_COMPLAINT_DT"]/value'
							, ULP_AGENCY_ANSWER_DT	VARCHAR2(10)	PATH './item[id="ULP_AGENCY_ANSWER_DT"]/value'
							, ULP_AGENCY_ANSWER_FILED_DT	VARCHAR2(10)	PATH './item[id="ULP_AGENCY_ANSWER_FILED_DT"]/value'
							, ULP_SETTLEMENT_DISCUSSION_DT	VARCHAR2(10)	PATH './item[id="ULP_SETTLEMENT_DISCUSSION_DT"]/value'
							, ULP_PREHEARING_DISCLOSURE_DUE	VARCHAR2(10)	PATH './item[id="ULP_PREHEARING_DISCLOSURE_DUE"]/value'
							, ULP_PREHEARING_DISCLOSUE_DT	VARCHAR2(10)	PATH './item[id="ULP_PREHEARING_DISCLOSUE_DT"]/value'
							, ULP_PREHEARING_CONFERENCE_DT	VARCHAR2(10)	PATH './item[id="ULP_PREHEARING_CONFERENCE_DT"]/value'
							, ULP_HEARING_DT	VARCHAR2(10)	PATH './item[id="ULP_HEARING_DT"]/value'
							, ULP_DECISION_DT	VARCHAR2(10)	PATH './item[id="ULP_DECISION_DT"]/value'
							, ULP_EXCEPTION_FILED	VARCHAR2(3)	PATH './item[id="ULP_EXCEPTION_FILED"]/value'
							, ULP_EXCEPTION_FILED_DT	VARCHAR2(10)	PATH './item[id="ULP_EXCEPTION_FILED_DT"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
                TRG.ULP_RECEIPT_CHARGE_DT = SRC.ULP_RECEIPT_CHARGE_DT
				, TRG.ULP_CHARGE_FILED_TIMELY = SRC.ULP_CHARGE_FILED_TIMELY
				, TRG.ULP_AGENCY_RESPONSE_DT = SRC.ULP_AGENCY_RESPONSE_DT
				, TRG.ULP_FLRA_DOCUMENT_REUQESTED = SRC.ULP_FLRA_DOCUMENT_REUQESTED
				, TRG.ULP_DOC_SUBMISSION_FLRA_DT = SRC.ULP_DOC_SUBMISSION_FLRA_DT
				, TRG.ULP_DOCUMENT_DESCRIPTION = SRC.ULP_DOCUMENT_DESCRIPTION
				, TRG.ULP_DISPOSITION_DT = SRC.ULP_DISPOSITION_DT
				, TRG.ULP_DISPOSITION_TYPE = SRC.ULP_DISPOSITION_TYPE
				, TRG.ULP_COMPLAINT_DT = SRC.ULP_COMPLAINT_DT
				, TRG.ULP_AGENCY_ANSWER_DT = SRC.ULP_AGENCY_ANSWER_DT
				, TRG.ULP_AGENCY_ANSWER_FILED_DT = SRC.ULP_AGENCY_ANSWER_FILED_DT
				, TRG.ULP_SETTLEMENT_DISCUSSION_DT = SRC.ULP_SETTLEMENT_DISCUSSION_DT
				, TRG.ULP_PREHEARING_DISCLOSURE_DUE = SRC.ULP_PREHEARING_DISCLOSURE_DUE
				, TRG.ULP_PREHEARING_DISCLOSUE_DT = SRC.ULP_PREHEARING_DISCLOSUE_DT
				, TRG.ULP_PREHEARING_CONFERENCE_DT = SRC.ULP_PREHEARING_CONFERENCE_DT
				, TRG.ULP_HEARING_DT = SRC.ULP_HEARING_DT
				, TRG.ULP_DECISION_DT = SRC.ULP_DECISION_DT
				, TRG.ULP_EXCEPTION_FILED = SRC.ULP_EXCEPTION_FILED
				, TRG.ULP_EXCEPTION_FILED_DT = SRC.ULP_EXCEPTION_FILED_DT
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.ULP_RECEIPT_CHARGE_DT
				, TRG.ULP_CHARGE_FILED_TIMELY
				, TRG.ULP_AGENCY_RESPONSE_DT
				, TRG.ULP_FLRA_DOCUMENT_REUQESTED
				, TRG.ULP_DOC_SUBMISSION_FLRA_DT
				, TRG.ULP_DOCUMENT_DESCRIPTION
				, TRG.ULP_DISPOSITION_DT
				, TRG.ULP_DISPOSITION_TYPE
				, TRG.ULP_COMPLAINT_DT
				, TRG.ULP_AGENCY_ANSWER_DT
				, TRG.ULP_AGENCY_ANSWER_FILED_DT
				, TRG.ULP_SETTLEMENT_DISCUSSION_DT
				, TRG.ULP_PREHEARING_DISCLOSURE_DUE
				, TRG.ULP_PREHEARING_DISCLOSUE_DT
				, TRG.ULP_PREHEARING_CONFERENCE_DT
				, TRG.ULP_HEARING_DT
				, TRG.ULP_DECISION_DT
				, TRG.ULP_EXCEPTION_FILED
				, TRG.ULP_EXCEPTION_FILED_DT
               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
                , SRC.ULP_RECEIPT_CHARGE_DT
				, SRC.ULP_CHARGE_FILED_TIMELY
				, SRC.ULP_AGENCY_RESPONSE_DT
				, SRC.ULP_FLRA_DOCUMENT_REUQESTED
				, SRC.ULP_DOC_SUBMISSION_FLRA_DT
				, SRC.ULP_DOCUMENT_DESCRIPTION
				, SRC.ULP_DISPOSITION_DT
				, SRC.ULP_DISPOSITION_TYPE
				, SRC.ULP_COMPLAINT_DT
				, SRC.ULP_AGENCY_ANSWER_DT
				, SRC.ULP_AGENCY_ANSWER_FILED_DT
				, SRC.ULP_SETTLEMENT_DISCUSSION_DT
				, SRC.ULP_PREHEARING_DISCLOSURE_DUE
				, SRC.ULP_PREHEARING_DISCLOSUE_DT
				, SRC.ULP_PREHEARING_CONFERENCE_DT
				, SRC.ULP_HEARING_DT
				, SRC.ULP_DECISION_DT
				, SRC.ULP_EXCEPTION_FILED
				, SRC.ULP_EXCEPTION_FILED_DT
            );

		END;

		--------------------------------
		-- ERLR_LABOR_NEGO table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_LABOR_NEGO TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, X.LN_NEGOTIATION_TYPE
					, X.LN_INITIATOR
					, TO_DATE(X.LN_DEMAND2BARGAIN_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_DEMAND2BARGAIN_DT
					, X.LN_BRIEFING_REQUEST
					, TO_DATE(X.LN_BRIEFING_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_BRIEFING_DT
					, TO_DATE(X.LN_PROPOSAL_SUBMISSION_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_PROPOSAL_SUBMISSION_DT
					, X.LN_PROPOSAL_SUBMISSION
					, X.LN_PROPOSAL_NEGOTIABLE
					, X.LN_NON_NEGOTIABLE_LETTER
					, X.LN_FILE_ULP
					, X.LN_PROPOSAL_INFO_GROUND_RULES
					, TO_DATE(X.LN_PRPSAL_INFO_NEG_COMMENCE_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_PRPSAL_INFO_NEG_COMMENCE_DT
					, X.LN_LETTER_PROVIDED
					, TO_DATE(X.LN_LETTER_PROVIDED_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_LETTER_PROVIDED_DT
					, X.LN_NEGOTIABLE_PROPOSAL
					, TO_DATE(X.LN_BARGAINING_BEGAN_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_BARGAINING_BEGAN_DT
					, TO_DATE(X.LN_IMPASSE_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_IMPASSE_DT
					, TO_DATE(X.LN_FSIP_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_FSIP_DECISION_DT
					, TO_DATE(X.LN_BARGAINING_END_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_BARGAINING_END_DT
					, TO_DATE(X.LN_AGREEMENT_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_AGREEMENT_DT
					, X.LN_SUMMARY_OF_ISSUE
					, X.LN_SECON_LETTER_REQUEST
					, X.LN_2ND_LETTER_PROVIDED
					, X.LN_NEGOTIABL_ISSUE_SUMMARY
					, TO_DATE(X.LN_2ND_PROVIDED_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_2ND_PROVIDED_DT
					, TO_DATE(X.LN_MNGMNT_ARTICLE4_NTC_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_MNGMNT_ARTICLE4_NTC_DT
					, X.LN_MNGMNT_NOTICE_RESPONSE
					, X.LN_MNGMNT_BRIEFING_REQUEST
					, TO_DATE(X.LN_BRIEFING_REQUESTED2_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_BRIEFING_REQUESTED2_DT
					, TO_DATE(X.LN_MNGMNT_BARGAIN_SBMSSION_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_MNGMNT_BARGAIN_SBMSSION_DT
					, X.LN_MNGMNT_PROPOSAL_SBMSSION
                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS
                            LN_NEGOTIATION_TYPE	NVARCHAR2(200)	PATH './item[id="LN_NEGOTIATION_TYPE"]/value'
							, LN_INITIATOR	NVARCHAR2(200)	PATH './item[id="LN_INITIATOR"]/value'
							, LN_DEMAND2BARGAIN_DT	VARCHAR2(10)	PATH './item[id="LN_DEMAND2BARGAIN_DT"]/value'
							, LN_BRIEFING_REQUEST	VARCHAR2(3)	PATH './item[id="LN_BRIEFING_REQUEST"]/value'
							, LN_BRIEFING_DT	VARCHAR2(10)	PATH './item[id="LN_BRIEFING_DT"]/value'
							, LN_PROPOSAL_SUBMISSION_DT	VARCHAR2(10)	PATH './item[id="LN_PROPOSAL_SUBMISSION_DT"]/value'
							, LN_PROPOSAL_SUBMISSION	VARCHAR2(3)	PATH './item[id="LN_PROPOSAL_SUBMISSION"]/value'
							, LN_PROPOSAL_NEGOTIABLE	VARCHAR2(3)	PATH './item[id="LN_PROPOSAL_NEGOTIABLE"]/value'
							, LN_NON_NEGOTIABLE_LETTER	VARCHAR2(3)	PATH './item[id="LN_NON_NEGOTIABLE_LETTER"]/value'
							, LN_FILE_ULP	VARCHAR2(3)	PATH './item[id="LN_FILE_ULP"]/value'
							, LN_PROPOSAL_INFO_GROUND_RULES	VARCHAR2(3)	PATH './item[id="LN_PROPOSAL_INFO_GROUND_RULES"]/value'
							, LN_PRPSAL_INFO_NEG_COMMENCE_DT	VARCHAR2(10)	PATH './item[id="LN_PROPOSAL_INFO_NEG_COMMENCED_DT"]/value'
							, LN_LETTER_PROVIDED	VARCHAR2(3)	PATH './item[id="LN_LETTER_PROVIDED"]/value'
							, LN_LETTER_PROVIDED_DT	VARCHAR2(10)	PATH './item[id="LN_LETTER_PROVIDED_DT"]/value'
							, LN_NEGOTIABLE_PROPOSAL	VARCHAR2(3)	PATH './item[id="LN_NEGOTIABLE_PROPOSAL"]/value'
							, LN_BARGAINING_BEGAN_DT	VARCHAR2(10)	PATH './item[id="LN_BARGAINING_BEGAN_DT"]/value'
							, LN_IMPASSE_DT	VARCHAR2(10)	PATH './item[id="LN_IMPASSE_DT"]/value'
							, LN_FSIP_DECISION_DT	VARCHAR2(10)	PATH './item[id="LN_FSIP_DECISION_DT"]/value'
							, LN_BARGAINING_END_DT	VARCHAR2(10)	PATH './item[id="LN_BARGAINING_END_DT"]/value'
							, LN_AGREEMENT_DT	VARCHAR2(10)	PATH './item[id="LN_AGREEMENT_DT"]/value'
							, LN_SUMMARY_OF_ISSUE	NVARCHAR2(500)	PATH './item[id="LN_SUMMARY_OF_ISSUE"]/value'
							, LN_SECON_LETTER_REQUEST	VARCHAR2(3)	PATH './item[id="LN_SECON_LETTER_REQUEST"]/value'
							, LN_2ND_LETTER_PROVIDED	VARCHAR2(3)	PATH './item[id="LN_2ND_LETTER_PROVIDED"]/value'
							, LN_NEGOTIABL_ISSUE_SUMMARY	NVARCHAR2(500)	PATH './item[id="LN_NEGOTIABL_ISSUE_SUMMARY"]/value'
							, LN_2ND_PROVIDED_DT	VARCHAR2(10)	PATH './item[id="LN_2ND_PROVIDED_DT"]/value'
							, LN_MNGMNT_ARTICLE4_NTC_DT	VARCHAR2(10)	PATH './item[id="LN_MNGMNT_ARTICLE4_NTC_DT"]/value'
							, LN_MNGMNT_NOTICE_RESPONSE	VARCHAR2(3)	PATH './item[id="LN_MNGMNT_NOTICE_RESPONSE"]/value'
							, LN_MNGMNT_BRIEFING_REQUEST	VARCHAR2(3)	PATH './item[id="LN_MNGMNT_BRIEFING_REQUEST"]/value'
							, LN_BRIEFING_REQUESTED2_DT	VARCHAR2(10)	PATH './item[id="LN_BRIEFING_REQUESTED2_DT"]/value'
							, LN_MNGMNT_BARGAIN_SBMSSION_DT	VARCHAR2(10)	PATH './item[id="LN_MNGMNT_BARGAIN_SUBMISSION_DT"]/value'
							, LN_MNGMNT_PROPOSAL_SBMSSION	VARCHAR2(3)	PATH './item[id="LN_MNGMNT_PROPOSAL_SUBMISSION"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET				
				TRG.LN_NEGOTIATION_TYPE = SRC.LN_NEGOTIATION_TYPE
				, TRG.LN_INITIATOR = SRC.LN_INITIATOR
				, TRG.LN_DEMAND2BARGAIN_DT = SRC.LN_DEMAND2BARGAIN_DT
				, TRG.LN_BRIEFING_REQUEST = SRC.LN_BRIEFING_REQUEST
				, TRG.LN_BRIEFING_DT = SRC.LN_BRIEFING_DT
				, TRG.LN_PROPOSAL_SUBMISSION_DT = SRC.LN_PROPOSAL_SUBMISSION_DT
				, TRG.LN_PROPOSAL_SUBMISSION = SRC.LN_PROPOSAL_SUBMISSION
				, TRG.LN_PROPOSAL_NEGOTIABLE = SRC.LN_PROPOSAL_NEGOTIABLE
				, TRG.LN_NON_NEGOTIABLE_LETTER = SRC.LN_NON_NEGOTIABLE_LETTER
				, TRG.LN_FILE_ULP = SRC.LN_FILE_ULP
				, TRG.LN_PROPOSAL_INFO_GROUND_RULES = SRC.LN_PROPOSAL_INFO_GROUND_RULES
				, TRG.LN_PRPSAL_INFO_NEG_COMMENCE_DT = SRC.LN_PRPSAL_INFO_NEG_COMMENCE_DT
				, TRG.LN_LETTER_PROVIDED = SRC.LN_LETTER_PROVIDED
				, TRG.LN_LETTER_PROVIDED_DT = SRC.LN_LETTER_PROVIDED_DT
				, TRG.LN_NEGOTIABLE_PROPOSAL = SRC.LN_NEGOTIABLE_PROPOSAL
				, TRG.LN_BARGAINING_BEGAN_DT = SRC.LN_BARGAINING_BEGAN_DT
				, TRG.LN_IMPASSE_DT = SRC.LN_IMPASSE_DT
				, TRG.LN_FSIP_DECISION_DT = SRC.LN_FSIP_DECISION_DT
				, TRG.LN_BARGAINING_END_DT = SRC.LN_BARGAINING_END_DT
				, TRG.LN_AGREEMENT_DT = SRC.LN_AGREEMENT_DT
				, TRG.LN_SUMMARY_OF_ISSUE = SRC.LN_SUMMARY_OF_ISSUE
				, TRG.LN_SECON_LETTER_REQUEST = SRC.LN_SECON_LETTER_REQUEST
				, TRG.LN_2ND_LETTER_PROVIDED = SRC.LN_2ND_LETTER_PROVIDED
				, TRG.LN_NEGOTIABL_ISSUE_SUMMARY = SRC.LN_NEGOTIABL_ISSUE_SUMMARY
				, TRG.LN_2ND_PROVIDED_DT = SRC.LN_2ND_PROVIDED_DT
				, TRG.LN_MNGMNT_ARTICLE4_NTC_DT = SRC.LN_MNGMNT_ARTICLE4_NTC_DT
				, TRG.LN_MNGMNT_NOTICE_RESPONSE = SRC.LN_MNGMNT_NOTICE_RESPONSE
				, TRG.LN_MNGMNT_BRIEFING_REQUEST = SRC.LN_MNGMNT_BRIEFING_REQUEST
				, TRG.LN_BRIEFING_REQUESTED2_DT = SRC.LN_BRIEFING_REQUESTED2_DT
				, TRG.LN_MNGMNT_BARGAIN_SBMSSION_DT = SRC.LN_MNGMNT_BARGAIN_SBMSSION_DT
				, TRG.LN_MNGMNT_PROPOSAL_SBMSSION = SRC.LN_MNGMNT_PROPOSAL_SBMSSION
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.LN_NEGOTIATION_TYPE
				, TRG.LN_INITIATOR
				, TRG.LN_DEMAND2BARGAIN_DT
				, TRG.LN_BRIEFING_REQUEST
				, TRG.LN_BRIEFING_DT
				, TRG.LN_PROPOSAL_SUBMISSION_DT
				, TRG.LN_PROPOSAL_SUBMISSION
				, TRG.LN_PROPOSAL_NEGOTIABLE
				, TRG.LN_NON_NEGOTIABLE_LETTER
				, TRG.LN_FILE_ULP
				, TRG.LN_PROPOSAL_INFO_GROUND_RULES
				, TRG.LN_PRPSAL_INFO_NEG_COMMENCE_DT
				, TRG.LN_LETTER_PROVIDED
				, TRG.LN_LETTER_PROVIDED_DT
				, TRG.LN_NEGOTIABLE_PROPOSAL
				, TRG.LN_BARGAINING_BEGAN_DT
				, TRG.LN_IMPASSE_DT
				, TRG.LN_FSIP_DECISION_DT
				, TRG.LN_BARGAINING_END_DT
				, TRG.LN_AGREEMENT_DT
				, TRG.LN_SUMMARY_OF_ISSUE
				, TRG.LN_SECON_LETTER_REQUEST
				, TRG.LN_2ND_LETTER_PROVIDED
				, TRG.LN_NEGOTIABL_ISSUE_SUMMARY
				, TRG.LN_2ND_PROVIDED_DT
				, TRG.LN_MNGMNT_ARTICLE4_NTC_DT
				, TRG.LN_MNGMNT_NOTICE_RESPONSE
				, TRG.LN_MNGMNT_BRIEFING_REQUEST
				, TRG.LN_BRIEFING_REQUESTED2_DT
				, TRG.LN_MNGMNT_BARGAIN_SBMSSION_DT
				, TRG.LN_MNGMNT_PROPOSAL_SBMSSION
               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.LN_NEGOTIATION_TYPE
				, SRC.LN_INITIATOR
				, SRC.LN_DEMAND2BARGAIN_DT
				, SRC.LN_BRIEFING_REQUEST
				, SRC.LN_BRIEFING_DT
				, SRC.LN_PROPOSAL_SUBMISSION_DT
				, SRC.LN_PROPOSAL_SUBMISSION
				, SRC.LN_PROPOSAL_NEGOTIABLE
				, SRC.LN_NON_NEGOTIABLE_LETTER
				, SRC.LN_FILE_ULP
				, SRC.LN_PROPOSAL_INFO_GROUND_RULES
				, SRC.LN_PRPSAL_INFO_NEG_COMMENCE_DT
				, SRC.LN_LETTER_PROVIDED
				, SRC.LN_LETTER_PROVIDED_DT
				, SRC.LN_NEGOTIABLE_PROPOSAL
				, SRC.LN_BARGAINING_BEGAN_DT
				, SRC.LN_IMPASSE_DT
				, SRC.LN_FSIP_DECISION_DT
				, SRC.LN_BARGAINING_END_DT
				, SRC.LN_AGREEMENT_DT
				, SRC.LN_SUMMARY_OF_ISSUE
				, SRC.LN_SECON_LETTER_REQUEST
				, SRC.LN_2ND_LETTER_PROVIDED
				, SRC.LN_NEGOTIABL_ISSUE_SUMMARY
				, SRC.LN_2ND_PROVIDED_DT
				, SRC.LN_MNGMNT_ARTICLE4_NTC_DT
				, SRC.LN_MNGMNT_NOTICE_RESPONSE
				, SRC.LN_MNGMNT_BRIEFING_REQUEST
				, SRC.LN_BRIEFING_REQUESTED2_DT
				, SRC.LN_MNGMNT_BARGAIN_SBMSSION_DT
				, SRC.LN_MNGMNT_PROPOSAL_SBMSSION
               
            );

		END;
	
	END IF;
		

    COMMIT;

EXCEPTION
	WHEN E_INVALID_PROCID THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_CLSF_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Process ID is not valid');
	WHEN E_INVALID_JOB_REQ_ID THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_CLSF_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Job Request ID is not valid');
	WHEN E_INVALID_STRATCON_DATA THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_CLSF_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Invalid data');
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		V_ERRCODE := SQLCODE;
		V_ERRMSG := SQLERRM;
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_CLSF_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || V_ERRCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || V_ERRMSG);
END;
/
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_ERLR_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_ERLR_TABLE TO HHS_CMS_HR_DEV_ROLE;
/

/**
 * This script will detect deleted ER/LR BizFlow process from certain date
 * , and remove corresponding ER/LR database records.
 *
 * @param P_STARTDATE - From Date of deletion
 * @param P_DEBUG_FLAG - 'T': not delete, 'F': delete records permanently
 *

 Example to run the SP
        SET SERVEROUTPUT ON; 
        CALL HHS_CMS_HR.SP_ERLR_CLEAN_PROC_DATA (SYSDATE, 'F');
    
    Query to verify the result. change ERLR_CASE_NUMBER and  number
        SELECT count(1) as ERLR_3RDPARTY_HEAR FROM HHS_CMS_HR.ERLR_3RDPARTY_HEAR WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_APPEAL FROM HHS_CMS_HR.ERLR_APPEAL WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_CNDT_ISSUE FROM HHS_CMS_HR.ERLR_CNDT_ISSUE WHERE ERLR_CASE_NUMBER = 10000;    
        SELECT count(1) as ERLR_EMPLOYEE_CASE FROM HHS_CMS_HR.ERLR_EMPLOYEE_CASE WHERE (CASEID = 10000 OR FROM_CASEID = 10000);
        SELECT count(1) as ERLR_GEN FROM HHS_CMS_HR.ERLR_GEN WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_GRIEVANCE FROM HHS_CMS_HR.ERLR_GRIEVANCE WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_INFO_REQUEST FROM HHS_CMS_HR.ERLR_INFO_REQUEST WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_INVESTIGATION FROM HHS_CMS_HR.ERLR_INVESTIGATION WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_LABOR_NEGO FROM HHS_CMS_HR.ERLR_LABOR_NEGO WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_LABOR_NEGO FROM HHS_CMS_HR.ERLR_LABOR_NEGO WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_MEDDOC FROM HHS_CMS_HR.ERLR_MEDDOC WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_PERF_ISSUE FROM HHS_CMS_HR.ERLR_PERF_ISSUE WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_PROB_ACTION FROM HHS_CMS_HR.ERLR_PROB_ACTION WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_ULP FROM HHS_CMS_HR.ERLR_ULP WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_WGI_DNL FROM HHS_CMS_HR.ERLR_WGI_DNL WHERE ERLR_CASE_NUMBER = 10000;
        
        SELECT count(1) as TBL_FORM_DTL HHS_CMS_HR.TBL_FORM_DTL WHERE PROCID = 123456;
        SELECT count(1) as TBL_FORM_DTL_AUDIT HHS_CMS_HR.TBL_FORM_DTL_AUDIT WHERE PROCID = 123456;        
*/

CREATE OR REPLACE PROCEDURE SP_ERLR_CLEAN_PROC_DATA
(
    P_STARTDATE         DATE := SYSDATE
    ,P_DEBUG_FLAG       VARCHAR2 := 'F' --[ 'T' | 'F' ]
)
IS
    C_ERLR_CASE_NUMBER	    NUMBER(20,0);
    C_ERLR_JOB_REQ_NUMBER	NVARCHAR2(16 CHAR);
    C_PROCID	            NUMBER(20,0);
    C_ERLR_CASE_STATUS_ID	NUMBER(20,0);
    C_ERLR_CASE_CREATE_DT	DATE;
    
    CURSOR CUR_DELETED_ERLR_PROCESSES(ip_StartDate DATE)
    IS
        SELECT ERLR_CASE_NUMBER, ERLR_JOB_REQ_NUMBER, PROCID, ERLR_CASE_STATUS_ID, ERLR_CASE_CREATE_DT
          FROM HHS_CMS_HR.ERLR_CASE
         WHERE ERLR_CASE_CREATE_DT >= SYSDATE - 10000
           AND NOT EXISTS (
                SELECT *
                  FROM BIZFLOW.PROCS P
                 WHERE P.NAME = 'ER/LR Case Initiation'
                   AND HHS_CMS_HR.ERLR_CASE.PROCID = P.PROCID
           )
    ;
    
BEGIN
    
    --DBMS_OUTPUT.PUT_LINE('P_DEBUG_FLAG=' || P_DEBUG_FLAG || ', P_STARTDATE=' || TO_CHAR(P_STARTDATE));    
    OPEN CUR_DELETED_ERLR_PROCESSES(P_STARTDATE);
    
    LOOP    
        FETCH
            CUR_DELETED_ERLR_PROCESSES
        INTO
            C_ERLR_CASE_NUMBER, C_ERLR_JOB_REQ_NUMBER, C_PROCID, C_ERLR_CASE_STATUS_ID, C_ERLR_CASE_CREATE_DT;
            
            IF C_PROCID IS NOT NULL THEN
            BEGIN
                --DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------');
                --DBMS_OUTPUT.PUT_LINE('PROCID = ' || TO_CHAR(C_PROCID) || ', ERLR_CASE_NUMBER = ' || TO_CHAR(C_ERLR_CASE_NUMBER));
                --DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------');

                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_3RDPARTY_HEAR'); 
                DELETE FROM HHS_CMS_HR.ERLR_3RDPARTY_HEAR WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_APPEAL');
                DELETE FROM HHS_CMS_HR.ERLR_APPEAL WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_CNDT_ISSUE');
                DELETE FROM HHS_CMS_HR.ERLR_CNDT_ISSUE WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;    
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_EMPLOYEE_CASE');
                DELETE FROM HHS_CMS_HR.ERLR_EMPLOYEE_CASE WHERE (CASEID = C_ERLR_CASE_NUMBER OR FROM_CASEID = C_ERLR_CASE_NUMBER) AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_GEN');
                DELETE FROM HHS_CMS_HR.ERLR_GEN WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_GRIEVANCE');
                DELETE FROM HHS_CMS_HR.ERLR_GRIEVANCE WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_INFO_REQUEST');
                DELETE FROM HHS_CMS_HR.ERLR_INFO_REQUEST WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_INVESTIGATION');
                DELETE FROM HHS_CMS_HR.ERLR_INVESTIGATION WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_LABOR_NEGO');
                DELETE FROM HHS_CMS_HR.ERLR_LABOR_NEGO WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_LABOR_NEGO');
                DELETE FROM HHS_CMS_HR.ERLR_LABOR_NEGO WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_MEDDOC');
                DELETE FROM HHS_CMS_HR.ERLR_MEDDOC WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_PERF_ISSUE');
                DELETE FROM HHS_CMS_HR.ERLR_PERF_ISSUE WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_PROB_ACTION');
                DELETE FROM HHS_CMS_HR.ERLR_PROB_ACTION WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_CASE');
                DELETE FROM HHS_CMS_HR.ERLR_CASE WHERE PROCID = C_PROCID AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_ULP');
                DELETE FROM HHS_CMS_HR.ERLR_ULP WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_WGI_DNL');
                DELETE FROM HHS_CMS_HR.ERLR_WGI_DNL WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                
                --------- common tables    
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - TBL_FORM_DTL_AUDIT');
                DELETE FROM HHS_CMS_HR.TBL_FORM_DTL_AUDIT WHERE PROCID = C_PROCID AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - TBL_FORM_DTL');
                DELETE FROM HHS_CMS_HR.TBL_FORM_DTL WHERE PROCID = C_PROCID AND 'F' = P_DEBUG_FLAG;
                DELETE FROM HHS_CMS_HR.TBL_FORM_DTL_AUDIT WHERE PROCID = C_PROCID AND 'F' = P_DEBUG_FLAG;
            END;
            END IF;
            
        EXIT WHEN CUR_DELETED_ERLR_PROCESSES%NOTFOUND;
    END LOOP;

    CLOSE CUR_DELETED_ERLR_PROCESSES;
    --DBMS_OUTPUT.PUT_LINE('--------------------------------------');
    
    COMMIT;

EXCEPTION
	WHEN OTHERS THEN
    CLOSE CUR_DELETED_ERLR_PROCESSES;
    ROLLBACK;
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred -------------------');
    --DBMS_OUTPUT.PUT_LINE('Error code    = ' || SQLCODE);
    --DBMS_OUTPUT.PUT_LINE('Error message = ' || SQLERRM);    
END;
/

GRANT EXECUTE ON HHS_CMS_HR.SP_ERLR_CLEAN_PROC_DATA TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_ERLR_CLEAN_PROC_DATA TO HHS_CMS_HR_DEV_ROLE;
/

