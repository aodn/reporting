﻿SET SEARCH_PATH = parameters_mapping; 

DROP TABLE IF EXISTS parameters CASCADE;
DROP TABLE IF EXISTS parameters_mapping CASCADE;
DROP TABLE IF EXISTS qc_flags CASCADE;
DROP TABLE IF EXISTS qc_scheme CASCADE;

CREATE TABLE parameters
(
  unique_id integer NOT NULL,
  cf_standard_name character varying(255),
  cf_alias_name character varying(255),
  long_name character varying(255),
  imos_vocabulary_name character varying(255),
  imos_vocabulary_id character varying(5),
  CONSTRAINT parameters_pkey2 PRIMARY KEY (unique_id)
);

CREATE TABLE parameters_mapping
( facility character varying(10),
  subfacility character varying(50),
  product character varying(50),
  variable_name character varying(50) NOT NULL,
  parameter_id integer,
  unit_id integer,
  unit_info character varying(255),
  qc_scheme_id integer,
  CONSTRAINT parameters_mapping_pkey PRIMARY KEY (facility, subfacility, product, variable_name)
);

CREATE TABLE qc_scheme
(
  qc_scheme_id integer NOT NULL,
  qc_scheme_short_name character varying(50),
  qc_scheme_definition character varying(255),
  CONSTRAINT qc_scheme_pkey PRIMARY KEY (qc_scheme_id)
);

CREATE TABLE qc_flags
(
  id integer NOT NULL,
  qc_scheme_id integer,
  flag_value character varying(2),
  flag_meaning character varying(100),
  flag_description character varying(500),
  CONSTRAINT qc_flags_pkey PRIMARY KEY (id),
  CONSTRAINT qc_flags_fkey FOREIGN KEY (qc_scheme_id)
      REFERENCES qc_scheme (qc_scheme_id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO qc_scheme (qc_scheme_id,
  qc_scheme_short_name,
  qc_scheme_definition) 
 VALUES (1,'IMOS IODE','IMOS standard set using the IODE flags'),
(2,'Argo measurement flag scale','ARGO quality control procedure for measurements'),
(3,'Argo profile quality flags','ARGO quality control procedure for profiles'),
(4,'BOM','BOM (SST and Air-Sea flux) quality control procedure'),
(5,'WOCE QC flags','WOCE quality control flags (Multidisciplinary Underway Network - CO2 measurements)'),
(6,'WOCE QC subflags','WOCE QC subflags are used to provide more information if CO2 observations are flagged as questionable'),
(7,'Argos location classes','Argos locations are classified according to the type of location (Argos or GPS), the estimated error, and the number of messages received during the pass');

INSERT INTO qc_flags (id ,
  qc_scheme_id,
  flag_value,
  flag_meaning,
  flag_description) 
 VALUES (1,1,'0','No QC performed','The level at which all data enter the working archive. They have not yet been quality controlled'),
(2,1,'1','Good data','Top quality data in which no malfunctions have been identified and all real features have been verified during the quality control process'),
(3,1,'2','Probably good data','Good data in which some features (probably real) are present but these are unconfirmed. Code 2 data are also data in which minor malfunctions may be present but these errors are small and/or can be successfully corrected without seriously affecting the overall quality of the data. '),
(4,1,'3','Bad data that are potentially correctable','Suspect data in which unusual,, and probably erroneous features are observed '),
(5,1,'4','Bad data','Obviously erroneous values are observed '),
(6,1,'5','Value changed','Altered by a QC Centre,, with original values (before the change) preserved in the history record of the profile. eMII discourage the use of this flag. Where data values must be changed (e.g. smoothing of data sets) we strongly prefer that the original data be retained and an additional variable be added to accommodate the interpolated/corrected data values.'),
(7,1,'6','Not used','Flag 6 is reserved for future use '),
(8,1,'7','Not used','Flag 7 is reserved for future use '),
(9,1,'8','Interpolated value','Indicates that data values are interpolated '),
(10,1,'9','Missing value','Indicates that the element is missing '),
(11,2,'0','No QC performed',''),
(12,2,'1','Good data','The adjusted value is statiscally consistent and a statistical error estimate is supplied '),
(13,2,'2','Probably good data','Probably good data '),
(14,2,'3','Bad data that are potentially correctable','Argo QC tests (15,, 16 or 17,, see Carval et al 2008) failed and all other real- time QC tests passed. These data are not to be used without scientific correction. A flag 3 may be assigned by an operator during additional visual QC for bad data that may be corrected in delayed mode '),
(15,2,'4','Bad data','Data have failed one or more of the real-time QC tests,, excluding T est 16 (see Carval et al 2008). A flag 4 may be assigned by an operator during additional visual QC for bad data that are not correctable'),
(16,2,'5','Value changed',''),
(17,2,'6','Not used',''),
(18,2,'7','Not used',''),
(19,2,'8','Interpolated value',''),
(20,2,'9','Missing value',''),
(21,3,'','No QC performed',''),
(22,3,'A','N = 100%','All profile levels contain good data'),
(23,3,'B','75% <= N < 100% ',''),
(24,3,'C','50% <= N < 75% ',''),
(25,3,'D','25% <= N < 50% ',''),
(26,3,'E','0% <= N < 25% ',''),
(27,3,'F','N = 0%','No profile levels have good data '),
(28,4,'B','Value out of bounds ',''),
(29,4,'C','Time not sequential ',''),
(30,4,'D','Failed T > Tw > Td test (see Verein 2008) ','This test is not realised yet'),
(31,4,'E','Failed resultant wind recomputation test ','This test gets applied to SST data product'),
(32,4,'F','Platform velocity unrealistic ',''),
(33,4,'G','Value exceeds (climatological) threshold ',''),
(34,4,'H','Discontinuity in data ',''),
(35,4,'J','Erroneous value ',''),
(36,4,'K','Suspect value (visual) ',''),
(37,4,'L','Value located over land ',''),
(38,4,'M','Instrument malfunction ',''),
(39,4,'Q','Pre-flagged as suspect ',''),
(40,4,'S','Spike in data (visual) ',''),
(41,4,'T','Time duplicate ',''),
(42,4,'U','Suspect data (statistical) ',''),
(43,4,'V','Spike in data (statistical) ',''),
(44,4,'X','Step in data (statistical) ',''),
(45,4,'Z','Value passes all test ',''),
(46,5,'2','Good',''),
(47,5,'3','Questionable',''),
(48,5,'4','Bad',''),
(49,6,'1','Outside of standard range',''),
(50,6,'2','Questionable/interpolated SST (Sea Surface Temperature) ',''),
(51,6,'3','Questionable EQU temperature ',''),
(52,6,'4','Anomalous (EQU T-SST) (+- 1 C) ',''),
(53,6,'5','Questionable sea-surface salinity',''),
(54,6,'6','Questionable pressure',''),
(55,6,'7','Low EQU gas flow',''),
(56,6,'8','Questionable air value',''),
(57,6,'10','Other, water flow',''),
(58,7,'G','GPS location, estimated error < 100m',''),
(59,7,'3','Argos location, estimated error < 250m',''),
(60,7,'2','Argos location, 250m < estimated error < 500m',''),
(61,7,'1','Argos location, 500m < estimated error < 1500m',''),
(62,7,'0','Argos location, estimated error > 1500m',''),
(63,7,'A','Argos location, no accuracy estimation',''),
(64,7,'B','Argos location, no accuracy estimation',''),
(65,7,'Z','Argos location, invalid location','');

GRANT SELECT ON TABLE parameters_mapping.qc_flags TO harvest_read_group;
GRANT ALL ON TABLE parameters_mapping.qc_flags TO harvest_write_group;
GRANT ALL ON TABLE parameters_mapping.qc_flags TO harvest_parameters_mapping_write_group;
GRANT SELECT ON TABLE parameters_mapping.qc_flags TO backup;
GRANT SELECT ON TABLE parameters_mapping.parameters TO harvest_read_group;
GRANT ALL ON TABLE parameters_mapping.parameters TO harvest_write_group;
GRANT ALL ON TABLE parameters_mapping.parameters TO harvest_parameters_mapping_write_group;
GRANT SELECT ON TABLE parameters_mapping.parameters TO backup;
GRANT SELECT ON TABLE parameters_mapping.parameters_mapping TO harvest_read_group;
GRANT ALL ON TABLE parameters_mapping.parameters_mapping TO harvest_write_group;
GRANT ALL ON TABLE parameters_mapping.parameters_mapping TO harvest_parameters_mapping_write_group;
GRANT SELECT ON TABLE parameters_mapping.parameters_mapping TO backup;
GRANT SELECT ON TABLE parameters_mapping.qc_scheme TO harvest_read_group;
GRANT ALL ON TABLE parameters_mapping.qc_scheme TO harvest_write_group;
GRANT ALL ON TABLE parameters_mapping.qc_scheme TO harvest_parameters_mapping_write_group;
GRANT SELECT ON TABLE parameters_mapping.qc_scheme TO backup;