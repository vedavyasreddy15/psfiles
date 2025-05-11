Whenever oserror exit 9;
Whenever sqlerror exit sql.sqlcode;

set appinfo on
select 'Begin Executing ' || sys_context('USERENV', 'MODULE') MSG  from dual;

CREATE OR REPLACE PROCEDURE PRC_CREATE_TRG01_TRIGGERS
(TABLE_NAME_IN VARCHAR2)
AS
V_SQL VARCHAR2(2000);
BEGIN

        V_SQL := 'CREATE OR REPLACE TRIGGER trg01_' || TABLE_NAME_IN || ' BEFORE ';
        V_SQL := V_SQL || ' INSERT OR UPDATE ON ' || TABLE_NAME_IN;
        V_SQL := V_SQL || ' FOR EACH ROW ';
        V_SQL := V_SQL || ' BEGIN';
        V_SQL := V_SQL || ' IF inserting THEN ';
        V_SQL := V_SQL || ' :new.' || TABLE_NAME_IN || '_crtd_id := user;';
        V_SQL := V_SQL || ' :new.' || TABLE_NAME_IN || '_crtd_dt := sysdate;';
        V_SQL := V_SQL || ' END IF;';
        V_SQL := V_SQL || ' :new.' || TABLE_NAME_IN || '_updt_id := user;';
        V_SQL := V_SQL || ' :new.' || TABLE_NAME_IN || '_updt_dt := sysdate;';
        V_SQL := V_SQL || ' END;';
        
        EXECUTE IMMEDIATE V_SQL;

    
END;
/
CREATE OR REPLACE PROCEDURE PRC_CREATE_TRG02_TRIGGERS
(TABLE_NAME_IN VARCHAR2,
 COLUMN_NAME_IN VARCHAR2)
AS
V_SQL VARCHAR2(2000);

BEGIN
        V_SQL := 'CREATE OR REPLACE TRIGGER trg02_' || TABLE_NAME_IN || ' BEFORE ';
        V_SQL := V_SQL || ' INSERT OR UPDATE ON ' || TABLE_NAME_IN;
        V_SQL := V_SQL || ' FOR EACH ROW ';
        V_SQL := V_SQL || ' BEGIN';
        V_SQL := V_SQL || ' IF inserting THEN ';
        V_SQL := V_SQL || ' IF :NEW.' || COLUMN_NAME_IN  || ' IS NULL THEN ';
        V_SQL := V_SQL || ' :NEW.' || COLUMN_NAME_IN || ' := SYS_GUID();';
        V_SQL := V_SQL || ' END IF;';
        V_SQL := V_SQL || ' END IF;';
        V_SQL := V_SQL || ' IF UPDATING THEN';
        V_SQL := V_SQL || ' :NEW.' || COLUMN_NAME_IN || ' := :OLD.' || COLUMN_NAME_IN || ';';
        V_SQL := V_SQL || ' END IF;';
        V_SQL := V_SQL || ' END;';
        
        
        EXECUTE IMMEDIATE V_SQL;
    
    
END;
/
create or replace PROCEDURE prc_create_triggers as

  CURSOR C_TABLES IS
  SELECT * FROM USER_TABLES;
  
  FUNCTION GET_PK(TABLE_NAME_IN VARCHAR2)
  RETURN VARCHAR2
  AS
    V_KEY_COL VARCHAR2(200);  
  
  BEGIN
  SELECT UCC.COLUMN_NAME
    INTO V_KEY_COL
    FROM SYS.user_constraints UC
    INNER JOIN user_cons_columns UCC
    ON UC.OWNER = UCC.OWNER
    AND UC.CONSTRAINT_NAME = UCC.CONSTRAINT_NAME
    WHERE CONSTRAINT_TYPE = 'P'
    AND UC.TABLE_NAME = TABLE_NAME_IN;

    RETURN V_KEY_COL;
  
  END;
BEGIN
    FOR R_TABLE IN C_TABLES
    LOOP    
        PRC_CREATE_TRG01_TRIGGERS(R_TABLE.TABLE_NAME);
        PRC_CREATE_TRG02_TRIGGERS(R_TABLE.TABLE_NAME, GET_PK(R_TABLE.TABLE_NAME));
    END LOOP;
END;
/

BEGIN
  PRC_CREATE_TRIGGERS();
END;
/


CREATE OR REPLACE PACKAGE pkg_data AS
    TYPE varray IS
        VARRAY(1000) OF VARCHAR2(50);
    PROCEDURE create_customers (
        nbr_cust_in NUMBER
    );
    PROCEDURE create_orders (
        nbr_cust_in NUMBER
    );
    
END pkg_data;
/

CREATE OR REPLACE PACKAGE BODY pkg_data wrapped 
a000000
b2
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
b
8079 31a6
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
LHt41sQ=

/


BEGIN
  PKG_DATA.CREATE_CUSTOMERS(50);
  PKG_DATA.CREATE_ORDERS(500);
END;
/
COMMIT;


CREATE TABLE gender (
    gender_id      VARCHAR2(38) NOT NULL,
    gender_name    VARCHAR2(20) NOT NULL,
    gender_crtd_id VARCHAR2(40) NOT NULL,
    gender_crtd_dt DATE NOT NULL,
    gender_updt_id VARCHAR2(40) NOT NULL,
    gender_updt_dt DATE NOT NULL,
    CONSTRAINT gender_pk PRIMARY KEY ( gender_id ) ENABLE
);

ALTER TABLE GENDER  
MODIFY (GENDER_ID DEFAULT sys_guid() );

BEGIN
  PRC_CREATE_TRIGGERS();
END;
/

ALTER TABLE customer ADD (
    customer_gender_id VARCHAR2(38)
);

INSERT INTO gender ( gender_name )
    SELECT DISTINCT
        customer_gender
    FROM
        customer;

UPDATE customer c
SET
    customer_gender_id = (
        SELECT
            g.gender_id
        FROM
            gender g
        WHERE
            g.gender_name = c.customer_gender
    );

ALTER TABLE customer DROP COLUMN customer_gender;

ALTER TABLE customer
    ADD CONSTRAINT customer_fk1 FOREIGN KEY ( customer_gender_id )
        REFERENCES gender ( gender_id )
    ENABLE;


UPDATE GENDER
SET GENDER_NAME = 'Transgender'
where GENDER_NAME = 'Transgendr';
commit;

CREATE TABLE product_price (
    product_price_id         VARCHAR2(38) NOT NULL,
    product_price_product_id VARCHAR2(38) NOT NULL,
    product_price_eff_date   DATE NOT NULL,
    product_price_price      NUMBER(9, 2) NOT NULL,
    product_price_crtd_id    VARCHAR2(40) NOT NULL,
    product_price_crtd_dt    DATE NOT NULL,
    product_price_updt_id    VARCHAR2(40) NOT NULL,
    product_price_updt_dt    DATE NOT NULL,
    CONSTRAINT product_price_pk PRIMARY KEY ( product_price_id ) ENABLE
);

ALTER TABLE product_price
    ADD CONSTRAINT product_price_fk1 FOREIGN KEY ( product_price_product_id )
        REFERENCES product ( product_id )
    ENABLE;

ALTER TABLE product_price ADD CONSTRAINT product_price_chk1 CHECK ( product_price_price > 0 ) ENABLE;

BEGIN
  PRC_CREATE_TRIGGERS();
END;
/