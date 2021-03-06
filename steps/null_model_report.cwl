class: CommandLineTool
cwlVersion: v1.1
$namespaces:
  sbg: https://sevenbridges.com
id: boris_majic/genesis-toolkit-demo/null-model-report/29
baseCommand: []
inputs:
- sbg:category: General
  id: family
  type:
    type: enum
    symbols:
    - gaussian
    - binomial
    - poisson
    name: family
  label: Family
  doc: 'Possible values: Gaussian, Binomial, Poisson'
- sbg:category: General
  sbg:toolDefaultValue: 'TRUE'
  id: inverse_normal
  type:
  - 'null'
  - type: enum
    symbols:
    - 'TRUE'
    - 'FALSE'
    name: inverse_normal
  label: Inverse normal
  doc: TRUE if an inverse-normal transform should be applied to the outcome variable.
    If Group variate is provided, the transform is done on each group separately.
    Default value is TRUE.
- sbg:category: Inputs
  id: null_model_params
  type: File
  label: Null Model Params
  doc: .params file generated by null model.
  sbg:fileTypes: params
- sbg:category: Null model
  id: phenotype_file
  type: File?
  label: Phenotype file
  doc: RData file with AnnotatedDataFrame of phenotypes.
  sbg:fileTypes: RData
- sbg:category: Null model
  id: sample_include_file
  type: File?
  label: Sample include file
  doc: RData file with vector of sample.id to include.
  sbg:fileTypes: RData
- sbg:category: Null model
  id: pca_file
  type: File?
  label: PCA File
  doc: RData file with PCA results created by PC-AiR.
  sbg:fileTypes: RData
- sbg:category: Null model
  id: relatedness_matrix_file
  type: File?
  label: Relatedness Matrix File
  doc: RData or GDS file with a kinship matrix or GRM.
  sbg:fileTypes: GDS, RData, gds, RDATA
- id: null_model_files
  type: File[]?
  label: Null model files
  doc: Null model files.
- id: output_prefix
  type: string?
  label: Output prefix
  doc: Output prefix.
- sbg:category: General
  id: conditional_variant_file
  type: File?
  label: Conditional variant file
  doc: Conditional variant file
  sbg:fileTypes: RData, RDATA
- sbg:category: General
  id: gds_files
  type: File[]?
  label: GDS Files
  doc: GDS files
  sbg:fileTypes: GDS
- sbg:toolDefaultValue: '10'
  id: n_categories_boxplot
  type: int?
  label: Number of categories in boxplot
  doc: Number of categories in boxplot
  default: 10
outputs:
- id: html_reports
  doc: HTML Reports generated by the tool.
  label: HTML Reports
  type: File[]?
  outputBinding:
    glob: '*.html'
  sbg:fileTypes: html
- id: rmd_files
  doc: R markdown files used to generate the HTML reports.
  label: Rmd files
  type: File[]?
  outputBinding:
    glob: '*.Rmd'
  sbg:fileTypes: Rmd
- id: null_model_report_config
  doc: Null model report config
  label: Null model report config
  type: File?
  outputBinding:
    glob: '*config'
label: null_model_report
arguments:
- prefix: ''
  shellQuote: false
  position: 2
  valueFrom: |-
    ${
        return " Rscript /usr/local/analysis_pipeline/R/null_model_report.R null_model_report.config"
    }
- prefix: ''
  shellQuote: false
  position: 100
  valueFrom: |-
    ${
        return ' >> job.out.log'
    }
requirements:
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: uwgac/topmed-master:2.8.1
- class: InitialWorkDirRequirement
  listing:
  - entryname: null_model_report.config
    entry: |-
      ${
          var config = "";
          if(inputs.family)
          {
              config += "family " + inputs.family + "\n";
          }
          
          if(inputs.inverse_normal)
          {
              config += "inverse_normal " + inputs.inverse_normal + "\n";
          }

          if(inputs.output_prefix)
          {
              config += "out_prefix \"" + inputs.output_prefix + "\"\n";
          }
          else
          {
              config += "out_prefix \"null_model\"" + "\n";
          }
          
          if(inputs.n_categories_boxplot){
              
              config += "n_categories_boxplot " + inputs.n_categories_boxplot + "\n";
          }
          return config
      }
    writable: false
  - entry: |-
      ${
          return inputs.null_model_params
      }
    writable: true
  - entry: |-
      ${
          return inputs.phenotype_file
      }
    writable: true
  - entry: |-
      ${
          return inputs.sample_include_file
      }
    writable: true
  - entry: |-
      ${
          return inputs.pca_file
      }
    writable: true
  - entry: |-
      ${
          return inputs.relatedness_matrix_file
      }
    writable: true
  - entry: |-
      ${
          return inputs.null_model_files
      }
    writable: true
  - entry: |-
      ${
          return inputs.conditional_variant_file
      }
    writable: true
  - entry: |-
      ${
          return inputs.gds_files
      }
    writable: true
- class: InlineJavascriptRequirement
hints:
- class: sbg:SaveLogs
  value: job.out.log
sbg:projectName: GENESIS toolkit - DEMO
sbg:revisionsInfo:
- sbg:revision: 0
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1570638120
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-report/0
- sbg:revision: 1
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1570725894
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-report/1
- sbg:revision: 2
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1573061757
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-report/2
- sbg:revision: 3
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1574271142
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-report/4
- sbg:revision: 4
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1591110143
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-report/5
- sbg:revision: 5
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593598494
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-report/6
- sbg:revision: 6
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593611042
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-report/9
- sbg:revision: 7
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593621230
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-report/10
- sbg:revision: 8
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602060536
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-report/11
- sbg:revision: 9
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602065168
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-report/12
- sbg:revision: 10
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602076754
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-report/13
- sbg:revision: 11
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602149870
  sbg:revisionNotes: SaveLogs hint
- sbg:revision: 12
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1603717510
  sbg:revisionNotes: Config cleaning
- sbg:revision: 13
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604504695
  sbg:revisionNotes: cwltool
- sbg:revision: 14
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604504897
  sbg:revisionNotes: cwltool
- sbg:revision: 15
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604505777
  sbg:revisionNotes: cwltool
- sbg:revision: 16
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604914652
  sbg:revisionNotes: Cwltool
- sbg:revision: 17
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604923918
  sbg:revisionNotes: Staged
- sbg:revision: 18
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604925559
  sbg:revisionNotes: Staging
- sbg:revision: 19
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604927522
  sbg:revisionNotes: Cwltool
- sbg:revision: 20
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604960501
  sbg:revisionNotes: Scr.R
- sbg:revision: 21
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604961179
  sbg:revisionNotes: Scr.R
- sbg:revision: 22
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604961573
  sbg:revisionNotes: Scr.R
- sbg:revision: 23
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604962104
  sbg:revisionNotes: Scr.R
- sbg:revision: 24
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604962543
  sbg:revisionNotes: Scr.R
- sbg:revision: 25
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604962858
  sbg:revisionNotes: Notwrittable
- sbg:revision: 26
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604964290
  sbg:revisionNotes: scr.R
- sbg:revision: 27
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604964499
  sbg:revisionNotes: Scr.R
- sbg:revision: 28
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1605004215
  sbg:revisionNotes: Staged
- sbg:revision: 29
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1608120879
  sbg:revisionNotes: Null model report config output added
sbg:image_url:
sbg:appVersion:
- v1.1
sbg:id: boris_majic/genesis-toolkit-demo/null-model-report/29
sbg:revision: 29
sbg:revisionNotes: Null model report config output added
sbg:modifiedOn: 1608120879
sbg:modifiedBy: dajana_panovic
sbg:createdOn: 1570638120
sbg:createdBy: boris_majic
sbg:project: boris_majic/genesis-toolkit-demo
sbg:sbgMaintained: false
sbg:validationErrors: []
sbg:contributors:
- dajana_panovic
- boris_majic
sbg:latestRevision: 29
sbg:publisher: sbg
sbg:content_hash: a0b38889480af037d80fdb4fe89877df92e17601468849e9a8bc0b034cdb3c54a
