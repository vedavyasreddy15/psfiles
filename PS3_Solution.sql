Whenever oserror exit 9;
Whenever sqlerror exit sql.sqlcode;

set appinfo on
select 'Begin Executing ' || sys_context('USERENV', 'MODULE') MSG  from dual;

Whenever oserror exit 9;
Whenever sqlerror exit sql.sqlcode;

Whenever oserror exit 9;
Whenever sqlerror exit sql.sqlcode;

set appinfo on
select 'Begin Executing ' || sys_context('USERENV', 'MODULE') MSG  from dual;

CREATE TABLE ADDRESS 
(
  ADDRESS_ID VARCHAR2(32) NOT NULL 
, ADDRESS_LINE1 VARCHAR2(50) NOT NULL 
, ADDRESS_LINE2 VARCHAR2(50) 
, ADDRESS_LINE3 VARCHAR2(50) 
, ADDRESS_CITY VARCHAR2(40) NOT NULL 
, ADDRESS_STATE CHAR(2) NOT NULL 
, ADDRESS_ZIP VARCHAR2(9) NOT NULL 
, ADDRESS_CRTD_ID VARCHAR2(40) NOT NULL 
, ADDRESS_CRTD_DT DATE NOT NULL 
, ADDRESS_UPDT_ID VARCHAR2(40) NOT NULL 
, ADDRESS_UPDT_DT DATE NOT NULL 
, CONSTRAINT ADDRESS_PK PRIMARY KEY 
  (
    ADDRESS_ID 
  )
  ENABLE 
);

CREATE TABLE ADDRESS_TYPE 
(
  ADDRESS_TYPE_ID VARCHAR2(32) NOT NULL 
, ADDRESS_TYPE_DESC VARCHAR2(10) NOT NULL 
, ADDRESS_TYPE_CRTD_ID VARCHAR2(40) NOT NULL 
, ADDRESS_TYPE_CRTD_DT DATE NOT NULL 
, ADDRESS_TYPE_UPDT_ID VARCHAR2(40) NOT NULL 
, ADDRESS_TYPE_UPDT_DT DATE NOT NULL 
, CONSTRAINT ADDRESS_TYPE_PK PRIMARY KEY 
  (
    ADDRESS_TYPE_ID 
  )
  ENABLE 
);


CREATE TABLE CUSTOMER_ADDRESS 
(
  CUSTOMER_ADDRESS_ID VARCHAR2(32) NOT NULL 
, CUSTOMER_ADDRESS_CUSTOMER_ID VARCHAR2(32) NOT NULL 
, CUSTOMER_ADDRESS_ADDRESS_ID VARCHAR2(32) NOT NULL 
, CUSTOMER_ADDRESS_ADDRESS_TYPE_ID VARCHAR2(32) NOT NULL 
, CUSTOMER_ADDRESS_ACTV_IND NUMBER(1) NOT NULL 
, CUSTOMER_ADDRESS_DEFAULT_IND NUMBER(1) NOT NULL 
, CUSTOMER_ADDRESS_CRTD_ID VARCHAR2(40) NOT NULL 
, CUSTOMER_ADDRESS_CRTD_DT DATE NOT NULL 
, CUSTOMER_ADDRESS_UPDT_ID VARCHAR2(40) NOT NULL 
, CUSTOMER_ADDRESS_UPDT_DT DATE NOT NULL 
, CONSTRAINT CUSTOMER_ADDRESS_PK PRIMARY KEY 
  (
    CUSTOMER_ADDRESS_ID 
  )
  ENABLE 
);

ALTER TABLE CUSTOMER_ADDRESS
ADD CONSTRAINT CUSTOMER_ADDRESS_FK1 FOREIGN KEY
(
  CUSTOMER_ADDRESS_CUSTOMER_ID 
)
REFERENCES CUSTOMER
(
  CUSTOMER_ID 
)
ENABLE;

ALTER TABLE CUSTOMER_ADDRESS
ADD CONSTRAINT CUSTOMER_ADDRESS_FK2 FOREIGN KEY
(
  CUSTOMER_ADDRESS_ADDRESS_ID 
)
REFERENCES ADDRESS
(
  ADDRESS_ID 
)
ENABLE;

ALTER TABLE CUSTOMER_ADDRESS
ADD CONSTRAINT CUSTOMER_ADDRESS_FK3 FOREIGN KEY
(
  CUSTOMER_ADDRESS_ADDRESS_TYPE_ID 
)
REFERENCES ADDRESS_TYPE
(
  ADDRESS_TYPE_ID 
)
ENABLE;

CREATE TABLE order_status (
    order_status_id                   VARCHAR2(32) NOT NULL,
    order_status_desc                 VARCHAR2(20) NOT NULL,
    order_status_next_order_status_id VARCHAR2(32),
    order_status_crtd_id              VARCHAR2(40) NOT NULL,
    order_status_crtd_dt              DATE NOT NULL,
    order_status_updt_id              VARCHAR2(40) NOT NULL,
    order_status_updt_dt              DATE NOT NULL,
    CONSTRAINT order_status_pk PRIMARY KEY ( order_status_id ) ENABLE
);

ALTER TABLE ORDER_STATUS
ADD CONSTRAINT ORDER_STATUS_FK1 FOREIGN KEY
(
  ORDER_STATUS_NEXT_ORDER_STATUS_ID 
)
REFERENCES ORDER_STATUS
(
  ORDER_STATUS_ID 
)
DEFERRABLE INITIALLY DEFERRED
ENABLE;



CREATE TABLE ORDER_STATE 
(
  ORDER_STATE_ID VARCHAR2(32) NOT NULL 
, ORDER_STATE_ORDERS_ID VARCHAR2(32) NOT NULL 
, ORDER_STATE_ORDER_STATUS_ID VARCHAR2(32) NOT NULL 
, ORDER_STATE_EFF_DATE DATE NOT NULL 
, ORDER_STATE_CRTD_ID VARCHAR2(40) NOT NULL 
, ORDER_STATE_CRTD_DT DATE NOT NULL 
, ORDER_STATE_UPDT_ID VARCHAR2(40) NOT NULL 
, ORDER_STATE_UPDT_DT DATE NOT NULL 
, CONSTRAINT ORDER_STATE_PK PRIMARY KEY 
  (
    ORDER_STATE_ID 
  )
  ENABLE 
);

ALTER TABLE ORDER_STATE
ADD CONSTRAINT ORDER_STATE_FK1 FOREIGN KEY
(
  ORDER_STATE_ORDERS_ID 
)
REFERENCES ORDERS
(
  ORDERS_ID 
)
ENABLE;

ALTER TABLE ORDER_STATE
ADD CONSTRAINT ORDER_STATE_FK2 FOREIGN KEY
(
  ORDER_STATE_ORDER_STATUS_ID 
)
REFERENCES ORDER_STATUS
(
  ORDER_STATUS_ID 
)
ENABLE;

BEGIN
  PRC_CREATE_TRIGGERS();
END;
/


DECLARE
    V_NEW_STATUS VARCHAR2(32);
    V_PICKING_STATUS VARCHAR2(32);
    V_PICKED_STATUS VARCHAR2(32);
    V_SHIPPING_STATUS VARCHAR2(32);
    V_SHIPPED_STATUS VARCHAR2(32);
BEGIN
    V_NEW_STATUS := sys_guid();
    V_PICKING_STATUS:= sys_guid();
    V_PICKED_STATUS:= sys_guid();
    V_SHIPPING_STATUS:= sys_guid();
    V_SHIPPED_STATUS:= sys_guid();
    
    INSERT INTO ORDER_STATUS
    (order_status_id, order_status_desc, order_status_next_order_status_id)
    values
    (V_NEW_STATUS, 'New',V_PICKING_STATUS);

    INSERT INTO ORDER_STATUS
    (order_status_id, order_status_desc, order_status_next_order_status_id)
    values
    (V_PICKING_STATUS, 'Picking',V_PICKED_STATUS);

    INSERT INTO ORDER_STATUS
    (order_status_id, order_status_desc, order_status_next_order_status_id)
    values
    (V_PICKED_STATUS, 'Picked',V_SHIPPING_STATUS);

    INSERT INTO ORDER_STATUS
    (order_status_id, order_status_desc, order_status_next_order_status_id)
    values
    (V_SHIPPING_STATUS, 'Shipping',V_SHIPPED_STATUS);

    INSERT INTO ORDER_STATUS
    (order_status_id, order_status_desc, order_status_next_order_status_id)
    values
    (V_SHIPPED_STATUS, 'Shipped',null);
END;
/



CREATE OR REPLACE PACKAGE pkg_order AS
    PROCEDURE set_order_status (
        order_state_orders_id_in       orders.orders_id%TYPE,
        order_state_order_status_id_in order_state.order_state_order_status_id%TYPE,
        order_state_eff_date_in        order_state.order_state_eff_date%TYPE
    );

    PROCEDURE advance_order_status (
        orders_id_in            orders.orders_id%TYPE,
        order_state_eff_date_in order_state.order_state_eff_date%TYPE
    );

END pkg_order;
/

CREATE OR REPLACE PACKAGE BODY pkg_order AS

    FUNCTION fn_current_order_status (
        order_id_in VARCHAR2
    ) RETURN VARCHAR2 AS

        v_cnt NUMBER(3);
        CURSOR c_status IS
        SELECT
            *
        FROM
            (
                SELECT
                    order_status_id,
                    order_status_desc,
                    level lvl
                FROM
                    order_status
                CONNECT BY
                    PRIOR order_status_id = order_status_next_order_status_id
                START WITH order_status_next_order_status_id IS NULL
            )
        ORDER BY
            lvl;

    BEGIN
        FOR r_status IN c_status LOOP
            --dbms_output.put_line(r_status.order_status_desc);
            SELECT
                COUNT(*)
            INTO v_cnt
            FROM
                order_state
            WHERE
                    order_state_orders_id = order_id_in
                AND order_state_order_status_id = r_status.order_status_id;

            IF v_cnt > 0 THEN
                RETURN r_status.order_status_id;
            END IF;
        END LOOP;

        RETURN NULL;
    END fn_current_order_status;

    FUNCTION fn_next_status (
        order_status_id_in VARCHAR2
    ) RETURN VARCHAR2 AS
        v_next_order_status_id VARCHAR2(32);
        v_cnt                  NUMBER(1);
    BEGIN
        IF order_status_id_in IS NULL THEN
            SELECT
                order_status_id
            INTO v_next_order_status_id
            FROM
                order_status
            WHERE
                order_status_id NOT IN (
                    SELECT
                        order_status_next_order_status_id
                    FROM
                        order_status
                    WHERE
                        order_status_next_order_status_id IS NOT NULL
                );

            RETURN v_next_order_status_id;
        END IF;

        SELECT
            COUNT(*)
        INTO v_cnt
        FROM
            order_status
        WHERE
            order_status_id = order_status_id_in;

        IF v_cnt = 0 THEN
            RETURN NULL;
        END IF;
        SELECT
            order_status_next_order_status_id
        INTO v_next_order_status_id
        FROM
            order_status
        WHERE
            order_status_id = order_status_id_in;

        RETURN v_next_order_status_id;
    END fn_next_status;

    PROCEDURE set_order_status (
        order_state_orders_id_in       orders.orders_id%TYPE,
        order_state_order_status_id_in order_state.order_state_order_status_id%TYPE,
        order_state_eff_date_in        order_state.order_state_eff_date%TYPE
    ) AS
    BEGIN
        INSERT INTO order_state (
            order_state_id,
            order_state_orders_id,
            order_state_order_status_id,
            order_state_eff_date
        ) VALUES (
            sys_guid(),
            order_state_orders_id_in,
            order_state_order_status_id_in,
            order_state_eff_date_in
        );

    END set_order_status;

    PROCEDURE advance_order_status (
        orders_id_in            orders.orders_id%TYPE,
        order_state_eff_date_in order_state.order_state_eff_date%TYPE
    ) AS
        v_current_order_status_id VARCHAR2(32);
        v_next_order_status_id    VARCHAR2(32);
    BEGIN
        v_current_order_status_id := fn_current_order_status(orders_id_in);
        v_next_order_status_id := fn_next_status(v_current_order_status_id);
        IF v_next_order_status_id IS NOT NULL THEN
            set_order_status(orders_id_in, v_next_order_status_id, order_state_eff_date_in);
        END IF;
    END advance_order_status;

END pkg_order;
/

create or replace PACKAGE pkg_data AS
    TYPE varray IS
        VARRAY(1000) OF VARCHAR2(50);
    PROCEDURE create_customers (
        nbr_cust_in NUMBER
    );

    PROCEDURE create_addresses (
        nbr_adrs_in NUMBER
    );

    PROCEDURE create_orders (
        nbr_cust_in NUMBER
    );

    PROCEDURE advance_random_orders (
        nbr_order_in NUMBER
    );

    FUNCTION get_random_city RETURN VARCHAR2;
    
    procedure create_product_status;

END pkg_data;
/

CREATE OR REPLACE PACKAGE BODY pkg_data AS

    vcity_names    varray := varray('Bellefonte', 'Newark', 'Camden', 'Seaford', 'Selbyville',
                                'Glasgow', 'Kent Acres', 'Smyrna', 'Clayton', 'Delmar',
                                'Wyoming', 'Rising Sun-Lebanon', 'Wilmington Manor', 'Lewes', 'Milford',
                                'Delaware City', 'Brookside', 'Georgetown', 'Greenwood', 'Edgemoor',
                                'Hockessin', 'Ocean View', 'Riverview', 'Bridgeville', 'Dover',
                                'Milton', 'Laurel', 'Pike Creek Valley', 'Woodside East', 'Bear',
                                'Harrington', 'Rodney Village', 'Pike Creek', 'Townsend', 'Elsmere',
                                'Middletown', 'Millsboro', 'Cheswold', 'New Castle', 'Claymont',
                                'Newport', 'Blades', 'North Star', 'Rehoboth Beach', 'Bethany Beach',
                                'Felton', 'Greenville', 'Dover Base Housing', 'Highland Acres', 'Long Neck',
                                'Wilmington');
    vstates_names  varray := varray('MD', 'MO', 'MS', 'NC', 'NJ',
                                  'OH', 'OK', 'PA', 'SC', 'TN',
                                  'TX', 'VA', 'WV', 'AL', 'CT',
                                  'IA', 'IL', 'IN', 'MA', 'ME',
                                  'MI', 'MN', 'ND', 'NE', 'NH',
                                  'NY', 'AR', 'DE', 'FL', 'GA',
                                  'KS', 'KY', 'LA', 'RI', 'SD',
                                  'VT', 'WI', 'CA', 'AZ', 'CO',
                                  'NM', 'NV', 'UT', 'AK', 'ID',
                                  'MT', 'OR', 'WA', 'HI', 'WY',
                                  'DC');
    vgender_names  varray := varray('Male', 'Female', 'Cisgender', 'Transgender', 'Nonbinary');
    vstreet_names1 varray := varray('Oak', 'Elm', 'Beaver', 'Quail', 'Red',
                                   'North', 'South', 'East', 'West', 'Green',
                                   'Farrell', 'Pinkerton', 'Derry', 'Vergennes', 'Silver',
                                   'Golden', 'Cavalier', 'Laurel', 'Connecticut', 'Columbia',
                                   'Hilltopper', 'Stirling', 'Silica', 'Norh', 'Yorkchester',
                                   'Ziegler', 'Crutch', 'Phyllis', 'Jaquar', 'Willakenzie',
                                   'Hard', 'Terry', 'Frankfort', 'Fews', 'Arapahoe',
                                   'Morrissey', 'Learning,', 'Monroe', 'Back', 'Cedar',
                                   'Ingram', 'Chestnut', 'Compton', 'Westminster', 'Hennepin',
                                   'Richley', 'Adams', 'Otterburn', 'Maverick', 'Level',
                                   'Pear', 'Rose', 'Medford', 'Summit', 'Swanwick',
                                   'Munchach', 'Miles', 'Plum', 'Misty', 'Ward',
                                   'Goodridge', 'Matthews', 'White', 'Olympian', 'Panorama',
                                   'Law', 'Lindsey', 'Barnes', 'Dunlap', 'Husky',
                                   'Pomona', 'Royal', 'Jacquard', 'Lunaliho', 'Cayuga',
                                   'Sugar', 'Kalanianaole', 'Ray', 'Monmouth', 'Tarrar',
                                   'Pettis', 'All', 'Genoa', 'Oakwood', 'Cabot',
                                   'Basse', 'Southridge', 'Shorehaven', 'Burcham', 'McCrimmon',
                                   'Keaau-Pahoa', 'Legion', 'Santa', 'Olinda', 'Waterhouse',
                                   'Goddard', 'Haygood', 'Maynard', 'East-West', 'Seeger');
    vstreet_names2 varray := varray('Ridge', 'Valley', 'Creek', 'Forest', 'Mill',
                                   'Ferry', 'River', 'Mountain', 'Hill', 'Woods',
                                   'Butternut', 'Kennedy', 'Loyalsock', 'Tusculum', 'Via',
                                   'Franconia', 'Fieldston', 'Grand', 'Perimeter', 'Nortus',
                                   'Westheimer', 'Yosemite', 'Slaughter', 'Hillyer', 'Points',
                                   'Hawkins', 'Smoky', 'Stabler', 'Cottonville', 'Lakota',
                                   'London', 'Georgetown', 'Mulberry', 'Avon', 'Grindstone',
                                   'Hornet', 'Jagerson', 'Aviation', 'Lamm', 'Hocking',
                                   'Uvalde', 'Appleyard', 'Nox', 'Bowman', 'Walzem',
                                   'Warrendale', 'Senecca', 'Perryville', 'Galloway', 'Clarke',
                                   'Admore', 'Walker', 'Peace', 'Southwest', 'Gifford',
                                   'Underwood', 'Thorne', 'Stanley', 'Harlin', 'Bryan',
                                   'Ferndale', 'Schubert', 'Lafayette', 'Vista', 'Voices',
                                   'Ohio', 'Shroyer', 'Telegraph', 'Higby', 'Hunsberger',
                                   'Middlebelt', 'Weymouth', 'Mapleton', 'Hollingsworth', 'Copeland',
                                   'Francis', 'Saulino', 'Hawthorne', 'Northeast', 'International',
                                   'Kamehameha', 'Huebner', 'Edgemere', 'Gorsuch', 'Chasepeak',
                                   'Rockfish', 'Riley', 'Elk', 'Ainsworth', 'Silo',
                                   'Aurora', 'Farmdale', 'Monte', 'Porter', 'Horsham',
                                   'Warfath', 'Widefield', 'Hillsmere', 'Crozier', 'Proffett');
    vstreet_names3 varray := varray('Street', 'Avenue', 'Court', 'Highway', 'Lane',
                                   'Parkway', 'Circle', 'Road', 'Boulevard', 'Crossing',
                                   'S.W.', 'Rdg.', 'Ne', 'Alley', 'HS',
                                   'S.E.', 'Dr', 'Bldg', 'Section', 'Walk',
                                   'Promenade', 'Northeast', 'Commune', 'Complex', 'Essex',
                                   'Trail', 'Terrace', 'Hwy', 'Route', 'Development',
                                   'Drive', 'Studios', 'Annex', 'Commission', 'Spur',
                                   'Academies', 'Yard', 'Preserve', 'South', 'Ministry',
                                   'Ulica', 'Strada', 'Rue', 'Straat', 'Carrer',
                                   'Calle', 'Gata', 'Ulice', 'Route', 'Estrada',
                                   'Via', 'Tee', 'Jalan', 'Building', 'Floor',
                                   'House', 'Assembly', 'Rd');
    vemail1        varray := varray('Big', 'Little', 'Happy', 'Red', 'Green',
                            'Top', 'Silver', 'Golden', 'Deep', 'Wide',
                            'Wig.', 'Smile.', 'Fig.', 'Yellow.', 'Orange.',
                            'Bottom.', 'Train.', 'Dog.', 'Merry.', 'Hope.',
                            'Ja', 'Nein', 'Danke', 'Vielen', 'Dank',
                            'Guten', 'Tag', 'Gute', 'Wie', 'Nacht',
                            'smanning.', 'cosima.', 'hendrix.', 'rduncan.', 'magchan.',
                            'insight.', 'swan.', 'chicken.', 'delphine.', 'monkey.',
                            'The.', 'yoyo', 'lorax', 'Yo.', 'Milo.',
                            'Fanta.', 'Vamp.', 'Sir.', 'Hairy.', 'Vanilla.',
                            'oui', 'vous', 'merci', 'voici', 'bonne',
                            'nuit', 'pas', 'sais', 'pouvez', 'voudrais',
                            'silver', 'zeus', 'mint', 'opt', 'clear',
                            'oiy', 'puppy', 'soap', 'canny', 'savvy',
                            'buenos', 'dias', 'noches', 'mucho', 'gusto',
                            'hasta', 'adios', 'luego', 'siento', 'por',
                            'bus.', 'love.', 'open.', 'violin.', 'boxer.',
                            'mud.', 'steward.', 'paws.', 'fingers.', 'snake.',
                            'Grazie', 'Prego.', 'Salve', 'Ciao.', 'Addio',
                            'Buona.', 'Parla', 'Cosi.', 'Pepe', 'Manzo.');
    vemail2        varray := varray('Cars', 'Bells', 'Tiger', 'Dog', 'Cat',
                            'Mountain', 'Tree', 'Key', 'Feather', 'Road',
                            'swim', 'foot', 'door', 'tennis', 'mop',
                            'quiche', 'onion', 'circle', 'deco', 'clay',
                            'Biz', 'Chocolate', 'Sunshine', 'Bead', 'Gamer',
                            'Shy', 'One', 'Apple', 'Whale', 'Rose',
                            'leda', 'castor', 'cloneclub', 'agricola', 'drmoreau',
                            'orphan', 'black', 'bchild', 'dyad', 'art',
                            'bis', 'muto', 'adepto', 'mora', 'aptus',
                            'barba', 'colo', 'decorus', 'mox', 'levo',
                            'hunc', 'Tendo', 'gravo', 'Rumor', 'Solus',
                            'Sane', 'Tamen', 'Levis', 'lam', 'hodiernus',
                            'Sinistra', 'Destra', 'Lontano', 'Vincino', 'Lungo',
                            'Corto', 'Breve', 'Museo', 'Banca', 'Negozio',
                            'Scuola', 'Chiesa', 'Valle', 'Collina', 'Picco',
                            'Monte', 'Lago', 'Fiume', 'Piscina', 'Torre',
                            'Ponte', 'febbraio', 'oggi', 'leri', 'compleanno',
                            'maggio', 'estate', 'duco', 'cerno', 'dexter',
                            'Pipeline', 'Doster', 'Club', 'Tribe', 'Clan',
                            'Ski', 'West', 'East', 'South', 'North');
    vemail3        varray := varray('Pacific.com', 'Caribbean.com', 'Indian.net', 'Bering.net', 'Arabian.com',
                            'Tasman.com', 'Barents.com', 'Antarctic.com', 'Mediterranean.com', 'Atlantic.com',
                            'countermail.com', 'neomailbox.com', 'runbox.net', 'safemail.net', 'vmail.com',
                            'mutemail.com', 'crypto.com', 'sestra.com', 'rediff.com', 'zoho.com',
                            'moonshine.com', 'copperhead.com', 'starfeet.net', 'fonstuff.net', 'reference.com',
                            'ncs.com', 'hostit.com', 'baggins.com', 'augustus.com', 'zebra.com',
                            'bluelight.com', 'adelphia.com', 'prodigy.net', 'netzero.net', 'juno.com',
                            'toucan.com', 'flash.com', 'mindspring.com', 'brutus.com', 'celtic.com',
                            'starmail.com', 'mailbox.com', 'batbox.net', 'speedymail.net', 'xyzmail.com',
                            'sunshinel.com', 'heaven.com', 'brosestra.com', 'bluedriff.com', 'whoho.com',
                            'siu.edu', 'sife.org', 'isdls.org', 'ri.org', 'sprintmail.com',
                            'gmail.com', 'worldboston.org', 'ihrco.com', 'ajshotels.com', 'hilton.com',
                            'knology.net', 'theinter.com', 'aloha.com', 'ihclt.org', 'radisson.com',
                            'phelpsstokes.org', 'jsums.edu', 'adnc.com', 'onondagacoach.com', 'twinlimo.com',
                            'infionline.net', 'eurocentres.com', 'Grandecom.net', 'understandourworld.org', 'ivcdetroit.org',
                            'aviahotels.com', 'cdsintl.org', 'quincysuites.com', 'aaionline.org', 'indigoinn.com',
                            'hitlon.com', 'wyndham.com', 'agreatwaytogo.com', 'northstate.net', 'kdsi.net',
                            'sheratonkc.com', 'innisfree.com', 'hotmail.com', 'miusa.org', 'aiesecus.org',
                            'bc.edu', 'irex.org', 'jalc.org', 'usicomos.org', 'bu.edu',
                            'internationalsport.com', 'kennesaw.edu', 'wtci.org', 'umn.edu', 'yahoo.co.uk');
    v_product_name varray := varray('Kia Forte', 'Chery A5', 'Suzuki Celerio', 'Lykan HyperSport', 'Ferrari 488',
                                   'Toyota Land Cruiser Prado', 'Mercedes-Benz SLK-Class', 'Mercedes-Benz SL-Class (R231)', 'Lexus LFA',
                                   'Honda Brio',
                                   'Ford Taurus (sixth generation)', 'McLaren P1', 'Volkswagen Jetta Pionier', 'Suzuki Lapin', 'Ascari KZ1',
                                   'Mitsubishi Mirage', 'Infiniti M', 'Volvo XC90', 'Honda N-One', 'Opel Adam',
                                   'Lada Riva', 'koda Rapid (2011)', 'Renault Espace', 'Nissan NV (North America)', 'BMW X5',
                                   'BMW 2 Series (F22)', 'Nissan Armada', 'Daihatsu Sigra', 'Nissan Qashqai', 'BMW 5 Series Gran Turismo',
                                   'Hyundai ix20', 'Hyundai Veracruz', 'Opel Mokka', 'Jeep Compass', 'Porsche 991',
                                   'Volkswagen Atlas', 'Volkswagen Scirocco', 'Daewoo Lacetti', 'Buick Park Avenue', 'Smart Forfour',
                                   'Honda Clarity', 'Lancia Ypsilon', 'Bentley Continental Flying Spur (2005)', 'Range Rover Sport', 'Cadillac DTS',
                                   'Alfa Romeo GT', 'Fiat Grande Punto', 'Toyota Allion', 'Audi Q7', 'Ferrari California',
                                   'Lexus CT', 'Toyota 86', 'BMW M4', 'Honda S660', 'Chevrolet Captiva',
                                   'Peugeot 5008', 'Mercedes-Benz GLA-Class', 'Alfa Romeo Stelvio', 'Renault Clio', 'Mahindra Quanto',
                                   'Renault Laguna', 'Audi Q3', 'Acura RDX', 'Infiniti QX80', 'Suzuki Ignis',
                                   'Pontiac Solstice', 'Honda BR-V', 'BYD e6', 'Tata Indigo', 'Great Wall Voleex C30',
                                   'Renault Fluence Z.E.', 'Mazdaspeed3', 'SsangYong Musso', 'Toyota Aygo', 'Chevrolet Cobalt',
                                   'Lada Granta', 'Renault Koleos', 'Volvo S40', 'Mercedes-Maybach 6', 'Tata Aria',
                                   'Cadillac CTS', 'Ford Fusion (Americas)', 'SEAT Altea', 'Vehicle Production Group', 'Lotus Evora',
                                   'Audi A3', 'Perodua Bezza', 'Saturn Vue', 'Volkswagen Touareg', 'Volkswagen Jetta',
                                   'Land Rover Discovery Sport', 'Chevrolet Volt (second generation)', 'Ford EcoSport', 'Toyota Belta',
                                   'Jaguar F-Pace',
                                   'Geely CK', 'Lotus Elise');
    v_prsn_name    varray := varray('Aaronson', 'Abra', 'Absa', 'Abshier', 'Adaiha',
                                'Adama', 'Adams', 'Addi', 'Addia', 'Adebayo',
                                'Adelaida', 'Adey', 'Adriaens', 'Adrian', 'Adrianna',
                                'Adriene', 'Aguste', 'Aia', 'Airlie', 'Alair',
                                'Albin', 'Alburga', 'Aldercy', 'Alek', 'Alessandra',
                                'Aleta', 'Alfi', 'Algy', 'Alis', 'Alitta',
                                'Allcot', 'Alodie', 'Alpheus', 'Alrick', 'Alvie',
                                'Alysa', 'Alyson', 'Alysoun', 'Amadeus', 'Amand',
                                'Amaris', 'Amati', 'Amend', 'Amick', 'Amity',
                                'An', 'Ananna', 'Anastase', 'Anastasius', 'Ancelin',
                                'Andrea', 'Anissa', 'Anjali', 'Anna-Diana', 'Annecorinne',
                                'Anurag', 'Any', 'Anya', 'Aphra', 'Aprilette',
                                'Ardeth', 'Areta', 'Arezzini', 'Argile', 'Arissa',
                                'Armbruster', 'Arni', 'Arratoon', 'Artemus', 'Asare',
                                'Ashlen', 'Ashli', 'Asia', 'Askari', 'Astra',
                                'Aubert', 'Auburta', 'Aubyn', 'Aurel', 'Azaria',
                                'Badger', 'Baggett', 'Bailie', 'Ban', 'Baptista',
                                'Barber', 'Barfuss', 'Barkley', 'Barnes', 'Barnet',
                                'Barrie', 'Basilio', 'Bass', 'Baxie', 'Bayer',
                                'Beau', 'Beaudoin', 'Beaulieu', 'Bebe', 'Beghtol',
                                'Beichner', 'Beilul', 'Belcher', 'Bellda', 'Benzel',
                                'Bergren', 'Berkow', 'Bertelli', 'Bertilla', 'Beryle',
                                'Bess', 'Bessy', 'Binah', 'Bing', 'Birecree',
                                'Birkner', 'Bishop', 'Blinnie', 'Block', 'Blondell',
                                'Bluhm', 'Blumenthal', 'Blythe', 'Boar', 'Boffa',
                                'Bolger', 'Bolton', 'Bondy', 'Boonie', 'Bopp',
                                'Borras', 'Bortz', 'Bouchier', 'Bourn', 'Bovill',
                                'Bowlds', 'Bowyer', 'Boyden', 'Bracci', 'Bradwell',
                                'Brady', 'Branch', 'Branden', 'Brandon', 'Brasca',
                                'Brebner', 'Brew', 'Brig', 'Brigida', 'Broder',
                                'Buck', 'Buckingham', 'Buehrer', 'Burkhardt', 'Burra',
                                'Buseck', 'Bushey', 'Button', 'Byrne', 'Bywaters',
                                'Calabresi', 'Call', 'Camel', 'Camila', 'Campman',
                                'Caniff', 'Cannell', 'Carder', 'Carita', 'Carry',
                                'Case', 'Casimir', 'Cassandry', 'Cassy', 'Castillo',
                                'Castro', 'Catherin', 'Cathrin', 'Chambers', 'Chandler',
                                'Chappy', 'Charie', 'Charlotte', 'Chellman', 'Cherise',
                                'Cheshire', 'Chiaki', 'Chisholm', 'Chrisman', 'Christean',
                                'Christian', 'Christiane', 'Christis', 'Chrotoem', 'Chrystel',
                                'Ciapas', 'Cicero', 'Cindie', 'Cinnamon', 'Ciro',
                                'Claiborn', 'Clarisa', 'Clarita', 'Clayborn', 'Clayborne',
                                'Cleopatra', 'Cocks', 'Cohberg', 'Cohl', 'Cointon',
                                'Colb', 'Coltun', 'Concha', 'Coniah', 'Conlan',
                                'Constance', 'Corabel', 'Cordelia', 'Cormick', 'Cornell',
                                'Cornie', 'Corny', 'Corotto', 'Cosma', 'Craner',
                                'Crary', 'Creath', 'Crellen', 'Crispin', 'Cristabel',
                                'Croteau', 'Cruce', 'Crysta', 'Curran', 'Cybill',
                                'Cyndy', 'Dabney', 'Daffodil', 'Damek', 'Danica',
                                'Danni', 'Daphna', 'Darcey', 'Darrick', 'Darton',
                                'Daveen', 'Davie', 'Ddene', 'Debbie', 'Deborah',
                                'Delaney', 'Delwin', 'Demetris', 'Demitria', 'Dempsey',
                                'Denman', 'Deppy', 'Deragon', 'Derk', 'Derna',
                                'Derwood', 'Desirae', 'Dewain', 'Dewhurst', 'Diantha',
                                'Dincolo', 'Dionne', 'Dodwell', 'Dogs', 'Dolf',
                                'Donnenfeld', 'Doscher', 'Dott', 'Dotti', 'Dougherty',
                                'Doughman', 'Dragelin', 'Drolet', 'Drusus', 'Dukey',
                                'Durst', 'Dusen', 'Eade', 'Eckel', 'Edwyna',
                                'Eidson', 'Eiger', 'Eisler', 'Eldwon', 'Eleanore',
                                'Elfrida', 'Eliath', 'Elihu', 'Elliot', 'Elsy',
                                'Elvia', 'Em', 'Emilia', 'Emmott', 'Eolande',
                                'Er', 'Erhard', 'Erie', 'Errick', 'Erroll',
                                'Ervin', 'Eshelman', 'Etti', 'Eustatius', 'Evan',
                                'Everard', 'Ez', 'Fachini', 'Fagen', 'Fagin',
                                'Fahland', 'Fanechka', 'Fanya', 'Farica', 'Farika',
                                'Farlie', 'Fauman', 'Favata', 'Fayina', 'Featherstone',
                                'Feeley', 'Feingold', 'Fennell', 'Fennessy', 'Fernyak',
                                'Ferro', 'Fiann', 'Fidelio', 'Fields', 'Fifine',
                                'Figone', 'Fillander', 'Fleming', 'Fontana', 'Forrest',
                                'Forsta', 'Francesca', 'Frasch', 'Frasier', 'Fredel',
                                'French', 'Fronia', 'Fronniah', 'Frost', 'Fryd',
                                'Furey', 'Gabe', 'Gabi', 'Gaddi', 'Galven',
                                'Gannie', 'Gapin', 'Gardy', 'Garey', 'Gargan',
                                'Geer', 'Geibel', 'Geldens', 'Genevieve', 'Genevra',
                                'Genisia', 'Geno', 'George', 'Georgeanne', 'Geraud',
                                'Gereld', 'Gerkman', 'Germann', 'Gerome', 'Gerrald',
                                'Gertrude', 'Gigi', 'Gilchrist', 'Gilmour', 'Ginevra',
                                'Gittle', 'Giusto', 'Glick', 'Gnni', 'Goddard',
                                'Golden', 'Goldsmith', 'Goldsworthy', 'Golightly', 'Gollin',
                                'Goody', 'Goran', 'Gould', 'Graehme', 'Grail',
                                'Grange', 'Grearson', 'Greenwood', 'Grenville', 'Grissom',
                                'Grounds', 'Gruber', 'Guevara', 'Guibert', 'Guild',
                                'Gulgee', 'Gunther', 'Gurevich', 'Gustavus', 'Gustie',
                                'Gypsy', 'Hachman', 'Haddad', 'Haff', 'Hakan',
                                'Haleigh', 'Hallett', 'Hallock', 'Hamann', 'Hamid',
                                'Hamlen', 'Hannibal', 'Hansen', 'Hanzelin', 'Hardin',
                                'Harley', 'Hartmunn', 'Harwill', 'Haughay', 'Haukom',
                                'Hecht', 'Hedelman', 'Hedgcock', 'Heidi', 'Heilner',
                                'Helve', 'Henri', 'Henriha', 'Henryetta', 'Hephzipah',
                                'Hermina', 'Herodias', 'Herrmann', 'Heti', 'Hett',
                                'Heyman', 'Hicks', 'Hindorff', 'Hirsh', 'Hitchcock',
                                'Hitoshi', 'Hluchy', 'Hock', 'Hogan', 'Hoi',
                                'Holden', 'Hollenbeck', 'Hollister', 'Honniball', 'Hooge',
                                'Hoopes', 'Horter', 'Horwitz', 'Houghton', 'Hourihan',
                                'Hugh', 'Huldah', 'Humph', 'Hung', 'Hussein',
                                'Hyrup', 'Iaria', 'Ibbie', 'Ibrahim', 'Idoux',
                                'Iiette', 'Ilke', 'Immanuel', 'Ingrim', 'Ireland',
                                'Isa', 'Isaiah', 'Island', 'Ivah', 'Ivanah',
                                'Jacqui', 'Jago', 'Jakob', 'Jamesy', 'Jamila',
                                'Jania', 'Jann', 'Jasisa', 'Jayson', 'Jecoa',
                                'Jeconiah', 'Jehiah', 'Jemie', 'Jenne', 'Jennine',
                                'Jerrome', 'Jo', 'Joe', 'Joerg', 'Jone',
                                'Jordain', 'Jordanna', 'Josey', 'Joyann', 'Joye',
                                'Jueta', 'Juliann', 'Julieta', 'Junina', 'Kal',
                                'Kamp', 'Karina', 'Karlin', 'Karp', 'Kauslick',
                                'Kawai', 'Kellina', 'Kendyl', 'Kentigerma', 'Kenway',
                                'Kerge', 'Keverian', 'Khichabia', 'Khoury', 'Kikelia',
                                'Killarney', 'Kimitri', 'Kimmi', 'Kirchner', 'Kirst',
                                'Kirstyn', 'Kirwin', 'Kleiman', 'Kloster', 'Kneeland',
                                'Koffler', 'Koser', 'Krasner', 'Krasnoff', 'Kraul',
                                'Kroll', 'Kruse', 'Krystin', 'Kunin', 'Kylila',
                                'La Verne', 'Lacombe', 'Lais', 'Lambard', 'Lamont',
                                'Landa', 'Lanford', 'Lanita', 'Lanta', 'Lattonia',
                                'Launcelot', 'Laurens', 'Leahey', 'Lemar', 'Lenna',
                                'Lesslie', 'Leverick', 'Levesque', 'Levison', 'Leyla',
                                'Libna', 'Lilli', 'Lillian', 'Lily', 'Lindeberg',
                                'Lindholm', 'Lindi', 'Lindsey', 'Ling', 'Link',
                                'Linkoski', 'Lipfert', 'Lisetta', 'Lisette', 'Lissak',
                                'Liz', 'Lombard', 'Lopes', 'Lorant', 'Lorenz',
                                'Losse', 'Lovato', 'Lovell', 'Lovett', 'Lowson',
                                'Lucius', 'Lunetta', 'Lussier', 'Lyris', 'Lyudmila',
                                'Macario', 'MacIntosh', 'MacLean', 'Madelyn', 'Madonia',
                                'Magavern', 'Magda', 'Maison', 'Maje', 'Malamut',
                                'Mallen', 'Mandal', 'Manlove', 'Manning', 'Margit',
                                'Margreta', 'Mariande', 'Marie-Jeanne', 'Mariquilla', 'Marissa',
                                'Marks', 'Marozik', 'Marr', 'Martell', 'Martina',
                                'Massingill', 'Mastrianni', 'Mathias', 'Mathilda', 'Matilde',
                                'Maupin', 'Maurreen', 'Mayberry', 'McAllister', 'McDonald',
                                'McNair', 'Meek', 'Meggs', 'Mehetabel', 'Mel',
                                'Melan', 'Melisandra', 'Melvyn', 'Menashem', 'Mera',
                                'Meraree', 'Metzgar', 'Michell', 'Mickey', 'Middendorf',
                                'Miett', 'Migeon', 'Mikael', 'Milena', 'Milinda',
                                'Milla', 'Millman', 'Mingche', 'Mireille', 'Mirisola',
                                'Missy', 'Mitzi', 'Mogerly', 'Mohandas', 'Monty',
                                'Morna', 'Morocco', 'Morton', 'Moskow', 'Mott',
                                'Mount', 'Mowbray', 'Mueller', 'Mychal', 'Myo',
                                'Myriam', 'Myrt', 'Na', 'Naara', 'Nadab',
                                'Nadaba', 'Nadeau', 'Naima', 'Nally', 'Nancee',
                                'Nanni', 'Naples', 'Natalie', 'Nate', 'Nathanial',
                                'Nea', 'Neff', 'Nelda', 'Neom', 'Nesline',
                                'Nessy', 'Nesto', 'Nevada', 'Nevil', 'Newhall',
                                'Nichy', 'Nickey', 'Nickolas', 'Nicole', 'Niki',
                                'Nino', 'Noble', 'Noreen', 'Norri', 'Nova',
                                'Nunciata', 'Oak', 'Odeen', 'Odrick', 'Ody',
                                'Odysseus', 'Oira', 'Ola', 'Olfe', 'Olimpia',
                                'Omer', 'Oneal', 'Oneil', 'Orland', 'Orvie',
                                'Osbourn', 'Pacien', 'Pages', 'Palmira', 'Panther',
                                'Papke', 'Pappas', 'Parcel', 'Paris', 'Parris',
                                'Patrica', 'Paulie', 'Pauly', 'Pedaiah', 'Peer',
                                'Peterus', 'Phaidra', 'Pilar', 'Pillsbury', 'Pine',
                                'Pomeroy', 'Poock', 'Poole', 'Powder', 'Powel',
                                'Priscilla', 'Prisilla', 'Profant', 'Pru', 'Publia',
                                'Pugh', 'Purdum', 'Purse', 'Quirita', 'Radack',
                                'Raddatz', 'Rai', 'Raimondo', 'Rajewski', 'Raji',
                                'Rame', 'Randolf', 'Ransome', 'Rapp', 'Raquel',
                                'Rasia', 'Rawlinson', 'Razid', 'Reade', 'Rebel',
                                'Reddy', 'Redmund', 'Reider', 'Reilly', 'Reina',
                                'Relly', 'Rento', 'Reseda', 'Reviel', 'Rex',
                                'Rexana', 'Rhine', 'Rhodes', 'Richard', 'Rickey',
                                'Rind', 'Rivi', 'Roanna', 'Robbin', 'Roberts',
                                'Rodie', 'Rodman', 'Roehm', 'Romalda', 'Romney',
                                'Ronalda', 'Roper', 'Rosabelle', 'Rosanne', 'Roseanna',
                                'Ross', 'Rriocard', 'Rudiger', 'Rudman', 'Rumilly',
                                'Ruttger', 'Ryan', 'Rye', 'Sackville', 'Safko',
                                'Saint', 'Salot', 'Samanthia', 'Sampson', 'Sanburn',
                                'Sander', 'Sandie', 'Sandy', 'Saree', 'Sashenka',
                                'Sass', 'Saum', 'Saunderson', 'Scarrow', 'Schaffel',
                                'Schaper', 'Schargel', 'Scherle', 'Schiffman', 'Schmeltzer',
                                'Scholz', 'Scornik', 'Scotney', 'Scrope', 'Seaden',
                                'Seafowl', 'Seaton', 'Sedberry', 'Sefton', 'Sergo',
                                'Serra', 'Seta', 'Shaina', 'Shanda', 'Sharai',
                                'Shawnee', 'Shenan', 'Sheree', 'Sherlock', 'Shetrit',
                                'Shewchuk', 'Shira', 'Shoshanna', 'Shotton', 'Sidran',
                                'Siloa', 'Silvanus', 'Silvie', 'Sim', 'Simone',
                                'Sion', 'Skantze', 'Skees', 'Skilken', 'Skylar',
                                'Slavic', 'Sloane', 'Slocum', 'Smail', 'Small',
                                'Smoot', 'Sollows', 'Sonnnie', 'Sophi', 'Spurgeon',
                                'Squier', 'Stamata', 'Stanhope', 'Stanway', 'Steffi',
                                'Stent', 'Steven', 'Stolzer', 'Strickler', 'Stronski',
                                'Studley', 'Sumer', 'Sung', 'Sven', 'Swagerty',
                                'Sylvia', 'Talbert', 'Tallbot', 'Tallulah', 'Tandy',
                                'Tannie', 'Tarr', 'Tarrel', 'Terrill', 'Terti',
                                'Tewfik', 'Thadeus', 'Thalassa', 'Thanos', 'Theadora',
                                'Theola', 'Theresa', 'Therine', 'Thilda', 'Thill',
                                'Thirion', 'Thorwald', 'Thurmann', 'Tibbetts', 'Tien',
                                'Tiffi', 'Tolmann', 'Tomlinson', 'Tonneson', 'Torrance',
                                'Torrence', 'Trask', 'Tremaine', 'Trip', 'Trish',
                                'Tristram', 'Trojan', 'Truitt', 'Tseng', 'Tulley',
                                'Turrell', 'Tut', 'Tutto', 'Uela', 'Ulphiah',
                                'Uriisa', 'Uttasta', 'Valaree', 'Valentin', 'Valley',
                                'Vano', 'Vargas', 'Vashti', 'Vasos', 'Veneaux',
                                'Vento', 'Verada', 'Verina', 'Verlie', 'Vick',
                                'Victoria', 'Vig', 'Vigen', 'Vins', 'Viola',
                                'Virnelli', 'Vitek', 'Volny', 'Vories', 'Waers',
                                'Waldner', 'Waller', 'Walrath', 'Wedurn', 'Weibel',
                                'Weidar', 'Weide', 'Wein', 'Wertheimer', 'Whallon',
                                'Whyte', 'Wie', 'Wier', 'Wiggins', 'Willabella',
                                'Willner', 'Win', 'Wina', 'Wing', 'Winston',
                                'Winwaloe', 'Witcher', 'Woodley', 'Woodman', 'Wrand',
                                'Wrennie', 'Wystand', 'Yelich', 'Yurik', 'Yves',
                                'Zamora', 'Zebapda', 'Zeiler', 'Zellner', 'Zucker');

    FUNCTION random_number (
        min_in NUMBER,
        max_in NUMBER
    ) RETURN NUMBER AS
    BEGIN
        RETURN floor(dbms_random.value(min_in, max_in));
    END random_number;

    FUNCTION product RETURN VARCHAR2 AS
    BEGIN
        RETURN v_product_name(floor(dbms_random.value(1, 100)));
    END;

    FUNCTION prsn_name RETURN VARCHAR2 AS
    BEGIN
        RETURN v_prsn_name(floor(dbms_random.value(1, 1000)));
    END;

    FUNCTION gender RETURN VARCHAR2 AS
    BEGIN
        RETURN vgender_names(floor(dbms_random.value(1, 5)));
    END;

    FUNCTION email RETURN VARCHAR2 AS
    BEGIN
        RETURN vemail1(floor(dbms_random.value(1, 101)))
               || vemail2(floor(dbms_random.value(1, 101)))
               || '@'
               || vemail3(floor(dbms_random.value(1, 101)));
    END;

    FUNCTION get_adrs_line1 RETURN VARCHAR2 AS
    BEGIN
        RETURN random_number(1, 499)
               || ' '
               || vstreet_names1(floor(dbms_random.value(1, vstreet_names1.count)))
               || ' '
               || vstreet_names2(floor(dbms_random.value(1, vstreet_names2.count)))
               || ' '
               || vstreet_names3(floor(dbms_random.value(1, vstreet_names3.count)));
    END;

    FUNCTION get_random_city RETURN VARCHAR2 AS
        v_idx NUMBER(4);
    BEGIN
        v_idx := floor(dbms_random.value(1, vcity_names.count));
        RETURN vcity_names(v_idx);
    END;

    FUNCTION get_random_state RETURN VARCHAR2 AS
        v_idx NUMBER(4);
    BEGIN
        v_idx := floor(dbms_random.value(1, vstates_names.count));
        RETURN vstates_names(v_idx);
    END;

    FUNCTION phone RETURN VARCHAR2 AS
    BEGIN
        RETURN '('
               || floor(dbms_random.value(100, 999))
               || ') '
               || floor(dbms_random.value(100, 999))
               || '-'
               || floor(dbms_random.value(1000, 9999));
    END;

    FUNCTION bdate RETURN DATE AS
    BEGIN
        RETURN trunc(sysdate - floor(dbms_random.value(7300, 25550)));  -- Between 20 and 70 yrs ago
    END;

    FUNCTION get_random_customer RETURN customer%rowtype AS
        v_customer_row customer%rowtype;
    BEGIN
        SELECT
            *
        INTO v_customer_row
        FROM
            (
                SELECT
                    *
                FROM
                    customer
                ORDER BY
                    dbms_random.random
            )
        WHERE
            ROWNUM < 2;

        RETURN v_customer_row;
    END;

    FUNCTION get_random_order RETURN orders%rowtype AS
        v_orders_row orders%rowtype;
    BEGIN
        SELECT
            *
        INTO v_orders_row
        FROM
            (
                SELECT
                    *
                FROM
                    orders
                ORDER BY
                    dbms_random.random
            )
        WHERE
            ROWNUM < 2;

        RETURN v_orders_row;
    END;

    FUNCTION get_random_gender RETURN VARCHAR2 AS
        v_gender_id VARCHAR2(32);
    BEGIN
        SELECT
            gender_id
        INTO v_gender_id
        FROM
            (
                SELECT
                    *
                FROM
                    gender
                ORDER BY
                    dbms_random.random
            )
        WHERE
            ROWNUM < 2;

        RETURN v_gender_id;
    END;

    FUNCTION ins_orders (
        orders_date_in        DATE,
        orders_customer_id_in VARCHAR2
    ) RETURN VARCHAR2 AS
        v_key VARCHAR2(32);
    BEGIN
        INSERT INTO orders (
            orders_id,
            orders_date,
            orders_customer_id
        ) VALUES (
            sys_guid(),
            orders_date_in,
            orders_customer_id_in
        ) RETURN orders_id INTO v_key;

        RETURN v_key;
    END ins_orders;

    FUNCTION ins_address (
        address_line1_in VARCHAR2,
        address_city_in  VARCHAR2,
        address_state_in VARCHAR2,
        address_zip_in   VARCHAR2
    ) RETURN VARCHAR2 AS
        v_key VARCHAR2(32);
    BEGIN
        INSERT INTO address (
            address_line1,
            address_city,
            address_state,
            address_zip
        ) VALUES (
            address_line1_in,
            address_city_in,
            address_state_in,
            address_zip_in
        ) RETURNING address_id INTO v_key;

        RETURN v_key;
    END;

    FUNCTION ins_customer (
        customer_first_name_in    VARCHAR2,
        customer_middle_name_in   VARCHAR2,
        customer_last_name_in     VARCHAR2,
        customer_date_of_birth_in DATE,
        customer_gender_id_in     VARCHAR2
    ) RETURN VARCHAR2 AS
        v_key VARCHAR2(32);
    BEGIN
        INSERT INTO customer (
            customer_first_name,
            customer_middle_name,
            customer_last_name,
            customer_date_of_birth,
            customer_gender_id
        ) VALUES (
            customer_first_name_in,
            customer_middle_name_in,
            customer_last_name_in,
            customer_date_of_birth_in,
            customer_gender_id_in
        ) RETURNING customer_id INTO v_key;

        RETURN v_key;
    END;

    PROCEDURE load_gender AS
        v_cnt NUMBER(1);
    BEGIN
        FOR idx IN 1..vgender_names.count LOOP
            SELECT
                COUNT(*)
            INTO v_cnt
            FROM
                gender
            WHERE
                gender_name = vgender_names(idx);

            IF v_cnt = 0 THEN
                NULL;
                INSERT INTO gender ( gender_name ) VALUES ( vgender_names(idx) );

            END IF;

        END LOOP;
    END load_gender;

    PROCEDURE create_addresses (
        nbr_adrs_in NUMBER
    ) AS
        v_address_id VARCHAR2(38);
    BEGIN
        FOR idx IN 1..nbr_adrs_in LOOP
            NULL;
            v_address_id := ins_address(get_adrs_line1(), get_random_city(), get_random_state(), to_char(random_number(1, 99999), '00000'));

        END LOOP;
    END create_addresses;

    PROCEDURE create_customers (
        nbr_cust_in NUMBER
    ) AS

        v_adrs_cnt    NUMBER(2);
        v_customer_id VARCHAR2(32);
        v_address_id  VARCHAR2(32);
        v_dflt_ind    NUMBER(1);
    BEGIN
        --  Ensure all the possible genders are loaded.
        load_gender();
        FOR idx IN 1..nbr_cust_in LOOP
            v_customer_id := ins_customer(prsn_name(), prsn_name(), prsn_name(), bdate(), get_random_gender());
        END LOOP;

    END create_customers;

    PROCEDURE create_orders (
        nbr_cust_in NUMBER
    ) AS
        v_customer_rec customer%rowtype;
        v_orders_id    VARCHAR2(32);
    BEGIN
        FOR idx IN 1..nbr_cust_in LOOP
            v_customer_rec := get_random_customer();
            v_orders_id := ins_orders(sysdate, v_customer_rec.customer_id);
        END LOOP;
    END create_orders;

    PROCEDURE advance_random_orders (
        nbr_order_in NUMBER
    ) AS
        v_orders_rec orders%rowtype;
    BEGIN
        FOR idx IN 1..nbr_order_in LOOP
            v_orders_rec := get_random_order();
            pkg_order.advance_order_status(v_orders_rec.orders_id, sysdate);
        END LOOP;
    END advance_random_orders;

    PROCEDURE create_product_status AS
    BEGIN
        INSERT INTO product_status ( product_status_desc ) VALUES ( 'Active' );

        INSERT INTO product_status ( product_status_desc ) VALUES ( 'Inactive' );

    END;

END pkg_data;
/

BEGIN
    dbms_utility.compile_schema(schema => user, compile_all => true, reuse_settings => true);
END;
/

DECLARE
  NBR_ORDER_IN NUMBER;
BEGIN
  NBR_ORDER_IN := 120;

  PKG_DATA.ADVANCE_RANDOM_ORDERS(
    NBR_ORDER_IN => NBR_ORDER_IN
  );

  PKG_DATA.CREATE_ADDRESSES(NBR_ORDER_IN);

  PKG_DATA.create_product_status();
END;


/
commit;
