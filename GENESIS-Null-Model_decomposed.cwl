dct:creator:
  "@id": "sbg"
  foaf:name: SevenBridges
  foaf:mbox: "mailto:support@sbgenomics.com"
$namespaces:
  sbg: https://sevenbridges.com
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/

class: Workflow
cwlVersion: v1.1
doc: |-
  **Null Model** workflow fits the regression or mixed effects model under the null hypothesis of no genotype effects. i.e., The outcome variable is regressed on the specified fixed effect covariates and random effects. The output of this null model is then used in the association tests.

  Quantitative and binary outcomes are both supported. Set parameter **family** to gaussian, binomial or poisson depending on the outcome type. Fixed effect covariates from the **Phenotype file** are specified using the **Covariates** parameter, and ancestry principal components can be included as fixed effects using the **PCA Files** and **Number of PCs to include as covariates** parameters. A kinship matrix (KM) or genetic relationship matrix (GRM) can be provided using the **Relatedness matrix file** parameter to account for genetic similarity among samples as a random effect. 

  When no **Relatedness matrix file** is provided, standard linear regression is used if the parameter **family** is set to gaussian, logistic regression is used if the parameter **family** is set to binomial and poisson regression is used in case when **family** is set to poisson. When **Relatedness matrix file** is provided, a linear mixed model (LMM) is fit if **family** is set to gaussian, or a generalized linear mixed model (GLMM) is fit using the [GMMAT method](https://doi.org/10.1016/j.ajhg.2016.02.012) if **family** is set to binomial or poisson. For either the LMM or GLMM, the [AI-REML algorithm](https://doi.org/10.1111/jbg.12398) is used to estimate the variance components and fixed effects parameters.
   
  When samples come from multiple groups (e.g., study or ancestry group), it is common to observe different variances by group for quantitative traits. It is recommended to allow the null model to fit heterogeneous residual variances by group using the parameter group_var. This often provides better control of false positives in subsequent association testing. Note that this only applies when **family** is set to gaussian.

  Rank-based inverse Normal transformation is supported for quantitative outcomes via the inverse_normal parameter. This parameter is TRUE by default. When **inverse normal** parameter is set to TRUE, (1) the null model is fit using the original outcome values, (2) the marginal residuals are rank-based inverse Normal transformed, and (3) the null model is fit again using the transformed residuals as the outcome; fixed effects and random effects are included both times the null model is fit. It has been shown that this fully adjusted two-stage procedure provides better false positive control and power in association tests than simply inverse Normalizing the outcome variable prior to analysis [(**reference**)](https://doi.org/10.1002/gepi.22188).

  This workflow utilizes the *fitNullModel* function from the [GENESIS](doi.org/10.1093/bioinformatics/btz567) software.

  Workflow consists of two steps. First step fits the null model, and the second one generates reports based on data. Reports are available both in RMD and HTML format. If **inverse normal** is TRUE, reports are generated for the model both before and after the transformation.
  Reports contain the following information: Config info, phenotype distributions, covariate effect size estimates, marginal residuals, adjusted phenotype values and session information.

  ### Common use cases:
  This workflow is the first step in association testing. This workflow fits the null model and produces several files which are used in the association testing workflows:
  * Null model file which contains adjusted outcome values, the model matrix, the estimated covariance structure, and other parameters required for downstream association testing. This file will be input in association testing workflows.
  * Phenotype file which is a subset of the provided phenotype file, containing only the outcome and covariates used in fitting null model.
  * *Reportonly* null model file which is used to generate the report for the association test


  This workflow can be used for trait heritability estimation.

  Individual genetic variants or groups of genetic variants can be directly tested for association with this workflow by including them as fixed effect covariates in the model (via the **Conditional Variant File** parameter). This would be extremely inefficient genome-wide, but is useful for follow-up analyses testing variants of interest.


  ### Common issues and important notes:
  * If **PCA File** is not provided, the **Number of PCs to include as covariates** parameter **must** be set to 0.

  * **PCA File** must be an RData object output from the *pcair* function in the GENESIS package.

  * The null model job can be very computationally demanding in large samples (e.g. > 20K). GENESIS supports using sparse representations of matrices in the **Relatedness matrix file** via the R Matrix package, and this can substantially reduce memory usage and CPU time.

  ### Performance Benchmarking

  In the following table you can find estimates of running time and cost on spot instances. 
        
  | Samples &nbsp; &nbsp;| Relatedness matrix &nbsp; &nbsp; | Instance type &nbsp; &nbsp;| Instance &nbsp;  &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;  &nbsp; &nbsp;&nbsp; &nbsp;| Time   &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; | Cost  |
  | ------- | --------------------- | ---------------- | -------------- | ----------- | ----- |
  | 2.5K    | w/o                   | Spot             | c4xlarge       | 5 min       | 0.01$ |
  | 10K     | w/o                   | Spot             | r4.8xlarge     | 6 min       | 0.06$ |
  | 36K     | w/o                   | Spot             | r4.8xlarge     | 7 min       | 0.06$ |
  | 50K     | w/o                   | Spot             | r4.8xlarge     | 7 min       | 0.07$ |
  | 2.5K    | Sparse                | Spot             | c4xlarge       | 5 min       | 0.01$ |
  | 10K     | Sparse                | Spot             | r4.8xlarge     | 8 min       | 0.06$ |
  | 36K     | Sparse                | Spot             | r4.8xlarge     | 40 min      | 0.40$ |
  | 50K     | Sparse                | Spot             | r4.8xlarge     | 50 min      | 0.50$ |
  | 2.5K    | Dense                 | Spot             | c4.xlarge      | 5 min       | 0.01$ |
  | 10K     | Dense                 | Spot             | c4.2xlarge     | 13 min      | 0.06$ |
  | 36K     | Dense                 | Spot             | r4.4xlarge     | 55 min      | 0.45$ |
  | 50K     | Dense                 | Spot             | r4.8xlarge     | 2 h         | 1.50$ |
  | 2.5K    | w/o                   | Preemtible       | n1-standard-4  | 5 min       | 0.01$ |
  | 10K     | w/o                   | Preemtible       | n1-standard-32 | 6 min       | 0.05$ |
  | 36K     | w/o                   | Preemtible       | n1-hihgmem-32  | 8 min       | 0.06$ |
  | 50K     | w/o                   | Preemtible       | n1-hihgmem-32  | 7 min       | 0.06$ |
  | 2.5K    | Sparse                | Preemtible       | n1-standard-4  | 5 min       | 0.01$ |
  | 10K     | Sparse                | Preemtible       | n1-hihgmem-32  | 7 min       | 0.06$ |
  | 36K     | Sparse                | Preemtible       | n1-hihgmem-32  | 40 min      | 0.30$ |
  | 50K     | Sparse                | Preemtible       | n1-hihgmem-32  | 50 min      | 0.45$ |
  | 2.5K    | Dense                 | Preemtible       | n1-highcpu-8   | 10 min      | 0.01$ |
  | 10K     | Dense                 | Preemtible       | n1-highcpu-16  | 12 min      | 0.04$ |
  | 36K     | Dense                 | Preemtible       | n1-standard-32 | 43 min      | 1$    |
  | 50K     | Dense                 | Preemtible       | n1-standard-96 | 2 h, 30 min | 12$   |


  *Cost shown here were obtained with **spot/preemptible instances** enabled. Visit the [Knowledge Center](https://docs.sevenbridges.com/docs/about-spot-instances) for more details.*
label: Null Model
$namespaces:
  sbg: https://sevenbridges.com
inputs:
- id: n_pcs
  type: int?
  label: Number of PCs to include as covariates
  doc: Number of PCs from PCA file to include as covariates.
  sbg:toolDefaultValue: '0'
  sbg:x: -598.6190185546875
  sbg:y: 372.05194091796875
- id: sample_include_file
  sbg:fileTypes: RDATA
  type: File?
  label: Sample include file
  doc: RData file with a vector of sample.id to include. If not provided, all samples
    in the Phenotype file will be included in the analysis.
  sbg:x: -490.25
  sbg:y: -666.1776123046875
- id: phenotype_file
  sbg:fileTypes: RDATA
  type: File
  label: Phenotype file
  doc: RData file with an AnnotatedDataFrame of phenotypes and covariates. Sample
    identifiers must be in column named “sample.id”.
  sbg:x: -597.75
  sbg:y: -621.5
- id: pca_file
  sbg:fileTypes: RDATA
  type: File?
  label: PCA File
  doc: RData file containing principal components for ancestry adjustment. R object
    type may be “pcair”, data.frame, or matrix. Row names must contain sample identifiers.
  sbg:x: -598.75
  sbg:y: -489.25
- id: output_prefix
  type: string?
  label: Output prefix
  doc: Base for all output file names. By default it is null_model.
  sbg:x: -485.25
  sbg:y: -441.75
- id: cpu
  type: int?
  label: CPU
  doc: Number of CPUs to use per job.
  sbg:toolDefaultValue: '1'
  sbg:x: -530.887451171875
  sbg:y: 457.2684020996094
- id: covars
  type: string[]?
  label: Covariates
  doc: Names of columns in Phenotype file containing covariates.
  sbg:x: -401.9177551269531
  sbg:y: 601.9609985351562
- id: inverse_normal
  type:
  - 'null'
  - type: enum
    symbols:
    - 'TRUE'
    - 'FALSE'
    name: inverse_normal
  label: Two stage model
  doc: 'TRUE if a two-stage model should be implemented. Stage 1: a null model is
    fit using the original outcome variable. Stage 2: a second null model is fit using
    the inverse-normal transformed residuals from Stage 1 as the outcome variable.
    When FALSE, only the Stage 1 model is fit.  Only applies when Family is “gaussian”.'
  sbg:toolDefaultValue: 'TRUE'
  sbg:x: -710.1770629882812
  sbg:y: 173.76121520996094
- id: outcome
  type: string
  label: Outcome
  doc: Name of column in Phenotype file containing outcome variable.
  sbg:x: -744.6608276367188
  sbg:y: 56.6402587890625
- id: rescale_variance
  type:
  - 'null'
  - type: enum
    symbols:
    - marginal
    - varcomp
    - none
    name: rescale_variance
  label: Rescale residuals
  doc: Applies only if Two stage model is TRUE. Controls whether to rescale the inverse-normal
    transformed residuals before fitting the Stage 2 null model, restoring the values
    to their original scale before the transform. “Marginal” rescales by the standard
    deviation of the marginal residuals from the Stage 1 model. “Varcomp” rescales
    by an estimate of the standard deviation based on the Stage 1 model variance component
    estimates; this can only be used if Norm by group is TRUE. “None” does not rescale.
  sbg:toolDefaultValue: marginal
  sbg:x: -739.3484497070312
  sbg:y: -190.6490020751953
- id: group_var
  type: string?
  label: Group variate
  doc: Name of column in Phenotype file providing groupings for heterogeneous residual
    error variances in the model. Only applies when Family is “gaussian”.
  sbg:x: -647.8939819335938
  sbg:y: 273.9382629394531
- id: conditional_variant_file
  sbg:fileTypes: RDATA
  type: File?
  label: Conditional Variant File
  doc: RData file with a data.frame of identifiers for variants to be included as
    covariates for conditional analysis. Columns should include “chromosome” and “variant.id”
    that match the variant.id in the GDS files. The alternate allele dosage of these
    variants will be included as covariates in the analysis.
  sbg:x: -466
  sbg:y: 527.7529907226562
- id: relatedness_matrix_file
  sbg:fileTypes: GDS, RDATA
  type: File?
  label: Relatedness matrix file
  doc: RData or GDS file with a kinship matrix or genetic relatedness matrix (GRM).
    For RData files, R object type may be “matrix” or “Matrix”. For very large sample
    sizes, a block diagonal sparse Matrix object from the “Matrix” package is recommended.
  sbg:x: -723.1589965820312
  sbg:y: -545.7281494140625
- id: gds_files
  sbg:fileTypes: GDS
  type: File[]?
  label: GDS Files
  doc: List of gds files with genotype data for variants to be included as covariates
    for conditional analysis. Only required if Conditional Variant file is specified.
  sbg:x: -773.5831298828125
  sbg:y: -57.84101486206055
- id: norm_bygroup
  type:
  - 'null'
  - type: enum
    symbols:
    - 'TRUE'
    - 'FALSE'
    name: norm_bygroup
  label: Norm by group
  doc: Applies only if Two stage model is TRUE and Group variate is provided. If TRUE,the
    inverse-normal transformation (and rescaling) is done on each group separately.
    If FALSE, this is done on all samples jointly.
  sbg:toolDefaultValue: 'FALSE'
  sbg:x: -171.19671630859375
  sbg:y: 693.8524780273438
- id: family
  type:
    type: enum
    symbols:
    - gaussian
    - poisson
    - binomial
    name: family
  label: Family
  doc: The distribution used to fit the model. Select “gaussian” for continuous outcomes,
    “binomial” for binary or case/control outcomes, or “poisson” for count outcomes.
  sbg:x: -220.80503845214844
  sbg:y: 532.3207397460938
- id: n_categories_boxplot
  type: int?
  label: Number of categories in boxplot
  doc: If a covariate has fewer than the specified value, boxplots will be used instead
    of scatter plots for that covariate in the null model report.
  sbg:x: 221.18121337890625
  sbg:y: 235.75128173828125
outputs:
- id: null_model_phenotypes
  outputSource:
  - null_model_r/null_model_phenotypes
  sbg:fileTypes: RDATA
  type: File?
  label: Null model Phenotypes file
  doc: Phenotype file containing all covariates used in the model. This file should
    be used as the “Phenotype file” input for the GENESIS association testing workflows.
  sbg:x: 461.51287841796875
  sbg:y: 53.166748046875
- id: rmd_files
  outputSource:
  - null_model_report/rmd_files
  sbg:fileTypes: Rmd
  type: File[]?
  label: Rmd files
  doc: R markdown files used to generate the HTML reports.
  sbg:x: 774.503173828125
  sbg:y: -378.1446533203125
- id: html_reports
  outputSource:
  - null_model_report/html_reports
  sbg:fileTypes: html
  type: File[]?
  label: HTML Reports
  sbg:x: 784.3648071289062
  sbg:y: -109
- id: null_model_output
  outputSource:
  - null_model_r/null_model_output
  type: File[]?
  label: Null model file
  sbg:x: 465.3710632324219
  sbg:y: 341.66351318359375
steps:
  null_model_r:
    in:
    - id: outcome
      source: outcome
    - id: phenotype_file
      source: phenotype_file
    - id: gds_files
      source:
      - gds_files
    - id: pca_file
      source: pca_file
    - id: relatedness_matrix_file
      source: relatedness_matrix_file
    - id: family
      source: family
    - id: conditional_variant_file
      source: conditional_variant_file
    - id: covars
      source:
      - covars
    - id: group_var
      source: group_var
    - id: inverse_normal
      source: inverse_normal
    - id: n_pcs
      source: n_pcs
    - id: rescale_variance
      source: rescale_variance
    - id: sample_include_file
      source: sample_include_file
    - id: cpu
      source: cpu
    - id: output_prefix
      source: output_prefix
    - id: norm_bygroup
      source: norm_bygroup
    out:
    - id: configs
    - id: null_model_phenotypes
    - id: null_model_files
    - id: null_model_params
    - id: null_model_output
    run: steps/null_model_r.cwl
    label: Fit Null Model
    sbg:x: 5.5
    sbg:y: 19.75
  null_model_report:
    in:
    - id: family
      source: family
    - id: inverse_normal
      source: inverse_normal
    - id: null_model_params
      source: null_model_r/null_model_params
    - id: phenotype_file
      source: phenotype_file
    - id: sample_include_file
      source: sample_include_file
    - id: pca_file
      source: pca_file
    - id: relatedness_matrix_file
      source: relatedness_matrix_file
    - id: null_model_files
      source:
      - null_model_r/null_model_files
    - id: output_prefix
      source: output_prefix
    - id: conditional_variant_file
      source: conditional_variant_file
    - id: gds_files
      source:
      - gds_files
    - id: n_categories_boxplot
      source: n_categories_boxplot
    out:
    - id: html_reports
    - id: rmd_files
    - id: null_model_report_config
    run: steps/null_model_report.cwl
    label: Null Model Report
    sbg:x: 474.8600769042969
    sbg:y: -248.57232666015625
requirements:
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement
sbg:projectName: GENESIS pipelines - DEMO
sbg:revisionsInfo:
- sbg:revision: 0
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1571921340
  sbg:revisionNotes: Copy of boris_majic/genesis-pipelines-dev/null-model/6
- sbg:revision: 1
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1574269224
  sbg:revisionNotes: Copy of boris_majic/genesis-pipelines-dev/null-model/14
- sbg:revision: 2
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1575642956
  sbg:revisionNotes: Copy of boris_majic/genesis-pipelines-dev/null-model/15
- sbg:revision: 3
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1576765551
  sbg:revisionNotes: Copy of boris_majic/genesis-pipelines-dev/null-model/16
- sbg:revision: 4
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1580990768
  sbg:revisionNotes: Copy of boris_majic/genesis-pipelines-dev/null-model/20
- sbg:revision: 5
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1583937759
  sbg:revisionNotes: Copy of boris_majic/genesis-pipelines-dev/null-model/22
- sbg:revision: 6
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1584372098
  sbg:revisionNotes: Final Wrap
- sbg:revision: 7
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1591621996
  sbg:revisionNotes: Null model report updated
- sbg:revision: 8
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593599483
  sbg:revisionNotes: 'New docker image: 2.8.0 and null_model input excluded'
- sbg:revision: 9
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593613764
  sbg:revisionNotes: Description updated
- sbg:revision: 10
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593693054
  sbg:revisionNotes: Input descriptions updated on nod level
- sbg:revision: 11
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1596459813
  sbg:revisionNotes: Benchmarking updated
- sbg:revision: 12
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1600431373
  sbg:revisionNotes: Benchmarking updated
- sbg:revision: 13
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1600673447
  sbg:revisionNotes: Benchmarking table updated
- sbg:revision: 14
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602062011
  sbg:revisionNotes: Docker 2.8.1 and SaveLogs hint
- sbg:revision: 15
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602069532
  sbg:revisionNotes: SaveLogs update
- sbg:revision: 16
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602143534
  sbg:revisionNotes: Input description update
- sbg:revision: 17
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602156414
  sbg:revisionNotes: Version 2.8.1
- sbg:revision: 18
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602246467
  sbg:revisionNotes: Input and output description updated
- sbg:revision: 19
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602573484
  sbg:revisionNotes: Report only excluded from the output
- sbg:revision: 20
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1603284498
  sbg:revisionNotes: Family corrected
- sbg:revision: 21
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1603796948
  sbg:revisionNotes: Config cleaning
- sbg:revision: 22
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1603903133
  sbg:revisionNotes: Config cleaning
- sbg:revision: 23
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1603962791
  sbg:revisionNotes: Config cleaning
- sbg:revision: 24
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1606726822
  sbg:revisionNotes: CWLtool compatible
- sbg:revision: 25
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1608903269
  sbg:revisionNotes: CWLtool compatible
sbg:image_url: https://platform.sb.biodatacatalyst.nhlbi.nih.gov/ns/brood/images/boris_majic/genesis-pipelines-demo/null-model/25.png
sbg:license: MIT
sbg:categories:
- GWAS
- Genomics
- CWL1.0
sbg:toolAuthor: TOPMed DCC
sbg:appVersion:
- v1.1
id: https://api.sb.biodatacatalyst.nhlbi.nih.gov/v2/apps/boris_majic/genesis-pipelines-demo/null-model/25/raw/
sbg:id: boris_majic/genesis-pipelines-demo/null-model/25
sbg:revision: 25
sbg:revisionNotes: CWLtool compatible
sbg:modifiedOn: 1608903269
sbg:modifiedBy: dajana_panovic
sbg:createdOn: 1571921340
sbg:createdBy: boris_majic
sbg:project: boris_majic/genesis-pipelines-demo
sbg:sbgMaintained: false
sbg:validationErrors: []
sbg:contributors:
- dajana_panovic
- boris_majic
sbg:latestRevision: 25
sbg:publisher: sbg
sbg:content_hash: ac551f1d6aa93ab8e45aecd78b1941a0772a987704799f2eaff7fad1e4be9e7cb
