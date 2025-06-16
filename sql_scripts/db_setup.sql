-- Database Initialization
CREATE DATABASE IF NOT EXISTS DB_Basili;
USE DB_Basili;

-- Required tables to be imported manually:
-- - uniprot_info_2
-- - prosite_info
-- - signor_info_corretto
-- - prosite_protein_info_total
-- - drivers

-- ================================
-- Protein Data
-- ================================
CREATE TABLE protein_raw AS
SELECT Entry, `Entry Name`, `Gene Names (primary)`, `Protein names`, Sequence, `Subcellular location [CC]`
FROM DB_Basili.uniprot_info_2;

CREATE TABLE protein_unique AS
SELECT DISTINCT * FROM protein_raw;

DELETE FROM protein_unique
WHERE Entry NOT IN (
    SELECT Entry FROM (
        SELECT MIN(Entry) AS Entry
        FROM protein_unique
        GROUP BY `Gene Names (primary)`
    ) AS temp
);

ALTER TABLE protein_unique 
MODIFY COLUMN Entry VARCHAR(20) NOT NULL;

ALTER TABLE protein_unique 
ADD PRIMARY KEY (Entry);

-- ================================
-- SIGNOR Data
-- ================================
CREATE TABLE signor_raw AS
SELECT `Path String`, `Final Effect`, `Protein`, Hallmark
FROM signor_info_corretto;

CREATE TABLE pathway_signaling AS
SELECT s.*, p.Entry
FROM signor_raw s
JOIN protein_unique p ON s.Protein = p.`Gene Names (primary)`;

ALTER TABLE pathway_signaling
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY,
ADD FOREIGN KEY (Entry) REFERENCES protein_unique(Entry);

DROP TABLE protein_raw;
DROP TABLE signor_raw;

-- ================================
-- Driver Genes
-- ================================
ALTER TABLE DB_Basili.drivers 
RENAME TO drivers_original;

ALTER TABLE drivers_original 
ADD COLUMN driver_id INT AUTO_INCREMENT PRIMARY KEY;

CREATE TABLE drivers_temp AS
SELECT entrez, symbol, pubmed_id, organ_system, driver_type, driver_id
FROM drivers_original;

CREATE TABLE driver_genes AS 
SELECT d.*, p.Entry
FROM drivers_temp d
JOIN protein_unique p ON d.symbol = p.`Gene Names (primary)`;

ALTER TABLE driver_genes 
ADD PRIMARY KEY (driver_id);

ALTER TABLE driver_genes
ADD FOREIGN KEY (Entry) REFERENCES protein_unique(Entry);

DROP TABLE drivers_temp;

CREATE TABLE cancer_drivers (
    driver_id INT PRIMARY KEY,
    driver_type VARCHAR(20),
    primary_site VARCHAR(40),
    cancer_type VARCHAR(100),
    method VARCHAR(200)
);

INSERT INTO cancer_drivers
SELECT driver_id, driver_type, primary_site, cancer_type, method
FROM drivers_original
WHERE driver_type = 'cancer';

CREATE TABLE healthy_drivers (
    driver_id INT PRIMARY KEY,
    driver_type VARCHAR(20)
);

INSERT INTO healthy_drivers
SELECT driver_id, driver_type
FROM driver_genes
WHERE driver_type = 'healthy';

-- ================================
-- Motifs and Positional Data
-- ================================
ALTER TABLE prosite_protein_info_total
ADD COLUMN pos_id INT AUTO_INCREMENT PRIMARY KEY;

CREATE TABLE motif_positions (
    position_id INT AUTO_INCREMENT,
    start INT,
    stop INT,
    PRIMARY KEY(position_id)
);

INSERT INTO motif_positions(start, stop, position_id)
SELECT start, stop, pos_id
FROM prosite_protein_info_total;

CREATE TABLE motifs (
    motif_ac VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100),
    description VARCHAR(100),
    pattern VARCHAR(400)
);

INSERT INTO motifs
SELECT accession, name, description, pattern
FROM prosite_info;

CREATE TABLE raw_motif_protein (
    motif_ac VARCHAR(50),
    position_id INT,
    protein_ac VARCHAR(50),
    PRIMARY KEY(protein_ac, motif_ac, position_id)
);

INSERT INTO raw_motif_protein(motif_ac, position_id, protein_ac)
SELECT signature_ac, pos_id, uniprot_ac
FROM prosite_protein_info_total;

CREATE TABLE motif_protein AS 
SELECT mp.*
FROM raw_motif_protein mp
JOIN motifs m ON m.motif_ac = mp.motif_ac
JOIN protein_unique p ON p.Entry = mp.protein_ac;

ALTER TABLE motif_protein
ADD CONSTRAINT fk_protein FOREIGN KEY (protein_ac) REFERENCES protein_unique(Entry),
ADD CONSTRAINT fk_position FOREIGN KEY (position_id) REFERENCES motif_positions(position_id),
ADD CONSTRAINT fk_motif FOREIGN KEY (motif_ac) REFERENCES motifs(motif_ac);

-- Sample queries are provided separately in 'queries_example.sql'
