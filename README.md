# Oncogene SQL Analysis

This project builds a structured SQL database for exploring oncogenes, their protein products, functional motifs, and signaling pathways.  
The data is collected from biomedical sources and stored in normalized SQL tables to enable complex analytical queries.

Originally developed in collaboration with **Diego Iacuone** and **Aurora Odierno**, this project has been restructured and republished by **Giulio Pacchiarotti** for improved readability, modularity, and GitHub publication.

##  Project Structure

```
oncogene-sql-analysis/
├── datasets/                  # Pre-downloaded CSV/TSV data files
├── notebooks/                 # Jupyter notebook to reproduce data extraction (optional)
├── sql_scripts/               # SQL scripts: db setup & queries
├── docs/                      # ER diagram
├── README.md                  # Project description (this file)
└── requirements.txt           # Python dependencies
```

##  Setup

1. **Clone the repository**  
   ```bash
   git clone https://github.com/Pacchiarotti-Giulio/oncogene-sql-analysis.git
   cd oncogene-sql-analysis
   ```

2. **Install Python dependencies**  
   *(only required if you want to rerun the notebook)*  
   ```bash
   pip install -r requirements.txt
   ```

3. **Prepare your MySQL database**  
   - Use `sql_scripts/db_setup.sql` to create the schema and import tables.
   - Use `sql_scripts/queries_example.sql` to explore relationships and perform advanced queries.

 The data is already included in the `datasets/` folder. Running the notebook `download_data.ipynb` is optional and serves for reproducibility.

 Data Sources

- [UniProt](https://www.uniprot.org/)
- [Prosite](https://prosite.expasy.org/)
- [CancerGeneNet / SIGNOR](https://signor.uniroma2.it/)
- [Network of Cancer Genes (NCG)](https://network-cancer-genes.org/)

##  Bibliography

- **SIGNOR**:  
  Lo Surdo P, Iannuccelli M, Contino S, Castagnoli L, Licata L, Cesareni G, Perfetto L.  
  _SIGNOR 3.0, the SIGnaling network open resource 3.0: 2022 update._  
  Nucleic Acids Res. 2022 Oct 16:gkac883. doi: [10.1093/nar/gkac883](https://doi.org/10.1093/nar/gkac883)

- **Cancer Gene Net**:  
  Dressler, Lisa, et al.  
  _Comparative assessment of genes driving cancer and somatic evolution in non-cancer tissues: an update of the Network of Cancer Genes (NCG) resource._  
  Genome Biology 23.1 (2022): 35.

- **UniProt**:  
  The UniProt Consortium.  
  _UniProt: the Universal Protein Knowledgebase in 2023._  
  Nucleic Acids Research, Volume 51, Issue D1, 6 January 2023, Pages D523–D531.  
  doi: [10.1093/nar/gkac1052](https://doi.org/10.1093/nar/gkac1052)

##  Author

**Giulio Pacchiarotti**  
[LinkedIn](https://www.linkedin.com/in/giulio-pacchiarotti-4aab80265)

##  Acknowledgments
This republished version is based on an original collaboration developed with Diego Aicuone and Aurora Odierno, 
originally published at [diego-iac/Database_Oncogeni](https://github.com/diego-iac/Database_Oncogeni).

