COPY parameters.parameters TO stdout WITH DELIMITER ',' CSV QUOTE AS '''' FORCE QUOTE cf_standard_name, cf_alias_name, long_name, imos_vocabulary_name ESCAPE AS ',';

SET SEARCH_PATH = parameters_mapping, public;
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
INSERT INTO parameters.parameters (unique_id,
  cf_standard_name,
  cf_alias_name,
  long_name,
  imos_vocabulary_name,
  imos_vocabulary_id) 
 VALUES (1,'air_temperature','','','Temperature of the atmosphere',78),
(2,'sea_water_electrical_conductivity','','','Electrical conductivity of the water body',381),
(3,'dew_point_temperature','','','Dew point temperature of the atmosphere',80),
(4,'latitude','','','Latitude north',85),
(5,'longitude','','','Longitude east',86),
(6,'platform_course','','','Direction of motion (over ground) of measurement platform',91),
(7,'platform_speed_wrt_ground','','','Speed (over ground) of measurement platform',93),
(8,'wind_from_direction','','','Wind from direction in the atmosphere',393),
(9,'wind_speed','','','Wind speed in the atmosphere',394),
(10,'air_pressure','','','Pressure (measured variable) exerted by the atmosphere',76),
(11,'wet_bulb_temperature','','','Wet bulb temperature of the atmosphere',392),
(12,'sea_water_salinity','','','Practical salinity of the water body',96),
(13,'sea_water_temperature','','','Temperature of the water body',98),
(14,'relative_humidity','','','Relative humidity of the atmosphere',95),
(15,'surface_downwelling_photosynthetic_radiative_flux_in_air','','','Downwelling vector irradiance as photons (PAR wavelengths) in the atmosphere',572),
(16,'','','platform relative wind direction','Wind direction (relative to moving platform) in the atmosphere',582),
(17,'','','platform relative wind speed','Wind speed (relative to moving platform) in the atmosphere',577),
(18,'','','GPS receiver altitude','','')




COPY qc.qc_flags TO stdout WITH DELIMITER ',' CSV QUOTE AS '''' FORCE QUOTE flag_value, flag_meaning, flag_description ESCAPE AS ',';
CREATE TABLE parameters.qc_flags
(
  id integer NOT NULL,
  qc_scheme_id integer,
  flag_value character varying(2),
  flag_meaning character varying(100),
  flag_description character varying(500),
  CONSTRAINT qc_flags_pkey PRIMARY KEY (id),
  CONSTRAINT qc_flags_fkey FOREIGN KEY (qc_scheme_id)
      REFERENCES qc.qc_scheme (qc_scheme_id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)

INSERT INTO parameters.qc_flags (id ,
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
(35,4,'L','Value located over land ',''),
(36,4,'T','Time duplicate ',''),
(37,4,'U','Suspect data (statistical) ',''),
(38,4,'V','Spike in data (statistical) ',''),
(39,4,'X','Step in data (statistical) ',''),
(40,4,'Z','Value passes all test ',''),
(41,5,'2','Good',''),
(42,5,'3','Questionable',''),
(43,5,'4','Bad',''),
(44,6,'1','Outside of standard range',''),
(45,6,'2','Questionable/interpolated SST (Sea Surface Temperature) ',''),
(46,6,'3','Questionable EQU temperature ',''),
(47,6,'4','Anomalous (EQU T-SST) (+- 1 C) ',''),
(48,6,'5','Questionable sea-surface salinity',''),
(49,6,'6','Questionable pressure',''),
(50,6,'7','Low EQU gas flow',''),
(51,6,'8','Questionable air value',''),
(52,6,'10','Other, water flow','')

COPY qc.qc_scheme TO stdout WITH DELIMITER ',' CSV QUOTE AS '''' FORCE QUOTE qc_scheme_short_name, qc_scheme_definition ESCAPE AS ',';
CREATE TABLE parameters.qc_scheme
(
  qc_scheme_id integer NOT NULL,
  qc_scheme_short_name character varying(50),
  qc_scheme_definition character varying(255),
  CONSTRAINT qc_scheme_pkey PRIMARY KEY (qc_scheme_id)
);

INSERT INTO parameters.qc_scheme (qc_scheme_id,
  qc_scheme_short_name,
  qc_scheme_definition) 
 VALUES (1,'IMOS IODE','IMOS standard set using the IODE flags'),
(2,'Argo measurement flag scale','ARGO quality control procedure for measurements'),
(3,'Argo profile quality flags','ARGO quality control procedure for profiles'),
(4,'BOM','BOM (SST and Air-Sea flux) quality control procedure'),
(5,'WOCE QC flags','WOCE quality control flags (Multidisciplinary Underway Network - CO2 measurements)'),
(6,'WOCE QC subflags','WOCE QC subflags are used to provide more information if CO2 observations are flagged as questionable')


COPY soop_sst.soop_sst_variables TO stdout WITH DELIMITER ',' CSV QUOTE AS '''' FORCE QUOTE variable_name, unit_info ESCAPE AS ',';
CREATE TABLE parameters.parameters_mapping
( facility character varying(10),
  subfacility character varying(50),
  product character varying(50),
  variable_name character varying(50) NOT NULL,
  parameter_id integer,
  unit_id integer,
  unit_info character varying(255),
  CONSTRAINT parameters_mapping_pkey PRIMARY KEY (facility, subfacility, product, variable_name)
);
INSERT INTO parameters.parameters_mapping
VALUES ('SOOP','SST','','AIRT',1,429,''),
('SOOP','SST','','ATMP',10,511,''),
('SOOP','SST','','CNDC',2,483,''),
('SOOP','SST','','CNDC_2',2,483,''),
('SOOP','SST','','CNDC_3',2,483,''),
('SOOP','SST','','DEWT',3,429,''),
('SOOP','SST','','GPS_HEIGHT',18,431,''),
('SOOP','SST','','LATITUDE',4,440,'Degrees North'),
('SOOP','SST','','LONGITUDE',5,440,'Degrees East'),
('SOOP','SST','','PL_CRS',6,441,'Clockwise from True North'),
('SOOP','SST','','PL_SPD',7,433,''),
('SOOP','SST','','PL_WDIR',16,441,'Clockwise from True North'),
('SOOP','SST','','PL_WSPD',17,433,''),
('SOOP','SST','','PSAL',12,481,''),
('SOOP','SST','','PSAL_2',12,481,''),
('SOOP','SST','','PSAL_3',12,481,''),
('SOOP','SST','','RAD_PAR',15,585,''),
('SOOP','SST','','RELH',14,446,''),
('SOOP','SST','','TEMP',13,429,''),
('SOOP','SST','','TEMP_2',13,429,''),
('SOOP','SST','','TEMP_3',13,429,''),
('SOOP','SST','','TEMP_4',13,429,''),
('SOOP','SST','','WDIR',8,441,'Clockwise from True North'),
('SOOP','SST','','WETT',11,429,''),
('SOOP','SST','','WSPD',9,433,'')

CREATE VIEW parameters.soop_sst_metadata_summary AS
SELECT 'data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'unit_info'
UNION ALL

SELECT variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || vocabulary_term_name || ',' || vocabulary_term_short_name || ',' || unit_info
FROM parameters.parameters_mapping
LEFT JOIN contr_vocab_db.unit_view ON parameters_mapping.unit_id = unit_view.vocabulary_term_code
LEFT JOIN parameters.parameters ON parameters.unique_id = parameters_mapping.parameter_id
WHERE facility = 'SOOP' AND subfacility = 'SST'
UNION ALL

SELECT ''
UNION ALL

SELECT 'qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL

SELECT qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
FROM parameters.qc_flags
LEFT JOIN parameters.qc_scheme ON qc_scheme.qc_scheme_id = qc_flags.qc_scheme_id
WHERE qc_flags.qc_scheme_id = 4;

SELECT * FROM parameters.soop_sst_metadata_summary