create or replace PROCEDURE SP_FINALIZE_ERLR
(
	I_PROCID               IN  NUMBER
)
IS
    V_CNT                   INT;
    V_XMLDOC                XMLTYPE;
    V_XMLVALUE              XMLTYPE;
    V_CASE_TYPE_ID          VARCHAR2(10);
    V_APPEAL                VARCHAR2(10);
    YES                     CONSTANT VARCHAR2(3) := 'Yes';
    INFORMATION_REQUEST_ID  CONSTANT VARCHAR2(10) := '747';    
    THIRD_PARTY_HEARING_ID  CONSTANT VARCHAR2(10) := '753';
    THIRD_PARTY_HEARING     CONSTANT VARCHAR2(50) := 'Third Party Hearing';
BEGIN
    SELECT FIELD_DATA
      INTO V_XMLDOC
      FROM TBL_FORM_DTL
     WHERE PROCID = I_PROCID;

    V_CASE_TYPE_ID := V_XMLDOC.EXTRACT('//id[contains(text(),"GEN_CASE_TYPE")]/../value/text()').getStringVal();
    --DBMS_OUTPUT.PUT_LINE('V_CASE_TYPE_ID=' || V_CASE_TYPE_ID);
    
    V_XMLVALUE := V_XMLDOC.EXTRACT('//id[text()="IR_APPEAL_DENIAL"]/../value/text()');
    IF V_XMLVALUE IS NOT NULL THEN
        V_APPEAL := V_XMLVALUE.GETSTRINGVAL();
    END IF;
    --DBMS_OUTPUT.PUT_LINE('V_APPEAL=' || V_APPEAL);
    
    -- Third Party Case
    IF V_CASE_TYPE_ID = INFORMATION_REQUEST_ID AND V_APPEAL = YES THEN
        --DBMS_OUTPUT.PUT_LINE('CREATE Third Party Case');
        SELECT DELETEXML(V_XMLDOC,'//id[not(contains(text(),"GEN_"))]/..') INTO V_XMLDOC FROM DUAL;
        SELECT DELETEXML(V_XMLDOC,'//id[text()="GEN_CASE_CATEGORY"]/..') INTO V_XMLDOC FROM DUAL;
        SELECT UPDATEXML(V_XMLDOC,'//id[text()="GEN_CASE_TYPE"]/../value/text()', THIRD_PARTY_HEARING_ID) INTO V_XMLDOC FROM DUAL;
        SELECT UPDATEXML(V_XMLDOC,'//id[text()="GEN_CASE_TYPE"]/../text/text()',  THIRD_PARTY_HEARING) INTO V_XMLDOC FROM DUAL;
    
        INSERT INTO ERLR_CASE_TRIGGER (SEQ,FROM_PROCID,FIELD_DATA) 
            VALUES (ERLR_CASE_TRIGGER_SEQ.NEXTVAL, I_PROCID, V_XMLDOC);
    END IF;
EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;
/