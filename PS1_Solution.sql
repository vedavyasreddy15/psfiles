Whenever oserror exit 9;
Whenever sqlerror exit sql.sqlcode;

set appinfo on
select 'Begin Executing ' || sys_context('USERENV', 'MODULE') MSG  from dual;

--------------------------------------------------------
--  DDL for Table CUSTOMER
--------------------------------------------------------

  CREATE TABLE "CUSTOMER" 
   (	"CUSTOMER_ID" VARCHAR2(38 BYTE), 
	"CUSTOMER_FIRST_NAME" VARCHAR2(30 BYTE), 
	"CUSTOMER_MIDDLE_NAME" VARCHAR2(30 BYTE), 
	"CUSTOMER_LAST_NAME" VARCHAR2(30 BYTE), 
	"CUSTOMER_DATE_OF_BIRTH" DATE, 
	"CUSTOMER_GENDER" VARCHAR2(10 BYTE), 
	"CUSTOMER_CRTD_ID" VARCHAR2(40 BYTE), 
	"CUSTOMER_CRTD_DT" DATE, 
	"CUSTOMER_UPDT_ID" VARCHAR2(40 BYTE), 
	"CUSTOMER_UPDT_DT" DATE
   ) ;
--------------------------------------------------------
--  DDL for Table ORDERS
--------------------------------------------------------

  CREATE TABLE "ORDERS" 
   (	"ORDERS_ID" VARCHAR2(38 BYTE), 
	"ORDERS_DATE" TIMESTAMP (6), 
	"ORDERS_CUSTOMER_ID" VARCHAR2(38 BYTE), 
	"ORDERS_CRTD_ID" VARCHAR2(40 BYTE), 
	"ORDERS_CRTD_DT" DATE, 
	"ORDERS_UPDT_ID" VARCHAR2(40 BYTE), 
	"ORDERS_UPDT_DT" DATE
   ) ;
--------------------------------------------------------
--  DDL for Table ORDERS_LINE
--------------------------------------------------------

  CREATE TABLE "ORDERS_LINE" 
   (	"ORDERS_LINE_ID" VARCHAR2(38 BYTE), 
	"ORDERS_LINE_ORDERS_ID" VARCHAR2(38 BYTE), 
	"ORDERS_LINE_PRODUCT_ID" VARCHAR2(38 BYTE), 
	"ORDERS_LINE_QTY" NUMBER(4,0), 
	"ORDERS_LINE_PRICE" NUMBER(9,2), 
	"ORDERS_LINE_CRTD_ID" VARCHAR2(40 BYTE), 
	"ORDERS_LINE_CRTD_DT" DATE, 
	"ORDERS_LINE_UPDT_ID" VARCHAR2(40 BYTE), 
	"ORDERS_LINE_UPDT_DT" DATE
   ) ;
--------------------------------------------------------
--  DDL for Table PRODUCT
--------------------------------------------------------

  CREATE TABLE "PRODUCT" 
   (	"PRODUCT_ID" VARCHAR2(38 BYTE) DEFAULT SYS_GUID(), 
	"PRODUCT_NAME" VARCHAR2(200 BYTE), 
	"PRODUCT_DESC" VARCHAR2(2000 BYTE), 
	"PRODUCT_PRODUCT_STATUS_ID" VARCHAR2(38 BYTE), 
	"PRODUCT_CRTD_ID" VARCHAR2(40 BYTE), 
	"PRODUCT_CRTD_DT" DATE, 
	"PRODUCT_UPDT_ID" VARCHAR2(40 BYTE), 
	"PRODUCT_UPDT_DT" DATE
   ) ;
--------------------------------------------------------
--  DDL for Table PRODUCT_STATUS
--------------------------------------------------------

  CREATE TABLE "PRODUCT_STATUS" 
   (	"PRODUCT_STATUS_ID" VARCHAR2(38 BYTE) DEFAULT SYS_GUID(), 
	"PRODUCT_STATUS_DESC" VARCHAR2(32 BYTE), 
	"PRODUCT_STATUS_CRTD_ID" VARCHAR2(40 BYTE), 
	"PRODUCT_STATUS_CRTD_DT" DATE, 
	"PRODUCT_STATUS_UPDT_ID" VARCHAR2(40 BYTE), 
	"PRODUCT_STATUS_UPDT_DT" DATE
   ) ;
--------------------------------------------------------
--  DDL for Index CUSTOMER_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "CUSTOMER_PK" ON "CUSTOMER" ("CUSTOMER_ID") 
  ;
--------------------------------------------------------
--  DDL for Index ORDERS_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "ORDERS_PK" ON "ORDERS" ("ORDERS_ID") 
  ;
--------------------------------------------------------
--  DDL for Index ORDERS_LINE_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "ORDERS_LINE_PK" ON "ORDERS_LINE" ("ORDERS_LINE_ID") 
  ;
--------------------------------------------------------
--  DDL for Index PRODUCT_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "PRODUCT_PK" ON "PRODUCT" ("PRODUCT_ID") 
  ;
--------------------------------------------------------
--  DDL for Index PRODUCT_STATUS_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "PRODUCT_STATUS_PK" ON "PRODUCT_STATUS" ("PRODUCT_STATUS_ID") 
  ;

--------------------------------------------------------
--  Constraints for Table CUSTOMER
--------------------------------------------------------

  ALTER TABLE "CUSTOMER" MODIFY ("CUSTOMER_ID" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMER" MODIFY ("CUSTOMER_FIRST_NAME" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMER" MODIFY ("CUSTOMER_LAST_NAME" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMER" MODIFY ("CUSTOMER_CRTD_ID" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMER" MODIFY ("CUSTOMER_CRTD_DT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMER" MODIFY ("CUSTOMER_UPDT_ID" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMER" MODIFY ("CUSTOMER_UPDT_DT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMER" ADD CONSTRAINT "CUSTOMER_PK" PRIMARY KEY ("CUSTOMER_ID")
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table ORDERS
--------------------------------------------------------

  ALTER TABLE "ORDERS" MODIFY ("ORDERS_ID" NOT NULL ENABLE);
  ALTER TABLE "ORDERS" MODIFY ("ORDERS_DATE" NOT NULL ENABLE);
  ALTER TABLE "ORDERS" MODIFY ("ORDERS_CUSTOMER_ID" NOT NULL ENABLE);
  ALTER TABLE "ORDERS" MODIFY ("ORDERS_CRTD_ID" NOT NULL ENABLE);
  ALTER TABLE "ORDERS" MODIFY ("ORDERS_CRTD_DT" NOT NULL ENABLE);
  ALTER TABLE "ORDERS" MODIFY ("ORDERS_UPDT_ID" NOT NULL ENABLE);
  ALTER TABLE "ORDERS" MODIFY ("ORDERS_UPDT_DT" NOT NULL ENABLE);
  ALTER TABLE "ORDERS" ADD CONSTRAINT "ORDERS_PK" PRIMARY KEY ("ORDERS_ID")
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table ORDERS_LINE
--------------------------------------------------------

  ALTER TABLE "ORDERS_LINE" MODIFY ("ORDERS_LINE_ID" NOT NULL ENABLE);
  ALTER TABLE "ORDERS_LINE" MODIFY ("ORDERS_LINE_ORDERS_ID" NOT NULL ENABLE);
  ALTER TABLE "ORDERS_LINE" MODIFY ("ORDERS_LINE_PRODUCT_ID" NOT NULL ENABLE);
  ALTER TABLE "ORDERS_LINE" MODIFY ("ORDERS_LINE_QTY" NOT NULL ENABLE);
  ALTER TABLE "ORDERS_LINE" MODIFY ("ORDERS_LINE_PRICE" NOT NULL ENABLE);
  ALTER TABLE "ORDERS_LINE" MODIFY ("ORDERS_LINE_CRTD_ID" NOT NULL ENABLE);
  ALTER TABLE "ORDERS_LINE" MODIFY ("ORDERS_LINE_CRTD_DT" NOT NULL ENABLE);
  ALTER TABLE "ORDERS_LINE" MODIFY ("ORDERS_LINE_UPDT_ID" NOT NULL ENABLE);
  ALTER TABLE "ORDERS_LINE" MODIFY ("ORDERS_LINE_UPDT_DT" NOT NULL ENABLE);
  ALTER TABLE "ORDERS_LINE" ADD CONSTRAINT "ORDERS_LINE_PK" PRIMARY KEY ("ORDERS_LINE_ID")
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table PRODUCT
--------------------------------------------------------

  ALTER TABLE "PRODUCT" MODIFY ("PRODUCT_ID" NOT NULL ENABLE);
  ALTER TABLE "PRODUCT" MODIFY ("PRODUCT_NAME" NOT NULL ENABLE);
  ALTER TABLE "PRODUCT" MODIFY ("PRODUCT_DESC" NOT NULL ENABLE);
  ALTER TABLE "PRODUCT" MODIFY ("PRODUCT_PRODUCT_STATUS_ID" NOT NULL ENABLE);
  ALTER TABLE "PRODUCT" MODIFY ("PRODUCT_CRTD_ID" NOT NULL ENABLE);
  ALTER TABLE "PRODUCT" MODIFY ("PRODUCT_CRTD_DT" NOT NULL ENABLE);
  ALTER TABLE "PRODUCT" MODIFY ("PRODUCT_UPDT_ID" NOT NULL ENABLE);
  ALTER TABLE "PRODUCT" MODIFY ("PRODUCT_UPDT_DT" NOT NULL ENABLE);
  ALTER TABLE "PRODUCT" ADD CONSTRAINT "PRODUCT_PK" PRIMARY KEY ("PRODUCT_ID")
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table PRODUCT_STATUS
--------------------------------------------------------

  ALTER TABLE "PRODUCT_STATUS" MODIFY ("PRODUCT_STATUS_CRTD_ID" NOT NULL ENABLE);
  ALTER TABLE "PRODUCT_STATUS" MODIFY ("PRODUCT_STATUS_CRTD_DT" NOT NULL ENABLE);
  ALTER TABLE "PRODUCT_STATUS" MODIFY ("PRODUCT_STATUS_UPDT_ID" NOT NULL ENABLE);
  ALTER TABLE "PRODUCT_STATUS" MODIFY ("PRODUCT_STATUS_ID" NOT NULL ENABLE);
  ALTER TABLE "PRODUCT_STATUS" MODIFY ("PRODUCT_STATUS_DESC" NOT NULL ENABLE);
  ALTER TABLE "PRODUCT_STATUS" ADD CONSTRAINT "PRODUCT_STATUS_PK" PRIMARY KEY ("PRODUCT_STATUS_ID")
  USING INDEX  ENABLE;
  ALTER TABLE "PRODUCT_STATUS" MODIFY ("PRODUCT_STATUS_UPDT_DT" NOT NULL ENABLE);
--------------------------------------------------------
--  Ref Constraints for Table ORDERS
--------------------------------------------------------

  ALTER TABLE "ORDERS" ADD CONSTRAINT "ORDERS_FK1" FOREIGN KEY ("ORDERS_CUSTOMER_ID")
	  REFERENCES "CUSTOMER" ("CUSTOMER_ID") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table ORDERS_LINE
--------------------------------------------------------

  ALTER TABLE "ORDERS_LINE" ADD CONSTRAINT "ORDERS_LINE_FK1" FOREIGN KEY ("ORDERS_LINE_ORDERS_ID")
	  REFERENCES "ORDERS" ("ORDERS_ID") ENABLE;
  ALTER TABLE "ORDERS_LINE" ADD CONSTRAINT "ORDERS_LINE_FK2" FOREIGN KEY ("ORDERS_LINE_PRODUCT_ID")
	  REFERENCES "PRODUCT" ("PRODUCT_ID") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table PRODUCT
--------------------------------------------------------

  ALTER TABLE "PRODUCT" ADD CONSTRAINT "PRODUCT_FK1" FOREIGN KEY ("PRODUCT_PRODUCT_STATUS_ID")
	  REFERENCES "PRODUCT_STATUS" ("PRODUCT_STATUS_ID") ENABLE;
