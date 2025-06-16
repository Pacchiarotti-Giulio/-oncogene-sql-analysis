-- Get all pathways associated with a specific protein entry
SELECT DISTINCT s.`Path String`
FROM pathway_signaling s
JOIN protein_unique p ON s.Protein = p.`Gene Names (primary)`
WHERE p.Entry = 'P00519';

-- Get all proteins associated with a specific pathway (e.g., ANGIOGENESIS)
SELECT DISTINCT s.Protein, p.Entry AS protein_entry
FROM pathway_signaling s
JOIN protein_unique p ON s.Protein = p.`Gene Names (primary)`
WHERE s.Hallmark = 'ANGIOGENESIS' AND s.Protein = 'ABL1';

-- Find gene with highest number of associated pathways
SELECT d.symbol, COUNT(s.`Path String`) AS num_pathways 
FROM driver_genes d 
JOIN pathway_signaling s ON d.symbol = s.Protein
GROUP BY d.symbol 
HAVING COUNT(s.`Path String`) = (
    SELECT MAX(pathway_count) FROM (
        SELECT COUNT(`Path String`) AS pathway_count
        FROM pathway_signaling
        GROUP BY Protein
    ) AS counts
);

-- Get all pathways linked to a given cancer driver gene
SELECT DISTINCT s.`Path String`
FROM pathway_signaling s
JOIN (
    SELECT d.symbol, c.cancer_type, d.Entry
    FROM driver_genes d
    JOIN cancer_drivers c ON d.driver_id = c.driver_id
    WHERE d.symbol = 'ABL1'
) AS temp ON s.Entry = temp.Entry;

-- Count of pathways activated per motif (positive effect only)
SELECT m.name, COUNT(*) AS count
FROM motifs m
JOIN motif_protein mp ON mp.motif_ac = m.motif_ac
JOIN pathway_signaling s ON s.Entry = mp.protein_ac
WHERE s.`Final Effect` = 1
GROUP BY m.name;

-- Proteins with motifs having only positive or only negative effect
SELECT DISTINCT m2.name, s.`Final Effect`
FROM motifs m2
JOIN motif_protein mp ON mp.motif_ac = m2.motif_ac
JOIN pathway_signaling s ON s.Entry = mp.protein_ac
WHERE m2.name IN (
    SELECT m.name FROM motifs m
    JOIN motif_protein mp ON mp.motif_ac = m.motif_ac
    JOIN pathway_signaling s ON s.Entry = mp.protein_ac
    WHERE s.`Final Effect` = 1
)
XOR m2.name IN (
    SELECT m.name FROM motifs m
    JOIN motif_protein mp ON mp.motif_ac = m.motif_ac
    JOIN pathway_signaling s ON s.Entry = mp.protein_ac
    WHERE s.`Final Effect` = -1
);

-- Most frequent motif in cancer driver genes
SELECT m.name, COUNT(*) AS count
FROM motifs m
JOIN motif_protein mp ON mp.motif_ac = m.motif_ac
JOIN driver_genes d ON d.Entry = mp.protein_ac
JOIN cancer_drivers c ON d.driver_id = c.driver_id
GROUP BY m.name
HAVING COUNT(*) = (
    SELECT MAX(motif_count) FROM (
        SELECT COUNT(*) AS motif_count
        FROM motifs m
        JOIN motif_protein mp ON mp.motif_ac = m.motif_ac
        JOIN driver_genes d ON d.Entry = mp.protein_ac
        JOIN cancer_drivers c ON d.driver_id = c.driver_id
        GROUP BY m.name
    ) AS counts
);

-- Motif pattern and protein subsequence match
SELECT temp.protein_ac AS accession, temp.motif_pattern,
       SUBSTRING(temp.sequence FROM temp.start_pos FOR 20) AS matched_sequence
FROM (
    SELECT m.pattern AS motif_pattern, m.motif_ac, pg.Entry AS protein_ac,
           pg.Sequence AS sequence, pos.start AS start_pos, pos.stop
    FROM motifs m
    JOIN motif_protein mp ON m.motif_ac = mp.motif_ac
    JOIN motif_positions pos ON pos.position_id = mp.position_id
    JOIN protein_unique pg ON mp.protein_ac = pg.Entry
    WHERE m.pattern <> ''
) AS temp;

-- Subcellular localization of cancer driver proteins
SELECT DISTINCT x.gene_name,
    SUBSTRING(
        x.location,
        LOCATE('SUBCELLULAR LOCATION: ', x.location) + LENGTH('SUBCELLULAR LOCATION: '),
        LOCATE('{', x.location) - LOCATE('SUBCELLULAR LOCATION: ', x.location) - LENGTH('SUBCELLULAR LOCATION: ')
    ) AS subcellular_location
FROM (
    SELECT DISTINCT pg.`Subcellular location [CC]` AS location, d.Entry AS gene_name
    FROM protein_unique pg
    JOIN driver_genes d ON pg.Entry = d.Entry
    WHERE d.driver_type = 'cancer' AND pg.`Subcellular location [CC]` IS NOT NULL
) AS x;
